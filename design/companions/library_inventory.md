# The standard component library: the admission guidelines and the inventory

*A companion record, not normative text. The ground truth is `spec.md`
[§13.7][s13-7] (the library and the rig), [§6.2][s6-2] (junctions), [§5.5][s5-5] (loop breaking)
and [§2.3][s2-3] (events), with decisions [D-311][d-311], [D-312][d-312] and [D-313][d-313]. If this
document and the spec ever disagree, the spec wins. It was written on
2026-10-06, when the first tranche was briefed, to keep the reasoning that
pruned Simulink's base library down to the blocks worth shipping and to
hold the candidates for later tranches.*

## 1. Why Simulink's granularity does not transfer

Simulink's base library is large because the diagram is its expression
language. There is no other way to write `2u + 3` than a Gain and a Bias,
so Gain, Bias, Abs, Sign, Product, Min/Max, the trigonometric functions,
the relational and logical operators and type conversion all exist as
blocks. In Redstone a leaf's stage body is Julia. The block for `2u + 3` is
one line of `y_direct`, and the same expression as a separate component
costs a build entry, a cell, a gather and a scatter, plus the
per-component compile cost [§9.7][s9-7] measures. Shipping those blocks would also
teach the diagram-granularity style the design rejects. [§13.7][s13-7]'s phrase is
"Simulink's library is a language, while this is a toolbox".

A second group disappears for structural reasons:

- Sinks (Scope, Display, To Workspace) are the snapshot table, the log and
  the inspector.
- Terminator is unnecessary, because only inputs must be wired.
- Stop Simulation is a stop request, any `StopFlag` port ([§13.5][s13-5]).
  `StopRequest` below spells one and holds no privilege.
- Goto/From are forbidden by the hierarchy rules ([§6.1][s6-1]).
- Bus Creator and Bus Selector are a struct or a named tuple port.
- Zero-Order Hold and Rate Transition are what the tiers and
  `sample_times` already do ([§10.5][s10-5], [§8.7][s8-7]).
- Enabled, triggered and resettable subsystems, If, Switch Case and Merge
  are assemblies and modes (`extensions.md` items 5 and 7).
- Lookup tables are generic mathematics for a utility package, called from
  a stage body.
- Clock is the bundle's `t`. Ramp, Sine Wave, Chirp, the interpolated
  Repeating Sequence and From Workspace are `Source{V}(f)`, an interpolant
  included, since a kink owes no event (section 2).
- Derivative is the filtered form, `TransferFunction(num = (1, 0), den = (τ, 1))`.
  The unfiltered block has no clean continuous form.
- Memory is `UnitDelay` on the fastest tier. Holding the previous step's
  value in continuous time is Simulink's hack.
- Zero-Pole, the first-order, lead-lag and real-zero transfer functions,
  Discrete Filter and Discrete FIR are constructor spellings of the linear
  blocks. PID 2DOF is the `b` and `c` weights of `PID`.
- Assertion and the range checks are a `StopRequest`, with a `Comparator`
  (section 3) in front when the check is on a continuous quantity.
- Counters and the Detect family are discrete one-liners, `s⁺ = mod(s + 1, N)`
  and a `UnitDelay` with a `Junction` fold. On the continuous tier the edge
  belongs to the consumer that resets on it ([D-141][d-141]).
- Data Store Memory, Algebraic Constraint and Descriptor State-Space are
  closed axes (`extensions.md`, section 1.3).

## 2. The admission guidelines

A block joins the inventory by judgement against three guidelines
([§13.7][s13-7], [D-313][d-313]). None is a requirement. A candidate is
weighed against them, it need not satisfy all three, and a block that
plainly belongs is not argued into them.

- **Domain-agnostic and generally useful.** Aerodynamics, engines and
  sensors belong in packages built on the framework.
