# Notes: the timing notation in the code

The record of the increment that makes `src/`, `test/`, `docs/` and
`code_map.md` conform to D-478 and D-479, run on 2026-11-24 overnight by
the session `notation-update-code`, handed over by `redstone-jl-40` after
the docs commit `e6c6ab4`. The user delegated the night, so the rulings
below are the coordinator's under `increment_rules.md`'s overnight clause,
each open to the user's morning review. Nothing is pushed.

## 1. State

- Stage reached: the delta check passed; the user's diff-verify of the
  arc is next, then the push. Earlier: the record, committed with the prototype's patch
  `timing_notation.patch`. The docs commit `d1b447f` carries the one spec
  sentence the key rename changes (§13.9's rate chain).
- Prototype worktree: `/Users/miguel/.julia/dev/Redstone.jl-worktrees/timing_notation`
  (branch `timing-notation-proto`, from `e6c6ab4`).
- Prototyper's notes and probes:
  `/Users/miguel/.julia/dev/Redstone.jl-worktrees/timing_notation_probes/`.

## 2. Rulings

Each is the coordinator's, made overnight, for the user's review.

1. **The descriptor's keys follow the notation** (handed over as the
   recommended reading). `Timing`'s `{anchor, m, c}` becomes
   `{anchor, D, phi}` and a `Relative` link's `{K, phi}` becomes
   `{D, phi}`. Each object fixes its count's lattice as a struct fixes a
   bare field's (D-478): a timing's counts are in its anchor's ticks, a
   link's in its scope's, a schedule row's in base ticks. The format stays
   at 1.0 (D-467). The user may overrule it: the rename breaks
   `RedstoneInspector.jl`'s reads until the inspector follows, which the
   user plans as a pin bump and a frontend adaptation after this increment,
   before the inspector's 10b.
2. **`show` prints the subscripted symbols as Unicode**, `Dₛ`, `Dₐ`,
   `Φ₀` and so on, as the spec writes them (handed over as the obvious
   reading).
3. **The prototyper's readings, all accepted.** Each with its reason:
   - *Formula mentions take the subscript, a field reference stays bare.*
     Comments and internal docstrings write `(n − Φ₀) % D₀`, `Φ₀ = 0`,
     `(D₀, Φ₀, Δt)`, while `row.Φ` and `entry.D` stay bare. D-478 reads a
     bare letter as a field name only. Rejected: sweeping only the retired
     letters and leaving bare `D`/`Φ` prose.
   - *`:not_a_count` says "`Dₛ` and `Φₛ` are integers"*, beside the
     `:multiplier` (`Dₛ ≥ 1`) and `:phase` (`0 ≤ Φₛ < Dₛ`) arms, since
     printed output writes the subscript. Rejected: the constructor's bare
     argument names.
   - *Two messages name `Δt_unit`*, the unit's `DeploymentInvalid` `:range`
     and `frame!`'s `ArgumentInvalid`, as D-479 names the unit and
     Appendix C writes it. Rejected: "the lattices' exact unit".
   - *`:unanchored` prints "period `Dₐ·Δt_base`"*, as §9.2 writes it for a
     component anchored on the base grid. Rejected: `D₀·Δt_base`.
   - *`CheckpointMismatch` keeps the field names `D`, `Φ`, `scope.D`,
     `scope.Φ`*, since its payload names a field and D-478 admits a bare
     field name. Rejected: a name map in `checkpoint.jl` to `D₀`/`Φ₀`.
   - *Locals spell a subscript with an underscore* (`D_a`, `Φ_0`),
     vectors over anchors take a word (`D_anchors`), `k` becomes `Q` where
     it held the admissible divisor and `Δt_k` becomes `Δt_anchor`, by
     `code_rules.md`'s naming rule. Rejected: Unicode subscripts in locals.
   - *`Timing` keeps the spec's field `Φ`*, and a new one-line writer
     `_timing` maps it to the ASCII key `phi`, since a field the spec names
     keeps its spelling. Rejected: a field named `phi`.
   - *`show(::Schedule)`'s chart index `k` becomes `n`*, D-479's base-tick
     index. The deployment chart's `k` counts `Δt_unit` columns and stays.
4. **The node's `timing` keys stay unnamed in the spec.** §13.9 names a
   primitive node's "timing" and leaves its keys to the schema, as it did
   for `m` and `c`. The prototyper offered a clause naming them; the
   coordinator kept the spec to the one sentence that named a retired key.
5. **The code lands before the user's diff-verify**, as the handover asked:
   applied, reviewed and fixed overnight, nothing pushed.

## 3. The shape built

21 files, +308 −286, all from the prototype (`timing_notation.patch`).

