# Module 8 — NAT, Firewalls & Session Border Control

**One-liner:** Solve the NAT problem correctly and turn the edge into a hardened, flood-resistant
border. **Est. time:** 5h · **Prereqs:** Module 7.

## Learning Objectives
- Explain NAT types and why SIP/RTP break through NAT.
- Apply STUN/TURN/ICE and server-side NAT handling (Kamailio + rtpengine).
- Build edge firewalling (nftables), rate limiting, and brute-force jails (fail2ban).

## 1. Concept
- **NAT & why VoIP breaks:** private addresses in SIP/SDP vs. public path; the two-plane problem
  (signaling Contact/Via + media `c=`/`m=`); hairpinning/tromboning.
- **NAT types:** full cone, restricted, port-restricted, symmetric; mapping vs. filtering
  behavior (RFC 4787 terminology); why symmetric NAT defeats classic STUN.
- **Client-side solutions:** STUN (RFC 5389/8489), TURN relay (5766/8656), ICE (8445),
  ICE-Lite/Trickle-ICE; SDP candidate lines.
- **Server-side solutions:** `received`/`rport` (RFC 3581), symmetric RTP, NAT keepalives
  (OPTIONS/CRLF), Kamailio `nathelper`/`fix_nated_*`, rtpengine as the media pin.
- **The SBC as border:** admission control, topology hiding (from M7), protocol repair, and the
  firewall/edge posture — where signaling security policy is enforced.
- **Edge firewalling:** stateful nftables, port strategy (5060/5061/RTP range), geo/allowlists,
  connection rate limits; ALG pitfalls (why SIP ALG on cheap routers is harmful).

## 2. Packet Reality
- Capture a call from behind NAT: private IPs in Contact/SDP vs. what the edge sees; observe
  `rport`/`received` correction and rtpengine media pinning.
- Observe a symmetric-NAT failure and its fix.

## 3. Build (OSS)
- Kamailio `nathelper` + fix_nated_contact/sdp; rtpengine for media; keepalives.
- Deploy `coturn` (TURN) and drive an ICE-capable client (Linphone/WebRTC) through it.
- nftables ruleset for the edge: allow 5061/TLS + RTP range, drop 5060 from untrusted, rate-limit.
- fail2ban jail parsing Kamailio/Asterisk logs to ban scanners.

## 4. Attack / Defend
- **SIP scanning & flooding (T1/T8):** svmap sweeps, INVITE/REGISTER floods → nftables rate
  limits + `pike` + fail2ban; drop plaintext 5060 at the edge where policy allows.
- **RTP bleed/injection (T9):** open media ports → rtpengine strict-source, symmetric RTP,
  tight RTP port range in the firewall, SRTP (M11).
- **NAT keepalive amplification / ALG corruption:** disable upstream SIP ALG; control keepalives.
- Consolidate the **edge hardening checklist**; update threat model with border attacks.

## 5. Labs
- **Lab 8.1:** Make a behind-NAT call work end-to-end (signaling + media) via Kamailio + rtpengine.
- **Lab 8.2:** Stand up coturn; capture ICE connectivity checks succeeding through TURN.
- **Lab 8.3 (defense):** Author an nftables edge ruleset + fail2ban jail; run a (lab) svmap scan
  and show it getting banned; measure flood mitigation.
- *Rubric:* working NAT traversal; TURN relay proven; scanner banned; flood throttled.

## Assessment (sample)
- Why does symmetric NAT defeat STUN, and what solves it?
- What do `rport` and `received` fix, and on which header?
- Why is consumer-router "SIP ALG" often worse than no ALG?

## Curriculum addition — IPv6 media bridging & TURN hardening (review: gemini_feedback1)

**Dual-stack media + stateful IPv6 filtering.**
- **Build:** rtpengine with both v4 and v6 interfaces to bridge media between an IPv4 and an
  IPv6 endpoint; `nftables` `ip6` stateful rules at parity with the v4 ruleset.
- **Attack/Defend:** the classic dual-stack blind spot — v4-only firewall rules that v6 traffic
  walks straight past; also RA/ND spoofing. Verify both address families are filtered.
- **Lab hook (adds BF9):** place an IPv4↔IPv6 call bridged by rtpengine; confirm the `ip6`
  ruleset permits/denies exactly as the v4 one does.

**Coturn / TURN server hardening.**
- **Rationale:** an open or loose TURN relay enables relay abuse, DDoS amplification, and
  SSRF-style scanning of internal networks (threat T8, plus internal reconnaissance).
- **Build:** `coturn` with `use-auth-secret` (short-term REST credentials), `denied-peer-ip`
  covering RFC1918/loopback/link-local and the `core`/`mgmt` subnets, allocation `quota` /
  `total-quota`, `no-multicast-peers`, and TLS on 5349.
- **Attack/Defend:** from `redteam`, request a relay allocation toward a `core` address and
  confirm `denied-peer-ip` blocks it; show short-term credentials expire.
- **Lab hook (adds BF10):** deploy coturn, prove it refuses to relay to internal subnets and
  enforces credential TTL + allocation quotas.

## References
- RFC 4787 (NAT behavior), 3581 (rport), 5389/8489 (STUN), 5766/8656 (TURN), 8445 (ICE),
  5853 (SBC); Kamailio nathelper/rtpengine docs; coturn docs; nftables & fail2ban docs.
