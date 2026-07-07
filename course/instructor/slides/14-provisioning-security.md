---
marp: true
theme: default
paginate: true
title: Module 14 — Provisioning & Device Configuration Security
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Module 14 — Provisioning & Device Configuration Security

**Get config onto phones without handing an attacker your SIP credentials — end to end.**

`Est. 4h` · Prereqs: Modules 6, 11, 13 · **Maps to threat T15 → T11**

<!--
Speaker: This module exists because plaintext config files are one of the largest real-world VoIP
credential leaks. A single open provisioning endpoint, or a guessable <MAC>.cfg URL, exposes SIP
passwords for the whole fleet at once — no protocol exploit needed. Two goals: secure config in
flight AND at rest.
-->

---

## What you'll leave with

- Map the **auto-provisioning ecosystem** (zero-touch, DHCP 66, redirection/RPS) and its attack surface.
- Serve configs securely: **HTTPS + mutual TLS, per-device scoping, signed AND encrypted configs**.
- Eliminate cleartext-credential exposure — in flight *and* at rest — with **key rotation**.

<!--
Speaker: Frame the two halves clearly: transport (HTTPS+mTLS) and at-rest (encrypt + sign). Teams
often do one and forget the other — HTTPS in flight, plaintext password on disk. Both matter.
-->

---

## How phones get configured

- Factory default → **DHCP option 66/150** (provisioning URL) → optional **redirection service** →
  provisioning server → `<MAC>.cfg` (+ common config) → register.
- **Redirection / RPS:** Yealink RPS, Cisco EDOS/PnP, Polycom ZTP, Grandstream GAPS.
- **PnP / event-based:** SIP `SUBSCRIBE`/`NOTIFY` `ua-profile` (RFC 6080).

<!--
Speaker: Zero-touch is convenient and dangerous. The redirection/RPS account is fleet-wide root — it
controls where every phone fetches config, so a compromised RPS account repoints the whole fleet to
an attacker. DHCP option 66 hands out the URL with no authentication of that URL. Convenience = attack
surface.
-->

---

## The core failure modes

- **Transport:** TFTP (no auth/crypto) and plain HTTP expose configs on-path (T5/T6).
- **Cleartext at rest:** the config stores the SIP password verbatim → anyone reading the file,
  a backup, or a cache has the credential (**T11**).
- **Enumeration:** MAC-based URLs are predictable → walk `<MAC>.cfg`, harvest the fleet (T15→T2).
- **Tampering:** an unsigned config can repoint the phone at a rogue proxy/dial plan.

<!--
Speaker: Four ways it goes wrong, and they compound. The scariest is enumeration + cleartext: an
unauthenticated server with guessable URLs lets an attacker script-download every phone's password in
minutes. Tampering is the flip side — swap the config and you own the phone's routing.
-->

---

## The defense model

- **Authenticate the device** (mutual TLS).
- **Scope** each device to *only its own* config.
- **Sign** configs for integrity.
- **Encrypt secrets at rest**; inject real passwords server-side.
- **Disable** insecure transports; protect the **redirection/RPS account**.

<!--
Speaker: This is the whole module in one slide. Each control kills one failure mode: mTLS stops
unauthenticated fetch + enumeration; per-device scoping stops cross-device theft; signing stops
tampering; at-rest encryption stops disk/backup leakage; RPS protection stops fleet takeover. The lab
(BF4) builds every one.
-->

---

## Packet reality

- Capture a **TFTP / plain-HTTP** provisioning fetch → read the SIP `secret` line in cleartext.
- Read **DHCP option 66/150** offering the URL (no authentication of it).
- Contrast an **HTTPS + mTLS** fetch: the config never appears in cleartext on the wire.

<!--
Speaker: Show the plaintext password sitting in a TFTP capture — that single image justifies the whole
module. Then the mTLS fetch where the same config is opaque. The DHCP option 66 packet shows how the
URL is just handed out unauthenticated, which is why the *server* must authenticate the device.
-->

---

## Build (OSS)

- **HTTPS + mutual TLS** (nginx `ssl_verify_client on` + device CA): no client cert ⇒ handshake refused.
- **Per-device scoping:** client-cert **CN == requested MAC**; MAC allowlist rejects unknowns.
- **Signed configs:** `sign-config.sh sign <cfg> <key>`; phone verifies, rejects tampered.
- **Encrypted at rest:** `encrypt-config.sh` (AES-256-CBC/PBKDF2) + **key rotation**.
- **Kill TFTP/HTTP**; DHCP 66 → the HTTPS URL; inject secrets server-side.

<!--
Speaker: The CN==MAC scoping is the elegant control — even an authenticated device can fetch ONLY its
own config, so a valid phone can't harvest its neighbours. `encrypt-config.sh` (from the H2 work) means
stored/backed-up configs carry no cleartext secret, and rotation lets you re-key without re-issuing
devices. All in lab BF4.
-->

---

## Attack / Defend

- **Cleartext exposure (T15→T11):** sniff HTTP/TFTP or read a file → HTTPS+mTLS + encrypt at rest +
  server-side secret injection.
- **MAC-URL enumeration (T15→T2):** walk `<MAC>.cfg` → mTLS + allowlist + **CN==MAC** so an
  authenticated device still can't fetch another's.
- **Tampering / rogue redirect (T6/T15):** unsigned config → signed configs + device verification;
  **protect & monitor the RPS account**.

<!--
Speaker: Note the threat chaining: T15 (provisioning abuse) leads to T11 (secret leak) and T2
(enumeration) — provisioning is a gateway to the credentials the rest of the course protects. The RPS
account is the one people forget; alert on unexpected re-provisioning events, treat it as fleet root.
-->

---

## Labs

- **Lab 14.1 (BF4 — secure auto-provisioning)** — HTTPS + mTLS + MAC allowlist + CN==MAC + signed
  configs; prove unauthenticated fetch, spoofed-MAC fetch, and tampered config all **fail**.
- **Lab 14.2 (encryption at rest)** — `encrypt-config.sh`: prove ciphertext leaks nothing, round-trip
  decrypt, reject a tampered ciphertext, **rotate the key**.

*Rubric:* HTTPS+mTLS only · device fetches only its own config · signed + encrypted at rest · no
cleartext secret anywhere · rotation works.

<!--
Speaker: 14.1 is the three-attacks-all-fail lab: no cert → refused, wrong MAC → 403, tampered → phone
rejects. 14.2 proves the at-rest half and key rotation. Together they close the "config file in the
clear" hole that opened the module.
-->

---

## Takeaways & quick check

- Provisioning is a **fleet-wide credential surface** — one hole leaks every phone.
- **HTTPS in flight is not enough** — encrypt secrets at rest too.
- **CN==MAC scoping** stops enumeration *and* cross-device theft; protect the **RPS account** as root.

**Check:** Why is a MAC-based `<MAC>.cfg` on an open HTTP server a fleet-wide leak, and which two
controls stop enumeration *and* cross-device fetch? What does at-rest encryption protect that HTTPS
does not? How can a compromised RPS account defeat a hardened server?

<!--
Speaker: Answers — guessable URLs + no auth let an attacker enumerate every device's config and harvest
credentials; mTLS + CN==MAC scoping stops both unauthorized fetch and one device grabbing another's.
At-rest encryption protects the secret once it's written to disk/backup/cache, where transport crypto
gives nothing. A compromised RPS/redirection account repoints the whole fleet to an attacker's server
regardless of how hardened the real one is — so protect and monitor it as fleet root. Next: VoIP
Threats & Offensive Testing (M15).
-->
