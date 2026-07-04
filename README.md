# VoIPSec — Secure Open-source VoIP Operations Certificate

An open-source, security-first VoIP training course modelled on The SIP School's SSCA "Elite"
programme but rebuilt around open-source tools and an emphasis on **secure VoIP operations**.
It pairs a written curriculum (18 modules + a DNS module + capstone) with a single, growing,
reproducible **Docker lab** that learners build, attack, defend, and operate across the course.
Completing it earns the **Certified VoIPSec Operator (CVO)** credential.

> Status: **build backlog complete** — full curriculum, lab, all graded labs, assessments, capstone harness, instructor material + rendered slides, CI, references. See **Progress**.

## What's here

| Path | What it is |
|------|-----------|
| [`course/00-course-overview.md`](course/00-course-overview.md) | Master design: outcomes, module map, assessment model, security spine |
| [`course/modules/`](course/modules/) | Per-module deep dives (5-beat: concept → packet → build → attack/defend → lab) |
| [`course/assessments/`](course/assessments/) | Checkpoint exams (answer keys + rubrics) |
| [`course/references/`](course/references/) | Bibliography (RFCs/standards/KBs) + glossary |
| [`course/requirements-traceability.md`](course/requirements-traceability.md) | Requirements → status → evidence matrix |
| [`course/README.md`](course/README.md) | Course index + SIP School → VoIPSec coverage crosswalk |
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
pushed. Reviewer feedback dropped as `feedback*.txt`/`.md` in the repo root is processed with
priority, then deleted (feedback files are gitignored — ephemeral steering, not repo content;
what each asked is recorded in the build-plan feedback log and the traceability matrix). Security
findings from automated review are addressed and logged.

## Progress

<!-- PROGRESS:START (updated each iteration) -->
- **Iteration:** 60 · **Date:** 2026-07-04 · **HEAD:** `git log --oneline -1`
- **Design:** ✅ complete — 18 modules + M9D (DNS Infrastructure) + capstone
- **Stage A (lab foundation):** ✅ complete (8 services)
- **Stage B (per-module labs):** ✅ complete — all 18 module labs (M0–M17), each with a `verify.sh`
- **Assessments:** ✅ all 3 checkpoint exams (keys held separately in `assessments/answer-keys/`)
- **Feedback-driven BF labs:** ✅ **all 14 done (BF1–BF14)**
- **Consistency audit:** ✅ complete (3 passes) · **Requirements audit:** ✅ complete (6 passes) — see [`course/requirements-traceability.md`](course/requirements-traceability.md)
- **CI:** `.github/workflows/ci.yml` (shell/YAML lint, compose config, offline graders) · **Testing:** `make verify-all` + `make smoke` (end-to-end)
- **References:** [bibliography](course/references/bibliography.md) + [glossary](course/references/glossary.md) + `verify-bibliography.sh`
- **Backlog:** ✅ all items complete (E0/E3 are ongoing `[~]`). Deferred: `.claude`/SSCA-PDF history purge (user)
- Full detail: [`course/build_plan.md`](course/build_plan.md) (iteration log).
<!-- PROGRESS:END -->

## License / use

Licensed **CC BY-NC-SA 4.0** — free to learn from, run, teach, and adapt for **non-commercial**
use with attribution and share-alike. Commercial/for-profit use needs a separate licence (royalty);
see [`LICENSE`](LICENSE). Contributions welcome under [`CONTRIBUTING.md`](CONTRIBUTING.md) (issue
first, approval-gated) — contributors are credited in [`CONTRIBUTORS.md`](CONTRIBUTORS.md).

Training material for **authorized** security education. Offensive tooling targets only the
local lab; testing systems without written authorization is illegal. See
[`lab/services/redteam/AUTHORIZED_USE.md`](lab/services/redteam/AUTHORIZED_USE.md).
