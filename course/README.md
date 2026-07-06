# VoIPSec — Secure Open-source VoIP Operations Certificate

A hands-on VoIP/SIP training course built entirely on open-source tools with an emphasis on
**secure VoIP operations**. Modeled on The SIP School's SSCA 'Elite' curriculum, re-architected
around building, attacking, defending, and operating real infrastructure.

> Status: **complete course design/plan**. This is the planning + curriculum layer. The next
> phase (not yet built) is authoring the actual lab repo, slide/scripts, and graded content.

## Read in this order
1. `00-course-overview.md` — master design (positioning, outcomes, pedagogy, module map, assessment).
2. `notes.md` — the engine room: OSS tool map, threat catalog, lab architecture, RFC backbone.
3. `modules/00…19` — per-module deep dives, plus `modules/20-capstone.md`.
4. `task_plan.md` — build plan + decisions (for maintainers of this course).

## Module Index
| # | File | Title |
|---|------|-------|
| 0 | `modules/00-orientation-and-lab.md` | Orientation & Lab Setup |
| 1 | `modules/01-voip-sip-foundations.md` | VoIP & SIP Foundations |
| 2 | `modules/02-core-sip-protocol.md` | Core SIP Protocol Deep Dive |
| 3 | `modules/03-sdp-media-negotiation.md` | SDP & Media Negotiation |
| 4 | `modules/04-rtp-codecs-qos.md` | RTP, RTCP, Codecs & QoS |
| 5 | `modules/05-packet-analysis-troubleshooting.md` | Packet Analysis & Troubleshooting *(exam #1)* |
| 6 | `modules/06-building-the-core.md` | Building the Core: Asterisk & FreeSWITCH |
| 7 | `modules/07-proxies-and-sbcs.md` | SIP Proxies & SBCs (Kamailio/OpenSIPS + rtpengine) |
| 8 | `modules/08-nat-firewalls-sbc.md` | NAT, Firewalls & Session Border Control |
| 9 | `modules/09-sip-trunking-pstn.md` | SIP Trunking & the PSTN |
| 10 | `modules/10-dns-infrastructure.md` | DNS Infrastructure & Resilience for VoIP |
| 11 | `modules/11-signaling-security-tls.md` | Signaling Security: TLS & SIPS |
| 12 | `modules/12-media-security-srtp.md` | Media Security: SRTP/DTLS-SRTP/ZRTP |
| 13 | `modules/13-authn-authz-identity.md` | AuthN, AuthZ & Caller Identity *(exam #2)* |
| 14 | `modules/14-provisioning-security.md` | Provisioning & Device Configuration Security |
| 15 | `modules/15-threats-offensive-testing.md` | VoIP Threats & Offensive Testing (authorized) |
| 16 | `modules/16-defense-hardening-fraud.md` | Defense, Hardening & Fraud Prevention |
| 17 | `modules/17-monitoring-observability-ir.md` | Monitoring, Observability & Incident Response |
| 18 | `modules/18-testing-interop-automation-cloud.md` | Testing, Interop, Automation & Cloud |
| 19 | `modules/19-frontiers.md` | Frontiers: VoLTE/IMS, FoIP, ENUM/Peering, UC/UCaaS/CPaaS *(exam #3)* |
| — | `modules/20-capstone.md` | Capstone + Operations Runbooks |

## Coverage Crosswalk — SIP School SSCA 'Elite' → VoIPSec
Every SSCA 'Elite' module is fully covered; VoIPSec adds build/attack/defend/operate depth.

| SSCA 'Elite' module | Covered in VoIPSec |
|---------------------|------------------|
| 1. Core SIP | M1, M2, M3 |
| 2. Wireshark | M5 (+ used in every module) |
| 3. SIP and the PSTN | M9 |
| 4. SIP, VVoIP and QoS | M4 |
| 5. SIP and Media Security | M11, M12 (+ security spine throughout) |
| 6. STIR/SHAKEN & identity | M13 (+ M19 international/OOB/RCD) |
| 7. Firewalls, NAT and SBCs | M7, M8 |
| 8. SIP Trunking | M9 (+ M18 MPLS/SD-WAN/automation) |
| 9. Testing, Troubleshooting & Interop | M5, M18 |
| 10. ENUM, Peering and Interconnect | M19 |
| 11. SIP in the Cloud | M18 |
| 12. SIP in Cellular networks | M19 |
| 13. SIP and Fax over IP | M19 |
| 14. SIP in UC, UCaaS and CPaaS | M19 |

### VoIPSec additions beyond SSCA 'Elite'
- **M0** reproducible lab (Docker/IaC) — SSCA has no shared build environment.
- **M6/M7** *building* PBX/proxy/SBC from OSS — SSCA describes, VoIPSec constructs.
- **M15** authorized offensive testing — new.
- **M16** defense, hardening & toll-fraud prevention as a full module — new depth.
- **M17** observability + incident response with runbooks — new.
- **M18** automation/IaC/CI + interop at scale — new depth.
- **Capstone** end-to-end secure platform with graded security gates — new.

## Design One-Liner
SSCA 'Elite' teaches you to *speak* SIP. VoIPSec teaches you to *build it, break it, defend it,
and run it* — with open source, security-first.
