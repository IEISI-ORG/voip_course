#!/usr/bin/env bash
# SOVOC M16 acceptance test — the automation/CI is valid and the repo passes its own lint
# (offline, deterministic, fail-closed). Mirrors what CI runs on every change.
# Run from lab/:  bash labs/m16-testing-cloud/verify.sh
set -u
cd "$(dirname "$0")/../.." || exit 3      # -> lab/
ROOT=..                                    # repo root (lab/ is one down)

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. CI workflow valid + has key gates =="
CI="$ROOT/.github/workflows/ci.yml"
if [ -f "$CI" ] && python3 -c "import yaml,sys; list(yaml.safe_load_all(open('$CI')))" 2>/dev/null; then
  ok "ci.yml is valid YAML"
  for step in "docker compose config" "Offline graders" "Shell syntax"; do
    grep -q "$step" "$CI" && ok "CI has step: $step" || bad "CI missing step: $step"
  done
  grep -q 'github.event' "$CI" && bad "CI uses untrusted github.event in run (injection risk)" || ok "no github.event injection surface"
else
  bad "ci.yml missing or invalid YAML"
fi

echo "== 2. repo shell scripts all parse (local lint = CI lint) =="
if find . "$ROOT/course" -name '*.sh' -print0 2>/dev/null | xargs -0 -n1 bash -n 2>/dev/null; then
  ok "all shell scripts pass bash -n"
else
  bad "a shell script failed bash -n"
fi

echo "== 3. load-test runner present =="
[ -x labs/m16-testing-cloud/load-test.sh ] && ok "load-test.sh present" || bad "load-test.sh missing"

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "M16 ACCEPTANCE: PASS"; exit 0; } || { echo "M16 ACCEPTANCE: FAIL"; exit 1; }
