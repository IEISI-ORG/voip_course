# edge-sbc — Kamailio + rtpengine border SBC (Stage A1)

The untrusted-edge session border controller. **Kamailio** (this dir) handles SIP signaling;
**rtpengine** (`../rtpengine`) anchors media. Together they form the border every module
sits behind.

## What this stage delivers

| Concern | Mechanism | Threat / module |
|---------|-----------|-----------------|
| Listeners | UDP/TCP 5060, TLS 5061 | M10 |
| Malformed-message drop | `sanity_check` | T10 / M13 |
| Flood protection | `pike` + `htable` ipban | T8 / M8, M14 |
| Scanner rejection | UA fingerprint match → ban | T1 / M14 |
| Topology hiding | `topoh` (masks internal Via/Contact/RR) | M7 |
| NAT handling | `nat_uac_test` + `fix_nated_*` | M8 |
| Media anchoring | `rtpengine_manage` rewrites SDP → rtpengine | T9 / M11 |
| Registrar | in-memory `usrloc` (DB in M6/M12) | — |

## Deliberate stubs (hardened later)

- **Authentication accepts all REGISTERs** — digest SHA-256 + per-user secrets land in
  **M12**. Do not expose this build to any untrusted network.
- **TLS is self-signed, verify off** — real ACME / private-CA + mutual TLS on trunks in **M10**.
- **Static route to `pbx-a`** — policy/DID routing and failover in **M9**.

## Files
- `kamailio.cfg` — border routing logic (the teaching artifact).
- `tls.cfg` — TLS baseline (hardened M10).
- `Dockerfile`, `entrypoint.sh` — build + first-boot secret/cert injection.

## Verify (once the topology is up)
```bash
make up
docker compose exec edge-sbc kamcmd core.uptime      # daemon alive
docker compose exec edge-sbc kamcmd tls.list          # TLS listener present
sngrep -d any port 5060                                # watch REGISTER/INVITE (M5)
```
