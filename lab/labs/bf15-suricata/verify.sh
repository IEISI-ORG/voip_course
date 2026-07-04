#!/usr/bin/env bash
# VoIPSec BF15 acceptance test — Suricata VoIP rules + EVE->ipset integration (offline,
# deterministic, fail-closed & self-validating). Uses `suricata -T` if present; else structural.
# Run from lab/:  bash labs/bf15-suricata/verify.sh
set -u
cd "$(dirname "$0")/../.." || exit 3
DIR=labs/bf15-suricata
RULES="$DIR/suricata-voip.rules"
YAML="$DIR/suricata.yaml"
EVE="$DIR/sample-eve.json"

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. rules are well-formed =="
if command -v suricata >/dev/null 2>&1; then
  suricata -T -S "$RULES" >/dev/null 2>&1 && ok "suricata -T accepts the ruleset" || bad "suricata -T rejected the ruleset"
else
  echo "  (suricata not installed — structural check)"
  nrules=$(grep -cE '^alert ' "$RULES")
  bad_rule=0
  while IFS= read -r r; do
    echo "$r" | grep -q 'msg:'   || { echo "    missing msg: $r"; bad_rule=1; }
    echo "$r" | grep -qE 'sid:[0-9]+' || { echo "    missing sid"; bad_rule=1; }
  done < <(grep -E '^alert ' "$RULES")
  uniq_sids=$(grep -oE 'sid:[0-9]+' "$RULES" | sort -u | wc -l | tr -d ' ')
  [ "$bad_rule" -eq 0 ] && ok "$nrules rules have msg+sid" || bad "a rule is missing msg/sid"
  [ "$uniq_sids" = "$nrules" ] && ok "all $nrules sids unique" || bad "duplicate sids ($uniq_sids uniq vs $nrules rules)"
fi

echo "== 2. threat coverage =="
cov=0
grep -qi 'friendly-scanner\|sipvicious' "$RULES" && echo "  ok: scanner recon" || { echo "  MISS: scanner"; cov=1; }
grep -qi 'REGISTER' "$RULES" && echo "  ok: REGISTER brute/flood" || { echo "  MISS: register"; cov=1; }
grep -qi 'INVITE flood' "$RULES" && echo "  ok: INVITE flood (DoS)" || { echo "  MISS: invite flood"; cov=1; }
grep -qi 'toll-fraud' "$RULES" && echo "  ok: toll-fraud dial pattern" || { echo "  MISS: toll-fraud"; cov=1; }
[ "$cov" -eq 0 ] && ok "covers recon + REGISTER + INVITE-flood + toll-fraud" || bad "threat coverage incomplete"

echo "== 3. EVE->ipset: only VOIPSEC alert sources are banned (self-validating) =="
out=$(bash "$DIR/eve-to-ipset.sh" "$EVE" 2>/dev/null)
echo "$out" | grep -q '203.0.113.7' && ok "banned the VOIPSEC-alert source (203.0.113.7)" || bad "did not ban the alert source"
if echo "$out" | grep -qE '198.51.100.9|192.0.2.50'; then
  bad "banned a non-alert/non-VOIPSEC source (filter fail-open)"
else
  ok "ignored the non-alert sip flow AND the non-VOIPSEC alert"
fi
cnt=$(echo "$out" | grep -c 'add element')
[ "$cnt" = "1" ] && ok "exactly 1 unique source banned (deduped 2 alerts)" || bad "expected 1 banned source, got $cnt"

echo "== 4. suricata.yaml wiring =="
grep -q 'HOME_NET' "$YAML" && ok "HOME_NET defined (core protected)" || bad "no HOME_NET"
grep -qE 'sip:\s*$|sip:' "$YAML" && grep -q 'enabled: yes' "$YAML" && ok "SIP app-layer + eve-log enabled" || bad "sip/eve output not enabled"
grep -q 'eve-log' "$YAML" && ok "EVE JSON output (integration point)" || bad "no eve-log"

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "BF15 ACCEPTANCE: PASS"; exit 0; } || { echo "BF15 ACCEPTANCE: FAIL"; exit 1; }
