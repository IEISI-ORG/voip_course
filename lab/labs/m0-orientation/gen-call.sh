#!/usr/bin/env bash
# VoIPSec M0 — generate a deterministic test call for Lab 0.2 (something to capture).
# Places a scripted call from `client` through the edge-sbc toward extension 1002, so you can
# watch it in sngrep / export a pcap. Run from lab/.
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
SBC="${EDGE_SBC_IP:-172.28.10.10}"
DST="${1:-1002}"

echo "[gen-call] client -> $SBC (SBC) -> ext $DST"
echo "[gen-call] tip: in another shell, watch it live:"
echo "           $COMPOSE exec -it client sngrep -d any 2>/dev/null || (capture on the host)"
$COMPOSE exec -T client \
  sipp -sf /scenarios/uac_call.xml "$SBC:5060" -s "$DST" -i 172.28.10.40 \
       -m 1 -l 1 -timeout 10s -nostdin
echo "[gen-call] done (exit $?). A single INVITE dialog should have traversed the border."
