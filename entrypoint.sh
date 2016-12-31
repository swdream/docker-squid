#!/bin/bash
set -e

SQUID_CACHE_DIR=/var/spool/squid
SQUID_LOG_DIR=/var/log/squid
SQUID_DIR=/squid
SQUID_CONFIG_DIR=/etc/squid
SQUID_USER=${USER:-squid}
    
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
elif [[ ${1} == squid || ${1} == $(which squid) ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

# default behaviour is to launch squid
if [[ -z ${1} ]]; then
  if [[ ! -d ${SQUID_CACHE_DIR}/00 ]]; then
    echo "Initializing cache..."
    $(which squid) -N -f ${SQUID_CONFIG_DIR}/squid.conf -z
  fi
  echo "Starting squid3..."
  exec $(which squid) -f ${SQUID_CONFIG_DIR}/squid.conf -NYCd 1 ${EXTRA_ARGS}
else
  exec "$@"
fi
