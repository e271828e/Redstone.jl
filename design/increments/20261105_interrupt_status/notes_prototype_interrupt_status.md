# proto_interrupt notes

## Milestone 1: reading done (2026-11-05)
- worktree at scratchpad/proto_interrupt, detached at 2bf58f9, Manifest copied.
- init!/overlay! keep settled!(hooks) OUTSIDE their try, and write :built on a throw (interrupt raw).
- Reading A (restore status): brief says :inconsistent; init!/overlay! write :built. In a sim, :inconsistent
  reads errored, terminal, with no termination record (the run was opened fresh), and restore! is unmasked,
  so a single Ctrl-C during restore!(sim) would make the session terminal. Recommend :built. Implementing
  the brief's :inconsistent, flagging.
- Reading B (sim rest gate): forced throw between `run.frame += 1` and frame!'s try leaves run.frame = k,
  clock at t_{k-1}, status :consistent, raw interrupt -> stop. Old sim clock clause (clock vs grid(run.frame))
  caught it; the model's gate does not (clock on *a* grid top). Brief drops it; flag.
- run.frame is incremented before frame!, so after a t* stop run.frame == _frames_to(clock) == k: payloads equal.
- Bare-value throw: brief's order (status first, then _wrap_step) makes a bare value move the lifecycle
  to errored; spec §13.4 says "the lifecycle does not move". Following brief; list sentence.
- interrupt_parked lives in test/test_devices.jl:218, not utils.jl. Frame-top (pause block) unmask point
  pinned by test_devices "an interrupt in the pause wait ends the run stopped at that frame top";
  the mask's-end unmask by test_failures "a signal inside a frame is deferred to its unmask".
- Old tests to rewrite: failures 366 (carve-out), 388 (HookedInterrupter after issuer), trace 1262 loop
  (TickInterrupter/Interrupter CheckpointMidFrame), diagnostics 1228 (never-published branch);
  lifecycle 515 uses HookedInterrupter's sync throw only to end the run.

## Milestone 2: src and tests edited (first pass)
- src: frame.jl catch; model.jl _restore_state! try (+cursor comp/fn reset), docstrings Model/checkpoint/restore!;
  diagnostics.jl showerror :restore lead + recipe, interrupt arm, CheckpointMidFrame branch dropped;
  sim.jl _advance! inner arm stores any throw, sim _assert_at_rest = lifecycle only, overlay!(sim) calls
  model gate before writes, docstrings LoopError/run!/step!/checkpoint/linearize/restore!/lifecycle.
- tests: LastStage in fixtures.jl; test_failures: HookedInterrupter -> HookedRamp (no throw), TopInterrupter,
  InterruptingSettle; 4 testsets replace the carve-out pair; rendering arms; trace loop rewritten; diagnostics
  never-published lines dropped.
- probe p1 (scratchpad/probes/p1.jl): LastStage frame 1 -> StepError{InterruptException} host loop b 0,
  cursor (c, x_deriv, integrate, 4), status inconsistent, checkpoint ServiceLifecycle, restore -> consistent.

## sim arm audit (tip line numbers)
- 1641 _run_body! inner catch `err isa InterruptException || (cause = err)`: bare interrupts out of _advance!
  are now (a) a raise in _advance!'s unmasked outer catch / _interrupt_source (second Ctrl-C), (b) a forced
  throw in the mask outside frame!'s try (between sigatomic_begin and frame!'s try, or after frame! returns
  until sigatomic_end), (c) a forced throw inside frame!'s catch (species lookup rethrows, model.jl:862),
  status already :inconsistent. Unchanged.
- 1650 outer arm: bracket edges, spawn mask, tail; plus the above. Unchanged.
- 1680, 1703: retry loops of the arm, unmasked raises only. Unchanged.
- 1822 _init_devices!: device init!, no frame. Unchanged.
- 1879, 1894, 1905 _tail!: unblock!/join, no frame. Unchanged.
- 2100 inner catch: changed, stores any throw.
- 2107 _advance! outer catch: deferred raises at wait_resume!/yield/wait_deadline!/mask end/inner catch's
  sigatomic_end; a bare failure (case b/c) is rethrown raw by `failure === nothing || throw(failure)`.
