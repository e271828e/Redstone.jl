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

- **The core work ahead of the inspector's increment 10**, settled in the
  design session of the deployment overlay on 2026-11-19 and 2026-11-20,
  in four parts in this order. The session's record is
  `RedstoneInspector.jl/design/deployment_overlay.md`, and its answer 17
  lists the five log entries the parts owe. Each part lands as a spec and
  log commit followed by its code. All four have landed: the notation, the
  grid report's placement, the descriptor and `show(::Deployment)` in the
  notation (D-464, D-466, D-467, D-468, D-471). Part three's cold review
  has closed and its fixes have landed, with D-470 among them. Its record
  is
  `design/increments/20261120_descriptor_content/notes_descriptor_content.md`,
  whose section 12 holds the review. Part four landed on 2026-11-21 while
  the user was away. Its record is
  `design/increments/20261121_show_deployment/notes_show_deployment.md`,
  whose section 3 lists the session's own decisions and whose section 6
  lists what it leaves open for the user. The arc waits for the user's
  diff-verify and the push. The session left open whether the
  build refuses a pool that admits no deployment. That was ruled on
  2026-11-20 and has landed ahead of part two: the build refuses a
  structure that no deployment binds, by one trial binding (§9.1, §9.2,
  D-465). `src/assembly.jl` was split for it, and the grid arithmetic now
  lives in `src/structure.jl`. The record, with its findings, the items
  it leaves open for the user and the grid report's part, is
  `design/increments/20261120_structure_trial/notes_structure_trial.md`.
- **The tutorial's loose change**, owed before its increment 3 by L12 and
  L23 of `design/increments/20261119_tutorial_pages/notes_tutorial_pages.md`:
  a compact `show` for `Simulation`, `Series`, `TrimReport` and
  `Linearization`; a `Series` that forwards its columns as properties
  (§11.2, D-474); and a `Linearization` of plain arrays, labeled through a
  ComponentArrays extension (§14.10, D-475), which answers friction item 10
  of that record. It grew past a loose change and runs as one small
  increment with no brief. Stage reached: the design session of 2026-11-21
  settled it, the prototype is built, and the session then worked on alone
  while the user was away. The record is
  `design/increments/20261121_tutorial_loose_change/notes_tutorial_loose_change.md`,
  whose section 2 holds the user's rulings, section 7 the session's own
  decisions for the user's review, and section 8 the four printed forms,
  which the user has not yet judged. It has landed, unpushed: the docs as
  `d382b00`, the code as `23458b8` and the cold review's fixes as
  `7410031`, with the gate at 10870 of 10870. The review has closed, and
  its record is section 11. What remains is the user's: the printed forms,
  the session's decisions, the diff-verify and the push. The inspector's
  increment 10 needs the first bullet's parts one to three pushed, and
  nothing in it reads what this change touches.
- **The inspector, stage 1**: the static inspector over the descriptor,
  built in the separate repo `RedstoneInspector.jl`, whose
  `design/pending.md` holds its work order and its open items, and whose
  `design/roadmap.md` stages its eleven increments. What this repo owes it
  before the release is the first bullet, and after it the later stages.
- **The tutorial and the README.** The tutorial builds the longitudinal
  aircraft from scratch in nine chapters, each ending at a named function
  of the examples package: the plant, trim, linearization, a first loop,
  the autopilot, the engage switch, the approach and touchdown, replay and
  checkpoint, and the LQR tracker as an optional last chapter. It teaches
  concepts through whole code beside real output and leaves the syntax to
  the reference. The deployment is taught where each quantity first
  matters: the frame in chapter 1, the algorithm and `h_max` in chapter 3,
  the base tick in chapter 4. The README keeps its quick start, shows three
  of the chapters condensed with the plot and the diagram, and links to the
  tutorial; the interactive part is the binding's few lines until the live
  inspector gives a recording. Writing the tutorial is what finds the API's
  friction, which is why it precedes the API audit. The work is an arc of five
  increments: the example's main path, the docs scaffold with chapters 1 to
  3, chapters 4 to 8, the tracker, and the closing with the README. Stage
  reached: increments 1 and 2 are pushed. Increment 1's state, rulings,
  pins and friction list are
  `design/increments/20261118_tutorial_example/notes_tutorial_example.md`,
  with the brief and the prototype's patch beside it. Increment 2's
  record is
  `design/increments/20261119_tutorial_pages/notes_tutorial_pages.md`,
  with the patch beside it and no brief. Increment 3 waits for the
  tutorial's loose change, the second bullet. The plan, the arc's
  rulings, the open decisions and the rules for the pages are
  `design/increments/roadmap_tutorial.md`.
