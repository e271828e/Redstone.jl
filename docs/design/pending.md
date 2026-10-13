# Pending

What `src/` and `test/` still owe the design, and the questions the design
leaves open, split by whether the first release waits on them. The first
section also lists the release work the spec does not ask for. Every item
here is known and recorded; none is abandoned. `check_refs.jl` and
`check_rows.jl` read this file, so every `§N` and `D-nnn` below resolves or
the tools go red.

## Before the first release

The bullets stand in working order, the first one next. The audit comes
last, because it sweeps the whole surface and the library and the bridge
both add names.

- **The inspector**, one browser client in four stages, in working order:
  the static inspector over the descriptor, whose first session is the
  descriptor's schema and `descriptor` together, at the tip of increment
  67's `Structure` refactor (the record's "Working order"); the bridge, an
  ordinary
  device serving the handle over a socket; the live inspector, values on
  the diagram; and the cockpit, panels over the bridge. The built-in Julia
  GUI is parked (D-310). The record is
  `docs/design/inspector/initial_design.md` (not normative), which carries
  each stage's answered questions and open list. What the spec owes, each
  ruled when its stage reaches it: `descriptor` and the carrier change (stage
  1); the handle's control verbs and the log-tail view (stage 2); and
  §11.7's panel convention amended from a drawing method to a panel
  description, with the GUI package's half of D-270's convention assigned
  to the client (stage 4).
- **The exported-name audit.** The export list is to be decided deliberately
  rather than by accident, and until the audit runs the module exports
  nothing (D-226). The audit is a full-surface sweep under the four-class
  naming convention (§8.1, D-144): every API name is exported, renamed or
  left unexported.
  - **The extension-only surface**, where *unexported* is preferred. It has
    three parts: the declaration and stage family of the import list (§8.1),
    the larger half, settled on every component file's first line; the
    binding interface `claims`/`reads` (§11.6) with the side traits
    `is_input`/`is_output`/`is_greedy`, `map_input`/`map_output` sitting
    outside the question as loop-idiom conventions the framework never
    calls; and the device contract `init!`/`loop`/`shutdown!`/`unblock!`,
    extended by `import` or qualified name, `Base.show`-style.
  - **The operator side.** `condition`, `fragment`, `at` and `combine`
    (§14.2) are generic names that share a namespace with user domain code,
    and whether the condition algebra ships behind a submodule is the
    packaging question.
  - **Five boundary cases** the convention does not settle are flagged for
    the sweep, none a defect of its list:
    - `input_faces`/`output_faces` (§13.3), build primitives named by nouns
      where class (4) asks for plain verbs, mitigated by being
      framework-facing; the pun on the `_types` declarations that D-144
      flagged went with their rename to `u_types`/`y_types` (D-267);
    - `loop` (§11.6), a mutating task body spelled as a bare noun among its
      verb-`!` siblings `init!`/`shutdown!`/`unblock!`; with `run!` taken
      and the "loop body" prose entrenched, it needs the whole-surface view;
    - the bare-noun accessors `trace(sim)`, `latest(sim)`,
      `binding(handle)`, `phase_bodies(sim)`, value selectors outside class
      (2)'s `get_` rule; `trace` is the sharpest, its kill-switch
      `trace = false` and post-run accessor `trace(sim)` being one name in
      two senses, the overload pattern D-122 and D-144 retire;
    - whether class (1) needs an explicit exemption for predicate traits
      (`is_input`, `is_greedy`).
    - whether an unexported name on the extension-only surface may coincide
      with a public Base name when the spec's verb is that word, reached by
      qualified name or explicit import; `peek` (§11.7, D-270) is the first
      instance, the panel kit's verb beside `Base.peek`.

### Outside the spec

Release work the spec does not ask for, in no order. Where an item changes
what the spec says, the spec edit is part of the item.

- **An example model**, large enough to measure on. It gives the
  compile-time and garbage measurements a model to run on, and the cockpit
  one to drive. The compile-cost report's harness
  (`docs/reports/20261001_compile_cost_reeval/probes`) drifted at D-313 and
  D-314: `Group` lives in `Redstone.Blocks` and its keywords are the
  declaration names; correct a copy before measuring, and leave the report as
  it is.
