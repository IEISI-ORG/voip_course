---
marp: true
theme: default
paginate: true
title: Module 8 — NAT, Firewalls & Session Border Control
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Module 8 — NAT, Firewalls & Session Border Control

**Solve the NAT problem correctly and turn the edge into a hardened, flood-resistant border.**

`Est. 5h` · Prereqs: Module 7

<!--
Speaker: NAT is the single most common reason VoIP "doesn't work" — and the edge is where most
attacks land. Two goals: make behind-NAT calls work end to end, and harden the border with nftables +
fail2ban. Keep tying NAT breakage back to the two-plane model from M1/M3.
-->

---

## What you'll leave with

- Explain **NAT types** and why SIP/RTP break through NAT.
- Apply **STUN/TURN/ICE** and server-side NAT handling (Kamailio + rtpengine).
- Build **edge firewalling** (nftables), rate limiting, brute-force jails (fail2ban).

<!--
Speaker: Frame the split: client-side NAT solutions (STUN/TURN/ICE) vs. server-side (rport, symmetric
RTP, rtpengine). Both exist because you can't always control the client. Then harden the edge.
-->

---

## Why VoIP breaks through NAT

- SIP/SDP carry **private addresses** that are meaningless on the public path.
- The **two-plane problem:** signaling Contact/Via **and** media `c=`/`m=` both carry the wrong IP.
- Hairpinning / tromboning make it worse.

<!--
Speaker: The root cause: SIP puts IP addresses *inside* the payload, and NAT only rewrites the packet
headers, not the payload. So the phone advertises 192.168.x.x to the world. It breaks in BOTH planes
independently — fix signaling and you can still have one-way audio (media). That's the M5 one-way
audio fault made mechanical.
-->

---

## NAT types

- Full-cone · restricted · port-restricted · **symmetric**.
- **Mapping vs. filtering** behaviour (RFC 4787 terms).
- **Symmetric NAT defeats classic STUN** — the mapping changes per destination.

<!--
Speaker: The one that matters: symmetric NAT. STUN learns your public mapping toward the STUN server,
but symmetric NAT gives a *different* mapping toward the actual peer — so STUN's answer is useless and
you fall back to a TURN relay. That's the exam question and the reason TURN exists.
-->

---

## Client-side: STUN / TURN / ICE

- **STUN** (RFC 5389/8489): discover your public mapping.
- **TURN** (5766/8656): a **relay** when direct paths fail (symmetric NAT).
- **ICE** (8445): try candidates, pick what works; ICE-Lite / Trickle-ICE; SDP candidate lines.

<!--
Speaker: ICE is the "try everything, use the best" framework — host, server-reflexive (STUN), and
relayed (TURN) candidates, connectivity-checked. WebRTC leans on it heavily (M19). TURN is a relay you
run, which is why hardening it matters (later slide) — an open relay is an amplification/SSRF risk.
-->

---

## Server-side NAT handling

- **`received` / `rport`** (RFC 3581) — correct the source on Via.
- **Symmetric RTP** + NAT keepalives (OPTIONS / CRLF).
- **Kamailio** `nathelper` / `fix_nated_*`; **rtpengine** as the media pin.

<!--
Speaker: Server-side fixes are what you use when you can't fix the client. rport/received tell the
proxy "reply to where it actually came from, not what the packet claims." rtpengine pinning the media
is the media-plane half. Keepalives keep the NAT pinhole open. This is what makes Lab 8.1 work.
-->

---

## Packet reality

- Behind-NAT call: private IPs in **Contact/SDP** vs. what the edge sees; observe **`rport`/`received`
  correction** and **rtpengine media pinning**.
- Observe a **symmetric-NAT failure** and its fix (fall back to relay).

<!--
Speaker: Show the private IP in the payload, then show the corrected path — the "aha" that NAT
handling is rewriting addresses the app-layer got wrong. The symmetric-NAT failure → TURN fallback is
worth staging live; it's abstract until they see the direct path fail.
-->

