#!/usr/bin/env bash
# VoIPSec — AI-slop reviewer aid (F2). Scans tracked Markdown for AI-writing patterns and
# reasoning-slop markers, and prints file:line hits for a human to judge. ADVISORY (always exits 0):
# some hits are legitimate (e.g. a paper titled "A Comprehensive Survey…", or "realm" in digest
# auth). Use it on PRs alongside the CONTRIBUTING "accuracy over trend" rule.
# Run from repo root:  bash course/references/slop-check.sh
set -u
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)" || exit 0

files=$(git ls-files '*.md' | grep -vE 'build_plan|task_plan')   # skip the working logs
[ -n "$files" ] || { echo "no tracked markdown"; exit 0; }

scan() { # <label> <regex>
  local label="$1" re="$2" hits
  hits=$(echo "$files" | xargs grep -niE "$re" 2>/dev/null)
  if [ -n "$hits" ]; then
    echo "• $label:"; echo "$hits" | sed 's/^/    /'
    echo "$hits" | wc -l | tr -d ' '
  else
    echo "0"
  fi
}

total=0
echo "== AI-writing patterns =="
for pair in \
  "AI vocabulary|\\b(crucial|delve|delving|seamless|seamlessly|vibrant|testament|moreover|furthermore|pivotal|holistic|cutting-edge|myriad|underscore|elevate|unlock the|in today.?s world)\\b" \
  "negative parallelism|not just .* (but|it.?s)|isn.?t just|it.?s not just|more than just" \
  "superficial -ing|\\b(highlighting the (importance|need)|showcasing|underscoring the|emphasizing the importance|demonstrating the (importance|power))\\b" \
  "promo/superlative|\\b(state-of-the-art|world-class|revolutionary|unparalleled|best-in-class|highly (scalable|performant))\\b" ; do
  label="${pair%%|*}"; re="${pair#*|}"
  n=$(scan "$label" "$re" | tail -1); total=$((total+n))
done

echo "== reasoning slop (trendslop / correlation-as-causation) =="
for pair in \
  "trendslop|\\b(best practice|industry.?standard|widely (used|adopted|considered)|most (experts|people|vendors)|everyone (uses|does)|de facto)\\b" \
  "causal-claim (check attribution)|\\b(proves that|causes the|directly causes|correlat)\\b" ; do
  label="${pair%%|*}"; re="${pair#*|}"
  n=$(scan "$label" "$re" | tail -1); total=$((total+n))
done

echo
if [ "$total" -eq 0 ]; then
  echo "SLOP CHECK: clean (0 marker hits)"
else
  echo "SLOP CHECK: $total marker hit(s) — review each; many are legitimate (paper titles, technical"
  echo "terms). Fix only genuine slop; cite an authority instead of asserting a trend, and don't"
  echo "present correlation as causation. Advisory only."
fi
exit 0
