---
marp: true
theme: default
paginate: true
title: Module 10 — DNS Infrastructure & Resilience for VoIP
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Module 10 — DNS Infrastructure & Resilience for VoIP

**DNS is how SIP finds servers and survives failure — and a prime target for redirecting calls.**

`Est. 4h` · Prereqs: M9 (trunking), M1 (RFC 3263 intro)

<!--
Speaker: DNS is invisible until it fails or gets poisoned — then every call is affected. Two threads:
build DNS-based location + failover correctly (RFC 3263), and defend it (DNSSEC + TLS cert identity).
Key reframe: what you publish in DNS *is policy* — publish only SIPS and you force TLS.
-->

---

## What you'll leave with

- Explain SIP server location per **RFC 3263**: NAPTR → SRV → A/AAAA.
- Design DNS **failover / load distribution** (SRV priority/weight, sane TTLs).
- Run safe **cut-overs and rollbacks**; treat DNS as an **attack surface** (spoofing → call redirect).

<!--
Speaker: The exam wants the resolution order and how it lets you force TLS, plus why you lower TTL
*before* a cut-over. Anchor both today.
-->

---

## The RFC 3263 resolution chain

```
domain
  → NAPTR   (service + transport: SIPS+D2T, SIP+D2U)
    → SRV   (_sips._tcp / _sip._udp : priority + weight)
      → A/AAAA
```

- The client picks transport from **what you publish** — so **what you publish is policy**.

<!--
Speaker: This is the crux slide. The UAC resolves NAPTR (which service+transport), then SRV (which
hosts, in what failover/load order), then A/AAAA (addresses) — all *before* sending a single SIP
packet. Publish only SIPS+D2T and clients have no plaintext option: DNS becomes a security control.
-->

---

## The records

- **NAPTR** (RFC 3401–3404): service + transport selection.
- **SRV** (RFC 2782): **priority = failover order**, **weight = load share**.
- **A/AAAA**: the addresses.
- **TTL** = how long a stale target lingers after a change.

<!--
Speaker: SRV priority/weight is the one to internalise: lower priority number = tried first
(failover tiers); weight distributes load within a tier. TTL is the lever for change speed — it's
central to both cut-overs (below) and to how long a poisoned answer persists.
-->

---

## Failover, distribution, anycast

- **Multiple SRV targets** (priority tiers) → client-side failover.
- **GeoDNS / weighted** answers → distribution; health-checked DNS withdraws dead nodes.
- **Anycast:** one IP announced from many sites (BGP). Great for stateless UDP + DDoS absorption;
  **stateful media (RTP) needs care** — a route flap can strand a flow (ties to M7 HA state).

<!--
Speaker: Anycast is powerful for the signaling frontend and DDoS absorption, but RTP is stateful — if
BGP reroutes mid-call to a node without the session, the media dies. That's why anycast pairs with the
shared media state from M7. Health-checked DNS is the automated "pull the dead node" mechanism.
-->

---

## Cut-overs & rollbacks (the TTL dance)

1. **Lower TTL first** (e.g. 300s → 30s), wait for it to propagate.
2. Make the change; **verify**.
3. Raise TTL back.
4. Keep the **old target warm** until TTL expires → instant rollback.

<!--
Speaker: This is operational security — a change you can't reverse quickly is a risk. Lowering TTL
*before* the change means clients re-query soon, so both the cut-over and any rollback take effect in
seconds, not hours. Keeping the old node warm means rollback is instant. This is Lab 10.4's runbook.
-->

---

## Packet reality

- `dig NAPTR`, `dig SRV _sip._udp…`, `dig +dnssec` — read the resolution a UAC does before it
  sends a packet.
- Capture resolve → register; kill the primary SRV target and watch **failover**; observe **TTL**
  controlling how fast a change takes.

<!--
Speaker: The dig sequence *is* what the phone does — make that concrete. Killing the primary SRV and
watching the client move to the secondary makes failover tangible, and varying TTL shows why it
governs recovery speed. This demystifies "DNS magic."
-->

---

## Build (OSS)

- **BIND9** authoritative zone for `lab.voipsec.test`: NAPTR + `_sip._udp` / `_sips._tcp` SRV →
  `edge-sbc`, plus a second lower-priority SRV.
- **DNSSEC** sign the zone; validate with `dig +dnssec`.
- Point Kamailio/Asterisk at the resolver; enable **SRV failover**
  (`use_dns_failover`, `dns_srv_lb`).

<!--
Speaker: They author a real signed zone. The second, lower-priority SRV target is what makes failover
demonstrable. DNSSEC signing here sets up the defense lab — a validating resolver will reject the
forged answer they inject next.
-->

---

## Attack / Defend

- **Spoofing / cache poisoning (T6/T7):** a forged answer points `_sips._tcp` SRV at an attacker →
  signaling redirected, calls intercepted/dropped.
- **Defense-in-depth:**
  - **DNSSEC** — validating resolvers reject forged answers.
  - **Authenticate the server, not the path:** with SIPS/TLS the client checks the **cert**, so a
    redirect to an attacker **without the valid cert fails the handshake**.
  - **DoT/DoH**, split-horizon DNS, RRL + anycast vs. DNS DDoS.

<!--
Speaker: The two-defenses point is the exam question and the module's best idea: DNSSEC protects the
*answer's integrity*; TLS cert verification protects the *destination's identity*. Even with NO
DNSSEC, TLS still saves you — the attacker can redirect the name but can't present your cert, so the
handshake fails. Two independent layers.
-->

---

## Labs

- **Lab 10.1** — Author the NAPTR/SRV/A zone in BIND9; prove RFC 3263 resolution + registration.
- **Lab 10.2 (failover)** — Two SRV targets; drop the primary, show failover; measure recovery vs. TTL.
- **Lab 10.3 (security)** — Inject a spoofed answer redirecting `_sips._tcp`; show the redirect, then
  show **DNSSEC** and **TLS cert verification** each defeat it.
- **Lab 10.4 (ops)** — TTL-based cut-over + clean rollback; write the runbook.

*Rubric:* correct RFC 3263 resolution · working SRV failover · spoof + DNSSEC/TLS mitigation · safe
reversible cut-over.

<!--
Speaker: 10.3 is the security keystone — they poison DNS, watch the call redirect, then watch two
independent defenses kill the attack. 10.4 produces a reusable ops runbook. Together: DNS is both a
resilience tool and an attack surface, and you must build for both.
-->

---

## Takeaways & quick check

- **What you publish in DNS is policy** — publish SIPS to force TLS.
- **Lower TTL before changes** — fast cut-over *and* instant rollback.
- **DNSSEC + TLS cert = two independent defenses** against redirection.

**Check:** In what order does a UAC use NAPTR/SRV/A, and how does that force TLS? Why lower TTL
*before* a cut-over? Which defense still protects you if DNSSEC isn't deployed?

<!--
Speaker: Answers — NAPTR (service+transport) → SRV (hosts, priority/weight) → A/AAAA; publishing only
SIPS+D2T removes the plaintext option. Lower TTL first so clients re-query quickly, making both change
and rollback near-instant. Without DNSSEC, SIPS/TLS still protects you — the redirected attacker can't
present your server cert, so the TLS handshake fails. Next: signaling security — TLS & SIPS (M11),
where that cert verification is built.
-->
