#!/bin/sh
# VoIPSec edge-sbc entrypoint (Stage A1).
# - Injects the topoh mask secret from the environment (never stored in git).
# - Generates a self-signed TLS cert on first boot if none was mounted.
#   Real ACME / private-CA certs replace this in M11.
set -eu

CFG=/etc/kamailio/kamailio.cfg
CERT_DIR=/etc/kamailio/tls
CERT="$CERT_DIR/edge-sbc.pem"

# topoh mask secret: default to a random value if the env var is unset, so the lab
# still boots, but a real deployment must set TOPOH_MASK_SECRET via .env.
: "${TOPOH_MASK_SECRET:=$(head -c16 /dev/urandom | od -An -tx1 | tr -d ' \n')}"
sed -i "s/REPLACE_WITH_ENV_SECRET/${TOPOH_MASK_SECRET}/" "$CFG" || true

if [ ! -f "$CERT" ]; then
  mkdir -p "$CERT_DIR"
  echo "[entrypoint] generating self-signed TLS cert (replace with real CA in M11)"
  openssl req -x509 -newkey rsa:2048 -nodes \
    -keyout "$CERT_DIR/edge-sbc.key" \
    -out "$CERT_DIR/edge-sbc.crt" \
    -subj "/CN=${SIP_DOMAIN:-lab.voipsec.test}" -days 365 2>/dev/null || \
    echo "[entrypoint] openssl not present; TLS listener may not start (fixed in M11 image)"
  [ -f "$CERT_DIR/edge-sbc.crt" ] && cat "$CERT_DIR/edge-sbc.key" "$CERT_DIR/edge-sbc.crt" > "$CERT" 2>/dev/null || true
fi

exec "$@"
