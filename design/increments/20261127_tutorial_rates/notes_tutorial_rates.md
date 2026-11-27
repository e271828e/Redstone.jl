# Notes: the tutorial's increment 1b, the example's rates and sensing

Increment 1b of `../roadmap_tutorial.md`: the rework of increment 1's
functions that the roadmap's R25 to R28 rule. The rates of chapters 5 to 8
become `Relative` under one constant, and `sensing` measures everything the
cascade reads through three sensors. The prototype is the implementation,
so this file is the increment's record and no brief is written. It holds
the state reached, the rulings local to the increment with their reasons,
the shape built, the measurements, the pins with their mutants, the
friction found, the bookkeeping, what is out of scope and the cold review's
charter. Increment 1's record is
`../20261118_tutorial_example/notes_tutorial_example.md`, and its rulings
L1 to L25 stand unless a ruling below says otherwise.

## 1. The state on 2026-11-27

- The prototype is settled after two rounds of rulings. The patch is
  `prototype_tutorial_rates.patch` beside this file, the worktree's
  `git diff` against `d2cccb07`. It touches four files under `examples/`,
  +209 −118, and `git apply --check` passes on the real tree at `d2cccb07`.
- The prototyper's gate, run in the worktree on Julia 1.13.3 as
  `julia --startup-file=no --project=examples -e 'using Pkg; Pkg.test()'`:
  194 of 194, against 179 of 179 before. It takes about 34 s.
- The worktree is `/Users/miguel/.julia/dev/Redstone.jl-worktrees/tutorial_1b`,
  detached at `d2cccb07`, with the prototyper's own notes
  `tutorial_1b_notes.md` beside it. Its probes are copied to `probes/`
  here, each script with its output, and every figure below comes from
  them.
- The coordinator checked only that the patch equals the worktree's diff
  and that it applies to the real tree. The gate and every figure are the
  prototyper's.
- The prototyper ended at 326k tokens of its 450k stop. It answers only
  the session that launched it.
- Landed since, all local and none pushed: the record as `03b45543`, the
  docs as `f71d9455`, the code as `675c1ac8`, the review's fixes as
  `b5583dd5`, and a rewrap of two docstring lines as `9d5b6710`. The
  examples' gate on the real tree reads 215 of 215 at `9d5b6710`. The
  cold review and its delta check are section 11. What is left is the
  user's review of this record and of section 10, the user's diff of the
  arc, the push, and then the scratch of section 12.

## 2. What the prototype builds

In `examples/src/longitudinal.jl`, between `pitch_hold` and `approach`.
The line ranges are those of `git show d2cccb07:examples/src/longitudinal.jl`.

| Name | Lines replaced | What it is now |
|---|---|---|
| `sensor_multipliers` | new | `(imu = 1, ins = 4, air_data = 20)`, the one constant of R28 |
| `sensor_noise_psd` | new | `(q = 2.0e-8, θ = 5.0e-9, h = 1.8e-3, V = 4.0e-5)`, the four default densities |
| `Measurement()` | 162 to 176, `Altimeter` | a stateless discrete leaf: inputs `signal` and `noise`, the bare output `y = signal + noise` |
| `sensing(; noise_psd)` | 178 to 192 | three groups, `imu`, `ins` and `air_data`, each a `<x>_noise` and a `<x>_meas` per measured variable; inputs `q`, `θ`, `h`, `V`; outputs `q_meas`, `θ_meas`, `h_meas`, `V_meas`; one `Relative` entry per sensor, read from the constant |
| `cascade(; standby)` | 194 to 236 | inputs `h_meas`, `θ_meas`, `q_meas`, `V_meas`; one `Relative` entry per controller, read from the constant; gains, limits and `Tt` kept |
| `actuators(solution)` | 238 to 252 | no `sample_times` |
| `feedback_wires()` | 254 to 263 | ten wires: the plant to the sensing, the sensing to the cascade, the actuators to the plant |
| `selection(solution)` | 297 to 319 | `sample_times = (latch = Relative(sensor_multipliers.air_data),)` |
| `autopilot`, `piloted`, `approach` | 265 to 279, 321 to 344, 355 to 370 | the keyword `noise_psd = sensor_noise_psd`; the roots declare no `sample_times` |

