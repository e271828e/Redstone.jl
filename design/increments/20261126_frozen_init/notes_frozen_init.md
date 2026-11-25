# Notes: `init!` establishes the frozen cells at a non-nominal scalar

The record of a small increment that closes row S9b-300 of the docs
conformance audit, with its wording row CV9a-049. The audit's record is
`design/reports/20261124_doc_conformance/notes_doc_conformance.md`. The
user ruled the row and the five readings below on 2026-11-26 and then left
for the night, so the prototype ran while the user was away. No brief was
written, since the prototype is the implementation. This file holds what
the spec, the log and `pending.md` do not carry.

## 1. The defect

A `Model` at a `Dual` keeps each frozen discrete cell at the build probe's
product after `init!`, with status `:consistent` and no diagnostic. The
probe is `design/reports/20261124_doc_conformance/probes/user_rows/s9b300_frozen_cells.jl`:
a discrete `Cmd` feeds a continuous `Lag`, and after `init!` with `r = 2`
the `Float64` model reads `ẋ = 2` where the `Dual` model reads 0.

D-213 describes this failure and closed it for `trim!` and `linearize`,
which call `_establish_frozen!` on their seeded scratch. D-317 then made
the model at another scalar public, and its `init!` never took the step.

## 2. The user's rulings

All of 2026-11-26.

1. The code moves. `init!` at a non-nominal scalar establishes the frozen
   cells as a service does. The doc alternative would leave a `:consistent`
   model on fabricated values, and a user's own service could not establish
   them, the helper being private.
2. Only `init!` changes. `restore!` copies the whole table of a state taken
   at the same scalar, and refuses a `Float64` state as `CheckpointMismatch`,
   so it inherits what `init!` established. `overlay!` runs an off-tick
   boundary, which moves no discrete cell on a `Float64` model either.
   `apply!` is the raw write D-213 keeps raw.
3. The nominal half is D-213's round as it stands: one establishment round
   on a `Float64` scratch, with no projection, no events and no `s_update`.
   A full nominal `init!` on the scratch is rejected, since its cells would
   come after events the `Dual` model never fires. Where boundary zero
   fires an event or projects, a `Dual` model's frozen cells can therefore
   differ from the `Float64` model's after the same `init!`, the difference
   D-317 already rules.
4. The nominal half takes its values from the model, not from the
   condition. After `establish_defaults!` and the plan, the model's stores
   hold the complete authored world. The scratch copies `x` and the
   root-input cells with partials dropped, and `s` and `m` as they are,
   their types being the same at every activation. This covers the
   plan-taking `init!` too, and no condition tree is walked twice.
5. `trim!` and `linearize` stay as they are. Their nominal half also serves
   the guess evaluation and the zero-decision bypass.
6. A model with no frozen component skips the scratch. The nominal round
   sits inside `init!`'s `try`, so a throw there is a `StepError` with host
   `:boundary_zero`. How that error names the component is the prototyper's
   to report, since the scratch has a cursor of its own.

The entry the user approved in draft:

> **Position.** `init!` on a model at a non-nominal scalar establishes its
> frozen discrete cells as a service does (D-213): a nominal scratch takes
> the model's authored state with partials dropped, runs one establishment
> round, and its frozen cells are copied. No cell of a `:consistent` model
> holds a probe value, at any scalar.
>
> **Rejected.** Leaving establishment to the caller; a full nominal
> boundary zero; resolving the condition again at `Float64`; refusing
> `init!` at a non-nominal scalar.

The spec sites named in the discussion: §9.3 takes CV9a-049's sentence,
§9.4's "hold `Float64` values" says which values, and §14.5 takes one
sentence. The `init!` and `boundary_zero!` docstrings and the comment in
`build.jl` on a frozen component's carried product follow.
