---
marp: true
theme: default
paginate: true
title: Module 15 — VoIP Threats & Offensive Testing (Authorized)
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Module 15 — VoIP Threats & Offensive Testing

**Think like an attacker — run a disciplined, authorized red-team assessment against your own platform.**

`Est. 5h` · Prereqs: Modules 1–12

> **Authorized-use rule (restated every lab):** all offensive tooling targets **only** the VoIPSec
> lab on `edge`/`redteam`. Testing systems you don't own or lack written authorization for is
> **illegal**.

<!--
Speaker: Open with the rules of engagement, out loud, every time — this is the ethics gate from
Module 0 made operational. The whole module is "attack your own lab to understand defense." The
deliverable is a real findings report that drives the M16 hardening. Offense in service of defense.
-->

---

## What you'll leave with

- Run a **structured assessment**: recon → enumeration → exploitation → impact.
- Use **SIPVicious, SIPp, fuzzers** to demonstrate real weaknesses.
- Produce **findings that drive the M16 hardening** — with evidence.

<!--
Speaker: The exam asks them to order the phases and state each goal. Emphasise structure over
"hacking": a methodology you can repeat and document beats ad-hoc poking. Every finding must carry
evidence (a pcap) and a mapped remediation.
-->

---

## Methodology

**Scope & authorize → recon → enumeration → credential attacks → service/DoS → media → fuzzing → reporting.**

- Mirrors **PTES / OWASP / NIST SP 800-115**, adapted to SIP.
- Scope and authorization come **first**, always.

<!--
Speaker: Walk the phases as a pipeline — each feeds the next (recon finds hosts, enumeration finds
users, credential attacks use those users). Anchor to the recognised frameworks so it's a real
assessment methodology, not a script kiddie checklist. Reporting is a phase, not an afterthought.
-->

---

## The threat taxonomy (T1–T15)

- Scanning (T1) · enumeration (T2) · brute force (T3) · toll fraud (T4) · eavesdropping (T5) ·
  MITM (T6) · spoofing (T7) · DoS/flood (T8) · RTP injection (T9) · fuzzing/parser (T10) ·
  secret leak (T11) · trunk abuse (T12) · feature abuse (T13) · recording exposure (T14) ·
  provisioning abuse (T15).
- Rooted in the **VoIPSA threat taxonomy** (2005); surveyed by **Keromytis (IEEE COMST 2012)**.

<!--
Speaker: This catalog has run through every module — now they attack across all of it. Keromytis's
survey of 245 papers found implementation flaws dominate over protocol flaws, which is why this
module tests real deployments, not specs. VoIPSA gives the academic backbone for the T-numbers.
-->

---

## The toolkit

- **SIPVicious OSS:** `svmap` (discovery), `svwar` (extension war-dial), `svcrack` (password crack).
- **SIPp:** floods, malformed messages, custom scenarios.
- **nmap** SIP scripts, simple fuzzers, RTP injection tools.
- **Real breaches:** default creds, open dialplans, exposed 5060, weak PINs, IP-only trunks.

<!--
Speaker: These map one-to-one to earlier defenses: svmap↔topology hiding, svwar↔enumeration defense
(M13), svcrack↔strong secrets/lockout, floods↔pike/nftables. The "real breaches" list is sobering —
almost every actual VoIP breach is a config default someone never changed, not a novel exploit.
-->

---

## Packet reality

- Capture and **fingerprint each attack's signature** — what svmap / svwar / floods look like on the
  wire and in HOMER.
- This is the **detection training for M17**.

<!--
Speaker: Key discipline: capture the signature *while you attack*, because you're the one who knows
exactly what you did. Those signatures become the detection rules in M17 (Lab 15.2). Attacking with a
capture running is how offense feeds monitoring.
-->

---

## Build & Attack (authorized, in-lab)

- Configure the `redteam` container; **verify fencing** (reaches `edge`, not `core`).
- **Recon (T1):** svmap the edge; fingerprint UAs. **Enum (T2):** svwar; watch response deltas.
- **Credentials (T3):** svcrack a weak secret; show a strong one resisting.
- **DoS (T8):** SIPp flood; measure impact with/without `pike`+nftables.
- **Fuzzing (T10):** RFC 4475 torture + mutation → assert **no crash, correct 4xx**.
- **Media (T5/T9)** + **toll-fraud (T4):** sniff/inject; attempt premium dialing → guardrails block.

<!--
Speaker: Every attack is paired with the defense that stops it — that pairing is the pedagogy. The
fencing check first (redteam can't reach core) is the safety proof. RFC 4475 torture is the parser
robustness test: a single malformed message must never crash a border element — assert clean 4xx
rejections, no hangs.
-->

---

## Reporting is a phase, not an afterthought

- Each finding: **severity + evidence pcap + reproduction + mapped defense**.
- Separate **config** weaknesses (change a setting) from **protocol** weaknesses (design/mitigate).
- The report is the **input to M16 hardening**.

<!--
Speaker: A finding without evidence and a reproduction is an opinion. The config-vs-protocol
distinction (an exam question) changes the fix: config flaws you just correct; protocol flaws you
mitigate with controls (rate limits, policy) because you can't change the RFC. This report is a real
deliverable they carry to the capstone.
-->

---

## Labs / Deliverable

- **Lab 15.1** — Full authorized assessment; produce a **findings report** (severity, evidence pcap,
  reproduction, mapped defense).
- **Lab 15.2** — For each finding, **capture its detection signature** for M17.

*Rubric:* methodology followed · each finding has evidence + concrete remediation · authorized-use
respected · detection signatures captured.

<!--
Speaker: 15.1 is the module's spine — a structured, evidence-backed assessment of their own platform.
15.2 is the bridge to monitoring: every attack they ran becomes a detection signature. An ethics-gate
reminder: an assessment that ignores scope fails regardless of technical quality.
-->

---

## Takeaways & quick check

- **Authorization first** — scope is not optional; ethics gate is absolute.
- **Offense feeds defense** — capture signatures while attacking.
- **Most breaches are config defaults**, not novel exploits.

**Check:** Order the assessment phases and each goal. Which findings are "config" vs. "protocol", and
how does that change the fix? Why capture attack signatures during offense, not only defense?

<!--
Speaker: Answers — scope/authorize → recon → enumeration → credential → service/DoS → media →
fuzzing → reporting, each narrowing toward impact. Config findings are fixed by changing a setting;
protocol findings are mitigated by controls since you can't rewrite the standard. Capture during
offense because the attacker (you) has ground truth of exactly what the signature looks like — those
become M17's detection rules. Next: Defense, Hardening & Fraud Prevention (M16).
-->
