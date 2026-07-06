#!/usr/bin/env bash
# VoIPSec M13 — decode a STIR/SHAKEN PASSporT (Lab 13.2). A PASSporT is a JWT
# (header.payload.signature); this prints the base64url-decoded header and payload claims.
# It does NOT verify the signature — that requires the x5u cert chain (do that in the lab).
# Usage: passport-decode.sh [compact-jwt]     (no arg = decode a built-in sample)
set -u

b64url_dec() {  # pad then translate base64url -> base64 and decode
  s="$1"; m=$(( ${#s} % 4 ))
  [ "$m" -eq 2 ] && s="${s}=="
  [ "$m" -eq 3 ] && s="${s}="
  printf '%s' "$s" | tr '_-' '/+' | base64 -d 2>/dev/null
}
b64url_enc() { base64 | tr '+/' '-_' | tr -d '=\n'; }

TOKEN="${1:-}"
if [ -z "$TOKEN" ]; then
  echo "[passport-decode] no token given — building & decoding a sample SHAKEN PASSporT"
  H='{"alg":"ES256","ppt":"shaken","typ":"passport","x5u":"https://ca.lab.voipsec.test/cert.pem"}'
  P='{"attest":"A","dest":{"tn":["15551230000"]},"iat":1700000000,"orig":{"tn":"15559990000"},"origid":"a1b2c3d4-lab"}'
  TOKEN="$(printf '%s' "$H" | b64url_enc).$(printf '%s' "$P" | b64url_enc).SIGPLACEHOLDER"
fi

HDR="${TOKEN%%.*}"; REST="${TOKEN#*.}"; PL="${REST%%.*}"
echo "== PASSporT header =="
b64url_dec "$HDR"; echo
echo "== PASSporT payload (claims) =="
b64url_dec "$PL"; echo
echo
echo "attest A/B/C = attestation level; verify the signature against x5u before trusting it."
