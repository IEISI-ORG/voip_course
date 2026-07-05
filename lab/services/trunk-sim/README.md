# trunk-sim — simulated PSTN peer (Stage A4)

SIPp-based external trunk on the `edge` network (172.28.10.30). Stands in for the PSTN so
trunking (M9), NAT/SBC (M8), and media (M4/M12) labs have a deterministic far end.

## Roles
- **`uas`** (default container role) — listens on 5060 and answers calls with a PCMU/PCMA SDP,
  echoing RTP. This is the PSTN answering an outbound call from the platform.
- **`uac [target]`** — originates an "inbound" call toward the SBC (default `edge-sbc`),
  simulating a call arriving from the PSTN to a DID.

## Use
```bash
# Default: already answering as the PSTN (see `docker compose ps`).
# Originate an inbound PSTN call to DID 1001 via the SBC:
docker compose run --rm trunk-sim uac 172.28.10.10
#   tune volume/rate with CALLS= and RATE= env vars.
```

## Scenarios
- `scenarios/uas_pstn.xml` — INVITE→100→180→200(SDP)→ACK→BYE.
- `scenarios/uac_inbound.xml` — INVITE→(100/180)→200→ACK→pause→BYE.

## Security notes
Trunk authentication/mTLS and IP allowlisting for the peer are added in **M9/M11** (threat
T12: trunk abuse / spoofed peers). This base peer is intentionally simple.
