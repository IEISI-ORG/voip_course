#!/usr/bin/env bash
# SOVOC M0 acceptance test — the automated grader for Lab 0.1 / 0.3.
# Verifies: base services are up, the four networks exist with correct subnets, and the
# segmentation invariant holds (redteam reaches edge but NOT core). Exit 0 = PASS.
#
# Run from lab/:  bash labs/m0-orientation/verify.sh
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3   # -> lab/

pass=0; fail=0
ok()   { echo "  PASS: $1"; pass=$((pass+1)); }
bad()  { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. base services running =="
for s in edge-sbc rtpengine pbx-a pbx-b trunk-sim client redteam; do
  if $COMPOSE ps --status running --services 2>/dev/null | grep -qx "$s"; then
    ok "$s running"
  else
    bad "$s not running"
  fi
done

echo "== 2. networks + subnets =="
check_net() { # name subnet
  got=$(docker network inspect "$1" --format '{{range .IPAM.Config}}{{.Subnet}}{{end}}' 2>/dev/null)
  [ "$got" = "$2" ] && ok "$1 = $2" || bad "$1 subnet '$got' != $2"
}
check_net sovoc_edge    172.28.10.0/24
check_net sovoc_core    172.28.20.0/24
check_net sovoc_mgmt    172.28.30.0/24
check_net sovoc_redteam 172.28.40.0/24

echo "== 3. segmentation invariant (the security check) =="
# FAIL-CLOSED design. A negative result ("core unreachable") is only trustworthy if we first
# prove the probe actually works. Otherwise a down redteam container or a missing ping tool
# would silently look like "segmentation holding" — a fail-open validator differential.
#
# ICMP is used deliberately: network segmentation is an L3 control, so L3 reachability is the
# right invariant to test. Two guards make it fail-closed:
#   (a) redteam must be running;
#   (b) a POSITIVE CONTROL (redteam -> edge-sbc) must succeed with the same tool.
# Only if both hold do we accept "redteam -> core blocked" as real evidence.
seg_probe_ok=0
if $COMPOSE ps --status running --services 2>/dev/null | grep -qx redteam; then
  if $COMPOSE exec -T redteam ping -c1 -W2 172.28.10.10 >/dev/null 2>&1; then
    ok "positive control: redteam -> edge-sbc reachable (probe works)"
    seg_probe_ok=1
  else
    bad "positive control FAILED: redteam cannot reach edge-sbc (ping missing or edge path broken) — segmentation test INCONCLUSIVE"
  fi
else
  bad "redteam container not running — segmentation test INCONCLUSIVE (cannot prove isolation)"
fi

if [ "$seg_probe_ok" -eq 1 ]; then
  # Negative test is only meaningful now that the positive control passed.
  if $COMPOSE exec -T redteam ping -c1 -W2 172.28.20.21 >/dev/null 2>&1; then
    bad "redteam -> pbx-a(core) REACHABLE — segmentation broken!"
  else
    ok "redteam -> pbx-a(core) blocked (expected)"
  fi
else
  bad "segmentation NOT verified (probe unusable) — treated as FAIL, not PASS"
fi

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "M0 ACCEPTANCE: PASS"; exit 0; } || { echo "M0 ACCEPTANCE: FAIL"; exit 1; }
