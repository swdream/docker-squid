#!/bin/bash
set -e

SQUID_VERSION=3
SQUID_CACHE_DIR=/var/spool/squid${SQUID_VERSION}
SQUID_LOG_DIR=/var/log/squid${SQUID_VERSION}
SQUID_DIR=/squid
SQUID_CONFIG_DIR=/etc/squid${SQUID_VERSION}
SQUID_USER=${USER:-proxy}
SQUID_USERNAME=${USERNAME:-foo}
SQUID_PASSWORD=${PASSWORD:-bar}
    
if [ -z "`ls ${SQUID_DIR} --hide='lost+found'`" ] || [ -z "`ls ${SQUID_CONFIG_DIR}`" ] 
then
	cp -R /etc-start/* ${SQUID_DIR}
fi

create_log_dir() {
  [[ -d ${SQUID_LOG_DIR} ]] || mkdir -p ${SQUID_LOG_DIR}
  chmod -R 755 ${SQUID_LOG_DIR}
  chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_DIR}/log
  chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_LOG_DIR}
}

create_cache_dir() {
  [[ -d ${SQUID_CACHE_DIR} ]] || mkdir -p ${SQUID_CACHE_DIR}
  rm -rf ${SQUID_CACHE_DIR}/*
  chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_DIR}/cache
  chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_CACHE_DIR}
}

apply_backward_compatibility_fixes() {
  if [[ -f ${SQUID_CONFIG_DIR}/squid.user.conf ]]; then
    rm -rf ${SQUID_CONFIG_DIR}/squid.conf
    ln -sf ${SQUID_CONFIG_DIR}/squid.user.conf ${SQUID_CONFIG_DIR}/squid.conf
  fi
}

create_log_dir
create_cache_dir
apply_backward_compatibility_fixes

# allow arguments to be passed to squid3
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
elif [[ ${1} == squid${SQUID_VERSION} || ${1} == $(which squid${SQUID_VERSION}) ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

# default behaviour is to launch squid
htpasswd -bc /usr/etc/passwd "${SQUID_USERNAME}" "${SQUID_PASSWORD}"
echo "Done"
echo "Squid Start"
exec squid${SQUID_VERSION} -N $*
