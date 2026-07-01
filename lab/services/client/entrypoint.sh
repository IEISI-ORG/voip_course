#!/bin/sh
# SOVOC client entrypoint (Stage A4).
# Renders the Baresip account (secret from env, never committed) so `baresip` can register
# through the edge-sbc immediately. Secrets default to safe placeholders for a first run.
set -eu

: "${SIP_DOMAIN:=lab.sovoc.test}"
: "${EDGE_SBC_IP:=172.28.10.10}"
: "${SIP_ALICE_SECRET:=change-me}"
export SIP_DOMAIN EDGE_SBC_IP SIP_ALICE_SECRET

mkdir -p /root/.baresip
if [ -f /etc/sovoc/baresip/accounts.tmpl ]; then
  envsubst '${SIP_DOMAIN} ${EDGE_SBC_IP} ${SIP_ALICE_SECRET}' \
    < /etc/sovoc/baresip/accounts.tmpl > /root/.baresip/accounts
  chmod 600 /root/.baresip/accounts
fi

exec "$@"
