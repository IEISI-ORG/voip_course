# Quiz Bank (C0)

Per-module multiple-choice questions in a single machine-readable file
([`quiz-bank.json`](quiz-bank.json)), security-focused, one+ per module (M0–M19 + M10).

## Format
```json
{ "id": "m12-1", "module": "M12", "topic": "...",
  "q": "question text",
  "options": ["A","B","C","D"],
  "answer": 0 }         // 0-based index of the correct option
```

## Validate
```bash
bash verify.sh
```
Checks: valid JSON, ≥4 options and an in-range `answer` per question, every module M0–M19 (+M10)
covered, and that correct answers aren't clustered on one position (anti-gaming).

## HTML exam (E1)
```bash
bash build-exam.sh        # regenerate exam.html from quiz-bank.json
```
`exam.html` is a **self-contained** page (data inlined, no external scripts) that scores
client-side and works from `file://` — double-click to run, or host it statically.

> **Practice tool, not a proctored exam.** Client-side scoring means the answers ship in the page.
> A real graded sitting must score server-side. `verify.sh` fails if `exam.html` drifts from the
> bank (regenerate + commit when you edit questions).

## Use
- Instructors: pull questions by `module` for per-module quizzes.
- Extend by adding entries; keep `answer` correct and vary its position; re-run `build-exam.sh`.

> Keep the bank a **subset of** and consistent with the module content; answers trace to the
> module's security takeaway (see `topic`).
