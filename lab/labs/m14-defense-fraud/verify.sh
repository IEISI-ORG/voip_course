#!/usr/bin/env bash
# VoIPSec M14 acceptance test — the fraud detector catches the IRSF pattern and the hardening
# checklist exists (Labs 14.1/14.2). Deterministic (offline analytics); fail-closed.
# Run from lab/:  bash labs/m14-defense-fraud/verify.sh
set -u
cd "$(dirname "$0")/../.." || exit 3
DIR=labs/m14-defense-fraud

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. fraud detector flags the sample IRSF burst =="
out=$(bash "$DIR/fraud-detect.sh" 2>/dev/null)
echo "$out" | grep -q 'spend cap breached'        && ok "spend-cap breach detected"      || bad "cap breach not detected"
echo "$out" | grep -qi 'IRSF'                      && ok "IRSF prefix spike detected"     || bad "IRSF spike not detected"
echo "$out" | grep -q 'SUSPEND-RECOMMEND: account 1001' && ok "auto-suspend targets the offending account" || bad "offending account not identified"

echo "== 2. clean CDR does NOT false-positive =="
tmp=$(mktemp)
printf 'ts,src,dst,dur_s,cost\n2026-07-03T09:00:00,1001,+13105551212,42,0.02\n2026-07-03T09:01:00,1002,+14155550100,60,0.03\n' > "$tmp"
clean=$(CAP=20 bash "$DIR/fraud-detect.sh" "$tmp" 2>/dev/null)
echo "$clean" | grep -q '== 0 alert(s) ==' && ok "no alerts on a clean CDR (no false positive)" || bad "false positive on clean CDR"
rm -f "$tmp"

echo "== 3. hardening checklist available (Lab 14.1 v-final base) =="
[ -f labs/m6-building-core/hardening-checklist.md ] && ok "hardening checklist template present" || bad "hardening checklist missing"

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "M14 ACCEPTANCE: PASS"; exit 0; } || { echo "M14 ACCEPTANCE: FAIL"; exit 1; }
