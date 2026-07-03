#!/usr/bin/env bash
# VoIPSec M3 acceptance test — asserts the media-negotiation prerequisites are in place.
# Fail-closed: services up (incl. the rtpengine media anchor), REGISTER traverses the SBC, and
# the rtpengine edge media interface is reachable on the media path. The SDP c=/codec rewrite
# behaviour is captured/analysis-graded (see README).
# Run from lab/:  bash labs/m3-sdp-media/verify.sh
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
SBC=172.28.10.10

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. media path up (fail-closed prerequisite) =="
path_ok=1
for s in edge-sbc rtpengine pbx-a client; do
  if $COMPOSE ps --status running --services 2>/dev/null | grep -qx "$s"; then
    ok "$s running"; else bad "$s not running"; path_ok=0; fi
done

echo "== 2. signaling positive control =="
if [ "$path_ok" -eq 1 ] && $COMPOSE exec -T client \
     sipp -sf /scenarios/register.xml $SBC:5060 -s 1001 -i 172.28.10.40 -m 1 -timeout 10s -nostdin >/dev/null 2>&1; then
  ok "REGISTER -> 200 (signaling reachable)"
else
  bad "REGISTER failed — INCONCLUSIVE, FAIL"
fi

echo "== 3. rtpengine media anchor reachable on the edge path =="
if [ "$path_ok" -eq 1 ]; then
  if $COMPOSE exec -T client ping -c1 -W2 172.28.10.11 >/dev/null 2>&1; then
    ok "client -> rtpengine(edge 172.28.10.11) reachable (anchor on-path)"
  else
    bad "rtpengine edge interface unreachable — media cannot be anchored, FAIL"
  fi
else
  bad "path down — anchor check INCONCLUSIVE, FAIL"
fi

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "M3 ACCEPTANCE: PASS"; exit 0; } || { echo "M3 ACCEPTANCE: FAIL"; exit 1; }
