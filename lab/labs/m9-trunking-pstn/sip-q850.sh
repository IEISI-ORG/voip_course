#!/usr/bin/env bash
# VoIPSec M9 Lab 9.2 — SIP status <-> Q.850 cause mapping (per RFC 3398). Deterministic lookup.
# Usage: sip-q850.sh            # print the common mapping table
#        sip-q850.sh 486        # look up one SIP code
set -u

# SIP_code  Q850_cause  meaning   (the well-established RFC 3398 mappings; consult the RFC for
# the exhaustive table and edge cases.)
MAP="403 21 Call_rejected
404 1 Unallocated_number
405 63 Service_or_option_unavailable
408 102 Recovery_on_timer_expiry
410 22 Number_changed
480 18 No_user_responding
484 28 Invalid_number_format
486 17 User_busy
488 31 Normal_unspecified(incompatible_media)
500 41 Temporary_failure
502 38 Network_out_of_order
503 34 No_circuit/channel_available
504 102 Recovery_on_timer_expiry
600 17 User_busy(global)
603 21 Call_rejected(decline)
604 1 Unallocated_number"

if [ $# -ge 1 ]; then
  row=$(printf '%s\n' "$MAP" | awk -v c="$1" '$1==c{print}')
  if [ -n "$row" ]; then
    echo "$row" | awk '{printf "SIP %s -> Q.850 cause %s  (%s)\n", $1, $2, $3}'
  else
    echo "SIP $1: not in the common table — see RFC 3398 for the full mapping."
  fi
  exit 0
fi

echo "SIP -> Q.850 (RFC 3398, common subset)"
echo "--------------------------------------"
printf '%s\n' "$MAP" | awk '{printf "  %-4s -> cause %-3s  %s\n", $1, $2, $3}'
echo
echo "Bridging SIP<->PSTN maps these both ways; a wrong mapping is an interop/billing bug."
