#!/usr/bin/env bash
# SOVOC BF11 — STIR/SHAKEN delegate certificate chain (RFC 9060 / RFC 8226). Builds an SP/root CA,
# issues an enterprise delegate cert chained to it, and verifies the chain. Deterministic (OpenSSL).
#   delegate-ca.sh demo [outdir]   # self-contained: CA -> delegate -> verify chain
set -u
command -v openssl >/dev/null 2>&1 || { echo "needs openssl"; exit 3; }
OUT="${2:-$(mktemp -d)}"; mkdir -p "$OUT"

echo "[1] SP/root CA"
openssl req -x509 -newkey rsa:2048 -nodes -keyout "$OUT/ca.key" -out "$OUT/ca.crt" \
  -subj "/C=US/O=SOVOC SP CA/CN=SOVOC STI-CA" -days 365 2>/dev/null

echo "[2] enterprise key + CSR"
openssl req -newkey rsa:2048 -nodes -keyout "$OUT/ent.key" -out "$OUT/ent.csr" \
  -subj "/C=US/O=Acme Corp/CN=Acme delegate" 2>/dev/null

echo "[3] SP issues the delegate cert (chained to the CA)"
# A real SHAKEN cert carries the TNAuthList extension (OID 1.3.6.1.5.5.7.1.26) scoping the
# authorized TNs; the enterprise's authorized range is tracked alongside (see tn-scope.txt) and
# enforced by the signer (attest-scope.sh).
openssl x509 -req -in "$OUT/ent.csr" -CA "$OUT/ca.crt" -CAkey "$OUT/ca.key" -CAcreateserial \
  -out "$OUT/ent.crt" -days 90 2>/dev/null
echo "14155550100-14155550199" > "$OUT/tn-scope.txt"   # delegated TN range (stand-in for TNAuthList)

echo "[4] verify the delegate cert chains to the SP CA"
if openssl verify -CAfile "$OUT/ca.crt" "$OUT/ent.crt" >/dev/null 2>&1; then
  echo "CHAIN OK: delegate cert is trusted via the SP CA"
  echo "outdir=$OUT"
  exit 0
else
  echo "CHAIN FAIL"
  exit 1
fi
