#!/usr/bin/env bash
# VoIPSec M13 acceptance test — SIP parser robustness (RFC 4475 / BF7). Fail-closed & self-
# validating: the SBC must answer a valid request BEFORE and AFTER a batch of malformed input.
# "Still answering after" = the parser dropped garbage cleanly rather than crashing (T10).
# Run from lab/:  bash labs/m13-offensive/verify.sh
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
SBC=172.28.10.10

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

probe() {
  $COMPOSE exec -T redteam sh -c \
    "printf 'OPTIONS sip:$SBC SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.90:5060;branch=z9hG4bK-$1\r\nMax-Forwards: 70\r\nFrom: <sip:p@172.28.10.90>;tag=$1\r\nTo: <sip:$SBC>\r\nCall-ID: m13-$1-\$\$\r\nCSeq: 1 OPTIONS\r\nContent-Length: 0\r\n\r\n' | ncat -u -w2 $SBC 5060" 2>/dev/null
}

echo "== 1. services up (fail-closed) =="
path_ok=1
for s in edge-sbc redteam; do
  $COMPOSE ps --status running --services 2>/dev/null | grep -qx "$s" && ok "$s running" || { bad "$s not running"; path_ok=0; }
done

echo "== 2. control: SBC alive before torture =="
alive0=0
if [ "$path_ok" -eq 1 ] && printf '%s' "$(probe pre)" | grep -q 'SIP/2.0'; then
  ok "SBC answers a valid request pre-torture"; alive0=1
else
  bad "no pre-torture response (down or redteam banned) — INCONCLUSIVE, FAIL"
fi

echo "== 3. fire malformed batch, then confirm the SBC survived =="
if [ "$alive0" -eq 1 ]; then
  bash labs/m13-offensive/torture.sh "$SBC" >/dev/null 2>&1 || true
  sleep 1
  if printf '%s' "$(probe post)" | grep -q 'SIP/2.0'; then
    ok "SBC still answers after malformed input (parser robust, no crash)"
  else
    bad "SBC silent after malformed input — possible crash/hang (T10), FAIL"
  fi
else
  bad "control failed — robustness test INCONCLUSIVE, FAIL"
fi

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "M13 ACCEPTANCE: PASS"; exit 0; } || { echo "M13 ACCEPTANCE: FAIL"; exit 1; }
