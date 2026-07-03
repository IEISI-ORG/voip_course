#!/usr/bin/env bash
# SOVOC BF8 acceptance test — secure-recording controls work (offline, deterministic, fail-closed).
# Run from lab/:  bash labs/bf8-secure-recording/verify.sh
set -u
cd "$(dirname "$0")/../.." || exit 3
T="labs/bf8-secure-recording/secure-recording.sh"

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

out=$(bash "$T" demo 2>/dev/null)

echo "== 1. encryption at rest (round-trip) =="
echo "$out" | grep -q 'round-trip OK' && ok "encrypt->decrypt recovers the recording" || bad "encryption round-trip broken"

echo "== 2. RBAC + audit trail =="
echo "$out" | grep -q 'ALLOW: auditor' && ok "allowlisted role granted access" || bad "RBAC allow broken"
echo "$out" | grep -q 'DENY: mallory'  && ok "non-allowlisted role denied"      || bad "RBAC deny broken"
echo "$out" | grep -q 'ALLOW user=auditor' && echo "$out" | grep -q 'DENY  user=mallory' \
  && ok "both access decisions written to the audit trail" || bad "audit trail incomplete"

echo "== 3. DTMF/PAN masking (PCI-DSS) =="
echo "$out" | grep -q 'card=\*\*\*\*1111' && ok "PAN masked to last 4 (no full card stored)" || bad "PAN not masked"
echo "$out" | grep -q 'PIN=\*\*\*\*'      && ok "PIN fully masked"                           || bad "PIN not masked"

echo "== 4. independent mask check =="
m=$(bash "$T" mask-dtmf "sensitive 4111111111111111 end" 2>/dev/null)
printf '%s' "$m" | grep -q '4111111111111111' && bad "full PAN leaked through mask" || ok "full PAN never appears after masking"

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "BF8 ACCEPTANCE: PASS"; exit 0; } || { echo "BF8 ACCEPTANCE: FAIL"; exit 1; }
