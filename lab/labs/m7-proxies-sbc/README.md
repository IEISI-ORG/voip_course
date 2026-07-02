# Lab M7 — SIP Proxies & SBCs

**Module:** [M7](../../../course/modules/07-proxies-and-sbcs.md) · **Est.** 6h ·
**Prereqs:** M6.

Goal: operate the routing + border layer — a Kamailio proxy/registrar and a real open-source
SBC (Kamailio + rtpengine) — and prove four properties: failover, topology hiding, media
anchoring, and rate limiting.

## Auto-graded core (rate limiting)
```bash
bash labs/m7-proxies-sbc/verify.sh
```
Self-validating & fail-closed: a pre-flood control probe must be answered, then a flood must get
the source **banned** (silence) — proving pike works. Bans the redteam IP ~300s (cooldown before
re-run, or `docker compose restart edge-sbc`).

## Lab 7.1 — Registrar + dispatcher failover  (25 pts)
Route through Kamailio to two PBXs (pbx-a, pbx-b) with a dispatcher list; take the primary down
and capture the reroute to the secondary.

**Deliverable:** capture of the failover + the dispatcher config.

## Lab 7.2 (security) — Topology hiding  (20 pts)
With `topoh` on, capture an external call and prove **no internal (core, 172.28.20.x) address**
appears in any header the external party sees.

**Deliverable:** external-side capture showing masked Via/Record-Route/Contact.

## Lab 7.3 — Media anchoring  (25 pts)
Show RTP always transits the SBC (rtpengine) — never endpoint-to-endpoint. Reuse
`labs/m3-sdp-media/sdp-offer.sh` to see `c=` rewritten to rtpengine, and confirm in a capture
that media flows via 172.28.10.11/172.28.20.11.

**Deliverable:** capture proving media transits the anchor; no direct-media path.

## Lab 7.4 (defense) — Rate limiting  (30 pts)
```bash
bash labs/m7-proxies-sbc/flood-demo.sh          # before/after probe + flood
docker compose logs --tail=30 edge-sbc | grep -i pike
```
Demonstrate an OPTIONS/INVITE flood being throttled: the flooder is answered, then banned.

**Deliverable:** before/after probe output + the pike ban log line.

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` rate-limit PASS | — | required |
| 7.1 dispatcher failover | 25 | capture |
| 7.2 topology hiding (no core IP leak) | 20 | capture |
| 7.3 media anchoring | 25 | capture |
| 7.4 flood throttled + ban log | 30 | output + log |
