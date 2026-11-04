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

- **The descriptor's class value `"leaf"` becomes `"primitive"`** (§13.9,
  D-432). The spec spells a node's class as assembly or primitive, and
  *leaf* in the spec is a value leaf, the leaf walk's and the leaf
  address's, which §13.9's own kind-marker paragraph uses in that sense.
  The schema of record writes `"class": "leaf"` with the definitions
  `LeafNode` and `LeafFace`, and the inspector's records, map and frontend
  follow it; `RedstoneInspector.jl/design/initial_design.md` answer 17
  called that the spec's vocabulary when it was not. The schema conforms:
  `"primitive"`, `PrimitiveNode` and `PrimitiveFace`, the writer and
  `test_descriptor.jl`, with no change to the format's version, which an
  unreleased package never needs. The inspector's half, the regenerated
  types and the renames through the frontend and the records, lands with
  its next pin on the core.
- **Tighten the blocks' `V` bound to what the build admits** (§7.1, §13.7,
  D-094, D-320), a loose fix, ruled by the user on 2026-11-04. Fifteen blocks,
  `Freeze` to `DiscretePID`, bound `V` as `Union{Real, StaticArray{<:Tuple,
  <:Real}}`, so a `Float32` or an `MVector` passes the constructor and is
  refused at build as `IllegalStateLeaf`, `IllegalStoreField` or
  `ConformanceFailure`; a probe on 2026-11-04 tried six such variants and
  every one was refused. The bound becomes `Union{Float64, SArray{<:Tuple,
  Float64}}`, so the refusal is the constructor's `TypeError`, with one test
  per tier. `GaussianWhiteNoise`'s `Union{Float64, SVector{<:Any, Float64}}`
  already is, and the docstrings already say `Float64` or an `SArray` of
  `Float64`.
- **One broadcast convention for the blocks' keywords** (§13.7, D-313), a
  loose fix, ruled by the user on 2026-11-04. Keywords sharing `V` broadcast
  to one shape, as `PID`, `DiscretePID`, `GaussianWhiteNoise` and the trackers
  do; the promoting blocks are the older spelling, with no design reason
  behind the difference. Only broadcasting can be universal, since `PID`'s
  scalar defaults must sit beside a vector `Kp`. Three commits: the
  inventory's sentence on promotion rewritten first; then `LimitedIntegrator`,
  `LimitedDoubleIntegrator`, `DiscreteLimitedIntegrator`, `Step`, `Relay`,
  `Comparator` and `Sequence`'s values through one helper making `Float64` of
  one shape, which replaces `promoted_keywords` and its refusal tests and may
  absorb `shape_type` and `GaussianWhiteNoise`'s idiom; then `RateLimiter`'s
  `rising` and `falling` and `FirstOrderLag`'s `τ` widened from `Float64` to
  `V`. A length mismatch stays Julia's `DimensionMismatch`, as on `PID`. The
  widening carries `RateLimiter`'s positivity refusal to `all(rising .> 0)`,
  and the helper retires the limited integrators' sentence on refused
  mixes. `check_limits` stays. The
  same commit refuses a non-positive `τ`, `τd` or `Tt` as `ArgumentError` in
  `FirstOrderLag`, `PID` and the trackers, over every component, skipping
  `AsPort()`, with `Tt = Inf` allowed and `DiscretePID`'s `τd = 0` kept
  legal, since the audit of 2026-11-04 found `τ = 0` failing at the first
  step as `NonfiniteState` and `τ = -1` diverging silently.
- **The inspector, stage 1**: the static inspector over the descriptor,
  built in the separate repo `RedstoneInspector.jl`, whose
  `design/pending.md` holds its work order and its open items, and whose
  `design/roadmap.md` stages its eleven increments. What this repo owes it
  is the class value above, the stage-function locations in the
  descriptor below, and the later stages after the release.
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
- **A contract entry that is not a type.** A `u_types` or `y_types` entry
  holding a value that is no type, a tuple of types or a number, named or
  bare, fails late as a raw error, since the walk never checks that an entry
  is a type (§8.2). The fix is a loose one: the walk refuses it as
  `IllegalPortType` under a reason of its own, with its Appendix C row.
- **The library's remaining candidates.** Whatever of the inventory in
  `design/companions/library_inventory.md` is unbuilt, each block
  built when wanted (§13.7, D-313). The order, by the mechanism each family
  exercises: the structure blocks `Fn`, `Select`, the unbundling component
  and the discrete backlash; then the additions to shipped blocks, where three
  readings wait for the brief: a second output on `Delay` names its output
  side, so the taps are a type parameter keeping the bare spelling; Tustin
  gives a nonzero `D`, so the discretized pair's class reads off the method;
  and scheduled limits move `lower` and `upper` into the guards' `u` and take
  `x0`'s default with them. `Freeze` over a struct is a framework seam, not a
  block, and stays here after the four.
- **Stage-function locations in the descriptor** (§13.9, D-432). A `types`
  row carries the source locations of the declaration methods alone, so the
  inspector has no line to show for an algebraic loop, whose feedthrough is
  in its members' `y_direct`; since increment 7's look pass its drawer shows
  none for a loop. With `y_direct`'s location in the row, the loop's row
  links one per member, under the message. A member traced structurally has
  its dependence presumed, so its `y_direct` may not read the input, and the
  row should say so. The spec edit and its log entry come first.

## Deviations

What is built in a shape the spec's is not. Transactional: the commit
introducing a deviation adds its bullet, and the one retiring it deletes it.
Where the code's shape is coherent and the spec may be what moves, the call
is the user's; a ruling lands docs-commit-first, then the bullet retires or
the code conforms.
