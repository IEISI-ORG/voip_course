---
marp: true
theme: default
paginate: true
title: Module 10 — Signaling Security: TLS & SIPS
---

# Module 10 — Signaling Security: TLS & SIPS

Encrypt and authenticate the signaling plane end-to-edge with TLS, and manage the certificates.

<!-- Instructor: set the scene; ~30 min. Every module ends with a hands-on lab + fail-closed verify.sh. -->
---

## Learning Objectives

- Deploy SIP over TLS (SIPS) on PBX and SBC, including mutual TLS on trunks.
- Manage certificates (public via Let's Encrypt, private via step-ca) and their lifecycle.
- Detect and prevent signaling MITM/tampering.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 1. Concept

- **Why encrypt signaling:** SIP over UDP/TCP is plaintext → interception, tampering, spoofing,
- **SIP transports:** UDP/TCP/TLS/WS/WSS; `sips:` URIs; port 5061; per-hop vs. end-to-end
- **TLS essentials for VoIP:** versions (require 1.2+, prefer 1.3), cipher policy, SNI, session
- **Certificate management:** public certs (Let's Encrypt via certbot/acme.sh) for edge;
- **Mutual TLS on trunks/peering:** authenticate carrier/peer by client cert — strong anti-spoof.
- **Interplay with topology hiding & SBC:** TLS terminates at the edge; re-originate to core over

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 2. Packet Reality

- Capture a TLS handshake for SIP; with the server key, decrypt and read the now-protected SIP.
- Contrast: capture plaintext SIP showing credentials/headers an attacker would harvest.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 3. Build (OSS)

- Asterisk `transport` type TLS (cert/key/ca, `verify_client` for mTLS); register a client over TLS.
- Kamailio `tls` module + `tls.cfg` profiles; TLS listener on 5061; edge-terminate then core-mTLS.
- Issue edge cert with acme.sh; issue internal certs with step-ca; automate renewal + reload.
- mTLS trunk between SBC and `trunk-sim`.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 4. Attack / Defend

- **Signaling MITM/tampering (T6):** demonstrate (in lab) reading/altering plaintext SIP; then
- **Cert-management failures:** expired certs = outage; weak ciphers/old TLS = exposure; private
- **Trust pitfalls:** hop-by-hop TLS means you trust every intermediary — document the trust
- Extend hardening checklist (transport policy) + threat model.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 5. Labs

- **Lab 10.1:** Enforce TLS-only registration on Asterisk + Kamailio; prove UDP/TCP are refused.
- **Lab 10.2:** Decrypt a captured SIP-TLS session with the server key and read it.
- **Lab 10.3 (security):** Establish mTLS on the trunk; show a peer without a valid client cert
- *Rubric:* TLS-only enforced; decryption demonstrated for teaching; working mTLS + expiry alert.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## Lab & assessment

- Hands-on lab with a fail-closed `verify.sh`; rubric 100 pts, pass ≥ 70.
- Update your living threat model + hardening checklist.

<!-- Speaker note: point learners at lab/labs/<module>/. -->
