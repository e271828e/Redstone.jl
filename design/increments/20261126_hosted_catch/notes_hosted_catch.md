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

- Stage reached: closed. The user approved the rulings of section 3 on
  2026-11-26 and asked for the push, and the scratch below was cleared after
  it.
- The scratch, removed after the push, was under
  `/Users/miguel/.julia/dev/Redstone.jl-worktrees/`: the worktrees
  `hosted_catch` (branch `hosted-catch-proto`), `hosted_catch_fix` (branch
  `hosted-catch-fix`), `hosted_catch_review` and `hosted_catch_review_pre`,
  nothing committed in any, and the notes folders `hosted_catch_probes`,
  `hosted_catch_fix_notes` and `hosted_catch_review_notes`, which hold the
  agents' notes and the gate logs.
- What the record rests on is beside this file: `hosted_catch.patch` and
  `probes/` from the prototyper, `review/` from the reviewer, and `fix/`
  from the fixer, with its patch.

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

D-482 states them as its Position. The user approved them on 2026-11-26,
after an explanation of ruling 3.3.1 from the start. They name five, the
ones the coordinator's summary listed: 3.3.1, 3.1.2, 3.1.1, 3.2.5 and
3.3.2. The rest of section 3 is either part of the shape they approved or
replaced by 3.3.1.

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
   the committed-state evaluation is evaluation 2 on the nominal scratch,
   since ruling 3.3.1 moved it there. A single count across the call was
   rejected. It needs a counter carried between the scratch models. So
   "evaluation 1 of trim!" can name the setup's derivative or the first
   search evaluation, both at the guess.
6. **The rendering lines** for the two hosts are the prototyper's, in
   `_host_lines` of `src/diagnostics.jl`. The location reads "<phase> of
   trim! at boundary N", so a round renders as "event round 1 of trim! at
   boundary 0". The boundary is kept for `trim!`, where it is always 0, so
   both services read alike.
7. **A fifth site, the committed-state evaluation.** Revised by ruling
   3.3.1, and kept here as it was first ruled. After the commit,
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
   The review showed what that state looks like, and ruling 3.3.1 replaced
   this one.
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

### 3.3 After the cold review

1. **The committed state is evaluated on a scratch.** This revises reading
   3.2.7. The review probed a simulation after a throw at the committed-state
   evaluation as first built. Its lifecycle read `built`, yet it held an
   open run, a taken trace header and one logged snapshot, which `logged`,
   `latest`, `series` and `show` exposed, and `MissingInit` said that
   boundary zero had not completed, which was false
   (`review/p1_commit_state.jl`). The status was untrue. Boundary zero had
   completed and published, and the evaluation writes only the derivative
   buffer. So `trim!` now takes the committed state to a `Float64` scratch
   by the checkpoint, as `linearize`'s default form does, and evaluates it
   there in a stretch under `:trim`. A throw there leaves the commit in
   place, the model `:consistent` and the simulation `initialized`, with no
   report. That is the lifecycle such a throw had before the increment, now
   framed, and it is what a throw from `residuals` at the same point leaves.
   `trim!` then touches the user's model through `init!` alone, the status
   follows from the host with no exception, and D-482 loses its one. The
   cost is one checkpoint, one restore and one sweep in each converged
   call, 1584 B measured. Rejected: keeping the evaluation on the user's
   model and stating the odd state in the spec, and dropping the log on that
   throw. The scratch is the nominal one the solve built, which the restore
   overwrites whole, where a fresh one would cost 20432 B
   (`fix/cp_cost.jl`). **This is the ruling most worth the user's eye.** It
   settles what `trim!` leaves behind when the committed state does not
   evaluate, and it was made twice.
2. **The claim is about the framework's entry points.** "Model code runs
   only inside a hosted stretch" left no room for the raw primitives a
   caller runs bare, which D-317 makes public. The sentence now speaks of
   the frame, the doors and the services, and says that a primitive run
   bare hosts nothing.
3. **A service's stretch is the tight one.** "A stretch holds the calls
   that run model code and no others" was false of the frame, which holds
   its hooks and the stepper's code, and of the restore, which holds the
   copy. D-441 rules those, wrapping whatever throws. The sentence is
   scoped to a service's stretch.
4. The `linearize` reproduction line names `about` and `t0`, as `trim!`'s
   names its keywords.
