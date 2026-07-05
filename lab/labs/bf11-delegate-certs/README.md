# Lab BF11 — STIR/SHAKEN Delegate Certificates (RFC 9060)

**Module:** [M13](../../../course/modules/13-authn-authz-identity.md). Feedback-derived
(gemini_feedback1). Closes the enterprise "attestation gap" (T7).

Goal: let an enterprise sign its **own** PASSporT at attestation **A** using a delegate
certificate chained to a trusted CA, scoped to its telephone numbers.

## Auto-graded core
```bash
bash labs/bf11-delegate-certs/verify.sh
bash labs/bf11-delegate-certs/delegate-ca.sh demo /tmp/bf11
bash labs/bf11-delegate-certs/attest-scope.sh +1-415-555-0142 14155550100-14155550199
```
Self-validating: the delegate cert chains to the SP CA (a rogue self-signed cert does **not**),
and A-attestation is granted only for numbers inside the delegated range.

## Concept
- **Attestation gap:** an enterprise dialing out via a carrier that doesn't own its numbers gets
  stamped B/C — its legitimate calls look less trusted than they should.
- **Delegate cert (RFC 9060):** the number-holder/SP issues the enterprise a cert, chained to a
  trusted CA, whose **TNAuthList** (RFC 8226) scopes it to the enterprise's TNs.
- The enterprise signs its own PASSporT at A; the verifier trusts it because (1) the chain proves
  the delegation and (2) the TNAuthList proves the number is in scope.

## Security notes (the critical checks)
- **Verify the chain to a trusted CA** — a self-signed/rogue cert must fail (`verify.sh` step 2).
- **Enforce TN scope at signing time** — sign A only for numbers the cert authorizes; signing
  outside scope is forgery (`attest-scope.sh`).
- Protect the delegate private key; short cert lifetimes + revocation (OCSP/CRL).

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` chain + scope PASS | — | required |
| delegate cert issued + chains to CA | 30 | openssl verify |
| enterprise signs its own PASSporT at A | 30 | signed call |
| verifier accepts A via the delegation | 25 | verify path |
| out-of-scope number refused A | 15 | scope enforcement |
