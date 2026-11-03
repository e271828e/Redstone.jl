# Brief: increment 86, the Comparator, the Integrator's commanded reset and the Sequence

One docs commit, one code commit applied from the prototype, one cold
review and a fixer if the review needs one. Drafted on 2026-11-03 at
cfb0db0, the code commit, after the docs commit 40a8e6c; not normative.
Find passages in `design/implementation.md` by heading. The measurements
and the readings are filled from the prototype, taken on 2026-11-03 by one
Opus agent on a scratch worktree at b7f52f3, resumed once with the user's
rulings. The patch lands as `prototype_increment_86.patch` beside this
brief, the worktree's diff from b7f52f3 to its tip 2a58420.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

## What is settled

The first of the four library increments `pending.md` orders, the three
blocks whose rows the inventory recommended first. None earns a log entry
(`decisions_style.md` rule 9); the inventory carries the design, docs
commit first, and the code conforms. The user's rulings of 2026-11-03,
made on the prototype's readings:

- **The `Sequence` handler catches up, never increments.** The row's
  `m += 1` sticks one short for good whenever two breakpoints are observed
  at one boundary, two inside one boundary-detected step or two at or
  before `t₀` under either policy: §10.6 reads each edge against the
  last-observed sample, so after the first firing the guard on the next
  breakpoint already holds and presents no fresh edge, and the prior is
  written as holding. The handler is `m = searchsortedlast(times, t)`.
  `times` ascend strictly, since equal times would leave a value never
  published. The row's sentence on the quiescence loop was wrong both ways
  and is rewritten.
- **The `Integrator` reset has no latch.** The row's latch pair, a `Bool`
  mode set by the reset and cleared by a re-arm guard, is what §2.3's edge
  semantics already does: a predicate that keeps holding presents no edge,
  so the guard `u.reset` alone fires once per rising edge and never while
  held. The mutant dropping `!m` survived every behavioural pin. One
  boundary-detected event `reset`, guard `u.reset`, handler `x = x0`, no
  mode; the row's claim that the latch pair is what D-362 means goes.
- **The `Comparator`'s fall is strict**, `u < lower`, spelled
  `prevfloat(lower) - u` in sign form so root-finding stays on a function
  continuous in `u`. With `Relay`'s non-strict guards and `lower == upper`,
  an input sitting exactly on the threshold holds both predicates, each
  switch re-enables the other, and the block exhausts its firing budget at
  `t₀` (`Relay(lower = 0, upper = 0)` on `Constant(0.0)` raised
  `FiringBudget(:switch_on, 0.0, 4, 4)`). The events keep `Relay`'s names,
  `switch_on` and `switch_off`; `lower > upper` is refused. The signature
  is `Comparator(; threshold = nothing, lower = nothing, upper = nothing,
  localized = true)` by the map's caveat on dependent defaults: `threshold`
  alone, or both limits, any other mix an `ArgumentError`.
- **`Relay`'s fall becomes strict too**, the same two lines, so
  `lower == upper` is a plain threshold that chatters nowhere. No existing
  relay pin relied on the non-strict fall.
- The `Switch` docstring names the `Comparator` first and the `Relay`
  beside it as the declared way to produce `select` from a continuous
  quantity.

## The shape built

All in `src/blocks.jl`, each block an ordinary component reaching the
parent through the file's import list, with a docstring in the file's
style and `@docs` entries in `docs/src/api.md`.

- `Comparator{V, L}` with fields `lower` and `upper`, `V` the `Relay`
  bound (`Real` or a static array), `L` the policy. `m_init` an `Int8`
  code per component, `0` below and `1` above; `u_types` bare `V`;
  `y_types` `Pinned{channel_type(V, Bool)}`; `y_state` `m .== 1`. Localized
  guards `m == 0 ? u - upper : -one(u)` and
  `m == 1 ? prevfloat(lower) - u : -one(u)`; boundary-detected guards
  `m == 0 && u >= upper` and `m == 1 && u < lower`. Over a vector the
  events are generated per component as `Relay`'s are, `switch_on_i` and
  `switch_off_i`.
- `Integrator{V, R}`, the second parameter from the keyword `reset`.
  `R = false` is the block as it was, bare on both sides, no mode, no
  events, and `Integrator(x0 = 1) isa Integrator{Float64}` still holds.
  `R = true` names the input side `(u = V, reset = Bool)`, the data port
  keeping the face `u` (D-437), `x_deriv` reading `u.u`, and declares one
  event `reset = StateEvent(reset_guard, reset_handler)` with guard
  `u.reset` and handler `(x = c.x0,)`, policy `:boundary`. Neither form
  declares `m_init`. The keyword constructor spells both parameters, since
  the positional constructor cannot infer `R`.
- `Sequence{V, L, N, M}` with `times::SVector{N, Float64}` and
  `values::SVector{M, V}`, `M = N + 1` because a type cannot write
  `N + 1`; `values` promoted and floated as `Step`'s keywords are. No
  inputs; `m_init` `0`; `y_types` `Pinned{V}`; `y_state`
  `values[m + 1]`. One event `advance`: guard
  `m < N ? t - times[m + 1] : -one(t)` localized, `m < N && t >= times[m + 1]`
  boundary-detected; handler `(m = searchsortedlast(times, t),)`. The
  constructor refuses a non-strictly-ascending `times` and a `values`
  length other than `N + 1`. `N = 0` is accepted, a constant, untested.
