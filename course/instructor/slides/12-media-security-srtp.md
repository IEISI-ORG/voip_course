---
marp: true
theme: default
paginate: true
title: Module 12 — Media Security: SRTP, DTLS-SRTP & ZRTP
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Module 12 — Media Security: SRTP, DTLS-SRTP & ZRTP

**Encrypt the media plane and get the key exchange right — "encrypted" vs. "actually private."**

`Est. 5h` · Prereqs: Module 11

<!--
Speaker: M11 closed signaling; this closes media. The twist: encrypting RTP is easy — the security
lives in *how you exchange the key*. Three methods, three trust models. Re-run the M4 eavesdrop attack
against SRTP and watch it fail — that's the emotional payoff of the whole crypto arc.
-->

---

## What you'll leave with

- Configure **SRTP** with **SDES**, **DTLS-SRTP**, and **ZRTP** across the OSS stack.
- Explain the **key-exchange trade-offs** and their attack surfaces.
- Bridge secure/insecure media at the SBC **without silently downgrading**.

<!--
Speaker: The exam trio: why SDES needs TLS (and DTLS doesn't), what ZRTP's SAS adds over DTLS, and
where a downgrade can sneak in at the SBC. Keep "key exchange = the real question" as the spine.
-->

---

## Why encrypt media

- TLS protects **signaling only** — RTP is separately sniffable/recordable (**M4 proved it**).
- **SRTP (RFC 3711)** adds confidentiality + authentication to RTP/RTCP.
- Encrypting one plane and not the other secures **neither** in practice.

<!--
Speaker: Callback hard to M4 — they reconstructed a real conversation from a plaintext capture.
SIPS/TLS did nothing for that. SRTP is the fix. Reinforce the two-plane rule one last time: both
planes or nothing.
-->

---

## Three key-exchange methods

| Method | Keys travel… | Trust model |
|---|---|---|
| **SDES** (4568) | in SDP `a=crypto` | only as safe as the signaling (needs TLS) |
| **DTLS-SRTP** (5763/64) | DTLS handshake in media | keys never in signaling; WebRTC default |
| **ZRTP** (6189) | in-media DH + **SAS** | end-to-end, MITM-resistant, server-agnostic |

<!--
Speaker: This table is the module. SDES puts the key in the SDP — so if signaling is plaintext, the
key is captured (demo it). DTLS-SRTP keys the media in-band, so signaling never sees the key. ZRTP
does an in-media Diffie-Hellman and adds a human-verified Short Authentication String for true E2E
even across untrusted servers. Match method to threat model.
-->

---

## Ciphers & the downgrade risk

- **SRTP profiles:** AES-CM + HMAC-SHA1, or **AES-GCM (AEAD)**; crypto-suite negotiation.
- **SBC bridging:** rtpengine as SRTP↔RTP / DTLS↔SDES gateway.
- **The border is where a security *downgrade* hides** — make policy explicit.

<!--
Speaker: The SBC translating between schemes is necessary (a browser DTLS leg to a legacy SDES/RTP
leg) but dangerous — if it silently accepts cleartext or briefly exposes media at the anchor, you've
lost. AES-GCM is the modern AEAD choice. The lab proves each leg stays encrypted per its own scheme.
-->

---

## Packet reality

- **SDES-SRTP:** note `a=crypto` (and why TLS must wrap it); RTP now unreadable.
- **DTLS-SRTP:** observe the DTLS handshake + `a=fingerprint`; **no keys in SDP**.
- **ZRTP:** observe Hello/Commit/DH and the **SAS**.

<!--
Speaker: Show the key sitting in cleartext in an SDES `a=crypto` line over plaintext signaling — that
image sells "SDES needs TLS." Then DTLS: fingerprint in SDP, actual key in the media handshake.
ZRTP: the SAS the two humans read to each other. Three captures, three trust models made visible.
-->

---

## Build (OSS)

- **Asterisk:** `media_encryption=sdes` then `dtls` on a PJSIP endpoint; certs/fingerprints for DTLS.
- **rtpengine:** bridge `SRTP<->RTP` and `DTLS<->SDES`; **enforce SRTP-only** policy.
- **ZRTP** with Linphone/Baresip end-to-end; verify the **SAS** between two humans.
- **WebRTC bridging:** rtpengine `ICE=force`, `DTLS=passive`, `rtcp-mux` → translate browser DTLS-SRTP
  to the PBX leg without cleartext on the wire.

<!--
Speaker: The SRTP-only policy flag is the crucial one — without it, a stripped-crypto offer downgrades
to plain RTP. WebRTC bridging is the real-world SBC job (M19): a browser's DTLS-SRTP leg translated to
Asterisk's SDES/RTP, each encrypted per its own scheme, never briefly clear at the anchor.
-->

---

## Attack / Defend

- **Eavesdropping (T5):** re-run the M4 audio-reconstruction against SRTP → **fails**.
- **Downgrade:** strip `a=crypto`/`fingerprint` to force cleartext → **require encryption, reject
  non-secure media, alarm on downgrade** at the SBC.
- **SDES-over-plaintext-signaling:** capture the key when SDES runs without TLS → **always pair SDES
  with SIPS**.
- **DTLS fingerprint substitution / MITM:** why **ZRTP's SAS** matters; bind fingerprint to identity.

<!--
Speaker: The through-line: encryption without policy is theatre. Downgrade only works if you allow
cleartext — so forbid it and alarm. SDES key capture is the concrete reason SDES ⇒ TLS. The DTLS MITM
(swap the fingerprint upstream) is what ZRTP's human-verified SAS defeats — no server can forge two
humans reading matching words.
-->

---

## Labs

- **Lab 12.1** — SDES-SRTP (with TLS) end to end; prove media is **unreadable** in capture.
- **Lab 12.2** — DTLS-SRTP (WebRTC-style) via rtpengine; capture the handshake.
- **Lab 12.3 (attack)** — Strip `a=crypto`; show **SRTP-only policy rejects** the call; then show
  **ZRTP SAS** defeating an in-path MITM.

*Rubric:* all three methods working · eavesdrop defeated · downgrade blocked · SAS verified.

<!--
Speaker: 12.3 is the crescendo of the crypto block — they attempt the downgrade and watch policy
reject it, then watch the SAS catch a MITM. Pair 12.1's "media now unreadable" capture with the M4
"media reconstructed" capture for a before/after that lands the whole confidentiality story.
-->

---

## Takeaways & quick check

- **Key exchange is the real question** — SDES (needs TLS), DTLS (WebRTC), ZRTP (E2E + SAS).
- **Downgrade works only if you allow cleartext** — require encryption, alarm at the SBC.
- The **SBC border** is where a silent downgrade hides — make policy explicit.

**Check:** Why is SDES unsafe without TLS but DTLS-SRTP isn't? What does ZRTP's SAS protect against
that DTLS alone may not? Where can a downgrade occur in an SBC-mediated call, and how do you stop it?

<!--
Speaker: Answers — SDES carries the key in SDP, so plaintext signaling leaks it; DTLS keys in the
media path so signaling never holds the key. ZRTP's SAS defeats a MITM that swapped DTLS fingerprints
upstream — humans verify a shared string no attacker can forge. Downgrade hides at the SBC's
scheme-bridging point; prevent with an SRTP-only/require-encryption policy plus a downgrade alarm.
Both planes are now closed — next: AuthN, AuthZ & Caller Identity (M13), checkpoint exam #2.
-->
