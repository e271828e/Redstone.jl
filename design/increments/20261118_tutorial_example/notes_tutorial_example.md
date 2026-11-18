# Notes: the tutorial's increment 1, the example's main path

Increment 1 of `../roadmap_tutorial.md`: the model of chapters 1 to 8 as
chapter-end functions of the examples package, with its testset. This
file holds the state reached, the rulings local to the increment with
their reasons, the pins, the friction found, and what is open. The
rulings that reach the whole arc are the roadmap's R18 to R20.

## 1. The state on 2026-11-18

- The prototype is settled after three rounds of rulings. No brief exists
  yet, and nothing of the prototype is in the real tree.
- The patch is `prototype_tutorial_example.patch` beside this file, the
  worktree's `git diff` against `0d43dfc`. It touches four files under
  `examples/`, +490 −34, and `git apply --check`
  passes on the real tree at `fb85189`.
- The prototyper's gate, run in the worktree as
  `julia --startup-file=no --project=examples -e 'using Pkg; Pkg.test()'`:
  146 of 146, against 77 of 77 before. The coordinator has not rerun it.
- The worktree is `/Users/miguel/.julia/dev/Redstone.jl-worktrees/tutorial_1`,
  detached at `0d43dfc`. Its probes are `tutorial_1_probes/` beside it and
  the prototyper's own notes `tutorial_1_notes.md` beside it. Every figure
  below comes from those probes, run by the prototyper.
- The prototyper ended at 384k tokens of its 450k stop. It answers only
  the session that launched it, so a successor session cannot resume it.

## 2. What the prototype builds

In `examples/src/longitudinal.jl`, after `longitudinal_taps`. `PID`,
`s_init` and `y_direct` join the module's imports.

| Function | Chapter | Root inputs | Composes |
|---|---|---|---|
| `pitch_hold(; discrete = false)` | 4 | `θ_ref`, `δt` | the plant and one `PID(Kp = -2.0, Ki = -1.0)` on θ, a `DiscretePID` at 50 Hz with `discrete = true` |
| `autopilot(solution; noise_psd = 1.8e-3)` | 5 | `h_ref`, `V_ref` | the plant, `sensing`, `cascade()`, `actuators` and a `Constant(true)` on `cascade/engaged` |
| `piloted(solution; noise_psd = 1.8e-3)` | 6 | `h_ref`, `V_ref`, `δe_pilot`, `δt_pilot`, `engage` | the same groups with `cascade(standby = true)` and `selection` between the cascade and the actuators; exports `h` |
| `approach(solution; noise_psd = 1.8e-3)` | 7 | the same five, passed through | `piloted` nested as the child `vehicle`, a `GroundContact` and a `StopRequest` |

- **Groups.** `sensing(; noise_psd)`, `cascade(; standby = false)`,
  `actuators(solution)`, `selection(solution)`, and the helper
  `feedback_wires()`, the seven root wires chapters 5 to 7 share.
- **One new component.** `Altimeter`, a stateless discrete leaf:
  `s_init = nothing`, inputs `h` and `noise`, one bare output
  `y = h + noise`.
- **Initial conditions.** `cruise(solution)` and `hand_flown(solution)`.
- **Removed.** `descent()` and its testset.
- **Untouched.** `aircraft()`, `level_flight()`, `longitudinal_taps()`, and
  the legacy `closed_loop`, `lqr_gains`, `trimmed` with their tests, which
  increment 4 replaces.
- **Chapter 8** adds no model. Its two testsets run on `approach`.

## 3. The rulings local to the increment

Each was a reading of the prototyper or a point raised in discussion, and
each is the user's ruling unless marked otherwise.

**L1. The names.** `pitch_hold`, `autopilot`, `piloted`, `approach`, with
`cruise` and `hand_flown` for the initial conditions, and the roadmap's
words for the groups. Rejected: numbered names, which say nothing to an
agent reading the API.

