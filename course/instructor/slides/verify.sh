#!/usr/bin/env bash
# VoIPSec D0 — validate the MARP decks (offline, deterministic, fail-closed).
# Model: decks are HAND-AUTHORED source of truth. build-slides.sh only *scaffolds* un-authored
# modules and never clobbers a deck marked `deck-status: authored`. This script therefore checks
# structure + an authoring quality bar (not byte-equality with the generator).
# Run:  bash course/instructor/slides/verify.sh
set -u
cd "$(dirname "$0")" || exit 3

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. scaffolder runs (and preserves authored decks) =="
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

echo "== 4. authored decks meet the full-deck quality bar =="
authored=0; qbad=0
for d in *.md; do [ "$d" = "README.md" ] && continue
  grep -q 'deck-status: authored' "$d" || continue
  authored=$((authored+1))
  slides=$(grep -c '^---$' "$d")            # front-matter + slide separators
  notes=$(grep -c 'Speaker:' "$d")           # instructor speaker notes
  # every module deck needs a Lab slide; the capstone is a deliverables/runbook deck (no per-module lab)
  labs=$(grep -cE '^## .*(Lab|Deliverable|Runbook|Rubric)' "$d")
  [ "$slides" -ge 10 ] || { echo "    $d: only $slides separators (<10) — too thin"; qbad=1; }
  [ "$notes"  -ge 4 ]  || { echo "    $d: only $notes speaker notes (<4)"; qbad=1; }
  [ "$labs"   -ge 1 ]  || { echo "    $d: no Lab/Deliverable slide"; qbad=1; }
done
[ "$qbad" -eq 0 ] && ok "all $authored authored deck(s) meet the bar" || bad "an authored deck is below the bar"

echo "== 5. authoring progress =="
echo "  authored: $authored / $decks decks  (scaffolded: $((decks-authored)))"

echo "== 6. readability / per-page fit =="
echo "  NOTE: rendered readability + per-slide overflow are checked by the marp render gate"
echo "        (chromium under xvfb): cd ../marp && make check   — asserts no slide overflows its page."

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "SLIDES: PASS"; exit 0; } || { echo "SLIDES: FAIL"; exit 1; }
