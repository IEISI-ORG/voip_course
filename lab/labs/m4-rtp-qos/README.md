# Lab M4 — RTP, RTCP, Codecs & QoS

**Module:** [M4](../../../course/modules/04-rtp-codecs-qos.md) · **Est.** 4h ·
**Prereqs:** M3.

Goal: understand how media actually travels, measure its quality, compute its cost, and see why
plaintext RTP is a confidentiality problem (threat T5) that SRTP fixes (M12).

## Auto-graded prerequisites
```bash
bash labs/m4-rtp-qos/verify.sh
```
Fail-closed: media path up (incl. rtpengine), REGISTER, and trunk-sim answering SIP (a media
endpoint to capture).

## Lab 4.1 — Extract & measure the media  (30 pts)
```bash
bash labs/m4-rtp-qos/capture-rtp.sh          # capture guidance + traffic generation
```
Capture a call, then in Wireshark: **Telephony > RTP > Streams** to read jitter and loss and get
a MOS estimate; play the stream back.

**Deliverable:** RTP stream stats (jitter, loss %) + estimated MOS + which codec was used.

## Lab 4.2 — Bandwidth budget  (25 pts)
```bash
bash labs/m4-rtp-qos/bw-budget.sh            # deterministic calculator
```
Explain why G.711@20ms is ~80 kbps (L3) one-way while Opus@20ms is ~40 kbps, and how ptime and
Ethernet overhead change the number. Verify one row against your own capture.

**Deliverable:** the budget for G.711 vs Opus at two ptimes + on-wire verification of one.

## Lab 4.3 (attack → defend) — Eavesdrop, then SRTP  (30 pts)
With the plaintext capture from 4.1, reconstruct the audio in Wireshark ("Play Streams"). That
is threat **T5**. Note that after **M12** (SRTP/DTLS-SRTP) the payload is encrypted and the same
capture can no longer be played — the sniffer is defeated.

**Deliverable:** evidence you reconstructed plaintext audio + a written explanation of how SRTP
defeats the same attack (forward reference to M12).

## Lab 4.4 — DSCP & QoS under impairment  (15 pts)
Mark media EF (DSCP 46) on a PBX/SBC, impair the edge link with `netem`
(`tc qdisc add dev <if> root netem delay 80ms 20ms loss 2%`), and observe the quality effect
(and, with obs up, in Grafana). Contrast marked vs unmarked.

**Deliverable:** before/after MOS or jitter under impairment; note on why DSCP alone doesn't help
without honoring queues end to end.

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` prerequisites | — | required to pass 4.1 |
| 4.1 RTP stats + MOS | 30 | capture |
| 4.2 bandwidth budget + on-wire check | 25 | calc + capture |
| 4.3 eavesdrop reconstructed + SRTP explanation | 30 | capture/notes |
| 4.4 DSCP + netem effect | 15 | capture/dashboard |
