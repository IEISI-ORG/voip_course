# SOVOC — Secure Open-source VoIP Operations Certificate

**Course design document (master plan)**

A hands-on training program that teaches SIP and VoIP the way a modern operator must know
it: built end-to-end on open-source software, with security woven through every module.
Modeled on The SIP School's SSCA 'Elite' curriculum, then re-architected around *building*,
*attacking*, *defending*, and *operating* real infrastructure.

---

## 1. Positioning vs. The SIP School SSCA 'Elite'

| Dimension | SSCA 'Elite' | SOVOC |
|-----------|--------------|-------|
| Primary verb | Understand / describe SIP | Build, secure, and operate SIP |
| Tools | Vendor-neutral, mostly Wireshark | Full OSS stack (Asterisk, Kamailio, rtpengine, HOMER, SIPp…) |
| Security | One module (M5) + STIR/SHAKEN (M6) | Structural: threat modeling in every module + 3 dedicated security modules |
| Labs | "Suggested exercises" | Reproducible Docker lab; graded, mandatory |
| Audience emphasis | Includes sales/marketing | Engineers, SREs, security/telecom ops |
| Outcome | Protocol literacy + cert | Deployable, defensible platform + cert |

SOVOC is a **superset**: it covers every SSCA topic (crosswalk in `README.md`) and adds
building, offensive testing, defense/fraud, observability/IR, and automation.

---

## 2. Learning Outcomes

By completion a learner can:
1. Read and reason about SIP/SDP/RTP at the packet level and diagnose faults from a capture.
2. Stand up a complete VoIP platform (PBX, proxy/SBC, media relay, trunk) from source/containers.
3. Encrypt signaling (TLS/SIPS) and media (SRTP/DTLS-SRTP/ZRTP) correctly and verify it.
4. Implement authentication, authorization, and caller identity (digest + STIR/SHAKEN).
5. Threat-model a deployment, run authorized offensive tests, and harden against them.
6. Detect and respond to toll fraud, DoS, and eavesdropping using observability tooling.
7. Automate deployment (IaC/CI) and validate at scale and for interop.
8. Operate the platform: monitoring, alerting, runbooks, and incident response.

---

## 3. Audience & Prerequisites

- **Audience:** VoIP/telecom engineers, network & security engineers, SREs/DevOps, developers
  integrating real-time comms, penetration testers moving into telecom.
- **Prerequisites:** solid TCP/IP and DNS; Linux command line; basic scripting (bash/Python);
  containers helpful. A "Module 0" refresher covers the lab toolchain. No prior SIP required.

---

## 4. Pedagogical Model — the 5-Beat Spine

Every module is structured identically so security is never optional:

1. **Concept** — the protocol/mechanism and *why it exists*.
2. **Packet reality** — see it on the wire (Wireshark/sngrep/HOMER); read real traces.
3. **Build (OSS)** — configure the mechanism in Asterisk/Kamailio/etc.
4. **Attack / Defend** — how it fails or is abused, and the concrete countermeasure.
5. **Lab** — a graded, reproducible exercise in the Docker lab.

Each module ends with: **objectives recap**, **quiz** (10–15 items), **lab rubric**, and
**references** (RFCs, tool docs, NIST/ENISA guidance).

---

## 5. Module Map (18 modules + capstone)

