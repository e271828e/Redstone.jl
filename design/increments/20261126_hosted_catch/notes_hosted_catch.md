# Notes: one hosted catch for model code, the services' included

The record of the increment that puts every throw of model code under one
catch on the `Model`, whoever ran the code. It grew out of two items that
`design/increments/20261126_frozen_init/notes_frozen_init.md` lists as out
of scope, discussed with the user on 2026-11-26 in the session
`frozen-init-fable`, which coordinates it. The user then left and delegated
the run, so the rulings of section 3 are the coordinator's under
`increment_rules.md`'s clause for a delegated run, each open to the user's
review. Nothing is pushed. No brief was written, since the prototype is the
implementation.

## 1. State

- Stage reached: the record is committed with the prototype's patch. The
  code commit, the cold review, its fixes and the reviewer's check of them
  follow, then the user's diff check of the arc.
- The docs commit is `c1ece565`: D-482, its annotations on D-132, D-223,
  D-224, D-317, D-441 and D-481, and the sentences of §13.4, §14.8, §14.10
  and Appendix C.
- Prototype worktree:
  `/Users/miguel/.julia/dev/Redstone.jl-worktrees/hosted_catch` (branch
  `hosted-catch-proto`, from `73e2bf13`), nothing committed there.
- Prototyper's notes, logs and probes:
  `/Users/miguel/.julia/dev/Redstone.jl-worktrees/hosted_catch_probes/`. The
  probes, the mutant script and its two result files are copied to
  `probes/` beside this file, and the patch is `hosted_catch.patch`.

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
   `trim!` and `linearize` ran every scratch evaluation outside any catch,
   so a stage that threw there arrived bare, where `init!` on the same
   condition raised a `StepError` naming the component
   (`probes/loose_ends.jl`, run before the increment). The frozen-init notes
   name the nominal round alone, and the sites were wider. D-223 rejected
   raw propagation for boundary zero because it "forgoes the frame and keeps
   two shapes for one failure", and the solve is where a domain error is
   most likely.
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
   host. The services dropped the model on their first line and drove the
   executor's primitives outside any host, and D-481's nominal half did the
   same and copied the cursor to get back under `init!`'s catch.
6. **The shape.** One helper on `Model` hosts every stretch of model code:
   the three doors, the frame, `init!`'s nominal half and the services'
   sites. Each caller passes the model that runs the code, the pointer and
   the host. The helper wraps through `_wrap_step` from that model's own
   cursor and writes that model's status, on a scratch too. The status
   follows from the host as D-441 rules, `:inconsistent` for the frame and
   `:built` for every other. The inline `try` of `init!`, `overlay!`, the
   restore and `run_frame!` goes, and so does the cursor copy. The frame
   joins only if its allocation gate holds. The catch does not move into the
   primitives. A door must catch more than they run, the hooks and the
   stepper's own code among it, two layers cannot nest since `_wrap_step`
   refuses a `StepError`, and a primitive knows neither host nor pointer.
   The services keep their scratch `Model` and call its model-level
   primitives inside the stretch. A stretch holds the calls that run model
   code and nothing else, so the condition's application, the reads and the
   problem's own functions stay outside it, as `init!` applies its plan
   before its catch. The hosts gain `:trim` and `:linearize`, and the
   rendering states each host's lines in one place.
7. **The pipeline.** A single-stage increment with this file as its record.
   The user agreed that the prototype take the coordinator's recommendation
   on the three points of section 3.1 as its reading, to be ruled with the
   figures in hand, and then delegated the run.

## 3. The coordinator's rulings, the user being away

Each waits on the user's review. D-482 states them as its Position, so a
ruling the user overturns moves the entry too.

### 3.1 The three points the user left open

1. **`init!`'s nominal half runs before `init!`'s own stretch.** The user's
   ruling 6 of the frozen-init notes placed it inside `init!`'s `try`.
   Hosted stretches cannot nest. The outcome of that ruling is kept: a throw
   there is a `StepError` with host `:boundary_zero`, framed as at
   `Float64`, and the status is `:built`, which `init!` writes first. One
   thing moves with it. The scratch is now materialized outside any stretch,
   so a throw there propagates bare, the model `:built`. Two throws reach
   it: a `ws_init` throw, which arrives as the declaration's
   `UserCodeFraming` carrier as at any `Model(...)`, and an interrupt during
   the scratch's compile. Before, `init!`'s `try` wrapped both as a
   `StepError` that named no component.
2. **An interrupt inside a service's stretch is wrapped**, as D-441 rules
   for every catch. §14.8 said that Ctrl-C during a solve unwinds as an
   ordinary call. A service now shows two shapes, wrapped inside an
   evaluation and bare in its own code or the backend's. The doors already
   show both, bare during the plan's application and wrapped inside boundary
   zero. A second policy in the helper, for one kind of caller, would be the
   origin test the user ruled out.
