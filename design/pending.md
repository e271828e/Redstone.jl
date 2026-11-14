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

- **Variable-step integration.** The frame and the integration step become
  separate quantities. The step is the `Model`'s to decide: it never
  crosses a frame top or a due instant and is never longer than the
  deployment's optional `h_max`. A fixed-step method takes the span between
  two such instants in equal steps, and an adaptive one under its error
  controller's proposal (§2.1, §2.2, §10.2, §10.4, §10.5). The plan, the
  settled rulings and the open decisions are
  `design/increments/roadmap_variable_step.md`, in seven increments. The
  update changes the deployment keywords, so it precedes the exported-name
  audit and delays the release.
  - **Landed:** the deployment surface, increment 90 (D-442, D-443); the
    three lattices, 91 (D-444 to D-447); the step bound, 92 (D-449,
    D-450); the seam protocol, 93 (D-452); exact time, 95 (D-454 to
    D-457); and exact arithmetic on the time surface, 96 (D-458, D-459),
    the fallout of the audit
    `design/reports/20261113_exact_arithmetic/report.md`. Each one's
    record is its folder under `design/increments/`.
  - **Waiting for the user from increment 96:** the diff of the arc from
    `daaeccf` and the push. The user ratified the overnight rulings R1 to
    R20 of `design/increments/096_exact_arithmetic/notes_increment_96.md`
    on 2026-11-14.
  - **Next: the first adaptive backend**, the roadmap's increment 4, with
    `h_min` and the attempt budget on the `Deployment`. Its rulings are the
    roadmap's section "Ruled on 2026-11-12". They cover the two things the
    seam protocol left open, which this increment builds: nothing bounds a
    step's attempts or the steps of a span, and a proposed step can end a
    sliver short of the span's end.
  - **Ruled from the three lattices** by the user on 2026-11-11, on the
    open points of
    `design/increments/091_three_lattices/notes_increment_91.md`. Every
    ruling has landed: the unbounded run that ends on `frame!`'s refusal,
    in D-450 and its Rejected list; the `settled!` hook's unenforced
    contract, in an annotation of D-447; D-448's rename, in
    `rules/log_rules.md` rule 2; a loop error outside the frame, in §13.4
    and §13.5; and the rest with increments 92, 95 and 96. One ruling has
    no other record: the reconstructed Rejected lists of D-445 to D-447
    stand as written.
- **The inspector, stage 1**: the static inspector over the descriptor,
  built in the separate repo `RedstoneInspector.jl`, whose
  `design/pending.md` holds its work order and its open items, and whose
  `design/roadmap.md` stages its eleven increments. What this repo owes it
  is the later stages after the release. Its next pin on the core takes
  three changes made here, detailed on its bullet "The class value and the
  module's name at the next pin": the descriptor's class value `"leaf"`
  became `"primitive"` with no format bump, its six construction sites
  move from `h =` to `Δt_frame =` (D-443), and the library is
  `Redstone.Library` (D-453), so the fixtures regenerate.
- **The API docstrings' two later passes.** The sweep to the manual's
  conventions landed (record `design/increments/20261027_docstring_sweep/notes_docstring_sweep.md`,
  convention `design/rules/docstring_rules.md`). Two passes remain: an examples pass
  after the tutorial, and a signature-and-link pass after the audit's
  renames, since a rename costs a signature line and the Documenter build
  catches a stale link. Unexported names keep their docstrings as they are.
- **The tutorial and the README.** The tutorial takes a newcomer from a
  component to a run and a plot, one chapter per layer of the example
  model. The README keeps its quick start, shows three of the layers
  condensed with the plot and the diagram, and links to the tutorial; the
  interactive part is the binding's few lines until the live inspector
  gives a recording. The closed loop's references are root inputs, so the
  tutorial can also linearize from `h_ref` to the altitude. Writing the
  tutorial is what finds the API's friction, which is why it precedes the
  audit.
- **The exported-name audit.** The export list is to be decided deliberately
  rather than by accident, and until the audit runs the module exports
  nothing (D-226). The audit is a full-surface sweep under the four-class
  naming convention (§8.1, D-144): every API name is exported, renamed or
  left unexported. It also settles which fields are public, since `Model`'s
  docstring lists every field, `exec` and `frame_diag` included, while
  `Deployment` and `Schedule` list none and tests read `deployment.h`. It
  comes after the tutorial, which surfaces the names a
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
  - **What Appendix B's rewrite left for the audit.** B lists the names
    the examples import, and some names no spec sentence spells:
    `logged(sim)`, `termination(sim)`, `port(snapshot, path, name)`, the
    `Simulation` forms of `port`, `state` and `modes`, and `Model(build)`
    and `Model(root)`. `reads` is both the binding trait `reads(b)` and the
    read-set constructor `reads(; selectors...)`, one name in two senses.
    And D-226 makes a name public by standing on B, so a diagnostic kind is
    public only where B names it; whether Appendix C's kind set is public
    as a whole is the audit's to settle.
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
- **The user guide and the API reference.** The reference is the Documenter
  build under `docs/`, deployed from master and already live over the
  current docstrings, which is why the docstrings precede the release. The
  guide grows from the tutorial and the companions.

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
- **The time surface's leftovers** (increment 96, outside its scope). Two
  things its prototype found and did not fix:
  - `Relative`'s constructor converts its arguments, so
    `Relative(big(2)^70)` raises a raw `InexactError` and
    `Relative(2.0, 0)` is taken as `K = 2`. `Relative` is not a time door.
  - A composite cofactor in the grid's prime attribution can list no
    supplier, since an entry may supply only one of its primes.

## Deviations

What is built in a shape the spec's is not. Transactional: the commit
introducing a deviation adds its bullet, and the one retiring it deletes it.
Where the code's shape is coherent and the spec may be what moves, the call
is the user's; a ruling lands docs-commit-first, then the bullet retires or
the code conforms.
