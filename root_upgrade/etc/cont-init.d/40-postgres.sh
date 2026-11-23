#!/usr/bin/with-contenv sh

# Prepares the PostgreSQL data directory.
#
#  * no cluster yet            -> initdb (fresh install)
#  * cluster of this version   -> nothing to do
#  * cluster of an OLDER major -> automatic in-place upgrade with pg_upgrade
#                                 (see migrate_cluster below)
#
# This runs in the s6 cont-init stage, i.e. BEFORE any service (including
# postgres) is started, so nothing can be writing to the database while we work.
#
# pg_upgrade needs the server binaries of the OLD major. They are not shipped in
# the image: they are installed from the PGDG apt repository only when an
# upgrade is needed, and purged again afterwards (see install_old_pg).

DATA_DIR=/config/postgres
NEW_DIR=/config/postgres.new
LOG_DIR=/config/pg_upgrade_logs
SOCK_DIR=/var/run/postgresql
PG_LIB_DIR=/usr/lib/postgresql
UPGRADE_URL="https://github.com/abesnier/docker-guacamole/blob/master/UPGRADE.md"

# apt bookkeeping for install_old_pg / cleanup_old_pg
APT_ARCHIVE_LIST=/etc/apt/sources.list.d/pgdg-upgrade-archive.list
PKG_BEFORE=/tmp/pg-upgrade-pkgs.before
OLD_PG_TOUCHED=0

log() { echo "[postgres-init] $*"; }

as_postgres() { s6-setuidgid postgres "$@"; }

mkdir -p "$DATA_DIR"
mkdir -p "$SOCK_DIR"
chown postgres:postgres "$SOCK_DIR"
chown -R postgres:postgres "$DATA_DIR"
chmod 0700 "$DATA_DIR"

# ---------------------------------------------------------------------------
# Failure handling. Whatever fails, /config/postgres must still be the original
# cluster, so the user can go back to the previous image.
# ---------------------------------------------------------------------------
fail() {
  log "ERROR: $*"
  log "The upgrade was aborted. Your original database in $DATA_DIR is still in place."
  log "See $UPGRADE_URL for what to do next."
  # keep pg_upgrade's own logs for diagnosis, drop the half-built cluster
  if [ -d "$NEW_DIR/pg_upgrade_output.d" ]; then
    cp -r "$NEW_DIR/pg_upgrade_output.d" "$LOG_DIR/" 2>/dev/null
  fi
  rm -rf "$NEW_DIR"
  cleanup_old_pg
  exit 1
}

# Same, for a failure while the OLD server may still be running
fail_old() {
  as_postgres "$PG_LIB_DIR/$old_major/bin/pg_ctl" -D "$DATA_DIR" -m immediate stop >/dev/null 2>&1
  fail "$*"
}

