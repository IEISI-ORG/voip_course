# Questions / Decisions

Answered questions are pruned each iteration (per your instruction).

## Open (need your steer)
- **Q5 (Suricata IDS placement):** Yes, Suricata fits well. Proposed as **F1** — a new lab that
  ties M13 (attack) → M15 (detect): Suricata on the `mgmt`/`edge` span with VoIP rules (SIP
  scanner/OPTIONS-sweep, REGISTER/INVITE flood, toll-fraud dial patterns), feeding the same
  nftables-ipset + Wazuh active-response pipeline as the honeypot (BF12). **OK to build it that way,
  or do you want Suricata as a standalone service instead of folded into M15?**
- **Q6 (commercial-licence contact):** `LICENSE` currently lists **tcs@ieisi.org** (your org
  address, already public in commit metadata) + a "Commercial licensing" GitHub issue. Swap in a
  different address, or keep as-is?

## Applied decisions
- **Q1 (RCD RFC):** RCD PASSporT = RFC 9795 (+9796); corrected. *(resolved iter 42)*
- **Q2 (citation style) = A:** per-module `## References` stay, but must be a **subset of and
  consistent with** the bibliography. *(auditing iter 48; single-source-of-truth = bibliography)*
- **Q3 (anti-slop depth) = A:** light touch — fix clear AI-isms/flow only, preserve technical
  wording. Content already scans near-zero for AI-isms. *(done)*
- **Q4 (terminology):** keep `redteam` for the literal service/network, "red team" in prose;
  spell out each acronym on first use per module, then abbreviate. Added a **glossary**
  (`course/references/glossary.md`). *(glossary done; first-use spell-out applied light-touch)*

## Noted for later (your call)
- "We will revisit the entire question of references later" — holding on any large reference
  rework until you steer it.

_Drop a `feedback.txt` to add decisions; it is processed then deleted (not committed)._
