#!/usr/bin/env bash
# SOVOC — validate the MC quiz bank (offline, deterministic, fail-closed). Checks JSON structure,
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

need = ["M0","M1","M2","M3","M4","M5","M6","M7","M8","M9","M9D","M10","M11","M12","M13","M14","M15","M16","M17"]
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
