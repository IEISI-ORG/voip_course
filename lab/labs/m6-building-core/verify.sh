#!/usr/bin/env bash
# SOVOC M6 acceptance test — the strongest security grader so far: queries the live PBXs for
# secure-default compliance (Lab 6.3). Fail-closed: any check whose command can't run is FAIL,
# not skipped. Run from lab/:  bash labs/m6-building-core/verify.sh
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. PBXs running (fail-closed) =="
for s in pbx-a pbx-b; do
  $COMPOSE ps --status running --services 2>/dev/null | grep -qx "$s" && ok "$s running" || bad "$s not running"
done

echo "== 2. Asterisk (pbx-a) secure defaults =="
# 2a. secret file not world-readable (T11)
mode=$($COMPOSE exec -T pbx-a stat -c '%a' /etc/asterisk/pjsip.conf 2>/dev/null)
if [ -n "$mode" ] && [ "$(( 8#$mode & 4 ))" -eq 0 ]; then
  ok "pjsip.conf not world-readable (mode $mode)"
else
  bad "pjsip.conf world-readable or unreadable (mode='${mode:-none}') — secret hygiene FAIL"
fi
# 2b. legacy chan_sip not loaded
if $COMPOSE exec -T pbx-a asterisk -rx 'module show like chan_sip.so' 2>/dev/null | grep -q '0 modules loaded'; then
  ok "chan_sip.so not loaded (legacy stack disabled)"
else
  bad "chan_sip.so present or Asterisk unreachable — FAIL"
fi
# 2c. no anonymous endpoint (anonymous calling / toll fraud T4)
if $COMPOSE exec -T pbx-a asterisk -rx 'pjsip show endpoint anonymous' 2>/dev/null | grep -qi 'unable to find'; then
  ok "no 'anonymous' PJSIP endpoint (anonymous calling blocked)"
else
  bad "anonymous endpoint exists or query failed — FAIL"
fi

echo "== 3. FreeSWITCH (pbx-b) secure defaults =="
pw=$($COMPOSE exec -T pbx-b fs_cli -x 'eval $${default_password}' 2>/dev/null | tr -d '[:space:]')
if [ -n "$pw" ] && [ "$pw" != "1234" ]; then
  ok "default_password changed from stock 1234"
else
  bad "default_password is stock/unknown ('${pw:-none}') — FAIL"
fi

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "M6 ACCEPTANCE: PASS"; exit 0; } || { echo "M6 ACCEPTANCE: FAIL"; exit 1; }