- `RedstoneExamples.jl` imports `Relative` beside `Absolute`, which
  `pitch_hold` keeps. `runtests.jl` imports `cor` from Statistics.
- Untouched: `aircraft`, `level_flight`, `longitudinal_taps`, `pitch_hold`,
  `cruise`, `hand_flown`, and the legacy `closed_loop`, `lqr_gains` and
  `trimmed`, each with its tests. The legacy `closed_loop` builds its own
  groups and keeps its anchors.
- The noise seeds are 3, 5, 7 and 11 for `q`, `θ`, `h` and `V`. The
  altitude keeps seed 7 and so its realization.
- The tests deploy chapters 5 to 8 through one constant,
  `loop_deployment = (Δt_frame = 1//400, Δt_base = 1//200)`.

## 3. The rulings local to the increment

Each is the user's ruling on a reading of the prototyper, made on
2026-11-27, unless marked otherwise. The arc's rulings are the roadmap's
R25 to R28.

**B1. The multipliers are 1, 4 and 20, the base tick 5 ms and the frame
2.5 ms.** At `Δt_base = 1//200` the IMU runs at 200 Hz, the INS at 50 Hz
and the air data at 10 Hz. The attitude and outer loops keep increment 1's
rates, so only `q_ctl` moves, and with the altitude noise alone the model
reproduces increment 1's pins to three digits. The frame is `1//400`, for
two reasons. The log then holds a snapshot between two ticks of the IMU, so
a 200 Hz component differs from a continuous one in it. And the base tick
no longer equals the frame, so `Δt_base` matters: left out, the base tick
falls to the frame and every rate doubles, with no warning. The user's
reason for the frame over a bound: `Δt_frame` is the required keyword a
fixed-step user sets the step with, and `h_max` is for a shorter step
without a frame top's drain and pacing. Rejected:
- `Δt_base = 1//100` with (1, 2, 10). It gives the same figures to three
  digits, with an INS only twice slower than the IMU, against R26's "a few
  times slower".
- The same multipliers with the frame at `1//200`. The keyword `Δt_base`
  is then redundant and the log cannot show the 200 Hz rate.
- The frame at `1//200` with `h_max = 1//400`. It gives the same
  trajectory to the bit and a log as fine, at 0.166 s for the approach
  against 0.209 s, but `Δt_base` stays redundant among three keywords.
- An air data at 5 Hz or slower, which moves the latch to 30.4 s or later
  and at least doubles the throttle's standby gap. An INS at 20 Hz, which
  lengthens the limited time of B11 from 1.76 to 2.05 s.

**B2. Every gain is kept.** No figure degrades at the new rates. Each
figure that moved against increment 1 moved with the new noises.

**B3. `Tt` stays 0.02 s, a time constant in seconds.** It is no longer
"one period" of anything: at 200, 50 and 10 Hz it is 4, 1 and 0.2 periods.
The `DiscretePID`'s tracking correction is stable at every period, and a
`Tt` derived from `Δt` would be the parameter §8.7 forbids. Rejected: a
shorter `Tt`. At 0 and at 0.005 s the elevator's jump at the engage falls
from 6.3e-4 to 5e-5 and 2.2e-4, but neither repairs a degraded figure and
both change the anti-windup of a controller in command.

**B4. The latch follows the air data's multiplier, and the delays and the
limiters take the default.** The latch must tick with the slowest
controller (L15), so it follows a sensor and R28 gives it its entry from
the constant. A command delay follows no sensor: at the base tick it hands
its reader the selected command at most one base tick old, whatever the
constant says. A limiter models the actuator. Rejected: each delay at its
reader's multiplier. Its figures are identical to four digits, and it
could differ only for a pilot's throttle staged off the 10 Hz grid.

