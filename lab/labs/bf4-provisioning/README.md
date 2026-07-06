# Lab BF4 — Secure Auto-Provisioning

**Module:** [M14](../../../course/modules/14-provisioning-security.md). Feedback-derived
(gemini_feedback1). Threat: insecure provisioning (T15) leaking credentials (T11).

Goal: serve device configs securely — HTTPS + **mutual TLS**, a **MAC allowlist**, per-device
scoping, and **signed configs** — replacing plaintext TFTP/HTTP provisioning.

## Auto-graded core
```bash
bash labs/bf4-provisioning/verify.sh          # signing round-trip + hardened server (offline)
bash labs/bf4-provisioning/sign-config.sh demo
```
Deterministic: a signed config verifies, a tampered one is rejected, and the nginx config enforces
mTLS + allowlist + per-device (CN==MAC) scoping over HTTPS-only.

## Build
1. **HTTPS + mTLS** — deploy [`nginx-provisioning.conf`](nginx-provisioning.conf): `ssl_verify_client
   on` with a device CA; no client cert ⇒ handshake refused.
2. **MAC allowlist + per-device scope** — only allowlisted MACs, and a device may fetch **only its
   own** `<MAC>.cfg` (client-cert CN must equal the requested MAC).
3. **Signed configs** — sign each config (`sign-config.sh sign <cfg> <key>`); the phone verifies
   the signature and rejects tampered configs.
4. Inject secrets server-side; never store real passwords in the served file
   ([`AABBCCDDEEFF.cfg`](AABBCCDDEEFF.cfg) uses a placeholder).

## Prove the attacks fail
- Unauthenticated fetch (no client cert) → TLS handshake refused.
- Valid device, spoofed MAC (fetch another device's config) → 403 (CN≠MAC).
- Tampered config → signature invalid → device rejects it.

## Config confidentiality — "config in the clear" is the hole (H2)
mTLS + signing protect the config **in transit** and **against tampering**, but a signed config is
still **plaintext** — anyone who reads the store, a backup, or a mis-served copy gets the SIP
credentials. Close it by **encrypting the config at rest** (encrypt-then-sign):
```bash
bash encrypt-config.sh demo                          # plaintext leaks the secret; ciphertext doesn't
bash encrypt-config.sh encrypt device.cfg key.bin device.cfg.enc
bash encrypt-config.sh rotate device.cfg.enc oldkey newkey   # re-key; plaintext never hits disk
```
`verify.sh` proves the encrypted config doesn't leak the secret, decrypts round-trip, and rejects a
tampered ciphertext (AES-256-CBC/PBKDF2 for confidentiality; pair with the RSA signature for
integrity). Rotate keys on a schedule and on any suspected exposure.

## This lab matches industry guidance (not hypothetical)
The **Comms Council UK** code *Recommendations for Device Provisioning Security*
([bib §11b](../../../course/references/bibliography.md)) states exactly what this lab enforces:
authenticate provisioning over **HTTPS with factory-installed client certificates**, **never** use
TFTP/HTTP/FTP/unencrypted transports, and **delete SIP passwords** from the server once provisioned.

Shipping products implement the same pattern — vendor docs (lower authority, concrete examples):
- **Yealink RPS** (Redirection & Provisioning Service): configs are served over **HTTPS** and a device
  only receives them if its **MAC is enrolled** to the reseller's authenticated account — the same
  "TLS + MAC-bound + authenticated fetch" pattern this lab enforces.
- **Crexendo firewall guidance:** don't blanket-open SIP — **allowlist the provider's specific
  signalling/media IPs+ports**, put phones on a **dedicated voice VLAN**, and disable **SIP ALG** on
  edge routers (it rewrites SIP and breaks TLS/topology hiding). Network-side complement to M8.

> Vendor documentation is the lowest-authority source class (below standards and peer-reviewed work);
> used here only for concrete, vendor-neutral configuration practice.

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` signing + hardened server PASS | — | required |
| mTLS enforced (no-cert refused) | 25 | capture |
| MAC allowlist + per-device scope | 25 | 403 on spoofed MAC |
| signed configs (tamper rejected) | 30 | sign/verify demo |
| no plaintext provisioning, secrets server-side | 20 | config review |
