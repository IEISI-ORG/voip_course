---
marp: true
theme: default
paginate: true
title: Module 13 — Authentication, Authorization & Caller Identity
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Module 13 — AuthN, AuthZ & Caller Identity

**Prove who a party is — at registration, at call setup, and across the PSTN with STIR/SHAKEN.**

`Est. 6h` · Prereqs: Modules 6–11 · **Checkpoint exam #2 after this module**

<!--
Speaker: This module answers "who are you, really?" at three levels: your subscriber (digest),
what they may do (authZ), and cross-operator trust (STIR/SHAKEN). It's the identity capstone of the
security block and gates checkpoint #2. Keep separating authN (who) from authZ (allowed to).
-->

---

## What you'll leave with

- Implement **SIP digest authentication** and authorization policy correctly.
- Deploy **STIR/SHAKEN** (sign + verify) with libstirshaken / Asterisk / OpenSIPS.
- Defend against **enumeration, brute force, caller-ID spoofing**.

<!--
Speaker: Exam themes: digest ≠ confidentiality (needs TLS), the PASSporT lifecycle + what
attestation A asserts, and two response changes that stop enumeration. Flag all three now.
-->

---

## SIP digest authentication

- **401/407 challenge:** realm, nonce, `qop`, response hash.
- **MD5 (legacy) vs. SHA-256** (RFC 8760); `Authorization` / `Proxy-Authorization`.
- Challenge where it matters: **REGISTER and INVITE**.
- **Digest ≠ confidentiality** — it proves knowledge of a secret; it does **not** encrypt.

<!--
Speaker: The one everyone must internalise: digest authenticates but does NOT hide anything — the
call is still plaintext without TLS. That's the checkpoint question. Use SHA-256 (RFC 8760); MD5 is
legacy. Challenge INVITE too, not just REGISTER, or an attacker skips registration.
-->

---

## Authentication vs. authorization

- **AuthN** = who you are (digest proves the subscriber).
- **AuthZ** = what that identity is *allowed* to do: class-of-service, destination restrictions,
  time-of-day, concurrent-call caps.
- Separate them — a valid user is not an unlimited user.

<!--
Speaker: A compromised-but-authenticated extension should still not be able to dial premium
international at 3am. That's authZ, and it's your toll-fraud backstop (ties to M9/M15). Authenticating
someone is only half the job — bound what they can do.
-->

---

## Caller identity in SIP (and why it's weak)

- **From** vs. **P-Asserted-Identity** (RFC 3325), P-Preferred, **Privacy** (RFC 3323), CNAM/eCNAM.
- **None of these are cryptographically trustworthy alone.**
- The robocall/spoofing problem is exactly this gap at PSTN scale.

<!--
Speaker: This is the motivation for STIR/SHAKEN. From and PAI are just headers a caller sets — trust
them from outside your network and you've enabled caller-ID spoofing (T7). CNAM is a lookup, not
proof. The base protocol never solved identity between operators; STIR/SHAKEN does.
-->

---

## STIR: signing the caller

- **PASSporT (RFC 8225):** a signed JWT over calling/called numbers + **attestation**.
- **`Identity` header (RFC 8224)** carries it; **certs (RFC 8226)** + the SPC/STI-CA trust chain.
- Attestation **A** = "I authenticate this subscriber **and** they're authorized to use this number."

<!--
Speaker: STIR is the cryptographic object — a signed token binding the caller to the calling number.
Attestation A is full attestation (you know the customer AND their right to the number); B = known
customer, unverified number; C = just passed it through. The exam asks what A asserts — this slide.
-->

---

## SHAKEN: the deployment framework

- **Authentication service** (originating) signs; **verification service** (terminating) checks.
- Attestation levels **A / B / C**; `verstat` result surfaced to the callee.
- Enterprise gaps: **delegate certificates** (RFC 9060), Rich Call Data, out-of-band STIR.

