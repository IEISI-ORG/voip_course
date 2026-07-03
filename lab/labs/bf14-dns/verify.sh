#!/usr/bin/env bash
# SOVOC BF14 acceptance test — DNS zone + BIND security config (offline, deterministic,
# fail-closed & self-validating). Run from lab/:  bash labs/bf14-dns/verify.sh
set -u
cd "$(dirname "$0")/../.." || exit 3
DIR=labs/bf14-dns
Z="$DIR/db.lab.sovoc.test"
CONF="$DIR/named.conf.snippet"

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. zone validates (RFC 3263 records, failover, low TTL) =="
bash "$DIR/zone-check.sh" "$Z" 2>/dev/null | grep -qE 'ZONE OK' && ok "zone-check passes" || bad "zone-check failed"

echo "== 2. records present =="
grep -vE '^\s*;' "$Z" | grep -qE 'NAPTR' && ok "NAPTR (transport selection)" || bad "no NAPTR"
grep -q '_sips._tcp' "$Z" && ok "_sips._tcp SRV (forces TLS transport)" || bad "no _sips._tcp SRV"

echo "== 3. self-validation: a single-target zone fails the failover check =="
tmp=$(mktemp)
grep -v 'edge-sbc-2.lab.sovoc.test.$' "$Z" > "$tmp"   # remove the secondary SRV targets
if bash "$DIR/zone-check.sh" "$tmp" 2>/dev/null | grep -q 'ZONE FAIL'; then
  ok "zone with no secondary SRV is flagged (failover check is meaningful)"
else
  bad "single-target zone not flagged (check fail-open)"
fi
rm -f "$tmp"

echo "== 4. BIND config: DNSSEC + rate-limit + not-open-resolver =="
grep -q 'dnssec-policy' "$CONF"      && ok "DNSSEC signing (dnssec-policy)"        || bad "no DNSSEC"
grep -q 'rate-limit'   "$CONF"       && ok "response-rate-limiting (anti-DoS)"     || bad "no RRL"
grep -qE 'recursion[[:space:]]+no'   "$CONF" && ok "recursion off (not an open resolver)" || bad "recursion not disabled"

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "BF14 ACCEPTANCE: PASS"; exit 0; } || { echo "BF14 ACCEPTANCE: FAIL"; exit 1; }
