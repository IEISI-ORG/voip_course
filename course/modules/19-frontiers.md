# Module 19 — Frontiers: VoLTE/IMS, Fax over IP, ENUM/Peering, UC/UCaaS/CPaaS

**One-liner:** Where SIP goes beyond the PBX — mobile core, fax, inter-carrier routing, and
unified communications — with the security caveats of each. **Est. time:** 5h · **Prereqs:** M1–17.
**Checkpoint exam #3 (operations) after this module.**

## Learning Objectives
- Explain SIP's role in IMS/VoLTE/VoNR and the trust model of inter-carrier peering.
- Deploy Fax over IP (T.38) and troubleshoot it.
- Understand ENUM/peering routing and UC/UCaaS/CPaaS architectures and their risks.

## 1. Concept

### 1a. SIP in Cellular (IMS / VoLTE / VoNR)
- IMS architecture: P-/I-/S-CSCF, HSS, AS/TAS, PCSCF; SIP registration in IMS; call flow.
- VoLTE (LTE/EPC) and VoNR (5G) media; SIP preconditions (RFC 3312) and codec (AMR/EVS);
  GSMA IR.92/IR.94 profiles; the OTT-vs-carrier tension; RCS.
- **VoWiFi (Wi-Fi calling):** IMS carried over untrusted Wi-Fi via IPsec/IKEv2 tunnels to the
  operator's **ePDG** (GSMA **IR.51**; roaming IR.61). The whole security of the call rests on that
  IKE key exchange — and it's a real-world weak point: a peer-reviewed measurement of commercial
  deployments (Gegenhuber et al., **USENIX Security 2024** — [bib §11](../references/bibliography.md))
  found **13 operators (~140M users)** using weak/deprecated Diffie-Hellman groups that are
  downgradeable to breakable, leaving VoWiFi setups susceptible to MITM. Lesson: mandate strong IKE
  groups + reject downgrade (the crypto-agility failure this course warns about in M11).
- Security/trust: IPX peering, SIP over secured bearers, the operator trust model.

### 1b. Fax over IP
- Why fax breaks on VoIP (T.30 timing vs. packet loss); G.711 pass-through vs. **T.38 relay** vs.
  T.37 store-and-forward; UDPTL; SDP for T.38; SIP re-INVITE to switch to fax.
- Troubleshooting FoIP (jitter, ECM, gateway timing).

### 1c. ENUM, Peering & Interconnect
- E.164 → NAPTR (RFC 6116) → SIP URI; public vs. private/carrier ENUM (e164.arpa); DNS role.
- Peering models (bilateral/multilateral), IP-NNI (ATIS/SIP Forum), staying "on-net," feature
  loss via the PSTN; trust and routing between carriers.

### 1d. UC / UCaaS / CPaaS
- Presence (SIP SUBSCRIBE/NOTIFY, PIDF, SIMPLE), IM (MESSAGE), conferencing (focus, REFER,
  centralized mixing), BLF; UC vs. UCaaS vs. CPaaS; REST APIs and programmable telephony (IVR,
  click-to-call) — how CPaaS wraps SIP behind HTTP APIs.

## 2. Packet Reality
- Read an IMS registration + VoLTE INVITE with preconditions (from a provided trace).
- Capture a T.38 switch (audio → re-INVITE → image/UDPTL).
- Resolve an ENUM NAPTR with `dig`; read presence PIDF in a NOTIFY.

## 3. Build (OSS)
- T.38 fax between two Asterisk/spandsp endpoints through the SBC; force a fax call and capture.
- Private ENUM in BIND (NAPTR records); route a call via ENUM lookup in Kamailio.
- Presence/BLF between two endpoints; a minimal CPaaS-style REST trigger to originate a call (ARI/ESL).
- (Optional) Kamailio IMS modules overview for a lab IMS registrar.

## 4. Attack / Defend
- **IMS/peering trust (T7/T12):** spoofing across peers, IPX trust assumptions → STIR/SHAKEN,
  IR.92 security, screening at NNI.
- **Fax security:** T.38 usually unencrypted → transport protection (TLS/IPsec) on the fax path;
  fax often carries sensitive data (PII/PHI).
- **CPaaS/API risk:** exposed origination APIs = toll-fraud/robocall vector → API auth, rate
  limits, per-key spend caps, STIR/SHAKEN attestation obligations for programmatic senders.
- **ENUM/DNS poisoning:** route hijack via DNS → DNSSEC, private ENUM trust.
- Final threat-model update covering the frontier surfaces.

## 5. Labs / Deliverable
- **Lab 19.1:** Working T.38 fax through the SBC; diagnose one induced failure.
- **Lab 19.2:** Private-ENUM routing + presence between endpoints.
- **Lab 19.3 (security):** Secure a CPaaS-style origination API (auth + rate + spend cap) and show
  an abusive caller blocked.
- *Rubric:* fax completes + troubleshooting shown; ENUM routing works; API abuse contained.

## Assessment / Checkpoint Exam #3 (operations)
- Where does SIP sit in the IMS, and what does the P-CSCF do?
- Why does T.38 exist instead of sending fax as G.711, and what still goes wrong?
- Name the top security control a CPaaS provider must enforce and why.

## Curriculum addition — WebRTC UC & NG911 as frontier compliance (review: gemini_feedback0)

The frontier is where browser-native comms and modern emergency services converge — both add
security/compliance surface that ties the earlier modules together.
- **WebRTC unified comms:** browser-to-PSTN as a first-class path (signaling M11, media M12);
  discuss SFU/MCU trust boundaries and end-to-end vs hop-by-hop media encryption.
- **NG911 / i3:** IP-based emergency services with PIDF-LO location (from M9), ESInet trust,
  and priority handling; contrast legacy E911.
- **Lab hook (capstone-linked):** a browser client places a secure call that traverses the
  SBC to the simulated PSTN carrying dispatchable location — exercising WebRTC media bridging,
  STIR/SHAKEN identity, and emergency-location delivery in one flow.

## References
- 3GPP TS 24.229 (IMS), GSMA IR.92/IR.94, **IR.51/IR.61 (VoWiFi)**, RFC 3312 (preconditions);
  Gegenhuber et al. (USENIX Sec '24, VoWiFi key exchange) — see [bibliography §11/§11d](../references/bibliography.md); ITU T.38/T.30, RFC 6913;
  RFC 6116 (ENUM), ATIS/SIP Forum IP-NNI; RFC 3856/3863 (presence/PIDF), 3515 (REFER);
  Asterisk ARI / FreeSWITCH ESL docs.
