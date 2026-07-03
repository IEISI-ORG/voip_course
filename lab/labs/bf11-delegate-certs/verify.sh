#!/usr/bin/env bash
# VoIPSec BF11 acceptance test — delegate-cert chain + attestation scope (offline, deterministic,
# fail-closed & self-validating). Run from lab/:  bash labs/bf11-delegate-certs/verify.sh
set -u
cd "$(dirname "$0")/../.." || exit 3
DIR=labs/bf11-delegate-certs
command -v openssl >/dev/null 2>&1 || { echo "needs openssl"; exit 3; }

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

W=$(mktemp -d)
echo "== 1. delegate cert chains to the SP CA =="
if bash "$DIR/delegate-ca.sh" demo "$W" >/dev/null 2>&1 && [ -f "$W/ent.crt" ]; then
  openssl verify -CAfile "$W/ca.crt" "$W/ent.crt" >/dev/null 2>&1 \
    && ok "enterprise delegate cert verified via SP CA" || bad "chain verify failed"
else
  bad "delegate-ca demo did not produce a cert"
fi

echo "== 2. self-validation: a rogue self-signed cert does NOT chain =="
openssl req -x509 -newkey rsa:2048 -nodes -keyout "$W/rogue.key" -out "$W/rogue.crt" \
  -subj "/CN=rogue" -days 1 2>/dev/null
if openssl verify -CAfile "$W/ca.crt" "$W/rogue.crt" >/dev/null 2>&1; then
  bad "rogue cert wrongly verified (chain check is fail-open!)"
else
  ok "rogue cert rejected by the SP CA (delegation trust is real)"
fi

echo "== 3. attestation only within the delegated TN scope =="
RANGE=$(cat "$W/tn-scope.txt" 2>/dev/null || echo 14155550100-14155550199)
bash "$DIR/attest-scope.sh" +1-415-555-0142 "$RANGE" 2>/dev/null | grep -q 'ATTEST=A' \
  && ok "in-scope number signs at A" || bad "in-scope number not A"
bash "$DIR/attest-scope.sh" +1-415-555-9999 "$RANGE" 2>/dev/null | grep -q 'refuse' \
  && ok "out-of-scope number refused A (no forgery)" || bad "out-of-scope number wrongly signed A"

rm -rf "$W"
echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "BF11 ACCEPTANCE: PASS"; exit 0; } || { echo "BF11 ACCEPTANCE: FAIL"; exit 1; }
