# Lab M6 — Building the Core: Asterisk & FreeSWITCH

**Module:** [M6](../../../course/modules/06-building-the-core.md) · **Est.** 6h ·
**Prereqs:** M1–M5.

Goal: build real PBX/application servers with **secure defaults**, on both stacks, and prove the
insecure defaults are gone.

## Auto-graded secure defaults
```bash
bash labs/m6-building-core/verify.sh
```
Fail-closed; queries the live PBXs: `chan_sip` unloaded, no `anonymous` endpoint, secret file
not world-readable (Asterisk), and FreeSWITCH `default_password` ≠ 1234.

## Lab 6.1 — Asterisk PBX with features  (30 pts)
Build a 4-extension PBX (extend `pbx-a`) with voicemail and a small IVR; place internal calls,
voicemail deposit/retrieval, and an IVR menu. Keep the outbound-deny default.

**Deliverable:** working feature demo (captures/CLI) + the endpoint/dialplan diff.

## Lab 6.2 — Reproduce on FreeSWITCH  (25 pts)
Reproduce the core on `pbx-b`; compare the generated SIP (headers, `Allow`, timers) and media
behavior with Asterisk. Note two concrete differences.

**Deliverable:** parallel feature demo + a short Asterisk-vs-FreeSWITCH comparison.

## Lab 6.3 (security) — Harden & checklist v1  (45 pts)
Start from a deliberately-insecure config (enable guest, world-readable secret, load `chan_sip`),
observe the exposure, then harden it back. Prove:
- anonymous/guest calling is **blocked**,
- secret files are **not world-readable**,
- legacy/AMI/ARI surfaces are off.
Copy and begin your **living hardening checklist**:
```bash
cp labs/m6-building-core/hardening-checklist.md hardening-checklist.md   # commit it
bash labs/m6-building-core/verify.sh                                      # evidence
```

**Deliverable:** committed `hardening-checklist.md` (v1) + `verify.sh` PASS + before/after
evidence for each hardened item.

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` secure defaults PASS | — | required for 6.3 |
| 6.1 Asterisk features | 30 | demo + diff |
| 6.2 FreeSWITCH parity + comparison | 25 | demo + notes |
| 6.3 hardening proven + checklist v1 | 45 | artifacts + PASS |
