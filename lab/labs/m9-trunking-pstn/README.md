# Lab M9 — SIP Trunking & the PSTN

**Module:** [M9](../../../course/modules/09-sip-trunking-pstn.md) · **Est.** 5h ·
**Prereqs:** M6–M8. **See also:** [M9D DNS Infrastructure](../../../course/modules/09d-dns-infrastructure.md).

Goal: connect the platform to the outside world (ITSP/PSTN) securely — two-way trunking, correct
cause mapping, authenticated/encrypted trunks, and fraud guardrails.

## Auto-graded prerequisites
```bash
bash labs/m9-trunking-pstn/verify.sh          # endpoints + trunk-sim reachable + Q.850 tool
```

## Lab 9.1 — Two-way trunk  (30 pts)
Bring up bidirectional trunking to `trunk-sim`: complete an **inbound DID** (trunk-sim → SBC →
pbx-a → extension) and an **outbound PSTN** call (extension → SBC → trunk-sim). Route outbound
numbers to the trunk and inbound DIDs to extensions.

**Deliverable:** captures of one inbound and one outbound call completing.

## Lab 9.2 — SIP ↔ Q.850 cause mapping  (25 pts)
```bash
bash labs/m9-trunking-pstn/sip-q850.sh          # table
bash labs/m9-trunking-pstn/sip-q850.sh 486      # lookup
```
From captures, map five SIP failure responses (e.g. 404, 486, 480, 503, 603) to their Q.850
causes and explain one interop consequence of a wrong mapping.

**Deliverable:** the five mappings from your own captures + one interop consequence.

## Lab 9.3 (security) — Harden the trunk  (45 pts)
Follow [`trunk-hardening.md`](trunk-hardening.md):
- convert IP-only trunk → **TLS + digest auth**; prove a spoofed source (from `redteam`) is
  **rejected** (capture the 401/403),
- add an **outbound destination allowlist** + **spend/concurrency limit**, and **trigger the
  alert** by dialing a blocked prefix.

**Deliverable:** spoof-rejection capture + allowlist/spend-limit config + the triggered alert.

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` prerequisites | — | required |
| 9.1 two-way trunk | 30 | captures |
| 9.2 Q.850 cause mapping | 25 | from captures |
| 9.3 TLS+auth + spoof rejected + fraud guardrails | 45 | config + captures + alert |
