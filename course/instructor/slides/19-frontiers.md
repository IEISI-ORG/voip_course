---
marp: true
theme: default
paginate: true
title: Module 19 — Frontiers: VoLTE/IMS, Fax over IP, ENUM/Peering, UC/UCaaS/CPaaS
---

# Module 19 — Frontiers: VoLTE/IMS, Fax over IP, ENUM/Peering, UC/UCaaS/CPaaS

Where SIP goes beyond the PBX — mobile core, fax, inter-carrier routing, and unified communications — with the security caveats of each.

<!-- Instructor: set the scene; ~30 min. Every module ends with a hands-on lab + fail-closed verify.sh. -->
---

## Learning Objectives

- Explain SIP's role in IMS/VoLTE/VoNR and the trust model of inter-carrier peering.
- Deploy Fax over IP (T.38) and troubleshoot it.
- Understand ENUM/peering routing and UC/UCaaS/CPaaS architectures and their risks.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 1. Concept

- IMS architecture: P-/I-/S-CSCF, HSS, AS/TAS, PCSCF; SIP registration in IMS; call flow.
- VoLTE (LTE/EPC) and VoNR (5G) media; SIP preconditions (RFC 3312) and codec (AMR/EVS);
- **VoWiFi (Wi-Fi calling):** IMS carried over untrusted Wi-Fi via IPsec/IKEv2 tunnels to the
- Security/trust: IPX peering, SIP over secured bearers, the operator trust model.
- Why fax breaks on VoIP (T.30 timing vs. packet loss); G.711 pass-through vs. **T.38 relay** vs.
- Troubleshooting FoIP (jitter, ECM, gateway timing).

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 2. Packet Reality

- Read an IMS registration + VoLTE INVITE with preconditions (from a provided trace).
- Capture a T.38 switch (audio → re-INVITE → image/UDPTL).
- Resolve an ENUM NAPTR with `dig`; read presence PIDF in a NOTIFY.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 3. Build (OSS)

- T.38 fax between two Asterisk/spandsp endpoints through the SBC; force a fax call and capture.
- Private ENUM in BIND (NAPTR records); route a call via ENUM lookup in Kamailio.
- Presence/BLF between two endpoints; a minimal CPaaS-style REST trigger to originate a call (ARI/ESL).
- (Optional) Kamailio IMS modules overview for a lab IMS registrar.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 4. Attack / Defend

- **IMS/peering trust (T7/T12):** spoofing across peers, IPX trust assumptions → STIR/SHAKEN,
- **Fax security:** T.38 usually unencrypted → transport protection (TLS/IPsec) on the fax path;
- **CPaaS/API risk:** exposed origination APIs = toll-fraud/robocall vector → API auth, rate
- **ENUM/DNS poisoning:** route hijack via DNS → DNSSEC, private ENUM trust.
- Final threat-model update covering the frontier surfaces.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 5. Labs / Deliverable

- **Lab 19.1:** Working T.38 fax through the SBC; diagnose one induced failure.
- **Lab 19.2:** Private-ENUM routing + presence between endpoints.
- **Lab 19.3 (security):** Secure a CPaaS-style origination API (auth + rate + spend cap) and show
- *Rubric:* fax completes + troubleshooting shown; ENUM routing works; API abuse contained.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## Lab & assessment

- Hands-on lab with a fail-closed `verify.sh`; rubric 100 pts, pass ≥ 70.
- Update your living threat model + hardening checklist.

<!-- Speaker note: point learners at lab/labs/<module>/. -->
