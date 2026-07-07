---
marp: true
theme: default
paginate: true
title: Module 2 — Core SIP Protocol Deep Dive
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Module 2 — Core SIP Protocol Deep Dive

**Read and reason about every part of a SIP transaction and dialog.**

`Est. 5h` · Prereqs: Module 1

<!--
Speaker: This is the densest protocol module — pace it. The payoff is that after today they can read
any SIP capture cold and explain every header and status code. Everything downstream (auth, routing,
attacks) assumes this fluency. Lean hard on live captures over slides.
-->

---

## What you'll leave with

- Parse SIP **requests/responses**: methods, status codes, headers, bodies.
- Explain **transactions vs. dialogs**, Via/branch, Route/Record-Route.
- Trace registration, proxying (stateful/stateless), redirect, **forking**, B2BUA.

<!--
Speaker: Three competencies: parse, distinguish transaction-from-dialog, and trace real routing
behaviour. Tell them the exam asks them to decompose a pcap — so today is practice for that.
-->

---

## Messages & methods

- **Request line / status line**; SIP grammar; compact headers.
- **Methods:** REGISTER, INVITE, ACK, BYE, CANCEL, OPTIONS, INFO, PRACK, UPDATE,
  SUBSCRIBE/NOTIFY, MESSAGE, REFER, PUBLISH.
- HTTP-shaped, but **stateful in ways HTTP is not** (transactions, dialogs).

<!--
Speaker: Don't drill every method — group them: session (INVITE/ACK/BYE/CANCEL), registration
(REGISTER), query (OPTIONS), events (SUBSCRIBE/NOTIFY/PUBLISH), transfer (REFER). They'll meet the
event package again in provisioning (M14) and presence (M19).
-->

---

## Response classes

- **1xx** provisional · **2xx** success · **3xx** redirect
- **4xx** client error · **5xx** server error · **6xx** global failure
- Know the operational meaning: `401/407` (auth), `403/404`, `486` busy, `487` cancelled,
  `488`, `491`, `503`.

<!--
Speaker: Focus on the security-relevant ones: 401/407 (the challenge you'll exploit and defend in
M13), and the 404-vs-403-vs-401 distinction that *leaks whether a user exists* — that's enumeration
(T2). Make them feel the difference between codes as an information leak.
-->

---

## Headers that matter

- **Via + branch magic cookie** (`z9hG4bK`) — transaction identity + loop detection.
- **From/To (+tags)**, **Call-ID**, **CSeq** — the dialog identifiers.
- **Route / Record-Route** — how a proxy stays in the path.
- **Max-Forwards**, Contact, Expires, Allow/Supported/Require, **Authorization / WWW-Authenticate**,
  **P-Asserted-Identity**, Diversion/History-Info.

<!--
Speaker: Via/branch is the one to slow down on — the magic cookie guarantees a transaction id that's
unique and RFC-3261-compliant, and it's how you correlate request↔response in a capture. Call-ID +
tags = dialog. Circle P-Asserted-Identity: it's how networks *assert* identity, and why it's
dangerous when trusted from outside (M13).
-->

---

## Transactions vs. dialogs

- **Transaction** = one request + its responses (client/server).
- **The INVITE 3-way:** INVITE → 2xx → **ACK**.
- **ACK is special:** part of the INVITE transaction for non-2xx, a **new** transaction for 2xx.
- **Dialog** = the longer relationship, keyed by **Call-ID + tags**.

<!--
Speaker: The ACK asymmetry is a classic exam question and a real source of bugs. For a failure
(non-2xx) the ACK is hop-by-hop inside the transaction; for success (2xx) it's end-to-end, a new
transaction — because only the endpoints know the call succeeded. Draw it.
-->

---

## Routing: loose, strict, Record-Route

- **Via** is built up on the way out, unwound on the way back.
- **Loose routing** (modern) vs. strict routing (legacy, avoid).
- **Record-Route** = "keep me in the path for the whole dialog" (proxies that must stay inline).

