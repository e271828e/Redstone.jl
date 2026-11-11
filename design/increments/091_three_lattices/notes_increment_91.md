# Notes: increment 91, rulings made overnight

The user delegated increment 91 on the night of 2026-11-10 to 2026-11-11.
`rules/increment_rules.md` asks that every ruling the coordinator makes
while the user is away be written here with its reason. Nothing is pushed.
Each ruling below is the coordinator's and is open to reversal; the ones
marked "put to the user" were stated to the user before they left and drew
no objection in the minutes they had.

## Before the prototype

1. **A due instant inside a step splits the step. The user's ruling**, made
   on 2026-11-11 before leaving, not the coordinator's. A fixed step `h`
   divides `Δt_frame` and nothing else; step points are counted from the
   frame top; the loop advances to the nearest of the next step point, the
   next due instant and the frame top. It reverses D-443's fourth bullet,
   ratified the day before, and D-019's "`Δt_base` is an integer multiple
   of `h`". The coordinator had first ruled to keep D-443 and raised the
   alternatives; the user chose the split over two others:
   - *`h` divides `Δt_base`, D-443 as ratified:* at `RK4()` it is the
     `:not_frame_multiple` refusal under another name; it makes "a base
     tick at which nothing is due is no boundary" vacuous for a fixed step;
     and an offset's finer base grid becomes a finer integration step.
   - *`h` divides every component's period and offset:* a more complex
     check that helps only when the base is finer than the schedule needs.
   What the split gives up: equal steps inside a frame, unless the user
   picks `h` to divide every period and offset and uses `Bool` guards; and
   the constructor's refusal of a schedule off the step lattice.
2. **The roadmap's lattice test runs as written**, at `RK4()`, which ruling
   1 makes legal: one step per frame plus one in each frame holding a due
   instant off its top.
3. **`localization_tol` references `Δt_frame` and the budget stays per
   frame** (put to the user), the roadmap's recommendation on its one open
   decision for this increment.
4. **One clock write per boundary, by the coarsest lattice the instant is
   on.** A frame top keeps `t₀ + k * Δt_frame`, the formula every existing
   run and every test's clock value uses; a due instant off the frame tops
   is written from the base-tick index; a sub-step end on neither from the
   step index. Reason: bit-identity of the existing trajectories, and the
   roadmap's "each instant is computed from its own index, coincidence is
   decided on the deployment's rationals, and the clock is written once".
5. **An instant on the base lattice at which nothing is due takes the empty
   due set**, by D-185's arity selection. Reason: the roadmap's "a base tick
   at which nothing is due is no boundary"; the table is the same either
   way.
6. **Freshness lives on the framework side of the seam**, so RK4's and
   Heun's `integrate!` bodies are untouched until increment 3 rewrites them
   under `attempt!`. Reason: one rewrite of the backends, not two.
7. **The vocabulary sweep to "non-localized" is its own stage and commit**,
   after the loop lands. The prototype keeps "boundary-detected" in the text
   it rewrites. Reason: no commit then mixes the two terms, and the
   prototype's context goes to the loop. The log is not swept:
   `log_rules.md` rule 2 applies a rename forward only, and this is a
   rename, not the retirement of a misleading word.
8. **Scope is roadmap increment 2 alone.** The seam protocol is not started
   tonight.

## Open, for the user

- **A report of the steps per frame.** With the refusal gone, nothing tells
  a user that their schedule splits steps. `show(deployment)` could state
  the steps per frame over one hyperperiod, "4" or "4 to 6". Proposed to
  the user on 2026-11-11 and left out of this increment; a strictness
  keyword is not proposed.
- **Whether an unsplit step always takes `h` exactly.** At the tip a model
  with localized events integrates by the float difference of two frame
  tops, one without by `Δt_frame` itself. The prototype keeps both
  bit-identical and reports what a single rule would cost.

## On the prototype's readings

The prototype ran as two high-tier agents on one worktree at c22d79d. The
first stopped at its context limit with the docs and the loop rewrite done
and handed the rest to the second. These are the rulings on the readings
the first one raised.

9. **The `Lattice` lives on the `Deployment`, outside `==` and `hash`**, as
   `grid` does. The `Deployment` stores its periods as `Float64`, so the
   exact periods the loop decides coincidence on travel in this field.
   Known hole: two exact periods that round to one `Float64` compare equal
   while their step sequences could differ. Reason for accepting it: the
   comparison was on `Float64` periods before, and storing and comparing
   exact periods is a change to the deployment's surface, the user's to
   make.
