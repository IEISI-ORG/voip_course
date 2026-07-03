---
marp: true
theme: default
paginate: true
title: Module 9 — SIP Trunking & the PSTN
---

# Module 9 — SIP Trunking & the PSTN

Connect your platform to the outside world (ITSPs/PSTN) securely and reliably.

<!-- Instructor: set the scene; ~30 min. Every module ends with a hands-on lab + fail-closed verify.sh. -->
---

## Learning Objectives

- Configure SIP trunks (registration and static/IP modes) to an ITSP/peer.
- Understand PSTN interworking: call flows, early media, DTMF, SIP-T/SIP-I, ISUP mapping.
- Secure trunks against spoofed peers, abuse, and interception.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 1. Concept

- **SIP trunks:** what replaces TDM; trunk vs. extension registration; static/IP-auth vs.
- **PSTN interworking:** SIP↔PSTN call flows, gateways, early media & early/delayed offer,
- **SIP-T / SIP-I:** ISUP encapsulation across a SIP core; SS7/ISDN↔SIP message and cause mapping;
- **DTMF across trunks:** RFC 4733 vs. inband vs. SIP INFO; negotiation pitfalls.
- **Trunk topologies:** single/multi-site, converged, central vs. multiple SBCs, least-cost
- **Choosing/validating an ITSP:** interop checklist, SIPconnect profile, what to test.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 2. Packet Reality

- Trace an outbound PSTN call and an inbound DID; map SIP responses to Q.850 causes.
- Observe DTMF negotiation mismatch (why IVR digits fail) and its fix.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 3. Build (OSS)

- Asterisk PJSIP trunk to a simulated ITSP (`trunk-sim` = SIPp/Asterisk peer); inbound + outbound.
- Kamailio edge routing to the trunk with dispatcher failover and LCR-style selection.
- DTMF interop matrix across two endpoints/trunk.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 4. Attack / Defend

- **Spoofed-peer / trunk abuse (T12):** IP-auth-only trunks are forgeable → require IP + TLS +
- **Toll fraud via trunk (T4):** an open outbound path is the classic loss event → destination
- **Interception on the trunk (T6):** carrier links may be untrusted → TLS/SIPS + SRTP toward
- **CLI/caller-ID spoofing inbound (T7):** don't trust From/PAI from the PSTN; verify via
- Update threat model with trunk/PSTN vectors.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 5. Labs

- **Lab 9.1:** Bring up bidirectional trunking to `trunk-sim`; complete inbound DID + outbound PSTN.
- **Lab 9.2:** Map five SIP failure responses to Q.850 causes from captures.
- **Lab 9.3 (security):** Convert an IP-only trunk to TLS + auth; prove a spoofed source is
- *Rubric:* working two-way trunk; correct cause mapping; hardened trunk with fraud guardrails.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## Lab & assessment

- Hands-on lab with a fail-closed `verify.sh`; rubric 100 pts, pass ≥ 70.
- Update your living threat model + hardening checklist.

<!-- Speaker note: point learners at lab/labs/<module>/. -->
