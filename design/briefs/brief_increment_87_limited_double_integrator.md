# Brief: increment 87, the limited double integrator

One docs commit, one code commit applied from the prototype, one cold
review and a fixer if the review needs one. Drafted on 2026-11-04 at
edeb2f2, the docs commit, before the code commit 1590a08; not normative.
Find passages in `design/implementation.md` by heading. The measurements
and the readings are filled from the prototype, taken on 2026-11-04 by one
Opus agent on a scratch worktree at 7e04e8c, resumed once with the
coordinator's rulings. The patch lands as `prototype_increment_87.patch`
beside this brief, the worktree's diff from 7e04e8c to its tip f5169ee.
The user delegated the increment and was away: the rulings below are the
coordinator's, each with its reason in `notes_increment_87.md`, for the
user to reverse at the arc's review.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

## What is settled

The second of the four library increments `pending.md` orders, the one
block the user set apart on 2026-11-03. No log entry
(`decisions_style.md` rule 9); the inventory carries the design, docs
commit first, and the code conforms. The rulings, made on the prototype's
readings:

- **The keywords name the leaves.** The row's `x0` becomes `q0`, so `q0`
  initializes the leaf `q` and `v0` the leaf `v`, as `x0` and `s0`
  initialize a bare store's one leaf. In the library `x0` means the
  whole initial state, which here is the pair. The user may prefer the
  row's `x0` for uniformity with `LimitedIntegrator`; the rename is three
  sites and a docstring.
- **The input is read bare.** The coda of increment 86 reads
  `LimitedIntegrator`'s input through `signal(u)` because its reset form
  names the side. This block has no reset form, so its derivative and
  leave guards read `u` directly; the four event tuples are grouped under
  `limit_events` as the coda groups them, so a reset form, if ruled,
  splits `state_events` on `R` as `LimitedIntegrator`'s does.
- **The row's "first handler" claim is corrected.** Since increment 86
  the reset handlers already write `x0`, a value other than a limit. What
  is new is a hit handler writing a second leaf its guard does not read.
- **Promotion stays as it is.** `float.(promote(0.5, 0, SVector(-1, -1),
  SVector(1, 1)))` throws an `ErrorException` from `promote`, so a scalar
  `q0` beside vector limits is refused by Base, not promoted and not
  refused by the block. `LimitedIntegrator` behaves the same. Not this
  increment's; a loose fix would refuse it on both with an
  `ArgumentError`.
- **No reset form.** The row has none. The prototype's reading on what
  `R = true` would cost is in "Readings", with the two questions a
  ruling needs.

## The shape built

All in `src/blocks.jl`, after `LimitedIntegrator`'s vector `limit_events`
and before `Relay`, append-only, with a docstring in the file's style and
a `@docs` entry in `docs/src/api.md`.

- `LimitedDoubleIntegrator{V, L}` with fields `q0`, `v0`, `lower` and
  `upper`, `V` the `LimitedIntegrator` bound (`Real` or a static array),
  `L` the leave policy; the keyword constructor
  `LimitedDoubleIntegrator(; lower, upper, q0 = zero(lower), v0 =
  zero(lower), localized = true)` promotes and floats the four values to
  one `V`.
- The state is the named pair `x_init = (q = q0, v = v0)`; the mode is
  the bare `Int8` code `Int8.(zero(q0))`, `-1`, `0`, `+1` as
  `LimitedIntegrator`'s; the input `u` is bare, the acceleration;
  `y_types = (out = V, velocity = V, saturation = saturation_type(V))`,
  published from stage 1 as `(out = x.q, velocity = x.v, saturation = m)`.
- `x_deriv`: `q̇ = v`, `v̇ = u` while free, both zero while saturated,
  gated on the mode by `ifelse.`.
