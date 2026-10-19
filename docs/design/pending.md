# Pending

What `src/` and `test/` still owe the design, the release work the spec
does not ask for, and the questions the design leaves open, in two lists:
the work order, and the items with no order. Every item here is known and
recorded; none is abandoned. `check_refs.jl` and `check_rows.jl` read this
file, so every `§N` and `D-nnn` below resolves or the tools go red.

## The work order

The bullets stand in working order, the first one next. The first release
is an item of the list, and the items after it are ordered too. Where an
item changes what the spec says, the spec edit is part of the item.

- **The inspector, stage 1**: the static inspector over the descriptor,
  whose first session is the descriptor's schema and `descriptor` together,
  at the tip of increment 67's `Structure` refactor (the record's "Working
  order"). The built-in Julia GUI is parked (D-310). The record is
  `docs/design/inspector/initial_design.md` (not normative), which carries
  each stage's answered questions and open list. What the spec owes at this
  stage, ruled when it is reached: `descriptor` and the carrier change. The
  later stages stand after the release, below.
- **The tutorial and the README.** The tutorial takes a newcomer from a
  component to a run and a plot, one chapter per layer of the example
  model. The README keeps its quick start, shows three of the layers
  condensed with the plot and the diagram, and links to the tutorial; the
  interactive part is the binding's few lines until the live inspector
  gives a recording. Writing the tutorial is what finds the API's friction,
  which is why it precedes the audit.
- **The exported-name audit.** The export list is to be decided deliberately
  rather than by accident, and until the audit runs the module exports
  nothing (D-226). The audit is a full-surface sweep under the four-class
  naming convention (§8.1, D-144): every API name is exported, renamed or
  left unexported. It comes after the tutorial, which surfaces the names a
  user types, and after the library has added its names; the examples are
  a package of their own and add none.
  - **The extension-only surface**, where *unexported* is preferred. It has
    three parts: the declaration and stage family of the import list (§8.1),
    the larger half, settled on every component file's first line; the
    binding interface `claims`/`reads` (§11.6) with the side traits
    `is_input`/`is_output`/`is_greedy`, `map_input`/`map_output` sitting
    outside the question as loop-idiom conventions the framework never
    calls; and the device contract `init!`/`loop`/`shutdown!`/`unblock!`,
    extended by `import` or qualified name, `Base.show`-style.
  - **The operator side.** `condition`, `set`, `at` and `combine`
    (§14.2) are generic names that share a namespace with user domain code,
    and whether the condition algebra ships behind a submodule is the
    packaging question.
  - **Appendix B's omissions.** Names the examples import that Appendix B
    does not list although their sections make them public:
    `AbstractComponent`, `Absolute`, `get_deriv`, `logged`, `termination`,
    `EndTimeReached` and `ModelRequestedStop`. The audit lists them or
    renames them.
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
- **The first release.** Registration in General, the tag, and the
  announcement, in that order. Registration is quiet and the announcement
  is the public moment, so the announcement waits for everything above.
- **The inspector, stages 2 to 4**: the bridge, an ordinary device serving
  the handle over a socket; the live inspector, values on the diagram; and
  the cockpit, panels over the bridge. What the spec owes, each ruled when
  its stage reaches it: the handle's control verbs and the log-tail view
  (stage 2); and §11.7's panel convention amended from a drawing method to
  a panel description, with the GUI package's half of D-270's convention
  assigned to the client, and a ruling on §11.7's "assembly panels compose
  children by path", a constraint on that half with no entry (stage 4).
- **The spec's readability rewrite.** Chapters 1 to 13 are done. The
  other chapters follow `docs/spec_rewrite/recipe.md`, and that directory's
  README tracks them. Until a chapter's turn comes, it keeps the old markers.