<!--
Speaker: Record-Route is why a stateful proxy/SBC sees BYE, re-INVITEs, everything — essential for
billing, media anchoring, and security enforcement. Tie it back: the SBC stays in path *on purpose*.
Strict routing is a security-relevant legacy footgun; mention and move on.
-->

---

## Forking, registration & B2BUA

- **Registration lifecycle:** bind, re-register, Expires; forking **parallel vs. sequential**.
- **Forwarding:** busy / no-answer / voicemail; Replaces, Diversion, History-Info.
- **Proxy modes:** stateless vs. stateful; **redirect (3xx)**; **B2BUA** — what it hides and breaks.

<!--
Speaker: Forking = one INVITE, many phones ring; the CANCEL race to the losers is in the lab. B2BUA
is the recurring theme: it breaks end-to-end (identity, some headers) in exchange for control. That
trade — control vs. transparency — is a security decision, not just plumbing.
-->

---

## Packet reality

- Line-by-line read of a real **INVITE + 200 OK**; follow **Via/branch** to correlate.
- **Registration trace:** 401 challenge → authenticated REGISTER.
- **Forking trace:** two 180s, one 200, CANCEL to the loser.
- Tools: `sngrep` ladder · Wireshark "Follow SIP" · HOMER correlation.

<!--
Speaker: This is the heart of the module — spend the time in captures, not slides. Have them trace
one transaction end to end by branch id, then find the dialog by Call-ID+tags. The 401 trace sets
up M13; the forking trace makes the transaction/dialog split concrete.
-->

---

## Attack / Defend

- **Header trust:** From / P-Asserted-Identity **aren't authenticated** by default → spoofing **(T7)**.
- **Registration hijack (T3):** an unauthenticated REGISTER is fatal — **challenge everything**.
- **CSeq / Call-ID / tag** manipulation, replay, Max-Forwards loops.
- **Defense:** auth REGISTER/INVITE · strip internal `Via`/`Record-Route` at the edge (topology
  hiding) · sane Max-Forwards · reject malformed (fuzzing preview, M15).

<!--
Speaker: The takeaway: SIP trusts its own headers, and trust without authentication is the root of
most VoIP attacks. Topology hiding (stripping internal Via/Record-Route on egress) is in the lab —
it stops you leaking your internal network map to anyone who reads a response.
-->

---

## Labs

- **Lab 2.1** — Three pcaps: identify each transaction/dialog; explain every non-2xx.
- **Lab 2.2** — Force and read a **401 challenge**; annotate the auth round-trip.
- **Lab 2.3** — Sequential + parallel **forking**; capture and explain the CANCEL race.
- **Lab 2.4 (defense)** — In Kamailio, strip internal `Via`/`Record-Route` on egress; prove
  topology hiding in a capture.

*Rubric:* accurate transaction/dialog decomposition · correct auth trace · working forking ·
verified header stripping.

<!--
Speaker: 2.1 is the exam rehearsal. 2.4 is their first hands-on defensive config — and the "before"
capture (internal topology leaking) vs "after" is a satisfying proof. Make them keep both captures.
-->

---

## Takeaways & quick check

- **Transaction ≠ dialog**; branch keys one, Call-ID+tags key the other.
- SIP **trusts its own headers** — authenticate and strip at the edge.
- The B2BUA/SBC trades transparency for **control** (and enforcement).

**Check:** Why is ACK inside the INVITE transaction for non-2xx but a new transaction for 2xx?
What does the branch magic cookie guarantee? Which two headers most enable caller-ID spoofing?

<!--
Speaker: Answers — 2xx success is only known end-to-end so its ACK is a fresh end-to-end
transaction; the `z9hG4bK` cookie guarantees an RFC-3261 globally-unique transaction id (correlation
+ loop detection); From and P-Asserted-Identity enable spoofing because the base protocol never
authenticates them — the gap STIR/SHAKEN fills in M13. Straight into Module 3: the SDP body.
-->
