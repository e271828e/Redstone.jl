# Notes: the build's refusal of a structure no deployment binds

The record of the work that delivers D-465, run on 2026-11-20 by one
coordinating session and two high-tier agents, the code while the user was
away. It is not an increment: a docs commit, then two loose commits, a
file split and the trial's code. No brief was written, and the agents'
prompts stand in the session's transcript. This file holds what the spec,
the log and `pending.md` do not carry: the rulings made in the session,
the findings, the coordinator's decisions while the user was away, and
what the coordinator did not verify.

## 1. The commits

- `175aec7`: `pending.md` orders the refusal ahead of the grid report.
- `82c64b5`: the spec and D-465, with annotations on D-187 and D-459.
- `16c5d62`: `src/assembly.jl` split into `assembly.jl` and
  `structure.jl`, a pure move.
- The commit that adds this file: the trial's code, its tests and the
  retired bullet.

Nothing is pushed.

## 2. The user's rulings

Each is stated in the spec or the log except where noted.

- The build refuses a structure that no deployment binds, and the
  frontier is whole: the pool, a divisor composed past `Int` beneath an
  anchor, and the frame loop's margin (D-465). The user's condition was
  that the frontier not be partial.
- The diagnostic is `RatesViolation` `:range` on the entry that composed
  the count (D-465).
- The grid arithmetic that reads the structure alone lives with the
  structure, never in `deployment.jl`. The frame loop's margin moves down
  as a helper that `_lattice` and the trial both call, so every call goes
  down the include order. Recorded here and in `code_map.md`.
- `assembly.jl` is split, not renamed, and the split lands before the
  trial's code. Recorded here and in `AGENTS.md`.
- For the grid report's part, still to build: `show(::Structure)` prints
  `_grid_block`'s lines under `grid:` after the anchor table, prints no
  block for a structure with no anchors, and `show(::Deployment)` drops
  its `grid:` block. Recorded on the `pending.md` bullet.

## 3. Findings

- **The grid report's overflow was not the test D-459 took it for.** The
  anchors `Absolute(Period(2^40))`, `Absolute(Period(1), 1//4099)` and
  `Absolute(Period(1), 1//4111)` get a whole report, admissible
  `1//16850989`, and the first counts about `1.85e19` base ticks there.
  D-465's Rationale holds the case, and the suite pins it.
- **A built structure's report never overflowed in the probes.** The
  builder ran 20,000 random trees, of which 6,674 built, and 3,000 pools
  made to sit at the frontier, of which 1,701 passed the trial.
  `_grid_report` threw on none, and every built tree deployed at
  `Δt_frame = Δt_base = gcd(pool)`. `bind_schedule` now calls
  `_grid_report` with no catch.
- **No caller's choice bound a refused structure.** For the nine refused
  boundary cases the builder called the binding helpers at 42 choices of
  base tick and frame each, and none bound. The five passing neighbours
  bound at 5 or 6 of the 42. The random probe ran the same check over its
  13,241 refusals at 25 choices, and none bound.
- **A rate scope with no discrete member can be declared**, an unkeyed
  continuous primitive in a keyed `Group`. Its divisor can overflow with
  no component row beneath it, and the trial refuses it. Its divisor takes
  no part in the frame margin, as in `_lattice`, so a scope at
  `typemax(Int)` with no component there deploys.
- **`test_discrete.jl`'s `huge` fixture was itself undeployable.** It was
  `Absolute(Period(typemax(Int)), typemax(Int) - 1)`, whose divisor
  leaves no frame at any base tick. Decision 4.2 below.
- **The split found the cut was not at a section boundary.** Endpoint
  resolution reads the draft and moved. Tier classification reads a
  component's declarations alone and stayed. The walk's memos
  `WALK_FACES`, `WALK_CHILDREN` and `_walked_children` stayed, since
  their readers are the build primitives.
- **Three stale texts the split left as they were**, since changing them
  is no move:
  - `structure.jl`'s banner "the sample-time fold" covers the whole walk,
    from `flatten_tree!` to `_check_root_faces`;
  - `build.jl`'s header says the flattened tree holds "one resolved
    producer per input", which predates D-315;
  - `code_map.md`'s Spec line for `structure.jl` omits D-414 and §10.5,
    which its bullets cite. The gap was the old `assembly.jl` entry's, and
    it went to `structure.jl` with the two bullets.
- **The inspector's repo names `assembly.jl` for what moved**, at
  `RedstoneInspector.jl/design/failure_descriptor.md` lines 70 and 84 and
  in the foundation increment's brief at lines 98 and 393. Nothing there
  was changed.

## 4. The coordinator's decisions while the user was away

1. **The trial runs before the first barrier**, right after
   `flatten_tree!`, so its refusals join the walk's in one throw. The
   spec states the premise as a fold with no violation, and D-229 runs
   every check whose premise holds. The alternative, after the barrier on
   a clean walk, would report the refusal one round late.
