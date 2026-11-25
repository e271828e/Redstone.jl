# Roadmap: the API audit

What the API audit of `pending.md`'s work order covers, in two parts, in
this order. It follows the tutorial, which surfaces the names a user types
and the friction a user meets. `pending.md`'s bullet carries the state.

## The friction review

Every item the tutorial arc records is ruled: fixed, documented, or declined
with its reason. The items sit in each increment's notes, by R17 of
`roadmap_tutorial.md`, and the arc's closing increment collates them:

- nineteen, `20261118_tutorial_example/notes_tutorial_example.md`, section 5;
- eleven, `20261119_tutorial_pages/notes_tutorial_pages.md`, section 6;
- one, on `lqr_gains`' weights,
  `20261121_tutorial_loose_change/notes_tutorial_loose_change.md`, section 4.

A fix lands as a loose commit or as an increment of its own, and before the
exported-name audit, since it can add or rename a name.

## The exported-name audit

The export list is to be decided deliberately rather than by accident, and
until the audit runs the module exports nothing (D-226). The audit is a
full-surface sweep under the four-class naming convention (§8.1, D-144):
every API name is exported, renamed or left unexported. It also settles
which fields are public, since `Model`'s docstring lists every field, `exec`
and `frame_diag` included, while `Deployment` and `Schedule` list none and
tests read `deployment.h`, and no doc lists the fields of `KindCounts`, which
`WriterStatus` exposes (CV11a-004 of
`design/reports/20261124_doc_conformance/ledgers/user_rows.md`), nor those of
`TraceBatch`, the record of `Trace.batches` (CV7a-038 there). It comes after the library has added its names;
the examples are a package of their own and add none.

Two things wait on it. The descriptor writer's `@ref` pass targets exported
bindings alone, so it rewrites no link until the audit exports some (§13.9,
D-467). And `docs/make.jl` lists `modules = [Redstone]`, so
`checkdocs = :exports` checks nothing in `Redstone.Library` even then, until
the list names it.

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
    (`is_input`, `is_greedy`);
  - whether an unexported name on the extension-only surface may coincide
    with a public Base name when the spec's verb is that word, reached by
    qualified name or explicit import; `peek` (§11.7, D-270) is the first
    instance, the panel kit's verb beside `Base.peek`;
  - `labeled` (§14.10, D-475), a participle where every class asks for a
    noun phrase or a verb; it converts a `Linearization` to its labeled
    form and mutates nothing.
