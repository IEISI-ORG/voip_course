# SOVOC Labs (Stage B)

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
| [m10-signaling-tls](m10-signaling-tls/) | M10 | SIP-over-TLS (handshake-tested), cert inspection, mTLS + expiry alert | ✅ |
| [m11-media-srtp](m11-media-srtp/) | M11 | SRTP foundation, SDES offer + crypto-strip demo, DTLS/ZRTP | ✅ |
| [m12-authn-identity](m12-authn-identity/) | M12 | digest/STIR-SHAKEN, PASSporT decoder, enumeration ban; exam #2 | ✅ |
| [m13-offensive](m13-offensive/) | M13 | authorized assessment, RFC 4475 torture (survival-tested), findings report | ✅ |
| [m14-defense-fraud](m14-defense-fraud/) | M14 | hardening v-final, CDR IRSF fraud detector (offline-graded) | ✅ |
| [m15-monitoring-ir](m15-monitoring-ir/) | M15 | Prometheus alert rules, M13 detection coverage, IR runbooks | ✅ |
| m16-… | M16 | testing / interop / automation / cloud | ⏳ |
| … | … | (built in backlog order B16..B17) | |

Conventions:
- Each lab dir has a `README.md` runbook with a **100-pt rubric (pass ≥ 70)**.
- `verify.sh` (when present) is the auto-graded core — exit 0 required to pass its items.
- Helper scripts assume you run them from `lab/` and use `docker compose` (override `COMPOSE=`).
