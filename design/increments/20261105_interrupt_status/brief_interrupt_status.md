# Brief: a cut frame is `:inconsistent` and a cut door is `:built`

Tip at drafting: `0217a1c`. Written on 2026-11-05. A one-stage increment
the main session prototyped through a high-tier agent in a scratch worktree
detached at `2bf58f9`, in three rounds, and applies itself, so this is the
record half: what was settled, the shape built, what the prototype measured
and read, what the tests pin, what stays out, and what the review looks at.
The docs commit is `11fbad4`, which adds D-441 and rewrites §12.4, §12.6 and
§13.4. The patch is `prototype_interrupt_status.patch` beside this brief, the
agent's notes `notes_prototype_interrupt_status.md`. The user was present for
every ruling. Line numbers below are the tip's; the four commits after
`2bf58f9` touch none of the files the patch touches, so the prototype's
numbers at `2bf58f9` hold at `0217a1c`.

Design and code are peers, neither subservient.

## Purpose

Close defect g of the docstring audit. `integrate!(::RK4, …)` writes the
clock to the frame top before its fourth `evaluate!`, so an interrupt in
that stage left `xbuf` at a stage point with the clock on a grid top and
the status `:consistent`, and `checkpoint(model)` returned the stage point.
An interrupt in a frame-top handler, a tick or `settled!` left the same
shape. The cause was `frame!`'s catch rethrowing an `InterruptException`
without writing a status (D-317), and the `Simulation` covered the one case
that reached it, the forced throw D-398 let through, with a second witness
in its rest gate, the latest snapshot's frame and time.

## What was settled (user rulings, 2026-11-05, recorded as D-441)

- **The status is written by the host of the catch, whatever threw.** A
  throw inside a frame writes `:inconsistent`; a throw inside a door
  (`init!`, `overlay!`, `restore!`) returns the model to `:built`. The
  status answers one question, whether the stores are a settled boundary,
  and the cause says what cut them.
- **Every catch site wraps what reaches it, an interrupt included.** Option
  A over B (the status written and the interrupt let through raw): with the
  interrupt wrapped, the type carries the disposition to the loop. A bare
  `InterruptException` reaching a loop arm is a deferred raise at an unmask
  point, a stop; a `StepError` is a cut frame, a failure. Under B every arm
  would have had to read the model's status to tell the two apart, and the
  record would have held a bare interrupt with no cursor. The forced throw
  therefore ends the run `errored`, superseding D-398's second bullet.
  Uniformity across the doors was ruled in round 3: `init!` and `overlay!`
  had kept the raw rethrow from before the split, and now wrap like the
  restore and the frame.
- **The restore door hosts a catch of its own**, host `:restore`, pointer
  the state's frame on its own grid, around the copy and the settling. It
  writes `:built` (reading A below), not `:inconsistent` as first built.
- **The run's frame index advances in the loop's top hook**, inside the
  frame's guarded sequence and before the drain. Ruled over the two
  alternatives of reading B, a clock-versus-counter clause in the sim's gate
  and a repair of the counter in the interrupt arm, because it holds by
  structure rather than by a check, survives Julia 1.14's cancellation
  model, and needs no grid arithmetic.
- **The simulation's rest is its lifecycle plus the model's own rest.**
  `_assert_at_rest(sim)` keeps the lifecycle test; the status and the clock
  on a grid top are the model's gate, which `checkpoint(sim)` reaches
  through `checkpoint(sim.model)` and `overlay!(sim)` asks before its first
  write. The snapshot witness and `CheckpointMidFrame`'s frame-top message
  branch go.
- **A bare value thrown by model code moves the status** like any throw;
  only the carrier is lost (reading E). The status is written before
  `_wrap_step` runs.

## The shape built

**`src/frame.jl`**
- 14–19, the comment above `frame!`: the catch wraps every throw.
- 46–49, the docstring's last paragraph: the interrupt is included in the
  `StepError` sentence; "never wrapped and writes no status" goes.
- 66–71, the catch: `@atomic :release model.status = :inconsistent`, then
  `rethrow(_wrap_step(model, k - 1, :loop, err))`; the species check line
  goes.

