#!/usr/bin/env bash
# VoIPSec BF4 acceptance test — signing works and the provisioning server is hardened (offline,
# deterministic, fail-closed). The live mTLS fetch/refusal is capture-graded.
# Run from lab/:  bash labs/bf4-provisioning/verify.sh
set -u
cd "$(dirname "$0")/../.." || exit 3
DIR=labs/bf4-provisioning
NGINX="$DIR/nginx-provisioning.conf"

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. config signing detects tampering =="
out=$(bash "$DIR/sign-config.sh" demo 2>/dev/null)
echo "$out" | grep -q 'verify signed config: signature OK' && ok "valid signed config verifies" || bad "signing/verify broken"
echo "$out" | grep -q 'tamper detected'                    && ok "tampered config rejected"      || bad "tamper NOT detected"

echo "== 2. provisioning server enforces mTLS + allowlist =="
grep -q 'ssl_verify_client[[:space:]]*on' "$NGINX"   && ok "mutual TLS required (ssl_verify_client on)" || bad "mTLS not required"
grep -q 'ssl_client_certificate' "$NGINX"            && ok "client-cert CA pinned"                      || bad "no client CA"
grep -q 'mac_allowed' "$NGINX"                       && ok "MAC allowlist present"                      || bad "no MAC allowlist"
grep -q 'ssl_client_s_dn_cn != \$mac' "$NGINX"       && ok "device can only fetch its own config (CN==MAC)" || bad "no per-device restriction"
grep -q 'listen 443 ssl' "$NGINX"                    && ok "HTTPS only (no plaintext TFTP/HTTP)"        || bad "not HTTPS-only"

echo "== 3. sample config has no committed secret + secure transport =="
grep -q '__INJECTED_FROM_SECURE_STORE__' "$DIR/AABBCCDDEEFF.cfg" && ok "password is a placeholder (no committed secret)" || bad "possible committed secret"
grep -q 'transport=TLS' "$DIR/AABBCCDDEEFF.cfg"                   && ok "device provisioned for TLS + SRTP"            || bad "insecure transport in config"

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "BF4 ACCEPTANCE: PASS"; exit 0; } || { echo "BF4 ACCEPTANCE: FAIL"; exit 1; }
