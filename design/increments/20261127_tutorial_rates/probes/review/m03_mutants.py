# m03: the reviewer's targeted mutants for the elevator standby gap and jump, in the copy mtree2.
# Reviewer's mutant runner. Runs each mutant in the copy `mtree` (a copy of the review worktree
# without .git), restores the file, and checks it byte for byte against the review worktree.
# Prints the summary and the failing test lines, each mapped to its enclosing testset.
import subprocess, sys, re, pathlib, filecmp
P = pathlib.Path(__file__).resolve().parent
M = P / "mtree2"
REF = P.parent / "tutorial_1b_review"
SRC, TEST = "examples/src/longitudinal.jl", "examples/test/test_longitudinal.jl"

def testset_of(line):
    lines = (REF / TEST).read_text().splitlines()
    for i in range(line - 1, -1, -1):
        m = re.search(r'@testset "(.*?)"', lines[i])
        if m and not lines[i].startswith('@testset "Longitudinal"'):
            return m.group(1)[:90]
    return "?"

MUTANTS = [
 ("P01_δe_track_from_δt_prev", SRC, '"selection/δe_prev" => "cascade/δe_track"', '"selection/δt_prev" => "cascade/δe_track"'),
 ("P02_q_ctl_Tt_2s", SRC, "q_ctl = pid(Kp = -0.2, Ki = -0.4, u_min = -0.5, u_max = 0.5),\n             V_ctl",
  "q_ctl = DiscretePID(Kp = -0.2, Ki = -0.4, u_min = -0.5, u_max = 0.5, Tt = 2.0, hold = true, tracking = standby),\n             V_ctl"),
 ("P03_q_ctl_Tt_0p2", SRC, "q_ctl = pid(Kp = -0.2, Ki = -0.4, u_min = -0.5, u_max = 0.5),\n             V_ctl",
  "q_ctl = DiscretePID(Kp = -0.2, Ki = -0.4, u_min = -0.5, u_max = 0.5, Tt = 0.2, hold = true, tracking = standby),\n             V_ctl"),
]

def run(name, rel, old, new):
    path = M / rel
    text = path.read_text()
    assert text.count(old) == 1, (name, text.count(old))
    try:
        path.write_text(text.replace(old, new, 1))
        out = subprocess.run(["julia", "--startup-file=no", "--project=examples/test", "examples/test/runtests.jl",
                              "longitudinal"], cwd=M, capture_output=True, text=True, timeout=1500)
    finally:
        path.write_text(text)
    same = filecmp.cmp(path, REF / rel, shallow=False)
    log = out.stdout + out.stderr
    (P / "m03_logs").mkdir(exist_ok=True)
    (P / "m03_logs" / f"{name}.log").write_text(log)
    summary = [l for l in log.splitlines() if l.startswith("Longitudinal")]
    fails = sorted(set(int(n) for n in re.findall(r"(?:Test Failed|Error During Test) at .*?test_longitudinal\.jl:(\d+)", log)))
    print(f"== {name}: {summary[-1].strip() if summary else '(no summary)'}  restored={same}")
    for n in fails:
        print(f"    line {n}: {testset_of(n)}")
    if not summary or (not fails and 'Fail' in (summary[-1] if summary else '')):
        print("    " + "\n    ".join(log.splitlines()[-6:]))
    sys.stdout.flush()

names = set(sys.argv[1:])
for name, rel, old, new in MUTANTS:
    if not names or any(name.startswith(n) for n in names):
        run(name, rel, old, new)
