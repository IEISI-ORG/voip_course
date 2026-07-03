#!/usr/bin/env bash
# VoIPSec BF9 acceptance test — dual-stack firewall parity + config (offline, deterministic,
# fail-closed & self-validating: the parity checker must PASS the good ruleset AND catch a gap).
# Run from lab/:  bash labs/bf9-dual-stack/verify.sh
set -u
cd "$(dirname "$0")/../.." || exit 3
DIR=labs/bf9-dual-stack
NFT="$DIR/nftables-dual-stack.nft"

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. shipped ruleset has v4/v6 parity =="
if bash "$DIR/parity-check.sh" "$NFT" 2>/dev/null | grep -q 'PARITY: OK'; then
  ok "IPv4 and IPv6 allow the same ports"
else
  bad "parity check did not confirm parity"
fi

echo "== 2. self-validation: a v6 gap is caught =="
tmp=$(mktemp)
sed '/table ip6 voipsec6/,/^}/ s/tcp dport 5061 accept//' "$NFT" > "$tmp"
if bash "$DIR/parity-check.sh" "$tmp" 2>/dev/null | grep -q 'PARITY: FAIL'; then
  ok "injected v6 blind spot detected (checker is meaningful)"
else
  bad "checker missed an injected gap (fail-open!)"
fi
rm -f "$tmp"

echo "== 3. Kamailio has dual-stack listeners + rtpengine 4<->6 =="
grep -q 'listen=udp:\[' "$DIR/kamailio-v6.snippet.cfg"  && ok "IPv6 SIP listener present" || bad "no v6 listener"
grep -qi 'IPv4<->IPv6\|IPv4.*IPv6 media\|address-family' "$DIR/kamailio-v6.snippet.cfg" && ok "rtpengine 4<->6 media bridge noted" || bad "no 4<->6 media bridge"

echo "== 4. nftables ruleset well-formed (if nft present) =="
if command -v nft >/dev/null 2>&1; then
  nft -c -f "$NFT" >/dev/null 2>&1 && ok "nft -c validates" || bad "nft rejected the ruleset"
else
  echo "  NOTE: nft not present — validate on the lab host: nft -c -f $NFT"
fi

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "BF9 ACCEPTANCE: PASS"; exit 0; } || { echo "BF9 ACCEPTANCE: FAIL"; exit 1; }
