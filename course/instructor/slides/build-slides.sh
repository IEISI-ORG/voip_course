#!/usr/bin/env bash
# VoIPSec D0 — generate MARP slide-outline decks from the module docs (single source of truth).
# One deck per module in slides/<name>.md. Rerun after editing a module; E4 renders these.
# Run:  bash build-slides.sh
set -u
cd "$(dirname "$0")" || exit 3
command -v python3 >/dev/null 2>&1 || { echo "needs python3"; exit 3; }

python3 - <<'PY'
import glob, os, re

MODDIR = os.path.abspath("../../modules")
OUT = os.path.abspath(".")
# sections we turn into slides (by keyword in the heading); skip References/Assessment/Curriculum add.
KEEP = ["Learning Objectives","Concept","Packet Reality","Build","Attack","Labs"]
SKIP = ["References","Assessment","Curriculum addition"]

def bullets(block, cap=6):
    out=[]
    for ln in block.splitlines():
        s=ln.strip()
        if s.startswith("- ") or re.match(r"^- \*\*", s):
            out.append(s)
        if len(out)>=cap: break
    return out

built=0; skipped=0
for path in sorted(glob.glob(os.path.join(MODDIR,"*.md"))):
    name=os.path.splitext(os.path.basename(path))[0]
    outpath_existing=os.path.join(OUT, name+".md")
    # Non-destructive: never clobber a hand-authored full deck (marked deck-status: authored).
    if os.path.exists(outpath_existing) and "deck-status: authored" in open(outpath_existing).read():
        skipped+=1
        continue
    txt=open(path).read()
    mtitle=re.search(r"^#\s+(.+)$", txt, re.M)
    title=mtitle.group(1).strip() if mtitle else name
    one=re.search(r"\*\*One-liner:\*\*\s*(.+?)(?:\*\*Est|\n\n|$)", txt, re.S)
    oneliner=" ".join(one.group(1).split()) if one else ""

    # split into (heading, body) by '## '
    parts=re.split(r"^##\s+", txt, flags=re.M)[1:]
    slides=[]
    for p in parts:
        head=p.splitlines()[0].strip()
        if any(k.lower() in head.lower() for k in SKIP): continue
        if not any(k.lower() in head.lower() for k in KEEP): continue
        body="\n".join(p.splitlines()[1:])
        bs=bullets(body)
        if bs: slides.append((head, bs))

    deck=[]
    deck.append("---\nmarp: true\ntheme: default\npaginate: true\n"
                f"title: {title}\n---\n")
    deck.append(f"# {title}\n\n{oneliner}\n\n<!-- Instructor: set the scene; ~{max(4,len(slides))*5} min. "
                "Every module ends with a hands-on lab + fail-closed verify.sh. -->")
    for head, bs in slides:
        notes = "<!-- Speaker note: connect this beat to the module's security takeaway. -->"
        deck.append("---\n\n## " + head + "\n\n" + "\n".join(bs) + "\n\n" + notes)
    deck.append("---\n\n## Lab & assessment\n\n- Hands-on lab with a fail-closed `verify.sh`; "
                "rubric 100 pts, pass ≥ 70.\n- Update your living threat model + hardening checklist.\n"
                "\n<!-- Speaker note: point learners at lab/labs/<module>/. -->")
    open(os.path.join(OUT, name+".md"),"w").write("\n".join(deck)+"\n")
    built+=1

print(f"generated {built} scaffold decks, skipped {skipped} authored, in {OUT}")
PY
