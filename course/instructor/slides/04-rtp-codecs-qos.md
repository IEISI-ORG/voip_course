---
marp: true
theme: default
paginate: true
title: Module 4 — RTP, RTCP, Codecs & QoS
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Module 4 — RTP, RTCP, Codecs & QoS

**The media plane: how voice/video actually travels, its quality metrics, and how it's attacked.**

`Est. 4h` · Prereqs: Module 3

<!--
Speaker: Module 3 decided *where* media goes; this module is *what flows there*. Two halves: quality
(RTP/RTCP, codecs, QoS, bandwidth math) and security (the media path is wide open unless you close
it). Keep returning to: plaintext RTP is just recordable audio.
-->

---

## What you'll leave with

- Dissect **RTP/RTCP headers** and relate them to jitter, loss, delay.
- Choose **codecs** by bandwidth/quality; compute a **link budget**.
- Configure/measure **QoS**; identify media-plane attacks and defenses.

<!--
Speaker: The exam wants a real bandwidth number and an RTP-fields-to-jitter explanation. Make the
maths muscle-memory, and make "plaintext RTP = eavesdropping" visceral with the lab.
-->

---

## RTP header

- **PT** (payload type) · **sequence** · **timestamp** · **SSRC** · marker.
- Runs over **UDP**; SSRC identifies a source, seq/timestamp drive the **jitter buffer**.
- One media stream = one SSRC.

<!--
Speaker: Sequence number detects loss/reorder; timestamp paces playout; together they feed the
jitter buffer that smooths network variation. SSRC identifies the stream — spoofing a valid SSRC is
how injection/"bleed" works later. Show these fields in a real RTP packet.
-->

---

## RTCP — the quality feedback channel

- **SR / RR:** sender/receiver reports — jitter, loss, RTT.
- **RTCP-XR** extended reports; classic **RTP:RTCP port pairing**, or **rtcp-mux** (one port).
- This is where you *measure* call quality, not guess it.

<!--
Speaker: RTCP is the out-of-band quality report riding alongside RTP. Reported loss/jitter is what
your monitoring (M17) turns into MOS trends. rtcp-mux collapses media+control to one port — a WebRTC
convenience and one fewer NAT pinhole. Correlate RTCP-reported loss with induced impairment in lab.
-->

---

## Codecs & quality

| Codec | Rate | Note |
|---|---|---|
| G.711 (µ/a-law) | 64 kbps | PSTN-grade, no compression |
| G.722 | 64 kbps | HD/wideband |
| G.729 | 8 kbps | low bandwidth, licensed history |
| Opus | ~6–510 kbps | VBR/CBR, wide/fullband, modern default |

- Quality = **MOS / R-factor**; DTMF via **RFC 4733** events (not inband).

<!--
Speaker: Opus is the modern answer for most cases. The point isn't memorising rates — it's the
delay-vs-bandwidth tradeoff (Goode, Proc. IEEE 2002). DTMF-as-events matters for PCI: digits ride as
named events you can suppress in recordings (M16), not as audio tones.
-->

---

## Bandwidth math

- **Per call = payload + RTP(12) + UDP(8) + IP(20) + L2 overhead**, times packets-per-second.
- **ptime** sets packets/sec (20 ms ptime → 50 pps).
- G.711 @20 ms ≈ **~87 kbps** one-way on Ethernet once overhead is counted.

<!--
Speaker: This is the calculation people get wrong by quoting the codec rate (64 kbps) and forgetting
overhead — the headers roughly *double* small payloads. Longer ptime = fewer packets = less overhead
but more delay/loss impact. Walk the arithmetic once; the lab's bw-budget.sh checks their answer.
-->

---

## QoS

