# Notes: the descriptor's content and a root input's pin

The record of the increment that builds D-467 and D-468, part three of the
core work ahead of the inspector's increment 10 (`pending.md`, first
bullet). It is run by the pipeline of `design/rules/increment_rules.md`: a
prototype in a scratch worktree, a readings round, this file as the record.
It holds what the spec, the log and `pending.md` do not carry.

## 1. State

- `1537538`: the spec and D-467, the descriptor's content.
- `df553d8`: the spec and D-468, a root input's pin.
- `f5ff3f5`: this file opened, the prototype's base.
- `be29b3d`: the glossary entry for the grid report.
- `d844332`: the spec and D-467 amended by the readings.
- The commit that adds section 11: the record and the prototype's patch,
  `prototype_descriptor_content.patch` beside this file. No code has landed.
- The prototype's worktree is
  `/Users/miguel/.julia/dev/Redstone.jl-worktrees/descriptor_content`,
  detached at that commit, with the prototyper's notes and probes beside it
  in `/Users/miguel/.julia/dev/Redstone.jl-worktrees/descriptor_content_notes/`.

Nothing is pushed.

## 2. The user's rulings of 2026-11-20

Each is in D-467 except the last two.

- **A stored position counts from 1.** The user asked what the proper rule
  is when the artifact counts from 1 and the first client from 0. The file
  already counted from 1 in its two places, `timing.anchor` and a tuple's
  field names, so `suppliers` counting from 0 would have been the file's one
  zero-based number. The inspector's record wrote its example from 0
  (`deployment_overlay.md`, answer 6), and the spec does not follow it. The
  record needs a note on its side when the pin moves.
- **An unfactored cofactor carries `unfactored`**, present only when true.
  The alternative was the client testing `prime ≥ 2^40` for itself.
- **The route.** The spec and the log land first, one docs commit per entry,
  then the code as an increment with a prototype.
- **The spec names no stand-in scalar for the meet.** It says the meet is
  D-168's and that the writer computes it from the `Structure` alone. Which
  scalar stands for "a `Dual`" is the prototype's reading, seam 1 below.

## 3. Seams handed to the prototype

Each comes back as a reading in the rules' form.

1. **The scalar the meet walks to.** One function over the `Structure` is
   to serve `show(::Structure)`, the writer and `linearize`'s refusal.
   `build.jl` has two candidates, `Marker` and `ProbeDual`.
   `linearize.jl`'s `_seeded_tap` builds the list today from an
   activation's declarations at its own `T`.
2. **The mark's printed form** on an input route. The spec fixes the words
   `pinned by tier` and `pinned by declaration` and no layout.
3. **The rate chain under parity.** `show` prints each component's chain of
   `sample_times` links. D-467 lists it among what a client derives, on the
   record's answer 10, whose derivation `K = m / mₛ`, `φ = (c − cₛ) / mₛ`
   was left "to check at the prototype". If the file does not determine the
   chain exactly, the spec is amended and the node carries it.
4. **Where `state_events` stands** among the located declarations. The spec
   lists it after `sample_times`.
5. **The `@ref` pass.** How a name resolves from the type's module, what
   counts as a binding its owner exports, and which link forms are bare.
6. **A parity check in the suite.** D-467's Rationale says the core's suite
   can check the rule. Whether a test does, and how, is open.

## 3a. The readings round, ratified by the user on 2026-11-20

The prototype was whole at the round: the gate at 10676 of 10676 against
10316 at the base, the examples at 179 of 179, thirteen mutants red and one
accepted survivor. The user accepted every recommendation below.

1. **The meet's scalar is `ProbeDual`**, an argument of
   `pinning_consumers(structure, T = ProbeDual)` in `build.jl`. `linearize`
   passes its own scalar, so its refusal is unchanged. `Marker` was
   rejected on a probe: an entry `Union{Float64, ForwardDiff.Dual}` admits a
   `Dual` and refuses `Marker`, which would print a false mark. The
   surviving mutant has `linearize` call at `ProbeDual`. The two scalars
   differ only for an entry that tells two `Dual` tags or widths apart,
   which no fixture has.
