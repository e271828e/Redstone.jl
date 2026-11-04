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

Run on 2026-10-19 by a second session, from the brief, with the user away.
The baseline gate at 1cba470 passed 6540 assertions on Julia 1.13.1, the
floor. Nothing was pushed.

### Stage 1, 9e9782b: the kind split

Both routed subsets unchanged, 1899 and 609 assertions before and after.
The stage's judgment calls, each accepted as routine:

- **The shared message builder is `_read_message`**, not the brief's
  `_tap_violation`: the brief gave that name to both the prefix builder in
  diagnostics.jl and linearize.jl's tap-set builder, and Naming forbids one
  name with two meanings. The tap-set builder keeps `_tap_violation`,
  beside `_reader_violation`, `_leaf_violation` and `_trim_violation`.
  The review's "tap clause on a `ReadResolution`" mutant targets
  `_read_message`.
- **`TapResolution` keeps `leaf`** although no message arm reads it:
  `test/test_linearize.jl` pins `d.leaf` on a `:duplicate_site`, and a
  no-behavior-change stage drops no payload. `declares`, `candidates` and
  `producer` go, as the recount against the arms says.
- **`linearize`'s docstring** said every violation is a `TapResolution`,
  false after the split; it now names both kinds. A docstring-sized
  conformance inside a file the stage owns.
- **`_tap_noun` keeps its name** although only `ReadResolution`'s
  `:undeclared` arm reads it now. A rename was outside the brief. For the
  user: `_declares_noun` or similar, a loose fix if wanted.
- **The docs run one stage ahead**: `_compile_reads`'s docstring names
  attach as a site from stage 1, as the brief asked, while
  `implementation.md`'s readers.jl entry describes the file as it stands
  and gains attach at stage 2.

### Stage 2, a630dea: attach as a site

The gate green at 6504 assertions against 6540, the examples' runner
green. The drop of 36 is accounted: five `@test_throws` in
`test_readers.jl` folded into the collected form; `test_bindings.jl` lost
the `device`/`binding` pin with the kind and gained the brief's three pins
and a `:store_selector` pin; `test_diagnostics.jl` lost eleven
`ReadBindingUnresolved` rows at three assertions each and gained one
`:store_selector` row and one rendering pin. The reviewer re-checks the
accounting. The stage's judgment calls, each accepted as routine:

- **The `{power, y}` rendering pin became the backtick list**
  "its output port names are `power`, `y`": `ReadResolution`'s
  `:undeclared` arm prints with `_namelist`, the reader's rendering at trim
  and linearization, and the brief's "keep the pin" meant the list in
  hand is printed, not its braces. Changing the message would have changed
  trim's and linearization's rendering, which D-406 leaves alone.
- **The three-violation pin uses `failure` and `diagnostics`**, not the
  prototype's `try … catch`: Naming's rule for a caught exception.
- **The unknown-path case gained a pin** the prototype left bare: a
  `PathResolution` with `:unknown_child`, segment `"q"`, candidates
  `["p"]`.
- **Citations added in `implementation.md`**: the dataplane.jl entry's
  spec line gains §14.4 and D-406; the readers.jl entry's gains §11.2;
  the bindings.jl entry's drops D-276, since the file no longer touches
  the leaf address.
- **`src/roster.jl`'s header still says the compiled gather lives in
  bindings.jl**, outside the stage's file list. Handed to the reviewer's
  sweep; lands with the fix commit.

### The cold review

