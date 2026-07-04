#!/usr/bin/env bash
# VoIPSec BF2 — NG112-style emergency routing decision (multi-jurisdiction). Maps (dialed number,
# jurisdiction) to a PSAP and enforces the invariant shared by RAY BAUM'S (US), EECC Art 109 (EU)
# and ATA C674 (AU): an emergency call MUST carry a dispatchable location — fail-closed if it does
# not. Deterministic (a teaching stand-in for an ECRF/LoST location→PSAP lookup, RFC 5222).
#   emergency-route.sh <dialed> <jurisdiction> [--location present|absent]
# jurisdiction: US | AU | UK | EU (or a EU country code: DE, FR, IE …)
set -u
DIALED="${1:?usage: emergency-route.sh <dialed> <jurisdiction> [--location present|absent]}"
JUR_IN="${2:?need jurisdiction (US|AU|UK|EU|DE|FR|…)}"
LOC="present"; [ "${3:-}" = "--location" ] && LOC="${4:-present}"

# Normalise jurisdiction: any EU member code -> EU.
case "$JUR_IN" in
  US|AU|UK) JUR="$JUR_IN" ;;
  EU|DE|FR|IE|ES|IT|NL|SE|PL|AT|BE|PT|FI|DK) JUR="EU" ;;
  *) echo "UNKNOWN jurisdiction: $JUR_IN"; exit 3 ;;
esac

# Emergency numbers per jurisdiction (112 is valid across EU + AU/UK mobiles).
case "$JUR" in
  US) NUMS="911";     PSAP="US-PSAP (NENA i3/ESInet)";  MANDATE="RAY BAUM'S Act" ;;
  AU) NUMS="000 112"; PSAP="AU Emergency Call Person (Triple Zero)"; MANDATE="ATA C674:2025" ;;
  UK) NUMS="999 112"; PSAP="UK 999 Emergency Operator (Ofcom)"; MANDATE="Ofcom GC A3" ;;
  EU) NUMS="112";     PSAP="EU PSAP (NG112 / ETSI TS 103 479)"; MANDATE="EECC Art 109" ;;
esac

is_emergency=0
for n in $NUMS; do [ "$DIALED" = "$n" ] && is_emergency=1; done

if [ "$is_emergency" -eq 0 ]; then
  echo "NON-EMERGENCY: $DIALED is not an emergency number in $JUR — route normally."
  exit 0
fi

# Emergency call. Fail-closed on missing location (the cross-jurisdiction invariant).
if [ "$LOC" != "present" ]; then
  echo "REFUSE: emergency $DIALED ($JUR) has NO dispatchable location — violates $MANDATE."
  echo "  A locationless emergency call must be flagged, never silently routed."
  exit 1
fi

echo "ROUTE: $JUR emergency '$DIALED' -> $PSAP"
echo "  location: present (PIDF-LO) · priority: Resource-Priority esnet.1 · mandate: $MANDATE"
exit 0
