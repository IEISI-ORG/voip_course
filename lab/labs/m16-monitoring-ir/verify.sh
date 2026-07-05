#!/usr/bin/env bash
# VoIPSec M16 acceptance test — alert rules are well-formed and cover the M14 threats (offline,
# deterministic, fail-closed). promtool is used if present; else a YAML parse.
# Run from lab/:  bash labs/m16-monitoring-ir/verify.sh
set -u
cd "$(dirname "$0")/../.." || exit 3
DIR=labs/m16-monitoring-ir
RULES="$DIR/alert-rules.yml"
SIGS="$DIR/detection-signatures.md"

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. alert rules well-formed =="
if command -v promtool >/dev/null 2>&1; then
  promtool check rules "$RULES" >/dev/null 2>&1 && ok "promtool check rules OK" || bad "promtool rejected the rules"
elif command -v python3 >/dev/null 2>&1; then
  python3 -c "import yaml,sys; yaml.safe_load(open('$RULES'))" 2>/dev/null && ok "alert-rules.yml is valid YAML (install promtool for full check)" || bad "alert-rules.yml invalid YAML"
else
  bad "no promtool/python3 to validate rules"
fi

echo "== 2. required security alerts present =="
for a in HighSIPFailureRatio RegistrationFlood InviteFlood CertExpiringSoon TollFraudSpend RecordingAccessAnomaly; do
  grep -q "alert: $a" "$RULES" && ok "alert $a defined" || bad "alert $a missing"
done

echo "== 3. detection signatures cover the M14 threats =="
for t in T1 T2 T3 T4 T8 T10 T14; do
  grep -q "| $t " "$SIGS" && ok "$t has a detection signature" || bad "$t detection signature missing"
done

echo "== 4. IR runbook covers the three required scenarios =="
for s in "Toll fraud" "INVITE flood" "eavesdropping"; do
  grep -qi "$s" "$DIR/incident-runbook-template.md" && ok "runbook covers: $s" || bad "runbook missing: $s"
done

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "M16 ACCEPTANCE: PASS"; exit 0; } || { echo "M16 ACCEPTANCE: FAIL"; exit 1; }