# ---------------------------------------------------------------------------
# install_old_pg <major>
# ---------------------------------------------------------------------------
# Installs postgresql-<major> from the PGDG repository (already configured in
# the image). PGDG moves end-of-life majors from its main repository to
# apt-archive.postgresql.org, so that suite is added as well. Needs internet
# access. Returns non-zero (after logging why) if the server cannot be installed.
install_old_pg() {
  major=$1
  codename=$(. /etc/os-release; echo "$VERSION_CODENAME")
  if [ -z "$codename" ]; then
    log "Could not determine the distribution codename from /etc/os-release."
    return 1
  fi

  log "PostgreSQL $major server binaries are needed for the upgrade."
  log "Installing postgresql-$major from the PGDG package repository (requires internet access)..."

  export DEBIAN_FRONTEND=noninteractive
  # remember what was installed before, so exactly what we add can be purged
  dpkg-query -f '${binary:Package}\n' -W | sort > "$PKG_BEFORE"
  OLD_PG_TOUCHED=1

  echo "deb https://apt-archive.postgresql.org/pub/repos/apt ${codename}-pgdg-archive main" > "$APT_ARCHIVE_LIST"
  # Installing a postgresql-<major> package must not create a default cluster.
  if [ -f /etc/postgresql-common/createcluster.conf ]; then
    echo "create_main_cluster = false" >> /etc/postgresql-common/createcluster.conf
  fi

  apt-get update > "$LOG_DIR/apt-update.log" 2>&1
  update_rc=$?
  if [ -z "$(apt-cache madison "postgresql-$major" 2>/dev/null)" ]; then
    if [ $update_rc -ne 0 ]; then
      log "Could not download the package lists: there appears to be no internet access (or a proxy/DNS problem). See $LOG_DIR/apt-update.log"
    else
      log "No package 'postgresql-$major' is available for '$codename' in the PGDG repositories (including apt-archive.postgresql.org)."
    fi
    return 1
  fi

  if ! apt-get install -y --no-install-recommends "postgresql-$major" > "$LOG_DIR/apt-install.log" 2>&1; then
    log "Installing postgresql-$major failed. See $LOG_DIR/apt-install.log"
    return 1
  fi
  if [ ! -x "$PG_LIB_DIR/$major/bin/postgres" ]; then
    log "postgresql-$major was installed but $PG_LIB_DIR/$major/bin/postgres is missing."
    return 1
  fi
  return 0
}

