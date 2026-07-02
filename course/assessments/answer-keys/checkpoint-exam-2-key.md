# Checkpoint Exam #2 — Answer Key & Rubric (INSTRUCTOR ONLY)

Held separately from the exam. Exam: [`../checkpoint-exam-2.md`](../checkpoint-exam-2.md).

## Answer key
- **1.** e.g. guest/anonymous calling, world-readable secrets, `chan_sip` loaded, AMI/ARI on,
  outbound-open dialplan, stock `default_password` — prove via `verify.sh` (module `pjsip show
  endpoint anonymous` = none, file mode 640, module not loaded, `default_password`≠1234).
- **2.** `chan_sip` = legacy stack with weak enumeration/defaults; AMI/ARI = full remote control
  surfaces (T11) — off unless TLS+ACL and needed.
- **3.** Internal Via/Record-Route/Contact (core IPs, software) leak; `topoh` masks them — verify
  an external capture shows no `172.28.20.x`.
- **4.** SRV priority = failover order (lowest first), weight = load share within a priority; TTL
  bounds how long stale targets linger, so lower it before a cut-over and keep old warm for
  instant rollback.
- **5.** Registrar/dialog state (usrloc in Redis/DB, media state); anycast helps stateless UDP
  frontends/DDoS but can move a stateful RTP flow to a node without its state.
- **6.** Endpoints behind NAT advertise private addresses; anchoring relays media via a reachable
  address; `rtp_symmetric`/strictrtp only accept RTP from the negotiated source → mitigates T9.
- **7.** `use-auth-secret` (short-term creds) prevents open relay; `denied-peer-ip` (internal
  subnets) prevents SSRF/relay into core; quotas prevent amplification/DoS.
- **8.** Behavioural bans on volume (robust, needs threshold; evasion: low-and-slow); signature
  bans on UA (one packet, cheap; evasion: rotate/spoof the User-Agent).
- **9.** e.g. 404→1, 486→17, 503→34 — a wrong map mis-signals the PSTN (wrong tone/billing/retry).
- **10.** IP allowlist + TLS + digest auth; prove a spoofed-source INVITE from redteam is 401/403.
- **11.** Each proxy terminates TLS → cleartext exists inside trusted hops; acceptable only if the
  core is trusted/segmented (why topology hiding + mTLS trunks matter).
- **12.** SDES puts the SRTP key in SDP `a=crypto`; plaintext signaling exposes the key → media
  decryptable. "Encrypted" ≠ private without secure keying.
- **13.** SDES: key in SDP (needs TLS); DTLS-SRTP: key via DTLS in the media path (fingerprint in
  SDP); ZRTP: DH in media path + human SAS — defeats even a signaling-path MITM.
- **14.** SRTP-only policy (reject RTP/AVP / offers lacking crypto); without it the call silently
  downgrades to plaintext media (T5).
- **15.** Scrape cert expiry (ssl_exporter/blackbox) and alert on `earliest_cert_expiry - time() <
  30d`; expired/near-expiry certs cause outages or force insecure fallbacks.
- **16.** UAS sends `401 WWW-Authenticate` with realm/nonce/qop/`algorithm=SHA-256`; UAC returns
  `Authorization` digest; refuse downgrade by not offering MD5 / rejecting MD5 responses.
- **17.** `attest` = A (full), B (partial), C (gateway); verifier must validate the PASSporT
  signature against the `x5u` cert chain and that numbers fall in scope; the "attestation gap" is
  an enterprise getting B/C because the carrier doesn't own its number block.
- **18.** RFC 9060 delegate certs let the enterprise sign its own PASSporT under a delegated cert
  scoped to its TNs, so the originating SP verifies and preserves **A**.
- **19.** Uniform responses (same code/timing for valid/invalid), rate-limit + fail2ban, so
  response deltas don't leak valid extensions.
- **20.** Strong secrets + account lockout + fail2ban + TLS + (optionally) IP allowlist make
  guessing futile; detect via auth-failure spikes in Wazuh/CDR and the pike/UA bans.

## Grading
| Part | Pts | Notes |
|------|-----|-------|
| A build & routing | 25 | partial credit |
| B edge/NAT/trunk | 25 | Q9 mappings must be correct |
| C crypto | 25 | conceptual precision |
| D security | 25 | **gate: ≥13 required** |
| **Pass** | **≥70** | and Security ≥ 50% |
