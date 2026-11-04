# Brief: increment 80, the `overlay!` door

One code commit, which I apply from the prototype, one cold review and a
fixer if the review needs one. Written on 2026-10-20 at 4f922f7, the docs
commit that landed D-429 with its spec sentences (§11.5, §12.6, §13.4, the
§14 intro, §14.1, Appendix B) and the annotations on D-063, D-273 and D-274.
The design record the entry was written from is
`companions/store_at_rest_walkthrough.md` section 7. Find passages in
`design/implementation.md` by heading.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

`prototype_increment_80.patch`, beside this brief, is the reference
implementation, taken at 6145fdd on a scratch worktree where the full gate
ran green at 6550 assertions and a probe of every pin below passed its 62.

## What is settled

D-429 and the spec sentences it landed, as 4f922f7 leaves them:

- `overlay!(sim, condition; trace, log, log_every, log_max)` writes a
  condition onto a stopped run and continues it as a fresh trajectory. The
  named stores are overwritten on the run's own; every other store, the
  clock, the lattice and the guard priors are kept; a root-input entry
  writes its cell and no totality is asked; a partial store entry merges
  onto the current store.
- The overlaid state settles through boundary zero's tail with the discrete
  output stages and the `s_update` calls left out: projection, then the
  sweep and the events to quiescence with the priors kept. An overlaid
  discrete store is the next tick's state and its held cell stays; a guard
  the overlay moved into holding fires at the overlay boundary; a guard
  already holding does not fire again.
- The settling publishes one snapshot at the stopped run's `t` under its
  last ordinal, as `restore!` re-publishes, and the trace header is the
  checkpoint taken after it. Replay reproduces the overlaid trajectory with
  no record of the overlay.
- The door is legal where `checkpoint` is, `initialized` or `stopped` with
  the clock on a published frame top, and refused otherwise as
  `ServiceLifecycle` with `legal = [:initialized, :stopped]` or
  `CheckpointMidFrame`. A throw inside the settling is a `StepError` with
  host `:overlay` and leaves the simulation `built`, no header.
- `overlay!(model, condition; hooks)` and `overlay!(model, plan; hooks)` are
  the model's forms, legal at `:consistent` on a frame top, gated on the
  claim as every writing door is.
- `init!` is bit-identical before and after the factoring.

## The shape, as the patch has it

- `src/model.jl`: `boundary_zero!` becomes a one-liner over `_settle!(model;
  fresh)`, which carries the sweep's gate (`ESTABLISH` fresh, the off-tick
  sweep continuing) and the `ticks(0)` call under the flag. The priors stay
  at the doors: `init!` resets them, `overlay!` keeps them, so the primitive
  `boundary_zero!` keeps its meaning. `overlay!`'s two methods sit after
  `init!`'s, the catch in each door's body with its own host and pointer.
  `_assert_at_rest(model, op)` is factored out of `checkpoint(model)` and
  returns the frame; `_store_values(exec)` reads the merge bases off the
  stores in `_store_bases`' order.
- `src/conditions.jl`: `resolve_condition` takes `bases = nothing`, the
  declared defaults when `nothing`; the misuse fallback absorbs the keyword.
  The plan's shape and `apply!` are untouched.
- `src/sim.jl`: `overlay!(sim, …)` after `checkpoint(sim)`, which now calls
  `_assert_at_rest(sim, op)`, the lifecycle and mid-frame checks factored
  out of it. The door checks rest, then the recording keywords, resolves
  with the stores as bases, resets the periphery, opens the run at the
  stopped run's counters, steps the ordinal back as `_enter_checkpoint!`
  does, calls the model's door under `LoopHooks`, and takes the header last.
- `src/diagnostics.jl`: the `:overlay` recipe arm in `showerror`;
  `src/checkpoint.jl`: the `ModelState` docstring's no-algebra sentence
  sharpened; `test/imports.jl`: `overlay!`.

## Rulings made while writing, each recorded in `notes_increment_80.md`

The priors' placement, the stepper, the merge base as a resolution keyword,
the gate factored from `checkpoint`, the host tag and pointer, the ordinal
dance, and the test placement.

## What the tests pin, by property

- `test/test_discrete.jl`: an overlaid `TickCounter` store reads the overlaid
  value at its next tick and the held cell is unchanged at the overlay
  boundary, against `init!` from the same copy, which decodes it now; a
  multi-rate controller overlaid at a non-due frame keeps moving at
  `8:4:40`.
