# Dockerfile for guacamole, forked from oznu/docker-guacamole
#
# Maintained by Antoine Besnier <nouanda@laposte.net>
#
# 2021-12-17:
# Sooo.... I tried to upgrade tomcat to 10, and spent a few days trying to figure out why guacamole was not working... 
# Turns out guacamole is not compatible with Tomcat 10... https://issues.apache.org/jira/browse/GUACAMOLE-1325
# 
# That being said, it was still possible to upgrade the following components:
# tomcat -> 9.0.56
# postgresql -> 13
# s6 overlay -> 2.2.03
# postgresql jdbc -> 42.3.1
#
# URLs for Guacamole downloads were also updated
#

FROM library/tomcat:9.0.56-jre11

ENV ARCH=amd64 \
  GUACAMOLE_HOME=/app/guacamole \
  PGDATA=/config/postgres \
  POSTGRES_USER=guacamole \
  POSTGRES_DB=guacamole_db \
  S6OVERLAY_VER=2.2.0.3 \
  POSTGREJDBC_VER=42.3.1 \
  GUAC_VER=1.3.0 \
  PG_MAJOR=13

# Apply the s6-overlay
RUN curl -SLO "https://github.com/just-containers/s6-overlay/releases/download/v${S6OVERLAY_VER}/s6-overlay-${ARCH}.tar.gz" \ 
  && tar -xzf s6-overlay-${ARCH}.tar.gz -C / \ 
  && tar -xzf s6-overlay-${ARCH}.tar.gz -C /usr ./bin \ 
  && rm -rf s6-overlay-${ARCH}.tar.gz \ 
  && mkdir -p ${GUACAMOLE_HOME} \ 
              ${GUACAMOLE_HOME}/lib \
              ${GUACAMOLE_HOME}/extensions \
              ${GUACAMOLE_HOME}/extensions-available

WORKDIR ${GUACAMOLE_HOME}

# Install dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
  libcairo2-dev libjpeg62-turbo-dev libpng-dev \
  libossp-uuid-dev libavcodec-dev libavutil-dev \
  libswscale-dev freerdp2-dev libfreerdp-client2-2 \
  libpango1.0-dev libssh2-1-dev libtelnet-dev \
  libvncserver-dev libpulse-dev libssl-dev \
  libvorbis-dev libwebp-dev libwebsockets-dev \
  ghostscript postgresql-${PG_MAJOR} make\
  libjpeg-dev libtool-bin libavformat-dev --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

# Link FreeRDP to where guac expects it to be
RUN [ "$ARCH" = "armhf" ] && ln -s /usr/local/lib/freerdp /usr/lib/arm-linux-gnueabihf/freerdp || exit 0
RUN [ "$ARCH" = "amd64" ] && ln -s /usr/local/lib/freerdp /usr/lib/x86_64-linux-gnu/freerdp || exit 0

# Install guacamole-server

RUN curl -SLO "https://dlcdn.apache.org/guacamole/${GUAC_VER}/source/guacamole-server-${GUAC_VER}.tar.gz" \
  && tar -xzf guacamole-server-${GUAC_VER}.tar.gz \
  && cd guacamole-server-${GUAC_VER} \
  && ./configure --enable-allow-freerdp-snapshots \
  && make -j$(getconf _NPROCESSORS_ONLN) \
  && make install \
  && cd .. \
  && rm -rf guacamole-server-${GUAC_VER}.tar.gz guacamole-server-${GUAC_VER} \
  && ldconfig

# Install guacamole-client and postgres auth adapter
RUN set -x \
  && rm -rf ${CATALINA_HOME}/webapps/ROOT \
  && curl -SLo ${CATALINA_HOME}/webapps/ROOT.war "https://dlcdn.apache.org/guacamole/${GUAC_VER}/binary/guacamole-${GUAC_VER}.war" \
  && curl -SLo ${GUACAMOLE_HOME}/lib/postgresql-${POSTGREJDBC_VER}.jar "https://jdbc.postgresql.org/download/postgresql-${POSTGREJDBC_VER}.jar" \                
  && curl -SLO "https://dlcdn.apache.org/guacamole/${GUAC_VER}/binary/guacamole-auth-jdbc-${GUAC_VER}.tar.gz" \
  && tar -xzf guacamole-auth-jdbc-${GUAC_VER}.tar.gz \
  && cp -R guacamole-auth-jdbc-${GUAC_VER}/postgresql/guacamole-auth-jdbc-postgresql-${GUAC_VER}.jar ${GUACAMOLE_HOME}/extensions/ \
  && cp -R guacamole-auth-jdbc-${GUAC_VER}/postgresql/schema ${GUACAMOLE_HOME}/ \
  && rm -rf guacamole-auth-jdbc-${GUAC_VER} guacamole-auth-jdbc-${GUAC_VER}.tar.gz

# Add optional extensions
RUN set -xe \
  && for i in auth-cas auth-duo auth-ldap auth-openid auth-quickconnect auth-saml auth-totp; do \         
    echo "https://dlcdn.apache.org/guacamole/${GUAC_VER}/binary/guacamole-${i}-${GUAC_VER}.tar.gz" \
    && curl -SLO "https://dlcdn.apache.org/guacamole/${GUAC_VER}/binary/guacamole-${i}-${GUAC_VER}.tar.gz" \
    && tar -xzf guacamole-${i}-${GUAC_VER}.tar.gz \
    && cp guacamole-${i}-${GUAC_VER}/guacamole-${i}-${GUAC_VER}.jar ${GUACAMOLE_HOME}/extensions-available/ \
    && rm -rf guacamole-${i}-${GUAC_VER} guacamole-${i}-${GUAC_VER}.tar.gz \
  ;done \
# special treatment for auth_header, still in version 1.2.0
  && curl -SLO "https://dlcdn.apache.org/guacamole/1.3.0/binary/guacamole-auth-header-1.2.0.tar.gz"\
  && tar -xzf guacamole-auth-header-1.2.0.tar.gz \
  && cp guacamole-auth-header-1.2.0/guacamole-auth-header-1.2.0.jar ${GUACAMOLE_HOME}/extensions-available \
  && rm -rf guacamole-auth-header-1.2.0 guacamole-auth-header-1.2.0.tar.gz

ENV PATH=/usr/lib/postgresql/${PG_MAJOR}/bin:$PATH
ENV GUACAMOLE_HOME=/config/guacamole

WORKDIR /config

COPY root /

EXPOSE 8080

ENTRYPOINT [ "/init" ]
