#!/usr/bin/env bash
# VoIPSec M1 acceptance test — grader for the "signaling reaches the border" core of Lab 1.1.
# Fail-closed: requires the probe path (client + edge-sbc) to be up, then asserts a REGISTER
# through the SBC succeeds (the stub registrar returns 200 until M12 adds real auth).
# Run from lab/:  bash labs/m1-foundations/verify.sh
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. probe path up (fail-closed prerequisite) =="
path_ok=1
for s in edge-sbc pbx-a client; do
  if $COMPOSE ps --status running --services 2>/dev/null | grep -qx "$s"; then
    ok "$s running"
  else
    bad "$s not running"; path_ok=0
  fi
done

echo "== 2. REGISTER traverses the SBC (signaling plane) =="
if [ "$path_ok" -eq 1 ]; then
  if $COMPOSE exec -T client \
       sipp -sf /scenarios/register.xml 172.28.10.10:5060 -s 1001 -i 172.28.10.40 \
            -m 1 -timeout 10s -nostdin >/dev/null 2>&1; then
    ok "client -> edge-sbc REGISTER returned 200 (registrar path works)"
  else
    bad "REGISTER did not succeed through the SBC"
  fi
else
  bad "probe path down — REGISTER test INCONCLUSIVE (treated as FAIL, not skipped)"
fi

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "M1 ACCEPTANCE: PASS"; exit 0; } || { echo "M1 ACCEPTANCE: FAIL"; exit 1; }