- **The API audit.** The API is reviewed as a whole before the release, in
  two parts, in this order. It comes after the tutorial, which surfaces the
  names a user types and the friction a user meets.
  - **The friction review.** Every item the tutorial arc records is ruled:
    fixed, documented, or declined with its reason. The items sit in each
    increment's notes, by R17 of `design/increments/roadmap_tutorial.md`,
    and the arc's closing increment collates them. The first nineteen are
    section 5 of
    `design/increments/20261118_tutorial_example/notes_tutorial_example.md`,
    eleven more are section 6 of
    `design/increments/20261119_tutorial_pages/notes_tutorial_pages.md`,
    and one more, on `lqr_gains`' weights, is section 4 of
    `design/increments/20261121_tutorial_loose_change/notes_tutorial_loose_change.md`.
    A fix lands as a loose commit or as an increment of its own, and before
    the exported-name audit, since it can add or rename a name.
  - **The exported-name audit.** The export list is to be decided deliberately
    rather than by accident, and until the audit runs the module exports
    nothing (D-226). The audit is a full-surface sweep under the four-class
    naming convention (§8.1, D-144): every API name is exported, renamed or
    left unexported. It also settles which fields are public, since `Model`'s
    docstring lists every field, `exec` and `frame_diag` included, while
    `Deployment` and `Schedule` list none and tests read `deployment.h`. It
    comes after the tutorial, which surfaces the names a
    user types, and after the library has added its names; the examples are
    a package of their own and add none. Two things wait on it. The
    descriptor writer's `@ref` pass targets exported bindings alone, so it
    rewrites no link until the audit exports some (§13.9, D-467). And
    `docs/make.jl` lists `modules = [Redstone]`, so `checkdocs = :exports`
    checks nothing in `Redstone.Library` even then, until the list names it.
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
    - **What Appendix B's rewrite left for the audit.** B lists the names
      the examples import, and some names no spec sentence spells:
      `logged(sim)`, `termination(sim)`, `port(snapshot, path, name)`, the
      `Simulation` forms of `port`, `state` and `modes`, and `Model(build)`
      and `Model(root)`. `reads` is both the binding trait `reads(b)` and the
      read-set constructor `reads(; selectors...)`, one name in two senses.
      And D-226 makes a name public by standing on B, so a diagnostic kind is
      public only where B names it; whether Appendix C's kind set is public
      as a whole is the audit's to settle.
    - **Six boundary cases** the convention does not settle are flagged for
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
      - `labeled` (§14.10, D-475), a participle where every class asks for a
        noun phrase or a verb; it converts a `Linearization` to its labeled
        form and mutates nothing.
- **The API docstrings' two later passes.** The sweep to the manual's
  conventions landed (record `design/increments/20261027_docstring_sweep/notes_docstring_sweep.md`,
  convention `design/rules/docstring_rules.md`). Two passes remain. The
  examples pass gives each entry point that earns one a `jldoctest` block
  under the convention's rules 35 to 38. `src/` holds one, on `Group`'s
  constructor, landed ahead of the pass with D-473 as its pilot. The docs
  build is shown to run it: a wrong expected output failed the build. The
  pass follows the tutorial, which shows the calls a user makes, and the
  exported-name audit, since the module exports nothing until then (D-226)
  and a block written earlier imports every name it uses, as the pilot
  does. The signature-and-link pass
  follows the audit's renames, since a rename costs a signature line and
  the Documenter build catches a stale link. Unexported names keep their
  docstrings as they are.
- **The `§` references in diagnostic messages.** Every message ends by
  citing a spec section, which a user without the spec cannot follow. The
  pass drops each reference or replaces it with a pointer into the
  documentation, kind by kind. Messages are presentation (D-058), and only
  `test_diagnostics.jl`'s rendering testset pins their text. It follows the
  exported-name audit, whose renames reach the messages too. The pass also rewords
  `AlgebraicCycle`'s verdict: a real verdict that rests on a member traced
  structurally reads "presumed real", since the tracer assumes every hop
  through such a member (§13.8). The classification stays `:real`.
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
- **The user guide and the API reference.** The reference is the Documenter
  build under `docs/`, deployed from master and already live over the
  current docstrings, which is why the docstrings precede the release. The
  guide grows from the tutorial and the companions.

## Unordered

