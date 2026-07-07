---
marp: true
theme: default
paginate: true
title: Module 19 — Frontiers: VoLTE/IMS, Fax over IP, ENUM/Peering, UC/UCaaS/CPaaS
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Module 19 — Frontiers

**Where SIP goes beyond the PBX — mobile core, fax, inter-carrier routing, unified comms.**

`Est. 5h` · Prereqs: M1–17 · **Checkpoint exam #3 (operations) after this module**

<!--
Speaker: The victory lap — SIP everywhere it lives beyond the enterprise PBX. Each frontier reuses
the security lessons of the whole course in a new setting: mobile (IMS/VoWiFi), fax (T.38), carrier
peering, and browser/API comms. Gate for checkpoint #3. Breadth over depth here — connect, don't
drown.
-->

---

## What you'll leave with

- Explain SIP's role in **IMS/VoLTE/VoNR** and inter-carrier peering trust.
- Deploy **Fax over IP (T.38)** and troubleshoot it.
- Understand **ENUM/peering** routing and **UC/UCaaS/CPaaS** architectures and their risks.

<!--
Speaker: Exam #3 is operations-flavoured. Themes: where SIP sits in IMS + what P-CSCF does, why T.38
exists, and the top CPaaS security control. Keep each frontier tied back to an earlier module's
control so it feels like reinforcement, not new material.
-->

---

## SIP in cellular (IMS / VoLTE / VoNR)

- IMS: **P-/I-/S-CSCF**, HSS, AS/TAS; SIP registration + call flow in IMS.
- VoLTE (LTE) / VoNR (5G); SIP **preconditions** (RFC 3312), codecs (AMR/EVS); GSMA IR.92/IR.94.
- IPX peering, SIP over secured bearers, the operator trust model.

