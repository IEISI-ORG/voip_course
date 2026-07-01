# Module 6 — Building the Core: Asterisk & FreeSWITCH

**One-liner:** Stand up real PBX/application servers from the ground up with secure defaults.
**Est. time:** 6h · **Prereqs:** Modules 1–5.

## Learning Objectives
- Install and configure Asterisk (PJSIP) and FreeSWITCH for registration, calling, and features.
- Model endpoints, auth, AORs, dialplan/routing, voicemail, IVR, and MoH.
- Apply secure-by-default configuration and secret hygiene.

## 1. Concept
- **Asterisk architecture:** channels, PJSIP stack (`endpoint`/`aor`/`auth`/`transport`),
  dialplan (`extensions.conf`) or AEL, applications (Dial, Voicemail, Queue), CDR/CEL.
- **FreeSWITCH architecture:** XML config, profiles/gateways, dialplan XML, mod_* modules,
  Event Socket Layer (ESL) for automation; when to prefer FS (scale, media) vs. Asterisk (features/community).
- **Core features:** registration, extension-to-extension, voicemail, IVR/auto-attendant,
  ring groups/queues, MoH, call recording (lawful), transfer/REFER, presence/BLF (preview M17).
- **Config data models:** flat files vs. realtime (DB-backed) config; provisioning at scale.

## 2. Packet Reality
- Compare the SIP/SDP a call generates in Asterisk vs. FreeSWITCH (headers, UA, media handling).
- Trace a voicemail deposit and an IVR menu (DTMF handling).

## 3. Build (OSS)
- Asterisk: `transport` (UDP/TCP/TLS), `endpoint`+`auth`+`aor`, a dialplan with Dial/Voicemail/IVR.
- FreeSWITCH: internal profile, a directory user, a dialplan extension, an IVR; ESL "hello world."
- Realtime config demo (Asterisk + DB) for scale.

## 4. Attack / Defend (secure defaults are the lesson)
- **Insecure defaults are the #1 real-world VoIP breach cause.** Concrete hardening:
  - Disable anonymous/guest calls; require auth on every endpoint.
  - Restrict `allowguest=no`, `allow_unauthenticated_options` off; bind to specific interfaces.
  - Dialplan trust boundaries: never let a compromised extension reach premium/international.
  - **Secret hygiene (T11):** strong endpoint secrets, file perms (`640 root:asterisk`), no
    credentials in git, secrets via env/vault, rotate.
  - Voicemail/feature-code hardening (T13): PIN policy, disable DISA, limit `Dial` options.
  - Logging to `mgmt` for later detection (M15).
- Start the **hardening checklist** deliverable here.

## 5. Labs
- **Lab 6.1:** Build a 4-extension PBX with voicemail + IVR on Asterisk; place all call types.
- **Lab 6.2:** Reproduce the core on FreeSWITCH; compare generated SIP and media behavior.
- **Lab 6.3 (security):** Harden a deliberately-insecure config; prove anonymous calling is
  blocked and secrets are non-readable; commit the hardening checklist v1.
- *Rubric:* working features on both platforms; insecure defaults eliminated with evidence.

## Assessment (sample)
- In PJSIP, which objects bind a credential to a registration and why separate them?
- Name three default settings that enable toll fraud if left unchanged.
- How do you keep endpoint secrets out of version control while staying reproducible?

## References
- Asterisk PJSIP & dialplan docs; FreeSWITCH Confluence (profiles, dialplan, ESL);
  Asterisk security best-practices; `../notes.md §2` (T11, T13).
