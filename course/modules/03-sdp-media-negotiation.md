# Module 3 — SDP & Media Negotiation

**One-liner:** How endpoints agree on media with SDP offer/answer, and how that negotiation is
abused. **Est. time:** 3h · **Prereqs:** Module 2.

## Learning Objectives
- Read an SDP body field-by-field and trace an offer/answer exchange.
- Explain hold, re-INVITE/UPDATE, multiple m-lines, and codec/direction negotiation.
- Identify SDP-driven attacks (media redirection, downgrade, hold abuse).

## 1. Concept
- **SDP structure:** `v= o= s= c= t= m= a=` lines; media descriptions (`m=audio/video`),
  connection (`c=`), attributes (`a=rtpmap/fmtp/ptime/sendrecv/recvonly/inactive/sendonly`).
- **Offer/answer model (RFC 3264):** who offers, who answers, delayed vs. early offer.
- **Codec negotiation:** payload types (static vs. dynamic), `rtpmap`/`fmtp`, ptime, DTMF
  (`telephone-event`).
- **Session changes:** hold (`sendonly`/`inactive`, old `c=0.0.0.0` method), re-INVITE vs.
  UPDATE, music-on-hold, multiple m-lines (audio+video), BUNDLE overview.
- **Direction & address:** how `c=` + `m=` port define where RTP goes — the crux of NAT and
  of media redirection attacks.
- Crypto attributes preview (`a=crypto`, `a=fingerprint`, `a=setup`) — full treatment in M11.

## 2. Packet Reality
- Annotate an INVITE SDP offer and the 200 OK answer; map the resulting RTP 5-tuple.
- Capture a hold/resume (re-INVITE) and read the direction attribute flip.
- Observe a codec renegotiation (re-INVITE changing `m=` list).

## 3. Build (OSS)
- Restrict/allow codecs in Asterisk (`allow=`/`disallow=`) and observe SDP effect.
- Force hold/MoH; capture and explain the SDP deltas.
- rtpengine offer/answer rewriting preview (how an SBC edits `c=`/`m=`).

## 4. Attack / Defend
- **Media redirection:** attacker rewrites `c=`/`m=` to steer RTP (eavesdrop/relay) → why the
  SBC must control media (rtpengine anchoring) and validate source (T9).
- **Codec/security downgrade:** stripping `a=crypto`/`fingerprint` to force plaintext RTP → the
  defense is policy: require SRTP, reject cleartext (M11).
- **Hold/inactive abuse & re-INVITE floods** (T8) → rate-limit re-INVITEs, sanity-check SDP.
- Update the living threat model with SDP vectors.

## 5. Labs
- **Lab 3.1:** From a pcap, reconstruct the negotiated media (codec, ports, direction) and the RTP 5-tuple.
- **Lab 3.2:** Configure codec policy; prove the SDP reflects it; force a transcode via rtpengine.
- **Lab 3.3 (attack):** In the lab, rewrite an SDP `c=` line via a MITM proxy and show RTP going
  to the wrong host; then anchor media in rtpengine and show the attack fails.
- *Rubric:* correct media reconstruction; working codec policy; demonstrated redirect + mitigation.

## Assessment (sample)
- How is a call put on hold in the modern vs. legacy SDP method?
- Which SDP fields must an SBC control to prevent media redirection?
- Why does stripping `a=crypto` succeed unless policy forbids cleartext?

## References
- RFC 4566 (SDP), 3264 (offer/answer), 3311 (UPDATE), 6337 (SIP offer/answer clarifications),
  8866 (SDP update), 4568 (SDES crypto), 5888 (BUNDLE/groups).
