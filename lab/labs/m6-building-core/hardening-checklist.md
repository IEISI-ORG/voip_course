# Living Hardening Checklist — <your name / cohort>

Started in M6 (v1), extended every module, audited at the checkpoints and capstone. The
companion to your living threat model. Check items as you implement them; cite evidence.

## PBX secure defaults (M6)
- [ ] Legacy `chan_sip` unloaded; `chan_pjsip` only (Asterisk)
- [ ] AMI disabled (or TLS + ACL, mgmt-only)
- [ ] ARI/HTTP disabled unless needed (then TLS + auth)
- [ ] No `anonymous`/guest endpoint; `allowguest=no`
- [ ] Secret files not world-readable (`640`); secrets from env, not in git (T11)
- [ ] FreeSWITCH `default_password` ≠ 1234; ESL bound to loopback + ACL (T3/T11)
- [ ] Dialplan denies outbound/PSTN by default (toll-fraud safe, T4)
- [ ] Unused channel drivers (MGCP/Skinny/Unistim) unloaded

## Edge / SBC (M7–M8)
- [ ] Topology hiding on (no internal IP leak)
- [ ] Rate limiting / pike; scanner-UA bans (T1/T8)
- [ ] nftables edge policy (v4 **and** v6), fail2ban jails
- [ ] rtpengine strict source; media anchored (T9)

## Signaling / media crypto (M11–M12)
- [ ] TLS/SIPS on signaling; strong ciphers; cert validation
- [ ] mutual TLS on trunks (T12)
- [ ] SRTP/DTLS-SRTP on media (T5)

## Identity / auth (M13)
- [ ] Digest auth on REGISTER/INVITE; SHA-256 (RFC 8760); downgrade rejected
- [ ] STIR/SHAKEN verify/attest; strip untrusted Identity at border (T7)

## Fraud / monitoring / IR (M15–M16)
- [ ] Spend limits + anomaly CDR (T4); DISA/voicemail PIN policy (T13)
- [ ] Recording encryption-at-rest + RBAC + DTMF suppression (T14)
- [ ] SIEM alerts (toll fraud, recording access, honeypot hits); IR runbooks

> Evidence column: link the capture, config diff, or `verify.sh` output that proves each item.
> The number of unchecked boxes is your remaining risk surface.