**L2. The run stages the approach's reference**, 0.15 m every 0.1 s.
Rejected: a `Source` inside the model. It works, but `h_ref` then stops
being a root input, so `at("vehicle", hand_flown(solution))` is refused as
`ConditionResolution` and the condition must split. Staging also keeps the
trace identical to chapter 6's.

**L3. `approach` replaces `descent()`.** Beside it, `descent()` would be
the subject of no chapter, and the approach re-pins every claim it
carried.

**L4. Two rates are kept, untuned.** The hold chain and the standby
tracking behave across 10 Hz and 50 Hz. With the hold, a pitch loop cut to
±0.05 rad/s stays saturated 1.14 s at two rates against 0.38 s at one, and
nothing winds or stalls.

**L5. The approach flies under the autopilot.** No loop saturates, the
airspeed stays within 0.05 m/s of 50, and 726 s of flight take about
0.25 s of wall time.

**L6. The cascade's keyword**, the first instance of the roadmap's R19.
`cascade(; standby = false)` adds the tracking inputs and the `δe_track`
and `δt_track` faces only with `standby = true`. Chapter 5's figures are
bit-identical either way, since no outer loop is ever limited there.

**L7. `feedback_wires()` shares the root wires.** Chapter 6 cannot nest
chapter 5, because the selection splices into chapter 5's command path,
and listing seven wires in each root would write them twice.

**L8. `approach` nests `piloted` as `vehicle`.** Paths gain a prefix and
the initial condition mounts under it. The child was `aircraft` at first,
which collided with `aircraft()`. Rejected: a flat root rebuilt from
`piloted`'s children, which needs the `children` field and a filter over
`input_wires`.

**L9. Rates are `Absolute` anchors per discrete child.** The model carries
its rates. Rejected: `Δt_base = Hz(50)` with `Relative(5)` on the slow
loops, which is bit-identical but runs every unlisted discrete child at
the frame rate when the keyword is forgotten.

**L10. Scenarios stage at the stop time.** The frame-early offset of the
legacy tests lands a write on an exact tick, a precision the tutorial does
not need. The pages say that a discrete component reads a staged write at
its next tick. The legacy `fly_closed_loop` keeps its offset.

**L11. The altimeter outputs at 10 Hz, already anti-aliased.** The first
prototype fed 50 Hz noise to the 10 Hz altitude loop, which decimated it
with no anti-aliasing, and the late altitude error grew by √5. The user's
design: a sensor is configured to its loop's rate and decimates inside.
So the noise ticks at 10 Hz and is given by its density, `psd = 1.8e-3`,
today's `0.3² × 0.02`, and `Altimeter` samples and holds the whole
measurement. Rejected: a low-pass filter inside `cascade`, the consumer's
side, which fits a sensor of fixed higher rate. The legacy `closed_loop`
keeps its 50 Hz sensor. No hold joins the library:
`library_inventory.md` section 1 already declines it, since the tier and
`sample_times` do it.

**L12. The noise keyword is `noise_psd`**, mirroring the library's `psd`.
A per-sample `σ` depends on the sensor's rate. Accepted on the coordinator's
recommendation, with no objection from the user.

**L13. The engage bump is pinned as the jump itself.** With the quieter
sensor the steady elevator jitter fell to 0.0017 rad, so "the bump is
below the jitter" no longer holds. A retune of the standby `Tt` was not
probed. Accepted on the coordinator's
recommendation, with no objection from the user.

**L14. The second approach sinks at 2 m/s**, plainly different from the
first. Accepted on the coordinator's
recommendation, with no objection from the user.

**L15. The mode is latched.** One staged `engage` reached the continuous
`Switch`, the 50 Hz loop and the 10 Hz loops at three instants, 30.005,
30.02 and 30.1 s. `selection` now holds `latch = UnitDelay(false)` at
10 Hz. The switches read it, and it leaves the group as the face `engaged`
for the cascade, so everything acts at 30.2 s. Rejected: leaving it and
showing the three instants as multi-rate semantics; and a hand-written
stateless leaf, which latches a tick sooner but would be the example's
second hand-written hold.