- **Didactic value**, as when a block shows one framework mechanism in a
  relatively simple form. The mechanisms worth showing:
  - *Modes and events.* A limited integrator is not a clamp. It is a mode
    (saturated or not) with events for hitting and leaving each limit, and
    a derivative that reads the mode. A relay with hysteresis is a mode plus
    a pair of sign-form guards.
  - *Tier semantics.* `UnitDelay` moves a signal onto the discrete tier,
    which [§5.5][s5-5] calls a modelling decision. A discrete integrator or
    filter is the same kind of object.
  - *Activation and pinning.* Every library block walks under `Dual` for
    linearization and trim. A hand-written lag filter that types its
    scratch as `Float64` works at nominal and fails the first `linearize`.
  - *Structure the declaration layer forces.* The junction exists because
    every input takes exactly one wire. Wires name whole ports, so feeding
    one component of an `SVector` port to a scalar consumer needs a block.
- **An implementation that is difficult to get right.** The lag filter
  typed at `Float64` is the standing example.

A gain fails the second and the third, and section 1 prices it, so it stays
out. A listed block is built whenever wanted, with no demonstrating model
required. How the limited integrator's exact-zero defect was found, which
implementation variants were weighed against it, and why the block ships two
detection policies for its departures is `limited_integrator_variants.md`.
How the PID's anti-windup design space was weighed, why the block carries
two independent ports and what it does not carry is `pid_anti_windup.md`,
and its section 11 adds standby through the hold's `engaged` input and the
discrete saturation output. Why the linear system is two blocks, how a transfer function is
realized and why it takes a steady-state input and no `x0` is
`linear_blocks.md`. The LQR tracker's derivation, the cascade it serves and
what it leaves to the design script is `lqr_tracker.md`.

A discontinuity is weighed by whether it jumps or kinks. A jump needs a
declared event, or it lands inside a step and smears it, a mode made silently
([§3.1][s3-1]). A kink needs none, since its error is second order and decays.
That is why `Step` is a block with a guard while a ramp is `Source{V}(f)`, and
why the continuous rate limiter and the clamps stay out while a comparator
that declares a crossing comes in.

## 3. The inventory

Status is one of *shipped*, *candidate* (listed, built when wanted), or
*example first* (built as an example model, promoted only if one form
proves standard). A block is generic over its port type `V`, in the
[D-263][d-263] spelling, unless its ports are fixed by what it is: the `Bool`
gates and the linear blocks, whose ports follow their matrix shapes. The
one input or one output a block has is a bare contract, one port whose face
is the default `u` or `y`, which a wire addresses as `block/u` or `block/y`
([D-437][d-437]); a side with several ports names them `in1…inN`, and `out1…outN`
where a block splits one port into `N` ports alike. The bundle reads a bare
side as `u` or `y`, the value itself.

A block with a defaulted parameter, or with more than one, gets a
hand-written keyword constructor, as in `Integrator(; x0 = 0.0)` and
`Relay(; lower, upper, off = zero(lower), on = one.(lower))`. A positional
call is easy to get wrong, and [§8.2][s8-2] already makes keyword defaults the
convention. A parameter with no sensible default is a required keyword.
Fields that share a type parameter promote, so mixed `Int` and `Float64`
keywords work, which is why the constructor is hand-written rather than
`@kwdef`. The PID's keywords that share `V` broadcast to one shape instead,
as `GaussianWhiteNoise`'s do: a scalar pairs with a vector and the shape's
type is `V`, so a uniform vector gain spells one keyword as a vector,
`Kp = @SVector fill(2.0, 3)`. A keyword given as `AsPort()` is a port of
the block, not a field, and takes no part in the shape. The struct keeps
its positional constructor. A block with one required parameter, such as
`Constant(value)`, takes it positionally. Its docstring shows the keyword
form, and its tests call it.

A block's signal types carry the scalar as a type parameter. The walk
substitutes type parameters and never fields ([§8.2][s8-2], [D-238][d-238]), so a `Float64`
inside a parameterless struct is pinned whole, and a continuous stage that
builds such a struct from `Dual`s fails the build's `Dual` probe ([D-307][d-307]).
Every port type and every `x` leaf type a block ships is therefore
`Pose{T}` rather than `Pose` with `Float64` fields. A block's own
parameters, a discrete-tier type, and a value a continuous stage builds
from pinned data alone need no parameter.

