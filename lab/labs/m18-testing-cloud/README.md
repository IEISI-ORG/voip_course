# Lab M18 — Testing, Interop, Automation & Cloud

**Module:** [M18](../../../course/modules/18-testing-interop-automation-cloud.md) · **Est.** 5h ·
**Prereqs:** M6–M17.

Goal: validate at scale, prove interop, and deploy the whole platform as code with CI.

## Auto-graded core
```bash
bash labs/m18-testing-cloud/verify.sh        # CI valid + repo lint + no Actions injection (offline)
```
Mirrors what CI runs on every push (`.github/workflows/ci.yml`).

## Lab 16.1 — Load & regression  (30 pts)
```bash
RATE=5 CALLS=50 bash labs/m18-testing-cloud/load-test.sh
RATE=50 CALLS=500 bash labs/m18-testing-cloud/load-test.sh   # find the knee
```
Report capacity (successful cps) and the **failure mode** as you push rate (retransmits, 5xx,
timeouts). Keep a regression baseline.

**Deliverable:** capacity numbers + the failure mode + a regression baseline.

## Lab 16.2 (interop) — Fix an interop failure  (30 pts)
Introduce an interop break (e.g., a header/codec a peer rejects) and fix it with **SBC message
manipulation** (Kamailio `textops`/`sdpops`, or Asterisk PJSIP header rules). Capture before/after.

**Deliverable:** the failing exchange, the SBC fix, and the working exchange.

## Lab 16.3 (IaC) — One-command deploy + CI  (40 pts)
- Deploy the whole platform reproducibly (`docker compose up` today; add Ansible/Terraform for
  VM/cloud parity).
- CI on every change (`.github/workflows/ci.yml`): shell lint, compose config, YAML lint, the
  offline graders, bibliography check, and an image/config scan (trivy).
- Cloud-native depth (backlog BF13): K8s media networking (Multus vs hostNetwork) + Pod Security
  Standards; HA state sharing (BF3).

**Deliverable:** one-command deploy + a green CI run on a change.

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` CI+lint PASS | — | required |
| 16.1 load + capacity + failure mode | 30 | SIPp report |
| 16.2 interop fix (SBC manipulation) | 30 | before/after |
| 16.3 IaC deploy + green CI | 40 | deploy + CI run |

> Security-in-CI: config lint + image scan on every change stops config drift and vulnerable
> images from reaching a cohort. See also the top-level `make verify-all` and `.github/`.
