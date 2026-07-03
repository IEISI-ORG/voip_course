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
- [x] B9. M9 SIP trunking / PSTN lab  ← iteration 23
- [x] B10. M10 signaling security (TLS/SIPS) lab  ← iteration 26
- [x] B11. M11 media security (SRTP/DTLS/ZRTP) lab  ← iteration 27
- [x] B12. M12 authN/authZ/identity lab (+ checkpoint exam #2 content)  ← iteration 28
- [x] B13. M13 threats & offensive testing lab (authorized)  ← iteration 29
- [x] B14. M14 defense / hardening / fraud lab  ← iteration 30
- [x] B15. M15 monitoring / observability / IR lab  ← iteration 31
- [x] B16. M16 testing / interop / automation / cloud lab  ← iteration 32
- [x] B17. M17 frontiers lab (+ checkpoint exam #3 content)  ← iteration 33 (STAGE B COMPLETE)

### Stage B+ — feedback-driven lab additions (review: gemini_feedback0)
Design threaded into the module docs in iteration 3; these are the concrete labs to build
when their parent B-task is reached.
- [x] BF1. M10/M11: WebRTC — Kamailio WSS gateway + rtpengine DTLS-SRTP↔SIP media bridge  ← iteration 34
- [x] BF2. M9/M17: emergency calling — PIDF-LO location body + Resource-Priority; Kari's/RAY BAUM'S  ← iteration 35
- [x] BF3. M7/M16: HA state sharing — Redis/MySQL registrar + rtpengine redundancy, hitless failover  ← iteration 36
- [x] BF4. M14: secure auto-provisioning — HTTPS mTLS config serving, signed configs, MAC allowlist  ← iteration 37
- [x] BF5. M12: transit STIR/SHAKEN — attestation "C", untrusted-header stripping, OOB (RFC 8816)  ← iteration 38
- [x] BF6. M12: RFC 8760 interop — dual MD5+SHA-256 challenge, downgrade rejection  ← iteration 39
- [x] BF7. M13: RFC 4475 SIP torture — parser-robustness baseline (torture.sh + verify.sh, iter 29;
      full SIPp mutation suite is an optional extension)
- [x] BF8. M14/M15: secure recording — encryption-at-rest, RBAC/audit, DTMF suppression (PCI-DSS)  ← iteration 43
- [x] BF9. M7/M8: dual-stack/IPv6 — Kamailio v6 listeners + rtpengine 4↔6 media + nftables ip6 parity
- [x] BF10. M8: coturn/TURN hardening — use-auth-secret, denied-peer-ip (internal), quotas, TLS
- [x] BF11. M12: STIR/SHAKEN delegate certs (RFC 9060) — enterprise self-signed PASSporT, A-level
- [x] BF12. M14/M15: SIP honeypot → nftables ipset blocklist + Wazuh active-response aggregation
- [x] BF13. M16: cloud-native K8s — Multus vs hostNetwork media, Pod Security Standards (restricted)
- [x] BF14. M9D: DNS infra lab — BIND9 NAPTR/SRV zone, SRV failover, DNSSEC + spoof mitigation, TTL cut-over/rollback

### Stage C — Assessment content
- [x] C0. Per-module quiz bank (question + answer key + rubric) M0..M17
- [x] C1. Three checkpoint exams (after M5, M12, M17) — #1 (iter 17), #2 (iter 28), #3 (iter 33) all done, keys separated
- [x] C2. Capstone grading harness (rubric → scoring sheet)

### Stage D — Instructor material
- [ ] D0. Per-module instructor notes / slide outlines
- [x] D1. Course delivery guide (pacing, prerequisites, environment setup for cohorts)

### Stage E — Testing & packaging (added iter 22 from feedback)
- [~] E0. Lab environment test & verification — `lab/verify-all.sh` aggregates every module
      verify.sh (`make verify-all`, iter 22); CI workflow `.github/workflows/ci.yml` added iter 32
      (lint + compose config + offline graders + bibliography). TODO: per-service healthcheck
      rollup + a smoke-call end-to-end test in CI (needs a dockerized topology runner).
- [x] E1. Package multiple-choice exams as standalone deployable HTML (self-contained, no server;
      score client-side). Start with checkpoint exams' MC portions.
- [~] E3. Living bibliography of RFCs/standards + package KBs — `course/references/bibliography.md`
      (started iter 24). Verification set up iter 25: `course/references/verify-bibliography.sh`
      (`list` offline; full run needs network — run in CI/manually, sandbox blocks egress).
- [ ] E4. Instructor slide decks in **MARP**. REQUIREMENTS (memorized): Makefile-driven marp-cli
      build; validate rendering via Playwright; run Playwright under a headless X server
      (`xvfb-run`) since the build runs on cron. See memory `marp-slide-tooling`.
- [x] E2. Assessment convention: keep answer keys in `assessments/answer-keys/` (one level deeper,
      separate file) — applied to exam #1 (iter 22); apply to exams #2/#3 when built.

## Loop protocol (each iteration)
1. Check `/home/terry/voip_course` for feedback files (`*feedback*`, `FEEDBACK*`, `feedback/`).
   If present: read, incorporate, and prioritize before the backlog. Record what it asked in the
   feedback log below; then **delete the feedback file** (do NOT commit it — they are gitignored
   and ephemeral). Also prune any now-answered items from `questions.md`.
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

- Iteration 23 (2026-07-02): built B9 (M9 SIP trunking & PSTN lab). sip-q850.sh deterministic
  SIP↔Q.850 mapping tool (RFC 3398; verified 486→17); verify.sh prereqs + trunk-sim SIP
  reachability (fail-closed); trunk-hardening.md reference (IP-only→TLS+digest+allowlist, spoof
  rejection, spend limits + alert) for 9.3; README rubric. Scripts bash-checked. Pushed.

- Iteration 26 (2026-07-02): built B10 (M10 signaling security TLS/SIPS lab). verify.sh proves
  SIP-over-TLS on :5061 via ncat --ssl (handshake + OPTIONS answered, fail-closed); tls-check.sh
  inspects cert subject/expiry + days-to-expiry + live handshake (feeds the Prometheus expiry
  alert lab); README rubric (TLS-only enforce / decrypt / mTLS + expiry alert). bash-checked.
  Pushed.

- Iteration 27 (2026-07-02): built B11 (M11 media security lab). verify.sh asserts the SRTP
  foundation (rtpengine anchor reachable + SIP-TLS present so SDES keys aren't cleartext,
  fail-closed); srtp-offer.sh sends an SDES RTP/SAVP offer with a=crypto and a --strip downgrade
  mode for 11.3; README rubric (SDES/DTLS/ZRTP, crypto-strip rejection). Lab-only throwaway key
  (not a secret). Closes the M4 eavesdrop thread. bash-checked. Pushed.

- Iteration 28 (2026-07-03): built B12 (M12 auth/identity lab + checkpoint exam #2). Lab:
  passport-decode.sh (STIR/SHAKEN JWT decoder, round-trip verified), verify.sh self-validating
  enumeration-ban (svwar→banned, fail-closed) + PASSporT tool check. Exam #2 (M6–M12, 20 items,
  security-gated) with answer key in answer-keys/ (convention). Scripts bash-checked; exam has 0
  inline answers. Second checkpoint exam done. Pushed.

- Iteration 29 (2026-07-03): built B13 (M13 offensive lab). verify.sh = RFC 4475 parser-
  robustness survival test (SBC answers valid request before AND after a malformed batch, fail-
  closed) → satisfies BF7 baseline. torture.sh (5 malformed patterns, lab-guarded);
  findings-report-template.md (severity/evidence/repro/remediation/detection + authorized-use
  attestation gate); README methodology. Scripts bash-checked. Pushed.

- Iteration 30 (2026-07-03): built B14 (M14 defense/hardening/fraud lab). fraud-detect.sh CDR
  IRSF detector (spend cap + high-cost prefix spike + per-account auto-suspend) with sample-cdr.csv;
  verify.sh runs fully offline and PASSES 5/5 (catches IRSF, no false-positive on clean CDR,
  checklist present). README rubric (hardening v-final / fraud detection+containment / M13
  before-after delta). Scripts bash-checked + executed. Pushed.

- Iteration 31 (2026-07-03): built B15 (M15 monitoring/observability/IR lab). alert-rules.yml
  (7 Prometheus security alerts), detection-signatures.md (M13 threats→detection layer/rule),
  incident-runbook-template.md (toll fraud/INVITE flood/eavesdropping IR + report). verify.sh
  runs offline and PASSES 17/17 (rules valid, alerts+threats+runbook coverage). Closes the
  red→blue arc. bash-checked + executed. Pushed.

- Iteration 32 (2026-07-03): built B16 (M16 testing/interop/automation/cloud lab). Added CI
  `.github/workflows/ci.yml` (shell lint, compose config base+obs, YAML lint, offline graders
  M14/M15, bibliography, trivy config scan) — no untrusted github.event interpolation (injection-
  safe). load-test.sh SIPp capacity runner; verify.sh runs offline PASS 7/7 (CI valid + all repo
  shell scripts parse + injection check). E0 CI done. bash-checked + executed. Pushed.

- Iteration 33 (2026-07-03): built B17 (M17 frontiers lab + checkpoint exam #3) — STAGE B COMPLETE.
  enum-lookup.sh (E.164→e164.arpa NAPTR→SIP URI, verified); verify.sh offline PASS 4/4 (encoding,
  private resolve, fall-through, normalization). Exam #3 (operations, M13–M17, 20 items,
  IR-gated) + separated answer key. All 18 module labs (M0–M17) and all 3 checkpoint exams done
  (C1 complete). Pushed.

- Iteration 34 (2026-07-03): built BF1 (WebRTC WSS gateway + DTLS-SRTP↔SIP bridge). Kamailio
  websocket snippet (xhttp+websocket, ws_handle_handshake), rtpengine WebRTC transform flags,
  jsSIP browser client.html (secure-by-default: vendored locally, no un-pinned CDN script —
  addressed a security-hook SRI warning), verify.sh (WSS/TLS basis + config + secure-client
  checks, fail-closed). bash-checked; offline artifact checks pass. Pushed.

- Iteration 35 (2026-07-03): built BF2 (emergency calling). pidf-lo-sample.xml (RFC 4119/5139/5491
  dispatchable location), e911-call.sh (multipart emergency INVITE w/ Resource-Priority + PIDF-LO
  + Geolocation, computed Content-Length), verify.sh PASSES 8/8 offline. Addressed a security-hook
  XML warning by parsing with defusedxml (ElementTree fallback) — models XXE-safe parsing.
  bash-checked + executed. Pushed.

- Iteration 36 (2026-07-03): built BF3 (HA state sharing / hitless failover). kamailio-ha.snippet.cfg
  (usrloc db_mode=3 Redis/MySQL + DMQ + rtpengine redis media state), docker-compose.ha.yml overlay
  (edge-sbc-2 replica + shared redis), failover-test.sh (register→kill R1→R2 serves). verify.sh
  PASSES 9/9 including a real base+HA `docker compose config` merge. Policy-parity security note.
  bash-checked + executed. Pushed.

- Iteration 37 (2026-07-03): built BF4 (secure auto-provisioning). sign-config.sh (RSA/SHA-256
  detached sign+verify with a demo that proves tamper detection), nginx-provisioning.conf (mTLS
  ssl_verify_client on + MAC allowlist + CN==MAC per-device scope, HTTPS-only), sample device
  cfg with placeholder secret + TLS/SRTP. verify.sh PASSES 9/9 (real openssl round-trip).
  bash-checked + executed. Pushed.

- Iteration 38 (2026-07-03): built BF5 (transit STIR/SHAKEN). shaken-policy.sh decision tool
  (strip untrusted Identity, attest A/B/C by own-number+trust, OOB for TDM/SS7 per RFC 8816);
  verify.sh PASSES 7/7 across scenarios. README with the policy table + M12 integration + "never
  relay unverified Identity" note. bash-checked + executed. Pushed.

- Iteration 39 (2026-07-03): built BF6 (RFC 8760 digest interop). digest-interop.sh computes
  MD5/SHA-256 digest responses (RFC 7616 math via openssl) + downgrade-check policy (reject a
  chosen alg weaker than strongest offered). verify.sh PASSES 7/7 (alg differ, deterministic,
  downgrade rejected). README with M12 integration + downgrade-attack note. bash-checked +
  executed. Pushed.

- Iteration 43 (2026-07-03): built BF8 (secure recording, PCI-DSS). secure-recording.sh — AES-256
  encrypt/decrypt at rest, RBAC-gated access with an audit trail, DTMF/PAN masking (last-4/PIN);
  verify.sh PASSES 7/7 offline (round-trip, RBAC allow+deny+audit, PAN/PIN masked, no full-PAN
  leak). README emphasises DTMF suppression (never write it) over redaction. bash-checked +
  executed. Consistency audit done; BF labs resumed. Pushed.

- Iteration 44 (2026-07-03): built BF9 (dual-stack/IPv6). nftables-dual-stack.nft (separate ip/ip6
  tables at parity), parity-check.sh (flags any port allowed on one family but not the other),
  kamailio-v6.snippet.cfg (v6 listeners + rtpengine 4↔6 note). verify.sh PASSES 4/4 — self-
  validating (confirms parity AND catches an injected v6 gap). README: `table inet` = parity by
  construction. bash-checked + executed. Pushed.

- Iteration 45 (2026-07-03): built BF10 (coturn/TURN hardening). turnserver.conf (use-auth-secret,
  denied-peer-ip SSRF fence for RFC1918/loopback/link-local, quotas, TLS, no-cli); coturn-audit.sh
  (10-control checklist); turn-cred.sh (TURN REST HMAC short-term credentials). verify.sh PASSES
  5/5 — self-validating (audit catches a weakened config; cred valid/expired/forged all correct).
  bash-checked + executed. Pushed.

- Iteration 46 (2026-07-03): built BF11 (STIR/SHAKEN delegate certs, RFC 9060). delegate-ca.sh
  (SP CA → enterprise delegate cert via OpenSSL, chain verified), attest-scope.sh (sign A only
  within the delegated TN range — fixed a country-code off-by-one), verify.sh PASSES 4/4 self-
  validating (real chain verifies, rogue self-signed cert rejected, in/out-of-scope attestation).
  bash-checked + executed. Pushed.

- Iteration 46b (2026-07-03): processed `feedback.txt` (mid-iteration) — start a 6-iteration
  requirements/traceability review + memory upkeep. Built `course/requirements-traceability.md`
  (original asks + all 9 feedback items + open backlog, each with status/evidence). Refreshed
  project memory `course-build-loop` (progress, conventions, standards-precision, security-hook
  lessons). Open: BF12–14, C0/C2, E1/E4, D0/D1. Archived feedback. Audit passes 2–6 next.

- Iteration 47 (2026-07-03): requirements audit **pass 2 (verification)** — ran every verify.sh.
  Result: 11/11 offline graders PASS (bf2/4/5/6/8/9/10/11, m14/15/17); topology-dependent graders
  correctly fail-closed without a live lab (no false-pass). Recorded measured verification health
  + honest gap (end-to-end topology run is E0's TODO) in requirements-traceability.md.

- Iteration 47b (2026-07-03): processed `feedback.txt` (answers + directives). Removed all
  committed feedback files (root + course/reviews/) and gitignored `/feedback*`; switched loop
  protocol to process→delete (no commit). Answered questions applied: Q2=A (module refs are a
  bibliography subset — verified, holds), Q3=A (light touch), Q4 terminology; added
  `references/glossary.md` (abbreviations), linked from bibliography. Pruned answered items from
  questions.md. Refreshed memory. Requirements audit passes 4–6 continue.

- Iteration 48 (2026-07-03): requirements audit **pass 4 (feedback traceability + Q4)** — verified
  every feedback item is threaded (gemini_feedback0 marker in 10 modules, feedback1 in 6) and each
  has its BF lab (BF1–11 built, BF12–14 pending; BF7 lives in m13-offensive). Applied Q4 light
  touch: spelled out "Session Border Controller (SBC)" first-use in M7; added acronym + references
  conventions to the overview (glossary is the abbreviation source). Updated traceability.

- Iteration 49 (2026-07-03): requirements audit **pass 5 (coverage + capstone)** — verified the
  SIP School crosswalk maps all **14** SSCA 'Elite' modules (A1, nothing dropped) and the capstone
  integrates the full security spine via 9 graded deliverables (A3: final threat model, hardening
  checklist, red-team report, IR runbooks, detection-coverage map). Clean, no fixes. Updated
  traceability. Pass 6 (definition-of-done sweep) next, then resume BF12.

- Iteration 50 (2026-07-03): requirements audit **pass 6 (definition-of-done sweep)** — found and
  fixed real drift in the README PROGRESS block (self-contradictory/stale lines: "#3 pending" vs
  all-done, duplicate BF status) and the "What's here" table (removed the deleted `reviews/` row,
  added glossary + traceability; corrected the feedback-handling description). **6-pass
  requirements audit COMPLETE** — verdict: all A1–A5 + processed feedback satisfied; only BF12–14
  and the packaging tier remain (tracked). Loop resumes BF12 next.

- Iteration 50 (2026-07-03): built BF12 (SIP honeypot → dynamic blocklist). hp2ipset.sh (honeypot
  log → deduped nft `add element` ban commands with timeout), nftables-honeypot.nft (timeout'd
  banned_v4 set + drop), wazuh-honeypot.xml (decoder + rule + active-response), sample log.
  verify.sh PASSES 6/6 self-validating (dedupes 5→3, no false ban on clean log, set+rule present,
  Wazuh XML parses). bash-checked + executed. Requirements audit complete; BF labs resumed. Pushed.

- Iteration 51 (2026-07-03): built BF13 (cloud-native K8s). pss-audit.sh (Python audit of a
  manifest against Pod Security Standards "restricted" — flags hostNetwork/PID/IPC, privileged,
  privilege-escalation, root, missing cap-drop/seccomp), media-pod-secure.yaml (Multus + restricted
  context), media-pod-insecure.yaml (anti-pattern). verify.sh PASSES 8/8 self-validating (accepts
  hardened, rejects insecure with 7 violations). bash-checked + executed. Pushed.

- Iteration 52 (2026-07-04): built BF14 (DNS infra, M9D runnable) — db.lab.sovoc.test (RFC 3263
  NAPTR + SRV failover, low TTL), named.conf.snippet (dnssec-policy + RRL + recursion off),
  zone-check.sh (named-checkzone or structural). verify.sh PASSES 7/7 self-validating (flags a
  removed secondary SRV). bash-checked + executed. **ALL 14 BF DEEP LABS COMPLETE.** Next: the
  packaging tier (C0 quiz bank, C2 capstone grading harness, E1 HTML MC exams, E4 MARP, D0/D1).

- Iteration 53 (2026-07-04): built C2 (capstone grading harness). score-capstone.sh reads a
  scoresheet CSV and enforces the gate (total ≥70 AND every security category ≥50% max — security
  mandatory); scoresheet.csv template (9 categories = 100, 5 gated). verify.sh self-test PASSES
  6/6 including the key case (total 87 but failing encryption cat → FAIL). bash-checked + executed.
  Next packaging item: C0 quiz bank / E1 HTML MC exams / E4 MARP / D0-D1.

- Iteration 54 (2026-07-04): built C0 (MC quiz bank). quiz-bank.json — 22 security-focused MC
  questions covering all 19 modules (M0–M17 + M9D), machine-readable (answer = option index).
  verify.sh validates structure + coverage + anti-clustering (answers spread across all four
  positions). Serves as the input for E1 (HTML exam). bash/JSON-checked + executed.

- Iteration 55 (2026-07-04): built E1 (standalone HTML exam). build-exam.sh generates exam.html
  from quiz-bank.json (data inlined; no external scripts → no CDN/SRI exposure; works from
  file://), client-side scored (practice tool — answers ship in page; real grading is server-side).
  Extended verify.sh: exam regenerates, self-contained, in-sync with the bank, and a git-drift
  check (stale exam.html fails). PASSES. Next: E4 MARP + D0/D1.

- Iteration 56 (2026-07-04): built D1 (course delivery guide) — `course/instructor/delivery-guide.md`:
  audience/prereqs, pacing (self-paced/cohort/bootcamp), per-cohort lab setup (secrets, isolation,
  reset, verify-all), assessment flow (labs+graders, quizzes/HTML, 3 checkpoint exams, capstone
  harness), instructor ops, pitfalls, certification. Closed E2 (answer-key convention already
  applied to all 3 exams). Remaining: D0 (instructor notes/slide outlines) + E4 (MARP).

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

- Iteration 24 (2026-07-02): processed feedback (priority) — started the course bibliography
  `course/references/bibliography.md` (RFCs by topic, standards/regulation, package KBs) per
  `feedback.txt`; added E3 backlog. `feedback2.md` was empty → removed. Linked bibliography from
  README. B10 deferred to iteration 25.

- Iteration 25 (2026-07-02): processed feedback (priority) — set up bibliography verification
  (`course/references/verify-bibliography.sh`, list+network modes; 28 URLs extracted) and saved
  it to project memory; added E4 MARP instructor slides to the plan with tooling requirements
  memorized (Makefile + Playwright render check + headless X on cron). Wrote memory files
  (course-build-loop, bibliography-verification, marp-slide-tooling + MEMORY.md). Archived
  feedback. B10 deferred to iteration 26.

- Iteration 40 (2026-07-03): processed `feedback.txt` — started a 3-iteration consistency audit.
  **Pass 1 (standards):** fixed `div` PASSporT mis-attribution (RFC 8588=SHAKEN, RFC 8946=div) in
  M12 + bibliography; added cited-but-missing RFCs to the bibliography (now the single source of
  truth). AI-slop scan: content already clean (crucial/delve/vibrant=0). Wrote root `questions.md`
  with decisions needed (RCD RFC #, citation-style policy, anti-slop depth, terminology). Passes
  2–3 next. BF8 deferred until the audit completes.

- Iteration 41 (2026-07-03): consistency audit **pass 2 (mechanical)** — all clean, no fixes:
  rubric point-totals all 24 labs = 100; 37/37 relative markdown cross-references resolve;
  threat IDs T1–T15 consistent, none undefined. Recorded results in questions.md. Pass 3
  (prose/anti-slop light touch) awaits user answers to Q1–Q4. BF8 still deferred until audit done.

- Iteration 42 (2026-07-03): consistency audit **pass 3 (final)** — resolved Q1 via IETF
  datatracker: RCD PASSporT = RFC 9795 (+9796 Call-Info); the content's "8946/9118 (div/RCD)" was
  wrong on both counts. Fixed M12 + bibliography; 0 stray 9118. Light-touch anti-slop: flagged
  words are legitimate technical terms, left as-is. **3-pass consistency audit COMPLETE.** BF8
  resumes next iteration. (Q2/Q4 style/terminology remain optional, awaiting user.)

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
- `feedback.txt` (received iter 24) → start bibliography of RFCs/standards + package KBs;
  archived `course/reviews/feedback-bibliography.md`. (`feedback2.md` empty → removed.)
- `feedback.txt` (received iter 25) → bibliography verification + memory; MARP slides to plan
  (memorized tooling); archived `course/reviews/feedback-bib-verify-marp.md`.
