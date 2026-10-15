### D-386 — Run no framework task as a thread monopolist

**Status.** ratified

**Position.** No framework task is a thread monopolist.

**Spec.** §12.2

**Rationale.** This restates the first ground of D-027's rejection of a hard
`nthreads` error, "no framework thread monopolist", which its Position does
not state. The spin's rule is not restated, because D-027's Position states
it. The entry decides nothing new.

**Rejected.** None beyond D-027's list.

### D-387 — Reproduce an error by trace replay, never by resuming the simulation

**Status.** ratified

**Position.** An error is reproduced by trace replay, not by resurrecting the
errored simulation.

**Spec.** §12.6

**Rationale.** This restates the reason in D-059's Rejected list for refusing
resumable-after-error simulations, which its Position does not state: the
stores may be mid-boundary, and reproduction is trace replay, not
resurrection. D-059's Position makes `errored` terminal. The entry decides
nothing new.

**Rejected.** None beyond D-059's list.

### D-388 — `step!`'s contract, and the authored re-run

**Status.** ratified

**Position.** Four rulings on partial advance and the re-run.

- `step!(sim; frames)` is a synchronous partial advance through ordinary
  frames, bit-identical to the same frames under `run!`. It returns the
  frames actually advanced.
- Between `step!` calls the status is `initialized`, boundary-consistent and
  ready to advance, and `run!` may follow `step!` from the current boundary.
- `t_end` and the honoured stop requests end a `step!` through the ordinary
  §12.4 tail.
- `stopped → init! → run!` is supported, and attachments persist across it
  as roster entries, orthogonal to the run lifecycle.

**Spec.** §12.6

**Rationale.** Each bullet restates a clause of D-088's Rationale that its
Position does not state. The source's `stop_on` is the stop requests since
D-316. Its clauses that `init!` clears the trace and log and that `t_end` and
`stop_on` are re-bindable at `run!` are not restated, because D-255 replaced
both. The entry decides nothing new.

**Rejected.**
- *A `run!`-only surface:* kills the test-harness advance-assert idiom and
  the REPL fly-inspect-continue idiom, neither of which is a §12.5 script
  (D-088).

### D-389 — Scope device observables to the run, and keep stepping deviceless

**Status.** ratified

**Position.** Two rulings on devices outside a run.

- Voluntary exit and the §12.2 liveness heartbeat are run-scoped. A device
  unplugged while stopped surfaces as the next run's device-`init!` failure.
- A stepping session is deviceless by construction: `attach!` only
  registers, and tasks appear at the next `run!`.

**Spec.** §12.4, §12.6

**Rationale.** Each bullet restates a clause of D-093's Rationale that its
Position does not state. The source's `should_close` is the loop body's
voluntary exit since D-373. The entry decides nothing new.

**Rejected.** None beyond D-093's list.

### D-390 — The harness writer's read half, and `step!`'s duration spelling

**Status.** ratified

**Position.** Three rulings on the harness writer's reads and `step!`.

- `latest(sim)` is the read half. It returns the current published
  snapshot, the same immutable value device handles read.
- `step!` takes the duration spelling `t_plus`, whole frames until the
  boundary time covers the duration, mutually exclusive with `frames`.
- An inspection accessor returning the immutable snapshot is not the public
  closure-evaluation API whose cost §13.5 rejects.

**Spec.** §12.6

**Rationale.** The first two bullets restate D-096's Rationale and the third
a clause of its Rejected list, none of which its Position states. The entry
decides nothing new.

**Rejected.** None beyond D-096's list.

### D-391 — Replay re-records, keeps pacing and control, and validates up front

**Status.** ratified

**Position.** Four rulings on what replay keeps of the loop.

- Replay re-records its own trace, the header inherited and the prefix
  bit-identical.
- Pacing and the control plane are unchanged under replay, so paced replay
  with a visualizer is session playback.
- Validation is loud and up front. The same pass normalizes the recorded
  sparse records to positional batches, once and off the loop, so the
  replay drain applies compiled scatters exactly as the live drain does.
- A structural mismatch is an error. A parametric difference is the
  what-if replay, which promises determinism, and reproduction only against
  the identical build.

**Spec.** §12.7

**Rationale.** Each bullet restates a clause of D-101's Rationale that its
Position does not state, in current terms. The Rationale's header taken
before boundary zero, and boundary zero re-executed under replay, fell with
D-274, and its interactive writer's records are every writer's since D-176.
Replay ending `initialized` and devices running as readers are not
restated, because D-218's Position states them. The entry decides nothing
new.

