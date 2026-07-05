# pbx-a — Asterisk application server (Stage A2)

The primary PBX on the trusted `core` network (172.28.20.21). Receives calls relayed by
`edge-sbc`; hosts local test endpoints. **Closed by default** — security posture is mostly
about what is turned off.

## Security posture (base)

| Choice | Why | Threat / module |
|--------|-----|-----------------|
| `chan_pjsip` only, `chan_sip` unloaded | legacy stack has weak enumeration/defaults | T2 / M13 |
| AMI disabled (`manager.conf`) | powerful remote-control surface | T11 / M16 |
| ARI/HTTP disabled (`http.conf`) | unneeded attack surface | T11 |
| MGCP/Skinny/Unistim unloaded | shrink channel-driver surface | T11 |
| Dialplan denies outbound by default | no toll route from a compromised ext | T4 / M9 |
| `direct_media=no`, `rtp_symmetric=yes`, `strictrtp` | media through anchor, drop stray RTP | T9 / M12 |
| Secrets rendered from env at boot | no credentials in git | T11 |

## Deliberate stubs (hardened later)
- **Plain UDP on core** — TLS transport in **M11**, SRTP media in **M12**.
- **Digest auth is basic** — SHA-256 + downgrade rejection (RFC 8760) in **M13**.
- **No outbound trunk** — added with restrictions/spend limits in **M9**.

## Endpoints
- `1001` (alice) / `1002` (bob) — secrets from `SIP_ALICE_SECRET` / `SIP_BOB_SECRET` in `.env`.
- Test targets: `600` echo, `601` playback (for M4/M5 media labs).

## Verify (topology up)
```bash
make up
docker compose exec pbx-a asterisk -rx 'pjsip show endpoints'
docker compose exec pbx-a asterisk -rx 'dialplan show internal'
docker compose exec pbx-a asterisk -rx 'manager show settings'   # expect disabled
```