**B5. `sensing` is a group per sensor over one leaf type.** The sensors
are `imu`, `ins` and `air_data`, the leaf is `Measurement` with the inputs
`signal` and `noise`, and a sensor's children are `<x>_noise` and
`<x>_meas`, so a leaf's name is the face it exports. The constants are
`sensor_multipliers` and `sensor_noise_psd`. Rejected: a leaf type per
instrument, four identical types; and a vector noise for the air data,
which needs an `Unpack` and a vector leaf.

**B6. The cascade reads four measurements, and its standby tracks them.**
Its inputs are `h_meas`, `θ_meas`, `q_meas` and `V_meas`. With
`standby = true` the outer loops track the measured variable of the loop
inside them, now `θ_meas` and `q_meas`, and the pins compare against the
sensing's faces. Rejected: keeping the plant's variables as the standby's
comparison. The noisy measurement at another rate costs little: 0.0093 and
0.0227 against 0.0086 and 0.0213.

**B7. The noise densities.** Each is given as a density and ticks at its
sensor's rate, as L11 ruled for the altimeter.

| Measurement | Density | Per sample | Seed |
|---|---|---|---|
| `q` | 2.0e-8 rad² s⁻¹ | 0.002 rad/s at 200 Hz | 3 |
| `θ` | 5.0e-9 rad² s | 0.0005 rad at 50 Hz | 5 |
| `h` | 1.8e-3 m² s, unchanged | 0.134 m at 10 Hz | 7 |
| `V` | 4.0e-5 m² s⁻¹ | 0.02 m/s at 10 Hz | 11 |

The airspeed noise reaches the throttle through `V_ctl`'s `Kp`, and two of
increment 1's bounds widen with it: the throttle's standby gap from 0.02 to
0.035, and its jump at the engage from 0.01 to 0.015. A 1% throttle jump
still reads as bumpless. Rejected: 0.05 m/s per sample, more realistic,
with a jump of 0.0135; and 0.01 m/s, which keeps the old jump bound.

**B8. The noise keyword stays `noise_psd`, now a `NamedTuple`** keyed
`(q, θ, h, V)`, with `sensor_noise_psd` as its default. It keeps L12's
name, writes the defaults once and lets a page vary one sensor. Rejected: a
`Bool` keyword, which drops the densities from the functions' signatures.

**B9. Two pins read internal fields.** The no-anchor pin reads
`build(model).structure.anchors` and the divisors pin
`sim.model.deployment.schedule.rows`, as the core's `test_discrete.jl` and
`test_show.jl` read the rows. No public accessor exists for either, and
the missing one goes to the friction review as item 1 of section 6.
Rejected: dropping the two pins for the rate pins that read the log.

**B10. One mutant survives by construction.** Removing `q_ctl`'s entry
passes every test, since an omitted key is `Relative(1)` and the IMU's
multiplier is 1. This is the case R28 writes the entry for, and no test
can tell the two apart while the constant holds a 1. Accepted on the
coordinator's recommendation, with no objection from the user.

**B11. The limited time is quoted like with like, with the noise on and
off.** The figure is the time the attitude loop sits on its limit on the
50 m step, with that limit cut to ±0.05 rad/s. It counts samples on the
limit, and noise knocks the command off it and back, so it depends on the
noise. The single-rate comparison keeps the air data at 10 Hz, as
increment 1's did. The prototyper's first single-rate figure, 1.42 s, ran
the air data at 50 Hz too and compared nothing. L4's note stands: several
rates cost no more than one. The coordinator's, put to the user with no
objection.

**B12. The gate is the examples' runner on Julia 1.13**, for the reviewer
and the fixer, as L19 ruled for increment 1. Nothing under `src/` or
`test/` changes. The coordinator's.

**B13. The constant's docstring states that the multipliers nest.** The
latch of B4 ticks at the air data's multiplier, and its ticks are every
controller's only while each multiplier divides the air data's. With an
INS at 4 and an air data at 10 the attitude loop would read the latch up to
two base ticks late. The prototype's docstrings do not say so. One
sentence joins `sensor_multipliers`' docstring in the review's fix commit,
as L22 did for a docstring of increment 1, so the patch stays the
worktree's diff. The coordinator's, taken while the user was away.

## 4. The pins

