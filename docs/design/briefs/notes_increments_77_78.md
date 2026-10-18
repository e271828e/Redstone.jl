# Notes: increments 77 and 78, the rulings made overnight

Written on 2026-10-19 while the user was away, having agreed D-406's entry
and delegated the rest. Each ruling below is mine, with its reason, for the
user's review. Nothing was pushed.

## D-407, the series over the log

The entry itself is a ruling made in the user's absence, on the design
discussed before they left. Its four bundled rulings and the reasons:

- **The read set is a `Reads`, not keyword selectors.** `at` then mounts
  it for free and the spelling is trim's. The keyword form was measured
  to recompile per label set and would have been a second spelling.
- **Columns are plain vectors.** Any plotting or analysis package takes
  them without a recipe; FlightCore's `TimeSeries` needed a Plots
  extension to be plottable at all.
- **Labels reach no compiled body.** Measured: labels in the gather's type
  cost 24 ms per new label set; `@nospecialize` on the selector value and
  a NamedTuple built last brought it to a few milliseconds.
- **The names `series` and `Series` are provisional** until the export
  audit (D-226), which owns names.

## Increment 77's brief

- **The test shape at attach changes.** Collected refusals arrive as
  `DiagnosticError{Vector{Diagnostic}}`, so `carried(@test_throws
  DiagnosticError{K} attach!(…))` cannot match; the form is
  `only(diagnostics(failure(() -> attach!(…))))`, both helpers already in
  `test/utils.jl`. A consequence of D-406's collecting rule, not a choice.
- **Candidates on `:undeclared` come in declaration order**, `[:y,
  :power]` where the binding resolver sorted them. The reader's
  convention, pinned at `test/test_readers.jl` 203, wins; one convention
  for one kind.
- **`gather_reads` over a snapshot lives in `src/dataplane.jl`**, beside
  `port(snapshot, …)`, because readers.jl precedes dataplane.jl in the
  include order and `Snapshot` is dataplane.jl's. The prototype hit the
  `UndefVarError` first.
- **`_root_input_names` is inlined at its one surviving caller** in
  devices.jl rather than kept as a one-line helper in bindings.jl, where
  every other use was deleted.
- **`ReadResolution` is placed where `ReadBindingUnresolved` sat**, and
  the old kind survives stage 1 so the rendering table compiles between
  the two stages. Stage 2 deletes it.
- **Two stages, not one.** The kind split is a pure rename the suite
  proves by an unchanged assertion total; the rewiring changes behavior.
  Keeping them apart gives the reviewer a clean baseline for each.

## Increment 78's brief

- **`_compile_reads` and `_resolve_reads` take their read set
  `@nospecialize`d.** Measured through the real resolver: 25 to 29 ms per
  new label set specialized, 12 ms unspecialized; both bodies iterate
  `pairs` into `Any[]`, so the specialization bought nothing. Trim and
  linearization run the compiled `Reader`, never the resolver, at runtime.
- **`_resolved_type` moves from linearize.jl to readers.jl.** `_column`
  needs it and sim.jl should not reach into linearization for a
  resolution helper; it is `last(resolve_leaf(P, chain))` and belongs
  beside `resolve_leaf`.
- **Tests live in `test/test_log.jl`.** The suite is cut by property, and
  the series is a read of the log; the resolver's refusals are already
  property-tested in `test/test_readers.jl`, so the series pins only that
  they arrive.
- **The examples' `logged_port` becomes a `series` call**, so the first
  consumer uses the public form, as `pending.md`'s bullet says.
- **Brief 78's line numbers are from 06ed3bf** and are recounted at
  increment 77's tip before its launch; the recount is noted at the
  brief's head.

## The arc

To be completed as the two sessions report: the stage commits, the
review findings, the fixes, and what the user is asked to diff-verify.
