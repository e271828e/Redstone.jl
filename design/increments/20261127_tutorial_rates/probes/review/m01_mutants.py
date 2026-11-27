# Reviewer's mutant runner. Runs each mutant in the copy `mtree` (a copy of the review worktree
# without .git), restores the file, and checks it byte for byte against the review worktree.
# Prints the summary and the failing test lines, each mapped to its enclosing testset.
import subprocess, sys, re, pathlib, filecmp
P = pathlib.Path(__file__).resolve().parent
M = P / "mtree"
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
 # the record's
 ("R01_V_meas_from_plant_h", SRC, '"sensing/V_meas" => "cascade/V_meas",', '"plant/h" => "cascade/V_meas",'),
 ("R01b_V_meas_from_h_meas", SRC, '"sensing/V_meas" => "cascade/V_meas",', '"sensing/h_meas" => "cascade/V_meas",'),
 ("R02_latch_anchored", SRC, "sample_times = (latch = Relative(sensor_multipliers.air_data),))", "sample_times = (latch = Absolute(1//10),))"),
 ("R03_ins_multiplier_5", SRC, "const sensor_multipliers = (imu = 1, ins = 4, air_data = 20)", "const sensor_multipliers = (imu = 1, ins = 5, air_data = 20)"),
 ("R04_theta_ctl_at_imu", SRC, "θ_ctl = Relative(sensor_multipliers.ins),", "θ_ctl = Relative(sensor_multipliers.imu),"),
 ("R05_ins_sensor_at_imu", SRC, "ins = Relative(sensor_multipliers.ins),", "ins = Relative(sensor_multipliers.imu),"),
 ("R06_imu_sensor_at_ins", SRC, "sample_times = (imu = Relative(sensor_multipliers.imu),", "sample_times = (imu = Relative(sensor_multipliers.ins),"),
 ("R07_latch_default", SRC, "sample_times = (latch = Relative(sensor_multipliers.air_data),))", "sample_times = (;))"),
 ("R08_delay_at_air_data", SRC, "sample_times = (latch = Relative(sensor_multipliers.air_data),))", "sample_times = (latch = Relative(sensor_multipliers.air_data), command_δe = Relative(sensor_multipliers.air_data)))"),
 ("R09_slower_no_dt_base", TEST, "slower = Simulation(piloted(solution); Δt_frame = 1//400, Δt_base = 1//100)", "slower = Simulation(piloted(solution); Δt_frame = 1//400)"),
 ("R10_test_no_dt_base", TEST, "loop_deployment = (Δt_frame = 1//400, Δt_base = 1//200)", "loop_deployment = (Δt_frame = 1//400,)"),
 ("R11_q_ctl_Kp", SRC, "\n             q_ctl = pid(Kp = -0.2, Ki = -0.4", "\n             q_ctl = pid(Kp = -0.3, Ki = -0.4"),
 ("R12_Tt_tenfold", SRC, "Tt = 0.02, hold = true, tracking = standby", "Tt = 0.2, hold = true, tracking = standby"),
 ("R13_q_psd_from_theta", SRC, "GaussianWhiteNoise(seed = 3, psd = noise_psd.q)", "GaussianWhiteNoise(seed = 3, psd = noise_psd.θ)"),
 ("R14_V_psd_raised", SRC, "h = 1.8e-3, V = 4.0e-5)", "h = 1.8e-3, V = 2.5e-4)"),
 ("R15_measurement_noiseless", SRC, "y_direct(::Measurement, (; u)) = u.signal + u.noise", "y_direct(::Measurement, (; u)) = u.signal"),
 ("R16_V_seed_as_h", SRC, "GaussianWhiteNoise(seed = 11, psd = noise_psd.V)", "GaussianWhiteNoise(seed = 7, psd = noise_psd.V)"),
 ("R17_h_ctl_tracks_q", SRC, '(("θ_ctl/y", "h_ctl/v"), ("q_ctl/y", "θ_ctl/v"))', '(("θ_ctl/y",), ("q_ctl/y", "θ_ctl/v", "h_ctl/v"))'),
 ("R18_q_ctl_anchored_400", SRC, "q_ctl = Relative(sensor_multipliers.imu), V_ctl", "q_ctl = Absolute(1//400), V_ctl"),
 ("R19_q_ctl_entry_omitted", SRC, "\n                          q_ctl = Relative(sensor_multipliers.imu), V_ctl", "\n                          V_ctl"),
 # the reviewer's
 ("O01_plant_q_theta_swapped", SRC, '"plant/q" => "sensing/q", "plant/θ" => "sensing/θ",', '"plant/q" => "sensing/θ", "plant/θ" => "sensing/q",'),
 ("O02_meas_q_theta_swapped", SRC, '"sensing/q_meas" => "cascade/q_meas", "sensing/θ_meas" => "cascade/θ_meas",', '"sensing/q_meas" => "cascade/θ_meas", "sensing/θ_meas" => "cascade/q_meas",'),
 ("O03_air_data_noises_swapped", SRC, '"h_noise/y" => "h_meas/noise", "V_noise/y" => "V_meas/noise"', '"h_noise/y" => "V_meas/noise", "V_noise/y" => "h_meas/noise"'),
 ("O04_q_seed_as_theta", SRC, "seed = 3, psd = noise_psd.q", "seed = 5, psd = noise_psd.q"),
 ("O05_theta_seed_as_h", SRC, "seed = 5, psd = noise_psd.θ", "seed = 7, psd = noise_psd.θ"),
 ("O06_q_seed_13", SRC, "seed = 3, psd = noise_psd.q", "seed = 13, psd = noise_psd.q"),
 ("O07_piloted_drops_noise_psd", SRC, "sensing = sensing(; noise_psd), cascade = cascade(standby = true)", "sensing = sensing(), cascade = cascade(standby = true)"),
 ("O08_approach_drops_noise_psd", SRC, "vehicle = piloted(solution; noise_psd)", "vehicle = piloted(solution)"),
 ("O09_autopilot_drops_noise_psd", SRC, "sensing = sensing(; noise_psd), cascade = cascade(),", "sensing = sensing(), cascade = cascade(),"),
 ("O10_q_psd_from_constant", SRC, "psd = noise_psd.q)", "psd = sensor_noise_psd.q)"),
 ("O11_V_psd_from_constant", SRC, "psd = noise_psd.V)", "psd = sensor_noise_psd.V)"),
 ("O12_V_ctl_at_ins", SRC, "V_ctl = Relative(sensor_multipliers.air_data))", "V_ctl = Relative(sensor_multipliers.ins))"),
 ("O13_h_ctl_at_ins", SRC, "h_ctl = Relative(sensor_multipliers.air_data), θ_ctl", "h_ctl = Relative(sensor_multipliers.ins), θ_ctl"),
 ("O14_latch_at_ins", SRC, "sample_times = (latch = Relative(sensor_multipliers.air_data),))", "sample_times = (latch = Relative(sensor_multipliers.ins),))"),
 ("O15_autopilot_cascade_halved", SRC, '"cascade/δe" => "actuators/δe_cmd", "cascade/δt" => "actuators/δt_cmd"))\n\n"""\n    cruise', '"cascade/δe" => "actuators/δe_cmd", "cascade/δt" => "actuators/δt_cmd"),\n          sample_times = (cascade = Relative(2),))\n\n"""\n    cruise'),
 ("O16_autopilot_sensing_cascade_halved", SRC, '"cascade/δe" => "actuators/δe_cmd", "cascade/δt" => "actuators/δt_cmd"))\n\n"""\n    cruise', '"cascade/δe" => "actuators/δe_cmd", "cascade/δt" => "actuators/δt_cmd"),\n          sample_times = (sensing = Relative(2), cascade = Relative(2)))\n\n"""\n    cruise'),
 ("O17_approach_vehicle_halved", SRC, '"gear/contact" => "stop/u"))', '"gear/contact" => "stop/u"),\n          sample_times = (vehicle = Relative(2),))'),
 ("O18_measurement_sign", SRC, "y_direct(::Measurement, (; u)) = u.signal + u.noise", "y_direct(::Measurement, (; u)) = u.signal - u.noise"),
 ("O19_theta_ctl_tracks_theta", SRC, '(("θ_ctl/y", "h_ctl/v"), ("q_ctl/y", "θ_ctl/v"))', '(("θ_ctl/y", "h_ctl/v", "θ_ctl/v"), ("q_ctl/y",))'),
 ("O20_theta_psd_raised", SRC, "(q = 2.0e-8, θ = 5.0e-9,", "(q = 2.0e-8, θ = 2.0e-8,"),
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
    (P / "m01_logs").mkdir(exist_ok=True)
    (P / "m01_logs" / f"{name}.log").write_text(log)
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
