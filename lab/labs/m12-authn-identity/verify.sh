#!/usr/bin/env bash
# VoIPSec M12 acceptance test — proves enumeration is mitigated (Lab 12.3) and the PASSporT tool
# works (Lab 12.2). Self-validating & fail-closed: a plain probe is answered, then an authorized
# svwar enumeration run must get the source banned. (Bans redteam IP ~300s.)
# Run from lab/:  bash labs/m12-authn-identity/verify.sh
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
SBC=172.28.10.10

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

probe() {
  $COMPOSE exec -T redteam sh -c \
    "printf 'OPTIONS sip:$SBC SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.90:5060;branch=z9hG4bK-$1\r\nMax-Forwards: 70\r\nFrom: <sip:p@172.28.10.90>;tag=$1\r\nTo: <sip:$SBC>\r\nCall-ID: m12-$1-\$\$\r\nCSeq: 1 OPTIONS\r\nContent-Length: 0\r\n\r\n' | ncat -u -w2 $SBC 5060" 2>/dev/null
}

echo "== 1. services + PASSporT tool =="
path_ok=1
for s in edge-sbc redteam; do
  $COMPOSE ps --status running --services 2>/dev/null | grep -qx "$s" && ok "$s running" || { bad "$s not running"; path_ok=0; }
done
if bash labs/m12-authn-identity/passport-decode.sh 2>/dev/null | grep -q '"attest":"A"'; then
  ok "passport-decode.sh decodes a SHAKEN PASSporT"
else
  bad "passport-decode.sh failed"
fi

echo "== 2. positive control: plain probe answered pre-enum =="
ctrl_ok=0
if [ "$path_ok" -eq 1 ] && printf '%s' "$(probe pre)" | grep -q 'SIP/2.0'; then
  ok "SBC answers a normal request (probe works, not pre-banned)"; ctrl_ok=1
else
  bad "no pre-enum response (down or already banned — cooldown ~300s) — INCONCLUSIVE, FAIL"
fi

echo "== 3. authorized svwar enumeration -> source banned =="
if [ "$ctrl_ok" -eq 1 ]; then
  $COMPOSE exec -T redteam sh -c "timeout 25 svwar -e1000-1010 $SBC >/dev/null 2>&1 || true"
  sleep 1
  if printf '%s' "$(probe post)" | grep -q 'SIP/2.0'; then
    bad "enumerator still answered after svwar — enumeration NOT mitigated, FAIL"
  else
    ok "enumerator silenced after svwar (banned; enumeration mitigated)"
  fi
else
  bad "control failed — enumeration test INCONCLUSIVE, FAIL"
fi

echo
echo "== note: base defense = scanner-UA ban; the full M12 build adds uniform auth responses,"
echo "==       fail2ban lockout, and SHA-256 digest so enumeration/brute force gain nothing."
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "M12 ACCEPTANCE: PASS"; exit 0; } || { echo "M12 ACCEPTANCE: FAIL"; exit 1; }