10. **No next-due cache.** The next due instant is recomputed from the
    frame's position, one `mod` per schedule row at a due boundary. The
    roadmap says "cached as a next-due index". Reason: a cache is state
    that `init!` and `restore!` must reset, and the recomputation is a few
    integer operations beside a sweep. The measurement of `_next_due`'s
    cost is in the brief.
11. **`frame!` refuses a frame past the lattice's `Int` range** as
    `ArgumentInvalid`, before its `try`, and the doors refuse a finite
    `t_end` past it. An unbounded run would end on that throw. The second
    agent pins what a `Simulation` reports there.
12. **Freshness at a frame top comes only from the hooks' report.** A hook
    that reports nothing counts as having written, and the first frame of
    each advance counts as written, since `apply!` or a staged write can
    land between advances.
13. **`NonfiniteState.boundary` comes from the loop's frame index**, since a
    step can now end inside a frame and rounding the clock no longer finds
    the frame.
14. **The cursor's phase after a boundary at which nothing is due is
    `:round`, not `:ticks`.** A visible change in a diagnostic's payload:
    at the tip a frame top of a model with no discrete rows ran the ticks
    block with every gate failing, and a `StepError` raised after it named
    `:ticks`. Ruling 5's empty due set never enters that block. Two pins in
    `test_failures.jl` moved from `:ticks` to `:round`. Reason: the cursor
    names the block that ran last. The alternative, forcing `:ticks` at
    such a frame top, keeps the old payload at the cost of a special case.
15. **Two step-length rules stay**, as at the tip: a model without
    localized events integrates by the exact length of the piece, one with
    them by the float distance to the step's end. A single rule would move
    every localized trajectory by an ulp here and there, which breaks the
    increment's invariant.
16. **D-444's Rationale is corrected** where it said a linearization
    integrates; linearization drives the sweep, never the integrator.
17. **The doors that take a frame count refuse one past the lattice's `Int`
    range**, as the `t_end` door already does. The second agent found that
    `step!(sim; frames = 1000)` ran 921 frames and then threw on a
    deployment whose range ends at frame 921. Reason: a door refuses up
    front what it can know up front. An unbounded `run!` still ends on
    `frame!`'s refusal, as a loop error with the clock at the last frame
    top; that is pinned, and its redesign is open below.
18. **`frame!`'s refusal gets a message of its own.** It fell through to
    `t_plus`'s text, "t_plus must be a finite real > 0 ... got 922".
19. **A `ChatteringBudget` raised in a frame with sub-steps rides the next
    frame's first step end, not its top.** No ruling was needed: the delta
    has always ridden the first publication after the fold. It is recorded
    because a reader of `latest(sim)` at frame tops no longer sees it there.
20. **`ArgumentInvalid` gains a `related` field**, the bound a `:range`
    value passes, `nothing` elsewhere. The second agent added it so
    `frame!`'s refusal can name the last frame the lattices index. Accepted:
    the message needs the bound, and Appendix C states the field.
21. **The range messages of `t0`, `t_end`, `frames` and `t_plus` now say "the
    last frame the lattices index"** where they said "fits an `Int`". The
    second agent went past ruling 18 here. Accepted: the bound those doors
    check is now the lattice's, and the old text named another.
22. **`test/test_lattices.jl` gets a `code_map.md` entry**, though no other
    property file has one, because it defines the suite's `Recorder`
    backend, which increment 3's stub will build on. **The Deviations list
    in `pending.md` is left empty**, its heading and intro kept.
23. **The prototype is the implementation.** The coordinator applied its
    patch to the real tree in two commits, docs first, and did not re-run
    the full gate there: the second agent ran it on the same content,
    9642 of 9642, and the cold reviewer runs it again.

## Open, for the user (added during the night)

- **The Rejected lists of D-445, D-446 and D-447 are reconstructed.** The
  roadmap states those rulings without their alternatives. The prototype
  wrote each rejection from the contrast the roadmap's own sentence draws,
  such as "the step lands on due instants, not on base ticks". They read
  true to the discussion as recorded, but only the user can confirm them.
- **Should the `Deployment` store and compare exact periods?** See ruling 9.
- **What an unbounded run should do at the end of the lattice's `Int`
  range.** See ruling 11. The alternative is to cap the unbounded budget
  there and end the run as if a `t_end` had been reached.
- **A run that ends on a loop error logs "the run ended errored" while
  `lifecycle(sim)` reads `:stopped`.** Found while pinning ruling 11, and
  reproduced at c22d79d with an ordinary exception thrown into the loop
  task, so it predates this increment. `lifecycle` derives `:errored` from
  the model's status alone, and a loop error leaves the stores a settled
  boundary. It may be two vocabularies and no defect; no `pending.md` item
  was written for it.
