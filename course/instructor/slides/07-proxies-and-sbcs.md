---
marp: true
theme: default
paginate: true
title: Module 7 — SIP Proxies & SBCs (Kamailio / OpenSIPS + rtpengine)
---

# Module 7 — SIP Proxies & SBCs (Kamailio / OpenSIPS + rtpengine)

Build the routing and border layer: a SIP proxy and a real open-source Session Border Controller (SBC).

<!-- Instructor: set the scene; ~30 min. Every module ends with a hands-on lab + fail-closed verify.sh. -->
---

## Learning Objectives

- Configure Kamailio/OpenSIPS as registrar, proxy, and load balancer.
- Assemble an SBC: topology hiding + media anchoring (rtpengine) + security policy.
- Understand stateful/stateless/transaction/dialog modules and routing logic.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 1. Concept

- **Why a proxy layer:** separate routing/security/scale from the media/feature PBX; put the
- **Kamailio internals:** request/reply route scripts, core + modules (`tm`, `sl`, `rr`,
- **Registrar & location:** `save()`/`lookup()`, usrloc, NAT-aware contacts.
- **Routing:** stateless forward vs. stateful (`t_relay`), record-routing, dispatcher-based load
- **SBC role decomposition:** signaling normalization/manipulation, topology hiding (`topoh`/
- **B2BUA vs. proxy SBC:** trade-offs (control/feature vs. transparency/scale).

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 2. Packet Reality

- Compare a call through a **transparent proxy** vs. one through **topology hiding**: what the
- Watch rtpengine rewrite SDP `c=`/`m=` and anchor RTP.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 3. Build (OSS)

- Kamailio: registrar + stateful proxy dispatching to `pbx-a`/`pbx-b`; add `rr`, `auth`.
- Enable `topoh`/`topos` for topology hiding; integrate `rtpengine` for media.
- OpenSIPS variant of the same routing (compare scripting).
- Dispatcher failover: kill a PBX, show calls reroute.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 4. Attack / Defend

- **Topology exposure (T12):** proxies that leak internal IPs/Via/Record-Route → `topoh`/`topos`,
- **Routing abuse / open relay:** never proxy for unauthenticated/unknown sources; enforce
- **Admission control (T8):** `pike` (per-source rate), `htable` counters, `dispatcher` overload
- Extend hardening checklist + threat model with border controls.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 5. Labs

- **Lab 7.1:** Kamailio registrar + stateful dispatcher to two PBXs with failover; capture the reroute.
- **Lab 7.2 (security):** Turn on topology hiding; prove no internal IPs leak externally.
- **Lab 7.3:** rtpengine media anchoring; show RTP always transits the SBC (no direct media).
- **Lab 7.4 (defense):** Configure `pike` rate-limiting; demonstrate an INVITE flood being throttled.
- *Rubric:* working failover; verified topology hiding; anchored media; effective rate limit.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## Lab & assessment

- Hands-on lab with a fail-closed `verify.sh`; rubric 100 pts, pass ≥ 70.
- Update your living threat model + hardening checklist.

<!-- Speaker note: point learners at lab/labs/<module>/. -->
