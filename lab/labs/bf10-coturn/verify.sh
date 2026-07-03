#!/usr/bin/env bash
# SOVOC BF10 acceptance test — coturn hardening audit + short-term credential lifecycle (offline,
# deterministic, fail-closed & self-validating). Run from lab/:  bash labs/bf10-coturn/verify.sh
set -u
cd "$(dirname "$0")/../.." || exit 3
DIR=labs/bf10-coturn
CONF="$DIR/turnserver.conf"

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. hardened config passes the audit =="
bash "$DIR/coturn-audit.sh" "$CONF" 2>/dev/null | grep -q 'COTURN AUDIT: PASS' \
  && ok "all hardening controls present" || bad "hardened config failed audit"

echo "== 2. self-validation: a weakened config is caught =="
tmp=$(mktemp)
grep -v '^use-auth-secret\|^denied-peer-ip=10\.' "$CONF" > "$tmp"   # drop SSRF fence + REST creds
if bash "$DIR/coturn-audit.sh" "$tmp" 2>/dev/null | grep -q 'issue(s)'; then
  ok "audit catches removed use-auth-secret + denied-peer-ip (not fail-open)"
else
  bad "audit missed a weakened config"
fi
rm -f "$tmp"

echo "== 3. short-term REST credential round-trip =="
cred=$(bash "$DIR/turn-cred.sh" gen labsecret 300 alice 2>/dev/null)
u=$(printf '%s' "$cred" | sed -n 's/username=//p'); p=$(printf '%s' "$cred" | sed -n 's/password=//p')
bash "$DIR/turn-cred.sh" verify labsecret "$u" "$p" 2>/dev/null | grep -q '^VALID' \
  && ok "valid HMAC credential accepted" || bad "credential round-trip broke"

echo "== 4. expired credential rejected =="
oldcred=$(bash "$DIR/turn-cred.sh" gen labsecret -100 alice 2>/dev/null)
ou=$(printf '%s' "$oldcred" | sed -n 's/username=//p'); op=$(printf '%s' "$oldcred" | sed -n 's/password=//p')
bash "$DIR/turn-cred.sh" verify labsecret "$ou" "$op" 2>/dev/null | grep -q 'EXPIRED' \
  && ok "expired credential rejected (leaked creds self-expire)" || bad "expired credential accepted"

echo "== 5. wrong secret rejected =="
bash "$DIR/turn-cred.sh" verify WRONGSECRET "$u" "$p" 2>/dev/null | grep -q 'INVALID' \
  && ok "HMAC with wrong secret rejected" || bad "forged credential accepted"

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "BF10 ACCEPTANCE: PASS"; exit 0; } || { echo "BF10 ACCEPTANCE: FAIL"; exit 1; }
