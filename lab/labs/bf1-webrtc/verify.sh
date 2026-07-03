#!/usr/bin/env bash
# VoIPSec BF1 acceptance test — WebRTC gateway prerequisites (fail-closed). Full browser<->PBX
# media bridging is capture/manual-graded (needs a browser); this asserts the WSS transport
# basis and that the config/client artifacts are in place and secure-by-default.
# Run from lab/:  bash labs/bf1-webrtc/verify.sh
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
SBC=172.28.10.10
DIR=labs/bf1-webrtc

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. gateway services up =="
path_ok=1
for s in edge-sbc rtpengine; do
  $COMPOSE ps --status running --services 2>/dev/null | grep -qx "$s" && ok "$s running" || { bad "$s not running"; path_ok=0; }
done

echo "== 2. TLS transport for WSS present (:5061) =="
if [ "$path_ok" -eq 1 ] && $COMPOSE ps --status running --services 2>/dev/null | grep -qx client \
   && $COMPOSE exec -T client sh -c "true | ncat --ssl -w3 $SBC 5061 >/dev/null 2>&1"; then
  ok "TLS handshake on :5061 (WSS rides this transport)"
else
  bad "no TLS on :5061 — WSS unavailable (or client down), FAIL"
fi

echo "== 3. config snippet enables WebSocket + rtpengine WebRTC transform =="
grep -q 'ws_handle_handshake' "$DIR/kamailio-webrtc.snippet.cfg" && ok "WS handshake handler present" || bad "WS handler missing"
grep -q 'DTLS=passive' "$DIR/kamailio-webrtc.snippet.cfg"        && ok "rtpengine DTLS-SRTP bridge flag present" || bad "DTLS bridge flag missing"

echo "== 4. browser client is secure-by-default (no un-pinned external script) =="
if grep -q './jssip.min.js' "$DIR/client.html" && ! grep -qE '<script src="https://[^"]+"></script>' "$DIR/client.html"; then
  ok "client.html vendors jsSIP locally (no CDN-compromise surface)"
else
  bad "client.html loads an external script without SRI"
fi

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "BF1 ACCEPTANCE: PASS"; exit 0; } || { echo "BF1 ACCEPTANCE: FAIL"; exit 1; }
