---
marp: true
theme: default
paginate: true
title: Module 17 — Monitoring, Observability & Incident Response
---

# Module 17 — Monitoring, Observability & Incident Response

See everything, detect abuse in real time, and respond with runbooks.

<!-- Instructor: set the scene; ~30 min. Every module ends with a hands-on lab + fail-closed verify.sh. -->
---

## Learning Objectives

- Build a VoIP observability stack (metrics, logs, SIP capture) and meaningful dashboards/alerts.
- Detect the Module 15 attack signatures automatically.
- Execute incident-response runbooks for the top VoIP incidents.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 1. Concept

- **Three pillars for VoIP:** metrics (Prometheus + exporters), logs (Loki/promtail, syslog),
- **KPIs & SLOs:** registration success rate, ASR (answer-seizure ratio), ACD, PDD (post-dial
- **Alerting:** thresholds vs. anomaly; alert on auth-failure spikes, scan patterns, flood, MOS
- **Detection engineering:** turn each M15 signature into a rule (Wazuh/Loki/HOMER queries):
- **Incident response for VoIP:** detect → triage → contain (suspend account, block source,
- **Forensics:** using HOMER captures + CDRs + logs to reconstruct an incident timeline.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 2. Packet Reality

- Correlate a single fraudulent call across HOMER (signaling), CDR (billing), and logs (auth)

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 3. Build (OSS)

- Prometheus + node/Asterisk/Kamailio exporters; Grafana dashboards for the KPIs above.
- Loki/promtail for structured SIP + auth logs; HOMER already capturing (M5).
- Wazuh rules + Alertmanager routes for the M15 signatures; test each alert fires.
- A CDR analytics job feeding fraud alerts (from M16) into the same alerting pipeline.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 4. Attack / Defend

- Run the M15 assessment again "blind"; prove the SOC view detects each phase in real time.
- Tune out false positives; document detection coverage vs. the threat catalog (gap analysis).

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 5. Labs / Deliverable

- **Lab 15.1:** Build the KPI dashboard + alerts; screenshot healthy vs. under-attack states.
- **Lab 15.2:** Detection rules for all M15 signatures; show each firing during a replay.
- **Lab 15.3 (IR):** Author and execute an incident runbook for (a) toll fraud, (b) INVITE flood,
- *Rubric:* actionable dashboards; complete detection coverage; runbooks executed with evidence.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## Lab & assessment

- Hands-on lab with a fail-closed `verify.sh`; rubric 100 pts, pass ≥ 70.
- Update your living threat model + hardening checklist.

<!-- Speaker note: point learners at lab/labs/<module>/. -->
