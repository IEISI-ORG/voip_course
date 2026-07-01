#!/bin/sh
# lab-enum [target] [ext-range]  — extension enumeration (SIPVicious svwar). M13/M12 (T2).
# Demonstrates why uniform auth responses + fail2ban matter. Scope-guarded.
. /opt/redteam/scripts/_guard.sh
TARGET="${1:-172.28.10.10}"
RANGE="${2:-1000-1010}"
sovoc_guard "$TARGET"
echo "[lab-enum] svwar -e $RANGE $TARGET (authorized lab enumeration)"
exec svwar -e "$RANGE" "$TARGET"
