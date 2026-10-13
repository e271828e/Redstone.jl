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

### 11.2 Outbound: snapshot publication

Every consumer of model state (GUI panels, output [devices](#g-device), the
log) needs a picture of the model that holds still while it is read, and none
of them should have to make the loop wait to get one. Publication is the
answer. One immutable value is published per [boundary](#g-boundary), handed
out through a single atomic reference. Three things follow from it, in that
order: how a [snapshot](#g-snapshot) is built and published, how the log
retains published snapshots under a bound, and how an output device addresses
what it reads.

#### The snapshot and its publication

**Rule.** The loop builds each snapshot in private memory, then publishes it
with a single release-store to an [`@atomic latest`](#g-latest) reference. A
snapshot carries the boundary-consistent [signal table](#g-signal-table), `t`,
its frame index and its published-boundary ordinal ([§12.3][s12-3]), and the
framework status. The frame index is what places a `t*` snapshot in its
frame, since a `t*` publication counts an ordinal of its own
([D-261][d-261]). Readers acquire-load that reference and then work
with an immutable, coherent world for as long as they like. The
[calling task](#g-calling-task) (the task that invoked `run!`) reads the same
value through `latest(sim)`, an inspection read ([§12.6][s12-6]).

The exchange is wait-free in both directions. A wedged reader cannot delay
publication by a nanosecond, and the loop cannot tear a reader's view.
Publication happens only after the boundary sequence completes
([§10.3][s10-3]).

**Binding rule: nothing reachable from a published snapshot is ever written
again.** The table's immutable values ([§4.1][s4-1], [§7][s7]) make the
compiler enforce most of it. **Why.** The soundness of lock-free reading rests
on this rule.

**The [framework status](#g-framework-status) is a concrete frozen value, not
a window onto live bookkeeping.** It carries the pacer diagnostics
([§10.7][s10-7]), plus the per-writer diagnostic batches, the suppressed and
cumulative counters and the liveness timestamps the loop takes at frame top
([§11.8][s11-8]). **Why.** The binding rule forces that shape. A status
referencing an accumulator its writers are still filling would be a snapshot
whose contents change after publication.

**The captured table is the whole table.** It holds the declared
[ports](#g-port), every one of them public
([§8.3][s8-3]). No presentation layer has anything to filter. Undeclared
intermediates are not in it, because only declared ports are [cells](#g-cell)
([§8.3][s8-3]). The inspection path for one is **promotion to a declared
output**. Add a line in `y_types`, and the value appears in the
snapshot, the log, the GUI and the wiring alike. Its visibility is then an
authored fact like every other.

**The captured table also includes the [root inputs](#g-root-input).**
Root inputs are source cells of the table, not state stores,
so they ride along. That is essential, not incidental. The [§11.7][s11-7]
[peek](#g-peek) (showing a widget's own pending write, else the snapshot
value) falls back to the snapshot, and that fallback is what an idle live
widget displays. Read-only mirrors of claimed root inputs, such as the axis
sliders under joystick [claim](#g-claim), show the applied root-input value
from the snapshot. Root input values in the log are derived data,
recomputable from the [trace](#g-trace). That is consistent, because
snapshots are derived wholesale.

**The snapshot deliberately does *not* carry the state stores (`x`, `s`,
`m`).** There are two reasons. The state trajectory is *derived* data,
recomputable from the [trace header](#g-trace-header) plus the batches
([§11.5][s11-5]) by bit-identical [replay](#g-replay). And per-boundary
capture would systematically record derived data, the same asymmetry the
trace-default decision ([D-029][d-029]) refuses in the other direction.

"What was the private state at t = 37.2?" is answered by replaying to 37.2 and
inspecting the live stores. A state field wanted in logs or GUI has the honest
remedy of being declared public and returned from `y_state` ([§5.3][s5-3]), at a cost of one
cell per [sweep](#g-sweep). Post-run continuation reads the live stores directly.
Periodic full-state checkpoints, which would allow warm restart without replay
from zero, are a [guarded addition](#g-guarded-addition) shaped as an opt-in log policy. Each would
retain a [checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one value), the
value `checkpoint(sim)` returns ([§12.6][s12-6]). A dev-mode flag that reads every state
field out of the stores is a possible future diagnostic. It would be a reader
over the stores, never a port class ([D-252][d-252]).

**Event firings are not recorded** ([D-309][d-309]). The log holds boundary
snapshots and the trace holds staged inputs ([§11.5][s11-5]). Neither carries
a per-event record. Replay plus the published modes recovers which events
fired at which boundary. The honest remedy is again to declare the mode field
public and return it from `y_state` ([D-252][d-252]). A mode field so exposed
is in every snapshot. An event-firing stream is a guarded addition.

#### The log: retained snapshots under a bound

**Logging dissolves into publication.** The log is a vector of retained
snapshot references. They are the same objects, with zero extra copies. The
per-step `deepcopy` detour of the `SavingCallback` disappears. The cost is one
snapshot allocation per boundary, on the framework side of the [§9.8][s9-8]
scope, which already carved out logging. Logged snapshots are not garbage at
all, and unlogged ones die young. Preallocated snapshot buffers are rejected
([D-023][d-023]).

**Retention: the trace's kill switch, plus [decimation](#g-decimation).** The
log takes the same plain on/off switch the trace has ([§11.5][s11-5]), and
additionally a keep-every-kth retention policy, `log_every`
([Appendix B][sB]). **Why decimation is admissible here and not there.** The
derived/primary split ([D-038][d-038]) decides it. The log is recomputable
from the trace by replay, so a thinned log costs resolution in a *view*,
never in a record. Thinning the trace would destroy the only primary account
of a session ([D-029][d-029]). Decimation is a retention policy only. Every
boundary still runs, is still published to live readers, and still enters the
trace.

Decimation slows the log's growth. It does not stop it. The default
configuration is `log = true, log_every = 1` alongside `t_end = Inf`, the
honest interactive default ([Appendix B][sB]), and it grows for as long as
the session lasts. At C172X scale and 50 Hz that is gigabytes per hour, and
it ends in an out-of-memory nobody was warned about.

**Rule.** The log takes a retention bound beside its switch and its stride:
`log_max`, the maximum number of retained snapshot references, default
**65536** (2¹⁶), with `Inf` the explicit opt-out.

**The bound is a count, not a memory budget.** Snapshots are immutable object
graphs ([§4.1][s4-1]) with internal sharing, and a
[field handle](#g-field-handle) (an immutable query object consumers evaluate
at their own arguments, [§4.4][s4-4]) rides as a reference to
build-time-frozen data ([§9.8][s9-8]). Byte accounting over them is therefore
fuzzy and platform-dependent. A count is exact, and it converts to memory
through one number the user can measure once, `Base.summarysize` of a single
snapshot.

**The default is finite unconditionally**, not a modal rule keyed on `t_end`.
A finite run shorter than the bound never notices the bound, and one number
is easier to hold than two regimes. At 50 Hz and full density, 2¹⁶ boundaries
is about 22 minutes before anything is dropped at all.

**When the log fills, the retention stride doubles, so coverage stays
global.** A rolling window, with the recent past at full density and the
start of the session forgotten, was rejected ([D-137][d-137]). Instead the log
**re-decimates progressively**. After *k* generations the effective stride is
`log_every · 2^k`. The whole run stays plottable, and what coarsens is
density, never extent.

**Why.** That is the division of labor ([D-038][d-038]) carried through. The
log's chief consumer is the post-run plot of a session *as a whole*, and
nobody plots hours at 50 Hz. Full density over any *segment* of interest is
what replay from the trace recovers ([§11.5][s11-5], [§12.7][s12-7]).

**The guarantees are normative, not the mechanism.** There are three. The
bound is respected continuously, and the retained count never exceeds
`log_max`. Coverage is global at the effective stride. The endpoints below
are kept.

The mechanism sketch is non-binding. The thinning is **amortized**. When the
log fills, the stride doubles immediately, and each subsequent retained
append also releases one predecessor of the previous generation. A cursor
over the odd indices does this in O(1) amortized, with physical compaction
once per generation. A generation's thinning therefore completes exactly when
its refill does.

> fill at stride `log_every` → **full** → stride doubles → thin one predecessor
> per retained append, while refilling → **full** at stride `log_every · 2` → ⋯
> → generation *k* at `log_every · 2^k`

Amortizing rather than halving in one shot is a responsiveness choice
([D-137][d-137]). The amortized form drops exactly one old snapshot per
retained append, the same steady trickle a rolling window would produce, so
keeping coverage global costs nothing extra in GC pressure. The loop's own
work is pointer bookkeeping, microseconds either way and on the framework
side of the scope ([§9.8][s9-8]). Publication stays wait-free and readers
never block. A reader holding a released snapshot simply keeps it alive.

**The endpoints are retained unconditionally.** The run's first snapshot and its
terminal snapshot ([§12.4][s12-4], [§13.5][s13-5]) survive any `log_every` and any `log_max`, and
they do not count against the bound. The first is the boundary-zero snapshot
under `init!` ([§14.5][s14-5]), and the snapshot the door publishes under `restore!` and
`replay!` ([§12.6][s12-6]). The stride counts boundaries from it. They are two extra
references. The terminal snapshot's status carries the run's final cumulative
diagnostic counters ([§11.8][s11-8]). A run's two endpoints and its diagnostic account,
complete to the final frame top ([D-201][d-201]), therefore always outlive whatever
retention did to the middle.

Two compositions are worth stating once. The `totals` monotonicity across
logged snapshots ([§11.8][s11-8]) is untouched. Re-decimation, like
decimation, loses *which* boundary within a stretch an occurrence fell on,
never *how many*. And `log_max` is a **view policy, not a
trajectory-determining one**. Like `log` and `log_every` it stays out of the
trace header's [`Deployment`](#g-deployment) (the scalar-free artifact the grid
parameters fix), and replay neither records nor compares it ([§11.5][s11-5],
[§12.7][s12-7]). Sizing follows. The `sizehint!` for the
expected duration ([§9.8][s9-8]) is now naturally capped by `log_max`, which
is also what defines the hint when `t_end = Inf`.

#### Output-device bindings

**Output-device bindings are snapshot bindings.** An output device
(telemetry, the XPlane visualizer, disk streaming) consumes snapshots via
[§12.3][s12-3]. It addresses what it reads with the
[selectors](#g-selector) (the closed family of deferred reads resolving
against a source, [§14.4][s14-4]), which reach any cell, since inspection
reads admit deep paths. A binding is resolved at attach against the
`Build` with [did-you-mean](#g-did-you-mean) (the offending name plus the
list-in-hand it should have matched), and compiled to one gather, the output
half of the binding interface ([§11.6][s11-6]). `map_output` therefore
receives a labeled NamedTuple, keyed by the names `reads` declared
([§11.6][s11-6]), instead of performing its own path lookups. A model
substitution that breaks a binding therefore fails at attach, not with silent
garbage on the wire. Loggers treat field-handle signals specially. They skip
or summarize them.

This is **inspection** ([§13.5][s13-5]). It is human-facing, with no effect
on run semantics. It is the same kind of observation as the log
retaining the full table and the GUI's deep-reading panels. Every cell is
reachable, because the table is public throughout ([§8.3][s8-3]), and an intermediate a
device wants to stream is one promoted to a declared output.

**A binding chooses its side.** A deep path is an *inspection* read.
It makes zero promises, gives free access, and is right for looking at *this*
build. An exported output [face](#g-face), spelled `get_face(name)`
([§14.4][s14-4]), is an *integration* read. It is named, curated and
meaning-stable under substitution, and right for consumers that outlive the
build they were configured against. What makes a face meaning-stable is
writer-independent semantics ([§11.4][s11-4]).

**Why the choice matters.** Attach validation converts *structural* drift to
loud errors on both sides. Only faces protect against *semantic* drift,
where a substituted aircraft publishes the same path at the same type with a
different meaning, such as a CG velocity under a name read as body-origin
velocity. Nothing else can, because meaning is not in the schema.

Semantically generic consumers should therefore bind faces. A visualizer
needs pose, and every aircraft has one. Aircraft families should export the
conventional surface such consumers need, a library/migration deliverable
(`migration_outline.md`). Wrapper types make face semantics structurally checkable, as in
`VelocityData` with its `v_eb_b` defined *at the type* as body-origin
velocity. A bare vector does not wire, and wrapping the wrong quantity is a
deliberate lie, not a drift.

### 11.3 Inbound: root inputs, claims and the frozen roster

**The [write surface](#g-write-surface) (the set of faces a writer's batch
entries may reach) is [root inputs](#g-root-input).** A root input *is* the
root [component](#g-component)'s own input [face](#g-face), an assembly's
`input_wires` key or a primitive's `u_types` key ([§8.2][s8-2],
[§8.6][s8-6]). It is routed inward to consumers and produced by no component.
At every non-root level an input face is fed by the parent's wire, and at the
root there is no parent. No dedicated vocabulary is needed.

A root input is usefully read as the output face of the one producer the
build never sees: the [periphery](#g-periphery) and the services. On that
reading, root-input exclusivity (below) is that producer's one-writer right,
and the totality ([§14.6][s14-6]) is its completeness obligation.

Root inputs are sources to the build-time ordering, constants within a
frame, and the *only* thing the periphery may write. The GUI reaches them
through the resolution ([§11.7][s11-7]), and control commands are not writes
([§12.1][s12-1]). [Devices](#g-device), mappings, the [trace](#g-trace) and
the GUI write path address root inputs by **face name** ([§8.6][s8-6]).
Structural slash paths never cross the periphery's *write* boundary. The
write side speaks the root [contract](#g-contract)'s names only. The read
side chooses per binding. It uses slash paths in inspection reads, and face
names in integration reads and in service reads
([§11.2][s11-2]/[§13.5][s13-5]/[§14.4][s14-4]).

**Root-input exclusivity: one writer per root input at any time.** A device [claims](#g-claim) its root inputs at attach, and
claiming an already-claimed root input is an attach-time error. Detaching
releases the claims. A released root input's GUI widgets are live again from
the next run ([§11.7][s11-7]). Exclusivity replaces any cross-device conflict
*policy*, such as attachment-order precedence at [drain](#g-drain)
([D-044][d-044]). Per-device [cells](#g-staging-cell), the CAS merge and the
atomicswap drain all stay. They serve atomicity and
[coalescing](#g-coalescing), not arbitration.

**Why.** A second live writer on one root input makes the applied value a
timing artifact, as the worked example in [§11.4][s11-4] shows. The usual
pair is a stream and its mirror, a joystick axis and the GUI slider showing
it. Claiming the stream settles that pair with no concurrent writing.

**A claim is what a device *may* write, not what it will.** Data-dependent
write-sets are ordinary. A UDP/JSON peer writes whichever subset of faces the
incoming message names, and `map_input` is arbitrary user code the framework
never inspects. Such a device therefore claims the **binding's enumerated
allowed set**, the faces the binding table lists, whether or not any given
batch touches them. The claim is registered at attach exactly as a joystick's
is. A broad claim costs liveness. Every enumerated face is claimed for the
device's whole attachment, so the derived-liveness rule ([§11.7][s11-7])
renders the device's GUI widget read-only even on faces the peer never
writes. Narrow the binding to narrow the claim. The enumeration *is* the
interface.

**Every writer has a write surface, and the periphery enforces it.** A batch
entry reaches a root input **iff the named face is inside the writer's
surface**. Anything else is discarded with a runtime warning
([§13.2][s13-2]). Because surfaces are static per run (the
[roster](#g-roster) freeze, below), enforcement runs entirely at *staging*,
the earliest site, on the writer's own task. The drain performs no checks at
all. **Every device's surface is its claim set**, and a claim set has two
*sources*:

- **Returned.** The binding enumerates the faces. It declares
  `is_input(b) = true`, `claims(b)` ([§11.6][s11-6]) is called once at
  attach, and what it names is staked. Such a claim is static for the
  attachment and exclusively its own, since claims are disjoint by
  construction. It is binding-bounded even where no one else is involved. A
  mapping that has drifted onto an unenumerated face is a diagnosable anomaly
  (`OutOfClaimEntry`), never a silent write, claimed or not.
- **Computed.** The binding declares `is_greedy(b) = true` ([§11.6][s11-6])
  and the framework computes the claim at attach: all root-input faces minus
  the union of the rostered claims, the unclaimed complement at that instant.
  This is the shipped GUI's claim ([§11.7][s11-7]), everything unclaimed,
  without configuration. It is disjoint from every incumbent claim by
  construction, so exclusivity validates trivially and nothing downstream can
  tell the two sources apart. A complement that comes out empty is legal and
  useless, and `attach!` records `EmptyGreedyClaim` in the roster entry's
  [diagnostic cell](#g-diagnostic-cell) ([§11.6][s11-6], [§11.8][s11-8],
  [D-250][d-250]).

**The periphery resolves root faces against the activation's cell layout
alone** ([D-261][d-261]). The layout carries the root faces in structure
order with their probe values, beside the address table, so both of the
build's lookup families, [schema and layout](#g-schema-vs-layout), read it
there, and writers, claims and the harness compile against it. The services
take their schema from the `Build` itself ([§14.3][s14-3]); the periphery
never needs an authored fact the layout does not hold.

One claim mechanism, two claim sources. The source is exhausted at the attach
point. Past it, validation, roster-entry storage, shape compilation
([§11.4][s11-4]), the drain, the trace and detach-releases-claims treat a
computed claim exactly as a returned one. The GUI is therefore not an
exception but an ordinary enumerated writer whose enumeration the framework
performed. Attaching the greedy claimant last is the idiom. Its computed
claim is taken at the attach point and never recomputed, so attachment order
is decisive by design. Opportunistic writing by autonomous devices does
not exist. A device that wants a face enumerates it, and greediness is an
explicit declaration, never a default. Cross-writer races on one root input
therefore cannot arise structurally, because every claim is exclusive,
whatever its source. That is what keeps drain order a diagnostic fact (below)
and lets a drained GUI value simply stay ([§11.7][s11-7]).

**One framework-owned remainder: the
[harness writer](#g-harness-writer).** Beside the roster sits a
**task-free entry point**, `stage!(sim, "face" => value, …)`, the harness/REPL
write path ([§12.6][s12-6]). It stages a batch from the
[calling task](#g-calling-task) itself (the task that invoked `run!`). Its
always-present cell is drained, traced and surface-checked exactly as any
device's. The harness writer's surface is the one thing in the design that is
*derived* rather than claimed. It is the unclaimed complement, the faces no
rostered device speaks for. That surface is recomputed at every stopped-sim
roster change, and is therefore as fixed within a run as any claim set. A
`stage!` write to a claimed face is rejected at staging
(`ClaimedFaceEntry`, naming the incumbent). A rostered greedy claimant
empties that surface outright. The greedy claim is itself a rostered claim,
so the complement it leaves is empty and every `stage!` in such a session is
rejected that way ([D-192][d-192]). There is one seam, a batch staged while
stopped whose face a subsequent `attach!` claims, and the attach itself
renormalizes it away (below). The [harness cell](#g-harness-cell) (the
always-present staging cell of the harness writer) drains **last**, by
convention. With every surface disjoint the order is unobservable, so the
rule exists to make the trace read the same way every time, not to arbitrate
anything.

**Root-input initial values are owned by the init/trim services.** Input
declarations are bare types ([§8.2][s8-2]) and carry no defaults, yet a root
input unfed by any device must hold a defined value from the first frame. No
declaration constant could own that value, because the trim service writes
root-input values it *solved for*, such as throttle and elevator. Export-entry defaults were rejected ([D-047][d-047]).
`init!` establishes every root input, and the
[trace header](#g-trace-header) captures the result. Totality is enforced
pre-write at every complete-world application: `init!`, trim setup, trim
commit ([§14.6][s14-6]).

**The roster is frozen per run: attach and detach are stopped-sim
operations.** `attach!`/`detach!` are legal in the `built`, `initialized`
and `stopped` states ([§12.6][s12-6]) and an error while `running`. That
error is `ServiceLifecycle` ([Appendix C][sC]), the same kind that gates the
[§14][s14] services. The list is exhaustive. An `errored` simulation refuses
both with the same kind. A roster change configures the next run, and an
errored simulation has none ([§13.6][s13-6], [D-232][d-232]). The prohibition
includes pause. Pause is a control-plane state *inside* a run
([§12.1][s12-1]), and a surface that could move while paused would move
mid-run. The roster (entries, claims, attachment order) is therefore a plain
immutable value the loop reads once at `run!`. The partition of the root face
set into per-writer surfaces plus the harness remainder is a static,
inspectable fact of the run. It is printable before the run starts and valid
until it ends (printable like the face routes, [§13.7][s13-7]). No republication
machinery exists. There is no atomic roster reference, no per-frame
acquire-load, no next-frame attachment granularity and no sequence numbers.
Attachment order is the roster's own order. The trace still tags entries
with a stable device id, never a roster index, because ids read across runs,
where the roster does change. Attach validation, claim registration and the
staging-shape compilation (below) all run at the attach point, which makes
`attach!`/`detach!` stopped-sim configuration operations beside `init!` and
trim ([§14][s14]). While a simulation runs, its configuration (build, roster,
claims, surfaces) is immutable. The doctrine ([§12.5][s12-5]) extends to its
final form. The running periphery stages writes and issues control commands,
*and nothing else changes*.

**Device identity, ids and roster admission.** Identity is the device
instance. The same object (`===`) may occupy at most one roster entry. Two
instances of the same type, two joysticks say, are two devices. The stable
device id the trace, heartbeat and diagnostics speak is assigned at
`attach!`, monotonic per `Simulation` and never reused. It lives exactly as
long as the entry: across runs (roster persistence, [§12.6][s12-6]), until
`detach!`.

Admission is a two-part check at the attach point, in order:

```
# each line: the condition that rejects the attach → the diagnostic it raises
identity   this instance is already rostered
               → AlreadyAttached      (names the entry and its binding)
claims     face exclusivity: this device's claim set meets a rostered claim
               → ClaimConflict        (names two distinct devices)
```

An already-rostered instance is rejected rather than silently absorbed,
because rebinding has an explicit spelling: `detach!` then `attach!`, both
legal at any stopped-sim point. Either a silent no-op or a silent rebind
would discard a binding the caller handed over. Running the claims check
after the identity check is what makes `ClaimConflict` always
name two *distinct* devices, never a device colliding with its own earlier
attachment.

**Device death does not detach.** A mid-run crash, voluntary exit or unplug
([§11.6][s11-6], [§12.4][s12-4]) ends the device's *task*. The cell stops
filling, the [§12.2][s12-2] heartbeat shows the death by name, and the roster
entry, claims included, persists to the end of the run. The
[orphaned claims](#g-orphaned-claims) are the accepted cost of
[the freeze](#g-the-freeze). The device's root inputs hold their
last-drained values and no other writer inherits them. The read-only widgets
([§11.7][s11-7]) render the orphan visibly ("claimed by `T16000M` — task
dead"), never mysteriously. Recovery is between runs: stop, `detach!`, and
either `init!` (fresh trajectory) or `replay!`-to-end then `run!`
(continuation from the interrupted boundary, [§12.7][s12-7]). The death is an
anomaly, not a surface event.

One deliberate asymmetry is on record as a
**[guarded addition](#g-guarded-addition)** (a capability the design admits
but does not build). A pure reader claims nothing. Examples are a binding
declaring `is_output` alone ([§11.6][s11-6]), a visualizer or a telemetry
tap. Attaching one mid-run would therefore move no writer's surface. A
dynamic reader list would touch only [§12.3][s12-3] wakeups, the heartbeat
and the shutdown join, never the drain, and it is cleanly severable from the
freeze should the join-a-running-session workflow find a customer. The
[§12.2][s12-2] thread-budget warning runs once per run, at either door,
against the frozen population.

### 11.4 Inbound: per-device staging, representation and the drain

A device produces writes on its own task, whenever its hardware or its peer
hands it a datum. The loop consumes them at frame top. Between those two
rates something has to hold each device's pending writes and hand the loop a
value it can apply. That something is the staging cell, a compound term
distinct from a table cell ([D-121][d-121]). Unlike a table cell it is mutated
frame by frame, outside the table's publish-once discipline. This section fixes
the policy under which a device writes into its cell, the shape the cell
holds, and the [drain](#g-drain) (the frame-top swap that publishes staged
device writes into the root inputs) that empties it.

**Rule.** Staging keeps one atomic [cell](#g-staging-cell) per attached
[device](#g-device) under one [coalescing](#g-coalescing) policy: CAS merge,
newest wins per [face](#g-face). Each cell has a single writer, its own device
task, and holds that device's latest pending [batch](#g-batch) of
[root input](#g-root-input) writes. Staging merges the incoming batch into the
pending one. Untouched faces survive, and re-staged faces take the newest
level. That is the per-face ZOH. The CAS can fail only because a drain
intercepted the old batch, so the retry is bounded. The failure case is
precisely correct as well. Intercepted writes are already applied, and must
not be re-staged.

**Why.** Merge is the *only* policy because it is always correct. A
**complete** writer covers every face in every batch it stages. A joystick
delivering its full write-set every poll is the type case. For such a writer
merge and overwrite are provably the same operation, which makes overwrite a
degenerate fast path rather than a second semantics. A **sparse** writer
stages only what was touched. The GUI and a JSON peer are sparse writers, and
under overwrite they lose writes silently instead. The worked example at the end of this section works that
hazard through: a pending `flaps` edit clobbered by an unrelated `gear`
message, undrained and undiagnosable. A user-facing overwrite opt-in
(`complete(binding)`) is closed ([D-104][d-104]).

**Rule.** The staged representation is fixed per attachment, compiled at
attach. An enumerated writer's [claim](#g-claim) set and root-input types are
both known at attach, since `claims(binding)` ([§11.6][s11-6]) is read
against the root [contract](#g-contract). So the framework fixes the cell's
content type there. It is a pair of positional tuples over the claim set: a
values tuple, concretely typed `Tuple{T₁, …, Tₙ}`, and a parallel `Bool`
touched-mask. A set mask position means *staged this time*. A clear one
means *not touched*, never "reset". Untouched positions carry placeholder
values and are never read. The mask guards every consumer, so no placeholder
ever reaches the model. The batch is therefore isbits with one concrete
layout per writer. The levels doctrine is untouched, and root inputs only
ever receive masked positions. The face-name → position schema lives in the
[roster](#g-roster) entry.

In sketch form:

```julia
# claim set enumerated f₁ … fₙ; Tᵢ = declared type of the root input behind fᵢ

# attach fixes the cell's content type — values and mask, both concrete:
values :: Tuple{T₁, …, Tₙ};  mask :: NTuple{n, Bool}

# stage!, on the device task: the shim turns the author's face ⇒ value pairs
# into `incoming` — name → position, convert to Tᵢ, set the mask

# staging merges into the pending batch, newest wins per face:
merged.values[i] = incoming.mask[i] ? incoming.values[i] : pending.values[i]
merged.mask[i]   = incoming.mask[i] | pending.mask[i]

# the drain scatters, unmasked positions skipped:
batch.mask[i] && (the root input at position i receives batch.values[i])
```

**Why.** One concrete layout is what makes the frame-top drain compilable.
The alternative carrier, `Union{Nothing, Tᵢ}` per face with the marker riding
in the value, has no such layout. Tuple types are covariant, so each
combination of touched faces is its own concrete type, and applying a batch
would specialize at frame top on which faces it touched ([D-202][d-202]). The
mask buys the layout back at the price of dead placeholders. Those are filled
from the declaration's [probe](#g-probe) values, which are constructible for
every declared type and unreachable behind the mask guard.

The consequences are each mechanical. The merge is positional and
mask-driven (the sketch above), so it compiles straight-line, leans on no
small-tuple heuristic, and does not degrade with surface width
([D-202][d-202]). The drain applies each cell through an attach-compiled
**scatter**: position → root-input cell, statically typed, masked-off
positions skipped. That scatter is the exact mirror of the compiled output
gather ([§11.2][s11-2]).

Authors never build the shape by hand. `map_input` returns face ⇒ value pairs
for whatever the datum touched, and `stage!` normalizes those pairs through
an attach-compiled shim. The shim does three things. It maps name to
position, converts to the root input's declared type, and sets the mask. It
thereby confines the residual name-shaped dynamism to one framework-owned
conversion on the device task, at the boundary where wire-shaped data becomes
system-shaped data. Author-built total tuples are rejected as a padding form,
the same disease [D-074][d-074] and the handler return law refuse
([D-104][d-104]).

**A greedy entry needs no special treatment here.** Its claim was computed at
the attach point, and by the time shapes are compiled it is an ordinary claim
set ([§11.3][s11-3]). The GUI's cell is compiled exactly as a joystick's.

**The [harness cell](#g-harness-cell) (the always-present staging cell of the
harness writer) gets the same treatment.** Under the roster freeze its
derived surface, the unclaimed complement, is as static as any claim set, so
it too is compiled to a positional shape. That shape is recompiled at each
`attach!`/`detach!`, both stopped-sim points, and it carries the same shim,
merge and scatter. Being always present, the harness cell gets the
compilation unasked. It is also the one cell whose shape the framework
derives rather than receives.

One representation, one mechanism. The name-keyed dynamic path the mutable
surface used to force does not exist, and no face name is ever resolved
inside the loop's frame.

The recompilation has one seam. A pending harness batch staged *before* a
stopped-sim `attach!` may hold the old shape, or may name a face the new
claim covers. The attach renormalizes that batch. It is reshaped, and
newly-claimed faces are discarded with `ClaimedFaceEntry`. So the run always
starts with cells matching the run's schemas.

**Rule.** Diagnostic sites follow the compilation, all of them to staging.
Face-name validity, surface membership and value convertibility are all
static facts of the run. Every check therefore runs in `stage!`'s
normalization, on the writer's own task. A device's out-of-claim face has no
position in the schema and is rejected with `OutOfClaimEntry`. Staging is an
earlier, better-attributed site than the drain for that rejection, and the
kind and [payload](#g-payload) are the same either way. The GUI is included,
its claim being an ordinary one. A **harness** write to a claimed face is
rejected the same way, with `ClaimedFaceEntry` naming the incumbent device.
And a value that cannot convert to its root input's declared type is
discarded with `EntryTypeMismatch` ([Appendix C][sC]), at the same spot.

Nothing remains at the drain. With surfaces frozen for the run, there is no
fact only the drain can know, and the drain is pure application.

**Doctrine: staged values are levels, never deltas** (`press_count = 17`,
never `presses += 1`). Levels are idempotent and survive coalescing. Button
edges ride as monotonic counters.

**Rule.** At frame top the drain takes each device's cell with one
`atomicswap(cell, nothing)`. The swap is an indivisible take, so there is no
lost-write window. Each taken cell is then applied through its compiled
scatter, **in attachment order**. Attachment order is retained as a
deterministic application order. Under root-input exclusivity, cross-device
writes to one root input cannot arise, so the order matters only for
diagnostics.

Which *frame* a write lands in remains wall-clock reality. What the drain
guarantees is that the frame's outcome is a pure function of the drained
batches.

Because the roster is a fixed value at `run!`, the drain is fully compilable.
The cells and their scatters form a heterogeneous but *known* tuple the frame
function can specialize on, which means zero dynamic dispatch at frame top.
That is the same per-configuration compile trade the [executor](#g-executor)
([§9.7][s9-7]) already makes, now incurred only at stopped-sim attach points.
The specialization is an implementation freedom
[the freeze](#g-the-freeze) creates, not an obligation. Iterating a roster
array costs a handful of dispatches per frame and remains acceptable.

Two shapes were rejected, both examined in the worked example below: per-input
atomic cells, and a shared lock-free [batch](#g-batch) stack ([D-024][d-024]).

**Mappings run on the device task.** Today's
`assign_input!(mdl, mapping, data)` becomes the pure
`map_input(data, mapping) → batch`. User-extensible code thereby never
executes inside the loop's frame, and the trace consists of root-input-level
batches.

**Mappings are binding data, not shaping code.** A mapping
is a declarative table: axis/button → root input, plus per-axis conditioning
parameters (deadzone, expo strength). The shipped `TableBinding` applies
those parameters in its generic `map_input`, on the device task. That is the
shared pure helper, with an owner ([§11.6][s11-6]).

The boundary is set by the face contract: **a face's meaning is
writer-independent**. Faces therefore carry *post-conditioning* semantics. A
GUI slider or a script writes the same command a curved stick delivers, and
running a mouse drag through a deadzone would be absurd. This GUI-parity test
is what places conditioning upstream.

Aircraft-semantic derivation must *not* ride along. A command fan-out such as
`q_ref = q_sf · axis` is the case in point. It is FCS design and
lives in-model, in the avionics. Alternatively it is accepted as a small
per-aircraft×device mapping entry, an aircraft-design fork.

The trace records post-conditioning levels. Those are exactly what the model
consumed, so [replay](#g-replay) is exact. The raw stick levels are the known,
accepted loss: re-running a session through *different* curves is impossible.
Edge logic follows the levels doctrine. Devices stage monotonic press counters.
Accumulators (trim offsets, flap detents) are model state, not mapping state.

#### Worked example: filter, joystick and GUI

This worked example is the exercise that selected per-[device](#g-device)
[cells](#g-staging-cell) and produced the [§11.7][s11-7] staging contracts. The setup is a first-order filter with root inputs `u_cmd`
and `τ`, a fictitious 100 Hz single-axis joystick streaming a slow ramp onto
`u_cmd` (a complete writer), and a 60 Hz GUI with sliders for both
[root inputs](#g-root-input) (a sparse writer). [Boundaries](#g-boundary) run
at 50 Hz, at pace 1. The interference on `u_cmd` is the point.

Three candidate staging shapes were on the table: **per-input cells**, a
shared **[batch](#g-batch) stack**, and **per-device cells**. The user-level
listing came out identical across all three, so ergonomics cannot discriminate
between them. Behavior under a concrete interleaving did.

**Root-input exclusivity rules out the very contest the setup builds.** Under
root-input exclusivity ([§11.3][s11-3]) the contested-`u_cmd` scenario cannot
arise, because a second writer on `u_cmd` is an attach-time error. What the
test settles is therefore the cell *shapes*: atomicity,
[coalescing](#g-coalescing), pause behavior and the peek rule. Its
conflict-precedence comparison and the active-widget stage-every-pass contract
([§11.7][s11-7]) describe a contested-input world the design does not have.
The findings below are read under that scope.

- **Drag against the stream.** The user grabs the `u_cmd` slider while the
  joystick streams. Under per-input cells and the batch stack, each
  [frame](#g-frame)'s conflict resolves by last-store/last-push wall-clock
  order ([D-024][d-024]). With 16.7 ms renders against 10 ms polls, the
  applied input alternates between drag value and ramp on the cadence beat,
  the filter visibly wobbles, and the pattern differs run to run. The
  [trace](#g-trace) replays any given run exactly, but the behavior is still a
  timing artifact. Under per-device cells the GUI stages in every drag frame,
  since it renders at least once per 20 ms frame and the active-widget
  contract stages on every pass. The GUI therefore wins every
  [drain](#g-drain) (the frame-top swap that publishes staged device writes
  into the root inputs) by attachment order. That win is a clean,
  deterministic override for exactly the grab duration. The same user code
  gives qualitatively different physics.
- **Edits while paused.** Under per-input cells, the still-polling joystick
  overwrites the user's `u_cmd` edit about 10 ms later ([D-024][d-024]). The
  knob visibly snaps back and the edit never applies. Under the batch stack,
  the edit is buried under newer pushes, and the pending chain grows at the
  polling rate, about 10³ nodes per 10 s pause, with every [peek](#g-peek)
  walking that chain ([D-024][d-024]). Under per-device cells, the `u_cmd`
  edit holds in the GUI's own cell across the pause, and the knob keeps the
  edit by the [§11.7][s11-7] peek rule. That edit merges with the `τ` edit,
  which is the sparse-accumulation case, and applies at the un-pause drain. It
  holds for one deterministic frame before the joystick reclaims the root
  input. That one-frame application is the honest semantics of one-shot
  editing a streamed input. The uncontested `τ` edit works under all three
  shapes.
- **Corrections the exercise forced.** The sparse-writer lost-write hazard is
  specific to one-cell-per-device layouts. Per-input cells cannot lose
  independent-input writes, so the CAS merge is per-device cells' antidote,
  not a general need. And the batch stack's conflict order is temporal, not an
  attachment-order policy ([D-024][d-024]).
- **Discoveries.** There were two: the active-widget contract, and the
  [port](#g-port)-resolution answer to panel reuse ([§11.7][s11-7]). The
  second came from asking how the filter's panel survives the filter becoming
  an embedded [component](#g-component) with `u_cmd` driven by another
  component.

### 11.5 Inbound: the input trace

**The input [trace](#g-trace)** is the sequence of drained,
[device](#g-device)-tagged batches per frame. It extends the determinism
([§10.7][s10-7]) end-to-end. Replaying a recorded interactive session
reproduces the trajectory bit-identically, with staging fed from the
recording and no devices or mappings present.

**One record format: every batch is retained sparse.** At the
[drain](#g-drain) (the frame-top swap that publishes staged device writes
into the root inputs) each drained [cell](#g-staging-cell) is scanned. Its
masked (touched) entries are recorded as (position ⇒ value) pairs, against
the writer's [face](#g-face)-name → position schema in the `schemas` list (below).
That is an O(surface-width) scan and one small allocation per drained batch.

**Why.** The rule is uniform because a [claim](#g-claim)'s *width* is a fact
about one binding, not about a class of writers. A
[greedy claim](#g-greedy-claim) is enumerated and as wide as the root
[contract](#g-contract) ([§11.3][s11-3]), so keying retention by claim source
is rejected ([D-176][d-176]). Every consumer then handles one format instead
of two. There is one record format at the trace's edge, no per-entry format
flag, one decoder in [what-if replay](#g-what-if-replay) (replay with
edited inputs), in disk serialization and in human inspection, and one
inverse conversion in [replay](#g-replay). That work is paid once, up front,
off the loop ([§12.7][s12-7]). The conversion site is the drain and not the
staging shim, because the drained tuple is the *coalesced* truth. A shim-side
sparse log would need its own merge.

**The costs are recorded rather than argued away.** On the wide writers the
conversion is what keeps the trace honest. A tuple as wide as the unclaimed
surface carrying one edit would otherwise make trace size track surface
width rather than information. At hundreds of faces, render-rate dragging
would inflate the trace past the two-orders-below-the-log budget that
justifies trace-on-by-default ([D-029][d-029]). On the dense
[component](#g-component) the conversion costs **about 2×**, a position
beside every value where the positional tuple carried the value alone. That
changes no order of magnitude, and it leaves the budget ([D-029][d-029])
standing for every writer at once. The allocation is in-class with what the
retention carve-out ([§9.8][s9-8]) already admits. Per [boundary](#g-boundary)
it is smaller than the log's [snapshot](#g-snapshot), the carve-out's standing
occupant and the one qualified exception to retains-what-was-already-allocated.
And the decision is **reversible as pure implementation**. The conversion is
lossless in both directions, so verbatim retention could return as a
per-entry storage optimization if a marathon-session measurement ever asks
for it. Such a return would leave the record semantics, the header and the
replay path exactly as they are.

**The [trace header](#g-trace-header) is the checkpoint `init!` takes at the
end of [boundary zero](#g-boundary-zero)**, after the first
[snapshot](#g-snapshot) is published ([§12.6][s12-6], [D-274][d-274]). A
[checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one
value) holds the flat buffer `x`, the `s` and `m` stores, the whole signal
table, the guard [priors](#g-prior), `t` and `t₀`, the frame and boundary
counters, and the fingerprint. The executor's clock holds `t` and `t₀`, and
the [run](#g-run) (the state one run owns) holds the frame index and the
boundary ordinal ([D-317][d-317]). The header
holds the stores and the [root-input](#g-root-input) cells as values, never
the sparse authored overlay. Replay must survive edits to declared defaults,
the primary-data doctrine ([D-038][d-038]).

An unfed `mixture = 0.5` never appears in any batch, so replay is broken
without the root inputs. The init/trim services own root-input
initialization ([§14.6][s14-6]), and the checkpoint's table holds the values
they wrote. The fingerprint is the part of the header replay compares
rather than restores ([§12.7][s12-7]).

- **The run's `Deployment` and the structural layout.** The
  [deployment](#g-deployment) (the scalar-free artifact the grid parameters
  fix) comes from [§9.2][s9-2], and it carries `Δt_base`, `h`, `N_base`, the
  algorithm identifier, `localization_tol`, `localization_budget`
  ([§10.4][s10-4]) and `firing_budget` ([§10.6][s10-6]). The layout is the
  store layout and the root-input faces the `Build` fixes. It also holds what
  a copy by position relies on: each component's `x` type, every cell's
  address with its type, and the event list in the order of the priors. Both
  are taken at the same instant
  as the state. The deployment holds no policy
  ([D-255][d-255]). `t_end` and `ignore_stop_requests` are keywords of each
  advance ([§13.5][s13-5]), and only the terminating advance's policy explains the
  stop, so the [termination record](#g-termination-record) carries that one.

**`Trace` is that fixed header plus two append-only lists**, `schemas` and
`batches`, and its length ([D-255][d-255]). A trace records a `Simulation`,
which runs only a `Model{Float64}`, so `Trace` takes no scalar parameter
([D-317][d-317]). The header is written once, by the door that
builds the run, and never again, which is what makes it an artifact. The lists
grow in place, the batches at every drain and the schemas at every roster
change. The length is the drain's count on the live trace, frozen into the value
`trace(sim)` hands back. It advances at the top of each drain, and the frame
ordinal every record of that drain carries is this count ([D-260][d-260]).

**Each writer's face-name → position schema lives in the `schemas` list.**
Positional records are meaningless without it, and replay does not reconstruct
claims ([§12.7][s12-7]). The list only grows ([D-217][d-217]). `attach!` and
`detach!` push the current writer set onto it in place, because a roster
change between advances ([§12.6][s12-6]) recompiles the harness writer and the
same face moves position. Earlier records keep their index, and a record
resolves only through its own schema entry.

The trajectory depends on the deployment exactly as it depends on the
stores. The `Deployment` constructor ([§9.2][s9-2]) sits outside the `Build`,
and the checkpoint carries the clock, `t₀` included ([§14.5][s14-5]). A header
without them could therefore not back the bit-identity claim
([§12.7][s12-7]). The header is also what the artifact's
[run metadata](#g-run-metadata) names ([§13.5][s13-5], [Appendix B][sB]). A
checkpoint is the one full-state capture, taken by `init!` for the header
and by `checkpoint(sim)` on demand ([§12.6][s12-6]). The header is the other
half of what "given the initial state and the trace, the log is
recomputable" requires. Header plus batches are the *primary* record.
Everything else, the state trajectory included, is derived
([§11.2][s11-2]). The trace also carries its length, the frame index of its last
drain ([D-217][d-217]). Under `init!` that is the number of drains since the
header was taken. A trace that `restore!` opens starts at the checkpoint's
frame, so its records keep the trajectory's own frame indices
([D-274][d-274]). A recording whose last frames drained nothing still ran
them, and every advance in `:replay` is capped at that frame
([§12.7][s12-7], [D-218][d-218]).

**Trace recording is on by default.** `init!` builds a fresh trace with the
run under its `trace` keyword ([§12.6][s12-6], [Appendix B][sB]), the trace
is retrievable after the run, and a plain kill
switch covers memory-constrained marathon sessions. The asymmetry that decides
the default is that the trace is *primary* data and the log *derived*. Given the initial
state and the trace, the log is recomputable, which is what bit-identical
replay means. An untraced interactive session, by contrast, is
unreproducible, permanently. The cost supports the default. The trace
retains one small sparse record per drained batch (above), at drain-rate ×
device-count. That is tens of MB per hour worst case, two orders of magnitude
below the snapshot log. There is no sampling and no rolling window
([D-029][d-029]).

### 11.6 Devices: one authoring contract, no taxonomy

FlightCore's input/output/GUI trichotomy is lock choreography, not modeling.
With no lock, the protocol the taxonomy encoded has no referent
([D-025][d-025]).

#### Every attached device receives the same handle

The handle carries the two primitive capabilities, read and stage, plus
control access (observe running, request shutdown). Read returns the latest
[snapshot](#g-snapshot), optionally waiting for the next
[boundary](#g-boundary) ([§12.3][s12-3]).

**A handle outlives its roster entry as an object only.** `detach!` retires
the entry and the compiled writer behind it, but the caller may still hold
the handle `attach!` returned. Its two write primitives, `stage!` and
`report!`, then refuse by name (`DeviceContractMismatch`, [Appendix C][sC]). A
batch staged there would land in a cell no [drain](#g-drain) reads, and a
report would land in a diagnostic cell no frame top folds. Silence is the
hidden-bug class this section tolerates nowhere. The read primitives stay
legal, since they read the simulation's shared state and nothing of the
entry's ([D-244][d-244]).

**[`should_abort`](#g-should_abort) is an `attach!` keyword**, defaulting to
`false`. It is per-attachment, never a device property. The same joystick is
advisory in one deployment and decisive in another. With it clear, a
device's departure is reported and the run continues without it. With it
set, that departure also requests a sim stop ([§12.4][s12-4]). A departure
is the loop body returning, a crash, or a failed `init!`. A
hardware-in-the-loop rig attaches its plant interface with it set, since a
run without that device is meaningless.

Input-only and output-only devices are degenerate uses, not framework
classes. A bidirectional network peer is *one* device with one socket and
one lifecycle, not two framework devices sharing state. The GUI is an
ordinary device, the paradigm one, and it uses every capability. Its one
genuine peculiarity is not taxonomic: read-modify-write widgets
([§11.7][s11-7]).

#### The authoring contract: four functions, one optional

A [device](#g-device) is a user type subtyping the framework's neutral root:
`MyDevice <: AbstractDevice`. That is one mandatory word, and it costs
nothing, because the [periphery](#g-periphery) has no competing hierarchy to
inherit from. What it buys is `attach!`'s dispatch gate below. The framework
asks for

```julia
init!(dev)          # per-run resource acquisition — calling task, before spawn (§12.4)
loop(dev, handle)   # the task body: owns its own wait structure
shutdown!(dev)      # per-run resource release — guaranteed on every exit path
unblock!(dev)       # optional hook, default no-op: make a blocked loop return (§12.4)
```

The framework owns everything around them. The wrapper is the shutdown
protocol ([§12.4][s12-4]) made structural:

```julia
init!(dev)                                   # its own bracket, pre-spawn (§12.4): a throw
                                             # here is shutdown! + DeviceCrash by name
task = Threads.@spawn try
    loop(dev, handle)
catch e
    report!(entry, DeviceCrash(e))           # §12.4(6): sim continues, device absent
finally
    shutdown!(dev)                           # any exit path: OS resources released
    mark_dead!(...)                          # heartbeat only — claims stay, §11.3
end
```

**`shutdown!` must tolerate a partially initialized device.** The release
guarantee holds on the one path *outside* this wrapper too. The
initialization step ([§12.4][s12-4]) brackets each `init!`, and a device that
threw half-way through acquisition goes straight back to `shutdown!`, so
nothing it did manage to open is leaked. The obligation that follows is
"close only what is open". That is the same defensiveness `shutdown!`
already owes the crash path, where a loop body may die at any point in its
own life. `init!` is correspondingly *not* asked to clean up after itself.
The bracket does once, for every device, what would otherwise be duplicated
in each and enforced in none.

**The same tolerance covers a repeated call.** The wrapper runs `shutdown!`
once on every exit path and records the release just after it returns. An
operator interrupt landing between the two makes the run's tail run
`shutdown!` again rather than leak the device ([§12.4][s12-4],
[D-268][d-268]). The tail's own call can be cut the same way, so each such
interrupt adds one call. A `shutdown!` that closes only what is open is
idempotent by construction, so a repeated call costs nothing and is never
reported.

**The tolerance also covers a call with no `init!` before it.** The
initialization step lists each device for release before its `init!` begins,
so that no interrupt can leave an initialized device unlisted ([§12.4][s12-4], [D-268][d-268]).
An operator interrupt landing between the listing and the `init!` therefore
releases a device that opened nothing. A `shutdown!` that closes only what is
open does nothing there, and the call is never reported.

The wrapper makes one discrimination. **An `InterruptException` is never a
`DeviceCrash`.** Under the spawned-loop topology the calling task is the one
running a device loop body inline, the GUI's ([§11.1][s11-1]). An operator
Ctrl-C therefore raises *there*, inside user code that did nothing wrong. The
wrapper forwards the control-plane stop and lets the body leave through the
ordinary `running(handle)` predicate ([§12.4][s12-4](4)). There is no crash
report for what is not a crash, and no `should_abort` consultation, since a
stop is already requested.

#### The author owns the loop body; the framework owns the bracket

One device contract means author-owned loop bodies. A framework-owned hook
loop would have to ask each device what it waits on, which is the rejected
taxonomy resurrected as a trait ([D-102][d-102]). Under the author-owned
body, every wait structure is ordinary user code composed from handle
primitives:

```julia
function loop(dev::T16000M, handle)              # timer-driven, full write-set
    while running(handle)
        sleep(dev.Δt_poll)
        stage!(handle, map_input(poll_axes(dev), binding(handle)))
    end
end

function loop(dev::UDPInput, handle)             # source-driven, data-dependent
    while running(handle)
        datum = recv(dev.socket)                 # blocks; unblock! closes the socket
        is_eot(datum) && return                  # voluntary exit
        try
            stage!(handle, map_input(datum, binding(handle)))
        catch e
            is_datum_error(dev, e) || rethrow()  # a bug → wrapper → DeviceCrash
            report!(handle, MalformedDatum(e))   # garbage → visible, bounded, alive
        end
    end
end

function loop(dev::Telemetry, handle)            # boundary-driven output
    while running(handle)
        snap = wait_next_snapshot(handle)        # §12.3; returns on stop
        send(dev.socket, map_output(gather(handle, snap), binding(handle)))
    end
end
```

A bidirectional peer composes both halves itself, with an inner reader task
inside its own domain, rather than forcing a select engine into the
framework. Two idioms are author obligations the framework can only teach
and diagnose, never force ([Appendix A][sA]): loop on `running(handle)`, and
make blocking calls interruptible (`unblock!`, or timeouts). A forgotten
predicate check surfaces as `DeviceJoinTimeout` with the device's name. A
stall surfaces as a stale heartbeat ([§12.2][s12-2]). Liveness timestamps
ride *inside* the handle primitives, which store them in the device's own
[diagnostic cell](#g-diagnostic-cell) ([§11.8][s11-8]), so the framework
observes activity without owning the loop.

**`should_close` dissolves.** A window ✕ or peer EOT is the loop body
returning. The wrapper's exit path releases the device's OS resources, marks
it dead for the heartbeat and consults `should_abort`. [Claims](#g-claim) and
the [roster](#g-roster) entry persist to run end (the freeze,
[§11.3][s11-3]). [§12.4][s12-4](6) is literally "the task body returned."
The GUI implements the same authoring contract.

#### The binding: framework-legible by enumeration, opaque in its mappings

A binding is a value subtyping `AbstractBinding`, the second mandatory root.
Its type declares which sides it has and enumerates what each side touches.
The legible half is explicit methods returning data, called once at attach
on the [calling task](#g-calling-task) (the task that invoked `run!`). The
opaque half is called per datum on the [device](#g-device) task by the
author's own loop:

```julia
struct T16000MBinding <: AbstractBinding    # the roots are mandatory: attach! dispatches
    table::NamedTuple                       # on ::AbstractDevice, ::AbstractBinding
end

is_input(::T16000MBinding)  = true     # sides are *declared*, never inferred; the root
is_output(::T16000MBinding) = false    # carries the false defaults, so silence = absent
is_greedy(::T16000MBinding) = false    # the claim source within the input side (§11.3)

claims(b::T16000MBinding)   = ...      # input side:  the enumerated face set → the claim
map_input(datum, b)                    #              datum → face ⇒ value pairs — user code
reads(b)                               # output side: labeled §14.4 selectors → one compiled gather
map_output(nt, b)                      #              the gather's NamedTuple → wire datum
```

The root carries `is_greedy(::AbstractBinding) = false` beside the two side
defaults, so silence is not greediness. The computed claim source is
declared or absent.

The framework needs no [contract](#g-contract) on the datum's shape. The
datum travels only between `loop` and `map_input`, written by the same
author, and the framework's structural knowledge comes entirely from the
declared traits and the enumeration methods. Everything enumerable validates
at attach. Everything opaque is bounded at its runtime enforcement point.
`map_input` is bounded by the staging checks ([§11.4][s11-4]). `map_output`
receives exactly the compiled gather's NamedTuple, and what it puts on the
wire is the peer's business. `map_input`/`map_output` are, precisely,
**conventions of the author-owned loop idiom**. The framework never calls
them, so they are taught ([Appendix A][sA]) and never checked. A binding
whose loop calls something else by another name is simply a binding with a
different private helper.

**Rule.** `reads(b)` returns a labeled NamedTuple of [selectors](#g-selector)
(the closed family of deferred reads, [§14.4][s14-4]), for example
`(; alt = get_output(…), pose = get_face(…))`. The labels are the binding's
own naming, carried through compilation in declaration order, so the
NamedTuple `map_output` receives is keyed by exactly the names `reads`
declared. One returned value thereby fixes names, order and reads together,
under the same attach-time validation as `claims` ([D-199][d-199]).

**Sides are declared, and the obligations they create are enforced both
ways.** `claims` and `reads` have **error-throwing fallbacks on the root**,
so a declared side whose method was never written fails loudly at the attach
point rather than degrading into silence. The attach runs a
**bidirectional conformance check** over the pair (trait, method):

- `is_input && !is_greedy` ⇒ `claims(b)` is called once and its
  [faces](#g-face) staked. The fallback firing here means "you declared an
  input side and wrote no enumeration".
- `is_input && is_greedy` ⇒ the [claim](#g-claim) is computed
  ([§11.3][s11-3]), and a `claims` method defined for this binding is an
  error. The two sources are alternatives, not layers.
- `is_output` ⇒ `reads(b)` is called and the gather compiled.
- Neither side declared ⇒ attach-time error naming both traits. A binding
  that touches nothing is a configuration mistake, not a degenerate.
- `is_greedy` without `is_input` ⇒ error. Greediness is a *source* within a
  side, and a source without its side is meaningless.
- A **specific** method of `claims` or `reads` defined for the binding type
  while its trait reads false ⇒ error, the converse direction of the same
  fact. A method written and never reached is exactly the drift the check
  exists to catch. Detecting it is one `which` against the fallback method.
  That is the reflection class ([§8.1][s8-1]), where the shadowing check is
  an `isdefined`/`!==` pair. The `which` detection runs once at a stopped-sim
  service point, not inside any frame.

Every violation in that list reports `BindingContractMismatch`
([Appendix C][sC]). The report names the binding type, the trait, the method
at fault and the direction (declared-but-missing, or defined-but-undeclared).

**This is what closes the shadowing hole.** Under the rejected alternative,
detection by method presence ([D-177][d-177]), a bidirectional binding whose
`claims` was written without extending the framework's generic presented as
output-only and degraded *silently*. That omission is the
`using`-without-`import` trap ([§8.1][s8-1]), one level down. With the side
declared, the absent method has something to contradict.

Greediness stays orthogonal to `reads`. A greedy front end may also drive a
compiled output gather. That combination is legal and currently
uninstantiated. Its plausible customer is a narrow-wire interactive surface,
a motorized control board whose detents must be driven back out. The binding
stays an `attach!` argument, never a device field. The same `T16000M` binds
differently per aircraft, and narrowing the binding narrows the claim
([§11.3][s11-3]).

**Why the [periphery](#g-periphery) gets roots where
[components](#g-component) have one.** [§8.5][s8-5] refuses a class supertype
for two reasons, and neither reaches here. First, a component's
single-inheritance slot is *already spoken for* by the domain hierarchies
(`AbstractAircraft`, engine families), while a device's and a binding's are
vacant. Nothing else wants them. Second, a component's class is
implementation detail behind its contract ([§8.5][s8-5]), while a binding's
**sidedness is its public contract**, the one thing every consumer of it
must know.

Rejected, correspondingly ([D-177][d-177]): an abstract binding-type
*taxonomy* encoding the sides, optional roots left unenforced, and a declared
`sides(b)` trait returning the side set. The last of the three is **answered
rather than repeated** by the design above, since redundancy *with a
cross-check* is drift detection. That is what the bidirectional check turns
the traits into. The same fact is stated twice, in two forms, with the
framework paid to compare them.

**`is_greedy` is a claim source, not a device class.** What the declaration
buys is one computation at the attach point. After it the binding holds an
ordinary claim set, and every mechanism downstream is blind to where the set
came from: exclusivity and storage ([§11.3][s11-3]); shape, shim, merge,
scatter and [drain](#g-drain) ([§11.4][s11-4]); [trace](#g-trace)
([§11.5][s11-5]); detach's release. There is no derived surface shared among
the writers that elected it, and no device class hanging off the marker. The
standing rejection is untouched. Opportunistic writing to unclaimed faces
"for any device" stays dead ([D-044][d-044]). Autonomous devices still
enumerate, and a maximal surface is what exactly one line of a binding asks
for, in the open, checked like any other claim.

**A second greedy attach stakes the empty remainder.** The complement is
computed against the [roster](#g-roster) as it stands. A greedy binding
attached after another has already swallowed everything therefore gets the
empty claim. That claim is legal, being the honest may-write-nothing
degenerate below, and it is useless, which is worth saying out loud. The
attach succeeds and records `EmptyGreedyClaim` ([Appendix C][sC], a warning
naming the device and its binding) in the roster entry's diagnostic cell.
`attach!` mutates the roster, so the warning lives in that state's status and
surfaces through the status record ([§11.8][s11-8], [D-250][d-250]). The log line
at return is presentation. That is the one honest reading of "you asked for
what is left and nothing was left".

**Several interactive front ends may be rostered at once.** A web console
can claim the autopilot faces beside a local GUI claiming the stick faces.
With explicit claims they are simply two enumerated devices, partitioning
the surface rather than sharing it.

**The shipped GUI binding is a greedy one.** It declares `is_input` and
`is_greedy`, stakes the computed claim (everything unclaimed at the moment
it attaches), and defines no `claims` of its own. It declares no `reads`
either, because its read path is the handle's primitive read. Paced by its
own clock, it reads `latest` afresh at each tick ([§12.3][s12-3]), with an
ad-hoc read set over the whole [snapshot](#g-snapshot). That is the
shape of an inspection read ([§11.2][s11-2]). The compiled output gather
therefore has nothing to do for it. The same GUI device type is equally
attachable under a binding that returns explicit claims. Greediness is the
binding's declaration, not the device's nature. Every other interactive
front end anyone might want (a web console, a remote panel) has both
spellings available. It can attach with the greedy binding where the GUI
would have been, or with explicit claims beside other front ends.

**The empty enumeration is not a back door.** `is_input(b) = true` with
`claims(b) = ()` stays an honest degenerate, a device that may write nothing.
Its writes are still binding-bounded, so drift onto any face is
`OutOfClaimEntry`. There is no privileged class for it to promote into
either. `claims` bodies are ordinary code (the idiom, [§8.5][s8-5];
comprehensions included), and an enumeration that came back empty by
accident stays inert, exactly as written. The maximal surface is reachable
only through the explicit `is_greedy(b) = true` declaration. The most
privileged claim is the hardest to acquire by accident, and a declared trait
is deliberate authorship. For the same reason, `claims` never returns
`nothing` or a sentinel to mean "compute it for me". The enumeration
contract has one meaning and the trait carries the other. A dual-meaning
return would be exactly the ambiguity the declaration vocabulary is built to
refuse.

#### One shipped binding type; conditioning has an owner

`TableBinding` is *data-driven*. The framework writes its `map_input` once,
and a table value (axis/button entry → [face](#g-face), deadzone/expo
parameters) is constructed per [device](#g-device) × aircraft pairing, where
configurations are made:

```julia
TableBinding(stick_y  = (face = "elevator", deadzone = 0.05, expo = 0.6),
             throttle = (face = "throttle",),
             trigger  = (face = "brake_count",))       # levels doctrine: a counter
```

Its generic `map_input` *is* the shared pure conditioning helper
([§11.4][s11-4]), and its owner. The entry tuple rides in the type, so the
mapping specializes per table with no dynamic dispatch. A *code-driven*
binding looks identical to the framework. A JSON telecommand peer whose
`claims` returns the vocabulary and whose `map_input` parses bytes is one.
One purity note is taught in [Appendix A][sA]. Cross-datum state, such as
press counters and edge detection, lives in the device struct, maintained by
the loop, and arrives *inside* the datum. `map_input` stays pure.

#### Bad datum versus bug: two classes, two fates

A datum that cannot be mapped for environmental reasons (a truncated
datagram, malformed JSON, an out-of-range field) is a
[bad datum](#g-bad-datum), tolerated *in the loop body*. The body catches
it, stages nothing, calls `report!(handle, MalformedDatum(cause))` and
continues. That tolerance is bounded by the [device](#g-device)'s own
[diagnostic cell](#g-diagnostic-cell) (the ring and suppressed counts,
[§11.8][s11-8]; the stream, [§13.2][s13-2]), and what it records is visible
next to a live heartbeat. Any other exception propagates, and the wrapper
turns it into `DeviceCrash` ([§12.4][s12-4]).

The classification is the author's, because only they know their parser.
FlightCore's `InputMappingError` docstring assigned it the same way. What
changes under the author-owned loop is that no framework per-iteration catch
site exists, so the framework's contribution is the diagnostic channel, not
the catch. A marked exception type is not provided ([D-105][d-105]).
`report!(handle, …)` writes device-attributed runtime warnings into that
device's diagnostic [cell](#g-diagnostic-cell), the single-writer entry point
into the runtime warning stream ([§13.2][s13-2], [§11.8][s11-8]), and
nothing more. It is not a general user-diagnostics channel. Tolerating
everything hides bugs as "device attached, nothing happens". Tolerating
nothing kills a live telemetry link on its first truncated datagram, and
since tasks are per-run artifacts ([D-093][d-093]), kills it for the rest of
the run.

### 11.7 The GUI write path: port resolution, peek, staging contract

Panels remain per-[component](#g-component) extensions in FlightCore's style,
such as `GUI.draw!(ctx, ::LowPassFilter)`, discovered by walking the
[assembly](#g-assembly). Widgets, however, name **the component's own
[ports](#g-port)**, never [root inputs](#g-root-input). The build-time wiring
answers one question statically and exactly: *is this port transitively
driven by a root input, and which one?* Every input port has exactly one
source ([§6.1][s6-1]), so the resolution is total:

- **Root-driven, within the GUI's claim: a live widget.** It
  [peeks](#g-peek) and stages the resolved root input through the GUI's own
  [staging cell](#g-staging-cell).
- **Component-driven, or root-driven under another device's claim: a
  read-only rendering.** It displays the driven value from the
  [snapshot](#g-snapshot), visually distinct, with its source
  ("driven by `avionics/throttle_cmd`", the canonical slash form of
  [§8.6][s8-6]).

This retires FlightCore's dead-slider convention and replaces it with checked
structure: **a widget is live exactly when the underlying input is yours to
command in this configuration.** The dead slider is the `Cessna172Xv1`
throttle. The engine panel's slider is visually live and the avionics
silently overwrite it every cycle, so who commands what lives in the user's
head. User-commandability is a wiring decision made where configurations are
made. Command-plus-manual-override is a mux component with a root-wired
select. That is explicit structure, not two writers racing (the same race as
the drag phase in the worked example of [§11.4][s11-4], ruled out the same way). This places one
obligation on the GUI. Read-only rendering is first-class, not an error
state, because the author of `input_slider!` cannot know at authoring time
whether it will be live.

**Liveness is a [derived property](#g-derived-liveness), and resolution is
transitive.** A widget is live iff two things hold. Its port's feed chain
terminates in a root input, *and* that root input lies **inside the GUI's
own [claim](#g-claim)** in the run's frozen surface partition (root-input
exclusivity, [§11.3][s11-3]). The feed chain is walked through [local wires](#g-local-wire) and
interface connections across *all* levels, not just the local assembly. The
claim may have been computed from the unclaimed complement under
`is_greedy`, or enumerated [face](#g-face) by face by a partial-claims
binding ([§11.6][s11-6]). Either way, "live" reads as "inside the surface I
declared for".

Under the [roster](#g-roster) freeze, liveness is a static fact of the run.
It is baked once, with the port resolution, when the run starts, and never
consulted against mutable claim state at render. There is no per-port
"GUI-controlled" marking anywhere. The export chain is the marking, written
by the one author entitled to write it. A component's ports become
GUI-commandable exactly when the assemblies above surface them. The switch
between "driven by its own panel" and "driven by an external provider" is
therefore automatic. At build time it follows the wiring archetype, where a
scripted `World` wires a [scenario component](#g-scenario-component) into the
same faces the interactive `World` exports to root. At run start it follows
roster claim state. Nominally-connected ports with a GUI *override* channel
are rejected ([D-045][d-045]). The honest cost stands. **Unexported ports are
unpokeable.** FlightCore's poke-any-`u` workflow does not survive
[contract](#g-contract) visibility ([§8.3][s8-3]), deliberately.

**Peek rule.** A widget displays its **own pending write if any, else the
snapshot value**. It peeks its own [cell](#g-staging-cell) only. Another
[device](#g-device)'s pending write is invisible by design. Its applied value
arrives via the snapshot one frame later, and cross-device peek is rejected
([D-026][d-026]). While paused, staged edits display indefinitely and apply
at the un-pause [drain](#g-drain) (the frame-top swap that publishes staged
device writes into the root inputs). Fan-out is consistent for free. Widgets
on ports resolving to the same root input peek the same pending value.

**Staging contract: widgets stage on interaction events only.** Value
widgets (sliders, drags) stage the new absolute level on edit. Edge widgets
(buttons) stage on activation, as a level computed from the peek. A flaps
button peeks the current counter `k` and stages `k+1`. The levels doctrine
makes this safe by construction. Repeated staging of the same level within a
drain window is idempotent, so there is no repeat-increment hazard.
Multi-click within one window counts correctly through the
own-pending-first peek (`k` → stage `k+1`; second click peeks pending `k+1`
→ stages `k+2`). Held buttons do not re-stage. After the drain applies and
the snapshot catches up, re-staging from the peek would auto-repeat at frame
rate. The activation edge is the intent.

The alternative, active widgets staging on *every* render pass, is rejected
([D-026][d-026]). Under root-input exclusivity ([§11.3][s11-3]) it has no
motivation. As a side benefit, staging traffic (and trace noise) drops from
render-rate-while-grabbed to actual edits.

No claim-transition policy exists, because no claim transition can occur
mid-run (the freeze, [§11.3][s11-3]). The one liveness-adjacent display rule
is the orphan case. A read-only widget whose claiming device's task has died
renders the fact in its source label ("claimed by `T16000M` — task dead"), the
heartbeat surfaced in place ([§12.2][s12-2]). What it displays beside that
fact is the ordinary snapshot value, the orphaned root input's last drained
level. An orphan widget is a read-only rendering like any other, never a
blanked one. An orphaned root input is therefore visible where the user is
looking, not only in the status panel.

**The panel convention has two halves. The framework's half is fixed here,
and the GUI package's half is deferred.** A panel reaches the framework
through three values: a port view, the device handle and a snapshot. The
port view is this section's baked verdict, one per declared port of every
component, input and output. The handle supplies the two reads the peek
composes and the one write, `stage!`. The snapshot supplies every driven
value and the writer status the orphan label reads. Nothing a panel needs
reaches into the loop ([D-270][d-270]).

**Rule. The port view.** `port_views(handle)` builds one view per port of
every component, keyed by `(path, port)`, from the build's wiring, the
handle's claim and the exclusivity index. A view carries the port's terminal
producer (`("", face)` when root-driven), the liveness verdict, the port's
position in the handle's staging schema when live, the producer's cell
address, and the incumbent writer of a root-driven port the GUI does not
command. The GUI's loop body builds the table once at its top. That point
is after the roster freeze, so the incumbents are the run's, and nothing at
render resolves a name. The handle carries the build's `Structure` and the
nominal `Layout` by reference for this, the two things the bake needs that
the handle did not hold. An output port's view is read-only with itself as
producer, so a generated panel reads every face through one lookup.

| the port resolves to | live | slot | incumbent |
|---|---|---|---|
| a root input inside the GUI's claim | yes | its position | the GUI |
| a root input in another device's claim | no | none | that device |
| a root input no device claims | no | none | the harness |
| another component's port, or its own output | no | none | none |

**Rule. The peek.** `pending(handle, slot)` reads the handle's own staging
cell with one acquire load and never takes it: `Some(value)` when the slot
is touched, else `nothing`. A staged batch is never mutated after it is
published into the cell, so the load sees a complete batch or none.
`peek(view, handle, snapshot)` composes that read with the snapshot. A
live view returns its own pending value when one is touched, and the
producer's cell off the snapshot otherwise. A read-only view skips the cell
and reads the producer's cell. Two ports resolving to one root input share
slot and address, which is the fan-out consistency above.

The rule has one visible consequence, and it is the rule's own. Between the
frame-top drain that takes the cell and the publication of that frame's
snapshot, a live widget finds nothing pending and shows the previous
snapshot's value, for at most one frame's compute. A click inside that
window peeks the old level and stages a level already drained, which the
levels doctrine makes idempotent. No device task reads the loop's store, so
no reading is more current than this one.

**Rule. The orphan fact.** `incumbent_status(view, snapshot)` returns the
incumbent's writer record from the snapshot's status ([§11.8][s11-8]), or `nothing`
for a port no device writes. On that record, `orphaned` is a task that
returned or crashed, and `stale` is [§12.2][s12-2]'s silent heartbeat. The record
tells an exited loop from a crashed one, and the label may. The label text
is the GUI package's.

**What stays deferred is the GUI package's half** (`pending.md`), which the
built-in GUI's parking ([D-310][d-310]) assigns to the browser client over the
bridge: what the client receives beside the three values, how a panel
scopes to a child component, and the widgets. Its constraints are fixed
here. Panels name their own ports by face-name string. Resolution to root
inputs and the liveness verdict are baked at run start, never performed at
render. Liveness and peek arrive through the framework-supplied context,
never by reaching into the loop. And assembly panels compose children by
path.

### 11.8 Diagnostics and liveness: the per-writer cell

The chapter's two data channels are specified down to their memory ordering.
The runtime warning stream ([§13.2][s13-2]) and the liveness heartbeat
([§12.2][s12-2]) are a third, and they cross the same task boundaries. They
are written at staging by whichever task stages (`OutOfClaimEntry`,
`ClaimedFaceEntry` and `EntryTypeMismatch`, [§11.4][s11-4], on a
[device](#g-device) task or through the harness writer, [D-200][d-200]).
They are written by the device tasks (`MalformedDatum` from the author's loop
body via `report!(handle, …)`, [§11.6][s11-6]), by the loop itself
(`DebtReanchor`, `UnboundedRun`), and by the frame the loop runs
(`ChatteringBudget`, `FiringBudget`).
They are written at `attach!` too, into the roster entry being created
(`EmptyGreedyClaim`, [§11.3][s11-3]). `attach!` mutates the roster, so its
warning lives in the roster's status rather than on an artifact
([D-250][d-250]). The device's task does not exist until `run!`, so that cell
has no other writer yet. They are read by the loop, which folds them into the
published [framework status](#g-framework-status) ([§11.2][s11-2]) and hence
into every [snapshot](#g-snapshot). An unspecified structure with those writers is
exactly the arbitrary shared mutable state the two rules ([§11.1][s11-1])
exist to eliminate, so it gets the mechanism [§11.4][s11-4] already
established, not one of its own.

**One [diagnostic cell](#g-diagnostic-cell) per writer: one per rostered
device, one for the harness writer, one for the loop itself
([D-200][d-200]).** The [`Model`](#g-model) (the deployment and its
executor at one scalar) owns one more. Its frame writes the chattering and
firing-budget reports there, and the drain folds that cell into the loop's
account beside the loop's own ([D-317][d-317]). A device's
[cell](#g-diagnostic-cell), the loop's and the `Model`'s each have a single
writer, the same ownership argument as the
[staging cells](#g-staging-cell). There is no locking, no arbitration and no
new primitive. The harness writer's cell is written from whichever task
stages, exactly as its staging cell is, and the same CAS append arbitrates.
It carries no heartbeat, and its status record no `task_state`, because it
has no task of its own to be alive or dead. The cell holds a **bounded
accumulation** and one atomic liveness timestamp. The accumulation is a
small ring of diagnostic values, capacity **16**, plus a per-kind count of
what the ring could not hold.

**That bound *is* the rate limit.** When a writer emits past the ring's
capacity within one frame, the entry is not stored and its kind's suppressed
count increments. The drop policy retains the earliest in the frame, and the
excess becomes counts. The first occurrences are the ones with diagnostic
content, and the hundredth is noise the count already reports. Rate-limiting
"wherever its source can repeat" ([§13.2][s13-2]) is therefore not a policy
layered over the stream but a structural property of the channel that
carries it. A [chattering](#g-chattering) model or a peer flooding malformed
datagrams costs at most sixteen retained values and one integer increment
per kind per frame, whatever its source does. No writer can starve another,
because the cells are disjoint.

**This [drain](#g-drain) is the same drain [§11.4][s11-4] specifies.** One
`atomicswap` per cell at frame top, at the same point and under the same
indivisible-take argument as the staging drain. What the loop swaps *in* is
a shared **empty sentinel**, so a quiet frame swaps the sentinel in and gets
the sentinel back. That allocates nothing, and it leaves no load-only code
path that goes untested on healthy runs. The take is also what makes
publication sound. The batch is exclusively the loop's before it is ever
reachable from a snapshot, so the binding rule ([§11.2][s11-2]), that nothing
reachable from a published snapshot is ever written again, holds by
construction. The live accumulator is never reachable from a published
value.

**The heartbeat rides in the same cell**, as an atomic timestamp field. The
device task stores it on every loop pass from inside the handle primitives
([§11.6][s11-6]: the framework observes activity without owning the loop
body), and the loop acquire-loads it at publication, when it assembles the
status ([D-240][d-240]). There is no separate liveness channel and no second
registry. A device that is alive is a device whose cell carries a recent
timestamp, and the 2 s staleness threshold ([§12.2][s12-2]) is read against
this field. The heartbeat is not a diagnostic kind. It is a field, always
present, never enumerated in [Appendix C][sC].

**The published framework status is a concrete frozen value.** Per writer it
carries four things. `recent` is the ring this boundary drained, at most
sixteen entries. `suppressed` is the per-kind counts the ring refused this
boundary. `totals` is the cumulative per-writer × per-kind counts since the
run began, owned privately by the loop and *copied* into each status. And
`heartbeat` rides beside the `task_state` the loop reads off its own device
`Task` handle at publication ([§12.2][s12-2]). Beside the per-writer records
ride the pacer diagnostics ([§10.7][s10-7]). Delta plus total is what makes
the status legible at any reading cadence. A GUI panel refreshing at 60 Hz
sees each occurrence once in `recent`, while a consumer that samples
occasionally still reads a complete account from `totals`. Nothing is lost
by not looking. The record's `who` is the only attribution a value has, so a
renderer presents each value under its record's writer ([D-228][d-228]).

**Presentation is where `maxlog` lives.** A status renderer prints a given
writer × kind up to **25** cumulative occurrences and then switches to
count-only display ("`MalformedDatum` from `UDPInput#3`: 1 482
occurrences"). That threshold is presentation policy, not channel policy.
Counts keep accumulating regardless, nothing recorded depends on it, and the
choice belongs to whoever renders. The channel's own bound, above, is the
one that is normative.

**The terminal snapshot carries the run's final cumulative counters**
([§12.4][s12-4], [§13.5][s13-5]). An [unattended run](#g-unattended-run) (a
run with empty staging and no snapshot readers) that nobody watched
therefore still answers "what went wrong, and how often" from the value its
own shutdown published. Final means final at the last frame top
([D-201][d-201]). The account closes with the drain that preceded the
terminal publication. What lands after it can reach no snapshot. Examples
are a report from a device's exit path and the tail's own
`DeviceJoinTimeout` ([§12.4][s12-4]). So the loop takes each cell once more
at the run's end, keeping the next run's account clean. That last take is
folded into the [termination record](#g-termination-record) as the tail
residue, per writer the final ring and its suppressed counts
([§13.5][s13-5]), and presented through the standard logging backend. It is
loud *and* recorded, and still never published ([D-201][d-201],
[D-203][d-203]).

**Allocation.** On a quiet frame **nothing allocated scales with diagnostic
activity**. The sentinel swap allocates nothing, and the per-writer status
costs one small vector of records per publication beside the per-boundary
snapshot allocation [§11.2][s11-2] already accepts. That is the same
GC-over-reuse trade, a roster-sized vector rather than a snapshot type per
roster size ([D-241][d-241]). The per-kind counters are a **fixed-shape
isbits record, never a `Dict`**. The closed kind set ([Appendix C][sC])
licenses that, because it makes the counter layout a type rather than a
lookup. On a noisy frame the diagnostic values are allocated at emission, on
the writer's own task. A drained non-empty ring is frozen into the snapshot
and can never be written again, so the writer allocates a fresh ring lazily
at its next emission. That cost, too, lands on the writer's task, and it is
the same GC-over-reuse trade [§11.2][s11-2] makes when it rejects
preallocated snapshot buffers. The rate limit is therefore an allocation
bound as well. One ring of sixteen entries per writer per boundary is the
worst case, and everything past it is an integer increment. The
zero-allocation invariant ([§9.8][s9-8]), scoped to the model
[sweep](#g-sweep), is untouched. The cells sit on the framework side of that
scope with publication and logging.

One composition with the log is worth stating once. Because the log retains
snapshot references ([§11.2][s11-2]), `totals` is monotone across logged
snapshots. So `log_every` [decimation](#g-decimation) (the log's
keep-every-kth retention policy) loses *which* boundary within a skipped
stretch an occurrence fell on, never *how many* occurrences there were.

Rejected: a shared queue under a lock, a status referencing the live
accumulator, ring reuse by double-buffering, and unbounded accumulation
([D-136][d-136]).

---

