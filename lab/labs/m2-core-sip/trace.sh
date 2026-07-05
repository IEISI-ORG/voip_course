#!/usr/bin/env bash
# VoIPSec M2 — capture raw SIP responses for annotation (Labs 2.1 / 2.2).
# Sends a REGISTER and an OPTIONS through the SBC and prints the responses so you can read
# the status line, Via/branch, From/To tags, CSeq, and Allow/Supported headers line by line.
# Run from lab/.  For the forking + 401 traces, follow the README steps with sngrep/HOMER.
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
SBC=172.28.10.10

send() { # label  raw-message
  echo "=== $1 ==="
  $COMPOSE exec -T client sh -c "printf '$2' | ncat -u -w2 $SBC 5060" 2>/dev/null | sed 's/\r$//'
  echo
}

send "OPTIONS (read Via/branch, CSeq, Allow)" \
  'OPTIONS sip:'"$SBC"' SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.40:5060;branch=z9hG4bK-opt\r\nMax-Forwards: 70\r\nFrom: <sip:probe@172.28.10.40>;tag=t1\r\nTo: <sip:'"$SBC"'>\r\nCall-ID: trace-opt-$$\r\nCSeq: 1 OPTIONS\r\nContent-Length: 0\r\n\r\n'

echo "For the authenticated REGISTER (401 challenge) trace, watch it live:"
echo "  docker compose exec -it client sngrep -d any"
echo "  (SBC stubs auth until M13; a real 401 challenge appears once M13 is applied.)"
