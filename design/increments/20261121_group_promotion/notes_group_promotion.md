# Notes: `Group` as the core's assembly for everyday use

The record of the work that moved `Group` to the core and gave it a copy
constructor and wire keywords that take a function, run on 2026-11-21 by
one session and one high-tier reviewer. The user ruled the design in
conversation and then left, so the code landed while the user was away. It
is not an increment: one docs commit, three code commits and one fix
commit. No brief was written. This file holds what the spec, the log and
`pending.md` do not carry: the rulings, the session's own decisions, the
findings, the review, what was verified, and what is left open for the
user.

## 1. The commits

- `784782c`: `pending.md`'s bullet on the docstrings' two later passes says
  what the examples pass does.
- `108e26a`: §8.5, §13.7 and Appendix B of the spec, D-472 and D-473, an
  annotation under D-184 and one under D-313, and the `Group` row out of
  `companions/library_inventory.md`.
- `336a79e`: `Group` moves from `src/library.jl` to `src/assembly.jl`, with
  the imports, the API page, the tutorial's first page, the README and the
  code map.
- `2b77bcd`: the copy constructor `Group(g; …)`.
- `4907ebb`: the wire keywords that take a function of the `Group`, the
  docstrings, the first `jldoctest` block, and `approach` in the examples.
- `9f307e1`: the cold review's fixes (section 5).
- The commit that adds this file, with the two probes beside it.

Nothing is pushed. Two other sessions used the tree meanwhile.
`descriptor-handover` prototyped the tutorial's loose change in a scratch
worktree cut at `336a79e` and held its commits until this work closed. A
third session committed `c373acc` to `pending.md` between `4907ebb` and the
fix commit. No hunk of either was staged here.

## 2. The user's rulings

All of 2026-11-21, in conversation.

1. `Group` takes more standing, by two moves and not a third. The spec
   leads with it, and it moves to the core. It gets no privilege: the
   assembly declarations stay the machinery, and no build step names it.
2. Named assembly types stay, because the user expects domain code to
   dispatch on assembly identity.
3. A copy constructor answers the first rough edge, a rebuild that drops a
   field in silence.
4. Wire keywords that take a function of the group answer the second, the
   passthrough helpers having no assembly to take. The docstring has to
   explain it clearly.
5. The sentence on `Group` goes into both passthrough helpers' docstrings.
6. `pending.md` records that the docstrings need `jldoctest` examples
   (`784782c`).
7. The work is applied at once and not recorded as a pending bullet, by
   this session and not by a delegated builder, with one cold review.
8. The order: spec and log, the move, the copy constructor, the wire
   keywords, the review.

The user then asked the session to work autonomously and to record its
findings and decisions for review.

## 3. The session's decisions

Each is open to the user's review. Decisions 1 to 4 were reported to the
user before the user left, and 5 onward were taken alone.

1. **Two log entries.** D-472 holds the standing and the move, D-473 the
   two additions, since their rejected alternatives differ.
2. **§8.5 leads with `Group` by use, and defines it last.** The definition
   uses the container rule and `transparent_container`, and
   `spec_rules.md` wants nothing used before it is defined. The section
   opens with the two forms and the two-line example.
3. **The inventory lost its `Group` row**, which cited D-184 for `Group` as
   a library member.
4. **No bullet under Deviations** for the hours between `108e26a` and
   `4907ebb`, when the spec was ahead of the code. The earlier arcs did the
   same between a spec commit and its code.
5. **`Group` lives in `src/assembly.jl`**, in a section after the
   passthrough helpers. A file of its own was the alternative. It would
   make "no build step names it" easier to check by eye and add a file to
   the include order for 70 lines.
6. **`src/library.jl` lost five names from its import list**, the assembly
   declarations, which only `Group` used there.
7. **The README's quick start imports `Group` from `Redstone`.** The
   session's first count of the import sites missed the README.
8. **`test_library.jl`'s roster of library components lost `Group`**, and
   three assertions with it. A new testset in `test_assembly.jl` holds the
   guard instead: the only functions of the package with a method that
   takes a `Group` are the five assembly declarations.
