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
  are assemblies and modes (`reports/20260809_extensions_charter/report.md` items 5 and 7).
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
  closed axes (`reports/20260809_extensions_charter/report.md`, section 1.3).

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

An event design is checked against [§10.6][s10-6]'s boundary bookkeeping before it
enters a row, since three shapes have failed there. A handler that moves
the guard onto a predicate already holding presents no fresh edge, so a
mode meant to advance one step per firing sticks when two crossings are
observed at one boundary, two inside a non-localized step or two at or
before `t₀`. A latch mode around a `Bool`-form guard duplicates [§2.3][s2-3]'s
edge rule, and no test tells the two apart. A threshold with non-strict
guards on both sides chatters at `lower == upper`; one side is strict.

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
side as `u` or `y`, the value itself. A long mechanism goes in a note under its
table, which keeps each row on one line of a full-screen editor.

A block with a defaulted parameter, or with more than one, gets a
hand-written keyword constructor, as in `Integrator(; x0 = 0.0)` and
`Relay(; lower, upper, off = zero(lower), on = one.(lower))`. A positional
call is easy to get wrong, and [§8.2][s8-2] already makes keyword defaults the
convention. A parameter with no sensible default is a required keyword.
Keywords that share a type parameter broadcast to one shape, `Float64` or
an `SArray` of `Float64`, which is why the constructor is hand-written
rather than `@kwdef`. A scalar pairs with a vector, and integer and `Float32`
keywords convert, a block's lone keyword too, as does an array keyword of any
kind, a plain `Vector` or an `MVector`, which becomes the `SArray` of its
size; past `STATIC_WARN_LENGTH` elements, 512, the conversion warns once,
since an `SArray` that large compiles slowly in every stage that touches it
and runs no faster than a plain array ([§7.1][s7-1]). A uniform vector gain
spells one keyword as a vector,
`Kp = @SVector fill(2.0, 3)`, and a scalar limit serves every component of a
vector integrator. Two lengths are Julia's `DimensionMismatch`. The
convention is one for every block because only broadcasting pairs the PID's
scalar defaults with a vector `Kp`, where promotion throws. A keyword given
as `AsPort()` is a port of the block, not a field, and takes no part in the
shape. The struct keeps
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
| `Pack{V, N}` and `Unpack{V, N}` | shipped | wires name whole ports: between scalar ports and an `SVector{N, V}` port, `Pack` a junction alias at a named fold |
| `StopRequest`, reason as instance data | shipped | a `Bool` in, a `StopFlag` out, consumed by nobody; the request is the port's type, so any component may publish one |
| `Fields{V}`, a `y_direct` leaf taking a struct-valued bundle port | shipped | publishes the bundle's fields as loose ports, one level deep, for a consumer wanting less than the bundle, since wiring is port-granular ([§4.3][s4-3], [D-276][d-276]) |
| `Switch{V}` selecting between two inputs on a `Bool` | shipped | the `Bool` a junction's one `In` cannot type |
| `Select{V, K}` choosing among inputs on an enum `K` | shipped | the N-way `Switch`, Simulink's Multiport Switch and Index Vector, keyed on `instances(K)` so the inputs wear the enum's names and a wire reads `sel/CRUISE` |
| `Fn{U, Y}(f)`, one input of type `U` and one output of type `Y`; `Fn{U}(f)` for `Y = U` | shipped | the transform between two children that wires cannot express, a unit conversion or a sign flip; the feedthrough sibling of `Source{V}(f)` |

**`StopRequest`.** `stop_reason` names the request in the termination record
([§13.5][s13-5], [D-316][d-316]).

**`Switch`.** The jump lands where the selector flips, so the event is the
selector's producer's, a `Comparator` when the selector reads a continuous
quantity.

**`Select`.** `y_direct` is a generated chain, `select === K1 ? u.K1 : …`, over
`instances(K)` passed as a `Val`, since a generator runs in its own world and
cannot call the enum's methods; no `Symbol` and no string is formed in the
body, either of which allocates. It is type-stable since every data input is a
`V`. The value set is closed, so no out-of-range case exists. The selector is
`select`, as `Switch` spells it, and an enum with an instance of that name, or
an abstract `K`, is refused at construction. An enum is an atom the cells, the probe and the descriptor already
carry, and its producer holds it as a mode ([D-308][d-308]), so the jump lands on a
boundary as `Switch` wants. There is no integer-keyed form, since an index wants
an enum anyway. `Switch{V}` stays, `Bool` being no `Enum`.

