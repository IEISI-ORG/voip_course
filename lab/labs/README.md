# VoIPSec Labs (Stage B)

Per-module hands-on labs. Each turns a module's design into a runnable, graded exercise
against the shared lab, with an executable checker where possible (`verify.sh`).

| Lab | Module | Focus | Status |
|-----|--------|-------|--------|
| [m0-orientation](m0-orientation/) | M0 | bring-up, health, segmentation, clean reset | ✅ |
| [m1-foundations](m1-foundations/) | M1 | two-plane call, recon, living threat model | ✅ |
| [m2-core-sip](m2-core-sip/) | M2 | transactions/dialogs, MF loop protection, topology hiding | ✅ |
| [m3-sdp-media](m3-sdp-media/) | M3 | SDP offer/answer, c= redirection vs media anchoring | ✅ |
| [m4-rtp-qos](m4-rtp-qos/) | M4 | RTP stats/MOS, bandwidth budget, eavesdrop→SRTP, DSCP | ✅ |
| [m5-packet-analysis](m5-packet-analysis/) | M5 | fault diagnosis, tshark automation, evidence redaction; exam #1 | ✅ |
| [m6-building-core](m6-building-core/) | M6 | secure-default PBXs (audited live), hardening checklist v1 | ✅ |
| [m7-proxies-sbc](m7-proxies-sbc/) | M7 | failover, topology hiding, media anchoring, pike rate-limit (self-validating) | ✅ |
| [m8-nat-firewall](m8-nat-firewall/) | M8 | NAT traversal, TURN, nftables edge, scanner-UA ban (self-validating) | ✅ |
| [m9-trunking-pstn](m9-trunking-pstn/) | M9 | two-way trunk, SIP↔Q.850 mapping, trunk TLS/auth + fraud guardrails | ✅ |
| [m11-signaling-tls](m11-signaling-tls/) | M11 | SIP-over-TLS (handshake-tested), cert inspection, mTLS + expiry alert | ✅ |
| [m12-media-srtp](m12-media-srtp/) | M12 | SRTP foundation, SDES offer + crypto-strip demo, DTLS/ZRTP | ✅ |
| [m13-authn-identity](m13-authn-identity/) | M13 | digest/STIR-SHAKEN, PASSporT decoder, enumeration ban; exam #2 | ✅ |
| [m14-offensive](m14-offensive/) | M14 | authorized assessment, RFC 4475 torture (survival-tested), findings report | ✅ |
| [m15-defense-fraud](m15-defense-fraud/) | M15 | hardening v-final, CDR IRSF fraud detector (offline-graded) | ✅ |
| [m16-monitoring-ir](m16-monitoring-ir/) | M16 | Prometheus alert rules, M14 detection coverage, IR runbooks | ✅ |
| [m17-testing-cloud](m17-testing-cloud/) | M17 | SIPp load test, CI pipeline (repo lint + graders), IaC | ✅ |
| [m18-frontiers](m18-frontiers/) | M18 | ENUM lookup tool, T.38 fax, CPaaS API hardening; exam #3 | ✅ |

**Stage B complete — all 18 module labs (M0–M18) built.**

Conventions:
- Each lab dir has a `README.md` runbook with a **100-pt rubric (pass ≥ 70)**.
- `verify.sh` (when present) is the auto-graded core — exit 0 required to pass its items.
- Helper scripts assume you run them from `lab/` and use `docker compose` (override `COMPOSE=`).