9. **`_declared` leaves its second argument untyped**, so that the test of
   decision 8 stays exact. Typed `g::Group`, the helper would join the
   list.
10. **Step 2's gate was not run again in full after its fix.** The gate
    failed on the one roster assertion of decision 8. The fix touched two
    test files, and those two were rerun under the gate's flags. The gates
    of the next two commits ran in full on top.
11. **The doctest stays in the constructor's docstring** as the pilot of
    the examples pass, ahead of the exported-name audit. It imports every
    name it uses. `pending.md`'s bullet now says so.
12. **`sample_times` takes no function**, a bullet of D-473. Its keys are
    child names, and the session saw nothing to compute. The type bound
    `R <: NamedTuple` refuses a function as a `MethodError`.
13. **A function's result takes the keyword form's shorthand**, a bare
    `Pair` as the one-entry tuple. The review found the code doing it and
    the spec silent (finding 4 of section 5). The session kept the
    behaviour and wrote it into §8.5 and an annotation under D-473. The
    alternative is to drop it, since a named assembly's body has no such
    shorthand and fails on a bare `Pair` with a raw `BoundsError`.
14. **`docstring_rules.md` rules 10 and 19 name `Group` apart from the
    library's components.** Both rules had it as one.
15. **D-472's count was corrected in place**, 29 files to 28. The entry was
    hours old and unpushed, and the count is no position. `log_rules.md`
    rule 1 would have an annotation.

## 4. Findings

1. **A rebuild that forgets a keyword is silent.** `selection` rebuilt
   without `sample_times` lost three rates and built with no diagnostic
   (`probe_edges.jl`). An empty rate scope is legal, so nothing can warn.
   The copy constructor removes the need to respell, and nothing stops a
   user from respelling.
2. **A passthrough helper run outside a build warns to Julia's log**, not
   to the build's list (`probe_edges.jl`). That still holds for any call
   made outside a declaration.
3. **`InteractiveUtils.methodswith(T, module)` reads public names only.**
   On a module that exports nothing it returns no method. The guard test
   walks `names(Redstone; all = true)` itself.
4. **The descriptor prints a computed wire field by the compiler's name for
   the function**, as in `input_wires = "#inner##0"`. That conforms to
   §13.9, where the parameter summary is a field's `repr` for a human, and
   the node's `wires` rows carry the entries. The inspector will show that
   name.
5. **A callable struct that is no `Function` is taken for written
   entries**, and the build then fails with a raw `MethodError` on
   `length`. The docstring now says `Function`.
6. **The separate inspector repo still imports `Group` from the library**:
   `RedstoneInspector.jl/test/runtests.jl:7` and `scripts/synthetic.jl:8`,
   and two fixtures name `Redstone.Library.Group`. It pins Redstone at an
   older revision, so nothing breaks until that pin moves.
7. **The first doctest costs two import lines of its five.** The module
   exports nothing until the audit (D-226).

## 5. The cold review

One high-tier agent reviewed `784782c..4907ebb` in a scratch worktree, with
probes kept in `../Redstone.jl-worktrees/group_promotion_review_probes/`.
It found no correctness defect and twelve findings. The fix commit takes
all but the remarks left open below.

| # | Finding | Ruling |
|---|---|---|
| 1 | The docstring said a warning the function raises joins the build's warnings. A user's own `@warn` does not. | Fixed: a warning a helper of the framework raises. |
| 2 | `pending.md` said `src/` holds no doctest, and the first one landed ahead of the order the bullet gives. | Fixed: the bullet names the pilot. |
| 3 | "Called at each read" had no test. A mutant that remembers the result passed. | Fixed: a counting function read twice. |
| 4 | The code normalizes a bare `Pair` a function returns, and the spec did not say so. | Kept and stated (decision 13). |
| 5 | The docstring said "a function", and the code takes a `Function`. | Fixed. |
| 6 | `docstring_rules.md` rules 10 and 19 held `Group` as a library component. | Fixed (decision 14). |
| 7 | Four stale comments or citations in the repo, and the inspector repo's imports. | The four fixed. The inspector is finding 6 of section 4. |
| 8 | Two sentences in the passthrough helpers' docstrings read as if the `Group` passed the helper. | Fixed. |
| 9 | The doctest read `outer.input_wires`, the field read the docstring warns against, and uses a library component. | The field read is out. `UnitDelay` stays: the rule's target is the examples package. |
| 10 | The `sample_times` refusal named no error. | Fixed: a `MethodError` at construction. |
| 11 | The descriptor's name for a computed field. | No change (finding 4 of section 4). |
| 12 | D-472's title runs 17 words, its third bullet rules the spec's layout, and its count was off by one file. | The count fixed (decision 15). The title and the bullet stand. |

