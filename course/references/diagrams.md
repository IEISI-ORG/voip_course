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
| SIP registration (digest auth) + unauthorised-call rejection | `diagrams/sip-registration-auth.dot` (Graphviz) | `diagrams/sip-registration-auth.svg` | `dot -Tsvg diagrams/sip-registration-auth.dot -o diagrams/sip-registration-auth.svg` | `modules/13-authn-authz-identity.md` |
| INVITE dialog — setup, media, teardown | `diagrams/sip-invite-dialog.dot` (Graphviz) | `diagrams/sip-invite-dialog.svg` | `dot -Tsvg diagrams/sip-invite-dialog.dot -o diagrams/sip-invite-dialog.svg` | `modules/02-core-sip-protocol.md` |
| Parallel forking + CANCEL race | `diagrams/sip-forking-cancel.dot` (Graphviz) | `diagrams/sip-forking-cancel.svg` | `dot -Tsvg diagrams/sip-forking-cancel.dot -o diagrams/sip-forking-cancel.svg` | `modules/02-core-sip-protocol.md` |
| NAT traversal — problem + server/client fixes | `diagrams/sip-nat-traversal.dot` (Graphviz) | `diagrams/sip-nat-traversal.svg` | `dot -Tsvg diagrams/sip-nat-traversal.dot -o diagrams/sip-nat-traversal.svg` | `modules/08-nat-firewalls-sbc.md` |
| STIR/SHAKEN sign→verify (pass/fail) | `diagrams/sip-stir-shaken.dot` (Graphviz) | `diagrams/sip-stir-shaken.svg` | `dot -Tsvg diagrams/sip-stir-shaken.dot -o diagrams/sip-stir-shaken.svg` | `modules/13-authn-authz-identity.md` |
| Securing both planes — TLS + SRTP (SDES/DTLS/ZRTP) | `diagrams/sip-media-crypto.dot` (Graphviz) | `diagrams/sip-media-crypto.svg` | `dot -Tsvg diagrams/sip-media-crypto.dot -o diagrams/sip-media-crypto.svg` | `modules/12-media-security-srtp.md` |
| DNS RFC 3263 resolution + SRV failover + spoof defense | `diagrams/sip-dns-resolution.dot` (Graphviz) | `diagrams/sip-dns-resolution.svg` | `dot -Tsvg diagrams/sip-dns-resolution.dot -o diagrams/sip-dns-resolution.svg` | `modules/10-dns-infrastructure.md` |
| Incident response — toll fraud + flood lifecycle | `diagrams/sip-fraud-flood-ir.dot` (Graphviz) | `diagrams/sip-fraud-flood-ir.svg` | `dot -Tsvg diagrams/sip-fraud-flood-ir.dot -o diagrams/sip-fraud-flood-ir.svg` | `modules/17-monitoring-observability-ir.md` |

## Planned — SIP workflow state-diagram library (Stage K)

A library of state/sequence diagrams for common SIP workflows, each **self-generated** with
**Graphviz** (`dot` → SVG; mermaid-cli isn't installed, and Graphviz matches the RFC-map precedent),
rendered offline, and embedded in the relevant module. Workflow list is provisional (maintainer may
amend — feedback2). Progress:

- [x] Registration bind (REGISTER → 401 → auth REGISTER → 200) + **unauthorised call** rejected
  (maintainer's example) — `diagrams/sip-registration-auth.svg`, embedded in M13.
- [x] INVITE 3-way + media start + BYE — `diagrams/sip-invite-dialog.svg`, embedded in M2.
- [x] Forking (parallel) with the CANCEL race — `diagrams/sip-forking-cancel.svg`, embedded in M2.
- [x] STIR/SHAKEN sign→verify (pass/fail) — `diagrams/sip-stir-shaken.svg`, embedded in M13.
- [x] TLS/SIPS + SRTP key exchange (SDES/DTLS/ZRTP) vs. plaintext —
  `diagrams/sip-media-crypto.svg`, embedded in M12.
- [x] NAT traversal (`rport`/`received`, symmetric-RTP, STUN/TURN/ICE) —
  `diagrams/sip-nat-traversal.svg`, embedded in M8.
- [x] DNS RFC 3263 resolution + SRV failover; DNS-spoof defeated by DNSSEC/TLS —
  `diagrams/sip-dns-resolution.svg`, embedded in M10.
- [x] Toll-fraud detect→contain + INVITE-flood mitigation IR lifecycle —
  `diagrams/sip-fraud-flood-ir.svg`, embedded in M17.

**Stage K provisional set complete (8/8).** Further workflows welcome from the maintainer.
Each entry graduates into the table above once its source + SVG are committed.