The frame is 1/400 s and the base tick 1/200 s, with the default
densities. Chapters 1 to 4 and the legacy testsets are unchanged. A mutant
named here was run and turned its pin red, unless marked. The cold review
reread the column pin by pin, since the prototyper's runner reported
failing testsets, and section 11 names the rows it corrected.

| Chapter | Pin | Probed | Tolerance | Mutant |
|---|---|---|---|---|
| all | every model builds under `(Float64, ProbeDual)` | true | exact | unchanged |
| 5 | rest at the trim, every noise off, over 60 s | 2.4e-10 m | ≤ 1e-6 | `V_meas` wired from `h_meas`; `autopilot` dropping `noise_psd` |
| 5 to 7, review | with every noise off, each measurement equals the plant's output at its sensor's ticks, in the three models | true | exact | `piloted` or `approach` dropping `noise_psd` |
| 5 to 7, new | `autopilot`, `piloted` and `approach` hold no anchor | true | exact | the latch anchored |
| 5 to 7, new | the schedule's divisors in the three models, 17 with `selection` and 14 without, every row with no anchor and no phase | true | exact | a root that gives `cascade` or `vehicle` a `Relative(2)`; the INS's multiplier at 5; `θ_ctl` at the IMU's; a sensor at another's; the latch at the default; a delay at the air data's |
| 5, new | at `Δt_base = 1//100` the same divisors, and `h_ctl`'s period 0.2 s | true | exact | a test that passes no `Δt_base`; not run |
| 5, new | 24000 of the climb's 48001 snapshots lie off the 200 Hz grid, and `q_ctl` changes only on it | true | exact | the test's deployment without `Δt_base` |
| 5, moved | each loop changes on its own grid and not only on the next coarser one, at 200, 50 and 10 Hz | true | exact | `θ_ctl` at the IMU's; the INS's multiplier at 5 |
| 5, moved | late errors after 75 s | 0.0795 m, 0.0235 m/s | ≤ 0.12, ≤ 0.035 | `V_meas` wired from `h_meas`; `q_meas` and `θ_meas` swapped into the cascade |
| 5 | peak altitude | 1050.063 | < 1050.2 | unchanged |
| 5, moved | airspeed excursion | 3.9244 m/s | 0.02 | `q_ctl`'s `Kp`; `Tt` tenfold |
| 5, new | each measurement changes on its sensor's grid and not only on the coarser one | true | exact | a sensor at another's multiplier |
| 5, new | each noise's deviation per sample | 0.001998, 0.0005018, 0.1322, 0.02004 | rtol 0.1 | `q`'s density from `θ`'s; `V`'s raised; a noiseless `Measurement` |
| 5, review | the four noises are uncorrelated, pair by pair | at most 0.057, the IMU's against the altitude's | below 0.15 | a seed shared by two noises |
| 6 | refusal with the delays bypassed | two real `AlgebraicCycle` | exact | unchanged |
| 6, moved | pull, release and engage snapshots | 2002, 2802, 12002 | exact | unchanged |
| 6, moved | standby gaps, δe over [8, 30) and δt over [5, 30) | 0.0048, 0.0255 | ≤ 0.008, ≤ 0.035 | δe: `δe_track` wired from `δt_prev`, or `q_ctl`'s `Tt` at 2 s; δt: `Tt` tenfold, or `V`'s density raised |
| 6, moved | outer gaps against `θ_meas` and `q_meas` | 0.0093, 0.0227 | ≤ 0.015, ≤ 0.03 | `h_ctl` tracking `q`; `θ_ctl` tracking `θ_meas` |
| 6 | the latched `engaged` first true | 30.2 s | exact | the latch at the default |
| 6, moved | the controllers equal the unengaged flight's over [0, 30.20125) | identical | exact | the latch at the default |
| 6, moved | jumps at the switch, δe and δt | 0.00063, 0.0106 | ≤ 0.005, ≤ 0.015 | δe: `δe_track` wired from `δt_prev`; δt: `Tt` tenfold |
| 6 | recapture of 1000 m over [80, 90) | 0.060 m | ≤ 0.12 | `V_meas` wired from `h_meas` |
| 7, moved | touchdown, after 6667 writes | 726.6468115368581 s | 1e-3 | `q_ctl`'s `Kp`; a noiseless `Measurement` |
| 7 | altitude at the stop, tracking over [160, t − 1) | −2.2e-13, 0.246 m | ≤ 1e-6, ≤ 0.35 | unchanged |
| 8 | replay of the whole flight | identical | exact | unchanged |
| 8, moved | second approach at 2 m/s | 559.9669062395417 s | 1e-3 | the INS's multiplier at 5 |
| 8 | the checkpoint restored and flown at 1.5 m/s | the first touchdown | exact | unchanged |
| 7 | the approach's phase bodies | 0 B | exact | unchanged |