2. **The mark sits in an aligned column**, two spaces after the widest
   route of the block, with no parentheses.
3. **The rate chain is not derivable, and the node carries it as `rates`.**
   A client derivation from the timings and the scope rows reproduced 12 of
   18 printed chains. §13.9 and D-467 are amended. The rejected alternatives
   are in D-467.
4. **`state_events` stands after `sample_times`.**
5. **The `@ref` rule stays as ruled and is inert until the export audit.**
   The package exports nothing (D-226), so none of the 124 bare links gains
   a target. D-467's rationale claimed the docs build guarantees an anchor,
   which was false and is corrected. The user chose to wait for the audit
   over targeting any documented binding. The inspector's record counts 121
   links in 42 docstrings, and the run found 124 in 45.
6. **A parity test joins the suite**: a client in Julia over the parsed
   JSON rebuilds `show`'s tables, on ten builds and four deployments.
7. **A pool entry finds its anchor by scope and key**, with no new field on
   `GridEntry`, an Appendix C payload.
8. **The events section is `{"components": [...]}`**, now named in §13.9.
9. **One helper holds `prime ≥ PRIME_DIVISOR_CAP^2`** for its three sites.
   The prototyper adds it after the round. `_root_input_cell` stays.

Rulings on the smaller findings:

- A schedule row's float `Δt` is derivable exactly from `D` and `dt_base`,
  so the format needs nothing. That the float is not the nearest to the
  exact period predates the increment and has its own `pending.md` item.
- A primitive root prints no routes, so its pin has no mark in `show`.
  §13.7 says so.
- The `Vector{Union{}}` trap is in `code_rules.md`.
- A discrete consumer with an abstract `Real` entry refuses nothing and is
  no pinning consumer. D-468 defines the consumer by the refusal, so the
  spec stands. Read, not probed.

## 4. The record's checks, for the prototype to run

- That an `AbstractFloat` entry pins. Read off `_accepts_wire`, not run.
  Result: it pins, verified by running.
- That the bare `@ref` links of the component docstrings, 121 at the
  record's count, all name exported bindings. Result: none does, since
  nothing is exported. All 124 resolve, and all stand on the API page.
- That the docs build's `checkdocs` covers `Redstone.Library`. Result: it
  does not, `docs/make.jl` listing `modules = [Redstone]`.

## 5. Bookkeeping the code commit owes

- `src/descriptor.json`'s description cites `design/inspector/descriptor_design.md`,
  which is now `RedstoneInspector.jl/design/descriptor_design.md`, and says
  the grid report waits for a minor bump.
- `design/code_map.md`: the entries for `descriptor.jl`, `show.jl`,
  `linearize.jl` and whichever file takes the meet's function.
- The `pending.md` sub-bullet retires.

## 6. Open for the user

- "Grid report" had no glossary entry. D-467 took it to §13.9, a third
  place, where the coinage rule gives it one. The user asked for it the
  same day: the entry is `g-grid-report` in Appendix D.4, linked at the
  first use in §9.2 and §13.9 and from the `Structure` entry, with its rows
  in `tools/gloss_table.md` and `tools/coinage_inventory.md`. Closed.
- The glossary's `Structure` entry omits the anchor table from what the
  artifact holds.

## 7. The shape built

The prototype is the implementation. Its figures and probes are the
prototyper's, run in the worktree, and the coordinator re-ran none.

- **`src/build.jl`.** `pinning_consumers(structure, T = ProbeDual)` returns,
  per root input in `structure.root_inputs`' order, the `(path, port, tier)`
  of each consumer face the root input reaches whose entry refuses the root
  input's type walked to `T`. It reads the `Structure` alone, by the test
  `_seeded_tap` and `_root_input_cell` use.
- **`src/linearize.jl`.** `_seeded_tap(::Val{:u})` builds its `pinning`
  payload from that function at the activation's own scalar. The payload,
  its order, the witness and the message are unchanged.