- Acceptance criteria: bounded **delay, jitter, loss** (voice is delay-sensitive, not bandwidth-hungry).
- **L2:** 802.1p/Q, VLANs · **L3:** DiffServ/**DSCP** (EF for voice, AF for video).
- The Internet gives **no QoS** across domains — mark inside your boundary, don't trust it outside.

<!--
Speaker: Voice needs *consistency*, not throughput — 87 kbps is nothing, but 150 ms of jitter kills
it. DSCP EF marks voice for priority queuing, but only within networks you control. That "only within
your boundary" is also a security statement: don't trust DSCP set by untrusted hosts (attack slide).
-->

---

## Packet reality

- Decode **RTP in Wireshark**, play back the audio, read stream stats (jitter, lost, delta).
- Inspect **RTCP SR/RR**; correlate reported loss with induced impairment (`tc netem`).
- Read a **DTMF (RFC 4733)** event sequence.

<!--
Speaker: The "play back the audio from a capture" moment is the one that lands the security lesson —
if you can hear it, so can any eavesdropper. netem lets them impair the link deterministically and
watch RTCP report it. Keep the impaired-vs-clean stats side by side.
-->

---

## Build (OSS)

- **rtpengine** as media relay; enable **rtcp-mux**; observe stats.
- Apply **DSCP** marking in Asterisk/Kamailio; verify on the wire.
- Induce impairment with **`tc netem`**; watch MOS/jitter degrade in Grafana.

<!--
Speaker: rtpengine reappears here as the media anchor (from M3) that also gives you stats. The netem
→ Grafana loop previews monitoring (M17): impair, observe, alert. Verifying DSCP actually on the wire
teaches "trust but verify" for QoS config.
-->

---

## Attack / Defend

- **RTP injection / "bleed" (T9):** open RTP ports accept spoofed streams → **symmetric RTP +
  strict-source** in rtpengine + SRTP auth.
- **Eavesdropping (T5):** plaintext RTP → recordable audio → **SRTP (M12)**.
- **QoS abuse:** untrusted hosts marking DSCP → re-mark / trust boundary at the edge.
- **RTCP info leak / bandwidth exhaustion** → policy + monitoring.

<!--
Speaker: The media plane is unauthenticated by default. Injection works because nothing checks the
source; symmetric RTP + strict-source makes rtpengine only accept media from the negotiated peer.
Eavesdropping works because it's plaintext; SRTP fixes it (M12). Everything here is "authenticate and
control the media path."
-->

---

## Labs

- **Lab 4.1** — From a pcap, extract & play audio; compute jitter/loss, estimate **MOS**.
- **Lab 4.2** — Bandwidth budget for **G.711 vs. Opus** at two ptimes; verify on the wire.
- **Lab 4.3 (attack)** — Sniff & reconstruct a plaintext call's audio; repeat with **SRTP** and show
  it fails (bridge to M12).
- **Lab 4.4** — Mark **DSCP EF**, impair with netem, show QoS effect in dashboards.

*Rubric:* correct stats/MOS · accurate budget · demonstrated eavesdrop + SRTP mitigation.

<!--
Speaker: 4.3 is the pivotal lab — reconstructing a real conversation from a plaintext capture is the
moment SRTP stops being abstract. 4.2 makes the bandwidth maths real against the wire. Keep the
plaintext-vs-SRTP captures for the M12 callback.
-->

---

## Takeaways & quick check

- RTP is **unauthenticated and (by default) plaintext** — that's two attacks (inject + eavesdrop).
- Voice needs **bounded delay/jitter/loss**, not bandwidth.
- Count the **overhead** — the codec rate is not the link cost.

**Check:** Which RTP fields drive the jitter buffer? G.711 @20 ms bandwidth incl. IP/UDP/RTP?
Why does symmetric RTP + strict source reduce injection risk?

<!--
Speaker: Answers — sequence + timestamp drive the jitter buffer; G.711@20ms ≈ 87 kbps once
IP/UDP/RTP/L2 overhead is added to the 64 kbps payload; symmetric RTP + strict-source makes the relay
accept media only from the negotiated address/port, so spoofed injection from elsewhere is dropped.
Next: Module 5 — capture, analysis, and evidence integrity.
-->
