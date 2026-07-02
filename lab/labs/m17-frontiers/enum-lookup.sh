#!/usr/bin/env bash
# SOVOC M17 Lab 17.2 — ENUM (RFC 6116): E.164 -> e164.arpa NAPTR query name -> SIP URI.
# Deterministic. Uses a built-in private-ENUM sample map (no public DNS). If `dig` is present
# and RESOLVE=1, it also queries a real NAPTR (for the lab BIND zone).
# Usage: enum-lookup.sh "+1 415 555 0100"
set -u
RAW="${1:-+14155550100}"
NUM=$(printf '%s' "$RAW" | tr -cd '0-9')
[ -n "$NUM" ] || { echo "usage: enum-lookup.sh <E.164>"; exit 3; }

# Reverse digits, dot-separate, append the ENUM apex.
QNAME="$(printf '%s' "$NUM" | rev | sed 's/\(.\)/\1./g')e164.arpa"
echo "E.164   : +$NUM"
echo "ENUM q  : $QNAME  (NAPTR)"

# Private-ENUM sample map (number -> SIP URI). This is the internal e164.arpa zone.
case "$NUM" in
  14155550100) URI="sip:1001@lab.sovoc.test" ;;
  14155550200) URI="sip:1002@lab.sovoc.test" ;;
  *)           URI="" ;;
esac
if [ -n "$URI" ]; then
  echo "NAPTR   : 100 10 \"u\" \"E2U+sip\" \"!^.*\$!$URI!\" ."
  echo "resolves: $URI"
else
  echo "resolves: (no private-ENUM record — would fall through to carrier ENUM / reject)"
fi

if [ "${RESOLVE:-0}" = "1" ] && command -v dig >/dev/null 2>&1; then
  echo "--- live NAPTR (lab BIND) ---"
  dig +short NAPTR "$QNAME" 2>/dev/null || echo "(no live answer)"
fi
