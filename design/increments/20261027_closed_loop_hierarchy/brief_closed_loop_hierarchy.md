# Brief: `closed_loop` as a hierarchy

Tip at drafting: `829d3c0`. Written on 2026-10-27. A one-stage increment
the main session prototyped in a scratch worktree and applied itself, so
this is the record half: what was settled, what the prototype measured,
the docs edits, what stays out, and what the review looks at.

Design and code are peers, neither subservient.

## Purpose

Refactor the example's closed loop from one flat `Group` of 27 library
blocks and 55 wires into a `Group` of five groups beside the plant, with
the references and the mode as root inputs, so that the inspector has a
real model with nested levels to open and the tutorial's chapters have the
model's layers to follow. The behaviour is unchanged: the refactored loop
reproduces the flat loop's runs to round-off.

## What was settled (user rulings, 2026-10-27)

- **The plant stays a bare root child.** The root level then reads as the
  control loop with the plant as its one non-controller box, and no group
  has to re-export the five plant states.
- **Six root blocks**: `plant`, `sensing`, `pid_controller`,
  `lqr_controller`, `selection`, `actuators`. The two controller names
  share the suffix so they read as alternative controllers with one
  objective; `_tracker` was passed over because it borrows the LQR block's
  own name and labels the cascade with a word none of its blocks carries.
- **`h_ref`, `V_ref` and `mode` are root inputs**, not `Step`, `Constant`
  and `Source` blocks. The scenario belongs to the run: `stage!` from the
  REPL flips the controller mid-run, the cockpit stages reach root inputs
  through the GUI write path, and `linearize` can tap a reference. The
  cost is root-input totality, which `trimmed` pays with a
  `set(u = (h_ref = 1000.0, V_ref = 50.0, mode = true))`, and a scripted
  driver in the tests.
- **The cascade is one group**, so the chain of `saturated` holds stays
  inside it and does not cross a boundary. The pending bullet listed that
  hold among the cross-group signals, which held only for a split cascade.
- **The sum junction is `altimeter`**, so the block's name and the face it
  publishes, `h_meas`, differ; a face name may not coincide with a child
  name in the same scope.
- **The negation of `mode` and the packing of the delayed commands live in
  `lqr_controller`**, so every boundary carries scalars and `mode` is the
  one flag that crosses. The group has eight blocks, over the four-to-six
  guideline, by choice.
- **`input_passthrough` sees no use.** The only whole face set a group
  forwards is the state pack's five inputs, whose helper names would be
  `state_pack.in1` through `in5` where the faces should read `V`, `γ`,
  `θ`, `q`, `h`. Every face is named explicitly.

## The boundaries

| group | blocks | input faces | output faces |
| --- | --- | --- | --- |
| `sensing` | `noise`, `altimeter` | `h` | `h_meas` |
| `pid_controller` | `h_ctl`, `θ_ctl`, `q_ctl`, `V_ctl`, `free` | `h_ref`, `V_ref`, `h_meas`, `θ`, `q`, `V`, `δe_prev`, `δt_prev`, `mode` | `δe`, `δt` |
| `lqr_controller` | `tracker`, `state_pack`, `z_pack`, `z_ref_pack`, `command_pack`, `u_unpack`, `free_pair`, `engaged` | `V`, `γ`, `θ`, `q`, `h`, `h_meas`, `h_ref`, `V_ref`, `δe_prev`, `δt_prev`, `mode` | `δe`, `δt` |
| `selection` | `select_δe`, `select_δt`, `command_δe`, `command_δt` | `δe_pid`, `δt_pid`, `δe_lqr`, `δt_lqr`, `mode` | `δe`, `δt`, `δe_prev`, `δt_prev` |
| `actuators` | `δe_limiter`, `δe_lag`, `δt_limiter`, `δt_lag` | `δe_cmd`, `δt_cmd` | `δe`, `δt` |

Two build rules the prototype met, both diagnosed by name: an input face
fanning out to several children is spelled `name => (path, path, …)`, and
face names are unique across `input_wires` and `output_wires` together, which
is why the actuators take `δe_cmd` and publish `δe`.

## What the prototype measured

- **The runs reproduce.** Over the 120 s tracker run, every logged signal of
  the refactored loop stays within 6e-9 of the flat loop's (altitude 2e-9,
  the controller commands and the elevator 4e-9 to 6e-9). The residual is
  evaluation order: the exact comparison differs in the last bits from
  `t = 0.015 s` on. The examples' 73 tests pass with every pin and probe
  comment unchanged.
