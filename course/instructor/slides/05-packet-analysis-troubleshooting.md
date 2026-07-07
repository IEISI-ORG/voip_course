---
marp: true
theme: default
paginate: true
title: Module 5 — Packet Analysis & Troubleshooting
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Module 5 — Packet Analysis & Troubleshooting

**Master the OSS analysis toolchain and a repeatable fault-isolation method.**

`Est. 4h` · Prereqs: Modules 2–4 · **Checkpoint exam #1 after this module**

<!--
Speaker: This module consolidates M2–M4 into a skill: reading captures to solve problems. It's also
the last stop before checkpoint exam #1, so today doubles as review. Emphasise *method* over tools —
tools change, the fault-isolation discipline doesn't.
-->

---

## What you'll leave with

- **Capture correctly** (where, what, at scale) and preserve **evidence integrity**.
- Drive **Wireshark/tshark, sngrep, HOMER/HEP** to diagnose signaling + media faults.
- Apply a **systematic method** to real SIP failures.

<!--
Speaker: The checkpoint asks them to diagnose a trace cold. So today's success metric is: given a
pcap, they find the plane and the *first* anomaly quickly and defend the root cause.
-->

---

## Capture strategy

- **Where to tap:** endpoint vs. edge vs. core — the answer changes what you can see.
- SPAN/mirror, **ring buffers** for long captures.
- **Capture filters vs. display filters** (BPF vs. Wireshark).
- **TLS:** capture *pre-encryption*, or decrypt with keys — you can't have plaintext without one.

<!--
Speaker: The single most common mistake is capturing at the wrong point and "not seeing" the
problem. If signaling is TLS, a mid-path tap shows ciphertext — you must capture before encryption or
supply keys. This is also a checkpoint question. Capture filters shrink the file; display filters
shrink the view.
-->

---

## The toolchain

- **Wireshark:** SIP/SDP/RTP dissectors, **VoIP Calls** window, flow sequence, Follow stream,
  **RTP player**, `tshark` for automation + big files.
- **sngrep:** live ladder from an interface or pcap; filter by Call-ID/method; save pcap.
- **HOMER 7 + Heplify (HEP):** centralized capture, **cross-hop correlation**, KPIs, retention —
  the operator's *flight recorder*.

<!--
Speaker: Match tool to job: sngrep for a fast live ladder, Wireshark for deep single-capture
analysis, tshark for automation/huge files, HOMER for "what happened across all hops last Tuesday."
HOMER's correlation is what makes multi-hop incidents (M17) tractable.
-->

---

## The troubleshooting method

1. **Reproduce.**
2. **Capture at the right point.**
3. **Isolate the plane** — signaling vs. media.
4. **Read the first anomaly, not the last.**
5. **Form and test a hypothesis.**

<!--
Speaker: Drill #4 relentlessly — people fixate on the final error (e.g., a BYE or a 503) when the
root cause was three messages earlier. Signaling-vs-media isolation (#3) instantly halves the search
space: no-audio-but-call-connects is a media problem, period.
-->

---

## Response-code triage

- **4xx** client · **5xx** server · **6xx** global — a decision tree, not memorisation.
- Classic faults: **one-way audio** (NAT), **488** (codec mismatch), **407 loop** (auth realm),
  **480/503** (registration/overload), **no ringback** (early media).

<!--
Speaker: Map each classic symptom to its usual plane and cause. One-way audio → media/NAT (M8);
488 → SDP codec mismatch (M3); 407 loop → auth realm/credential mismatch (M13). These five cover a
huge fraction of real tickets and several exam questions.
-->

---

## Packet reality: the fault library

- Diagnose a curated set from pcaps:
  - **one-way audio** (NAT) · **488** (codec) · **407 loop** (auth realm)
  - **480/503** (registration/overload) · **no ringback** (early media)

<!--
Speaker: This is the core of the module — hands in captures. For each, have them state plane, first
anomaly, root cause, and fix in one paragraph. That format is exactly the checkpoint answer shape.
Time-box each so they build speed.
-->

---

## Build (OSS)

- Wire **Heplify** agents on `edge-sbc` / `pbx-*`; confirm HOMER receives HEP; build a **KPI dashboard**.
- Automate triage with **tshark** — e.g., extract Call-IDs with non-2xx final responses.

<!--
Speaker: Getting HEP flowing is the prerequisite for all later observability (M17). The tshark
automation is their first taste of turning manual analysis into a repeatable script — a habit that
scales from one call to a platform.
-->

---

## Attack / Defend — captures are sensitive

- **Evidence integrity & chain of custody:** hash pcaps, record timestamps, control access —
  needed for IR (M17) and fraud cases.
- **Captures contain secrets/PII:** SDP, **DTMF card numbers (inband!)**, recordings → redact,
  encrypt, restrict.
- **Detect recon in captures:** svmap / OPTIONS sweeps, enumeration patterns (feeds M15/M16).

<!--
Speaker: Flip the frame: the capture that helps you debug is a data-protection liability. Inband DTMF
can carry card numbers in the clear — that's a PCI problem living in your pcaps. Handling captures
(hash, redact, encrypt, access-control) is itself a security control, not just hygiene.
-->

---

## Labs

- **Lab 5.1** — Six fault pcaps: diagnose each with a one-paragraph root cause + fix.
- **Lab 5.2** — Stand up HOMER capture across the platform; correlate a multi-hop call.
- **Lab 5.3** — A `tshark` one-liner listing all calls with a 4xx/5xx final response.
- **Lab 5.4 (security)** — Redact DTMF/PII from a pcap and **hash it for evidence**.

*Rubric:* correct root causes · working HOMER correlation · automation script · proper evidence handling.

<!--
Speaker: 5.1 is direct checkpoint prep. 5.4 makes the "captures are sensitive" lesson concrete — they
redact real PII and produce a hashed, defensible evidence file. That evidence discipline carries into
the IR runbooks in M17.
-->

---

## Takeaways & quick check

- **Capture at the right point** or you'll debug the wrong thing.
- Read the **first** anomaly; isolate the **plane**.
- Captures are **evidence and liability** — hash, redact, control.

**Check:** For a one-way-audio call, which plane and first anomaly? When capture *before* TLS vs.
decrypt after? Why are captures a data-protection liability, and how do you mitigate it?

<!--
Speaker: Answers — one-way audio is a media-plane problem (usually NAT/SDP address), first anomaly is
RTP not flowing to the right 5-tuple, not the eventual BYE; capture before TLS when you lack keys
(mid-path only sees ciphertext otherwise); captures hold SDP/DTMF/PII so you hash for integrity,
redact PII, encrypt, and restrict access. This closes the protocol block — checkpoint #1, then
Module 6 starts the build.
-->
