# Module 14 — Defense, Hardening & Fraud Prevention

**One-liner:** Turn the Module 13 findings into a hardened platform and stop toll fraud before it
drains a budget. **Est. time:** 6h · **Prereqs:** Module 13.

## Learning Objectives
- Apply a complete, layered hardening baseline across endpoints, PBX, proxy/SBC, and edge.
- Design and implement toll-fraud prevention (limits, allowlists, anomaly detection).
- Automate brute-force/scan defense and validate it against Module 13 attacks.

## 1. Concept
- **Defense-in-depth layers:** network edge (nftables/geo/rate) → SBC (topology hiding, admission,
  `pike`) → proxy (auth, routing policy) → PBX (secure defaults, class-of-service) → app
  (voicemail/feature hardening) → data (secrets, recordings, CDR) → monitoring (M15).
- **Hardening baseline (consolidated checklist):**
  - Transport: TLS/SIPS only externally; drop plaintext 5060 at edge; SRTP-only media policy.
  - Identity: strong SHA-256 digest, no anonymous/guest, uniform error responses.
  - Routing: From-domain + destination allowlists; no open relay; loop protection.
  - Class-of-service: per-account destination restrictions, concurrent-call and velocity caps.
  - Secrets (T11): perms, vault/env, rotation, none in git; secure auto-provisioning over HTTPS
    with signed configs + MAC binding (T15).
  - Feature abuse (T13): PIN policy, disable DISA, restrict `Dial` options, guard feature codes.
- **Toll fraud / IRSF (T4):** how it works (compromised creds → premium/international dialing at
  scale, often off-hours); the money model that makes it attractive.
- **Fraud controls:** destination allow/deny (block high-risk ranges), per-account spend and
  concurrency limits, time-of-day rules, velocity/anomaly detection on CDRs, hard spend caps,
  real-time alerting and auto-suspend.
- **Brute-force/scan defense:** fail2ban jails, `pike`, nftables rate limits, CrowdSec-style
  reputation, lockout/backoff.

## 2. Packet Reality
- Re-run Module 13 attack signatures and show them being dropped/banned/throttled in captures
  and logs — proof the controls work.

## 3. Build (OSS)
- Implement the full hardening checklist across `edge-sbc`, `pbx-a`, `pbx-b`.
- fail2ban jails for Kamailio/Asterisk auth-failure + scan patterns; nftables rate limits.
- CDR-based fraud detection: a script/Wazuh rule flagging abnormal international/premium volume,
  off-hours spikes, and concurrent-call anomalies; wire an auto-suspend + alert.
- Secure auto-provisioning: HTTPS + per-device credentials + config signing.

## 4. Attack / Defend (validation)
- Replay every Module 13 finding; confirm remediation; record residual risk in the threat model.
- Tabletop: an account *is* compromised — what limits the loss? (spend cap, velocity, alerting).

## 5. Labs / Deliverable
- **Lab 14.1:** Apply and commit the **hardening checklist v-final**; map each item to the T# it
  mitigates.
- **Lab 14.2:** Build fraud detection + auto-suspend; simulate an IRSF pattern and show it caught
  and contained within a set spend cap.
- **Lab 14.3:** Re-run the M13 assessment; produce a before/after findings delta.
- *Rubric:* layered baseline applied with evidence; fraud pattern detected + contained; measurable
  reduction in exploitable findings.

## Assessment (sample)
- Give the single most cost-effective control against toll fraud and justify it.
- Why do uniform error responses + rate limiting together beat either alone?
- What makes auto-provisioning a supply-chain risk, and how do you close it?

## Curriculum addition — Secure provisioning & recording compliance (review: gemini_feedback0)

Two of the most common real-world VoIP breaches live in operations: insecure device
provisioning and mishandled call recordings.

**Secure auto-provisioning.**
- **Problem:** plaintext TFTP/HTTP provisioning leaks SIP credentials to anyone on-path (T15).
- **Build:** serve device configs over HTTPS with **mutual TLS** — per-device client certs (or
  MAC-bound tokens), signed configs, and an allowlist so only authenticated hardware can pull
  its own config. No credentials in world-readable files (T11).
- **Lab hook (adds B14+):** provision a phone only over mTLS; prove an unauthenticated request
  is refused and a spoofed MAC cannot fetch another device's config.

**Secure session recording (PCI-DSS aware).**
- **Standards/regulation:** PCI-DSS (no stored PANs/authentication data), lawful-recording and
  consent requirements.
- **Build:** encryption-at-rest for recordings, RBAC + access logging, retention limits, and
  **DTMF suppression / pause-resume** so card numbers spoken or keyed during a call are never
  captured (threat T14).
- **Lab hook:** record a call with DTMF masked during a "payment" segment; confirm no PAN is
  present and every access is logged. Audit/monitoring side continues in M15.

## Curriculum addition — SIP honeypot & dynamic blocklist (review: gemini_feedback1)

A decoy listener turns reconnaissance into free threat intelligence: nobody legitimate ever
touches it, so every hit is a confirmed bad actor you can block pre-emptively.
- **Build:** a dummy Kamailio listener on UDP 5060 while the real service runs SIPS on 5061;
  any request to the honeypot pushes the source into an `nftables` IP set blocklist and emits
  a log event.
- **Attack/Defend (T1/T8):** `svmap` the honeypot from `redteam` and confirm the source is
  auto-banned before it can reach the real service.
- **Lab hook (adds BF12):** deploy the honeypot, scan it, and verify the scanner IP lands in
  the `nftables` set and is refused at the real listener. Aggregation/active-response in M15.

## References
- NIST SP 800-58 (VoIP security), ENISA VoIP security; Asterisk/Kamailio hardening guides;
  fail2ban, nftables, CrowdSec, Wazuh docs; `../notes.md §2` (T4,T11,T13,T15).
