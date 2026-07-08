# Build Plan: VoIPSec Course Content (Execution Phase)

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
- [x] D0. Per-module instructor notes / slide outlines
- [x] D1. Course delivery guide (pacing, prerequisites, environment setup for cohorts)

### Stage E — Testing & packaging (added iter 22 from feedback)
- [~] E0. Lab environment test & verification — `lab/verify-all.sh` aggregates every module
      verify.sh (`make verify-all`, iter 22); CI `ci.yml` (lint + compose config + offline graders,
      iter 32). End-to-end smoke test added iter 59: `lab/smoke-test.sh` (`make smoke`) — up →
      health → M0 segmentation → REGISTER through the SBC; manual CI `.github/workflows/smoke.yml`
      (workflow_dispatch, kept off per-push since it builds community images). Effectively complete;
      leaving `[~]` since the smoke run is validated by design/bash-check, not executed in-sandbox.
- [x] E1. Package multiple-choice exams as standalone deployable HTML (self-contained, no server;
      score client-side). Start with checkpoint exams' MC portions.
- [~] E3. Living bibliography of RFCs/standards + package KBs — `course/references/bibliography.md`
      (started iter 24). Verification set up iter 25: `course/references/verify-bibliography.sh`
      (`list` offline; full run needs network — run in CI/manually, sandbox blocks egress).
- [x] E4. Instructor slide decks in **MARP**. REQUIREMENTS (memorized): Makefile-driven marp-cli
      build; validate rendering via Playwright; run Playwright under a headless X server
      (`xvfb-run`) since the build runs on cron. See memory `marp-slide-tooling`.
- [x] E2. Assessment convention: keep answer keys in `assessments/answer-keys/` (one level deeper,
      separate file) — applied to exam #1 (iter 22); apply to exams #2/#3 when built.

### Stage F — community & licensing (added iter 62 from feedback)
- [x] F0. LICENSE (CC BY-NC-SA 4.0 + commercial/royalty clause) + CONTRIBUTING.md (issue-first,
      approval-gated, PR must match license) + CONTRIBUTORS.md  ← iteration 62
- [x] F1. Suricata IDS lab (BF15) — SIP scanner/flood/toll-fraud rules; EVE→nftables-ipset (same
      sink as BF12) + Wazuh; the IDS stage of the M13→detect→M15 pipeline (Q5). verify.sh 9/9. ← iter 67
- [ ] F4. Papers ingestion workflow (feedback3): `papers/` is gitignored — the maintainer drops
      articles (any format) there; convert each to Markdown, KEEP THE MD ONLY, then fold genuinely
      relevant/useful conclusions into the course content **with a citation** (added to the
      bibliography). Ask the maintainer when a paper's usefulness is uncertain. Never commit the
      source papers; only distilled, cited conclusions land in tracked content.
- [x] F2. AI-slop content review pass — audited tracked markdown for AI-vocabulary, negative parallelism, promo/superlative, superficial -ing, trendslop, and correlation-as-causation: CLEAN (only legit hits: paper titles, digest-auth "realm", "powerful" attack-surface descriptor). Shipped reusable `course/references/slop-check.sh` (advisory) + CONTRIBUTING hook. ← iter 68
- [ ] F3. Issue-triage loop — read `gh issue list`, draft a planned response per open issue, act
      ONLY after the maintainer approves in the issue thread. (feedback.txt.)
