# Module 9 — SIP Trunking & the PSTN

**One-liner:** Connect your platform to the outside world (ITSPs/PSTN) securely and reliably.
**Est. time:** 5h · **Prereqs:** Modules 6–8.

## Learning Objectives
- Configure SIP trunks (registration and static/IP modes) to an ITSP/peer.
- Understand PSTN interworking: call flows, early media, DTMF, SIP-T/SIP-I, ISUP mapping.
- Secure trunks against spoofed peers, abuse, and interception.

## 1. Concept
- **SIP trunks:** what replaces TDM; trunk vs. extension registration; static/IP-auth vs.
  registration mode; DID mapping, number formats (E.164), CLI/CLIP.
- **PSTN interworking:** SIP↔PSTN call flows, gateways, early media & early/delayed offer,
  ringback, call-failure mapping (SIP↔Q.850 cause codes).
- **SIP-T / SIP-I:** ISUP encapsulation across a SIP core; SS7/ISDN↔SIP message and cause mapping;
  when carriers require it.
- **DTMF across trunks:** RFC 4733 vs. inband vs. SIP INFO; negotiation pitfalls.
- **Trunk topologies:** single/multi-site, converged, central vs. multiple SBCs, least-cost
  routing, number consolidation, disaster recovery/failover, trunk bursting/elastic SIP.
- **Choosing/validating an ITSP:** interop checklist, SIPconnect profile, what to test.

## 2. Packet Reality
- Trace an outbound PSTN call and an inbound DID; map SIP responses to Q.850 causes.
- Observe DTMF negotiation mismatch (why IVR digits fail) and its fix.

## 3. Build (OSS)
- Asterisk PJSIP trunk to a simulated ITSP (`trunk-sim` = SIPp/Asterisk peer); inbound + outbound.
- Kamailio edge routing to the trunk with dispatcher failover and LCR-style selection.
- DTMF interop matrix across two endpoints/trunk.

## 4. Attack / Defend
- **Spoofed-peer / trunk abuse (T12):** IP-auth-only trunks are forgeable → require IP + TLS +
  (where possible) digest; pin peer certs; topology hiding toward the carrier.
- **Toll fraud via trunk (T4):** an open outbound path is the classic loss event → destination
  allowlists, per-account spend/velocity limits, block premium/high-risk ranges, alerting (M15/M16).
- **Interception on the trunk (T6):** carrier links may be untrusted → TLS/SIPS + SRTP toward
  the ITSP where supported; IPsec/WireGuard overlay when not. Budget for the crypto cost: a test-bed
  study (Kolahi et al., IEEE ICUFN 2017 — [bib §11](../references/bibliography.md)) measured **higher
  CPU usage and added delay** with IPsec on VoIP (throughput ~unchanged; RTT/jitter inconsistent).
  It's a real tradeoff, not free — size the SBC/gateway for it, which is also why per-hop TLS+SRTP is
  often preferred over a blanket IPsec tunnel.
- **CLI/caller-ID spoofing inbound (T7):** don't trust From/PAI from the PSTN; verify via
  STIR/SHAKEN (M13) where available.
- Update threat model with trunk/PSTN vectors.

## 5. Labs
- **Lab 9.1:** Bring up bidirectional trunking to `trunk-sim`; complete inbound DID + outbound PSTN.
- **Lab 9.2:** Map five SIP failure responses to Q.850 causes from captures.
- **Lab 9.3 (security):** Convert an IP-only trunk to TLS + auth; prove a spoofed source is
  rejected; add an outbound destination allowlist + spend limit and trigger the alert.
- *Rubric:* working two-way trunk; correct cause mapping; hardened trunk with fraud guardrails.

## Assessment (sample)
- Registration vs. static trunk mode: security and operational trade-offs?
- Why is IP-only trunk authentication insufficient, and what do you add?
- Which single control most reduces toll-fraud blast radius, and why?

## Curriculum addition — Emergency calling & regulatory compliance (review: gemini_feedback0)

Emergency calls are a legal obligation with their own security/integrity requirements
(accurate location, tamper-resistant priority). US law makes this concrete.
- **Standards/regulation:** Kari's Law (direct 911 dial + on-site notification), RAY BAUM'S
  Act (dispatchable location); PIDF-LO location object (RFC 4119; geo shapes RFC 5491;
  civic/geo RFC 4776 superseding 3825); `Resource-Priority` header (RFC 4412); NENA i3/NG911.
- **Build:** dialplan that routes `911`/direct-dial without a prefix and fires a notification;
  attach a PIDF-LO body carrying dispatchable location; mark priority calls with
  `Resource-Priority` for preferential routing across the trunk.
- **Attack/Defend:** spoofed or stripped location metadata; ensure the SBC does not remove the
  PIDF-LO body and that priority marking cannot be forged by untrusted peers.
- **Lab hook (adds B9+):** place a simulated 911 call carrying PIDF-LO, verify location
  delivery and `Resource-Priority` marking end-to-end. Forward-linked from M18 (NG911).

## References
- RFC 3398 (ISUP↔SIP), 3372/3204 (SIP-T/ISUP encap), Q.850; SIPconnect 2.0 profile;
  Asterisk/Kamailio trunk docs; `../notes.md §2` (T4, T12).
- Kolahi et al. (IEEE ICUFN 2017), *Impact of IPSec Security on VoIP in Different Environments* — see
  [bibliography §11](../references/bibliography.md). Evidence for the trunk-crypto overhead tradeoff.
