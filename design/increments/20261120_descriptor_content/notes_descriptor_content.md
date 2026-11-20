# Notes: the descriptor's content and a root input's pin

The record of the increment that builds D-467 and D-468, part three of the
core work ahead of the inspector's increment 10 (`pending.md`, first
bullet). It is run by the pipeline of `design/rules/increment_rules.md`: a
prototype in a scratch worktree, a readings round, this file as the record.
It holds what the spec, the log and `pending.md` do not carry.

## 1. State

- `1537538`: the spec and D-467, the descriptor's content.
- `df553d8`: the spec and D-468, a root input's pin.
- The commit that adds this file opens the increment. No code is written.
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
