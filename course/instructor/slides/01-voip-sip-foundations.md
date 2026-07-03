---
marp: true
theme: default
paginate: true
title: Module 1 — VoIP & SIP Foundations
---

# Module 1 — VoIP & SIP Foundations

What VoIP is, where SIP fits, and the attack surface you're signing up to defend.

<!-- Instructor: set the scene; ~30 min. Every module ends with a hands-on lab + fail-closed verify.sh. -->
---

## Learning Objectives

- Explain the VoIP call model (signaling vs. media) and where SIP sits in the stack.
- Identify SIP entities (UAC, UAS, registrar, proxy, redirect, B2BUA) and SIP URIs.
- Map the end-to-end attack surface of a basic VoIP call.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 1. Concept

- VoIP basics: sampling → encoding → packetization → transport; the two-plane model
- Where SIP fits: application layer over UDP/TCP/TLS/WS(S); relationship to HTTP heritage.
- SIP entities: User Agents (UAC/UAS), Registrar, Location Service, Proxy (stateful/stateless),
- Addressing: SIP/SIPS URIs, `user@domain`, contacts, AoR vs. contact, E.164 in SIP.
- Standards landscape: RFC 3261 and the "beyond 3261" family; IETF working groups; why SIP is

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 2. Packet Reality

- Anatomy of a call at 10,000 ft: REGISTER → INVITE → 100/180/200 → ACK → RTP → BYE.
- Observe a full call in Wireshark's "VoIP Calls" + flow sequence; identify each plane.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 3. Build (OSS)

- Minimal registrar/PBX with Asterisk (`pjsip.conf` endpoint + auth + aor).
- Two clients (Linphone GUI, Baresip CLI) register and call; inspect CLI (`pjsip show endpoints`).

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 4. Attack / Defend

- Attack-surface enumeration as a mindset: what an attacker sees at each hop (open ports,
- Threats introduced here (detailed later): scanning (T1), enumeration (T2), eavesdropping (T5),

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 5. Labs

- **Lab 1.1:** Register two clients, place a call, annotate the flow (label every message/plane).
- **Lab 1.2:** Passive recon of *your own* PBX with `nmap`/OPTIONS; record the banner/leaked info.
- **Lab 1.3:** Start the living threat model: list assets, entry points, trust boundaries.
- *Rubric:* correct plane labeling; accurate entity identification; first threat model committed.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## Lab & assessment

- Hands-on lab with a fail-closed `verify.sh`; rubric 100 pts, pass ≥ 70.
- Update your living threat model + hardening checklist.

<!-- Speaker note: point learners at lab/labs/<module>/. -->