3. **A bare evaluation stands at a new phase, `:evaluation`**, its index the
   evaluation ordinal. It renders as "evaluation N".

### 3.2 The readings round

The prototyper reported eleven readings. The coordinator ruled them the same
day.

1. **The helper calls its stretch with the model, `f(model)`.** The
   coordinator had proposed a closure, `f()`. Over the seeded scratch, whose
   type `_linearize` does not infer, the closure cost 272 B in each pass,
   and the bare call, the inline `try` and `f(model)` cost nothing
   (`probes/pass_cost.jl`). The hot sites pass the named function
   `evaluate!`. No site needs an inline `try`.
2. **The status follows from the host inside the helper**, and `fresh` is
   cleared for every host. A status argument would let a caller write a
   status D-441 does not rule. Only the frame's integration arms `fresh`, so
   the write does nothing elsewhere.
3. **The helper clears the cursor's component and function on entry.** The
   frame and the restore did it themselves. Every stretch now starts with no
   component named, so a throw before the first dispatch names no stale one.
4. **The pointer is the boundary the stretch's model stands at.** That is 0
   for every `trim!` site and for `linearize` under `about`, and the
   checkpoint's frame for `linearize`'s default form, as the restore
   computes it. Zero everywhere was rejected, since the default form's
   scratch does stand at a frame.
5. **The ordinal counts the evaluations on the stretch's own model**, and
   the establishment round is a round wherever it runs. The prototype first
   put the services' round at `(:evaluation, 1)`. The coordinator amended
   it: the same round stood at `(:round, 1)` in `init!`'s nominal half and
   in boundary zero, and one operation takes one label. The three nominal
   halves now share one primitive for it, `_establishment_round!(model)`.
   The count: `trim!`'s setup derivative is evaluation 1 on the nominal
   scratch, the search's evaluations run from 1 on the seeded scratch, and
   the committed-state evaluation is evaluation 1 on the user's model. A
   single count across the call was rejected. It needs a counter carried
   between the scratch models and into the verdict. So "evaluation 1 of
   trim!" can name three evaluations, told apart by the function, the
   model's status afterwards and the deterministic reproduction.
6. **The rendering lines** for the two hosts are the prototyper's, in
   `_host_lines` of `src/diagnostics.jl`. The location reads "<phase> of
   trim! at boundary N", so a round renders as "event round 1 of trim! at
   boundary 0". The boundary is kept for `trim!`, where it is always 0, so
   both services read alike.
7. **A fifth site, the committed-state evaluation.** After the commit,
   `_verdict!` evaluates `x_deriv` on the user's own model, outside any
   catch. A projection or a handler at the commit can move the state to a
   point where it throws, which the `FlipLag` fixture does. It is hosted
   under `:trim`, pointer 0, and writes `:built` on the user's model, since
   `trim!` is the door there (D-441). No report is returned, as for a throw
   inside the commit (D-224). On a simulation the lifecycle reads `built`.
   The run the commit opened keeps its trace header, which nothing can
   reach, since `trace(sim)` refuses a built simulation. Rejected: leaving
   it bare, a raw throw out of a door, and hosting it with the status kept
   `:consistent`, which needs the status argument of reading 2 and marks as
   consistent a model whose first frame would throw at the same point.
   **This one changes what `trim!` does to the user's model and is the
   ruling most worth the user's eye.**
8. **The frame joins the helper.** Its allocation is 0 B before and after
   (section 6).
9. **No caller assumes that a `StepError` out of `trim!` means the commit
   failed.** `sim.jl`'s `trim!` does no bookkeeping after the verdict. The
   simulation's `trim!` and `linearize` docstrings were silent on throws and
   now state them.
10. **The frozen-init record's mutants.** "No cursor copy" and the accepted
    survivor on the cursor reset are gone with the code. "The call outside
    the `try`" is now "the nominal stretch unhosted". The frozen-init
    testset on the nominal half's `StepError` holds unchanged at both
    scalars, for a stage and for a projection.
11. **`linearize`'s default-form restore stays unhosted.** It copies a
    state onto the nominal scratch and runs no model code.

## 4. The commits

