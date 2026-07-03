#!/bin/sh
# VoIPSec pbx-b entrypoint (Stage A3).
# Removes FreeSWITCH's two well-known default credentials at boot by injecting secrets from
# the environment (never committed): the global default_password (T3) and the event-socket
# password (T11). Safe random defaults keep the lab bootable on a first run.
set -eu

: "${FS_DEFAULT_PASSWORD:=fsuser-$(head -c6 /dev/urandom | od -An -tx1 | tr -d ' \n')}"
: "${FS_ESL_PASSWORD:=fsesl-$(head -c8 /dev/urandom | od -An -tx1 | tr -d ' \n')}"

VARS=/etc/freeswitch/vars.xml
ESL=/etc/freeswitch/autoload_configs/event_socket.conf.xml

# Replace the stock default_password=1234 with the injected secret.
if [ -f "$VARS" ]; then
  sed -i "s#default_password=[^\"]*#default_password=${FS_DEFAULT_PASSWORD}#" "$VARS" || true
fi

# Replace the event-socket password placeholder (or stock ClueCon) with the injected secret.
if [ -f "$ESL" ]; then
  sed -i "s#__ESL_PASSWORD__#${FS_ESL_PASSWORD}#; s#>ClueCon<#>${FS_ESL_PASSWORD}<#" "$ESL" || true
fi

exec "$@"
