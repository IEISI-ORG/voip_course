---
marp: true
theme: default
paginate: true
title: Module 5 — Packet Analysis & Troubleshooting
---

# Module 5 — Packet Analysis & Troubleshooting

Master the OSS analysis toolchain (Wireshark, sngrep, HOMER) and a repeatable fault-isolation method.

<!-- Instructor: set the scene; ~30 min. Every module ends with a hands-on lab + fail-closed verify.sh. -->
---

## Learning Objectives

- Capture correctly (where, what, at scale) and preserve evidence integrity.
- Use Wireshark/tshark, sngrep, and HOMER/HEP to diagnose signaling and media faults.
- Apply a systematic troubleshooting method to real SIP failures.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 1. Concept

- **Capture strategy:** where to tap (endpoint vs. edge vs. core), SPAN/mirror, ring buffers,
- **Wireshark for VoIP:** SIP/SDP/RTP dissectors, VoIP Calls window, flow sequence, Follow
- **sngrep:** live ladder from interface or pcap; filtering by call-id/method; save pcap.
- **HOMER 7 + Heplify/captagent (HEP):** centralized capture, correlation across hops, KPIs,
- **Troubleshooting method:** reproduce → capture at the right point → isolate plane (signaling
- **Response-code triage:** 4xx (client), 5xx (server), 6xx (global) decision trees; common

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 2. Packet Reality

- Diagnose a curated fault library from pcaps: one-way audio (NAT), 488 (codec mismatch),

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 3. Build (OSS)

- Wire Heplify agents on `edge-sbc`/`pbx-*`; confirm HOMER receives HEP; build a KPI dashboard.
- Automate a triage with `tshark` (extract call-ids with non-2xx final responses).

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 4. Attack / Defend

- **Evidence integrity & chain of custody:** hashing pcaps, timestamps, access control — needed
- **Captures contain secrets/PII:** SDP, DTMF (card numbers via inband!), recordings → handle,
- **Detecting recon in captures:** spot svmap/OPTIONS sweeps and enumeration patterns (feeds M14/M15).

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 5. Labs

- **Lab 5.1:** Given 6 fault pcaps, diagnose each with a one-paragraph root cause + fix.
- **Lab 5.2:** Stand up HOMER capture across the platform; correlate a multi-hop call.
- **Lab 5.3:** Write a `tshark` one-liner that lists all calls with a 4xx/5xx final response.
- **Lab 5.4 (security):** Redact DTMF/PII from a pcap and hash it for evidence.
- *Rubric:* correct root causes; working HOMER correlation; automation script; proper evidence handling.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## Lab & assessment

- Hands-on lab with a fail-closed `verify.sh`; rubric 100 pts, pass ≥ 70.
- Update your living threat model + hardening checklist.

<!-- Speaker note: point learners at lab/labs/<module>/. -->
