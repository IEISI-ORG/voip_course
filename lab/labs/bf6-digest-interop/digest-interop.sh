#!/usr/bin/env bash
# VoIPSec BF6 — SIP digest interop (RFC 7616 / RFC 8760). Compute a digest response for MD5 or
# SHA-256, and decide whether a client's chosen algorithm is a downgrade of what was offered.
# Deterministic. Modes:
#   digest-interop.sh compute <MD5|SHA-256> [--user u --realm r --pass p --method M --uri U \
#                                            --nonce N --nc 00000001 --cnonce C --qop auth]
#   digest-interop.sh downgrade-check "<offered-csv>" <chosen>   # e.g. "SHA-256,MD5" MD5
set -u
command -v openssl >/dev/null 2>&1 || { echo "needs openssl"; exit 3; }

H() { # H(alg, string)  -> lowercase hex
  case "$1" in
    MD5)     printf '%s' "$2" | openssl dgst -md5    -r | cut -d' ' -f1 ;;
    SHA-256) printf '%s' "$2" | openssl dgst -sha256 -r | cut -d' ' -f1 ;;
    *) echo "bad-alg"; return 1 ;;
  esac
}

compute() {
  ALG="$1"; shift
  U=alice REALM=lab.voipsec.test P=secret M=REGISTER URI=sip:lab.voipsec.test
  NONCE=abc123 NC=00000001 CNONCE=deadbeef QOP=auth
  while [ $# -gt 0 ]; do case "$1" in
    --user) U="$2";; --realm) REALM="$2";; --pass) P="$2";; --method) M="$2";;
    --uri) URI="$2";; --nonce) NONCE="$2";; --nc) NC="$2";; --cnonce) CNONCE="$2";; --qop) QOP="$2";;
  esac; shift 2; done
  HA1=$(H "$ALG" "$U:$REALM:$P")
  HA2=$(H "$ALG" "$M:$URI")
  RESP=$(H "$ALG" "$HA1:$NONCE:$NC:$CNONCE:$QOP:$HA2")
  echo "alg=$ALG response=$RESP"
}

strongest() { # pick strongest from a CSV (SHA-512-256 > SHA-256 > MD5)
  echo "$1" | tr ',' '\n' | grep -qi 'SHA-512-256' && { echo SHA-512-256; return; }
  echo "$1" | tr ',' '\n' | grep -qi 'SHA-256'     && { echo SHA-256; return; }
  echo MD5
}

case "${1:-}" in
  compute) shift; compute "$@";;
  downgrade-check)
    OFFERED="$2"; CHOSEN="$3"; BEST=$(strongest "$OFFERED")
    if [ "$CHOSEN" = "$BEST" ]; then
      echo "DECISION=accept (chosen=$CHOSEN == strongest offered=$BEST)"
    else
      echo "DECISION=reject (downgrade: chosen=$CHOSEN < strongest offered=$BEST)"
    fi ;;
  *) echo "usage: digest-interop.sh {compute|downgrade-check} ..."; exit 3 ;;
esac
