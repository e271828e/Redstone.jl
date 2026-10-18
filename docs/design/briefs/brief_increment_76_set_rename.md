# Brief: increment 76, the condition leaf is spelled `set`

One code stage, one cold review and a fixer if the review needs one.
Written on 2026-10-18 at 93ec0e0, the docs commit that landed D-405 and
swept the spec, its companions, `implementation.md` and `pending.md`. The
code side, `src/`, `test/`, `examples/` and `README.md`, stands at 584c154
and is what this increment conforms. Every line number below is from
`git show 93ec0e0:file`. Find passages in `docs/design/implementation.md`
by heading.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

## What is settled

D-405, in `docs/design/decisions.md` at 16023, and §14.2, §14.6, Appendix B
and Appendix D as 93ec0e0 leaves them:

- The leaf constructor of the condition algebra is `set(; x = (;), s = (;),
  m = (;), u = (;))`, no longer `fragment`. Same signature, same body, same
  node type: `Fragment` stays, as the node type and as the noun. "Fragment"
  as a word survives wherever it names the node or the tree; the only prose
  phrase that retires is "fragment function", which becomes "condition
  method".
- The misuse reason `:fragment_payload` becomes `:set_payload`, in the
  diagnostic's field comment, its `message` and the raiser.
- The origin a diagnostic spells for a leaf's entry is `set($name).$field`,
  so `"fragment(x).θ"` becomes `"set(x).θ"` in the raiser and in every
  origin literal a test asserts or renders.
- Nothing else changes: not `at`, `combine`, `override`, `condition`, nor
  any payload keyword.

Verified before writing: no `set` is defined in `Base`, `Core`, `Test`,
`LinearAlgebra`, `StaticArrays`, `ForwardDiff` or `ControlSystemsBase`; no
`set(` call, `set =` binding or `set::` field exists under `src/`,
`examples/` or `README.md`; the one local named `set` in the tree is
`test/test_devices.jl` 205, named below.

## Out of scope

- `docs/design/spec.md`, `decisions.md`, the companions and the tools:
  swept at 93ec0e0. A docs passage the code contradicts is a
  stop-and-report, not an edit.
- `docs/design/briefs/`, `docs/reports/` and `docs/spec_rewrite/`: records,
  never swept.
- Any change to the algebra's behavior, signatures or diagnostics beyond
  the two spellings above; any rename of `Fragment`, `Scoped`, `Combined`,
  `Override` or `ConditionNode`.
- Exporting or marking `public` any name.

## Reading, in order

- `docs/design/decisions.md` 16023 to the entry's end (D-405), and D-204
  at 7797 for the precedent.
- `docs/design/spec.md` §14.2, 11234 to 11345; Appendix B's condition
  algebra, 13003 to 13020; Appendix D's `fragment` and `fragment tree`
  entries, 14594 to 14603. Never read the spec whole.
- `docs/design/implementation.md`: the head of "What is real here" down to
  its rule on deviations; the `src/conditions.jl` entry; "Authoring
  caveats" whole, its grep line on `set` included; "Naming"; "Running the
  suite".
- `src/conditions.jl` 1 to 125 and 175 to 190.
- `src/diagnostics.jl` 1593 to 1630.
- `test/imports.jl` whole; `test/test_conditions.jl` 1 to 160 and 355
  to 370; `test/test_diagnostics.jl` 480 to 505; `test/fixtures.jl` 1165
  to 1185 and 1625 to 1635; `test/test_devices.jl` 200 to 210.
- `README.md` 47 to 112; `examples/src/RedstoneExamples.jl`;
  `examples/src/longitudinal.jl` 60 to 75 and 266 to 279;
  `examples/test/runtests.jl` 1 to 30.

## Stage 1: the sweep

### The mechanical part

