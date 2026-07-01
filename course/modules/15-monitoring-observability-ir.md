# Module 15 — Monitoring, Observability & Incident Response

**One-liner:** See everything, detect abuse in real time, and respond with runbooks.
**Est. time:** 5h · **Prereqs:** Modules 5, 13, 14.

## Learning Objectives
- Build a VoIP observability stack (metrics, logs, SIP capture) and meaningful dashboards/alerts.
- Detect the Module 13 attack signatures automatically.
- Execute incident-response runbooks for the top VoIP incidents.

## 1. Concept
- **Three pillars for VoIP:** metrics (Prometheus + exporters), logs (Loki/promtail, syslog),
  and full SIP capture/correlation (HOMER/HEP) — plus CDRs for fraud.
- **KPIs & SLOs:** registration success rate, ASR (answer-seizure ratio), ACD, PDD (post-dial
  delay), 4xx/5xx rates, concurrent calls, MOS/jitter/loss trends, trunk utilization.
- **Alerting:** thresholds vs. anomaly; alert on auth-failure spikes, scan patterns, flood, MOS
  drop, cert expiry, fraud indicators; Alertmanager routing; avoiding alert fatigue.
- **Detection engineering:** turn each M13 signature into a rule (Wazuh/Loki/HOMER queries):
  svmap sweeps, svwar enumeration, floods, spoofed/failed STIR verification, off-hours toll spikes.
- **Incident response for VoIP:** detect → triage → contain (suspend account, block source,
  reroute) → eradicate → recover → post-incident review; evidence handling from M5.
- **Forensics:** using HOMER captures + CDRs + logs to reconstruct an incident timeline.

## 2. Packet Reality
- Correlate a single fraudulent call across HOMER (signaling), CDR (billing), and logs (auth)
  to build an incident timeline.

## 3. Build (OSS)
- Prometheus + node/Asterisk/Kamailio exporters; Grafana dashboards for the KPIs above.
- Loki/promtail for structured SIP + auth logs; HOMER already capturing (M5).
- Wazuh rules + Alertmanager routes for the M13 signatures; test each alert fires.
- A CDR analytics job feeding fraud alerts (from M14) into the same alerting pipeline.

## 4. Attack / Defend
- Run the M13 assessment again "blind"; prove the SOC view detects each phase in real time.
- Tune out false positives; document detection coverage vs. the threat catalog (gap analysis).

## 5. Labs / Deliverable
- **Lab 15.1:** Build the KPI dashboard + alerts; screenshot healthy vs. under-attack states.
- **Lab 15.2:** Detection rules for all M13 signatures; show each firing during a replay.
- **Lab 15.3 (IR):** Author and execute an incident runbook for (a) toll fraud, (b) INVITE flood,
  (c) suspected eavesdropping; produce an incident report with a timeline.
- *Rubric:* actionable dashboards; complete detection coverage; runbooks executed with evidence.

## Assessment (sample)
- Which three KPIs best reveal an in-progress toll-fraud event, and why?
- Design an alert that catches svwar without firing on a busy call center.
- Outline the containment step for a compromised extension and its trade-offs.

## Curriculum addition — Recording access audit & compliance monitoring (review: gemini_feedback0)

The monitoring plane is where recording/CDR compliance is proven and where misuse is caught.
- **Build:** ship recording- and CDR-access events to the SIEM (Wazuh); alert on unauthorized
  or out-of-hours access to recordings, bulk exports, or retention-policy violations.
- **Attack/Defend:** insider access to recordings/CDRs (threat T14); maintain a tamper-evident
  audit trail and detection rules for anomalous access.
- **PCI/lawful-intercept:** log every access with actor + reason; verify DTMF-suppressed
  segments (built in M14) actually contain no card data before archival.
- **Lab hook (adds B15+):** add a Wazuh rule that fires on access to the recordings directory;
  trigger it and walk the alert → IR runbook path.

## References
- Prometheus/Grafana/Loki/Alertmanager docs; HOMER 7; Wazuh ruleset docs; NIST SP 800-61
  (incident handling); `../notes.md §2` threat catalog for detection mapping.
