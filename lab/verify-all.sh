#!/usr/bin/env bash
# SOVOC — lab environment test & verification harness.
# Runs every module lab's verify.sh and prints a pass/fail summary. This is the top-level
# "does the whole lab still work" check (CI-friendly: non-zero exit if any grader fails).
#
# CAUTION: the M7/M8 graders deliberately ban the redteam source IP for pike's ~300s autoexpire.
# Running them back-to-back can make a later one report INCONCLUSIVE. Use --safe to restart
# edge-sbc between ban-inducing graders, or run those two individually with a cooldown.
#
# Usage: bash verify-all.sh [--safe] [module-glob]
#   bash verify-all.sh                 # all graders, in order
#   bash verify-all.sh m0-orientation  # a single lab
#   bash verify-all.sh --safe          # restart edge-sbc before m7/m8
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")" || exit 3          # -> lab/

SAFE=0; [ "${1:-}" = "--safe" ] && { SAFE=1; shift; }
GLOB="${1:-m*}"

total=0; passed=0; failed=0; fails=""
for d in labs/$GLOB/; do
  [ -f "$d/verify.sh" ] || continue
  name=$(basename "$d")
  total=$((total+1))
  if [ "$SAFE" -eq 1 ] && { [ "$name" = "m7-proxies-sbc" ] || [ "$name" = "m8-nat-firewall" ]; }; then
    echo "--- [$name] restarting edge-sbc first (--safe) ---"
    $COMPOSE restart edge-sbc >/dev/null 2>&1; sleep 3
  fi
  echo "=== [$name] ==="
  if bash "$d/verify.sh"; then
    passed=$((passed+1))
  else
    failed=$((failed+1)); fails="$fails $name"
  fi
  echo
done

echo "############################################################"
echo "# lab verify-all: $passed/$total passed, $failed failed"
[ -n "$fails" ] && echo "# failed:$fails"
echo "############################################################"
[ "$failed" -eq 0 ] && exit 0 || exit 1
