# Lab BF6 — SIP Digest Interop (RFC 8760): dual challenge + downgrade rejection

**Module:** [M12](../../../course/modules/12-authn-authz-identity.md). Feedback-derived
(gemini_feedback0). Threat: registration/credential attacks + algorithm downgrade (T3).

Goal: authenticate a mixed fleet by challenging with **both SHA-256 and MD5** (RFC 8760), while
**rejecting downgrade** — a response must not use a weaker algorithm than the strongest offered.

## Auto-graded core
```bash
bash labs/bf6-digest-interop/verify.sh
bash labs/bf6-digest-interop/digest-interop.sh compute SHA-256
bash labs/bf6-digest-interop/digest-interop.sh downgrade-check "SHA-256,MD5" MD5   # -> reject
```
Deterministic: MD5 vs SHA-256 responses differ and are reproducible, and the downgrade policy
accepts the strongest and rejects a weaker choice.

## Concept
- Digest math (RFC 7616) is identical across algorithms — only the hash changes:
  `HA1=H(user:realm:pass)`, `HA2=H(method:uri)`, `response=H(HA1:nonce:nc:cnonce:qop:HA2)`.
- **Dual challenge:** the server sends two `WWW-Authenticate` headers (SHA-256 preferred, MD5
  fallback). Modern clients answer SHA-256; legacy answer MD5.
- **Downgrade attack:** a MITM strips the SHA-256 challenge so the client answers MD5. Defense:
  the server remembers what it offered and **rejects** a weaker-than-strongest response.

## Build (M12 integration)
- Asterisk/Kamailio: enable SHA-256 digest (RFC 8760) alongside MD5 for transition; configure the
  auth policy to **prefer strongest** and reject a downgraded response.
- Capture a `401` with both challenges and the client's `Authorization` (note `algorithm=`).

## Security notes
- Offer MD5 only while you still have legacy devices; remove it once the fleet is upgraded.
- Digest protects the password but not the message — pair with TLS (M10) and SRTP (M11).
- A downgrade that succeeds means an MD5-only crack path; the policy check is the real control.

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` interop + downgrade PASS | — | required |
| dual challenge issued (401, both algs) | 30 | capture |
| modern client selects SHA-256 | 25 | capture |
| downgrade to MD5 rejected under policy | 45 | capture + config |
