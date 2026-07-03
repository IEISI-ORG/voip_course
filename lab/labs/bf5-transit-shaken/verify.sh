#!/usr/bin/env bash
# SOVOC BF5 acceptance test — the transit SHAKEN policy makes the correct decisions (offline,
# deterministic, fail-closed). Live signing/verification is capture-graded (M12 lab).
# Run from lab/:  bash labs/bf5-transit-shaken/verify.sh
set -u
cd "$(dirname "$0")/../.." || exit 3
P="labs/bf5-transit-shaken/shaken-policy.sh"

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; bad_detail="$2"; echo "        got: $bad_detail"; fail=$((fail+1)); }
want() { # desc  expected-line  args...
  desc="$1"; exp="$2"; shift 2
  out=$(bash "$P" "$@" 2>/dev/null)
  echo "$out" | grep -q "$exp" && ok "$desc ($exp)" || bad "$desc" "$(echo "$out" | tr '\n' ' ')"
}

echo "== transit SHAKEN policy decisions =="
# Untrusted upstream carrying an Identity -> strip it + attest C.
want "untrusted+identity -> strip"        "STRIP_IDENTITY=yes" --own no  --trusted-upstream no  --identity valid
want "untrusted origin  -> attest C"      "ATTEST=C"           --own no  --trusted-upstream no  --identity valid
# We own the number and authenticated the originator -> attest A, keep (no strip).
want "own+authenticated  -> attest A"     "ATTEST=A"           --own yes --trusted-upstream yes --identity absent
want "own+authenticated  -> no strip"     "STRIP_IDENTITY=no"  --own yes --trusted-upstream yes --identity absent
# Known customer, not the specific number -> attest B.
want "known customer     -> attest B"     "ATTEST=B"           --own no  --trusted-upstream yes --identity absent
# Invalid inbound signature from a trusted peer -> still strip.
want "invalid identity   -> strip"        "STRIP_IDENTITY=yes" --own no  --trusted-upstream yes --identity invalid
# TDM/SS7 next hop -> Out-of-Band SHAKEN.
want "TDM next hop        -> OOB"          "OOB=yes"            --own no  --trusted-upstream yes --identity absent --nexthop tdm

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "BF5 ACCEPTANCE: PASS"; exit 0; } || { echo "BF5 ACCEPTANCE: FAIL"; exit 1; }
