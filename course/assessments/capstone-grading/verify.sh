#!/usr/bin/env bash
# VoIPSec — self-test for the capstone grading harness (offline, deterministic, fail-closed).
# Confirms the gate: total >= 70 AND every security category >= 50% max.
# Run:  bash course/assessments/capstone-grading/verify.sh
set -u
cd "$(dirname "$0")" || exit 3
pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

mk() { # write a scoresheet with the 9 scores given as args
  printf 'category,max,security,score\n'
  printf 'Functionality,15,no,%s\n' "$1"
  printf 'Reproducibility & IaC + secure CI,15,no,%s\n' "$2"
  printf 'Signaling + media encryption,15,yes,%s\n' "$3"
  printf 'Identity (digest + STIR/SHAKEN),10,yes,%s\n' "$4"
  printf 'Edge/border defense,10,yes,%s\n' "$5"
  printf 'Fraud prevention,10,yes,%s\n' "$6"
  printf 'Observability + detection,10,no,%s\n' "$7"
  printf 'IR runbooks executed,10,yes,%s\n' "$8"
  printf 'Documentation quality,5,no,%s\n' "$9"
}

echo "== 1. strong scores -> PASS =="
mk 13 12 14 9 8 8 8 9 4 > /tmp/c_pass.csv
bash score-capstone.sh /tmp/c_pass.csv 2>/dev/null | grep -q 'CAPSTONE: PASS' && ok "85/100, all security ok -> PASS" || bad "strong scoresheet not PASS"

echo "== 2. security gate overrides a high total =="
mk 15 15 2 10 10 10 10 10 5 > /tmp/c_secfail.csv   # total 87 but encryption 2/15
out=$(bash score-capstone.sh /tmp/c_secfail.csv 2>/dev/null)
echo "$out" | grep -q 'CAPSTONE: FAIL' && ok "high total but failing security cat -> FAIL" || bad "security gate not enforced"
echo "$out" | grep -q 'Signaling + media encryption' && ok "names the failing security category" || bad "did not name failing category"

echo "== 3. low total -> FAIL =="
mk 5 5 6 4 4 4 4 4 2 > /tmp/c_low.csv              # total 38
bash score-capstone.sh /tmp/c_low.csv 2>/dev/null | grep -q 'total < 70' && ok "total 38 -> FAIL (total<70)" || bad "low total not failed"

echo "== 4. invalid (score > max) rejected =="
mk 99 12 14 9 8 8 8 9 4 > /tmp/c_bad.csv
bash score-capstone.sh /tmp/c_bad.csv 2>/dev/null | grep -q 'INVALID' && ok "score exceeding max rejected" || bad "invalid scoresheet accepted"

echo "== 5. template sums to 100 =="
m=$(awk -F, 'NR>1&&$1!=""{s+=$2} END{print s}' scoresheet.csv)
[ "$m" = "100" ] && ok "scoresheet max points = 100" || bad "template max != 100 ($m)"

rm -f /tmp/c_*.csv
echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "CAPSTONE-HARNESS: PASS"; exit 0; } || { echo "CAPSTONE-HARNESS: FAIL"; exit 1; }
