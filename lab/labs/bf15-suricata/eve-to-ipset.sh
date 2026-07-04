#!/usr/bin/env bash
# VoIPSec BF15 — turn Suricata EVE JSON alerts into nftables blocklist entries, feeding the SAME
# sink as the honeypot (bf12). Every VOIPSEC alert's source IP is banned (with a timeout).
# Deterministic; uses jq.
#   eve-to-ipset.sh <eve.json>            # print `add element` commands
#   eve-to-ipset.sh <eve.json> --apply    # apply them (needs nft + the ruleset loaded)
set -u
EVE="${1:?usage: eve-to-ipset.sh <eve.json> [--apply]}"
[ -f "$EVE" ] || { echo "no such eve log: $EVE"; exit 3; }
command -v jq >/dev/null 2>&1 || { echo "needs jq"; exit 3; }
TABLE="${TABLE:-inet voipsec_edge}"
SET="${SET:-banned_v4}"
TIMEOUT="${TIMEOUT:-1h}"

# Only alert events, only our VOIPSEC signatures, unique IPv4 sources.
ips=$(jq -r 'select(.event_type=="alert") | select(.alert.signature|test("^VOIPSEC")) | .src_ip' "$EVE" 2>/dev/null \
      | grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$' | sort -u)

n=0
for ip in $ips; do
  cmd="add element $TABLE $SET { $ip timeout $TIMEOUT }"
  if [ "${2:-}" = "--apply" ] && command -v nft >/dev/null 2>&1; then
    nft $cmd 2>/dev/null && echo "applied: $ip" || echo "apply-failed: $ip"
  else
    echo "$cmd"
  fi
  n=$((n+1))
done
echo "# $n unique VOIPSEC-alert source(s) from $EVE" 1>&2
