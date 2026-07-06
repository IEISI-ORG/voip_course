# Lab M15 — VoIP Threats & Offensive Testing (Authorized)

**Module:** [M15](../../../course/modules/15-threats-offensive-testing.md) · **Est.** 5h ·
**Prereqs:** M1–M13.

> **AUTHORIZED USE ONLY.** All tooling targets the VoIPSec lab (`edge`/`redteam` subnets) only.
> Testing any other system without written authorization is illegal. The `redteam` container is
> network-fenced and its helpers refuse non-lab targets. See
> [`services/redteam/AUTHORIZED_USE.md`](../../services/redteam/AUTHORIZED_USE.md).

Goal: run a disciplined, authorized red-team assessment against your own platform and produce a
findings report with evidence, remediation, and detection signatures.

## Auto-graded core (parser robustness / RFC 4475)
```bash
bash labs/m15-offensive/verify.sh        # torture the SBC; confirm it survives (no crash)
```
Fail-closed & self-validating: the SBC must answer a valid request before AND after a batch of
malformed messages — proving the parser drops garbage cleanly (threat T10).

## Lab 13.1 — Full authorized assessment  (60 pts)
Work the methodology from the `redteam` container:
```bash
docker compose exec -it redteam bash
lab-scan 172.28.10.10          # recon (svmap)
lab-enum 172.28.10.10 1000-1010# enumeration (svwar)
lab-crack 172.28.10.10 1001    # brute force (svcrack)
```
```bash
bash labs/m15-offensive/torture.sh 172.28.10.10   # malformed-input robustness
```
Produce a findings report using
[`findings-report-template.md`](findings-report-template.md): severity, evidence pcap,
reproduction, mapped defense.

**Deliverable:** the completed findings report (≥3 findings, each with evidence + remediation).

## Lab 13.2 — Detection signatures  (40 pts)
For each finding, capture its **detection signature** (log pattern / metric / Wazuh rule) so M17
can alert on it. Link each signature to its finding.

**Deliverable:** a detection signature per finding, carried into the M17 monitoring lab.

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` robustness PASS | — | required |
| 13.1 methodology + findings report | 60 | report quality/evidence |
| 13.2 detection signatures | 40 | one per finding |

> Authorized-use rules respected is a **pass gate** — an assessment that ignores scope fails
> regardless of technical quality.
