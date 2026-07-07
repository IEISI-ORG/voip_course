---
marp: true
theme: default
paginate: true
title: Module 7 — SIP Proxies & SBCs (Kamailio / OpenSIPS + rtpengine)
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Module 7 — SIP Proxies & SBCs

**Build the routing and border layer: a SIP proxy and a real open-source SBC.**

`Est. 6h` · Prereqs: Module 6

<!--
Speaker: This is where the architecture gets serious. The PBX (M6) is the feature brain; now we put
a hardened, internet-facing proxy/SBC in front of it. Big idea: "SBC" is not a product you buy — it's
a *pattern* you assemble from OSS parts (Kamailio + rtpengine). We build it piece by piece.
-->

---

## What you'll leave with

- Configure **Kamailio/OpenSIPS** as registrar, proxy, load balancer.
- Assemble an **SBC**: topology hiding + media anchoring (rtpengine) + security policy.
- Understand stateless/stateful/transaction/dialog routing.

<!--
Speaker: The mental model to install: separate routing/security/scale (proxy) from media/features
(PBX). Internet-facing brain in Kamailio; trusted feature core in Asterisk/FS behind it.
-->

---

## Why a proxy layer at all

- **Separation of concerns:** routing + security + scale ≠ media + features.
- Put the **hardened, internet-facing brain** in Kamailio/OpenSIPS.
- Keep **Asterisk/FreeSWITCH in the trusted core**, never directly exposed.

<!--
Speaker: This separation is itself a security control — the box exposed to the internet is a small,
auditable router, not your feature-rich PBX with its dialplan and voicemail. Attack surface
minimisation by architecture. Ties straight to the edge/core network split from Module 0.
-->

---

## Kamailio internals

- **Route scripts:** request route, reply route, failure route, branch route.
- **Modules:** `tm` (transactions), `sl` (stateless), `rr` (record-route), `registrar` + `usrloc`,
  `auth`, `dispatcher` (load balance), `pike` (rate), `htable`, **`topoh`/`topos`** (topology
  hiding), `rtpengine`.

<!--
Speaker: Don't teach every module — teach the *shape*: Kamailio is a scripting engine where you pull
in modules for capabilities. Name the security-relevant ones (auth, pike, topoh/topos) since they
reappear in the attack/defend slide. `tm` vs `sl` = stateful vs stateless, the M2 concept made real.
-->

---

## The SBC is a pattern, not a product

Assembled from OSS parts:

- **Signaling** normalization / manipulation
- **Topology hiding** (`topoh` / `topos`)
- **Media anchoring** (rtpengine)
- **NAT handling** · admission / rate control · protocol repair
- **Security policy enforcement**

<!--
Speaker: This slide is the module's thesis. A commercial SBC bundles these; we build each from
Kamailio + rtpengine so they understand what's actually happening. Every bullet is a security
function. "SBC" = the assembly of these at the border.
-->

---

## Packet reality: transparent vs. topology-hidden

- Compare a call through a **transparent proxy** vs. one with **topology hiding**.
- What the external party can/can't see: **internal IPs, Via chain, UA**.
- Watch **rtpengine** rewrite SDP `c=`/`m=` and anchor RTP.

<!--
Speaker: The before/after capture is the "aha": transparent proxy leaks your internal IP addresses
and Via chain to anyone who reads a response — a free network map for an attacker (T12). topoh/topos
mask it. Pair with the rtpengine anchoring from M3 — signaling AND media both controlled at the SBC.
-->

---

## Build (OSS)

- Kamailio: **registrar + stateful proxy** dispatching to `pbx-a`/`pbx-b`; add `rr`, `auth`.
- Enable **`topoh`/`topos`**; integrate **rtpengine**.
- **OpenSIPS** variant of the same routing (compare scripting).
- **Dispatcher failover:** kill a PBX, show calls reroute.

<!--
Speaker: Build order: get routing working, then add record-route + auth, then topology hiding, then
media anchoring. The OpenSIPS comparison shows the concepts are portable across engines. Dispatcher
failover previews the availability theme below.
-->

