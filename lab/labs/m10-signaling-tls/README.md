# Lab M10 — Signaling Security: TLS & SIPS

**Module:** [M10](../../../course/modules/10-signaling-security-tls.md) · **Est.** 5h ·
**Prereqs:** M6–M9.

Goal: encrypt and authenticate the signaling plane with TLS/SIPS, manage the certificates, and
extend it to mutual TLS on trunks. SIP TLS is **hop-by-hop** (each proxy re-originates).

## Auto-graded core
```bash
bash labs/m10-signaling-tls/verify.sh        # TLS handshake + SIP transaction over :5061
bash labs/m10-signaling-tls/tls-check.sh     # cert subject/expiry + live handshake
```
Fail-closed: proves SIP-over-TLS works on the SBC. Base image ships a self-signed cert; replace
with a real ACME/private-CA cert in this lab.

## Lab 10.1 — TLS-only registration  (30 pts)
Configure Asterisk + Kamailio to require TLS for registration; **disable/refuse** plain UDP/TCP
for those users. Capture a UDP REGISTER being refused and a TLS REGISTER succeeding.

**Deliverable:** capture showing UDP refused + TLS accepted; the transport config diff.

## Lab 10.2 — Decrypt SIP-TLS (teaching)  (25 pts)
With the **server private key** (and a keylog where needed), decrypt a captured SIP-TLS session
in Wireshark and read the signaling. Explain why hop-by-hop TLS means the proxy sees cleartext.

**Deliverable:** decrypted SIP shown + a note on the hop-by-hop trust implication.

## Lab 10.3 (security) — mTLS trunk + cert-expiry alert  (45 pts)
- Establish **mutual TLS** on the trunk; prove a peer **without a valid client cert is rejected**
  (capture the handshake failure).
- Add a **cert-expiry alert** to Prometheus (ssl_exporter / blackbox_exporter):
  alert when `probe_ssl_earliest_cert_expiry - time() < 30d`. Use `tls-check.sh` to see the
  current days-to-expiry.

**Deliverable:** mTLS reject capture + the Prometheus alert rule firing on a short-lived cert.

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` SIP-over-TLS PASS | — | required |
| 10.1 TLS-only enforced | 30 | capture + config |
| 10.2 decryption demonstrated | 25 | capture |
| 10.3 mTLS reject + expiry alert | 45 | capture + alert rule |

> Cert hygiene → your living hardening checklist: TLS 1.2+ only, strong ciphers, cert
> validation on, mTLS on trunks, automated renewal + expiry alerting.
