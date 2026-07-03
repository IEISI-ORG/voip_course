# Requirements Traceability Matrix

Started iter 46 (feedback: "make sure we are on track to satisfy all requirements"). Maps every
requirement — original ask + each feedback item — to its status and evidence. Reviewed over the
6-iteration audit; kept current thereafter.

Status: ✅ done · 🟡 partial/in-progress · ⬜ open

## A. Original course requirements
| # | Requirement | Status | Evidence |
|---|-------------|--------|----------|
| A1 | Course modelled on SIP School SSCA 'Elite' | ✅ | `course/00-course-overview.md`, README crosswalk |
| A2 | Open-source tools throughout | ✅ | `lab/` (Kamailio/Asterisk/FreeSWITCH/rtpengine/HOMER/…), `notes.md` tool map |
| A3 | Emphasis on **secure** VoIP operations | ✅ | security spine: threat catalog T1–T15, per-module attack/defend, M13–M15 |
| A4 | Plan then deep-dive every section | ✅ | 18 modules + M9D + capstone, each 5-beat with labs |
| A5 | Runnable/reproducible lab | ✅ | Docker compose (8 svcs), 24 module labs + BF labs, `make verify-all`, CI |

## B. Feedback items
| Feedback (iter) | Ask | Status | Evidence |
|-----------------|-----|--------|----------|
| gemini_feedback0 (3) | 8 curriculum additions | ✅ | threaded M7,M9–M17; BF1–BF8 built |
| feedback1 (11) | 5 additions (IPv6, coturn, K8s, delegate certs, honeypot) | 🟡 | threaded; BF9,BF10,BF11 done; **BF12,BF13 pending** |
| DNS module (16) | new DNS module | ✅ | `modules/09d-dns-infrastructure.md`; BF14 pending |
| repo README + hide .claude (19) | root README, gitignore .claude | ✅ | `README.md`, `.gitignore` (history purge deferred) |
| exams + testing (22) | hide answers, lab test harness, HTML MC exams | 🟡 | answer-keys/ ✅, `verify-all.sh`+CI ✅, **HTML MC exams (E1) open** |
| bibliography (24) | RFC/standards + KB bibliography | ✅ | `references/bibliography.md` |
| bib-verify + MARP (25) | verify bib + MARP to plan + memorize | 🟡 | `verify-bibliography.sh` ✅, memory ✅, **MARP slides (E4) open** |
| consistency audit (40) | 3-pass standards/consistency + questions.md | ✅ | passes 1–3 done; RCD/8588 fixes; questions.md |
| requirements audit (46) | 6-iteration on-track review + memory upkeep | 🟡 | this doc (passes 1–3); memory refreshed |
| Q&A + housekeeping (47) | answer Q2/Q3/Q4; glossary; remove committed feedback; prune questions | ✅ | Q2=A subset (holds), Q3=A, Q4 terminology; `references/glossary.md`; feedback files removed + gitignored; questions.md pruned |

## C. Open / remaining backlog (must close to "satisfy all requirements")
| Item | Status | Note |
|------|--------|------|
| BF12 SIP honeypot | ⬜ | next BF lab |
| BF13 cloud-native K8s pod security | ⬜ | feedback1 item |
| BF14 DNS infra lab (M9D) | ⬜ | runnable BIND9 lab |
| C0 per-module quiz bank | ⬜ | assessment |
| C2 capstone grading harness | ⬜ | assessment |
| E1 HTML MC exams | ⬜ | feedback iter 22 |
| E4 MARP instructor slides | ⬜ | feedback iter 25 (tooling memorized) |
| D0/D1 instructor notes + delivery guide | ⬜ | instructor material |
| questions.md Q2/Q4 | ⬜ | awaiting user (citation-style, terminology) |
| `.claude/` history purge | ⬜ | deferred by user ("later") |

## D. Verification health (measured iter 47, audit pass 2)
Ran every `verify.sh`:
- **Offline graders: 11/11 PASS** — bf2, bf4, bf5, bf6, bf8, bf9, bf10, bf11, m14, m15, m17.
  These are deterministic and run in CI.
- **Topology-dependent graders: correctly FAIL/inconclusive without a live lab** (fail-closed,
  no false-pass) — m0–m13, bf1. (bf3, m16 pass their config-validation parts since the Docker
  CLI is present.)
- **Honest gap:** the topology-dependent labs are structurally validated (`bash -n` on all
  scripts, `docker compose config`, self-validating logic) but **not yet executed end-to-end
  against a running topology in this environment**. That end-to-end run is E0's remaining TODO
  (a dockerized topology runner in CI). Not a defect — a coverage boundary to close.
