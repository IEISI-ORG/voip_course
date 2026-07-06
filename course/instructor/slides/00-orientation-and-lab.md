---
marp: true
theme: default
paginate: true
title: Module 0 — Orientation & Lab Setup
---

# Module 0 — Orientation & Lab Setup

Get the reproducible, segmented lab running and learn the toolchain before touching SIP.

<!-- Instructor: set the scene; ~30 min. Every module ends with a hands-on lab + fail-closed verify.sh. -->
---

## Learning Objectives

- Stand up the full VoIPSec Docker topology and verify every service is healthy.
- Understand lab network segmentation and the ethical/authorized-use rules for offensive tools.
- Know where captures, logs, configs, and secrets live, and how to reset the lab cleanly.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 1. Concept

- Why a shared, growing lab: you build one platform across 20 modules; the capstone is its
- Network segmentation model: `edge` (untrusted), `core` (trusted/mTLS), `mgmt`
- Reproducibility contract: infra-as-code, no snowflake hosts, `docker compose down -v` resets.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 2. Packet Reality

- First capture: run `sngrep` on the edge and place a call between two softphones; watch the

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 3. Build (OSS)

- Install Docker + compose; `git clone` the lab repo; `docker compose up -d`.
- Services: `edge-sbc` (Kamailio+rtpengine), `pbx-a` (Asterisk), `pbx-b` (FreeSWITCH),
- Health checks: `docker compose ps`, service logs, Grafana up, HOMER receiving HEP.
- Register two softphones (Linphone, Baresip) against `pbx-a`; place a test call.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 4. Attack / Defend (orientation only)

- Tour the `redteam` container (SIPVicious, SIPp, nmap) — but **do not run yet**.
- Authorized-use rules: offensive tooling only against lab targets on `edge`/`redteam`;

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 5. Labs

- **Lab 0.1:** Bring up the topology; paste `docker compose ps` + a Grafana screenshot.
- **Lab 0.2:** Capture a call in `sngrep`, export the pcap, open it in Wireshark.
- **Lab 0.3:** Break and reset — `down -v`, back `up`, prove idempotency.
- *Rubric:* all services healthy, one call captured end-to-end, clean reset demonstrated.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## Lab & assessment

- Hands-on lab with a fail-closed `verify.sh`; rubric 100 pts, pass ≥ 70.
- Update your living threat model + hardening checklist.

<!-- Speaker note: point learners at lab/labs/<module>/. -->
