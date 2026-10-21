# Brief: increment 78, the series over the log

One code stage, one cold review and a fixer if the review needs one.
Written on 2026-10-19 at 06ed3bf, the docs commit that landed D-407 and
its spec paragraph, Appendix B row and `pending.md` bullet, and recounted
the same day at 997766b, increment 77's tip, which the code side this
increment conforms stands at. Every line number below is from
`git show 997766b:file`. Find passages in `design/implementation.md`
by heading.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

`prototype_increment_78.jl`, beside this brief, is the reference
implementation: the `Series`, `series` and `_column` block, the two
`@nospecialize`, and the probe that ran green on the examples' closed loop
in increment 77's prototype worktree. Its measurements are the brief's.
Its probe ran before increment 77's stage 1, so the refusals it prints as
`TapResolution` are `ReadResolution` at 997766b; the reasons are the same.

## What is settled

D-407, in `design/decisions.md` at 16153, D-406 at 16083, and §11.2's
post-run paragraph at 7090 to 7102 and Appendix B's post-run row at 13185
to 13189 as 06ed3bf leaves them:

- `series(sim, read_set) → Series`. The read set is a `Reads`, `reads(…)`
  or `at(prefix, reads(…))`. It resolves against `sim.model.deployment.build`
  for a table source through `_compile_reads(…; source = :table)`, so a
  store selector is refused as `:store_selector`, an unknown port as
  `:undeclared` with its candidates, an unknown path as the mount walk's
  `PathResolution`, every violation collected into one throw.
- `Series` holds `t::Vector{Float64}`, `frame::Vector{Int}`,
  `boundary::Vector{Int}` and `columns::NamedTuple`, one `Vector{L}` per
  entry with `L` the entry's resolved leaf type, keyed as the set labels
  it. Before the first `init!` every column is empty and typed.
- A column is built behind a function barrier specialized on the entry's
  leaf type and chain alone; the labels reach no compiled body.
  `series` takes its read set `@nospecialize`d and builds the NamedTuple
  of columns last, from the runtime label tuple.
- `series` is a stopped-sim read behind `logged`'s gate,
  `assert_stopped(sim, :series)`.
- `_compile_reads` and `_resolve_reads` take their read set
  `@nospecialize`d. Measured on the closed loop: a new label set over seen
  entries costs 25 to 29 ms with the resolver specialized on the `Reads`
  type and 12 ms without; a new leaf type or chain 25 to 30 ms either way,
  the column loop's own compile. Trim and linearization run the compiled
  `Reader` at runtime and never the resolver, so nothing hot changes.
- `_resolved_type` moves from `src/linearize.jl` 332 to `src/readers.jl`
  beside `resolve_leaf` at 228, unchanged, as the resolution helper it is;
  its three callers at 366, 382 and 410 stay.
- The names `series` and `Series` are provisional until the export audit;
  nothing is exported.

## Out of scope

- A window or slice over a `Series`, a resampler, a plot recipe, a lazy
  column view, a vector method of `port`: each rejected or deferred in
  D-407.
- Any change to `logged`, `latest`, `trace` or the log's retention.
- A mount for a binding's `reads`; any change to `attach!`.
- `design/spec.md`, `decisions.md`, the companions and the tools:
  swept at 06ed3bf. A docs passage the code contradicts is a
  stop-and-report, not an edit. `implementation.md` and `pending.md` are
  the increment's bookkeeping and are edited as named below.
- `design/briefs/`, `design/reports/`, `docs/spec_rewrite/`: records.

## Reading, in order

- `design/decisions.md` 16153 to the entry's end (D-407) and 16083
  to the Position's end (D-406).
- `design/spec.md` §11.2's log subsection, 6985 to 7102; Appendix B's
  post-run row, 13185 to 13200; §14.4's read-selector family, 11461 to
  11562; §14.9's mount, by heading, its first twenty lines. Never read the
  spec whole.
- `design/implementation.md`: the head of "What is real here" down to
  its rule on deviations; the entries `src/sim.jl`, `src/readers.jl`,
  `src/linearize.jl`, `src/dataplane.jl` and `test/imports.jl`;
  "Authoring caveats" whole; "Naming"; "Running the suite".
- `src/sim.jl` 415 to 430 and 2010 to 2070.
- `src/readers.jl` 1 to 20, 222 to 262, 283 to 302, 329 to 347 and 385 to
  455.
- `src/linearize.jl` 320 to 335.
- `src/dataplane.jl` 540 to 545 and 670 to 700.
- `test/test_log.jl` whole; `test/test_readers.jl` 1 to 60;
  `test/fixtures.jl` by the fixtures those two files call; `test/utils.jl`
  48 to 64; `test/imports.jl` whole.
- `examples/test/runtests.jl` 1 to 50 and 96 to 175;
  `examples/src/RedstoneExamples.jl` 1 to 20.

## Stage 1: the series

### `src/readers.jl`

- `_resolved_type` lands after `resolve_leaf`, with its one-line comment,
  and leaves `src/linearize.jl`.
- `_compile_reads` (406) and `_resolve_reads` (425) take
  `@nospecialize(read_set::Reads)`. Their bodies iterate `pairs` and build
  `Any[]`, so nothing in them needed the specialization. The docstring of
  `_compile_reads` already lists its sites; `series` joins them as the
  fourth, a table source over the log.

### `src/sim.jl`

- After `logged` (2034 to 2046) and before `trace`'s docstring (2047): the
  `Series` struct, `series` and `_column`, as the reference file has them,
  docstrings included. `_column` reads its eltype off
  `_resolved_type(_port_type(entry.addr), C)` and fills a preallocated
  `Vector`, so an empty log yields a typed empty column.

