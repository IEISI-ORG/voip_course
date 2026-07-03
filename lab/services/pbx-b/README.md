# pbx-b — FreeSWITCH application server (Stage A3)

The second-stack PBX on the trusted `core` network (172.28.20.22). Runs alongside `pbx-a`
(Asterisk) so later modules can show cross-stack interop (M16) and compare hardening idioms.

## Security posture (base)

| Choice | Why | Threat / module |
|--------|-----|-----------------|
| Inject `default_password` from env at boot | kill FreeSWITCH's stock `1234` | T3 / M12 |
| ESL bound to `127.0.0.1`, `loopback.auto` ACL, env password | ESL = full switch control | T11 / M15 |
| Test users in restricted `voipsec` context | no PSTN route from a user | T4 / M9 |
| Explicit reject catch-all in dialplan | no fraud-enabling fallthrough | T4 |

## Approach
The community FreeSWITCH image keeps its working default config; we overlay only hardening
files onto the standard include points:
- `autoload_configs/event_socket.conf.xml` — locked-down ESL.
- `directory/default/1003.xml`, `1004.xml` — authenticated users in `voipsec` context.
- `dialplan/voipsec.xml` — restricted context (echo `9196`, tone `9197`, else reject).

## Deliberate stubs (hardened later)
- **Plain SIP/RTP** — sofia TLS in **M10**, SRTP/DTLS in **M11**.
- **Shared `default_password`** — per-user secrets + RFC 8760 digest in **M12**.
- **No outbound trunk** — added with restrictions in **M9**.

## Reproducibility note
`FREESWITCH_IMAGE` defaults to a community image because SignalWire's Debian packages are
now token-gated. Pin and verify the tag (and its `/etc/freeswitch` layout) before a cohort.

## Verify (topology up)
```bash
make up
docker compose exec pbx-b fs_cli -x 'sofia status'
docker compose exec pbx-b fs_cli -x 'user_exists id 1003 default'
docker compose exec pbx-b fs_cli -x 'eval $${default_password}'   # NOT 1234
```
