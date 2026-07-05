# Module 7 — SIP Proxies & SBCs (Kamailio / OpenSIPS + rtpengine)

**One-liner:** Build the routing and border layer: a SIP proxy and a real open-source Session
Border Controller (SBC).
**Est. time:** 6h · **Prereqs:** Module 6.

## Learning Objectives
- Configure Kamailio/OpenSIPS as registrar, proxy, and load balancer.
- Assemble an SBC: topology hiding + media anchoring (rtpengine) + security policy.
- Understand stateful/stateless/transaction/dialog modules and routing logic.

## 1. Concept
- **Why a proxy layer:** separate routing/security/scale from the media/feature PBX; put the
  hardened, internet-facing brain in Kamailio/OpenSIPS, keep Asterisk/FS in the trusted core.
- **Kamailio internals:** request/reply route scripts, core + modules (`tm`, `sl`, `rr`,
  `registrar`, `usrloc`, `auth`, `dispatcher`, `pike`, `htable`, `topos`/`topoh`, `rtpengine`).
- **Registrar & location:** `save()`/`lookup()`, usrloc, NAT-aware contacts.
- **Routing:** stateless forward vs. stateful (`t_relay`), record-routing, dispatcher-based load
  balancing to PBX pools, failover, LCR concepts.
- **SBC role decomposition:** signaling normalization/manipulation, topology hiding (`topoh`/
  `topos`), media anchoring (rtpengine), NAT handling, admission/rate control, protocol repair,
  and security policy enforcement. "SBC" = a *pattern*, assembled from OSS parts.
- **B2BUA vs. proxy SBC:** trade-offs (control/feature vs. transparency/scale).

## 2. Packet Reality
- Compare a call through a **transparent proxy** vs. one through **topology hiding**: what the
  external party can and cannot see (internal IPs, Via chain, UA).
- Watch rtpengine rewrite SDP `c=`/`m=` and anchor RTP.

## 3. Build (OSS)
- Kamailio: registrar + stateful proxy dispatching to `pbx-a`/`pbx-b`; add `rr`, `auth`.
- Enable `topoh`/`topos` for topology hiding; integrate `rtpengine` for media.
- OpenSIPS variant of the same routing (compare scripting).
- Dispatcher failover: kill a PBX, show calls reroute.

## 4. Attack / Defend
- **Topology exposure (T12):** proxies that leak internal IPs/Via/Record-Route → `topoh`/`topos`,
  strip/rewrite headers, mask UA. Demonstrated in capture.
- **Routing abuse / open relay:** never proxy for unauthenticated/unknown sources; enforce
  From-domain and destination allowlists; prevent loops (Max-Forwards, `loose_route`).
- **Admission control (T8):** `pike` (per-source rate), `htable` counters, `dispatcher` overload
  handling — flood defense at the border.
- Extend hardening checklist + threat model with border controls.

## 5. Labs
- **Lab 7.1:** Kamailio registrar + stateful dispatcher to two PBXs with failover; capture the reroute.
- **Lab 7.2 (security):** Turn on topology hiding; prove no internal IPs leak externally.
- **Lab 7.3:** rtpengine media anchoring; show RTP always transits the SBC (no direct media).
- **Lab 7.4 (defense):** Configure `pike` rate-limiting; demonstrate an INVITE flood being throttled.
- *Rubric:* working failover; verified topology hiding; anchored media; effective rate limit.

## Assessment (sample)
- When do you choose a proxy-mode SBC over a B2BUA, and what do you lose?
- Which Kamailio modules provide topology hiding, and what exactly do they rewrite?
- How does `pike` differentiate an attack source from a busy legitimate trunk?

## Curriculum addition — High availability & cluster state sharing (review: gemini_feedback0)

An SBC/proxy that fails takes every in-flight call with it. Production security includes
*availability*, so learners must build hitless failover, not just a single node.
- **Concepts/standards:** registrar semantics (RFC 3261); Kamailio DMQ cache sync; usrloc
  DB replication; rtpengine media-state sharing.
- **Build:** move `usrloc` to `db_mode=3` backed by MySQL/Redis; enable DMQ so two `edge-sbc`
  replicas share registrations; configure rtpengine with a Redis backend so media state can
  fail over.
- **Attack/Defend:** single-point-of-failure and split-brain; validate no call state leaks
  across a failover; keep the trust boundary intact on the standby node.
- **Lab hook (adds B7+):** run two `edge-sbc` replicas sharing registrar state in Redis; kill
  the active node mid-call and confirm the call survives. Orchestration side is in M17.

## Curriculum addition — Dual-stack / IPv6 signaling (review: gemini_feedback1)

Carrier and IMS networks (VoLTE/VoNR) are frequently IPv6-only, so the SBC must present
dual-stack signaling and keep security policy identical on both stacks.
- **Standards:** RFC 3261 transports; RFC 5118 (SIP-over-IPv6 torture); DNS AAAA/NAPTR/SRV
  (RFC 3263); happy-eyeballs sequencing.
- **Build:** Kamailio dual-stack listeners (UDP/TCP/TLS bound on both v4 and v6), correct
  outbound socket selection (`mhomed`/`set_send_socket`), and v6-aware record-routing.
- **Attack/Defend:** a v6 listener that skips the v4 hardening (pike/ratelimit, ACLs) is a
  bypass; enforce policy parity and test v6 literals against parser bugs (RFC 5118).
- **Lab hook (adds BF9):** add an IPv6 listener to `edge-sbc`, register a v6 client, and prove
  rate-limit/ACLs apply identically on v6. Media 4↔6 bridging continues in M8.

## References
- Kamailio docs (core, tm/rr/registrar/topoh/topos/pike/dispatcher/rtpengine);
  OpenSIPS docs; rtpengine README; RFC 5853 (SBC in SIP).
