# Lab M1 — VoIP & SIP Foundations

**Module:** [M1](../../../course/modules/01-voip-sip-foundations.md) · **Est.** 3h ·
**Prereqs:** M0, TCP/IP.

Goal: see the two-plane call model for real (signaling vs media), identify SIP entities on the
wire, map your attack surface, and start the **living threat model** you carry all course.

## Lab 1.1 — Register, call, annotate the flow  (40 pts)
1. Bring the lab up (`make up`) and confirm the signaling path with the auto-grader:
   ```bash
   bash labs/m1-foundations/verify.sh        # asserts REGISTER traverses the SBC
   ```
2. Generate a call to capture and annotate:
   ```bash
   bash labs/m0-orientation/gen-call.sh 1002
   ```
3. In sngrep/Wireshark, label **every** message and which plane it belongs to:
   REGISTER (signaling) → INVITE/100/180/200 (signaling) → RTP (media) → BYE (signaling).

**Deliverable:** annotated flow (screenshot/pcap) + the `M1 ACCEPTANCE: PASS` line.

## Lab 1.2 — Passive recon of your own PBX  (25 pts)
```bash
bash labs/m1-foundations/probe-banner.sh 172.28.10.10   # OPTIONS to the SBC
```
Record what a scanner learns: the `Server`/`User-Agent` header (does it say "SBC" or leak
"kamailio/x.y"?), the `Allow` methods, and response codes. Compare with an OPTIONS straight to
a PBX in the core (note the SBC's topology hiding).

**Deliverable:** the captured response + 3 concrete pieces of information a default UA leaks.

## Lab 1.3 — Start the living threat model  (25 pts)
```bash
cp labs/m1-foundations/threat-model-template.md threat-model.md   # in your working copy
```
Fill in assets, entry points, trust boundaries, and the first threats (T1/T2/T5/T7). Commit it;
you extend this file in every module.

**Deliverable:** committed `threat-model.md` with all five sections populated.

## Entities check (10 pts)
Identify, in your capture, which component acts as UAC, UAS, registrar, and proxy/SBC, and
explain where end-to-end identity is broken (and what that enables).

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Evidence |
|------|-----|----------|
| 1.1 flow annotated + `verify.sh` PASS | 40 | pcap/flow + PASS line |
| 1.2 recon: leaked info recorded | 25 | OPTIONS response + findings |
| 1.3 living threat model started | 25 | committed threat-model.md |
| Entity identification correct | 10 | short write-up |

**Auto-graded core:** `verify.sh` exit 0 required for Lab 1.1.