2. **The `huge` fixture's new values are accepted.** It is now
   `Absolute(Period(2^62), 2^62 - 1)` at `Δt_base = 1//4`, and it asserts
   what it asserted: `:anchor_period` and `:anchor_offset` at a base tick
   the caller chose finer than the gcd.
3. **An anchor's refusal carries the declared entry**, found on the chain
   of whatever the anchor keys, where the prompt had it rebuilt from the
   `Anchor`'s fields. The builder's reading, accepted: one spelling of the
   entry.
4. **The chain search throws `InternalInvariant` when no link passes the
   limit.** A sound fold makes that unreachable.
5. **The split's helpers moved with their only callers.** Read per
   definition, `_endpoints`, `_wrong_direction`, `_check_sample_times`,
   `_rate_entry`, `_entry`, `_check_face_names` and `_check_root_faces`
   read no draft, and each is called from the walk or the fold alone.
6. **`_grid_block` and `DeploymentInvalid.grid` still accept `nothing`.**
   The non-grid refusals carry no report, and the tests build occurrences
   without one.
7. **No exported docstring was edited.** None states anything false. See
   section 6.

## 5. What the coordinator verified, and what it did not

- Verified on the split: the line multiset of the old file against the
  two new ones, 7 lines on one side and 15 on the other, all headers, one
  banner and one repointed comment; the two gate logs, 10291 of 10291
  before and after.
- Verified on the trial: the new section of `structure.jl` read whole,
  the diffs of `build.jl`, `deployment.jl` and `diagnostics.jl`, the
  gate's log at 10312 of 10312, and the docs battery.
- Not verified: the probes' figures in section 3, the eleven mutants the
  builder ran, the examples' runner, and the test bodies beyond their
  testset names. Those are the builder's. No cold review ran.

## 6. Open for the user

- Whether a cold review should run over the trial. The increment rules
  ask for one on an increment, and this work was run as loose commits.
- The docstrings of `Absolute` and `sample_times` list the build's
  refusals and omit the new one. `Relative`'s already omitted the fold's
  `:range`. They could join the docstrings' later passes in `pending.md`.
- The three stale texts of section 3.
- The inspector repo's mentions of `assembly.jl`.
- The record `RedstoneInspector.jl/design/deployment_overlay.md` expected
  the grid report's placement to take the log number after D-464. D-465
  took it, and the placement entry will be D-466.

## 7. The follow-up, on the user's word the same day

The user asked for three of section 6's items to be fixed, in one loose
commit after the trial's.

- **The docstrings.** `Relative` and `Absolute` each gain a paragraph on
  the build's refusal of an entry that leaves the tree no `Δt_base` to
  deploy at, and `sample_times` points at the two for an entry's own
  refusals.
- **The stale texts.** `structure.jl` gains the banner "the walk" ahead of
  `flatten_tree!`, so the fold's banner covers the fold alone.
  `build.jl`'s header names the `Structure` and D-315's resolution.
  `code_map.md`'s Spec line for `structure.jl` gains §10.5 and D-414. The
  line for `assembly.jl` needed nothing, since none of its bullets cites
  either.
- **The inspector's repo.** `failure_descriptor.md` names `structure.jl`
  at its two present-tense mentions, in a commit of that repo. The
  foundation increment's brief keeps `src/assembly.jl:1565` to `1596`:
  the brief is pinned to the core at `9c2ba28`, where that path and those
  lines are right, and `structure.jl` does not exist at that tip.

## 8. Handover: the grid report's part

The next work is the sub-bullet "The grid report, derived from the
structure" of `pending.md`'s first bullet. It was not started. The
session that wrote this file stopped at about 360k tokens of context, and
a fresh session takes the part. Its sources are that bullet,
`RedstoneInspector.jl/design/deployment_overlay.md` answers 6 and 17, and
this section. It lands as a spec and log commit, then its code.

