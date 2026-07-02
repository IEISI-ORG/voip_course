#!/usr/bin/env bash
# SOVOC M5 acceptance test — analysis toolchain prerequisites (fail-closed). Fault diagnosis,
# HOMER correlation, and evidence handling are rubric-graded (see README).
# Run from lab/:  bash labs/m5-packet-analysis/verify.sh
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
SBC=172.28.10.10

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }
note(){ echo "  NOTE: $1"; }

echo "== 1. base path up (fail-closed) =="
path_ok=1
for s in edge-sbc pbx-a client; do
  if $COMPOSE ps --status running --services 2>/dev/null | grep -qx "$s"; then
    ok "$s running"; else bad "$s not running"; path_ok=0; fi
done

echo "== 2. signaling positive control =="
if [ "$path_ok" -eq 1 ] && $COMPOSE exec -T client \
     sipp -sf /scenarios/register.xml $SBC:5060 -s 1001 -i 172.28.10.40 -m 1 -timeout 10s -nostdin >/dev/null 2>&1; then
  ok "REGISTER -> 200 (traffic to analyze is reachable)"
else
  bad "REGISTER failed — INCONCLUSIVE, FAIL"
fi

echo "== 3. HOMER correlation plane (Lab 5.2, optional profile) =="
if $COMPOSE ps --status running --services 2>/dev/null | grep -qx heplify-server; then
  ok "heplify-server running (HOMER capture available)"
else
  note "obs profile down — run 'make obs-up' for Lab 5.2 (not required to pass)"
fi

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "M5 ACCEPTANCE: PASS"; exit 0; } || { echo "M5 ACCEPTANCE: FAIL"; exit 1; }
