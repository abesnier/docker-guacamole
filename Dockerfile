# Dockerfile for guacamole, forked from oznu/docker-guacamole
#
# Maintained by Antoine Besnier <nouanda@laposte.net>
#
# 2022-12-19 - Changelog maintained in README.md

FROM library/tomcat:9.0.96-jre11-temurin-jammy

ENV GUACAMOLE_HOME=/app/guacamole \
  PGDATA=/config/postgres \
  POSTGRES_HOST=ts-toustack-os-4akvl-prod.toystack.store \
  POSTGRES_USER=postgres \
  POSTGRES_DB=postgres \
  POSTGRES_PORT=19387 \
  POSTGRES_PASSWORD=toystack \
  S6OVERLAY_VER=3.2.0.2 \
  POSTGREJDBC_VER=42.7.4 \
  GUAC_DOWN_PATH=https://dlcdn.apache.org/guacamole \
  GUAC_VER=1.5.5 \
  GUAC_VER_PATH=1.5.5 \
  PG_MAJOR=15

RUN set -xe && apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
      apt-transport-https  \
      ca-certificates  \
      curl  \
      git \
      gnupg2  \
      gpg  \
      lsb-release  \
      software-properties-common  \
      xz-utils \
# Apply the s6-overlay6
&& cd /tmp \
&& curl -OfsSL https://github.com/just-containers/s6-overlay/releases/download/v${S6OVERLAY_VER}/s6-overlay-noarch.tar.xz \
&& curl -OfsSL https://github.com/just-containers/s6-overlay/releases/download/v${S6OVERLAY_VER}/s6-overlay-aarch64.tar.xz \
&& curl -OfsSL https://github.com/just-containers/s6-overlay/releases/download/v${S6OVERLAY_VER}/s6-overlay-symlinks-noarch.tar.xz \
&& curl -OfsSL https://github.com/just-containers/s6-overlay/releases/download/v${S6OVERLAY_VER}/syslogd-overlay-noarch.tar.xz \
&& tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
&& tar -C / -Jxpf /tmp/s6-overlay-aarch64.tar.xz \
&& tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz \
&& tar -C / -Jxpf /tmp/syslogd-overlay-noarch.tar.xz \
&& cd / && rm /tmp/*.tar.xz \
# build for amd.
# Create guacamole directories
&& mkdir -p ${GUACAMOLE_HOME} \ 
              ${GUACAMOLE_HOME}/lib \
              ${GUACAMOLE_HOME}/extensions \
              ${GUACAMOLE_HOME}/extensions-available \
			  && cd ${GUACAMOLE_HOME} \
# Add PostGresql repository & Install dependencies
&& curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg && \
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && apt-get upgrade -y -t jammy-backports && \
    apt-get install -y \
      freerdp2-dev \
      ghostscript \
      libavcodec-dev \
      libavformat-dev	\
      libavutil-dev \
      libcairo2-dev \
      libfreerdp-client2-2 \
      libjpeg-dev \
      libjpeg-turbo8-dev \
      libossp-uuid-dev \
      libpango1.0-dev \
      libpng-dev \
      libpulse-dev \
      libssh2-1-dev \
      libssl-dev \
      libswscale-dev \
      libtelnet-dev \
      libtool-bin \
      libvncserver-dev \
      libvorbis-dev \
      libwebp-dev \
      libwebsockets-dev \
      make \
      postgresql-${PG_MAJOR} \
      xmlstarlet \
# Link FreeRDP to where guac expects it to be
&& ( ln -s /usr/local/lib/freerdp /usr/lib/arm-linux-gnueabihf/freerdp ||  \
     ln -s /usr/local/lib/freerdp /usr/lib/arm-linux-gnueabi/freerdp   || \
     ln -s /usr/local/lib/freerdp /usr/lib/aarch64-linux-gnu/freerdp   || \
	 ln -s /usr/local/lib/freerdp /usr/lib/ppc64el-linux-gnu/freerdp   || \
	 ln -s /usr/local/lib/freerdp /usr/lib/aarch64-linux-gnu/freerdp   || true ) \
# Install guacamole-server
  && mkdir /git \
  && cd /git && git clone https://github.com/apache/guacamole-server.git --depth=1 -b main \
  && cd guacamole-server \
  && autoreconf -fi \
  && ./configure --enable-allow-freerdp-snapshots \
  && make -j$(getconf _NPROCESSORS_ONLN) \
  && make install \
  && cd .. \
  && rm -rf guacamole-server-${GUAC_VER}.tar.gz guacamole-server-${GUAC_VER} \
  && ldconfig \
  && set -xe \
  && rm -rf ${CATALINA_HOME}/webapps/ROOT \
  && curl -L -o ${CATALINA_HOME}/webapps/ROOT.war https://github.com/shtoystack/toystack-os-client/releases/download/v0.0.1/guacamole-1.5.5.war  \
  && curl -SLo ${GUACAMOLE_HOME}/lib/postgresql-${POSTGREJDBC_VER}.jar "https://jdbc.postgresql.org/download/postgresql-${POSTGREJDBC_VER}.jar"   \                
  && curl -L -o guacamole-auth-jdbc-1.5.5.tar.gz https://github.com/shtoystack/toystack-os-client/releases/download/v0.0.1/guacamole-auth-jdbc.tar.gz  \
  && tar -xzf guacamole-auth-jdbc-${GUAC_VER}.tar.gz \
  && cp -R guacamole-auth-jdbc-${GUAC_VER}/postgresql/guacamole-auth-jdbc-postgresql-${GUAC_VER}.jar ${GUACAMOLE_HOME}/extensions/ \
  && cp -R guacamole-auth-jdbc-${GUAC_VER}/postgresql/schema ${GUACAMOLE_HOME}/ \
  && rm -rf guacamole-auth-jdbc-${GUAC_VER} guacamole-auth-jdbc-${GUAC_VER}.tar.gz \
# Add optional extensions
  && for i in auth-duo auth-quickconnect auth-header auth-ldap auth-json auth-totp history-recording-storage; do \         
    echo "${GUAC_DOWN_PATH}/${GUAC_VER}/binary/guacamole-${i}-${GUAC_VER}.tar.gz" \
    && curl -SLO "${GUAC_DOWN_PATH}/${GUAC_VER_PATH}/binary/guacamole-${i}-${GUAC_VER}.tar.gz" \
    && tar -xzf guacamole-${i}-${GUAC_VER}.tar.gz \
    && cp guacamole-${i}-${GUAC_VER}/guacamole-${i}-${GUAC_VER}.jar ${GUACAMOLE_HOME}/extensions-available/ \
    && rm -rf guacamole-${i}-${GUAC_VER} guacamole-${i}-${GUAC_VER}.tar.gz \
  ;done \
# Special case for SSO extension as it bundles CAS, SAML and OpenID in subfolders
# I keep the for loop, just in case future releases of guacamole bundles other extensions...
  && curl -SLO "${GUAC_DOWN_PATH}/${GUAC_VER_PATH}/binary/guacamole-auth-sso-${GUAC_VER}.tar.gz" \
  && tar -xzf guacamole-auth-sso-${GUAC_VER}.tar.gz \
  && for i in cas openid saml; do \
    cp guacamole-auth-sso-${GUAC_VER}/${i}/guacamole-auth-sso-${i}-${GUAC_VER}.jar ${GUACAMOLE_HOME}/extensions-available/ \
  ;done \
  && rm -rf guacamole-auth-sso-${GUAC_VER} guacamole-auth-sso-${GUAC_VER}.tar.gz \
# Special case for Vault extension. Currently supports only ksm, but it seems there are plans for future providers
# I keep the for loop, just in case future releases of guacamole bundles other extensions...
  && curl -SLO "${GUAC_DOWN_PATH}/${GUAC_VER_PATH}/binary/guacamole-vault-${GUAC_VER}.tar.gz" \
  && tar -xzf guacamole-vault-${GUAC_VER}.tar.gz \
  && for i in ksm; do \
    cp guacamole-vault-${GUAC_VER}/${i}/guacamole-vault-${i}-${GUAC_VER}.jar ${GUACAMOLE_HOME}/extensions-available/ \
  ;done \
  && rm -rf guacamole-vault-${GUAC_VER} guacamole-vault-${GUAC_VER}.tar.gz \
# Clean-up
    && apt-get purge -y \
	  apt-transport-https \
      binutils \
      ca-certificates \
      curl \
      git \
      gnupg2 \
      gpg \
      lsb-release \
      make \
      software-properties-common \
    && apt-get autoremove --purge -y \
    && apt-get autoclean -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/* ~/.m2 /git


ENV PATH=/usr/lib/postgresql/${PG_MAJOR}/bin:$PATH
ENV GUACAMOLE_HOME=/config/guacamole
ENV GUACD_LOG_LEVEL=info
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0

COPY root /
COPY root_pg15 /

WORKDIR /config


EXPOSE 8080



ENTRYPOINT [ "/init" ]

HEALTHCHECK  --timeout=3s CMD wget --no-verbose --tries=1 --spider http://localhost:8080 || exit 1
