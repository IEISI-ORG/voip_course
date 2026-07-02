# Checkpoint Exam #3 — Answer Key & Rubric (INSTRUCTOR ONLY)

Held separately from the exam. Exam: [`../checkpoint-exam-3.md`](../checkpoint-exam-3.md).

## Answer key
- **1.** Recon→enum→exploit→impact→remediation→detection; the gate = **authorized-use/scope**
  (testing out of scope fails the engagement regardless of technical quality).
- **2.** Parser DoS (T10); caught pre-prod with RFC 4475 torture + fuzzing in CI/regression, and
  `sanity_check` dropping malformed input.
- **3.** Behavioural = pike (volume/threshold; evasion: low-and-slow); signature = UA ban (one
  packet; evasion: rotate UA). Layered: UA ban + pike + nftables rate-limit + fail2ban.
- **4.** Detect via CDR analytics (spend-cap breach + high-cost prefix burst); contain by
  auto-suspending the account + blocking the prefix before loss exceeds cap; eradicate by rotating
  creds + tightening outbound allowlist.
- **5.** Prevent (allowlist + strong auth), **cap** (bounds loss), detect + auto-suspend. The cap
  is the backstop because prevention and detection can both be late/bypassed.
- **6.** e.g. SIP failure ratio (T2/T10), registration rate (T3), INVITE rate (T8), ban-spike
  (T1), spend (T4), cert expiry (T6), recording access (T14).
- **7.** Otherwise an attack that succeeded once recurs unseen; coverage gap = incomplete defense.
- **8.** Detect (InviteFlood) → triage (scope/ongoing) → contain (pike/nftables/fail2ban) →
  eradicate (tune thresholds, jail sources) → recover (latency to baseline) → post-incident
  (update thresholds + signature).
- **9.** Hash the evidence; redact the media plane (RTP/RTCP carry audio+DTMF PIN/PAN), keep
  signaling; sign a custody record; store encrypted with RBAC; keep signaling, drop media.
- **10.** Scrape earliest-cert-expiry (ssl/blackbox exporter), alert `< 30d`; expiry causes outage
  (availability) and forces insecure fallback (security).
- **11.** Shell/YAML lint, compose config, offline graders (fraud/rules), image/config scan; all
  run without the live topology. Live flood/ban graders need the running lab.
- **12.** NodePort (limited port range), hostNetwork (full host stack, high blast radius),
  Multus (dedicated media NIC per pod, best isolation). Enforce Pod Security Standards (restricted).
- **13.** Capacity = max successful calls/sec sustained; failure mode = what breaks first past it
  (retransmits/5xx/timeouts); find the knee by ramping rate until success drops.
- **14.** SBC message manipulation (Kamailio `textops`/`sdpops`, Asterisk PJSIP header rules) to
  add/remove/rewrite the offending header/SDP; capture before/after.
- **15.** Drift = running config diverging from source of truth; IaC + CI (config lint on every
  change) catches it before deploy.
- **16.** `0.0.1.0.5.5.5.5.1.4.1.e164.arpa` NAPTR; private ENUM keeps the number→URI map off the
  public tree (no external enumeration/redirection).
- **17.** A poisoned/forged DNS answer redirects `_sips._tcp` SRV to an attacker; defenses:
  **DNSSEC** (authenticate records) and **TLS cert verification** (redirect fails the handshake).
- **18.** T.38 re-INVITE blocked or the gateway not re-negotiating; causes: SBC not passing/relaying
  the T.38 re-INVITE, or a mismatch — fix by allowing/handling the T.38 re-INVITE at the SBC.
- **19.** API key/JWT auth (stops unauthenticated origination), rate limit (stops flooding), spend
  cap (stops toll-fraud runaway).
- **20.** A v4-only firewall rule that IPv6 bypasses; mitigate with parity `ip6` nftables rules and
  policy parity across both stacks (M8/BF9).

## Grading
| Part | Pts | Notes |
|------|-----|-------|
| A offensive/defensive | 25 | partial credit |
| B monitoring & IR | 25 | **gate: ≥13 required** |
| C testing/automation/cloud | 25 | |
| D frontiers | 25 | Q16 must be correct |
| **Pass** | **≥70** | and Security/IR ≥ 50% |
