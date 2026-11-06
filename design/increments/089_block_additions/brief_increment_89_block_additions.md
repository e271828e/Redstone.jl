# Brief: increment 89, the taps on `Delay` and the zero-pole spelling

One docs commit, one code commit applied from the prototype, one cold
review and a fixer if the review needs one. Drafted on 2026-11-06 at
59bfc5b, the docs commit itself; not normative. The prototype is the
implementation, built by the coordinator on a scratch worktree detached at
59bfc5b, the measurements and the readings taken there the same day. The
patch lands as `prototype_increment_89.patch` beside this brief, the
worktree's diff from 59bfc5b, which applies textually at the tip. The user
was present: the rulings below are theirs, taken in the session of
2026-11-06.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

## What is settled

The last of the library increments the `pending.md` bullet "The library's
remaining candidates" orders: the two additions to shipped blocks that the
inventory's section "Additions to shipped blocks" keeps, after the same
session declined scheduled limits (59bfc5b). No log entry (`log_rules.md`
rule 9); the inventory carries the design, docs commit first, and the code
conforms.

- **Scheduled limits are not admitted.** On the discrete blocks the
  scheduled form is the one-liner reading its limits off `u`, a model's own
  three-line component, and the controllers' scheduled `u_min` and `u_max`
  serve the cascade case. On `LimitedIntegrator` a moving limit on a
  saturated state needs the limit's rate, which no stage sees; the best
  design is a staircase one boundary behind the limit, two more `Bool`-form
  events and a §10.6 probe, for no model that asks for it. The inventory
  says so in the additions section.
- **The taps are a type parameter naming the output side.** `taps = true`
  names the outputs `(y, taps)`, keeping the face `y` as
  `Integrator(reset = true)` keeps `u` (D-437); `taps = false` keeps the
  bare `y`. Newest first, `taps[1]` the input from one tick ago and
  `taps[K]` from `K`, so `y == taps[end]`. Published from stage 1 as a
  rotation of the ring by the cursor, so the loop break stays. A FIR filter
  is a `DiscreteTransferFunction`; the taps serve a law over the window
  that is not linear.
- **The zero-pole spelling reaches all three transfer functions.** The
  user added the discrete pair on 2026-11-06. `zeros`, `poles` and `gain`
  are exclusive with `num` and `den`; roots real or complex, a product
  whose imaginary part is not zero to rounding refused, which conjugate
  pairs pass; the real coefficients then meet the existing refusals.

## The shape built

Line ranges from `git show 59bfc5b:file`.

