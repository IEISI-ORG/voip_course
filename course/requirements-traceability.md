# Requirements Traceability Matrix

Started iter 46 (feedback: "make sure we are on track to satisfy all requirements"). Maps every
requirement — original ask + each feedback item — to its status and evidence.

**Audit verdict (refreshed iter 93, G8):** all original requirements (A1–A5) and every processed
feedback item are ✅ satisfied and verified. The packaging tier and all BF deep labs are **done**;
the course was **renamed SOVOC → VoIPSec** (credential: Certified VoIPSec Operator) and grew a
community/licensing tier (Stage F), a multi-jurisdiction emergency arc, a peer-review-gated
reference set, and an 8-pass consistency audit (Stage G, G1–G8). Only **reactive** items (issue
triage, paper ingestion) and the **planned** Stage H (DNS-module promotion, provisioning-security
expansion) remain open by design.

Status: ✅ done · 🟡 partial/in-progress · ⬜ open

## A. Original course requirements
| # | Requirement | Status | Evidence |
|---|-------------|--------|----------|
| A1 | Course modelled on SIP School SSCA 'Elite' | ✅ | README crosswalk maps **all 14** SSCA modules (verified iter 49, nothing dropped) |
| A2 | Open-source tools throughout | ✅ | `lab/` (Kamailio/Asterisk/FreeSWITCH/rtpengine/HOMER/…), `notes.md` tool map |
| A3 | Emphasis on **secure** VoIP operations | ✅ | security spine T1–T15, per-module attack/defend, M13–M15; **capstone** (verified iter 49) requires final threat model, hardening checklist, red-team report, IR runbooks, detection-coverage map |
| A4 | Plan then deep-dive every section | ✅ | 18 modules + M9D + capstone, each 5-beat with labs |
| A5 | Runnable/reproducible lab | ✅ | Docker compose (8 svcs), 24 module labs + BF labs, `make verify-all`, CI |

## B. Feedback items
| Feedback (iter) | Ask | Status | Evidence |
|-----------------|-----|--------|----------|
| gemini_feedback0 (3) | 8 curriculum additions | ✅ | **verified iter 48:** `review: gemini_feedback0` marker in 10 modules; BF1–BF8 all built |
| feedback1 (11) | 5 additions (IPv6, coturn, K8s, delegate certs, honeypot) | 🟡 | **verified iter 48:** marker in 6 modules; BF9/10/11 done; **BF12,BF13 pending** |
| DNS module (16) | new DNS module | ✅ | `modules/09d-dns-infrastructure.md`; BF14 pending |
| repo README + hide .claude (19) | root README, gitignore .claude | ✅ | `README.md`, `.gitignore` (history purge deferred) |
| exams + testing (22) | hide answers, lab test harness, HTML MC exams | 🟡 | answer-keys/ ✅, `verify-all.sh`+CI ✅, **HTML MC exams (E1) open** |
| bibliography (24) | RFC/standards + KB bibliography | ✅ | `references/bibliography.md` |
| bib-verify + MARP (25) | verify bib + MARP to plan + memorize | 🟡 | `verify-bibliography.sh` ✅, memory ✅, **MARP slides (E4) open** |
| consistency audit (40) | 3-pass standards/consistency + questions.md | ✅ | passes 1–3 done; RCD/8588 fixes; questions.md |
| requirements audit (46) | 6-iteration on-track review + memory upkeep | ✅ | **6 passes done:** matrix, grader health (11/11 offline PASS), Q&A+housekeeping, feedback threading (10+6 markers, BF1–11), coverage (14/14 SSCA) + capstone, README definition-of-done sweep |
| Q&A + housekeeping (47) | answer Q2/Q3/Q4; glossary; remove committed feedback; prune questions | ✅ | Q2=A subset (holds), Q3=A, Q4 terminology; `references/glossary.md`; feedback files removed + gitignored; questions.md pruned |

## C. Packaging tier + deep labs — now all CLOSED
| Item | Status | Note |
|------|--------|------|
| BF12 honeypot / BF13 K8s PSS / BF14 DNS / BF15 Suricata | ✅ | iters 43-67; each self-validating verify.sh |
| C0 quiz bank · C2 capstone grading harness | ✅ | iters 53-54 |
| E1 HTML MC exams · E4 MARP slides (Makefile+Playwright+xvfb) | ✅ | iters 55, 58 (ran 20 decks) |
| D0 slide decks · D1 delivery guide | ✅ | iters 56-57 |
| questions.md Q1–Q8 | ✅ | all answered (subset citation rule, terminology, Suricata placement, contacts, peer-review) |
| `.claude/` + feedback + index.html history purges | ✅ | iters 60/63/85 (filter-branch + force-push, lease) |

## E. Post-rename era — Stages F/G/H
| Item | Status | Evidence |
|------|--------|----------|
| Rename SOVOC → VoIPSec + CVO credential | ✅ | iter 62; 0 live residue (G8), history/log clean |
| F0 LICENSE (CC BY-NC-SA 4.0) + CONTRIBUTING + CONTRIBUTORS | ✅ | iter 62 |
| F1 Suricata IDS (BF15) into M13→M15 pipeline | ✅ | iter 67, verify 9/9 |
| F2 AI-slop review + `slop-check.sh` | ✅ | iter 68 (clean) |
| F5 multi-jurisdiction emergency (US/AU/UK/EU) + NG112 hook | ✅ | iters 72-76 (BF2 14/14) |
| F6 RFC evolution SVG · F7 device-config-security | ✅ | iters 74, 85 |
| Peer-review gate on all processed papers | ✅ | iter 70+ (Keromytis/Dantu/Kolahi/JTDE/Goode kept; predatory venues rejected) |
| G1–G8 consistency audit | ✅ | iters 86-93 (threat-map, citations, lab-align, links, glossary +49, security, assessments, naming) |
| F3 issue-triage · F4 paper ingestion | 🟡 | reactive — wake on GitHub issue / dropped paper |
| F8 VoWiFi/GSMA · F9 Schulzrinne · H1 DNS-into-main · H2 provisioning-security | ⬜ | planned; H1/H2 post-audit (feedback iter 92) |

## D. Verification health (re-measured across the G-audit, iters 86–93)
Ran every `verify.sh` + validators:
- **Offline graders: all PASS** — the deterministic set has grown to include bf13 (K8s), bf14 (DNS),
  bf15 (Suricata 9/9), bf2 (emergency 14/14 incl. NG112 routing), plus m14/m15 and the earlier BF
  set; assessment/instructor validators (quiz-bank/E1, capstone harness, slides) all PASS.
- **G3 confirmed:** 32 labs, every one a fail-closed `verify.sh`; all 32 rubrics sum to 100.
- **Topology-dependent graders: correctly FAIL/inconclusive without a live lab** (fail-closed,
  no false-pass) — m0–m13, bf1. (bf3, m16 pass their config-validation parts since the Docker
  CLI is present.)
- **Honest gap:** the topology-dependent labs are structurally validated (`bash -n` on all
  scripts, `docker compose config`, self-validating logic) but **not yet executed end-to-end
  against a running topology in this environment**. That end-to-end run is E0's remaining TODO
  (a dockerized topology runner in CI). Not a defect — a coverage boundary to close.
