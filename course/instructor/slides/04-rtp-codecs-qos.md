---
marp: true
theme: default
paginate: true
title: Module 4 — RTP, RTCP, Codecs & QoS
---

# Module 4 — RTP, RTCP, Codecs & QoS

The media plane: how voice/video actually travels, its quality metrics, and how the media path is attacked.

<!-- Instructor: set the scene; ~30 min. Every module ends with a hands-on lab + fail-closed verify.sh. -->
---

## Learning Objectives

- Dissect RTP/RTCP headers and relate them to jitter, loss, and delay.
- Choose codecs by bandwidth/quality and compute link budgets.
- Configure and measure QoS; identify media-plane attacks and defenses.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 1. Concept

- **RTP (RFC 3550):** header fields (PT, seq, timestamp, SSRC, marker), payload, encapsulation
- **RTCP:** SR/RR, jitter/loss/RTT reporting; RTCP-XR extended reports; RTP:RTCP port pairing
- **Codecs:** G.711 (a/µ-law), G.722 (HD), G.729, Opus (VBR/CBR, wideband/fullband), iLBC;
- **Bandwidth math:** payload + RTP/UDP/IP + L2 overhead; ptime effect; packets-per-second;
- **QoS:** delay/jitter/loss acceptance criteria; L2 (802.1p/Q, VLANs), L3 (DiffServ/DSCP, EF/AF);
- **Video over IP:** RTP for video, keyframes, bitrate, one-way vs. conferencing, SDP for AV.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 2. Packet Reality

- Decode RTP in Wireshark; play back audio; read the RTP stream stats (jitter, lost, delta).
- Inspect RTCP SR/RR; correlate reported loss with induced network impairment (tc/netem).
- Read a DTMF (RFC 4733) event sequence.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 3. Build (OSS)

- rtpengine as media relay; enable rtcp-mux; observe stats.
- Apply DSCP marking in Asterisk/Kamailio; verify with capture.
- Induce impairment with `tc netem` and watch MOS/jitter degrade in Grafana.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 4. Attack / Defend

- **RTP injection / bleed (T9):** unauthenticated RTP ports accept spoofed streams → symmetric
- **Eavesdropping (T5):** plaintext RTP is trivially recorded (`rtp` export → audio) → SRTP (M11).
- **QoS abuse / DSCP marking by untrusted hosts:** re-mark/trust boundaries at the edge.
- **RTCP-based info leak / bandwidth exhaustion.** Update threat model.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 5. Labs

- **Lab 4.1:** From a pcap, extract and play the audio; compute jitter/loss and estimate MOS.
- **Lab 4.2:** Compute the bandwidth budget for G.711 vs. Opus at two ptimes; verify on the wire.
- **Lab 4.3 (attack):** Sniff and reconstruct a plaintext call's audio; then repeat with SRTP and
- **Lab 4.4:** Mark DSCP EF, impair the link with netem, and show QoS effect in dashboards.
- *Rubric:* correct stats/MOS; accurate budget; demonstrated eavesdrop + SRTP mitigation.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## Lab & assessment

- Hands-on lab with a fail-closed `verify.sh`; rubric 100 pts, pass ≥ 70.
- Update your living threat model + hardening checklist.

<!-- Speaker note: point learners at lab/labs/<module>/. -->
