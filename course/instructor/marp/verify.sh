#!/usr/bin/env bash
# VoIPSec E4 — build the MARP decks and validate rendering with Playwright under xvfb.
# Needs marp-cli, node+playwright, xvfb-run (see README `make deps`). If the toolchain is absent
# (e.g. CI without a browser), it reports SKIP rather than a false failure — run it where the
# tooling exists. Run:  bash course/instructor/marp/verify.sh
set -u
cd "$(dirname "$0")" || exit 3

have(){ command -v "$1" >/dev/null 2>&1; }
if ! have marp || ! have node || ! have xvfb-run || ! node -e "require.resolve('playwright')" 2>/dev/null; then
  echo "SKIP: marp / node+playwright / xvfb-run not all present — run 'make deps' on a host with the toolchain."
  exit 0
fi

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. decks render to HTML =="
make html >/dev/null 2>&1 && ok "marp rendered decks" || bad "marp render failed"
n=$(ls out/[0-9]*.html 2>/dev/null | wc -l | tr -d ' ')
[ "$n" -ge 19 ] && ok "$n deck HTML files produced" || bad "expected >=19 decks, got $n"

echo "== 2. Playwright render check (headless X) =="
if xvfb-run -a node render-check.js out 2>/dev/null | grep -q 'RENDER CHECK: PASS'; then
  ok "all decks render with no page errors"
else
  bad "a deck failed the render check"
fi

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "MARP: PASS"; exit 0; } || { echo "MARP: FAIL"; exit 1; }
