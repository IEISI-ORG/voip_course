#!/bin/sh
# lab-enum [target] [ext-range]  — extension enumeration (SIPVicious svwar). M15/M13 (T2).
# Demonstrates why uniform auth responses + fail2ban matter. Scope-guarded.
. /opt/redteam/scripts/_guard.sh
TARGET="${1:-172.28.10.10}"
RANGE="${2:-1000-1010}"
voipsec_guard "$TARGET"
echo "[lab-enum] svwar -e $RANGE $TARGET (authorized lab enumeration)"
exec svwar -e "$RANGE" "$TARGET"
