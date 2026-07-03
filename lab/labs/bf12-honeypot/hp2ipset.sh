#!/usr/bin/env bash
# SOVOC BF12 — turn honeypot hits into nftables blocklist entries. Every source that touches the
# decoy is malicious by definition, so ban it (with a timeout). Deterministic.
#   hp2ipset.sh <honeypot.log>            # print `add element` commands
#   hp2ipset.sh <honeypot.log> --apply    # apply them (needs nft + the ruleset loaded)
set -u
LOG="${1:?usage: hp2ipset.sh <honeypot.log> [--apply]}"
[ -f "$LOG" ] || { echo "no such log: $LOG"; exit 3; }
TABLE="${TABLE:-inet sovoc_edge}"
SET="${SET:-banned_v4}"
TIMEOUT="${TIMEOUT:-1h}"

# Extract unique source IPv4s from `src=<ip>` fields.
ips=$(grep -oE 'src=([0-9]{1,3}\.){3}[0-9]{1,3}' "$LOG" | cut -d= -f2 | sort -u)

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
echo "# $n unique source(s) from $LOG" 1>&2
