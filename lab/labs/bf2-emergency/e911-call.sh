#!/usr/bin/env bash
# SOVOC BF2 — construct an emergency INVITE carrying a PIDF-LO dispatchable location and a
# Resource-Priority header (RFC 4412). Prints the message so you can see the emergency-call
# shape; --send transmits it via the client container. Run from lab/.
set -u
COMPOSE="${COMPOSE:-docker compose}"
HERE="$(cd "$(dirname "$0")" && pwd)"
TARGET="${TARGET:-172.28.10.10}"     # route 911 to the SBC -> PSAP sim in your dialplan
PIDF="$(cat "$HERE/pidf-lo-sample.xml")"
B="sovoc911boundary"

# multipart/mixed: SDP + PIDF-LO
BODY=$(printf -- '--%s\r\nContent-Type: application/sdp\r\n\r\nv=0\r\no=e911 1 1 IN IP4 172.28.10.40\r\ns=emergency\r\nc=IN IP4 172.28.10.40\r\nt=0 0\r\nm=audio 40000 RTP/AVP 0\r\na=rtpmap:0 PCMU/8000\r\n\r\n--%s\r\nContent-Type: application/pidf+xml\r\nContent-ID: <loc@lab.sovoc.test>\r\n\r\n%s\r\n--%s--\r\n' "$B" "$B" "$PIDF" "$B")
LEN=$(printf '%s' "$BODY" | wc -c | tr -d ' ')

MSG=$(printf -- 'INVITE sip:911@%s SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.40:5060;branch=z9hG4bK-e911\r\nMax-Forwards: 70\r\nFrom: "Caller" <sip:1001@lab.sovoc.test>;tag=e911\r\nTo: <sip:911@%s>\r\nCall-ID: e911-%s\r\nCSeq: 1 INVITE\r\nContact: <sip:1001@172.28.10.40:5060>\r\nResource-Priority: esnet.1\r\nPriority: emergency\r\nGeolocation: <cid:loc@lab.sovoc.test>\r\nGeolocation-Routing: yes\r\nContent-Type: multipart/mixed;boundary="%s"\r\nContent-Length: %s\r\n\r\n%s' "$TARGET" "$TARGET" "$$" "$B" "$LEN" "$BODY")

if [ "${1:-}" = "--send" ]; then
  echo "[e911] sending emergency INVITE to $TARGET ..."
  printf '%s' "$MSG" | $COMPOSE exec -T client sh -c "cat | ncat -u -w3 $TARGET 5060" 2>/dev/null | sed 's/\r$//' | head -5
else
  echo "[e911] constructed emergency INVITE (use --send to transmit):"
  printf '%s\n' "$MSG"
fi
