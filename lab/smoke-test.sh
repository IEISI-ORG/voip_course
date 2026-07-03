#!/usr/bin/env bash
# SOVOC — end-to-end smoke test (E0). Brings the base topology up, waits for health, asserts the
# segmentation invariant, and drives one real REGISTER through the border. This is the "whole
# platform works together" check — heavier than the offline graders, so run it on a host/CI with
# Docker (not on every push). Run from lab/:  bash smoke-test.sh [--keep]
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")" || exit 3
KEEP="${1:-}"
command -v docker >/dev/null 2>&1 || { echo "SKIP: docker not present"; exit 0; }

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

cleanup(){ [ "$KEEP" = "--keep" ] || $COMPOSE down -v >/dev/null 2>&1; }
trap cleanup EXIT

echo "== 1. bring up the base topology =="
$COMPOSE up -d --build >/dev/null 2>&1 && ok "compose up" || { bad "compose up failed"; exit 1; }

echo "== 2. wait for core services to be running =="
ready=0
for i in $(seq 1 30); do
  up=$($COMPOSE ps --status running --services 2>/dev/null | grep -cE '^(edge-sbc|rtpengine|pbx-a|client|redteam)$')
  [ "$up" -ge 5 ] && { ready=1; break; }
  sleep 2
done
[ "$ready" -eq 1 ] && ok "core services running" || bad "services did not come up in time"

echo "== 3. segmentation invariant (M0 grader) =="
bash labs/m0-orientation/verify.sh 2>/dev/null | grep -q 'M0 ACCEPTANCE: PASS' \
  && ok "segmentation holds (redteam blocked from core)" || bad "M0 segmentation grader failed"

echo "== 4. end-to-end signaling: REGISTER through the SBC =="
$COMPOSE exec -T client \
  sipp -sf /scenarios/register.xml 172.28.10.10:5060 -s 1001 -i 172.28.10.40 -m 1 -timeout 10s -nostdin >/dev/null 2>&1 \
  && ok "client -> edge-sbc REGISTER -> 200" || bad "REGISTER did not complete end to end"

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "SMOKE TEST: PASS"; exit 0; } || { echo "SMOKE TEST: FAIL"; exit 1; }
