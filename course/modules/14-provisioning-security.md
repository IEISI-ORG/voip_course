# Module 14 — Provisioning & Device Configuration Security

**One-liner:** Get configuration onto phones and gateways without handing an attacker your SIP
credentials — secure auto-provisioning end to end, in flight and at rest. **Est. time:** 4h ·
**Prereqs:** Modules 6 (secret hygiene), 11 (TLS/SIPS), 13 (authN). **Maps to threat T15
(provisioning abuse) → T11 (secret leakage).**

> **Why a whole module:** device config files in the clear are one of the largest real-world VoIP
> credential-exposure holes. A single unauthenticated TFTP/HTTP provisioning endpoint, or a
> predictable `<MAC>.cfg` URL, leaks SIP passwords for every phone on the fleet at once — no
> protocol exploit required.

## Learning Objectives
- Map the auto-provisioning ecosystem (zero-touch, DHCP option 66, redirection/RPS services) and
  its attack surface.
- Serve configs securely: HTTPS + mutual TLS, per-device scoping, signed **and** encrypted configs.
- Eliminate cleartext-credential exposure in provisioning, in flight and at rest, with key rotation.

## 1. Concept
- **How phones get configured:** manual → **auto-provisioning**. The zero-touch chain: factory
  default → DHCP (option 66/150 `tftp-server-name`, option 160/other vendor URLs) → optional
  **redirection service** → provisioning server → `<MAC>.cfg` (+ a common/model config) → register.
- **Redirection / RPS services:** Yealink RPS, Cisco EDOS/PnP (`Network-Provisioning`), Polycom
  ZTP, Snom redirection, Grandstream GAPS. Convenient, but the account that controls redirection
  can **repoint an entire fleet** to an attacker's server — a supply-chain-grade takeover (T15).
- **PnP / event-based provisioning:** SIP `SUBSCRIBE`/`NOTIFY` for `ua-profile` (RFC 6080 event
  package); Asterisk `res_pjsip`/`phoneprov` multicast PnP. Same secret-exposure rules apply.
- **The core failure modes:**
  - **Transport:** TFTP (no auth, no crypto) and plain HTTP expose configs to anyone on-path (T5/T6).
  - **Cleartext at rest:** config files store the SIP auth password verbatim; anyone who reads the
    file — on the server, a backup, a cache, or a mis-scoped fetch — has the credential (T11).
  - **Enumeration:** MAC-address URLs are predictable; an unauthenticated server lets an attacker
    walk `<MAC>.cfg` and harvest the fleet (T15 → T2/T11).
  - **Tampering:** an unsigned config can be swapped to point the phone at a rogue proxy or dial plan.
- **Defense model (this module):** authenticate the *device* (mTLS), scope each device to **only
  its own** config, sign configs for integrity, **encrypt secrets at rest**, inject real passwords
  server-side, disable insecure transports, and protect the redirection/RPS account.

## 2. Packet Reality
- Capture a TFTP and a plain-HTTP provisioning fetch; read the SIP `auth`/`secret` line in cleartext.
- Read DHCP option 66/150 offering the provisioning URL; note there is no authentication of that URL.
- Contrast with an HTTPS + mTLS fetch: the config never appears in cleartext on the wire.

## 3. Build (OSS)
- **HTTPS + mutual TLS** provisioning server (nginx, `ssl_verify_client on` with a device CA): no
  valid client cert ⇒ handshake refused. See lab `nginx-provisioning.conf`.
- **Per-device scoping:** a device may fetch **only** its own `<MAC>.cfg` — enforce client-cert
  `CN == requested MAC`; MAC allowlist rejects unknown devices.
- **Signed configs:** `sign-config.sh sign <cfg> <key>`; the phone verifies and rejects tampered files.
- **Encrypted at rest:** `encrypt-config.sh` (AES-256-CBC/PBKDF2) so stored/backed-up configs carry
  no cleartext secret; support **key rotation** (`rotate`) without re-issuing devices.
- **Secret injection:** template the served file; never store the real SIP password in the repo
  or the base config (placeholder only), inject per-device at serve time.
- **Kill insecure paths:** disable TFTP/plain-HTTP provisioning; DHCP option 66 points at the HTTPS URL.
- **Protect the redirection account:** strong unique credential, MFA where offered, alerting on
  re-provisioning events — treat it as fleet-wide root.

## 4. Attack / Defend
- **Cleartext config exposure (T15→T11):** sniff HTTP/TFTP or read a served file → move to HTTPS+mTLS,
  encrypt at rest, inject secrets server-side.
- **MAC-URL enumeration (T15→T2):** walk `<MAC>.cfg` on an open server → mTLS + allowlist + CN==MAC
  scoping so an authenticated device still cannot fetch another's config.
- **Config tampering / rogue redirect (T6/T15):** swap an unsigned config to a rogue proxy → signed
  configs + device-side verification; protect and monitor the RPS/redirection account.
- Update the threat model + hardening checklist (provisioning controls).

## 5. Labs
- **Lab 14.1 (BF4 — secure auto-provisioning):** stand up HTTPS + mTLS + MAC allowlist + per-device
  (CN==MAC) scoping + signed configs; prove unauthenticated fetch, spoofed-MAC fetch, and tampered
  config all fail. `bash labs/bf4-provisioning/verify.sh`
- **Lab 14.2 (encryption at rest):** encrypt a config's secrets with `encrypt-config.sh`, prove the
  ciphertext leaks nothing, round-trip decrypt, reject a tampered ciphertext, and rotate the key.
  `bash labs/bf4-provisioning/encrypt-config.sh demo`
- *Rubric:* provisioning is HTTPS+mTLS only; a device can fetch only its own config; configs are
  signed and encrypted at rest; no cleartext SIP secret exists in flight or at rest; key rotation works.

## Assessment (build + security)
- Why is a MAC-based `<MAC>.cfg` URL on an unauthenticated HTTP server a fleet-wide credential leak,
  and which two controls together stop enumeration *and* cross-device fetch?
- What does encrypting configs at rest protect that HTTPS-in-flight does not?
- How can a compromised redirection/RPS account defeat an otherwise hardened provisioning server,
  and how do you detect it?
