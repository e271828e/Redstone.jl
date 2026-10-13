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