**`Fn`.** The alternative is a four-declaration primitive per glue step. It is
admitted on didactic value, for the structure the declaration layer forces, as
the `Junction` is, not as a gain, so section 1's pricing still applies per
instance. The port types are type parameters and never read off `f` ([D-033][d-033]), so
a closure's output type is declared. `f` is applied in `y_direct`, so the block
is a stage 2 leaf, and `f` walks under `Dual`, which the probe checks. It is the
one-input `Junction` with its input bare ([D-437][d-437]), a struct of its own
since the junction's `in1` is the N-ary spelling. A `Pinned{Y}` is the struct
`Freeze`'s spelling, `Fn{V, Pinned{V}}(strip)`: `f` must drop the partials
itself, and one that keeps them is refused as `ConformanceFailure` at the first
`Dual` build or linearization ([D-266][d-266], [D-312][d-312]).

**`Fields`.** The outputs take the field names and types of `V`, one level
deep, so a struct field is one output and a second instance splits it. A
`NamedTuple` qualifies by its names. A `Real`, a `StaticArray`, a `Tuple`, an
empty `NamedTuple` or a `UnionAll` is refused at construction, and `Unpack`
splits the static array.

### Sources

| Block | Status | Mechanism |
|---|---|---|
| `Constant(value)` | shipped | the pinned source; the zero-contributor wire and the rig stub |
| `Step(; t_step, before = 0.0, after = 1.0, localized = true)`, with a guard on the bundle's `t` in either form | shipped | the jump is localized, or lands on a step boundary, by the guard's form, which `localized` picks ([D-179][d-179]) |
| `Sequence(; times, values, localized = true)`, `N` strictly ascending breakpoints and `N + 1` values | shipped | the breakpoint schedule, `Step` at `N = 1`, covering Signal Builder, Repeating Sequence Stair and a finite pulse train |
| `Source{V}(f)`, a user function of the nominal `t` | shipped | covers ramps and sines without a block each; pinned ([D-312][d-312]): `t` is the activation scalar, stripped before `f` |
| `GaussianWhiteNoise(; seed, μ, σ, psd)`, a discrete Gaussian white noise process, seed as instance data | shipped | a counter-based draw; `σ` per sample, or the two-sided density `psd` read against the bundle's `Δt` as `σ² = psd/Δt` |

**`Sequence`.** A mode counts the breakpoints passed, read by `y_state`. One
event's guard is `t - times[m + 1]` until the last, so it re-arms after each
firing. Its handler sets the mode to the count of breakpoints at or before `t`,
never `m + 1`: two breakpoints observed at one boundary, inside one
non-localized step or both at or before `t₀`, present no fresh edge after the
first firing ([§10.6][s10-6]), so an increment would stick one short for good. It is
not periodic, since a periodic reset is not a time-guard event ([D-362][d-362]). A
periodic pulse is a discrete counter at its own period, `s⁺ = mod(s + 1, K)`, a
one-liner and no block.

**`GaussianWhiteNoise`.** The sample is a pure function of the seed and a tick
counter, the store's one field ([D-231][d-231]), so the stage draws and no generator
or workspace is needed.

### Continuous dynamics

| Block | Status | Mechanism |
|---|---|---|
| `Integrator(; x0 = 0.0, reset = false)`, `reset = true` a type parameter adding the `Bool` input `reset` | shipped | walks under `Dual`; the commanded continuous reset as an event ([§3.1][s3-1], [§5.3][s5-3], [D-141][d-141]) |
| `LimitedIntegrator{V, L, R}` over `Float64` or an `SArray` | shipped | a mode the derivative reads, and four events; departures localized or non-localized, by `L` ([D-179][d-179]); `saturation` published |
| `LimitedDoubleIntegrator(; lower, upper, q0 = zero(lower), v0 = zero(lower), localized = true)` | shipped | position limits on the double integral of its input, the mechanical stop, Simulink's Second-Order Integrator Limited |
| `FirstOrderLag{V}`, time constant as instance data | shipped | the actuator model and [§5.5][s5-5]'s α-filter idiom |
| a continuous rate limiter | not admitted | `q̇ = clamp((in - q) / τ, -R, R)` is one line, its kinks are second-order and its offsets decay; the discrete form is the block |
| `StateSpace(; A, B, C, D, x0)` from any matrices, scalar or `SVector` ports by the matrix shapes | shipped | stored as static ones; `D` picks the stage, so the feedthrough class is a type parameter; `x0` in the user's coordinates; `linear_blocks.md` |
| `TransferFunction(; num, den, u0)` from coefficient tuples or vectors, one input and one output | shipped | realized to a `StateSpace` at construction; started at rest or at the steady state for `u0`, never from an `x0`; `linear_blocks.md` |
| a continuous transport delay | not admitted | a history buffer indexed by the step; `reports/20260809_extensions_charter/report.md` item 4 |

