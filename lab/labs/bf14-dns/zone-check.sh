#!/usr/bin/env bash
# SOVOC BF14 — validate the SIP DNS zone (RFC 3263). Uses named-checkzone if present; otherwise
# structural checks: SOA, NAPTR present, SRV failover (>=2 priorities per service), low TTL.
# Usage: zone-check.sh [zonefile]
set -u
Z="${1:-$(dirname "$0")/db.lab.sovoc.test}"
[ -f "$Z" ] || { echo "no zone file: $Z"; exit 3; }

if command -v named-checkzone >/dev/null 2>&1; then
  named-checkzone lab.sovoc.test "$Z" && { echo "ZONE OK (named-checkzone)"; exit 0; } || exit 1
fi

echo "named-checkzone not present — structural validation of $Z"
fail=0
grep -qE 'SOA' "$Z"   && echo "  ok: SOA present"   || { echo "  MISSING: SOA"; fail=1; }
naptr=$(grep -vE '^\s*;' "$Z" | grep -cE '[[:space:]]NAPTR[[:space:]]'); [ "$naptr" -ge 1 ] && echo "  ok: $naptr NAPTR record(s)" || { echo "  MISSING: NAPTR"; fail=1; }

# SRV failover: each service should have >=2 distinct priorities.
for svc in _sips._tcp _sip._udp; do
  prios=$(awk -v s="$svc" '$1==s && $3=="SRV"{print $4}' "$Z" | sort -u | wc -l | tr -d ' ')
  [ "$prios" -ge 2 ] && echo "  ok: $svc has $prios SRV priorities (failover)" || { echo "  FAIL: $svc lacks a failover target"; fail=1; }
done

ttl=$(awk '/^\$TTL/{print $2}' "$Z")
{ [ -n "$ttl" ] && [ "$ttl" -le 60 ]; } 2>/dev/null && echo "  ok: low \$TTL=$ttl (safe cut-over/rollback)" || { echo "  WARN: \$TTL not low (cut-over slow)"; fail=1; }

[ "$fail" -eq 0 ] && { echo "ZONE OK (structural)"; exit 0; } || { echo "ZONE FAIL"; exit 1; }