- **`src/show.jl`.** `_route_lines` takes the marks, and `_pin_marks` maps
  each pinning consumer to `pinned by tier` or `pinned by declaration`.
- **`src/descriptor.jl`.** The build body is structure, outputs, `events`,
  warnings. `_deployment_body` is flat. `_schedule_section` writes the
  anchors' counts through `_anchor_counts`, the rows and the scopes. The
  structure section writes `dt`, the root inputs' `pinned` and `pinned_by`,
  `_grid_section` over `_grid_report`, and `rates` on each primitive node.
  `_events_section` writes the rows under `components`. `_docstring` runs
  the `@ref` pass through `_targeted_link`. `LOCATED_DECLARATIONS` gains
  `state_events`.
- **`src/descriptor.json`.** Thirteen new definitions, each new section
  required, `Anchor` under `dt`, and the description's two stale sentences
  corrected. The format stays at 1.0.
- **Tests.** `test/fixtures.jl` gains `pinned_fanout()`. `test/test_show.jl`
  gains a testset for the mark. `test/test_descriptor.jl` gains seven
  testsets, the parity client, and the fixtures `FloatEntry`,
  `DualUnionEntry`, `abstract_entries()`, `RefOwner`, `RefUser.Linked`,
  `unfactored_model()` and `chained_model()`.
- **`src/diagnostics.jl`, `src/structure.jl`.** One helper,
  `_unfactored(prime) = prime ≥ PRIME_DIVISOR_CAP^2`, sits in
  `diagnostics.jl` beside `GridEntry`, and `_supplies`, `_grid_block` and
  the writer's `_grid_section` call it. No other copy of the test remains.
- **`design/code_map.md`.** The entries for `build.jl`, `descriptor.jl`,
  `diagnostics.jl`, `linearize.jl`, `show.jl` and `fixtures.jl`.

**The figures.** The patch is 11 files, 874 insertions and 67 deletions.
In the worktree the gate read 10676 of 10676 before and after the helper,
against 10316 at the base, and the examples 179 of 179 before it. The
battery passed there. The mutants ran before the helper and were not
re-run.

**The `@ref` pass, as built.** A bare link is exactly `` [`name`](@ref) ``,
the name an identifier or a dotted path resolved segment by segment from the
type's parent module. The owner is `which(scope, sym)`, and the pass
rewrites only where `Base.isexported(owner, sym)` holds. Calls, unresolved
names, targeted links, plain-text links and glossary links stay as written.

## 8. What the tests pin