**L16. The steps of chapters 4 and 5 come from the initial condition.**
`stage!` is chapter 6's feature, and staging had doubled chapter 4's gap
between the tiers with a delay that is not discretization.

## 4. The pins

Frame period 1/200 s, altimeter seed 7, `noise_psd = 1.8e-3`.

| Chapter | Pin | Probed | Tolerance |
|---|---|---|---|
| all | every model builds under `(Float64, ProbeDual)` | true | exact |
| 4 | closed-loop eigenvalues | −2.0474 ± 8.0637i, −1.3922, −0.6423, −0.0516 | to 1e-6 |
| 4 | DC gain from `θ_ref` to θ | 1.0 | 1e-9 |
| 4 | the discrete loop's refusal | two `TapResolution` | exact set |
| 4 | step peaks, continuous and discrete | 0.0799086, 0.0819967 | 1e-4 |
| 4 | largest gap between the tiers | 0.00211 | ≤ 0.003 |
| 5 | rest drift without noise over 60 s | below 3e-10 | ≤ 1e-6 |
| 5 | `h_ctl`, `V_ctl` and the altimeter change only on the 10 Hz grid | true | exact |
| 5 | noise deviation at the ticks | 0.1322 | rtol 0.1 of 0.134 |
| 5 | late errors after 75 s | 0.0775 m, 0.0187 m/s | ≤ 0.12, ≤ 0.03 |
| 5 | peak altitude | 1050.061 | < 1050.2 |
| 6 | refusal with the delays bypassed | two `AlgebraicCycle`, both real | exact |
| 6 | pull, release and engage snapshots | 1002, 1402, 6002 | exact |
| 6 | standby gaps, δe over [8, 30) and δt over [5, 30) | 0.0043, 0.0156 | ≤ 0.008, ≤ 0.02 |
| 6 | the latched `engaged` first true | 30.2 s | exact |
| 6 | jumps at the switch, δe and δt | 0.00110, 0.00862 | ≤ 0.005, ≤ 0.01 |
| 6 | recapture of 1000 m over [80, 90) | 0.0566 m | ≤ 0.12 |
| 7 | the approach equals chapter 6's flight over [0, 60) | identical | exact |
| 7 | touchdown | 726.6442291951134 s | 1e-2 |
| 7 | termination record | `ModelRequestedStop`, `"stop"`, `:y`, `"touchdown"` | exact |
| 7 | altitude at the stop | −1.0e-13 | ≤ 1e-6 |
| 7 | tracking over [160, t − 1) | 0.247 m | ≤ 0.35 |
| 7 | the approach's phase bodies | 0 B | exact |
| 8 | replay of the whole flight | identical, same stop | exact |
| 8 | second approach from the 60 s checkpoint, at 2 m/s | 559.9685756981099 s | 1e-2 |
| 8 | the checkpoint restored and flown at 1.5 m/s | the first touchdown | exact |

The sensor's effect on the 50 m step, the evidence chapter 5 can show:

| Sensor and rates | Late altitude error (m) | Late airspeed error (m/s) | Peak (m) |
|---|---|---|---|
| 50 Hz sensor, two rates | 0.1646 | 0.0392 | 1050.126 |
| 50 Hz sensor, one rate | 0.0640 | 0.0150 | 1050.064 |
| 10 Hz altimeter, two rates | 0.0775 | 0.0187 | 1050.061 |

Further figures for `longitudinal_aircraft.md`: the airspeed excursion in
the step is 3.90 m/s at 3.73 s, and the altitude is within 1 m by 24.4 s.
By hand the altitude runs from 988.0 to 1016.7 m. The actuator's elevator
jump at the engage is 1.0e-4 rad. On the approach the airspeed stays
between 49.978 and 50.022 m/s and γ at the stop is −0.0303.

## 5. Friction

By the roadmap's R17. Each item is what the writing found, with the call
that showed it in the prototyper's notes.

1. Moving a PID between tiers changes the condition's key from `x` to `s`.
2. A hold PID's `engaged` has no default, so an always-engaged loop wires
   a `Constant(true)`.
