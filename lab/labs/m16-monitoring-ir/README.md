# Lab M16 — Monitoring, Observability & Incident Response

**Module:** [M16](../../../course/modules/16-monitoring-observability-ir.md) · **Est.** 5h ·
**Prereqs:** M5, M14, M15.

Goal: see everything, detect abuse in real time, and respond with runbooks. Bring up the
observability stack: `make obs-up`.

## Auto-graded core
```bash
bash labs/m16-monitoring-ir/verify.sh        # rules valid + alert/threat/runbook coverage (offline)
```
Deterministic: alert rules are well-formed and every M14 threat has a detection signature and the
three IR scenarios have runbooks.

## Lab 15.1 — KPI dashboard + alerts  (30 pts)
Load `alert-rules.yml` into Prometheus (validate `promtool check rules alert-rules.yml`); build a
Grafana dashboard of security KPIs (failure ratio, registration/INVITE rates, bans, spend, cert
expiry). Screenshot **healthy vs under-attack**.

**Deliverable:** dashboard + the two screenshots.

## Lab 15.2 — Detection coverage  (40 pts)
Implement a detection rule for **every** M14 signature
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
| 15.2 detection coverage (all M14) | 40 | alerts firing |
| 15.3 IR runbooks executed | 30 | reports + timelines |

> Closes the red→blue arc: M14 attacks → M15 defenses → M16 detection + response. A finding with
> no detection is an incomplete defense.