Items with no order among them. Nothing prevents any of them before the
first release, but each is low priority, additive, and lands without
breaking user code, and each may benefit from user feedback first.

- **A schedule row's `Δt` is not the float nearest its exact period**
  (§9.2, §10.5). `bind_schedule` writes `D * Float64(Δt_base)`, so three
  base ticks of `1//10` read `0.30000000000000004`, which `show(::Schedule)`
  prints and every discrete bundle receives. The exact value is `D·Δt_base`
  as a rational, which `show(::Deployment)` prints (D-471). Found by the
  descriptor increment's parity check, whose client copied the float
  product.
- **A framework throw inside a step is framed as a component's** (§13.4).
  A `StepError`'s message names the cursor as the catch found it, so a
  throw from the framework's own step code reads as the last stage entered.
  Seen once, by the descriptor increment's fixer, with D-470's refusal
  removed: a bouncer deployed at `localization_tol = Inf` threw an
  `InexactError` in `_crossing` (`src/frame.jl`), and the message read "in
  `c` x_deriv, arrival sweep of the frame from boundary 3". The `cause` and
  its stack trace were right. D-470 closes that path, so no input reaches
  the framing today, and any later throw in the framework's step code
  would. Whether the message tells a throw inside a stage body from one
  outside it is open. Evidence:
  `design/increments/20261120_descriptor_content/probe_localization_inf.jl`.
- **Publication's garbage** (§9.8, §10.7, §11.2, D-269). A new snapshot and
  table copy per boundary are by design: §11.2 leaves published snapshots to
  the GC, so a run never avoids it. The requirement that sets the target is
  a hardware-in-the-loop run: a paced run in which no collection pause may
  break a frame deadline, at the expense of logging. Publication cannot be
  switched off for it, since a device reads the model through the snapshot.
  On a small model `publish!` allocates about 784 B per boundary, plus 8 B per
  `Float64` cell and about 272 B per rostered device, and the status vector
  is two thirds of it (`design/reports/20261002_tuple_walks/report.md`,
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
  `design/reports/20261016_ctrlc_julia_114/report.md`. It is taken up when 1.14
  branches or its cancellation names become public, whichever comes first.
  - **The pause wait's hang at one thread.** A real SIGINT into the pause
    wait at `-t 1` with a device rostered hangs the run: 1.13 throws the
    interrupt into whichever task is current on thread 1, which is not the
    parked loop (§12.4, D-268). Found by the interrupt increment's cold
    review and reproduced at `0217a1c`, before that increment. Evidence:
    `design/increments/20261105_interrupt_status/probe_pause_wait_t1.jl`.
    Under 1.14 the pause wait is itself a cancellation point, so the case
    does not exist there; whether it is fixed on 1.13 is settled with the
    floor when this item lands.
- **`Dual` allocation coverage for the library** (§9.8, §13.7). The
  allocation testsets in `test_library.jl` measure phase bodies at `Float64`
  alone; the suite's one `Dual` measurement is `test_executor.jl`'s over
  `bare_ports_world`. Extend each continuous component's testset with that
  test's loop over `(Float64, LinearizeDual)`. A `Dual` model freezes the
  discrete tier and compiles events out, so the sweep covers the continuous
  components' sweep and `x_deriv` bodies and says nothing about the discrete
  ones. The standing rule for new library components is
  `rules/brief_rules.md`'s, under its section on library components.
- **A component backed by an external library, demonstrated** (§8.2,
  §14.10, D-266). No component in `src/`, `test/` or `examples/` calls a
  foreign function, so the FFI door of §8.2 is designed and has never been
  exercised. Add to the examples package the twin of one discrete
  controller behind the same contract, its stage bodies calling a C or Rust
  library through `@ccall`, with a test that compares the two on one input
  trace within a tolerance. The external code takes its state in and
  returns it, since a stage mutates nothing (§4.1). The demonstration
  answers three questions: how the build's checks treat a stage whose body
  is a foreign call, whether the wrapper steps without allocating, and what
  trim and linearization need from it, pinned inputs or a local derivative
  rule. Asked for by the design session of the Simulink explainer on
  2026-11-21, whose page describes the workflow as not built yet until
  this lands.

## Deviations

What is built in a shape the spec's is not. Transactional: the commit
introducing a deviation adds its bullet, and the one retiring it deletes it.
Where the code's shape is coherent and the spec may be what moves, the call
is the user's; a ruling lands docs-commit-first, then the bullet retires or
the code conforms.
