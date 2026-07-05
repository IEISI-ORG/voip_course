---
marp: true
theme: default
paginate: true
title: Module 3 — SDP & Media Negotiation
---

# Module 3 — SDP & Media Negotiation

How endpoints agree on media with SDP offer/answer, and how that negotiation is abused.

<!-- Instructor: set the scene; ~30 min. Every module ends with a hands-on lab + fail-closed verify.sh. -->
---

## Learning Objectives

- Read an SDP body field-by-field and trace an offer/answer exchange.
- Explain hold, re-INVITE/UPDATE, multiple m-lines, and codec/direction negotiation.
- Identify SDP-driven attacks (media redirection, downgrade, hold abuse).

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 1. Concept

- **SDP structure:** `v= o= s= c= t= m= a=` lines; media descriptions (`m=audio/video`),
- **Offer/answer model (RFC 3264):** who offers, who answers, delayed vs. early offer.
- **Codec negotiation:** payload types (static vs. dynamic), `rtpmap`/`fmtp`, ptime, DTMF
- **Session changes:** hold (`sendonly`/`inactive`, old `c=0.0.0.0` method), re-INVITE vs.
- **Direction & address:** how `c=` + `m=` port define where RTP goes — the crux of NAT and
- Crypto attributes preview (`a=crypto`, `a=fingerprint`, `a=setup`) — full treatment in M12.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 2. Packet Reality

- Annotate an INVITE SDP offer and the 200 OK answer; map the resulting RTP 5-tuple.
- Capture a hold/resume (re-INVITE) and read the direction attribute flip.
- Observe a codec renegotiation (re-INVITE changing `m=` list).

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 3. Build (OSS)

- Restrict/allow codecs in Asterisk (`allow=`/`disallow=`) and observe SDP effect.
- Force hold/MoH; capture and explain the SDP deltas.
- rtpengine offer/answer rewriting preview (how an SBC edits `c=`/`m=`).

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 4. Attack / Defend

- **Media redirection:** attacker rewrites `c=`/`m=` to steer RTP (eavesdrop/relay) → why the
- **Codec/security downgrade:** stripping `a=crypto`/`fingerprint` to force plaintext RTP → the
- **Hold/inactive abuse & re-INVITE floods** (T8) → rate-limit re-INVITEs, sanity-check SDP.
- Update the living threat model with SDP vectors.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## 5. Labs

- **Lab 3.1:** From a pcap, reconstruct the negotiated media (codec, ports, direction) and the RTP 5-tuple.
- **Lab 3.2:** Configure codec policy; prove the SDP reflects it; force a transcode via rtpengine.
- **Lab 3.3 (attack):** In the lab, rewrite an SDP `c=` line via a MITM proxy and show RTP going
- *Rubric:* correct media reconstruction; working codec policy; demonstrated redirect + mitigation.

<!-- Speaker note: connect this beat to the module's security takeaway. -->
---

## Lab & assessment

- Hands-on lab with a fail-closed `verify.sh`; rubric 100 pts, pass ≥ 70.
- Update your living threat model + hardening checklist.

<!-- Speaker note: point learners at lab/labs/<module>/. -->
