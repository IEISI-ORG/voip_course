---
marp: true
theme: default
paginate: true
title: Module 15 — VoIP Threats & Offensive Testing (Authorized)
---

# Module 15 — VoIP Threats & Offensive Testing (Authorized)

Think like an attacker — run a disciplined, authorized red-team assessment against your own platform.

<!-- Instructor: set the scene; ~30 min. Every module ends with a hands-on lab + fail-closed verify.sh. -->
---

## Learning Objectives

- Conduct a structured VoIP security assessment (recon → enumeration → exploitation → impact).
- Use SIPVicious, SIPp, and fuzzers to demonstrate real weaknesses.
- Produce findings that drive the Module 16 hardening.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 1. Concept

- **Methodology:** scoping & authorization → reconnaissance → enumeration → credential attacks →
- **Threat taxonomy (from `../notes.md §2`):** scanning (T1), enumeration (T2), brute force (T3),
- **Tooling:** SIPVicious OSS (`svmap` discovery, `svwar` extension war-dialing, `svcrack`
- **Real-world context:** how breaches actually happen (default creds, open dialplans, exposed

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 2. Packet Reality

- Capture and fingerprint each attack's signature (what svmap/svwar/floods look like on the

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 3. Build (OSS) — the attacker toolkit

- Configure the `redteam` container; verify network fencing (can reach `edge`, not `core`).
- Baseline scans and scenarios saved as repeatable scripts.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 4. Attack (authorized, against the lab)

- **Recon/scan (T1):** svmap the edge; fingerprint UAs; find open transports.
- **Enumeration (T2):** svwar valid extensions; observe response deltas (ties to M13 defense).
- **Credential attack (T3):** svcrack a weak secret; then show a strong-secret account resisting.
- **DoS/flood (T8):** SIPp INVITE/REGISTER flood; measure impact with/without `pike`+nftables.
- **Fuzzing (T10):** malformed SIP via SIPp/fuzzer; watch parser behavior; note any instability.
- **Media (T5/T9):** sniff/reconstruct a cleartext call; inject RTP; confirm SRTP defeats it.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 5. Labs / Deliverable

- **Lab 15.1:** Full authorized assessment of the lab; produce a findings report (severity,
- **Lab 15.2:** For each finding, capture its detection signature for M17.
- *Rubric:* methodology followed; each finding has evidence + a concrete remediation reference;

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## Lab & assessment

- Hands-on lab with a fail-closed `verify.sh`; rubric 100 pts, pass ≥ 70.
- Update your living threat model + hardening checklist.

<!-- Speaker note: point learners at lab/labs/<module>/. -->
