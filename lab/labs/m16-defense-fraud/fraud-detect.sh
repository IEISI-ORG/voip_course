#!/usr/bin/env bash
# VoIPSec M16 Lab 16.2 — CDR fraud detector (IRSF / toll fraud). Deterministic analytics.
# Flags: spend-cap breach, high-cost destination-prefix spikes (IRSF), and per-account spend
# that warrants auto-suspend. Works offline on a CDR CSV (ts,src,dst,dur_s,cost).
# Usage: fraud-detect.sh [cdr.csv]     env: CAP=<global $ cap> PREFIX_CAP=<$ per prefix>
set -u
CDR="${1:-$(dirname "$0")/sample-cdr.csv}"
[ -f "$CDR" ] || { echo "CDR file not found: $CDR"; exit 3; }
CAP="${CAP:-20}"
PREFIX_CAP="${PREFIX_CAP:-10}"
ACCT_CAP="${ACCT_CAP:-10}"

awk -F, -v cap="$CAP" -v pcap="$PREFIX_CAP" -v acap="$ACCT_CAP" '
NR>1 && $3!="" {
  total += $5
  acct[$2]  += $5
  # destination country/prefix bucket: "+" plus up to 4 digits
  p = substr($3, 1, 5)
  pcost[p] += $5; pcnt[p]++
}
END {
  alerts = 0
  printf "== CDR fraud scan ==\n"
  printf "total spend: $%.2f  (cap $%.2f)\n", total, cap
  if (total > cap) { print "ALERT: global spend cap breached"; alerts++ }

  for (p in pcost)
    if (pcost[p] > pcap || pcnt[p] > 5) {
      printf "ALERT: destination %s* — %d calls, $%.2f (possible IRSF)\n", p, pcnt[p], pcost[p]
      alerts++
    }

  for (a in acct)
    if (acct[a] > acap) {
      printf "SUSPEND-RECOMMEND: account %s spent $%.2f (auto-suspend + review)\n", a, acct[a]
      alerts++
    }

  printf "== %d alert(s) ==\n", alerts
  exit (alerts>0 ? 0 : 0)   # exit 0 either way; caller inspects output
}
' "$CDR"
