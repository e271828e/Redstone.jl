# Notes: one hosted catch for model code, the services' included

The record of the increment that puts every throw of model code under one
catch on the `Model`, whoever ran the code. It grew out of two items that
`design/increments/20261126_frozen_init/notes_frozen_init.md` lists as out
of scope, discussed with the user on 2026-11-26 in the session
`frozen-init-fable`, which coordinates it. The user then left and delegated
the run, so the rulings of section 3 are the coordinator's under
`increment_rules.md`'s clause for a delegated run, each open to the user's
review. Nothing is pushed.

## 1. State

- Stage reached: the prototype is being built. The readings round, the docs
  commit, the code commit and the cold review follow.
- Prototype worktree:
  `/Users/miguel/.julia/dev/Redstone.jl-worktrees/hosted_catch` (branch
  `hosted-catch-proto`).
- Prototyper's notes and probes:
  `/Users/miguel/.julia/dev/Redstone.jl-worktrees/hosted_catch_probes/`.

## 2. The user's rulings

All of 2026-11-26.

1. **The projection in `init!`'s nominal half stands.** The user agrees with
   the coordinator's ruling 3.1 of the frozen-init notes. The nominal half
   at a non-nominal scalar projects and then runs the round, as D-481 says.
2. **A model that skips `init!` is left as it is.** The frozen-init notes
   list a `Dual` model written with `apply!` and evaluated without `init!`
   as still reading the probe's frozen cells. It is not a `Dual` gap. A
   `Float64` model reads the same probe values, since `evaluate!` runs the
   interior sweep and a discrete output stage runs only at a boundary. §9.3
   says a fresh table holds the probe's values until `init!` or a restore
   writes it, the status reads `:built`, and D-481's promise is about a
   `:consistent` model. `probes/loose_ends.jl` shows both scalars. Each fix
   meets a standing ruling. D-213 keeps `apply!` raw. D-317 gives no model
   door a gate. D-481 rejected leaving establishment to the caller.
3. **A throw of model code inside a service's evaluation is framed.**
   `trim!` and `linearize` run every scratch evaluation outside any catch,
   so a stage that throws there arrives bare, where `init!` on the same
   condition raises a `StepError` naming the component
   (`probes/loose_ends.jl`). The frozen-init notes name the nominal round
   alone. The sites are four: `trim!`'s setup round with the guess
   derivative, `trim!`'s seeded evaluation, `linearize`'s round under
   `about`, and `linearize`'s passes. D-223 rejected raw propagation for
   boundary zero because it "forgoes the frame and keeps two shapes for one
   failure", and the solve is where a domain error is most likely.
4. **A solution is judged by the code it leaves.** The coordinator's first
   proposal added a guard for the services beside the doors' catches and the
   cursor copy of D-481. The user asked for the coherent shape, the cases
   already handled moved into it, at the cost of a wider change.
5. **A `Model` is a `Model`.** Whether it is the user's or a service's
   scratch has no bearing on how a throw inside one of its methods is
   handled. The coordinator's second proposal split the cases by whose
   executor ran the code, and the user rejected that axis. The split in the
   code is by layer. The methods that host a catch treat every model alike.
   The primitives under them have no catch and are meant to run inside a
   host. The services drop the model on their first line and drive the
   executor's primitives outside any host, and D-481's nominal half does
   the same and copies the cursor to get back under `init!`'s catch.
6. **The shape.** One helper on `Model` hosts every stretch of model code:
   the three doors, the frame, `init!`'s nominal half and the services'
   four sites. Each caller passes the model that runs the code, the pointer
   and the host. The helper wraps through `_wrap_step` from that model's own
   cursor and writes that model's status, on a scratch too. The status
   follows from the host as D-441 rules, `:inconsistent` for the frame and
   `:built` for every other. The inline `try` of `init!`, `overlay!`, the
   restore and `run_frame!` goes, and so does the cursor copy. The frame
   joins only if its allocation gate holds, and keeps an inline `try` with
   the same lines otherwise. The catch does not move into the primitives. A
   door must catch more than they run, the hooks and the stepper's own code
   among it, two layers cannot nest since `_wrap_step` refuses a
   `StepError`, and a primitive knows neither host nor pointer. The services
   keep their scratch `Model` and call its model-level primitives inside the
   stretch. A stretch holds the calls that run model code and nothing else,
   so the condition's application, the reads and the problem's own functions
   stay outside it, as `init!` applies its plan before its catch. The hosts
   gain `:trim` and `:linearize`, and the rendering states each host's
   lines in one place.
7. **The pipeline.** A single-stage increment, the prototype being the
   implementation, with this file as its record and no brief.

## 3. The coordinator's rulings, the user being away

The user left three points unruled and agreed that the prototype take the
coordinator's recommendation as its reading on each, to be ruled with the
figures in hand. They are recorded here as readings until the round.

1. `init!`'s nominal half runs before `init!`'s own stretch, not inside it.
   The user's ruling 6 of the frozen-init notes placed it inside `init!`'s
   `try`. Hosted stretches cannot nest. The outcome of that ruling is kept:
   a throw there is a `StepError` with host `:boundary_zero`, and the status
   is `:built`, which `init!` writes first.
2. An interrupt inside a service's stretch is wrapped, as D-441 rules for
   every catch. §14.8 says today that Ctrl-C during a solve unwinds as an
   ordinary call. The doors already show both shapes, bare during the
   plan's application and wrapped inside boundary zero.
3. A bare evaluation stands at a new phase, `:evaluation`, its index the
   evaluation ordinal.

## 4. Seen, and out of scope

- `pending.md` holds an open item, "a framework throw inside a step is
  framed as a component's". A hosted stretch wraps whatever reaches it from
  the cursor as it stands, so the item reaches the services' stretches as
  it reaches the doors'. It stays open.
