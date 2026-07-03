# Capstone Grading Harness (C2)

Turns the capstone's rubric ([`../../modules/18-capstone.md`](../../modules/18-capstone.md)) into
a runnable scoring sheet with the **mandatory-security gate**.

## Use
```bash
cp scoresheet.csv my-cohort/candidate.csv     # fill the `score` column per category
bash score-capstone.sh my-cohort/candidate.csv
bash verify.sh                                 # self-test of the harness (6 checks)
```

## The gate
`PASS` requires **both**:
1. **overall total ≥ 70**, and
2. **no failing security category** — a `security=yes` category fails if it scores `< 50%` of its
   max. Security is mandatory: a strong total cannot buy a pass if a security area is weak.

## Categories (max 100)
| Category | Max | Security |
|----------|-----|----------|
| Functionality | 15 | — |
| Reproducibility & IaC + secure CI | 15 | — |
| Signaling + media encryption | 15 | ✔ |
| Identity (digest + STIR/SHAKEN) | 10 | ✔ |
| Edge/border defense | 10 | ✔ |
| Fraud prevention | 10 | ✔ |
| Observability + detection | 10 | — |
| IR runbooks executed | 10 | ✔ |
| Documentation quality | 5 | — |

Five security categories (55 pts) are gated; a candidate must be *demonstrably secure*, not just
feature-complete — which is the whole point of VoIPSec.
