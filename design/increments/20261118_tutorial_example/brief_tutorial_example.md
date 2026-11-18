# Brief: the tutorial's increment 1, the example's main path

The arc makes four commits: this brief, the docs commit, the code commit,
and one fix commit after the cold review. Drafted on 2026-11-18 at
`dec5ee4`. A high-tier agent prototyped the whole increment in the scratch
worktree `../Redstone.jl-worktrees/tutorial_1`, detached at `0d43dfc`, and
revised it over three rounds of the user's rulings. The patch beside this
brief, `prototype_tutorial_example.patch`, is that worktree's diff, and
nothing under `examples/` changed between `0d43dfc` and the tip. The
prototype is the implementation: the coordinator applies the patch and
commits. The user is present. The rulings are R18 to R20 of
`../roadmap_tutorial.md` and L1 to L22 of `notes_tutorial_example.md`. The
brief comes before the docs commit here, since the coordinating session
handed over between the two, so the docs commit's hash enters the review's
record. This brief keeps its record half only.

Not normative: if a shape below proves wrong at the keyboard, stop and
report rather than deviate.

## What is settled

The increment delivers item 1 of the roadmap's sequence and the stage the
"tutorial and the README" bullet of `pending.md` names. Each ruling's
reason is in the roadmap or the notes. In short:

- **The chapter order** (R18). The approach is chapter 7 and "The flight,
  again" is chapter 8, which replays and restores on the final model.
- **No forward reference in a chapter's model** (R19). Its first instance
  is the cascade's `standby` keyword (L6).
- **The names** (L1): `pitch_hold`, `autopilot`, `piloted`, `approach`,
  the conditions `cruise` and `hand_flown`, the groups `sensing`,
  `cascade`, `actuators`, `selection`.
- **The run stages the approach's reference** (L2), 0.15 m every 0.1 s.
- **`approach` replaces `descent()`** (L3).
- **Two rates, untuned** (L4), and **the approach under the autopilot**
  (L5). Neither fallback of the roadmap's risks is taken.
- **`feedback_wires()`** shares the seven root wires of chapters 5 to 7
  (L7). **`approach` nests `piloted` as `vehicle`** (L8).
- **Rates are `Absolute` anchors per discrete child** (L9).
- **Scenarios stage at the stop time** (L10). The legacy
  `fly_closed_loop` keeps its frame-early offset.
- **The altimeter outputs at 10 Hz, already anti-aliased** (L11), and the
  noise keyword is `noise_psd` (L12).
- **The engage bump is pinned as the jump itself** (L13). **The second
  approach sinks at 2 m/s** (L14).
- **The mode is latched** at 10 Hz inside `selection` (L15).
- **The steps of chapters 4 and 5 come from the initial condition** (L16).

L12 to L14 are the previous coordinator's, accepted with no objection.

The docs commit lands before the code commit and touches no rule of the
framework, so the spec and the log stay as they are:

- `design/companions/longitudinal_aircraft.md`. Sections 4 and 5 keep
  their numbers, since the patch's docstrings cite them. Section 4 gains a
  part on the pitch hold, and its parts on the actuators, the sensing, the
  cascade, the initial condition and the engage describe `autopilot` and
  `piloted` with the figures of the notes' section 4. The tracker and the
  two-controller loop stay as the last part, named as chapter 9's and as
  increment 4's to replace. Section 5 becomes the approach and the
  touchdown. Lines 7 and 115 lose "the descent".
- `design/companions/examples_inventory.md`. Section 3's surface, layers
  and pins follow the file, with the layers restated as the chapters and
  their functions and the arc left to the roadmap. Section 2's line 108
  loses "the descent".
- `design/increments/roadmap_tutorial.md`. The three open decisions marked
  "Increment 1" retire to L1, L2 and L3.

## The shape built

Line ranges are from `git show dec5ee4:file`. The patch is the reference:
four files, +490 −34.

- `examples/src/RedstoneExamples.jl`, lines 13 and 17. `s_init` and
  `y_direct` join the `Redstone` import, and `PID` the library's.
- `examples/src/longitudinal.jl`, 329 lines at the tip.
  - Lines 2 to 4, the header, and 104 to 106, `aircraft()`'s docstring,
    name the new functions where they named `descent`.
  - After line 142, between `longitudinal_taps` and `lqr_gains`' docstring
    at 143, 231 lines appear, in this order: `pitch_hold(; discrete =
    false)`; the component `Altimeter` with its four declarations;
    `sensing(; noise_psd)`; `cascade(; standby = false)`;
    `actuators(solution)`; `feedback_wires()`; `autopilot(solution;
    noise_psd)`; `cruise(solution)`; `selection(solution)`;
    `piloted(solution; noise_psd)`; `hand_flown(solution)`;
    `approach(solution; noise_psd)`. The notes' section 2 gives each
    function's root inputs and children.
  - Lines 318 to 329, `descent()` from its docstring's opening at 319, go.
  - `lqr_gains`, `closed_loop` and `trimmed`, 143 to 317, are untouched.