- Sixteen source mutants were run in round 1, and fifteen turned red. The
  survivor is B10's. The five whose pins round 2 touched were rerun and
  stayed red. The source and the test were restored byte for byte after
  each round, checked with `cmp`. `probes/mutants.py` runs them, and its
  outputs are `mutants.out`, `mutants2.out` and `mutants3.out`.
- A source mutant that anchors `q_ctl` at `Absolute(1//400)` never reaches
  the log pin: the deployment refuses it, since `1//200` does not divide
  it.
- Twenty alignments of the pilot's writes, 2.5 ms apart, move the gaps and
  the jumps of chapter 6 by under 7e-5 (`probes/p11_v1_sweep`), so no
  window pins the noise's realization.
- Tolerances follow increment 1: about 1.5 times the probed value for a
  maximum the noise drives, and 1e-3 on the touchdowns by L23.

## 5. Measurements

**The candidates for B1** (`probes/p02_candidates.condensed`), with the
gains untuned, `Tt = 0.02 s`, every noise on and the frame at `1//200`.
"Limited" is B11's time, with the hold and without.

| `Δt_base`, multipliers | Hz | Late h, V | Limited | Gaps δe, δt | Latch | Jumps δe, δt | Approach's tracking |
|---|---|---|---|---|---|---|---|
| 1//200, (1, 4, 20) | 200/50/10 | 0.0795, 0.0235 | 1.76 / 2.14 | 0.0048, 0.0255 | 30.2 | 0.00063, 0.0106 | 0.246 |
| 1//100, (1, 2, 10) | 100/50/10 | 0.0792, 0.0236 | 1.76 / 2.14 | 0.0047, 0.0255 | 30.2 | 0.00057, 0.0106 | 0.243 |
| 1//100, (1, 5, 10) | 100/20/10 | 0.0890, 0.0255 | 2.05 / 2.75 | 0.0049, 0.0255 | 30.2 | 0.00050, 0.0106 | 0.227 |
| 1//50, (1, 5, 10) | 50/10/5 | 0.0920, 0.0199 | 2.60 / 3.40 | 0.0033, 0.0383 | 30.4 | 0.00035, 0.0159 | 0.412 |
| 1//50, (1, 5, 25) | 50/10/2 | 0.1005, 0.0247 | 2.30 / 3.50 | 0.0036, 0.0770 | 31.0 | 0.0016, 0.0508 | 0.844 |
| 1//400, (1, 8, 40) | 400/50/10 | 0.0752, 0.0222 | 3.52 / 4.24 | 0.0044, 0.0255 | 30.2 | 0.0012, 0.0106 | 0.259 |
| 1//200, (1, 2, 20) | 200/100/10 | 0.0805, 0.0237 | 1.65 / 1.74 | 0.0052, 0.0255 | 30.2 | 0.00076, 0.0106 | 0.238 |
| 1//200, (1, 4, 40) | 200/50/5 | 0.0946, 0.0220 | 2.02 / 2.26 | 0.0032, 0.0383 | 30.4 | 0.0013, 0.0159 | 0.386 |

**The frame against the bound** (`probes/p09_frames`, `p09b_timing`), for
the first row's multipliers.

