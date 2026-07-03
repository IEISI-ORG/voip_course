#!/usr/bin/env bash
# VoIPSec M5 Lab 5.3 — list every call in a pcap that got a 4xx/5xx final response.
# The graded deliverable is your own one-liner; this is the reference solution.
# Usage: list-bad-calls.sh <capture.pcap>
set -u
PCAP="${1:?usage: list-bad-calls.sh <capture.pcap>}"
command -v tshark >/dev/null 2>&1 || { echo "needs tshark (Wireshark CLI)"; exit 3; }

echo "Call-ID                              Code  Reason"
echo "------------------------------------------------------------------"
tshark -r "$PCAP" -Y 'sip.Status-Code >= 400' \
  -T fields -e sip.Call-ID -e sip.Status-Code -e sip.Status-Line 2>/dev/null \
  | sort -u
