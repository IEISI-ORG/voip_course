---
marp: true
theme: default
paginate: true
title: Module 14 — Provisioning & Device Configuration Security
---

# Module 14 — Provisioning & Device Configuration Security

Get configuration onto phones and gateways without handing an attacker your SIP credentials — secure auto-provisioning end to end, in flight and at rest.

<!-- Instructor: set the scene; ~30 min. Every module ends with a hands-on lab + fail-closed verify.sh. -->
---

## Learning Objectives

- Map the auto-provisioning ecosystem (zero-touch, DHCP option 66, redirection/RPS services) and
- Serve configs securely: HTTPS + mutual TLS, per-device scoping, signed **and** encrypted configs.
- Eliminate cleartext-credential exposure in provisioning, in flight and at rest, with key rotation.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 1. Concept

- **How phones get configured:** manual → **auto-provisioning**. The zero-touch chain: factory
- **Redirection / RPS services:** Yealink RPS, Cisco EDOS/PnP (`Network-Provisioning`), Polycom
- **PnP / event-based provisioning:** SIP `SUBSCRIBE`/`NOTIFY` for `ua-profile` (RFC 6080 event
- **The core failure modes:**
- **Transport:** TFTP (no auth, no crypto) and plain HTTP expose configs to anyone on-path (T5/T6).
- **Cleartext at rest:** config files store the SIP auth password verbatim; anyone who reads the

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 2. Packet Reality

- Capture a TFTP and a plain-HTTP provisioning fetch; read the SIP `auth`/`secret` line in cleartext.
- Read DHCP option 66/150 offering the provisioning URL; note there is no authentication of that URL.
- Contrast with an HTTPS + mTLS fetch: the config never appears in cleartext on the wire.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 3. Build (OSS)

- **HTTPS + mutual TLS** provisioning server (nginx, `ssl_verify_client on` with a device CA): no
- **Per-device scoping:** a device may fetch **only** its own `<MAC>.cfg` — enforce client-cert
- **Signed configs:** `sign-config.sh sign <cfg> <key>`; the phone verifies and rejects tampered files.
- **Encrypted at rest:** `encrypt-config.sh` (AES-256-CBC/PBKDF2) so stored/backed-up configs carry
- **Secret injection:** template the served file; never store the real SIP password in the repo
- **Kill insecure paths:** disable TFTP/plain-HTTP provisioning; DHCP option 66 points at the HTTPS URL.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 4. Attack / Defend

- **Cleartext config exposure (T15→T11):** sniff HTTP/TFTP or read a served file → move to HTTPS+mTLS,
- **MAC-URL enumeration (T15→T2):** walk `<MAC>.cfg` on an open server → mTLS + allowlist + CN==MAC
- **Config tampering / rogue redirect (T6/T15):** swap an unsigned config to a rogue proxy → signed
- Update the threat model + hardening checklist (provisioning controls).

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 5. Labs

- **Lab 14.1 (BF4 — secure auto-provisioning):** stand up HTTPS + mTLS + MAC allowlist + per-device
- **Lab 14.2 (encryption at rest):** encrypt a config's secrets with `encrypt-config.sh`, prove the
- *Rubric:* provisioning is HTTPS+mTLS only; a device can fetch only its own config; configs are

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## Lab & assessment

- Hands-on lab with a fail-closed `verify.sh`; rubric 100 pts, pass ≥ 70.
- Update your living threat model + hardening checklist.

<!-- Speaker note: point learners at lab/labs/<module>/. -->