Each mutant ran alone on a scratch copy under its routed subset
(`mutants.py` and `mutants.log` in the prototyper's notes folder).

| mutant | subset | result |
|---|---|---|
| M1, the meet at `Marker` | descriptor, show | red |
| M2, a pool entry's anchor taken as its pool position | descriptor | red |
| M3, the `unfactored` flag dropped | descriptor | red |
| M4, the two marks swapped | descriptor, show | red |
| M5, `Relative(1)` links dropped from `rates` | descriptor | red |
| M6, the export test dropped from the `@ref` pass | descriptor | red |
| M7, an anchor's `phi` written from `D` | descriptor | red |
| M8, the events bundle dropped | descriptor | red |
| M9, `h_min` never written | descriptor | red |
| M10, `linearize` calling the meet at `ProbeDual` | linearize | survives, accepted (section 3a, item 1) |
| M11, a root input's `pinned` from the face flag | descriptor | red |
| M12, `state_events` not located | descriptor | red |
| M13, no route marked | descriptor, show | red |
| M14, `alternatives` dropped | descriptor | red |

The pin's oracle in the descriptor tests is the activation's own root cell,
`_root_input_cell`, which is separate code. The grid, schedule and events
assertions use literals and exact quotients computed in the test.

## 9. Out of scope

- `show(::Deployment)` in the notation, the bullet's next part.
- The inspector's repo. Its record needs two notes at the pin bump: the
  suppliers count from 1, and the link counts are 124 in 45 docstrings.
- The float `Δt` of a schedule row and the docs build's module list, each
  now a `pending.md` item.

## 10. The cold review's charter

One independent high-tier agent over the whole increment, by
`increment_rules.md`'s step 5: an open mind, probe scripts outside the tree,
and "empty is acceptable". Its sources are §13.9, §13.7's paragraph on the
mark, D-467, D-468, this file and the code commit's diff. It runs the gate
on the Julia floor `Project.toml` declares. Worth its attention:

- whether the parity client can pass while a fact `show` prints is missing
  from the file, since the client and the writer were written together;
- the `@ref` pass on link forms the fixtures do not hold, since no package
  link exercises it until the audit;
- `pinning_consumers` at a mount (D-277), where `linearize` reads the face
  the mount step landed on;
- the schema's strictness on the new definitions, each object closed and
  each new section required;
- the docstring of `descriptor` against `docstring_rules.md`.

## 11. Handover: landing the increment

The session that ran the prototype stopped at about 390k tokens of context,
at the record's commit, and a fresh session lands the increment.

**The state at the tip.** The spec, the log, `code_rules.md` and
`pending.md` hold every ruling. Sections 2 and 3a of this file hold the
reasons the log does not. The code is the patch beside this file, which
`git apply --check` passed at the tip of this commit. The prototyper checked
it at `f5ff3f5`; the commits since touch no file it touches.

**What the successor does**, by `increment_rules.md`'s steps 4 to 7:

1. `ListAgents`, then `git status`, before touching the tree.
2. `git apply design/increments/20261120_descriptor_content/prototype_descriptor_content.patch`
   from the repository root.
3. The run. The patch touches `diagnostics.jl` beyond a new kind, the
   routing table's last row, so the gate runs on the real tree, in the
   background, then the examples' runner, then the battery, since the patch
   edits `code_map.md`. Expect 10676 of 10676.
4. One code commit: the eleven files, the retired `pending.md` sub-bullet
   "The descriptor", and the parent bullet's sentence on which parts have
   landed.
5. Tell the peer session `redstone-jl-15` that the code is on master, with
   the hash. Its `Period` and `Hz` sweep waits on that, approved by the user
   and uncommitted in `Redstone.jl-worktrees/period_hz`. It takes D-469. It
   was sent the nine files of the first report and not yet
   `src/diagnostics.jl` and `src/structure.jl`, which the helper added.
6. The cold review, by section 10's charter, then the fixes and the
   reviewer's check of the delta.
7. The user diff-verifies the arc. Nothing is pushed without the user's
   word, and the inspector's increment 10 needs parts one to three pushed.

**Open, and not this increment's.**

- The bullet's next part, `show(::Deployment)` in the notation.
- The glossary's `Structure` entry omits the anchor table.
- The inspector's record needs its two notes at the pin bump (section 9).

**Paths.**

- The worktree: `/Users/miguel/.julia/dev/Redstone.jl-worktrees/descriptor_content`,
  detached at `f5ff3f5` with the patch applied and uncommitted. It can be
  removed once the code commit is on master.
- The prototyper's notes, probes, mutants and logs:
  `/Users/miguel/.julia/dev/Redstone.jl-worktrees/descriptor_content_notes/`,
  with `notes.txt`, `probe1.jl` to `probe5.jl`, `mutants.py`, `mutants.log`
  and `gate.log`.
- The prototyper cannot be resumed by another session. A question for it
  goes to a fresh agent with this file and those notes.

**The first prompt for the successor.** "Land the descriptor increment.
Read `AGENTS.md`, the sub-bullet 'The descriptor' of the first bullet of
`design/pending.md`, `design/rules/increment_rules.md`, and
`design/increments/20261120_descriptor_content/notes_descriptor_content.md`,
whose section 11 is the handover. The record and the patch are committed at
the tip. Apply the patch, run the gate, commit, tell the peer session, then
run the cold review."
