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

## 3. The coordinator's rulings, the user being away

1. **The nominal half projects.** Ruling 3 above said "no projection", and
   its reason was false of the code. A model at a `Dual` fires no events but
   does project its own `x` at boundary zero, `x_projection` being in the
   `Dual` executable set (§9.4). The cold review showed what the unprojected
   round costs: a rotor started off its constraint left a frozen cell at 2.0
   where the `Float64` model and the model's own projected state read 1.0,
   and an `acos` reader behind it made `init!` throw at the `Dual` alone.
   The nominal half therefore mirrors what the model itself runs at boundary
   zero, projection and then the round, with no events. The alternative,
   keeping the round unprojected and recording both effects, is two lines of
   `_establish_frozen!(model, origin)` and the entry's wording. **This
   departs from the letter of the user's ruling and waits on the user's
   confirmation.** D-481's Position gained "projects it as boundary zero
   does" for the same reason.
2. The prototyper's readings stand as taken. A throw in the nominal half
   copies the scratch's cursor into the model's, field by field, so the
   `StepError` carries the frame a `Float64` model's boundary zero reports.
   `_drop_partials` lives in `model.jl` beside its one caller. The new
   method shares the name `_establish_frozen!`. The whole call sits inside
   `init!`'s `try`. The workspaces, the event priors and the stepper are not
   copied, since a round with no events reads none of them.
3. §9.3's sentence reads "until `init!` or a restore writes it", where the
   user approved "until `init!` writes it", since `restore!` also writes a
   `:built` table.

## 4. The commits

On master, none pushed: `55bc376e` (D-481, its annotations on D-213 and
D-317, and the sentences of §9.3, §9.4 and §14.5), `bff344cc` (the code and
its tests) and `8e66ad01` (the review's fixes). `frozen_init.patch` beside
this file is the three together.

## 5. The shape built

- `src/model.jl`: `_establish_frozen!(model, origin)` and `_drop_partials`
  in the scratch-world section, the one call as the first statement of
  `init!`'s `try`, and the docstrings of `init!` and `boundary_zero!`.
- `src/build.jl`: comments only. Three said a frozen cell holds the probe's
  product for the whole run, and two cited §6.3 for the seeding, which §9.3
  states.
- `test/test_discrete.jl`: `discrete_frozen_init`, five testsets over
  fixtures that are groups of existing components plus `Fuse`.
- A `Float64` `init!` is unchanged in behaviour and in allocation, 368 B and
  752 B per call on the reviewer's two models
  (`review/probe_cost.jl`). At a `Dual`, a model with a discrete component
  builds one `Float64` executor per `init!`, which nobody has timed.

## 6. What the tests pin

Each with the mutant that turns it red, all run by the prototyper
(`probes/mutants.jl`, `probes/mutants_land.jl`) and again by the reviewer
(`review/mutants.jl`).

- A frozen cell after `init!` equals the `Float64` model's, the derivative
  and ten frames of the continuous state follow, a continuous `y_direct`
  behind the cell reads it at once, and an offset component is established
  though not due. Mutants: the call deleted; the round moved after boundary
  zero; a due-only round in place of the establishment round.
- The nominal half takes each walking value alone and leaves the model's
  partials. Mutants: no `x` copy; no root-input copy; one layer of a nested
  `Dual` dropped.
- It reads the authored `s`, `m` and clock. Mutants: each copy removed.
- It projects as boundary zero does. Mutants: no projection; projection
  after the round.
- A throw in it is boundary zero's `StepError`, framed as at `Float64`, for
  a stage and for a projection. Mutants: no cursor copy; no phase written;
  the call outside the `try`.

Two survivors are accepted. Building the scratch for a model with no frozen
component changes a cost and no value; a probe shows no scratch is built.
The cursor reset before the scratch is built is reached only by a throw
before the round, in practice an interrupt during the scratch's compile.

## 7. The reviews

One cold review by a high-tier agent, then its check of the fix. The gate
passed at each stage: 10960 of 10960 on the prototype, 10973 on the
increment as first committed, and 10991 on the fixed tree, which is
master's but for the last wording of D-481's Position and the `init!`
docstring. The examples' runner passed on that tree.

The review's findings, all fixed in `8e66ad01`: the missing projection
(ruling 3.1); a conflict marker the coordinator's merge left in `log.md`,
which no tool of the battery catches; two missing tests; "from the nominal
activation" in §9.4, whose products are the probe's; a claim in D-481 that
`linearize` keeps a nominal half as `trim!` does; an ambiguous annotation on
D-317; a stale test comment; and the cursor reset.

## 8. Out of scope, and seen

- `trim.jl` and `linearize.jl` run their nominal round outside any `try`,
  the scratch cursor at its default, so a throw there propagates raw.
- `code_map.md`'s build.jl entry still lists §6.3 on its Spec line, though
  `build.jl` cites it nowhere now.
- A public `Model` at a `Dual` that a user writes with `apply!` and
  evaluates without `init!` still reads the probe's frozen cells. `init!` is
  the door that establishes them.