### Structure

| Block | Status | Mechanism |
|---|---|---|
| `Junction{In, Out, N}(f)`, with `SumJunction{V, N}`, `Or{N}`, `And{N}` | shipped | one wire per input; the consumer's consolidated input |
| `Group` | shipped | the on-the-fly assembly ([§8.5][s8-5], [D-184][d-184]) |
| `Pack{V, N}`, a junction alias at a named fold, and `Unpack{V, N}` between scalar ports and an `SVector{N, V}` port | shipped | wires name whole ports |
| `StopRequest`, reason as instance data | shipped | a `Bool` in, a `StopFlag` out, consumed by nobody; the request is the port's type, so any component may publish one, and `stop_reason` names it in the termination record ([§13.5][s13-5], [D-316][d-316]) |
| An unbundling component, a `y_direct` leaf taking a struct-valued bundle port | candidate | publishes the bundle's fields as loose ports, for a consumer wanting less than the bundle, since wiring is port-granular ([§4.3][s4-3], [D-276][d-276]) |
| `Switch{V}` selecting between two inputs on a `Bool` | shipped | the `Bool` a junction's one `In` cannot type; the jump lands where the selector flips, so the event is the selector's producer's |
| `Select{V, K}` choosing among inputs on an enum `K` | candidate | the N-way `Switch`, Simulink's Multiport Switch and Index Vector, keyed on `instances(K)` so the inputs wear the enum's names and a wire reads `sel/CRUISE`; `y_direct` by field lookup on the selector's `Symbol`, type-stable since every data input is a `V`; the value set is closed, so no out-of-range case exists; an enum is an atom the cells, the probe and the descriptor already carry, and its producer holds it as a mode ([D-308][d-308]), so the jump lands on a boundary as `Switch` wants; no integer-keyed form, since an index wants an enum anyway; `Switch{V}` stays, `Bool` being no `Enum` |
| `Fn{U, Y}(f)`, one input of type `U` and one output of type `Y`, `f` applied in `y_direct`; `Fn{U}(f)` for `Y = U` | candidate | the transform between two children that wires cannot express, a unit conversion or a sign flip, where the alternative is a four-declaration primitive per glue step; the feedthrough sibling of `Source{V}(f)`; admitted on the fourth guideline, as the `Junction` is, not as a gain, so section 1's pricing still applies per instance; the port types are type parameters and never read off `f` ([D-033][d-033]), so a closure's output type is declared; a `y_direct` leaf, so stage 2; `f` walks under `Dual`, which the probe checks |

### Sources

| Block | Status | Mechanism |
|---|---|---|
| `Constant(value)` | shipped | the pinned source; the zero-contributor wire and the rig stub |
| `Step(; t_step, before = 0.0, after = 1.0, localized = true)`, with a guard on the bundle's `t` in either form | shipped | the jump is localized, or lands on a step boundary, by the guard's form, which `localized` picks ([D-179][d-179]) |
| `Sequence(; times, values, localized = true)`, `N` ascending breakpoints and `N + 1` values | candidate | the breakpoint schedule, `Step` at `N = 1`, covering Signal Builder, Repeating Sequence Stair and a finite pulse train: a mode counting the breakpoints passed, read by `y_state`, and one event whose guard is `t - times[m + 1]` until the last, so it re-arms after each firing; two breakpoints inside one step rely on the quiescence loop ([§10.6][s10-6]); not periodic, since a periodic reset is not a time-guard event ([D-362][d-362]), so a periodic pulse is a discrete counter at its own period, `s⁺ = mod(s + 1, K)`, a one-liner and no block |
| `Source{V}(f)`, a user function of the nominal `t` | shipped | covers ramps and sines without a block each; pinned ([D-312][d-312]): `t` is the activation scalar, stripped before `f` |
| `GaussianWhiteNoise(; seed, μ, σ, psd)`, a discrete Gaussian white noise process, seed as instance data | shipped | a counter-based draw: the sample is a pure function of the seed and a tick counter, the store's one field ([D-231][d-231]), so the stage draws and no generator or workspace is needed; `σ` per sample, or the two-sided density `psd` read against the bundle's `Δt` as `σ² = psd/Δt` |

