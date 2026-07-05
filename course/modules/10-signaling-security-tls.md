# Module 10 — Signaling Security: TLS & SIPS

**One-liner:** Encrypt and authenticate the signaling plane end-to-edge with TLS, and manage the
certificates. **Est. time:** 5h · **Prereqs:** Modules 6–9.

## Learning Objectives
- Deploy SIP over TLS (SIPS) on PBX and SBC, including mutual TLS on trunks.
- Manage certificates (public via Let's Encrypt, private via step-ca) and their lifecycle.
- Detect and prevent signaling MITM/tampering.

## 1. Concept
- **Why encrypt signaling:** SIP over UDP/TCP is plaintext → interception, tampering, spoofing,
  credential capture. TLS provides confidentiality, integrity, and server (optionally mutual)
  authentication for the signaling plane.
- **SIP transports:** UDP/TCP/TLS/WS/WSS; `sips:` URIs; port 5061; per-hop vs. end-to-end
  reality (SIP TLS is hop-by-hop — implications for trust).
- **TLS essentials for VoIP:** versions (require 1.2+, prefer 1.3), cipher policy, SNI, session
  resumption; certificate chains, SAN matching to SIP domain, CN/SAN pitfalls.
- **Certificate management:** public certs (Let's Encrypt via certbot/acme.sh) for edge;
  private CA (step-ca/OpenSSL) for internal mTLS; rotation, revocation, monitoring expiry.
- **Mutual TLS on trunks/peering (T12):** authenticate carrier/peer by client cert — strong anti-spoof.
- **Interplay with topology hiding & SBC:** TLS terminates at the edge; re-originate to core over
  internal mTLS.

## 2. Packet Reality
- Capture a TLS handshake for SIP; with the server key, decrypt and read the now-protected SIP.
- Contrast: capture plaintext SIP showing credentials/headers an attacker would harvest.

## 3. Build (OSS)
- Asterisk `transport` type TLS (cert/key/ca, `verify_client` for mTLS); register a client over TLS.
- Kamailio `tls` module + `tls.cfg` profiles; TLS listener on 5061; edge-terminate then core-mTLS.
- Issue edge cert with acme.sh; issue internal certs with step-ca; automate renewal + reload.
- mTLS trunk between SBC and `trunk-sim`.

## 4. Attack / Defend
- **Signaling MITM/tampering (T6):** demonstrate (in lab) reading/altering plaintext SIP; then
  show TLS defeats it. Downgrade attempts (offer only TLS; drop UDP/TCP at edge).
- **Cert-management failures:** expired certs = outage; weak ciphers/old TLS = exposure; private
  key leakage (T11) → perms, HSM/where feasible, rotation, expiry alerts in monitoring (M15).
- **Trust pitfalls:** hop-by-hop TLS means you trust every intermediary — document the trust
  boundary; use mTLS on peer links.
- Extend hardening checklist (transport policy) + threat model.

## 5. Labs
- **Lab 10.1:** Enforce TLS-only registration on Asterisk + Kamailio; prove UDP/TCP are refused.
- **Lab 10.2:** Decrypt a captured SIP-TLS session with the server key and read it.
- **Lab 10.3 (security):** Establish mTLS on the trunk; show a peer without a valid client cert
  is rejected; add a cert-expiry alert to Prometheus.
- *Rubric:* TLS-only enforced; decryption demonstrated for teaching; working mTLS + expiry alert.

## Assessment (sample)
- Why is SIP TLS hop-by-hop a trust concern, and how do you bound it?
- What breaks if the edge certificate expires, and how do you prevent it operationally?
- How does mutual TLS reduce trunk spoofing risk compared to IP auth?

## Curriculum addition — WebRTC signaling gateway over Secure WebSocket (review: gemini_feedback0)

Browsers speak SIP over WebSocket, not UDP/TCP. Securing that transport is a distinct
signaling-security skill and the entry point for the WebRTC media work in M11.
- **Standards:** SIP over WebSocket (RFC 7118); TLS 1.2/1.3 (RFC 8446); origin/CORS concerns.
- **Build:** add a Kamailio `WSS` listener (`tls` + `websocket` modules) on the edge; terminate
  Secure WebSocket from browser clients (jsSIP/SIP.js) and normalise into the core.
- **Attack/Defend:** unauthenticated WS upgrades, cross-origin abuse, mixed `ws://` exposure;
  enforce `wss://` only, validate `Origin`, rate-limit upgrades (ties to T8).
- **Lab hook (adds B10+):** a browser softphone registers over `wss://` to `edge-sbc`; capture
  and verify the TLS-wrapped WebSocket handshake. Media bridging continues in M11.

## References
- RFC 3261 (§26 security), 5630 (sips: usage), 8446 (TLS 1.3), 7525/9325 (TLS BCP);
  NIST SP 800-52r2; certbot/acme.sh/step-ca docs; Kamailio tls & Asterisk TLS docs.
