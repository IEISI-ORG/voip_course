---
marp: true
theme: default
paginate: true
title: Module 1 — VoIP & SIP Foundations
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Module 1 — VoIP & SIP Foundations

**What VoIP is, where SIP fits, and the attack surface you're signing up to defend.**

`Est. 3h` · Prereqs: Module 0, TCP/IP

<!--
Speaker: This is the conceptual foundation for everything. Two ideas must land today: (1) signaling
and media are separate planes, and (2) a SIP call touches many entities, each of which is attack
surface. Keep it concrete — we place a real call and read it in Wireshark before the hour is out.
-->

---

## What you'll leave with

- The VoIP call model: **signaling vs. media**, and why they're split.
- The SIP cast of characters: UAC, UAS, registrar, proxy, redirect, B2BUA, SBC.
- SIP addressing: URIs, **AoR vs. Contact**.
- A first map of the **end-to-end attack surface** of one call.

<!--
Speaker: Preview the arc. By the end they should be able to point at any hop in a call and say what
lives there and what an attacker sees there. That "attacker's-eye view" is the habit the whole
course reinforces.
-->

---

## Two planes: signaling and media

- **Signaling plane = SIP** — set up, modify, tear down calls. Text, HTTP-like.
- **Media plane = RTP** — the actual audio/video, usually a *separate* UDP flow.
- They travel different paths and are secured by different mechanisms (TLS vs. SRTP).

> A call can have perfect signaling and wide-open media — or vice versa. Two planes, two problems.

<!--
Speaker: This split is the single most important idea in the module. It's *why* we later need both
SIPS/TLS (signaling) AND SRTP (media) — securing one does nothing for the other. Foreshadow modules
11 and 12. Ask: if you encrypt SIP but not RTP, what can an eavesdropper still do? (Hear the call.)
-->

---

## Where SIP sits

- Application layer over **UDP / TCP / TLS / WS(S)**.
- **HTTP heritage:** requests, responses, headers, status codes — familiar shapes.
- SIP is a **toolkit of extensions**, not one spec: RFC 3261 is the core, then a large "beyond
  3261" family (IETF working groups).

<!--
Speaker: The HTTP resemblance helps people who know the web. But warn them: SIP's extension sprawl
means "compliant" implementations still differ — that's where interop bugs and parser
vulnerabilities live (module 18, module 14-threats). SIP is a family, not a monolith.
-->

---

## The SIP cast of characters

- **UAC / UAS** — the endpoints (a phone is both).
- **Registrar + Location Service** — binds *who you are* to *where you are*.
- **Proxy** (stateful / stateless) — routes requests.
- **Redirect server** — tells you where to go instead of forwarding.
- **B2BUA / SBC** — sits in the middle of *both* legs; the control/enforcement point.

<!--
Speaker: The B2BUA/SBC is the one to dwell on — it breaks the call into two legs and can see/modify
everything. That's exactly why it's our security enforcement point later (topology hiding, mTLS
trunks, flood control). Every entity here is a trust boundary.
-->

---

## Addressing: AoR vs. Contact

- **SIP / SIPS URI:** `sip:alice@example.com` — an *identity* (Address of Record).
- **Contact:** where that identity is *actually reachable right now* (a device/IP:port).
- **Registration binds AoR → Contact.** That binding is a security-sensitive act.

<!--
Speaker: The AoR-vs-Contact distinction trips everyone up first. AoR = the phone number/identity;
Contact = the specific device. REGISTER creates the mapping. Ask them to hold the question: if an
attacker can forge a registration, what happens? (They hijack your calls — module 13.)
-->

---

## Packet reality: a call at 10,000 ft

```
REGISTER  →  (bind AoR→Contact)
INVITE    →  100 Trying → 180 Ringing → 200 OK
ACK       →  ── RTP media flows ──  →  BYE
```

- Open Wireshark → **VoIP Calls** → flow sequence; label each message and its plane.

<!--
Speaker: Run this live. Have them identify: which messages are signaling, where media starts, and
the three-way INVITE/200/ACK handshake. Point out RTP is a *different* flow on different ports —
back to the two-plane idea. This is their first real capture reading.
-->

---

## Build: a minimal PBX

- Asterisk **PJSIP**: an endpoint + auth + AoR (`pjsip.conf`).
- Two clients register and call: **Linphone** (GUI), **Baresip** (CLI).
- Inspect from the CLI: `pjsip show endpoints`, `pjsip show aors`.

<!--
Speaker: Keep the config minimal — one endpoint, one auth, one aor. The goal is a working call they
built themselves, plus seeing the registrar's state on the CLI. Resist configuring security yet;
that's the point of the modules ahead. Get a call up.
-->

---

## Attack / Defend: the attacker's-eye view

- At each hop an attacker sees: **open ports, UA banners, response codes, media ports.**
- Threats introduced here (detailed later): scanning **(T1)**, enumeration **(T2)**,
  eavesdropping **(T5)**, spoofing **(T7)**.
- Start your **living threat model** now — it grows every module.

<!--
Speaker: Introduce the threat catalog IDs (T1, T2, T5, T7) — they'll recur all course. The living
threat model is a deliverable that accumulates: assets, entry points, trust boundaries. Framing:
you can't defend a surface you haven't enumerated. This is where defensive discipline begins.
-->

---

## Labs

- **Lab 1.1** — Register two clients, place a call, annotate the flow (label every message + plane).
- **Lab 1.2** — Passive recon of *your own* PBX with `nmap` / OPTIONS; record banner/leaked info.
- **Lab 1.3** — Start the living threat model: assets, entry points, trust boundaries.

*Rubric:* correct plane labeling · accurate entity identification · first threat model committed.

<!--
Speaker: 1.2 is their first (authorized, self-targeted) recon — reinforce the rules of engagement
from Module 0. The banner leak they find becomes motivation for hardening later. 1.3 is the artifact
they'll carry to the capstone.
-->

---

## Takeaways & quick check

- **Two planes** (SIP + RTP) — secure both, or you've secured neither.
- Every SIP entity is a **trust boundary**.
- Registration **binds identity to location** — protect it.

**Check:** Distinguish AoR from Contact — why does registration bind them? Which entity breaks
end-to-end signaling identity? Name three things a default SIP UA response leaks.

<!--
Speaker: Answers — AoR is identity, Contact is current location, REGISTER binds them so calls route
to your device; the B2BUA/SBC terminates and re-originates signaling, breaking end-to-end identity
(why STIR/SHAKEN exists); default responses leak UA/version banner, valid-vs-invalid user via status
codes, and supported methods/transports. Good bridge to Module 2's message deep-dive.
-->