### Continuous dynamics

| Block | Status | Mechanism |
|---|---|---|
| `Integrator{V}` | shipped | walks under `Dual` |
| `Integrator(; x0, reset = false)`, `reset = true` a type parameter adding the `Bool` input `reset` | candidate | the commanded continuous reset as an event ([§3.1][s3-1], [§5.3][s5-3], [D-141][d-141]): a `Bool` latch mode, a boundary-detected guard `reset & !m` whose handler writes `x0` and sets the latch, and a re-arm guard `!reset & m`; the latch pair is what [D-362][d-362] means by modes enabling reset maps; rising edge only, no level reset and no initial-condition port, so no all-in-one; the bare face stays `u` in both forms ([D-437][d-437]); a reset driven by a continuous quantity arrives through a `Comparator`, where it is localized; on the discrete tier the same reset is one `ifelse` in `s_update`, the sibling `DiscreteIntegrator(; reset)` by contrast |
| `LimitedIntegrator{V, L}` over `Real` or a `StaticArray` | shipped | a mode the derivative reads, and four events, the leave pair gated by the mode and strictly inward input; departures localized or boundary-detected, by `L` ([D-179][d-179]); modes as `Int8` codes, `4N` per-component events over a vector; `saturation` published |
| `LimitedDoubleIntegrator(; lower, upper, x0, v0, localized = true)`, position limits on the double integral of its input | candidate | the mechanical stop, Simulink's Second-Order Integrator Limited: `x` the static pair of position and velocity, `LimitedIntegrator`'s mode and four events, the leave pair on the input's sign, and a hit handler that writes the limit and zeroes the velocity, the first library handler to jump a state to a value other than the limit it hit; actuators with inertia and gear struts; the bouncing ball, `v ← -e v` with no saturated mode, is the same shape, an example model where its Zeno behaviour shows the event budget ([§10.6][s10-6]) and not a row |
| `FirstOrderLag{V}`, time constant as instance data | shipped | the actuator model and [§5.5][s5-5]'s α-filter idiom; for a scalar signal it is the lag form of `TransferFunction`, and the block stays for static-array signals, for `x0` in the signal's own coordinates and for the spelling |
| a continuous rate limiter | not admitted | `q̇ = clamp((in - q) / τ, -R, R)` is one line, its kinks are second-order and its offsets decay; the discrete form is the block |
| `StateSpace(; A, B, C, D, x0)` from any matrices, stored as static ones, scalar or `SVector` ports by the matrix shapes | shipped | `D` picks the stage, so the feedthrough class is a type parameter; `x0` in the user's coordinates; `linear_blocks.md` |
| `TransferFunction(; num, den, u0)` from coefficient tuples or vectors, one input and one output | shipped | realized to a `StateSpace` at construction, the stage arms shared through the abstract `LinearBlock{FT}`; the class from the numerator's degree; started at rest or at the steady state for `u0`, never from an `x0`; `linear_blocks.md` |
| a continuous transport delay | not admitted | a history buffer indexed by the step; `extensions.md` item 4 |

### Discontinuities

| Block | Status | Mechanism |
|---|---|---|
| `Relay{V}` (hysteresis) over `Real` or a `StaticArray` | shipped | the reference mode-switching leaf; modes as `Int8` codes, `2N` per-component events over a vector |
| `Comparator(; threshold, lower = threshold, upper = threshold, localized = true)`, a `Bool` output | candidate | Hit Crossing, Compare To Constant and the threshold criterion of Simulink's Switch in one: `Relay`'s latch and guard pair publishing `Pinned{Bool}` from the mode, a plain threshold at `lower == upper` and hysteresis between them, the policy by `L` as in `Step` ([D-179][d-179]); the declared way to produce `Switch`'s `select` from a continuous quantity, which the `Switch` docstring otherwise calls a mode made silently; the declared kink the saturation row reserves, a clamp staying one line beside it; `Relay` is a `Comparator` feeding a `Switch` over two constants, and stays for the spelling |
| Saturation, dead zone | not admitted | one-line clamps; when localization doctrine wants a declared kink, a `Comparator` on the same signal lands the step on it |
| Quantizer, Coulomb and viscous friction | not admitted | the quantizer jumps at every level and belongs on the discrete tier, where it jumps at ticks and smears nothing; the friction block is a memoryless sign law, and a stiction model with stick and slip modes is a mechanics package's |

