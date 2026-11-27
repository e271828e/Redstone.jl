# The mutants of the new and moved pins, run one at a time against the longitudinal testset in
# the worktree: each edits the source in place, runs the file, restores the source byte for
# byte, and prints the summary and the failing testsets. Run from anywhere:
#   python3 mutants.py [name ...]
import subprocess, sys, re, pathlib

WT = pathlib.Path(__file__).resolve().parent.parent / "tutorial_1b"
SRC = WT / "examples/src/longitudinal.jl"
TEST = WT / "examples/test/test_longitudinal.jl"

MUTANTS = [
    ("ins_multiplier_5", "const sensor_multipliers = (imu = 1, ins = 4, air_data = 20)",
     "const sensor_multipliers = (imu = 1, ins = 5, air_data = 20)"),
    ("theta_ctl_at_imu", "θ_ctl = Relative(sensor_multipliers.ins),\n                          q_ctl",
     "θ_ctl = Relative(sensor_multipliers.imu),\n                          q_ctl"),
    ("ins_sensor_at_imu", "ins = Relative(sensor_multipliers.ins),\n                          air_data",
     "ins = Relative(sensor_multipliers.imu),\n                          air_data"),
    ("imu_sensor_at_ins", "sample_times = (imu = Relative(sensor_multipliers.imu),",
     "sample_times = (imu = Relative(sensor_multipliers.ins),"),
    ("latch_default", "sample_times = (latch = Relative(sensor_multipliers.air_data),))",
     "sample_times = (;))"),
    ("latch_anchored", "sample_times = (latch = Relative(sensor_multipliers.air_data),))",
     "sample_times = (latch = Absolute(1//10),))"),
    ("q_ctl_entry_omitted", "\n                          q_ctl = Relative(sensor_multipliers.imu), V_ctl",
     "\n                          V_ctl"),
    ("delay_at_air_data", "sample_times = (latch = Relative(sensor_multipliers.air_data),))",
     "sample_times = (latch = Relative(sensor_multipliers.air_data), command_δe = Relative(sensor_multipliers.air_data)))"),
    ("V_seed_as_h", "GaussianWhiteNoise(seed = 11, psd = noise_psd.V)", "GaussianWhiteNoise(seed = 7, psd = noise_psd.V)"),
    ("q_psd_from_theta", "GaussianWhiteNoise(seed = 3, psd = noise_psd.q)", "GaussianWhiteNoise(seed = 3, psd = noise_psd.θ)"),
    ("V_psd_raised", "h = 1.8e-3, V = 4.0e-5)", "h = 1.8e-3, V = 2.5e-4)"),
    ("measurement_noiseless", "y_direct(::Measurement, (; u)) = u.signal + u.noise", "y_direct(::Measurement, (; u)) = u.signal"),
    ("h_ctl_tracks_q", '(("θ_ctl/y", "h_ctl/v"), ("q_ctl/y", "θ_ctl/v"))',
     '(("θ_ctl/y",), ("q_ctl/y", "θ_ctl/v", "h_ctl/v"))'),
    ("Tt_tenfold", "Tt = 0.02, hold = true, tracking = standby", "Tt = 0.2, hold = true, tracking = standby"),
    ("q_ctl_Kp", "\n             q_ctl = pid(Kp = -0.2, Ki = -0.4", "\n             q_ctl = pid(Kp = -0.3, Ki = -0.4"),
    ("V_meas_reads_plant_h", '"sensing/V_meas" => "cascade/V_meas",', '"sensing/h_meas" => "cascade/V_meas",'),
]
# Round 2, under V1 (frame 1//400): the pin from the log, and the deployment's base tick dropped.
MUTANTS += [
    ("q_ctl_anchored_400", "q_ctl = Relative(sensor_multipliers.imu), V_ctl", "q_ctl = Absolute(1//400), V_ctl"),
    ("test_no_dt_base", "loop_deployment = (Δt_frame = 1//400, Δt_base = 1//200)", "loop_deployment = (Δt_frame = 1//400,)", TEST),
]

def run(name, old, new, path=SRC):
    SRC_ = path
    text = SRC_.read_text()
    assert text.count(old) == 1, (name, text.count(old))
    try:
        SRC_.write_text(text.replace(old, new))
        out = subprocess.run(["julia", "--startup-file=no", "--project=examples/test", "examples/test/runtests.jl",
                              "longitudinal"], cwd=WT, capture_output=True, text=True, timeout=1200)
    finally:
        SRC_.write_text(text)
    log = out.stdout + out.stderr
    summary = [l for l in log.splitlines() if l.startswith("Longitudinal")]
    failed = sorted(set(re.findall(r"^(.*?): Test Failed", log, re.M) + re.findall(r"^(.*?): Error During Test", log, re.M)))
    erred = "LoadError" in log or "ERROR:" in log
    print(f"== {name}: {summary[-1] if summary else '(no summary)'}{'  [error]' if erred and not summary else ''}")
    for f in failed:
        print("   ", f[:200])
    if not summary:
        print("   ", "\n    ".join(log.splitlines()[-8:]))
    sys.stdout.flush()

names = set(sys.argv[1:])
for name, old, new, *path in MUTANTS:
    if not names or name in names:
        run(name, old, new, *path)