5. One more survivor is accepted. The phase write before the
   committed-state evaluation changes nothing a test can see, since the
   setup's stretch leaves the nominal scratch's cursor at the same phase and
   ordinal. The line stays, so the ordinal does not rest on what an earlier
   stretch left.

## 4. The commits

On master, none pushed:

- `73e2bf13`: this file opened, and the confirmation of the projection
  recorded in `pending.md` and the audit's notes.
- `c1ece565`: D-482, its annotations on D-132, D-223, D-224, D-317, D-441
  and D-481, and the sentences of §13.4, §14.8, §14.10 and Appendix C.
- `e3fb897c`: the record as it stood before the code, with the prototype's
  patch and probes.
- `ed33035e`: the code and its tests.
- `59a06198`: the review's fixes, code and docs together.
- The closing commit: this file, the reviews' and the fixer's probes, and
  the `pending.md` bullet.

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
  seeded scratch inside `eval!`, and the committed-state evaluation in
  `_verdict!`, on the nominal scratch with the commit's checkpoint restored
  onto it. `_solve_problem` returns that scratch in both packings.
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
| `trim!`, a whole converged call | 101632 B | 101472 B, and 102992 B with the review's fix |
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
  throw at the committed-state evaluation is a `StepError` under `:trim`
  that leaves the commit in place, the model `:consistent` and the
  simulation `initialized`. Mutants, the fixer's (`fix/mutants_fix.jl`): the
  evaluation on the user's model; unhosted; no restore; the reads off the
  user's model.
- A throw from `condition` inside the search and from `residuals` at the
  committed state arrive bare, the review's two missing tests. Mutants: the
  seeded `apply!` inside the stretch; the committed residuals inside it.
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
- The raw primitives a caller may run bare host nothing, as D-317 rules:
  `evaluate!`, `integrate!`, `boundary!`, `offtick_boundary!`,
  `boundary_zero!` and the bodies `phase_bodies` returns. The spec now says
  so. Two other runs of authored code sit outside every stretch and carry
  the `UserCodeFraming` carrier of their own: the activation's probe at a
  new scalar, and `ws_init` when a scratch is materialized.
- `MissingInit` says that boundary zero has not completed. That is false of
  a simulation left `built` by a throw inside `overlay!` or a restore. So is
  the list in `trace`'s docstring, which names `init!` alone. Both were so
  before.
- A restore does not reset the cursor's phase, so its `StepError` can carry
  the phase the last stretch left. It was so before.
- The committed-state evaluation runs `evaluate!`, the sweep and the
  derivative. The restore copies the whole table, so the derivative alone
  would give the same values, and the reviewer's mutant of that survives.
  The sweep is kept, as `linearize`'s default form runs it after the same
  restore. §14.8 still calls the committed-state residuals nearly free,
  which now means a checkpoint, a restore and one evaluation, 1584 B.

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

## 10. The reviews

One cold review by a high-tier agent, then its check of the fix. The gate
passed at each stage on Julia 1.13.3, the floor: 11067 of 11067 on the
prototype, twice, 11067 on `ed33035e` and 11075 on `59a06198`, the eight
more being the fix's assertions. The examples' runner passed 179 of 179 each
time. The reviewer reproduced the allocation figures of section 6 exactly.

The review found no defect in the code. It ran the prototyper's 30 mutants
and 21 of its own. Its findings, all closed in `59a06198`:

- Two missing tests, each shown by a surviving mutant: `condition` throwing
  inside the search, and `residuals` throwing at the committed state.
- "A stretch holds the calls that run model code and no others", false of
  the frame and the restore (ruling 3.3.3), and the headline claim with no
  room for the bare primitives (ruling 3.3.2).
- What a simulation looked like after a throw at the committed-state
  evaluation, which led to ruling 3.3.1.
- Sentences that listed where a throw leaves `built` and missed the
  committed state, moot after ruling 3.3.1. Three stale comments, on who
  writes the status, on the frame's `try` and on the pointer. Two docstrings
  that called a round an evaluation. The `linearize` line without its
  keywords.

The check of the fix found nothing new. On five problems the committed
residuals, the checks, the fired events and the model's state are identical
before and after the fix (`review/p5_committed.jl`): a plain one, one with
an event fired at the commit, one with a projection and an event, the
zero-decision one, and a simulation's claimed model after three frames. The
restore overwrites all a reader can see on the scratch, and mutants that
skip the table or the clock go red. The fixer's 13 mutants and three more of
the reviewer's ran: 13 red, and three survivors, each accepted with its
reason in sections 3.3.5, 7 and 8.
