---
marp: true
theme: default
paginate: true
title: Module 3 — SDP & Media Negotiation
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Module 3 — SDP & Media Negotiation

**How endpoints agree on media with SDP offer/answer — and how that negotiation is abused.**

`Est. 3h` · Prereqs: Module 2

<!--
Speaker: SDP is the small body inside SIP that decides where the audio actually goes. Today's hook:
control the SDP and you control the media path — which is exactly what both an SBC and an attacker
want. Keep tying `c=`/`m=` back to "where does the RTP land?"
-->

---

## What you'll leave with

- Read an **SDP body field-by-field** and trace an offer/answer.
- Explain **hold**, re-INVITE/UPDATE, multiple m-lines, codec/direction negotiation.
- Spot SDP-driven attacks: **media redirection, downgrade, hold abuse**.

<!--
Speaker: The through-line is the RTP 5-tuple: src IP/port, dst IP/port, protocol. Everything in SDP
exists to establish that 5-tuple. If they can derive it from a capture, they've got it.
-->

---

## SDP structure

```
v=0
o=alice 2890 2890 IN IP4 host
s=-  t=0 0
c=IN IP4 198.51.100.10      ← where media goes
m=audio 49170 RTP/AVP 0 8   ← media type, PORT, codecs
a=rtpmap:0 PCMU/8000
a=sendrecv                  ← direction
```

- Key lines: `c=` (connection), `m=` (media + **port**), `a=` (attributes).

<!--
Speaker: Walk the lines but spotlight `c=` and the `m=` port — together they say where RTP lands.
`a=` carries codec (`rtpmap`/`fmtp`), packetisation (`ptime`), DTMF (`telephone-event`), and
direction. Everything else is mostly boilerplate. Have them find these three in a real capture.
-->

---

## Offer / answer (RFC 3264)

- One side **offers** capabilities; the other **answers** with the intersection.
- **Early offer** (in INVITE) vs. **delayed offer** (offer in the 200 OK).
- Codecs: **static vs. dynamic** payload types, `rtpmap` / `fmtp`, `ptime`, DTMF `telephone-event`.

<!--
Speaker: Offer/answer is a negotiation to a common subset — if there's no shared codec, the call
fails (488). Dynamic payload types (96–127) need an `rtpmap` to be meaningful; static ones (0=PCMU,
8=PCMA) don't. DTMF-as-events (RFC 4733) matters later for PCI (M16 recording redaction).
-->

---

## Session changes: hold, re-INVITE, UPDATE

- **Hold:** modern = `a=sendonly` / `a=inactive`; legacy = `c=0.0.0.0`.
- **re-INVITE vs. UPDATE** to change an established session; music-on-hold.
- **Multiple m-lines** (audio + video); BUNDLE overview.

<!--
Speaker: Hold is just a direction flip in SDP — show the attribute change in a capture. The legacy
`c=0.0.0.0` trick still appears in the wild. re-INVITE renegotiates mid-call, which is powerful and,
as we'll see, abusable (re-INVITE floods, T8). BUNDLE (one port for many streams) is a WebRTC-ism —
just name it here.
-->

---

## Direction & address = where RTP goes

- `c=` (address) + `m=` (port) define the **RTP destination**.
- This is the crux of both **NAT traversal** and **media-redirection attacks**.
- Crypto attributes preview: `a=crypto`, `a=fingerprint`, `a=setup` (full treatment M12).

<!--
Speaker: This slide is the pivot of the module. Whoever writes `c=`/`m=` decides where the audio
flows. NAT breaks this (the address inside is wrong from outside — M8), and an attacker rewriting it
steers your media (this module's attack). Same field, two problems. The crypto attrs are the hook
into media security (M12).
-->

---

## Packet reality

- Annotate an **INVITE SDP offer** + the **200 OK answer**; map the resulting **RTP 5-tuple**.
- Capture a **hold/resume** (re-INVITE) and read the direction flip.
- Observe a **codec renegotiation** (re-INVITE changing the `m=` list).

<!--
Speaker: The core exercise: given offer and answer, derive exactly where RTP will flow and which
codec wins. Then watch it change on hold. If they can do this, media troubleshooting (one-way audio,
no audio) becomes mechanical rather than mysterious.
-->

---

## Build (OSS)

- Asterisk `allow=` / `disallow=` — restrict codecs, observe the SDP effect.
- Force **hold / MoH**; capture and explain the SDP deltas.
- **rtpengine** offer/answer rewriting — how an SBC edits `c=` / `m=` (media anchoring).

<!--
Speaker: rtpengine rewriting is the good-guy version of the attack: the SBC deliberately rewrites
`c=`/`m=` so all media flows through it (anchoring). That's what makes the redirect attack in the
lab fail. Same technique, opposite intent — control of the media path.
-->

---

## Attack / Defend

- **Media redirection:** rewrite `c=`/`m=` to steer RTP (eavesdrop/relay) **(T9)** → SBC controls
  media (rtpengine anchoring) + validates source.
- **Security downgrade:** strip `a=crypto` / `fingerprint` to force plaintext RTP → **policy:**
  require SRTP, reject cleartext (M12).
- **Hold/inactive abuse & re-INVITE floods (T8)** → rate-limit re-INVITEs, sanity-check SDP.

<!--
Speaker: Three attacks, all "just edit the SDP." Redirection steers media; downgrade removes crypto;
re-INVITE floods are DoS. The unifying defense is: don't trust endpoint SDP blindly — anchor media
and enforce policy at the SBC. Downgrade only works if you *allow* cleartext, so the fix is a policy
that forbids it.
-->

---

## Labs

- **Lab 3.1** — From a pcap, reconstruct negotiated media (codec, ports, direction) + the RTP 5-tuple.
- **Lab 3.2** — Configure codec policy; prove the SDP reflects it; force a transcode via rtpengine.
- **Lab 3.3 (attack)** — Rewrite an SDP `c=` via a MITM proxy, show RTP going to the wrong host;
  then anchor media in rtpengine and show the attack fails.

*Rubric:* correct media reconstruction · working codec policy · demonstrated redirect + mitigation.

<!--
Speaker: 3.3 is the money lab — they *perform* the redirection (authorized, in-lab) and then defeat
it with anchoring. Seeing RTP land on the wrong host, then seeing anchoring stop it, makes the whole
"control the media path" lesson concrete. Keep both captures for the report.
-->

---

## Takeaways & quick check

- SDP's `c=` + `m=` decide **where RTP goes** — control them or lose the media path.
- **Downgrade works only if policy allows cleartext** — so forbid it.
- Anchor media at the SBC to defeat redirection.

**Check:** Modern vs. legacy hold method? Which SDP fields must an SBC control to prevent
redirection? Why does stripping `a=crypto` succeed unless policy forbids cleartext?

<!--
Speaker: Answers — modern hold = `a=sendonly/inactive`, legacy = `c=0.0.0.0`; the SBC must control
`c=` and the `m=` port (and anchor via rtpengine); stripping `a=crypto` downgrades to plain RTP
unless an SRTP-only policy rejects the cleartext offer. Next module: RTP itself — what flows once
SDP has decided where.
-->
