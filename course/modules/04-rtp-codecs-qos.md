# Module 4 — RTP, RTCP, Codecs & QoS

**One-liner:** The media plane: how voice/video actually travels, its quality metrics, and how
the media path is attacked. **Est. time:** 4h · **Prereqs:** Module 3.

## Learning Objectives
- Dissect RTP/RTCP headers and relate them to jitter, loss, and delay.
- Choose codecs by bandwidth/quality and compute link budgets.
- Configure and measure QoS; identify media-plane attacks and defenses.

## 1. Concept
- **RTP (RFC 3550):** header fields (PT, seq, timestamp, SSRC, marker), payload, encapsulation
  over UDP; SSRC/CSRC; the relationship of seq/timestamp to jitter buffers.
- **RTCP:** SR/RR, jitter/loss/RTT reporting; RTCP-XR extended reports; RTP:RTCP port pairing
  (and rtcp-mux).
- **Codecs:** G.711 (a/µ-law), G.722 (HD), G.729, Opus (VBR/CBR, wideband/fullband), iLBC;
  MOS/R-factor; DTMF via RFC 4733 (`telephone-event`) vs. inband vs. SIP INFO.
- **Bandwidth math:** payload + RTP/UDP/IP + L2 overhead; ptime effect; packets-per-second;
  codec vs. link (SDSL/fibre) budgeting; bandwidth calculator methodology.
- **QoS:** delay/jitter/loss acceptance criteria; L2 (802.1p/Q, VLANs), L3 (DiffServ/DSCP, EF/AF);
  queuing/policing; QoS across administrative domains and the Internet's lack of it.
- **Video over IP:** RTP for video, keyframes, bitrate, one-way vs. conferencing, SDP for AV.

## 2. Packet Reality
- Decode RTP in Wireshark; play back audio; read the RTP stream stats (jitter, lost, delta).
- Inspect RTCP SR/RR; correlate reported loss with induced network impairment (tc/netem).
- Read a DTMF (RFC 4733) event sequence.

## 3. Build (OSS)
- rtpengine as media relay; enable rtcp-mux; observe stats.
- Apply DSCP marking in Asterisk/Kamailio; verify with capture.
- Induce impairment with `tc netem` and watch MOS/jitter degrade in Grafana.

## 4. Attack / Defend
- **RTP injection / bleed (T9):** unauthenticated RTP ports accept spoofed streams → symmetric
  RTP, strict-source in rtpengine, SRTP authentication.
- **Eavesdropping (T5):** plaintext RTP is trivially recorded (`rtp` export → audio) → SRTP (M11).
- **QoS abuse / DSCP marking by untrusted hosts:** re-mark/trust boundaries at the edge.
- **RTCP-based info leak / bandwidth exhaustion.** Update threat model.

## 5. Labs
- **Lab 4.1:** From a pcap, extract and play the audio; compute jitter/loss and estimate MOS.
- **Lab 4.2:** Compute the bandwidth budget for G.711 vs. Opus at two ptimes; verify on the wire.
- **Lab 4.3 (attack):** Sniff and reconstruct a plaintext call's audio; then repeat with SRTP and
  show it fails (bridges to M11).
- **Lab 4.4:** Mark DSCP EF, impair the link with netem, and show QoS effect in dashboards.
- *Rubric:* correct stats/MOS; accurate budget; demonstrated eavesdrop + SRTP mitigation.

## Assessment (sample)
- Which RTP fields drive the jitter buffer, and how?
- Give the per-call bandwidth for G.711 @20ms including IP/UDP/RTP overhead.
- Why does symmetric RTP + strict source reduce injection risk?

## References
- RFC 3550/3551 (RTP/RTCP), 3611 (RTCP-XR), 4733/4734 (DTMF events), 6716 (Opus),
  3168 (ECN), 4594/8837 (DiffServ for RT), 5761 (rtcp-mux).
- Goode (Proc. IEEE, 2002), *Voice Over Internet Protocol (VoIP)* — see
  [bibliography §11](../references/bibliography.md). The authoritative treatment of the
  **delay-vs-bandwidth tradeoff**, codec selection, and the delay budget behind this module's
  bandwidth-budget maths (`lab/labs/m4-rtp-qos/bw-budget.sh`).
