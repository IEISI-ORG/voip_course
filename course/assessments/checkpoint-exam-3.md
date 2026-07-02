# Checkpoint Exam #3 — Operations (after M17)

Covers **operations across M13–M17** and running the whole platform: offensive testing, defense
& fraud, monitoring & IR, testing/automation/cloud, and the frontiers — plus cross-cutting
operational security.

- **Format:** 20 items, 100 points. **Pass ≥ 70** (and ≥ 50% on the Security/IR section).
- **Open-book.** Time: 90 minutes.
- Answers held separately (instructor-only):
  [`answer-keys/checkpoint-exam-3-key.md`](answer-keys/checkpoint-exam-3-key.md).

---

## Part A — Offensive & defensive ops (25 pts)
1. (5) Outline an authorized red-team methodology and the one non-technical gate that fails an
   assessment regardless of findings.
2. (5) A SIP parser crashes on malformed input. Classify the threat and how you'd have caught it
   pre-production.
3. (5) Contrast behavioural vs signature banning; give a layered config that uses both.
4. (5) An IRSF pattern appears in CDRs. Describe detection → containment within a spend cap →
   eradication.
5. (5) Give the three-layer fraud defense and why the spend cap is the essential backstop.

## Part B — Monitoring & IR (25 pts) — *must score ≥ 13/25*
6. (5) Name five security KPIs you'd alert on and the threat each maps to.
7. (5) Why must every M13 finding have a detection signature? What's the failure otherwise?
8. (5) Walk the six IR phases for an INVITE flood, naming the containing control at each step.
9. (5) A capture for troubleshooting contains a PAN + PIN. How do you handle it end to end?
10. (5) How do you alert on cert expiry, and why is that an availability *and* security control?

## Part C — Testing, automation & cloud (25 pts)
11. (5) What belongs in CI for a VoIP platform, and which checks can run without the live topology?
12. (5) You must scale media in Kubernetes. Compare NodePort / hostNetwork / Multus and the
    security cost of each.
13. (5) Define a load test's "capacity" and "failure mode"; how do you find the knee?
14. (5) An interop failure: a peer rejects your INVITE. How do you fix it at the SBC without
    touching endpoints?
15. (5) What is config drift and how does IaC + CI prevent it reaching a cohort?

## Part D — Frontiers & cross-cutting (25 pts)
16. (5) Encode `+1-415-555-0100` as an ENUM query and explain the security case for *private* ENUM.
17. (5) Why is DNS a call-redirection threat, and what two defenses protect a redirected call?
18. (5) T.38 fax fails after a re-INVITE. Give two likely causes and the SBC-side fix.
19. (5) Securing a CPaaS origination API: name the three controls and one abuse each prevents.
20. (5) VoLTE/IMS is largely IPv6. Give one dual-stack security pitfall and its mitigation.

### Grading (weighting)
| Part | Pts | Notes |
|------|-----|-------|
| A offensive/defensive | 25 | partial credit |
| B monitoring & IR | 25 | **gate: ≥13 required to pass** |
| C testing/automation/cloud | 25 | |
| D frontiers | 25 | Q16 encoding must be correct |
| **Pass** | **≥70** | and Security/IR ≥ 50% |