<!--
Speaker: The P-CSCF is the SIP entry point into the IMS core (the mobile SBC, essentially) — that's
the exam answer. Preconditions ensure the bearer/QoS is ready before the phone rings (no "answered
but no media"). IR.92/94 are the carrier profiles. This is the SBC/trust-boundary story at carrier
scale.
-->

---

## VoWiFi — a real-world weak point

- IMS over **untrusted Wi-Fi** via **IPsec/IKEv2** tunnels to the operator's **ePDG**
  (GSMA IR.51; roaming IR.61).
- Security rests on the **IKE key exchange**.
- **Peer-reviewed finding** (Gegenhuber et al., USENIX Security 2024): **13 operators (~140M users)**
  used weak/deprecated DH groups, downgradeable → MITM.

<!--
Speaker: This is the module's headline security lesson and it's recent + peer-reviewed. VoWiFi carries
your calls over any Wi-Fi via an IPsec tunnel to the ePDG — and the crypto-agility failure this course
warns about (M11) showed up in real commercial networks at 140M-user scale. Lesson: mandate strong IKE
groups, reject downgrade. Same failure mode, carrier stakes.
-->

---

## Fax over IP & ENUM/peering

- **FoIP:** why fax breaks on VoIP (T.30 timing vs. loss); G.711 pass-through vs. **T.38 relay**;
  UDPTL; re-INVITE to switch to fax.
- **ENUM:** E.164 → **NAPTR (RFC 6116)** → SIP URI; public vs. private/carrier ENUM.
- **Peering:** bilateral/multilateral, **IP-NNI** (ATIS/SIP Forum); staying "on-net"; carrier trust.

<!--
Speaker: T.38 exists because fax's strict T.30 timing can't survive packet loss as audio — it relays
the fax as data instead (exam answer). ENUM is DNS again (M10) — E.164 numbers mapped to SIP URIs via
NAPTR; private/carrier ENUM keeps routing on-net. Peering trust is the STIR/SHAKEN + screening story
between carriers.
-->

---

## UC / UCaaS / CPaaS

- Presence (SUBSCRIBE/NOTIFY, PIDF), IM (MESSAGE), conferencing (focus, REFER), BLF.
- **CPaaS** wraps SIP behind **HTTP/REST APIs** (programmable telephony, IVR, click-to-call).
- **WebRTC** UC: browser-to-PSTN as first-class (signaling M11, media M12).

<!--
Speaker: CPaaS is SIP behind an HTTP API — which means your telephony attack surface is now a web API
too. That's the pivot: an exposed origination API is a toll-fraud/robocall vector. WebRTC UC brings
the M11/M12 secure-transport work into the browser. Presence/conferencing are features with their own
abuse surfaces.
-->

---

## Attack / Defend across the frontiers

- **IMS/peering trust (T7/T12):** spoofing across peers, IPX assumptions → STIR/SHAKEN, IR.92
  security, **NNI screening**.
- **Fax:** T.38 usually unencrypted → transport protection (TLS/IPsec); fax carries PII/PHI.
- **CPaaS/API risk:** exposed origination APIs → **API auth, rate limits, per-key spend caps**,
  STIR/SHAKEN attestation obligations.
- **ENUM/DNS poisoning:** route hijack → **DNSSEC**, private-ENUM trust.

<!--
Speaker: Every frontier maps to a control they already built: peering→STIR/SHAKEN (M13), fax→transport
crypto (M11/M12), CPaaS→spend caps + auth (M9/M16), ENUM→DNSSEC (M10). The top CPaaS control (exam) is
API auth + rate + per-key spend cap — it's the toll-fraud backstop wearing a REST hat. NG911 with
PIDF-LO location (M9) also lives here.
-->

---

## Packet reality & build

- Read an **IMS registration + VoLTE INVITE** with preconditions (provided trace).
- Capture a **T.38 switch** (audio → re-INVITE → image/UDPTL); resolve an **ENUM NAPTR** with `dig`.
- **Build:** T.38 fax between Asterisk/spandsp endpoints through the SBC; **private ENUM in BIND**;
  presence/BLF; a minimal **CPaaS-style REST trigger** (ARI/ESL).

<!--
Speaker: The T.38 capture (audio then re-INVITE to image/UDPTL) makes the fax switch concrete. Private
ENUM in BIND reuses the M10 DNS skills. The CPaaS REST trigger is their first "telephony behind an API"
— and the hook to secure that API. Breadth: touch each frontier hands-on.
-->

---

## Labs / Deliverable

- **Lab 19.1** — Working **T.38 fax** through the SBC; diagnose one induced failure.
- **Lab 19.2** — **Private-ENUM** routing + presence between endpoints.
- **Lab 19.3 (security)** — Secure a **CPaaS-style origination API** (auth + rate + spend cap); show
  an abusive caller blocked.

*Rubric:* fax completes + troubleshooting shown · ENUM routing works · API abuse contained.

<!--
Speaker: 19.3 is the security keystone and a satisfying full-circle: the toll-fraud controls from M9/
M16 applied to a modern REST origination API. Blocking the abusive caller with auth + rate + spend cap
proves the principle transfers from SIP trunks to HTTP APIs. This is checkpoint-#3 material.
-->

---

## Takeaways & quick check

- **New surfaces, same principles** — peering→STIR/SHAKEN, fax→crypto, CPaaS→caps, ENUM→DNSSEC.
- **VoWiFi is real crypto-agility risk** at carrier scale — mandate strong IKE, reject downgrade.
- **CPaaS = SIP behind a web API** — secure the API like any other.

**Check:** Where does SIP sit in IMS, and what does the P-CSCF do? Why does T.38 exist instead of
G.711 fax? Top security control a CPaaS provider must enforce, and why?

<!--
Speaker: Answers — SIP is the IMS signaling protocol; the P-CSCF is the first contact point / proxy
into the IMS core (the mobile-network SBC). T.38 relays fax as timing-tolerant data because T.30's
strict timing can't survive packet loss when sent as G.711 audio. Top CPaaS control: strong API
authentication + rate limiting + per-key spend caps (plus STIR/SHAKEN attestation) — an exposed
origination API is a toll-fraud/robocall vector. That's checkpoint #3 — next and last: the Capstone.
-->
