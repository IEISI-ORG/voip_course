# SOVOC Labs (Stage B)

Per-module hands-on labs. Each turns a module's design into a runnable, graded exercise
against the shared lab, with an executable checker where possible (`verify.sh`).

| Lab | Module | Focus | Status |
|-----|--------|-------|--------|
| [m0-orientation](m0-orientation/) | M0 | bring-up, health, segmentation, clean reset | ✅ |
| [m1-foundations](m1-foundations/) | M1 | two-plane call, recon, living threat model | ✅ |
| [m2-core-sip](m2-core-sip/) | M2 | transactions/dialogs, MF loop protection, topology hiding | ✅ |
| m3-… | M3 | SDP / media negotiation | ⏳ |
| … | … | (built in backlog order B3..B17) | |

Conventions:
- Each lab dir has a `README.md` runbook with a **100-pt rubric (pass ≥ 70)**.
- `verify.sh` (when present) is the auto-graded core — exit 0 required to pass its items.
- Helper scripts assume you run them from `lab/` and use `docker compose` (override `COMPOSE=`).