**`Integrator`.** The reset is one non-localized event whose guard reads
`reset` and whose handler writes `x0`, firing once per rising edge and never
while held, which is [§2.3][s2-3]'s edge semantics and needs no latch. It acts on the
rising edge only, with no level reset and no initial-condition port, so no
all-in-one ([D-362][d-362]). The data port keeps the face `u` in both forms ([D-437][d-437]). A
reset driven by a continuous quantity arrives through a `Comparator`, where it
is localized. A `Bool` input is held, never tapped, so the linearization has no
`reset` column. On the discrete tier the same reset is the level form, one
`ifelse` in `s_update`, on `DiscreteIntegrator(; reset)` and its limited sibling
by contrast.

**`LimitedIntegrator`.** The hit pair of events reads `x - limit` and on the
limit `u`, so a block freed there presents a fresh edge when its input turns
outward. The leave pair is gated by the mode and strictly inward input. Modes
are `Int8` codes, with `4N` per-component events over a vector. `reset = true`
is the `Integrator`'s reset form, a fifth event on the flag's rising edge whose
handler writes `x0` clamped to the limits and the code `x0` earns. So a reset
onto a limit lands saturated, until an inward input frees it by its leave event,
and one inside lands free.

**`LimitedDoubleIntegrator`.** The named state pair is `q` and `v`, each keyword
naming the leaf it starts. It has `LimitedIntegrator`'s mode and four events,
the hit pair on `q` and the leave pair on the input's sign, and hit handlers
that write the limit and zero the velocity. Saturated means at rest on the
limit, so a block that reaches a limit while its input already points back frees
in the next round of the same boundary and leaves from rest. A hit guard reads
the first nonzero of `q - limit`, `v` and `u`, so a block freed at rest does not
hold its predicate and an input turning outward again, even inside the same
step, presents a fresh edge ([§2.3][s2-3]), while a slow departure whose `q` rounds back
onto the limit does not re-fire. A `q0` on a limit with `v0` pointing back in
starts free and keeps it. Under the non-localized leave `v` carries an
offset of at most `a h² / 2` and `q` one that grows with time until the next
limit. The outputs are `out`, `velocity` and `saturation`, with `4N`
per-component events over a vector. It has no reset form yet, its two open
questions in increment 87's brief. It serves actuators with inertia and gear
struts. The bouncing ball, `v ← -e v` with no saturated mode, is the same shape,
an example model where its Zeno behaviour shows the event budget ([§10.6][s10-6]) and not
a row.

**`FirstOrderLag`.** For a scalar signal it is the lag form of
`TransferFunction`, and the block stays for static-array signals, for `x0` in
the signal's own coordinates and for the spelling.

**`TransferFunction`.** The stage arms are shared through the abstract
`LinearBlock{FT}`, and the class comes from the numerator's degree.

### Discontinuities

| Block | Status | Mechanism |
|---|---|---|
| `Relay{V}` (hysteresis) over `Float64` or an `SArray` | shipped | the reference mode-switching leaf; modes as `Int8` codes, `2N` per-component events over a vector |
| `Comparator(; threshold, lower, upper, localized = true)`, `threshold` alone or both limits, a `Bool` output | shipped | Hit Crossing, Compare To Constant and the threshold criterion of Simulink's Switch in one; a plain threshold at `lower == upper`, hysteresis between them |
| Saturation, dead zone | not admitted | one-line clamps; when localization doctrine wants a declared kink, a `Comparator` on the same signal lands the step on it |
| Quantizer, Coulomb and viscous friction | not admitted | the quantizer belongs on the discrete tier; the friction block is a memoryless sign law |

**`Relay`.** The fall is strict as the `Comparator`'s, so `lower == upper` is a
plain threshold that chatters nowhere.

