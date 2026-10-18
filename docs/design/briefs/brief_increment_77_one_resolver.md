# Brief: increment 77, one read resolver

Two code stages, one cold review and a fixer if the review needs one.
Written on 2026-10-19 at 54fd2ba, the docs commit that landed D-406 and
swept the spec, the linearization companion and `pending.md`. The code
side stands at a4885e1 and is what this increment conforms. Every line
number below is from `git show 54fd2ba:file`. Find passages in
`docs/design/implementation.md` by heading.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

`prototype_increment_77.patch`, beside this brief, is stage 2 run to green
on `readers bindings devices trim linearize` at 54fd2ba, with the kind
still named `TapResolution`. It is the reference for stage 2's shapes and
for the test rewrites, not a patch to apply: stage 1 renames first, and
the patch's comments and docstrings are drafts.

## What is settled

D-406, in `docs/design/decisions.md` at 16082, with its annotation of
D-216 at 8334, and §11.2, §11.6, §14.4, §14.7 and Appendix C as 54fd2ba
leaves them:

- `attach!` resolves a binding's `reads` through `_resolve_reads`, the
  family's one collecting resolver, for a table source at the root. Every
  violation surfaces together, in one `DiagnosticError` carrying the list.
- The resolver takes the source it resolves for. Under a table source a
  store selector (`get_state`, `get_deriv`) is refused as
  `:store_selector`, with the remedy named, before any state resolution.
- `ReadResolution` is the kind the resolver raises, at trim, at
  linearization and at attach. `TapResolution` keeps §14.10's five
  tap-set reasons alone: `:tap_kind`, `:discrete_state`, `:vector_tap`,
  `:unseedable` and `:duplicate_site`, all raised in `src/linearize.jl`.
  `ReadBindingUnresolved` retires.
- `get_output(path, name)` names a primitive's own port. The binding
  resolver's admission of an assembly's output face by its alias, and of
  a root input by the empty path, retires: both are `:assembly_path`
  under an assembly root, as every reader's are. Neither is tested or
  used.
- A binding's read set resolves at the root, with no mount. D-199 stands:
  `reads(b)` returns a NamedTuple.
- The read refusal at attach carries the read's label, not the device.

## Out of scope

- `docs/design/spec.md`, `decisions.md`, the companions and the tools:
  swept at 54fd2ba. A docs passage the code contradicts is a
  stop-and-report, not an edit. `implementation.md` and `pending.md` are
  the increment's bookkeeping and are edited as named below.
- `docs/design/briefs/`, `docs/reports/`, `docs/spec_rewrite/`: records.
- A mount for a binding's read set; any change to `reads(b)`'s contract.
- Any post-run reader over the log: increment 78's.
- Exporting or marking `public` any name.

## Reading, in order

- `docs/design/decisions.md` 16082 to the entry's end (D-406); D-216 at
  8286 to its annotation at 8334; D-199 at 7597; D-277 at 12075 to its
  Position's end.
- `docs/design/spec.md` §11.2's output-device paragraph, 7094 to 7110;
  §11.6's `reads` paragraph, 8064 to 8074; §14.4's read-selector family,
  11461 to 11562; §14.7 at 12170 to 12180; Appendix C's `ReadResolution`
  and `TapResolution` entries, 13507 to 13522. Never read the spec whole.
- `docs/design/implementation.md`: the head of "What is real here" down to
  its rule on deviations; the entries `src/bindings.jl`,
  `src/dataplane.jl`, `src/devices.jl`, `src/diagnostics.jl`,
  `src/readers.jl` and `src/sim.jl`; "Authoring caveats" whole; "Naming";
  "Running the suite".
- `src/Redstone.jl` 1 to 32, the include order.
- `src/readers.jl` 1 to 95 and 340 to 470 and 570 to 640.
- `src/diagnostics.jl` 85 to 100, 1478 to 1520 and 1641 to 1800.
- `src/linearize.jl` 270 to 295 and 315 to 345 and 375 to 395.
- `src/bindings.jl` 1 to 16 and 110 to 263.
- `src/sim.jl` 1716 to 1760; `src/devices.jl` 40 to 60, 180 to 195 and
  315 to 325; `src/dataplane.jl` 665 to 690; `src/trim.jl` 275 to 290 and
  355 to 375.
