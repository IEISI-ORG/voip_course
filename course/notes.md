# Notes: Open-Source Stack, Threat Catalog & Lab Architecture

These notes back the course design. They are the reusable "engine room" referenced by
every module deep dive.

## 1. Open-Source Tool Map (by function)

| Function | Primary OSS | Alternatives | Notes |
|----------|-------------|--------------|-------|
| PBX / application server | Asterisk | FreeSWITCH | Asterisk = dialplan-centric, huge community; FreeSWITCH = XML/ESL, scales well |
| SIP proxy / router / registrar | Kamailio | OpenSIPS | C, config-scripted routing; both fork from original SER |
| SBC (signaling + media anchor) | Kamailio + rtpengine | OpenSIPS + rtpengine, drachtio | "SBC" = proxy for topology hiding + media relay for NAT/security |
| Media relay / SRTP bridge | rtpengine | RTPproxy, mediaproxy-ng | Kernel-forwarded RTP, SRTP<->RTP, transcoding via codecs |
| Softphone / UAC-UAS test client | Linphone, Baresip | PJSUA (PJSIP), MicroSIP, Jitsi | Baresip scriptable; PJSIP = library for automation |
| Load / conformance testing | SIPp | sipsak, pjsua scripts | XML scenarios, RTP echo, TLS support |
| Recon / offensive (authorized) | SIPVicious OSS (svmap/svwar/svcrack) | sipvicious_pro (comm.), Mr.SIP, sipp fuzzers | Scanning, extension & password enumeration |
| Packet capture / analysis | Wireshark / tshark | tcpdump | SIP/SDP/RTP dissectors, RTP player, VoIP calls window |
| Live SIP CLI viewer | sngrep | homer-ui | ncurses SIP flow ladder from live capture or pcap |
| SIP capture aggregation | HOMER 7 + Heplify/captagent (HEP) | — | Central pcap/metadata store, correlation, KPIs |
| TLS certs | OpenSSL + Let's Encrypt (certbot/acme.sh) | step-ca (private CA) | Public certs for edge; private CA for internal mTLS |
| Media crypto | libsrtp (SRTP), DTLS via OpenSSL, ZRTP via libzrtp/GNU ZRTP | — | SDES, DTLS-SRTP, ZRTP end-to-end |
| Caller identity | libstirshaken, Asterisk STIR/SHAKEN, sti-ca tooling | OpenSIPS stir_shaken module | PASSporT signing/verification, cert mgmt |
| Fax | spandsp (T.38/T.30) in Asterisk/FreeSWITCH | iaxmodem/hylafax | T.38 gateway + pass-through |
| DNS / ENUM | BIND9, dnsmasq | PowerDNS | NAPTR records, e164.arpa, private ENUM |
| Firewall / edge | nftables (iptables), fail2ban | ipset, CrowdSec | Rate limits, geo/deny, brute-force jails |
| Fraud / SIEM | Wazuh, custom CDR analytics | Graylog, ELK | Toll-fraud detection, log correlation |
| Metrics / dashboards | Prometheus + Grafana | Zabbix | Asterisk/Kamailio exporters, SIP KPIs |
| Logs | Loki + promtail | rsyslog + ELK | Structured SIP logs |
| Transport security overlay | WireGuard, IPsec (strongSwan) | OpenVPN | Trunk encryption where TLS/SRTP insufficient |
| Orchestration / IaC | Docker + docker-compose, Kubernetes, Ansible, Terraform | Nomad | Reproducible lab + prod parity |
| Session recording (lawful) | Asterisk MixMonitor, FreeSWITCH recordings | — | Handle with encryption + access control |

## 2. Threat Catalog (mapped to modules that treat it)

