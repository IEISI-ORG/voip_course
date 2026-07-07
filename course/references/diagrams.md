# VoIPSec Diagram Registry

A single list of every diagram/figure in the course, its **source**, and the tool that renders it.

## Golden rule: we generate our own

**Every diagram in this course is generated from source we own — no third-party images, screenshots,
or copied figures.** Each diagram ships as (a) a text **source** file (Graphviz `.dot`, Mermaid
`.mmd`, or equivalent) and (b) a rendered **`.svg`** built from that source, both committed. This
keeps the course:

- **CC BY-NC-SA 4.0 clean** — no external copyright, licensable as our own work;
- **reproducible** — anyone can rebuild every figure from its source with one command;
- **maintainable** — diffs are readable, edits are text, no binary opaque assets.

If a figure would otherwise come from a vendor doc, an RFC, or a web image, we **redraw it from our
own source** instead. (Vendored `node_modules` badges under the gitignored MARP tooling are not
course content and are never published.)

## Current diagrams

| Diagram | Source | Rendered | Rebuild | Used in |
|---|---|---|---|---|
| VoIP/SIP RFC evolution & dependency map | `rfc-evolution-map.dot` (Graphviz) | `rfc-evolution-map.svg` | `dot -Tsvg rfc-evolution-map.dot -o rfc-evolution-map.svg` | `rfc-dependency-map.md` |

## Planned — SIP workflow state-diagram library (Stage K)

A library of state/sequence diagrams for common SIP workflows, each **self-generated** (Mermaid
`sequenceDiagram`/`stateDiagram` or Graphviz → SVG), rendered offline, and embedded in the relevant
module + slide deck. Workflow list is being gathered with the maintainer (feedback2). Seed
candidates (pending maintainer steer):

- Registration bind (REGISTER → 401 → auth REGISTER → 200) — success **and** an **unauthorised call**
  rejected (the maintainer's example).
- INVITE 3-way + media start + BYE; forking (parallel/sequential) with the CANCEL race.
- Digest challenge round-trip; STIR/SHAKEN sign→verify (pass/fail).
- TLS/SIPS handshake; SRTP vs. plaintext media; ZRTP SAS.
- NAT traversal (`rport`/`received`, symmetric-RTP, STUN/TURN/ICE).
- DNS RFC 3263 resolution + SRV failover; DNS-spoof redirect defeated by DNSSEC/TLS.
- Toll-fraud detect→contain runbook; INVITE-flood mitigation.

Each entry graduates into the table above once its source + SVG are committed.
