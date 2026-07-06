# Module 0 — Orientation & Lab Setup

**One-liner:** Get the reproducible, segmented lab running and learn the toolchain before
touching SIP. **Est. time:** 2h · **Prereqs:** Linux CLI, Docker basics.

## Learning Objectives
- Stand up the full VoIPSec Docker topology and verify every service is healthy.
- Understand lab network segmentation and the ethical/authorized-use rules for offensive tools.
- Know where captures, logs, configs, and secrets live, and how to reset the lab cleanly.

## 1. Concept
- Why a shared, growing lab: you build one platform across 20 modules; the capstone is its
  hardened final form.
- Network segmentation model: `edge` (untrusted), `core` (trusted/mTLS), `mgmt`
  (observability), `redteam` (isolated). Maps to real DMZ design.
- Reproducibility contract: infra-as-code, no snowflake hosts, `docker compose down -v` resets.

## 2. Packet Reality
- First capture: run `sngrep` on the edge and place a call between two softphones; watch the
  SIP ladder appear. No theory yet — just prove the tooling sees traffic.

## 3. Build (OSS)
- Install Docker + compose; `git clone` the lab repo; `docker compose up -d`.
- Services: `edge-sbc` (Kamailio+rtpengine), `pbx-a` (Asterisk), `pbx-b` (FreeSWITCH),
  `trunk-sim` (SIPp), `obs` (HOMER/Prometheus/Grafana/Loki/Wazuh), `clients`, `redteam`.
- Health checks: `docker compose ps`, service logs, Grafana up, HOMER receiving HEP.
- Register two softphones (Linphone, Baresip) against `pbx-a`; place a test call.

## 4. Attack / Defend (orientation only)
- Tour the `redteam` container (SIPVicious, SIPp, nmap) — but **do not run yet**.
- Authorized-use rules: offensive tooling only against lab targets on `edge`/`redteam`;
  never against third parties; this rule is restated in every offensive lab.

## 5. Labs
- **Lab 0.1:** Bring up the topology; paste `docker compose ps` + a Grafana screenshot.
- **Lab 0.2:** Capture a call in `sngrep`, export the pcap, open it in Wireshark.
- **Lab 0.3:** Break and reset — `down -v`, back `up`, prove idempotency.
- *Rubric:* all services healthy, one call captured end-to-end, clean reset demonstrated.

## Assessment (sample)
- Which network may attacker containers reach, and why is `core` excluded?
- What command fully resets lab state including volumes?
- Where are SIP captures aggregated for correlation?

## References
- Docker Compose docs; Asterisk & FreeSWITCH quick-start; sngrep README; HOMER 7 docs.
- Lab conventions in `../notes.md §3`.
