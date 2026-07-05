# Lab M12 — Media Security: SRTP, DTLS-SRTP & ZRTP

**Module:** [M12](../../../course/modules/12-media-security-srtp.md) · **Est.** 5h ·
**Prereqs:** M11 (SDES keys ride TLS-protected signaling).

Goal: encrypt the media plane and get key exchange right — "encrypted" vs "actually private."

## Auto-graded foundation
```bash
bash labs/m12-media-srtp/verify.sh          # media anchor on-path + SIP-TLS present
```
Fail-closed: asserts SRTP can be anchored (rtpengine) and SDES keys can be protected (TLS from
M11). Media-payload encryption itself is capture-graded.

## Lab 11.1 — SDES-SRTP end to end  (30 pts)
Enable SDES-SRTP (RTP/SAVP) with TLS signaling via rtpengine (`rtpengine_manage("... SDES ...")`
/ `transport-protocol=RTP/SAVP`). Prove media is **unreadable** in capture (Wireshark can't play
the RTP payload).
```bash
bash labs/m12-media-srtp/srtp-offer.sh 172.28.10.30       # observe RTP/SAVP + a=crypto
```
**Deliverable:** capture showing encrypted media (no playable audio) + the negotiated `a=crypto`.

## Lab 11.2 — DTLS-SRTP  (25 pts)
Bring up DTLS-SRTP (WebRTC-style) through rtpengine (`DTLS=passive`, fingerprint in SDP);
capture the DTLS handshake and confirm keys are exchanged in the media path (not the SDP).

**Deliverable:** DTLS handshake capture + note on why it beats SDES for key secrecy.

## Lab 11.3 (attack → defend) — crypto strip & ZRTP SAS  (45 pts)
```bash
bash labs/m12-media-srtp/srtp-offer.sh 172.28.10.30 --strip    # downgrade attempt (no a=crypto)
```
- Show an SDP `a=crypto` **strip**; then set an **SRTP-only policy** (reject offers without
  crypto / RTP/AVP) and prove the downgraded call is **rejected**.
- Demonstrate **ZRTP** (Linphone/Baresip): verify the **SAS** and show it defeats an in-path
  MITM even without trusting the signaling path.

**Deliverable:** strip rejected under SRTP-only policy + ZRTP SAS verification screenshot.

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` foundation PASS | — | required |
| 11.1 SDES-SRTP, media unreadable | 30 | capture |
| 11.2 DTLS-SRTP handshake | 25 | capture |
| 11.3 crypto-strip rejected + ZRTP SAS | 45 | capture + screenshot |

> This closes the eavesdropping thread from M4: the same plaintext capture that leaked audio
> there is now useless to a sniffer. Update the hardening checklist (SRTP/DTLS on media).
