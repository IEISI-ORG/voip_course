---
marp: true
theme: default
paginate: true
title: Module 17 — Monitoring, Observability & Incident Response
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Module 17 — Monitoring, Observability & Incident Response

**See everything, detect abuse in real time, and respond with runbooks.**

`Est. 5h` · Prereqs: Modules 5, 13, 15

<!--
Speaker: Prevention (M16) always leaks something — this module is how you *see* it and *respond*.
The through-line: every attack from M15 becomes a detection rule here, and every detection needs a
runbook. "Assume breach" made operational. Dashboards are nice; detection + response is the point.
-->

---

## What you'll leave with

- Build a **VoIP observability stack** (metrics, logs, SIP capture) with meaningful dashboards/alerts.
- **Detect the M15 attack signatures** automatically.
- Execute **incident-response runbooks** for the top VoIP incidents.

<!--
Speaker: Exam angles: three KPIs that reveal in-progress toll fraud, and designing an alert that
catches svwar without firing on a busy call center. Keep "detection coverage vs. the threat catalog"
as the success metric — can you catch every T#?
-->

---

## Three pillars for VoIP

- **Metrics:** Prometheus + exporters.
- **Logs:** Loki/promtail, syslog.
- **SIP capture/correlation:** HOMER/HEP (from M5) — the flight recorder.
- Plus **CDRs** for toll-fraud detection (T4).

<!--
Speaker: The three pillars plus CDRs cover the whole picture: metrics tell you *something's wrong*,
logs tell you *what*, HOMER lets you *reconstruct the call across hops*, and CDRs catch the fraud
money-trail. HOMER's cross-hop correlation (M5) is what makes multi-hop incidents solvable.
-->

---

## KPIs & SLOs

- **Registration success rate**, ASR (answer-seizure ratio), ACD.
- **PDD** (post-dial delay), 4xx/5xx rates, concurrent calls.
- **MOS / jitter / loss** trends, trunk utilization.

<!--
Speaker: These are the vital signs. For security specifically: a spike in 4xx/auth failures = scan or
brute force; an off-hours concurrent-call + international spike = toll fraud in progress; an MOS
cliff = impairment or attack. Tie each KPI to the attack it reveals — that's the security lens on
ops metrics.
-->

---

## Alerting & detection engineering

- Thresholds vs. anomaly; alert on **auth-failure spikes, scan patterns, floods, MOS drop, cert
  expiry, fraud indicators**.
- **Turn each M15 signature into a rule** (Wazuh/Loki/HOMER queries): svmap sweeps, svwar
  enumeration, floods, failed STIR verification, off-hours toll spikes.
- Alertmanager routing; **avoid alert fatigue**.

<!--
Speaker: This is the heart of the module — detection engineering. In M15 they captured the signature
of each attack they ran; here those become firing rules. Alert fatigue is the silent killer: a
dashboard nobody watches and 500 alerts nobody reads is worse than nothing. Tune ruthlessly.
-->

---

## Signature diversity: honeypot + Suricata

- **Honeypot** (behavioural): decoy 5060 hit → auto-ban (from M16).
- **Suricata (BF15)** (signature IDS): watches the edge span for scanner UAs, OPTIONS/REGISTER/
  INVITE floods, toll-fraud dial patterns.
- Both feed the **same** `nftables`-ipset blocklist + Wazuh correlation — diverse detection, **one
  response path**.

<!--
Speaker: Two different detection philosophies — behavioural (honeypot: anyone who touches it is bad)
and signature (Suricata: match known-bad patterns) — converging on one response (the nftables ipset).
Diverse sensors, single actuator. That's the M15→detect→M17 arc closing: attack, capture, detect,
auto-respond.
-->

---

## Incident response for VoIP

- **Detect → triage → contain → eradicate → recover → post-incident review.**
- Contain = suspend account, block source, reroute.
- **Forensics:** HOMER captures + CDRs + logs → reconstruct the incident **timeline**.
- Evidence handling from **M5** (hash, chain of custody).

<!--
Speaker: A runbook turns panic into procedure. Containment for VoIP is concrete: suspend the
compromised extension, block the source IP, reroute if needed — then eradicate and recover. Forensics
reuses the M5 evidence discipline: your hashed pcaps and correlated HOMER data reconstruct exactly
what happened, defensibly.
-->

---

## Recording access audit & compliance

- Ship **recording- and CDR-access events** to the SIEM (Wazuh).
- Alert on **unauthorized / out-of-hours access, bulk exports, retention-policy violations**.
- **PCI / lawful intercept:** log every access with actor + reason; verify DTMF-suppressed segments
  (built in M16) actually contain no card data before archival.

<!--
Speaker: The monitoring plane is where recording compliance is *proven*. Insider access to recordings
(T14) is a real threat — a tamper-evident audit trail plus alerts on anomalous access is the control.
This is also where you verify M16's DTMF masking actually worked: no PAN in the archive, every access
logged.
-->

---

## Build (OSS)

- **Prometheus** + node/Asterisk/Kamailio exporters; **Grafana** dashboards for the KPIs.
- **Loki/promtail** for structured SIP + auth logs; **HOMER** capturing (M5).
- **Wazuh** rules + Alertmanager routes for the M15 signatures; **test each alert fires**.
- CDR analytics job feeding fraud alerts (from M16) into the same pipeline.

<!--
Speaker: "Test each alert fires" is the discipline that separates real detection from decoration — an
untested alert is an assumption. Have them trigger each rule deliberately (replay the M15 attack) and
confirm it lights up. One pipeline for metrics, logs, capture, and fraud keeps the SOC view coherent.
-->

---

## Labs / Deliverable

- **Lab 17.1** — KPI dashboard + alerts; screenshot healthy vs. under-attack states.
- **Lab 17.2** — **Detection rules for all M15 signatures**; show each firing during a replay.
- **Lab 17.3 (IR)** — Author + execute an **incident runbook** for (a) toll fraud, (b) INVITE flood,
  (c) suspected eavesdropping; produce a report with a **timeline**.

*Rubric:* actionable dashboards · complete detection coverage · runbooks executed with evidence.

<!--
Speaker: 17.2 is the coverage proof — every M15 attack has a firing rule (a detection-coverage map vs.
the threat catalog). 17.3 makes IR muscle memory: they don't just write a runbook, they execute it
under a simulated incident and produce the timeline report. That report is capstone-grade evidence.
-->

---

## Takeaways & quick check

- **Three pillars + CDRs** — metrics say *something's wrong*, capture says *what happened*.
- **Every M15 attack → a firing detection rule**; diverse sensors, one response path.
- **A runbook turns panic into procedure** — and forensics needs M5 evidence discipline.

**Check:** Three KPIs that best reveal in-progress toll fraud, and why? Design an alert that catches
svwar without firing on a busy call center. Containment steps for a compromised extension?

<!--
Speaker: Answers — international/premium call volume, concurrent calls, and off-hours ASR/spend spikes
reveal toll fraud (money + minutes + timing). An svwar alert keys on a burst of 401/404 across *many
distinct extensions from one source* (enumeration shape), not raw call volume, so a busy call center
(legit calls to real users) doesn't trip it. Containment: suspend the extension, block the source,
reroute/limit, preserve evidence, then eradicate/recover. Next: Testing, Interop, Automation & Cloud
(M18).
-->
