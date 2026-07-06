# Incident Runbook & Report Template (Lab 15.3)

Author and **execute** a runbook for each scenario; capture a timeline. One report per incident.

## Runbook skeleton (per scenario)
1. **Detect** — which alert/signature fired (link the M17 rule).
2. **Triage** — severity, scope (accounts/trunks/nodes affected), is it ongoing?
3. **Contain** — the immediate action (ban IP, suspend account, block prefix, disable trunk).
4. **Eradicate** — root cause fix (rotate creds, patch config, close the finding).
5. **Recover** — restore service; verify with the module `verify.sh`.
6. **Post-incident** — update threat model + hardening checklist + detection signature.

---

## Scenario A — Toll fraud / IRSF
- **Detect:** `TollFraudSpend` (spend cap breach) / M16 fraud-detect.
- **Contain:** auto-suspend the account; block the destination prefix at the SBC/dialplan.
- **Eradicate:** rotate the compromised secret; tighten the outbound allowlist (M9).
- **Recover:** re-enable with new creds + lower cap; confirm no residual calls.

## Scenario B — INVITE flood (DoS)
- **Detect:** `InviteFlood` / pike bans.
- **Contain:** confirm pike/nftables rate-limit engaged; add the source range to the nftables
  banned set; scale/anycast if distributed.
- **Eradicate:** tune pike thresholds; fail2ban jail the sources.
- **Recover:** verify call setup latency returns to baseline.

## Scenario C — Suspected eavesdropping
- **Detect:** unexpected SPAN/mirror, `RecordingAccessAnomaly`, or plaintext RTP where SRTP is
  policy.
- **Contain:** enforce SRTP-only (M12); revoke exposed keys/certs; isolate the suspect host.
- **Eradicate:** rotate SRTP/TLS material; audit access; close the exposure.
- **Recover:** confirm media is encrypted end-to-end; review recordings' at-rest encryption (M16).

---

## Incident report (fill per incident)
| Field | Value |
|-------|-------|
| Incident ID / date | |
| Scenario | A / B / C |
| Detected by | (alert/signature) |
| Timeline | HH:MM detect → triage → contain → eradicate → recover |
| Impact | (accounts, $, downtime) |
| Root cause | |
| Actions taken | |
| Follow-ups | (threat-model / checklist / signature updates) |
