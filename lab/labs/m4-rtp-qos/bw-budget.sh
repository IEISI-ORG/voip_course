#!/usr/bin/env bash
# SOVOC M4 — RTP bandwidth budget calculator (Lab 4.2). Deterministic; no lab needed.
# Shows how header overhead (RTP 12 + UDP 8 + IPv4 20 = 40 B, + Ethernet 18 B) inflates the
# on-the-wire rate versus the raw codec bitrate, at different ptimes.
# Usage: bw-budget.sh          (default table)
set -u

# codec  bitrate_bps  ptime_ms
rows="G.711 64000 20
G.711 64000 30
G.722 64000 20
Opus 24000 20
Opus 24000 60
G.729 8000 20"

printf "%-7s %-6s %-5s %-9s %-8s %-11s %-12s\n" "CODEC" "BR(k)" "PTIME" "PAYLOAD" "PPS" "L3(kbps)" "L2eth(kbps)"
echo "------------------------------------------------------------------------"
printf '%s\n' "$rows" | while read -r codec br ptime; do
  awk -v c="$codec" -v br="$br" -v pt="$ptime" 'BEGIN{
    payload = br * (pt/1000) / 8;        # bytes per packet
    pps = 1000 / pt;
    l3  = (payload + 40) * pps * 8 / 1000;      # + RTP/UDP/IP
    l2  = (payload + 40 + 18) * pps * 8 / 1000; # + Ethernet+FCS
    printf "%-7s %-6d %-5d %-9.0f %-8.0f %-11.1f %-12.1f\n", c, br/1000, pt, payload, pps, l3, l2;
  }'
done
echo
echo "Note: L3 = one-way IP-layer rate per stream; a call is bidirectional (x2)."
echo "Smaller ptime => more packets/sec => more header overhead (worse efficiency)."
