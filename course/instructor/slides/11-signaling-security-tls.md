---
marp: true
theme: default
paginate: true
title: Module 11 — Signaling Security: TLS & SIPS
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Module 11 — Signaling Security: TLS & SIPS

**Encrypt and authenticate the signaling plane with TLS — and manage the certificates.**

`Est. 5h` · Prereqs: Modules 6–9

<!--
Speaker: We start closing the planes we spent nine modules leaving open. This module = signaling
(SIP); next = media (SRTP). The recurring theme: encryption is easy, *certificate management* is the
hard part that actually causes outages. Show plaintext SIP leaking a password, then close it.
-->

---

## What you'll leave with

- Deploy **SIP over TLS (SIPS)** on PBX + SBC, including **mutual TLS** on trunks.
- Manage certificates (public via **Let's Encrypt**, private via **step-ca**) and their lifecycle.
- Detect and prevent signaling **MITM/tampering**.

<!--
Speaker: The exam angles: why hop-by-hop TLS is a trust concern, what breaks when a cert expires, and
how mTLS beats IP auth. Keep certificate *lifecycle* front and centre — issuing is easy, renewing
reliably is where teams fail.
-->

---

## Why encrypt signaling

- Plaintext SIP → **interception, tampering, spoofing, credential capture**.
- TLS gives **confidentiality + integrity + server (optionally mutual) authentication**.
- `sips:` URIs, **port 5061**; transports UDP/TCP/**TLS**/WS/**WSS**.

<!--
Speaker: Motivate with the M2/M5 captures — a plaintext REGISTER hands an attacker the credential and
every header. TLS fixes confidentiality AND integrity AND identity in one move. WSS matters for
browsers (WebRTC slide). Reinforce: 5061 = SIPS, and we prefer to *only* offer it.
-->

---

## Hop-by-hop, not end-to-end

- **SIP TLS is hop-by-hop** — each proxy terminates and re-originates.
- So you **trust every intermediary** on the path.
- Bound the trust: terminate at the edge, **re-originate to core over internal mTLS**.

<!--
Speaker: This is the subtle, examinable point. Unlike end-to-end encryption, SIP TLS protects each
hop but every proxy sees plaintext internally. That's a trust decision you must document — and it's
why the SBC terminates edge TLS then uses *internal mTLS* to the core, keeping the trust boundary
explicit (back to the edge/core split from M0).
-->

---

## TLS essentials for VoIP

- Versions: **require 1.2+, prefer 1.3**; sane cipher policy; SNI; session resumption.
- **Cert chains + SAN matching** to the SIP domain (CN/SAN pitfalls).
- Downgrade defense: **offer only TLS**, drop UDP/TCP at the edge.

<!--
Speaker: Most "TLS but insecure" cases are policy: old TLS versions, weak ciphers, or a cert whose
SAN doesn't match the SIP domain so verification is skipped. The strongest anti-downgrade move is to
simply not offer plaintext transports at the edge — you can't be downgraded to what isn't there.
-->

---

## Certificate management (the hard part)

- **Public** (edge): Let's Encrypt via acme.sh/certbot.
- **Private** (internal mTLS): **step-ca** / OpenSSL CA.
- **Lifecycle:** rotation, revocation, **monitor expiry** (an expired cert = an outage).

<!--
Speaker: Say it plainly: the #1 TLS incident isn't a broken cipher, it's an expired certificate that
took down registration at 2am. Automate renewal (acme.sh) and *alert on expiry* in Prometheus (M17) —
the lab adds exactly that alert. step-ca gives you an internal CA for mTLS without paying per cert.
-->

---

## Mutual TLS on trunks & peering

- Authenticate the **carrier/peer by client certificate** (T12) — strong anti-spoof.
- Far better than **IP auth**: a stolen IP is forgeable; a client cert is not (without the key).
- The SBC verifies the peer cert before accepting the trunk.

<!--
Speaker: Callback to M9's forgeable IP-auth trunk — mTLS is the fix. IP auth trusts a source address
(spoofable); mTLS requires the peer to prove possession of a private key. This is the single biggest
upgrade to trunk trust, and it's Lab 11.3.
-->

---

## Packet reality

- Capture a **TLS handshake** for SIP; with the server key, **decrypt** and read the protected SIP.
- Contrast with **plaintext SIP** showing the credentials/headers an attacker would harvest.

<!--
Speaker: The decrypt-with-key exercise is for teaching (and for your own troubleshooting/lawful
capture) — it also drives home that "TLS" means you must capture pre-encryption or hold the key (M5).
The plaintext-vs-TLS side-by-side is the money shot: same call, one leaks the password, one doesn't.
-->

---

## Build (OSS)

- **Asterisk** `transport` type TLS (cert/key/ca, `verify_client` for mTLS); register over TLS.
- **Kamailio** `tls` module + profiles; TLS listener on 5061; edge-terminate then core-mTLS.
- Edge cert via **acme.sh**; internal certs via **step-ca**; automate renewal + reload.
- **WSS** listener (browsers): Secure WebSocket (RFC 7118) for jsSIP/SIP.js — `wss://` only,
  validate `Origin`, rate-limit upgrades.

<!--
Speaker: Build order: TLS listener → TLS-only enforcement → mTLS on the trunk → automated renewal.
The WSS piece is the browser on-ramp (WebRTC, M12/M19) — the security notes are real: never allow
`ws://`, validate Origin, rate-limit the upgrade (T8) or you've built a new flood surface.
-->

---

## Attack / Defend

- **Signaling MITM/tampering (T6):** read/alter plaintext SIP in lab → TLS defeats it; block downgrade.
- **Cert-management failures:** expired = outage · weak ciphers/old TLS = exposure · **private key
  leak (T11)** → perms, rotation, expiry alerts (M17).
- **Trust pitfalls:** hop-by-hop means trusting every intermediary → mTLS on peer links, document
  the boundary.

<!--
Speaker: Tie it together: the crypto is rarely what fails — operations are. Protect the private key
(T11 again — same lesson as secret hygiene and provisioning), automate renewal, alert on expiry,
enforce modern versions. The threat is as much "self-inflicted outage" as "attacker MITM."
-->

---

## Labs

- **Lab 11.1** — Enforce **TLS-only** registration on Asterisk + Kamailio; prove UDP/TCP refused.
- **Lab 11.2** — **Decrypt** a captured SIP-TLS session with the server key and read it.
- **Lab 11.3 (security)** — **mTLS on the trunk**: a peer without a valid client cert is rejected;
  add a **cert-expiry alert** to Prometheus.

*Rubric:* TLS-only enforced · decryption demonstrated for teaching · working mTLS + expiry alert.

<!--
Speaker: 11.1 (no plaintext accepted) + 11.3 (mTLS + expiry alert) are the keystones. The expiry
alert is the operational-maturity marker — they don't just deploy TLS, they build the thing that
warns them before it breaks. Roll transport policy into the hardening checklist.
-->

---

## Takeaways & quick check

- **Offer only TLS** — you can't be downgraded to what you don't serve.
- **Certificate lifecycle, not ciphers, is what breaks** — automate renewal, alert on expiry.
- **mTLS > IP auth** for peers; hop-by-hop trust must be **bounded and documented**.

**Check:** Why is hop-by-hop SIP TLS a trust concern, and how do you bound it? What breaks if the edge
cert expires, and how do you prevent it? How does mTLS reduce trunk spoofing vs. IP auth?

<!--
Speaker: Answers — hop-by-hop means each proxy sees plaintext, so you trust every intermediary; bound
it by terminating at the edge and using internal mTLS with a documented boundary. An expired edge cert
breaks TLS registration/calls (outage); prevent with automated renewal + expiry alerting. mTLS
requires proof of a private key vs. a spoofable source IP. Next: media security — SRTP/DTLS-SRTP/ZRTP
(M12), closing the other plane.
-->
