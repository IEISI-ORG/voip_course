#!/usr/bin/env bash
# VoIPSec BF10 — TURN short-term REST credential (coturn use-auth-secret). Deterministic.
#   username = <unix-expiry>[:userid]   password = base64(HMAC-SHA1(secret, username))
# Modes:
#   turn-cred.sh gen <secret> [ttl-seconds] [userid]
#   turn-cred.sh verify <secret> <username> <password>
set -u
command -v openssl >/dev/null 2>&1 || { echo "needs openssl"; exit 3; }

hmac_b64() { printf '%s' "$2" | openssl dgst -sha1 -hmac "$1" -binary | openssl base64; }

case "${1:-}" in
  gen)
    SECRET="$2"; TTL="${3:-300}"; USERID="${4:-}"
    EXP=$(( $(date +%s) + TTL ))
    USER="$EXP"; [ -n "$USERID" ] && USER="$EXP:$USERID"
    echo "username=$USER"
    echo "password=$(hmac_b64 "$SECRET" "$USER")"
    echo "expires=$(date -u -d "@$EXP" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "@$EXP")"
    ;;
  verify)
    SECRET="$2"; USER="$3"; PASS="$4"
    EXP="${USER%%:*}"
    exp_ok=1; [ "$EXP" -lt "$(date +%s)" ] 2>/dev/null && exp_ok=0
    if [ "$(hmac_b64 "$SECRET" "$USER")" = "$PASS" ]; then
      [ "$exp_ok" = 1 ] && echo "VALID (hmac ok, not expired)" || echo "EXPIRED (hmac ok but past expiry)"
      [ "$exp_ok" = 1 ] && exit 0 || exit 1
    else
      echo "INVALID (hmac mismatch)"; exit 1
    fi
    ;;
  *) echo "usage: turn-cred.sh {gen <secret> [ttl] [userid] | verify <secret> <user> <pass>}"; exit 3 ;;
esac
