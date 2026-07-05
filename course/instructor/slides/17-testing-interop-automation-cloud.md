---
marp: true
theme: default
paginate: true
title: Module 17 — Testing, Interop, Automation & Cloud Deployment
---

# Module 17 — Testing, Interop, Automation & Cloud Deployment

Validate at scale, prove interoperability, and deploy the whole platform as code.

<!-- Instructor: set the scene; ~30 min. Every module ends with a hands-on lab + fail-closed verify.sh. -->
---

## Learning Objectives

- Write SIPp scenarios for load, regression, and conformance testing.
- Diagnose interoperability failures and apply SBC message manipulation to fix them.
- Deploy the platform reproducibly with containers + IaC and a secure CI pipeline.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 1. Concept

- **Testing types:** functional/regression, load/capacity (CPS, concurrent calls), soak, chaos
- **SIPp deeply:** XML scenarios (UAC/UAS), variables, RTP echo/playback, CSV injection, TLS/SRTP
- **Interoperability:** RFC 3261 interpretation differences, header/behavior mismatches; SBC
- **Automation / IaC:** Docker/compose (lab), Kubernetes (scale/HA), Ansible (config mgmt),
- **Cloud/containers for VoIP:** networking pitfalls (NAT, host networking for RTP, port ranges),
- **Secure pipelines:** secrets in CI, image scanning, config linting, no creds in git, signed

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 2. Packet Reality

- Run a SIPp load test; watch KPIs (M16) under CPS ramp; find the break point.
- Capture an interop mismatch (e.g., a required header a peer rejects) and the post-manipulation fix.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 3. Build (OSS)

- Author 3 SIPp scenarios: register storm, INVITE load with RTP, and a malformed-message regression.
- Fix a simulated interop bug via Kamailio header manipulation; prove with before/after captures.
- Convert the lab to: (a) a `docker compose` prod-like stack, (b) an Ansible-provisioned VM set,

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 4. Attack / Defend

- **Fuzz/conformance as security testing (T10):** malformed-message SIPp scenarios in CI to catch
- **Pipeline security:** secret leakage in CI, unsigned images, drift → scanning, signing,
- **Cloud media exposure:** wide RTP port ranges + public IPs → tight ranges, security groups,

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 5. Labs / Deliverable

- **Lab 16.1:** SIPp scenarios for load + regression; report capacity and the failure mode.
- **Lab 16.2 (interop):** Diagnose and fix an interop failure with SBC message manipulation.
- **Lab 16.3 (IaC):** One-command deploy of the platform via compose + Ansible/Terraform; CI runs
- *Rubric:* working scenarios + capacity numbers; interop fix proven; reproducible secure deploy.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## Lab & assessment

- Hands-on lab with a fail-closed `verify.sh`; rubric 100 pts, pass ≥ 70.
- Update your living threat model + hardening checklist.

<!-- Speaker note: point learners at lab/labs/<module>/. -->
