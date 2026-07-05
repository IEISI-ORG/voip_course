# Module 5 — Packet Analysis & Troubleshooting

**One-liner:** Master the OSS analysis toolchain (Wireshark, sngrep, HOMER) and a repeatable
fault-isolation method. **Est. time:** 4h · **Prereqs:** Modules 2–4. **Checkpoint exam #1 after this module.**

## Learning Objectives
- Capture correctly (where, what, at scale) and preserve evidence integrity.
- Use Wireshark/tshark, sngrep, and HOMER/HEP to diagnose signaling and media faults.
- Apply a systematic troubleshooting method to real SIP failures.

## 1. Concept
- **Capture strategy:** where to tap (endpoint vs. edge vs. core), SPAN/mirror, ring buffers,
  capture filters vs. display filters, decrypting TLS (with keys) vs. capturing pre-encryption.
- **Wireshark for VoIP:** SIP/SDP/RTP dissectors, VoIP Calls window, flow sequence, Follow
  stream, RTP player, profiles, coloring rules, `tshark` for automation and big files.
- **sngrep:** live ladder from interface or pcap; filtering by call-id/method; save pcap.
- **HOMER 7 + Heplify/captagent (HEP):** centralized capture, correlation across hops, KPIs,
  retention — the operator's "flight recorder."
- **Troubleshooting method:** reproduce → capture at the right point → isolate plane (signaling
  vs. media) → read the first anomaly, not the last → form/test hypothesis.
- **Response-code triage:** 4xx (client), 5xx (server), 6xx (global) decision trees; common
  SIP/VoIP problems (one-way audio, no ringback, 488, 407 loops, NAT/media).

## 2. Packet Reality
- Diagnose a curated fault library from pcaps: one-way audio (NAT), 488 (codec mismatch),
  407 loop (auth realm), 480/503 (registration/overload), no ringback (early media).

## 3. Build (OSS)
- Wire Heplify agents on `edge-sbc`/`pbx-*`; confirm HOMER receives HEP; build a KPI dashboard.
- Automate a triage with `tshark` (extract call-ids with non-2xx final responses).

## 4. Attack / Defend
- **Evidence integrity & chain of custody:** hashing pcaps, timestamps, access control — needed
  for incident response (M16) and fraud cases.
- **Captures contain secrets/PII:** SDP, DTMF (card numbers via inband!), recordings → handle,
  redact, encrypt, and control access. This is itself a security control.
- **Detecting recon in captures:** spot svmap/OPTIONS sweeps and enumeration patterns (feeds M14/M15).

## 5. Labs
- **Lab 5.1:** Given 6 fault pcaps, diagnose each with a one-paragraph root cause + fix.
- **Lab 5.2:** Stand up HOMER capture across the platform; correlate a multi-hop call.
- **Lab 5.3:** Write a `tshark` one-liner that lists all calls with a 4xx/5xx final response.
- **Lab 5.4 (security):** Redact DTMF/PII from a pcap and hash it for evidence.
- *Rubric:* correct root causes; working HOMER correlation; automation script; proper evidence handling.

## Assessment / Checkpoint Exam #1 (protocol + analysis)
- Given a trace, identify the plane and first anomaly for a one-way-audio call.
- When must you capture before TLS encryption vs. decrypt after?
- Why are captures a data-protection liability, and how do you mitigate it?

## References
- Wireshark User Guide (VoIP); sngrep README; HOMER 7 / Heplify / HEP RFC-draft; tshark docs.