- `src/declare.jl`: `Relative`'s fields and constructors `D`, `Φ`; its
  docstring under `Dₛ`, `Φₛ`, `D₀(s)`, `Φ₀(s)`; `Absolute`'s summary
  "ticks at `t₀ + τ`, then every `Δt`".
- `src/structure.jl`: `Timing = @NamedTuple{anchor::Int, D::Int, Φ::Int}`;
  the fold, `_child_scope`, `_composing_link`, `_grid_report` (`Qₚ`),
  `_anchor_counts`, `_timing_counts` and `_check_trial_binding` under the
  new letters and locals.
- `src/deployment.jl`: `ScheduleEntry`, `ScopeEntry`, `Schedule`'s
  docstring (`D₀`, `Φ₀` under the fields `D`, `Φ`), the `Lattice`'s
  `Δt_unit`, `bind_schedule`'s locals.
- `src/diagnostics.jl`: the `RatesViolation` arms `:range`,
  `:multiplier`, `:phase` and `:not_a_count`, the grid block's
  `gcd(pool)/Q`, `GridUtilization`'s `at D₀ = N`, `:unanchored`'s
  `Dₐ·Δt_base`, the two `Δt_unit` messages; `GridEntry`'s `Qₚ`.
- `src/show.jl`: the headers. `Structure`: components
  `path tier anchor Dₐ Φₐ rates`, scopes `path key anchor Dₐ Φₐ`, anchors
  `anchor Δt τ scope key`. `Schedule`: rows `path anchor D₀ Φ₀ Δt rates`,
  scopes `path key anchor D₀ Φ₀`. `Deployment`: anchors
  `anchor Δt τ D₀ Φ₀`, components `path anchor Dₐ Φₐ D₀ Φ₀ Δt τ`, scopes
  `path key anchor Dₐ Φₐ D₀ Φ₀ Δt τ`.
- `src/descriptor.jl` and `src/descriptor.json`: `Timing`
  `{anchor, D, phi}` through `_timing`, a `Relative` link
  `{scope, key, D, phi}`; the format stays 1.0.
- `src/executor.jl`, `src/model.jl`, `src/sim.jl`, `src/build.jl`:
  comments only.
- Tests: `test_show.jl` (every pinned table regenerated by probe, headers
  and padding alone moved), `test_descriptor.jl` (the client mimic and the
  key pins), `test_diagnostics.jl` (three new pins), `test_discrete.jl`,
  `test_assembly.jl`, `test_declare.jl`, comments in `test_conditions.jl`,
  `test_build.jl` and `fixtures.jl`.
- `design/code_map.md`: the deployment, descriptor, executor, show and
  store entries.
- `docs/` and `examples/` carry none of the old letters.

## 4. Measurements and runs (the prototype's)

- Full gate under the sandbox flags: 10895/10895, 10 min 58 s.
- Examples runner: Longitudinal 179/179.
- `julia --project=docs docs/make.jl` (doctests, `checkdocs = :exports`):
  green.
- `design/tools/docstring_roster.jl`: every check empty.

## 5. What the tests pin, and the mutant that turns each red

Every mutant was run by the prototyper on a scratch copy, one line each.

| mutant | red in |
|---|---|
| descriptor `_timing`: key `phi` → `c` | descriptor, 55 failed |
| descriptor `_rate_link`: key `D` → `K` | descriptor, 17 failed |
| `Structure` header `Dₐ` → `m` | show, 3 failed |
| `Schedule` header `D₀` → `D` | show, 1 failed |
| `Deployment` anchor header `D₀` → `Dₖ` | show and descriptor, 9 failed |
| `Deployment` component header `Φₐ` → `c` | show and descriptor, 11 failed |
| `Relative`'s field `D` → `K` | declare, 1 errored |
| `Timing`'s field `Φ` → `c` | the package's precompile workload |
| `:multiplier` back to `K ≥ 1` | diagnostics, new pin |
| `:phase` back to `0 ≤ φ < K` | diagnostics, new pin |
| `:not_a_count` back to `K` and `φ` | diagnostics |
| grid block `gcd(pool)/Q` → `/k` | diagnostics, show, descriptor |
| `GridUtilization` `at D₀` → `at D` | diagnostics |
| `:unanchored` `Dₐ·Δt_base` → `m·Δt_base` | diagnostics, new pin |
| `Δt_unit` message back to "the lattices' exact unit" | diagnostics |

## 6. Bookkeeping

- `pending.md`: the bullet carries the stage; it retires when the user has
  diff-verified the arc, and the inspector's bullet then names the key
  rename the inspector follows.
- `code_map.md`: five entries, in the patch.

## 7. Out of scope

