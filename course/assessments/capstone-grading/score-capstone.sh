#!/usr/bin/env bash
# VoIPSec — capstone grading harness. Reads a scoresheet CSV (category,max,security,score),
# computes the total, and enforces the gate: PASS requires total >= 70 AND no failing security
# category (a security category fails if it scores < 50% of its max — security is mandatory).
# Usage: score-capstone.sh [scoresheet.csv]
set -u
CSV="${1:-$(dirname "$0")/scoresheet.csv}"
[ -f "$CSV" ] || { echo "no scoresheet: $CSV"; exit 3; }

awk -F, '
NR>1 && $1!="" {
  cat=$1; max=$2+0; sec=$3; sc=$4+0
  if (sc>max) { printf "ERROR: %s score %d > max %d\n", cat, sc, max; err=1 }
  total+=sc; maxtotal+=max
  printf "  %-38s %3d / %-3d %s\n", cat, sc, max, (sec=="yes" ? "[security]" : "")
  if (sec=="yes" && sc < 0.5*max) secfail = secfail "\n    - " cat " (" sc "/" max ")"
}
END {
  printf "  %-38s %3d / %-3d\n", "TOTAL", total, maxtotal
  if (err) { print "RESULT: INVALID (a score exceeds its max)"; exit 3 }
  gate_total = (total >= 70)
  gate_sec   = (secfail == "")
  if (gate_total && gate_sec) { print "CAPSTONE: PASS"; exit 0 }
  print "CAPSTONE: FAIL"
  if (!gate_total) print "  - overall total < 70"
  if (!gate_sec)   print "  - failing security category:" secfail
  exit 1
}' "$CSV"