**`Comparator`.** `Relay`'s latch and guard pair publishing `Pinned{Bool}` from
the mode, the policy by `L` as in `Step` ([D-179][d-179]). The fall is strict,
`u < lower`, spelled `prevfloat(lower) - u` in sign form, since with both guards
non-strict an input sitting exactly on a plain threshold holds both predicates
and the switches re-enable each other to the firing budget. `lower > upper` is
refused. It is the declared way to produce `Switch`'s `select` from a continuous
quantity, which the `Switch` docstring otherwise calls a mode made silently. It
is the declared kink the saturation row reserves, a clamp staying one line
beside it. `Relay` is a `Comparator` feeding a `Switch` over two constants, and
stays for the spelling.

**Quantizer and friction.** The quantizer jumps at every level, and on the
discrete tier it jumps at ticks and smears nothing. A stiction model with stick
and slip modes is a mechanics package's.

### Discrete tier

| Block | Status | Mechanism |
|---|---|---|
| `UnitDelay{V}` | shipped | the tier's native `z⁻¹` ([§10.6][s10-6]) |
| `DiscreteIntegrator{V, R}` | shipped | tier semantics; forward Euler, its bare output the state from `s0`, so it breaks a loop as `UnitDelay` does; no gain and no limits, as `Integrator` has none |
| `RateLimiter{V}` | shipped | tier semantics; feedthrough, its bare output following its bare input within `rising Δt` up and `falling Δt` down per tick from `s0`; its `s_update` stores `y` |
| `Backlash{V}` | shipped | `RateLimiter`'s sibling, admitted on tier semantics as the rate limiter was and priced as the one-liner it is: `y = clamp(s, u - w/2, u + w/2)`, its `s_update` storing `y` |
| `DiscreteStateSpace` and `DiscreteTransferFunction`, the pair in `z` | shipped | the continuous pair mirrored over `DiscreteLinearBlock{FT}`, `s_update` for `x_deriv`; the period is the scope's and the block cannot check it; `linear_blocks.md`, section 9 |
| `DiscretizedStateSpace` and `DiscretizedTransferFunction`, from a continuous system | shipped | the zero-order hold taken per tick at the bundle's `Δt`, so the class and the initial condition are the continuous ones; `linear_blocks.md`, section 9 |
| `DiscreteLimitedIntegrator{V, R}` | shipped | tier semantics by contrast: the continuous block's mode and four events are one `clamp` in `s_update`, with no mode store and no localization |
| `Delay(; K, v0)` | shipped | the tier's `z⁻ᴷ` in a ring store, `K` ticks of the component's own period ([§10.5][s10-5]), one output, `K = 1` the `UnitDelay` in keyword spelling |
| a trapezoidal or backward-Euler integrator, and Tustin on the discretized pair | not admitted | all three feedthrough, which costs the loop break `DiscreteIntegrator` exists for; a Tustin design arrives discretized, through the pair in `z`; `linear_blocks.md`, section 9.2 |

**`DiscreteIntegrator`.** `reset = true` adds the `Bool` input `reset`, a level
reset in `s_update` ([§5.3][s5-3]). The update writes `s0` while the flag reads true, so
the state lands at the next tick and the output at the reset tick is the stale
integral. The same-tick spelling reads the flag in an output stage, which makes
every input a feedthrough edge and costs the loop break, so it is not offered.

**`Backlash`.** The output holds inside a deadband of `width` about itself and
follows the input at half a width's offset outside it, from `s0` as the previous
output. The continuous block needs the sign of `u̇`, which no stage sees and
Simulink fakes.

**`DiscreteLimitedIntegrator`.** It has `LimitedIntegrator`'s interface,
`lower`, `upper`, `s0`, `reset` and the `Int8` `saturation` code, the code read
off the state from stage 1. The reset is the level form of
`DiscreteIntegrator`'s, `s0` clamped.

### Stop-gradient

| Block | Status | Mechanism |
|---|---|---|
| `Freeze{V}` over `Float64` and `SArray` | shipped | the declared stop-gradient ([D-266][d-266]) |
| `Freeze` over a struct `V` | not admitted | the strip for one struct is a leaf of the author's, tolerant in and pinned out; the generic allocation-free leafwise map has no user ([D-312][d-312]) |

### Controllers

