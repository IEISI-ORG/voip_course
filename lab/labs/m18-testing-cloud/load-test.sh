#!/usr/bin/env bash
# VoIPSec M18 Lab 16.1 — SIPp load + regression test. Drives calls from `client` to `trunk-sim`
# (which answers) at a chosen rate and reports capacity + the failure mode.
# Usage: load-test.sh   env: RATE=<cps> CALLS=<total> TARGET=<ip>
# Run from lab/.
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
TARGET="${TARGET:-172.28.10.30}"     # trunk-sim answers, so calls complete
RATE="${RATE:-5}"                     # calls/sec
CALLS="${CALLS:-50}"                  # total calls

echo "[load-test] $CALLS calls @ ${RATE}/s : client -> $TARGET"
$COMPOSE exec -T client \
  sipp -sf /scenarios/uac_call.xml "$TARGET:5060" -s svc -i 172.28.10.40 \
       -r "$RATE" -m "$CALLS" -timeout 30s -nostdin -trace_stat -fd 1s 2>/dev/null \
  | tail -20
echo "[load-test] report: successful vs failed calls, response-time percentiles, and the"
echo "            failure mode when you push RATE up (retransmits, 5xx, or timeouts)."
