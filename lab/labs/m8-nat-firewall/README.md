# Lab M8 — NAT, Firewalls & Session Border Control

**Module:** [M8](../../../course/modules/08-nat-firewalls-sbc.md) · **Est.** 5h ·
**Prereqs:** M7.

Goal: solve NAT traversal correctly and turn the edge into a hardened, flood-resistant border.

## Auto-graded core (scanner ban)
```bash
bash labs/m8-nat-firewall/verify.sh
```
Self-validating & fail-closed: a plain probe is answered, then an `svmap` scan (UA
`friendly-scanner`) gets the source **banned** — the SBC's signature-based scanner block.
(Bans the redteam IP ~300s; cooldown or `restart edge-sbc` before re-run.)

## Lab 8.1 — NAT traversal end to end  (30 pts)
Make a behind-NAT call work for both signaling and media via Kamailio (`nat_uac_test`,
`fix_nated_*`) + rtpengine (symmetric RTP). Capture proof that media flows via the anchor, not
the private address.

**Deliverable:** capture of a working NAT'd call; note the `Contact`/SDP fix-ups.

## Lab 8.2 — TURN with coturn  (25 pts)
Stand up `coturn`, obtain a relay allocation, and capture ICE connectivity checks succeeding
through TURN. **Harden it** (see the M8 curriculum addition): `use-auth-secret`, `denied-peer-ip`
covering the `core`/`mgmt` subnets, allocation quotas.

**Deliverable:** ICE-through-TURN capture + a coturn config refusing a relay to an internal IP.

## Lab 8.3 (defense) — Edge firewall + banning  (45 pts)
1. Load an nftables edge ruleset (reference: `nftables-edge.example.nft`; validate with
   `nft -c -f`).
2. Run a lab scan and show it banned:
   ```bash
   bash labs/m8-nat-firewall/verify.sh          # svmap -> banned
   docker compose logs --tail=30 edge-sbc | grep -i -E 'scanner|ban'
   ```
3. Add a fail2ban jail keyed on SBC logs; measure flood mitigation (reuse
   `labs/m7-proxies-sbc/flood-demo.sh`).

**Deliverable:** validated nftables ruleset + scanner-ban evidence + fail2ban jail + flood
before/after.

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` scanner ban PASS | — | required |
| 8.1 NAT traversal (signaling+media) | 30 | capture |
| 8.2 TURN relay + hardening | 25 | capture + config |
| 8.3 nftables + fail2ban + flood | 45 | ruleset + logs |

> Layered defense: signature ban (UA), behavioural (pike), stateful firewall (nftables),
> dynamic bans (fail2ban). No single layer is sufficient — attackers rotate UAs and sources.
