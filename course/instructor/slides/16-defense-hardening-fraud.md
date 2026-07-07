---
marp: true
theme: default
paginate: true
title: Module 16 — Defense, Hardening & Fraud Prevention
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Module 16 — Defense, Hardening & Fraud Prevention

**Turn the M15 findings into a hardened platform, and stop toll fraud before it drains a budget.**

`Est. 6h` · Prereqs: Module 15

<!--
Speaker: M15 attacked; now we defend — and prove it by replaying those exact attacks and watching
them fail. This module consolidates every hardening thread from the whole course into one checklist,
then adds the money defense: toll-fraud prevention. The tone shifts from "here's a control" to
"here's the complete, layered baseline."
-->

---

## What you'll leave with

- Apply a **complete, layered hardening baseline** across endpoints → PBX → proxy/SBC → edge.
- Design **toll-fraud prevention** (limits, allowlists, anomaly detection).
- Automate **brute-force/scan defense** and validate it against the M15 attacks.

<!--
Speaker: Exam favourites: the single most cost-effective toll-fraud control, and why uniform error
responses + rate limiting beat either alone. Keep "validate against real attacks" central — a control
you haven't tested against the attack is a hope, not a defense.
-->

---

## Defense-in-depth layers

`edge` (nftables/geo/rate) → **SBC** (topology hiding, admission, `pike`) → **proxy** (auth, routing
policy) → **PBX** (secure defaults, class-of-service) → **app** (voicemail/feature) → **data**
(secrets, recordings, CDR) → **monitoring** (M17).

<!--
Speaker: Each layer is a module they already built — this slide is the assembly. No single layer is
trusted alone: the edge drops scanners, the SBC throttles, the proxy authenticates, the PBX limits
class-of-service, and monitoring catches what leaks through. Defense-in-depth means an attacker must
beat all of them.
-->

---

## The consolidated hardening baseline

- **Transport:** TLS/SIPS only externally; drop plaintext 5060; SRTP-only media.
- **Identity:** SHA-256 digest, no guest, **uniform error responses**.
- **Routing:** From-domain + destination allowlists; no open relay; loop protection.
- **Class-of-service:** per-account destination + concurrent-call + velocity caps.
- **Secrets (T11):** perms, vault/env, rotation; **HTTPS+mTLS provisioning, signed configs (T15)**.
- **Feature abuse (T13):** PIN policy, disable DISA, restrict `Dial`.

<!--
Speaker: This is the hardening checklist v-final — every item maps to a T# it mitigates (Lab 16.1).
It's the single most reusable artifact in the course; they carry it to the capstone and to real jobs.
Walk it as a checklist, not prose — that's how it gets used.
-->

---

## Toll fraud / IRSF (T4) — the money attack

- **How:** compromised creds → premium/international dialing at scale, often **off-hours**.
- **Why:** International Revenue Share Fraud — the attacker *owns* the premium number and gets paid.
- It's a business model, which is why it's relentless and automated.

<!--
Speaker: Make the money model explicit — this isn't vandalism, the attacker literally earns revenue
per minute you're billed. That's why it runs at 3am on weekends and dials obscure premium ranges.
Understanding the economics tells you where to put controls: bound the minutes and the spend.
-->

---

## Fraud controls

- **Destination allow/deny** — block high-risk premium ranges by default.
- **Per-account spend + concurrency + time-of-day** limits.
- **Velocity / anomaly detection on CDRs**; **hard spend caps**.
- **Real-time alerting + auto-suspend.**

<!--
Speaker: The single most cost-effective control (exam answer): a hard spend/velocity cap — it bounds
the loss regardless of how the breach happened. Everything else reduces probability; the cap bounds
impact. Defense-in-depth for fraud = reduce likelihood (allowlists, auth) AND bound loss (caps).
-->

---

## Brute-force & scan defense

- **fail2ban** jails (auth-failure + scan patterns) · **`pike`** · nftables rate limits.
- CrowdSec-style reputation; lockout/backoff.
- **SIP honeypot:** decoy on UDP 5060 (real service on SIPS 5061) → any hit auto-bans the source.

<!--
Speaker: The honeypot is elegant: nobody legitimate ever touches a decoy 5060 listener, so every hit
is a confirmed bad actor you can block *pre-emptively*, before it reaches the real service. Combined
with fail2ban + pike, it turns reconnaissance into a free, high-confidence blocklist (feeds M17).
-->

---

## Provisioning & recording compliance

- **Secure provisioning (T15):** HTTPS + mTLS, per-device certs/MAC-bound, signed configs, allowlist
  — no creds in world-readable files (deep-dived in M14).
- **Recording (PCI-DSS, T14):** encrypt at rest, RBAC + access logging, retention limits, **DTMF
  suppression / pause-resume** so spoken/keyed card numbers are never captured.

<!--
Speaker: Two of the most common real breaches live in operations, not protocol. Provisioning is now
its own module (M14) — reference it. Recording + PCI is the compliance angle: a call recording with a
card number keyed during payment is a PAN in storage. DTMF masking during the payment segment is the
control; every access gets logged (audit continues in M17).
-->

---

## Packet reality & validation

- **Re-run every M15 attack signature** — show it dropped / banned / throttled in captures + logs.
- Tabletop: an account **is** compromised — what limits the loss? (spend cap, velocity, alerting).

<!--
Speaker: This is the proof phase and the module's satisfaction: the same svmap/svwar/flood/fraud
attacks from M15, now defeated on camera. The tabletop matters — assume prevention failed and show the
loss is still bounded. That "assume breach" mindset is what separates hardening from wishful thinking.
-->

---

## Labs / Deliverable

- **Lab 16.1** — Apply + commit the **hardening checklist v-final**; map each item to its T#.
- **Lab 16.2** — Build fraud detection + **auto-suspend**; simulate an IRSF pattern, show it caught
  and **contained within a spend cap**.
- **Lab 16.3** — Re-run the M15 assessment; produce a **before/after findings delta**.

*Rubric:* layered baseline applied with evidence · fraud pattern detected + contained · measurable
reduction in exploitable findings.

<!--
Speaker: 16.3's before/after delta is the money metric — a measurable drop in exploitable findings
proves the hardening worked. 16.2's contained-within-a-spend-cap is the toll-fraud win. These
deliverables are exactly what a real security review would ask for.
-->

---

## Takeaways & quick check

- **Defense-in-depth:** every layer, validated against the real attack.
- **Bound the loss** with a hard spend/velocity cap — the top toll-fraud control.
- **Uniform responses + rate limiting** together: no info leak *and* no cheap retries.

**Check:** Single most cost-effective control against toll fraud, and why? Why do uniform error
responses + rate limiting beat either alone? What makes auto-provisioning a supply-chain risk, and how
do you close it?

<!--
Speaker: Answers — a hard spend/velocity cap bounds loss regardless of breach path. Uniform responses
stop enumeration (no info leak) while rate limiting stops brute force (no cheap retries) — each closes
a gap the other leaves open. Auto-provisioning is a supply-chain risk because a compromised
provisioning server or RPS account repoints the whole fleet; close it with mTLS + signed configs +
per-device scoping (M14). Next: Monitoring, Observability & Incident Response (M17).
-->
