# Lab BF9 — Dual-Stack / IPv6 VoIP

**Modules:** [M7](../../../course/modules/07-proxies-and-sbcs.md) +
[M8](../../../course/modules/08-nat-firewalls-sbc.md). Feedback-derived (gemini_feedback1).

Goal: run SIP over IPv4 **and** IPv6 (carrier/IMS is often v6-only), bridge media across families,
and keep the firewall at **v4/v6 parity** — no IPv6 blind spot.

## Auto-graded core
```bash
bash labs/bf9-dual-stack/verify.sh
bash labs/bf9-dual-stack/parity-check.sh labs/bf9-dual-stack/nftables-dual-stack.nft
```
Self-validating: the parity checker must confirm the shipped ruleset AND catch an injected v6 gap.

## Build
1. **Dual-stack SIP** — merge [`kamailio-v6.snippet.cfg`](kamailio-v6.snippet.cfg): add v6 listeners
   (UDP/TCP/TLS) alongside v4; publish A + AAAA and NAPTR/SRV; the same `request_route` security
   logic (pike, ACLs, topoh) applies to both families.
2. **IPv4↔IPv6 media bridge** — rtpengine interface carries both families so a v6 endpoint can
   reach a v4 PBX; media anchored at the border.
3. **Firewall parity** — use a single `table inet` (parity by construction, see M8) **or** keep
   separate `ip`/`ip6` tables and prove they match ([`nftables-dual-stack.nft`](nftables-dual-stack.nft)
   + `parity-check.sh`).

## Security notes
- The classic breach: a careful v4 firewall + neglected v6 rules → the same SIP port open on v6.
  Attackers scan v6 for exactly this. **`table inet` removes the possibility.**
- Parser-harden IPv6 literals (RFC 5118 torture, see M15).
- Verify a v6 scan triggers the same bans as a v4 scan (policy parity, not just port parity).

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` parity + config PASS | — | required |
| dual-stack registration + call (v6 endpoint) | 30 | capture |
| IPv4↔IPv6 media bridged by rtpengine | 30 | capture |
| nftables v4/v6 parity proven | 25 | parity-check |
| v6 scan triggers the same bans as v4 | 15 | capture |
