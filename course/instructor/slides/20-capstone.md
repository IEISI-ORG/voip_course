---
marp: true
theme: default
paginate: true
title: Capstone — Design, Deploy, Secure, Attack, Defend & Operate a VoIP Platform
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Capstone — Secure VoIP Platform

**Prove mastery: deliver a complete, hardened, observable VoIP platform and the artifacts to run it.**

`Est. 10h+` · Prereqs: all modules (0–19)

<!--
Speaker: This is where the whole course converges. There's no new material — the capstone is the
platform they've grown across 20 modules, taken to a production-grade, defensible state, then proven
under attack and operated through incidents. Set the tone: this is a portfolio piece, not a quiz.
Security is mandatory to pass.
-->

---

## The objective

- Take the platform grown across **Modules 0–19** to **production-grade, defensible** state.
- **Prove it** under authorized attack.
- **Operate it** through simulated incidents.

<!--
Speaker: Three verbs: harden, attack, operate. It's not enough to build securely — they must
demonstrate the security holds under their own red-team (M15 methodology) and that they can run the
platform through real incidents with runbooks. Design + proof + operations.
-->

---

## Deliverables (1–5)

1. **Architecture doc** — topology, trust boundaries, data flows, component rationale.
2. **Reproducible deployment** — one-command compose + IaC variant; parity; **secure CI**.
3. **Security implementation** — TLS/SIPS, SRTP/DTLS, SHA-256 digest, STIR/SHAKEN, topology hiding,
   edge firewall + rate limits + fail2ban, toll-fraud controls.
4. **Living threat model (final)** — every threat addressed or accepted with rationale; residual risk.
5. **Hardening checklist (final)** — each item mapped to the T# it mitigates, with evidence.

<!--
Speaker: These five are the "built it right" half. The threat model and hardening checklist have grown
since Module 1 and Module 6 respectively — now they must be complete: every T# addressed or explicitly
accepted. "Accepted with rationale" is a mature security answer; pretending risk away is not.
-->

---

## Deliverables (6–9)

6. **Authorized red-team report** — full M15 assessment vs. the final platform; before/after deltas.
7. **Observability** — KPI dashboards, alerts covering **all M15 signatures**, detection-coverage map.
8. **IR runbooks** — toll fraud, INVITE flood, credential compromise, eavesdropping; **each executed
   once** with report + timeline.
9. **Operations guide** — backup/restore, cert rotation, capacity, upgrade, on-call escalation.

<!--
Speaker: These four are the "proved it and can run it" half. #6's before/after delta shows the
hardening actually reduced exploitable findings. #8 is the differentiator — runbooks that have been
*executed*, not just written. #9 is what separates a lab from an operable platform. This is a real
security-review package.
-->

---

## Assessment rubric (100 pts)

| Area | Pts |
|---|---|
| Functionality (calls/trunk/fax/ENUM) | 15 |
| Reproducibility + IaC parity + secure CI | 15 |
| Signaling + media encryption (verified in capture) | 15 |
| Identity (digest + STIR/SHAKEN) | 10 |
| Edge/border defense | 10 |
| Fraud prevention (demonstrated) | 10 |
| Observability + detection coverage | 10 |
| IR runbooks executed with evidence | 10 |
| Documentation quality | 5 |

**Pass = ≥70 overall AND no failing security category.** Security is mandatory.

<!--
Speaker: Spell out the gate: you cannot certify on protocol fluency while failing security. A student
with great functionality but broken encryption FAILS — that's the whole ethos of a security-first
course. The categories mirror the modules, so the rubric is also a course-coverage map.
-->

---

## Runbook: toll fraud & flood

- **Toll fraud:** detect (spend/velocity/off-hours) → triage (account, destinations, CDR+HOMER) →
  contain (suspend, block range, cap) → eradicate (rotate, find entry) → recover → review.
- **INVITE/REGISTER flood:** detect (CPS/4xx spike) → triage (attack vs. surge) → contain (nftables
  rate limit / `pike` / fail2ban / scale) → recover → review.

<!--
Speaker: These templates are starter artifacts — students execute and refine them. The six-step shape
(detect→triage→contain→eradicate→recover→review) is consistent across all runbooks, which is the
point: incident response is a repeatable procedure, not improvisation. "Attack vs. legitimate surge"
is the hard judgment call in the flood runbook.
-->

---

## Runbook: credential compromise & eavesdropping

- **Credential compromise:** auth-failure spike → success from new geo → suspend/rotate, invalidate
  registrations, scope other accounts (T11/T15 entry) → stronger secret + TLS-only.
- **Suspected eavesdropping:** cleartext where SRTP required / downgrade alarm → enforce SRTP-only,
  re-anchor media, rotate keys → find where the downgrade occurred → close it.

<!--
Speaker: Both trace back to specific modules — credential compromise to secret hygiene/provisioning
(M6/M14) and eavesdropping to media security (M12). The investigation step matters most: don't just
recover, find the entry point and close it, or it recurs. Evidence handling uses M5's integrity
discipline throughout.
-->

---

## The presentation (defend your design)

- Walk the **threat model**.
- **Demo** an attack being detected + contained.
- Show the platform **recovering**.
- Peer + instructor scored.

<!--
Speaker: The live defense is where mastery shows. They must explain *why* the design is defensible,
then prove it — run an attack, show it detected and contained on the dashboards, and recover. Being
able to stand behind the design under questioning is the real certification of a "Certified VoIPSec
Operator."
-->

---

## The whole course, in one platform

- **Protocol** (M0–5) → **Build** (M6–10) → **Secure** (M11–14) → **Attack/Defend/Operate** (M15–19).
- Two planes closed (TLS + SRTP); identity proven (digest + STIR/SHAKEN).
- Every **T1–T15** addressed; every attack has a **detection + runbook**.

<!--
Speaker: Zoom out one last time. The capstone is the course's thesis made real: security is
structural, not a bolt-on module. They didn't learn VoIP then learn security — they built a secure
VoIP platform, and can prove it holds. That's the Certified VoIPSec Operator standard.
-->

---

## Final check

**Defend it:** Which single deliverable best demonstrates that your hardening *worked*?
Why does the rubric make security categories mandatory to pass? Which runbook step most often
prevents recurrence, and why?

<!--
Speaker: Answers — the red-team before/after delta (#6) best proves the hardening worked: fewer
exploitable findings against the same methodology. Security is mandatory because a fast, feature-rich,
insecure platform is a liability, not a pass — the credential says "secure operator." The runbook
"review/investigate-entry" step prevents recurrence: recovering without finding the entry point just
resets the clock until the same hole is used again. Congratulations — that's the full VoIPSec course.
-->