- `src/blocks.jl`:
  - `Delay`, 483–532: the type parameter `Taps` after `K`, the keyword
    `taps::Bool = false`, `y_types` and `y_state` split by it, the taps
    form's `y_state` returning `(y = s.ring[s.cursor], taps = …)` with the
    taps an `SVector{K, V}` built by `ntuple` over `Val(K)` reading
    `s.ring[mod1(s.cursor - i, K)]`. `s_init`, `u_types` and `s_update`
    unchanged. The docstring gains the signature's keyword, one paragraph
    and one keyword bullet; the comment names `Taps` and the rotation.
  - Two helpers before `TransferFunction`'s comment at 1142:
    `coefficients_from_roots(roots, name)`, the monic polynomial's
    coefficients highest power first by the running product
    `[p; 0] - root [0; p]` in complex arithmetic, refused as an
    `ArgumentError` naming `name` when any imaginary part exceeds `1e-12`
    of the magnitudes' sum, and returned real; `transfer_coefficients(num,
    den, zeros, poles, gain)`, which refuses both spellings at once,
    neither complete, `zeros` or `gain` without `poles`, and more zeros
    than poles, and returns `(num, den)` as given or as `gain` times the
    expansion.
  - `TransferFunction`, 1142–1209: the keywords `num`, `den`, `zeros`,
    `poles` and `gain` default to `nothing` and resolve through
    `transfer_coefficients` on the constructor's first line; the body after
    it unchanged. The docstring gains the second signature line, a
    paragraph with the root form of `G(s)` and the refusals, and three
    keyword bullets.
  - `DiscreteTransferFunction`, 1319–1380: the same constructor change and
    docstring additions, the roots in `z`.
  - `DiscretizedTransferFunction`, 1441–1479: the constructor forwards
    `kw...` to `TransferFunction`; the docstring takes the second signature
    line, "in either spelling" and the three bullets.
- `test/test_blocks.jl`:
  - the fixture `window_model(K)` after `delay_model(::Delay)` at 28: the
    tick counter through `Fn(float)` into `Delay(K = K, v0 = -1, taps =
    true)`, with `Fn{SVector{K, Float64}, Float64}` taking the mean of
    `d/taps`.
  - one testset after the delay line's at 1172, and one after the
    transfer function's refusals at 1849.
  - two models in the discrete allocation testset at 1458,
    `window_model(50)` and the vector `Delay(K = 50, …, taps = true)`.

## Measurements

All from runs on the worktree, Julia 1.13.3.

- **Allocations per phase body** for the two new models of the allocation
  testset, `sweep_1`, `sweep_2`, `rhs` and `ticks` as `body()` and
  `body(1)`, then `boundary!` and `offtick_boundary!`: 0 B under `Float64`,
  and the `LinearizeDual` build passes. A direct `y_state` of the taps form
  with its result used allocates 0 B at `K = 3` and `K = 50`, scalar and
  `SVector{2}`; `@code_warntype` infers the body to
  `@NamedTuple{y::Float64, taps::SVector{3, Float64}}` with no `Any`. The
  same call with the result discarded reads 160 B to 2560 B, the trap
  `increment_rules.md` names.
- **Compile latency**, `Simulation`, `init!` and ten frames in a fresh
  process with `--startup-file=no`, the taps form against the plain
  `Delay`: equal within noise to `K = 20`; at 50, 2.1 s against 1.7 s; at
  100, 7.3 s against 1.4 s; at 200, 48.8 s against 1.4 s; at 400, 341 s.
  All of it in `init!`, the first sweep's compile, growing about as `K³`
  in the leaves of the `taps` port. Not the rotation: the `ntuple` body
  compiles in 0.3 s alone at `K = 200`, and a loop over an `MVector`
  changed nothing in the model. A 100-wide `UnitDelay` with no taps costs
  7.4 s and a 100-wide `DiscreteIntegrator` 11.4 s, while a 100-wide `Fn`
  and `Integrator` cost 0.4 s: the discrete tier's trait for a wide value
  published off a store, `reports/20261106_wide_store_compile/report.md`,
  measured after the code commit at the user's request.
- **Each form alone at the root (D-210)**: `Delay(K = 3, taps = true)`,
  `Delay(K = 3)`, `TransferFunction(zeros = (-2,), poles = (-5,))`,
  `DiscreteTransferFunction(poles = (0.5,))` and
  `DiscretizedTransferFunction(poles = (-2,), gain = 2)` build at nominal
  and under `LinearizeDual`.
- **The expansion**: `(-1, -2, -3)` gives `[1, 6, 11, 6]` exactly; the
  pair `-0.6 ± √3.64 i` gives `[1, 1.2, 4]` to rounding.
- **Routed runners** under the sandbox flags, from the worktree:
  `blocks` 3530/3530 in 4m25s, Dual sweep 131 covered, 62 skipped, 105
  refused at nominal; `build` 521/521 in 55s; no warnings. The Documenter
  build with `doctest = true` and `checkdocs = :exports` is green.

## Readings the prototype took

1. **The keyword `zeros` shadows `Base.zeros` inside two constructor
   bodies and `transfer_coefficients`.** `code_rules.md`'s naming rule bars
   a local sharing a Base name the package calls, and `realize` calls
   `zeros`. The keyword is the spelling a control engineer writes and the
   inventory settled it. Kept, ratified by the user with the spelling. The
   review placed it: the constructors' keyword falls under the rule's
   public-signature exemption, the private helper's parameter did not and
   was renamed.
2. **`gain` defaults to `nothing`, not `1.0`**, so that `gain` beside
   `num` and `den` is refused as a mixed spelling rather than ignored. The
   docstring's second signature line writes `gain = 1.0`, the value the
   root spelling resolves it to, and `zeros = ()`, the resolved default,
   as `docstring_rules.md` rule 14 allows for a sentinel.
3. **`DiscretizedTransferFunction` forwards `kw...`** rather than naming
   six keywords twice; the docstring shows the callee's keywords, rule 11.
4. **A headless `port(sim, "d")` on the taps form is `ArgumentError`**, as
   D-437 rules for a named output contract, pinned in the testset.

## What the tests pin, by property

- **The tapped delay line publishes the last `K` inputs newest first, `y`
  the oldest, from stage 1** (§7.3, §13.7, D-313, D-437): eight ticks of
  the counter through `window_model(3)` against the window `max(k - i,
  -1)`, `y == taps[end]`, the mean through `Fn` off the `d/taps` wire; the
  headless read refused; the vector form after one and two ticks; the loop
  through the taps form builds, closed through `y` and through the taps;
  the default form's type is `Delay{Float64, 2, false}`. A reversed order,
  an off-by-one cursor, a missing `mod1` and a stage-2 `taps` each turn it
  red.
- **The zero-pole spelling expands to the coefficients on all three
  transfer functions, and refuses a mixed spelling, an unpaired complex root
  and more zeros than poles** (§13.7, D-313): the lead-lag from its roots
  equal to `lead_lag()` in `num`, `den` and realization; the resonant pair
  with `zeros` left out, `den ≈ [1, 1.2, 4]` and the class `{2, false}`;
  `gain = 6` on `(s + 1)/((s + 2)(s + 3))` with `u0 = 2` reaching `G(0) u0`
  at init; the pair in `z` and the discretized lead-lag equal to their
  coefficient spellings, `held` included; the `z = 1` refusal reached
  through roots; twenty conjugate pairs on the unit circle accepted and
  one root moved by `1e-6` refused; the helper's two messages; eleven refused
  spellings on each of the three constructors, a vector and a complex
  `gain` among them. A dropped `gain`, a sign flip in the product, a
  dropped pairing, a dropped exclusivity check and a vector `gain`
  broadcast each turn it red.
- **The discrete tier's phase bodies allocate nothing** (§9.8): the two
  taps models at `K = 50`, scalar and vector.

## Bookkeeping

- `companions/library_inventory.md`: the taps and the zero-pole bullets of
  the additions section marked shipped on 2026-11-06 as increment 89; the
  order-of-work paragraph names the increment.
- `pending.md`: the bullet "The library's remaining candidates" retired.
- `code_map.md`, `src/blocks.jl`: `Delay`'s taps form, and the two
  helpers the three transfer functions share.
- `src/blocks.jl` and `test/test_blocks.jl` as the patch.

## Out of scope

- Scheduled limits on `RateLimiter`, `LimitedIntegrator` and
  `DiscreteLimitedIntegrator`: declined in the inventory's additions
  section, the continuous block's event design sketched there.
- A zero-pole spelling on `StateSpace` and its discrete pair: a matrix
  block has no roots to spell.
- The order-of-taps option Simulink offers, oldest first: the user picks the
  order with `reverse` in the stage body.

## The cold review

An independent high-tier agent over the whole increment at the code
commit's tip: the gate on the floor `Project.toml` declares; each testset
reverted alone on a scratch copy; the taps' allocation and the expansion
re-probed outside the tree; the four docstrings against
`docstring_rules.md` and the roster tool; reading 1 against the naming
rule's text; the two testsets' mutants listed above, plus a rotation that
reads `s.cursor + i` and a `transfer_coefficients` that lets `zeros`
without `poles` through. "Empty is acceptable."

## The review's record

The docs commit is 59bfc5b, the brief f59e08c and the code commit f9b4ccf.
The cold review ran on 2026-11-06 by one Opus agent on scratch worktrees at
f9b4ccf, its probes and notes under the coordinator's scratchpad
`review89/`. The gate ran on Julia 1.13.3, the floor: `Redstone 9523/9523`
in 11m43s, no warning. Twelve mutants over `test_blocks()`; nine turned a
pin red, three survived.

Findings, landed as "Fix increment 89's review findings":

- `coefficients_from_roots` checked the expansion's imaginary parts against
  the coefficients' sum, which is small for discrete poles spread around a
  circle, so exact conjugate sets of ten to twenty pairs were refused with
  a false message. Each complex root is now paired with its conjugate
  before the expansion, by a tolerance relative to the root, and an
  unmatched one refused; pinned by twenty pairs on the unit circle accepted
  and one root moved by `1e-6` refused. The first pin took ten pairs,
  whose residue under the old check fell below its tolerance, so the
  check put back survived the suite; the verification pass found it, and
  the twenty-pair set fails the old check by a factor of 7500.
- `taps` moved alone into `y_direct` survived, since the loop test closes
  through `y`; a loop closed through `d/taps` joins the testset.
- `Delay`'s docstring said both ports share `V`, false in the taps form,
  and used `V` before defining it; the taps paragraph moved below `v0`'s,
  the sentence names `u` and `y`, and the paragraph says what fills the
  slots before `K` ticks.
- A vector `gain` broadcast silently and a complex one failed with
  `InexactError`; `gain` is refused unless `Real`, pinned.
- Reading 1 was half right: the constructors' keyword `zeros` falls under
  the naming rule's public-signature exemption, the helper's positional
  parameter did not, and the comment was wrong; the helper's parameters
  are `zero_roots` and `pole_roots`.
- Two docstring lines rewrapped.

Survivors, fixed by pinning the messages: the helper's "without `poles`"
and "zeros over" refusals, which the constructor body's own refusals
repeated as a plain `ArgumentError`. Informational and not changed:
`gain = 0` builds the zero system, as the coefficient spelling does; a
user's positional `Delay{Float64, 2}(0.0)` now breaks on the third type
parameter, behind the keyword constructor docstring rule 10 shows; the
docstring rules have no sentence for a sentinel shown as its resolved
value, the shape of reading 2.

The fixes landed as deb0bb3 after the gate on the real tree, 9534/9534 on
Julia 1.13.3, no warning, Documenter green. The reviewer verified the
delta: the three survivors turn a pin red, the pairing accepts every
review set and refuses each with one root moved by `1e-6` or `1e-3`, and
the docstring and the roster tool pass. The pin swap landed as a second
fix commit, the `blocks` and `build` runners green.

The latency sweep the user asked for beside the review found the taps
form's compile cost growing as `K³`, the discrete tier's wide-store trait:
`reports/20261106_wide_store_compile/report.md` and its pending bullet
landed as a docs commit before the fixes, and `Delay`'s docstring sentence
on it with them.