- `examples/test/runtests.jl`, lines 10 and 11. The import list gains
  `get_state`, `taps`, `lifecycle`, `checkpoint`, `restore!`, `replay!`,
  `trace`, `local_wires`, `input_wires`, `output_wires`, `diagnostics`,
  `DiagnosticError`, `TapResolution`, `AlgebraicCycle`, and `Group` from
  the library.
- `examples/test/test_longitudinal.jl`, 198 lines at the tip.
  - Line 5, the import of the six new names in place of `descent`.
  - Lines 15 to 17. `at_trim` loses its `δt` keyword, which only the
    descent's testset used.
  - After line 38, 58 lines of helpers: `frame_index`,
    `pitch_hold_at_trim`, `fly_autopilot`, `fly_by_hand!`, `descend!`,
    `plant_outputs`, `change_times`, `on_10_hz`.
  - Lines 45 and 46. The build testset takes five new models, the pitch
    hold on both tiers among them.
  - Lines 175 to 187, the descent's testset, give way to thirteen chapter
    testsets and one allocation testset, with three runs set up between
    them at the top level of the outer testset: `climb`, `hand` and
    `flight`.

## Measurements

Every figure is the prototyper's, from the probes in
`../Redstone.jl-worktrees/tutorial_1_probes/` and its notes
`tutorial_1_notes.md` beside them. The pins are the notes' section 4, not
repeated here. Julia 1.13.3, the floor both `Project.toml` files declare.

