# redteam — authorized offensive-testing toolbox (Stage A6)

> **AUTHORIZED LAB USE ONLY.** Read [`AUTHORIZED_USE.md`](AUTHORIZED_USE.md). Using these
> tools against systems you are not authorized to test is illegal.

The attacker container. It exists so learners can *see* attacks in order to build defenses —
the offensive half of the course's threat model (M14), always paired with the defensive
response (M15).

## Ethical fencing (defense-in-depth)
1. **Network:** attached to `edge` (172.28.10.90) and `redteam` (172.28.40.90) **only** — it
   cannot reach `core`/`mgmt` by construction.
2. **Procedural:** an authorized-use banner prints on start and to `/etc/motd`.
3. **Tooling:** helper scripts refuse any target outside the lab subnets (`_guard.sh`).

## Tools
- **SIPVicious OSS** — `svmap`, `svwar`, `svcrack`, `svreport` (recon → enum → password).
- **SIPp** — scenario-driven load / malformed-message probing.
- Scope-guarded helpers on `PATH`:

| Helper | Tool | Demonstrates | Threat / module |
|--------|------|--------------|-----------------|
| `lab-scan [target]` | svmap | device discovery | T1 / M14 |
| `lab-enum [target] [range]` | svwar | extension enumeration | T2 / M13,M14 |
| `lab-crack [target] [ext]` | svcrack | password brute force | T3 / M15 |
| `lab-fuzz [target]` | ncat/SIPp | parser robustness smoke | T10 / M14 |

## Use
```bash
docker compose exec -it redteam bash     # see the banner
lab-scan 172.28.10.10                     # recon the SBC (allowed)
lab-scan 8.8.8.8                          # REFUSED by the scope guard
```

The full RFC 4475 SIP torture suite (BF7) and structured red-team exercises are built in the
M14 lab (Stage B).
