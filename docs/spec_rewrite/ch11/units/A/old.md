## 11. Runtime periphery: the data plane

This chapter covers GUI, input [devices](#g-device), network I/O and logging, and how
data crosses between them and the [§10][s10] loop:

- the architecture that replaces the shared mutable model ([§11.1][s11-1]);
- outbound [snapshot](#g-snapshot) publication ([§11.2][s11-2]);
- the inbound path:
  - [root inputs](#g-root-input), [claims](#g-claim) and the [frozen roster](#g-roster) ([§11.3][s11-3]);
  - per-device staging and the [drain](#g-drain) ([§11.4][s11-4]);
  - the input [trace](#g-trace) ([§11.5][s11-5]);
- the device authoring contract ([§11.6][s11-6]);
- the GUI write path ([§11.7][s11-7]);
- the third cross-task channel, runtime diagnostics and liveness ([§11.8][s11-8]).

The machinery that drives the loop itself follows in [§12][s12].

### 11.1 No shared mutable model: staged writes, snapshot reads

Everything in the [periphery](#g-periphery) (GUI, input [devices](#g-device),
network I/O, logging) runs on tasks the loop does not control, and every one
of them wants the data the loop is stepping. FlightCore's answer is one big
lock. `SimControl` and the live `Model` are guarded by `io_lock`, with one
task per attached interface reading or mutating the model under it (sim.jl).
That lock does enforce the [boundary](#g-boundary)-visibility rule
([§10.3][s10-3]), because it is only ever free between steps. Transplanting
it here was nevertheless rejected, on three structural costs ([D-022][d-022]).
One of the three is decisive for everything below. Under a lock, input
timing is scheduler-determined and unrecorded. There is then no defined input
[trace](#g-trace), and bit-identical [replay](#g-replay) ([§10.7][s10-7]) is
unachievable *in principle* for interactive runs.

The replacement has five planes. Its unit of account is the [frame](#g-frame)
(one iteration of the loop: [drain](#g-drain), integrate, boundary sequence,
publication), the grid step [§10.1][s10-1] names. A frame is what `step!`
counts, and it is the ordinal that keys the trace. "Per frame" means this
throughout the document. The kinematic *reference frames* of the aircraft
domain are a different word, and they always appear compounded: the b frame,
the ECEF frame.

1. **Staging (inbound).** Devices submit pending input writes at any
   wall-clock moment, never touching live [root inputs](#g-root-input)
   ([§11.4][s11-4]).
2. **The drain.** Exactly one point in each frame, at its top, where the loop
   takes the staged batches and applies them to the root inputs. It never
   happens at a `t*` boundary ([§10.4][s10-4]). Between drains the loop owns
   its data exclusively, and no lock is held during stepping, ever.
3. **Publication (outbound).** At the end of each boundary sequence the loop
   publishes an immutable [snapshot](#g-snapshot). Readers observe it without
   coordinating with the loop ([§11.2][s11-2]).
4. **Control.** Pause, pace and stop live on a separate few-word atomic
   surface ([§12.1][s12-1]).
5. **Task topology.** One loop on the calling task, one spawned task per
   rostered device, all run-scoped.

The fifth plane carries the most machinery, and the rest of this section
spells it out.

**Device tasks are run-scoped.** `run!` spawns one task per
[roster](#g-roster) entry after device `init!`, and [§12.4][s12-4] joins them
all at every stop ([§12.6][s12-6]). `attach!` never spawns. It registers, in
a stopped-sim state only ([§11.3][s11-3]), and the task appears at the next
`run!`.

**The loop runs on the calling task** ([D-310][d-310]). The
[calling task](#g-calling-task) (the task that invoked `run!`) runs the loop
itself, and every rostered device runs on a spawned task. This is what the
synchronous rethrow ([§13.4][s13-4]) presupposes. It is also what lets
parallel unattended sweeps thread `run!` inline with no nested task fan-out.
One immutable [`Build`](#g-build) is shared across the workers
([§9.2][s9-2]), and each `Simulation` owns its own [buffers](#g-buffer) ([§9.4][s9-4]).
Pre-materializing the sweep's [activations](#g-activation), its per-eltype
[executable sets](#g-executable-set) via `build(world; activations = …)`
([§9.4][s9-4]), then leaves no worker synchronizing on anything. `run!`
blocks its caller until the run ends.

**Topology is derived after initialization**, from the
[frozen roster](#g-roster) plus the outcomes of device `init!`, and never from
`run!`'s keywords. [§12.4][s12-4] carries the rule: a device whose `init!`
failed gets no task.

**Spawn-inside-`run!` is the start gate.** A task exists only once the run it
serves exists. Any first-boundary synchronization a device needs is the
counter-plus-condition predicate wait ([§12.3][s12-3]), never a `Base.Event`
latch ([D-093][d-093]).

Two rules bind the implementation:

- **Every handoff is one atomic reference operation.** Both shared structures
  reduce their mutable surface to single words, release/acquire `@atomic`
  fields. The GC is the reclamation mechanism, since an object a reader still
  holds is reachable and therefore never recycled. That dissolves the
  reclamation problem (hazard pointers, epochs, RCU grace periods) which makes
  these patterns hard in non-GC languages. Deep immutability of the exchanged
  objects is what makes this sound.
- **No user code, no unbounded work, ever, inside a framework critical
  section.** FlightCore's pathologies are all "arbitrary code under a shared
  lock". Here mappings run on device tasks, rendering runs against snapshots,
  and the loop's frame contains framework and model code only. A stalled
  device produces stale snapshots and late staging. It cannot stall the loop.
  Two exposures are residual and pre-existing, GC pauses and OS scheduling,
  and the pacer's debt absorption is the mitigation for both.

One consequence is recorded here because it collapses an API axis.
Interactive and unattended simulation stop being different execution modes.
An [unattended run](#g-unattended-run) is the same loop with empty staging and
no snapshot readers. A replayed interactive session is the same loop with
staging fed from a recording ([§11.5][s11-5], [§12.7][s12-7]).