- **A tutorial** that takes a newcomer from a component to a run and a plot.
- **The spec's readability rewrite.** Chapters 1 to 10 are done. The
  other chapters follow `docs/spec_rewrite/recipe.md`, and that directory's
  README tracks them. Until a chapter's turn comes, it keeps the old markers.
  Chapter 6 left these for the owner:
  - whether the locality law is machine-checked or convention. §6.1 enforces
    the one-level rule in `resolve` (D-207) and names it the locality law
    (D-065). §14.2 says the law "is convention" and that this carries over
    from §6.1, as D-065's Rejected list does. Recommended: rule the wiring
    instance machine-checked and the fragment law's ownership clause
    convention, if it survives D-207's second bullet at all; then annotate
    D-065 and fix §14.2 in chapter 14's rewrite.
  - four §6 sentences with no live entry behind them, each uncited until
    ruled: the walk violation's payload and remedies (only superseded D-167
    records them; Appendix C states them), unconnected inputs as a build
    error with no silent defaults (two Rejected lists point back at §6.1),
    that local fan-out is free (§4.3 says so too), and that contributors
    publish in the common body frame (Flight.jl's convention).
  Chapter 5 left these for the owner. Each sentence stays plain and uncited
  until ruled; the evidence is group C of chapter 5's `rulings_batch.md`,
  which `git show ffd659f:docs/spec_rewrite/ch05/rulings_batch.md` recovers.
  - five §5 rulings no entry records, each recommended for an entry:
    stage-2 conservatism, unless D-006's all-inputs feedthrough is read as
    carrying it (the glossary and `pid_anti_windup.md` rely on it);
    evaluating the RHS means running the sweep, with no incremental
    re-evaluation (§5.3, restated by §10.3 and §10.4); the unit delay's tier
    caveat, which §5.5 and §13.7 each state citing only the other, with
    algebraic balances inside a component as its scope note; the tracer's
    two modes, what it seeds and its blind spot (§5.6); and stage discovery
    by method existence (§5.2), which only superseded D-165 records.
  - five more recommended as needing no entry: when stage 1 exists (it
    follows from D-252), `BundleFieldError`'s three classifications and the
    dead hop's payload form (Appendix C describes both payloads), the name
    "tracer activation" (§9.4), and why `x_projection` stays positional.
  Chapters 1 to 4 left these for the owner. Each sentence stays as written,
  plain and uncited for the point in question, until ruled; the evidence is
  group C of their `rulings_batch.md`, which
  `git show 4214370:docs/spec_rewrite/ch01-04/rulings_batch.md` recovers.
  - a mutable cache "in the consumer's state" (§4.4), a home D-231, D-183
    and D-342 close. No build check backs the bullet either, since the leaf
    walk never enters a field handle. Recommended: strike the clause,
    leaving "the interpolant is restructured to be pure", and point the rule
    at §4.1.
  - "every component provides two output stages" (§4.1, §5.2, §5.4 and the
    glossary), untrue of an assembly. Recommended: "every leaf", a wording
    correction under D-006 at all four places.
  - five rulings no entry records, each recommended for an entry: the
    signal requirement, immutability plus frozen references (§4.1; D-243
    and D-231 cite §4.1 back); the rule of meaning's "do not overlap"
    (§3.1), read as the meanings not overlapping, since a commanded
    continuous reset uses both mechanisms (D-141); "`m` changes only through
    event handlers" (§3.1, §10.4), scoped to a run, since a condition sets
    it before one (§14.1); field-addressed staging as a recorded guarded
    addition (§4.3 and the glossary); and the write-side rule's cadence half
    (§4.3; D-045 records only the writers half).
  - four more recommended as needing no entry: the composed granularity
    principle (§4.3), the five design criteria and "recorded with its shape"
    (§1 and the glossary), "It has no dynamics of its own" (§3.3), and
    "well-defined semantics" (§2.1).
  - a companion fix, not a ruling: section 1 of
    `event_visibility_walkthrough.md` pictures a cell as a reference to an
    immutable value, which the spec does not say; its heading and code
    comments need recasting in value terms.
- **Package registration.**
- **A precompile workload** for the generic machinery a cold process
  pays, about 9 s whatever the model (§9.7).

## After the first release

Each is additive, so it can land later without breaking user code.

- **Publication's garbage** (§7.5, §10.7, §11.2, D-269). A new snapshot and
  table copy per frame are by design: §11.2 leaves published snapshots to
  the GC, so a run never avoids it. The requirement that sets the target is
  a hardware-in-the-loop run: a paced run in which no collection pause may
  break a frame deadline, at the expense of logging. Publication cannot be
  switched off for it, since a device reads the model through the snapshot.
  On a small model `publish!` allocates about 784 B per frame, plus 8 B per
  `Float64` cell and about 272 B per rostered device, and the status vector
  is two thirds of it (`docs/reports/20261002_tuple_walks/report.md`,
  section 7). A proper analysis on a model of real size comes first, with
  the pause length measured against the frame deadline, then a ruling beside
  D-269, then the build. The analysis should assess:
  - **Sharing status records.** `_status` builds a fresh vector of writer
    records at every publication. An unchanged record could be shared with
    the previous snapshot. A device's heartbeat changes every frame, which
    makes this a design question.
  - **A scheduled young collection.** §7.5 names `GC.gc(false)` at frame
    boundaries, and nothing in `src/` builds it. The candidate: the pacer's
    wait collects when enough garbage has built up and the time to the next
    deadline exceeds the recent p99 pause with a margin. Unpaced runs and
    `step!` skip it, and `PacerStatus` reports the pauses.
  - **What limits a scheduled collection.** The trigger is process-wide, so
    a device that allocates can still start a collection mid-frame. The GUI
    will be the main such device, so the analysis runs with it attached.
    With the log on, thinned snapshots die in the old generation, where only
    a full collection reclaims them. The fixed cost grows with tasks, live
    heap and GC threads.
  - **Device-side garbage.** A device's own task allocates too. Staging
    rebuilds every batch dynamically (`_normalize`), at any width. The
    collection trigger is process-wide, so the analysis counts this beside
    publication's garbage.
- **The NLopt fallback** (§14.8, H 4.5): `NLoptBackend(:LN_BOBYQA)` as a
  package extension, the squared and normalized objective at `stopval = 1`,
  and the nominal-activation loop it would run on.
- **Log and trace persistence.** The in-memory artifacts are settled (§11.2,
  §11.5) and nothing on-disk is. The on-disk questions wait for real users
  to ground them: the HDF5 export scope (the whole snapshot log, or selected
  subtrees); field-handle summarization over retained snapshots, the
  post-processing entry point, as `getproperty`-style navigation of a run's
  history; and the trace file format, which doubles as the reproducibility
  carrier and whose positions the replay pointers name (§13.4). §4.4 and
  §7.5 state the loggers' skip-or-summarize rule for field handles with no
  entry; it is ruled with the summarization question.
  - **The trace header's deployment half.** The checkpoint's `deployment`,
    which the trace header carries, holds the whole `Deployment`, and through
    it the `Build` with the component instances, into an artifact §11.5 calls
    primary data; the deployment's `==` excludes the build, so replay never
    compares it. Whether the header should hold the build-free half is a
    D-254 question, to be ruled when this deferral lifts.
  - **§7.1's FlightCore-era names.** §7.1's bullet on the flat vector names
    OrdinaryDiffEq and HDF5 logging among its users. §10.2 dropped
    OrdinaryDiffEq as a dependency and the HDF5 export is undecided, so the
    bullet is reworded when this deferral lifts.
- **The library's remaining candidates.** Whatever of the inventory in
  `docs/design/companions/library_inventory.md` is unbuilt at release,
  each block built when wanted (§13.7, D-313).

## Deviations

What is built in a shape the spec's is not. Transactional: the commit
introducing a deviation adds its bullet, and the one retiring it deletes it.
Where the code's shape is coherent and the spec may be what moves, the call
is the user's; a ruling lands docs-commit-first, then the bullet retires or
the code conforms.

- **The quoted cycle and bundle diagnostics** (§5.2, §5.4, §5.6). The spec
  quotes "cycle through `systems/aero` is artificial at port level — split
  the component, or narrow the neighbor's contract", "insert a state" for a
  genuine cycle, and "`x_deriv` of `Foo` destructures `m`, but `Foo`
  declares no `m_init`". `src/diagnostics.jl` renders richer text that
  agrees in substance: it names `split m` and the fallback-branch condition,
  offers "a state, a stage-1 (`y_state`) port, or a `UnitDelay`" for a
  genuine cycle, and names the component by its path rather than its type.
  Recommended: conform the spec's quotes to `src`'s wording, after the user
  rules whether the bundle diagnostic names a path or a type.