### Discrete tier

| Block | Status | Mechanism |
|---|---|---|
| `UnitDelay{V}` | shipped | the tier's native `z⁻¹` ([§10.6][s10-6]) |
| `DiscreteIntegrator{V}` | shipped | tier semantics; forward Euler, its bare output the state from `s0`, so it breaks a loop as `UnitDelay` does; no gain and no limits, as `Integrator` has none |
| `RateLimiter{V}` | shipped | tier semantics; feedthrough, its bare output following its bare input within `rising Δt` up and `falling Δt` down per tick from `s0`; its `s_update` stores `y` |
| a discrete backlash, `y = clamp(s, u - w/2, u + w/2)` with `s_update` storing `y` | candidate | the continuous block needs the sign of `u̇`, which no stage sees and Simulink fakes; the discrete form is `RateLimiter`'s sibling, admitted on tier semantics as the rate limiter was and priced as the one-liner it is, the weakest candidate of the 2026-10-30 sweep |
| `DiscreteStateSpace` and `DiscreteTransferFunction`, the pair in `z` | shipped | the continuous pair mirrored over `DiscreteLinearBlock{FT}`, `s_update` for `x_deriv`; the period is the scope's and the block cannot check it; `linear_blocks.md`, section 9 |
| `DiscretizedStateSpace` and `DiscretizedTransferFunction`, from a continuous system | shipped | the zero-order hold taken per tick at the bundle's `Δt`, so the class and the initial condition are the continuous ones; `linear_blocks.md`, section 9 |
| `DiscreteLimitedIntegrator{V}` | shipped | tier semantics by contrast: the continuous block's mode and four events are one `clamp` in `s_update`, with no mode store and no localization; `LimitedIntegrator`'s interface, `lower`, `upper`, `s0` and the `Int8` `saturation` code, the code read off the state from stage 1 |
| `Delay(; K, v0)` | shipped | the tier's `z⁻ᴷ` in a ring store, `K` ticks of the component's own period ([§10.5][s10-5]), one output, `K = 1` the `UnitDelay` in keyword spelling |

### Stop-gradient

| Block | Status | Mechanism |
|---|---|---|
| `Freeze{V}` over `Real` and `StaticArray` | shipped | the declared stop-gradient ([D-266][d-266]) |
| `Freeze` over a struct `V` | candidate | needs an allocation-free leafwise map ([D-312][d-312]) |

### Controllers

