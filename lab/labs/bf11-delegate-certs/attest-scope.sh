#!/usr/bin/env bash
# SOVOC BF11 — attestation scope check. Sign at "A" ONLY if the calling number falls within the
# delegate cert's authorized TN range (the RFC 9060 / TNAuthList promise). Otherwise refuse to
# claim A. Deterministic.
#   attest-scope.sh <calling-tn> "<lo>-<hi>"     e.g. attest-scope.sh +1-415-555-0142 14155550100-14155550199
set -u
TN=$(printf '%s' "${1:?usage: attest-scope.sh <tn> <lo-hi>}" | tr -cd '0-9')
RANGE="${2:?usage: attest-scope.sh <tn> <lo-hi>}"
LO="${RANGE%%-*}"; HI="${RANGE##*-}"

# Compare full digit strings; the range and the TN must use the same convention (E.164 with
# country code, matching tn-scope.txt).
if [ "$TN" -ge "$LO" ] 2>/dev/null && [ "$TN" -le "$HI" ] 2>/dev/null; then
  echo "ATTEST=A (tn $TN in delegated range $LO-$HI)"
  exit 0
else
  echo "ATTEST=refuse (tn $TN NOT in delegated range $LO-$HI — signing A here would be forgery)"
  exit 1
fi