On master, none pushed: `73e2bf13` (this file opened, and the confirmation
of the projection recorded in `pending.md` and the audit's notes) and
`c1ece565` (D-482, its annotations and the spec's sentences). The code
commit and the review's commits follow, and this section takes their hashes
at the closing.

## 5. The shape built

- `src/model.jl`: `_hosted(f, model, entry_boundary, host)` before
  `_wrap_step`, its one caller now. `_establishment_round!(model)` beside
  `_round!(model, tick)`. `init!` runs the nominal half and then
  `_hosted(boundary_zero!, model, 0, :boundary_zero)`. The nominal half
  keeps its copies outside and runs the projection and the round as a
  stretch on its scratch. `overlay!` and the inner restore call the helper.
- `src/frame.jl`: `run_frame!` calls the helper with `k - 1` and `:loop`.
- `src/trim.jl`: three stretches, all `:trim` with pointer 0. The setup's
  round and derivative on the nominal scratch, each `evaluate!` of the
  seeded scratch inside `eval!`, and the committed-state derivative on the
  user's model in `_verdict!`.
- `src/linearize.jl`: the `about` round and each pass, both `:linearize`,
  the pointer the checkpoint's frame or 0.
- `src/executor.jl`: the cursor's comments name the `:evaluation` phase.
- `src/diagnostics.jl`: `_phase_text` gains the evaluation. `_host_lines`
  returns each host's location phrase, reproduction line and interrupt line,
  and `showerror` prints from it in place of three ternary chains.
- `src/sim.jl`: the simulation's `trim!` and `linearize` docstrings.
- Docstrings of `trim!`, `linearize`, `TrimReport` and `StepError`, and the
  entries of `design/code_map.md` for the files above.
- `test/test_trim.jl`, `test/test_linearize.jl`, `test/test_failures.jl`:
  section 7.

## 6. The measurements

The prototyper's, under `(Float64, LinearizeDual)` with the results used
(`probes/measure.jl`). The frame is read on the whole `frame!` call, since
the helper wraps the whole frame.

| Measure | Before | After |
|---|---|---|
| `frame!`, per frame, on three models | 0 B each | 0 B each |
| `init!(plan)` at `Float64`, the two models of last night's review | 368 B, 752 B | 368 B, 752 B |
| `trim!`, one evaluation inside the solve | 0 B | 0 B |
| `trim!`, a whole converged call | 101632 B | 101472 B |
| `linearize`, a whole call, width 8 and width 1 | 59536 B, 58736 B | 59536 B, 58736 B |
| one hosted `evaluate!` on a seeded scratch | 0 B bare | 0 B |

The gate passed 11067 of 11067 on the prototype, before and after the
amendment of reading 5, and the examples' runner 179 of 179.

## 7. What the tests pin

Each with the mutant that turns it red, all run by the prototyper
(`probes/mutants.jl`, results in `probes/mutants_result.txt` and
`probes/mutants_result2.txt`).

- A throw in each service site is a `StepError` with its host, path,
  function, phase and pointer: the setup's round and derivative, a search
  evaluation, the committed-state evaluation, the `about` round and a pass.
  Mutants: each site unhosted; each under the wrong host; the round outside
  the stretch; the pointer always 0.
- The phases: the round at round 1 at each of the three nominal halves, and
  the evaluation ordinal at the second search evaluation and the second
  pass. Mutants: the primitive writes no phase; each site calls a bare
  `_round!`; no `:evaluation` phase; the phase reset at every evaluation.
- The user's model is untouched by a throw in the search, for a model at
  `:consistent`, a fresh one at `:built` and an initialized simulation. A
  throw at the committed-state evaluation leaves it `:built`.
- The problem's own functions stay outside. A throwing `residuals` and a
  `condition` with no `Dual` method arrive as they are, and a refused
  condition stays a `DiagnosticError`. Mutants: the residuals inside each
  stretch.
- An interrupt inside a stretch of `trim!` and of `linearize` is a
  `StepError{InterruptException}`.
- The helper: the status by host, and the cursor cleared on entry. Mutants:
  `:built` for the frame too; no clear; each door under another host.
- The rendering of the two hosts, their interrupt lines and the evaluation
  phase. Mutants: each arm removed.
- `init!` at a `Dual` still raises boundary zero's `StepError` framed as at
  `Float64`, by last night's testset. Mutants: the nominal stretch unhosted,
  under another host, with no phase.

One survivor is accepted. Dropping `fresh = false` from the helper changes
nothing a test can see. A door or a service never arms the flag, and the
frame re-arms it at each attempt. A stale flag after a cut frame could be
read only by a bare `evaluate!(model)`, which had no pin before either.

## 8. Out of scope, and seen

- `pending.md` holds an open item, "a framework throw inside a step is
  framed as a component's". A stretch wraps whatever reaches it from the
  cursor as it stands, so the item reaches the services' stretches as it
  reaches the doors'. The cursor clear on entry narrows it to throws after
  the first dispatch. It stays open.
- The bare `integrate!` primitive can leave `fresh` armed after a throw in
  the middle of an attempt, since it runs unhosted. It was so before.
- `code_map.md`'s build.jl entry still lists §6.3 on its Spec line, as the
  frozen-init notes say.

## 9. The cold review's charter

One independent high-tier agent, over the docs commit `c1ece565` and the
code commit together, with an open mind, and "empty is acceptable". It runs
the gate on the Julia floor `Project.toml` declares and the examples'
runner. It reverts each fix alone on a scratch copy to see a test go red.
Beyond the usual, it is asked to look at four things: whether any call that
runs model code is still outside every stretch, in the services or
elsewhere; whether anything that is not model code sits inside one; what a
simulation looks like after a throw at the committed-state evaluation; and
whether D-482 and the spec's sentences say what the code does.