| | Frame 1//200 | Frame 1//400 | Frame 1//200, `h_max = 1//400` |
|---|---|---|---|
| Snapshots of a 60 s `autopilot` run | 12001 | 24001 | 24001 |
| Changes of `q_ctl`'s output | every snapshot | every second one | every second one |
| Touchdown | 726.6468115372288 s | 726.6468115368581 s | 726.6468115368581 s |
| The approach's wall time, least of three warm runs | 0.108 s | 0.209 s | 0.166 s |

The last two columns agree to the bit at all 48001 common instants of
chapter 5's 120 s climb, and differ from the first by up to 1.7e-7. Every
pin of section 4 reads the same under all three to the printed digits. The
default `log_max` thins the approach's log to a 10 ms stride after 60 s
under all three.

**The limited time of B11** (`probes/p10_limited`, `p13_v1_companion`).

| Configuration | Every noise on | No noise |
|---|---|---|
| Hold, three rates | 1.76 s | 2.20 s |
| Hold, every loop at 50 Hz, the air data at 10 Hz | 1.92 s | 2.24 s |
| No hold, three rates | 2.14 s | 2.98 s |

Rebuilt through the probes' knobs, increment 1's models read its 2.02 s at
one rate and 1.84 s at two.

**The air data's rate** on the 50 m step, every noise on
(`probes/p06_companion`).

| Air data and its loops | Late h (m) | Late V (m/s) | Peak (m) |
|---|---|---|---|
| Air data at 50 Hz, its loops at 10 Hz | 0.1693 | 0.0509 | 1050.141 |
| Air data and its loops at 50 Hz | 0.0589 | 0.0191 | 1050.059 |
| Air data and its loops at 10 Hz, as shipped | 0.0795 | 0.0235 | 1050.063 |

**Further figures for the companion.** The altitude is within 1 m by
24.3 s, and the airspeed excursion falls at 3.7325 s. By hand the altitude
runs from 988.0 to 1016.7 m. The elevator command's largest change between
two ticks over [80, 90) s is 0.0024 rad, and behind its actuator the
elevator jumps by 3.1e-5 rad at the engage, read across one 2.5 ms
snapshot. Without the latch a staged `engage` would reach the switches at
30.0025 s, `q_ctl` at 30.005 s, `θ_ctl` at 30.02 s and the outer loops at
30.1 s. After the latch acts at 30.2 s the controllers first depart from
the unengaged flight at 30.205, 30.22 and 30.3 s. On the approach the
airspeed stays between 49.969 and 50.029 m/s, and the tracking error at
full log resolution is 0.2574 m.

**The gate's time.** About 34 s, under either deployment. One gate read
1 min 30 s while the machine's load average was near 13, and 33.7 s and
34.0 s on two later runs. The first calls are compilation at the test's
call sites, 92% to 99.9% of each (`probes/p15_compile_split`), and nothing
specializes on a frame finer than the base tick.

## 6. Friction

By the roadmap's R17, each item with the call that showed it.

1. The bound rates have no public reader. The pins of B9 read
   `sim.model.deployment.schedule.rows` and `build(model).structure.anchors`.
2. An omitted `Relative(1)` cannot be told from a written one, in the
   schedule or in the build. B10's mutant shows it.
3. At a frame equal to the base tick, the log cannot tell a component at
   the base tick from a continuous one. B1's frame works around it.
4. Item 13 of increment 1 stays silent, and B1 makes it visible:
   `Simulation(piloted(solution); Δt_frame = 1//400)` runs every rate
   doubled and `warnings(sim)` is empty.
5. A rate scope's row exists only for a keyed assembly. `schedule.scopes`
   lists the three sensors and neither `sensing` nor `cascade`, so nothing
   in the deployment says that they share the root's grid.
6. An entry of `sample_times` reads only off the source. Seven entries of
   the form `Relative(sensor_multipliers.x)` make long lines, and nothing
   reads back which constant an entry came from.
7. A module constant cannot be varied by a run. The probes evaluated copies
   of `sensing` and `cascade` over a run-time knob, and a `const` redefined
   with `Core.eval` did not reach an evaluated method
   (`probes/p06_debug.jl`). The second half is Julia's, not the
   framework's.

## 7. Bookkeeping

The docs commit, which lands before the code:

- `../roadmap_tutorial.md`: R4 amended to three rates and row 5 of the arc
  with it, the three open decisions of the rework retired with a pointer
  here, and the header's sentence on R25 to R28 brought up to date.
- `../../companions/longitudinal_aircraft.md`, sections 4 and 5: the rates
  and the base tick, the sensing's paragraph and table, the cascade's
  table, the limited times of B11, the delays' rate, the instants a staged
  `engage` reaches its readers, the step's and the engage's figures, the
  sentence on the throttle limiter's 0.01 per tick, which is now 0.0025,
  the approach's airspeed band, and the testset's summary.
- `../../companions/examples_inventory.md`: `Measurement` for `Altimeter`,
  the two constants, and the two sentences on what the testset pins.
- `../../pending.md`: the bullet's stage, and at the push the bullet
  retired and the tutorial's bullet updated.

Not done, in the other repo: one line in
`RedstoneInspector.jl/design/pending.md` that the next bump of its pin
meets new paths under `sensing` and new faces on `cascade`. Section 10
says why.

## 8. Out of scope

- The pages of chapters 4 to 8, which are increment 3's. Chapter 5's page
  passes `Δt_base` and says why, by R27 and B1.
- The legacy `closed_loop`, its sensing and its anchors, which increment 4
  replaces.
- The inspector's pin bump and its fixtures, which are that repo's work.
- `../../companions/time_quantities.md`, the companion on the frame, the
  base tick and the step that B1's discussion raised. It lands as its own
  docs commit after this increment's code, with one pointer from §9.2.
- Every friction item of section 6, which goes to the friction review.

## 9. The cold review

One independent high-tier agent, on Julia 1.13, with the examples' runner
as its gate.

- It reads R25 to R28, this file and the patch, and checks the code
  against each ruling of section 3.
- It reruns the mutants of section 4, then its own. It runs the one mutant
  the prototyper did not: the divisors pin at `Δt_base = 1//100` against a
  test that passes no `Δt_base`.
- It re-probes the figures the companion quotes, from its own scripts
  outside the tree, the limited times of B11 first.
- It sweeps every docstring of `longitudinal.jl` and every sentence of the
  companion's sections 4 and 5 for a rate, a sensor or a period that the
  rework made false.
- It may accept B10's survivor, for the reason given there. An empty
  review is acceptable.

## 10. Taken while the user was away

The user left on 2026-11-27 after ruling B1 to B9 and agreeing to the
companion of section 8, and asked the coordinator to work on and record
its decisions. Each entry is the coordinator's and waits for the user's
review. Nothing is pushed.

- B10 to B13 above, each marked as the coordinator's.
- The user had not read this record before its commit. The pipeline shows
  the record first, so the user's review of it is still owed.
- The folder's name, `20261127_tutorial_rates`, and the prefix B for this
  increment's rulings, which keeps them apart from increment 1's L.
- The companion `../../companions/time_quantities.md` landed as
  `86a5955b`, on the proposal the user agreed to, before the user read its
  text. It joined three rosters, `check_refs.jl`, `check_rows.jl` and
  `linkify.jl`, and not `sweep_rows.jl`, which lists no recent companion.
  The pointer from §9.2 is not added: the coordinator had said it would
  show the sentence first. The sentence proposed, after the paragraph on
  `h_max`: "`time_quantities.md` works the choice between a shorter frame
  and a bound."
- `RedstoneInspector.jl` is untouched. Another session had unpushed
  commits there on the day, and its `design/pending.md` already says that
  its README's pictures wait for a pin bump after this increment. At that
  bump its fixtures meet the paths `sensing/imu`, `sensing/ins` and
  `sensing/air_data` with their `<x>_noise` and `<x>_meas` children, the
  faces `q_meas`, `θ_meas`, `h_meas` and `V_meas` on `sensing` and on
  `cascade`, and a schedule with no anchor.
- The adjudication of the cold review, section 11, and the rejection of
  four of its nits.
- The review found a contradiction inside §9.2, outside this increment. It
  is recorded as a bullet of `../../pending.md` for the user's ruling, and
  the spec is unchanged.

## 11. The review's record

