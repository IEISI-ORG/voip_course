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

## Answer key & rubric (instructor)

- **1.** NAPTR → SRV → A/AAAA; NAPTR service field (e.g. `SIPS+D2T`) selects transport. (M9D/M1)
- **2.** RFC 3261 magic cookie marks RFC-3261 branch IDs; guarantees the branch is a **unique
  transaction identifier** across a message's Via chain (loop/retrans detection). 
- **3.** Non-2xx ACK is hop-by-hop, absorbed by the INVITE server transaction (reliability of the
  final response); 2xx ACK is end-to-end (new transaction) because only the UAC knows the 2xx
  won. Mishandling → retransmission storms / stuck dialogs.
- **4.** AoR = public identity (`user@domain`); Contact = where it's reachable now. Registration
  binds AoR→Contact for the `Expires` lifetime.
- **5.** Record-Route keeps the proxy in the dialog path for in-dialog requests; `topoh` masks the
  internal Route/Via/Contact so the core topology doesn't leak to the edge (M2/M7).
- **6.** 100 Trying (received, working); 183 Session Progress (early media); 407 Proxy Auth
  Required; 486 Busy Here; 488 Not Acceptable Here (codec/SDP); 491 Request Pending (glare).
- **7.** B2BUA (or SBC as B2BUA): terminates/re-originates signaling; exists for control/topology/
  interop; hides internal topology, breaks end-to-end identity/`Replaces`/some headers. (T7 enabler)
- **8.** `c=` connection address, `m=` media type/port/codecs; unauthenticated → an attacker who
  edits them redirects/hijacks RTP (T9/T5).
- **9.** 160 B payload + 40 B (RTP/UDP/IP) = 200 B × 50 pps × 8 = **80 kbps** one-way.
- **10.** Forces media through the anchor (rtpengine) so endpoints only send to the border with
  strict source checks → mitigates **T9** (RTP injection/redirect) and aids T5.
- **11.** Re-INVITE with `a=sendonly`/`c=0.0.0.0`; abuse: media cut/redirect, or state churn
  (re-INVITE flood).
- **12.** Fixed 40 B header per packet; smaller ptime → more packets/s → higher header %:
  G.711@20 ms = 80 kbps vs @30 ms ≈ 74.7 kbps L3.
- **13.** (i) NAT/media path (asymmetric RTP) — check where RTP is actually sent/receive 5-tuple;
  (ii) codec/SDP direction (`sendonly`) — check the answer SDP direction attributes.
- **14.** `tshark -r f.pcap -Y 'sip.Status-Code >= 400' -T fields -e sip.Call-ID -e sip.Status-Code | sort -u`.
- **15.** Capture before TLS if you only have on-path access (ciphertext otherwise); decrypt after
  only with the server key/keylog and authorization. Encryption is the reason plaintext capture
  fails post-M10.
- **16.** A shared correlation key — the SIP **Call-ID** (plus tags) carried in HEP from each
  capture agent lets HOMER stitch the hops.
- **17.** e.g.: reproduce → capture at the edge → confirm request arrives → follow the transaction
  (Via/CSeq) → isolate the first non-2xx/timeout → check that hop's config/logs → fix → re-verify.
- **18.** (a) T1 scanning → rate-limit/UA-hide/fail2ban; (b) T2 enumeration → uniform responses +
  delay; (c) T5 eavesdropping → SRTP; (d) T7 spoofing → STIR/SHAKEN + PAI trust policy.
- **19.** Network (edge/redteam only), procedural (authorized-use banner), tooling (scope guard).
  Network alone fails if a tool is pointed at an in-scope-but-unauthorized host, or the container
  is later re-homed — controls should encode the RoE, not rely on the operator.
- **20.** (a) contains PCI/PII (PAN, PIN) → storage/retention liability; (b) drop RTP/RTCP (audio +
  DTMF telephone-events), keep SIP; (c) sha256 original + redacted, signed custody record with
  operator/time; (d) keep **signaling** (diagnosis), drop **media** (the sensitive payload).

### Grading
| Part | Pts | Notes |
|------|-----|-------|
| A protocol | 30 | partial credit per item |
| B SDP/media | 20 | math must be shown for 9/12 |
| C analysis | 20 | Q14 must be a working expression |
| D security | 30 | **gate: ≥15 required to pass overall** |
| **Pass** | **≥70** | and Security ≥ 50% |