- `Relay`: `switch_off_guard` becomes `prevfloat(c.lower) - u`, scalar
  and per-component; the `lower` keyword reads "at most `upper`".
- `test/imports.jl` imports `Comparator` and `Sequence`.

## Measurements

Taken on the worktree, re-checked on the real tree at cfb0db0 for the
routed subset:

- The routed subset `blocks build` under the sandbox flags: blocks 2149,
  build 436, against 2003 and 436 before the increment. The Dual sweep is
  unchanged at 122 covered, 61 skipped and 90 refused, since it covers the
  test module's own fixtures only.
- The full gate on the worktree before the rulings, two halves: half A
  (`leaves declare assembly store build blocks executor continuous
  discrete stepper events localization dataplane roster`) 3805 in 5m40s,
  half B (`bindings devices log trace readers conditions trim linearize
  diagnostics failures lifecycle show descriptor precompile`) 3890 in
  3m22s, both exit 0. The rulings changed `blocks.jl` and `test_blocks.jl`
  only, and the routed subset ran green after them; the cold review runs
  the gate again.
- Builds: every block under `(Float64, LinearizeDual, ProbeDual)`, scalar
  and vector; `Pinned{Bool}` wires into `Switch`'s `select`.
- Jump landing: a `Comparator` on the ramp `t - 0.25` driving a `Switch`
  into an integrator lands at `0.25` localized (the integrator reads
  `0.25` at `t = 0.5`) and on the boundary `0.3` boundary-detected (it
  reads `0.2`). An input exactly on a plain threshold reads `true` with no
  `FiringBudget` under either policy.
- The reset: three `Step`s summed into `Comparator(0.5)` into `reset`,
  `x0 = 0.5`, `u = 1`, `h = 0.1`. With localized steps `x` at `0.2, 0.3,
  0.5, 0.8, 1.0` reads `0.7, 0.55, 0.75, 1.05, 0.65`, the resets landing at
  `0.25` and `0.85`, the steps' own boundaries, through a three-round
  cascade (step, sum, comparator, reset); boundary-detected, `0.7, 0.5,
  0.7, 1.0, 0.6` with the resets at `0.3` and `0.9`. Holding `reset` high
  resets once; a second rising edge resets again; `reset` high at `t₀`
  fires at boundary zero and overrides a condition's `x = 2.0` with `0.5`.
  Linearized about a held `reset`, `A = [0]`, `B = [1]` on `u`; tapping
  `reset` is refused as `TapResolution` `:unseedable` (D-168), so the
  `reset` column cannot be produced, only held.
- The sequence: values `0, 1, -1, 2` at `0.25, 0.45, 0.75` integrate to
  `0.4` by `t = 1.0` localized and `0.3` boundary-detected; two breakpoints
  inside one step (`0.23` and `0.27`) give `m = 2` at `0.3`, the integral
  to `0.4` reading `0.43` and `0.3`; breakpoints at `-1` and `0` are both
  passed at boundary zero, and a lone breakpoint at `t₀` fires there;
  `N = 1` gives bitwise the same integrator state as `Step`.
- Allocation: `phase_bodies` and the quiet boundary allocate 0 for every
  block's model, scalar and vector.
- Churn: 5 files, +569 −29; `blocks.jl` 229, `test_blocks.jl` 355.

## Readings the prototype took

The ones the user ratified are in "What is settled". The rest, kept as
built:

1. The `Comparator`'s localized fall could instead use `LimitedIntegrator`'s
   gate idiom, `m == 1 && u < lower ? lower - u : -one(u)`, whose
   discontinuity falls back to bisection at about 15 extra sweeps;
   `prevfloat` keeps the function continuous. Kept.
2. `Sequence` could declare `N` events `advance_i` gated on `m == i - 1`,
   correct through §10.6's re-decision of blocked edges but `N` guards
   per sweep and `N` rounds at boundary zero; a re-arm latch pair costs
   two rounds per breakpoint and sticks past four coincident breakpoints
   under `firing_budget = 4`. Rejected both.
3. `fed(Integrator(reset = true))` alone is refused as `UnconnectedInput`
   for `c/reset`, so the reset tests use a two-face rig.
4. The vector reset form has no behavioural test, only the keyword and
   type checks; its law is the scalar one componentwise.
5. `Step` publishes `Float64` only, so a `Bool` input is driven through a
   `Comparator` on a sum of steps.
6. The examples in `src/declare.jl` at lines 152 and 190 quote
   `u_types(::Integrator{V})`; the method is now on `Integrator{V, false}`
   and the example stands as an illustration. The spec's illustrations at
   its lines 2570, 2571 and 2815 likewise.
7. The "resets once while held" pin is the framework's edge rule, not
   block code, so no block mutant targets it.

## What the tests pin, by property

