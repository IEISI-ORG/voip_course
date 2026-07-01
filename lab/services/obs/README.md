# obs — observability plane (Stage A5)

The monitoring/SIEM stack on the `mgmt` network. **Profile-gated** so the everyday lab stays
light: base `make up` does *not* start it.

```bash
make obs-up      # docker compose --profile obs up -d
make obs-down
```

## Components

| Service | Role | Net (mgmt / core) | Port |
|---------|------|-------------------|------|
| `heplify-server` | HEP collector → HOMER schema (ingests mirrored SIP) | .52 / .52 | 9060 |
| `homer-webapp` | HOMER 7 UI — SIP call-ladder search/correlation | .53 | 9080 |
| `obs-db` | Postgres backing HOMER | .51 | 5432 |
| `prometheus` | metrics | .54 / .54 | 9090 |
| `grafana` | dashboards (Prometheus + Loki auto-provisioned) | .55 | 3000 |
| `loki` | log aggregation | .56 | 3100 |
| `wazuh` | SIEM (single-node manager) | .57 | 1514/55000 |

`heplify-server` and `prometheus` also attach to `core` so core services can send HEP / be
scraped — the mgmt plane never touches `edge` or `redteam`.

## What's wired now vs later
- **Now:** Prometheus (self-scrape), Grafana datasources, Loki, HOMER HEP intake path, a
  single-node Wazuh manager.
- **M15:** enable Kamailio/Asterisk exporters (Prometheus targets are commented in
  `prometheus/prometheus.yml`), mirror SIP from `edge-sbc` to HEP, SIP dashboards, Wazuh
  rules for toll-fraud / recording-access (threats T4/T14), full Wazuh indexer+dashboard.

## Reproducibility note
HOMER/heplify/Wazuh image tags and env keys move between versions. Pin and verify
`sipcapture/*` and `wazuh/*` images (and their env variables) before a cohort; the
Prometheus/Grafana/Loki configs here are standard and version-stable.
