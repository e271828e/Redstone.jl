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
  built in the separate repo `RedstoneInspector.jl`. Its
  `design/pending.md` holds its state and work order, its
  `design/roadmap.md` the staging. This repo owes it nothing before the
  release, and the later stages after.
- **The docs conformance audit.** The spec, the log, the docstrings, the
  companions and the rest of the docs are checked against the code, which
  is the source of truth, in both directions, and what drifted is fixed.
  Stage reached: the sweep is done, every group from the §14 trial to G7
  run and its clear fixes landed, and every row put to the user is ruled
  and applied. The state, the rulings, the group plan and the tools are in
  `design/reports/20261124_doc_conformance/notes_doc_conformance.md`; the
  brief is `00_brief.md` beside it, and the user's rows and their rulings
  are in its `ledgers/user_rows.md`. Left, in order:
  - The small sweep of the items the notes list as seen and not yet fixed,
    about 25, each re-checked first, since two have landed since.
  - The log clustering, Stage F step 4 of the brief: the 326 findings of
    `ledgers/log_findings.tsv` grouped by topic, one superseding entry
    drafted per group, for the user's approval. It settles CV2-026 and
    CV6a-033, which wait on the CIT-D166 finding.
  - The closing: the final report the brief asks for, the
    `doc_conformance` worktree removed, and this bullet retired. CV11a-004
    and CV7a-038 stay on the API audit's roadmap.
- **The tutorial and the README.** The tutorial builds the longitudinal
  aircraft from scratch in nine chapters, in an arc of five increments.
  Stage reached: increments 1 and 2 are pushed, and increment 3 is next.
  The plan, the arc's rulings, the open decisions and the rules for the
  pages are `design/increments/roadmap_tutorial.md`; the increments'
  records are
  `design/increments/20261118_tutorial_example/notes_tutorial_example.md`
  and
  `design/increments/20261119_tutorial_pages/notes_tutorial_pages.md`. The
  README keeps its quick start, shows three of the chapters condensed with
  the plot and the diagram, and links to the tutorial; the interactive part
  is the binding's few lines until the live inspector gives a recording.
- **The API audit.** The API is reviewed as a whole before the release: the
  friction review first, then the exported-name audit. Until the second
  runs the module exports nothing (D-226). It decides the export list, the
  extension-only surface, the operator side's packaging and the boundary
  cases, `peek` among them (D-270). The scope and the items are
  `design/increments/roadmap_api_audit.md`.
- **The API docstrings' two later passes**, under
  `design/rules/docstring_rules.md`. Unexported names keep their docstrings
  as they are.
  - The examples pass gives each entry point that earns one a `jldoctest`
    block under rules 35 to 38. `output_passthrough` earns one, since no
    example calls it. The pilot is on `Group`'s constructor (D-473). It
    follows the tutorial and the exported-name audit, since a block written
    earlier imports every name it uses.
  - The signature-and-link pass follows the audit's renames, since a rename
    costs a signature line and the Documenter build catches a stale link.
- **The `§` references in diagnostic messages.** Every message ends by
  citing a spec section, which a user without the spec cannot follow. The
  pass drops each reference or replaces it with a pointer into the
  documentation, kind by kind. Messages are presentation (D-058), and only
  `test_diagnostics.jl`'s rendering testset pins their text. It follows the
  exported-name audit, whose renames reach the messages too. The pass also
  rewords `AlgebraicCycle`'s verdict: a real verdict that rests on a member
  traced structurally reads "presumed real", since the tracer assumes every
  hop through such a member (§13.8). The classification stays `:real`.
- **The first release.** Registration in General, the tag, and the
  announcement, in that order. Registration is quiet and the announcement
  is the public moment, so the announcement waits for everything above.
- **The inspector, stages 2 to 4**: the bridge, an ordinary device serving
  the handle over a socket; the live inspector, values on the diagram; and
  the cockpit, panels over the bridge. What the spec owes, each ruled when
  its stage reaches it: the handle's control verbs and the log-tail view,
  and §11.6's front-end passages checked against the bridge's ruled design,
  its binding and its exit, since a closed tab ends no bridge loop (stage
  2); and a ruling on how §11.7's client half spells a panel, as a
  description, and on §11.7's "assembly panels compose children by path",
  a constraint on that half with no entry (stage 4).
- **The user guide and the API reference.** The reference is the Documenter
  build under `docs/`, deployed from master and already live over the
  current docstrings. The guide grows from the tutorial and the companions.

## Unordered

Items with no order among them. Nothing prevents any of them before the
first release, but each is low priority, additive, and lands without
breaking user code, and each may benefit from user feedback first.

- **A schedule row's `Δt` is not the float nearest its exact period**
  (§6.3, §9.2, §10.5). `bind_schedule` writes `D * Float64(Δt_base)`, so
  three base ticks of `1//10` read `0.30000000000000004`, which
  `show(::Schedule)` prints and every discrete bundle receives. The exact
  value is `D·Δt_base` as a rational, which `show(::Deployment)` prints
  (D-471).
