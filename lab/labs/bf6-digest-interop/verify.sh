#!/usr/bin/env bash
# VoIPSec BF6 acceptance test — digest interop math + downgrade rejection (offline, deterministic,
# fail-closed). Live 401 dual-challenge is capture-graded (M13 lab).
# Run from lab/:  bash labs/bf6-digest-interop/verify.sh
set -u
cd "$(dirname "$0")/../.." || exit 3
T="labs/bf6-digest-interop/digest-interop.sh"

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. algorithm matters: MD5 != SHA-256 =="
md5=$(bash "$T" compute MD5     | sed 's/.*response=//')
s256=$(bash "$T" compute SHA-256 | sed 's/.*response=//')
[ "${#md5}" -eq 32 ]  && ok "MD5 response is 32 hex chars"     || bad "MD5 length wrong (${#md5})"
[ "${#s256}" -eq 64 ] && ok "SHA-256 response is 64 hex chars" || bad "SHA-256 length wrong (${#s256})"
[ "$md5" != "$s256" ] && ok "responses differ by algorithm"   || bad "responses identical (broken)"

echo "== 2. deterministic (same inputs -> same response) =="
s256b=$(bash "$T" compute SHA-256 | sed 's/.*response=//')
[ "$s256" = "$s256b" ] && ok "SHA-256 response reproducible" || bad "non-deterministic digest"

echo "== 3. downgrade rejection policy (RFC 8760) =="
bash "$T" downgrade-check "SHA-256,MD5" SHA-256 | grep -q 'DECISION=accept' && ok "strongest chosen -> accept" || bad "strongest wrongly rejected"
bash "$T" downgrade-check "SHA-256,MD5" MD5     | grep -q 'DECISION=reject' && ok "MD5 when SHA-256 offered -> reject (downgrade)" || bad "downgrade NOT rejected"
bash "$T" downgrade-check "MD5" MD5             | grep -q 'DECISION=accept' && ok "MD5 when only MD5 offered -> accept" || bad "MD5-only wrongly rejected"

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "BF6 ACCEPTANCE: PASS"; exit 0; } || { echo "BF6 ACCEPTANCE: FAIL"; exit 1; }
