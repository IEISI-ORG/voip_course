# Module 1 — VoIP & SIP Foundations

**One-liner:** What VoIP is, where SIP fits, and the attack surface you're signing up to
defend. **Est. time:** 3h · **Prereqs:** Module 0, TCP/IP.

## Learning Objectives
- Explain the VoIP call model (signaling vs. media) and where SIP sits in the stack.
- Identify SIP entities (UAC, UAS, registrar, proxy, redirect, B2BUA) and SIP URIs.
- Map the end-to-end attack surface of a basic VoIP call.

## 1. Concept
- VoIP basics: sampling → encoding → packetization → transport; the two-plane model
  (signaling plane = SIP; media plane = RTP), and why they are separate.
- Where SIP fits: application layer over UDP/TCP/TLS/WS(S); relationship to HTTP heritage.
- SIP entities: User Agents (UAC/UAS), Registrar, Location Service, Proxy (stateful/stateless),
  Redirect server, Back-to-Back UA (B2BUA), SBC.
- Addressing: SIP/SIPS URIs, `user@domain`, contacts, AoR vs. contact, E.164 in SIP.
- Standards landscape: RFC 3261 and the "beyond 3261" family; IETF working groups; why SIP is
  a toolkit of extensions, not a single spec.

## 2. Packet Reality
- Anatomy of a call at 10,000 ft: REGISTER → INVITE → 100/180/200 → ACK → RTP → BYE.
- Observe a full call in Wireshark's "VoIP Calls" + flow sequence; identify each plane.

## 3. Build (OSS)
- Minimal registrar/PBX with Asterisk (`pjsip.conf` endpoint + auth + aor).
- Two clients (Linphone GUI, Baresip CLI) register and call; inspect CLI (`pjsip show endpoints`).

## 4. Attack / Defend
- Attack-surface enumeration as a mindset: what an attacker sees at each hop (open ports,
  UA banners, response codes, media ports).
- Threats introduced here (detailed later): scanning (T1), enumeration (T2), eavesdropping (T5),
  spoofing (T7). Learners start their **living threat model** doc now.

## 5. Labs
- **Lab 1.1:** Register two clients, place a call, annotate the flow (label every message/plane).
- **Lab 1.2:** Passive recon of *your own* PBX with `nmap`/OPTIONS; record the banner/leaked info.
- **Lab 1.3:** Start the living threat model: list assets, entry points, trust boundaries.
- *Rubric:* correct plane labeling; accurate entity identification; first threat model committed.

## Assessment (sample)
- Distinguish AoR from Contact; why does registration bind them?
- Which SIP entity breaks end-to-end signaling identity, and what does that enable?
- Name three pieces of information leaked by a default SIP UA response.

## References
- RFC 3261 (§1–§8), RFC 3263 (locating servers); Asterisk PJSIP config docs; Wireshark VoIP guide.
