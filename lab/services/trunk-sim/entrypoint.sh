#!/bin/sh
# VoIPSec trunk-sim entrypoint (Stage A4).
# Roles:
#   uas   (default) — listen on 5060 and answer calls, acting as the PSTN far end.
#   uac   <target>  — originate an "inbound" call toward the SBC (default target: edge-sbc).
set -eu

SELF_IP="${TRUNK_IP:-172.28.10.30}"
SBC="${EDGE_SBC_IP:-172.28.10.10}"
ROLE="${1:-uas}"

case "$ROLE" in
  uas)
    echo "[trunk-sim] UAS: answering calls on ${SELF_IP}:5060 (PSTN far end)"
    # Foreground (PID 1), no interactive keys/tty, echo RTP back so media flows.
    exec sipp -sf /scenarios/uas_pstn.xml -i "$SELF_IP" -mi "$SELF_IP" -p 5060 \
              -nostdin -rtp_echo -pause_msg_ign
    ;;
  uac)
    TARGET="${2:-$SBC}"
    echo "[trunk-sim] UAC: originating inbound call to ${TARGET}:5060"
    exec sipp -sf /scenarios/uac_inbound.xml "$TARGET:5060" -i "$SELF_IP" -p 5061 \
              -m "${CALLS:-1}" -r "${RATE:-1}" -nostdin
    ;;
  *)
    exec "$@"
    ;;
esac