<!--
Speaker: STIR is the token; SHAKEN is how carriers actually deploy it — sign on the way out, verify on
the way in, act on the result. The "attestation gap" is real: enterprises with their own numbers need
delegate certs to get full attestation. `verstat` is what a downstream network/handset shows the user.
-->

---

## Digest proves your subscriber; STIR/SHAKEN conveys trust between operators

- Digest = **your** customer to **you**.
- STIR/SHAKEN = trust **across** operator boundaries.
- **Interplay:** you authenticate locally, then attest outward.

<!--
Speaker: The mental model to leave them with: two different identity problems at two different scopes.
Don't conflate them — digest can't help a terminating carrier trust a call from another network, and
STIR/SHAKEN doesn't replace authenticating your own subscribers.
-->

---

## Packet reality

- Read a **401/407 digest** round-trip; identify realm/nonce/qop/response.
- Read a **signed INVITE:** decode the `Identity` header, the PASSporT header/payload/signature,
  the attestation level; trace a verification **success and failure**.

<!--
Speaker: Decoding a real PASSporT (it's a JWT — base64url header.payload.signature) makes STIR
concrete rather than magic. Trace both a pass and a fail (missing/bad Identity) so they see what
verification actually decides. The digest round-trip sets up the enumeration/brute-force defense.
-->

---

## Attack / Defend

- **Enumeration (T2):** 401 vs. 404 vs. 403 + timing deltas leak valid users → **uniform responses,
  randomized delay, fail2ban**; don't leak in error bodies.
- **Brute force (T3):** svcrack → strong-secret policy, lockout/backoff, TLS, monitor auth failures.
- **Caller-ID spoofing (T7):** untrusted From/PAI → **verify STIR/SHAKEN, gate by attestation**;
  never display unverified CNAM as trusted.
- **Downgrade:** issue a **dual-algorithm** challenge (MD5 + SHA-256); **reject algorithm downgrade**.

<!--
Speaker: Enumeration is an information leak — the fix is to make valid and invalid users look
identical (same response, same timing). Brute force needs lockout + strong secrets. For transit: strip
untrusted inbound Identity, verify-then-reattest, apply attestation C when you can't verify. The
dual-algo challenge lets mixed fleets upgrade without a downgrade hole.
-->

---

## Labs

- **Lab 13.1** — Enforce **SHA-256 digest** on REGISTER+INVITE; capture + annotate the challenge.
- **Lab 13.2 (identity)** — **Sign + verify** STIR/SHAKEN in the lab CA; decode a PASSporT; branch on attestation.
- **Lab 13.3 (attack→defend)** — Authorized `svwar`/`svcrack`; uniform responses + fail2ban + lockout
  defeat enumeration/brute force.

*Rubric:* strong digest · working sign/verify + attestation logic · enumeration & brute force mitigated.

<!--
Speaker: 13.2 stands up a real STI-CA in the lab so they sign and verify end to end — the only way
STIR/SHAKEN stops being abstract. 13.3 is the satisfying attack→defend: run the enumeration, then watch
uniform responses + fail2ban shut it down. This is checkpoint-#2 rehearsal.
-->

---

## Takeaways & quick check

- **Digest authenticates, it does not encrypt** — pair with TLS.
- **AuthN ≠ AuthZ** — bound what a valid identity may do (toll-fraud backstop).
- **STIR/SHAKEN** conveys trust *between* operators; act on attestation.

**Check:** Why doesn't digest give confidentiality? What does attestation A assert? What stops enumeration?

<!--
Speaker: Answers — digest only proves knowledge of a secret via a hash; it needs TLS for
confidentiality. PASSporT: originating auth service signs a JWT over the numbers + attestation, carried
in the Identity header, verified by the terminating service against the STI-CA chain; A asserts the
signer authenticated the subscriber and their right to the number. Enumeration fixes: identical
responses for valid/invalid users + randomized/constant timing, so neither status code nor latency
leaks existence. That's checkpoint #2 — then Module 14: provisioning & device configuration security.
-->
