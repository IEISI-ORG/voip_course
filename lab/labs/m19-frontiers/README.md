# Lab M19 — Frontiers: VoLTE/IMS, FoIP, ENUM/Peering, UC/UCaaS/CPaaS

**Module:** [M19](../../../course/modules/19-frontiers.md) · **Est.** 5h · **Prereqs:** M1–M18.
**Checkpoint Exam #3 (operations) follows this module.**

Goal: take SIP beyond the PBX — mobile core, fax, inter-carrier routing, and unified comms — with
each frontier's security caveats. See also [M10 DNS](../../../course/modules/10-dns-infrastructure.md).

## Auto-graded core (ENUM)
```bash
bash labs/m19-frontiers/verify.sh                    # ENUM encoding + private routing (offline)
bash labs/m19-frontiers/enum-lookup.sh "+1 415 555 0100"
```

## Lab 17.1 — T.38 fax through the SBC  (30 pts)
Bring up a T.38 fax call through the SBC (spandsp in Asterisk/FreeSWITCH); complete a fax, then
diagnose one **induced failure** (e.g. re-INVITE to T.38 blocked, or a codec/ptime mismatch).

**Deliverable:** a successful fax + the diagnosed failure with root cause.

## Lab 17.2 — Private ENUM + presence  (30 pts)
Stand up a **private** `e164.arpa` zone (BIND, from M10) mapping numbers to SIP URIs; route a call
via ENUM and show presence/SUBSCRIBE-NOTIFY between endpoints. Use `enum-lookup.sh` to see the
NAPTR query name and resolution.

**Deliverable:** ENUM-routed call + presence exchange; note the DNSSEC/private-zone security point.

## Lab 17.3 (security) — Secure a CPaaS origination API  (40 pts)
Front call origination with an API that enforces **auth (API key/JWT) + rate limit + spend cap**.
Show an abusive caller (over-rate or over-cap) blocked, and the event alerted (M17).

**Deliverable:** the API policy + an abusive caller blocked + the alert.

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` ENUM PASS | — | required |
| 17.1 T.38 fax + troubleshooting | 30 | capture + RCA |
| 17.2 private ENUM + presence | 30 | routing + capture |
| 17.3 CPaaS API abuse contained | 40 | policy + block + alert |

## → Checkpoint Exam #3 (operations)
[`../../../course/assessments/checkpoint-exam-3.md`](../../../course/assessments/checkpoint-exam-3.md)
— covers operations across M15–M19 and the whole platform.
