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

## Security review log
- Commit `1182c54` (B0) → MEDIUM fail-open in verify.sh segmentation check → FIXED iter 10
  (positive-control gating, fail-closed). Verified bash-clean.

- Iteration 11 (2026-07-02): processed feedback `feedback1.md` (priority over backlog).
  Threaded 5 curriculum additions into M7,M8,M12,M14,M15,M16; added BF9–BF13. Permanent review
  already at `course/reviews/gemini_feedback1.md`; removed the top-level trigger. B1 deferred to
  iteration 12.

## Feedback log
- `gemini_feedback0.md` (received iter 3) → incorporated across 10 modules + BF1–BF8;
  archived at `course/reviews/gemini_feedback0.md`.
- `feedback1.md` (received iter 11) → incorporated across M7,M8,M12,M14,M15,M16 + BF9–BF13;
  permanent copy `course/reviews/gemini_feedback1.md`; top-level trigger removed.
