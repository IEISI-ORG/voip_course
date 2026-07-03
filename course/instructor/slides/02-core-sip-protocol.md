---
marp: true
theme: default
paginate: true
title: Module 2 — Core SIP Protocol Deep Dive
---

# Module 2 — Core SIP Protocol Deep Dive

Read and reason about every part of a SIP transaction and dialog.

<!-- Instructor: set the scene; ~30 min. Every module ends with a hands-on lab + fail-closed verify.sh. -->
---

## Learning Objectives

- Parse SIP requests/responses: methods, status codes, headers, bodies.
- Explain transactions vs. dialogs, Via/branch, Route/Record-Route, and Contact handling.
- Trace registration, proxying (stateful/stateless), redirect, forking, and B2BUA behavior.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 1. Concept

- **Messages:** request line, status line; the SIP grammar; compact headers.
- **Methods:** REGISTER, INVITE, ACK, BYE, CANCEL, OPTIONS, INFO, PRACK, UPDATE, SUBSCRIBE,
- **Responses:** 1xx–6xx classes; key codes (100,180,183,200,401,403,404,407,408,486,487,488,
- **Headers (mandatory + common):** Via (branch magic cookie), From/To (+tags), Call-ID, CSeq,
- **Transactions vs. dialogs:** client/server transactions, the 3-way INVITE transaction, ACK
- **Routing:** Via processing, loose vs. strict routing, Record-Route, service-route.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 2. Packet Reality

- Line-by-line read of a real INVITE and 200 OK; follow Via/branch to correlate the transaction.
- Registration trace with 401 challenge → authenticated REGISTER.
- Forking trace (two 180s, one 200, CANCEL to the loser).
- Tools: `sngrep` ladder, Wireshark "Follow SIP", HOMER call correlation.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 3. Build (OSS)

- Asterisk PJSIP dialplan for call forward + voicemail; observe generated headers.
- Kamailio as a **stateless** then **stateful** proxy for the same call; compare Via handling.
- Redirect scenario (3xx) via Kamailio `sl`/`tm`.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 4. Attack / Defend

- **Header trust:** From/PAI are not authenticated by default → spoofing (T7). Which headers a
- **CSeq/Call-ID/tag** manipulation and replay considerations; Max-Forwards loops.
- **Registration hijack (T3):** why an unauthenticated REGISTER is fatal; challenge everything.
- Defense: authenticate REGISTER/INVITE, strip internal Via/Record-Route at edge, sane

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 5. Labs

- **Lab 2.1:** Given three pcaps, identify each transaction/dialog and explain every non-2xx.
- **Lab 2.2:** Force and read a 401 challenge; annotate the auth round-trip.
- **Lab 2.3:** Configure sequential + parallel forking; capture and explain the CANCEL race.
- **Lab 2.4 (defense):** In Kamailio, strip internal `Via`/`Record-Route` on egress; prove
- *Rubric:* accurate transaction/dialog decomposition; correct auth trace; working forking;

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## Lab & assessment

- Hands-on lab with a fail-closed `verify.sh`; rubric 100 pts, pass ≥ 70.
- Update your living threat model + hardening checklist.

<!-- Speaker note: point learners at lab/labs/<module>/. -->
