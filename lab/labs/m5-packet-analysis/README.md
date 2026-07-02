# Lab M5 — Packet Analysis & Troubleshooting

**Module:** [M5](../../../course/modules/05-packet-analysis-troubleshooting.md) · **Est.** 4h ·
**Prereqs:** M2–M4. **Checkpoint Exam #1 follows this module.**

Goal: master the OSS analysis toolchain (Wireshark, sngrep, HOMER), a repeatable fault-isolation
method, an automation one-liner, and safe evidence handling.

## Auto-graded prerequisites
```bash
bash labs/m5-packet-analysis/verify.sh      # services + REGISTER + HOMER availability
```

## Lab 5.1 — Diagnose fault captures  (30 pts)
Diagnose a set of fault scenarios (one-way audio, no ringback, 488 codec mismatch, registration
loop, NAT'd media, TLS setup failure). For each: one-paragraph **root cause + fix**. Generate
your own faults by mis-editing a service config and re-capturing, or analyze instructor pcaps.

**Deliverable:** root cause + fix per fault, each tied to the plane and first anomaly.

## Lab 5.2 — HOMER multi-hop correlation  (25 pts)
```bash
make obs-up                                  # HOMER/heplify + Grafana
```
Correlate a call across hops (client → SBC → PBX) in HOMER; show the single call ID stitched
from multiple capture points.

**Deliverable:** HOMER correlation view of one call across ≥2 hops.

## Lab 5.3 — Automation one-liner  (20 pts)
Write a `tshark` one-liner that lists every call with a 4xx/5xx final response. Reference
solution:
```bash
bash labs/m5-packet-analysis/list-bad-calls.sh <capture.pcap>
```
**Deliverable:** your one-liner + sample output.

## Lab 5.4 (security) — Evidence handling  (25 pts)
Captures are investigative gold *and* a PII/PCI liability. Redact the media plane (audio +
DTMF) and produce tamper-evident hashes + custody:
```bash
bash labs/m5-packet-analysis/redact-and-hash.sh evidence.pcap
```
**Deliverable:** redacted pcap + `.sha256` for original and redacted + custody record; explain
why signaling is kept and media dropped.

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` prerequisites | — | required |
| 5.1 fault root causes + fixes | 30 | rubric |
| 5.2 HOMER correlation | 25 | screenshot |
| 5.3 tshark automation | 20 | script + output |
| 5.4 evidence redaction + hashing | 25 | artifacts |

## → Checkpoint Exam #1
After this lab, take [`../../../course/assessments/checkpoint-exam-1.md`](../../../course/assessments/checkpoint-exam-1.md)
(covers M0–M5: protocol + analysis + the security threads introduced so far).
