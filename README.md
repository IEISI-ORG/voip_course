# SOVOC — Secure Open-source VoIP Operations Certificate

An open-source, security-first VoIP training course modelled on The SIP School's SSCA "Elite"
programme but rebuilt around open-source tools and an emphasis on **secure VoIP operations**.
It pairs a written curriculum (18 modules + a DNS module + capstone) with a single, growing,
reproducible **Docker lab** that learners build, attack, defend, and operate across the course.

> Status: **active build** via an autonomous iteration loop. Design layer complete; the runnable
> lab and per-module graded labs are being built module-by-module. See **Progress** below.

## What's here

| Path | What it is |
|------|-----------|
| [`course/00-course-overview.md`](course/00-course-overview.md) | Master design: outcomes, module map, assessment model, security spine |
| [`course/modules/`](course/modules/) | Per-module deep dives (5-beat: concept → packet → build → attack/defend → lab) |
| [`course/assessments/`](course/assessments/) | Checkpoint exams (answer keys + rubrics) |
| [`course/references/bibliography.md`](course/references/bibliography.md) | RFCs, standards, and package knowledge-base citations |
| [`course/reviews/`](course/reviews/) | Incorporated reviewer feedback (archived) |
| [`course/README.md`](course/README.md) | Course index + SIP School → SOVOC coverage crosswalk |
| [`lab/`](lab/) | The reproducible Docker lab (SBC, PBXs, trunk, clients, observability, red-team) |
| [`lab/labs/`](lab/labs/) | Per-module hands-on labs with `verify.sh` auto-graders |

## Plan & progress reports

- **Build plan + iteration log:** [`course/build_plan.md`](course/build_plan.md) — the backlog,
  per-iteration progress, feedback log, and security-review log.
- **Original design plan:** [`course/task_plan.md`](course/task_plan.md).

## The lab in one glance

Four segmented Docker networks — `edge` (untrusted), `core` (trusted), `mgmt` (observability),
`redteam` (isolated) — with Kamailio+rtpengine SBC, Asterisk and FreeSWITCH PBXs, a SIPp PSTN
simulator, a softphone/load-test client, an (profile-gated) HOMER/Prometheus/Grafana/Loki/Wazuh
stack, and a scope-guarded offensive toolbox. Quick start in [`lab/README.md`](lab/README.md).

## How this repo is built

Content is produced by an autonomous loop, one coherent unit per iteration, each committed and
pushed. Reviewer feedback dropped as `feedback*.md`/`.txt` in the repo root is processed with
priority. Security findings from automated review are addressed and logged.

## Progress

<!-- PROGRESS:START (updated each iteration) -->
- **Iteration:** 24 · **Date:** 2026-07-02 · **HEAD tracks:** see `git log --oneline -1`
- **Stage A (lab foundation):** ✅ complete (edge-sbc, rtpengine, pbx-a, pbx-b, trunk-sim, client, observability, redteam)
- **Stage B (per-module labs):** M0–M9 done; **next: M10 (signaling security TLS/SIPS)**
- **References:** [bibliography](course/references/bibliography.md) started (RFCs/standards/package KBs)
- **Testing:** `make verify-all` runs every module grader (`lab/verify-all.sh`)
- **Assessments:** Checkpoint Exam #1 (M0–M5) done, answer key held separately; #2/#3 pending
- **Modules added from feedback:** M9D (DNS Infrastructure); curriculum additions BF1–BF14
- Full detail: [`course/build_plan.md`](course/build_plan.md) (iteration log).
<!-- PROGRESS:END -->

## License / use

Training material for **authorized** security education. Offensive tooling targets only the
local lab; testing systems without written authorization is illegal. See
[`lab/services/redteam/AUTHORIZED_USE.md`](lab/services/redteam/AUTHORIZED_USE.md).