**Rejected.** None beyond D-101's list.

### D-392 — Check the thread budget once per run, against the frozen roster

**Status.** ratified

**Position.** The thread budget is checked once per run, against the frozen
roster, and never re-checked per attach.

**Spec.** §12.2

**Rationale.** This restates a clause of D-106's Rejected list, which its
Position does not state: the per-attach thread-budget re-checks fell with
the earlier attach-anytime design. D-027's Position makes the budget a
startup warning, and D-106's freezes the roster for the run. The doctrine's
final form in D-106's Rationale is not restated, because D-031's Position
states it. The entry decides nothing new.

**Rejected.**
- *Per-attach thread-budget re-checks, part of the earlier attach-anytime
  design:* priced for a hypothetical workflow (D-106).

### D-393 — Let a recorded stop request reproduce its termination

**Status.** ratified

**Position.** A termination the recorded run reached through a stop request
reproduces itself under replay.

**Spec.** §12.7

**Rationale.** This restates a reason in D-127's Rejected list, which its
Position does not state. The source's `stop_on` termination is a stop
request's since D-316. The entry decides nothing new.

**Rejected.** None beyond D-127's list.

### D-394 — The operator interrupt's masking, escalation and scope

**Status.** ratified

**Position.** Three rulings on the operator interrupt.

- Boundary masking is normative, not an implementation hint. The loop masks
  interrupt delivery across the boundary macro-sequence and takes the
  deferred raise at its unmask points, all boundary-consistent, and the
  `stopped`-with-consistent-stores guarantee depends on it.
- A second interrupt during the tail collapses the remaining device joins
  immediately, §12.4(5)'s abandonment path taken at once with the devices
  still named, and the run still ends `stopped`. Escalation shortens the
  tail and never reclassifies the run.
- The interrupt's scope is the interactive session. Outside the REPL,
  Julia's default `exit_on_sigint(true)` kills the process on SIGINT first,
  the framework flips nothing process-global, and unattended runs rely on
  `t_end` and stop requests.

**Spec.** §12.4

**Rationale.** Each bullet restates a clause of D-132's Rationale that its
Position does not state. D-294's Position names the unmask points. The
source's `stop_on` is the stop requests since D-316. The entry decides
nothing new.

**Rejected.**
- *Process-global `exit_on_sigint(false)` set by the framework:* changes
  process-wide signal behavior behind the user's back, and is wrong for the
  unattended runs that want the kill (D-132).
- *Escalation reclassifying the run as `errored`:* nothing is broken; the
  operator asked twice for the same stop (D-132).

### D-395 — Keep heartbeat staleness loose, the heartbeat advisory

**Status.** ratified

**Position.** Heartbeat staleness is deliberately loose. The heartbeat is
advisory, never a kill trigger, and must tolerate a device legitimately
parked in a blocking read.

**Spec.** §12.2

**Rationale.** This restates a clause of D-133's Rationale that its Position
does not state. The Position fixes the 2 s threshold. The other D-133
Rationale rulings §12.4 and §12.7 rely on are not restated, because
Positions state them: the event parameters compared as moving the
trajectory, in D-133's own; `t_end` landing on the grid, in D-133's too;
and stop requests read at every publication, in D-316's. The entry decides
nothing new.

**Rejected.** None beyond D-133's list.

### D-396 — Dispose of a failed device `init!` as an ordinary crash, split on `should_abort`

**Status.** ratified

**Position.** Three rulings on a device whose `init!` throws.

- The failure is reported as the ordinary `DeviceCrash`, with no diagnostic
  kind of its own. Its payload and disposition already fit.
- The device is dead from the run's first frame top, with no dead-marking
  machinery of its own, and its claims persist to run end. That is §11.3's
  death-is-not-detach disposition applied one step earlier than §12.4(6)'s,
  the orphaned root inputs holding the values the run started with.
- The run's disposition splits on `should_abort`, uniformly with §12.4(6).
  With the flag clear the remaining entries initialize and the run starts
  with the device absent from its first frame. With the flag set the
  failure requests a control-plane stop already pending at the run's first
  frame top. The remaining entries still initialize, every rostered device
  getting its `init!`/`shutdown!` pair, and the run ends `stopped` where it
  started, through the ordinary §12.4 tail, the termination record naming
  the source.

**Spec.** §12.4

**Rationale.** Each bullet restates a clause of D-138's Rationale that its
Position does not state, read at the run's start as its 2026-10-15
annotation reads it. The source's orphaned slots are root inputs since
D-206. The entry decides nothing new.

