# Authorized Assessment — Findings Report (Lab 13.1/13.2)

**Engagement:** VoIPSec lab · **Tester:** <name> · **Date:** <date> · **Scope:** `edge`/`redteam`
lab subnets ONLY (written authorization: this is a training lab). No third-party targets.

## Methodology
Recon → enumeration → exploitation attempts → impact → remediation → detection. Tools:
`lab-scan` (svmap), `lab-enum` (svwar), `lab-crack` (svcrack), `torture.sh` (RFC 4475), SIPp.
All from the scope-guarded `redteam` container.

## Findings
For each finding, fill one block. Severity: Critical / High / Medium / Low (justify).

### F-01 — <title>
- **Severity:** <…>  ·  **Threat ID:** <T#>
- **Description:** <what/where>
- **Evidence:** <pcap/log file> (attach; redact PII per M5)
- **Reproduction:** <exact commands/steps>
- **Impact:** <what an attacker gains>
- **Remediation:** <concrete fix + module reference, e.g. "enable pike (M7), fail2ban (M16)">
- **Detection signature (Lab 13.2 → M17):** <log pattern / metric / Wazuh rule that catches it>

### F-02 — <title>
- (repeat)

## Summary table
| ID | Title | Severity | Threat | Remediation | Detection |
|----|-------|----------|--------|-------------|-----------|
| F-01 | | | | | |

## Authorized-use attestation
I confirm all testing was performed only against the VoIPSec lab, which I am authorized to test.
No production or third-party systems were targeted.  Signed: <name> / <date>