- [x] F5. Emergency-calling coverage for multiple jurisdictions (feedback3). BF2 covers US (Kari's/
      RAY BAUM'S), AU 000 (C674:2025), EU 112 (EECC Art 109 + ETSI TS 103 479 NG112 + EENA), UK 999/112
      (Ofcom), cited in bib §11b. **NG112 routing lab hook added iter 76**: `emergency-route.sh`
      (ECRF/LoST stand-in) maps (number, jurisdiction) → PSAP and is **fail-closed on missing
      location**; verify.sh now 14/14. ← iter 76
- [x] F6. VoIP RFC dependency map (feedback4) — `course/references/rfc-dependency-map.md`, a Mermaid
      graph (29 nodes/27 edges, validated) of how the core SIP/VoIP RFCs build on RFC 3261; the VoIP
      analogue of the RPKI RFC dependency graph. ← iter 71
- [x] F7. Device-config-security (feedback6) — folded into BF4: Comms Council UK *Recommendations for Device Provisioning Security* (UK code) as the authority + Yealink RPS / Crexendo vendor docs as concrete examples; bibliography §11b/§11c. ← iter 74

### Stage G — full consistency audit (feedback13: next 8 iterations)
Reserve the next 8 loop iterations for a fuller cross-course consistency check. One pass per iteration,
fixing what it finds:
- [x] G1. Threat catalog T1–T15 — used consistently across every module + lab; none undefined/orphaned.
- [x] G2. Citations — every module `## References` is a subset of, and consistent with, the bibliography
      (Q2); RFC numbers/titles/years correct; no dangling cites.
- [x] G3. Lab ↔ module alignment — each module has its lab; every lab ships a fail-closed `verify.sh`;
      rubrics sum to 100 (pass ≥ 70).
- [x] G4. Internal links — every relative link in course/ + lab/ resolves to a real file/anchor.
- [x] G5. Terminology/glossary — acronyms spelled out first-use; glossary covers what the modules use.
- [x] G6. Security invariants — fail-closed graders, no committed secrets, offensive tooling lab-scoped.
- [x] G7. Assessments — quiz bank + 3 exams map to modules; answer keys separated; capstone gate intact.
- [x] G8. Naming/branding (VoIPSec, zero SOVOC), build_plan ↔ reality, requirements-traceability refresh.
Fold F8/F9 opportunistically during these passes.

### Stage F — community & licensing (continued)
- [x] F8. VoWiFi / WiFi-calling (feedback2/3): add **GSMA IR.51/IR.61** (VoWiFi/roaming) to the
      bibliography, and fold the CISPA VoWiFi key-exchange paper (venue-checked) into M10/M11 (media
      security) — empirical evidence on commercial VoWiFi IPsec/IKE weaknesses.
- [x] F9. Track Henning Schulzrinne's standards work (feedback9) — a "key authors" note in the
      bibliography (SIP 3261, RTP 3550, RTSP, plus his emergency-calling contributions).

### Stage H — post-audit content expansion (feedback0/1, execute AFTER the G-audit)
- [x] H1. **Promote M9D (DNS Infrastructure) into the main module series** — it is core, not an
      optional extra. Renumber it into sequence and update every reference (modules, labs BF14,
      bibliography, crosswalk, dependency map). Big cross-cutting refactor — do carefully post-audit.
- [x] H2. **Provisioning-security expansion** — "device config files in the clear are a major SIP
      security hole." DONE (iter 107): dedicated module **M14 Provisioning & Device Configuration
      Security** (placed after M13 per feedback; old M14–M19 → M15–M20). Covers cleartext-config
      threat (T15), redirection/RPS + zero-touch (mTLS/MAC allowlist/CN-scoping), signed **and**
      encrypted configs, key rotation. Lab = BF4 (`verify.sh` + `sign-config.sh` + `encrypt-config.sh`).

## Stage I — Full authored instructor decks (feedback iter ~123: "write the full decks, one module/iteration")
Upgrades E4: decks move from mechanically-generated outlines to **hand-authored, presentation-ready
MARP decks** (real teaching slides + instructor speaker notes). One module per loop iteration, in order.
Tooling reconciled: decks are now source-of-truth (marked `<!-- deck-status: authored -->`);
`build-slides.sh` only **scaffolds** un-authored modules and never clobbers an authored deck;
`slides/verify.sh` drops the byte-drift check for a **quality bar** (≥10 slide separators, ≥4 speaker
notes, a Lab slide) + prints `authored N/21` progress. Deck spec: title+one-liner slide, objectives,
per-5-beat teaching slides w/ speaker notes, a security-takeaway/quick-check slide, lab & assessment.
- [x] I0. Tooling + exemplar — non-destructive scaffolder, quality-bar verify.sh, **M0 deck authored**.
- [x] I1..I20. **STAGE I COMPLETE** — all 21 decks hand-authored (M0…M19 + capstone), one per
      iteration. `slides/verify.sh` PASS: authored 21/21, quality bar met (≥10 slides, ≥4 speaker
      notes, Lab/Deliverable slide). Capstone exempted from the Lab-slide rule (deliverables deck).

## Stage J — Deck render + readability/fit check (feedback1: render each deck in Playwright headless)
Render every authored deck (marp-cli → HTML/PDF) and check readability under a headless browser
(Playwright + xvfb), **including per-page overflow** — content must fit each slide. Wire into the
existing `course/instructor/marp/` Makefile + render-check.js (memorized tooling: Makefile + Playwright
+ headless X). Fail-closed: a slide whose content overflows the page fails the check.
- [ ] J0. Render pipeline (marp-cli build all 21 decks) + Playwright fit/overflow check under xvfb.
- [ ] J1. Fix any decks that overflow; re-run until all pass.

## Stage K — SIP workflow state-diagram library (feedback2 + feedback3)
A library of **self-generated** state/sequence diagrams for common SIP workflows (feedback3 rule:
own source only, no 3rd-party images — see `references/diagrams.md`). Workflow list gathered WITH the
maintainer (feedback2: "ask me for ideas"; example given: non-authorised calls). Each diagram:
Mermaid/Graphviz source + rendered SVG, embedded in the relevant module + slide, listed in the registry.
- [~] K0. Workflow list — AskUserQuestion sent iter 144; **no response (maintainer away)**, so
      adopting the **provisional** 8-workflow set from `references/diagrams.md` (call flows:
      registration+unauthorised-call, INVITE dialog+BYE, forking+CANCEL race, NAT traversal; security
      flows: STIR/SHAKEN, TLS+media crypto, DNS 3263+spoof defense, fraud/flood). List stays OPEN —
      maintainer can add/drop any time via feedback. Start order: **registration + unauthorised call**
      (the maintainer's explicit example) first.
- [x] K1..K8. **STAGE K provisional set COMPLETE** — 8 self-generated Graphviz→SVG diagrams
      (registration+unauth call·M13, INVITE dialog·M2, forking+CANCEL·M2, NAT traversal·M8,
      STIR/SHAKEN·M13, TLS+SRTP crypto·M12, DNS 3263+spoof·M10, fraud/flood IR·M17), each embedded in
      its module + listed in `references/diagrams.md`. Library stays open to maintainer additions.
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
  bound to loopback+ACL, users 1003/1004 in restricted `voipsec` context (T4), echo/tone tests.
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

- Iteration 52 (2026-07-04): built BF14 (DNS infra, M9D runnable) — db.lab.voipsec.test (RFC 3263
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

- Iteration 57 (2026-07-04): built D0 (instructor slide outlines). build-slides.sh generates 20
  MARP decks from the module docs (single source) — title, objectives, 5-beat sections, speaker
  notes, lab closer. verify.sh: one deck/module, MARP-valid, drift check. PASS. Decks are E4's
  input. Only E4 (MARP render tooling) remains.

- Iteration 58 (2026-07-04): built E4 (MARP render tooling). Makefile (marp-cli html/pdf/check/
  watch/clean), render-check.js (Playwright opens each rendered deck under xvfb, asserts MARP
  slides + no page errors), verify.sh (SKIPs cleanly if toolchain absent). The toolchain (marp,
  node+playwright, xvfb) was present — ran it: **20 decks render, all PASS**. node_modules/out/
  gitignored. **BUILD BACKLOG COMPLETE** — 0 open items; only E0/E3 remain `[~]` (ongoing CI /
  living bibliography). Remaining discretionary: `.claude`/SSCA-PDF git-history purge (deferred by
  user), E0 dockerized smoke test in CI.

- Iteration 59 (2026-07-04): backlog complete, so advanced E0's remaining TODO — end-to-end smoke
  test. `lab/smoke-test.sh` (up → wait-for-health → M0 segmentation grader → REGISTER through the
  SBC, teardown), `make smoke`, and `.github/workflows/smoke.yml` (manual workflow_dispatch — heavy
  image builds kept off per-push CI; no untrusted github.event input). bash/YAML-checked. Did NOT
  do the deferred `.claude`/SSCA history purge (needs explicit user go-ahead + force-push).

- Iteration 60 (2026-07-04): integrity sweep (15/15 offline graders + 3/3 validators PASS, tree
  clean/no drift). Then, on explicit user go-ahead, **purged git history**: `git filter-branch`
  removed `.claude/` (+ `course/.claude/`) from all 63 commits; cleaned refs/original + reflog +
  gc; force-pushed with `--force-with-lease` (76b45de → 1b7f888). Verified 0 `.claude` in HEAD/
  branch/all-history, 139 lab+module files intact. (SSCA PDF was already purged in the very first
  rewrite.) Note: GitHub may retain old blobs server-side until GC — not secrets, so acceptable.

- Rename (2026-07-04, user-directed): **SOVOC → VoIPSec** across the whole repo (162 files: brand
  text + `sovoc`→`voipsec` slugs incl. compose project `voipsec-lab`, networks `voipsec_*`, nft
  tables, Multus net, Wazuh rules; renamed files `db.lab.voipsec.test`, dialplan `voipsec.xml`).
  Regenerated exam.html + slide decks. Verified: 8 offline graders + bf14 PASS, compose config
  VALID, all 3 assessment/instructor validators PASS (drift clear). Credential subtitle kept
  ("Secure Open-source VoIP Operations").

- Iteration 62 (2026-07-04): processed 3 feedback files (priority over backlog). **Fixed .gitignore**
  (`/feedback.txt`+`/feedback*.md` → `/feedback*`) — feedback1.txt/feedback2.txt were NOT ignored and
  could have been committed. Built F0: LICENSE (CC BY-NC-SA 4.0 + commercial/royalty clause, contact
  contact@ieisi.org), CONTRIBUTING.md (issue-first, approval-gated; PR must match license + add to
  contributors; no-secrets/lab-scoped rules; accuracy-over-trend), CONTRIBUTORS.md. Logged F1
  (Suricata IDS), F2 (AI-slop review), F3 (issue-triage loop) to the backlog. Answered the questions
  in questions.md; memorized the AI-slop guidance. Deleted the 3 feedback files (never committed).

- Iteration 63 (2026-07-04): processed 4 feedback files. Q5 → Suricata integrates into M13→M15
  pipeline (F1 note updated). Q6 → commercial contact = contact@ieisi.org + www.ieisi.org/contact +
  /training (LICENSE, CONTRIBUTING updated). feedback3 → `papers/` gitignored + F4 ingestion
  workflow added (convert→keep MD→fold cited conclusions→ask if unsure; never commit sources).
  feedback4 → history purge of all feedback-named paths (root feedback*.txt + course/reviews/
  feedback-*.md + gemini_feedback*.md) via filter-branch + force-push; substance retained in this
  feedback log. Deleted the 4 feedback files (never committed).

- Iteration 64 (2026-07-04): F4 papers ingestion — 3 PDFs dropped in `papers/`, converted to MD
  (pdftotext), PDFs removed (MD kept, gitignored). Folded 2 high-authority sources into cited
  content: **Keromytis, IEEE COMST 2012 VoIP-security survey** → bibliography §11 + M13 (impl
  bugs/misconfig = primary vuln source; DoS/service-abuse under-addressed); **Raut/Shukla/Modi, J.
  Digital Security & Forensics 2026 VoIP forensics review** → bib §11 + M5 (volatile+encrypted
  evidence → memory forensics + ML detection complement capture). Paper 3 (Bernard, Walden doctoral
  study 2022) held pending user decision (Q7 — managerial register, uncertain fit). Citations taken
  verbatim from the PDFs (no memory guessing, per anti-slop guardrail). F1 (Suricata) deferred to
  next iteration.

- Iteration 65 (2026-07-04): finished paper-3 handling per Q7 — Bernard (Walden 2022) gets **one
  MARP slide only**: hand-authored `slides/z-appendix-governance.md` (4 governance themes + practitioner
  recs, incl. card-number masking → BF8) + cited in bibliography §11; NOT folded into module prose.
  Taught the slides pipeline about hand-authored appendices: `slides/verify.sh` excludes `z-*` from
  the per-module count (still MARP-validates), `marp/render-check.js` now render-checks `z-*` too
  (21 decks PASS under xvfb). Memorized the standing rule **always cite papers we process+use**
  ([[cite-processed-papers]], feedback2). Deleted feedback files. F1 (Suricata) still next.

- Iteration 66 (2026-07-04): (1) **Dropped Bernard** per feedback — removed the governance appendix
  slide, its bibliography entry, and MD; restored slides/verify.sh + marp/render-check.js to
  pre-appendix state (management, not technical). Q7 marked DROPPED. (2) Processed new paper
  **VoIPSA VoIP Security & Privacy Threat Taxonomy (Public Release 1.0, 2005)** → bibliography §11 +
  M13: the canonical six-category classification (Social, Eavesdropping, Interception & Modification,
  Service Abuse, Intentional Interruption of Service/DoS, Physical Intrusion) that the course's
  T1–T15 catalog maps onto and that Keromytis extends. Citation verbatim from the PDF. F1 (Suricata)
  still next.

- Iteration 67 (2026-07-04): deleted a stale duplicate feedback (Bernard-drop, already done iter 66).
  Built **F1 = BF15 Suricata IDS** (Q5 decision — the IDS stage of M13→detect→M15). suricata-voip.rules
  (scanner UAs, OPTIONS sweep, REGISTER/INVITE floods, toll-fraud dial prefixes, oversized SIP;
  local sid 9000000+), suricata.yaml (HOME_NET, SIP app-layer, EVE JSON), eve-to-ipset.sh (EVE alerts
  → same nftables-ipset sink as BF12's hp2ipset.sh). verify.sh PASSES 9/9, self-validating (bans only
  VOIPSEC-alert sources; ignores non-alert flows + non-VOIPSEC alerts). Cross-linked into M15.

- Iteration 69 (2026-07-04): F4 — processed paper **Kolahi et al. (2013), "Impact of IPSec Security
  on VoIP in Different Environments"** → bibliography §11 + M9 (trunk security). Cited the measured
  tradeoff (IPsec adds CPU + delay; throughput ~unchanged; RTT/jitter inconsistent) as evidence that
  trunk crypto must be capacity-budgeted, and why per-hop TLS+SRTP is often preferred over a blanket
  IPsec tunnel. Attributed carefully (small single test-bed; no overclaiming on the inconsistent
  metrics, per anti-slop guardrail). MD kept in papers/ (gitignored); citation verbatim from source.

- Iteration 70 (2026-07-04): **peer-review audit** (feedback: use only peer-reviewed papers). Checked
  venues of 4 new + recent papers. KEPT/folded peer-reviewed: **Dantu et al. (Elsevier Computers &
  Security 2009**, co-author Schulzrinne) → M1; **Mohd Ramly et al. (JTDE 2024)** → M13; Keromytis
  (IEEE); **Kolahi — corrected 2013→IEEE ICUFN 2017** (WebSearch-verified; DOI added) after catching
  my own guessed year. REMOVED (not peer-reviewed): Raut et al. (Granthaalayah — questionable
  publisher; unfolded from M5+bib), "Enhancing…" (Macron, no venue), "Threat Detection…" (Martins, no
  venue). Kept VoIPSA taxonomy as a standards doc. Q8 flags the two judgment calls. Memorized the
  peer-review gate ([[cite-processed-papers]]). Deleted feedback + all source PDFs (papers/ = 5 MDs).

- Iteration 71 (2026-07-04): processed 6 feedback + logged a 7-paper batch (queued for venue-check).
  Q8 resolved (drop Raut for good; keep VoIPSA as aged rebuttable standard). Added **Broadband Forum
  TR-104 Issue 2** to bibliography (§11b, new non-RFC standards section; feedback5). Built **F6 VoIP
  RFC dependency map** (Mermaid, 29 nodes/27 edges, structurally validated; feedback4). Logged **F5**
  (emergency AU/UK — real gap: BF2 is US-only), **F7** (vendor device-config-security from Crexendo/
  Yealink docs). 7 dropped papers (SIP papers + TR-104 + vendor docs) queued for venue-checked
  ingestion next. Deleted all 6 feedback files.

- Iteration 72 (2026-07-04): MEMO (feedback2) → memorized **source priority: standards & codes of
  conduct > peer-reviewed papers**. Processed **C674:2025** (dropped) — turned out to be the ATA
  industry code *Emergency Calling – Network and Mobile Phone Testing* (not SIP headers as the user
  recalled). Added to bibliography §11b (cited, not reproduced — © ATA), and folded a "Jurisdictions"
  note into BF2 (US/AU/UK-EU) → F5 now `[~]` (AU started; UK/EU remain). Deleted 2 feedback. The
  other queued papers (vendor docs, SIP papers) still pending venue-checked ingestion.

- Iteration 73 (2026-07-04): feedback9 → converted all remaining papers/ PDFs to MD (0 PDFs left,
  gitignored). F5 EU (feedback1/2): added **EECC Art 109** (Directive (EU) 2018/1972), **ETSI TS 103
  479** (NG112 — corrected from the user's "TR 103 479"; WebSearch-verified title), and **EENA** to
  bibliography §11b; expanded the BF2 Jurisdictions note to US/AU/EU/UK. Refined C674 note (it defines
  AU emergency SIP-header requirements). F5 now covers all four jurisdictions at the standards level;
  only a NG112 routing/testing lab hook remains. Deleted 3 feedback files.

- Iteration 74 (2026-07-04): F7 device-config-security — folded into BF4: **Comms Council UK
  *Recommendations for Device Provisioning Security*** (UK code; HTTPS + factory client certs, no
  TFTP/HTTP, delete SIP passwords post-provision — validates BF4's design) as the authority, plus
  Yealink RPS + Crexendo vendor docs as concrete examples. Bibliography §11b (UK code) + new §11c
  (vendor docs, lowest-authority class). Triaged the paper queue: **rejected** Session_Initiation_
  Protocol (IJSER, predatory). Remaining queued: Bur Goode (Proc. IEEE — keep, fold to M1), a Journal
  of Communications SIP study + an EU emergency legislation slide (assess). No feedback this iter.

- Iteration 75 (2026-07-05): deleted 3 stale duplicate feedback (EU-emergency items already done
  iter 73). Finished paper-queue triage: folded **B. Goode, *VoIP*, Proc. IEEE 2002** (invited;
  vol/no/DOI verified from the PDF) into M4 + bibliography §11 (delay-vs-bandwidth budget authority).
  **Rejected** the Journal of Communications P2P-SIP study (Academy Publisher — marginal, redundant).
  EENA legislation slide is redundant with the existing EENA/EECC citations (no new cite). papers/ =
  12 MDs, all triaged; the remaining ones are the kept sources.

- Iteration 76 (2026-07-05): built the F5 NG112 routing lab hook — `lab/labs/bf2-emergency/
  emergency-route.sh`: a deterministic ECRF/LoST (RFC 5222) stand-in mapping (dialed number,
  jurisdiction) → PSAP for US 911 / AU 000 / UK 999 / EU 112, **fail-closed on missing dispatchable
  location** (the invariant shared by RAY BAUM'S / EECC Art 109 / C674). Extended BF2 verify.sh with
  6 routing tests (now 14/14, self-validating: locationless call REFUSED, non-emergency not
  misclassified). **F5 complete.** No feedback this iter.

- Iteration 84 (2026-07-05): feedback — added the IETF **ECRIT** emergency-RFC family to bibliography
  §6 (**RFC 6443** framework, **6881** BCP 181, **5222** LoST/ECRF, **6442** location conveyance,
  **7852** additional data) + the ECRIT WG charter; cross-referenced in BF2. Added the three new
  nodes (5222/6881/7852) to the RFC dependency map (re-validated: 32 nodes/30 edges). Processed 2 new
  AU standards: **Comms Alliance C536:2025** (Emergency Call Service Requirements) and **G673:2024**
  (*Transport of SIP* — the AU SIP guideline the user meant by "G674") → bibliography §11b. Deleted 2
  feedback + 2 source PDFs.

- Iteration 85 (2026-07-05): feedback1 → replaced the Mermaid RFC map with a Graphviz **SVG**
  (`rfc-evolution-map.dot`/`.svg`): left-to-right by year, domain-coloured, **obsoleted RFCs dashed
  with red "replaced by" edges** (2543→3261, 2327→4566→8866, 1889→3550, 3265→6665, 2617→7616) —
  showing the course tracks superseded standards. 31 RFC nodes, well-formed SVG. Recorded **Stage G**
  (feedback13: next 8 iterations = full consistency audit, G1–G8) and queued **F8** (VoWiFi/GSMA +
  CISPA paper, feedback2/3) + **F9** (Schulzrinne tracking, feedback9). Converted 2 new papers to MD.
  Deleted 5 feedback. Next: G1 (threat-catalog consistency).

- History purge (2026-07-05, user-directed): removed the stray `index.html` (copyrighted saved
  web page) from all history via filter-branch; force-pushed with lease (ccc39c8 -> fc01731).
  0 hits in history; 265 files intact. Now gitignored so it can't recur.

- Iteration 86 (2026-07-05): **G1 threat-catalog consistency pass**. All T1-T15 defined (notes.md
  §2) and actively used (8-31 refs each); no orphans, none out-of-range. Found + fixed **4 mapping
  drifts** where the catalog claimed a module treats a threat but the module didn't tag it: added
  T1/T2/T3 to M14 (brute-force/scan defense), T4 to M15 (toll-fraud CDR detection), T12 to M10
  (mutual-TLS trunks). Re-verified: catalog fully consistent (0 mismatches). feedback0 - TelcoBridges
  YouTube noted as a pending source (user to transcribe); converted the TelcoBridges SIP-headers
  article to MD (vendor blog, not folded - RFC 3261 is the header authority). Next: G2.

- Iteration 87 (2026-07-05): **G2 citations consistency pass**. Extracted every RFC cited across
  the 19 module docs (incl. slash-lists) vs. the bibliography+maps (77 RFCs). Found **1 dangling**
  cite: M17 referenced **RFC 3863** (base PIDF) not in the bibliography -> added it alongside RFC
  3856 (presence). Re-verified: 0 dangling — every module RFC cite is backed (Q2 subset rule holds).
  Next: G3 (lab<->module alignment).

- Iteration 88 (2026-07-05): **G3 lab<->module alignment pass** — CLEAN. 32 labs; modules M0-M17
  all have a lab; every lab ships a verify.sh with a fail path (exit 1); all 32 rubrics parse and
  sum to exactly 100 (pass >= 70). No defects. Next: G4 (internal-link integrity).

- Iteration 89 (2026-07-05): **G4 internal-link integrity pass** — CLEAN. Checked 147 relative
  Markdown links across all tracked docs (course/, lab/, root README/CONTRIBUTING, image links incl.
  the RFC SVG): every one resolves to a real file. No broken links. Next: G5 (terminology/glossary).

- Iteration 90 (2026-07-05): **G5 terminology/glossary pass**. Extracted 201 distinct domain
  acronyms across modules; the glossary covered only ~65. Added **49 entries** (55 -> 104): SDES,
  ALG, MITM, TTL, IVR, SAS, ISUP, SPIT, SS7, HMAC, WAF, RRL, DMZ, standards bodies (IETF/ATIS/NIST/
  NENA/GSMA/ENISA/OWASP/PTES), telephony KPIs (ASR/ACD/PDD/RTT), codecs (AMR/EVS/CBR/VBR), crypto
  (AEAD/AES-GCM/JWT/HSM/SAN/DH), + a 'SIP methods' line. Residual ~57 are non-glossary tokens (tool
  names HOMER/BIND9/PJSIP, citation venues IEEE/JTDE, English-word false positives, terms spelled out
  in-context). First-use spell-out stays light-touch (Q4); glossary now backstops it. Next: G6.

- Iteration 91 (2026-07-05): **G6 security-invariant pass** — CLEAN. (1) No committed secrets: no
  PEM private keys; every password/secret is a placeholder (`__FROM_ENV__`/`__INJECTED__`) or
  env-injected, or an auditor grepping *for* a setting. (2) Fail-closed graders: all verify.sh exit 1
  on failure; the two `|| ok` uses (bf8 PAN-absent, m16 no-github.event) are correct negative tests.
  (3) Offensive tooling lab-scoped: redteam container attaches to edge+redteam ONLY (never core/mgmt);
  `_guard.sh` refuses any target outside 172.28.10/40 and is sourced by 5 scripts; AUTHORIZED_USE
  present. No defects. Next: G7 (assessments alignment).

- Iteration 92 (2026-07-05): **G7 assessments-alignment pass**. Quiz-bank + capstone validators
  PASS; 3 checkpoint exams (M5/M12/M17) present; answer keys separated in answer-keys/ (3 keys) with
  **no leakage** in exam files — the 2 grep hits were references-to-the-key, not answers. Fixed a
  stale line in checkpoint-exam-1 ('answer key at the bottom' -> 'held separately'). Also recorded
  **Stage H** (feedback0/1, post-audit): H1 promote M9D DNS into the main module series; H2 expand
  provisioning-security (cleartext config = major hole). Next: G8 (naming/traceability) — last pass.

- Iteration 93 (2026-07-05): **G8 naming/branding + traceability pass — the 8-pass audit is
  COMPLETE (G1-G8).** Zero live SOVOC residue (only the 3 intentional rename-log lines in this
  file). build_plan<->reality spot-check: all sampled done-items have their artifacts. **Refreshed
  requirements-traceability.md** (was frozen ~iter 50): closed the packaging tier + all BF labs,
  added the post-rename era (VoIPSec, Stage F community/licensing, multi-jurisdiction emergency,
  peer-review gate, G1-G8), updated verification health. Remaining open = reactive (F3/F4) +
  planned Stage H (H1 DNS-into-main, H2 provisioning-security). **Next: begin Stage H (H1).**

- Iteration 94 (2026-07-05): **H1 — promoted the DNS module into the main series.** DNS is now
  **M10** (`10-dns-infrastructure.md`); former M10-M17 shifted +1 to M11-M18, capstone 18->19. Done
  with a collision-free token-renumber over 214 content files + file/lab-dir renames + module-map
  table + regenerated slides/exam. **First attempt had a placeholder off-by-one bug -> caught by the
  verification gate, `git reset --hard`, redone correctly.** Verified GREEN: 0 broken links, quiz/
  capstone/slides validators PASS, offline graders PASS, threat-catalog map still 0 mismatches.
  NOTE: earlier log entries + Stage B backlog use the pre-shift numbering (they narrate past state);
  current course content uses M10=DNS. Checkpoint exams now after M5/M13/M18. Next: H2.

- Iteration 95 (2026-07-05): feedback 'move DNS to M10 and renumber' — already done (H1, iter 94);
  deleted as satisfied. **H2 step 1 (config confidentiality)**: added `encrypt-config.sh` to BF4 —
  AES-256-CBC/PBKDF2 encrypt/decrypt + **key rotation** (re-key without persisting plaintext), the
  direct fix for 'config files in the clear'. BF4 verify.sh now 12/12 (encrypted config hides the
  secret, round-trips, tamper rejected). Extended **T15** (cleartext config exposure -> signed AND
  encrypted configs + rotation). H2 left `[~]`: a *dedicated* provisioning-security module would
  need a placement decision + another renumber — deferred to the user's steer (won't renumber
  reactively). Next: continue H2 / reactive backlog.

- Iteration 96 (2026-07-05): **CI fix** (feedback). The H1 renumber (iter 94) renamed lab dirs but
  my content-replace scope excluded `.github/`, so `ci.yml` still ran `labs/m14-defense-fraud` and
  `labs/m15-monitoring-ir` (now m15-defense-fraud / m16-monitoring-ir) -> CI offline-grader step
  failed. Fixed both paths; both graders PASS locally; ci.yml valid YAML. Swept all tracked scripts/
  workflows for stale `labs/m<n>-` refs -> none. (Lesson: renumber scope must include .github/.)

- Iteration 97 (2026-07-05): **F8 VoWiFi/GSMA**. Venue-checked the CISPA VoWiFi paper -> Gegenhuber
  et al., **USENIX Security 2024** (verified via WebSearch; I'd have guessed 2023) -> bibliography §11.
  Added **GSMA IR.51/IR.61** (VoWiFi/Wi-Fi roaming) as a new §11d (mobile standards). Folded a VoWiFi
  section into M18 (frontiers): IMS-over-Wi-Fi via IPsec/IKEv2 to the ePDG, with the paper's finding
  (13 operators/~140M users on weak/downgradeable DH groups -> MITM) as the crypto-agility lesson.
  Next: F9 (Schulzrinne) / reactive backlog.

- Iteration 98 (2026-07-06): **F9** — added a 'Key standards contributors' note to the bibliography
  tracking **Henning Schulzrinne** (co-author RFC 3261 SIP; first author RFC 3550 RTP + RFC 2326 RTSP;
  ECRIT/NG911 emergency-calling leadership; FCC CTO; + the Dantu 2009 survey we cite), with his IETF
  datatracker + Scholar links (feedback9). Cited only specs I'm confident of (verify-don't-guess).
  Stage F queued items now done (F8/F9); remaining: F3/F4 reactive + H2 (dedicated provisioning
  module awaits user placement call).

- Iteration 99 (2026-07-06): post-refactor integrity sweep (graders/validators/links/slop all
  PASS; module sequence 00-09,10=DNS,11-18,19=capstone). Caught one **real drift**: iter 97 edited
  M18 (VoWiFi section) but didn't regenerate its MARP deck -> the slides drift check flagged it.
  Regenerated `slides/18-frontiers.md`; SLIDES PASS. (The drift check earned its keep.)
- Iteration 107 (2026-07-06): **H2 done** — processed `feedback1.txt` ("place new provisioning
  after M13 and renumber"). Inserted **M14 Provisioning & Device Configuration Security** (maps
  T15; lab = BF4 + `encrypt-config.sh`), shifted old M14–M19 → **M15–M20** via descending
  collision-free token passes over 214 files + 31 git-mv renames (module/slide files, lab dirs
  m14–m18 → m15–m19). Regenerated 21 slide decks + `exam.html`; added 2 M14 quiz Qs (coverage
  M0–M19). Reassigned BF4 + threat-catalog T15 to M14. **Renumber misses caught** (the point of
  the audit): (a) overview map used bare `| 14 |` numbers — rebuilt + inserted M14 row; (b) README
  map still carried the **pre-H1 `9D` DNS number** and lagged filenames by one — rebuilt to true
  numbering; (c) three prose module-counts "19 modules" → "20". CI offline-grader paths shifted
  correctly this time (`.github/` was in scope — iter-96 lesson held). Verify: bash -n / YAML /
  offline graders (m16-defense, m17-monitoring) / quiz / slop all PASS; 0 broken content links.
  Next 2 iterations: continue auditing for missed changes per the feedback.
- Iteration 108 (2026-07-06): **renumber-audit pass 1** (feedback1's "next 2 iterations"). Found
  the miss-class the token pass structurally can't catch: **bare numbers in prose** (not `M<n>` /
  `Module <n>` form). Fixed: prereq lists — M17 `5,13,14`→`5,13,15`, M18 `6–15`→`6–16`, M19
  `M1–16`→`M1–17`; capstone range `0–17`→`0–19`. Bigger find: **`Lab N.x` sub-numbers had drifted
  from `module N`** — H1 (DNS→M10) never re-synced them (modules 11–13 lagged 1) and H2 widened it
  to lag-2 (modules 15–19) **and collided** my new M14 `Lab 14.x` with defense's stale `Lab 14.x`.
  Restored the course's own convention (`Lab N.x == module N`) across 8 module groups (docs + lab
  dirs + regenerated slides); verified every module 0–19 now self-consistent, no collision. Topical
  `Module N` cross-refs (threats→16 harden, →17 detect) were already correct. Verify: bash -n / quiz
  / offline graders (m16,m17) / slop all PASS; 0 broken links. (Runtime graders m11/12/13/15 FAIL
  offline — pre-existing service dependency, not this change.) 1 audit pass left.
- Iteration 109 (2026-07-06): **renumber-audit pass 2 — renumber CLOSED**. Residual long-tail
  swept and fixed: delivery-guide count/hours ("18 modules + M10" → "20 modules … + capstone;
  ~105 h") + bootcamp cadence (6→7 modules/wk); README "modules/00…18" → "00…19 + 20-capstone";
  module-00 "across 18 modules" → 20 (regen slide); traceability A4 count + the DNS status row
  (stale `09d-dns-infrastructure.md`/"BF14 pending" → `10-dns-infrastructure.md`/done). Also
  fixed **H1-era drift the DNS promotion missed**: module M10's labs were still `Lab 9D.x` →
  `Lab 10.x`. Final state: every module 0–19 has `Lab N.x == module N`; no residual `9D`/`M9D`/
  stale-count tokens; 0 broken links; quiz/slop/offline-graders PASS. `task_plan.md` left as-is
  (frozen start-of-project planning doc, like this log). H2 + its 2-pass audit fully complete.
- Iteration ~123 (2026-07-07): after a run of idle iterations, processed `feedback1.txt` — "plan
  autonomously writing the full decks for all modules, one module per iteration." Opened **Stage I**.
  Reconciled the slide tooling so authored decks can coexist with the scaffolder: `build-slides.sh`
  now skips any deck marked `<!-- deck-status: authored -->` (non-destructive); `slides/verify.sh`
  drops the byte-drift check for a full-deck **quality bar** (≥10 separators, ≥4 speaker notes, a Lab
  slide) + `authored N/21` progress. Authored the **M0 exemplar deck** (12 slides, instructor speaker
  notes, 5-beat coverage, ethics gate). SLIDES verify PASS 4/4, progress 1/21. Next iterations: one
  authored deck each, M1 → capstone.
- Iterations 124–143 (2026-07-07/08): **Stage I executed** — authored all 21 full decks (M1…M19 +
  capstone), one per loop iteration, each verified (SLIDES PASS 4/4) and pushed. Capstone exempted
  from the Lab-slide quality rule (deliverables deck). Stage I COMPLETE at 21/21.
- Iteration 144 (2026-07-08): processed **3 feedback files**. (f3) Created `references/diagrams.md`
  — a diagram registry + the **self-generated-only rule** (own Graphviz/Mermaid→SVG source, no
  3rd-party images); linked from the bibliography. Inventory: 1 current diagram (RFC evolution map).
  (f1) Opened **Stage J** — Playwright headless render + per-page overflow/fit check for the 21 decks.
  (f2) Opened **Stage K** — self-generated SIP workflow state-diagram library; **AskUserQuestion sent
  to gather the workflow list** (maintainer example: non-authorised calls). Feedback files consumed.

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
