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
  - `code_map.md`'s Spec lines for `assembly.jl` and `structure.jl` omit
    D-414 and §10.5, which their bullets cite.
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