- 2224 step!'s arm: as 1641. Unchanged.

## Milestone 3: subsets green, mutants
- routed subset (failures lifecycle diagnostics build trace) under gate flags: 2711/2711 green; Dual sweep
  129 covered, 62 skipped (pin unchanged), 102 refused at nominal.
- mutants (scratchpad/mut): m1 frame! carve-out back -> 11 fail 6 err (failures, trace); m2 restore try
  removed -> red; m3 restore pointer k-1 -> red; m4 cursor reset dropped -> red; m5 interrupt arm off -> red;
  m6 :restore recipe off -> red; m7 _interrupt_source forces :interrupt -> red; m8 interrupt clause back in
  CheckpointMidFrame -> red; m9 / m10 singly survive (each run! arm stores `cause` independently, so either
  alone is equivalent); m9+m10 together -> red; m11 step! arm treats StepError{Interrupt} as stop -> red.
- probe p2: inner restore cut in a sim -> lifecycle errored, termination nothing, restore!/init! refused
  ServiceLifecycle errored. Supports Reading A (:built recommended).

## Milestone 4: gate and examples
- full gate under sandbox flags: Redstone 9145/9145 pass, 9m02s, exit 0 (allocation and specialization pins inside).
- examples: Pkg.instantiate + Pkg.test(): Longitudinal 77/77, exit 0.
- patch written: scratchpad/proto_interrupt.patch (no new files; examples Manifest untracked, not in patch).

## Round 2: rulings A (:built) and B (counter advance in the top hook)
- A applied: _restore_state! catch writes :built; Model/restore!(model)/restore!(sim)/lifecycle docstrings.
- B applied: frame_top!(::LoopHooks) = (run.frame += 1; drain!); _advance! calls frame!(model, run.frame + 1, hooks).
  frame_top! runs only inside frame! (frame.jl:57); init!, overlay!, _restore_state! call settled! only.
- Coordinator asked to remove `_assert_at_rest(sim.model, :overlay!)` from overlay!(sim). Removed and ran
  lifecycle+failures: test_lifecycle.jl:813 red (`lifecycle(halted) === :stopped` after a refused overlay!
  on a t* stop): the model's refusal then comes after _reset_periphery!/_open_run!, so the stopped sim reads
  initialized at a mid-frame clock. Kept the call; flagged.
- New testset "the run's frame index advances inside the frame's guarded sequence" (poke: plane.harness_drain
  replaced by a throwing thunk; no fixture throws inside the drain). Subset failures lifecycle diagnostics
  build trace devices: 3038/3038. Mutants: m13 (old placement, increment back before the call) survives
  failures+trace+devices 1198/1198, by construction (differs only in the forced-throw window);
  m14 (drain then increment) red: 40 fail 12 err.
- Round 2 gate and examples: see the report; patch rewritten at the same path.
Redstone      | 9149   9149  8m48.0s

## Round 3: doors wrap the interrupt (D-441)
- init!/overlay! catches: the raw-interrupt rethrow goes; docstrings (model init!/overlay!, sim init!/overlay!).
- showerror: interrupt arms for :boundary_zero and :overlay.
- New testset "a door's catch wraps an interrupt and returns the model to :built"; rendering extended.
- No suite test pinned the raw form (IntrEv lived only in the audit probe). Sim init!/overlay!/_enter_checkpoint!
  have no catch; the StepError propagates out of the door.
- Subset failures lifecycle diagnostics build trace devices: 3053/3053.
- Mutants: m15 (init! raw rethrow back) red 2F 2E; m16 (overlay! raw rethrow back) red 1F 1E;
  m17 (:boundary_zero interrupt arm off) red 2F; m18 (:overlay interrupt arm off) red 2F.
- Gate: Redstone 9164/9164, 9m04s, exit 0. Examples: Longitudinal 77/77, exit 0. Patch rewritten (1018 lines).
