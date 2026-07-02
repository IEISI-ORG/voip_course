#!/usr/bin/env bash
# SOVOC M4 — set up an RTP capture (Labs 4.1 / 4.3). Prints host-side capture guidance and
# generates call signaling toward trunk-sim so there is a media session to record.
# For audible, reconstructable audio, place a real call between two Baresip clients (see below).
# Run from lab/.
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
TARGET="${1:-172.28.10.30}"

cat <<'GUIDE'
[capture-rtp] To capture RTP for analysis:

  1) Find the host bridge for the edge network:
       docker network inspect sovoc_edge -f '{{range .IPAM.Config}}{{.Subnet}}{{end}}'
       ip -o link | grep -i br-        # the matching br-* interface

  2) Capture media ports on the host (needs sudo):
       sudo tshark -i br-<id> -f 'udp portrange 30000-40100' -w /tmp/call.pcap
     or watch signaling live:
       docker compose exec -it client sngrep -d any

  3) Generate the call in another shell (see below), then stop the capture.

  4) Analyze in Wireshark: Telephony > RTP > Streams (jitter, loss, and MOS estimate);
     "Play Streams" to reconstruct plaintext audio (Lab 4.3 attack).
     Telephony > VoIP Calls to reconstruct the whole call.

  For real, audible audio use two softphones:
     docker compose exec -it client baresip     # dial the other endpoint and speak/play

  SRTP mitigation (Lab 4.3 defend): after M11, the RTP payload is encrypted and Wireshark can
  no longer play it back — the same capture that leaked audio here becomes useless to a sniffer.
GUIDE

echo
echo "[capture-rtp] generating signaling toward $TARGET (trunk-sim answers, echoes RTP)..."
$COMPOSE exec -T client \
  sipp -sf /scenarios/uac_call.xml "$TARGET:5060" -s svc -i 172.28.10.40 \
       -m 1 -l 1 -timeout 10s -nostdin -rtp_echo >/dev/null 2>&1 \
  && echo "[capture-rtp] call attempted — check your capture." \
  || echo "[capture-rtp] call attempt finished (inspect capture / trunk-sim logs)."
