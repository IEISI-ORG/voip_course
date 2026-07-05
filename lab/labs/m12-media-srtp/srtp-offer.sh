#!/usr/bin/env bash
# VoIPSec M12 — send an SDES-SRTP offer and read the answer (Labs 11.1 / 11.3).
# The offer requests RTP/SAVP with an a=crypto line. Watch the answer:
#   - a peer/anchor that supports SRTP answers RTP/SAVP + a=crypto  (11.1 secure)
#   - a plain peer answers RTP/AVP (no crypto) -> would be a silent downgrade
#   - an SRTP-ONLY policy (Lab 11.3) should REJECT an offer whose crypto was stripped
# Usage: srtp-offer.sh [target] [--strip]   (--strip sends RTP/AVP with NO a=crypto)
# Run from lab/.  The inline key below is a LAB-ONLY throwaway, never a real key.
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
TARGET="${1:-172.28.10.30}"
MODE="${2:-}"

case "$TARGET" in 172.28.10.*|172.28.20.*|172.28.40.*) ;; *) echo "REFUSED: $TARGET outside lab."; exit 2;; esac

# Lab-only throwaway SRTP master key (base64 of 30 bytes). NOT a secret.
KEY="inline:d0RmdmV3TFdCd2ExRkFDbGFuZFpsQnhtN2lZZ0hkZmJnQmc="
if [ "$MODE" = "--strip" ]; then
  echo "[srtp-offer] STRIP mode: offering RTP/AVP with NO a=crypto (downgrade attempt)"
  MEDIA='m=audio 40000 RTP/AVP 0\r\na=rtpmap:0 PCMU/8000\r\n'
else
  echo "[srtp-offer] SDES mode: offering RTP/SAVP with a=crypto (secure media)"
  MEDIA='m=audio 40000 RTP/SAVP 0\r\na=rtpmap:0 PCMU/8000\r\na=crypto:1 AES_CM_128_HMAC_SHA1_80 '"$KEY"'\r\n'
fi

MSG='INVITE sip:svc@'"$TARGET"' SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.40:5060;branch=z9hG4bK-srtp\r\nMax-Forwards: 70\r\nFrom: <sip:t@172.28.10.40>;tag=srtp\r\nTo: <sip:svc@'"$TARGET"'>\r\nCall-ID: srtp-$$\r\nCSeq: 1 INVITE\r\nContact: <sip:t@172.28.10.40>\r\nContent-Type: application/sdp\r\nContent-Length: 200\r\n\r\nv=0\r\no=t 1 1 IN IP4 172.28.10.40\r\ns=x\r\nc=IN IP4 172.28.10.40\r\nt=0 0\r\n'"$MEDIA"

echo "[srtp-offer] -> $TARGET; read the answer's m=/a=crypto lines:"
$COMPOSE exec -T client sh -c "printf '$MSG' | ncat -u -w3 $TARGET 5060" 2>/dev/null | sed 's/\r$//' | grep -iE 'SIP/2.0|m=audio|a=crypto' || echo "(no answer / rejected)"
