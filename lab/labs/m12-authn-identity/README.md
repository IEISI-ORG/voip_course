# Lab M12 — Authentication, Authorization & Caller Identity

**Module:** [M12](../../../course/modules/12-authn-authz-identity.md) · **Est.** 6h ·
**Prereqs:** M6–M11. **Checkpoint Exam #2 follows this module.**

Goal: prove who a party is — at registration, at call setup, and across the PSTN with
STIR/SHAKEN — and mitigate enumeration and brute force.

## Auto-graded core
```bash
bash labs/m12-authn-identity/verify.sh          # enumeration ban (self-validating) + PASSporT tool
bash labs/m12-authn-identity/passport-decode.sh # decode a SHAKEN PASSporT
```

## Lab 12.1 — Strong digest auth  (30 pts)
Enforce **SHA-256** digest (RFC 8760) on REGISTER + INVITE (Asterisk/Kamailio); reject algorithm
downgrade to MD5. Capture and annotate the `401 WWW-Authenticate` challenge → `Authorization`
round-trip (realm, nonce, qop, algorithm).

**Deliverable:** the annotated challenge/response + config; a downgrade attempt refused.

## Lab 12.2 (identity) — STIR/SHAKEN  (30 pts)
Sign outbound calls and verify inbound STIR/SHAKEN using the lab CA; decode a PASSporT
(`passport-decode.sh`) and **branch call handling on attestation** (A/B/C). Include the RFC 9060
delegate-cert scenario (enterprise self-signs to keep "A").

**Deliverable:** a signed+verified call, the decoded PASSporT claims, and attestation-based
routing (e.g. tag/deprioritize B/C).

## Lab 12.3 (attack → defend) — enumeration & brute force  (40 pts)
Run authorized `svwar` (extension enumeration) and `svcrack` (password) against the lab, then show
the mitigations work:
```bash
bash labs/m12-authn-identity/verify.sh          # svwar -> banned
```
- **uniform responses** (no 401/403/404 delta that leaks valid extensions),
- **fail2ban lockout** + strong secrets,
- confirm `svcrack` gets nowhere against a strong secret + lockout.

**Deliverable:** before/after showing enumeration & brute force defeated (bans, uniform replies).

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` enumeration ban PASS | — | required |
| 12.1 SHA-256 digest + downgrade refused | 30 | capture + config |
| 12.2 STIR/SHAKEN sign/verify + attestation logic | 30 | capture + PASSporT |
| 12.3 enumeration + brute force mitigated | 40 | before/after |

## → Checkpoint Exam #2
[`../../../course/assessments/checkpoint-exam-2.md`](../../../course/assessments/checkpoint-exam-2.md)
(covers M6–M12: build + security).
