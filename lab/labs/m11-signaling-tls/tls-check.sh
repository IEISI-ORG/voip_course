#!/usr/bin/env bash
# VoIPSec M11 — inspect the SBC's TLS cert (Labs 10.2 / 10.3). Prints subject/issuer/validity and
# days-to-expiry, and does a live handshake from the client. Feeds the cert-expiry alert lab.
# Run from lab/.
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
SBC=172.28.10.10
CERT=/etc/kamailio/tls/edge-sbc.crt

echo "== SBC certificate (on edge-sbc) =="
$COMPOSE exec -T edge-sbc sh -c "openssl x509 -in $CERT -noout -subject -issuer -dates" 2>/dev/null \
  || { echo "cert not found at $CERT (is TLS bootstrapped?)"; }

echo
echo "== days until expiry =="
END=$($COMPOSE exec -T edge-sbc sh -c "openssl x509 -in $CERT -noout -enddate" 2>/dev/null | cut -d= -f2)
if [ -n "${END:-}" ]; then
  if command -v date >/dev/null 2>&1 && date -d "$END" +%s >/dev/null 2>&1; then
    days=$(( ( $(date -d "$END" +%s) - $(date +%s) ) / 86400 ))
    echo "  notAfter: $END  ->  ~$days days"
    [ "$days" -lt 30 ] && echo "  WARNING: cert expires in <30 days (Lab 10.3: Prometheus should alert)"
  else
    echo "  notAfter: $END  (install GNU date to compute days here)"
  fi
fi

echo
echo "== live TLS handshake from client =="
$COMPOSE exec -T client sh -c "true | ncat --ssl -v -w3 $SBC 5061 2>&1 | grep -iE 'SSL|subject|issuer|connected' | head -5" \
  || echo "  (client handshake failed)"

echo
echo "Cert-expiry alerting (Lab 10.3): scrape with prometheus ssl_exporter or blackbox_exporter"
echo "and alert on probe_ssl_earliest_cert_expiry - time() < 30d."