- **Gate.** The examples' runner, `julia --startup-file=no
  --project=examples -e 'using Pkg; Pkg.test()'`, read 146 of 146 in
  27.1 s after round 3, against 77 of 77 in 17.1 s at `0d43dfc`. The
  coordinator reran it in the worktree at the draft: 146 of 146 in 26.9 s.
- **Both activations.** The five new models build under `(Float64,
  ProbeDual)`, in the testset.
- **Allocation.** The approach's four phase bodies read 0 B at `Float64`,
  in the testset. `approach` holds every component of chapters 5 to 7 but
  `autopilot`'s `Constant`. The pitch hold's bodies are not measured.
- **Wall time.** 726 s of flight take about 0.25 s.
- **The sensor.** On the 50 m step, late altitude error, late airspeed
  error and peak: 0.1646 m, 0.0392 m/s and 1050.126 m with a 50 Hz sensor
  at two rates; 0.0640, 0.0150 and 1050.064 at one rate; 0.0775, 0.0187
  and 1050.061 with the 10 Hz altimeter at two rates.
- **The hold chain.** With the shipped limits the attitude loop never
  saturates, in any scenario of the testset. With its limits cut to
  ±0.05 rad/s it stays saturated 1.14 s at two rates against 0.38 s at
  one, and 2.54 s with no hold.
- **The base tick.** `Δt_base = Hz(50)` with `Relative(5)` on the slow
  loops is bit-identical on the step. With `Δt_base` forgotten the
  altitude departs by up to 0.487 m, silently.
- **The log.** The approach runs past `log_max`, so its log keeps 65 537
  snapshots spaced 0.02 s. Chapter 7's tracking pin and chapter 8's
  comparisons read that thinned log.
- **The staged values' rounding.** The stop time moves 7e-11 s between
  `h_ref = 1000 - 0.15 n` and `h_ref -= 0.15`.

Not measured: the compile latency of the new models through a fresh
process, and no mutant was run.

## Readings the prototype took

The prototyper's nine readings and the points of the later rounds were all
put to the user, and each is ruled: L1 to L16 and R18 to R20, as listed
under "What is settled". Reading 5, the cascade with its standby faces
from chapter 5 on, was overruled by R19 and rebuilt as L6. Reading 8, the
conflict with R6, became R18.

**Raised at the brief.** Six points the notes did not settle. The user
ruled on each as the coordinator recommended, on 2026-11-18, and the notes
hold them as L17 to L22.

1. **`piloted` exports `h` for `approach` alone** (L17), the notes'
   friction item 8. This is a second instance of R19, found by the sweep
   the rule asks for. It stands as a named exception: L8 chose the nesting
   knowing this cost, and the alternative is the flat rebuild that L8
   rejected. Chapter 6's page says what the export is for.
2. **Three locals of the legacy `closed_loop` now share a name with a
   module function** (L18): `sensing`, `selection` and `actuators`, at
   lines 221, 263 and 272. The naming rules forbid it. It is harmless at
   run time, and the gate passes. They stay, since increment 4 replaces
   `closed_loop`.
3. **The gate of this arc is the examples' runner** (L19). Nothing under
   `src/` or `test/` changes, and `code_rules.md` routes a change under
   `examples/` to that runner alone. The reviewer and the fixer run it on
   Julia 1.13 and leave the main suite's gate out.
4. **No mutant has been run** (L20). The mutants under "What the tests
   pin" are the coordinator's expectations from reading the patch. The
   cold review runs them first, then its own.
5. **The inspector** (L21). Its `scripts/fixtures.jl` imports `descent`,
   at lines 25 and 64, and its `design/pending.md` does not say so. One
   line goes there, committed in that repo with the code commit here, so
   the next bump of its pin finds it.
6. **One docstring line of `piloted` overruns the file's wrap** (L22),
   the fourth line of its body. The review's fix commit rewraps it, and
   the patch stays the worktree's diff.

## What the tests pin, by property

All in `examples/test/test_longitudinal.jl`. Each mutant is expected to
turn its testset red and has not been run.

- **Every model builds under both activations** (§9.4). An unfed input: a
  tracking wire dropped from `piloted`, or `cascade(standby = true)` in
  `autopilot`.
- **Chapter 4: the continuous pitch hold linearizes with unit DC gain,
  and the discrete one refuses** (§14.10, D-272). A gain of `pitch_hold`
  changed moves the eigenvalues. `Ki = 0` loses the unit gain. A
  `DiscretePID` that linearized would empty the refusal.
- **Chapter 4: the discrete hold at 50 Hz follows the continuous one
  through a step** (§10.5). The rate at 10 Hz moves the discrete peak past
  1e-4.
- **Chapter 5: the autopilot rests at the trim** (§14.5). A seed of
  `cruise` dropped, or a swap in `feedback_wires`.
- **Chapter 5: the outer loops tick at 10 Hz and the pitch loops at
  50 Hz** (§10.5). `slow` and `fast` swapped on any controller.
- **Chapter 5: the autopilot holds the altitude step** (§13.7). An outer
  gain halved, or the sensor's noise at 50 Hz, which reads 0.16 m late.
- **Chapter 5: the altimeter samples and holds at 10 Hz, with noise of
  the declared density** (§3.2, §7.3). The altimeter at 50 Hz, the noise
  at 50 Hz, or `y = h` alone. The legacy loop's accepted survivor,
  `sensing` without its rate, dies here.
- **Chapter 6: the tracking wires without the delays close one algebraic
  loop per switch** (§5.4, §13.8). A delay removed from `selection` makes
  the shipped model refuse. The member sets pin which controller and
  which switch.
- **Chapter 6: the pilot's staged commands and the engage land on their
  snapshots** (§11.3). A write staged one frame early or late, a
  misspelled face, or `hand_flown` with the pilot off the trim.
- **Chapter 6: the standby cascade tracks the pilot and the engage is
  bumpless** (D-385). The two tracking wires swapped, `Tt` at ten
  periods, an outer loop's `v` on the wrong measurement, or the latch at
  50 Hz, which moves the first `engaged` to 30.04 s.
- **Chapter 6: once engaged the autopilot recaptures the reference**
  (§13.7). `selection/engaged` not wired to the cascade.
- **Chapter 7: the approach flies chapter 6's flight to the bit, then
  descends to a touchdown that stops the run** (§2.3, §13.5, D-316).
  Anything in `approach` that disturbs the vehicle, the stop request
  unwired, the gear on another signal, or a sink rate changed.
- **Chapter 8: the whole flight replays to the bit, touchdown included**
  (§12.7). No mutant of the example reaches it, short of a component with
  state outside its declarations. The testset shows the framework's claim
  on this model.
- **Chapter 8: a checkpoint at the top of the descent flies a second
  approach, and the first again to the bit** (§12.6). The second sink
  rate changed moves the pinned time. The bitwise half is the framework's
  claim, as above.
- **The approach's phase bodies allocate nothing** (§9.8). Measured.

## Routing

Single-stage, so none for a builder. The reviewer reads:

- this brief, `notes_tutorial_example.md` whole, and the roadmap's arc
  table with R18 and R19;
- `design/rules/code_rules.md` whole. The caveats that apply are the
  local-scope and the import traps, the staged root input read back, the
  collected refusal, the structural trace of a discrete member, the
  refused `checkpoint` after a `t*` stop, and the test's clock value;
- `design/companions/longitudinal_aircraft.md` sections 4 and 5 and
  `examples_inventory.md` section 3, as the docs commit leaves them, and
  `pid_anti_windup.md` sections 4 and 11, from lines 130 and 520;
- `design/spec.md` by line range: §3.2 at 742 to 801, §10.5 at 6586 to
  7072, §11.3 at 7878 to 8130, §12.6 and §12.7 at 10049 to 10733, §13.5
  at 11371 to 11633, §13.8 at 11996 to 12133;
- in `src/library.jl`, the docstrings of `Switch` above 260, `UnitDelay`
  at 356, `GaussianWhiteNoise` at 789, `PID` at 2442 and `DiscretePID` at
  2581.

`code_map.md` has no entry under `examples/`. The examples' register is
`examples_inventory.md`.

## Bookkeeping

- The docs commit: the two companions and the roadmap, as "What is
  settled" lists, with the battery.
- `design/pending.md`: the tutorial bullet's "Stage reached" moves at each
  commit of the arc, and after the fix commit names increment 2 as next.
  No bullet retires.
- `notes_tutorial_example.md`: the rulings on the six points above, its
  sections 1 and 6 brought to the state at each commit, and its section 7
  rewritten at a handover.
- `design/code_map.md`: nothing.
- `README.md`: nothing. "Under LQR and PID control" holds while
  `closed_loop` stays.
- `RedstoneInspector.jl/design/pending.md`: one line, by L21, with the
  code commit.

## Out of scope

- The legacy `closed_loop`, `lqr_gains` and `trimmed`, their tests and
  their part of the companion, the three locals of point 2 included:
  increment 4, the roadmap's sequence.
- The pages: increments 2 and 3. The notes' section 6 holds what this
  increment hands them: chapter 6 explains the latch, and `stage!` first
  appears there.
- The margins from `A` and `B` that R3 promises for chapter 4: an open
  decision of the roadmap, increment 3's.
- A name for chapter 9's rebuilt selection group: an open decision of the
  roadmap, increment 4's.
- The nineteen friction items and the two fixes sketched: the friction
  review of the API audit, `pending.md`.
- A retune of the standby `Tt` and a flare: not probed, not planned.
- The inspector's fixtures: its next pin bump.

## The cold review

An open mind, probe scripts outside the tree, and "empty is acceptable".
The examples' runner on Julia 1.13. The mutants above run first, and each
fix is reverted alone on a scratch copy to show a test goes red. What to
probe in particular:

- **The wiring.** `autopilot` and `piloted` against the legacy
  `closed_loop`'s cascade path, by flattening the descriptors to
  leaf-to-leaf wires. The differences must be the tracker's absence, the
  latch, the altimeter and the `engaged` source, and nothing else.
- **Every pin and every figure**, reproduced by a probe of the reviewer's
  own, and the companion's numbers against the same probes.
- **The windows.** Sweep the pull, the release and the engage over the
  alignments of the 10 Hz and 50 Hz ticks, 5 ms apart across 0.1 s. The
  standby gaps over [8, 30) and [5, 30), the jumps at the switch, the
  recapture over [80, 90) and the late window from 75 s must read the
  same at every alignment, or the window is a finding.
- **The latch.** That one staged `engage` reaches both switches and all
  four controllers at one tick, whatever the alignment, and what a staged
  `engage = false` does. The docstrings claim nothing about the hand-back,
  so a bump there is a report and not a finding.
- **The thinned log.** Whether any pin of chapters 7 and 8 reads less
  than its name claims at 0.02 s spacing.
- **The staged reference.** `descend!` stages `h_ref` and the testset
  reads it back, but pins no snapshot of it. Say whether the tracking pin
  covers a write that never lands.
- **The R19 sweep.** Each chapter's function for a child, a wire, a face
  or a keyword that only a later chapter uses. Point 1 is the known one.
- **The docstrings** against what is built: face names, rates, the
  default density and its "0.134 m per sample", `Altimeter`'s tier claim
  against §3.2, the latch's "one tick after it is read", and the throttle
  jump "under the 0.01 its rate limiter passes per tick".
- **The naming rules** over the new code, and the tolerance of each pin
  against its probed value. A jump of 0.0011 under a bound of 0.005 lets
  a fourfold regression through.

Survivors the reviewer may accept, each with its reason restated:

- A hold wire of the cascade changed. No scenario saturates the attitude
  loop, and the hold chain's probe needs limits the model does not ship.
- A `yf` seed of `cruise` dropped. With `Kd = 0` it never reaches an
  output.
- The rate of `command_δe` or `command_δt` dropped, if the delays' rate is
  inferred as the legacy review found.

## The review's record

The arc on top of `dec5ee4`: `f71ac93` (this brief), `a4c72ed` (docs),
`e70da63` (code) and the fix commit that adds this record. In
`RedstoneInspector.jl`, `cba1680` carries L21's bullet. Nothing is
pushed.

**The review**, at `e70da63`, by an independent high-tier agent in the
worktree `../Redstone.jl-worktrees/tutorial_1_review`, its probes and
notes beside it. The examples' runner read 146 of 146 on Julia 1.13.3,
and the battery was green. It ran 57 mutants. Of the brief's 28, 26 went
red, one survived and one hung the testset. Its probes found sound: the
wiring flattened leaf to leaf against the legacy cascade path, every pin
of chapters 4 to 8, the six statements the coordinator flagged, every
pin of chapter 6 at 20 alignments of the pull, the release and the
engage, the latch's single instant, and 0 B in the phase bodies of every
new model. It listed eight findings. The user took the coordinator's
recommendations on all of them, and L23 to L25 in the notes record the
rulings they asked for.

A fresh high-tier fixer made the fixes in the worktree
`../Redstone.jl-worktrees/tutorial_1_fix` and showed each test fix red by
its mutant. The coordinator applied its diff to the real tree and added
the two pins paragraphs and one table figure:

- **F1, a staged write that never lands hung the testset.** `descend!`
  now stops at 10 000 writes and returns the count. Chapter 7 pins 6667
  writes and the last staged `h_ref`, −0.05 to 1e-6. The engage or the
  reference misspelled now fail in 31 s.
- **F2, the standby's outer loops were unpinned.** Two gaps over
  [8, 30) s: the altitude loop's command against θ, 0.0086, bound 0.015,
  and the attitude loop's against q, 0.0201, bound 0.03. Their worst over
  20 alignments of each write is 0.0088 and 0.0202. The outer `v` on the
  wrong measurement, at 0.104 and 0.107, goes red.
- **F3, the switches reading `engage` around the latch survived.** The
  instant the selected elevator command first leaves the pilot's is
  pinned at 30.2 s. The unlatched switches, at 30.005 s, go red.
- **F4, the hold chain's figures came from an older model.** The
  companion now gives 1.84 s limited at two rates, 2.02 s at one and
  2.68 s with no hold. L4 carries the correction, and its ruling stands.
- **F5, the approach's tracking read low on the thinned log.** "Within
  0.26 m", against 0.254 m at full resolution, and the airspeed band tied
  to the same span. L5 carries the correction.
- **F6, the sensor table's first peak was a staged step's.** 1050.152.
  Row 2's late altitude error became 0.0641 on the same ground.
- **F7, eight gain and actuator mutants passed every pin.** Chapter 5
  pins the climb's airspeed excursion, 3.9015 m/s to 0.02, and all eight
  go red. The touchdowns tighten from 1e-2 to 1e-3 by L23, which alone
  catches two of them.
- **F8, the 0.0017 rad of jitter** now names its window, [80, 90) s.
- **L22.** `piloted`'s docstring paragraph rewrapped, no word changed.

The fixer moved chapter 7's `h_refs` read above the line that reads
`record.t`, so that a descent which never stops fails the new pins
instead of throwing first. The examples' runner read 152 of 152 in the
fixer's worktree, and 152 of 152 on the real tree before the commit,
with the battery green.

**Survivors accepted.** A hold wire of the cascade changed to the zero
code, since no scenario publishes a nonzero `saturated` code. A `yf` seed
dropped, since with `Kd = 0` it never reaches an output. A delay's rate
dropped, since its 50 Hz rate is inferred. `Tt` doubled, whose figures
stay inside the spread the alignments give. The elevator delay starting
at 0, identical to six digits. Each reads identical to six digits or
within the alignment spread on the reviewer's probes.

**Reported and left.** A staged `engage = false` jumps the elevator
command by 6.6e-4 rad, unpinned by L24. `longitudinal_taps()` carries a
forward reference for chapter 9, handed to increment 4 by L25. The brief's
"65 537 snapshots spaced 0.02 s" reads 65 538, spaced in a mix of 0.01 and
0.02 s. Not checked by either agent: whether the run is identical on the
examples' Linux CI.
