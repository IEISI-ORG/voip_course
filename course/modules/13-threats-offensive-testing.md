# Module 13 — VoIP Threats & Offensive Testing (Authorized)

**One-liner:** Think like an attacker — run a disciplined, authorized red-team assessment against
your own platform. **Est. time:** 5h · **Prereqs:** Modules 1–12.

> **Authorized-use rule (restated every lab):** all offensive tooling in this module targets
> ONLY the VoIPSec lab on the `edge`/`redteam` networks. Testing systems you do not own or lack
> written authorization for is illegal. This module teaches defense through understanding attacks.

## Learning Objectives
- Conduct a structured VoIP security assessment (recon → enumeration → exploitation → impact).
- Use SIPVicious, SIPp, and fuzzers to demonstrate real weaknesses.
- Produce findings that drive the Module 14 hardening.

## 1. Concept
- **Methodology:** scoping & authorization → reconnaissance → enumeration → credential attacks →
  service/DoS testing → media attacks → fuzzing → reporting. Mirrors PTES/OWASP adapted to SIP.
- **Threat taxonomy (from `../notes.md §2`):** scanning (T1), enumeration (T2), brute force (T3),
  toll fraud (T4), eavesdropping (T5), MITM (T6), spoofing (T7), DoS/flood (T8), RTP injection
  (T9), fuzzing/parser crashes (T10), secret leakage (T11), trunk abuse (T12), feature abuse
  (T13), recording exposure (T14), provisioning abuse (T15).
- **Tooling:** SIPVicious OSS (`svmap` discovery, `svwar` extension war-dialing, `svcrack`
  password cracking), `sipsak` probes, SIPp custom scenarios (floods, malformed messages),
  simple SIP fuzzers, nmap SIP scripts, RTP injection tools.
- **Real-world context:** how breaches actually happen (default creds, open dialplans, exposed
  5060, weak PINs, IP-only trunks) — attacks map to earlier modules' defenses.

## 2. Packet Reality
- Capture and fingerprint each attack's signature (what svmap/svwar/floods look like on the
  wire and in HOMER) — this is the detection training for M15.

## 3. Build (OSS) — the attacker toolkit
- Configure the `redteam` container; verify network fencing (can reach `edge`, not `core`).
- Baseline scans and scenarios saved as repeatable scripts.

## 4. Attack (authorized, against the lab)
- **Recon/scan (T1):** svmap the edge; fingerprint UAs; find open transports.
- **Enumeration (T2):** svwar valid extensions; observe response deltas (ties to M12 defense).
- **Credential attack (T3):** svcrack a weak secret; then show a strong-secret account resisting.
- **DoS/flood (T8):** SIPp INVITE/REGISTER flood; measure impact with/without `pike`+nftables.
- **Fuzzing (T10):** malformed SIP via SIPp/fuzzer; watch parser behavior; note any instability.
- **Media (T5/T9):** sniff/reconstruct a cleartext call; inject RTP; confirm SRTP defeats it.
- **Toll-fraud path (T4):** with captured creds, attempt premium/international dialing; show the
  M9/M14 guardrails blocking it.

## 5. Labs / Deliverable
- **Lab 13.1:** Full authorized assessment of the lab; produce a findings report (severity,
  evidence pcap, reproduction, mapped defense).
- **Lab 13.2:** For each finding, capture its detection signature for M15.
- *Rubric:* methodology followed; each finding has evidence + a concrete remediation reference;
  authorized-use rules respected; detection signatures captured.

## Assessment (sample)
- Order the assessment phases and state the goal of each.
- Which findings are "config" vs. "protocol" weaknesses, and how does that change the fix?
- Why capture attack signatures during offense, not only during defense?

## Curriculum addition — SIP torture / input-validation fuzzing (review: gemini_feedback0)

Parser robustness is a security property: a single malformed message must never crash or hang
a border element. RFC 4475 gives a standardized adversarial corpus to prove it.
- **Standards:** RFC 4475 (SIP torture test messages); RFC 5118 (SIP-over-IPv6 torture).
- **Build/Attack (authorized lab only):** drive the RFC 4475 message set through SIPp against
  `edge-sbc` and the PBXs; extend with mutation fuzzing for input-validation coverage.
- **Defend:** confirm `sanity_check` and WAF-style validation drop malformed input with a
  correct 4xx and no crash/leak; regression-test after every config change (threat T10).
- **Lab hook (adds B13+):** run the torture suite, assert zero crashes and well-formed
  rejections, and record parser behaviour as a robustness baseline.

## References
- SIPVicious OSS docs; SIPp scenarios; PTES; OWASP testing concepts; NIST SP 800-115
  (technical assessment); `../notes.md §2` threat catalog.
