---
marp: true
theme: default
paginate: true
title: Module 6 — Building the Core: Asterisk & FreeSWITCH
---

# Module 6 — Building the Core: Asterisk & FreeSWITCH

Stand up real PBX/application servers from the ground up with secure defaults.

<!-- Instructor: set the scene; ~30 min. Every module ends with a hands-on lab + fail-closed verify.sh. -->
---

## Learning Objectives

- Install and configure Asterisk (PJSIP) and FreeSWITCH for registration, calling, and features.
- Model endpoints, auth, AORs, dialplan/routing, voicemail, IVR, and MoH.
- Apply secure-by-default configuration and secret hygiene.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 1. Concept

- **Asterisk architecture:** channels, PJSIP stack (`endpoint`/`aor`/`auth`/`transport`),
- **FreeSWITCH architecture:** XML config, profiles/gateways, dialplan XML, mod_* modules,
- **Core features:** registration, extension-to-extension, voicemail, IVR/auto-attendant,
- **Config data models:** flat files vs. realtime (DB-backed) config; provisioning at scale.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 2. Packet Reality

- Compare the SIP/SDP a call generates in Asterisk vs. FreeSWITCH (headers, UA, media handling).
- Trace a voicemail deposit and an IVR menu (DTMF handling).

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 3. Build (OSS)

- Asterisk: `transport` (UDP/TCP/TLS), `endpoint`+`auth`+`aor`, a dialplan with Dial/Voicemail/IVR.
- FreeSWITCH: internal profile, a directory user, a dialplan extension, an IVR; ESL "hello world."
- Realtime config demo (Asterisk + DB) for scale.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 4. Attack / Defend (secure defaults are the lesson)

- **Insecure defaults are the #1 real-world VoIP breach cause.** Concrete hardening:
- Disable anonymous/guest calls; require auth on every endpoint.
- Restrict `allowguest=no`, `allow_unauthenticated_options` off; bind to specific interfaces.
- Dialplan trust boundaries: never let a compromised extension reach premium/international.
- **Secret hygiene (T11):** strong endpoint secrets, file perms (`640 root:asterisk`), no
- Voicemail/feature-code hardening (T13): PIN policy, disable DISA, limit `Dial` options.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 5. Labs

- **Lab 6.1:** Build a 4-extension PBX with voicemail + IVR on Asterisk; place all call types.
- **Lab 6.2:** Reproduce the core on FreeSWITCH; compare generated SIP and media behavior.
- **Lab 6.3 (security):** Harden a deliberately-insecure config; prove anonymous calling is
- *Rubric:* working features on both platforms; insecure defaults eliminated with evidence.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## Lab & assessment

- Hands-on lab with a fail-closed `verify.sh`; rubric 100 pts, pass ≥ 70.
- Update your living threat model + hardening checklist.

<!-- Speaker note: point learners at lab/labs/<module>/. -->
