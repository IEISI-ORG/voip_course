# Capstone — Design, Deploy, Secure, Attack, Defend & Operate a VoIP Platform

**One-liner:** Prove mastery by delivering a complete, hardened, observable VoIP platform and the
operational artifacts to run it. **Est. time:** 10h+ · **Prereqs:** all modules.

## Objective
Take the platform grown across Modules 0–17 to a production-grade, defensible state, then prove
it under authorized attack and operate it through simulated incidents.

## Deliverables (the graded artifacts)
1. **Architecture document** — topology, trust boundaries, data flows, component choices
   (Asterisk/FreeSWITCH + Kamailio/OpenSIPS + rtpengine + edge + observability), with rationale.
2. **Reproducible deployment** — one-command bring-up (compose) plus an IaC variant
   (Ansible/Terraform); parity between them; secure CI pipeline (lint + SIPp smoke + image scan).
3. **Security implementation** — TLS/SIPS everywhere external, SRTP/DTLS-SRTP media, SHA-256
   digest, STIR/SHAKEN sign+verify, topology hiding, edge firewall + rate limits + fail2ban,
   toll-fraud controls (limits/allowlists/auto-suspend).
4. **Living threat model (final)** — every threat in `../notes.md §2` addressed or accepted with
   rationale; residual risk register.
5. **Hardening checklist (final)** — each item mapped to the threat it mitigates, with evidence.
6. **Authorized red-team report** — full assessment (M14 methodology) against the final platform,
   with before/after deltas showing earlier findings remediated.
7. **Observability** — KPI dashboards, alerts covering all M14 signatures, detection-coverage map.
8. **Incident-response runbooks** — for toll fraud, INVITE flood, credential compromise, and
   suspected eavesdropping; each executed once with an incident report + timeline.
9. **Operations guide** — backup/restore, cert rotation, capacity limits, upgrade procedure,
   on-call escalation.

## Assessment Rubric (100 pts)
- Functionality (calls, trunk, features, fax, ENUM) — 15
- Reproducibility & IaC parity + secure CI — 15
- Signaling + media encryption correctness (verified in capture) — 15
- Identity (digest + STIR/SHAKEN, attestation logic) — 10
- Edge/border defense (firewall, rate limits, topology hiding) — 10
- Fraud prevention (limits, detection, containment demonstrated) — 10
- Observability + detection coverage — 10
- IR runbooks executed with evidence — 10
- Documentation quality (threat model, ops guide) — 5
- **Pass requires ≥70 overall AND no failing security category** (security is mandatory).

## Operations Runbook Templates (starter set)

### Runbook: Suspected Toll Fraud
1. Detect: spend/velocity/off-hours alert (M16).
2. Triage: identify account, destinations, concurrent calls; pull CDR + HOMER trace.
3. Contain: auto/manual suspend account; block destination range; cap spend.
4. Eradicate: rotate credentials, find entry (weak secret? exposed 5060? provisioning?).
5. Recover: re-enable with tightened class-of-service; verify.
6. Review: root cause, loss estimate, control gap → update threat model + checklist.

### Runbook: INVITE/REGISTER Flood
1. Detect: CPS/registration-rate/4xx spike alert.
2. Triage: source(s), transport, target; distinguish attack vs. legitimate surge.
3. Contain: nftables rate limit / geo-block; `pike` tighten; fail2ban ban; scale/roll if needed.
4. Recover: confirm KPI normalization; document thresholds.
5. Review: tune detection; consider upstream/carrier mitigation.

### Runbook: Credential Compromise
1. Detect: auth-failure spike then success from new geo; unusual registration.
2. Contain: suspend/rotate; invalidate registrations; block source.
3. Investigate: how creds leaked (T11/T15); scope other accounts.
4. Recover: enforce stronger secret + TLS-only; monitor.
5. Review: provisioning/secret-hygiene fix.

### Runbook: Suspected Eavesdropping
1. Detect: cleartext media where policy requires SRTP; downgrade alarm; anomalous media path.
2. Contain: enforce SRTP-only; re-anchor media at SBC; rotate keys/certs.
3. Investigate: where downgrade occurred (SBC bridging? peer?); capture evidence (M5 integrity).
4. Recover: close the downgrade path; verify E2E encryption.
5. Review: policy + SBC config hardening.

## Presentation
- Defend the design in a review: walk the threat model, demo an attack being detected+contained,
  and show the platform recovering. Peer + instructor scored.
