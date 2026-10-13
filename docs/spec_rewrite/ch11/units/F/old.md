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

