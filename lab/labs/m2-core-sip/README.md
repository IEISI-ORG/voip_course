# Lab M2 — Core SIP Protocol Deep Dive

**Module:** [M2](../../../course/modules/02-core-sip-protocol.md) · **Est.** 5h ·
**Prereqs:** M1.

Goal: read and reason about every part of a SIP transaction and dialog, and prove two protocol
invariants at the border. Much of M2 is *analysis* — graded by rubric, not a script.

## Auto-graded invariants
```bash
bash labs/m2-core-sip/verify.sh
```
Asserts (fail-closed): the REGISTER transaction traverses the SBC (200), and **Max-Forwards: 0
→ 483 Too Many Hops** (loop protection). Exit 0 = these invariants hold.

## Lab 2.1 — Decompose transactions & dialogs  (30 pts)
Generate and read traffic:
```bash
bash labs/m2-core-sip/trace.sh                 # raw OPTIONS response to annotate
bash labs/m0-orientation/gen-call.sh 1002      # a call to follow in sngrep/HOMER
```
Identify each **transaction** (Via/branch) and **dialog** (Call-ID + tags); explain every
non-2xx you see. Correlate in HOMER (`make obs-up`).

**Deliverable:** annotated ladder with transaction/dialog boundaries + a note on each non-2xx.

## Lab 2.2 — Authentication round-trip  (20 pts)
Read the challenge/response model. The edge-sbc **stubs auth until M12**, so today you trace the
REGISTER→200; once M12 is applied, re-run to capture the real `401 WWW-Authenticate` → digest
`Authorization` round-trip and annotate the nonce/realm/qop.

**Deliverable:** the REGISTER trace now + a note on where the 401 will appear post-M12.

## Lab 2.3 — Forking & the CANCEL race  (25 pts)
Register the same AoR from two clients (parallel forking), call it, and capture the two `180`s,
the winning `200`, and the `CANCEL` to the loser. (Use two `baresip` instances or two SIPp
UACs registering the same extension.)

**Deliverable:** capture showing the fork + CANCEL, with the dialog that won identified.

## Lab 2.4 (defense) — Topology hiding  (25 pts)
The edge-sbc uses `topoh` to mask internal `Via`/`Record-Route`/`Contact`. Capture a call on the
edge side and prove **no `core` address (172.28.20.x) leaks** to the external client.

**Deliverable:** edge-side capture showing masked routing headers (no core IPs).

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` invariants (REGISTER, MF=0→483) | — | required to pass 2.1 |
| 2.1 transaction/dialog decomposition | 30 | rubric |
| 2.2 auth round-trip understanding | 20 | rubric |
| 2.3 forking + CANCEL race captured | 25 | capture |
| 2.4 topology hiding verified (no core IP leak) | 25 | capture |
