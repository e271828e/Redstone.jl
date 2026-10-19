import os, sys, subprocess
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import edits
from wrap import wrap
CH = edits.CH
out = ["# Chapter 13, step 5: editorial fixes, half 1 (units A and B)", "",
"The editorial fixer's log for units A and B. Sources: the EDITORIAL findings",
"of `chapter_pass_1.md` and `chapter_pass_2.md` that fall in units A and B, and",
"`step5_carry.md`'s rewraps for A and B. Pass 2 has no EDITORIAL finding in A",
"or B. Each entry replaces one whole paragraph, list item or table pair of",
"`units/<U>/new.md` at `5f21eba`. Apply the entries in order; each old text",
"occurs exactly once. Every replaced paragraph is rewrapped to 80 rendered",
"columns, link markup, backticks and asterisks collapsed; the table rows are",
"exempt. The `claims.md` changes that keep every span matching follow the",
"entries, as unified diffs against `5f21eba`; `inventory.json` is regenerated",
"by `checks/build_inventory.py`.", ""]
n = 0
for u in "AB":
    orig = open(os.path.join(CH, "scratch_step5/fix1", f"{u}_new.orig.md")).read()
    lines = orig.split("\n"); cur = orig
    out += [f"## Unit {u}", ""]
    for (uu, a, b, ids, what, new, rewrap) in edits.E:
        if uu != u: continue
        n += 1
        old = "\n".join(lines[a - 1:b])
        if rewrap is True: new2 = wrap(new)
        elif rewrap == "blocks": new2 = "\n\n".join(wrap(x) for x in new.split("\n\n"))
        else: new2 = new
        assert cur.count(old) == 1
        cur = cur.replace(old, new2)
        out += [f"### {n}. {ids} (unit {u}, lines {a}–{b} at `5f21eba`)", "", what[0].upper() + what[1:] + ".", "",
                "Old:", "", "~~~~", old, "~~~~", "", "New:", "", "~~~~", new2, "~~~~", ""]
    assert cur == open(os.path.join(CH, "units", u, "new.md")).read(), u
for u in "AB":
    d = subprocess.run(["git", "diff", "5f21eba", "--", f"units/{u}/claims.md"], cwd=CH, capture_output=True, text=True).stdout
    out += [f"## Unit {u}, `claims.md`", "", "~~~~diff", d.rstrip("\n"), "~~~~", ""]
out += open(os.path.join(CH, "scratch_step5/fix1/left.md")).read().rstrip("\n").split("\n") + [""]
open(os.path.join(CH, "chapter_fixes_1.md"), "w").write("\n".join(out))
print("entries", n)