**Rejected.**
- *A dedicated init-failure diagnostic kind:* `DeviceCrash`'s payload and
  disposition already fit, and Appendix C's closed set pays for every
  addition (D-138).
- *Short-circuit teardown on an aborting init failure, ending the run
  without publishing:* invents a second exit path beside §12.4's one tail
  and yields a `stopped` simulation with no terminal snapshot (D-138).

### D-397 — Let the input mode outlive the replay call

**Status.** ratified

**Position.** The input mode outlives the `replay!` call, so after a partial
replay the recording still has a consumer, and the next `step!` re-executes
the following frame on its recorded inputs.

**Spec.** §12.7

**Rationale.** This restates a clause of D-218's Rationale that its Position
does not state. One loop and one drain branch are not restated: D-101's
Position makes replay the ordinary loop, and D-218's drives its one drain
branch by the mode. The entry decides nothing new.

**Rejected.**
- *The implicit switch, a feed present only while the replay call runs:*
  after a partial replay the next record has no consumer, and the following
  `step!` runs a live frame with empty staging (D-218).

### D-398 — Keep the inherited header across `live!`

**Status.** ratified

**Position.** After `live!` the trace keeps the header it inherited, so the
frames flown after the call append to the re-recorded prefix and the
session leaves behind one seamless recording of itself.

**Spec.** §12.7

**Rationale.** This restates a clause of D-219's Rationale that its Position
does not state. The Position has `live!` touch nothing but the mode and the
recording's remainder. `to_time`'s rounding, to the last frame top at or
before the time given, is not restated, because D-219's Position states it.
The entry decides nothing new.

**Rejected.** None beyond D-219's list.

### D-399 — Keep the control plane open to anyone and the run field never `nothing`

**Status.** ratified

**Position.** Two rulings on what the control plane and the simulation hold.

- The control plane is what anyone may poke, and a run's outcome is not.
- The simulation's run field is never `nothing`. The placeholder run gives
  every accessor a run to read, and the lifecycle state says whether it
  started.

**Spec.** §12.1, §12.6

**Rationale.** Each bullet restates what D-255's Rationale and Rejected list
record and its Position does not state. The source's `Control.lifecycle` is
`lifecycle(sim)` since D-317. The entry decides nothing new.

**Rejected.**
- *`termination` staying on `Control`:* the control plane is what anyone
  may poke; a run's outcome is not (D-255).
- *A `Union{Nothing,Run}` field:* every accessor branches on a state the
  lifecycle already reports (D-255).

### D-400 — Make recording a per-run declaration

**Status.** ratified

**Position.** Recording is per run: a long untraced run and then a short
traced one may share one simulation.

**Spec.** §12.6

**Rationale.** This restates a clause of D-261's Rationale that its Position
does not state. The Position puts the recording keywords on the doors that
build a run, and per-run recording comes with that move, at no cost the
doors did not already pay, since each rebuilds the log, the trace and the
drain thunks. The entry decides nothing new.

**Rejected.** None beyond D-261's list.

### D-401 — The interrupt's throw dispositions, and the stop word cleared per run

**Status.** ratified

**Position.** Three rulings on the interrupt and the stop word.

- A frame that throws while an interrupt is pending ends `errored` under its
  own `StepError`, the cause wrapped under the mask and the pending
  interrupt consumed at the catch on its way out.
- Julia's forced throw after repeated SIGINTs reaches §13.4's defensive arm
  inside the mask. Its disposition is `stopped` with the frame abandoned,
  the published record consistent and the stores possibly mid-boundary
  until the next `init!`, `restore!` or `replay!`.
- The stop word is cleared at a run's start.

**Spec.** §12.1, §12.4

**Rationale.** The first two bullets restate D-268's annotations of
2026-09-26, the second as its annotation of 2026-10-15 reads it. The third
restates its Rejected list, which contrasts the pause flag with the stop
word cleared at a run's start. None of them is in its Position. The entry
decides nothing new.

**Rejected.** None beyond D-268's list.

### D-402 — Record boundary zero's firings in the header, and make a long run seekable

**Status.** ratified

**Position.** Two rulings on the checkpoint as the trace header.

- The trace header records boundary zero's post-firing state faithfully and
  suppresses nothing.
- A long run is seekable: a checkpoint at boundary `k` plus the batches from
  frame `k+1`.

**Spec.** §12.7

**Rationale.** Each bullet restates a clause of D-274's Rationale that its
Position does not state. Its Position has replay restore the header and run
no boundary zero, so nothing is applied twice. The entry decides nothing
new.

**Rejected.** None beyond D-274's list.

