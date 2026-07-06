---
marp: true
theme: default
paginate: true
title: Module 12 — Media Security: SRTP, DTLS-SRTP & ZRTP
---

# Module 12 — Media Security: SRTP, DTLS-SRTP & ZRTP

Encrypt the media plane and get the key exchange right — the difference between "encrypted" and "actually private."

<!-- Instructor: set the scene; ~30 min. Every module ends with a hands-on lab + fail-closed verify.sh. -->
---

## Learning Objectives

- Configure SRTP with SDES, DTLS-SRTP, and ZRTP across the OSS stack.
- Explain the key-exchange trade-offs and their attack surfaces.
- Bridge secure/insecure media at the SBC without silently downgrading.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 1. Concept

- **Why encrypt media:** TLS protects signaling only; RTP is separately sniffable/recordable
- **Key-exchange methods:**
- **SDES (RFC 4568):** keys in SDP `a=crypto` — *only as safe as the signaling*; requires
- **DTLS-SRTP (RFC 5763/5764):** DTLS handshake in the media path; SDP carries
- **ZRTP (RFC 6189):** in-media Diffie-Hellman with SAS verification; end-to-end even across
- **SRTP profiles/ciphers:** AES-CM + HMAC-SHA1, AES-GCM (AEAD); crypto-suite negotiation.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 2. Packet Reality

- Capture SDES-SRTP: note `a=crypto` (and why TLS must wrap it); show RTP is now unreadable.
- Capture DTLS-SRTP: observe the DTLS handshake + `a=fingerprint`; no keys in SDP.
- Capture ZRTP: observe Hello/Commit/DH and the SAS.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 3. Build (OSS)

- Asterisk: `media_encryption=sdes` then `dtls` on a PJSIP endpoint; certs/fingerprints for DTLS.
- rtpengine flags to bridge `SRTP<->RTP` and `DTLS<->SDES`; enforce SRTP-only policy.
- ZRTP with Linphone/Baresip end-to-end; verify the SAS between two humans.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 4. Attack / Defend

- **Eavesdropping (T5):** re-run the M4 audio-reconstruction attack against SRTP and show failure.
- **Downgrade attacks:** stripping `a=crypto`/`fingerprint` to force cleartext → policy: require
- **SDES-over-plaintext-signaling:** demonstrate key capture when SDES runs without TLS → always
- **DTLS fingerprint substitution / MITM without SAS:** why ZRTP's SAS matters; cert/fingerprint
- Finalize the crypto section of the hardening checklist; update threat model.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 5. Labs

- **Lab 12.1:** Bring up SDES-SRTP (with TLS) end-to-end; prove media is unreadable in capture.
- **Lab 12.2:** Bring up DTLS-SRTP (WebRTC-style) via rtpengine; capture the handshake.
- **Lab 12.3 (attack):** Attempt an SDP `a=crypto` strip; show SRTP-only policy rejects the call;
- *Rubric:* all three methods working; eavesdrop defeated; downgrade blocked; SAS verified.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## Lab & assessment

- Hands-on lab with a fail-closed `verify.sh`; rubric 100 pts, pass ≥ 70.
- Update your living threat model + hardening checklist.

<!-- Speaker note: point learners at lab/labs/<module>/. -->
