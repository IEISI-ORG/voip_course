#!/usr/bin/env bash
# VoIPSec M1 — attack-surface recon helper for Lab 1.2 (passive, against YOUR OWN lab SBC).
# Sends a SIP OPTIONS and prints the response so you can see what a scanner learns: which
# headers leak software/version, what response codes reveal. Run from lab/.
#
# This is recon of the lab you own. The same act against a third party is illegal (see the
# redteam AUTHORIZED_USE.md).
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
TARGET="${1:-172.28.10.10}"   # edge-sbc by default

case "$TARGET" in
  172.28.10.*|172.28.20.*|172.28.40.*) ;;
  *) echo "REFUSED: $TARGET is outside the lab. Recon only your own systems."; exit 2 ;;
esac

echo "[probe] OPTIONS -> $TARGET:5060 (observe leaked headers: Server / User-Agent / Allow)"
REQ=$(printf 'OPTIONS sip:%s SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.40:5060;branch=z9hG4bK-probe\r\nMax-Forwards: 70\r\nFrom: <sip:probe@172.28.10.40>;tag=probe\r\nTo: <sip:%s>\r\nCall-ID: probe-%s\r\nCSeq: 1 OPTIONS\r\nContact: <sip:probe@172.28.10.40>\r\nContent-Length: 0\r\n\r\n' "$TARGET" "$TARGET" "$$")
printf '%s' "$REQ" | $COMPOSE exec -T client ncat -u -w2 "$TARGET" 5060 || \
  echo "[probe] no response captured (SBC may have dropped it — note that as a finding)"
echo "[probe] done. Record in your threat model: what did the response reveal vs. hide?"
