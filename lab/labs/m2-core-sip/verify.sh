#!/usr/bin/env bash
# SOVOC M2 acceptance test — asserts deterministic SIP protocol invariants at the SBC.
# Fail-closed. Auto-graded core for Labs 2.1/2.2 sign-off; the transaction/dialog analysis
# and forking/topology-hiding labs are rubric-graded (see README).
# Run from lab/:  bash labs/m2-core-sip/verify.sh
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
SBC=172.28.10.10

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. probe path up (fail-closed prerequisite) =="
path_ok=1
for s in edge-sbc pbx-a client; do
  if $COMPOSE ps --status running --services 2>/dev/null | grep -qx "$s"; then
    ok "$s running"; else bad "$s not running"; path_ok=0; fi
done

echo "== 2. REGISTER transaction traverses the SBC =="
if [ "$path_ok" -eq 1 ] && $COMPOSE exec -T client \
     sipp -sf /scenarios/register.xml $SBC:5060 -s 1001 -i 172.28.10.40 -m 1 -timeout 10s -nostdin >/dev/null 2>&1; then
  ok "REGISTER -> 200 (registrar transaction OK)"
else
  bad "REGISTER did not succeed (path down or SBC issue) — INCONCLUSIVE, FAIL"
fi

echo "== 3. Max-Forwards loop protection (protocol invariant, threat: MF loops) =="
if [ "$path_ok" -eq 1 ]; then
  resp=$($COMPOSE exec -T client sh -c \
    "printf 'OPTIONS sip:$SBC SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.40:5060;branch=z9hG4bK-mf0\r\nMax-Forwards: 0\r\nFrom: <sip:probe@172.28.10.40>;tag=mf\r\nTo: <sip:$SBC>\r\nCall-ID: mf-\$\$\r\nCSeq: 1 OPTIONS\r\nContent-Length: 0\r\n\r\n' | ncat -u -w2 $SBC 5060" 2>/dev/null)
  if printf '%s' "$resp" | grep -q '483'; then
    ok "Max-Forwards: 0 -> 483 Too Many Hops (loop protection works)"
  else
    bad "no 483 for Max-Forwards: 0 (got: $(printf '%s' "$resp" | head -1)) — INCONCLUSIVE, FAIL"
  fi
else
  bad "probe path down — Max-Forwards test INCONCLUSIVE, FAIL"
fi

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "M2 ACCEPTANCE: PASS"; exit 0; } || { echo "M2 ACCEPTANCE: FAIL"; exit 1; }