---

## Attack / Defend — the border controls

- **Topology exposure (T12):** leaking internal IPs/Via/RR → `topoh`/`topos`, strip/rewrite, mask UA.
- **Open relay / routing abuse:** never proxy for unauthenticated/unknown sources; enforce
  From-domain + destination allowlists; prevent loops.
- **Admission control (T8):** `pike` (per-source rate), `htable` counters, dispatcher overload
  handling — **flood defense at the border**.

<!--
Speaker: Three border defenses. Open relay is the SIP version of an open mail relay — proxy for
strangers and you become an attacker's toll-fraud launchpad. `pike` is the star of the flood lab:
per-source rate limiting that can distinguish an attack IP from a busy trunk (that's an exam
question — busy trunk is one source with high *legitimate* volume; tune thresholds/allowlist).
-->

---

## Availability is a security property (HA)

- An SBC that fails takes **every in-flight call** with it.
- **Build:** `usrloc db_mode=3` (MySQL/Redis) + **DMQ** so two `edge-sbc` replicas share
  registrations; rtpengine with a **Redis** backend for media-state failover.
- **Defend:** avoid split-brain; no call state leaks across failover; trust boundary intact on standby.

<!--
Speaker: Production security includes uptime — a downed border is a denial of service you inflicted
on yourself. The lab runs two replicas sharing registrar state and kills the active node mid-call;
the call must survive. Watch for the standby node silently missing a hardening rule (policy parity).
-->

---

## Dual-stack / IPv6 signaling

- Carrier/IMS (VoLTE/VoNR) is frequently **IPv6-only** → SBC must present **dual-stack**.
- **Build:** Kamailio listeners on v4 **and** v6 (UDP/TCP/TLS), correct outbound socket selection,
  v6-aware record-routing.
- **Defend:** a v6 listener that skips v4 hardening (`pike`, ACLs) is a **bypass** — enforce parity;
  test v6 literals against parser bugs (RFC 5118).

<!--
Speaker: The security point here is *policy parity*. Teams add an IPv6 listener and forget to apply
the rate limits and ACLs they built for v4 — instant bypass around all your border defense. RFC 5118
is the "SIP over IPv6 torture test" — v6 address literals break naive parsers. Same policy, both
stacks.
-->

---

## Labs

- **Lab 7.1** — Kamailio registrar + stateful dispatcher to two PBXs with **failover**; capture reroute.
- **Lab 7.2 (security)** — Turn on **topology hiding**; prove no internal IPs leak externally.
- **Lab 7.3** — **rtpengine** media anchoring; show RTP always transits the SBC.
- **Lab 7.4 (defense)** — Configure **`pike`** rate-limiting; throttle an INVITE flood.

*Rubric:* working failover · verified topology hiding · anchored media · effective rate limit.

<!--
Speaker: 7.2 and 7.4 are the security keystones — a proven no-leak capture and a throttled flood.
These border controls (topology hiding + rate limiting + media anchoring) are what turn the raw
proxy into an actual SBC. All feed the hardening checklist.
-->

---

## Takeaways & quick check

- **SBC = a pattern** assembled from OSS: hide topology, anchor media, control admission.
- **Availability and policy parity** are security properties, not afterthoughts.
- Never be an **open relay**.

**Check:** Proxy-mode SBC vs. B2BUA — what do you lose? Which Kamailio modules hide topology and what
do they rewrite? How does `pike` tell an attack source from a busy trunk?

<!--
Speaker: Answers — proxy-mode SBC scales and stays transparent but gives up per-leg control/feature
manipulation a B2BUA has; `topoh`/`topos` rewrite/encrypt Via, Record-Route, Contact and internal
addresses so external parties can't map you; `pike` rate-limits *per source IP*, so a single busy
trunk is handled by allowlisting/thresholds while many-hits-from-one-scanner trips the limit. Next:
NAT, firewalls & session border control (M8).
-->
