#!/usr/bin/env bash
# SOVOC M11 acceptance test — asserts the SRTP foundation is in place (fail-closed):
# the media anchor (rtpengine) is on-path AND signaling TLS works (SDES keys must ride secure
# signaling, or "encrypted" media is trivially decryptable). Actual media-payload encryption,
# DTLS handshakes, crypto-strip rejection and ZRTP SAS are capture/config-graded (see README).
# Run from lab/:  bash labs/m11-media-srtp/verify.sh
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
SBC=172.28.10.10

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. services up (fail-closed) =="
path_ok=1
for s in edge-sbc rtpengine client; do
  $COMPOSE ps --status running --services 2>/dev/null | grep -qx "$s" && ok "$s running" || { bad "$s not running"; path_ok=0; }
done

echo "== 2. media anchor reachable (SRTP bridging point) =="
if [ "$path_ok" -eq 1 ] && $COMPOSE exec -T client ping -c1 -W2 172.28.10.11 >/dev/null 2>&1; then
  ok "rtpengine edge interface reachable (SRTP<->RTP anchor on-path)"
else
  bad "rtpengine unreachable — SRTP cannot be anchored, FAIL"
fi

echo "== 3. secure signaling present (SDES keys must not travel in cleartext) =="
if [ "$path_ok" -eq 1 ] && $COMPOSE exec -T client sh -c "true | ncat --ssl -w3 $SBC 5061 >/dev/null 2>&1"; then
  ok "SIP-TLS handshake OK on :5061 (SDES keying can be protected)"
else
  bad "no TLS signaling — SDES keys would be exposed; SRTP foundation INCOMPLETE, FAIL"
fi

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "M11 ACCEPTANCE: PASS"; exit 0; } || { echo "M11 ACCEPTANCE: FAIL"; exit 1; }