- **A staged write reaches a tick one frame later than a `Step` block
  does.** A batch applies at the top of the next frame, and the ticks at a
  boundary settle in the frame that reaches it, so a write staged after
  `step!(sim; t_plus = 5.0)` is first seen by the 50 Hz blocks at 5.02 s.
  With that one-tick shift the dynamics are the same but the noise
  realization is not aligned with the step, and two pins moved: the standby
  attitude and pitch-rate loops' gaps over `[10, 60)` read 0.137 against the
  flat loop's 0.037 and 0.010, the climb's transient having lasted to 10.8 s
  instead of 9.3 s. The helper therefore stages each write one frame before
  its tick (`frames = frame(t) - 1`), which the test comment states.
- **The tracking pins' window was fragile.** It opened at 10 s, inside the
  transient whose end moves with the noise's alignment, so it pinned a
  realization rather than the companion's claim about the settled climb.
  The five gaps now read over `[15, 60)`. The review swept the step over 25
  tick alignments, 5.00 to 5.48 s: the standby attitude loop's transient
  ends anywhere between 8.6 and 14.0 s, three alignments fail a `[12, 60)`
  window, and from 15 s on every gap reads the same under all 25: 0.0078
  for the standby tracker, and 0.0101, 0.0020, 0.0134 and 0.0374 for the
  standby cascade's pitch-rate, airspeed, altitude and attitude loops.
- **`combine` refuses a second write to `mode`**, so the helper layers the
  mode over `trimmed(solution)` with `override`.
- **A level's face is read with `get_face` mounted at the level**,
  `at("selection", reads(y = get_face(:δe)))`; a path selector addresses a
  component's own declarations and refuses an assembly. The tests gain a
  `logged_face` helper beside `logged_port`, and `largest_jump` and
  `largest_gap` take logged signals rather than `(path, name)` pairs.

## Docs edits (same increment)

- `design/companions/longitudinal_aircraft.md` section 4: the groups and
  their boundaries, the sensing paragraph, the root inputs, the test
  helper's staging rule. The numbers stand.
- `design/companions/examples_inventory.md`: `closed_loop`'s signature and
  layer 5's description.
- `design/pending.md`: the bullet retires.
- The spec and the log are untouched: nothing here rules on the framework.

## Out of scope

- The README's diagram, which does not exist yet; the tutorial bullet adds
  it.
- A closed-loop linearization from `h_ref`, now possible, for the tutorial.
- `design/prototypes/render_spike/` and its hand-transcribed fixtures,
  frozen records.

## Review dimensions

- Wiring equivalence: every one of the flat loop's 55 wires has a route
  through the faces, and no new signal crosses a boundary.
- The docstrings of `closed_loop` and `trimmed` and the companion's
  section 4 describe what is built, group names and face names included.
- The test helper's frame arithmetic at `h = 1//200`, and that each
  `stage!` lands on the tick it is meant for.
- The pinned probes: unchanged by the measurement above, re-read against
  the new reads.

## Review (2026-10-27, one cold Opus reviewer over both commits)

No correctness defect. The reviewer walked the flat loop's 55 wires through
the faces by hand and by flattening both descriptors to leaf-to-leaf wires,
with an empty set difference both ways; ran the five scenarios old against
new, within 6e-9 on the tracker run and 2.4e-8 on the hand-back run's
altitude; reproduced every pinned probe value; and ran 24 mutants. Four
findings, all on tests and wording, fixed in the increment's fix commit:

- No pin checked that the staged `mode` write took effect: a mutant staging
  the current value survived, since `stage!` reports a misspelled face to
  the harness writer's diagnostic cell, not to the caller. A testset now
  reads the root inputs back with `get_input` and pins the snapshot at
  which `h_ref` steps and `mode` flips, which also guards the frame
  arithmetic directly, where before only the hand-back jump pin caught a
  write one frame late.
- The `[12, 60)` window's comment claimed more than held; the window moved
  to `[15, 60)` on the sweep above.
- `trimmed`'s "cascade in command" was unpinned because the helper always
  overrode `mode`; the helper now uses `trimmed` alone when the cascade
  flies.
- Two wordings in the companion's section 4, and the closed-loop
  linearization from `h_ref` recorded on the tutorial's pending bullet.

Accepted survivors: the tracker's `z` reading the true altitude instead of
the measurement, within the pins' bounds as in the old suite; `h_ctl`
holding on the wrong `saturated`, unreachable since the scenario never hits
a limit; the first gap pin reading `δe_prev`, one tick inside the pin's
headroom; `sensing` dropping its rate, which the noise σ pin cannot see, an
existing gap; and `selection` dropping its rate, an equivalent mutant since
the delays' rate is inferred.