| # | Module | Core OSS | Security spotlight | Est. hours |
|---|--------|----------|--------------------|-----------|
| 0 | Orientation & Lab Setup | Docker, compose, Ansible | Lab isolation, safe red-team net | 2 |
| 1 | VoIP & SIP Foundations | Linphone, Wireshark | Attack surface overview | 3 |
| 2 | Core SIP Protocol Deep Dive | sngrep, Wireshark | Message tampering basics | 5 |
| 3 | SDP & Media Negotiation | Wireshark, Baresip | SDP-based attacks, hold/re-INVITE abuse | 3 |
| 4 | RTP, RTCP, Codecs & QoS | rtpengine, Wireshark | RTP injection, bleed, QoS abuse | 4 |
| 5 | Packet Analysis & Troubleshooting | Wireshark, sngrep, HOMER | Capture handling, evidence integrity | 4 |
| 6 | Building the Core: Asterisk & FreeSWITCH | Asterisk, FreeSWITCH | Secure defaults, secret hygiene | 6 |
| 7 | SIP Proxies & SBCs | Kamailio, OpenSIPS, rtpengine | Topology hiding, routing security | 6 |
| 8 | NAT, Firewalls & Session Border Control | nftables, rtpengine, STUN/TURN/ICE | Edge hardening, flood control | 5 |
| 9 | SIP Trunking & the PSTN | Asterisk, SIPp, spandsp | Trunk auth, spoofed peers, SIP-I | 5 |
| 10 | Signaling Security: TLS & SIPS | OpenSSL, Let's Encrypt, step-ca | MITM, cert mgmt, mTLS trunks | 5 |
| 11 | Media Security: SRTP/DTLS-SRTP/ZRTP | libsrtp, rtpengine, ZRTP clients | Eavesdropping, key exchange pitfalls | 5 |
| 12 | AuthN, AuthZ & Caller Identity | Asterisk, libstirshaken, OpenSIPS | Enumeration, brute force, spoofing | 6 |
| 13 | VoIP Threats & Offensive Testing | SIPVicious, SIPp, custom fuzzers | Authorized red-team methodology | 5 |
| 14 | Defense, Hardening & Fraud Prevention | fail2ball, Wazuh, CDR analytics | Toll fraud, IRSF, DoS mitigation | 6 |
| 15 | Monitoring, Observability & Incident Response | HOMER, Prometheus, Grafana, Loki | Detection, IR runbooks, forensics | 5 |
| 16 | Testing, Interop, Automation & Cloud | SIPp, Docker/K8s, Ansible, Terraform, CI | Secure pipelines, config drift | 5 |
| 17 | Frontiers: VoLTE/IMS, FoIP, ENUM/Peering, UC/UCaaS/CPaaS | Kamailio IMS, spandsp, BIND | IMS/peering trust, RCS/OTT risks | 5 |
| — | Capstone: Secure VoIP Platform | Whole stack | Full build+attack+defend+operate | 10+ |

**Total structured time ≈ 100 hours** (SIP School's "running time" is ~16h; SOVOC is a
deeper, build-and-operate program). Self-paced; labs dominate.

---

## 6. The Lab (shared infrastructure)

A single `docker compose` topology (see `notes.md §3`) provides: an edge SBC (Kamailio +
rtpengine + nftables + fail2ban), two PBXs (Asterisk, FreeSWITCH), a PSTN/trunk simulator
(SIPp/Asterisk), an observability stack (HOMER, Prometheus, Grafana, Loki, Wazuh), and
client/attacker containers on an isolated red-team network. Every module's lab plugs into
this same topology, so learners grow one coherent platform across the course — which becomes
the capstone deliverable.

Design rules:
- **Reproducible:** `git clone && docker compose up` = working platform.
- **Segmented:** untrusted `edge`, trusted `core` (mTLS), `mgmt`, isolated `redteam`.
- **Parity:** Ansible/Terraform variants deploy the same topology to VMs/cloud for the automation module.
- **Ethical fencing:** offensive tools only reach `edge`/`redteam`; labs restate authorized-use rules.

---

## 7. Assessment Model

- **Per-module quiz** (auto-graded, 10–15 items) — protocol/security literacy.
- **Per-module lab** with a rubric (functionality + security posture + evidence of verification).
- **Three checkpoint exams:** after M5 (protocol), M12 (build+security), M17 (operations).
- **Capstone:** design → deploy → attack (authorized) → defend → operate a platform, with a
  written threat model and an incident-response runbook. Peer + instructor review.
- **Certification:** SOVOC issued on capstone pass + checkpoint exams. Security competencies
  are mandatory to pass (you cannot certify on protocol knowledge alone).

---

## 8. Security Spine (cross-module thread)

A persistent thread ("the platform under attack") runs across modules. Learners maintain:
- a **living threat model** (updated each module against `notes.md §2` catalog),
- a **hardening checklist** (accumulates concrete controls), and
- an **incident runbook** (grows into the capstone deliverable).

This guarantees the "emphasis on secure VoIP operations" is assessed continuously, not once.

---

## 9. Deliverable Files

- `00-course-overview.md` — this document.
- `modules/00-orientation-and-lab.md` … `modules/17-frontiers.md` — per-module deep dives.
- `modules/18-capstone.md` — capstone + operations runbooks.
- `notes.md` — OSS tool map, threat catalog, lab architecture, RFC backbone.
- `README.md` — index + SIP School coverage crosswalk.
