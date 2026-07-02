# Lab BF3 — HA State Sharing & Hitless Failover

**Modules:** [M7](../../../course/modules/07-proxies-and-sbcs.md) (SBC HA) +
[M16](../../../course/modules/16-testing-interop-automation-cloud.md) (orchestration).
Feedback-derived (gemini_feedback1).

Goal: run two SBC replicas that share registration and media state so a node loss doesn't drop
calls — with **identical security policy** on both (a weaker failover node is a silent downgrade).

## Auto-graded core
```bash
bash labs/bf3-ha-failover/verify.sh          # HA config + compose overlay valid (offline/CI)
```
Checks the HA config directives, the compose overlay (second replica + shared Redis), and that
`base + HA` merges (`docker compose config`).

## Bring up HA + run the failover test
```bash
cd lab
docker compose -f docker-compose.yml -f labs/bf3-ha-failover/docker-compose.ha.yml up -d
bash labs/bf3-ha-failover/failover-test.sh   # register via R1, kill R1, R2 still serves
```

## Build
1. **Shared registrar state** — merge [`kamailio-ha.snippet.cfg`](kamailio-ha.snippet.cfg):
   `usrloc db_mode=3` on Redis/MySQL, **or** DMQ (`dmq`+`dmq_usrloc`) cache replication.
2. **rtpengine media redundancy** — `redis = redis:6379/1` so a standby has active call state.
3. **Two replicas** — [`docker-compose.ha.yml`](docker-compose.ha.yml) adds `edge-sbc-2` + `redis`.
   Front them with a VIP/anycast in production.

## Security notes
- **Policy parity:** both replicas MUST enforce the same TLS/ACL/pike config — verify with each
  node's module `verify.sh`. Failover must not downgrade security.
- Protect the shared store (Redis AUTH/TLS, network-fenced to `core`); it holds registration data.
- Split-brain: ensure a consistent view (quorum / single-writer) so bindings don't diverge.

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` HA config/overlay PASS | — | required |
| shared registrar state (two replicas) | 30 | binding on both |
| rtpengine media redundancy | 25 | standby has call state |
| hitless failover (call survives node loss) | 30 | capture |
| policy parity verified on both nodes | 15 | per-node verify.sh |
