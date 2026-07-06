# Lab BF2 — Emergency Calling (PIDF-LO + Resource-Priority)

**Modules:** [M9](../../../course/modules/09-sip-trunking-pstn.md) +
[M19](../../../course/modules/19-frontiers.md) (NG911). Feedback-derived (gemini_feedback0).

Goal: deliver a compliant emergency call — direct 911 dialing with notification (**Kari's Law**),
a **dispatchable location** (**RAY BAUM'S Act**, via PIDF-LO), and **priority** (Resource-Priority).

## Auto-graded core
```bash
bash labs/bf2-emergency/verify.sh          # PIDF-LO well-formed + emergency INVITE construction
bash labs/bf2-emergency/e911-call.sh       # print the constructed emergency INVITE
```
Offline & deterministic: the PIDF-LO parses (with XXE/entity protection) and carries a
dispatchable location; the INVITE carries `Resource-Priority`, a `Geolocation` header, and the
`application/pidf+xml` body.

## Build
1. **Kari's Law dialplan:** `911` (and any `9+911`) routes with **no prefix** and fires an
   on-site **notification** (email/webhook) in parallel.
2. **RAY BAUM'S location:** attach the PIDF-LO ([`pidf-lo-sample.xml`](pidf-lo-sample.xml)) as a
   multipart `application/pidf+xml` body with civic (building/floor/room) + geo.
3. **Priority:** set `Resource-Priority` (e.g. `esnet.1`) so the call is preferentially routed.
4. Route `911` to a PSAP simulator (trunk-sim) and complete the call.

## Security / compliance notes
- The SBC must **not strip** the PIDF-LO or `Geolocation` — a call without location fails RAY
  BAUM'S and endangers the caller.
- `Resource-Priority` must **not be forgeable** by untrusted peers (a spoofed priority is a DoS
  amplification lever) — accept it only from authenticated internal sources.
- Location is sensitive PII: `retransmission-allowed=no`; handle per privacy rules.
- Parse any inbound location XML with an XXE/entity-safe parser (see `verify.sh`).

## NG112-style routing (multi-jurisdiction)
[`emergency-route.sh`](emergency-route.sh) is a deterministic stand-in for an ECRF/LoST
(RFC 5222) location→PSAP lookup: it maps `(dialed number, jurisdiction)` to the right PSAP for
**US 911 / AU 000 / UK 999 / EU 112** and enforces the invariant shared by RAY BAUM'S, EECC Art 109
and C674 — **an emergency call with no dispatchable location is refused, never silently routed**.
```bash
bash emergency-route.sh 000 AU                 # -> ROUTE to Triple Zero
bash emergency-route.sh 911 US --location absent   # -> REFUSE (fail-closed)
```

## Jurisdictions (the framework is neutral; the rules are national)
PIDF-LO and Resource-Priority are jurisdiction-neutral; the *obligations* are national:
- **US:** direct-dial + notification (**Kari's Law**) and **dispatchable location** (**RAY BAUM'S
  Act**) — the default this lab implements.
- **AU (000):** the ATA industry code **C674:2025 — *Emergency Calling – Network and Mobile Phone
  Testing*** ([bib §11b](../../../course/references/bibliography.md)) governs emergency-call handling
  and testing (including the SIP-header requirements for AU emergency calls); carrier obligations sit
  under the ACMA.
- **EU (112):** the **EECC** (Directive (EU) 2018/1972) **Article 109** mandates *free* emergency
  communications and automatic transmission of **precise network + handset-derived (AML)** caller
  location *without delay*. Architecture: **ETSI TS 103 479** (**NG112** — BCF/ESRP/ECRF/PSAP/LIS);
  operational body **EENA**.
- **UK (999 / 112):** both numbers reach the same emergency services; regulated by **Ofcom**;
  NG112/AML adopted. (Fuller UK detail + a routing/testing lab hook are tracked as backlog **F5**.)

## References
- IETF **ECRIT** WG — the emergency-calling RFC family
  ([bib §6](../../../course/references/bibliography.md)): **RFC 6443** (framework), **RFC 6881**
  (BCP 181), **RFC 5222** (LoST — the ECRF location→PSAP routing that `emergency-route.sh` stands in
  for), **RFC 6442** (location conveyance), **RFC 7852** (additional data), **RFC 4119** (PIDF-LO),
  **RFC 4412** (Resource-Priority).
- AU: Comms Alliance **C674:2025** / **C536:2025** (emergency) · **G673:2024** (SIP transport).

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` construction PASS | — | required |
| Kari's Law direct-dial + notification | 25 | dialplan + capture |
| RAY BAUM'S dispatchable location delivered | 30 | PIDF-LO in capture |
| Resource-Priority routing + not forgeable | 25 | capture + policy |
| PSAP-sim call completes | 20 | capture |