**What is ruled.** The report is a function of the structure's anchors,
derived where it is used, and `Deployment` drops its `grid` field (the
record's answer 6). The user's three rulings of 2026-11-20 are on the
bullet: `show(::Structure)` prints `_grid_block`'s lines under `grid:`
after the anchor table and before the routes; a structure with no anchors
prints no block; `show(::Deployment)` drops its `grid:` block. The line
once planned for a pool that admits no deployment is gone, since D-465
leaves no such structure. Whether `show(::Deployment)` prints its
`Δt_base` against the coarsest admissible one was raised and left to
part four.

**The log entry, D-466.** It states the placement and annotates D-254,
whose third bullet lands the grid diagnostics on the deployment, and the
last bullet of D-261, which keeps `Deployment.grid`. The refusal's
message, the derivation line and `GridUtilization` stay the deployment's
and keep the report in their payloads. Its rejected alternatives are the
report kept on the deployment, where D-254 bundled it with the three
things that do depend on the deployment, and the field moved to the
`Build`. D-261's rule on derived values is the reason.

**The spec sites**, all found by reading, none edited:

- §9.2's opening paragraph, "how a `Deployment` explains its grid";
- §9.2's `Deployment` paragraph, which lists "the grid diagnostics below"
  among what the artifact holds;
- §9.2's rendering list, the `show(::Structure)` bullet, which gains the
  report, and the sentence under "The `Schedule` lives on the
  `Deployment`" that calls the schedule the diagnostics' substrate;
- the lead ruling of "Grid diagnostics", "The grid diagnostics live on the
  `Deployment`", bold under D-187 and D-254, which the new entry replaces.
  The paragraph "A built structure always has a grid report" is D-465's
  and stays;
- Appendix B's `Deployment` line, "carrying the `Schedule`, the grid
  diagnostics and its `warnings`";
- Appendix D's `Deployment` entry, the same phrase, and its `Structure`
  entry, which can say the report is a function over the anchors;
- Appendix C's `GridUtilization` row cites D-254 for the warning's home,
  which stands.
- Appendix D's `Schedule` entry calls the schedule the substrate of the
  grid diagnostics, as §9.2 does. Both are to be read against the new
  placement, since the report reads the anchors and only the advisory
  reads the rows.

**The code sites.**

- `src/deployment.jl`: the field, the constructor's argument, the
  `bound.grid` hand-off, the comment on `==` and the docstring of
  `bind_schedule`, which lists the grid attribution among what it returns.
  The constructor still needs the report for the derivation line and the
  advisory.
- `src/show.jl`: the block in `_lines(::Structure)`, `_lines(::Deployment)`
  without its `grid` lines, and the header comment's two sentences on the
  block.
- `src/diagnostics.jl`: the comment above `GridEntry` still says the
  `Deployment` carries a report.
- `src/structure.jl`: `_grid_report`'s docstring names its callers.
- `src/descriptor.json` mentions the grid report at its deployment body.
  That is part three's.

**The test sites.**

- `test/test_discrete.jl` reads `deployment.grid` at about fifteen places,
  which become `_grid_report(deployment.build.structure.anchors)` or a
  local helper. `_grid_report` is already on `test/imports.jl`'s list. One
  identity check, `warning.grid === grid`, compares the warning's payload
  with the field. `GridReport` has no `==`, so it becomes a read of the
  warning's own payload.
- `test/test_show.jl`: `MULTIRATE_STRUCTURE` has one anchor, `1//50`, so it
  gains a block, by hand `admissible: gcd(pool)/k, coarsest 1//50`, one
  pool row and `primes: 50 = 2·5²` with two rows. That text was not run.
  The `Deployment` testset loses its three `grid:` assertions, and the
  anchored group's block moves to a structure assertion.
- `test/test_diagnostics.jl` reads `.grid` off a deployment once, near its
  unfactored-cofactor case.

**The run.** `deployment.jl` is in the routing table's last row, so the
commit runs the gate, about ten minutes, and the examples' runner. The
suite read 10312 of 10312 at `05089f1`.

**The first prompt for the successor.** "Continue the first bullet of
`design/pending.md` at its sub-bullet 'The grid report, derived from the
structure'. Read `AGENTS.md`, that bullet, and
`design/increments/20261120_structure_trial/notes_structure_trial.md`,
whose section 8 is the handover. The spec and log commit, D-466, comes
first, then the code."

## 9. The grid report's part, landed

A fresh session took section 8's handover the same day and landed the part
as two commits, on the user's word at each.

- `41ff09c`: the spec, D-466 and the stage on the `pending.md` bullet.
- The commit that adds this section: the code, its tests, `code_map.md` and
  the retired bullet.

**Beyond the handover, confirmed by the user.**

- D-187 and D-257 are annotated beside D-254 and D-261. D-187 calls the
  schedule the substrate of every grid diagnostic, and D-257 lists what
  `show(::Structure)` prints.
- D-466's Rationale gives `show(::Deployment)`'s lost block a reason in the
  session's words, that the block states nothing the deployment fixes. The
  handover held the ruling and no reason.
- The Rationale cites the data survey's finding B5 for why D-261 kept the
  field.

**The shape built.** `bind_schedule` still computes the report once per
`Deployment` call and returns it, for the refusals, the derivation line and
the advisory. Only the hand-off to the struct went. `show(::Structure)`
derives its own.

**What changed shape in the tests.**

- `test_discrete.jl`'s identity check `warning.grid === grid` is gone. The
  line after it pins the payload's drivers.
- The neighbour testset asserted the report on each of three deployments of
  one build. It now asserts it once on the build, and the loop keeps
  `Δt_base`.
- `test_show.jl` gains a structure testset for the block and its absence,
  and the `Deployment` testset asserts no `grid:` line.

**The run.** The gate read 10316 of 10316, against 10312 at `05089f1`.

**Left as found.**

- `src/descriptor.json` says the grid report waits for a minor bump. That is
  the descriptor's part.
- The glossary's `Structure` entry omits the anchor table from what the
  artifact holds.
- "Grid report" has no glossary entry. With the descriptor's part it reaches
  §13.9, a third place, where the coinage rule gives it one.