- Four events under `limit_events`, `LimitedIntegrator`'s names and
  reasons. `hit_upper`: guard `x.q - upper`, sign form, ungated, always
  localized; handler `x = (q = upper, v = 0), m = +1`. `hit_lower`
  mirrors it. `leave_upper`: `m == 1 && u < 0`, sign form `-u` under
  `L = true`, the `Bool` predicate under `L = false`; handler `m = 0`.
  `leave_lower` mirrors it. Over a static array, `4N` closure events
  `hit_upper_i`, `hit_lower_i`, `leave_upper_i`, `leave_lower_i`, each
  handler writing one component of `q`, `v` and the code.
- `test/imports.jl` imports `LimitedDoubleIntegrator`.

## Measurements

Taken on the worktree:

- The routed subset `blocks build` under the sandbox flags: blocks 2464, build 436 at the real tree, the increment's 137 assertions over the 2327 and 436 at edeb2f2 (2401 on the worktree, whose base lacked increment 86's review fixes).
  The Dual sweep in `build` is unchanged at 122 covered and 61 skipped.
- Allocation: 0 bytes in every phase body and at a quiet boundary,
  scalar and vector, both policies.
- Events: 4 scalar, 8 at `N = 2`.
- First-use compile in a fresh process after a warm-up, `Simulation`,
  `init!` and 3 s of stepping, then the build under `(Float64,
  LinearizeDual)`: scalar 1.26 s and 0.26 s against `LimitedIntegrator`'s
  0.86 s and 0.20 s, whose scalar form the precompile workload already
  exercises; vector 2.04 s and 0.43 s against 1.92 s and 0.36 s. A repeated
  build takes 1 ms.
- The boundary-detected departure's offsets, derived and pinned exactly:
  with the input crossing zero at slope `a` and the leave firing
  `δ = (1 - θ) h` later, `v` carries the constant `a δ² / 2` and `q` the
  growing `a δ² τ / 2 - a δ³ / 3`, `τ` the time since the crossing.
- Churn: 3 files, +329 −1; `blocks.jl` 140, `test_blocks.jl` 189, `imports.jl` one name.

## Readings the prototype took

The ones ruled are in "What is settled". The rest, kept as built:

1. The output names `out` and `velocity`: `out` matches both limited
   integrators, so a model swapping one in keeps its wire.
2. Two behaviours the row does not state, now in the docstring and
   pinned: a block that reaches a limit while `u` already points back
   saturates and frees in successive §10.6 rounds of one boundary, so it
   leaves from rest, which the single integrator cannot do; and under
   the boundary-detected leave the position's offset grows with time
   until the next limit removes it.
3. The hit guards need no gating beyond the single integrator's. After a
   leave, `q` sits on the limit with `v = 0` and the guard holds at
   zero, so no fresh edge re-saturates the block; under inward input `q`
   moves strictly off the limit, by `a τ³ / 6` after a localized leave
   and by at least `|u| h² / 2` per step after a boundary-detected one,
   so a later return presents a fresh edge. A return within the leave's
   own step is the single integrator's existing blind spot, an input
   reversing twice in one step. Gating brings back the re-saturation
   chatter, as the gated mutants show.
4. The vector form costs `4N` events and compiles at about the vector
   `LimitedIntegrator`'s cost. Nothing to change.
