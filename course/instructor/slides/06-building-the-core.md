---
marp: true
theme: default
paginate: true
title: Module 6 — Building the Core: Asterisk & FreeSWITCH
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Module 6 — Building the Core: Asterisk & FreeSWITCH

**Stand up real PBX / application servers from the ground up — with secure defaults.**

`Est. 6h` · Prereqs: Modules 1–5

<!--
Speaker: We stop reading other people's calls and start building the platform. Two engines,
Asterisk and FreeSWITCH, so they see the concepts are portable. The security spine of this module:
insecure defaults are the #1 real-world VoIP breach cause — we fix them from the first config.
-->

---

## What you'll leave with

- Configure **Asterisk (PJSIP)** and **FreeSWITCH** for registration, calling, features.
- Model **endpoints, auth, AORs, dialplan, voicemail, IVR, MoH**.
- Apply **secure-by-default** config and **secret hygiene** — and start the hardening checklist.

<!--
Speaker: The deliverable that starts today and lives to the capstone: the hardening checklist. Every
build decision gets a security counterpart. Frame features and hardening as one activity, not two.
-->

---

## Asterisk architecture

- **Channels** + the **PJSIP** stack: `transport` → `endpoint` → `auth` → `aor`.
- **Dialplan** (`extensions.conf` / AEL); apps: **Dial, Voicemail, Queue**.
- **CDR / CEL** for call records.

<!--
Speaker: The PJSIP object model is the exam bait: transport (how you listen), endpoint (the peer),
auth (the credential), aor (where they register). Separating auth from endpoint lets you reuse and
rotate credentials cleanly. Draw the four-object chain.
-->

---

## FreeSWITCH architecture

- **XML config:** profiles / gateways, dialplan XML, `mod_*` modules.
- **Event Socket Layer (ESL)** for automation.
- **When to prefer FS:** scale + media; **Asterisk:** features + community.

<!--
Speaker: Don't frame it as FS-vs-Asterisk tribalism — they solve overlapping problems. FS shines at
high-volume media and programmable control via ESL; Asterisk has the deeper feature set and community
recipes. The lab builds the same PBX on both so the concepts transfer.
-->

---

## Core features

- Registration · extension-to-extension · **voicemail** · **IVR / auto-attendant**.
- Ring groups / queues · MoH · lawful **call recording** · transfer/REFER.
- Presence / BLF (preview M19).
- **Config data models:** flat files vs. realtime (DB-backed) for scale.

<!--
Speaker: These are the building blocks of any phone system. Each is also attack surface: voicemail
PINs, IVR that reaches the dialplan, DISA. Realtime (DB) config previews provisioning-at-scale
(M14). Keep noting the security shadow of each feature.
-->

---

## Packet reality

- Compare the **SIP/SDP** a call generates in **Asterisk vs. FreeSWITCH** (headers, UA, media).
- Trace a **voicemail deposit** and an **IVR menu** (DTMF handling).

<!--
Speaker: Seeing the two engines' on-the-wire differences (UA banner, header ordering, media
handling) reinforces M2 — "compliant" implementations differ. The DTMF-through-IVR trace connects
to recording redaction (M16) and the inband-DTMF PII risk from M5.
-->

---

## Build (OSS)

- **Asterisk:** `transport` (UDP/TCP/TLS) → `endpoint` + `auth` + `aor` → dialplan with
  Dial / Voicemail / IVR.
- **FreeSWITCH:** internal profile, a directory user, a dialplan extension, an IVR; ESL "hello world."
- **Realtime config** demo (Asterisk + DB) for scale.

<!--
Speaker: Keep the first build minimal and working, then layer features. The TLS transport option is
here but full signaling security is M11 — plant the seed. ESL "hello world" is their hook into
automating the platform later (M18).
-->

---

## Attack / Defend — secure defaults ARE the lesson

- **Insecure defaults = the #1 real-world VoIP breach cause.**
- Disable anonymous/guest calls; **require auth on every endpoint** (`allowguest=no`).
- **Dialplan trust boundaries:** a compromised extension must never reach premium/international.
- **Secret hygiene (T11):** strong secrets, file perms `640 root:asterisk`, **no creds in git**,
  env/vault, rotate.
- **Feature-code hardening (T13):** VM PIN policy, disable DISA, limit `Dial` options.

<!--
Speaker: This is the heart of the module. The classic breach: default/guest calling + an open
dialplan reaching international = a five-figure toll-fraud bill overnight. Secret hygiene is a
recurring T11 theme — the config file with the password is the thing attackers want (ties to M14
provisioning). Log to mgmt now so M17 has data.
-->

---

## Labs

- **Lab 6.1** — 4-extension PBX with voicemail + IVR on **Asterisk**; place all call types.
- **Lab 6.2** — Reproduce the core on **FreeSWITCH**; compare generated SIP + media.
- **Lab 6.3 (security)** — Harden a deliberately-insecure config: prove anonymous calling is
  blocked and secrets are non-readable; **commit the hardening checklist v1**.

*Rubric:* working features on both platforms · insecure defaults eliminated with evidence.

<!--
Speaker: 6.3 is the keystone — they take a knowingly-broken config and prove each fix (anonymous
call rejected, secret file unreadable). The hardening checklist v1 they commit here gets re-run and
extended every remaining module. Make them keep the before/after evidence.
-->

---

## Takeaways & quick check

- **Secure defaults from line one** — retrofitting security is how breaches happen.
- Keep **secrets out of git** while staying reproducible (env/vault).
- Every feature has a **security shadow** — harden as you build.

**Check:** Which PJSIP objects bind a credential to a registration, and why separate them? Three
default settings that enable toll fraud? How do you keep endpoint secrets out of VCS yet stay reproducible?

<!--
Speaker: Answers — auth (credential) + aor (registration target), bound via the endpoint; separated
so credentials rotate/reuse independently. Toll-fraud defaults: guest/anonymous calling enabled, an
open dialplan reaching international, weak/default secrets. Secrets out of VCS: reference env vars or
a vault/secret store and inject at deploy — the config in git holds placeholders. Next: proxies and
SBCs (M7).
-->
