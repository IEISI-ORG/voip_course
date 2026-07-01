#!/bin/sh
# SOVOC pbx-a entrypoint (Stage A2).
# Renders endpoint secrets from the environment into pjsip.conf so no credential is ever
# committed to git (threat T11). Real per-user secrets come from .env; safe defaults keep
# the lab bootable for a first run.
set -eu

: "${SIP_ALICE_SECRET:=alice-lab-$(head -c6 /dev/urandom | od -An -tx1 | tr -d ' \n')}"
: "${SIP_BOB_SECRET:=bob-lab-$(head -c6 /dev/urandom | od -An -tx1 | tr -d ' \n')}"
export SIP_ALICE_SECRET SIP_BOB_SECRET

TMPL=/etc/asterisk/pjsip.conf.tmpl
OUT=/etc/asterisk/pjsip.conf
if [ -f "$TMPL" ]; then
  envsubst '${SIP_ALICE_SECRET} ${SIP_BOB_SECRET}' < "$TMPL" > "$OUT"
  chmod 640 "$OUT"; chown root:asterisk "$OUT" 2>/dev/null || true
fi

exec "$@"