| Block | Status | Mechanism |
|---|---|---|
| `PID(; Kp, …, hold, tracking)` over `Real` or a `StaticArray` | shipped | one law, `q̇ = Ki ε + (ref - u_raw) / Tt`, componentwise over a static vector, with two independent axes: the hold, adding the saturation code that gates the integrator by sign and the flag `engaged` under which the error is gated off, not engaged taking precedence; and the tracking reference `v`, which `u_raw` converges to while limited or not engaged, so a block not in command follows the selected command and engages bumplessly, with the fallback to the own `u` while free; back-calculation against the own limits otherwise; the three ports at the output's shape; `Ki` inside the integral; every parameter a `V`, and any of them a port by `AsPort()`; the setpoint weights `b = 1` and `c = 0`, so the derivative acts on the measurement by default; a fixed infinite `Tt` refused with `tracking`; no saturation output, since a continuous code would need a mode and events; `pid_anti_windup.md`, section 4 for the table, section 10 for the vectors, the ports and the weights, section 11 for standby |
| `DiscretePID(; Kp, …, hold, tracking)` | shipped | the positional law carried to the discrete tier, the ports, the gate, the reference rule and the parameters shared through `PIDBlock{V, Hold, Track, Fixed}`, so componentwise over a static vector, every parameter a `V`, any of them a port by `AsPort()` and the weights `b = 1` and `c = 0` as in `PID`; forward Euler on the integral, backward Euler on the derivative filter so `τd = 0` is the backward difference, and the correction's step `1 - e^{-Δt/Tt}` so every `Tt` is stable and `Tt = 0` is instant, which makes standby follow exactly; a second output `saturated`, the own clamp's `Int8` code written to the store at the tick and published from stage 1 at the next, one tick stale, for an outer block's hold, named apart from the hold's input ([D-384][d-384]); `pid_anti_windup.md`, sections 9 to 11 |
| `LQRTracker(; K_fbk, K_fwd, …)` | shipped | the LQR tracker about a trim point, `u_raw = u_trim + K_fwd (z_ref - z_trim) - K_fbk (x - x_trim) + q` with `q̇ = ε + (ref - u_raw) / Tt` over an `n_u`-wide integrator, `ε` the gated `K_int (z_ref - z)` and `K_int` inside it; inputs `x`, `z` and `z_ref` as static vectors, outputs `u` and `u_raw` from stage 2; the PID's two axes over the integrator input channel by channel, `engaged` per channel, and the own clamp by back-calculation; the nine parameters, the three gains and the trim triple as static matrices and vectors and `Tt`, `u_min`, `u_max` per channel, any of them a port by `AsPort()`, which is how a gain schedule arrives; gains designed outside, from `trim!` and `linearize`; no saturation output; `lqr_tracker.md` |
| `DiscreteLQRTracker(; K_fbk, K_fwd, …)` | shipped | the tracker on the discrete tier over `LQRTrackerBlock`, forward Euler on the integrator and the correction's exact step as `DiscretePID`; the own clamp's `Int8` code vector as the output `saturated` ([D-384][d-384]), from stage 1 off the store, one tick stale, for the outer loops of a cascade, each channel reaching a scalar consumer through `Unpack{Int8, NU}`; `lqr_tracker.md`, sections 6 and 7 |

A flag-gated reset face on a library PI block is sugar over exactly the
edge-triggered reset event of [§5.3][s5-3], which resets a continuous
component on its input's edge ([D-141][d-141]). [Appendix A][sA] carries the
continuous-reset contract too.

The PID assembly of library blocks, the first variant as a `Group`, is an
example model in the tests, the inspector's example beside the block, not a
library row. A tracking leaf wired from a memoryless clamp of its own output
is refused as an artificial cycle ([§5.4][s5-4]), which is why the limits live inside
the block.

### Additions to shipped blocks

Simulink features that are a keyword or an output on a shipped block, not a
row:

- Saturation Dynamic, Rate Limiter Dynamic and Dead Zone Dynamic take their
  limits as ports: `AsPort()` on the limits of `RateLimiter`,
  `LimitedIntegrator` and `DiscreteLimitedIntegrator`, as on the controllers.
- Tapped Delay: a second output on `Delay` publishing the ring as an
  `SVector{K, V}`, for a FIR law written in a stage body.
- The trapezoidal and backward-Euler Discrete-Time Integrator: both are
  feedthrough, so they would stop `DiscreteIntegrator` breaking a loop. The
  honest spelling is a `method` keyword on the discretized pair, Tustin
  beside the zero-order hold.
- Zero-Pole: a `zeros`, `poles`, `gain` keyword path into `TransferFunction`.

## 4. The order of work

The shipped rows are the first two tranches. The candidate rows follow in any
order, each when wanted. A second sweep of Simulink's base library on
2026-10-30 added the candidate rows for `Select`, `Sequence`, the
`Integrator` reset, `LimitedDoubleIntegrator`, `Comparator` and the discrete
backlash, the recommended order being the comparator, then the reset, then
the schedule, since the first two close gaps a shipped docstring already
names. The example model (`examples_inventory.md`) is one
source of further candidates: what it hand-writes
twice is a block to list. Packaging beyond the `Redstone.Blocks` submodule,
a workspace sub-package or a separate repository, is an after-release
question ([D-313][d-313]).
The blocks are unexported from `Redstone.Blocks` ([D-226][d-226]), so a model file
imports the names it uses, and a file that also loads ControlSystems
qualifies the two they share, `StateSpace` and `TransferFunction`.

