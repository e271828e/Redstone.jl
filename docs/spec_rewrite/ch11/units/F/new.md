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
