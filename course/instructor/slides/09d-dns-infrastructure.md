---
marp: true
theme: default
paginate: true
title: Module 9D — DNS Infrastructure & Resilience for VoIP
---

# Module 9D — DNS Infrastructure & Resilience for VoIP

DNS is how SIP finds servers and survives failure — and a prime target for redirecting calls. Build it correctly and defend it.

<!-- Instructor: set the scene; ~30 min. Every module ends with a hands-on lab + fail-closed verify.sh. -->
---

## Learning Objectives

- Explain SIP server location per **RFC 3263**: NAPTR → SRV → A/AAAA, and how transport is chosen.
- Design DNS-based **failover and load distribution** with SRV priority/weight and sane TTLs.
- Use **anycast** for resilient, DDoS-tolerant SIP/edge frontends, and know its limits for stateful media.
- Run **cut-overs and rollbacks** safely with TTL strategy and health-checked record changes.
- Treat DNS as an **attack surface**: spoofing/cache poisoning → call redirection, and the

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 1. Concept

- **Resolution chain (RFC 3263):** domain → NAPTR (service+transport, e.g. `SIPS+D2T`, `SIP+D2U`)
- **Records:** NAPTR (RFC 3401–3404), SRV (RFC 2782: priority = failover order, weight = load
- **Failover models:** multiple SRV targets (priority tiers) for client-side failover; GeoDNS /
- **Anycast:** same IP announced from many sites via BGP; the network routes to the nearest.
- **Cut-overs/rollbacks:** lower TTL *before* a change (e.g. 300s → 30s), make the change,

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 2. Packet Reality

- `dig NAPTR lab.voipsec.test`, `dig SRV _sip._udp.lab.voipsec.test`, `dig +dnssec` — read the
- Capture a client resolving and then registering; kill the primary SRV target and watch the

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 3. Build (OSS)

- **BIND9** (or dnsmasq) authoritative zone for `lab.voipsec.test`: NAPTR + `_sip._udp` /
- Configure **DNSSEC** signing of the zone; validate with `dig +dnssec`.
- Point Kamailio/Asterisk at the resolver and enable DNS **SRV failover** (Kamailio
- (Stretch) simulate anycast with two resolver instances sharing an address on the lab bridge.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 4. Attack / Defend

- **DNS spoofing / cache poisoning (T6/T7):** a forged answer points `_sips._tcp` SRV at an
- **Defenses:**
- **DNSSEC** to authenticate records end-to-end; validating resolvers reject forged answers.
- **Authenticate the server, not the name path:** with SIPS/TLS (M10) the client verifies the
- **DoT/DoH** for resolver privacy/integrity; split-horizon DNS so internal SRV data never
- Anycast to blunt DNS DDoS; rate-limit and RRL on authoritative servers.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 5. Labs

- **Lab 9D.1:** Author the NAPTR/SRV/A zone in BIND9; prove a client resolves it (RFC 3263 order)
- **Lab 9D.2 (failover):** Give the SIP service two SRV targets; take the primary down and show
- **Lab 9D.3 (security):** Inject a spoofed DNS answer redirecting `_sips._tcp` to a rogue host;
- **Lab 9D.4 (ops):** Perform a TTL-based cut-over to a new edge node and a clean rollback; write
- *Rubric:* correct RFC 3263 resolution; working SRV failover; demonstrated spoof + DNSSEC/TLS

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## Lab & assessment

- Hands-on lab with a fail-closed `verify.sh`; rubric 100 pts, pass ≥ 70.
- Update your living threat model + hardening checklist.

<!-- Speaker note: point learners at lab/labs/<module>/. -->
