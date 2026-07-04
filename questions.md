# Questions / Decisions

Answered questions are pruned each iteration (per your instruction).

## Open (need your steer)
_None right now._

## Applied decisions
- **Q7 (paper 3 Bernard 2022) = DROPPED entirely:** management, not technical. Reverted the slide +
  citation + MD (iter 66). *(final)*
- **Q5 (Suricata) = integrate into M13→M15 pipeline:** build F1 as the IDS stage of the existing
  attack→detect→respond pipeline (not a standalone service). *(answered iter 63)*
- **Q6 (commercial contact) = contact@ieisi.org** + web <https://www.ieisi.org/contact> and
  training <https://www.ieisi.org/training>. Applied to LICENSE/CONTRIBUTING. *(answered iter 63)*
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
