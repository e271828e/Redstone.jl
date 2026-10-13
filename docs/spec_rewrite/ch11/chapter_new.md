## 11. Runtime periphery: the data plane

This chapter specifies the data plane, how data crosses between the loop ([§10][s10])
and the periphery (GUI, input devices, network I/O and logging), taking root
inputs ([§8.6][s8-6]) as given. [§11.1][s11-1] covers the architecture that replaces FlightCore's
shared mutable model; [§11.2][s11-2] the outbound data channel, snapshot publication;
[§11.3][s11-3], [§11.4][s11-4] and [§11.5][s11-5] the inbound data channel, in turn its root inputs, claims
and frozen roster, its per-device staging, staged representation and drain, and
its input trace; [§11.6][s11-6] the device authoring contract; [§11.7][s11-7] the GUI write path;
and [§11.8][s11-8] runtime diagnostics and liveness, a third channel between tasks beside
the two data channels.

The machinery that drives the loop itself follows in [§12][s12].

### 11.1 No shared mutable model: staged writes, snapshot reads

Everything in the [periphery](#g-periphery) (GUI, input devices, network I/O, logging) runs on
tasks the loop does not control, and every one of them wants the data the loop
is stepping. FlightCore's answer is one big lock. In FlightCore's `sim.jl`,
`SimControl` and the live `Model` are guarded by `io_lock`, with one task per
attached interface reading or mutating the model under it. That lock does
enforce the [boundary](#g-boundary)-visibility rule ([§10.3][s10-3]), because the lock is only ever free
between steps. A boundary is a published consistency point. Transplanting the
lock here was nevertheless rejected, on three structural costs ([D-022][d-022]). One of
the three is decisive for everything below. Under a lock, input timing is
scheduler-determined and unrecorded. There is then no defined input [trace](#g-trace) (the
primary record of a session), and bit-identical [replay](#g-replay) (the ordinary loop with
its drain reading the trace, [§12.7][s12-7]) is unachievable *in principle* for
interactive runs. This section sets out the five planes that replace the lock,
the two rules that bind their implementation, the task topology, and one
consequence for execution modes.

The replacement's unit of account is the [frame](#g-frame) (one grid step, [§10.1][s10-1]). Each
frame is one iteration of the loop, which runs the [drain](#g-drain) (the frame-top swap
that applies staged device writes to the root inputs), then integrates, then
runs the boundary sequence, then publishes. A frame is what `step!` counts, and
it is the ordinal that keys the trace ([D-101][d-101]). "Per frame" means this throughout
the document. The kinematic *reference frames* of the aircraft domain are a
different word, and they always appear compounded, as in the b frame and the
ECEF frame. The b frame is the body frame, and ECEF stands for Earth-centered,
Earth-fixed.

The replacement has five planes.

1. Staging is the inbound path ([§11.4][s11-4]). [Devices](#g-device) (attached participants in the
   periphery) submit pending input writes at any wall-clock moment, never
   touching live [root inputs](#g-root-input) (the root component's own input faces).
2. **The drain is exactly one point in each frame, at its top**, where the loop
   takes the staged [batches](#g-batch) (each device's set of pending writes) and applies
   them to the root inputs ([D-022][d-022]). It never happens at a `t*` boundary ([§10.4][s10-4]).
   Between drains the loop owns its data exclusively, and no lock is held during
   stepping, ever.
3. Publication is the outbound path. The loop publishes an immutable [snapshot](#g-snapshot) (a
   boundary-consistent signal table with its framework status) at the end of
   each boundary sequence ([D-022][d-022]). Readers observe it without coordinating with
   the loop ([§11.2][s11-2]).
4. **Control places pause, pace and stop on a separate few-word atomic surface**
   ([§12.1][s12-1], [D-022][d-022]).
5. Task topology places one loop on the [calling task](#g-calling-task) (the task that invoked
   `run!`) and one spawned task per rostered device, all run-scoped.

Two rules bind the implementation.

- **Every handoff is one atomic reference operation** ([D-022][d-022]). The [staging cells](#g-staging-cell)
  (where a device's pending write batch waits between drains) and the reference
  to the published snapshot reduce their mutable surface to single words,
  release/acquire `@atomic` fields. The GC is the reclamation mechanism, since
  an object a reader still holds is reachable and therefore never recycled. That
  dissolves the reclamation problem (hazard pointers, epochs, read-copy-update
  grace periods) which makes lock-free handoffs hard in non-GC languages. Deep
  immutability of the exchanged objects is what makes this sound.
- **No user code, no unbounded work, ever, inside a framework critical section**
  ([D-022][d-022]). FlightCore's pathologies are all "arbitrary code under a shared
  lock". Here mappings run on device tasks ([§11.4][s11-4]), rendering runs against
  snapshots, and the loop's frame contains framework and model code only. A
  stalled device produces stale snapshots and late staging. It cannot stall the
  loop. Two exposures are residual and pre-existing, GC pauses and OS
  scheduling, and the pacer's debt absorption ([§10.7][s10-7]) is the mitigation for
  both.

The fifth plane carries the most machinery, and the paragraphs below spell it
out.

**Device tasks are run-scoped** ([D-093][d-093]). `run!` spawns one task per entry of the
[roster](#g-roster) (the list of attached device entries) after device `init!`, and [§12.4][s12-4]
joins them all at every stop ([§12.6][s12-6]). `attach!` never spawns. It registers, in a
stopped-sim state only ([§11.3][s11-3]), and the task appears at the next `run!`.

**The loop runs on the calling task** ([D-310][d-310]). This is what the synchronous
rethrow ([§13.4][s13-4]) presupposes. It is also what lets parallel unattended sweeps
thread `run!` inline with no nested task fan-out. One immutable [`Build`](#g-build) (the
artifact `build(world)` produces) is shared across the workers ([§9.2][s9-2], [D-282][d-282]),
and each `Simulation` owns its own `Model`, and with it the `Model`'s [buffers](#g-buffer)
(the framework-owned vectors backing continuous state) ([§9.4][s9-4]). Pre-materializing
the sweep's [activations](#g-activation) (the build's typed products at a scalar type) with
`build(world; activations = …)` ([§9.4][s9-4], [D-135][d-135]) then leaves no worker
synchronizing on anything. `run!` blocks its caller until the run ends.

Which devices get a task is decided after initialization, from the frozen roster
and the outcomes of device `init!`, never from `run!`'s keywords ([D-310][d-310], [D-138][d-138]).
A device whose `init!` failed gets no task ([§12.4][s12-4], [D-138][d-138]).

**Spawn-inside-`run!` is the start gate** ([D-093][d-093]). A task exists only once the
run it serves exists. Any first-boundary synchronization a device needs is the
counter-plus-condition predicate wait ([§12.3][s12-3]), never a `Base.Event` latch.

One consequence is recorded here because it collapses an API axis. Interactive
and unattended simulation stop being different execution modes ([D-022][d-022]). An
[unattended run](#g-unattended-run) is the same loop with empty staging and no snapshot readers. A
replayed interactive session is the same loop with staging fed from a recording
([§11.5][s11-5], [§12.7][s12-7]).

### 11.2 Outbound: snapshot publication

Every consumer of model state needs a picture of the model that holds still
while it is read. GUI panels and output [devices](#g-device) (attached participants in the
periphery) are such consumers. So is the [log](#g-log) (the retained sequence of published
snapshots). None of them should have to make the loop wait to get one.
Publication is the answer. One immutable value is published per [boundary](#g-boundary) (a
published consistency point), handed out through a single atomic reference.
Three things follow from it. In order, they are how a [snapshot](#g-snapshot) (the immutable
per-boundary publication) is built and published, how the log retains published
snapshots under a bound, and how an output device addresses what it reads.

#### The snapshot and its publication

**The loop builds each snapshot in private memory, then publishes it with a
single release-store** ([D-023][d-023]) to an [`@atomic latest`](#g-latest) reference (the single
handout point for published snapshots). A snapshot carries the
boundary-consistent [signal table](#g-signal-table) (the cells holding every produced signal) and
`t`. It carries the index of its [frame](#g-frame) (one iteration of the loop) and its
published-boundary ordinal ([§12.3][s12-3]). It also carries the [framework status](#g-framework-status) (the
run's diagnostics and liveness record, [§11.8][s11-8]). The frame index is what places a
`t*` snapshot in its frame, since a `t*` publication counts an ordinal of its
own ([D-261][d-261]). Readers acquire-load that reference and then work with an
immutable, coherent world for as long as they like. The [calling task](#g-calling-task) (the task
that invoked `run!`) reads the same value through `latest(sim)`, an inspection
read ([§12.6][s12-6]).

The exchange is wait-free in both directions ([D-023][d-023]). A wedged reader cannot
delay publication by a nanosecond, and the loop cannot tear a reader's view.
Publication happens only after the boundary sequence completes ([§10.3][s10-3], [D-293][d-293]).

The binding rule states that **nothing reachable from a published snapshot is
ever written again** ([D-023][d-023]). The soundness of lock-free reading rests on this
rule. The table's immutable values ([§4.1][s4-1], [§7][s7]) make the compiler enforce most of
it.

The framework status is a concrete frozen value, not a window onto live
bookkeeping ([D-136][d-136]). [§11.8][s11-8] lists what it carries. The binding rule forces that
shape. A status referencing an accumulator its writers are still filling would
be a snapshot whose contents change after publication.

The captured table is the whole table. It holds the declared [ports](#g-port) (the
addressable unit, one declared name with one cell), every one of them public
([§8.3][s8-3]). No presentation layer has anything to filter. Undeclared intermediates
are not in it, because only declared ports are [cells](#g-cell) (the signal table's typed
value holders, one per output port, [§8.3][s8-3]). The inspection path for one is
promotion to a declared output ([D-194][d-194]). Add a line in `y_types`, and the value
appears in the snapshot, the log, the GUI and the wiring alike. Its visibility
is then an authored fact like every other.

**The captured table also includes the [root inputs](#g-root-input)** ([D-047][d-047]). Root inputs are
the root component's own input [faces](#g-face) (the names ports wear on their component's
boundary). They are source cells of the table, not state stores, so they ride
along. That is essential, not incidental. The [peek](#g-peek) (showing a widget's own
pending write, else the snapshot value, [§11.7][s11-7]) falls back to the snapshot, and
that fallback is what an idle live widget displays. Read-only mirrors of claimed
root inputs, such as the axis sliders under joystick [claim](#g-claim) (the set of faces a
device may write), show the applied root-input value from the snapshot. Root
input values in the log are derived data, recomputable from the [trace](#g-trace) (the
primary record of a session). That is consistent, because snapshots are derived
wholesale.

**The snapshot deliberately does *not* carry the state stores** `x`, `s` and `m`
([D-038][d-038]). There are two reasons. The state trajectory is *derived* data,
recomputable from the [trace header](#g-trace-header) (the trace's fixed preamble) plus the [batches](#g-batch)
of staged device writes ([§11.5][s11-5]). The recomputation is bit-identical [replay](#g-replay) (the
ordinary loop re-driven from the trace). And per-boundary capture would
systematically record derived data, the same asymmetry the trace-default
decision ([D-029][d-029]) refuses in the other direction.

"What was the private state at t = 37.2?" is answered by replaying to 37.2 and
inspecting the live stores ([D-038][d-038]). A state field wanted in logs or GUI has the
honest remedy of being declared public and returned from `y_state` ([§5.3][s5-3],
[D-252][d-252]). It costs one cell per [sweep](#g-sweep) (one pass through the execution order).
Post-run continuation reads the live stores directly. Periodic full-state
checkpoints are a [guarded addition](#g-guarded-addition) (a capability the design admits but does not
build), shaped as an opt-in log policy ([D-038][d-038]). They would allow warm restart
without replay from zero. Each would retain a [checkpoint](#g-checkpoint) (the `Model`'s state at
a frame top as one value), the value `checkpoint(sim)` returns ([§12.6][s12-6]). A
dev-mode flag that reads every state field out of the stores is a possible
future diagnostic. It would be a reader over the stores, never a port class
([D-252][d-252]).

**Event firings are not recorded** ([D-309][d-309]). The log holds boundary snapshots and
the trace holds staged inputs ([§11.5][s11-5]). Neither carries a per-event record.
Replay plus the published modes recovers which events fired at which boundary.
The honest remedy is again to declare the mode field public and return it from
`y_state` ([D-252][d-252]). A mode field so exposed is in every snapshot. An event-firing
stream is a guarded addition.

#### The log: retained snapshots under a bound

**The log is a vector of retained snapshot references** ([D-023][d-023]). Logging thus
dissolves into publication. The references are the same objects, with zero extra
copies. The per-step `deepcopy` detour of FlightCore's `SavingCallback`
disappears. The cost is one snapshot allocation per boundary. It falls on the
framework side of the allocation scope [§9.8][s9-8] sets, which already carved out
logging. Logged snapshots are not garbage at all, and unlogged ones die young.
Preallocated snapshot buffers are rejected ([D-023][d-023]).

**Log retention is the trace's kill switch, plus [decimation](#g-decimation)** ([D-038][d-038]). The log
takes the same plain on/off switch the trace has ([§11.5][s11-5]). Decimation is the
log's additional keep-every-kth retention policy, `log_every` ([Appendix B][sB]).

The derived/primary split ([D-038][d-038]) decides why decimation is admissible here and
not there. The log is recomputable from the trace by replay, so a thinned log
costs resolution in a *view*, never in a record. Thinning the trace would
destroy the only primary account of a session ([D-029][d-029]). Decimation is a retention
policy only. Every boundary still runs, is still published to live readers, and
still enters the trace ([D-038][d-038]).

Decimation slows the log's growth. It does not stop it. The default
configuration is `log = true, log_every = 1` alongside `t_end = Inf`, `init!`'s
and `run!`'s defaults ([Appendix B][sB]). Under it the log grows for as long as the
session lasts. At the scale of the C172X (FlightApps' Cessna 172X model) and 50
Hz, that is gigabytes per hour. It ends in an out-of-memory nobody was warned
about.

**The log takes a retention bound beside its switch and its stride** ([D-137][d-137]).
The bound is `log_max`, the maximum number of retained snapshot references. Its
default is 65536 (2¹⁶), with `Inf` the explicit opt-out ([D-137][d-137]). The four
recording keywords appear on `init!` with their defaults ([Appendix B][sB]).

```julia
init!(sim, condition; trace = true, log = true, log_every = 1, log_max = 65536)
```

**The bound is a count, not a memory budget** ([D-137][d-137]). Snapshots are immutable
object graphs ([§4.1][s4-1]) with internal sharing. A [field handle](#g-field-handle) (an immutable query
object consumers evaluate at their own arguments, [§4.4][s4-4]) rides as a reference to
build-time-frozen data ([§9.8][s9-8]). Byte accounting over snapshots is therefore fuzzy
and platform-dependent. A count is exact. It converts to memory through one
number the user can measure once, `Base.summarysize` of a single snapshot.

**The default is finite unconditionally** ([D-137][d-137]). It is not a modal rule keyed
on `t_end`. A finite run shorter than the bound never notices the bound, and one
number is easier to hold than two regimes. At 50 Hz and full density, 2¹⁶
boundaries is about 22 minutes before anything is dropped at all.

**When the log fills, the retention stride doubles**, so coverage stays global
([D-137][d-137]). A rolling window, with the recent past at full density and the start of
the session forgotten, was rejected ([D-137][d-137]). Instead the log re-decimates
progressively. After *k* generations the effective stride is `log_every · 2^k`.
The whole run stays plottable, and what coarsens is density, never extent.

The doubling is the division of labor ([D-038][d-038]) carried through. The log's chief
consumer is the post-run plot of a session *as a whole*, and nobody plots hours
at 50 Hz. Full density over any *segment* of interest is what replay from the
trace recovers ([§11.5][s11-5], [§12.7][s12-7]).

**The guarantees are normative, not the mechanism** ([D-137][d-137]). There are three.
The bound is respected continuously, and the retained count never exceeds
`log_max`. Coverage is global at the effective stride. And **the endpoints are
retained unconditionally** ([D-137][d-137]).

The run's first snapshot and its terminal snapshot ([§12.4][s12-4], [§13.5][s13-5]) survive any
`log_every` and any `log_max`, and they do not count against the bound. They are
two extra references. The first is the boundary-zero snapshot under `init!`
([§14.5][s14-5]), and the snapshot `restore!` or `replay!` publishes as it builds the run
([§12.6][s12-6]). The stride counts boundaries from it. The terminal snapshot's status
carries the run's final cumulative diagnostic counters ([§11.8][s11-8]). A run's two
endpoints and its diagnostic account therefore always outlive whatever retention
did to the middle.

The mechanism sketch is non-binding. The thinning is amortized. When the log
fills, the stride doubles immediately. Each subsequent retained append also
releases one predecessor of the previous generation. A cursor over the odd
indices does this in O(1) amortized, with physical compaction once per
generation. A generation's thinning therefore completes exactly when its refill
does.

> fill at stride `log_every` → **full** → stride doubles → thin one predecessor
> per retained append, while refilling → **full** at stride `log_every · 2` → ⋯
> → generation *k* at `log_every · 2^k`

Amortizing rather than halving in one shot is a responsiveness choice ([D-137][d-137]).
The amortized form drops exactly one old snapshot per retained append, the same
steady trickle a rolling window would produce. Keeping coverage global therefore
costs nothing extra in GC pressure. The loop's own work is pointer bookkeeping,
microseconds either way and on the framework side of the scope ([§9.8][s9-8]).
Publication stays wait-free and readers never block. A reader holding a released
snapshot simply keeps it alive.

Two compositions are worth stating once. The monotonicity of `totals`, the
status's cumulative per-writer counters, across logged snapshots ([§11.8][s11-8]) is
untouched. Re-decimation, like decimation, loses *which* boundary within a
stretch an occurrence fell on, never *how many*. And **`log_max` is a view
policy, not a trajectory-determining one** ([D-137][d-137]). Like `log` and `log_every`
it stays out of the trace header's [`Deployment`](#g-deployment) (the scalar-free artifact the
grid parameters fix), and replay neither records nor compares it ([§11.5][s11-5], [§12.7][s12-7]).
Sizing follows. A finite `log_max` is the log's `sizehint!` ([§9.8][s9-8]).

#### Output-device bindings

**Output-device [bindings](#g-binding) are snapshot bindings** ([D-083][d-083]). A binding is the value
passed at `attach!` that makes a device framework-legible. An output device
consumes snapshots as [§12.3][s12-3] specifies. Examples are telemetry, disk streaming
and the XPlane visualizer (FlightCore's `XPlane12Control` output device). An
output device addresses what it reads with the [selectors](#g-selector) (the closed family of
deferred reads resolving against a source, [§14.4][s14-4]). They reach any cell, since
inspection reads admit deep paths. A binding is resolved at attach against the
`Build` with [did-you-mean](#g-did-you-mean) (the offending name plus the list-in-hand it should
have matched), and compiled to one gather, the output half of the binding
interface ([§11.6][s11-6]). `map_output` therefore receives a labeled NamedTuple ([§11.6][s11-6])
instead of performing its own path lookups. A model substitution that breaks a
binding therefore fails at attach, not with silent garbage on the wire. Attach
refuses such a binding with `ReadBindingUnresolved` ([D-130][d-130]). An exporting logger
treats field-handle signals specially. It skips or summarizes them.

An output device's read of the snapshot is inspection ([§13.5][s13-5], [D-083][d-083]). It is
human-facing, with no effect on run semantics. It is observation of the same
sort as the log retaining the full table and the GUI's deep-reading panels.
Every cell is reachable, because the table is public throughout ([§8.3][s8-3]).

A binding chooses its side ([D-129][d-129]). A deep path is an *inspection* read. It
makes zero promises, gives free access, and is right for looking at *this*
build. An exported output face, spelled `get_face(name)` ([§14.4][s14-4]), is an
*integration* read. It is named, curated and meaning-stable under substitution,
and right for consumers that outlive the build they were configured against.
What makes a face meaning-stable is writer-independent semantics ([§11.4][s11-4], [D-045][d-045]).

The choice matters because of drift. Attach validation converts *structural*
drift to loud errors on both sides ([D-083][d-083]). Only faces protect against
*semantic* drift. In semantic drift, a substituted aircraft publishes the same
path at the same type with a different meaning, such as a center-of-gravity
velocity under a name read as body-origin velocity. Nothing else can protect
against it, because meaning is not in the schema.

Semantically generic consumers should therefore bind faces ([D-083][d-083]). A visualizer
needs pose, and every aircraft has one. Aircraft families should export the
conventional surface such consumers need, a library/migration deliverable (the
migration outline companion). Wrapper types make face semantics structurally
checkable. An example is `VelocityData`, an illustrative wrapper type, with its
`v_eb_b` defined *at the type* as body-origin velocity. A bare vector does not
wire, and wrapping the wrong quantity is a deliberate lie, not a drift.

### 11.3 Inbound: root inputs, claims and the frozen roster

The [periphery](#g-periphery) (everything outside the loop that exchanges data with it) writes
into a running model through its [root inputs](#g-root-input) (the root component's own input
faces) alone. The periphery's writers include [devices](#g-device) (any attached participants
in the periphery). Each root input has at most one writer at any time, and the
assignment of root inputs to writers is fixed for a whole run, because the
[roster](#g-roster) (the list of attached device entries) is frozen per run. The section's
parts, in order, cover root inputs, exclusivity and claims, write surfaces and
claim sources, the harness writer and the layout, root-input initial values, the
frozen roster, device identity and admission, device death, and mid-run readers.

#### Root inputs

The [write surface](#g-write-surface) is the set of faces the entries of a writer's [batch](#g-batch) (its
staged set of writes, applied whole at the next drain) may reach. Its members
are root inputs. A root input *is* the root [component](#g-component)'s own input [face](#g-face), an
assembly's `input_wires` key or a primitive's `u_types` key ([§8.2][s8-2], [§8.6][s8-6], [D-208][d-208]).
A component is the unit of modeling, and a face is the name a port wears on its
component's boundary. A root input is routed inward to consumers and produced by
no component. At every non-root level an input face is fed by the parent's wire,
and at the root there is no parent. No dedicated vocabulary is needed.

A root input is usefully read as the output face of the one producer the build
never sees, the periphery and the services. On that reading, root-input
exclusivity (below) is that producer's one-writer right, and the totality
([§14.6][s14-6]) is its completeness obligation.

Root inputs are sources to the build-time ordering, and they are constants
within a [frame](#g-frame) (one iteration of the loop). They are the *only* thing the
periphery may write ([D-031][d-031]). The GUI reaches them through port resolution
([§11.7][s11-7]), and control commands are not writes ([§12.1][s12-1]). Devices, mappings, the
[trace](#g-trace) (the primary record of a session) and the GUI write path address root
inputs by face name ([§8.6][s8-6]). Structural slash paths never reach the periphery's
writes. The write side speaks the names of the root's [contract](#g-contract), the interface
the root component declares, and no others ([D-129][d-129]). The read side chooses per
[binding](#g-binding) (the value passed at `attach!` that makes a device framework-legible).
It uses slash paths in inspection reads, and face names in integration reads and
in service reads ([§11.2][s11-2]/[§13.5][s13-5]/[§14.4][s14-4]).

#### Exclusivity and claims

**Root-input exclusivity permits at most one writer per root input at any time**
([D-044][d-044]). A device [claims](#g-claim) its root inputs (stakes them as faces it may write) at
attach, and claiming an already-claimed root input is an attach-time error.
Detaching releases the claims. A released root input's GUI widgets are live
again from the next run ([§11.7][s11-7]). Exclusivity replaces any cross-device conflict
*policy* ([D-044][d-044]), such as attachment-order precedence at the [drain](#g-drain) (the
frame-top swap that applies staged device writes to the root inputs). Per-device
[staging cells](#g-staging-cell) (where each device's pending batch waits between drains), the
compare-and-swap (CAS) merge and the atomicswap drain all stay. They serve
atomicity and [coalescing](#g-coalescing) (keeping one pending batch per device), not
arbitration.

Exclusivity holds because a second live writer on one root input makes the
applied value a timing artifact, as the worked example in [§11.4][s11-4] shows. The usual
pair is a stream and its mirror, a joystick axis and the GUI slider showing it.
Claiming the stream settles that pair with no concurrent writing.

A claim is what a device *may* write, not what it will. Data-dependent
write-sets are ordinary. A UDP/JSON peer writes whichever subset of faces the
incoming message names, and `map_input` is arbitrary user code the framework
never inspects. Such a device therefore claims the binding's enumerated allowed
set, the faces the binding table lists, whether or not any given batch touches
them. The claim is registered at attach exactly as a joystick's is. A broad
claim costs liveness. Every enumerated face is claimed for the device's whole
attachment, so the [derived-liveness](#g-derived-liveness) rule (GUI widget liveness, baked once at run
start, [§11.7][s11-7]) renders the GUI's widgets read-only even on faces the peer never
writes. Narrow the binding to narrow the claim. The enumeration *is* the
interface.

#### Write surfaces and claim sources

Every writer has a write surface, and the periphery enforces it. **A batch entry
reaches a root input iff the named face is inside the writer's surface**
([D-044][d-044]). Anything else is discarded with a runtime warning ([§13.2][s13-2]). Because
surfaces are static per run under [the roster freeze](#g-the-freeze) (attach and detach only
while stopped, below), enforcement runs entirely at *staging*, the earliest
site, on the writer's own task. The drain performs no checks at all.

**Every device's surface is its claim set, and a claim set has two sources**
([D-174][d-174]):

- A *returned* claim is enumerated by the binding. The binding declares
  `is_input(b) = true`, `claims(b)` ([§11.6][s11-6]) is called once at attach, and what
  it names is staked. Such a claim is static for the attachment and exclusively
  its own, since the attach-time exclusivity check keeps claims disjoint. It is
  binding-bounded even where no one else is involved. A mapping that has drifted
  onto an unenumerated face is a diagnosable anomaly (`OutOfClaimEntry`), never
  a silent write, claimed or not. An enumeration naming a face outside the
  root's input faces is refused at attach (`AttachUnknownFace`, [D-216][d-216]).
- A *computed* claim is computed by the framework at attach, when the binding
  declares `is_greedy(b) = true` ([§11.6][s11-6]). It is all root-input faces minus the
  union of the rostered claims, the unclaimed complement at that instant. This
  is the standard GUI binding's claim ([§11.6][s11-6]), everything unclaimed, without
  configuration. It is disjoint from every incumbent claim by construction, so
  exclusivity validates trivially and nothing downstream can tell the two
  sources apart. A complement that comes out empty is legal and useless.
  `attach!` records an `EmptyGreedyClaim` warning for it ([§11.6][s11-6]).

There is one claim mechanism with two claim sources. The source is exhausted at
the attach point. Past it, validation, roster-entry storage, the compilation of
shape, shim, merge and scatter ([§11.4][s11-4]), the drain, the trace ([§11.5][s11-5]) and
detach-releases-claims treat a computed claim exactly as a returned one ([D-174][d-174]).
The GUI is therefore not an exception but an ordinary enumerated writer whose
enumeration the framework performed. Attaching the [greedy claimant](#g-greedy-claim) (the device
holding the computed claim) last is the idiom ([D-192][d-192]). Its computed claim is
taken at the attach point and never recomputed, so attachment order is decisive
by design.

Opportunistic writing by autonomous devices does not exist ([D-044][d-044]). A device
that wants a face enumerates it, and greediness is an explicit declaration,
never a default. Cross-writer races on one root input therefore cannot arise
structurally, because every claim is exclusive, whatever its source. That is
what keeps drain order a diagnostic fact ([§11.4][s11-4]) and lets a drained GUI value
simply stay ([§11.7][s11-7]).

#### The harness writer and the layout

One framework-owned remainder sits beside the roster, the [harness writer](#g-harness-writer) (the
framework-owned write path `stage!(sim, …)`). It is an entry point with no task
of its own, the harness/REPL write path ([§12.6][s12-6], [D-096][d-096]), called as follows.

```julia
stage!(sim, "face" => value, …)
```

It stages a batch from any task, the [calling task](#g-calling-task) (the task that invoked `run!`)
included ([D-200][d-200]). Its always-present staging cell, the [harness cell](#g-harness-cell), is drained,
traced and surface-checked exactly as any device's.

The harness writer's surface is the one thing in the design that is *derived*
rather than claimed ([D-174][d-174]). It is the unclaimed complement, the faces no
rostered device speaks for. That surface is recomputed at every stopped-sim
roster change, and is therefore as fixed within a run as any claim set. A
`stage!` write to a claimed face is rejected at staging (`ClaimedFaceEntry`,
naming the incumbent, [D-174][d-174]). A rostered greedy claimant empties that surface
outright. The greedy claim is itself a rostered claim, so the complement it
leaves is empty and every `stage!` in such a session is rejected that way
([D-192][d-192]). There is one edge case, a batch staged while stopped whose face a
subsequent `attach!` claims, and the attach itself renormalizes it away ([§11.4][s11-4]).

**The harness cell drains last**, by convention ([D-096][d-096], [D-174][d-174]). With every
surface disjoint the order is unobservable, so the rule exists to make the trace
read the same way every time, not to arbitrate anything.

**The periphery resolves root faces against the [activation](#g-activation)'s cell layout alone**
([D-261][d-261]). An activation is the build's typed products at a scalar type. The
layout carries the root faces in structure order with their [probe](#g-probe) values (the
real values the build evaluates each user function with), beside the address
table, so both of the build's lookup families, [schema and layout](#g-schema-vs-layout), read it there,
and writers, claims and the harness compile against it. The services take their
schema from the `Build` itself ([§14.3][s14-3]). The periphery never needs an authored
fact the layout does not hold.

#### Root-input initial values

**The init/trim services own root-input initial values** ([D-047][d-047]). Input
declarations are bare types ([§8.2][s8-2]) and carry no defaults, yet a root input unfed
by any device must hold a defined value from the first frame. No declaration
constant could own that value, because the trim service writes root-input values
it *solved for*, such as throttle and elevator. Export-entry defaults were
rejected ([D-047][d-047]). `init!` establishes every root input, and the [trace header](#g-trace-header)
(the trace's fixed preamble, a checkpoint `init!` takes) captures the result.
Totality is enforced pre-write at every complete-world application, namely
`init!`, trim setup and trim commit ([§14.6][s14-6], [D-149][d-149]).

#### The frozen roster

**The roster is frozen per run** ([D-106][d-106]). Attach and detach are stopped-sim
operations. `attach!`/`detach!` are legal in the `built`, `initialized` and
`stopped` states ([§12.6][s12-6]) and an error while `running`. That error is
`ServiceLifecycle` ([Appendix C][sC], [D-108][d-108]), the same kind that gates the [§14][s14]
services. The list is exhaustive. An `errored` simulation refuses both with the
same kind. A roster change configures the next run, and an errored simulation
has none ([§13.6][s13-6], [D-232][d-232]). The prohibition includes pause. Pause is a
control-plane state *inside* a run ([§12.1][s12-1]), and a surface that could move while
paused would move mid-run.

The roster (roster entries, claims, attachment order) is therefore a plain
immutable value. The loop reads it once at `run!`, and nothing republishes it
([D-087][d-087]). The partition of the root face set into per-writer surfaces plus the
harness remainder is a static, inspectable fact of the run ([D-106][d-106]). It is
printable before the run starts and valid until it ends (printable like the face
routes, [§13.7][s13-7]). Attachment order is the roster's own order. The trace still tags
each record with a stable device id (described below), never a roster index,
because ids read across runs, where the roster does change ([D-087][d-087]).

Attach validation, claim registration and the staging-shape compilation ([§11.4][s11-4])
all run at the attach point. That makes `attach!`/`detach!` stopped-sim
configuration operations beside `init!` and trim ([§14][s14]). While a simulation runs,
its configuration (build, roster, claims, surfaces) is immutable. The mid-run
mutation doctrine ([§12.5][s12-5]) extends to its final form. The running periphery
stages writes and issues control commands, *and nothing else changes* ([D-031][d-031]).

#### Device identity and admission

Identity is the device instance. The same object (`===`) may occupy at most one
roster entry. Two instances of the same type, two joysticks say, are two
devices. The stable device id the trace, heartbeat and diagnostics speak is
assigned at `attach!`, monotonic per `Simulation` and never reused. It lives
exactly as long as its roster entry, across runs (roster persistence, [§12.6][s12-6]) and
until `detach!`.

Admission is a two-part check at the attach point, in order:

```
# each line: the condition that rejects the attach → the diagnostic it raises
identity   this instance is already rostered
               → AlreadyAttached      (names the entry and its binding)
claims     face exclusivity: this device's claim set meets a rostered claim
               → ClaimConflict        (names two distinct devices)
```

An already-rostered instance is rejected rather than silently absorbed, because
rebinding has an explicit spelling, `detach!` then `attach!`, both legal at any
stopped-sim point. Either a silent no-op or a silent rebind would discard a
binding the caller handed over. Running the claims check after the identity
check is what makes `ClaimConflict` always name two *distinct* devices, never a
device colliding with its own earlier attachment. Detaching a device the roster
does not hold is an error (`NotAttached`, [D-215][d-215]).

#### Device death and orphaned claims

**Device death does not detach** ([D-106][d-106]). A mid-run crash, voluntary exit or
unplug ([§11.6][s11-6], [§12.4][s12-4]) ends the device's *task*. The staging cell stops filling,
the heartbeat ([§12.2][s12-2]) shows the death by name, and the roster entry, claims
included, persists to the end of the run. The [orphaned claims](#g-orphaned-claims) (the claims of a
device whose task died mid-run) are the accepted cost of the freeze. The
device's root inputs hold their last-drained values and no other writer inherits
them. The read-only widgets render the orphan visibly, never mysteriously
([§11.7][s11-7]). Recovery is between runs. It takes a stop, a `detach!`, and either
`init!` (fresh trajectory) or `replay!`-to-end then `run!`, which continues from
the interrupted [boundary](#g-boundary) ([§12.7][s12-7]), a published consistency point. The death is an
anomaly, not a surface event.

#### Mid-run readers

One deliberate asymmetry is on record as a [guarded addition](#g-guarded-addition) (a capability the
design admits but does not build). A pure reader claims nothing. Examples are a
binding declaring `is_output` alone ([§11.6][s11-6]), a visualizer or a telemetry tap.
Attaching one mid-run would therefore move no writer's surface ([D-106][d-106]). A
dynamic reader list would touch only [§12.3][s12-3] wakeups, the heartbeat and the
shutdown join, never the drain. The addition is cleanly severable from the
freeze should the join-a-running-session workflow find a customer. The [§12.2][s12-2]
thread-budget warning runs once per run, at `run!` or `replay!`, against the
frozen population.

### 11.4 Inbound: per-device staging, representation and the drain

A [device](#g-device) (any attached participant in the periphery) produces writes on its own
task, whenever its hardware or its peer hands it a datum. The loop consumes them
at the top of each [frame](#g-frame) (one iteration of the loop). Between those two rates
something has to hold each device's pending writes and hand the loop a value it
can apply. That something is the [staging cell](#g-staging-cell) (the per-device atomic holding
place for pending writes), a compound term distinct from a table cell ([D-121][d-121]).
Unlike a table cell it is mutated frame by frame, outside the table's
publish-once discipline. This section first fixes the [coalescing](#g-coalescing) policy (the
compare-and-swap, or CAS, merge that keeps one pending set of writes per device)
under which a device writes into its staging cell. It then fixes the doctrine
for staged values, the mappings that produce them, the shape the staging cell
holds, the sites of the staging diagnostics, and the [drain](#g-drain) (the frame-top swap
that applies staged device writes to the root inputs) that empties it. A worked
example closes the section.

#### The coalescing policy

**Staging keeps one atomic staging cell per attached device** ([D-024][d-024]). **Staging
has one coalescing policy, CAS merge, newest wins per face** ([D-104][d-104]). A device's
staging cell has a single writer, its own device task. It holds that device's
latest pending [batch](#g-batch) (a set of writes applied whole at the next drain). Each
write in it targets a [root input](#g-root-input) (the root component's own input face). Staging
merges the incoming batch into the pending one. Untouched [faces](#g-face) (the names ports
wear on their component's boundary) survive, and re-staged faces take the newest
level. That is the per-face zero-order hold (ZOH). For a device's staging cell,
the CAS can fail only because a drain intercepted the old batch, so the retry is
bounded. The failure case is precisely correct as well. Intercepted writes are
already applied, and must not be re-staged. The [harness cell](#g-harness-cell) (the always-present
staging cell of the harness writer) is the exception to the single writer, since
several tasks may stage into it concurrently, and a CAS that fails because
another stager merged first retries the same way ([D-200][d-200]).

Merge is the *only* policy because it is always correct. A *complete* writer
covers every face in every batch it stages. A joystick delivering its full
write-set every poll is the type case. For such a writer merge and overwrite are
provably the same operation, which makes overwrite a degenerate fast path rather
than a second semantics. A *sparse* writer stages only what was touched. The GUI
and a JSON peer are sparse writers, and under overwrite they lose writes
silently instead. Under overwrite, a pending `flaps` edit is clobbered by an
unrelated `gear` message, undrained and undiagnosable. The worked example at the
end of this section works that hazard through. A user-facing overwrite opt-in
(`complete(binding)`) is closed ([D-104][d-104]).

#### The levels doctrine

The levels doctrine says that **staged values are levels, never deltas**
([D-024][d-024]), as in `press_count = 17`, never `presses += 1`. Levels are idempotent
and survive coalescing. Edge logic follows the levels doctrine, and button edges
ride as monotonic press counters, which devices stage. Accumulators (trim
offsets, flap detents) are model state, not mapping state ([D-045][d-045]).

#### Mappings and conditioning

**Mappings run on the device task** ([D-024][d-024]). Where FlightCore, the predecessor,
had `assign_input!(mdl, mapping, data)`, the framework has the pure
`map_input(data, mapping) → batch`. User-extensible code thereby never executes
inside the loop's frame, and the [trace](#g-trace) (the primary record of a session)
consists of root-input-level batches.

**Mappings are binding data, not shaping code** ([D-045][d-045]). A mapping is a
declarative table. It maps axis/button → root input, plus per-axis conditioning
parameters (deadzone, expo strength). The shipped `TableBinding` applies those
parameters in its generic `map_input` on the device task. `TableBinding` is the
shared pure helper, with an owner ([§11.6][s11-6]).

A rule about faces sets where conditioning belongs. **A face's meaning is
writer-independent** ([D-045][d-045]). Faces therefore carry *post-conditioning*
semantics. A GUI slider or a script writes the same command a curved stick
delivers, and running a mouse drag through a deadzone would be absurd. This
GUI-parity test is what places conditioning upstream.

Aircraft-semantic derivation must *not* ride along ([D-045][d-045]). A command fan-out
such as the illustrative `q_ref = q_sf · axis` is the case in point. It is
flight control system (FCS) design and lives in-model, in the avionics.

The trace records post-conditioning levels. Those are exactly what the model
consumed, so [replay](#g-replay) (the ordinary loop, its drain reading the trace) is exact.
The raw stick levels are the known, accepted loss. Re-running a session through
*different* curves is impossible.

#### The staged representation

**The staged representation is fixed per attachment, compiled at attach**
([D-104][d-104]). An enumerated writer's [claim](#g-claim) set (the faces a device *may* write) and
root-input types are both known at attach, because `claims(binding)` ([§11.6][s11-6]) is
read against the root [contract](#g-contract) (the root component's declared interface). So the
framework fixes the staging cell's content type there. **The content type is a
pair of positional tuples over the claim set** ([D-202][d-202]). One is a values tuple,
concretely typed `Tuple{T₁, …, Tₙ}`, and the other a parallel `Bool`
touched-mask. A set mask position means *staged this time*. A clear one means
*not touched*, never "reset". Untouched positions carry placeholder values and
are never read. The mask guards every consumer, so no placeholder ever reaches
the model. The batch is therefore isbits with one concrete layout per writer.
The levels doctrine is untouched, and root inputs only ever receive masked
positions. The writer's [roster](#g-roster) entry, its record in the list of attached
devices, holds the face-name → position schema ([D-104][d-104]).

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

One concrete layout is what makes the frame-top drain compilable. The
alternative carrier, `Union{Nothing, Tᵢ}` per face with the marker riding in the
value, has no such layout. Tuple types are covariant, so each combination of
touched faces is its own concrete type, and applying a batch would specialize at
frame top on which faces it touched ([D-202][d-202]). The mask buys the layout back at
the price of dead placeholders. Those are filled from the declaration's [probe](#g-probe)
values (the real values the build evaluates each user function with), which are
constructible for every declared type and unreachable behind the mask guard.

The consequences are each mechanical. The merge is positional and mask-driven
(the sketch above), so it compiles straight-line, leans on no small-tuple
heuristic, and does not degrade with surface width ([D-202][d-202]). The drain applies
each staging cell through an attach-compiled *scatter*, which maps position →
root-input cell, statically typed, with masked-off positions skipped ([D-104][d-104]).
That scatter is the exact mirror of the compiled output gather ([§11.2][s11-2]).

Authors never build the shape by hand. `map_input` returns face ⇒ value pairs
for whatever the datum touched, and `stage!` normalizes those pairs through an
attach-compiled shim ([D-104][d-104]). The shim does three things. It maps name to
position, converts to the root input's declared type, and sets the mask. It
thereby confines the residual name-shaped dynamism to one framework-owned
conversion on the task that stages, at the point where wire-shaped data becomes
system-shaped data. Author-built total tuples are rejected as a padding form,
the same disease [D-074][d-074] and the handler return law refuse ([D-104][d-104]).

A device with a [greedy claim](#g-greedy-claim) (the unclaimed complement, computed by the
framework) needs no special treatment here ([D-174][d-174]). Its claim was computed at
the attach point, and by the time shapes are compiled it is an ordinary claim
set ([§11.3][s11-3]). The GUI's staging cell is compiled exactly as a joystick's.

The harness cell gets the same treatment ([D-174][d-174]). Under the [roster freeze](#g-the-freeze)
(attach and detach as stopped-sim operations) its derived surface, the unclaimed
complement, is as static as any claim set, so it too is compiled to a positional
shape. That shape is recompiled at each `attach!`/`detach!`, both stopped-sim
points, and it carries the same shim, merge and scatter. Being always present,
the harness cell gets the compilation unasked. It is also the one staging cell
whose shape the framework derives rather than receives.

All staging cells share one representation and one mechanism. The name-keyed
dynamic path does not exist, and no face name is ever resolved inside the loop's
frame.

The recompilation has one edge case. A pending harness batch staged *before* a
stopped-sim `attach!` may hold the old shape, or may name a face the new claim
covers. The attach renormalizes that batch. It is reshaped, and newly-claimed
faces are discarded with `ClaimedFaceEntry`. So the run always starts with
staging cells matching the run's schemas.

#### Diagnostic sites

Diagnostic sites follow the compilation, every one of them to staging ([D-044][d-044]).
Face-name validity, surface membership and value convertibility are all static
facts of the run. Every check therefore runs in `stage!`'s normalization, on the
writer's own task. A device's out-of-claim face has no position in the schema
and is rejected with `OutOfClaimEntry`. Staging is an earlier, better-attributed
site than the drain for that rejection, and the kind and [payload](#g-payload) (the structured
data a diagnostic carries beside its kind) are the same either way. The GUI is
included, its claim being an ordinary one. A *harness* write to a claimed face
is rejected the same way, with `ClaimedFaceEntry` naming the incumbent device
([D-174][d-174]). And a value that cannot convert to its root input's declared type is
discarded with `EntryTypeMismatch` ([Appendix C][sC], [D-105][d-105]), at the same spot.

Nothing remains at the drain. With surfaces frozen for the run, there is no fact
only the drain can know, and the drain is pure application ([D-106][d-106]).

#### The drain

At frame top **the drain takes each device's staging cell with one
`atomicswap(cell, nothing)`** ([D-024][d-024]). The swap is an indivisible take, so there
is no lost-write window. Each taken staging cell is then applied through its
compiled scatter, in attachment order ([D-024][d-024]), the harness cell last ([§11.3][s11-3]).
Attachment order is retained as a deterministic application order. Under
root-input exclusivity, cross-device writes to one root input cannot arise, so
the order matters only for diagnostics ([D-044][d-044]).

Which *frame* a write lands in remains wall-clock reality. What the drain
guarantees is that the frame's outcome is a pure function of the drained
batches.

Because the roster is a fixed value at `run!`, the drain is fully compilable
([D-106][d-106]). The staging cells and their scatters form a heterogeneous but *known*
tuple the frame function can specialize on, which means zero dynamic dispatch at
frame top. That is the same per-configuration compile trade the [executor](#g-executor) (the
compiled form of the stage execution order, [§9.7][s9-7]) already makes, now incurred
only at stopped-sim attach points. The specialization is an implementation
freedom the freeze creates, not an obligation ([D-106][d-106]). Iterating a roster array
costs a handful of dispatches per frame and remains acceptable.

Two shapes were rejected, per-input atomic cells and a shared lock-free batch
stack ([D-024][d-024]). The worked example below examines both.

#### Worked example: filter, joystick and GUI

This worked example is the exercise that selected per-device cells. It produced
two things for [§11.7][s11-7]: the active-widget contract, which [§11.7][s11-7] rejects ([D-026][d-026]),
and the [port](#g-port)-resolution answer to panel reuse. A port is the addressable unit of
the model. The setup is a first-order filter with root inputs `u_cmd` and `τ`, a
fictitious 100 Hz single-axis joystick streaming a slow ramp onto `u_cmd` (a
complete writer), and a 60 Hz GUI with sliders for both root inputs (a sparse
writer). [Boundaries](#g-boundary) (published consistency points, where [snapshots](#g-snapshot) go out) run
at 50 Hz, at pace 1. The interference on `u_cmd` is the point.

Three candidate staging shapes were on the table: *per-input cells*, a shared
*batch stack*, and *per-device cells*. The user-level listing came out identical
across all three, so ergonomics cannot discriminate between them. Behavior under
a concrete interleaving did.

Root-input exclusivity rules out the very contest the setup builds. Under
root-input exclusivity ([§11.3][s11-3]) the contested-`u_cmd` scenario cannot arise,
because a second writer on `u_cmd` is an attach-time error. What the test
settles is therefore the cell *shapes*: atomicity, coalescing, pause behavior
and the [peek](#g-peek) rule (a widget shows its own pending write if any, else the
snapshot value). Its conflict-precedence comparison and the active-widget
stage-every-pass contract ([§11.7][s11-7]) describe a contested-input world the design
does not have. The findings below are read under that scope.

- *Drag against the stream.* The user grabs the `u_cmd` slider while the
  joystick streams. Under per-input cells and the batch stack, each frame's
  conflict resolves by last-store/last-push wall-clock order ([D-024][d-024]). With 16.7
  ms renders against 10 ms polls, the applied input alternates between drag
  value and ramp on the cadence beat, the filter visibly wobbles, and the
  pattern differs run to run. The trace replays any given run exactly, but the
  behavior is still a timing artifact. Under per-device cells the GUI stages in
  every drag frame, since it renders at least once per 20 ms frame and the
  active-widget contract stages on every pass. The GUI therefore wins every
  drain by attachment order. That win is a clean, deterministic override for
  exactly the grab duration. The same user code gives qualitatively different
  physics.
- *Edits while paused.* Under per-input cells, the still-polling joystick
  overwrites the user's `u_cmd` edit about 10 ms later ([D-024][d-024]). The knob visibly
  snaps back and the edit never applies. Under the batch stack, the edit is
  buried under newer pushes, and the pending chain grows at the polling rate,
  about 10³ nodes per 10 s pause, with every peek walking that chain ([D-024][d-024]).
  Under per-device cells, the `u_cmd` edit holds in the GUI's own cell across
  the pause, and the knob keeps the edit by the [§11.7][s11-7] peek rule. That edit
  merges with the `τ` edit, which is the sparse-accumulation case, and applies
  at the un-pause drain. It holds for one deterministic frame before the
  joystick reclaims the root input. That one-frame application is the honest
  semantics of one-shot editing a streamed input. The uncontested `τ` edit works
  under all three shapes.
- *Corrections the exercise forced.* The sparse-writer lost-write hazard is
  specific to one-cell-per-device layouts. Per-input cells cannot lose
  independent-input writes, so the CAS merge is per-device cells' antidote, not
  a general need. And the batch stack's conflict order is temporal, not an
  attachment-order policy ([D-024][d-024]).
- *Discoveries.* There were two: the active-widget contract, and the
  port-resolution answer to panel reuse ([§11.7][s11-7]). The second came from asking how
  the filter's panel survives the filter becoming an embedded [component](#g-component) (a unit
  of modeling) with `u_cmd` driven by another component.

### 11.5 Inbound: the input trace

The input [trace](#g-trace) is the sequence of [drained](#g-drain), [device](#g-device)-tagged [batches](#g-batch) per [frame](#g-frame). A
device is any attached participant in the periphery, and a batch is its staged
set of writes. A frame is one iteration of the loop, from drain to publication.
The drain is the frame-top swap that applies staged device writes to the root
inputs. The trace extends the determinism ([§10.7][s10-7]) end-to-end. [Replay](#g-replay) re-runs the
ordinary loop on a recorded input trace. Replaying a recorded interactive
session reproduces the trajectory bit-identically ([§2.4][s2-4]), with staging fed from
the recording, so no device or mapping feeds the inputs ([D-218][d-218]).

#### The record format

**The trace retains every batch sparse, in one record format** ([D-176][d-176]). At the
drain each drained [staging cell](#g-staging-cell) is scanned. A staging cell is the per-device
holding place where a device's pending batch waits between drains. Its masked
(touched) batch entries are recorded as (position ⇒ value) pairs, against the
writer's [face](#g-face)-name → position schema in the `schemas` list (below). A face is
the name a port wears on its [component](#g-component)'s boundary. A component is the unit of
modeling, a leaf or an assembly. The recording is an O(surface-width) scan and
one small allocation per drained batch, plus the values boxed into that
allocation.

The rule is uniform because the *width* of a [claim](#g-claim) (the set of faces a device
*may* write) is a fact about one [binding](#g-binding), not about a category of writers. A
binding is the value passed at `attach!` that makes a device framework-legible.
A [greedy claim](#g-greedy-claim) is the unclaimed complement the framework computes at attach
([§11.3][s11-3]). It is enumerated and as wide as the root [contract](#g-contract) (the root's declared
interface), so keying retention by claim source is rejected ([D-176][d-176]). Every
consumer then handles one format instead of two. There is one record format at
the trace's edge, no per-record format flag, one decoder in the edited-inputs
what-if (replay with edited inputs), in disk serialization and in human
inspection, and one inverse conversion in replay. That work is paid once, up
front, off the loop ([§12.7][s12-7]). The conversion site is the drain and not the
staging shim, because the drained tuple is the *coalesced* truth. A shim-side
sparse log would need its own merge.

The format's costs are recorded rather than argued away. On the wide writers the
conversion is what keeps the trace honest. A tuple as wide as the unclaimed
surface carrying one edit would otherwise make trace size track surface width
rather than information. At hundreds of faces, render-rate dragging would
inflate the trace past the two-orders-below-the-log budget that justifies
trace-on-by-default ([D-029][d-029]). On the dense component the conversion costs about
2×, a position beside every value where the positional tuple carried the value
alone. That changes no order of magnitude, and it leaves the budget ([D-029][d-029])
standing for every writer at once.

The allocation is of the same sort the retention carve-out ([§9.8][s9-8]) already
admits. Per [boundary](#g-boundary) (a published consistency point) it is smaller than the
[log](#g-log)'s [snapshot](#g-snapshot). The log is the retained sequence of published snapshots. A
snapshot, the immutable per-boundary publication, is the carve-out's standing
occupant and the one qualified exception to retains-what-was-already-allocated.
The decision is reversible as pure implementation. The conversion is lossless in
both directions, so verbatim retention could return as a per-record storage
optimization if a marathon-session measurement ever asks for it. Such a return
would leave the record semantics, the header and the replay path exactly as they
are.

#### The header

The [trace header](#g-trace-header) is the trace's fixed preamble. A [checkpoint](#g-checkpoint) is the `Model`'s
state at a frame top as one value. **The header is the checkpoint `init!` takes
at the end of [boundary zero](#g-boundary-zero)** (the initialization boundary at `t₀`), after the
first snapshot is published ([§12.6][s12-6], [D-274][d-274]). A checkpoint holds the flat buffer
`x`, the `s` and `m` stores, the whole [signal table](#g-signal-table) (the collection of cells
holding every produced signal), the guard [priors](#g-prior), `t` and `t₀`, the frame and
boundary counters, and the fingerprint (the structural layout) and the
[deployment](#g-deployment) ([D-319][d-319]). The deployment is the scalar-free artifact the grid
parameters fix. A prior is an event's stored predicate sample from the previous
boundary. The [executor](#g-executor)'s clock holds `t` and `t₀`, and the [`Run`](#g-run) (the state one
run owns, a `Simulation` field) holds the frame index and the boundary ordinal
([D-317][d-317]). The executor is the compiled form of the stage execution order. The
header holds the stores and the cells of the [root inputs](#g-root-input) (the root component's
own input faces) as values, never the sparse authored overlay. Replay must
survive edits to declared defaults, the primary-data doctrine ([D-038][d-038]).

An illustrative unfed root input such as `mixture = 0.5` never appears in any
batch, so replay is broken without the root inputs ([D-047][d-047]). The init/trim
services own root-input initialization ([§14.6][s14-6]), and the checkpoint's table holds
the values they wrote. The fingerprint and the deployment are the parts of the
header replay compares rather than restores ([§12.7][s12-7]).

The deployment comes from [§9.2][s9-2]. It carries `Δt_base`, `h`, `N_base`, the
algorithm identifier, `localization_tol`, `localization_budget` ([§10.4][s10-4]) and
`firing_budget` ([§10.6][s10-6], [D-254][d-254]). The fingerprint is the store layout and the
root-input faces the [`Build`](#g-build) (the artifact `build(world)` produces) fixes. It
also holds what a copy by position relies on, namely each component's `x` type,
every cell's address with its type, and the event list in the order of the
priors. Both are taken at the same instant as the state. The deployment holds no
policy ([D-255][d-255]). `t_end` and `ignore_stop_requests` are keywords of each advance
([§13.5][s13-5], [D-316][d-316]). Only the terminating advance's policy explains the stop, so the
[termination record](#g-termination-record) (the stopped-sim value naming how the run ended) carries that
one.

The trajectory depends on the deployment exactly as it depends on the stores
([§2.4][s2-4]). The `Deployment` constructor ([§9.2][s9-2]) sits outside the `Build`, and the
checkpoint carries the clock, `t₀` included ([§14.5][s14-5]). A header without them could
therefore not back the bit-identity claim ([§2.4][s2-4], [§12.7][s12-7]). The header is also what
the artifact's [run metadata](#g-run-metadata) names, its `Deployment` and `t₀` ([§13.5][s13-5],
[Appendix B][sB]). A checkpoint is the one full-state capture, taken by `init!` for
the header and by `checkpoint(sim)` on demand ([§12.6][s12-6], [D-274][d-274]). The header is the
other half of what "given the initial state and the trace, the log is
recomputable" (below) requires.

#### The `Trace` value

**`Trace` is that fixed header plus two append-only lists**, `schemas` and
`batches`, and its length ([D-255][d-255]). A trace records a `Simulation`, which runs
only a `Model{Float64}`, so `Trace` takes no scalar parameter ([D-317][d-317]). The
header is written once, by the door that builds the run (`init!`, `restore!` or
`replay!`, [§12.6][s12-6]), and never again, which is what makes it an artifact. The
lists grow in place, the batches at every drain and the schemas at every change
to the [roster](#g-roster) (the immutable list of attached devices). The length is the frame
index of the last drain on the live trace ([D-217][d-217]), frozen into the value
`trace(sim)` hands back. It advances at the top of each drain, and the frame
ordinal every record of that drain carries is this frame index ([D-260][d-260]). Under
`init!` that is the number of drains since the header was taken. A trace that
`restore!` opens starts at the checkpoint's frame, so its records keep the
trajectory's own frame indices ([D-274][d-274]). A recording whose last frames drained
nothing still ran them, and every advance in `:replay` is capped at the
recording's last frame ([§12.7][s12-7], [D-218][d-218]).

Each writer's face-name → position schema lives in the `schemas` list.
Positional records are meaningless without it, and replay does not reconstruct
claims ([§12.7][s12-7]). **The list only grows** ([D-217][d-217]). `attach!` and `detach!` push
the current writer set onto it in place ([D-255][d-255]). They do so because a roster
change between advances ([§12.6][s12-6]) recompiles the [harness writer](#g-harness-writer) (the
framework-owned write path `stage!(sim, …)`) and the same face moves position.
Earlier records keep their index, and a record resolves only through its own
schema entry.

#### Recording is on by default

**Trace recording is on by default** ([D-029][d-029]). `init!` builds a fresh trace with
the run under its `trace` keyword ([§12.6][s12-6], [Appendix B][sB], [D-261][d-261]), the trace is
retrievable after the run, and a plain kill switch covers memory-constrained
marathon sessions. The asymmetry that decides the default is that the trace is
*primary* data and the log *derived*. Header plus batches are the *primary*
record. Everything else, the state trajectory included, is derived ([§11.2][s11-2],
[D-038][d-038]). Given the initial state and the trace, the log is recomputable, which is
what bit-identical replay means ([§2.4][s2-4]). An untraced interactive session, by
contrast, is unreproducible, permanently.

The cost supports the default. The trace retains one small sparse record per
drained batch (above), at drain-rate × device-count. That is tens of MB per hour
worst case, two orders of magnitude below the snapshot log. There is no sampling
and no rolling window ([D-029][d-029]).

### 11.6 Devices: one authoring contract, no taxonomy

FlightCore's input/output/GUI trichotomy is lock choreography, not modeling.
With no lock, the protocol the taxonomy encoded has no referent ([D-025][d-025]). A
[device](#g-device) is an attached participant in the [periphery](#g-periphery) (everything outside the loop
that exchanges data with it). A device may be input-only or output-only, and
those are degenerate uses, not framework classes ([D-025][d-025]). A bidirectional
network peer is *one* device with one socket and one lifecycle, not two
framework devices sharing state. The GUI is an ordinary device, the paradigm
one, and it uses every capability of the handle below. Its one genuine
peculiarity, read-modify-write widgets, is not taxonomic ([§11.7][s11-7]).

#### The device handle

Every attached device receives the same handle. The handle carries the two
primitive capabilities, read and stage, plus control access (observe running,
request shutdown) ([D-025][d-025]). Read returns the latest [snapshot](#g-snapshot) (the immutable
per-boundary publication). It can optionally wait for the next [boundary](#g-boundary) (a
published consistency point) first ([§12.3][s12-3]).

Each attached device has a [roster](#g-roster) entry (its record in the list of attached
devices). **A handle outlives its roster entry as an object only** ([D-244][d-244]).
`detach!` retires the roster entry and the compiled writer behind it, but the
caller may still hold the handle `attach!` returned. Its two write primitives,
`stage!` and `report!`, then refuse by name (`DeviceContractMismatch`,
[Appendix C][sC]). A [batch](#g-batch) staged there would land in a [staging cell](#g-staging-cell) that no [drain](#g-drain)
reads. A report would land in a [diagnostic cell](#g-diagnostic-cell) that no [frame](#g-frame) top folds. A batch
is a device's staged set of writes. A staging cell is the per-device holding
place where a pending batch waits between drains. The drain is the frame-top
swap that applies staged device writes to the root inputs. A diagnostic cell is
each writer's bounded ring of diagnostics and its heartbeat. A frame is one
iteration of the loop. Silence is the hidden-bug class this section tolerates
nowhere. The read primitives stay legal, since they read the simulation's shared
state and nothing of the roster entry's ([D-244][d-244]).

#### The authoring contract

A device's type is a user type subtyping the framework's neutral root,
`MyDevice <: AbstractDevice` ([D-177][d-177]). That is one mandatory word, and it costs
nothing, because the periphery has no competing hierarchy to inherit from. What
it buys is `attach!`'s dispatch gate ([D-177][d-177]).

```julia
attach!(sim::Simulation, dev::AbstractDevice, new_binding::AbstractBinding;
        should_abort::Bool = false)
```

`attach!` takes the device with its [binding](#g-binding) (the value that makes a device
framework-legible, described below). Its keyword [`should_abort`](#g-should_abort) (the
per-attachment failure policy) is covered after the loop bodies below.

The framework asks for four functions.

```julia
init!(dev)          # per-run resource acquisition — calling task, before spawn (§12.4)
loop(dev, handle)   # the task body: owns its own wait structure
shutdown!(dev)      # per-run resource release — guaranteed on every exit path
unblock!(dev)       # make a blocked loop return (§12.4)
```

**Of the four functions, only `loop` is mandatory** ([D-366][d-366]). `init!`,
`shutdown!` and `unblock!` are optional hooks, each defaulting to a no-op.
`attach!` refuses a device with no `loop` method (`DeviceContractMismatch`,
[D-216][d-216]).

The framework owns everything around the four functions ([D-102][d-102]). The wrapper is
the shutdown protocol ([§12.4][s12-4]) made structural.

```julia
init!(dev)                                   # its own bracket, pre-spawn (§12.4): a throw
                                             # here is shutdown! + DeviceCrash by name
task = Threads.@spawn try
    loop(dev, handle)
catch e
    report!(entry, DeviceCrash(e))           # §12.4(6): sim continues, device absent
finally
    shutdown!(dev)                           # any exit path: OS resources released
                                             # no dead-marking: task_state shows the end,
                                             # claims stay, §11.3
end
```

#### What `shutdown!` must tolerate

**`shutdown!` must tolerate a partially initialized device** ([D-138][d-138]). The
release guarantee holds on the one path *outside* this wrapper too. The
initialization step ([§12.4][s12-4]) brackets each `init!` ([D-138][d-138]). A device that threw
half-way through acquisition goes straight back to `shutdown!`, so nothing it
did manage to open is leaked. The obligation that follows is "close only what is
open". That is the same defensiveness `shutdown!` already owes the crash path,
where a loop body may die at any point in its own life. `init!` is
correspondingly *not* asked to clean up after itself. The bracket does once, for
every device, what would otherwise be duplicated in each and enforced in none.

**The same tolerance covers a repeated call** ([D-268][d-268]). The wrapper runs
`shutdown!` once on every exit path. When an [operator interrupt](#g-operator-interrupt) (Ctrl-C in an
interactive session) reaches `run!` before its tail, `run!` releases directly,
not through a wrapper, each device it never spawned, advancing a cursor after
each `shutdown!` returns, and retries from where an interrupt cut it ([§12.4][s12-4],
[D-268][d-268]). An interrupt landing between a `shutdown!`'s return and the cursor's
advance repeats that call rather than leak the device, so each such interrupt
adds one call. A `shutdown!` that closes only what is open is idempotent by
construction, so a repeated call costs nothing and is never reported.

**The tolerance also covers a call with no `init!` before it** ([D-268][d-268]). The
initialization step lists each device for release before its `init!` begins, so
that no interrupt can leave an initialized device unlisted ([§12.4][s12-4], [D-268][d-268]). An
operator interrupt landing between the listing and the `init!` therefore
releases a device that opened nothing. A `shutdown!` that closes only what is
open does nothing there, and the call is never reported.

#### The operator interrupt

The wrapper makes one discrimination. **An `InterruptException` is never a
`DeviceCrash`** ([D-132][d-132]). The operator interrupt is a control-plane stop, not a
failure ([D-132][d-132]). The wrapper forwards the control-plane stop. There is no crash
report for what is not a crash, and no `should_abort` consultation, since a stop
is already requested.

#### The author-owned loop body

One device contract means author-owned loop bodies. A framework-owned hook loop
would have to ask each device what it waits on, which is the rejected taxonomy
resurrected as a trait ([D-102][d-102]). Under the author-owned body, every wait
structure is ordinary user code composed from handle primitives. In the
sketches, `T16000M` is FlightCore's type for the Thrustmaster T16000M joystick,
and `UDPInput` is FlightCore's UDP input device type. `Telemetry` is an
illustrative output device type. The sketches map data through the binding's
`map_input` and `map_output`, described below.

```julia
function loop(dev::T16000M, handle)              # timer-driven, full write-set
    while running(handle)
        sleep(dev.Δt_poll)
        stage!(handle, map_input(poll_axes(dev), binding(handle))...)
    end
end

function loop(dev::UDPInput, handle)             # source-driven, data-dependent
    while running(handle)
        datum = recv(dev.socket)                 # blocks; unblock! closes the socket
        is_eot(datum) && return                  # voluntary exit
        try
            stage!(handle, map_input(datum, binding(handle))...)
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
inside its own domain, rather than forcing a select engine into the framework.
Two idioms are author obligations the framework can only teach and diagnose,
never force ([Appendix A][sA], [D-102][d-102]). The author must loop on `running(handle)` and
must make blocking calls interruptible (`unblock!`, or timeouts). A forgotten
predicate check surfaces as `DeviceJoinTimeout` with the device's name. A stall
surfaces as a stale heartbeat ([§12.2][s12-2]). Liveness timestamps ride *inside* the
handle primitives, which store them in the device's own diagnostic cell ([§11.8][s11-8]),
so the framework observes activity without owning the loop.

FlightCore's device hook **`should_close` dissolves** ([D-102][d-102]). A window ✕ or
peer EOT is the loop body returning, which is [§12.4][s12-4](6)'s case. The wrapper's
exit path releases the device's OS resources and consults `should_abort`.
Nothing marks the device dead beyond its record. The task has ended,
`task_state` ([§11.8][s11-8]) says so at the next publication, and its heartbeat goes
stale ([§12.2][s12-2]). A device's [claim](#g-claim) is the set of [faces](#g-face) (the names ports wear on
their component's boundary) it *may* write. Claims and the roster entry persist
to run end (the freeze, [§11.3][s11-3], [D-106][d-106]). The GUI implements the same authoring
contract.

#### The failure policy

**`should_abort` is an `attach!` keyword**, defaulting to `false` ([D-138][d-138],
[D-177][d-177]). It is per-attachment, never a device property. The same joystick is
advisory in one deployment and decisive in another. With `should_abort` clear, a
device's departure is reported and the run continues without it. With it set,
that departure also requests a sim stop ([§12.4][s12-4]). A departure is the loop body
returning, a crash, or a failed `init!`. A hardware-in-the-loop rig attaches its
plant interface with it set, since a run without that device is meaningless.

#### Bad datum versus bug: two classes, two fates

A datum that cannot be mapped for environmental reasons (a truncated datagram,
malformed JSON, an out-of-range field) is a [bad datum](#g-bad-datum), tolerated *in the loop
body* ([D-105][d-105]). The body catches it, stages nothing, calls
`report!(handle, MalformedDatum(cause))` and continues. That tolerance is
bounded by the device's own diagnostic cell (the ring and suppressed counts,
[§11.8][s11-8]; the stream, [§13.2][s13-2]), and what it records is visible next to a live
heartbeat. Any other exception propagates, and the wrapper turns it into
`DeviceCrash` ([§12.4][s12-4]).

The classification is the author's, because only they know their parser.
FlightCore's `InputMappingError` docstring assigned it the same way. What
changes under the author-owned loop is that no framework per-iteration catch
site exists, so the framework's contribution is the diagnostic channel, not the
catch. A marked exception type is not provided ([D-105][d-105]). `report!(handle, …)`
writes device-attributed runtime warnings into that device's diagnostic cell,
the single-writer entry point into the runtime warning stream ([§13.2][s13-2], [§11.8][s11-8],
[D-160][d-160]), and nothing more. It is not a general user-diagnostics channel.
Tolerating everything hides bugs as "device attached, nothing happens".
Tolerating nothing kills a live telemetry link on its first truncated datagram,
and since tasks are per-run artifacts ([D-093][d-093]), kills it for the rest of the run.

#### The binding

A binding is a value subtyping `AbstractBinding`, the second mandatory root. Its
type declares which sides it has and enumerates what each side touches. A
binding is framework-legible by enumeration and opaque in its mappings. The
legible half is explicit methods returning data, called once at attach on the
[calling task](#g-calling-task) (the task that invoked `run!`). The opaque half is called per datum
on the device task by the author's own loop:

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
defaults, so silence is not greediness ([D-177][d-177]). A [greedy claim](#g-greedy-claim) is the unclaimed
complement computed at attach. The computed claim source (the greedy one, [§11.3][s11-3])
is declared or absent.

The framework needs no contract on the datum's shape. The datum travels only
between `loop` and `map_input`, written by the same author. The framework's
structural knowledge comes entirely from the declared traits and the enumeration
methods. Everything enumerable validates at attach. Everything opaque is bounded
at its runtime enforcement point. `map_input` is bounded by the staging checks
([§11.4][s11-4]). `map_output` receives exactly the compiled gather's NamedTuple, and
what it puts on the wire is the peer's business. **`map_input`/`map_output` are,
precisely, conventions of the author-owned loop idiom** ([D-177][d-177]). The framework
never calls them, so they are taught ([Appendix A][sA]) and never checked. A binding
whose loop calls something else by another name is simply a binding with a
different private helper.

**`reads(b)` returns a labeled NamedTuple of [selectors](#g-selector)** ([D-199][d-199]). Selectors are
the closed family of deferred reads ([§14.4][s14-4]). An example is
`(; alt = get_output(…), pose = get_face(…))`. The labels are the binding's own
naming, carried through compilation in declaration order, so the NamedTuple
`map_output` receives is keyed by exactly the names `reads` declared. One
returned value thereby fixes names, order and reads together, under the same
attach-time validation as `claims` ([D-199][d-199]).

The periphery gets roots where [components](#g-component) (the units of modeling) have one. [§8.5][s8-5]
refuses a supertype for [class](#g-class) (a component's primitive-vs-assembly status) for
two reasons, and neither reaches here. First, a component's single-inheritance
slot is *already spoken for* by the domain hierarchies (`AbstractAircraft`,
engine families), while a device's and a binding's are vacant. Nothing else
wants them. Second, a component's class is implementation detail behind its
contract ([§8.5][s8-5]), while a binding's sidedness is its public contract, the one
thing every consumer of it must know ([D-177][d-177]).

#### The conformance check

**Sides are declared, and the obligations they create are enforced both ways**
([D-177][d-177]). `claims` and `reads` have error-throwing fallbacks on the root. A
declared side whose method was never written therefore fails loudly at the
attach point rather than degrading into silence. The attach runs a bidirectional
conformance check over the pair (trait, method):

- `is_input && !is_greedy` ⇒ `claims(b)` is called once and its faces staked.
  The fallback firing here means "you declared an input side and wrote no
  enumeration".
- `is_input && is_greedy` ⇒ the claim is computed ([§11.3][s11-3]), and a `claims` method
  defined for this binding is an error. The two sources are alternatives, not
  layers.
- `is_output` ⇒ `reads(b)` is called and the gather compiled.
- Neither side declared ⇒ attach-time error naming both traits. A binding that
  touches nothing is a configuration mistake, not a degenerate.
- `is_greedy` without `is_input` ⇒ error. Greediness is a *source* within a
  side, and a source without its side is meaningless.
- A *specific* method of `claims` or `reads` defined for the binding type while
  its trait reads false ⇒ error, the converse direction of the same fact. A
  method written and never reached is exactly the drift the check exists to
  catch. Detecting it is one `which` against the fallback method. It is a
  reflection check like the shadowing check of [§8.1][s8-1], an `isdefined`/`!==` pair.
  The `which` detection runs once at a stopped-sim service point, not inside any
  frame.

Every violation in that list reports `BindingContractMismatch` ([Appendix C][sC]). The
report names the binding type, the trait, the method at fault and the direction
(declared-but-missing, or defined-but-undeclared). `gather` against a binding
with no output side reports `DeviceContractMismatch`, the device twin of
`BindingContractMismatch` ([D-216][d-216]).

Declared sides, checked both ways, close the shadowing hole. Under the rejected
alternative, detection by method presence ([D-177][d-177]), a bidirectional binding whose
`claims` was written without extending the framework's generic presented as
output-only and degraded *silently*. That omission is the
`using`-without-`import` trap ([§8.1][s8-1]), one level down. With the side declared,
the absent method has something to contradict. An abstract binding-type
*taxonomy* encoding the sides, optional roots left unenforced, and a declared
`sides(b)` trait returning the side set are rejected ([D-177][d-177]).

#### Greedy claims

`is_greedy` is a claim source, not a device class ([D-174][d-174]). A binding declares
that source in exactly one line, in the open, and past the attach point nothing
tells a greedy claim from a returned one ([§11.3][s11-3]). The standing rejection of
opportunistic writing to unclaimed faces "for any device" is untouched ([D-044][d-044]).

Greediness stays orthogonal to `reads`. A greedy front end may also drive a
compiled output gather. That combination is legal and currently uninstantiated.
Its plausible customer is a narrow-wire interactive surface, a motorized control
board whose detents must be driven back out. The binding stays an `attach!`
argument, never a device field. The same `T16000M` binds differently per
aircraft, and narrowing the binding narrows the claim ([§11.3][s11-3]).

**A second greedy attach stakes the empty remainder** ([D-174][d-174]). The complement is
computed against the roster as it stands. A greedy binding attached after
another has already swallowed everything therefore gets the empty claim. That
claim is legal, being the honest may-write-nothing degenerate below, and it is
useless, which is worth saying out loud. The attach succeeds and records
`EmptyGreedyClaim` ([Appendix C][sC], a warning naming the device and its binding) in
the roster entry's diagnostic cell. `attach!` mutates the roster, so the warning
lives in that state's status and surfaces through the status record ([§11.8][s11-8],
[D-250][d-250]). The log line at return is presentation. That is the one honest reading
of "you asked for what is left and nothing was left".

**Several interactive front ends may be rostered at once** ([D-174][d-174]). A web
console can claim the autopilot faces beside a local GUI claiming the stick
faces. With explicit claims they are simply two enumerated devices, partitioning
the surface rather than sharing it.

The standard GUI binding is a greedy one. It declares `is_input` and
`is_greedy`, stakes the computed claim (everything unclaimed at the moment it
attaches), and defines no `claims` of its own. It declares no `reads` either,
because its read path is the handle's primitive read. The compiled output gather
therefore has nothing to do for it. The same GUI device type is equally
attachable under a binding that returns explicit claims. Greediness is the
binding's declaration, not the device's nature. Every other interactive front
end anyone might want (a web console, a remote panel) has both spellings
available. It can attach with the greedy binding where the GUI would have been,
or with explicit claims beside other front ends.

#### The empty enumeration

The empty enumeration is not a back door. **`is_input(b) = true` with
`claims(b) = ()` stays an honest degenerate**, a device that may write nothing
([D-177][d-177]). Its writes are still binding-bounded, so drift onto any face is
`OutOfClaimEntry` ([D-044][d-044]). There is no privileged category for it to promote
into either. `claims` bodies are ordinary code (the idiom, [§8.5][s8-5]; comprehensions
included), and an enumeration that came back empty by accident stays inert,
exactly as written. The maximal surface is reachable only through the explicit
`is_greedy(b) = true` declaration. The most privileged claim is the hardest to
acquire by accident, and a declared trait is deliberate authorship. For the same
reason, `claims` never returns `nothing` or a sentinel to mean "compute it for
me". The enumeration contract has one meaning and the trait carries the other. A
dual-meaning return would be exactly the ambiguity the declaration vocabulary is
built to refuse.

#### `TableBinding`

`TableBinding` is the one shipped binding type, and it is *data-driven* ([D-045][d-045]).
The framework writes its `map_input` once. A table value (axis/button entry →
face, deadzone/expo parameters) is constructed per device × aircraft pairing,
where configurations are made:

```julia
TableBinding(stick_y  = (face = "elevator", deadzone = 0.05, expo = 0.6),
             throttle = (face = "throttle",),
             trigger  = (face = "brake_count",))       # levels doctrine: a counter
```

A malformed table reports `ArgumentInvalid`, collected over the table's entries
([D-216][d-216]).

`TableBinding`'s generic `map_input` *is* the shared pure conditioning helper
([§11.4][s11-4]), and its owner. The entry tuple rides in the type, so the mapping
specializes per table with no dynamic dispatch. A *code-driven* binding looks
identical to the framework. A JSON telecommand peer whose `claims` returns the
vocabulary and whose `map_input` parses bytes is one. One purity note is taught
in [Appendix A][sA]. Cross-datum state, such as press counters and edge detection,
lives in the device struct, maintained by the loop, and arrives *inside* the
datum. `map_input` stays pure.

### 11.7 The GUI write path: port resolution, peek, staging contract

This section specifies how a GUI widget resolves its [port](#g-port) (the addressable unit,
one declared name) to the [root input](#g-root-input) (the root component's own input face)
behind it, when the widget is live, what it displays and when it stages, and the
framework's half of the panel convention.

#### Port resolution and derived liveness

Panels remain extensions per [component](#g-component) (the unit of modeling, a leaf or an
assembly) in FlightCore's style, such as `GUI.draw!(ctx, ::LowPassFilter)`. They
are discovered by walking the [assembly](#g-assembly) (pure composition, whose component-typed
fields are its children). However, **widgets name the component's own ports,
never root inputs** ([D-026][d-026]). The build-time wiring answers one question
statically and exactly. *Is this port transitively driven by a root input, and
which one?* Every input port has exactly one source ([§6.1][s6-1]), so the resolution is
total, with two outcomes.

- If the port is root-driven within the GUI's [claim](#g-claim) (the set of faces a device
  *may* write), its widget is live. It [peeks](#g-peek) (the GUI display rule, specified
  below) and stages the resolved root input through the GUI's own [staging cell](#g-staging-cell)
  (the per-device atomic holding place for pending writes).
- If the port is component-driven, or root-driven under the claim of another
  [device](#g-device) (any attached participant in the periphery), its widget is a read-only
  rendering. It displays the driven value from the [snapshot](#g-snapshot) (the immutable
  per-boundary publication), visually distinct, with its source ("driven by
  `avionics/throttle_cmd`", the canonical slash form of [§8.6][s8-6]).

This retires FlightCore's dead-slider convention and replaces it with checked
structure. **A widget is live exactly when the underlying input is yours to
command in this configuration** ([D-045][d-045]). The dead slider is the throttle of
`Cessna172Xv1`, the first variant of FlightApps' Cessna 172X model. The engine
panel's slider is visually live and the avionics silently overwrite it every
cycle, so who commands what lives in the user's head. User-commandability is a
wiring decision made where configurations are made. Command-plus-manual-override
is a mux component with a root-wired select. That is explicit structure, not two
writers racing (the same race as the drag phase in the worked example of [§11.4][s11-4],
ruled out the same way). This places one obligation on the GUI. Read-only
rendering is first-class, not an error state, because the author of
`input_slider!` (an illustrative widget function) cannot know at authoring time
whether it will be live ([D-026][d-026]).

Liveness is a [derived property](#g-derived-liveness) (the rule computing a widget's liveness from
wiring and claims), and resolution is transitive ([D-045][d-045]). A widget is live iff
two things hold. Its port's feed chain terminates in a root input, *and* that
root input lies inside the GUI's own claim ([D-174][d-174]) in the run's frozen surface
partition (root-input exclusivity, [§11.3][s11-3]). The feed chain is walked through
[local wires](#g-local-wire) (wires with both ends inside one assembly) and interface connections
across *all* levels, not just the local assembly. The claim may have been
computed from the unclaimed complement under `is_greedy`. It may instead have
been enumerated by a partial-claims [binding](#g-binding) (the value passed at `attach!`,
[§11.6][s11-6]). Such a binding enumerates the claim one [face](#g-face) (the name a port wears on
its component's boundary) at a time. Either way, "live" reads as "inside the
surface I declared for".

The [roster](#g-roster) (the list of attached devices, with their claims) is frozen for a
run, since `attach!` and `detach!` are stopped-sim operations ([§11.3][s11-3]). Under
that freeze, liveness is a static fact of the run. It is baked once, with the
port resolution, when the run starts, and never consulted against mutable claim
state at render ([D-270][d-270]).

There is no per-port "GUI-controlled" marking anywhere. The export chain is the
marking, written by the one author entitled to write it. A component's ports
become GUI-commandable exactly when the assemblies above surface them. The
switch between "driven by its own panel" and "driven by an external provider" is
therefore automatic. `World` is the example assembly of pure composition that
[§8.8][s8-8] introduces. At build time the switch follows the wiring archetype, where a
scripted `World` wires a [scenario component](#g-scenario-component) into the same faces the interactive
`World` exports to root. A scenario component is the home of a sim-time script.
At run start the switch follows roster claim state. Nominally-connected ports
with a GUI *override* channel are rejected ([D-045][d-045]). The honest cost stands.
**Unexported ports are unpokeable** ([D-045][d-045]). FlightCore's poke-any-`u` workflow
deliberately does not survive the visibility rule of the [contract](#g-contract) (the declared
interface of a component, [§8.3][s8-3]).

#### The peek and the staging contract

Under the peek rule, **a widget displays its own pending write if any, else the
snapshot value** ([D-026][d-026]). It peeks its own staging cell only. Another device's
pending write is invisible by design. Its applied value arrives via the snapshot
one [frame](#g-frame) (one iteration of the loop) later, and cross-device peek is rejected
([D-026][d-026]). While paused, staged edits display indefinitely and apply at the
un-pause [drain](#g-drain) (the frame-top swap that applies staged device writes to the root
inputs). Fan-out is consistent for free. Widgets on ports resolving to the same
root input peek the same pending value.

**Widgets stage on interaction events only** ([D-047][d-047]). This GUI staging contract
is [stage-on-interaction](#g-stage-on-interaction) (staging on edit or activation, never per render pass).
Value widgets (sliders, drags) stage the new absolute level on edit. Edge
widgets (buttons) stage on activation, as a level computed from the peek. A
flaps button peeks the current counter `k` and stages `k+1`. The levels doctrine
makes this safe by construction. Repeated staging of the same level within a
drain window is idempotent, so there is no repeat-increment hazard. Multi-click
within one window counts correctly through the own-pending-first peek (`k` →
stage `k+1`; second click peeks pending `k+1` → stages `k+2`). Held buttons do
not re-stage. After the drain applies and the snapshot catches up, re-staging
from the peek would auto-repeat at frame rate. The activation edge is the
intent.

The alternative, active widgets staging on *every* render pass, is rejected
([D-026][d-026]). Under root-input exclusivity ([§11.3][s11-3]) it has no motivation. As
insurance, staging every render pass would mask invariant violations at render
rate ([D-026][d-026]). As a side benefit, staging traffic (and trace noise) drops from
render-rate-while-grabbed to actual edits.

#### The orphan case

No claim-transition policy exists, because no claim transition can occur mid-run
(the freeze, [§11.3][s11-3]). The one liveness-adjacent display rule is the orphan case.
A read-only widget whose claiming device's task has died renders the fact in its
source label, such as "claimed by `T16000M` — task dead". `T16000M` is
FlightCore's type for the Thrustmaster T16000M joystick. The heartbeat is
surfaced in place ([§12.2][s12-2]). What the widget displays beside that fact is the
ordinary snapshot value, the orphaned root input's last drained level. An orphan
widget is a read-only rendering like any other, never a blanked one. An orphaned
root input is therefore visible where the user is looking, not only in the
status panel.

#### The framework's half of the panel convention

The panel convention has two halves. **The framework's half is fixed here, and
the GUI package's half is deferred** ([D-270][d-270]). A panel reaches the framework
through three values, a port view, the device handle and a snapshot. The port
view is this section's baked verdict, one per declared port of every component,
input and output. The handle supplies the two reads the peek composes and the
one write, `stage!`. The snapshot supplies every driven value and the writer
status the orphan label reads. Nothing a panel needs reaches into the loop
([D-270][d-270]). The block below lists four functions, and the paragraphs after it
specify each.

```julia
port_views(handle)
pending(handle, slot)
peek(view, handle, snapshot)
incumbent_status(view, snapshot)
```

**`port_views(handle)` builds one view per port of every component**, keyed by
`(path, port)`, from the build's wiring, the handle's claim and the exclusivity
index ([D-270][d-270]). A view carries the port's terminal producer (`("", face)` when
root-driven), the liveness verdict, the port's position in the handle's staging
schema when live, the producer's cell address, and the incumbent writer of a
root-driven port the GUI does not command. The GUI's loop body builds the table
once at its top. That point is after the roster freeze, so the incumbents are
the run's, and nothing at render resolves a name. The handle carries the build's
`Structure` and the nominal `Layout` by reference for this, the two things the
bake needs that the handle did not hold. An output port's view is read-only with
itself as producer, so a generated panel reads every face through one lookup.

| the port resolves to | live | slot | incumbent |
|---|---|---|---|
| a root input inside the GUI's claim | yes | its position | the GUI |
| a root input in another device's claim | no | none | that device |
| a root input no device claims | no | none | the harness |
| another component's port, or its own output | no | none | none |

**`pending(handle, slot)` reads the handle's own staging cell with one acquire
load and never takes it** ([D-270][d-270]). It returns `Some(value)` when the slot is
touched, else `nothing`. A staged batch is never mutated after it is published
into the staging cell, so the load sees a complete batch or none.
`peek(view, handle, snapshot)` composes that read with the snapshot. A live view
returns its own pending value when one is touched, and the producer's cell off
the snapshot otherwise. A read-only view skips the staging cell and reads the
producer's cell. Two ports resolving to one root input share slot and address,
which is the fan-out consistency above.

The peek rule has one visible consequence, and it is the rule's own. Between the
frame-top drain that takes the staging cell and the publication of that frame's
snapshot, a live widget finds nothing pending and shows the previous snapshot's
value, for at most one frame's compute ([D-270][d-270]). A click inside that window peeks
the old level and stages a level already drained, which the levels doctrine
makes idempotent. No device task reads the loop's store, so no reading is more
current than this one.

**`incumbent_status(view, snapshot)` returns the incumbent's writer record**
from the snapshot's status ([§11.8][s11-8]), or `nothing` for a port no device writes
([D-270][d-270]). On that record, `orphaned` is a task that returned or crashed, and
`stale` is the silent heartbeat ([§12.2][s12-2]). The record tells an exited loop from a
crashed one, and the label may. The label text is the GUI package's.

#### What stays deferred

The GUI package's half stays deferred, and `pending.md` (the record of what the
implementation still owes) tracks it. The built-in GUI's parking ([D-310][d-310]) assigns
it to the browser client over the bridge. The bridge is the link to the
simulation, and [D-310][d-310] leaves the bridge's design open. That half covers what the
client receives beside the three values, how a panel scopes to a child
component, and the widgets. Its constraints are fixed here. Panels name their
own ports by face-name string. Resolution to root inputs and the liveness
verdict are baked at run start, never performed at render. Liveness and peek
arrive through the framework-supplied context, never by reaching into the loop.
And assembly panels compose children by path.

### 11.8 Diagnostics and liveness: the per-writer diagnostic cell

The chapter's two data channels are specified down to their memory ordering. The
runtime warning stream ([§13.2][s13-2]) and the liveness heartbeat ([§12.2][s12-2]) are a third,
and they cross between the same tasks.

#### Writers and readers

The diagnostics are written in these places.

- Whichever task stages writes `OutOfClaimEntry`, `ClaimedFaceEntry` and
  `EntryTypeMismatch` at staging ([§11.4][s11-4]). The staging happens on the task of a
  [device](#g-device) (any attached participant in the periphery). It can also go through the
  [harness writer](#g-harness-writer) (the framework-owned write path `stage!(sim, …)`, [D-200][d-200]).
- The device tasks write `MalformedDatum`, from the author's loop body via
  `report!(handle, …)` ([§11.6][s11-6]).
- The loop itself writes `DebtReanchor` and `UnboundedRun`.
- The [frame](#g-frame) (one iteration of the loop) that the loop runs writes
  `ChatteringBudget` and `FiringBudget` ([D-317][d-317]).
- `attach!` writes `EmptyGreedyClaim` as it adds a device to the [roster](#g-roster) (the
  list of attached devices, [§11.3][s11-3]). The value goes into the roster entry being
  created.

`attach!` mutates the roster, so its warning lives in the roster's status rather
than on an artifact ([D-250][d-250]). The device's task does not exist until `run!`, so
the new roster entry's [diagnostic cell](#g-diagnostic-cell) (a writer's own holding place for runtime
diagnostics) has no other writer yet.

The loop reads the diagnostics. It folds them into the published [framework
status](#g-framework-status) (the diagnostics value each snapshot carries, [§11.2][s11-2]). They hence reach
every [snapshot](#g-snapshot) (the immutable per-boundary publication). An unspecified
structure with those writers is exactly the arbitrary shared mutable state that
the two rules of [§11.1][s11-1] exist to eliminate. So the channel gets the mechanism
[§11.4][s11-4] already established, not one of its own.

#### One diagnostic cell per writer

**Each writer has one diagnostic cell** ([D-136][d-136], [D-200][d-200]). There is one per
rostered device, one for the harness writer and one for the loop itself ([D-200][d-200]).
The [`Model`](#g-model) (the deployment and its executor at one scalar) owns one more. Its
frame writes the chattering and firing-budget reports there. The [drain](#g-drain) (the
frame-top swap that applies staged device writes to the root inputs) folds that
diagnostic cell into the loop's account beside the loop's own ([D-317][d-317]).

A device's diagnostic cell, the loop's and the `Model`'s each have a single
writer, by the same ownership argument as the [staging cells](#g-staging-cell) (each device's
atomic holding place for pending writes). There is no locking, no arbitration
and no new primitive ([D-136][d-136]). **The harness writer's diagnostic cell is written
from whichever task stages**, exactly as its staging cell is, and the same CAS
(compare-and-swap) append arbitrates ([D-200][d-200]). It carries no heartbeat, and its
status record no `task_state`, because it has no task of its own to be alive or
dead. The loop's own record carries neither, for the same reason ([D-240][d-240], [D-193][d-193]).

A diagnostic cell holds a bounded accumulation and one atomic liveness
timestamp. The accumulation is a small ring of diagnostic values, capacity 16,
plus a count per [kind](#g-kind) (a diagnostic's identity in the closed set) of what the
ring could not hold ([D-136][d-136]). The rejected alternatives are in [D-136][d-136].

#### The bound and the drain

**The ring's bound *is* the rate limit** ([D-136][d-136]). When a writer emits past the
ring's capacity within one frame, the value is not stored and its kind's
suppressed count increments. The drop policy retains the earliest in the frame,
and the excess becomes counts. The first occurrences are the ones with
diagnostic content, and the hundredth is noise the count already reports.
Rate-limiting "wherever its source can repeat" ([§13.2][s13-2]) is therefore not a policy
layered over the stream but a structural property of the channel that carries
it. A [chattering](#g-chattering) model (one exhausting its per-frame localization budget) or a
peer flooding malformed datagrams costs at most sixteen retained values and one
integer increment per kind per frame, whatever its source does. No writer can
starve another, because the diagnostic cells are disjoint.

**The diagnostic cells are taken at the same drain [§11.4][s11-4] specifies** ([D-136][d-136]).
The loop performs one `atomicswap` per diagnostic cell at frame top, at the same
point and under the same indivisible-take argument as the staging drain. What
the loop swaps *in* is a shared *empty sentinel*, so a quiet frame swaps the
sentinel in and gets the sentinel back. That allocates nothing, and it leaves no
load-only code path that goes untested on healthy runs.

The take also makes publication sound. The binding rule says that nothing
reachable from a published snapshot is ever written again ([§11.2][s11-2]). Because the
taken ring is exclusively the loop's before it is ever reachable from a
snapshot, the binding rule holds by construction. The live accumulator is never
reachable from a published value.

#### The heartbeat

The heartbeat rides in the same diagnostic cell, as an atomic timestamp field
([D-136][d-136]). The device task stores it on every loop pass from inside the handle
primitives. That way the framework observes activity without owning the loop
body ([§11.6][s11-6]). **The loop acquire-loads the heartbeat at publication**, when it
assembles the status ([D-240][d-240]). There is no separate liveness channel and no
second registry. A device that is alive is a device whose diagnostic cell
carries a recent timestamp, and the 2 s staleness threshold ([§12.2][s12-2]) is read
against this field. The heartbeat is not a diagnostic kind. It is a field,
always present, never enumerated in [Appendix C][sC].

#### The published status

**The published framework status is a concrete frozen value** ([D-136][d-136]). Per
writer it carries four things beside `who`. `recent` is the ring the frame's
drain took, carried by the first publication after that drain, at most sixteen
values per diagnostic cell it takes. The loop's record folds two, its own and
the `Model`'s ([D-317][d-317]). `suppressed` is the per-kind counts the ring refused in
that drain. `totals` is the cumulative per-writer × per-kind counts since the
run began, owned privately by the loop and *copied* into each status. And
`heartbeat` rides beside the `task_state` the loop reads off its own device
`Task` handle at publication ([§12.2][s12-2], [D-193][d-193]). Beside the per-writer records ride
the pacer diagnostics ([§10.7][s10-7]).

Each per-writer record has this shape.

```julia
struct WriterStatus
    who::String
    recent::Vector{DiagValue}
    suppressed::KindCounts
    totals::KindCounts
    heartbeat::Union{Nothing,Float64}
    task_state::Union{Nothing,Symbol}
end
```

`DiagValue` is any value of the kinds the channel carries, and `KindCounts` is
the per-kind counter record that the allocation rules below describe.

Delta plus total is what makes the status legible at any reading cadence. A GUI
panel refreshing at 60 Hz sees each occurrence once in `recent`, while a
consumer that samples occasionally still reads a complete account from `totals`.
Nothing is lost by not looking. The record's `who` is the only attribution a
value has, so a renderer presents each value under its record's writer ([D-228][d-228]).

#### Presentation

Presentation is where `maxlog`, the cap Julia's logging macros put on repeats,
lives. A status renderer prints a given writer × kind up to 25 cumulative
occurrences and then switches to count-only display ("`MalformedDatum` from
`UDPInput#3`: 1 482 occurrences"). **That threshold is presentation policy, not
channel policy** ([D-136][d-136]). Counts keep accumulating regardless, nothing recorded
depends on it, and the choice belongs to whoever renders. The channel's own
bound, above, is the one that is normative.

#### The run's end

**The terminal snapshot carries the run's final cumulative counters** ([§12.4][s12-4],
[§13.5][s13-5], [D-136][d-136]). An [unattended run](#g-unattended-run) (a run with empty staging and no snapshot
readers) that nobody watched therefore still answers "what went wrong, and how
often" from the value its own shutdown published. Final means final at the last
frame top ([D-201][d-201]). The account closes with the drain that preceded the terminal
publication. What lands after it can reach no snapshot. Examples are a report
from a device's exit path and the tail's own `DeviceJoinTimeout` ([§12.4][s12-4]). So the
loop takes each diagnostic cell once more at the run's end, keeping the next
run's account clean.

That last take is folded into the [termination record](#g-termination-record) (the stopped-sim value
naming how the run ended) as the tail residue ([§13.5][s13-5]). Per writer, the tail
residue is the final ring and its suppressed counts. The take is also presented
through the standard logging backend. It is loud *and* recorded, and still never
published ([D-201][d-201], [D-203][d-203]).

#### Allocation

**On a quiet frame nothing allocated scales with diagnostic activity** ([D-241][d-241]).
The sentinel swap allocates nothing. **The per-writer status costs one small
vector of records per publication** ([D-241][d-241]), beside the snapshot allocation per
[boundary](#g-boundary) (a published consistency point) that [§11.2][s11-2] already accepts. That is the
same GC-over-reuse trade, a roster-sized vector rather than a snapshot type per
roster size ([D-241][d-241]).

**The per-kind counters are a fixed-shape isbits record, never a `Dict`**
([D-136][d-136]). The closed kind set ([Appendix C][sC]) licenses that, because it makes the
counter layout a type rather than a lookup.

On a noisy frame the diagnostic values are allocated at emission, on the
writer's own task. A drained non-empty ring is frozen into the snapshot and can
never be written again, so the writer allocates a fresh ring lazily at its next
emission. That cost, too, lands on the writer's task, and it is the same
GC-over-reuse trade [§11.2][s11-2] makes when it rejects preallocated snapshot buffers.
The rate limit is therefore an allocation bound as well. One ring of sixteen
values per diagnostic cell per frame is the worst case, and everything past it
is an integer increment. The zero-allocation invariant, scoped to the stepping
loop ([§9.8][s9-8], [D-305][d-305]), is untouched. The diagnostic cells sit on the framework side
of that scope with publication and logging.

#### Composition with the log

Because the [log](#g-log) (the retained sequence of published snapshots) retains snapshot
references ([§11.2][s11-2]), `totals` is monotone across logged snapshots. `log_every`
[decimation](#g-decimation) (the log's keep-every-kth retention policy) therefore loses *which*
boundary within a skipped stretch an occurrence fell on, never *how many*
occurrences there were.

---

