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

- **Bare declarations, the contracts half.** A contract declaration may be
  one bare leaf, a port with no face, addressed by the component path alone.
  The docs landed as D-436 (amending D-036, D-040, D-046, D-207, D-210,
  D-276 and D-435; spec §4.3, §5.2, §6.1, §8.2, §8.6, §8.8, §9.1, §9.3,
  §9.5, §11.3, §13.3, §13.5, §13.7, §13.9, §14.4, Appendices B, C, D).
  Next: the prototype in a scratch worktree, then the brief, then the
  pipeline, as increment 83 did for the stores half
  (`design/briefs/brief_increment_83_bare_stores.md` is the template). The
  record is `design/reports/20261029_bare_declarations/README.md` (not
  normative), its "Seam inventory, contracts half" the checklist; the
  rulings D-436 adds beyond it, all in the entry's Position: the
  one-segment endpoint's refusals are `UnknownPort` with an empty name
  and the list in hand; `input_faces`/`output_faces` list a bare contract
  as one empty name and the passthrough label is the prefix alone; a face
  name is never empty (`FaceNameIllegal`, contract keys included); the
  root refusals are `FaceNameCollision` at `:root` and `IllegalPortType`
  `:bare_at_root`; `get_output` and `port` default to the headless
  address, `get_face("")` reads a primitive root's bare output, and the
  shape mismatch is `ReadResolution` `:port_shape`; the descriptor writes
  `""` for a bare face name and endpoint port at format 1.0. Where the
  stores half leaves it: a bare `u_types` or `y_types` fails today as a
  raw `MethodError` on `keys(::Type)`, not as a diagnostic; `get_output(path,
  "")` arrives as `ReadResolution` `:undeclared` at `BARE`; and the
  `(path, name)` renderer `_named` drops an empty name, but most port
  renderings still interpolate the pair and must be routed through it. The
  prototype proves: the one-segment endpoint wired both ways and refused
  where the child's side is not bare; the two root refusals; the
  feedthrough graph, the layout and the trace on the `BARE` key; the single-
  cell gather and scatter at zero allocation with the check folded; the
  `Dual` sweep over a bare-contract `Integrator`; the descriptor validating
  against the unchanged schema with `""` names; no stray `/` in any
  rendering at depth; and the library and examples churn. When the
  library's contracts go bare, the docstrings of the integrating and linear
  blocks rename the port names `in` and `out` to `u` and `y`, the textbook
  form `ẋ = A x + B u`, `y = C x + D u`, and `s⁺ = A s + B u` on the
  discrete tier; the state letters `x` and `s` are already in place. The
  block companions and `library_inventory.md` move with the code, as they
  did for the stores. An explicitly empty contract key, `(var"" = V,)`,
  must be refused rather than read as bare, a pin for the brief.
- **The inspector, stage 1**: the static inspector over the descriptor.
  The stage's record is `design/inspector/initial_design.md` (not
  normative), with one record per axis session beside it:
  `descriptor_design.md` for axes 1 and 2, landed as §13.9, D-432 and
  increment 81; `design/prototypes/render_spike/report.md` for axis 4,
  hand-rolled SVG over ELK.js; `visual_grammar.md` for axis 3;
  `workspace.md` for axis 5; `live_session.md` for axis 6, the Julia
  package and the live session; `failure_descriptor.md` for the failure
  bump, landed as §13.9, D-434 and increment 82. Next: axis 7, then the
  package's increment, in `live_session.md`'s "Design axes" order; the
  deployment overlay's bump stands as `visual_grammar.md` hands it on. The built-in Julia GUI is parked
  (D-310). The later stages stand after the release, below.
- **The API docstrings' two later passes.** The sweep to the manual's
  conventions landed (commits `84ece6b` to `b1d9ae3`, record
  `design/briefs/notes_docstring_sweep.md`, convention
  `design/tools/docstring_style.md`). Two passes remain: an examples pass
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
- **The library's remaining candidates.** Whatever of the inventory in
  `design/companions/library_inventory.md` is unbuilt, each block
  built when wanted (§13.7, D-313).

## Deviations

What is built in a shape the spec's is not. Transactional: the commit
introducing a deviation adds its bullet, and the one retiring it deletes it.
Where the code's shape is coherent and the spec may be what moves, the call
is the user's; a ruling lands docs-commit-first, then the bullet retires or
the code conforms.