- **A framework throw inside a step is framed as a component's** (§13.4).
  A `StepError`'s message names the cursor as the catch found it, so a
  throw from the framework's own step code reads as the last stage entered;
  the `cause` and its stack trace are right. D-470 closed the one path that
  reached it. Whether the message tells a throw inside a stage body from
  one outside it is open. Evidence:
  `design/increments/20261120_descriptor_content/probe_localization_inf.jl`.
- **Publication's garbage** (§9.8, §10.7, §11.2, D-269). A paced
  hardware-in-the-loop run needs that no collection pause breaks a frame
  deadline, and publication allocates at every boundary. An analysis on a
  model of real size comes first, then a ruling beside D-269, then the
  build. What it assesses is
  `design/increments/roadmap_publication_garbage.md`.
- **The NLopt fallback** (§14.8, H 4.5): `NLoptBackend(:LN_BOBYQA)` as a
  package extension, the squared and normalized objective at `stopval = 1`,
  and the nominal-activation loop it would run on.
- **Log and trace persistence.** The in-memory artifacts are settled (§11.2,
  §11.5) and nothing on-disk is. These questions wait for real users:
  - the HDF5 export scope, the whole snapshot log or selected subtrees;
  - field-handle summarization over retained snapshots, as
    `getproperty`-style navigation of a run's history, with §11.2's
    skip-or-summarize rule for field handles, which has no entry;
  - the trace file format, which doubles as the reproducibility carrier and
    whose positions the replay pointers name (§13.4);
  - whether the trace header holds the build-free half of the `Deployment`,
    a D-254 question. It now holds the whole, and through it the `Build`
    with the component instances, which the deployment's `==` excludes, so
    replay never compares it;
  - the bullet of `flight_case_studies.md` section 1 on the flat vector,
    reworded: it names OrdinaryDiffEq, which §10.2 dropped, and HDF5 logging
    among its users.
- **The operator interrupt on Julia 1.14** (§12.4, D-132, D-394). Julia
  master delivers Ctrl-C as a cancellation, not an `InterruptException`, so
  the mechanism of §12.4 stops working while its contract can stay. The
  break, a candidate design and its open questions are
  `design/reports/20261016_ctrlc_julia_114/report.md`. It is taken up when
  1.14 branches or its cancellation names become public, whichever comes
  first.
  - **The pause wait's hang at one thread.** A real SIGINT into the pause
    wait at `-t 1` with a device rostered hangs the run: 1.13 throws the
    interrupt into whichever task is current on thread 1, which is not the
    parked loop (§12.4, D-268). Under 1.14 the pause wait is a cancellation
    point, so the case does not exist there; whether it is fixed on 1.13 is
    settled with the floor when this item lands. Evidence:
    `design/increments/20261105_interrupt_status/probe_pause_wait_t1.jl`.
  - **A forced throw inside the tail's bookkeeping.** A forced throw that
    lands in the few writes between the bookkeeping's mask and the store
    that clears the running flag leaves the lifecycle `running`, possibly
    with no record, every service refusing (§12.4, D-268). The presentation
    of the residue, the one step there that prints, now follows those
    writes. No test can place a throw in what is left. Whether a retrying
    `try` around the bookkeeping closes it is settled when this item lands.
    Evidence:
    `design/reports/20261124_doc_conformance/probes/user_rows/s12b236_masked_bookkeeping.jl`.
- **`Dual` allocation coverage for the library** (§9.8, §13.7). The
  allocation testsets in `test_library.jl` measure phase bodies at `Float64`
  alone. Extend each continuous component's testset with the loop over
  `(Float64, LinearizeDual)` that `test_executor.jl` runs over
  `bare_ports_world`. A `Dual` model freezes the discrete tier and compiles
  events out, so the sweep says nothing about the discrete components. The
  standing rule for new library components is in `rules/brief_rules.md`.
- **A component backed by an external library, demonstrated** (§8.2,
  §14.10, D-266). The FFI door of §8.2 is designed and has never been
  exercised. Add to the examples package the twin of one discrete
  controller behind the same contract, its stage bodies calling a C or Rust
  library through `@ccall`, with a test that compares the two on one input
  trace within a tolerance. The external code takes its state in and
  returns it, since a stage mutates nothing (§4.1). It answers how the
  build's checks treat a stage whose body is a foreign call, whether the
  wrapper steps without allocating, and what trim and linearization need
  from it, pinned inputs or a local derivative rule. The Simulink
  explainer's page describes the workflow as not built until this lands.

## Deviations

What is built in a shape the spec's is not. Transactional: the commit
introducing a deviation adds its bullet, and the one retiring it deletes it.
Where the code's shape is coherent and the spec may be what moves, the call
is the user's; a ruling lands docs-commit-first, then the bullet retires or
the code conforms.