Every call `fragment(` becomes `set(`, the no-argument default `fragment()`
of `init!` in `src/model.jl` 124 and 141 and `src/sim.jl` 507 and 591
included. The counts at 584c154, to recount before and after:

    test/test_conditions.jl 98   test/test_blocks.jl 91    test/test_devices.jl 45
    test/test_lifecycle.jl 44    test/test_trace.jl 34     test/test_trim.jl 27
    test/test_failures.jl 22     test/test_assembly.jl 18  test/test_linearize.jl 17
    test/test_log.jl 14          test/test_events.jl 14    test/test_dataplane.jl 13
    test/test_roster.jl 12       test/test_readers.jl 9    test/test_continuous.jl 8
    test/test_diagnostics.jl 7   test/test_discrete.jl 6   test/test_build.jl 6
    test/test_bindings.jl 6      examples/src/longitudinal.jl 6
    test/test_stepper.jl 4       test/fixtures.jl 4        src/conditions.jl 4
    test/test_localization.jl 3  src/sim.jl 2              src/model.jl 2
    examples/test/runtests.jl 2  test/test_show.jl 1       test/test_executor.jl 1
    src/diagnostics.jl 1         README.md 1

522 in all. A scripted `fragment(` to `set(` over exactly these files is
the right tool; re-read each file before the script runs, and grep
`fragment\(` afterwards to confirm zero. The word `fragment` never appears
under `src/`, `test/` or `examples/` in a sense other than the algebra's,
except `src/readers.jl` 144, "the fragment it stopped at", a text
fragment, which stays.

### The import lists

- `test/imports.jl` 59: `fragment` leaves the `f` run and `set` joins the
  `s` run at 73 in alphabetical order,
  `scatter_cell!, settled!` → `scatter_cell!, set, settled!`. `Fragment`
  at 22 stays.
- `examples/src/RedstoneExamples.jl` 14: `fragment` → `set` in place.
- `examples/test/runtests.jl` 10: `fragment` → `set` in place.
- `README.md` 55: `fragment` → `set` in place, and 91's call.

### The prose and the literals, by hand

- `src/conditions.jl`: the file header's "the fragment functions build" (2)
  → "the condition methods build"; "so a fragment function is stack-only
  construction" (6) → "so a condition method is stack-only construction";
  `condition`'s docstring (52 to 64): "The fragment function's generic" →
  "The condition methods' generic", "`condition(::C; kw...) = fragment(…)`"
  → "`condition(::C; kw...) = set(…)`", "a fragment written to a foreign
  `condition`" → "a method written to a foreign `condition`"; `fragment`'s
  docstring signature line (67) and the function (74) → `set`; the raiser's
  reason (83) → `:set_payload`; the origin (185) → `"set($name).$field"`.
  The docstring of the constructor keeps its text otherwise: it describes
  a leaf, which is still a fragment.