- `test/test_events.jl`: a root-input entry moves `Trigger`'s `Bool` guard
  into holding and it fires at the overlay boundary; an overlaid `x` moves
  `Sawtooth`'s sign-form guard into holding and the handler wraps before
  the next integrate; a holding `Trigger` does not re-fire, and a partial
  `m` entry merges onto the current mode store; an overlaid `Rotor` state
  off the circle is projected before publication.
- `test/test_trace.jl`: the door opens a fresh run whose header equals the
  post-settling checkpoint field by field, one snapshot under the stopped
  run's last ordinal, the staged batch dropped, the continuous cell
  refreshed and the discrete cell held; replay of the overlaid trajectory
  reproduces it with its ordinals; `trace = false` leaves no trace.
- `test/test_lifecycle.jl`: the refusals, `built`, `errored`, a `t*` stop
  (`CheckpointMidFrame` at frame 4), a recording keyword, a bad entry and a
  bare NamedTuple, each writing nothing; a throw inside the settling
  (`Mine` armed by a root-input entry) is `StepError{Detonated}` with host
  `:overlay`, pointer 2, cursor at `c` in an event round, the simulation
  `built`, `trace` refused and `init!` legal again; the model door on a
  standalone model, the plan method, the `:built` refusal with
  `legal = [:consistent]` and the claimed model's `:claimed`.
- `test/test_failures.jl`: the rendered recipe for host `:overlay`.

## Bookkeeping, in the same commit

- `design/implementation.md`: the `src/model.jl` entry's doors list
  gains `overlay!` and names `_settle!` under the macro-sequence bullet and
  `_assert_at_rest` and `_store_values`; the `src/sim.jl` entry's doors
  bullet gains `overlay!` and `_assert_at_rest`; the `src/conditions.jl`
  entry says `resolve_condition` takes the merge bases.
- `design/pending.md`: the "A state what-if" bullet retires.
- Files to commit: `src/model.jl`, `src/sim.jl`, `src/conditions.jl`,
  `src/checkpoint.jl`, `src/diagnostics.jl`, `test/imports.jl`,
  `test/test_discrete.jl`, `test/test_events.jl`, `test/test_trace.jl`,
  `test/test_lifecycle.jl`, `test/test_failures.jl`,
  `design/implementation.md`, `design/pending.md`. Never a
  `Manifest.toml`, and never another session's untracked files.

## Out of scope

- §14.5's rest-reading sentence, planned with Appendix A's rewrite and in
  a parallel session's hands.
- Whether `overlay!` is exported: the audit's.
- Sugar on `restore!`, a stepper reset hook, `trim!` or `linearize` over an
  overlaid point: each rejected or deferred in D-429 or the record.

## The cold review

One fresh Opus reviewer over the code commit, 4f922f7 read for what it
owes: open-mind stance, probe scripts in the scratchpad, "empty is
acceptable". Dimensions:

- **The docs against the tree.** D-429's Position and its three bullets
  hold of the code, each probed; §12.6's paragraph, §14.1's base sentence,
  the §14 table row and Appendix B's two rows describe what the doors do.
- **The five choices.** Confirm from the code that `init!` and `overlay!`
  differ in exactly the five and share everything else, and that `init!`'s
  path is byte-for-byte the old one (`_settle!(fresh = true)` reproduces
  the old `boundary_zero!` body).
- **The rest reading.** On a multi-rate model overlaid at a due frame and
  at a non-due one, the held cell and the store relate as section 1 of the
  companion says, and the next due tick decodes the overlaid value.
- **The ordinals and the header.** The overlay snapshot's ordinal, the
  run's counter after it and the header's, against `restore!`'s.
- **Naming** over every touched line; `test/imports.jl` sorted where it
  was sorted; no local shares a name with a function its module sees.
- **Mutants on a scratch copy**, each named test going red: the continuing
  sweep run under `ESTABLISH`; `ticks(0)` run under `fresh = false`; the
  priors reset in `overlay!`; projection skipped under `fresh = false`; the
  header taken at the run's opening; `bases` ignored in favour of the
  defaults; the ordinal step-back dropped; the status left `:consistent`
  on a throw; `_assert_at_rest` dropped from the sim door; `init!` calling
  `_settle!(fresh = false)`. A surviving mutant is a missing test, or an
  acceptable survivor named with its reason.
- The gate and the examples' runner green on the Julia floor `Project.toml`
  declares.
