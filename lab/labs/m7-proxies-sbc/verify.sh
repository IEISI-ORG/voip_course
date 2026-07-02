#!/usr/bin/env bash
# SOVOC M7 acceptance test — proves pike rate-limiting bans a flooding source (Lab 7.4).
# Self-validating & fail-closed: a positive control (single probe answered) must pass BEFORE the
# flood, so "no response after flood" is trustworthy evidence of a ban, not a broken probe.
# Side effect: bans the redteam IP for pike autoexpire (~300s). Re-run needs a cooldown or an
# `edge-sbc` restart. Run from lab/:  bash labs/m7-proxies-sbc/verify.sh
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
SBC=172.28.10.10

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

# Send one OPTIONS from redteam; echo any response.
probe() {
  $COMPOSE exec -T redteam sh -c \
    "printf 'OPTIONS sip:$SBC SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.90:5060;branch=z9hG4bK-$1\r\nMax-Forwards: 70\r\nFrom: <sip:p@172.28.10.90>;tag=$1\r\nTo: <sip:$SBC>\r\nCall-ID: m7-$1-\$\$\r\nCSeq: 1 OPTIONS\r\nContent-Length: 0\r\n\r\n' | ncat -u -w2 $SBC 5060" 2>/dev/null
}

echo "== 1. services up (fail-closed) =="
path_ok=1
for s in edge-sbc pbx-a redteam; do
  $COMPOSE ps --status running --services 2>/dev/null | grep -qx "$s" && ok "$s running" || { bad "$s not running"; path_ok=0; }
done

echo "== 2. positive control: redteam probe is answered pre-flood =="
ctrl_ok=0
if [ "$path_ok" -eq 1 ] && printf '%s' "$(probe pre)" | grep -q 'SIP/2.0'; then
  ok "SBC answers redteam OPTIONS (probe works, source not already banned)"
  ctrl_ok=1
else
  bad "no pre-flood response (SBC down or redteam already banned — cooldown ~300s) — INCONCLUSIVE, FAIL"
fi

echo "== 3. flood, then confirm the source is banned (pike rate-limit) =="
if [ "$ctrl_ok" -eq 1 ]; then
  # ~150 near-simultaneous OPTIONS to exceed pike density (30 / 2s).
  $COMPOSE exec -T redteam sh -c \
    'for i in $(seq 1 150); do printf "OPTIONS sip:'"$SBC"' SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.90:5060;branch=z9hG4bK-f$i\r\nMax-Forwards: 70\r\nFrom: <sip:f@172.28.10.90>;tag=f$i\r\nTo: <sip:'"$SBC"'>\r\nCall-ID: flood-$i\r\nCSeq: 1 OPTIONS\r\nContent-Length: 0\r\n\r\n" | ncat -u -w0 '"$SBC"' 5060 >/dev/null 2>&1 & done; wait' 2>/dev/null
  sleep 1
  if printf '%s' "$(probe post)" | grep -q 'SIP/2.0'; then
    bad "source still answered after flood — pike rate-limit NOT effective, FAIL"
  else
    ok "source silenced after flood (pike banned the flooder)"
  fi
else
  bad "control failed — rate-limit test INCONCLUSIVE, FAIL"
fi

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "M7 ACCEPTANCE: PASS"; exit 0; } || { echo "M7 ACCEPTANCE: FAIL"; exit 1; }
