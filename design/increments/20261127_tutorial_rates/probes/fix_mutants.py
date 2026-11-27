# Runs each named mutant in the scratch copy, restores the file, checks it against the real tree.
import subprocess, sys, re, pathlib, filecmp
M = pathlib.Path("/Users/miguel/.julia/dev/Redstone.jl-worktrees/tutorial_1b_fix")
REF = pathlib.Path("/Users/miguel/.julia/dev/Redstone.jl")
OUT = pathlib.Path(sys.argv[1])
SRC = "examples/src/longitudinal.jl"
CR = '"cascade/δe" => "actuators/δe_cmd", "cascade/δt" => "actuators/δt_cmd"))\n\n"""\n    cruise'
MUTANTS = [
 ("PRISTINE", SRC, None, None),
 ("O04_q_seed_as_theta", SRC, "seed = 3, psd = noise_psd.q", "seed = 5, psd = noise_psd.q"),
 ("O05_theta_seed_as_h", SRC, "seed = 5, psd = noise_psd.θ", "seed = 7, psd = noise_psd.θ"),
 ("O07_piloted_drops_noise_psd", SRC, "sensing = sensing(; noise_psd), cascade = cascade(standby = true)", "sensing = sensing(), cascade = cascade(standby = true)"),
 ("O08_approach_drops_noise_psd", SRC, "vehicle = piloted(solution; noise_psd)", "vehicle = piloted(solution)"),
 ("O15_autopilot_cascade_halved", SRC, CR, CR.replace('"actuators/δt_cmd"))', '"actuators/δt_cmd"),\n          sample_times = (cascade = Relative(2),))')),
 ("O16_autopilot_sensing_cascade_halved", SRC, CR, CR.replace('"actuators/δt_cmd"))', '"actuators/δt_cmd"),\n          sample_times = (sensing = Relative(2), cascade = Relative(2)))')),
 ("O17_approach_vehicle_halved", SRC, '"gear/contact" => "stop/u"))', '"gear/contact" => "stop/u"),\n          sample_times = (vehicle = Relative(2),))'),
]
def testset_of(line):
    lines = (REF / "examples/test/test_longitudinal.jl").read_text().splitlines()
    for i in range(line - 1, -1, -1):
        m = re.search(r'@testset "(.*?)"', lines[i])
        if m and m.group(1) != "Longitudinal":
            return m.group(1)[:100]
    return "?"
OUT.mkdir(exist_ok=True)
names = set(sys.argv[2:])
for name, rel, old, new in MUTANTS:
    if names and not any(name.startswith(n) for n in names):
        continue
    path = M / rel
    text = path.read_text()
    try:
        if old is not None:
            assert text.count(old) == 1, (name, text.count(old))
            path.write_text(text.replace(old, new, 1))
        out = subprocess.run(["julia", "--startup-file=no", "--project=examples/test", "examples/test/runtests.jl",
                              "longitudinal"], cwd=M, capture_output=True, text=True, timeout=1500)
    finally:
        path.write_text(text)
    same = filecmp.cmp(path, REF / rel, shallow=False)
    log = out.stdout + out.stderr
    (OUT / f"{name}.log").write_text(log)
    summary = [l for l in log.splitlines() if l.startswith("Longitudinal")]
    fails = sorted(set(int(n) for n in re.findall(r"(?:Test Failed|Error During Test) at .*?test_longitudinal\.jl:(\d+)", log)))
    print(f"== {name}: {summary[-1].strip() if summary else '(no summary)'}  restored={same}")
    for n in fails:
        print(f"    line {n}: {testset_of(n)}")
    if not summary:
        print("    " + "\n    ".join(log.splitlines()[-15:]))
    sys.stdout.flush()
