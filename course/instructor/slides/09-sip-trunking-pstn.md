---
marp: true
theme: default
paginate: true
title: Module 9 — SIP Trunking & the PSTN
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Module 9 — SIP Trunking & the PSTN

**Connect your platform to the outside world (ITSPs/PSTN) securely and reliably.**

`Est. 5h` · Prereqs: Modules 6–8

<!--
Speaker: The trunk is where your platform meets the money — and the risk. An open outbound path is
the classic toll-fraud loss event. Two threads today: make trunking work (inbound DID + outbound
PSTN, cause mapping) and harden it (spoofed peers, toll fraud, interception).
-->

---

## What you'll leave with

- Configure **SIP trunks** (registration and static/IP modes) to an ITSP/peer.
- Understand **PSTN interworking:** call flows, early media, DTMF, SIP-T/SIP-I, ISUP↔Q.850.
- Secure trunks against **spoofed peers, abuse, interception**.

<!--
Speaker: The exam's favourite: which single control most reduces toll-fraud blast radius (spend/
velocity limits + destination allowlists). Keep that answer in view all module.
-->

---

## SIP trunks

- Replaces TDM; **trunk vs. extension** registration.
- **Static / IP-auth** vs. **registration** mode.
- DID mapping, **E.164** number formats, CLI/CLIP.

<!--
Speaker: Static/IP-auth is convenient but authenticates only by source IP — forgeable. Registration
mode adds a credential. This trade (convenience vs. security) is the trunk-mode exam question. DID =
the inbound number → internal extension mapping.
-->

---

## PSTN interworking

- SIP↔PSTN call flows; gateways; **early vs. delayed offer**, early media, ringback.
- **Call-failure mapping: SIP ↔ Q.850** cause codes (RFC 3398).
- **SIP-T / SIP-I:** ISUP encapsulated across a SIP core (when carriers require it).

<!--
Speaker: Q.850 cause mapping is where PSTN troubleshooting lives — a SIP 486 maps to "user busy",
a 503 to congestion, etc. When something fails on the carrier side, the cause code tells you why.
SIP-T/SIP-I carry legacy ISUP intact for carriers that still need SS7 semantics — name it, don't
drown in it.
-->

---

## DTMF & trunk topologies

- **DTMF across trunks:** RFC 4733 events vs. inband vs. SIP INFO — negotiation mismatches break IVR.
- **Topologies:** single/multi-site, central vs. multiple SBCs, **least-cost routing**, DR/failover,
  elastic/bursting trunks.
- **Choosing an ITSP:** SIPconnect profile, interop checklist.

<!--
Speaker: The classic trunk bug: IVR digits don't register because two ends negotiated different DTMF
methods. Show the mismatch and the fix in the lab. LCR and failover are the operational levers;
SIPconnect is the interop baseline you test an ITSP against.
-->

---

## Packet reality

- Trace an **outbound PSTN call** and an **inbound DID**; map SIP responses to **Q.850** causes.
- Observe a **DTMF negotiation mismatch** (why IVR digits fail) and its fix.

<!--
Speaker: The cause-mapping exercise is Lab 9.2 — five failure responses to Q.850 causes from real
captures. This is the skill that makes carrier finger-pointing ("it's your side") resolvable with
evidence.
-->

---

## Build (OSS)

- Asterisk PJSIP trunk to a simulated ITSP (**`trunk-sim`**); inbound + outbound.
- Kamailio edge routing to the trunk with **dispatcher failover** + LCR-style selection.
- **DTMF interop matrix** across two endpoints/trunk.

<!--
Speaker: `trunk-sim` (SIPp/Asterisk) stands in for the carrier so they can break and fix trunking
safely. The failover + LCR piece reuses the dispatcher from M7. The DTMF matrix makes the negotiation
pitfalls concrete before they cost a support ticket.
-->

---

## Attack / Defend — the trunk is the money path

- **Spoofed-peer / trunk abuse (T12):** IP-auth-only is forgeable → require IP **+ TLS + digest**;
  pin peer certs; topology-hide toward the carrier.
- **Toll fraud (T4):** an open outbound path = classic loss → **destination allowlists, per-account
  spend/velocity limits, block premium ranges, alert** (M16/M17).
- **CLI/caller-ID spoofing inbound (T7):** don't trust From/PAI from the PSTN → **STIR/SHAKEN** (M13).

<!--
Speaker: Toll fraud is the headline: attackers dial premium/international numbers they own and bill
you. The single highest-leverage control is a spend/velocity cap — it bounds the loss even if
everything else fails. IP-only auth is forgeable; layer TLS + digest. Inbound caller-ID from the PSTN
is untrusted until STIR/SHAKEN verifies it.
-->

---

## Interception & the crypto-cost tradeoff

- Carrier links may be untrusted (**T6**) → **TLS/SIPS + SRTP** toward the ITSP where supported;
  IPsec/WireGuard overlay when not.
- **It isn't free:** Kolahi et al. (IEEE ICUFN 2017) measured **higher CPU + added delay** with IPsec
  on VoIP → **size the SBC/gateway** for crypto; often prefer per-hop TLS+SRTP over a blanket tunnel.

<!--
Speaker: This is the "security has a cost, budget for it" lesson backed by a peer-reviewed
measurement. IPsec everywhere sounds safe but adds CPU and latency; per-hop TLS+SRTP is often the
better-scaling choice. The point isn't "don't encrypt" — it's "measure and size", the engineering
maturity this course wants.
-->

---

## Labs

- **Lab 9.1** — Bidirectional trunking to `trunk-sim`; complete inbound DID + outbound PSTN.
- **Lab 9.2** — Map five SIP failure responses to **Q.850** causes from captures.
- **Lab 9.3 (security)** — Convert an IP-only trunk to **TLS + auth**; prove a spoofed source is
  rejected; add an outbound **destination allowlist + spend limit** and trigger the alert.

*Rubric:* working two-way trunk · correct cause mapping · hardened trunk with fraud guardrails.

<!--
Speaker: 9.3 is the toll-fraud defense made real — they harden a forgeable trunk and then watch their
own spend cap fire on a simulated fraud burst. That alert is the thing that saves a business a
five-figure bill. Emergency-calling content (Kari's Law / RAY BAUM'S / PIDF-LO) attaches here too —
route 911 without a prefix and carry dispatchable location.
-->

---

## Takeaways & quick check

- The trunk is the **money path** — cap spend/velocity, allowlist destinations.
- **IP-auth alone is forgeable** — add TLS + digest, pin certs.
- **Encryption has a measurable cost** — size for it, don't skip it.

**Check:** Registration vs. static trunk — trade-offs? Why is IP-only auth insufficient and what do
you add? Which single control most reduces toll-fraud blast radius?

<!--
Speaker: Answers — registration mode adds a credential + presence but needs the trunk to register/
re-register; static/IP mode is simpler but authenticates only by source IP; add TLS + digest + cert
pinning. The single best toll-fraud control is a per-account spend/velocity limit — it bounds loss
regardless of how the breach happened. Next: DNS infrastructure & resilience (M10).
-->
