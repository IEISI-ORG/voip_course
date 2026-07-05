#!/usr/bin/env bash
# VoIPSec — validate the MC quiz bank (offline, deterministic, fail-closed). Checks JSON structure,
# valid answer indices, per-module coverage, and that correct answers aren't clustered on one option.
# Run:  bash course/assessments/quiz-bank/verify.sh
set -u
cd "$(dirname "$0")" || exit 3
command -v python3 >/dev/null 2>&1 || { echo "needs python3"; exit 3; }

python3 - quiz-bank.json <<'PY'
import json, sys, collections
data = json.load(open(sys.argv[1]))
qs = data.get("questions", [])
issues = []; modules = set(); answer_pos = collections.Counter()

for q in qs:
    qid = q.get("id","?")
    opts = q.get("options",[])
    ans = q.get("answer", None)
    if len(opts) < 4: issues.append(f"{qid}: <4 options")
    if not isinstance(ans, int) or not (0 <= ans < len(opts)):
        issues.append(f"{qid}: answer index {ans} out of range")
    else:
        answer_pos[ans] += 1
    if not q.get("q"): issues.append(f"{qid}: empty question text")
    modules.add(q.get("module",""))

need = ["M0","M1","M2","M3","M4","M5","M6","M7","M8","M9","M10","M11","M12","M13","M14","M15","M16","M17","M18"]
missing = [m for m in need if m not in modules]
if missing: issues.append("modules with no question: " + ",".join(missing))

# distribution: no single answer position should hold > 60% of questions
if qs:
    top = max(answer_pos.values())
    if top > 0.6*len(qs):
        issues.append(f"answers clustered: position {answer_pos.most_common(1)[0][0]} holds {top}/{len(qs)}")

print(f"questions: {len(qs)}  modules covered: {len(modules)}  answer-position spread: {dict(answer_pos)}")
if issues:
    print("QUIZ BANK: FAIL")
    for i in issues: print("  -", i)
    sys.exit(1)
print("QUIZ BANK: PASS")
PY
qb=$?
[ "$qb" -eq 0 ] || exit 1

echo "== E1 HTML exam is generated, self-contained, and in sync =="
efail=0
bash build-exam.sh >/dev/null 2>&1 && echo "  ok: exam.html regenerates" || { echo "  FAIL: build-exam.sh"; efail=1; }
if grep -qE 'src="https?://|href="https?://' exam.html; then echo "  FAIL: exam.html loads an external resource"; efail=1; else echo "  ok: no external resources (self-contained)"; fi
grep -q 'id="quizdata"' exam.html && echo "  ok: quiz data embedded" || { echo "  FAIL: no embedded quiz data"; efail=1; }
qn=$(python3 -c "import re,json,sys; m=re.search(r'application/json\">(.*?)</script>', open('exam.html').read(), re.S); print(len(json.loads(m.group(1))['questions']))" 2>/dev/null)
bn=$(python3 -c "import json; print(len(json.load(open('quiz-bank.json'))['questions']))" 2>/dev/null)
[ -n "$qn" ] && [ "$qn" = "$bn" ] && echo "  ok: exam has all $qn bank questions (in sync)" || { echo "  FAIL: exam/bank question count mismatch ($qn vs $bn)"; efail=1; }
# fail if a tracked exam.html would differ from freshly-generated (drift)
if command -v git >/dev/null 2>&1 && git ls-files --error-unmatch exam.html >/dev/null 2>&1; then
  git diff --quiet -- exam.html && echo "  ok: committed exam.html matches the bank" || { echo "  FAIL: exam.html is stale — run build-exam.sh and commit"; efail=1; }
fi
[ "$efail" -eq 0 ] && echo "E1 EXAM: PASS" || { echo "E1 EXAM: FAIL"; exit 1; }
