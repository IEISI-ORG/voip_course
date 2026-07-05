# Lab BF15 — Suricata IDS for VoIP (the detect stage)

**Modules:** [M14](../../../course/modules/14-threats-offensive-testing.md) (attack) →
**detect** → [M16](../../../course/modules/16-monitoring-observability-ir.md) (respond). Feedback-
derived (F1). A signature sensor that sits **beside** the honeypot (BF12) and feeds the **same**
response pipeline: diverse detection, unified response (defense in depth).

Threats (VoIPSA taxonomy): reconnaissance/service-abuse and intentional interruption of service.

## Auto-graded core
```bash
bash labs/bf15-suricata/verify.sh
```
Self-validating: the ruleset is well-formed and covers scanner recon, REGISTER brute/flood, INVITE
flood, and toll-fraud dial patterns; and `eve-to-ipset.sh` bans **only** the sources of `VOIPSEC`
alerts (a non-alert SIP flow and a non-VOIPSEC alert are correctly ignored).

## Pieces
- [`suricata-voip.rules`](suricata-voip.rules) — VoIP/SIP detection (local sid 9000000+): scanner
  UAs (friendly-scanner/sipvicious), OPTIONS sweep, REGISTER flood, INVITE flood, toll-fraud dial
  prefixes, oversized/malformed SIP.
- [`suricata.yaml`](suricata.yaml) — HOME_NET (the core), SIP app-layer parser, EVE JSON output.
- [`eve-to-ipset.sh`](eve-to-ipset.sh) — EVE alerts → `nft add element inet voipsec_edge banned_v4`
  (same sink as BF12's `hp2ipset.sh`). Wazuh can also ingest EVE for correlation/active-response.

## Run it live (where Suricata is installed)
```bash
suricata -T -S suricata-voip.rules                 # validate rules
suricata -c suricata.yaml -i eth0 &                # sniff the edge span
# from the redteam net (authorized), run an svwar/OPTIONS sweep -> alerts appear in eve.json
tail -f /var/log/suricata/eve.json | grep VOIPSEC
bash eve-to-ipset.sh /var/log/suricata/eve.json --apply    # ban the scanners
```

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` PASS | — | required |
| Suricata detects a SIP scan/flood (live) | 30 | run svwar → EVE alert |
| Toll-fraud dial pattern caught | 15 | INVITE to premium prefix → alert |
| EVE → nftables ban applied | 25 | scanner IP appears in `banned_v4` |
| Wired to M16 (Wazuh/Grafana sees the alert) | 20 | alert visible in the obs plane |
| No false ban of a legitimate REGISTER/OPTIONS | 10 | threshold tuning shown |
