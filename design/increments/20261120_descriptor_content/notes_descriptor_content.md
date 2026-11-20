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

## 4. The record's checks, for the prototype to run

- That an `AbstractFloat` entry pins. Read off `_accepts_wire`, not run.
- That the bare `@ref` links of the component docstrings, 121 at the
  record's count, all name exported bindings.
- That the docs build's `checkdocs` covers `Redstone.Library`.

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
