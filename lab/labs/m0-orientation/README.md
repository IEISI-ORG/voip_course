# Lab M0 — Orientation & Lab Setup

**Module:** [M0](../../../course/modules/00-orientation-and-lab.md) · **Est.** 2h ·
**Prereqs:** Linux CLI, Docker + Compose v2.

Goal: stand up the segmented lab, prove every service is healthy, capture one call end to end,
and demonstrate a clean reset. No SIP theory yet — just make the platform real and trusted.

## Setup
```bash
cd lab
make init          # create .env from template — then edit secrets
make up            # start the base topology (obs is separate: make obs-up)
make status        # services + sovoc_ networks
```

## Lab 0.1 — Bring-up & health  (40 pts)
1. `make up`, then `make status`; every base service is running.
2. Run the automated acceptance test:
   ```bash
   bash labs/m0-orientation/verify.sh
   ```
   It checks services, network subnets, and the segmentation invariant.
3. (Optional) `make obs-up` and open Grafana (`:3000`) + HOMER (`:9080`).

**Deliverable:** paste `make status` output and the final `verify.sh` line (`M0 ACCEPTANCE: PASS`).

## Lab 0.2 — Capture a call end to end  (30 pts)
1. Generate a deterministic test call:
   ```bash
   bash labs/m0-orientation/gen-call.sh 1002
   ```
2. Watch/record it. Either:
   - live ladder: `docker compose exec -it client sngrep -d any`, or
   - pcap: capture on the host bridge for `sovoc_edge` with `tshark`/Wireshark and re-run gen-call.
3. Identify the INVITE → 200 OK → ACK → BYE and note that the SBC (topology hiding) rewrote
   the internal addresses.

**Deliverable:** the exported `.pcap` (or an sngrep flow screenshot) showing one full dialog.

## Lab 0.3 — Break & reset (idempotency)  (20 pts)
```bash
make clean         # down -v: remove containers, networks, volumes
make up            # back from zero
bash labs/m0-orientation/verify.sh
```
**Deliverable:** show `verify.sh` PASS again after a full teardown — proving the lab is
reproducible, not a snowflake.

## Orientation only — do NOT attack yet  (10 pts)
Tour the attacker container and read the rules of engagement:
```bash
docker compose exec -it redteam bash        # note the authorized-use banner
cat /opt/redteam/AUTHORIZED_USE.md
lab-scan 8.8.8.8                             # confirm the scope guard REFUSES external targets
```
**Deliverable:** paste the `REFUSED:` line. (Offensive tooling is used for real starting M13.)

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Evidence |
|------|-----|----------|
| 0.1 all services healthy + `verify.sh` PASS | 40 | status output + PASS line |
| 0.2 one call captured end to end | 30 | pcap / sngrep flow |
| 0.3 clean reset re-passes `verify.sh` | 20 | second PASS after `make clean` |
| Ethics: scope guard refuses external target | 10 | `REFUSED:` line |

**Auto-graded core:** `verify.sh` exit 0 is required for 0.1 and 0.3.
