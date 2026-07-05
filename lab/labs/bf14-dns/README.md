# Lab BF14 — DNS Infrastructure for VoIP (BIND9)

**Module:** [M10](../../../course/modules/10-dns-infrastructure.md). Feedback-derived
(the DNS module). Threats: DNS spoofing / cache poisoning → call redirection (T6/T7).

Goal: publish correct SIP DNS (RFC 3263), fail over between SBCs, sign the zone with DNSSEC, and
run safe TTL-based cut-overs — the runnable form of Module 10.

## Auto-graded core
```bash
bash labs/bf14-dns/verify.sh
bash labs/bf14-dns/zone-check.sh labs/bf14-dns/db.lab.voipsec.test
```
Self-validating: the zone validates (NAPTR + SRV failover + low TTL), the BIND config has DNSSEC +
rate-limiting + recursion off, and removing the secondary SRV target is flagged.

## Build
1. **Zone** ([`db.lab.voipsec.test`](db.lab.voipsec.test)): NAPTR selects transport (publish
   `SIPS+D2T` to force TLS); `_sips._tcp` / `_sip._udp` SRV records carry **two targets** at
   different priorities for client-side failover. `$TTL 30` keeps cut-overs reversible.
2. **BIND** ([`named.conf.snippet`](named.conf.snippet)): `dnssec-policy` (signing + rollover),
   response-rate-limiting, `recursion no` (not an open resolver). Validate with `named-checkzone`
   / `named-checkconf`.
3. Point Kamailio/Asterisk at the resolver; enable SRV failover.

## Verify (live)
```bash
dig NAPTR lab.voipsec.test
dig SRV _sips._tcp.lab.voipsec.test
dig +dnssec SRV _sips._tcp.lab.voipsec.test    # RRSIG present
# take the primary SRV target down -> client fails over to the secondary
```

## Security notes (spoofing → redirection)
- A forged answer pointing `_sips._tcp` at an attacker redirects signaling. **Two independent
  defenses:** DNSSEC (validating resolver rejects the forgery) **and** TLS cert verification (a
  redirect fails the handshake — identity is not tied to DNS).
- **Cut-over/rollback:** lower TTL *before* the change, verify, then raise it; keep the old target
  warm until the TTL fully expires so rollback is instant.

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` zone + config PASS | — | required |
| NAPTR/SRV resolution (RFC 3263) works | 25 | dig |
| SRV failover to secondary SBC | 25 | primary down → reroute |
| DNSSEC signed + spoof defeated (DNSSEC/TLS) | 30 | +dnssec + redirect test |
| TTL cut-over + rollback runbook | 20 | runbook + timing |
