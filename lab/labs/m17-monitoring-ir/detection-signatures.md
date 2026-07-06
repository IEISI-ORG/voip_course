# Detection Signatures — M15 findings → M17 alerts (Lab 17.2)

Every threat the M15 assessment exercised must have a detection signature here, so a repeat is
seen in real time. Layer: **M** = metric (Prometheus), **L** = log/SIEM (Wazuh/Loki), **C** = CDR.

| Threat | Attack (M15) | Layer | Signature | Alert / rule |
|--------|--------------|-------|-----------|--------------|
| T1 | scanning (svmap) | M/L | ipban entries spike; SBC "scanner UA … banned" log | `SourceBannedSpike` |
| T2 | enumeration (svwar) | M | 4xx/failure-ratio spike | `HighSIPFailureRatio` |
| T3 | brute force (svcrack) | M/L | registration-rate spike; repeated 401 per AoR | `RegistrationFlood` + Wazuh auth-fail rule |
| T4 | toll fraud / IRSF | C | spend cap breach; high-cost prefix burst | `TollFraudSpend` (from M16 fraud-detect) |
| T8 | INVITE/REGISTER flood | M | INVITE/channel rate spike | `InviteFlood` |
| T10 | malformed / torture | L | SBC "malformed message dropped" log rate | Loki/Wazuh rule on sanity-drop |
| T6 | MITM / cert issues | M | cert expiry < 30d; unexpected cert change | `CertExpiringSoon` |
| T14 | recording/CDR exposure | L | access to recordings dir by non-RBAC user | `RecordingAccessAnomaly` + Wazuh FIM |

## Replay validation (15.2)
For each row, trigger the attack from `redteam` (or replay a pcap) and show the alert firing:
```bash
# examples (authorized lab):
lab-scan 172.28.10.10                         # -> SourceBannedSpike
bash labs/m7-proxies-sbc/flood-demo.sh        # -> InviteFlood
bash labs/m16-defense-fraud/fraud-detect.sh   # -> TollFraudSpend
bash labs/m15-offensive/torture.sh 172.28.10.10  # -> sanity-drop log rule
```
**Coverage gate:** an M15 finding with no detection signature is an incomplete defense.