| Block | Status | Mechanism |
|---|---|---|
| `PID(; Kp, …, hold, tracking)` over `Float64` or an `SArray` | shipped | one law, `q̇ = Ki ε + (ref - u_raw) / Tt`, componentwise over a static vector, with two independent axes, the hold and the tracking reference `v` |
| `DiscretePID(; Kp, …, hold, tracking)` | shipped | the positional law carried to the discrete tier, the ports, the gate, the reference rule and the parameters shared through `PIDBlock{V, Hold, Track, Fixed}` |
| `LQRTracker(; K_fbk, K_fwd, …)` | shipped | the LQR tracker about a trim point; inputs `x`, `z` and `z_ref` as static vectors, outputs `u` and `u_raw` from stage 2; gains designed outside, from `trim!` and `linearize`; no saturation output |
| `DiscreteLQRTracker(; K_fbk, K_fwd, …)` | shipped | the tracker on the discrete tier over `LQRTrackerBlock`, forward Euler on the integrator and the correction's exact step as `DiscretePID` |

**`PID`.** The hold adds the saturation code that gates the integrator by sign
and the flag `engaged` under which the error is gated off, not engaged taking
precedence. The tracking reference `v` is what `u_raw` converges to while
limited or not engaged, so a block not in command follows the selected command
and engages bumplessly, with the fallback to the own `u` while free. Otherwise
back-calculation runs against the own limits. The three ports are at the
output's shape, and `Ki` sits inside the integral. Every parameter is a `V`, and
any of them a port by `AsPort()`. The setpoint weights are `b = 1` and `c = 0`,
so the derivative acts on the measurement by default. A fixed infinite `Tt` is
refused with `tracking`. There is no saturation output, since a continuous code
would need a mode and events. See `pid_anti_windup.md`, section 4 for the table,
section 10 for the vectors, the ports and the weights, section 11 for standby.

**`DiscretePID`.** The sharing makes it componentwise over a static vector,
every parameter a `V`, any of them a port by `AsPort()` and the weights `b = 1`
and `c = 0`, as in `PID`. It uses forward Euler on the integral, backward Euler
on the derivative filter so `τd = 0` is the backward difference, and the
correction's step `1 - e^{-Δt/Tt}` so every `Tt` is stable and `Tt = 0` is
instant, which makes standby follow exactly. A second output `saturated`, the
own clamp's `Int8` code written to the store at the tick and published from
stage 1 at the next, one tick stale, serves an outer block's hold, named apart
from the hold's input ([D-384][d-384]). See `pid_anti_windup.md`, sections 9 to 11.

**`LQRTracker`.** The law is
`u_raw = u_trim + K_fwd (z_ref - z_trim) - K_fbk (x - x_trim) + q` with
`q̇ = ε + (ref - u_raw) / Tt` over an `n_u`-wide integrator, `ε` the gated
`K_int (z_ref - z)` and `K_int` inside it. It has the PID's two axes over the
integrator input channel by channel, `engaged` per channel, and the own clamp by
back-calculation. The nine parameters are the three gains and the trim triple as
static matrices and vectors and `Tt`, `u_min`, `u_max` per channel, any of them
a port by `AsPort()`, which is how a gain schedule arrives. See
`lqr_tracker.md`.

**`DiscreteLQRTracker`.** The own clamp's `Int8` code vector is the output
`saturated` ([D-384][d-384]), from stage 1 off the store, one tick stale, for the outer
loops of a cascade, each channel reaching a scalar consumer through
`Unpack{Int8, NU}`. See `lqr_tracker.md`, sections 6 and 7.

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
  limits as ports, `AsPort()` on the limits of `RateLimiter`,
  `LimitedIntegrator` and `DiscreteLimitedIntegrator`: not admitted, on
  2026-11-06. On the discrete blocks the scheduled form is the same one-liner
  reading its limits off `u`, which a model writes as its own three-line
  component, and the cascade case, inner limits set by an outer command, is
  what the controllers' scheduled `u_min` and `u_max` serve. On
  `LimitedIntegrator` a moving limit on a saturated state needs the limit's
  rate, which no stage sees, so the best design is a staircase one boundary
  behind the limit, two more `Bool`-form events and a [§10.6][s10-6] probe,
  for no model that asks for it.
- Tapped Delay, shipped on 2026-11-06 as increment 89: a second output on
  `Delay` publishing the ring as an
  `SVector{K, V}`, for a law over the window written in a stage body, a
  moving median or a min over the last `K` samples; a FIR filter is already a
  `DiscreteTransferFunction`. `taps = true` is a type parameter naming the
  output side `(y, taps)`, so `taps = false` keeps the bare `y` as
  `Integrator(reset = true)` keeps `u`. Newest first, `taps[1]` the input
  from one tick ago and `taps[K]` from `K`, so `y == taps[end]`; published
  from stage 1 as a rotation of the ring by the cursor, so the loop break
  stays.
