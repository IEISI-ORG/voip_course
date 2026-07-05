---
marp: true
theme: default
paginate: true
title: Module 15 — Defense, Hardening & Fraud Prevention
---

# Module 15 — Defense, Hardening & Fraud Prevention

Turn the Module 14 findings into a hardened platform and stop toll fraud before it drains a budget.

<!-- Instructor: set the scene; ~30 min. Every module ends with a hands-on lab + fail-closed verify.sh. -->
---

## Learning Objectives

- Apply a complete, layered hardening baseline across endpoints, PBX, proxy/SBC, and edge.
- Design and implement toll-fraud prevention (limits, allowlists, anomaly detection).
- Automate brute-force/scan defense and validate it against Module 14 attacks.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 1. Concept

- **Defense-in-depth layers:** network edge (nftables/geo/rate) → SBC (topology hiding, admission,
- **Hardening baseline (consolidated checklist):**
- Transport: TLS/SIPS only externally; drop plaintext 5060 at edge; SRTP-only media policy.
- Identity: strong SHA-256 digest, no anonymous/guest, uniform error responses.
- Routing: From-domain + destination allowlists; no open relay; loop protection.
- Class-of-service: per-account destination restrictions, concurrent-call and velocity caps.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 2. Packet Reality

- Re-run Module 14 attack signatures and show them being dropped/banned/throttled in captures

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 3. Build (OSS)

- Implement the full hardening checklist across `edge-sbc`, `pbx-a`, `pbx-b`.
- fail2ban jails for Kamailio/Asterisk auth-failure + scan patterns; nftables rate limits.
- CDR-based fraud detection: a script/Wazuh rule flagging abnormal international/premium volume,
- Secure auto-provisioning: HTTPS + per-device credentials + config signing.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 4. Attack / Defend (validation)

- Replay every Module 14 finding; confirm remediation; record residual risk in the threat model.
- Tabletop: an account *is* compromised — what limits the loss? (spend cap, velocity, alerting).

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 5. Labs / Deliverable

- **Lab 14.1:** Apply and commit the **hardening checklist v-final**; map each item to the T# it
- **Lab 14.2:** Build fraud detection + auto-suspend; simulate an IRSF pattern and show it caught
- **Lab 14.3:** Re-run the M14 assessment; produce a before/after findings delta.
- *Rubric:* layered baseline applied with evidence; fraud pattern detected + contained; measurable

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## Lab & assessment

- Hands-on lab with a fail-closed `verify.sh`; rubric 100 pts, pass ≥ 70.
- Update your living threat model + hardening checklist.

<!-- Speaker note: point learners at lab/labs/<module>/. -->
