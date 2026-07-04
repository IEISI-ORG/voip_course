#!/usr/bin/env bash
# VoIPSec BF2 acceptance test — emergency-call construction is correct (offline, deterministic,
# fail-closed). Routing 911 to a PSAP sim + SBC not stripping the PIDF-LO is capture-graded.
# Run from lab/:  bash labs/bf2-emergency/verify.sh
set -u
cd "$(dirname "$0")/../.." || exit 3
DIR=labs/bf2-emergency

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. PIDF-LO location object well-formed + dispatchable =="
# Parse safely: a location body can come from an untrusted endpoint, so guard against XXE /
# entity-expansion. Prefer defusedxml; fall back to ElementTree (expat does not expand external
# entities by default). Never use a parser that resolves external entities on caller-supplied XML.
if python3 - "$DIR/pidf-lo-sample.xml" <<'PY' 2>/dev/null
import sys
try:
    from defusedxml.ElementTree import parse
except ImportError:
    from xml.etree.ElementTree import parse
parse(sys.argv[1])
PY
then
  ok "pidf-lo-sample.xml is well-formed XML (parsed with entity protection)"
else
  bad "PIDF-LO not well-formed"
fi
grep -q 'civicAddress' "$DIR/pidf-lo-sample.xml" && ok "civic address present"     || bad "no civic address"
grep -q '<cl:FLR>'     "$DIR/pidf-lo-sample.xml" && ok "floor (dispatchable detail)" || bad "no floor/room (RAY BAUM'S dispatchable location)"
grep -q 'geopriv'      "$DIR/pidf-lo-sample.xml" && ok "geopriv wrapper present"    || bad "no geopriv"

echo "== 2. emergency INVITE carries priority + location =="
msg=$(bash "$DIR/e911-call.sh" 2>/dev/null)
echo "$msg" | grep -q 'Resource-Priority:'        && ok "Resource-Priority header (RFC 4412)"      || bad "no Resource-Priority"
echo "$msg" | grep -q 'application/pidf+xml'       && ok "PIDF-LO body attached (application/pidf+xml)" || bad "no PIDF-LO body"
echo "$msg" | grep -q 'Geolocation:'               && ok "Geolocation header references the body"  || bad "no Geolocation header"
echo "$msg" | grep -q 'multipart/mixed'            && ok "multipart/mixed (SDP + location)"         || bad "not multipart"

echo "== 3. NG112-style routing across jurisdictions (fail-closed on location) =="
R="$DIR/emergency-route.sh"
for pair in "911 US" "000 AU" "999 UK" "112 EU"; do
  bash "$R" $pair 2>/dev/null | grep -q '^ROUTE:' && ok "routes $pair to a PSAP with location" || bad "did not route $pair"
done
# self-validation: a located-absent emergency call must be REFUSED (exit 1), not routed
if bash "$R" 911 US --location absent >/dev/null 2>&1; then
  bad "locationless emergency call was NOT refused (fail-open)"
else
  bash "$R" 911 US --location absent 2>/dev/null | grep -q '^REFUSE' && ok "locationless emergency call refused (RAY BAUM'S/EECC/C674)" || bad "refuse path malformed"
fi
bash "$R" 5551234 US 2>/dev/null | grep -q '^NON-EMERGENCY' && ok "non-emergency number not treated as emergency" || bad "misclassified a normal call"

echo
echo "== note: SBC must NOT strip the PIDF-LO and Resource-Priority must not be forgeable by"
echo "==       untrusted peers (spoofed priority = DoS amplification). Kari's Law: direct 911 + notify."
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "BF2 ACCEPTANCE: PASS"; exit 0; } || { echo "BF2 ACCEPTANCE: FAIL"; exit 1; }
