#!/usr/bin/env bash
# SOVOC M10 acceptance test — proves the SBC's SIP-over-TLS endpoint works (Lab 10.1 core).
# Fail-closed: services up, then an OPTIONS carried over a TLS handshake to :5061 must draw a
# SIP response. (TLS-only *enforcement* — refusing UDP/TCP — is a config step, capture-graded.)
# Run from lab/:  bash labs/m10-signaling-tls/verify.sh
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
SBC=172.28.10.10

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. services up (fail-closed) =="
path_ok=1
for s in edge-sbc client; do
  $COMPOSE ps --status running --services 2>/dev/null | grep -qx "$s" && ok "$s running" || { bad "$s not running"; path_ok=0; }
done

echo "== 2. TLS listener present on :5061 =="
tls_ok=0
if [ "$path_ok" -eq 1 ]; then
  # ncat --ssl does the TLS handshake; empty send just to test the handshake completes.
  if $COMPOSE exec -T client sh -c "true | ncat --ssl -w3 $SBC 5061 >/dev/null 2>&1"; then
    ok "TLS handshake to $SBC:5061 succeeded"; tls_ok=1
  else
    bad "TLS handshake to :5061 failed (TLS not enabled or ncat lacks --ssl) — FAIL"
  fi
else
  bad "services down — TLS check INCONCLUSIVE, FAIL"
fi

echo "== 3. SIP transaction carried over TLS =="
if [ "$tls_ok" -eq 1 ]; then
  resp=$($COMPOSE exec -T client sh -c \
    "printf 'OPTIONS sip:$SBC SIP/2.0\r\nVia: SIP/2.0/TLS 172.28.10.40:5061;branch=z9hG4bK-tls\r\nMax-Forwards: 70\r\nFrom: <sip:p@172.28.10.40>;tag=tls\r\nTo: <sip:$SBC>\r\nCall-ID: m10-\$\$\r\nCSeq: 1 OPTIONS\r\nContent-Length: 0\r\n\r\n' | ncat --ssl -w3 $SBC 5061" 2>/dev/null)
  printf '%s' "$resp" | grep -q 'SIP/2.0' \
    && ok "OPTIONS over TLS answered (SIP/SIPS signaling works)" \
    || bad "no SIP response over TLS — INCONCLUSIVE, FAIL"
else
  bad "no TLS handshake — SIP-over-TLS test INCONCLUSIVE, FAIL"
fi

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "M10 ACCEPTANCE: PASS"; exit 0; } || { echo "M10 ACCEPTANCE: FAIL"; exit 1; }
