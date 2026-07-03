#!/usr/bin/env bash
# SOVOC BF5 — transit/gateway STIR/SHAKEN policy decision (RFC 8224/8588/8816).
# Decides: strip inbound Identity? apply which attestation (A/B/C)? use Out-of-Band SHAKEN?
# Deterministic — encodes the gateway's obligations so they can be audited/tested.
#
# Usage: shaken-policy.sh --own {yes|no} --trusted-upstream {yes|no} \
#                         --identity {valid|invalid|absent} [--nexthop {ip|tdm}]
#   --own              : do we assign/own the calling telephone number?
#   --trusted-upstream : is the sending peer authenticated/trusted?
#   --identity         : state of any inbound Identity header
#   --nexthop          : ip (inline Identity OK) or tdm/ss7 (needs OOB)
set -u
OWN=no TRUSTED=no IDENTITY=absent NEXTHOP=ip
while [ $# -gt 0 ]; do case "$1" in
  --own) OWN="$2"; shift 2;;
  --trusted-upstream) TRUSTED="$2"; shift 2;;
  --identity) IDENTITY="$2"; shift 2;;
  --nexthop) NEXTHOP="$2"; shift 2;;
  *) echo "unknown arg: $1"; exit 3;;
esac; done

# (1) Strip an inbound Identity we cannot trust: untrusted source OR invalid signature.
if [ "$IDENTITY" != "absent" ] && { [ "$TRUSTED" = "no" ] || [ "$IDENTITY" = "invalid" ]; }; then
  STRIP=yes
else
  STRIP=no
fi

# (2) Attestation to apply when we sign as the gateway.
if [ "$OWN" = "yes" ] && [ "$TRUSTED" = "yes" ]; then
  ATTEST=A          # full: we own the number and authenticated the originator
elif [ "$OWN" = "no" ] && [ "$TRUSTED" = "yes" ]; then
  ATTEST=B          # partial: we know the customer, not the specific number
else
  ATTEST=C          # gateway: cannot verify the originator
fi

# (3) Out-of-Band SHAKEN for hops that cannot carry the Identity header inline.
if [ "$NEXTHOP" = "tdm" ] || [ "$NEXTHOP" = "ss7" ]; then OOB=yes; else OOB=no; fi

echo "STRIP_IDENTITY=$STRIP"
echo "ATTEST=$ATTEST"
echo "OOB=$OOB"
echo "rationale: own=$OWN trusted-upstream=$TRUSTED identity=$IDENTITY nexthop=$NEXTHOP"
[ "$STRIP" = "yes" ] && echo "  -> strip unverifiable inbound Identity (don't launder a spoofer's identity)"
[ "$ATTEST" = "C" ]  && echo "  -> sign attestation C: origin unverified, call transited this gateway"
[ "$OOB" = "yes" ]   && echo "  -> publish PASSporT to the OOB CPS (RFC 8816); TDM/SS7 can't carry Identity inline"
exit 0
