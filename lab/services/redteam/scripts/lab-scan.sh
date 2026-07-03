#!/bin/sh
# lab-scan [target]  — SIP device discovery (SIPVicious svmap). Maps to M13 (threat T1).
# Default target: the edge-sbc. Scope-guarded to the lab subnets.
. /opt/redteam/scripts/_guard.sh
TARGET="${1:-172.28.10.10}"
voipsec_guard "$TARGET"
shift 2>/dev/null || true
echo "[lab-scan] svmap $TARGET (authorized lab recon)"
exec svmap "$TARGET" "$@"