- Zero-Pole, shipped on 2026-11-06 as increment 89: a `zeros`, `poles`,
  `gain` keyword path into `TransferFunction`,
  `DiscreteTransferFunction` and `DiscretizedTransferFunction`, exclusive
  with `num` and `den`. Roots real or complex; a product whose imaginary part
  is not zero to rounding is refused, which conjugate pairs pass, and the
  real coefficients then meet the existing refusals.

## 4. The order of work

The shipped rows are the first two tranches. The candidate rows follow in any
order, each when wanted. A second sweep of Simulink's base library on
2026-10-30 added the candidate rows for `Select`, `Sequence`, the
`Integrator` reset, `LimitedDoubleIntegrator`, `Comparator` and the discrete
backlash. The comparator, the reset and the schedule shipped first, as
increment 86 on 2026-11-03, since the first two closed gaps a shipped
docstring already named, and the limited double integrator as increment 87
on 2026-11-04, and the structure blocks `Fn`, `Select` and `Fields` as
increment 88 on 2026-11-05, the day Tustin on the discretized pair and
`Freeze` over a struct were retired from the candidates, and the discrete
backlash as a loose commit on 2026-11-06, and the two additions to shipped
blocks as increment 89 the same day, which closed the list. The example model
(`examples_inventory.md`) is one
source of further candidates: what it hand-writes
twice is a block to list. Packaging beyond the `Redstone.Blocks` submodule,
a workspace sub-package or a separate repository, is an after-release
question ([D-313][d-313]).
The blocks are unexported from `Redstone.Blocks` ([D-226][d-226]), so a model file
imports the names it uses, and a file that also loads ControlSystems
qualifies the two they share, `StateSpace` and `TransferFunction`.

<!-- citation link definitions — generated by tools/linkify.jl; do not edit -->
[d-033]: ../log.md#d-033--declaration-inventory-by-value-by-type-by-allocation-conventions
[d-141]: ../log.md#d-141--continuous-state-resets-are-events-owned-by-the-reimplemented-pivector
[d-179]: ../log.md#d-179--derive-detection-policy-from-the-guards-return-type
[d-184]: ../log.md#d-184--fold-group-into-the-spec-as-an-ordinary-library-component
[d-226]: ../log.md#d-226--reach-the-public-surface-by-qualified-name-until-the-export-audit
[d-231]: ../log.md#d-231--require-isbits-store-values-checked-at-build
[d-238]: ../log.md#d-238--decide-embed-accept-on-the-type-lift-the-arrival-compare-exactly
[d-263]: ../log.md#d-263--one-arity-on-both-tiers-plain-contracts-the-pinned-marker-and-the-mandatory-store
[d-266]: ../log.md#d-266--two-doors-for-an-ad-opaque-implementation-the-local-rule-and-the-freeze-block
[d-276]: ../log.md#d-276--address-a-leaf-inside-a-port-value-by-a-dotted-leaf-address
[d-307]: ../log.md#d-307--keep-authored-continuous-math-generic-over-the-scalar
[d-308]: ../log.md#d-308--keep-integers-enums-and-bools-in-modes-and-the-workspace-out-of-snapshots-and-replay
[d-311]: ../log.md#d-311--fold-the-summing-junction-and-the-bool-gates-into-one-generic-junction
[d-312]: ../log.md#d-312--settle-the-leaf-blocks-constant-pins-unitdelay-holds-its-initial-value-freeze-strips-by-broadcast
[d-313]: ../log.md#d-313--admit-a-library-block-by-judgement-against-three-guidelines
[d-316]: ../log.md#d-316--stop-requests-are-structural-a-stopflag-port-ends-the-run-unless-the-advance-ignores-it
[d-362]: ../log.md#d-362--reset-maps-the-continuous-only-mode-store-and-the-rejected-all-in-one-component
[d-384]: ../log.md#d-384--publish-the-discrete-controllers-saturation-code-as-saturated
[d-437]: ../log.md#d-437--address-a-bare-contracts-port-by-the-default-face-u-or-y
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
[s7-1]: ../spec.md#71-continuous-state-structured-immutable-flat-backing
[s8-2]: ../spec.md#82-the-declaration-inventory
[s8-5]: ../spec.md#85-assembly-declaration-type-based-class-by-declaration-shape
[s8-7]: ../spec.md#87-rate-scopes
[s9-7]: ../spec.md#97-the-compiled-executor
[sA]: ../spec.md#appendix-a-taught-contracts-the-author-facing-index