## 6. What the tests pin

The reviewer broke each behaviour alone and ran the routed files. Lines are
`test/test_assembly.jl`'s at `4907ebb`.

| Mutant | Goes red at |
|---|---|
| a function's result not normalized | 1207 |
| the function given a throwaway `Group`, or `g.children` | 1214 |
| the function called at construction | 1206, 1233, 1240, 1247 |
| the copy reading the declarations, which freezes a function's entries | 1240 |
| the copy dropping `sample_times` | 394, 405, 413, 415 |
| the copy ignoring `children` | 405, 1240 |
| the copy or the keyword form skipping `_entries` | 412, 414 and others |
| `_declared` typed on `Group`, or `_children` specialized on it | 380 |
| the function run outside the build's warning list | 1233 |
| the bound `R <: NamedTuple` removed | 1244 |
| the result remembered across reads | survived, then fixed by the counting test |
| a `comp isa Group` branch in `classify` | survives |

The last is an accepted survivor. The dispatch test sees methods, not
branches inside a body, and `code_rules.md` leaves a deviation of that kind
to the diff review. Outside its definition, `src/` names `Group` in
`precompile.jl`'s workload and in one comment of `structure.jl`.

## 7. What was verified, and what was not

- The docs battery passed after every docs edit.
- The full gate passed at `2b77bcd` (10768 tests), at `4907ebb` (10783) and
  at the fix commit. At `336a79e` see decision 10.
- The examples' tests (179) and the Documenter build passed at each code
  commit.
- The docs build runs the doctest: a wrong expected output failed it once,
  on purpose.
- `docstring_roster.jl`'s token and summary checks came back empty.
- The reviewer counted the calls of a function-valued wire field: once in
  `build`, and never in `Deployment`, `Simulation`, `init!`, `run!`,
  `descriptor`, `show`, `checkpoint`, `restore!` or `linearize`.
- Julia's floor in `Project.toml` is 1.13, the version every run used.
- Not run: Accessors.jl's `@set` on a `Group`, which D-473 rejects as
  untried. Not run: the inspector repo's suite.

## 8. Open for the user

1. The diff of the six commits, and the wording of D-472 and D-473.
2. Decision 13: keep the bare `Pair` shorthand on a function's result, or
   drop it.
3. Decision 5: `Group` in `src/assembly.jl`, or in a file of its own.
4. Decision 15: the count corrected in place, or by annotation.
5. Review finding 12: whether D-472's third bullet, on §8.5's layout,
   belongs in a log entry.
6. Finding 6 of section 4: the inspector repo's imports and fixtures, due
   at its next pin of Redstone.
7. Finding 4 of section 4: whether the descriptor should print a computed
   wire field some other way.
8. `approach` is the one example that computes its boundary. `piloted` and
   `autopilot` pick two or three faces of children whose other faces are
   fed inside, where the helper saves nothing.

## 9. Where things are

- The spec: §8.5, §13.7, Appendix B's Authoring list.
- The log: D-472, D-473, and the annotations under D-184 and D-313.
- The code: the `Group` section of `src/assembly.jl`.
- The tests: three testsets in `test/test_assembly.jl`, on `Group`'s
  standing, its copy, and its function-valued wire keywords.
- The probes beside this file: `probe_edges.jl` and
  `probe_deferred_keywords.jl`, both run against `d8089d7`, when `Group`
  was still imported from `Redstone.Library`. They are evidence of what
  was seen then and no longer run as written.
- The reviewer's probes: `../Redstone.jl-worktrees/group_promotion_review_probes/`.
