#!/usr/bin/env bash
# VoIPSec BF12 acceptance test — honeypot log -> blocklist pipeline (offline, deterministic,
# fail-closed & self-validating). Run from lab/:  bash labs/bf12-honeypot/verify.sh
set -u
cd "$(dirname "$0")/../.." || exit 3
DIR=labs/bf12-honeypot

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. pipeline extracts + dedupes scanner IPs into ipset commands =="
out=$(bash "$DIR/hp2ipset.sh" "$DIR/sample-honeypot.log" 2>/dev/null)
n=$(printf '%s\n' "$out" | grep -c 'add element')
[ "$n" -eq 3 ] && ok "3 unique sources from 5 log lines (deduped)" || bad "expected 3 add-element lines, got $n"
printf '%s' "$out" | grep -q 'banned_v4 { 203.0.113.5 timeout' && ok "well-formed nft add-element with timeout" || bad "malformed ipset command"

echo "== 2. self-validation: a clean log yields no bans =="
tmp=$(mktemp); printf '2026-07-03T00:00:00Z startup ok\n' > "$tmp"
c=$(bash "$DIR/hp2ipset.sh" "$tmp" 2>/dev/null | grep -c 'add element')
[ "$c" -eq 0 ] && ok "no bans from a log with no honeypot hits (no false bans)" || bad "false ban on clean log"
rm -f "$tmp"

echo "== 3. nftables ruleset defines the timeout'd blocklist set =="
grep -q 'set banned_v4' "$DIR/nftables-honeypot.nft" && grep -q 'ip saddr @banned_v4 drop' "$DIR/nftables-honeypot.nft" \
  && ok "banned_v4 set + drop rule present" || bad "blocklist set/rule missing"
if command -v nft >/dev/null 2>&1; then
  nft -c -f "$DIR/nftables-honeypot.nft" >/dev/null 2>&1 && ok "nft -c validates" || bad "nft rejected ruleset"
else
  echo "  NOTE: nft not present — validate on host: nft -c -f $DIR/nftables-honeypot.nft"
fi

echo "== 4. Wazuh rule/active-response well-formed =="
python3 -c "import xml.dom.minidom as m; m.parseString('<r>'+open('$DIR/wazuh-honeypot.xml').read()+'</r>')" 2>/dev/null \
  && ok "wazuh-honeypot.xml parses (decoder+rule+active-response)" || bad "wazuh XML malformed"
grep -q 'active-response' "$DIR/wazuh-honeypot.xml" && ok "active-response wired to the honeypot rule" || bad "no active-response"

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "BF12 ACCEPTANCE: PASS"; exit 0; } || { echo "BF12 ACCEPTANCE: FAIL"; exit 1; }
