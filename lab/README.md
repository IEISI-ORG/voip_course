# VoIPSec Reference Lab

The single, growing lab every VoIPSec module plugs into. You build it once and then extend,
attack, defend, and operate it across the course. This is the practical counterpart to the
course design in [`../course/`](../course/).

## Status

**Stage A0 — foundation (bootable placeholders).** The full segmented topology is defined and
boots today with idle placeholder containers so you can verify network segmentation
immediately (M0 lab). Each subsequent build iteration replaces one placeholder with its real
service. Track progress in [`../course/build_plan.md`](../course/build_plan.md).

| Slot | Real service (arrives in) | Networks |
|------|---------------------------|----------|
| `edge-sbc` | Kamailio + rtpengine (A1) | edge, core |
| `pbx-a` | Asterisk (A2) | core |
| `pbx-b` | FreeSWITCH (A3) | core |
| `trunk-sim` | SIPp/Asterisk PSTN peer (A4) | edge |
| `client` | Baresip/PJSUA/Linphone/SIPp (A4) | edge |
| `obs` | HOMER, Prometheus, Grafana, Loki, Wazuh (A5) | mgmt, core |
| `redteam` | SIPVicious OSS + fuzzers (A6) | edge, redteam |

## Topology

```
        external (edge 172.28.10.0/24)          mgmt 172.28.30.0/24
   client ─┐   trunk-sim ─┐   redteam ─┐         obs ─┐
           │              │            │              │
        ┌──▼──────────────▼────────────▼──┐           │
        │           edge-sbc              │           │
        │  Kamailio + rtpengine (border)  │           │
        └───────────────┬─────────────────┘           │
                        │ core 172.28.20.0/24          │
                ┌───────┼───────────────┐              │
             pbx-a    pbx-b            obs ◀───────────┘
           (Asterisk)(FreeSWITCH)   (HEP/metrics)

   redteam plane (172.28.40.0/24): redteam ↔ edge only. Never core/mgmt.
```

## Quick start

```bash
cp .env.example .env      # then edit secrets  (make init does this)
make up                   # start topology
make status               # services + voipsec_ networks
make segtest              # M0: prove redteam cannot reach core
make down                 # stop
```

Requires Docker Engine + the Compose v2 plugin (`docker compose`).

## Security ground rules (read before A6)

- Offensive tooling (SIPVicious, sipp fuzzers) targets **only** this lab, from the `redteam`
  container on `edge`/`redteam`. Scanning or testing any system without written authorization
  is illegal. The red-team container ships with an authorized-use banner for this reason.
- Secrets live in `.env` and generated `secrets/` / `pki/` material — **never** in tracked
  config. See the repo `.gitignore`.

## Layout

```
lab/
├── docker-compose.yml     # topology contract (this stage)
├── .env.example           # copy to .env; real secrets never committed
├── Makefile               # up/down/status/logs/segtest
├── services/              # per-service build context + config (filled A1..A6)
│   ├── edge-sbc/  pbx-a/  pbx-b/  trunk-sim/  client/  obs/  redteam/
├── scenarios/             # SIPp XML, capture scripts (filled from A4)
└── labs/                  # per-module exercise runbooks (Stage B)
```
