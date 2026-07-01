#!/bin/sh
# lab-fuzz [target]  — minimal SIP robustness probe (guarded). The full RFC 4475 SIP torture
# suite is built in M13 (backlog BF7); this is a smoke probe that a malformed OPTIONS does not
# crash the border and returns a well-formed 4xx.
. /opt/redteam/scripts/_guard.sh
TARGET="${1:-172.28.10.10}"
sovoc_guard "$TARGET"

echo "[lab-fuzz] sending a malformed OPTIONS to $TARGET:5060 (expect a clean 4xx, no crash)"
# Deliberately malformed: bad Max-Forwards + truncated headers.
printf 'OPTIONS sip:%s SIP/2.0\r\nVia: SIP/2.0/UDP redteam\r\nMax-Forwards: notanumber\r\nFrom: <sip:fuzz@redteam>\r\nTo: <sip:%s>\r\nCall-ID: fuzz-%s\r\nCSeq: 1 OPTIONS\r\n\r\n' \
  "$TARGET" "$TARGET" "$$" | ncat -u -w2 "$TARGET" 5060 || true
echo "[lab-fuzz] done. Verify edge-sbc is still up: it should have dropped/answered without crashing."
