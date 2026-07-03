# Lab BF4 — Secure Auto-Provisioning

**Module:** [M14](../../../course/modules/14-defense-hardening-fraud.md). Feedback-derived
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

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` signing + hardened server PASS | — | required |
| mTLS enforced (no-cert refused) | 25 | capture |
| MAC allowlist + per-device scope | 25 | 403 on spoofed MAC |
| signed configs (tamper rejected) | 30 | sign/verify demo |
| no plaintext provisioning, secrets server-side | 20 | config review |
