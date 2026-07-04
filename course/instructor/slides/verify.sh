#!/usr/bin/env bash
# VoIPSec D0 — validate the generated MARP decks (offline, deterministic, fail-closed & in-sync).
# Run:  bash course/instructor/slides/verify.sh
set -u
cd "$(dirname "$0")" || exit 3

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. decks regenerate =="
bash build-slides.sh >/dev/null 2>&1 && ok "build-slides.sh runs" || bad "build-slides.sh failed"

echo "== 2. one deck per module =="
mods=$(ls ../../modules/*.md | wc -l | tr -d ' ')
decks=$(ls *.md 2>/dev/null | grep -v '^README' | wc -l | tr -d ' ')
[ "$mods" = "$decks" ] && ok "$decks decks for $mods modules" || bad "deck/module mismatch ($decks vs $mods)"

echo "== 3. every deck has MARP front-matter + a title slide =="
missing=0
for d in *.md; do [ "$d" = "README.md" ] && continue
  head -6 "$d" | grep -q 'marp: true' || { echo "    no marp front-matter: $d"; missing=1; }
  grep -q '^# ' "$d" || { echo "    no title slide: $d"; missing=1; }
done
[ "$missing" -eq 0 ] && ok "all decks are MARP-valid with a title slide" || bad "a deck is malformed"

echo "== 4. decks are in sync with the module docs (no drift) =="
if command -v git >/dev/null 2>&1 && git ls-files --error-unmatch 00-orientation-and-lab.md >/dev/null 2>&1; then
  git diff --quiet -- . && ok "committed decks match freshly generated" || bad "decks stale — run build-slides.sh and commit"
else
  echo "  NOTE: decks not yet tracked — commit them (first run)"
fi

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "SLIDES: PASS"; exit 0; } || { echo "SLIDES: FAIL"; exit 1; }
