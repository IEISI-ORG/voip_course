# Checkpoint Exam #1 — Protocol & Analysis (after M5)

Covers **M0–M5**: lab/segmentation, SIP foundations, core protocol, SDP, RTP/QoS, packet
analysis, and the security threads introduced so far (T1, T2, T5, T7, T10, evidence handling).

- **Format:** 20 items, 100 points. **Pass ≥ 70** (and ≥ 50% on the Security section).
- **Open-book** (RFCs, your notes, the lab). Time: 90 minutes.
- Answer key + rubric at the bottom (instructor copy — the two are split in delivery).

---

## Part A — SIP protocol (30 pts)

1. (4) In what order does a UAC locate a SIP server per RFC 3263, and what decides the transport?
2. (4) Explain the **branch magic cookie** (`z9hG4bK`) and what it guarantees.
3. (4) Why is ACK part of the INVITE transaction for a non-2xx final response but a **separate**
   transaction for a 2xx? What breaks if you get this wrong?
4. (4) Distinguish **AoR** from **Contact**; what does registration bind, and for how long?
5. (4) A proxy adds `Record-Route`. What problem does that solve, and what does `topoh` do to it
   at the edge?
6. (5) Give the operational meaning of each: `100`, `183`, `407`, `486`, `488`, `491`.
7. (5) Which SIP entity **breaks end-to-end signaling identity**, why does it exist, and name one
   thing it hides and one thing it breaks.

## Part B — SDP & media (20 pts)

8. (4) In SDP offer/answer, what do the `c=` and `m=` lines specify, and why are they a security
   problem when unauthenticated?
9. (4) A call negotiates `PCMU` at ptime 20 ms. State the one-way L3 bandwidth and show the math.
10. (4) What does `direct_media=no` / media anchoring achieve, and which threat (ID) does it
    mitigate?
11. (4) Explain a hold/re-INVITE and one way it can be abused.
12. (4) Why does a smaller ptime *reduce* efficiency? Quantify with two ptimes for G.711.

## Part C — Analysis & troubleshooting (20 pts)

13. (4) A call has audio in only one direction. Name the two most likely causes and the first
    packet-level thing you'd check for each.
14. (4) Write a `tshark` expression that lists calls with a 4xx/5xx final response.
15. (4) When must you capture **before** TLS encryption vs. **decrypt after**, and why?
16. (4) In HOMER, what makes multi-hop **correlation** of one call possible?
17. (4) Give a repeatable fault-isolation method (ordered steps) for "call setup fails."

## Part D — Security (30 pts) — *must score ≥ 15/30*

18. (8) Map each to a threat ID and one concrete defense: (a) OPTIONS/REGISTER sweeps, (b) 401/404
    response deltas during registration, (c) sniffing RTP on-path, (d) forged `From`/PAI.
19. (8) The lab's `redteam` container is fenced three ways. Name each layer and why network-level
    isolation alone is insufficient.
20. (14) **Scenario.** You captured a production call for troubleshooting; it contains a spoken
    credit-card number and DTMF-entered PIN.
    (a) Why is this capture a liability?
    (b) Describe a redaction that preserves diagnosability.
    (c) How do you make the artifact tamper-evident and maintain chain of custody?
    (d) Which plane do you keep, which do you drop, and why?

---

## Answers

> The answer key and rubric are held separately (instructor-only), one directory deeper:
> [`answer-keys/checkpoint-exam-1-key.md`](answer-keys/checkpoint-exam-1-key.md).
> Learners get the exam without adjacent answers.

### Grading (weighting)
| Part | Pts | Notes |
|------|-----|-------|
| A protocol | 30 | partial credit per item |
| B SDP/media | 20 | math must be shown for 9/12 |
| C analysis | 20 | Q14 must be a working expression |
| D security | 30 | **gate: ≥15 required to pass overall** |
| **Pass** | **≥70** | and Security ≥ 50% |
