# Lab BF2 — Emergency Calling (PIDF-LO + Resource-Priority)

**Modules:** [M9](../../../course/modules/09-sip-trunking-pstn.md) +
[M17](../../../course/modules/17-frontiers.md) (NG911). Feedback-derived (gemini_feedback0).

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

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` construction PASS | — | required |
| Kari's Law direct-dial + notification | 25 | dialplan + capture |
| RAY BAUM'S dispatchable location delivered | 30 | PIDF-LO in capture |
| Resource-Priority routing + not forgeable | 25 | capture + policy |
| PSAP-sim call completes | 20 | capture |
