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
for s in edge-sbc rtpengine pbx-a pbx-b trunk-sim client; do
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
# redteam MUST reach the edge-sbc...
if $COMPOSE exec -T redteam ping -c1 -W2 172.28.10.10 >/dev/null 2>&1; then
  ok "redteam -> edge-sbc reachable (expected)"
else
  bad "redteam -> edge-sbc unreachable (edge path broken?)"
fi
# ...but MUST NOT reach the core PBX.
if $COMPOSE exec -T redteam ping -c1 -W2 172.28.20.21 >/dev/null 2>&1; then
  bad "redteam -> pbx-a(core) REACHABLE — segmentation broken!"
else
  ok "redteam -> pbx-a(core) blocked (expected)"
fi

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "M0 ACCEPTANCE: PASS"; exit 0; } || { echo "M0 ACCEPTANCE: FAIL"; exit 1; }
