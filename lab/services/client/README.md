# client — softphone + load-test toolbox (Stage A4)

External-user container on the `edge` network (172.28.10.40). Registers through the
`edge-sbc`, so every call it makes exercises the border security from A1.

## Tools
- **Baresip** — scriptable softphone; account (ext 1001) rendered from `SIP_ALICE_SECRET`.
- **SIPp** — reproducible REGISTER / call scenarios for labs and load tests.

## Use
```bash
# Interactive softphone (registers 1001 via the SBC):
docker compose exec -it client baresip

# Scripted REGISTER through the SBC:
docker compose exec client \
  sipp -sf /scenarios/register.xml 172.28.10.10:5060 -s 1001 -i 172.28.10.40 -m 1

# Scripted call to 1002 through the SBC:
docker compose exec client \
  sipp -sf /scenarios/uac_call.xml 172.28.10.10:5060 -s 1002 -i 172.28.10.40 -m 1 -l 1
```

## Security notes
- Account password is injected from `.env` at boot; never stored in git (T11).
- Plain UDP for now — SIPS/TLS registration and SRTP media are added in **M10/M11**, at which
  point the SIPp scenarios gain a 401→auth retry (SBC auth is stubbed until **M12**).
