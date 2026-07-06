# Lab M16 — Defense, Hardening & Fraud Prevention

**Module:** [M16](../../../course/modules/16-defense-hardening-fraud.md) · **Est.** 6h ·
**Prereqs:** M15.

Goal: turn the M15 findings into a hardened platform and stop toll fraud before it drains a budget.

## Auto-graded core
```bash
bash labs/m16-defense-fraud/verify.sh          # fraud detector + hardening checklist (offline)
bash labs/m16-defense-fraud/fraud-detect.sh    # scan the sample CDR
```
Deterministic: the detector must catch the IRSF burst (spend-cap breach + high-cost prefix spike
+ offending account) and NOT false-positive on a clean CDR.

## Lab 16.1 — Hardening checklist v-final  (30 pts)
Apply the layered baseline and complete your **living hardening checklist**
([template](../m6-building-core/hardening-checklist.md)); map each item to the threat (T#) it
mitigates and cite the evidence (`verify.sh` output, config diff, capture).

**Deliverable:** committed `hardening-checklist.md` with every item checked + evidence.

## Lab 16.2 — Fraud detection + auto-suspend  (40 pts)
Build CDR-based fraud detection with a spend cap and auto-suspend:
```bash
bash labs/m16-defense-fraud/fraud-detect.sh labs/m16-defense-fraud/sample-cdr.csv
CAP=100 PREFIX_CAP=50 bash labs/m16-defense-fraud/fraud-detect.sh your-cdr.csv
```
Simulate an **IRSF** pattern (burst of calls to a high-cost prefix), show it caught, and
contained within the spend cap (the account is suspended before loss exceeds the cap). Wire the
alert to Wazuh (M17).

**Deliverable:** the detector firing on your IRSF simulation + the auto-suspend/containment action.

## Lab 16.3 — Before/after findings delta  (30 pts)
Re-run the M15 assessment (`labs/m15-offensive/`) against the hardened platform and produce a
**before/after findings delta** — quantify the reduction in exploitable findings.

**Deliverable:** the delta table (findings before vs after, with severities).

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` fraud + checklist PASS | — | required |
| 14.1 hardening checklist v-final + T# map | 30 | checklist + evidence |
| 14.2 fraud detection + containment | 40 | detector + action |
| 14.3 before/after findings delta | 30 | delta table |

> Layered fraud defense: prevent (allowlist + auth, M9/M13), **cap** (bounds the loss), detect +
> auto-suspend (this lab). The cap is the backstop when prevention fails.
