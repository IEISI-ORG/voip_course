# Task Plan: Build "Secure Open-Source VoIP Operations" Course

## Goal
Design a complete, buildable training course modeled on The SIP School's SSCA 'Elite'
curriculum, but rebuilt around **open-source tools** and an **emphasis on secure VoIP
operations**. Deliver a course overview plus a detailed deep-dive for every module and
section. Run autonomously (no user interaction) and leave a complete plan on disk.

## Design Principles
1. Every module follows the 5-beat spine: Concept → Packet reality → Build (OSS) → Attack/Defend → Lab.
2. Security is structural, not a bolt-on module. Threat modeling appears in every module.
3. 100% reproducible with free/open-source software in a self-contained Docker lab.
4. Hands-on first: each module ships runnable labs and a graded rubric.
5. Vendor-neutral but concrete: named tools, versions, configs, RFCs.

## Phases
- [x] Phase 1: Source analysis — parse SIP School curriculum (done in prior turns; see SSCA-Elite-SIP-training.md)
- [x] Phase 2: Tooling + threat research — map OSS stack and threat catalog (notes.md)
- [x] Phase 3: Course architecture — overview, module map, assessment model (00-course-overview.md)
- [x] Phase 4: Deep dives — one detailed file per module (modules/*.md)
- [x] Phase 5: Capstone + operations runbooks (modules/18-capstone.md)
- [x] Phase 6: Review pass — cross-check coverage vs. SIP School, consistency, index (README.md)

## Key Decisions
- Course name: **VoIPSec — Secure Open-source VoIP Operations Certificate**.
- 18 modules (M0 orientation → M18 frontiers) + capstone, vs. SIP School's 14.
- Reference stack: Asterisk, FreeSWITCH, Kamailio, OpenSIPS, rtpengine, Wireshark/sngrep,
  HOMER/Heplify, SIPp, Baresip/Linphone/PJSIP, OpenSSL/Let's Encrypt, fail2ban/nftables,
  libstirshaken, Prometheus/Grafana/Loki, Wazuh, Docker/Ansible/Terraform, spandsp, BIND.
- Offensive tooling (SIPVicious, sipp fuzzing) framed strictly as authorized testing.

## Status
**COMPLETE** — full plan written to course/. See course/README.md for the index.

## File Map
- SSCA-Elite-SIP-training.md ............ source curriculum (reference)
- course/task_plan.md .................... this file
- course/notes.md ........................ OSS tooling map + threat catalog + lab arch
- course/00-course-overview.md ........... master course design
- course/modules/00..17 .................. per-module deep dives
- course/modules/18-capstone.md .......... capstone project + ops runbooks
- course/README.md ....................... index + SIP-School coverage crosswalk
