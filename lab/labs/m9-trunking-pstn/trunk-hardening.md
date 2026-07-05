# Trunk hardening reference (Lab 9.3)

Take an IP-only trunk to authenticated + encrypted, then add fraud guardrails. Apply these on
`pbx-a` (Asterisk) or the SBC; capture the evidence for grading.

## 1. Peer authentication (defeats spoofed peers, T12)

**Weak (IP-only):** anyone who can spoof the ITSP source IP is trusted.
```ini
; pjsip.conf — identify by IP ONLY (starting point; insecure alone)
[itsp]
type=identify
endpoint=itsp
match=172.28.10.30
```
**Hardened:** IP allowlist **and** digest auth **and** TLS transport.
```ini
[transport-tls]
type=transport
protocol=tls
bind=0.0.0.0:5061
cert_file=/etc/asterisk/keys/edge.crt
priv_key_file=/etc/asterisk/keys/edge.key
method=tlsv1_2

[itsp]
type=endpoint
transport=transport-tls
context=from-trunk
disallow=all
allow=ulaw,opus
outbound_auth=itsp-auth
[itsp-auth]
type=auth
auth_type=userpass
username=voipsec-trunk
password=${TRUNK_SECRET}         ; from .env, never committed
[itsp-ident]
type=identify
endpoint=itsp
match=172.28.10.30               ; allowlist + auth + TLS = defense in depth
```
**Prove:** a spoofed INVITE from `redteam` (172.28.10.90) claiming to be the trunk is rejected
(no `identify` match / auth fails). Capture the 401/403.

## 2. Egress control (defeats toll fraud, T4)

**Destination allowlist** — only dial permitted number patterns:
```ini
; extensions.conf [from-internal-outbound]
exten => _1NXXNXXXXXX,1,Set(GROUP()=outbound)          ; NANP only
 same => n,GotoIf($[${GROUP_COUNT(outbound)} > 10]?blocked)   ; concurrency cap
 same => n,Dial(PJSIP/${EXTEN}@itsp,30)
 same => n,Hangup()
exten => _X.,1,NoOp(BLOCKED non-allowlisted destination ${EXTEN}); Hangup(21)
blocked => 1,NoOp(spend/concurrency cap hit); Hangup(21)
```
- Block international/premium prefixes by default; allowlist explicitly.
- **Spend limit:** track per-account cost/min via CDR or a counter (`GROUP_COUNT`, AGI, or a
  Redis counter); when exceeded, reject + alert.

## 3. Alerting
- Emit a log/CDR event on: blocked destination, concurrency cap, spend-limit breach.
- Ship to Wazuh (M16) and fire an alert. **Trigger it** in the lab by dialing a blocked prefix.

## Checklist (add to your living hardening checklist)
- [ ] Trunk requires TLS + digest auth (not IP-only)
- [ ] Spoofed-source INVITE rejected (evidence: 401/403 capture)
- [ ] Outbound destination allowlist enforced; international blocked by default
- [ ] Spend/concurrency limit enforced with an alert on breach
