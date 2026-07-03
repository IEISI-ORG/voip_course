#!/usr/bin/env bash
# SOVOC BF8 — secure call-recording handling (PCI-DSS aware). Encryption-at-rest, RBAC-gated
# access with an audit trail, and DTMF/PAN masking. Deterministic (OpenSSL).
# Modes:
#   secure-recording.sh encrypt <in> <out.enc> <keyfile>
#   secure-recording.sh decrypt <in.enc> <out> <keyfile>
#   secure-recording.sh access  <user> <file>        # RBAC check + audit log
#   secure-recording.sh mask-dtmf "<text>"           # mask PAN/PIN digit runs
#   secure-recording.sh demo
set -u
command -v openssl >/dev/null 2>&1 || { echo "needs openssl"; exit 3; }
AUDIT="${AUDIT_LOG:-/tmp/sovoc-recording-audit.log}"
# RBAC allowlist (roles permitted to access recordings).
RBAC_ALLOW="${RBAC_ALLOW:-compliance auditor}"

enc() { openssl enc -aes-256-cbc -pbkdf2 -salt -in "$1" -out "$2" -pass "file:$3"; }
dec() { openssl enc -d -aes-256-cbc -pbkdf2 -in "$1" -out "$2" -pass "file:$3"; }

access() { # user file
  AUDIT="${AUDIT_LOG:-/tmp/sovoc-recording-audit.log}"   # resolve at call time
  u="$1"; f="$2"; ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  if echo " $RBAC_ALLOW " | grep -q " $u "; then
    echo "$ts ALLOW user=$u file=$f" >> "$AUDIT"; echo "ALLOW: $u may access $f (audited)"
  else
    echo "$ts DENY  user=$u file=$f" >> "$AUDIT"; echo "DENY: $u not in RBAC allowlist (audited)"; return 1
  fi
}

mask_dtmf() { # mask runs of 6+ digits, keeping only the last 4 (PAN); full-mask short PINs.
  printf '%s' "$1" | sed -E 's/[0-9]{2,}([0-9]{4})/****\1/g; s/PIN=[0-9]+/PIN=****/g'
}

case "${1:-demo}" in
  encrypt) enc "$2" "$3" "$4" && echo "encrypted -> $3" ;;
  decrypt) dec "$2" "$3" "$4" && echo "decrypted -> $3" ;;
  access)  access "$2" "$3" ;;
  mask-dtmf) mask_dtmf "$2" ;;
  demo)
    T=$(mktemp -d); K="$T/key"; head -c 32 /dev/urandom > "$K"
    printf 'RIFF....fake-wav-audio-bytes....' > "$T/rec.wav"
    enc "$T/rec.wav" "$T/rec.enc" "$K"
    dec "$T/rec.enc" "$T/rec.out" "$K"
    if cmp -s "$T/rec.wav" "$T/rec.out"; then echo "[demo] encryption-at-rest round-trip OK"; else echo "[demo] round-trip FAILED"; fi
    echo -n "[demo] RBAC: "; AUDIT_LOG="$T/audit" access auditor "$T/rec.enc"
    echo -n "[demo] RBAC: "; AUDIT_LOG="$T/audit" access mallory "$T/rec.enc" || true
    echo "[demo] audit trail:"; sed 's/^/    /' "$T/audit"
    echo "[demo] DTMF/PAN mask: $(mask_dtmf 'card=4111111111111111 PIN=1234')"
    rm -rf "$T" ;;
  *) echo "usage: secure-recording.sh {encrypt|decrypt|access|mask-dtmf|demo} ..."; exit 3 ;;
esac
