# Lab BF5 — Transit STIR/SHAKEN (attestation C, header stripping, OOB)

**Module:** [M12](../../../course/modules/12-authn-authz-identity.md). Feedback-derived
(gemini_feedback1). Threat: caller-ID spoofing / laundered identity (T7).

Goal: handle STIR/SHAKEN as a **transit/gateway** carrier — strip untrusted `Identity`, apply
attestation **C** when the originator can't be verified, and use **Out-of-Band SHAKEN** (RFC 8816)
for TDM/SS7 hops.

## Auto-graded core
```bash
bash labs/bf5-transit-shaken/verify.sh          # policy decisions across scenarios (offline)
bash labs/bf5-transit-shaken/shaken-policy.sh --own no --trusted-upstream no --identity valid
```
Deterministic: the policy tool strips unverifiable inbound Identity, chooses A/B/C correctly, and
flags OOB for TDM/SS7.

## Policy (encoded in `shaken-policy.sh`)
| Situation | Strip inbound Identity | Attestation | OOB |
|-----------|------------------------|-------------|-----|
| Untrusted upstream, Identity present | **yes** | C | — |
| Trusted peer, invalid Identity | **yes** | per below | — |
| Own the number + authenticated originator | no | **A** | — |
| Known customer, not the number | no | **B** | — |
| Cannot verify originator (gateway) | — | **C** | — |
| Next hop is TDM/SS7 | — | — | **yes** (RFC 8816) |

## Build (M12 integration)
- Kamailio/Asterisk STIR/SHAKEN: on ingress, **remove** any `Identity` from an untrusted or
  unverified source before routing (don't pass forged identity downstream).
- On egress where you sign, apply the attestation from the policy above; sign with the SHAKEN
  cert (RFC 8226 TNAuthList).
- For TDM/SS7 egress, publish the PASSporT to the OOB call-placement service; the terminating
  provider retrieves it (RFC 8816).

## Security notes
- **Never** relay an unverified `Identity` — that launders a spoofer's claim into a trusted one.
- Attestation **C** is honest signalling ("passed through me, origin unverified"), not a failure.
- Verify inbound signatures against the `x5u` chain and TN scope before trusting (see M12
  `passport-decode.sh`).

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` policy decisions PASS | — | required |
| untrusted Identity stripped on ingress | 30 | capture |
| correct attestation (A/B/C) on egress | 35 | capture + policy |
| OOB SHAKEN for a TDM/SS7 hop | 35 | CPS publish/retrieve |