**`src/model.jl`**
- 70–74, the `Model` docstring's status paragraph: the door rule and the
  frame rule.
- 245, 273–277, 310, `init!`: comment, docstring and catch; the catch
  writes `:built` then wraps every throw with host `:boundary_zero`.
- 372, 399, `overlay!`: docstring and catch, likewise with host `:overlay`.
- 810–817, the `_wrap_step` comment: the caller list gains the restore.
- 911–918, the `checkpoint` docstring: the legality sentence under the rule.
- 1005–1033, the `restore!(model)` docstring: the catch's paragraph.
- 1049–1058, `_restore_state!`: `k` from `_frames_to` on the state's own
  grid, the cursor's `comp` and `fn` reset, the copy and `settled!` in one
  `try` whose catch writes `:built` and wraps with host `:restore`;
  `:consistent` written last as before.

**`src/diagnostics.jl`**
- 246, the `StepError` host comment gains `:restore`.
- 282–301, `showerror(::StepError)`: a `:restore` lead line ("restoring
  boundary k (t = …)"), a `:restore` recipe, and an interrupt arm covering
  all four hosts (readings C and the round-3 wordings).
- 2520, 2527–2535, `CheckpointMidFrame`: the docstring's "a frame an
  interrupt from model code abandoned" and the message's `t == t_frame`
  branch and interrupt clause go.

**`src/sim.jl`**
- 14–21, the head comment; 104–117, the `LoopError` docstring; 483–492, the
  `lifecycle` docstring's `:built` bullet; 800–803 and 951, the `init!` and
  `overlay!` docstrings; 843–851 and 868–874, `checkpoint(sim)`'s comment
  and docstring; 1047, `restore!`'s; 1140–1143, `linearize`'s; 1501–1503,
  `run!`'s; 2165, `step!`'s. A grep for "other than an `InterruptException`"
  over `src/` returns nothing.
- 879–902, `_assert_at_rest(sim)`: the clock and snapshot clauses go.
- 957, `overlay!(sim)`: `_assert_at_rest(sim.model, :overlay!)` before its
  first write (the prototype's one deviation, kept; see the readings).
- 1991–1995, `frame_top!(hooks::LoopHooks)`: advances `run.frame`, then
  drains. 2077–2081, `_advance!`: `frame!(sim.model, run.frame + 1, hooks)`,
  the `k = (run.frame += 1)` line gone. 2040–2052, 2063, 2086–2102: the
  inner arm stores every throw as `failure`; the carve-out, its `return`
  and its comments go. 2610–2612 and 2649: the drain comments follow.

**`test/fixtures.jl`**: 867–870, the `Interrupter` docstring; after 879,
`LastStage`, the probe's fixture at top level, zero-argument, in the Dual
sweep.

**`test/test_failures.jl`**: head comment; `HookedInterrupter` →
`HookedRamp` (its armed RHS runs its hook and no longer throws); new
fixtures `TopInterrupter` (a Bool guard at 0.15 whose handler throws) and
`InterruptingSettle <: FrameHooks`; the testsets at 366 and 388 replaced by
the ones below; the rendering testset extended.

**`test/test_lifecycle.jl`**: the rename only (32, 34, 519–552).

**`test/test_trace.jl`**: 1115–1117, the `TickInterrupter` comment;
1262–1283, the abandoned-frame loop now ends `errored`.

**`test/test_diagnostics.jl`**: 1228–1234, the never-published assertions
replaced by `!occursin("interrupt", rendered)` on the `t*` message.

## Measurements

- The catch arms are cold and the top hook's increment is one `Int` write,
  so the loop path did not move: every allocation and specialization pin
  passes unchanged.
- Worktree, round 3: routed subset (failures lifecycle diagnostics build
  trace devices) 3053/3053; full gate under the sandbox flags 9164/9164 in
  9m04s; examples 77/77. The Dual sweep reads 129 covered, 62 skipped, 102
  refused at nominal, unchanged, so `LastStage`, `TopInterrupter` and
  `HookedRamp` all build at `ProbeDual`.
- Real tree at `0217a1c` with the patch applied, run by the coordinator
  before the commit: full gate under the sandbox flags 9359/9359 in
  15m23.8s, sharing the cores with a peer's review; examples 77/77.

## Readings the prototype took

- **A, the restore's status.** Built `:inconsistent` as instructed,
  recommended `:built`: `restore!(sim)` runs unmasked, so a single Ctrl-C
  during the copy would have left the session `errored` with
  `termination(sim)` empty. Ratified `:built`.
- **B, the counter window.** With the snapshot witness gone, a forced throw
  between `k = (run.frame += 1)` and `frame!`'s `try` left the counter one
  ahead of a consistent clock, and `checkpoint(sim)` labelled state `k - 1`
  as frame `k`. Recommended restoring the clock clause; ratified the third
  option, the advance in the top hook.
- **C, `showerror` wordings.** `:restore` lead line "restoring boundary k
  (t = …)"; recipe "restore!(sim2, cp) of the same checkpoint reproduces
  it"; interrupt arms "an interrupt cut the frame, so nothing reproduces it;
  replay!(sim2, trc; to_boundary = k) resumes from the boundary it started
  at", and the `:restore`, `:boundary_zero` and `:overlay` variants
  ("… resumes from boundary k", "… init!(sim2, condition) under the same
  condition runs it again", "… overlay!(sim2, condition) on the same stopped
  state runs it again"). Ratified as written.
- **D, the `:restore` pointer.** `_frames_to(state.t, state.t₀,
  state.deployment.h)`, equal to `cp.frame` for a sim checkpoint. The
  cursor's phase is left stale and not rendered. Ratified.
- **E, a bare value.** The status written first moves the lifecycle where
  §13.4 said it did not; ratified, the spec sentence changed in `11fbad4`.
- **F, the lost `step!` count.** Moot once B's third option landed.
- **G, the sim arms.** Of the eleven `err isa InterruptException` tests in
  `sim.jl`, only `_advance!`'s inner arm changes; every other one is now
  reachable only by a deferred raise at an unmask point. The sim's doors
  have no arm at all, so a door's `StepError` propagates straight out with
  the lifecycle `built`.
- **The `overlay!(sim)` gate call.** Instructed to drop it, the prototype
  kept it: without it a `t*` stop is refused only by the plan method, after
  `_reset_periphery!` and `_open_run!` have run, and `test_lifecycle.jl:813`
  ("refuses before any write") goes red. Kept, as the sim relying on the
  model's gate. The plan method repeats the check, as `overlay!(model,
  condition)` already did at the tip.
- **The dead branch.** `CheckpointMidFrame`'s `t == t_frame` branch had two
  construction sites left, `model.jl:942` and `model.jl:1002`, both throwing
  only off the grid; the sim's site is gone. Every clock writer sits inside
  `frame!`'s `try` or a door, so a cut frame is refused by the status and a
  `t*` abandon by the clock. Direct calls to the ungated primitives can
  still move a `:consistent` model's clock, as at the tip.

## What the tests pin, by property

Mutant scripts and logs sit in the agent's scratch (`mut/` beside the
patch's source); the reviewer reverts each fix on a scratch copy as
`increment_rules.md` says.

- "an interrupt inside a model's frame writes :inconsistent and arrives
  wrapped (§13.4, §12.6)": three cases, `LastStage`'s RK4 stage 4,
  `TopInterrupter`'s handler at frame 2's top, `InterruptingSettle` after
  frame 1. Each asserts `StepError{InterruptException}`, host `:loop`,
  `boundary == k - 1`, the cursor, the clock on the top, `:inconsistent`,
  `checkpoint` refused as `ServiceLifecycle`, and `restore!` of the earlier
  state back to `:consistent` with an equal checkpoint. Red under m1,
  `frame!`'s carve-out restored (11 failures, 6 errors across failures and
  trace).
- "a restore an interrupt cuts returns the model to :built under host
  :restore (§12.6, §13.4)": red under m2 (the `try` removed), m3 (pointer
  `k - 1`), m4 (cursor reset dropped).
- "a door's catch wraps an interrupt and returns the model to :built
  (§13.4, §12.6, D-441)": model `init!` (host `:boundary_zero`, boundary 0,
  cursor `("c", :handler, :round, 1)`, status `:built`, a plain `init!`
  reopens), model `overlay!` after frame 1 (host `:overlay`, boundary 1),
  sim `init!` (lifecycle `built`, then `initialized`). Red under m15 and
  m16, the raw rethrows put back.
- "an interrupt thrown inside a frame ends the run errored under its
  StepError (§12.4, §13.4)": under `step!`, the rethrow, `errored`,
  `LoopError.exception === err`, the last published `t = 2h`,
  `checkpoint(sim)` refused as `ServiceLifecycle`; under `run!` with
  `TailProbe` rostered, `errored`, one error log, the probe's
  `[:init, :shutdown]`. Red under m1, m11 (`step!`'s arm reads the type as
  a stop) and m9 with m10 together.
- "a deferred interrupt after another issuer keeps that issuer as the
  source (§12.1, §12.4, D-268)": a real SIGINT under `sigint_raising` with
  the hook's `stop!` first; held, `stopped`, source `:code`, frame 3. Red
  under m7 (`_interrupt_source` forced to `:interrupt`).
- "the run's frame index advances inside the frame's guarded sequence
  (§13.4, §11.5, D-317)": the harness writer's drain thunk replaced by a
  throwing closure; `StepError{ErrorException}`, host `:loop`, boundary 2,
  cursor `(nothing, :none, :drain, 0)`, `errored`, clock at `2h`,
  `run.frame == 3`. Red under m14 (drain before increment: 40 failures, 12
  errors).
- Rendering (§13.4, §13.2): the `:restore` lead line and recipe and the
  four interrupt arms, none naming `replay!` for a door. Red under m5, m6,
  m17, m18 (each arm removed).
- `test_trace` "the refusals of `checkpoint` and `restore!` (§12.6,
  D-274)": the loop rewritten to `errored` and `ServiceLifecycle`, the
  clock-at-top witness kept. Red under m1.
- `test_diagnostics` rendering: no interrupt clause in the `t*` message.
  Red under m8.
- Unchanged and still passing: the pause-block unmask point
  (`test_devices.jl:446`) and the mask's-end point (`test_failures`, "a
  signal inside a frame is deferred to its unmask"). No test pins a real
  signal at the pacer's wait or the `yield`.

## Routing (the cold review)

- `design/rules/code_rules.md` whole; `docstring_rules.md` for the edited
  docstrings.
- `design/code_map.md`: "What is real here", and the entries for
  `src/frame.jl`, `src/model.jl`, `src/sim.jl`, `src/checkpoint.jl`,
  `src/diagnostics.jl`, `test/fixtures.jl`, `test/utils.jl`.
- `design/spec.md` at `11fbad4`: §12.4's operator-interrupt subsection,
  §12.6's lifecycle and checkpoint paragraphs, §13.4 whole, Appendix C's
  `CheckpointMidFrame` and `StepError` entries.
- `design/log.md`: D-441, and the annotated D-132, D-268, D-317, D-318,
  D-394, D-398.
- The authoring caveats on masks, `interrupt_parked`, real SIGINT delivery,
  and tests never passing by timing.

## Bookkeeping

- `design/code_map.md`: the `frame.jl`, `model.jl` (restore bullet,
  `_wrap_step`, rest gate) and `sim.jl` (`checkpoint(sim)`, `LoopHooks`,
  `_advance!`) bullets, landed in `11fbad4`.
- `design/pending.md`: the defect g bullet retired in `11fbad4`.
- No inventory rows, no new exported names, nothing for `docs/`.
- The audit's ledger rows 23, 24, 37, 62, 76 and 83 (`A6.txt`) stay as the
  audit left them; reports stay untouched until the release.

## Out of scope

- The operator interrupt on Julia 1.14: its own pending bullet. D-441's
  rule is mechanism-agnostic, and what 1.14 must add is a shield at the
  frame top.
- Direct calls to the ungated stepping primitives, which can move a
  `:consistent` model's clock: a poke at the internals, as at the tip.
- The `overlay!(sim)` double check: the plan method repeats the model's
  gate. A wart with no cost, left for the exported-name audit's sweep of
  the doors.

## The cold review

- Revert each fix alone on a scratch copy and show its test red; the
  mutant table above names the expected one.
- Survivors to accept: m9 and m10 alone (each of `run!`'s paired arms
  covers the other, by design; together they die), and m13 (the counter's
  advance moved back before the call: the two placements differ only for a
  throw landing in a window no deterministic test reaches, since the
  forced throw cannot be produced).
- Probe: a synchronous `InterruptException` from a stage, a handler and
  `settled!` on a `Model` at `Float64` and at `ProbeDual`; the forced-throw
  stand-in under `step!` and `run!`; the three doors cut; a real SIGINT at
  the pause block and the mask's end on `-t 1` and `-t auto`.
- Sweep: every `err isa InterruptException` in `src/` against the
  prototype's table (reading G), and every docstring that names an
  interrupt against D-441's wording.
- The gate on the Julia floor `Project.toml` declares, and the examples
  runner.

## The review's record

The cold review ran on `afc1568` in a worktree, on Julia 1.13.3, the floor:
the gate 9359/9359 in 9m09s, the `-t 1` subset `failures devices lifecycle
trace` 1610/1610, the examples 77/77. Its probes and mutant scripts sit in
the coordinator's scratch (`review_probes/`), the one probe worth keeping
copied beside this brief. Six findings survived verification; the user
ruled on the first, the coordinator landed the rest as the docs commit
`8bd06bf` and the code commit after it.

- **F1, a false premise in D-441's Rationale and §12.4.** Both said a run
  ending `errored` after a forced throw loses "nothing operational", since
  `init!`, `restore!` and `replay!` accept any status. True of the model's
  doors, false of the simulation's: all four refuse `:errored`, which §12.6
  rules terminal (D-059). The user re-ruled A with the true cost, the
  session, on the ground that a cut frame is a frame failure and `errored`'s
  terminality is D-059's own rule with no exception for one species of
  failure. The two sentences now say the simulation is terminal like any
  `errored` one and the trace replays the run into a fresh simulation.
- **F2, the defect class survived in the doors' prefix.** `init!` runs
  `establish_defaults!` (the user's `m_init` inside), `_apply_plan!` and the
  clock writes before its `try`, and `overlay!` runs `_apply_plan!` before
  its own. A throw there on a re-initialized model left `:consistent` over
  half-reset stores, and on a simulation `run.frame == 0` with the clock at
  the old time, a case the dropped clock clause had refused at the tip.
  Fixed by writing `:built` at each door's first write (`init!`, `overlay!`,
  `_restore_state!`), so a throw anywhere in a door leaves `:built`, a
  `settled!` throw included; the two docstrings' "writes no status" became
  "the status left `:built`". The reviewer's probe then reads `:built`,
  `checkpoint(sim)` refused as `ServiceLifecycle`, `step!` as `MissingInit`.
- **F3, a raw interrupt out of `frame!`'s catch.** The species rule's
  lookup re-invokes the user's declarations and rethrew an interrupt raw,
  now after the status write, so the run ended `errored` under a stop
  record. Fixed: the lookup returns the original error on any throw, since
  the frame has already failed. `_advance!`'s header comment (F6) is true
  with it.
- **F4, reading E unpinned.** The mutant moving `frame!`'s status write back
  after `_wrap_step` survived. Fixed by the `BareThrower` fixture and the
  testset "a bare value thrown inside a frame moves the status, the carrier
  lost (§13.4, D-441)", asserting the constructor's `MethodError` and
  `:inconsistent`.
- **F5, a false comment and an ambiguous sentence on the counter.**
  `frame_top!`'s comment claimed the index is the clock's frame plus one
  after any cut frame, false when the throw lands after the clock write;
  §12.4's "a throw there" read as inside the `try`. Both reworded.
- **F6**, `_advance!`'s header missing F3's source: resolved by F3.

The mutant table ran as predicted, with four extra mutants of the
reviewer's (the `:restore` lead line and interrupt recipe, the `overlay!(sim)`
gate call, the restore catch at `:inconsistent`), each red. Survivors
accepted: m9 and m10 alone, and m13. Rejected: m21, F4's.

Outside the increment, reproduced at `0217a1c`: a real SIGINT into the
pause wait at `-t 1` with a device rostered hangs. Recorded as a pending
bullet with the probe `probe_pause_wait_t1.jl` beside this brief.