---

## Build (OSS)

- Kamailio `nathelper` + `fix_nated_contact/sdp`; rtpengine; keepalives.
- Deploy **coturn** (TURN); drive an ICE client (Linphone/WebRTC) through it.
- **nftables** edge ruleset: allow 5061/TLS + RTP range, drop 5060 from untrusted, rate-limit.
- **fail2ban** jail parsing Kamailio/Asterisk logs to ban scanners.

<!--
Speaker: The nftables ruleset is the module's defensive centrepiece — least-privilege at the edge:
only the ports you need, from the sources you trust, at rates you allow. fail2ban turns log evidence
into automated bans (previews the detect→respond arc of M17). coturn setup leads into TURN hardening.
-->

---

## Attack / Defend

- **Scanning & flooding (T1/T8):** svmap sweeps, INVITE/REGISTER floods → nftables rate limits +
  `pike` + fail2ban; drop plaintext **5060** at the edge where policy allows.
- **RTP bleed/injection (T9):** open media ports → rtpengine strict-source, symmetric RTP, **tight
  RTP port range**, SRTP (M12).
- **SIP ALG corruption:** consumer-router "SIP ALG" mangles messages — **disable it**.

<!--
Speaker: "Drop 5060, keep 5061" is a strong default — force TLS and you shrink the attack surface
massively. The counter-intuitive one: cheap-router SIP ALG tries to "help" with NAT and corrupts
SIP instead — often worse than no ALG. Tight RTP ranges limit both injection surface and firewall
holes.
-->

---

## Dual-stack media & TURN hardening

- **IPv6 blind spot:** v4-only firewall rules that **v6 traffic walks straight past** — filter both
  families at parity; watch RA/ND spoofing.
- **coturn hardening:** `use-auth-secret` (short-term creds), **`denied-peer-ip`** (RFC1918 /
  loopback / `core` / `mgmt`), allocation quotas, `no-multicast-peers`, TLS on 5349.

<!--
Speaker: The dual-stack blind spot is a real breach pattern — a perfect v4 ruleset and a wide-open v6
path. An unhardened TURN relay is worse: attackers use it to relay attacks (amplification) or scan
your internal network (SSRF-style). denied-peer-ip pointing at core/mgmt is the key control — the lab
proves redteam can't relay toward core.
-->

---

## Labs

- **Lab 8.1** — Make a behind-NAT call work end to end via Kamailio + rtpengine.
- **Lab 8.2** — Stand up **coturn**; capture ICE connectivity checks succeeding through TURN.
- **Lab 8.3 (defense)** — Author an **nftables** edge ruleset + **fail2ban** jail; run a lab svmap
  scan and show it banned; measure flood mitigation.

*Rubric:* working NAT traversal · TURN relay proven · scanner banned · flood throttled.

<!--
Speaker: 8.3 is the defensive keystone and satisfying: they run an (authorized, in-lab) scan against
their own edge and watch fail2ban lock it out in real time. That scan→ban loop is the first taste of
active defense, extended in M15/M16. All controls roll into the edge hardening checklist.
-->

---

## Takeaways & quick check

- NAT breaks **both planes** — fix signaling *and* media.
- **Least-privilege edge:** only needed ports, trusted sources, bounded rates; prefer 5061/TLS.
- **Filter every address family**; don't run an open TURN relay.

**Check:** Why does symmetric NAT defeat STUN, and what solves it? What do `rport`/`received` fix, and
on which header? Why is consumer "SIP ALG" often worse than none?

<!--
Speaker: Answers — symmetric NAT maps differently per destination so STUN's learned mapping is wrong;
a TURN relay solves it. rport/received correct the reply address on the Via header. Consumer SIP ALG
rewrites SIP payloads incorrectly (breaking Contact/SDP) and often can't be fully disabled — worse
than leaving SIP alone and handling NAT properly server-side. Next: SIP trunking & the PSTN (M9).
-->