- **The normative kernel**, after the rewrite lands. Settled on 2026-10-14:
  the spec and the code are redundant where the spec describes mechanism,
  and that description is what costs the bookkeeping on every increment and
  leaves an implementer unsure which sentences are decisions. The code
  already fulfils the spec (this file holds additions, not debt), so once
  chapter 14 and the appendices are rewritten the spec splits into three
  homes. The kernel keeps every bold ruling with one line of context,
  its D-citation and a pointer to the test that pins it, in Appendix A's
  shape; the cross-cutting chapters on evaluation order and time (§5, §10)
  stay in prose. Description moves beside the code, into docstrings,
  comments and `implementation.md`, where a diff review catches drift in one
  place. The human-facing views are generated: an API reference from the
  docstrings, diagrams of the build pipeline and the frame, the companions as
  tutorials. The decision log is untouched. The rewrite comes first because
  its survey and track 2 are the classification: a bold with an entry is the
  kernel's unit, so extraction from a rewritten chapter is near mechanical.
  From chapter 13 the survey tags each descriptive passage with the source
  file that realizes it, which is the migration list; chapters 1 to 12 are
  tagged at extraction. Chapter 13's list is part H of
  `docs/spec_rewrite/ch13/survey_1.md` and `survey_2.md` at `ae63ca9`. A
  ruling about the design's shape rather than runtime behavior has no
  natural test, so its kernel line points at the build-time
  check or diagnostic that enforces it, and where none does, carries its
  D-citation alone. Chapter 12's rulings with no entry beyond D-400 to
  D-404, the pause block's condition, `checkpoint`'s latest-snapshot test
  and the B78 rows of `rulings_batch.md` at `eb1d832`, are such description and get none.
  The kernel extraction replaces the report that closes
  `docs/spec_rewrite/`, whose lessons already live in its recipe.
- **The user guide and the API reference.** The reference is the kernel's
  generated view of the docstrings. The guide grows from the tutorial and
  the companions, and is written once the kernel has settled what the
  docstrings carry.

## Unordered

Items with no order among them. Nothing prevents any of them before the
first release, but each is low priority, additive, and lands without
breaking user code, and each may benefit from user feedback first.

- **Publication's garbage** (§9.8, §10.7, §11.2, D-269). A new snapshot and
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
  - **A scheduled young collection.** §9.8 names `GC.gc(false)` at frame
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
  carrier and whose positions the replay pointers name (§13.4). §11.2
  states the loggers' skip-or-summarize rule for field handles with no
  entry; it is ruled with the summarization question.
  - **The trace header's deployment half.** The checkpoint's `deployment`,
    which the trace header carries, holds the whole `Deployment`, and through
    it the `Build` with the component instances, into an artifact §11.5 calls
    primary data; the deployment's `==` excludes the build, so replay never
    compares it. Whether the header should hold the build-free half is a
    D-254 question, to be ruled when this deferral lifts.
  - **The flat vector's FlightCore-era names.** `flight_case_studies.md`
    section 1, which took §7.1's bullet on the flat vector, names
    OrdinaryDiffEq and HDF5 logging among its users. §10.2 dropped
    OrdinaryDiffEq as a dependency and the HDF5 export is undecided, so the
    bullet is reworded when this deferral lifts.
- **The operator interrupt on Julia 1.14** (§12.4, D-132, D-394). Julia
  master delivers Ctrl-C as a cancellation, not an `InterruptException`, so
  the mechanism of §12.4 stops working while its contract can stay. The
  break, a candidate design and its open questions are
  `docs/reports/20261016_ctrlc_julia_114/report.md`. It is taken up when 1.14
  branches or its cancellation names become public, whichever comes first.
- **The library's remaining candidates.** Whatever of the inventory in
  `docs/design/companions/library_inventory.md` is unbuilt, each block
  built when wanted (§13.7, D-313).

## Deviations

What is built in a shape the spec's is not. Transactional: the commit
introducing a deviation adds its bullet, and the one retiring it deletes it.
Where the code's shape is coherent and the spec may be what moves, the call
is the user's; a ruling lands docs-commit-first, then the bullet retires or
the code conforms.

None open.
