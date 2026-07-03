#!/usr/bin/env bash
# VoIPSec M8 acceptance test — proves the SBC bans a scanner by its UA fingerprint (Lab 8.3).
# Self-validating & fail-closed: a plain probe must be answered pre-scan (control); then a
# single svmap scan (User-Agent: friendly-scanner) must get the source banned (silence).
# Side effect: bans the redteam IP ~300s. Run from lab/:  bash labs/m8-nat-firewall/verify.sh
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
SBC=172.28.10.10

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

probe() {
  $COMPOSE exec -T redteam sh -c \
    "printf 'OPTIONS sip:$SBC SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.90:5060;branch=z9hG4bK-$1\r\nMax-Forwards: 70\r\nFrom: <sip:p@172.28.10.90>;tag=$1\r\nTo: <sip:$SBC>\r\nCall-ID: m8-$1-\$\$\r\nCSeq: 1 OPTIONS\r\nContent-Length: 0\r\n\r\n' | ncat -u -w2 $SBC 5060" 2>/dev/null
}

echo "== 1. services up (fail-closed) =="
path_ok=1
for s in edge-sbc redteam; do
  $COMPOSE ps --status running --services 2>/dev/null | grep -qx "$s" && ok "$s running" || { bad "$s not running"; path_ok=0; }
done

echo "== 2. positive control: plain probe answered pre-scan =="
ctrl_ok=0
if [ "$path_ok" -eq 1 ] && printf '%s' "$(probe pre)" | grep -q 'SIP/2.0'; then
  ok "SBC answers a normal OPTIONS (probe works, not pre-banned)"; ctrl_ok=1
else
  bad "no pre-scan response (SBC down or redteam already banned — cooldown ~300s) — INCONCLUSIVE, FAIL"
fi

echo "== 3. scan with svmap, then confirm the scanner is banned =="
if [ "$ctrl_ok" -eq 1 ]; then
  # svmap sends User-Agent: friendly-scanner -> the SBC's scanner-UA rule bans the source.
  $COMPOSE exec -T redteam sh -c "timeout 20 svmap $SBC >/dev/null 2>&1 || true"
  sleep 1
  if printf '%s' "$(probe post)" | grep -q 'SIP/2.0'; then
    bad "scanner still answered after svmap — UA fingerprint ban NOT effective, FAIL"
  else
    ok "scanner silenced after svmap (banned by UA fingerprint)"
  fi
else
  bad "control failed — scan-ban test INCONCLUSIVE, FAIL"
fi

echo
echo "== note: signature bans are one layer; attackers change the UA. Behavioural (pike) and"
echo "==       nftables/fail2ban layers (nftables-edge.example.nft, M14) complete the defense."
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "M8 ACCEPTANCE: PASS"; exit 0; } || { echo "M8 ACCEPTANCE: FAIL"; exit 1; }