3. `@test_throws` cannot name a diagnostic kind, so tests catch and
   filter `diagnostics(err)`.
4. `series` refuses `get_state`. This is settled design on both tiers:
   a snapshot carries no store (D-261).
5. Changing one wire of a group means rebuilding it by hand. `children`
   has no accessor, and a declaration left out is dropped silently.
6. A checkpoint is refused on a model that only nests the old one under a
   prefix.
7. Nesting a root re-wires each of its root inputs by name.
8. An inner root must export a port only so that a later parent reads it.
9. A condition that writes root inputs is refused once a parent feeds one
   of them.
10. `step!` returns the full count when the stop falls in its last frame,
    so a staged loop polls `lifecycle`.
11. A write meant for a tick is staged one frame early. L10 avoids it in
    the tutorial; item 17 is its other face.
12. A run past `log_max` thins the log silently.
13. Without `Δt_base`, unlisted discrete children run at the frame rate
    silently.
14. `Absolute(Hz(50))` is written once per discrete child.
15. A face appears once across `input_wires`, so a keyword that adds a
    reader rebuilds the face's whole reader tuple.
16. One staged root input reaches a continuous reader and two discrete
    rates at three instants, with no warning. L15 cures it in the model.
17. Staging at the stop time delays a discrete reader by up to a tick.
18. A stateless leaf's tier comes from declaring an empty store:
    `s_init(::Altimeter) = nothing` reads like "no store".
19. Coordinating one mode flag across rates takes a latch in the model,
    at the cost of up to two ticks of the slowest rate.

Two fixes were sketched in discussion and left for the friction review:
`condition` methods or an initial-value keyword for the controllers
(item 1), and a write scheduled by time (items 11 and 17).

## 6. Open

- **The brief**, then the pipeline's later stages. The prototype is the
  implementation, so the build is the patch applied to the real tree.
- **The docs commit.** `longitudinal_aircraft.md` sections 4 and 5 take
  the figures above, with a new part on the pitch hold, and
  `examples_inventory.md` section 3 takes the file's new surface.
- **The inspector.** Its `scripts/fixtures.jl` imports `descent`, which
  becomes `approach(solution)` at the next bump of its pin.
- **For increment 3's pages.** Chapter 6 explains the latch. Chapters 4
  and 5 put their step in the initial condition, so `stage!` first appears
  in chapter 6.
- **For increment 4.** `selection` is taken, so chapter 9's rebuilt group
  needs another name or a method.
- **The friction review.** Section 5's list feeds the friction review of
  the API audit, the bullet of `pending.md` that the user's ruling of
  2026-11-18 widened from the exported-name audit.

## 7. The handover

Written on 2026-11-18, when the coordinating session handed over before
the brief, at 360k tokens of its context.

- **Read, in this order.** `AGENTS.md`; `design/rules/increment_rules.md`
  and `design/rules/brief_rules.md`, whole; `../roadmap_tutorial.md`,
  whole; this file; the patch beside it; and `design/rules/code_rules.md`,
  whole, before anything under `examples/` is touched.
- **What comes next.** The brief, the pipeline's third stage: drafted from
  the settled prototype, shown to the user before anything lands, and
  committed to this folder. Then the docs commit of section 6, the patch
  applied with `git apply`, the examples' gate, one cold review and its
  fix.
- **Every ruling is on file.** The arc's are the roadmap's R1 to R20, and
  the increment's are section 3. None lives only in the old transcript.
  L12 to L14 are the coordinator's, as marked, and so is rule 2 of the
  roadmap's rules for the pages.
- **What the coordinator did not verify.** The gate and every figure are
  the prototyper's. The coordinator checked only that the patch equals the
  worktree's diff and that it applies to the real tree.
- **Agents.** None is running. The prototyper cannot be resumed from
  another session, so a change to the prototype goes to a fresh agent
  that continues from the worktree and `tutorial_1_notes.md`.
- **The coordinator pushed nothing.** `git log origin/master..HEAD` lists
  what is not on the remote.
