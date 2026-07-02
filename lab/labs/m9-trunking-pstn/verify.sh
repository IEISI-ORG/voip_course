#!/usr/bin/env bash
# SOVOC M9 acceptance test — trunking prerequisites (fail-closed). The two-way trunk, TLS/auth
# hardening, and fraud guardrails are config/capture-graded (see README + trunk-hardening.md).
# Run from lab/:  bash labs/m9-trunking-pstn/verify.sh
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
TRUNK=172.28.10.30

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. trunk endpoints up (fail-closed) =="
path_ok=1
for s in edge-sbc pbx-a trunk-sim client; do
  $COMPOSE ps --status running --services 2>/dev/null | grep -qx "$s" && ok "$s running" || { bad "$s not running"; path_ok=0; }
done

echo "== 2. PSTN peer (trunk-sim) reachable and speaks SIP =="
if [ "$path_ok" -eq 1 ]; then
  resp=$($COMPOSE exec -T client sh -c \
    "printf 'OPTIONS sip:$TRUNK SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.40:5060;branch=z9hG4bK-m9\r\nMax-Forwards: 70\r\nFrom: <sip:t@172.28.10.40>;tag=m9\r\nTo: <sip:$TRUNK>\r\nCall-ID: m9-\$\$\r\nCSeq: 1 OPTIONS\r\nContent-Length: 0\r\n\r\n' | ncat -u -w2 $TRUNK 5060" 2>/dev/null)
  printf '%s' "$resp" | grep -q 'SIP/2.0' \
    && ok "trunk-sim answers SIP (PSTN peer present for in/outbound trunking)" \
    || bad "trunk-sim gave no SIP response — INCONCLUSIVE, FAIL"
else
  bad "endpoints down — trunk check INCONCLUSIVE, FAIL"
fi

echo "== 3. Q.850 mapping tool present (Lab 9.2) =="
[ -x labs/m9-trunking-pstn/sip-q850.sh ] && ok "sip-q850.sh available" || bad "sip-q850.sh missing/not executable"

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "M9 ACCEPTANCE: PASS"; exit 0; } || { echo "M9 ACCEPTANCE: FAIL"; exit 1; }