### Tests, in `test/test_log.jl`

New testsets at the file's end, after 210, each named with its sections:

- *Columns are the comprehension's values, typed by the leaf* (§11.2,
  D-407): on `fed(Plant(), "u")` or a fixture with an `SVector` port
  (`pose_model()` in `test/test_readers.jl` 48, or one in
  `test/fixtures.jl`), after a run, `series(sim, reads(…))` gives
  `columns.y == [port(s, path, :y) for s in logged(sim)]` for a scalar and
  for an `SVector` port, `eltype(columns.y)` the port's type, and `t`,
  `frame`, `boundary` equal to the snapshots' fields.
- *A leaf step reads one component* (§14.4, D-276, D-407): `"q[2]"` or
  `"pose.v"` gives a scalar column equal to the broadcast over the
  comprehension.
- *Labels and order are the set's* (D-407): `keys(columns)` equals the
  read set's labels in declared order.
- *Empty before the first `init!`, typed all the same* (§11.2, D-407):
  `length(t) == 0` and `eltype` of each column the leaf type.
- *A mount reads what its root-authored twin reads* (§14.9, D-277):
  `at("plant", reads(h = get_face(:y)))` against `reads(h =
  get_output("plant", :y))`, columns equal.
- *Refusals are the resolver's, collected* (§14.4, §13.1, D-406, D-407):
  `get_state` is `:store_selector`; an unknown port `:undeclared` with
  `declares === :output_port` and the port list in declaration order; an
  unknown path a `PathResolution`; a set with three bad reads yields three
  diagnostics in declared order. Use `diagnostics(failure(() -> …))`.
- *The stride thins the columns with the log* (§11.2): under `log_every =
  3`, `length(t) == length(logged(sim))`.
- *A stopped-sim read behind the gate* (§11.3): the same refusal `logged`
  raises mid-run at 169 to 186, with `op = :series`.
- *Labels reach no compiled body* (D-407): after one call,
  `length(Base.specializations(Redstone.series))` is unchanged by a call
  with the same entries under new labels, and
  `Base.specializations(Redstone._column)` grows by one per new entry type
  only. Probe the exact counts before pinning them.

Fixtures stay where their siblings are: a new model, if one is needed, at
top level in `test/fixtures.jl`, grepped across `test/` and `examples/`
first.

- `test/imports.jl`: `Series` joins the `S` run at 35 before `Simulation`;
  `series` joins the `s` run at 73 before `set`.

### The examples

- `examples/test/runtests.jl` 27 to 29: `logged_port(sim, path, name)`
  becomes `series(sim, reads(y = get_output(path, name))).columns.y`, and
  `logged_times(sim)` becomes `series(sim, reads()).t` if an empty read set
  resolves, else stays a comprehension; every pin from 103 to 169 keeps
  its value. The import at 9 to 10 gains `series`, `reads` and
  `get_output`.

### Routing

`src/sim.jl` is the table's last row: the stage runs the gate itself, in
the foreground, under the sandbox flags, and the examples' runner:

    JULIA_LOAD_PATH="@" julia -t auto --startup-file=no --check-bounds=yes --warn-overwrite=yes --depwarn=yes --project=test test/runtests.jl
    julia --project=examples -e 'using Pkg; Pkg.test()'

### Bookkeeping, in the same commit

- `design/implementation.md`: the `src/sim.jl` entry's accessors
  bullet at 828 gains `series` and `Series`, with `_column` as the
  function barrier; the `src/readers.jl` entry gains `_resolved_type` and
  says `_compile_reads` and `_resolve_reads` take their read set
  unspecialized, naming `series` beside the other sites; the
  `src/linearize.jl` entry loses `_resolved_type` if it names it.
- `design/pending.md`: the "A post-run series over the log" bullet
  retires.
- Files to commit: `src/readers.jl`, `src/linearize.jl`, `src/sim.jl`,
  `test/test_log.jl`, `test/imports.jl`, `test/fixtures.jl` if touched,
  `examples/test/runtests.jl`, `design/implementation.md`,
  `design/pending.md`. Never a `Manifest.toml`.

## The cold review

One fresh Opus reviewer over the stage's commit, 06ed3bf read for what it
owes: open-mind stance, probe scripts in the scratchpad, "empty is
acceptable". Dimensions:

- **The docs against the tree.** D-407's four rulings hold of the code,
  each probed: a mounted read set; a store selector refused with the
  remedy; `typeof(columns.y) === Vector{L}` for a scalar, an `SVector` and
  a stepped leaf; the specialization counts of `series` and `_column`
  across label sets. §11.2's paragraph and Appendix B's row describe what
  `series` does.
- **Latency as stated.** `@time` in a fresh process on the examples'
  closed loop reproduces the brief's classes: a new label set over seen
  entries in the low tens of milliseconds, a new leaf type or chain
  likewise, a repeated set under two milliseconds.
- **Nothing hot changed.** The allocation pins on `gather_reads` in
  `test/test_readers.jl` and trim's per-iteration pins in
  `test/test_trim.jl` hold after the two `@nospecialize`.
- **Naming** over every touched line; `test/imports.jl` sorted where it
  was sorted; no local shares a name with a function its module sees.
- **Mutants on a scratch copy**, each named test going red: `_column`
  allocating `Vector{Any}`; `series` calling `_compile_reads` with the
  default source; `series` skipping `assert_stopped`; the `boundary`
  column built from `frame`; `@nospecialize` dropped from `series`; the
  columns' NamedTuple keyed in sorted order. A surviving mutant is a
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
at top level. Report: the commit hash, the files touched, both runners'
results with the assertion count before and after, the specialization
counts probed, and every deviation from this brief with its reason.
