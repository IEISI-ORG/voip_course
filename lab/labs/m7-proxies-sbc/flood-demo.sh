#!/usr/bin/env bash
# VoIPSec M7 Lab 7.4 — INVITE/OPTIONS flood vs pike rate-limiting (authorized lab).
# Shows the before/after: a probe answered pre-flood, then silenced once pike bans the source.
# Run from lab/.  (Bans the redteam IP for ~300s; restart edge-sbc to reset sooner.)
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
SBC=172.28.10.10
N="${1:-150}"

probe() { $COMPOSE exec -T redteam sh -c \
  "printf 'OPTIONS sip:$SBC SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.90:5060;branch=z9hG4bK-$1\r\nMax-Forwards: 70\r\nFrom: <sip:p@172.28.10.90>;tag=$1\r\nTo: <sip:$SBC>\r\nCall-ID: d-$1\r\nCSeq: 1 OPTIONS\r\nContent-Length: 0\r\n\r\n' | ncat -u -w2 $SBC 5060" 2>/dev/null; }

echo "[demo] BEFORE flood — probe response:"; probe before | head -1
echo "[demo] flooding $N requests from redteam ($SBC) ..."
$COMPOSE exec -T redteam sh -c \
  'for i in $(seq 1 '"$N"'); do printf "OPTIONS sip:'"$SBC"' SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.90:5060;branch=z9hG4bK-f$i\r\nMax-Forwards: 70\r\nFrom: <sip:f@172.28.10.90>;tag=f$i\r\nTo: <sip:'"$SBC"'>\r\nCall-ID: fl-$i\r\nCSeq: 1 OPTIONS\r\nContent-Length: 0\r\n\r\n" | ncat -u -w0 '"$SBC"' 5060 >/dev/null 2>&1 & done; wait' 2>/dev/null
sleep 1
echo "[demo] AFTER flood — probe response (expect empty = banned):"; probe after | head -1
echo "[demo] watch the ban in the SBC log:  docker compose logs --tail=20 edge-sbc | grep -i pike"