5. What `R = true` would cost: about eight source lines (a third type
   parameter, `reset_ports`, the keyword, `state_events` split on `R`,
   one handler), a docstring paragraph, one testset and the shared-list
   rows. Two questions want a ruling first. The `v` a reset writes: it
   must be zero whenever the landing is saturated, to keep "saturated
   implies `v = 0`", and `v0` when free, so the handler is `code =
   saturation_code.(q0, lower, upper)` and `v = ifelse.(code .== 0, v0,
   0)`. A reset onto a limit with `v0` pointing inward: computing the
   code from `q` alone, as `LimitedIntegrator` does, lands it saturated at
   rest and loses `v0`; the prototype recommends that rule for uniformity.
6. `block_linearization` reads one state, so the two-state taps are
   spelled inline, `get_state("c", "q")` and `get_state("c", "v")`.

## What the tests pin, by property

- The stop: from rest under input `1` with `upper = 0.5`, `q == 0.5`
  exactly and `v == 0` at `t = 1`, the `velocity` and `saturation` ports
  reading `0` and the mode; the leave at the step's own boundary `1.05`
  under both policies, `q` and `v` on the exact quadratic within the
  bracket; the stop at `lower = -1` exactly, `v` zeroed again.
- Linearization by mode on `fed` rigs: free `A = [0 1; 0 0]`, `B = [0;
  1]`; saturated, zeros.
- `q0` outside the limits clamped at boundary zero with `v0` zeroed, at
  either limit.
- The arrival against the input: `v0 = 2`, `u = -1`, the hit and the
  leave in successive rounds of one boundary, then `q = 0.5 - (t - 2 +
  √3)² / 2`, both policies.
- An input of exactly zero at a limit keeps the block saturated with
  `v == 0`, either limit, both policies.
- The vector form: at `t = 0.9` only component 2 clamped, which tells a
  handler writing one component from one writing all; after `1.05`
  component 2's input exactly zero, which tells a leave guard reading its
  own component from one reading the first; `y_types`; Dual builds of the
  scalar and vector models.
- The event policies through `limited_events`: hits localized under both
  policies, leaves by `L`; the generated names over a vector.
- The offsets of the boundary-detected departure, exact on the ramp
  `1.05 - t` (`a = 1`, `θ = 0.5`, `δ = 0.05`): `v == -1.9` and `q` on the
  cubic plus `δ² τ / 2 - δ³ / 3` within `1e-12`, the localized run on the
  exact cubic.
- The keyword constructor: integers give `Float64`, `localized = false`
  the second type parameter, the `v0` and `q0` fields, a vector shape, an
  integer vector `q0`, `localized = 1` a `TypeError`.
- Allocation of the four models' phase bodies and quiet boundaries; the
  shadowing check over four instances.

Mutants the prototype ran, each turning a named pin red: the hit handler
not zeroing `v`, scalar and vector; the hit guard gated on the mode,
scalar and vector; a non-strict leave, scalar and vector; a vector handler
writing every component; `x_deriv` ignoring the mode on `q̇`, killed only
by the saturated Jacobian, and on `v̇`; the leave guard reading `v`,
scalar and vector; the two policies swapped; the vector leave reading
component 1; `q0` and `v0` swapped in the constructor; `float.` dropped;
the `velocity` or `saturation` port wrong; a misspelt `y_state`; an
allocating `x_deriv`; `Float64.()` on `q̇`, which breaks the `Dual` walk.
Two mutants the compiler or the build neutralized were replaced.

## Bookkeeping

- The docs commit edeb2f2: the inventory's row to shipped with the
  corrected mechanism cell and the order note in its section 4; the
  map's `src/blocks.jl` entry.
- The code commit 1590a08: `src/blocks.jl`, `test/test_blocks.jl`,
  `test/imports.jl`, `docs/src/api.md`, and `design/pending.md`'s library
  bullet with the block retired from the order.
- This brief, the notes and the patch, their own commit.

## Out of scope

- The reset form (reading 5), the bouncing-ball example model, any change
  to `LimitedIntegrator`, the promotion refusal.
- The structure blocks and the additions to shipped blocks: the two
  increments that follow.
- The inspector's fixtures: regenerated once after the four increments.

## The cold review

One fresh Opus reviewer over 1590a08 against edeb2f2, with §2.3, §3.1,
§5.3, §10.4, §10.6, §13.7, D-179, D-437, D-438 and the inventory row read
for what they owe: open-mind stance, probe scripts in the scratchpad,
"empty is acceptable". Dimensions:

- **The docs against the tree.** Every clause of the row's mechanism cell
  and of the docstring holds of the code, each probed.
- **The stop's invariant.** Saturated implies `v = 0` and `q` on the
  limit, after a hit from any speed, after boundary zero with `q0`
  outside the limits and `v0 ≠ 0`, after a hit against the input, and
  through a `restore!` of a saturated checkpoint.
- **Edge semantics.** The arrival-against-the-input cascade under both
  policies, with the input reversing inside the leave's own step; a
  return to the same limit after a leave under both policies, localized
  and boundary-detected, lands exactly; an input touching zero at a limit
  without crossing keeps it saturated.
- **Localization.** The hits end the step at the crossing; the localized
  leave at the input's zero; the boundary-detected leave at the first
  boundary after it, with the offsets of the brief's formula.
- **The hot path.** `@ballocated` 0 on every phase body and quiet boundary
  of the test models at `(Float64, LinearizeDual)`.
- **Naming** over every touched line, and the docstring against
  `docstring_style.md`.
- **Mutants on a scratch copy**, each named test going red, the list above
  re-run plus any the reviewer adds. A surviving mutant is a missing test,
  or an acceptable survivor named with its reason.
- The gate green on the Julia floor `Project.toml` declares, as two
  named-file halves.

## The review's record

The cold review of 1590a08 ran on 2026-11-04 on Julia 1.13.3, the floor:
the gate green in both halves (4123 and 3890), 47 mutants run in an
in-process harness over the increment's testsets, every mutant on the
brief's list killed, and every clause of the row and the docstring
probed. Two medium findings and four low. The first medium is a defect
the hit guard's form leaves open: after the arrival cascade the block
rests free on the limit with the hit predicate holding, so an input
turning outward within the rest of that step carries `q` back past the
limit as two crossings §2.3 cannot see; the single integrator has no
counterpart, since it cannot arrive against its input. Landed as
documentation in the docstring and the row; the guard that closes it,
reading `u` while the block rests exactly on the limit, is the user's
ruling, with the coordinator's recommendation in `notes_increment_87.md`.
The second medium was a test gap: no test made `leave_lower` fire and the
vector `hit_lower` was pinned on component 1 only, seven mutants
surviving the real suite. Landed as a mirrored scalar testset and a
vector case in which component 2 reaches `lower` first and leaves it.
The lows, all landed: a `q0` on a limit with an inward `v0` loses `v0`
at boundary zero, now in the docstring; the vector paragraph's handler
sentence, the boundary-detected departure's "at the first boundary
after", and the row's offset bound; three over-long lines rewrapped.
Left as they are: the `Float64` wording four docstrings share, false for
`Float32` keywords, and `LimitedIntegrator`'s identical departure
sentence. The fixer landed the findings at 7bbf4b9 and, on its own
mutant run, found two vector survivors left by the brief's first vector
scenario, which never left the lower limit; 8159e4d changes the step so
component 2 leaves, and both die. The routed subset reads blocks 2538 and
build 436.
The reviewer verified the delta at 8159e4d: the seven survivors each
turn a named pin red, the two vector ones on 8159e4d's assertions, and
the gate is green on the floor at 4197 and 3890, 8087 in all. Its one
wording nit, the departure sentence's "for the rest of that step",
landed as "until then" in the closing commit.

Two loose fixes after the review, on the user's rulings of 2026-11-04. A
scalar beside a vector among the keywords refused by name at b51e3e5, which
the single broadcast convention, first in the work order, then replaces. And
the unseen return closed at 3d76179: a hit guard takes the first nonzero of
`q - limit`, `v` and `u`, not the form the review sketched and the notes
first recommended, which re-fired up to about 9000 times on a slow departure
and erased `v`. This also lets a `q0` on a limit with an inward `v0` keep it,
so the docstring's boundary-zero sentence changed. Reading 3 no longer
stands for this block; the single integrator keeps the hole under its
boundary-detected leave, on its own pending bullet. Reading 5's second question
is unchanged, but a reset form should read the guard above first.