Nothing blocking. The gate green at 6504 in the real tree on 1.13.1, the
examples green. The brief's five mutants all died on a scratch copy: the
dropped `:store_selector` check (the store-selector pins in readers and
bindings), `source` defaulting to `:table` (trim's `get_deriv` reads),
attach throwing at the first violation in both variants (the
three-violation pin), sorted output-port candidates (`[:y, :power]`), and
the tap clause printed for a `ReadResolution` (the `:store_selector`
rendering pin). The assertion accounting checks out; nothing was lost
beyond what the brief retired. D-406's rulings were each probed and hold;
`reads(b)` still returns a NamedTuple and the contract checks fire as
before; a mount on a binding read is impossible by construction; the
gather allocation pins hold with `Reader` in the handle's type.

Five low findings, each ruled "fix" and landed by the fixer:

1. The one-argument `_field` in readers.jl was dead after bindings.jl's
   resolver went; deleted.
2. `src/roster.jl`'s header still placed the compiled gather in
   bindings.jl; reworded.
3. readers.jl's file header and `_leaf_clause`'s comment described the
   retired shape; reworded.
4. `_tap_noun` served only `ReadResolution`'s `:undeclared` arm; renamed
   `_declares_noun` and moved beside the kind. A private helper, not
   spec-named.
5. No pin covered `TapResolution`'s " (tap `x`)" clause, the guard stage 1
   rewrote: an extra mutant survived. One rendering pin added.

Two informational items, left for the user:

- **A state-field candidates sort survives** in `_undeclared_violation`'s
  NamedTuple method: every state candidate list in the suite is one name
  or already sorted. Attach cannot reach it, so it is an older gap outside
  this increment; a loose fix if wanted.
- **§14.4 still says** "on `get_input`, `get_face` and a binding read the
  head is matched rather than parsed" (D-276's annotation). After D-406 a
  binding read has no resolution of its own and its `get_output` is
  parsed like any path selector, so "and a binding read" is redundant, or
  misleading if read as covering `get_output`. A spec edit, the user's
  ruling.

### The fix, 22ef32c

The five findings in one commit over `src/readers.jl`, `src/roster.jl`,
`src/diagnostics.jl` and `test/test_diagnostics.jl`. The gate green at
6505 in the real tree, the examples green; the new pin shown to kill its
mutant on the scratch copy. The reviewer verified the delta.

### What the user should diff-verify

The arc is 9e9782b, a630dea and 22ef32c over 1cba470, unpushed.

- `git show 9e9782b -- src/diagnostics.jl`: the field roster of each kind
  against Appendix C, and that the arms split by reason with none lost.
- `git show a630dea -- src/bindings.jl src/readers.jl`: that what remains
  in bindings.jl is the two contract checks and the one call, and that the
  `:store_selector` refusal sits after `_rebase` and before
  `_resolve_selector`.
- `test/test_bindings.jl` at a630dea: the pins' values against D-406's
  rulings, candidates in declaration order included.
- The rendering pin's backtick form and the `_declares_noun` rename, both
  rulings made here.
- The two informational items above: the state-field candidates sort
  and §14.4's "and a binding read".

## After increment 77's arc

- **§14.4's "and a binding read" clause dropped**, the reviewer's first
  item: after D-406 a binding's `get_output` is parsed like every path
  selector and its face selectors are matched like every reader's, so the
  clause named a resolution that no longer exists. Landed as a docs commit
  at 997766b's tip; no code change.
- **Left for the user**, the reviewer's second item: `_undeclared_violation`'s
  NamedTuple method sorts state-field candidates, which no test can
  observe since every state candidate list in the suite is one name or
  sorted already. A loose fix if wanted, outside both increments.
- **Brief 78 recounted at 997766b** before its launch, as its head says.

## Increment 78's arc

Run on 2026-10-19 by a third session, from the brief, with the user away.
The baseline gate at 63b00cb passed 6505 assertions on Julia 1.13.1, the
floor. Nothing was pushed.

### Stage 1, e297652: the series

The gate green at 6543 against 6505, the 38 new assertions all in
`test/test_log.jl`; the examples' runner green at 73. The stage's judgment
calls, each accepted as routine:

- **The specialization pins use `specialization_counts`**, the helper
  `test/test_build.jl` already defines, since `Base.specializations` takes
  a `Method` on 1.13.1, not a function. They pin deltas across calls, not
  absolute counts, which depend on what ran earlier in the process.
  Probed: `series` holds at one instance per `Simulation` type across new
  labels, a new order and a new entry of a seen type; `_column` grows by
  one per new leaf type or chain. Without `@nospecialize` the relabel calls
  took `series` from one to three.
- **`port` and `logged` left the examples' import** once `series` replaced
  both comprehensions; the brief said only that three names join.
- **`logged_times` became `series(sim, reads()).t`**, since an empty read
  set resolves, as the brief allowed.
- **The mount test uses `fed(Plant(), "u")` at `"c"`**, the brief's pattern
  on an existing fixture, not the prototype's aircraft.

### The cold review

Nothing blocking. The gate green at 6543 in the real tree on 1.13.1, the
examples green. The brief's six mutants all died on a scratch worktree:
`Vector{Any}` columns (the type pins), the default source (`get_state`
resolves and `_column` errors), the dropped gate (the `op === :series`
pin), `boundary` from `frame` (the t* run's `[0,1,2,3,4,4,5]` frames
against `0:6` boundaries), `@nospecialize` dropped from `series` (the
count pins), and sorted keys (`(:power, :q, :input)`). D-407's four rulings
were each probed and hold. Latency in a fresh process on the examples'
closed loop, 24001 snapshots: a repeated set 1.2 to 1.6 ms; a new label
set over seen entries 11 to 12 ms; a new leaf type 26 ms; a new chain 18
to 19 ms; the first call 66 ms.

Three findings ruled "fix" and landed by the fixer:

1. **`_mount` was still specialized on the `Reads` type**, so a new label
   set paid about 10 ms of compilation there. D-407 says labels reach no
   compiled body, and `_mount` is a second instance of the principle the
   brief's grep missed; its two callers are setup, never hot. One
   `@nospecialize`, and `implementation.md`'s readers.jl entry names it.
   The brief's "12 ms without" was measured before this site was seen;
   D-407's "a few milliseconds" is the ruling and now holds.
2. **`Series` sat after `ServiceLifecycle` in `test/imports.jl`**; ASCII
   order puts it before. The brief's "before `Simulation`" admitted both.
3. **The test local `stamps` held a whole `Series`**; renamed for what it
   holds.

One accepted survivor: dropping both resolver `@nospecialize` passes
`log readers`, since the only effect is latency and the keyword methods'
specializations sit on their body functions, out of
`specialization_counts`'s reach. A timing pin would be flaky.

Two items left for the user:

- **`series(sim, (; y = …))` raises a bare `MethodError`**, since the
  signature requires `Reads`, where `taps` reports `ReadSetMisuse` and trim
  `TrimProblemInvalid(:not_a_read_set)`. The brief gave the signature and
  no spec line mandates the misuse for `series`; the fix would be a
  `series(::Simulation, other)` method throwing
  `ReadSetMisuse(observed = typeof(other), reason = :not_a_read_set)` plus
  one pin, a loose fix if wanted.
- **Appendix B's row writes `series(sim, read_set) → series`**, naming the
  value as the function where `trace(sim) → trc` does not. A spec edit,
  outside the increment.

### The fix, 21b8793

The three findings in one commit over `src/readers.jl`,
`design/implementation.md`, `test/imports.jl` and `test/test_log.jl`.
The gate green at 6543 in the real tree, the examples green. A new label
set over seen entries measured 4.9 to 5.1 ms in a fresh process after the
change, of which 3.3 to 3.8 ms is compilation, against 12 ms before. The
reviewer verified the delta.

### What the user should diff-verify

The arc is e297652 and 21b8793 over 63b00cb, unpushed.

- `git show e297652 -- src/sim.jl`: the `series` block against the
  prototype, and that the NamedTuple is built last from the runtime
  labels.
- `git show e297652 -- src/readers.jl src/linearize.jl`: the two
  `@nospecialize` and `_resolved_type`'s move, unchanged.
- `test/test_log.jl` at e297652: the pins' values against D-407's
  rulings, the specialization deltas included.
- `examples/test/runtests.jl`: the two helpers as `series` calls, every
  pin's value kept.
- The `_mount` ruling above, and the two items left open.

## After increment 78's arc

- **`series(sim, other)` refuses a bare NamedTuple as `ReadSetMisuse`**
  with `:not_a_read_set`, the reviewer's first item, landed as a loose fix
  with one pin: the read side's §14.2 misuse is refused by name at every
  other site (`_compile_reads`, `taps`, trim), and a `MethodError` there
  would have been the one exception.
- **Appendix B's row names the value `ts`**, not `series`, the reviewer's
  second item, so the function and its value no longer share a spelling,
  as `trace(sim) → trc` keeps them apart. A docs commit.

## The user's rulings

Made on 2026-10-19 on the points the arcs left open; the arc was pushed
after them.

- **The state-field candidates sort does not exist.** `_undeclared_violation`'s
  NamedTuple method collects `keys(declared)` in declaration order at every
  commit of the arc, and the only candidate sorts readers.jl ever held were
  the two `layout.addr` comprehensions stage 2 deleted. Closed as moot; no
  code change.
- **The backtick rendering pin and the `_declares_noun` rename**, stage 2's
  two rulings, ratified.
- **The `_mount` finding.** D-407's "a few milliseconds" holds at 5 ms, and
  its 15 to 25 ms per new leaf type or chain stands beside the review's 26
  and 18. No spec edit.
- **The accepted survivor stands** with no timing pin: the count pins on
  `series` and `_column` guard the public sites, and `implementation.md`
  names the three `@nospecialize`d functions a future grep needs.
- **`series` and `Series` stay provisional** until D-226; the audit's entry
  in `pending.md` needs no per-name reminder.
- **The first call's 66 ms goes to the precompile workload**: `pending.md`'s
  workload bullet now names `series`.
