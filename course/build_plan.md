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
- [x] A2. pbx-a (Asterisk) base: PJSIP endpoints, dialplan, ARI/AMI off by default  ← iteration 4
- [x] A3. pbx-b (FreeSWITCH) base: sofia profile, dialplan, ESL  ← iteration 5
- [x] A4. trunk-sim (PSTN sim) + clients (Baresip/PJSUA/Linphone provisioning, SIPp scenarios)  ← iteration 6
- [x] A5. observability: HOMER 7 + Heplify (HEP), Prometheus + exporters, Grafana, Loki, Wazuh  ← iteration 7
- [x] A6. redteam container: SIPVicious OSS + sipp fuzzers, fenced to `edge`/`redteam` only; authorized-use banner  ← iteration 8 (Stage A COMPLETE)

### Stage B — Per-module lab exercises (module order)
- [x] B0. M0 orientation lab: bring-up, health checks, capture pipeline verification  ← iteration 9
- [x] B1. M1 SIP foundations lab  ← iteration 12
- [x] B2. M2 core SIP protocol lab  ← iteration 13
- [x] B3. M3 SDP / media negotiation lab  ← iteration 14
- [x] B4. M4 RTP / codecs / QoS lab  ← iteration 15
- [x] B5. M5 packet-analysis lab (+ checkpoint exam #1 content)  ← iteration 17
- [x] B6. M6 build-the-core lab  ← iteration 18
- [x] B7. M7 proxies & SBC lab  ← iteration 20
- [x] B8. M8 NAT / firewall / SBC lab  ← iteration 21
- [ ] B9. M9 SIP trunking / PSTN lab
- [ ] B10. M10 signaling security (TLS/SIPS) lab
- [ ] B11. M11 media security (SRTP/DTLS/ZRTP) lab
- [ ] B12. M12 authN/authZ/identity lab (+ checkpoint exam #2 content)
- [ ] B13. M13 threats & offensive testing lab (authorized)
- [ ] B14. M14 defense / hardening / fraud lab
- [ ] B15. M15 monitoring / observability / IR lab
- [ ] B16. M16 testing / interop / automation / cloud lab
- [ ] B17. M17 frontiers lab (+ checkpoint exam #3 content)

### Stage B+ — feedback-driven lab additions (review: gemini_feedback0)
Design threaded into the module docs in iteration 3; these are the concrete labs to build
when their parent B-task is reached.
- [ ] BF1. M10/M11: WebRTC — Kamailio WSS gateway + rtpengine DTLS-SRTP↔SIP media bridge
- [ ] BF2. M9/M17: emergency calling — PIDF-LO location body + Resource-Priority; Kari's/RAY BAUM'S
- [ ] BF3. M7/M16: HA state sharing — Redis/MySQL registrar + rtpengine redundancy, hitless failover
- [ ] BF4. M14: secure auto-provisioning — HTTPS mTLS config serving, signed configs, MAC allowlist
- [ ] BF5. M12: transit STIR/SHAKEN — attestation "C", untrusted-header stripping, OOB (RFC 8816)
- [ ] BF6. M12: RFC 8760 interop — dual MD5+SHA-256 challenge, downgrade rejection
- [ ] BF7. M13: RFC 4475 SIP torture — SIPp fuzzing + parser-robustness regression baseline
- [ ] BF8. M14/M15: secure recording — encryption-at-rest, RBAC/audit, DTMF suppression (PCI-DSS)
- [ ] BF9. M7/M8: dual-stack/IPv6 — Kamailio v6 listeners + rtpengine 4↔6 media + nftables ip6 parity
- [ ] BF10. M8: coturn/TURN hardening — use-auth-secret, denied-peer-ip (internal), quotas, TLS
- [ ] BF11. M12: STIR/SHAKEN delegate certs (RFC 9060) — enterprise self-signed PASSporT, A-level
- [ ] BF12. M14/M15: SIP honeypot → nftables ipset blocklist + Wazuh active-response aggregation
- [ ] BF13. M16: cloud-native K8s — Multus vs hostNetwork media, Pod Security Standards (restricted)
- [ ] BF14. M9D: DNS infra lab — BIND9 NAPTR/SRV zone, SRV failover, DNSSEC + spoof mitigation, TTL cut-over/rollback

### Stage C — Assessment content
- [ ] C0. Per-module quiz bank (question + answer key + rubric) M0..M17
- [~] C1. Three checkpoint exams (after M5, M12, M17) — exam #1 done (iter 17); #2/#3 pending
- [ ] C2. Capstone grading harness (rubric → scoring sheet)

### Stage D — Instructor material
- [ ] D0. Per-module instructor notes / slide outlines
- [ ] D1. Course delivery guide (pacing, prerequisites, environment setup for cohorts)

### Stage E — Testing & packaging (added iter 22 from feedback)
- [~] E0. Lab environment test & verification — `lab/verify-all.sh` aggregates every module
      verify.sh (`make verify-all`); iter 22 first cut. TODO: per-service healthcheck rollup,
      a smoke-call end-to-end test, and a CI workflow that runs it.
- [ ] E1. Package multiple-choice exams as standalone deployable HTML (self-contained, no server;
      score client-side). Start with checkpoint exams' MC portions.
- [ ] E2. Assessment convention: keep answer keys in `assessments/answer-keys/` (one level deeper,
      separate file) — applied to exam #1 (iter 22); apply to exams #2/#3 when built.

## Loop protocol (each iteration)
1. Check `/home/terry/voip_course` for feedback files (`*feedback*`, `FEEDBACK*`, `feedback/`).
   If present: read, incorporate, and prioritize the feedback before continuing the backlog.
2. Build the next unmarked backlog item (one coherent unit).
3. Update this file (mark `[x]`, note the iteration).
4. Update the top-level `README.md` `PROGRESS` block (iteration #, stage, next item).
5. `git commit` on `main` with a Conventional Commit message.
6. `git push origin main` (fast-forward; never force-push in the loop).

## Iteration log
- Iteration 1 (2026-07-01): scheduled hourly loop `e7810ccd`; built A0 (lab foundation scaffold).
- Iteration 2 (2026-07-01): built A1 (edge-sbc: Kamailio border config + rtpengine media relay);
  added rtpengine service to topology; compose validates (8 services). Loop now `48a47bda` (:00).
- Iteration 3 (2026-07-01): processed feedback `gemini_feedback0.md` (priority over backlog).
  Threaded 8 curriculum additions into modules M7,M9,M10,M11,M12,M13,M14,M15,M16,M17; added
  BF1–BF8 lab tasks. Archived the feedback to `course/reviews/`. Loop now `203820fb`. A2 deferred
  to iteration 4.

- Iteration 4 (2026-07-01): built A2 (pbx-a Asterisk base) — chan_pjsip only, AMI/ARI/HTTP off,
  legacy channel drivers unloaded, outbound-denied dialplan (T4), env-injected secrets (T11),
  1001/1002 endpoints + echo/playback tests. compose validates (still 8 services). Pushed.

- Iteration 5 (2026-07-02): built A3 (pbx-b FreeSWITCH base) — overlay on community image;
  injects default_password + ESL password from env at boot (kills 1234/ClueCon, T3/T11), ESL
  bound to loopback+ACL, users 1003/1004 in restricted `sovoc` context (T4), echo/tone tests.
  compose validates; all XML well-formed. Pushed.

- Iteration 6 (2026-07-02): built A4 (trunk-sim + client) on edge — SIPp PSTN peer (UAS answer /
  UAC originate scenarios) and a Baresip+SIPp client toolbox with env-injected account secret
  (T11) and REGISTER/call scenarios. compose validates (8 services, both real); shells OK; all
  4 SIPp scenario XML well-formed. Pushed.

- Iteration 7 (2026-07-02): built A5 (observability plane) — profile-gated (`obs`) stack:
  heplify-server+homer-webapp+postgres (HOMER 7 HEP), Prometheus, Grafana (auto datasources),
  Loki, single-node Wazuh. Added `make obs-up/obs-down`, volumes, env keys. Both base and obs
  compose profiles validate; standard configs YAML-linted. Exporters/HEP-mirroring deferred to
  M15. Pushed.

- Iteration 8 (2026-07-02): built A6 (redteam) — SIPVicious + SIPp, fenced to edge/redteam by
  compose, authorized-use banner + AUTHORIZED_USE.md, scope-guarded helpers (lab-scan/enum/
  crack/fuzz) that refuse non-lab targets. Removed the now-unused x-placeholder anchor; all 8
  slots are real builds. Both compose profiles validate; scripts shell-checked.
  **STAGE A (lab foundation) COMPLETE.** Next: Stage B (B0/M0 orientation lab).

- Iteration 9 (2026-07-02): built B0 (M0 orientation lab) — first Stage-B lab. Runbook with
  100-pt rubric (Labs 0.1 bring-up / 0.2 capture / 0.3 reset / ethics), plus `verify.sh`
  auto-grader (services + network subnets + segmentation invariant, exit-coded) and
  `gen-call.sh` deterministic call generator. Added labs/ index. Scripts bash-checked. Pushed.

- Iteration 10 (2026-07-02): addressed automated commit security review (MEDIUM: fail-open
  validator differential in m0 verify.sh). Made the segmentation test fail-closed — negative
  probe (redteam->core) only trusted after a positive control (redteam->edge) passes and
  redteam is confirmed running; broken/absent probe now yields INCONCLUSIVE→FAIL, not a false
  PASS. Added the lesson to the M0 README. B1 deferred to iteration 11.

- Iteration 12 (2026-07-02): built B1 (M1 SIP foundations lab) — verify.sh (fail-closed:
  services up → REGISTER traverses SBC returns 200), probe-banner.sh recon helper, living
  threat-model template, 100-pt rubric. Added `ncat` to the client image for the recon probe.
  Scripts bash-checked; compose still valid. Pushed.

- Iteration 13 (2026-07-02): built B2 (M2 core SIP lab) — verify.sh asserts protocol invariants
  (REGISTER→200 + Max-Forwards:0→483 loop protection, fail-closed), trace.sh raw-response
  reader for annotation, README with rubric (transaction/dialog, auth, forking, topology-hiding
  labs are analysis-graded). Scripts bash-checked. Pushed.

- Iteration 14 (2026-07-02): built B3 (M3 SDP/media lab) — verify.sh (fail-closed: services +
  REGISTER + rtpengine edge anchor reachable), sdp-offer.sh raw-offer helper carrying an
  attacker-chosen c= line to demonstrate T9 redirection vs rtpengine anchoring, README rubric.
  Scripts bash-checked. Pushed.

- Iteration 15 (2026-07-02): built B4 (M4 RTP/codecs/QoS lab) — verify.sh (fail-closed: media
  path + REGISTER + trunk-sim answers), bw-budget.sh deterministic bandwidth calculator
  (validated: G.711@20ms=80kbps L3), capture-rtp.sh RTP capture/analysis helper (eavesdrop→SRTP
  bridge to M11), README rubric. Scripts bash-checked. Pushed.

- Iteration 17 (2026-07-02): built B5 (M5 packet-analysis lab + checkpoint exam #1). Lab:
  verify.sh (prereqs + HOMER availability), list-bad-calls.sh (tshark 4xx/5xx solution),
  redact-and-hash.sh (drop media plane, hash + chain-of-custody). Exam: course/assessments/
  checkpoint-exam-1.md — 20 items/100pts covering M0–M5 with a security gate, answer key +
  rubric. Scripts bash-checked. First checkpoint exam of three done. Pushed.

- Iteration 18 (2026-07-02): built B6 (M6 building-the-core lab). verify.sh is the strongest
  grader yet — queries live PBXs for secure defaults (fail-closed): Asterisk secret file not
  world-readable (octal-bit checked), chan_sip unloaded, no anonymous endpoint; FreeSWITCH
  default_password != 1234. Added living hardening-checklist.md template (v1, security-spine
  companion to the threat model) + README rubric. Scripts bash-checked; perm logic verified.
  Pushed.

- Iteration 20 (2026-07-02): built B7 (M7 proxies & SBCs lab). verify.sh is a self-validating
  rate-limit grader — positive control probe answered pre-flood, then a 150-req flood from
  redteam must get the source pike-banned (silence), fail-closed. flood-demo.sh before/after
  helper; README rubric (failover/topology-hiding/anchoring/rate-limit). Scripts bash-checked.
  Pushed.

- Iteration 21 (2026-07-02): built B8 (M8 NAT/firewalls/SBC lab). verify.sh self-validating
  scanner-UA ban test (plain probe answered → svmap friendly-scanner → banned, fail-closed).
  nftables-edge.example.nft reference ruleset (default-drop, rate-limited SIP, media/TURN ports,
  dynamic banned set; validate on-host with `nft -c -f`). README rubric. bash-checked. Pushed.

## Security review log
- Commit `1182c54` (B0) → MEDIUM fail-open in verify.sh segmentation check → FIXED iter 10
  (positive-control gating, fail-closed). Verified bash-clean.

- Iteration 11 (2026-07-02): processed feedback `feedback1.md` (priority over backlog).
  Threaded 5 curriculum additions into M7,M8,M12,M14,M15,M16; added BF9–BF13. Permanent review
  already at `course/reviews/gemini_feedback1.md`; removed the top-level trigger. B1 deferred to
  iteration 12.

- Iteration 16 (2026-07-02): processed `feedback.txt` (priority over backlog) — added a new
  module **M9D DNS Infrastructure & Resilience** (RFC 3263 NAPTR/SRV, DNS failover, anycast,
  DNSSEC + spoof mitigation via TLS cert, TTL cut-over/rollback) as a lettered insert (no
  renumber). Registered in overview + README; added BF14. Archived feedback to
  `course/reviews/feedback-dns-module.md`. B5 deferred to iteration 17.

- Iteration 19 (2026-07-02): processed `feedback.txt` (priority) — added a top-level repo
  `README.md` (project overview linked to plan + progress, with a PROGRESS block updated each
  iteration; added that as loop-protocol step 4). Untracked `.claude/` and gitignored it (kept
  on disk; history purge deferred per request). Archived feedback to
  `course/reviews/feedback-repo-readme.md`. B7 deferred to iteration 20.

- Iteration 22 (2026-07-02): processed `feedback.txt` (priority) — (1) split checkpoint exam #1
  answer key into `assessments/answer-keys/checkpoint-exam-1-key.md` (one level deeper, separate
  file); exam now points to it, 0 answers remain inline. (2) Built `lab/verify-all.sh` +
  `make verify-all` lab test harness (runs all module graders). (3) Added Stage E backlog
  (E0 lab testing, E1 HTML MC exams, E2 answer-key convention). Archived feedback. B9 deferred
  to iteration 23.

## Feedback log
- `gemini_feedback0.md` (received iter 3) → incorporated across 10 modules + BF1–BF8;
  archived at `course/reviews/gemini_feedback0.md`.
- `feedback1.md` (received iter 11) → incorporated across M7,M8,M12,M14,M15,M16 + BF9–BF13;
  permanent copy `course/reviews/gemini_feedback1.md`; top-level trigger removed.
- `feedback.txt` (received iter 16) → new module M9D DNS Infrastructure + BF14;
  archived `course/reviews/feedback-dns-module.md`.
- `feedback.txt` (received iter 19) → top-level repo README + hide `.claude/`;
  archived `course/reviews/feedback-repo-readme.md`.
- `feedback.txt` (received iter 22) → hide exam answers (answer-keys/ subdir), lab test harness,
  HTML MC exams to plan; archived `course/reviews/feedback-testing-and-exams.md`.
