# Lab BF12 — SIP Honeypot → Dynamic Blocklist

**Modules:** [M14](../../../course/modules/14-defense-hardening-fraud.md) +
[M15](../../../course/modules/15-monitoring-observability-ir.md). Feedback-derived
(gemini_feedback1). Threats: scanning (T1), flood (T8).

Goal: a decoy SIP listener that no legitimate client touches, turning every hit into a
platform-wide ban — noise-free detection with an automated response.

## Auto-graded core
```bash
bash labs/bf12-honeypot/verify.sh
bash labs/bf12-honeypot/hp2ipset.sh labs/bf12-honeypot/sample-honeypot.log
```
Self-validating: the pipeline extracts + dedupes scanner IPs into `nft add element` commands and
raises **no** bans from a clean log.

## Build
1. **Decoy listener** — run a dummy SIP responder on UDP 5060 while the real service is SIPS on
   5061 (M14). Log every hit as `HONEYPOT hit src=<ip> ua=<ua> method=<m>`.
2. **Blocklist** — load [`nftables-honeypot.nft`](nftables-honeypot.nft) (a timeout'd `banned_v4`
   set + a drop rule). Feed it from the honeypot log:
   ```bash
   bash hp2ipset.sh honeypot.log --apply    # add offenders (with expiry) to the set
   ```
3. **Aggregate + active response** — [`wazuh-honeypot.xml`](wazuh-honeypot.xml): a decoder + rule
   (any honeypot hit = scanner) + an active-response that bans the source across edge nodes.

## Security notes
- Every honeypot hit is malicious **by definition** — no false positives, no thresholds.
- **Caution:** a spoofed source could try to get a legitimate IP banned. Rate-limit the response,
  allowlist known-good, and prefer connection-verified signals for high-impact bans.
- Bans carry a **timeout** so the blocklist self-cleans.

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` pipeline PASS | — | required |
| decoy listener logging hits | 25 | capture/log |
| log → nftables ipset ban (with timeout) | 35 | scan → ban |
| Wazuh rule + active-response fires | 25 | alert + propagation |
| spoof-poisoning mitigated | 15 | design/config |
