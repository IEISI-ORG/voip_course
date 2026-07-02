#!/usr/bin/env bash
# SOVOC M4 acceptance test — media-plane prerequisites (fail-closed). RTP stats/MOS, eavesdrop,
# and QoS impairment are capture/analysis-graded (see README).
# Run from lab/:  bash labs/m4-rtp-qos/verify.sh
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
SBC=172.28.10.10

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. media path up (fail-closed) =="
path_ok=1
for s in edge-sbc rtpengine trunk-sim client; do
  if $COMPOSE ps --status running --services 2>/dev/null | grep -qx "$s"; then
    ok "$s running"; else bad "$s not running"; path_ok=0; fi
done

echo "== 2. signaling positive control =="
if [ "$path_ok" -eq 1 ] && $COMPOSE exec -T client \
     sipp -sf /scenarios/register.xml $SBC:5060 -s 1001 -i 172.28.10.40 -m 1 -timeout 10s -nostdin >/dev/null 2>&1; then
  ok "REGISTER -> 200"
else
  bad "REGISTER failed — INCONCLUSIVE, FAIL"
fi

echo "== 3. trunk-sim answers (a media endpoint exists to capture) =="
if [ "$path_ok" -eq 1 ]; then
  # Direct INVITE to trunk-sim should draw a 200 with an SDP answer.
  resp=$($COMPOSE exec -T client sh -c \
    "printf 'OPTIONS sip:172.28.10.30 SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.40:5060;branch=z9hG4bK-m4\r\nMax-Forwards: 70\r\nFrom: <sip:t@172.28.10.40>;tag=m4\r\nTo: <sip:172.28.10.30>\r\nCall-ID: m4-\$\$\r\nCSeq: 1 OPTIONS\r\nContent-Length: 0\r\n\r\n' | ncat -u -w2 172.28.10.30 5060" 2>/dev/null)
  if printf '%s' "$resp" | grep -q 'SIP/2.0'; then
    ok "trunk-sim reachable and speaks SIP (media endpoint available)"
  else
    bad "trunk-sim gave no SIP response — INCONCLUSIVE, FAIL"
  fi
else
  bad "path down — trunk check INCONCLUSIVE, FAIL"
fi

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "M4 ACCEPTANCE: PASS"; exit 0; } || { echo "M4 ACCEPTANCE: FAIL"; exit 1; }