- Declarations: the reset form's `(u, reset)` input side, its one event
  with policy `:boundary`, `m_init === nothing` on both forms; the plain
  form's type.
- The reset trajectory at both step policies, the reset landing on the
  step's boundary; once while held; again at the next rise; high at `t₀`
  through boundary zero against a condition; the linearization about a
  held `reset` and the `:unseedable` refusal.
- The comparator's threshold, hysteresis, start below, the jump landing
  through a `Switch` at both policies, the vector form per component; the
  six refused keyword mixes, `lower > upper` scalar and vector, and
  `Comparator(lower = 0, upper = 1).upper === 1.0`.
- The sequence's values between breakpoints at both policies; two
  breakpoints in one step and at or before `t₀` advancing together; the
  lone breakpoint at `t₀`; `N = 1` equal to `Step`; the vector form; the
  constructor's refusals.
- The relay's strict fall: `Relay(lower = 0, upper = 0)` on `Constant(0.0)`
  reads on from boundary zero, stays on for three steps, raises no
  `FiringBudget`; a vector twin reads `(1, 1)`.
- Allocation: the phase bodies and the quiet boundary of every model.

Mutants the prototype ran on the worktree, each turning a named pin red:
the comparator's non-strict fall in each policy, the on guard's sign
flipped, either handler dropped, the off guard reading `upper`, the mode
starting above, the `Bool` form given the localized guard, the vector
form reading `upper[1]` or `lower[1]` or writing component 1, the
constructor accepting `threshold` with a limit, defaulting a lone limit,
dropping the `lower > upper` refusal, swapping the limits; the reset
guard firing on the fall or never, the handler writing zero, the event
dropped, the derivative zero; the sequence's `m + 1` handler,
`searchsortedfirst`, the guard's sign flipped, the guard reading
`times[1]`, the output off by one, the `Bool` form given the localized
guard, strict `>` in the `Bool` form (killed by the lone breakpoint at
`t₀`); the relay's non-strict fall, scalar and vector. The one reasoned
and not run: dropping `lower === nothing ||` from the comparator's
refusal turns the empty call's `ArgumentError` into a `MethodError`.

## Bookkeeping

- The docs commit 40a8e6c: the inventory's rows for `Comparator`, the
  `Integrator` reset and `Sequence` to shipped with the corrected
  mechanism cells, the `Relay` and `Switch` rows amended, the order
  note in its section 4; the map's `src/blocks.jl` entry with D-141 on
  its Spec line.
- The code commit cfb0db0: `src/blocks.jl`, `test/test_blocks.jl`,
  `test/imports.jl`, `docs/src/api.md`, and `design/pending.md`'s library
  bullet with the shipped trio retired from the order.
- This brief and the patch, their own commit.

## Out of scope

- `LimitedDoubleIntegrator`, the structure blocks and the additions to
  shipped blocks: the three increments that follow.
- The inspector's fixtures: regenerated once after the four increments.
- The inventory's `Relay(; lower, upper, off = zero(lower), …)` spelling
  against the map's caveat on dependent defaults: the code's actual
  signature, left as is.

## The cold review

One fresh Opus reviewer over cfb0db0 against 40a8e6c, with §2.3, §3.1,
§5.3, §10.4, §10.6, §13.7, D-141, D-179, D-181, D-437 and the three
inventory rows read for what they owe: open-mind stance, probe scripts in
the scratchpad, "empty is acceptable". Dimensions:

- **The docs against the tree.** Every clause of the three rows' mechanism
  cells and of the `Relay` and `Switch` amendments holds of the code,
  each probed.
- **Edge semantics.** The catch-up handler and the latchless reset are
  right by §10.6's bookkeeping: build the stuck cases (two breakpoints in
  one boundary-detected step, two at or before `t₀`, `reset` held high
  across several boundaries, `reset` high at `t₀` after a `restore!`) and
  read the mode and the state.
- **The strict fall.** A plain threshold on an input that sits on it,
  crosses it, and touches it from each side without crossing, under both
  policies, for `Comparator` and `Relay`; the localized fall's root is
  found at the crossing and no step is split for a touch.
- **Localization.** The comparator's and the sequence's localized events
  end the step at the crossing and the boundary-detected ones at the
  first boundary after it; the jump through a `Switch` lands there.
- **The hot path.** `@ballocated` 0 on every phase body and quiet boundary
  of the test models at `(Float64, LinearizeDual)`; the `Sequence`'s
  `searchsortedlast` over a static vector allocates nothing and
  specializes once per `N`.
- **The plain integrator.** Unchanged behaviour and compiled code for
  `R = false`: the `Dual` walk, the linearization, every existing pin;
  `Integrator{Float64}` spelled anywhere in `src/`, `test/`, `examples/`,
  `README.md` and `docs/` still builds.
- **Naming** over every touched line, and the docstrings against
  `docstring_style.md`.
- **Mutants on a scratch copy**, each named test going red, the list above
  re-run plus any the reviewer adds. A surviving mutant is a missing test,
  or an acceptable survivor named with its reason.
- The gate green on the Julia floor `Project.toml` declares.
