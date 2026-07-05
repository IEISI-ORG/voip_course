# Checkpoint Exam #2 — Build + Security (after M13)

Covers **M6–M13** (+ M10): building PBXs, proxies/SBCs, NAT/firewall/TURN, trunking, DNS,
signaling TLS, media SRTP, and auth/identity.

- **Format:** 20 items, 100 points. **Pass ≥ 70** (and ≥ 50% on the Security section).
- **Open-book.** Time: 90 minutes.
- Answers held separately (instructor-only), one directory deeper:
  [`answer-keys/checkpoint-exam-2-key.md`](answer-keys/checkpoint-exam-2-key.md).

---

## Part A — Build & routing (25 pts)
1. (5) List five insecure PBX defaults you must eliminate and how you prove each is gone.
2. (5) Why unload `chan_sip` and disable AMI/ARI by default? What does each expose?
3. (5) A proxy adds `Record-Route`; the SBC runs `topoh`. What leaks without topology hiding, and
   how do you verify it's hidden?
4. (5) Explain SRV-based failover: priority vs weight, and how TTL governs a cut-over/rollback.
5. (5) In HA, what state must be shared between two SBC replicas for hitless failover, and where
   does anycast help vs hurt for media?

## Part B — Edge, NAT & trunking (25 pts)
6. (5) Why does media need anchoring (rtpengine) for NAT'd calls, and which threat does symmetric
   RTP mitigate?
7. (5) Name two coturn hardening settings and the abuse each prevents.
8. (5) Contrast behavioural (pike) vs signature (UA) banning; give one evasion of each.
9. (5) Map three SIP failure codes to Q.850 causes; why does a wrong mapping matter at the PSTN?
10. (5) A trunk is IP-only. Give the three-layer hardening and how you prove a spoofed peer is
    rejected.

## Part C — Crypto: signaling & media (25 pts)
11. (5) SIP TLS is hop-by-hop. What does that imply for where cleartext exists, and why is that
    acceptable (or not)?
12. (5) Why does SDES-SRTP depend on TLS signaling? What breaks if signaling is plaintext?
13. (5) Contrast SDES vs DTLS-SRTP vs ZRTP on *where the key is exchanged* and what each defeats.
14. (5) An attacker strips `a=crypto`. What policy rejects the downgraded call, and what's the
    failure mode if you don't have it?
15. (5) How would you alert on certificate expiry, and why is that a security control?

## Part D — Security: identity, auth, hardening (25 pts) — *must score ≥ 13/25*
16. (5) Walk the SHA-256 digest challenge/response (RFC 8760). How do you refuse a downgrade to MD5?
17. (5) Decode this concept: a SHAKEN PASSporT's `attest` A/B/C. What must a verifier check before
    trusting it, and what is the "attestation gap"?
18. (5) How do RFC 9060 delegate certificates close the attestation gap for an enterprise?
19. (5) Enumeration (`svwar`) leaks valid extensions via response deltas. Give two defenses that
    remove the signal.
20. (5) A brute-force run (`svcrack`) is underway. List the layered controls that make it futile
    and how you'd detect it.

### Grading (weighting)
| Part | Pts | Notes |
|------|-----|-------|
| A build & routing | 25 | partial credit |
| B edge/NAT/trunk | 25 | Q9 needs correct mappings |
| C crypto | 25 | conceptual precision |
| D security | 25 | **gate: ≥13 required to pass** |
| **Pass** | **≥70** | and Security ≥ 50% |
