# Build Plan: SOVOC Course Content (Execution Phase)

The design layer is complete (see `task_plan.md`, all phases `[x]`). This file tracks the
**execution phase**: turning the module designs into runnable, gradeable course content,
built **in order** from the dependency root outward. One coherent unit per loop iteration,
each ending in a git commit.

## Ordering principle
Everything references the shared lab, so the lab is built first (foundation → edge → core →
edges/clients → observability → redteam), then per-module lab exercises in module order,
then assessment content, then instructor material.

## Backlog (in order)

### Stage A — Lab foundation
- [x] A0. Repo scaffold: `lab/` layout, compose topology skeleton, 4 networks, README, `.env.example`, Makefile  ← iteration 1
- [x] A1. edge-sbc: Kamailio base routing + rtpengine media relay (UDP/TCP/TLS listeners, topology hiding, pike/ratelimit stub)  ← iteration 2
- [ ] A2. pbx-a (Asterisk) base: PJSIP endpoints, dialplan, ARI/AMI off by default
- [ ] A3. pbx-b (FreeSWITCH) base: sofia profile, dialplan, ESL
- [ ] A4. trunk-sim (PSTN sim) + clients (Baresip/PJSUA/Linphone provisioning, SIPp scenarios)
- [ ] A5. observability: HOMER 7 + Heplify (HEP), Prometheus + exporters, Grafana, Loki, Wazuh
- [ ] A6. redteam container: SIPVicious OSS + sipp fuzzers, fenced to `edge`/`redteam` only; authorized-use banner

### Stage B — Per-module lab exercises (module order)
- [ ] B0. M0 orientation lab: bring-up, health checks, capture pipeline verification
- [ ] B1. M1 SIP foundations lab
- [ ] B2. M2 core SIP protocol lab
- [ ] B3. M3 SDP / media negotiation lab
- [ ] B4. M4 RTP / codecs / QoS lab
- [ ] B5. M5 packet-analysis lab (+ checkpoint exam #1 content)
- [ ] B6. M6 build-the-core lab
- [ ] B7. M7 proxies & SBC lab
- [ ] B8. M8 NAT / firewall / SBC lab
- [ ] B9. M9 SIP trunking / PSTN lab
- [ ] B10. M10 signaling security (TLS/SIPS) lab
- [ ] B11. M11 media security (SRTP/DTLS/ZRTP) lab
- [ ] B12. M12 authN/authZ/identity lab (+ checkpoint exam #2 content)
- [ ] B13. M13 threats & offensive testing lab (authorized)
- [ ] B14. M14 defense / hardening / fraud lab
- [ ] B15. M15 monitoring / observability / IR lab
- [ ] B16. M16 testing / interop / automation / cloud lab
- [ ] B17. M17 frontiers lab (+ checkpoint exam #3 content)

### Stage C — Assessment content
- [ ] C0. Per-module quiz bank (question + answer key + rubric) M0..M17
- [ ] C1. Three checkpoint exams (after M5, M12, M17)
- [ ] C2. Capstone grading harness (rubric → scoring sheet)

### Stage D — Instructor material
- [ ] D0. Per-module instructor notes / slide outlines
- [ ] D1. Course delivery guide (pacing, prerequisites, environment setup for cohorts)

## Loop protocol (each iteration)
1. Check `/home/terry/voip_course` for feedback files (`*feedback*`, `FEEDBACK*`, `feedback/`).
   If present: read, incorporate, and prioritize the feedback before continuing the backlog.
2. Build the next unmarked backlog item (one coherent unit).
3. Update this file (mark `[x]`, note the iteration).
4. `git commit` on `main` with a Conventional Commit message.
5. `git push origin main` (fast-forward; never force-push in the loop).

## Iteration log
- Iteration 1 (2026-07-01): scheduled hourly loop `e7810ccd`; built A0 (lab foundation scaffold).
- Iteration 2 (2026-07-01): built A1 (edge-sbc: Kamailio border config + rtpengine media relay);
  added rtpengine service to topology; compose validates (8 services). Loop now `48a47bda` (:00).
