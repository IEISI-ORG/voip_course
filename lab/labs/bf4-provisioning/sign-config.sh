#!/usr/bin/env bash
# SOVOC BF4 — sign & verify a device provisioning config (integrity, so a tampered/rogue config
# is rejected even if the transport is subverted). RSA/SHA-256 detached signatures via OpenSSL.
# Modes:
#   sign-config.sh sign   <cfg> <privkey.pem> [out.sig]
#   sign-config.sh verify <cfg> <sig> <pubkey.pem>
#   sign-config.sh demo                     # self-contained: sign, verify, tamper -> fail
set -u
command -v openssl >/dev/null 2>&1 || { echo "needs openssl"; exit 3; }
MODE="${1:-demo}"

case "$MODE" in
  sign)
    CFG="$2"; KEY="$3"; SIG="${4:-$CFG.sig}"
    openssl dgst -sha256 -sign "$KEY" -out "$SIG" "$CFG" && echo "signed -> $SIG" ;;
  verify)
    CFG="$2"; SIG="$3"; PUB="$4"
    if openssl dgst -sha256 -verify "$PUB" -signature "$SIG" "$CFG" >/dev/null 2>&1; then
      echo "signature OK"; exit 0
    else
      echo "signature INVALID"; exit 1
    fi ;;
  demo)
    TMP=$(mktemp -d)
    openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out "$TMP/k.pem" 2>/dev/null
    openssl rsa -in "$TMP/k.pem" -pubout -out "$TMP/pub.pem" 2>/dev/null
    printf 'account.1.userid=1001\naccount.1.password=FROM_SECURE_STORE\n' > "$TMP/cfg"
    openssl dgst -sha256 -sign "$TMP/k.pem" -out "$TMP/cfg.sig" "$TMP/cfg"
    echo -n "[demo] verify signed config: "
    openssl dgst -sha256 -verify "$TMP/pub.pem" -signature "$TMP/cfg.sig" "$TMP/cfg" >/dev/null 2>&1 \
      && echo "signature OK" || echo "signature INVALID"
    echo "FLR_TAMPER=yes" >> "$TMP/cfg"     # attacker edits the config
    echo -n "[demo] verify TAMPERED config: "
    if openssl dgst -sha256 -verify "$TMP/pub.pem" -signature "$TMP/cfg.sig" "$TMP/cfg" >/dev/null 2>&1; then
      echo "signature OK (BAD — tamper not detected!)"
    else
      echo "tamper detected (signature INVALID) — device rejects it"
    fi
    rm -rf "$TMP" ;;
  *) echo "usage: sign-config.sh {sign|verify|demo} ..."; exit 3 ;;
esac
