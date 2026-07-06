# VoIPSec Course Delivery Guide (D1)

For instructors running VoIPSec — Secure Open-source VoIP Operations Certificate. Covers pacing,
prerequisites, per-cohort lab setup, the assessment flow, and operations.

## 1. Audience & prerequisites
- **Audience:** network/VoIP engineers, SecOps, SREs moving into telephony security.
- **Prereqs:** comfortable Linux CLI; TCP/IP; Docker + Docker Compose v2 basics. No prior SIP
  required (M0–M1 build it).
- **Machine per learner:** ≥ 4 vCPU / 8 GB RAM / 20 GB disk for the base lab; +4 GB RAM if the
  observability profile (`make obs-up`) runs concurrently.

## 2. Structure & pacing
18 modules + M10 (DNS) + capstone; ~100 structured hours, lab-dominant.

| Mode | Duration | Cadence |
|------|----------|---------|
| Self-paced | 8–12 weeks | ~8–12 h/week |
| Instructor-led cohort | 12 weeks | 1 module/week (M5,M13,M19 weeks include the checkpoint exam) |
| Intensive bootcamp | 3 weeks | 6 modules/week; capstone in a 4th week |

Checkpoint exams gate progress after **M5** (protocol), **M13** (build+security), **M19** (operations).

## 3. Per-cohort lab setup
Each learner runs their own copy of [`lab/`](../../lab/):
```bash
cd lab
make init            # create .env from template
# edit .env: set unique strong secrets (SIP_*_SECRET, TOPOH_MASK_SECRET, FS_*, GRAFANA_*, HOMER_*)
make up              # base topology (SBC, PBXs, trunk, client, redteam)
make status && bash labs/m0-orientation/verify.sh    # confirm healthy + segmentation
make obs-up          # observability plane, when M5/M17 need it
```
- **Secrets:** every learner generates their own (`openssl rand -base64 24`); never share/commit
  `.env` (it is gitignored).
- **Isolation:** the `redteam` container is fenced to `edge`/`redteam` by design — offensive labs
  target only the learner's own lab. Restate the authorized-use rule at M0 and every offensive lab.
- **Reset:** `make clean && make up` returns a known-good state (M0 Lab 0.3 proves idempotency).
- **Health at scale:** `make verify-all` runs every module grader; use `--safe` so the M7/M8 ban
  tests restart `edge-sbc` between runs.

## 4. Assessment flow
- **Per module:** hands-on lab with a `verify.sh` auto-grader (fail-closed) + a 100-pt rubric
  (pass ≥ 70). Many graders are self-validating and run offline (CI-covered).
- **Quizzes:** [`assessments/quiz-bank/`](../assessments/quiz-bank/) — per-module MC; a
  self-contained `exam.html` for practice (client-scored; **not proctored** — grade real sittings
  server-side).
- **Checkpoint exams:** three, after M5/M13/M19, each with a **gated Security section**. Question
  files and answer keys are separate — keys live in
  [`assessments/answer-keys/`](../assessments/answer-keys/) (instructor-only).
- **Capstone:** 9 graded deliverables. Score with the harness
  [`assessments/capstone-grading/`](../assessments/capstone-grading/):
  ```bash
  cp scoresheet.csv cohort/<learner>.csv    # fill scores
  bash score-capstone.sh cohort/<learner>.csv
  ```
  **Pass = total ≥ 70 AND no failing security category** (security is mandatory).

## 5. Instructor operations
- **Grading labs:** run the learner's `verify.sh`; require the PASS line as evidence, plus the
  rubric deliverables (captures, configs, threat-model/hardening-checklist updates).
- **Living artifacts:** learners carry a threat model (from M1) and a hardening checklist (from M6),
  extended every module and audited at the capstone.
- **Ethics gate:** an M15 assessment that ignores scope fails regardless of technical quality.
- **References:** cite from [`references/bibliography.md`](../references/bibliography.md); acronyms
  in [`references/glossary.md`](../references/glossary.md).

## 6. Common pitfalls
- Image pulls: pin/verify `FREESWITCH_IMAGE`, `KAMAILIO_TAG`, `sipcapture/*`, `wazuh/*` before a
  cohort (some are community/token-gated).
- Ban side effects: pike/scanner bans expire after ~300 s; wait or `docker compose restart edge-sbc`
  between offensive re-runs.
- Host tools: a few labs validate on the host (`nft`, `named-checkzone`, `tshark`) — install where
  learners will run them.

## 7. Certification
The **Certified VoIPSec Operator (CVO)** credential is issued on: all module labs passed + three
checkpoint exams passed + capstone pass (≥ 70 and no failing security category).
