#!/usr/bin/env bash
# VoIPSec M13 — SIP torture / malformed-input probe (RFC 4475 style, Lab 13.1 / BF7).
# AUTHORIZED LAB ONLY. Sends a batch of malformed SIP messages at a lab target so you can
# confirm the parser drops them cleanly (a robust border returns 4xx or silently drops, never
# crashes). Run from lab/.  Guarded to lab subnets.
set -u
COMPOSE="${COMPOSE:-docker compose}"
cd "$(dirname "$0")/../.." || exit 3
TARGET="${1:-172.28.10.10}"
case "$TARGET" in 172.28.10.*|172.28.20.*|172.28.40.*) ;; *) echo "REFUSED: $TARGET outside lab."; exit 2;; esac

send() { # label  raw
  echo "--- $1 ---"
  $COMPOSE exec -T redteam sh -c "printf '$2' | ncat -u -w1 $TARGET 5060" 2>/dev/null | head -1 || echo "(no response / dropped)"
}

echo "[torture] sending malformed SIP to $TARGET (expect clean 4xx or silent drop, never a crash)"

send "non-numeric Max-Forwards" \
  'OPTIONS sip:'"$TARGET"' SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.90:5060;branch=z9hG4bK-t1\r\nMax-Forwards: NaN\r\nFrom: <sip:t@x>;tag=1\r\nTo: <sip:'"$TARGET"'>\r\nCall-ID: t1\r\nCSeq: 1 OPTIONS\r\nContent-Length: 0\r\n\r\n'

send "Content-Length overrun (declares 9999, no body)" \
  'OPTIONS sip:'"$TARGET"' SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.90:5060;branch=z9hG4bK-t2\r\nMax-Forwards: 70\r\nFrom: <sip:t@x>;tag=2\r\nTo: <sip:'"$TARGET"'>\r\nCall-ID: t2\r\nCSeq: 2 OPTIONS\r\nContent-Length: 9999\r\n\r\n'

send "missing required headers (no From/CSeq)" \
  'OPTIONS sip:'"$TARGET"' SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.90:5060;branch=z9hG4bK-t3\r\nMax-Forwards: 70\r\nTo: <sip:'"$TARGET"'>\r\nCall-ID: t3\r\nContent-Length: 0\r\n\r\n'

send "garbage request line" \
  'N0T-A-METH0D sip:'"$TARGET"' SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.90:5060;branch=z9hG4bK-t4\r\nMax-Forwards: 70\r\nFrom: <sip:t@x>;tag=4\r\nTo: <sip:'"$TARGET"'>\r\nCall-ID: t4\r\nCSeq: 4 N0T\r\nContent-Length: 0\r\n\r\n'

send "overlong header value" \
  'OPTIONS sip:'"$TARGET"' SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.90:5060;branch=z9hG4bK-t5\r\nMax-Forwards: 70\r\nFrom: <sip:t@x>;tag=5\r\nTo: <sip:'"$TARGET"'>\r\nCall-ID: t5\r\nCSeq: 5 OPTIONS\r\nSubject: '"$(printf 'A%.0s' $(seq 1 2000))"'\r\nContent-Length: 0\r\n\r\n'

echo "[torture] done. Now confirm the border survived (a valid request still gets answered)."
