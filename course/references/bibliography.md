# VoIPSec Bibliography — Authoritative References

Living reference set for the course: RFCs and standards, regulatory sources, and the official
knowledge base for every package in the lab. Cited across the module docs; extend as content
grows.

> URLs compiled from canonical/official sources; spot-check for drift before publishing a cohort
> (docs move). RFCs: `https://www.rfc-editor.org/rfc/rfcNNNN`.

## 1. Core SIP & session control (RFC)
- **RFC 3261** — SIP: Session Initiation Protocol (core)
- **RFC 3262** — Reliability of provisional responses (PRACK / 100rel)
- **RFC 3263** — Locating SIP servers (NAPTR → SRV → A/AAAA)
- **RFC 3264** — Offer/Answer model with SDP
- **RFC 3311** — UPDATE method
- **RFC 3323** — Privacy mechanism
- **RFC 3325** — P-Asserted-Identity (PAI)
- **RFC 3515** — REFER method
- **RFC 3891** — Replaces header
- **RFC 6140** — Bulk registration (trunking)
- **RFC 4028** — Session timers
- **RFC 6665** — SIP event notification (SUBSCRIBE/NOTIFY); **RFC 3856** — presence event package

## 2. Media: SDP, RTP, codecs (RFC)
- **RFC 4566** — SDP
- **RFC 3550 / 3551** — RTP / RTP audio-video profile
- **RFC 5761** — Multiplexing RTP and RTCP
- **RFC 2833 / 4733** — DTMF / telephone-events in RTP
- **RFC 6716** — Opus codec

## 3. Signaling & media security (RFC)
- **RFC 8446** — TLS 1.3; **RFC 5246** — TLS 1.2
- **RFC 7118** — SIP over WebSocket (WS/WSS)
- **RFC 3711** — SRTP; **RFC 4568** — SDES key exchange
- **RFC 5763 / 5764** — DTLS-SRTP framework / DTLS extension
- **RFC 6189** — ZRTP
- **RFC 8826 / 8827 / 8834** — WebRTC security / architecture / RTP usage
- **RFC 8445** — ICE; **RFC 5389 / 8489** — STUN; **RFC 5766 / 8656** — TURN
- **RFC 4787** — NAT behavioural requirements (UDP); **RFC 3581** — `rport`; **RFC 1918** —
  private address space; **RFC 5853** — SBC use in SIP
- **RFC 7616** — HTTP Digest (SHA-256, obsoletes **RFC 2617**); **RFC 8760** — SIP digest
  additional algorithms (updates RFC 3261 auth)

## 4. Caller identity / STIR/SHAKEN (RFC + ATIS)
- **RFC 8224** — Authenticated Identity Management (Identity header)
- **RFC 8225** — PASSporT
- **RFC 8226** — Secure Telephone Identity Credentials (certs, TNAuthList)
- **RFC 8588** — SHAKEN PASSporT extension (`attest` / `origid`)
- **RFC 8946** — PASSporT extension for diverted calls (`div`)
- **RFC 9795** — PASSporT extension for Rich Call Data (RCD); **RFC 9796** — SIP Call-Info
  parameters for RCD
- **RFC 8816** — Out-of-Band STIR/SHAKEN
- **RFC 9060** — Delegate certificates
- **ATIS-1000074 / 1000080** — SHAKEN framework & governance

## 5. DNS, ENUM, resilience (RFC + NIST)
- **RFC 2782** — DNS SRV; **RFC 3401–3404** — NAPTR / DDDS
- **RFC 6116** — ENUM (E.164 → URI)
- **RFC 4033–4035** — DNSSEC; **RFC 7858** — DoT; **RFC 8484** — DoH
- **NIST SP 800-81** — Secure DNS Deployment Guide

## 6. PSTN interworking, fax, emergency (RFC/ITU + regulation)
- **RFC 3398** — ISUP ↔ SIP mapping (SIP status ↔ Q.850 cause)
- **RFC 6913** — indicating Fax-over-IP capability in SIP; **RFC 3312** — preconditions
- **ITU-T Q.850** — Cause values; **ITU-T T.38 / T.30** — real-time fax / fax
- **RFC 4412** — Resource-Priority header
- **RFC 4119 / 5491 / 4776** — PIDF-LO location object / geo shapes / civic
- **Kari's Law**, **RAY BAUM'S Act**, **NENA i3 / NG911** — emergency calling

## 7. Robustness / testing (RFC)
- **RFC 4475** — SIP torture test messages; **RFC 5118** — SIP-over-IPv6 torture

## 8. Mobile / IMS / VoLTE
- **3GPP TS 23.228** — IMS architecture; **TS 24.229** — SIP/SDP for IMS
- **GSMA IR.92** — VoLTE profile; **GSMA IR.94** — video (ViLTE)

## 9. Security frameworks & compliance
- **NIST SP 800-58** — Security for VoIP systems
- **NIST SP 800-52r2** — TLS deployment guidance
- **ENISA** — VoIP/telephony security guidance
- **PCI-DSS** — cardholder data (call-recording DTMF suppression, at-rest encryption)
- **OWASP** — general web/API hardening (provisioning, dashboards)

