#!/usr/bin/env bash
# SOVOC BF9 — nftables dual-stack parity check. Extracts the allowed dports for the IPv4 (table
# ip) and IPv6 (table ip6) families and reports any port allowed on one family but not the other
# (the dual-stack blind spot). A single `table inet` needs no check (parity by construction).
# Usage: parity-check.sh <ruleset.nft>
set -u
F="${1:?usage: parity-check.sh <ruleset.nft>}"
[ -f "$F" ] || { echo "no such file: $F"; exit 3; }

if grep -qE '^\s*table\s+inet\b' "$F" && ! grep -qE '^\s*table\s+ip6?\b' "$F"; then
  echo "PARITY: uses 'table inet' — v4+v6 covered by one ruleset (parity by construction)"
  exit 0
fi

# Collect dport tokens per family by tracking which table we're inside.
ports() { # family-keyword
  awk -v fam="$1" '
    $1=="table" && $2==fam {inb=1}
    inb && /dport/ { for(i=1;i<=NF;i++) if($i=="dport"){print $(i+1)} }
    inb && /^}/ {inb=0}
  ' "$F" | sort -u
}
V4=$(ports ip)
V6=$(ports ip6)

only4=$(comm -23 <(printf '%s\n' "$V4") <(printf '%s\n' "$V6"))
only6=$(comm -13 <(printf '%s\n' "$V4") <(printf '%s\n' "$V6"))

echo "v4 allowed dports: $(echo $V4)"
echo "v6 allowed dports: $(echo $V6)"
if [ -z "$only4" ] && [ -z "$only6" ]; then
  echo "PARITY: OK — IPv4 and IPv6 allow the same ports"
  exit 0
else
  [ -n "$only4" ] && echo "GAP: allowed on v4 but NOT v6: $(echo $only4)"
  [ -n "$only6" ] && echo "GAP: allowed on v6 but NOT v4: $(echo $only6)  <- v6 blind spot!"
  echo "PARITY: FAIL"
  exit 1
fi
