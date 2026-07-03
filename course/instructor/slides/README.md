# Instructor Slide Decks (D0)

One MARP deck per module, **generated from the module docs** (single source of truth) — objectives,
the 5-beat sections, speaker notes, and a lab/assessment closer.

## Build & validate
```bash
bash build-slides.sh     # (re)generate <module>.md decks from ../../modules/*.md
bash verify.sh           # decks exist per module, MARP-valid, and in sync (drift fails)
```

## Rendering (E4)
These `.md` decks are MARP source. Rendering to HTML/PDF is E4 (see `../marp/`): Makefile-driven
`marp-cli`, with a Playwright render check under a headless X server (`xvfb-run`).

## Editing
Edit the **module doc**, not the deck — rerun `build-slides.sh` and commit. `verify.sh` fails if a
committed deck drifts from its module. Speaker notes are MARP HTML comments (`<!-- ... -->`),
shown in MARP presenter mode, hidden on the slide.
