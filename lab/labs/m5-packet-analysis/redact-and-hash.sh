#!/usr/bin/env bash
# SOVOC M5 Lab 5.4 — evidence handling. Redact the media plane (RTP/RTCP carry audio and
# DTMF telephone-events = spoken/keyed PINs, card numbers) while keeping signaling for analysis,
# then produce tamper-evident hashes and a chain-of-custody record.
# Usage: redact-and-hash.sh <evidence.pcap> [redacted-out.pcap]
set -u
IN="${1:?usage: redact-and-hash.sh <evidence.pcap> [out.pcap]}"
OUT="${2:-${IN%.pcap}.redacted.pcap}"
command -v tshark    >/dev/null 2>&1 || { echo "needs tshark"; exit 3; }
command -v sha256sum >/dev/null 2>&1 || { echo "needs sha256sum"; exit 3; }

echo "[custody] hashing original evidence..."
sha256sum "$IN" | tee "${IN}.sha256"

echo "[redact] dropping media plane (RTP/RTCP), keeping SIP signaling..."
tshark -r "$IN" -Y 'not rtp and not rtcp' -w "$OUT" 2>/dev/null

echo "[custody] hashing redacted artifact..."
sha256sum "$OUT" | tee "${OUT}.sha256"

CUSTODY="${OUT%.pcap}.custody.txt"
{
  echo "SOVOC evidence chain of custody"
  echo "source_evidence : $IN"
  echo "source_sha256   : $(cut -d' ' -f1 "${IN}.sha256")"
  echo "redacted_artifact : $OUT (media plane removed)"
  echo "redacted_sha256   : $(cut -d' ' -f1 "${OUT}.sha256")"
  echo "operator        : ${USER:-unknown}"
  date -u +"redacted_at_utc : %Y-%m-%dT%H:%M:%SZ"
} > "$CUSTODY"
echo "[done] wrote $OUT, hashes, and $CUSTODY"