| # | Threat | Vector | Primary defense | Module |
|---|--------|--------|-----------------|--------|
| T1 | SIP scanning / device fingerprinting | OPTIONS/REGISTER sweeps (svmap) | Rate limit, fail2ban, hide UA, TLS | M8,M13,M14 |
| T2 | Extension enumeration | 401/403/404 response deltas | Uniform responses, delay, fail2ban | M12,M13,M14 |
| T3 | Registration hijack / password brute force | svcrack, credential stuffing | Strong secrets, TLS, lockout, IP allowlist | M12,M14 |
| T4 | Toll fraud / IRSF | Compromised creds, open dialplan | Dial restrictions, spend limits, anomaly CDR | M14,M15 |
| T5 | Eavesdropping (media) | RTP sniffing on path | SRTP / DTLS-SRTP / ZRTP | M11 |
| T6 | Signaling tampering / MITM | Plain UDP/TCP SIP | TLS/SIPS, mutual TLS on trunks | M10 |
| T7 | Caller-ID spoofing / robocalls | Forged From/PAI | STIR/SHAKEN, attestation, analytics | M12,M17 |
| T8 | DoS / flood (INVITE, REGISTER) | Volumetric + app-layer | pike/ratelimit (Kamailio), nftables, SBC | M8,M13,M14 |
| T9 | RTP injection / bleed | Unauthenticated media ports | rtpengine strict source, SRTP, symmetric RTP | M8,M11 |
| T10 | SIP message fuzzing / parser crashes | Malformed SIP | Robust parsers, WAF-style checks, patching | M13,M16 |
| T11 | Config/secret leakage | World-readable configs, plaintext secrets | Secrets mgmt, file perms, no creds in git | M6,M14 |
| T12 | Trunk abuse / spoofed peers | Static-IP trunks without auth | IP+TLS+SIP auth, topology hiding | M9,M10 |
| T13 | Voicemail / feature-code abuse | Weak PINs, DISA misuse | PIN policy, disable DISA, monitor | M14 |
| T14 | Insider / recording exposure | Access to recordings/CDRs | Encryption at rest, RBAC, audit | M14,M15 |
| T15 | Supply-chain / provisioning abuse | Insecure auto-provisioning (TFTP) | HTTPS provisioning, signed configs, MACs | M14 |

## 3. Reference Lab Architecture (Docker-composed)

```
              Internet / PSTN sim
                     │
             ┌───────▼────────┐
             │  edge-sbc      │  Kamailio + rtpengine
             │  (nftables,    │  TLS 5061, topology hiding, pike/ratelimit
             │   fail2ban)    │  STIR/SHAKEN verify
             └───────┬────────┘
                     │ internal (mTLS)
        ┌────────────┼─────────────┐
   ┌────▼────┐  ┌────▼────┐   ┌─────▼─────┐
   │ pbx-a   │  │ pbx-b   │   │ trunk-sim │  SIPp / Asterisk peer
   │ Asterisk│  │FreeSWITCH│  │ (PSTN)    │
   └────┬────┘  └────┬────┘   └───────────┘
        │            │
   ┌────▼─────────────▼────┐
   │ observability          │  HOMER+Heplify, Prometheus, Grafana, Loki, Wazuh
   └───────────────────────┘
   ┌───────────────────────┐
   │ clients / attackers    │  Linphone, Baresip, PJSUA, SIPp, SIPVicious (isolated net)
   └───────────────────────┘
```

- Networks: `edge` (untrusted), `core` (trusted, mTLS), `mgmt` (observability), `redteam` (isolated).
- Everything reproducible: `docker compose up` brings the full topology; Ansible role variants for VM/bare-metal.
- Attacker containers only reach the `edge`/`redteam` networks — mirrors real DMZ segmentation and keeps offensive labs ethically fenced.

## 4. Standards / RFC backbone (cited across modules)
- RFC 3261 (SIP core), 3262 (PRACK/100rel), 3263 (locating servers), 3264 (offer/answer),
  4566 (SDP), 3550/3551 (RTP/RTCP), 3711 (SRTP), 5763/5764 (DTLS-SRTP), 6189 (ZRTP),
  3325 (P-Asserted-Identity), 8224/8225/8226/8588 (STIR/SHAKEN: PASSporT, cert, div),
  5389/8489 (STUN), 5766/8656 (TURN), 8445 (ICE), 3311 (UPDATE), 3515 (REFER),
  3891 (Replaces), 3323 (Privacy), 6140 (registration bulk), 6116 (ENUM), 3435/MGCP (ctx),
  T.38/T.30 (fax), 3GPP TS 24.229 (IMS), GSMA IR.92 (VoLTE), 8760 (digest AKA/SHA-256).
- NIST SP 800-58 (VoIP security), SP 800-52 (TLS), ENISA VoIP guidance, OWASP-style SIP hardening.

## 5. SIP School coverage crosswalk (ensure nothing dropped)
Every SIP School module maps into SOVOC; security-first reordering shown in README.md.
Additions beyond SIP School: dedicated offensive module (M13), defense/fraud module (M14),
observability/IR module (M15), automation/IaC (M16), and a build-focus (M6/M7) that SIP
School only describes conceptually.
