# Quiz Bank (C0)

Per-module multiple-choice questions in a single machine-readable file
([`quiz-bank.json`](quiz-bank.json)), security-focused, one+ per module (M0–M17 + M9D).

## Format
```json
{ "id": "m11-1", "module": "M11", "topic": "...",
  "q": "question text",
  "options": ["A","B","C","D"],
  "answer": 0 }         // 0-based index of the correct option
```

## Validate
```bash
bash verify.sh
```
Checks: valid JSON, ≥4 options and an in-range `answer` per question, every module M0–M17 (+M9D)
covered, and that correct answers aren't clustered on one position (anti-gaming).

## Use
- Instructors: pull questions by `module` for per-module quizzes.
- This file is the input for **E1** — a self-contained HTML exam that scores client-side.
- Extend by adding entries; keep `answer` correct and vary its position.

> Keep the bank a **subset of** and consistent with the module content; answers trace to the
> module's security takeaway (see `topic`).
