# Lab BF1 — WebRTC: WSS gateway + DTLS-SRTP↔SIP media bridge

**Modules:** [M10](../../../course/modules/10-signaling-security-tls.md) (WSS signaling) +
[M11](../../../course/modules/11-media-security-srtp.md) (DTLS-SRTP media). Feedback-derived
(gemini_feedback0). **Prereqs:** M10, M11.

Goal: let a browser (jsSIP/SIP.js) place a call to a legacy SIP endpoint — translating **Secure
WebSocket ↔ SIP** (signaling) and **DTLS-SRTP + ICE + RTCP-mux ↔ RTP/SRTP** (media) at the SBC.

## Auto-graded prerequisites
```bash
bash labs/bf1-webrtc/verify.sh          # WSS transport basis + config + secure client
```
Fail-closed: TLS on :5061 (WSS rides it), the Kamailio WS handshake + rtpengine DTLS bridge flag
are configured, and the browser client vendors jsSIP locally (no CDN-compromise surface).

## Build
1. **Kamailio WSS** — merge [`kamailio-webrtc.snippet.cfg`](kamailio-webrtc.snippet.cfg): load
   `xhttp`+`websocket`, handle the upgrade in `event_route[xhttp:request]`, keepalive pings.
2. **rtpengine WebRTC transform** — offer/answer with
   `ICE=force RTP/SAVPF DTLS=passive rtcp-mux-offer` so the browser's DTLS-SRTP leg bridges to
   the PBX's RTP/SRTP leg (neither leg cleartext on the wire).
3. **Browser client** — serve [`client.html`](client.html) over HTTPS (getUserMedia + WSS need a
   secure context). Vendor `jssip.min.js` next to it (verify its checksum).

## Security notes
- WSS only (`wss://`), never `ws://`; validate `Origin`; rate-limit WS upgrades (T8).
- The account password comes from `.env` (`SIP_ALICE_SECRET`) — never commit a real one.
- jsSIP is vendored locally by default; if you use a CDN, pin **Subresource Integrity**
  (`integrity="sha384-…" crossorigin="anonymous"`).

## Verify (manual)
- Register `client.html` over WSS; place a call to `1002` (Asterisk).
- Capture: browser leg is **DTLS-SRTP** (handshake in the media path), PBX leg is RTP/SRTP,
  rtpengine bridges — confirm no cleartext media anywhere.

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` prerequisites | — | required |
| WSS registration from the browser | 30 | capture |
| DTLS-SRTP ↔ RTP media bridge works | 40 | capture (both legs encrypted) |
| Security: wss-only, Origin check, SRI/vendored, secret hygiene | 30 | config review |
