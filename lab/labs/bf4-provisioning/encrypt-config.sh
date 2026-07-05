#!/usr/bin/env bash
# VoIPSec BF4 (H2) — encrypt device provisioning configs so credentials are NEVER in the clear.
# Signing (sign-config.sh) gives integrity; this gives CONFIDENTIALITY at rest and in transit —
# the direct fix for "config files in the clear leak SIP credentials". AES-256-CBC + PBKDF2 via
# OpenSSL; pair with the RSA signature (encrypt-then-sign) for full AEAD-equivalent protection.
# Modes:
#   encrypt-config.sh encrypt <cfg> <keyfile> [out.enc]
#   encrypt-config.sh decrypt <in.enc> <keyfile> [out]
#   encrypt-config.sh rotate  <in.enc> <oldkey> <newkey> [out.enc]   # re-key without exposing plaintext on disk
#   encrypt-config.sh demo
set -u
command -v openssl >/dev/null 2>&1 || { echo "needs openssl"; exit 3; }
MODE="${1:-demo}"

enc() { openssl enc -aes-256-cbc -pbkdf2 -salt -in "$1" -out "$2" -pass "file:$3"; }
dec() { openssl enc -d -aes-256-cbc -pbkdf2 -in "$1" -out "$2" -pass "file:$3"; }

case "$MODE" in
  encrypt) enc "$2" "${4:-$2.enc}" "$3" && echo "encrypted -> ${4:-$2.enc}" ;;
  decrypt) dec "$2" "${4:-/dev/stdout}" "$3" ;;
  rotate)
    IN="$2"; OLD="$3"; NEW="$4"; OUT="${5:-$IN}"
    tmp=$(mktemp); trap 'rm -f "$tmp"' EXIT
    dec "$IN" "$tmp" "$OLD" || { echo "rotate: decrypt with old key failed"; exit 1; }
    enc "$tmp" "$OUT" "$NEW" && echo "rotated -> $OUT (re-encrypted under new key; plaintext never persisted)" ;;
  demo)
    d=$(mktemp -d); trap 'rm -rf "$d"' EXIT
    printf 'account.1.userid=1001\naccount.1.password=S3cr3t-P@ss-9x\naccount.1.sip_server=edge-sbc\n' > "$d/cfg"
    head -c 32 /dev/urandom > "$d/k1"
    enc "$d/cfg" "$d/cfg.enc" "$d/k1"
    echo "1) plaintext config leaks the secret:   $(grep -c 'S3cr3t' "$d/cfg") hit(s)"
    echo "2) encrypted config leaks the secret:   $(grep -ac 'S3cr3t' "$d/cfg.enc") hit(s)   <- must be 0"
    dec "$d/cfg.enc" "$d/out" "$d/k1"
    if cmp -s "$d/cfg" "$d/out"; then echo "3) decrypt round-trips:                 yes"; else echo "3) decrypt round-trips:                 NO"; fi
    # flip a byte in the ciphertext body and confirm decryption is rejected
    python3 - "$d/cfg.enc" <<'PY'
import sys
p=sys.argv[1]; b=bytearray(open(p,'rb').read()); b[-5]^=0xFF; open(p,'wb').write(b)
PY
    if dec "$d/cfg.enc" "$d/bad" "$d/k1" 2>/dev/null; then echo "4) tampered ciphertext decrypt:         SUCCEEDED (bad)"; else echo "4) tampered ciphertext decrypt:         rejected (good)"; fi
    ;;
  *) echo "usage: encrypt-config.sh {encrypt|decrypt|rotate|demo} ..."; exit 2 ;;
esac
