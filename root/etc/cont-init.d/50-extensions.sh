#!/usr/bin/with-contenv sh

# remove all extensions from previous versions from the extensions directory
echo "Cleaning Extensions from previous Guacamole versions"
for e in $(ls -1 ${GUACAMOLE_HOME}/extensions | grep -v ${GUAC_VER}); do
  rm ${GUACAMOLE_HOME}/extensions/${e}
done

# Remove all provided extensions, they will be populated back when container starts.
echo "Cleaning Extensions"
for i in auth-duo auth-header auth-json auth-restrict auth-ldap auth-quickconnect auth-sso-cas auth-sso-openid auth-sso-saml auth-sso-ssl auth-totp branding display-statistics history-recording-storage vault-ksm; do
  rm -rf ${GUACAMOLE_HOME}/extensions/guacamole-${i}-*.jar
done

# this was from Oznu's image
# if the guacamole version was bumped, delete the contents of the extensions directory - just on the first run 
#if [ "$(cat /config/.database-version)" != "$GUAC_VER" ]; then
#  rm -rf ${GUACAMOLE_HOME}/extensions/*
#fi

# enable extensions
echo "Enabling selected extensions"
for i in $(echo "$EXTENSIONS" | tr "," " "); do
  cp ${GUACAMOLE_HOME}/extensions-available/guacamole-${i}-${GUAC_VER}.jar ${GUACAMOLE_HOME}/extensions
done
