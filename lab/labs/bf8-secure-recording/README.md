# Lab BF8 — Secure Call Recording (PCI-DSS aware)

**Modules:** [M14](../../../course/modules/14-defense-hardening-fraud.md) +
[M15](../../../course/modules/15-monitoring-observability-ir.md). Feedback-derived
(gemini_feedback0). Threats: recording/CDR exposure (T14), PCI/PII liability.

Goal: record lawfully without creating a breach. **Suppress** sensitive DTMF during payment,
**encrypt** at rest, gate access with **RBAC + audit**, and detect misuse.

## Auto-graded core
```bash
bash labs/bf8-secure-recording/verify.sh
bash labs/bf8-secure-recording/secure-recording.sh demo
```
Deterministic: AES encrypt/decrypt round-trip, RBAC allow/deny with an audit trail, and DTMF/PAN
masking (last-4 only, PIN fully masked).

## Build
1. **DTMF suppression (the key PCI control):** pause recording during the payment IVR so the card
   number / PIN is never written to disk.
   - Asterisk: `MixMonitor` with pause/resume (or `PauseMonitor`/`UnpauseMonitor`, or a "secure
     agent" mute) triggered around the DTMF collection.
   - FreeSWITCH: stop/mask the recording during the secure segment.
2. **Encryption at rest:** encrypt recordings (`secure-recording.sh encrypt <in> <out> <key>`);
   keys in a KMS/secure store, not beside the media.
3. **RBAC + audit:** only allowlisted roles may access; every access is logged
   (`secure-recording.sh access <user> <file>`). Ship the audit log to the SIEM (M15).
4. **Detection:** Wazuh rule on recording-directory access / bulk export (M15
   `RecordingAccessAnomaly`).

## Security / compliance notes
- PCI-DSS: never store sensitive authentication data (CVV/PIN); protect PAN. Suppression beats
  redaction — data never captured can't leak.
- Retention limits + secure deletion; encryption keys rotated and access-controlled.
- Recordings are consent/lawful-intercept sensitive — handle per jurisdiction.

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` controls PASS | — | required |
| DTMF suppression during payment (nothing on disk) | 35 | capture/config |
| encryption at rest + key handling | 25 | demo + config |
| RBAC + audit trail (+ SIEM) | 25 | access log |
| detection rule on recording access | 15 | Wazuh alert |
