#!/usr/bin/env bash
# SOVOC M17 acceptance test — ENUM encoding/routing is correct (Lab 17.2). Deterministic,
# offline, fail-closed. Fax (T.38) and the CPaaS API labs are capture/config-graded.
# Run from lab/:  bash labs/m17-frontiers/verify.sh
set -u
cd "$(dirname "$0")/../.." || exit 3
TOOL=labs/m17-frontiers/enum-lookup.sh

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. ENUM query-name encoding (RFC 6116) =="
out=$(bash "$TOOL" "+1 415 555 0100" 2>/dev/null)
echo "$out" | grep -q '0.0.1.0.5.5.5.5.1.4.1.e164.arpa' \
  && ok "E.164 -> reversed e164.arpa NAPTR name correct" \
  || bad "ENUM query name wrong"
echo "$out" | grep -q 'sip:1001@lab.sovoc.test' \
  && ok "private-ENUM resolves to the mapped SIP URI" \
  || bad "ENUM did not resolve to the expected URI"

echo "== 2. unknown number falls through (no silent misroute) =="
bash "$TOOL" "+19998887777" 2>/dev/null | grep -q 'no private-ENUM record' \
  && ok "unmapped number falls through cleanly" \
  || bad "unmapped number did not fall through"

echo "== 3. digits-only normalization =="
bash "$TOOL" "+1 (415) 555-0200" 2>/dev/null | grep -q 'sip:1002@lab.sovoc.test' \
  && ok "punctuation stripped; formatted E.164 resolves" \
  || bad "formatted E.164 not normalized"

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "M17 ACCEPTANCE: PASS"; exit 0; } || { echo "M17 ACCEPTANCE: FAIL"; exit 1; }
