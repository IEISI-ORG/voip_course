# Lab M3 — SDP & Media Negotiation

**Module:** [M3](../../../course/modules/03-sdp-media-negotiation.md) · **Est.** 3h ·
**Prereqs:** M2.

Goal: understand SDP offer/answer, reconstruct negotiated media from the wire, and see why
unauthenticated `c=`/`m=` lines make media anchoring a security control (threat T9).

## Auto-graded prerequisites
```bash
bash labs/m3-sdp-media/verify.sh
```
Fail-closed: services up (incl. rtpengine), REGISTER through the SBC, and the rtpengine edge
media interface reachable (anchor on-path).

## Lab 3.1 — Reconstruct the media  (35 pts)
```bash
bash labs/m3-sdp-media/sdp-offer.sh 172.28.10.30      # offer to trunk-sim; read the answer SDP
```
From the answer (and/or an sngrep/Wireshark capture of a full call), state the negotiated
**codec**, **media port**, **direction** (sendrecv/sendonly), and the resulting **RTP 5-tuple**.

**Deliverable:** the reconstructed media parameters + the 5-tuple.

## Lab 3.2 — Codec policy & transcoding  (30 pts)
On a PBX, set a codec policy (e.g., allow `opus,ulaw` only) and prove the SDP reflects it. Then
force a transcode through rtpengine (offer `opus` one side, `ulaw` the other) and observe the
bridged media.

**Deliverable:** before/after SDP showing the policy + evidence of the transcode.

## Lab 3.3 (attack → defend) — `c=` redirection vs anchoring  (35 pts)
```bash
# Attack leg: offer with an attacker-chosen c= straight to the UAS (no anchor):
bash labs/m3-sdp-media/sdp-offer.sh 172.28.10.30 172.28.10.99
```
Observe that an un-anchored path honours the bogus `c=` — RTP would flow to the wrong host.
Then send the call **through the SBC** so rtpengine rewrites `c=` to its own address and applies
strict source checks; show the redirect fails. (The fully anchored end-to-end call completes
once trunk routing is added in M9; today, capture the un-anchored redirect and explain the
rtpengine mitigation.)

**Deliverable:** capture/notes showing the bogus `c=` honoured un-anchored, and the rewrite
under anchoring.

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` prerequisites | — | required to pass 3.1 |
| 3.1 media reconstruction + 5-tuple | 35 | rubric |
| 3.2 codec policy + transcode | 30 | capture |
| 3.3 `c=` redirect shown + anchoring mitigation | 35 | capture/notes |
