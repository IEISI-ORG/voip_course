# Lab BF10 — coturn / TURN Hardening

**Module:** [M8](../../../course/modules/08-nat-firewalls-sbc.md). Feedback-derived
(gemini_feedback1). Threats: open-relay abuse, DDoS amplification (T8), SSRF into internal nets.

Goal: run a TURN server that relays media for NAT'd/WebRTC clients **without** becoming an open
relay or an SSRF pivot.

## Auto-graded core
```bash
bash labs/bf10-coturn/verify.sh
bash labs/bf10-coturn/coturn-audit.sh labs/bf10-coturn/turnserver.conf
bash labs/bf10-coturn/turn-cred.sh gen <secret> 300 alice
```
Self-validating: the audit passes the hardened config and catches a weakened one; short-term
credentials verify, expire, and reject a wrong secret.

## The controls (in `turnserver.conf`)
- **`use-auth-secret`** — time-limited HMAC (TURN REST) credentials, not static passwords. A
  leaked credential self-expires (see `turn-cred.sh`).
- **`denied-peer-ip`** — refuse to relay toward RFC1918 / loopback / link-local / ULA. This is the
  **SSRF fence**: the TURN box must not be steerable at internal targets.
- **`total-quota` / `user-quota`** — cap allocations to blunt amplification/DoS.
- **TLS** (`tls-listening-port`, `cert`/`pkey`) and **`no-cli`** — encrypt and lock the control surface.

## Prove the attacks fail
- Request a relay allocation toward a `core` address (e.g. `172.28.20.21`) → **refused** by
  `denied-peer-ip`.
- Use a credential past its expiry → **rejected**.
- Static-password relay → not possible (no `lt-cred-mech`/`user=`).

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` audit + cred lifecycle PASS | — | required |
| working TURN relay for a NAT'd/WebRTC call | 25 | capture |
| short-term credentials (expire) | 25 | cred demo |
| `denied-peer-ip` blocks an internal relay (SSRF) | 35 | attempt + refusal |
| quotas + TLS + CLI locked | 15 | config review |