## 10. Package knowledge bases (official)
| Package | Role | Docs / KB |
|---------|------|-----------|
| Asterisk | PBX | https://docs.asterisk.org |
| FreeSWITCH | PBX | https://developer.signalwire.com/freeswitch · https://freeswitch.org |
| Kamailio | proxy/SBC | https://www.kamailio.org/docs/ · https://www.kamailio.org/wiki/ |
| OpenSIPS | proxy/SBC | https://opensips.org/Documentation/ |
| rtpengine | media relay | https://github.com/sipwise/rtpengine |
| SIPp | load/test | https://sipp.readthedocs.io |
| SIPVicious OSS | recon (authorized) | https://github.com/EnableSecurity/sipvicious |
| HOMER / heplify | capture/correlation | https://sipcapture.org · https://github.com/sipcapture |
| Wireshark / tshark | analysis | https://www.wireshark.org/docs/ |
| sngrep | live SIP viewer | https://github.com/irontec/sngrep |
| coturn | STUN/TURN | https://github.com/coturn/coturn |
| fail2ban | banning | https://www.fail2ban.org |
| nftables | firewall | https://wiki.nftables.org |
| Prometheus | metrics | https://prometheus.io/docs/ |
| Grafana / Loki | dashboards / logs | https://grafana.com/docs/ |
| Wazuh | SIEM | https://documentation.wazuh.com |
| BIND 9 | DNS | https://bind9.readthedocs.io |
| spandsp | fax (T.38) | https://www.soft-switch.org |
| OpenSSL | TLS/crypto | https://docs.openssl.org |
| step-ca | private CA | https://smallstep.com/docs/step-ca/ |
| libsrtp | SRTP | https://github.com/cisco/libsrtp |
| libstirshaken | STIR/SHAKEN | https://github.com/signalwire/libstirshaken |
| Baresip / Linphone | softphones | https://github.com/baresip/baresip · https://www.linphone.org |
| Docker / Compose | orchestration | https://docs.docker.com |

## 11. Academic surveys & literature (peer-reviewed)
| Work | Relevance | Key finding used |
|------|-----------|------------------|
| VoIP Security Alliance (VOIPSA), *VoIP Security and Privacy Threat Taxonomy*, Public Release 1.0, 24 Oct 2005. https://www.voipsa.org | M13 threats; the course threat catalog | The canonical VoIP threat classification — six top-level categories: **Social Threats, Eavesdropping, Interception & Modification, Service Abuse, Intentional Interruption of Service (DoS/DDoS), Physical Intrusion**. The course's T1–T15 catalog maps onto these; the Keromytis survey classifies the literature by an extended version of it. |
| A. D. Keromytis, "A Comprehensive Survey of Voice over IP Security Research," *IEEE Communications Surveys & Tutorials*, vol. 14, no. 2, pp. 514–537, 2012. | M13 threats; whole-course thesis | Classifies 245 papers by the VoIPSA threat taxonomy; finds **DoS and service abuse** the most under-addressed areas, and that most research takes a *black-box* view that misses **implementation bugs and misconfigurations** — the primary vulnerability source. |
| R. Dantu, S. Fahmy, H. Schulzrinne, J. Cangussu, "Issues and Challenges in Securing VoIP," *Computers & Security* (Elsevier), 2009. DOI 10.1016/j.cose.2009.05.003. | M1 architecture; M13 threats | Peer-reviewed (co-authored by H. Schulzrinne, an author of RFC 3261/SIP). Proposes a high-level security architecture that captures the required features **at each boundary network element** of the VoIP infrastructure — the framing this course's edge/core/SBC layering follows. |
| A. Mohd Ramly, Z. W. Ng, Y. Khamayseh, C. S. C. Kwan, A. Amphawan, T.-K. Neo, "Review and Enhancement of VoIP Security: Identifying Vulnerabilities and Proposing Integrated Solutions," *Journal of Telecommunications and the Digital Economy*, vol. 12, no. 4, 2024. DOI 10.18080/jtde.v12n4.1022. | M13 threats | Recent peer-reviewed review of VoIP vulnerabilities (eavesdropping, registration/call hijacking, SPIT, vishing, malware) and layered/integrated mitigations. |
| S. S. Kolahi, K. Mudaliar, C. Zhang, Z. Gu, "Impact of IPSec Security on VoIP in Different Environments," *9th Int'l Conf. on Ubiquitous and Future Networks (IEEE ICUFN)*, pp. 979–982, 2017. DOI 10.1109/ICUFN.2017.7993945. | M9 trunk security; security-vs-performance | Peer-reviewed IEEE conference paper. Test-bed comparison (IPv4/IPv6/6in4, ±IPsec): IPsec raised **CPU usage** and added **delay**; throughput ~unchanged; RTT/jitter results **inconsistent**. Used carefully (single test-bed): encryption overhead is real and must be capacity-budgeted. |

## Glossary
Abbreviations and acronyms are defined in [`glossary.md`](glossary.md).

## 12. Citation convention
In module docs, cite as `RFC NNNN` (SIP/media/security), standards body + doc id
(e.g. `ATIS-1000074`, `NIST SP 800-58`, `GSMA IR.92`), or the package KB by name. Keep this file
the single source of truth for the canonical reference list.
