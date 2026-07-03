#!/usr/bin/env bash
# VoIPSec BF3 acceptance test — HA config + overlay are well-formed (offline, deterministic,
# fail-closed). The live hitless-failover run is failover-test.sh (needs the HA overlay up).
# Run from lab/:  bash labs/bf3-ha-failover/verify.sh
set -u
cd "$(dirname "$0")/../.." || exit 3
DIR=labs/bf3-ha-failover
SNIP="$DIR/kamailio-ha.snippet.cfg"
HA="$DIR/docker-compose.ha.yml"

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. HA config directives present =="
grep -q 'db_mode' "$SNIP"                 && ok "usrloc db_mode (shared store)"        || bad "no db_mode"
grep -qE 'db_redis|db_mysql' "$SNIP"      && ok "shared DB/Redis backend module"       || bad "no shared-store module"
grep -q 'dmq' "$SNIP"                     && ok "DMQ replication configured"           || bad "no DMQ"
grep -q 'redis' "$SNIP"                   && ok "rtpengine redis media-state note"     || bad "no rtpengine redis"

echo "== 2. HA compose overlay valid + adds replica & shared store =="
if python3 -c "import yaml,sys; yaml.safe_load(open('$HA'))" 2>/dev/null; then
  ok "docker-compose.ha.yml valid YAML"
  grep -q 'edge-sbc-2:' "$HA" && ok "second SBC replica defined"     || bad "no edge-sbc-2 replica"
  grep -q 'redis:' "$HA"      && ok "shared redis service defined"    || bad "no redis service"
else
  bad "docker-compose.ha.yml invalid YAML"
fi

echo "== 3. merged compose config (if docker present) =="
if command -v docker >/dev/null 2>&1; then
  docker compose -f docker-compose.yml -f "$DIR/docker-compose.ha.yml" config -q 2>/dev/null \
    && ok "base+HA compose merges and validates" || bad "merged compose invalid (check overlay)"
else
  echo "  NOTE: docker not present — validate merge in CI/lab: docker compose -f ... -f ... config -q"
fi

echo "== 4. failover demo present =="
[ -x "$DIR/failover-test.sh" ] && ok "failover-test.sh present" || bad "failover-test.sh missing"

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "BF3 ACCEPTANCE: PASS"; exit 0; } || { echo "BF3 ACCEPTANCE: FAIL"; exit 1; }
