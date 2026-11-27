# Runs r09_candidates.jl in the copy `mtree2` under each named mutant of m01_mutants.py (and unmutated
# first), restoring and checking each file byte for byte against the review worktree.
import subprocess, sys, pathlib, filecmp
P = pathlib.Path(__file__).resolve().parent
M = P / "mtree2"
REF = P.parent / "tutorial_1b_review"
src = (P / "m01_mutants.py").read_text().split("def run")[0]
ns = {"__file__": str(P / "m01_mutants.py")}
exec(src, ns)
table = {m[0]: m for m in ns["MUTANTS"]}
def go(name):
    if name == "none":
        rel = None
    else:
        _, rel, old, new = table[name]
        path = M / rel; text = path.read_text(); assert text.count(old) == 1
    try:
        if rel: path.write_text(text.replace(old, new, 1))
        out = subprocess.run(["julia", "--startup-file=no", "--project=examples/test", str(P / "r09_candidates.jl")],
                             cwd=M, capture_output=True, text=True, timeout=1500)
    finally:
        if rel: path.write_text(text)
    same = True if not rel else filecmp.cmp(path, REF / rel, shallow=False)
    lines = [l for l in (out.stdout + out.stderr).splitlines() if l.startswith(("PASS", "FAIL", "ERROR", "Redstone"))]
    print(f"== {name} restored={same}"); [print("   ", l[:200]) for l in lines]; sys.stdout.flush()
for n in sys.argv[1:]:
    go(n)
