---
marp: true
theme: default
paginate: true
title: Module 8 — NAT, Firewalls & Session Border Control
---

# Module 8 — NAT, Firewalls & Session Border Control

Solve the NAT problem correctly and turn the edge into a hardened, flood-resistant border.

<!-- Instructor: set the scene; ~30 min. Every module ends with a hands-on lab + fail-closed verify.sh. -->
---

## Learning Objectives

- Explain NAT types and why SIP/RTP break through NAT.
- Apply STUN/TURN/ICE and server-side NAT handling (Kamailio + rtpengine).
- Build edge firewalling (nftables), rate limiting, and brute-force jails (fail2ban).

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 1. Concept

- **NAT & why VoIP breaks:** private addresses in SIP/SDP vs. public path; the two-plane problem
- **NAT types:** full cone, restricted, port-restricted, symmetric; mapping vs. filtering
- **Client-side solutions:** STUN (RFC 5389/8489), TURN relay (5766/8656), ICE (8445),
- **Server-side solutions:** `received`/`rport` (RFC 3581), symmetric RTP, NAT keepalives
- **The SBC as border:** admission control, topology hiding (from M7), protocol repair, and the
- **Edge firewalling:** stateful nftables, port strategy (5060/5061/RTP range), geo/allowlists,

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 2. Packet Reality

- Capture a call from behind NAT: private IPs in Contact/SDP vs. what the edge sees; observe
- Observe a symmetric-NAT failure and its fix.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 3. Build (OSS)

- Kamailio `nathelper` + fix_nated_contact/sdp; rtpengine for media; keepalives.
- Deploy `coturn` (TURN) and drive an ICE-capable client (Linphone/WebRTC) through it.
- nftables ruleset for the edge: allow 5061/TLS + RTP range, drop 5060 from untrusted, rate-limit.
- fail2ban jail parsing Kamailio/Asterisk logs to ban scanners.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 4. Attack / Defend

- **SIP scanning & flooding (T1/T8):** svmap sweeps, INVITE/REGISTER floods → nftables rate
- **RTP bleed/injection (T9):** open media ports → rtpengine strict-source, symmetric RTP,
- **NAT keepalive amplification / ALG corruption:** disable upstream SIP ALG; control keepalives.
- Consolidate the **edge hardening checklist**; update threat model with border attacks.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 5. Labs

- **Lab 8.1:** Make a behind-NAT call work end-to-end (signaling + media) via Kamailio + rtpengine.
- **Lab 8.2:** Stand up coturn; capture ICE connectivity checks succeeding through TURN.
- **Lab 8.3 (defense):** Author an nftables edge ruleset + fail2ban jail; run a (lab) svmap scan
- *Rubric:* working NAT traversal; TURN relay proven; scanner banned; flood throttled.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## Lab & assessment

- Hands-on lab with a fail-closed `verify.sh`; rubric 100 pts, pass ≥ 70.
- Update your living threat model + hardening checklist.

<!-- Speaker note: point learners at lab/labs/<module>/. -->