One cold reviewer, a high-tier agent, on Julia 1.13.3 in the worktree
`/Users/miguel/.julia/dev/Redstone.jl-worktrees/tutorial_1b_review`, with
its probes in `tutorial_1b_review_probes/` beside it and its notes in
`tutorial_1b_review_notes.md`. Its gate at `675c1ac8` read 194 of 194.

**No defect.** The code matches R25 to R28 and B1 to B9. Every figure the
companion quotes in the changed passages agreed with the reviewer's own
probes, the two of F3 and F4 excepted. Forty alignments of the pilot's
writes over a full 10 Hz period move each pin of chapter 6 by at most
2.3e-4, and each window's maximum sits mid-window.

**Fixed in `b5583dd5`**, by a separate fixer, with the gate at 215 of 215.

- F1, a missing test. Nothing checked that `noise_psd` reaches the sensing
  in `piloted` or `approach`: either function dropping the keyword passed
  every test. A new testset checks, with every noise off, that each
  model's four measurements equal the plant's outputs at their sensors'
  ticks.
- F2, a missing test. The divisors pin read `piloted`'s schedule alone, so
  a `Relative(2)` on `autopilot`'s or `approach`'s root died only on a
  figure that happened to shift. The pin now reads all three models.
- F5, a stronger test. A seed shared by two noises died only on the
  touchdowns, which react to any change of realization. The check on the
  air data's pair became one on all six pairs of noises, read by draw.
- F3. The airspeed excursion falls at 3.73 s. The companion's 3.74 s was
  the figure at a frame of `1//200`, rounded up.
- F4. The limited time of 1.92 s needs the IMU and the INS at 50 Hz beside
  the loops, as the prototyper's probe ran it. With the IMU left at 200 Hz
  it reads 1.88 s. The companion's sentence now names all three.
- F7, a stale drift figure in a test comment.
- B13's sentence in `sensor_multipliers`' docstring.

**Fixed in this file.** F6: section 4's mutant column was read per
testset. Five rows named a mutant that turns another pin of the same
testset red. They are the late errors, the standby gaps, the jumps, the
rest and the recapture, and they now carry the reviewer's results by line.

**Rejected.** A name line on the two constants' docstrings, since the
file's constant `g` has none. A test line of 124 characters, since no rule
bounds it. The name `ins`, which `code_rules.md` reserves for a row's
faces and which is here B5's ruled name for a sensor. `const` on the
test's two globals.

**Survivors.** B10's, accepted. And `q_ctl`'s own `Tt` at 0.2 s: nothing
claims that loop's own tracking lag, the elevator's gap stays under its
bound, and `Tt` tenfold on all four controllers is red.

**The delta check**, by the same reviewer at `9d5b6710`. Every fix is
closed as proposed, and B13's sentence is true of the code. Each new test
turns red under the mutants it was written for, on the line of the new
pin, and stays green under a fresh seed and under B10's survivor. It found
two stale summaries the fix left behind, in the inventory and in the
companion's section 4, and the commit that carries this section corrects
both.

**Not checked by the review.** The examples' CI on Linux. The candidates'
table and the frame-against-bound table of section 5, beyond the shipped
configuration. The prototyper's probes as sources.

## 12. The scratch

Kept until the push, by step 8 of the pipeline. What the record rests on
is already here: the prototyper's probes and the fixer's mutant runner
under `probes/`, and the reviewer's scripts with their outputs under
`probes/review/`. The reviewer's per-mutant logs are left behind.

- `/Users/miguel/.julia/dev/Redstone.jl-worktrees/tutorial_1b`, the
  prototype's worktree, with `tutorial_1b_probes/` and
  `tutorial_1b_notes.md` beside it.
- `/Users/miguel/.julia/dev/Redstone.jl-worktrees/tutorial_1b_review`, the
  reviewer's worktree, with `tutorial_1b_review_probes/` and
  `tutorial_1b_review_notes.md` beside it, and its two mutant copies.
- `/Users/miguel/.julia/dev/Redstone.jl-worktrees/tutorial_1b_fix`, the
  fixer's copy.