# Removes whatever install_old_pg added (packages, extra apt source, apt
# lists/cache). Safe to call more than once, and when nothing was installed.
cleanup_old_pg() {
  [ "$OLD_PG_TOUCHED" = 1 ] || return 0
  OLD_PG_TOUCHED=0
  export DEBIAN_FRONTEND=noninteractive
  if [ -f "$PKG_BEFORE" ]; then
    dpkg-query -f '${binary:Package}\n' -W | sort > "$PKG_BEFORE.after"
    added=$(comm -13 "$PKG_BEFORE" "$PKG_BEFORE.after")
    if [ -n "$added" ]; then
      # shellcheck disable=SC2086  # one argument per package name
      apt-get purge -y $added >> "$LOG_DIR/apt-install.log" 2>&1 \
        || log "WARNING: could not purge the temporary packages (see $LOG_DIR/apt-install.log); they are harmless but use disk space."
    fi
  fi
  rm -f "$APT_ARCHIVE_LIST" "$PKG_BEFORE" "$PKG_BEFORE.after"
  apt-get clean > /dev/null 2>&1
  rm -rf /var/lib/apt/lists/*
}

# ---------------------------------------------------------------------------
# migrate_cluster <old major>
# ---------------------------------------------------------------------------
# Upgrades $DATA_DIR from <old major> to $PG_MAJOR with pg_upgrade (copy mode).
#
# Safety rules:
#   - the new cluster is built next to the old one (/config/postgres.new);
#   - the old cluster is only started/stopped (normal crash recovery at most),
#     never modified or deleted. After success it is kept as
#     /config/postgres.pg<old>.bak; the user deletes it manually;
#   - the swap (two renames) only happens after pg_upgrade AND the post-upgrade
#     reindex succeeded; on any failure we exit 1 and /config/postgres is
#     still the original cluster.
migrate_cluster() {
  old_major=$1
  old_bin="$PG_LIB_DIR/$old_major/bin"
  new_bin="$PG_LIB_DIR/$PG_MAJOR/bin"

  log "Database cluster is PostgreSQL $old_major, this image runs PostgreSQL $PG_MAJOR."
  log "Starting automatic upgrade. Do not stop the container until it completes."

  mkdir -p "$LOG_DIR"
  chown postgres:postgres "$LOG_DIR"

  # -- 0. disk space: copy mode needs roughly the size of the old cluster again
  used_kb=$(du -sk "$DATA_DIR" | cut -f1)
  free_kb=$(df -Pk /config | awk 'NR==2 {print $4}')
  need_kb=$((used_kb + used_kb / 10 + 10240))
  if [ "$free_kb" -lt "$need_kb" ]; then
    fail "not enough free space in /config for the upgrade (need ~$((need_kb / 1024)) MB, have $((free_kb / 1024)) MB)"
  fi

  # -- 1. the old major's server binaries (not part of the image)
  if [ ! -x "$old_bin/postgres" ]; then
    install_old_pg "$old_major" \
      || fail "the PostgreSQL $old_major server needed to upgrade your database is not available"
  fi

  # -- 2. start the OLD server once. This (a) completes crash recovery if the
  #       previous container was killed instead of stopped (pg_upgrade refuses
  #       a cluster that was not shut down cleanly), and (b) lets us read the
  #       locale/encoding the new cluster must match.
  #       Nothing else is running at this stage, so a leftover pid file from a
  #       killed container is stale by definition.
  rm -f "$DATA_DIR/postmaster.pid"
  log "Starting the old PostgreSQL $old_major server to check/recover the cluster..."
  as_postgres "$old_bin/pg_ctl" -D "$DATA_DIR" -w -t 3600 -l "$LOG_DIR/old-server.log" \
    -o "-c listen_addresses='' -c unix_socket_directories=$SOCK_DIR" start \
    || fail_old "could not start the old server (see $LOG_DIR/old-server.log)"

  locale_info=$(as_postgres psql -h "$SOCK_DIR" -U postgres -d template1 -Atq \
    -c "SELECT datcollate || '|' || datctype || '|' || pg_encoding_to_char(encoding) FROM pg_database WHERE datname = 'template0'")
  rc=$?

  as_postgres "$old_bin/pg_ctl" -D "$DATA_DIR" -m fast -w -t 3600 stop \
    || fail "could not stop the old server cleanly (see $LOG_DIR/old-server.log)"

  if [ $rc -ne 0 ] || [ -z "$locale_info" ]; then
    fail "could not read locale/encoding from the old cluster"
  fi
  old_collate=${locale_info%%|*}
  rest=${locale_info#*|}
  old_ctype=${rest%%|*}
  old_encoding=${rest#*|}

  # Data checksums must match between old and new cluster (initdb from
  # PostgreSQL 18 on enables them by default).
  checksum_version=$(as_postgres "$old_bin/pg_controldata" "$DATA_DIR" \
    | awk -F: '/Data page checksum version/ {gsub(/[[:space:]]/, "", $2); print $2}')
  if [ -n "$checksum_version" ] && [ "$checksum_version" != "0" ]; then
    checksum_flag="--data-checksums"
  elif [ "$PG_MAJOR" -ge 18 ]; then
    checksum_flag="--no-data-checksums"
  else
    checksum_flag=""
  fi

  log "Old cluster: encoding=$old_encoding collate=$old_collate ctype=$old_ctype checksums=${checksum_version:-0}"

  # -- 3. new, empty cluster with the same locale/encoding/checksum setting
  rm -rf "$NEW_DIR"
  mkdir -p "$NEW_DIR"
  chown postgres:postgres "$NEW_DIR"
  chmod 0700 "$NEW_DIR"
  # shellcheck disable=SC2086  # $checksum_flag is intentionally unquoted (may be empty)
  as_postgres "$new_bin/initdb" -D "$NEW_DIR" \
    --encoding="$old_encoding" --lc-collate="$old_collate" --lc-ctype="$old_ctype" \
    $checksum_flag \
    || fail "initdb of the new cluster failed"

  # -- 4. pg_upgrade (copy mode: the old cluster is left untouched)
  # Run from a directory the postgres user can write to; pg_upgrade drops its
  # socket and helper files in the current directory.
  log "Running pg_upgrade $old_major -> $PG_MAJOR ..."
  ( cd "$LOG_DIR" && as_postgres "$new_bin/pg_upgrade" \
      -b "$old_bin" -B "$new_bin" -d "$DATA_DIR" -D "$NEW_DIR" ) \
    || fail "pg_upgrade failed (logs: $LOG_DIR and $NEW_DIR/pg_upgrade_output.d)"

  # pg_upgrade writes a script that deletes the OLD cluster path. After our
  # rename, that path will point at the NEW cluster - make sure nobody runs it.
  rm -f "$LOG_DIR/delete_old_cluster.sh"

  # -- 5. the C library / collation rules of this image can differ from the
  #       image that created the old cluster, and pg_upgrade copies indexes
  #       as they are. Rebuild all indexes (cheap for a Guacamole database)
  #       and refresh planner statistics before the new cluster goes live.
  log "Rebuilding indexes in the upgraded cluster..."
  as_postgres "$new_bin/pg_ctl" -D "$NEW_DIR" -w -t 3600 -l "$LOG_DIR/new-server.log" \
    -o "-c listen_addresses='' -c unix_socket_directories=$SOCK_DIR" start \
    || fail "could not start the upgraded cluster (see $LOG_DIR/new-server.log)"
  as_postgres reindexdb -h "$SOCK_DIR" -U postgres --all
  rc=$?
  if [ $rc -eq 0 ]; then
    as_postgres vacuumdb -h "$SOCK_DIR" -U postgres --all --analyze-only \
      || log "WARNING: vacuumdb --analyze-only failed (not fatal, autovacuum will catch up)"
  fi
  as_postgres "$new_bin/pg_ctl" -D "$NEW_DIR" -m fast -w -t 3600 stop \
    || fail "could not stop the upgraded cluster cleanly (see $LOG_DIR/new-server.log)"
  [ $rc -eq 0 ] || fail "reindexdb failed on the upgraded cluster"

  # -- 6. swap. Same filesystem, so these are atomic renames.
  backup_dir="/config/postgres.pg$old_major.bak"
  [ -e "$backup_dir" ] && backup_dir="$backup_dir-$(date +%Y%m%d%H%M%S)"

  mv "$DATA_DIR" "$backup_dir" || fail "could not move the old cluster to $backup_dir"
  if ! mv "$NEW_DIR" "$DATA_DIR"; then
    mv "$backup_dir" "$DATA_DIR"
    fail "could not move the new cluster into place; old cluster restored"
  fi
  chown -R postgres:postgres "$DATA_DIR"
  chmod 0700 "$DATA_DIR"

  # the old major's server is no longer needed
  cleanup_old_pg

  log "Upgrade to PostgreSQL $PG_MAJOR completed."
  log "Your previous PostgreSQL $old_major database was kept in $backup_dir"
  log "and can be deleted once you have checked that everything works."
  log "pg_upgrade logs are in $LOG_DIR (also safe to delete)."
}

# ---------------------------------------------------------------------------

if [ -e "$DATA_DIR/postgresql.conf" ]; then
  data_major=$(cat "$DATA_DIR/PG_VERSION" 2>/dev/null)
  case "$data_major" in
    ''|"$PG_MAJOR")
      echo "Database already configured"
      ;;
    *[!0-9]*)
      log "ERROR: cannot upgrade a database with PG_VERSION '$data_major' (found in $DATA_DIR)."
      log "Your data has not been touched. See $UPGRADE_URL"
      exit 1
      ;;
    *)
      if [ "$data_major" -lt "$PG_MAJOR" ]; then
        migrate_cluster "$data_major"
      else
        log "ERROR: the database in $DATA_DIR was created by PostgreSQL $data_major, which is newer than the PostgreSQL $PG_MAJOR in this image."
        log "Downgrades are not supported; use an image with PostgreSQL $data_major or newer. See $UPGRADE_URL"
        exit 1
      fi
      ;;
  esac
else
  as_postgres "$PG_LIB_DIR/$PG_MAJOR/bin/initdb"
fi