- `RedstoneInspector.jl`, whose reads of `m`, `c` and `K` break until its
  pin bump.
- The `K` and `φ` that are not the timing notation: `Delay`'s tap count
  `K`, the trim angle `φ`, `OpaqueRoster`'s type parameter `K`.
- `structure.jl`'s comment "anchors 1…K" and `_steps_line`'s comment
  index `j` in `(Φ₀ + j·D₀)`, which D-479 does not rule.

## 8. The cold review's charter

One independent high-tier reviewer over the code commit, open-minded, probe
scripts outside the tree, "empty is acceptable". It checks:

- that every timing count in `src/`, `test/`, `docs/`, `examples/` and
  `code_map.md` reads as D-478 and D-479 write it, printed output always
  subscripted, a bare letter only as a field name, and nothing else renamed;
- the descriptor: schema, writer and test client agree on the new keys, and
  §13.9 as amended in `d1b447f` describes them;
- the exported docstrings touched against `docstring_rules.md`;
- the tests: each changed pin and the mutants above, reverting each fix
  alone to show a test goes red, a survivor named;
- the gate on the Julia floor `Project.toml` declares (1.13).

## 9. The cold review and its rulings

One high-tier reviewer over `7c24c48`, in a detached worktree at that
commit. Gate on Julia 1.13.3: 10895/10895. Forty mutants, 36 killed. Its
notes and probes:
`/Users/miguel/.julia/dev/Redstone.jl-worktrees/timing_notation_review_probes/`.
The coordinator's rulings, each with its reason:

- **F1, accepted.** Three comments keep D-479's retired span letters,
  `n = ⌈g / h_max⌉` in `frame.jl` and `deployment.jl` and `n = ⌈r / cap⌉`
  in `model.jl`, where `n` now also indexes base ticks. They take `N` and
  `l` as §10.5 writes them.
- **F2, accepted.** `frame!`'s refusal changed to "counted in Δt_unit", and
  its pin stops before that clause. The pin extends to it.
- **F3, accepted.** The fold's phase law was tested only at scopes where
  `Dₐ(s) = Φₐ(s) + 1`, so `scope.Φ + 1` for `scope.D` survived. A scope at
  `Relative(5, 2)` over a child at `Relative(3, 1)`, `(D₀, Φ₀) = (15, 7)`,
  separates them.
- **F4, accepted.** `test_show.jl`'s `ticking(K)` becomes `ticking(D)`.
- **F5, accepted.** `test_discrete.jl`'s `D1`, `D2`, `Φ2` read as counts in
  ticks of `A₁` and `A₂` under D-478, so they become `D_outer`, `D_inner`,
  `Φ_inner`.
- **F6, accepted at `show.jl` alone.** `timing_cells(timing, D, Φ)` sets
  the field `D`, `Dₐ`, beside the local `D`, `D₀`. The locals become
  `D_0`, `Φ_0`. The sites in `deployment.jl` and `structure.jl` stay: each
  local there feeds a field of its own lattice at once, as a constructor
  parameter mirrors its field.
- **F7, accepted.** `show.jl`'s comment and `test_show.jl`'s testset name
  say `Δt_unit` for "exact unit".
- **S03, S04, acceptable survivors.** A schema's `required` list losing a
  key survives because the suite validates the writer's output alone and
  holds no negative schema test, a pattern older than this increment.

The fixer landed all seven in the real tree. The gate passes 10896/10896,
the one assertion added being F3's, and F3's mutant turns that assertion
red (`[(15, 5)] == [(15, 7)]`). In `frame.jl` the step end's offset is
written `i·l/N`, `l` being the code's `units·unit`.

The reviewer verified the delta at `57ac7dc`: each fix does what its
finding asked, nothing else in `src/` or `test/` changed, and M23 and M28
are now killed.

## 10. For the user's review

- The arc, unpushed: `d1b447f` (§13.9), `e15d7b2` (this record and the
  patch), `7c24c48` (the code), `57ac7dc` (the review's fixes), and the
  commit that closes this file.
- Rulings 1 to 5 in section 2 and the review's in section 9 are the
  coordinator's. Ruling 1, the descriptor's keys, breaks
  `RedstoneInspector.jl`'s reads of `m`, `c` and `K` until its pin bump.
- After the diff-verify the `pending.md` bullet retires, and the
  inspector's bullet names the key rename it follows.
- Worktrees to delete once the arc is pushed:
  `/Users/miguel/.julia/dev/Redstone.jl-worktrees/timing_notation` (branch
  `timing-notation-proto`), `…/timing_notation_review` (detached), and the
  probe folders `…/timing_notation_probes` and
  `…/timing_notation_review_probes`.