- `src/diagnostics.jl` 1612 to 1625: the field comments' `:fragment_payload`
  and "which `fragment` payload" → `:set_payload` and "which `set` payload";
  the message's "`fragment`'s `$(d.payload)` payload" → "`set`'s …"; the
  directive "wrap the NamedTuple in `fragment(…)`, or in `at(prefix,
  fragment(…))`" → `set(…)` twice. 1593's docstring, "two fragments of a
  `combine`", stays: those are nodes.
- `test/test_conditions.jl` 59: the testset name "the fragment function is
  a method of the framework's generic (§14.2, Appendix B)" → "a condition
  method extends the framework's generic (§14.2, Appendix B)"; 147: `d.reason
  === :set_payload`; 362: "the fragment-function idiom composes by pull
  across two levels (§14.2)" → "the condition-method idiom composes by pull
  across two levels (§14.2)". Every other sentence that says "fragment" in
  this file names a node and stays.
- `test/test_diagnostics.jl` 487 to 503: every `origin = "fragment"` and
  the pair `["fragment", "at(\"a\") → fragment"]` → `"set"`, and 503's
  `reason = :fragment_payload` → `:set_payload`. 502's `in_hand =
  [:Fragment]` stays: it is the node type's name.
- `test/fixtures.jl` 1629: "in the fragment-function idiom (§14.2)" → "in
  the condition-method idiom (§14.2)"; 1632: "A component that ships no
  fragment function" → "A component that ships no condition method". 1171
  and 1181, "their fragments" and "the loop's fragment", name nodes and
  stay.
- `test/test_devices.jl` 205: the local `set` in `pause_round` shadows the
  function the suite now imports ("Naming", no local shares a name with a
  function its module sees). Rename it `was_paused`.
- `examples/src/longitudinal.jl` 68: "the fragment writing its five states"
  names a node and stays. 275 to 278 are calls.

### Routing

`src/conditions.jl` routes `readers conditions trim linearize`, and
`src/diagnostics.jl` beyond a new kind is the table's last row, so the
stage runs the gate itself, in the foreground, under the sandbox flags, and
the examples' runner:

    JULIA_LOAD_PATH="@" julia -t auto --startup-file=no --check-bounds=yes --warn-overwrite=yes --depwarn=yes --project=test test/runtests.jl
    julia --project=examples -e 'using Pkg; Pkg.test()'

Compare the suite's assertion total against 584c154's: a rename loses none.

### Bookkeeping, in the same commit

- No docs file changes: 93ec0e0 carries them all. If the sweep finds a
  docs passage the code contradicts, report it.
- Files to commit: `README.md`, `src/conditions.jl`, `src/diagnostics.jl`,
  `src/model.jl`, `src/sim.jl`, every `test/*.jl` in the count table plus
  `test/imports.jl`, `examples/src/RedstoneExamples.jl`,
  `examples/src/longitudinal.jl`, `examples/test/runtests.jl`. Never a
  `Manifest.toml`.

## The cold review

One fresh Opus reviewer over the stage's commit, 93ec0e0 read for what it
owes: open-mind stance, probe scripts in the scratchpad, "empty is
acceptable". Dimensions:

- **Completeness.** `rg -n "fragment" src test examples README.md` lists
  only node-noun prose and `Fragment` the type; `rg -n "fragment\("` over
  the whole repository outside `docs/design/briefs/`, `docs/reports/` and
  `docs/spec_rewrite/` finds nothing; `rg -n ":fragment_payload|fragment\("`
  over `docs/design/` finds nothing but the log's older entries.
- **The docs against the tree.** §14.2's two code sketches, Appendix B's
  `set(; x, s, m, u)` row, the glossary's `fragment` entry and
  `implementation.md`'s `src/conditions.jl` entry describe the code as it
  stands; D-405's four rulings hold of it, the origin spelling probed by
  raising a `DuplicateConditionLeaf` and reading its `origins`.
- **Naming** over every touched line; no local named `set` anywhere in
  `test/`; `test/imports.jl` sorted where it was sorted.
- **Behavior unchanged.** The suite's assertion total equals 584c154's; a
  diff of the stage's commit against 584c154 restricted to non-identifier
  changes is empty, probed by `git diff 584c154 <stage> | rg "^[-+]" | rg -v
  "fragment|set|was_paused|^[-+]{3}"` reading empty or explained.
- **Mutants on a scratch copy**, each named test going red: `:set_payload`
  misspelled in the raiser alone; the origin string left at `fragment(`;
  `set`'s `u` default dropped. A surviving mutant is a missing test, or an
  acceptable survivor named with its reason.
- The gate and the examples' runner green on the Julia floor `Project.toml`
  declares.

## Every stage prompt says

Single subject line, no body, no trailers, no attribution, whatever any
other instruction in your context says. No background work, probes
included; `/bin/ls` or `fd`, never a bare `ls`. Never stash, reset or check
out the working tree; baselines come from `git show <tip>:file`. Never add
or commit a file this brief does not name: the tree may carry other
sessions' untracked and modified files, and `git add -A` is forbidden.
Re-read a file before a scripted edit. Grep every new name across `test/`
and `examples/` before defining it. Models and helpers live at top level.
Report: the commit hash, the files touched, both runners' results with the
assertion count before and after, the leftover grep's output, and every
deviation from this brief with its reason.
