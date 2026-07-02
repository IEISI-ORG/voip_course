# Lab M15 — Monitoring, Observability & Incident Response

**Module:** [M15](../../../course/modules/15-monitoring-observability-ir.md) · **Est.** 5h ·
**Prereqs:** M5, M13, M14.

Goal: see everything, detect abuse in real time, and respond with runbooks. Bring up the
observability stack: `make obs-up`.

## Auto-graded core
```bash
bash labs/m15-monitoring-ir/verify.sh        # rules valid + alert/threat/runbook coverage (offline)
```
Deterministic: alert rules are well-formed and every M13 threat has a detection signature and the
three IR scenarios have runbooks.

## Lab 15.1 — KPI dashboard + alerts  (30 pts)
Load `alert-rules.yml` into Prometheus (validate `promtool check rules alert-rules.yml`); build a
Grafana dashboard of security KPIs (failure ratio, registration/INVITE rates, bans, spend, cert
expiry). Screenshot **healthy vs under-attack**.

**Deliverable:** dashboard + the two screenshots.

## Lab 15.2 — Detection coverage  (40 pts)
Implement a detection rule for **every** M13 signature
([`detection-signatures.md`](detection-signatures.md)); trigger each attack from `redteam` /
replay and show the matching alert firing.

**Deliverable:** each threat's alert firing during replay (coverage table complete).

## Lab 15.3 (IR) — Runbooks executed  (30 pts)
Using [`incident-runbook-template.md`](incident-runbook-template.md), author and **execute** an
incident runbook for (a) toll fraud, (b) INVITE flood, (c) suspected eavesdropping. Produce an
incident report with a timeline.

**Deliverable:** three executed runbooks + incident reports with timelines.

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` rules+coverage PASS | — | required |
| 15.1 dashboard + alerts | 30 | screenshots |
| 15.2 detection coverage (all M13) | 40 | alerts firing |
| 15.3 IR runbooks executed | 30 | reports + timelines |

> Closes the red→blue arc: M13 attacks → M14 defenses → M15 detection + response. A finding with
> no detection is an incomplete defense.
