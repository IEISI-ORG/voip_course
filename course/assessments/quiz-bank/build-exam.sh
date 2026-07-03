#!/usr/bin/env bash
# SOVOC E1 — generate a self-contained HTML exam from quiz-bank.json (single source of truth).
# The data is inlined (works from file://; no fetch/CORS), and there are NO external scripts
# (no CDN/SRI exposure). Client-side scoring => this is a PRACTICE/self-assessment tool, not a
# proctored exam. Run:  bash build-exam.sh   ->  exam.html
set -u
cd "$(dirname "$0")" || exit 3
command -v python3 >/dev/null 2>&1 || { echo "needs python3"; exit 3; }
python3 - <<'PY'
import json
data = open("quiz-bank.json").read()
json.loads(data)  # fail early if the bank is invalid
TEMPLATE = r"""<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>SOVOC Practice Exam</title>
<style>
 body{font:16px/1.5 system-ui,sans-serif;max-width:820px;margin:2rem auto;padding:0 1rem;color:#111}
 h1{margin-bottom:.2rem} .sub{color:#666;margin-top:0}
 .q{border:1px solid #ddd;border-radius:8px;padding:1rem;margin:1rem 0}
 .q .mod{font-size:.8rem;color:#0a6;font-weight:600}
 label{display:block;padding:.25rem 0;cursor:pointer}
 button{font-size:1rem;padding:.6rem 1.2rem;border:0;border-radius:6px;background:#0a6;color:#fff;cursor:pointer}
 #result{font-size:1.2rem;font-weight:700;margin:1rem 0;padding:1rem;border-radius:8px}
 .pass{background:#e6f7ee;color:#0a6} .fail{background:#fdecea;color:#c0392b}
 .ok{color:#0a6} .no{color:#c0392b} .correct{font-weight:600}
</style></head><body>
<h1>SOVOC Practice Exam</h1>
<p class="sub">Self-assessment (answers are scored in your browser). Pass mark 70%.</p>
<form id="exam"></form>
<button id="submit">Submit &amp; score</button>
<div id="result" hidden></div>
<script id="quizdata" type="application/json">
__QUIZDATA__
</script>
<script>
(function(){
  var data = JSON.parse(document.getElementById("quizdata").textContent);
  var qs = data.questions || [], form = document.getElementById("exam");
  qs.forEach(function(q,i){
    var div = document.createElement("div"); div.className="q";
    var h = document.createElement("div"); h.className="mod"; h.textContent = q.module + " · " + (q.topic||"");
    var p = document.createElement("p"); p.textContent = (i+1)+". "+q.q; p.style.fontWeight="600";
    div.appendChild(h); div.appendChild(p);
    (q.options||[]).forEach(function(opt,j){
      var lab=document.createElement("label");
      var r=document.createElement("input"); r.type="radio"; r.name="q"+i; r.value=j;
      lab.appendChild(r); lab.appendChild(document.createTextNode(" "+opt));
      div.appendChild(lab);
    });
    var fb=document.createElement("div"); fb.id="fb"+i; div.appendChild(fb);
    form.appendChild(div);
  });
  document.getElementById("submit").onclick=function(){
    var correct=0;
    qs.forEach(function(q,i){
      var sel=form.querySelector('input[name="q'+i+'"]:checked');
      var fb=document.getElementById("fb"+i);
      var got = sel? parseInt(sel.value,10) : -1;
      if(got===q.answer){ correct++; fb.className="ok"; fb.textContent="✓ correct"; }
      else { fb.className="no"; fb.innerHTML="✗ correct answer: <span class='correct'>"+q.options[q.answer]+"</span>"; }
    });
    var pct=Math.round(100*correct/qs.length);
    var r=document.getElementById("result"); r.hidden=false;
    r.className = pct>=70 ? "pass":"fail";
    r.textContent = "Score: "+correct+"/"+qs.length+" ("+pct+"%) — "+(pct>=70?"PASS":"try again");
    r.scrollIntoView({behavior:"smooth"});
  };
})();
</script>
</body></html>
"""
open("exam.html","w").write(TEMPLATE.replace("__QUIZDATA__", data))
print("wrote exam.html (%d questions)" % len(json.loads(data)["questions"]))
PY