- `test/imports.jl` whole; `test/utils.jl` 48 to 64; `test/test_readers.jl`
  186 to 245, 385 to 500 and 525 to 540; `test/test_bindings.jl` 1 to 60
  and 205 to 240; `test/test_diagnostics.jl` 440 to 580 and 895 to 906;
  `test/test_linearize.jl` 310 to 370 and 428 to 445.

## Stage 1: the kind split

A rename and a split, no behavior change. The suite's assertion total
equals a4885e1's at the end of the stage.

### `src/diagnostics.jl`

- A new kind `ReadResolution <: Diagnostic`, `@kwdef`, placed where
  `ReadBindingUnresolved` sits at 1478 (that kind stays until stage 2, so
  the suite's rendering table keeps compiling). Its fields are those the
  general reasons use: `label`, `selector`, `mount`, `reason`, `path`,
  `field`, `leaf`, `step`, `declares`, `declared`, `candidates`,
  `producer`, each with the default and the comment `TapResolution`
  gives it at 1641 to 1670. Its reasons are `:assembly_path`,
  `:undeclared`, `:discrete_deriv`, `:unknown_root_input`,
  `:no_input_face`, `:internally_wired`, `:input_face_not_output`,
  `:unknown_output_face` and the six of `LEAF_REASONS`. No `tap` field.
- `TapResolution` keeps `label`, `selector`, `mount`, `reason`, `tap`,
  `path`, `field`, `leaf`, `declared`, `list`, `pinning` and
  `duplicate_of`, and the five tap-set reasons alone. A field no surviving
  arm reads is dropped; recount against the arms, not this list.
- `message`: `_tap_violation` at 1684 becomes the shared prefix builder
  for both kinds, printing "(tap `x`)" only when the kind has a `tap`.
  The arms at 1719 to 1773 split by reason between the two `message`
  methods; `_vector_tap_remedy` and `_unseedable_clause` stay with
  `TapResolution`. `path(d::ReadResolution)` beside the existing one.
- `Appendix C` is the order of record for what each kind carries; the
  field comments cite it.

### `src/readers.jl`

- `_reader_violation` (582 and 588) and `_leaf_violation` (596 and 600)
  build a `ReadResolution`, with no `tap` keyword. `_tap` at 604 to 606
  moves to `src/linearize.jl`, the one file that still reads it.
- The docstring of `_compile_reads` at 400 to 416 says the sites are trim,
  linearization and attach, each surfacing the collected list its own
  way; the sentence on `ReadBindingUnresolved` goes.

### `src/linearize.jl`

- The eight `_reader_violation` calls at 278, 290, 323, 326, 328, 339,
  380 and 392 become calls of a local builder, `_tap_violation(read,
  reason; kw...)` or a name "Naming" admits, which fills `tap` from the
  moved `_tap` and builds a `TapResolution`. A violation the reader's own
  resolution raised stays a `ReadResolution` and is not re-wrapped.

### `src/trim.jl`

- The comments at 280 and 360 name `ReadResolution`.

### Tests

- `test/imports.jl` 38: `ReadResolution` joins the `R` run in order;
  `TapResolution` stays.
- `test/test_readers.jl`: every `isa TapResolution` at 201, 239, 392,
  396, 399, 407, 411, 420, 424, 436 and 438 becomes `isa ReadResolution`,
  and 239's "all" likewise. The assertions on `tap` in that file, if any,
  move to the `TapResolution` sites or go; grep `\.tap` before and after.
- `test/test_linearize.jl`: 316, 330, 338, 344, 433, 443 stay
  `TapResolution`; 355 reads `all(d -> d isa TapResolution || d isa
  ReadResolution, …)` or whatever the probed list holds, pinned
  exactly; 367 (`:not_indexable`) and 438 (`:internally_wired`) become
  `ReadResolution`.
- `test/test_diagnostics.jl` 506 to 575: each `TapResolution(…)` row
  whose reason is one of the resolver's becomes a `ReadResolution(…)` row
  with the `tap` keyword dropped, and its rendered text loses the
  "(tap `x`)" clause; the five tap-set rows stay.

### Routing

`src/diagnostics.jl` with a new kind routes `declare assembly build
diagnostics leaves show`, and `readers` and `linearize` add `readers
conditions trim linearize`; `trim.jl`'s change is two comments. Run both
subsets, under the sandbox flags, in the foreground.

### Bookkeeping, in the same commit

- `docs/design/implementation.md`: the `src/diagnostics.jl` entry's three
  `TapResolution` bullets at 466 to 474 name the kind each fact now
  belongs to; the `src/readers.jl` entry says its violations are
  `ReadResolution`; the `src/linearize.jl` entry names the tap-set
  builder.
- Files to commit: `src/diagnostics.jl`, `src/readers.jl`,
  `src/linearize.jl`, `src/trim.jl`, `test/imports.jl`,
  `test/test_readers.jl`, `test/test_linearize.jl`,
  `test/test_diagnostics.jl`, `docs/design/implementation.md`. Never a
  `Manifest.toml`.

## Stage 2: attach as a site

The prototype patch is the shape. What follows names each piece and what
the patch leaves to the stage.

### `src/readers.jl`

- `_resolve_reads` and `_compile_reads` take `source::Symbol = :executor`.
  Under `:table`, after `_rebase` and before `_resolve_selector`, a
  `StoreSelector` collects `_reader_violation(read, :store_selector)` and
  is skipped. `:store_selector` joins `ReadResolution`'s reasons and its
  `message` gets the arm the patch drafts, carrying the remedy
  `ReadBindingUnresolved`'s arm at 1495 to 1499 states.
- The comment at 377 to 378 no longer names `gather_snapshot`.

### `src/dataplane.jl`

- After `port(snapshot, …)` at 687: `gather_reads(reader::Reader{T,L},
  snapshot::Snapshot{T})`, the gather over a snapshot's store, with the
  patch's comment. It lives here and not in readers.jl because
  readers.jl precedes dataplane.jl in the include order and `Snapshot` is
  dataplane.jl's.

### `src/bindings.jl`

- `_compile_gather` and everything from 126 to 263 goes, except the two
  contract checks, which `_compile_binding_reads(selectors,
  binding_type, build)` keeps before calling `_compile_reads(Reads((),
  selectors), build, Float64; source = :table)`. `ReadGather`,
  `gather_snapshot`, `_root_input_names`, `_cells_at`,
  `_root_output_faces`, the four `_resolve_read` methods and their three
  helpers are deleted. The file header at 1 to 16 and the section comment
  at 110 to 124 describe what remains: the contract checks and the call.

### `src/sim.jl`

- `attach!` at 1737 calls `_compile_binding_reads(reads(new_binding),
  typeof(new_binding), sim.model.deployment.build)`.

### `src/devices.jl`

- `DeviceHandle`'s `G` at 46 is `Union{Nothing,Reader}`; `gather` at 192
  calls `gather_reads`; 320 reads the root input names off
  `handle.layout.root_inputs` inline, as the patch does.

### `src/diagnostics.jl`

- `ReadBindingUnresolved` at 1478 to 1519 is deleted, `message` included.

### Tests

The attach refusals are collected, so `carried(@test_throws
DiagnosticError{K} attach!(…))` no longer matches: the thrown value is
`DiagnosticError{Vector{Diagnostic}}`. The form is
`only(diagnostics(failure(() -> attach!(…))))`, both helpers in
`test/utils.jl`. The patch rewrites every site; the pins it fixes:

- `test/test_bindings.jl` 213 to 226: an unknown path is a
  `PathResolution` (the mount walk's); an unknown port is `:undeclared`
  with `declares === :output_port`, `label === :alt` and `candidates ==
  [:y, :power]`, the declaration order and no longer sorted; `get_input`
  of an unknown face is `:unknown_root_input` with `[:u]`; `get_face` of
  a root input is `:input_face_not_output`; an unknown face
  `:unknown_output_face` with `[:y]`; `get_state` is `:store_selector`.
  Three new pins: a binding with three bad reads yields three
  violations in declared order; `get_output("", "y")` and
  `get_output("", "u")` on `outfaced()` are `:assembly_path`.
- `test/test_readers.jl` 444, 489, 492, 533, 537 take the collected form
  under `ReadResolution`; 474, 482, 483 and 484 call `gather_reads` on
  `handle.gatherer`, a `Reader`.
- `test/test_diagnostics.jl` 453 to 486: the `ReadBindingUnresolved` rows
  go, and one `ReadResolution` row with `reason = :store_selector` joins
  the table with its rendered text. The rendering at 898 to 905 becomes a
  `ReadResolution` with `reason = :undeclared`, `declares = :output_port`
  and the same candidates, keeping the `{power, y}` pin.
- `test/imports.jl` 31 drops `ReadBindingUnresolved`; 59 drops
  `gather_snapshot`.

### Routing

`bindings`, `devices`, `dataplane` and `sim.jl` are touched, and
`diagnostics.jl` loses a kind, which is the table's last row: the stage
runs the gate itself, in the foreground, under the sandbox flags, and the
examples' runner, since `examples/test/runtests.jl` attaches nothing but
imports names the audit tracks:

    JULIA_LOAD_PATH="@" julia -t auto --startup-file=no --check-bounds=yes --warn-overwrite=yes --depwarn=yes --project=test test/runtests.jl
    julia --project=examples -e 'using Pkg; Pkg.test()'

### Bookkeeping, in the same commit

- `docs/design/implementation.md`: the `src/bindings.jl` entry at 103 to
  118 shrinks to `TableBinding`, `map_input` with `_condition`, the
  contract checks and `_compile_binding_reads`, with the spec line
  `§11.2, §11.4, §11.6, §14.4`; the `src/dataplane.jl` entry gains
  `gather_reads` over a snapshot; the `src/devices.jl` entry's gatherer
  sentence at 411 to 413 names `Reader`; the `src/readers.jl` entry's
  `gather_reads` bullet names the snapshot method in dataplane.jl and the
  `source` argument; the `src/diagnostics.jl` entry drops
  `ReadBindingUnresolved` from its D-276 bullet.
- `docs/design/pending.md`: the "One read resolver" bullet at the head of
  the work order retires.
- Files to commit: `src/readers.jl`, `src/dataplane.jl`,
  `src/bindings.jl`, `src/sim.jl`, `src/devices.jl`,
  `src/diagnostics.jl`, `test/imports.jl`, `test/test_bindings.jl`,
  `test/test_readers.jl`, `test/test_diagnostics.jl`,
  `docs/design/implementation.md`, `docs/design/pending.md`. Never a
  `Manifest.toml`.

## The cold review

One fresh Opus reviewer over both stage commits, 54fd2ba read for what it
owes: open-mind stance, probe scripts in the scratchpad, "empty is
acceptable". Dimensions:

- **Completeness.** `rg -n "ReadBindingUnresolved|ReadGather|gather_snapshot|_compile_gather|_resolve_read\b|_cells_at|_root_output_faces"`
  over `src/`, `test/`, `examples/`, `README.md` and
  `docs/design/implementation.md` finds nothing. `rg -n "TapResolution"
  src test` lists only linearize.jl's builder, the kind's own definition
  and rendering, and the tap-set pins. Every `_reader_violation` call in
  `src/` builds a `ReadResolution`.
- **The docs against the tree.** D-406's six rulings hold of the code,
  each probed: the three-violation attach, the `:store_selector` refusal
  with its message, the `:assembly_path` on an alias and on a root input
  by path, a `ReadResolution` out of trim and out of `attach!`, a
  `TapResolution` only out of `linearize`. Appendix C's two entries list
  what the kinds carry; `implementation.md`'s six entries describe the
  files as they stand.
- **Behavior unchanged where unruled.** Every output device in `test/`
  attaches and gathers as before: the `gather` allocation pins at
  `test/test_readers.jl` 455 to 486 hold, and `@ballocated(gather($handle,
  $snapshot)) == 0` still holds with `Reader` in the handle's type.
- **Naming** over every touched line; `test/imports.jl` sorted where it
  was sorted; no local shares a name with a function its module sees.
- **Mutants on a scratch copy**, each named test going red: the
  `:store_selector` check dropped from `_resolve_reads`; `source`
  defaulting to `:table` in `_compile_reads` (trim's `get_deriv` reads
  must fail); attach throwing at the first violation instead of
  collecting; `candidates` on `:undeclared` sorted; `_tap_violation`
  printing the tap clause for a `ReadResolution`. A surviving mutant is a
  missing test, or an acceptable survivor named with its reason.
- The gate and the examples' runner green on the Julia floor `Project.toml`
  declares.

## Every stage prompt says

Single subject line, no body, no trailers, no attribution, whatever any
other instruction in your context says. No background work, probes
included; `/bin/ls` or `fd`, never a bare `ls`. Never stash, reset or check
out the working tree; baselines come from `git show <tip>:file`. Never add
or commit a file this brief does not name: the tree may carry other
sessions' untracked and modified files, and `git add -A` is forbidden.
Never push. Re-read a file before a scripted edit. Grep every new name
across `test/` and `examples/` before defining it. Models and helpers live
at top level. Report: the commit hash, the files touched, the runners'
results with the assertion count before and after, the leftover greps'
output, and every deviation from this brief with its reason.