<!-- citation link definitions — generated by tools/linkify.jl; do not edit -->
[d-033]: ../decisions.md#d-033--declaration-inventory-by-value-by-type-by-allocation-conventions
[d-141]: ../decisions.md#d-141--continuous-state-resets-are-events-owned-by-the-reimplemented-pivector
[d-179]: ../decisions.md#d-179--derive-detection-policy-from-the-guards-return-type
[d-184]: ../decisions.md#d-184--fold-group-into-the-spec-as-an-ordinary-library-component
[d-226]: ../decisions.md#d-226--reach-the-public-surface-by-qualified-name-until-the-export-audit
[d-231]: ../decisions.md#d-231--require-isbits-store-values-checked-at-build
[d-238]: ../decisions.md#d-238--decide-embed-accept-on-the-type-lift-the-arrival-compare-exactly
[d-263]: ../decisions.md#d-263--one-arity-on-both-tiers-plain-contracts-the-pinned-marker-and-the-mandatory-store
[d-266]: ../decisions.md#d-266--two-doors-for-an-ad-opaque-implementation-the-local-rule-and-the-freeze-block
[d-276]: ../decisions.md#d-276--address-a-leaf-inside-a-port-value-by-a-dotted-leaf-address
[d-307]: ../decisions.md#d-307--keep-authored-continuous-math-generic-over-the-scalar
[d-308]: ../decisions.md#d-308--keep-integers-enums-and-bools-in-modes-and-the-workspace-out-of-snapshots-and-replay
[d-311]: ../decisions.md#d-311--fold-the-summing-junction-and-the-bool-gates-into-one-generic-junction
[d-312]: ../decisions.md#d-312--settle-the-leaf-blocks-constant-pins-unitdelay-holds-its-initial-value-freeze-strips-by-broadcast
[d-313]: ../decisions.md#d-313--admit-a-library-block-by-judgement-against-three-guidelines
[d-316]: ../decisions.md#d-316--stop-requests-are-structural-a-stopflag-port-ends-the-run-unless-the-advance-ignores-it
[d-362]: ../decisions.md#d-362--reset-maps-the-continuous-only-mode-store-and-the-rejected-all-in-one-component
[d-384]: ../decisions.md#d-384--publish-the-discrete-controllers-saturation-code-as-saturated
[d-437]: ../decisions.md#d-437--address-a-bare-contracts-port-by-the-default-face-u-or-y
[s10-5]: ../spec.md#105-multi-rate-tick-scheduling
[s10-6]: ../spec.md#106-event-iteration-at-boundaries-to-quiescence-budgeted
[s13-5]: ../spec.md#135-termination-is-a-state-not-an-exception
[s13-7]: ../spec.md#137-tooling-consequences-face-routes-and-the-component-library
[s2-3]: ../spec.md#23-events-two-detection-policies
[s3-1]: ../spec.md#31-continuous-component-the-hybrid-primitive
[s4-3]: ../spec.md#43-table-mechanics-and-port-granularity
[s5-3]: ../spec.md#53-structural-feedthrough-stage-roles-execution-order-and-step-boundaries
[s5-4]: ../spec.md#54-artificial-loops-and-the-escape-hatch
[s5-5]: ../spec.md#55-algebraic-loop-policy-reject-at-build-time
[s6-1]: ../spec.md#61-connections-and-hierarchy
[s6-2]: ../spec.md#62-aggregation-explicit-summing-junctions
[s8-2]: ../spec.md#82-the-declaration-inventory
[s8-5]: ../spec.md#85-assembly-declaration-type-based-class-by-declaration-shape
[s8-7]: ../spec.md#87-rate-scopes
[s9-7]: ../spec.md#97-the-compiled-executor
[sA]: ../spec.md#appendix-a-taught-contracts-the-author-facing-index
