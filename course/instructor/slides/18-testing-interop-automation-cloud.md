---
marp: true
theme: default
paginate: true
title: Module 18 — Testing, Interop, Automation & Cloud Deployment
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Module 18 — Testing, Interop, Automation & Cloud Deployment

**Validate at scale, prove interoperability, and deploy the whole platform as code.**

`Est. 5h` · Prereqs: Modules 6–16

<!--
Speaker: This module makes the platform *repeatable and provable*. Testing at scale, fixing interop,
and deploying as code — with security baked into the pipeline, not bolted on. Theme: if a control
isn't in the pipeline and tested on every change, it will rot. Automation is how security survives.
-->

---

## What you'll leave with

- Write **SIPp scenarios** for load, regression, and conformance testing.
- Diagnose **interop failures** and fix them with SBC message manipulation.
- Deploy reproducibly with **containers + IaC** and a **secure CI pipeline**.

<!--
Speaker: Exam angles: design a SIPp test for max sustainable CPS without media starvation, the classic
container-VoIP networking pitfall, and three controls that make a CI/CD pipeline secure-by-default.
Keep "tested on every change" as the refrain.
-->

---

## Testing types

- Functional / regression · **load/capacity** (CPS, concurrent calls) · soak · chaos (kill a PBX) ·
  conformance.
- **SIPp deeply:** XML scenarios (UAC/UAS), variables, RTP echo/playback, TLS/SRTP scenarios,
  rate control (`-r`, `-rp`), response assertions; SIPp as `trunk-sim`.

<!--
Speaker: SIPp is the workhorse — the same tool that simulated the carrier (M9) now load-tests and
regression-tests. Chaos testing (kill a PBX mid-load) validates the M7 HA work. The key security
testing type is *regression*: prove a hardening control still holds after every config change.
-->

---

## Interoperability

- RFC 3261 **interpretation differences**; header/behaviour mismatches.
- **SBC message manipulation / normalization** (Kamailio `textops`, OpenSIPS, rtpengine) to bridge quirks.
- SIPconnect; capture + compare vendor traces.

<!--
Speaker: Callback to M2 — "compliant" implementations differ, and the SBC is where you paper over the
differences. Message manipulation is powerful and security-relevant: the same rewrite that fixes an
interop bug can also strip a dangerous header or normalize malformed input. Capture-compare is how you
prove the fix.
-->

---

## Automation / IaC

- **Docker/compose** (lab) · **Kubernetes** (scale/HA) · **Ansible** (config) · **Terraform** (infra).
- The **parity principle:** same topology dev → prod (including security policy).
- **Cloud pitfalls:** NAT, host networking for RTP, wide port ranges, stateful media, autoscaling limits.

<!--
Speaker: Parity is the security point: if dev and prod differ, your tested controls aren't the ones
running in prod. IaC makes the whole platform — including nftables rules, TLS config, ACLs —
version-controlled and reviewable. The RTP-in-containers problem (next slide) is where teams take
insecure shortcuts.
-->

---

## Cloud-native VoIP networking & pod security

- RTP needs **thousands of UDP ports per pod** → the container media problem.
- **NodePort** (limited) vs. **`hostNetwork: true`** (full host stack, high blast radius) vs.
  **Multus CNI** (dedicated media interface per pod).
- **Pod Security Standards (restricted):** drop caps, non-root, **reject privileged `hostNetwork`**.

<!--
Speaker: This is the module's sharpest security lesson. `hostNetwork: true` "solves" the RTP port
problem but gives a compromised media pod the whole host network stack — a container escape becomes a
node pivot. Multus gives a dedicated media interface without that blast radius. PSA (restricted) is
the admission control that rejects the dangerous shortcut. This is the SBC trust boundary, containerised.
-->

---

## Secure pipelines

- **Secrets in CI** (never in git), **image scanning**, config **linting**, **signed artifacts**,
  **config-drift detection**.
- Least-privilege deploy credentials.
- **Fuzz/conformance as security testing (T10):** malformed-message SIPp scenarios in CI to catch
  parser regressions **before prod**.

<!--
Speaker: The pipeline is attack surface too — leaked CI secrets, unsigned images, and drift are real
breach vectors. The elegant move: put the RFC 4475 torture suite (M15) *in CI* so a parser regression
fails the build, not production. Security tests that run on every commit are the ones that actually
hold. Drift detection catches the "someone changed it by hand at 2am" problem.
-->

---

## Packet reality

- Run a **SIPp load test**; watch KPIs (M17) under a CPS ramp; find the **break point**.
- Capture an **interop mismatch** (a required header a peer rejects) and the post-manipulation fix.

<!--
Speaker: Finding the break point is capacity planning *and* DoS-resilience data — you learn where the
platform falls over before an attacker (or Black Friday) finds it for you. Watching M17 dashboards
under the load ramp connects testing to observability. The interop before/after proves the SBC fix.
-->

---

## Build (OSS)

- Author 3 SIPp scenarios: **register storm**, **INVITE load with RTP**, **malformed-message regression**.
- Fix a simulated interop bug via **Kamailio header manipulation**; prove with before/after captures.
- Convert the lab to: (a) `docker compose` prod-like, (b) Ansible-provisioned VMs, (c) Terraform cloud
  skeleton; **CI job** lints configs + runs SIPp smoke + image scan.

<!--
Speaker: The three SIPp scenarios cover capacity, function, and security (the malformed regression).
The IaC trio shows the same platform expressed three ways — parity in action. The CI job is the
deliverable that keeps security alive: every change gets linted, smoke-tested, and scanned.
-->

---

## Labs / Deliverable

- **Lab 18.1** — SIPp scenarios for load + regression; report **capacity + failure mode**.
- **Lab 18.2 (interop)** — Diagnose + fix an interop failure with SBC message manipulation.
- **Lab 18.3 (IaC)** — One-command deploy via compose + Ansible/Terraform; **CI runs config lint +
  SIPp smoke + image scan on every change**.

*Rubric:* working scenarios + capacity numbers · interop fix proven · reproducible secure deploy.

<!--
Speaker: 18.3 is the operational-maturity keystone — a one-command reproducible deploy with security
gates in CI. That's the difference between a lab and a platform someone can actually run. The capacity
numbers from 18.1 feed the capstone's operational story.
-->

---

## Takeaways & quick check

- **Tested-on-every-change** is how security survives — put fuzz/regression in CI.
- **Parity dev→prod** — your tested controls must be the ones that run.
- **Don't `hostNetwork` your media pods** — Multus + PSA restricted instead.

**Check:** Design a SIPp test for max sustainable CPS without media starvation. Why is host/RTP
networking the classic container-VoIP pitfall, and how do you solve it? Three controls for a
secure-by-default CI/CD pipeline?

<!--
Speaker: Answers — ramp CPS with real RTP attached and assert on MOS/answer-rate, stepping until
media quality (not just signaling) degrades — that's the true sustainable CPS. hostNetwork gives
media pods the whole host stack (huge blast radius on escape); solve with Multus CNI (dedicated media
interface) + PSA restricted. Secure CI: secrets out of git (vault-injected), signed+scanned images,
and config lint/drift detection on every change. Next: Frontiers — VoLTE/IMS, FoIP, ENUM/Peering,
UC/UCaaS/CPaaS (M19), checkpoint exam #3.
-->
