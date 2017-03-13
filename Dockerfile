FROM babim/alpinebase

ENV SQUID_CACHE_DIR=/var/spool/squid \
    SQUID_LOG_DIR=/var/log/squid \
    SQUID_DIR=/squid \
    SQUID_CONFIG_DIR=/etc/squid \
    SQUID_USER=squid

RUN apk add --no-cache squid bash apache2-utils \
 && mv ${SQUID_CONFIG_DIR}/squid.conf ${SQUID_CONFIG_DIR}/squid.conf.dist

COPY squid.conf ${SQUID_CONFIG_DIR}/squid.conf
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

# change to one directory
RUN [ -d ${SQUID_CACHE_DIR} ] || mkdir -p ${SQUID_CACHE_DIR} && \
    [ -d ${SQUID_LOG_DIR} ] || mkdir -p ${SQUID_LOG_DIR} && \
    [ -d ${SQUID_DIR} ] || mkdir -p ${SQUID_DIR} && \
    [ -d /usr/etc ] || mkdir -p /usr/etc && \
    mv ${SQUID_CACHE_DIR} ${SQUID_DIR}/cache && ln -s ${SQUID_DIR}/cache ${SQUID_CACHE_DIR} && \
    mv ${SQUID_LOG_DIR} ${SQUID_DIR}/log && ln -s ${SQUID_DIR}/log ${SQUID_LOG_DIR} && \
    mv ${SQUID_CONFIG_DIR} ${SQUID_DIR}/config && ln -s ${SQUID_DIR}/config ${SQUID_CONFIG_DIR} && \
    mkdir /etc-start && cp -R ${SQUID_DIR}/* /etc-start

EXPOSE 3128/tcp
#VOLUME ["${SQUID_CACHE_DIR}", "${SQUID_LOG_DIR}", "${SQUID_CONFIG_DIR}"]
VOLUME ["${SQUID_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
