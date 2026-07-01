#!/bin/sh
# SOVOC redteam entrypoint (Stage A6). Prints the authorized-use banner, then runs the CMD.
set -eu

BANNER='
========================================================================
  SOVOC redteam toolbox  —  AUTHORIZED LAB USE ONLY
  Targets: edge 172.28.10.0/24 and redteam 172.28.40.0/24 ONLY.
  Testing any system without written authorization is illegal.
  Full terms: /opt/redteam/AUTHORIZED_USE.md
  Scope-guarded helpers: lab-scan, lab-enum, lab-crack, lab-fuzz
========================================================================
'
printf '%s\n' "$BANNER"
printf '%s\n' "$BANNER" > /etc/motd 2>/dev/null || true

exec "$@"
