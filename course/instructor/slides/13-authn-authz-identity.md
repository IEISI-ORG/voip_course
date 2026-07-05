---
marp: true
theme: default
paginate: true
title: Module 13 — Authentication, Authorization & Caller Identity
---

# Module 13 — Authentication, Authorization & Caller Identity

Prove who a party is — at registration, at call setup, and across the PSTN with STIR/SHAKEN.

<!-- Instructor: set the scene; ~30 min. Every module ends with a hands-on lab + fail-closed verify.sh. -->
---

## Learning Objectives

- Implement SIP digest authentication and authorization policy correctly.
- Deploy STIR/SHAKEN (sign + verify) with libstirshaken/Asterisk/OpenSIPS.
- Defend against enumeration, brute force, and caller-ID spoofing.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 1. Concept

- **SIP digest auth (RFC 7616/2617 heritage):** 401/407 challenge, realm, nonce, `qop`, MD5 vs.
- **Authorization policy:** what an authenticated identity is *allowed* to do — class-of-service,
- **Caller identity in SIP:** From vs. P-Asserted-Identity (RFC 3325), P-Preferred, Privacy
- **STIR/SHAKEN:**
- The robocall/caller-ID-spoofing problem and its scale.
- **STIR:** PASSporT (RFC 8225) — a signed JWT over calling/called numbers + attestation;

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 2. Packet Reality

- Read a 401/407 digest round-trip; identify realm/nonce/qop/response.
- Read a signed INVITE: decode the `Identity` header, the PASSporT header/payload/signature,

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 3. Build (OSS)

- Enforce digest auth on REGISTER + INVITE in Asterisk and Kamailio (`auth`/`auth_db`); use SHA-256.
- STIR/SHAKEN: sign outbound with Asterisk `res_stir_shaken` (or OpenSIPS `stir_shaken`/
- Authorization: dialplan/route policy mapping identity → allowed destinations + caps.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 4. Attack / Defend

- **Extension enumeration (T2):** response/timing deltas (401 vs. 404 vs. 403) reveal valid users
- **Registration/password brute force (T3):** svcrack → strong secret policy, lockout/backoff,
- **Caller-ID spoofing (T7):** untrusted From/PAI → verify STIR/SHAKEN, gate features by
- **Weak digest (MD5, no qop):** upgrade to SHA-256/qop; TLS still required (digest ≠ confidentiality).
- Update threat model + hardening checklist (identity controls).

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 5. Labs

- **Lab 12.1:** Enforce SHA-256 digest on REGISTER+INVITE; capture and annotate the challenge.
- **Lab 12.2 (identity):** Sign outbound calls and verify inbound STIR/SHAKEN in the lab CA;
- **Lab 12.3 (attack→defend):** Run authorized `svwar`/`svcrack` against the lab; measure how
- *Rubric:* strong digest enforced; working sign/verify with attestation logic; enumeration &

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## Lab & assessment

- Hands-on lab with a fail-closed `verify.sh`; rubric 100 pts, pass ≥ 70.
- Update your living threat model + hardening checklist.

<!-- Speaker note: point learners at lab/labs/<module>/. -->
