# The longitudinal aircraft: the physics and the control design

*A companion record, not normative text. It gives the background of the
first example, `Longitudinal` in `examples/`, whose place and guidelines are
`examples_inventory.md`: the model and its parameters, the trim problem, the
linearization and its modes, the closed loop the tutorial builds and the
descent it flies. The framework mechanisms it leans on are `spec.md` [§14.7][s14-7]
and [§14.8][s14-8] (trim), [§14.10][s14-10] (linearization), [§13.5][s13-5] (termination) and [§13.7][s13-7]
(the library), and the controllers' design is `pid_anti_windup.md` and
`lqr_tracker.md`. Written on 2026-10-18 from the prototype that fixed the
example's numbers, which the testset pins.*

## 1. The model

A rigid aircraft confined to its plane of symmetry, with three degrees of
freedom: translation along two axes and rotation in pitch. Flat earth,
constant gravity `g = 9.81 m/s²`, constant air density, still air. Thrust
acts along the body axis through the center of mass, so it produces no
moment. No landing gear, no ground effect, no atmosphere.

The states are written in wind axes for translation and body axes for
rotation:

| State | Meaning | Unit |
|---|---|---|
| `V` | airspeed | m/s |
| `γ` | flight path angle, the velocity's angle above the horizon | rad |
| `θ` | pitch angle, the body axis's angle above the horizon | rad |
| `q` | pitch rate | rad/s |
| `h` | altitude | m |

The angle of attack is `α = θ − γ`, the angle between the body axis and
the velocity, and it is what the aerodynamics read. The inputs are the
elevator deflection `δe`, in radians and positive trailing edge down, and
the throttle setting `δt`, from 0 to 1.

**Forces and moment.** With dynamic pressure `q̄ = ½ ρ V²`, wing area `S`
and mean chord `c̄`:

    L = q̄ S CL          CL = CL0 + CLα α
    D = q̄ S CD          CD = CD0 + k CL²
    M = q̄ S c̄ Cm        Cm = Cm0 + Cmα α + Cmq q c̄ / (2V) + Cmδe δe
    T = δt T_max

The lift is linear in `α`, which holds below the stall and is where the
example stays. The drag polar is parabolic, `k = 1 / (π e AR)` for aspect
ratio `AR` and Oswald factor `e`. The moment has a static part, the
stability derivative `Cmα < 0` that pitches the nose back toward trim, the
pitch damping `Cmq < 0` in the dimensionless rate `q c̄ / 2V`, and the
elevator effectiveness `Cmδe < 0`: a positive deflection pitches the nose
down. The thrust law is the crudest possible, a fraction of a fixed
maximum. A propeller delivers roughly constant power rather than constant
thrust, and the example does not care.

**Equations of motion.** Newton along and normal to the velocity, Euler in
pitch, and the kinematics of climb:

    V̇ = (T cos α − D) / m − g sin γ
    γ̇ = (L + T sin α) / (m V) − g cos γ / V
    θ̇ = q
    q̇ = M / Iyy
    ḣ = V sin γ

Every output is a function of the state alone, so the plant has no
feedthrough and all its outputs come from `y_state`; the inputs are read by
`x_deriv` only. That makes the plant the simplest kind of component the
framework has, one stage-1 output set and one derivative.

**The parameters.** A light single-engine aircraft, round numbers in the
class of a Cessna 172:

| Parameter | Value | Note |
|---|---|---|
| `m` | 1000 kg | |
| `S` | 16 m² | |
| `c̄` | 1.5 m | |
| `Iyy` | 1800 kg m² | |
| `T_max` | 2500 N | about a quarter of the weight |
| `ρ` | 1.225 kg/m³ | sea-level density, held constant |
| `CL0`, `CLα` | 0.3, 5.0 /rad | |
| `CD0`, `k` | 0.03, 0.05 | `AR ≈ 7.5`, `e ≈ 0.85` |
| `Cm0`, `Cmα` | 0.05, −1.0 /rad | static margin `−Cmα / CLα = 0.2` |
| `Cmq` | −12 | |
| `Cmδe` | −1.2 /rad | |

The nominal state is `V = 50 m/s`, level, at `h = 1000 m`.

## 2. Trim

Level flight at a given airspeed and altitude means `γ = 0`, `q = 0` and
three rates at zero, `V̇ = γ̇ = q̇ = 0`, with `θ̇ = q = 0` and `ḣ = 0`
following. Three unknowns balance them: the pitch angle `θ`, which in level
flight is the angle of attack, the elevator `δe` and the throttle `δt`. A
hand estimate ignoring the thrust's tilt gives

    CL = m g / (q̄ S) = 0.400        →   α = (CL − CL0) / CLα = 0.0201 rad
    Cm = 0                          →   δe = (Cm0 + Cmα α) / (−Cmδe) = 0.0249 rad
    T = D = q̄ S (CD0 + k CL²)       →   δt = D / T_max = 0.373

The trim service ([§14.7][s14-7], [§14.8][s14-8]) solves the exact problem. The decisions
are `(θ, δe, δt)`, the condition writes `θ` into the plant's state beside
the held `V`, `γ = 0`, `q = 0` and `h`, and `δe`, `δt` into the root
inputs, the reads are the three derivatives, and the residuals are the
reads themselves. It converges in four iterations to

    θ = 0.019930 rad    δe = 0.025058 rad    δt = 0.37234

within one percent of the estimate, the difference being the small component
of thrust along the lift.

## 3. Linearization and the modes

Linearizing at the trim ([§14.10][s14-10]) with the state order `(V, γ, θ, q, h)` and
the input order `(δe, δt)` gives

    A = ⎡ −0.0372  −4.896  −4.914   0      0 ⎤      B = ⎡  0      2.500 ⎤
        ⎢  0.0078  −2.469   2.469   0      0 ⎥          ⎢  0      0.001 ⎥
        ⎢  0        0       0       1      0 ⎥          ⎢  0      0     ⎥
        ⎢  0       20.42  −20.42  −3.675   0 ⎥          ⎢ −24.5   0     ⎥
        ⎣  0       50      0       0      0 ⎦          ⎣  0      0     ⎦

The last column of `A` is zero: with constant density nothing depends on
altitude, so `h` is a pure integrator and one eigenvalue is exactly zero.
The other four form two complex pairs.

**The short period.** On the time scale of a second the airspeed has no
time to change. Freezing `V` and writing the `γ` and `q` rows in `α = θ − γ`
gives the two-state system

    α̇ = q − 2.469 α
    q̇ = −20.42 α − 3.675 q

whose characteristic polynomial `s² + 6.14 s + 29.5` has `ωn = 5.43 rad/s`
and `ζ = 0.566`, the exact values of the full matrix's fast pair. The
`20.42` is `−Mα`, the static stiffness `−q̄ S c̄ Cmα / Iyy`, the `3.675`
the pitch damping `−Mq` and the `2.469` the lift slope's `−Zα / V`, so the
short period is a mass on a spring whose stiffness is the static margin and
whose damping is `Cmq` plus the lift curve.

**The phugoid.** On the time scale of half a minute the angle of attack
stays at its trim value and the aircraft exchanges kinetic and potential
energy. Lanchester's estimate gives `ωn = √2 g / V = 0.277 rad/s` and
`ζ = 1 / (√2 L/D) = 0.067` with `L/D = CL / CD = 10.5`. The full matrix's
slow pair is at `ωn = 0.231 rad/s`, a period of 27.3 s, and `ζ = 0.067`:
the damping estimate is exact and the frequency estimate is 20% high,
because it drops the speed dependence of thrust and drag that the first row
of `A` carries. The tutorial's open-loop run shows this mode directly: from
`55 m/s` at the trim controls the airspeed swings between 46 and 55 m/s and
crosses the trim airspeed every 13.6 s, half the period, while the altitude
rides 46 m above and back.

## 4. The closed loop

The tutorial's fifth layer closes the loop with library blocks alone
([§13.7][s13-7]). Everything discrete runs at 50 Hz under a plant step of 5 ms.

**The actuators.** Each control passes through a discrete `RateLimiter` and
a continuous `FirstOrderLag`: the elevator at 1 rad/s and 50 ms, the
throttle at 0.5 /s and 0.5 s. Their initial values are the trim's.
`trimmed(solution)` seeds the three integrators whose trim value is not
zero through `at` and `fragment(s = …)`, the altitude loop's at `θ`, the
pitch-rate loop's at `δe` and the throttle's at `δt`. The closed loop then
starts at rest at the trim.

**The cascade.** Four `DiscretePID` blocks, each with the hold and the
tracking axis (`pid_anti_windup.md`, section 4):

| Loop | Reads | Commands | `Kp`, `Ki` | Limits |
|---|---|---|---|---|
| pitch rate | `q` | elevator | −0.2, −0.4 | ±0.5 rad |
| pitch attitude | `θ` | pitch rate | 2.0, 0.5 | ±0.5 rad/s |
| altitude | `h` with sensor noise | pitch attitude | 0.01, 0.001 | ±0.26 rad |
| airspeed | `V` | throttle | 0.2, 0.05 | 0 to 1 |

The signs follow `Cmδe < 0`: a positive elevator pitches down, so the
innermost gains are negative. The inner loop's crossover sits near the
short period's frequency, where `|24.5 Kp| ≈ 5 rad/s`, and each outer loop
is slower by a factor of three to ten, the usual spacing that lets each be
designed as if the loop inside it were ideal. The altitude loop closes
through `ḣ ≈ V γ`, so one metre of error asks for 0.01 rad of pitch and
the loop's bandwidth is about 0.5 rad/s. The altitude the controller reads
carries Gaussian white noise of 0.3 m standard deviation per sample from a
`GaussianWhiteNoise` at the same rate, so the plots show a measurement
rather than a state.

Each block's hold input is wired from the block inside it: the attitude
loop reads the rate loop's `saturated` code and the altitude loop the
attitude loop's, so an outer integrator stops winding when the inner
command is on its limit. The two innermost blocks read a constant zero code
and back-calculate against their own limits.

Every tracking time constant `Tt` is one period, 0.02 s, the tracker's
included. A block not in command follows the selected command with a lag
of about `Tt` times the rate at which its own law moves, plus one tick, so
a short `Tt` keeps the standby close to the command during a maneuver. A
block in command back-calculates against its limits, and at one period it
pulls a limited integrator back within a tick.

**The LQR tracker.** A `DiscreteLQRTracker` over the full state
`x = (V, γ, θ, q, h)` commanding both controls, with the command vector
`z = (h, V)`, designed by `lqr_tracker.md`'s sections 2 and 3. The state is
augmented with the integrals of both command errors, and the gain comes
from `ControlSystemsBase`'s `lqr` with diagonal weights by Bryson's rule, an
acceptable excursion per state and per input:

    V: 5 m/s     γ, θ: 0.05 rad     q: 0.2 rad/s     h: 20 m
    ∫h: 100 m s     ∫V: 25 m     δe: 0.2 rad     δt: 0.3

`K_fbk` is the state half of the augmented gain, `K_int` the integral
half, and `K_fwd = M_22 + K_fbk M_12` with the two blocks read off the
inverse of the full `[A B; C D]`; the Schur-complement form of section 2
needs `A⁻¹`, which the zero altitude eigenvalue denies. The trim triple is
the linearization's operating point. The tracker's own limits are the
actuators' ranges, and its hold input reads a zero code.

**The switch and the bumpless engage.** A `Switch` per control selects the
cascade's command while a pinned `Source{Bool}` over a predicate of time,
`cascade(t)`, holds, and the tracker's otherwise. Both controllers run all
the time, and the one not in command tracks the one that is
(`pid_anti_windup.md`, section 11): the engaged flags are the switch's
selector and its negation, and each innermost block reads the selected
command, one tick old through a `UnitDelay`, as its tracking input. The two
outer loops of the cascade track the measured variable of the loop inside
them, pitch attitude for the altitude loop and pitch rate for the attitude
loop, so when the cascade is re-engaged every integrator holds nearly the
value that reproduces the current command.

The switch is bumpless in steady flight. During a maneuver the standby lags
the command by about `Tt` times the command's slew rate plus one tick, a
few hundredths of a radian at one period. With the cascade in command, the
standby tracker stays within about 0.034 rad of the elevator command over
the climb after its first half second. It reaches 0.43 rad for about a
tenth of a second right after the reference step, since the step moves the
tracker's own law in one tick, and it sits within 0.015 rad after
`t = 10 s`. At a switch to the tracker at 60 s, in steady flight, the
elevator's largest frame-to-frame change is 3.45e-4, below the 5.05e-4 of
jitter the altitude noise induces in steady cascade flight. At a switch at
10 s, mid-climb, it is 1.5e-3. A hand-back to the cascade at 10 s, once
the pull-up is over, jumps the elevator command by 2.3e-3. Handed back
during the pull-up itself, at 7 s, the command would jump by about
0.15 rad, the standby's lag behind a command slewing at up to about
4 rad/s, which the actuator's rate limit then spreads over about 0.15 s.

**What the loop does.** From trim, a 50 m step in the altitude reference at
`t = 5 s` is held within 0.1 m by `t = 80 s` by either controller, the
cascade with no overshoot and the tracker with about 2 m. During the climb
the airspeed strays from 50 m/s by up to about 4 m/s under the cascade and
about 1 m/s under the tracker, and after `t = 80 s` it stays within
0.02 m/s. The testset pins the hold after `t = 80 s`, the two peaks, the
equilibrium at trim, the standby's tracking during the climb, the jumps at
the two switches and at the hand-back, and the sensor noise.

## 5. The descent and the touchdown

The sixth layer flies the open-loop aircraft from 30 m at the trim
elevator and a reduced throttle, `δt = 0.25`. The thrust deficit of about
300 N settles into a shallow glide, `sin γ ≈ −ΔT / (m g) ≈ −0.03`, and the
aircraft reaches the ground after 17.7 s.

The ground is a `GroundContact` leaf wired from the plant's altitude. Its
one event is a localized state event ([§2.3][s2-3], [§10.4][s10-4]): the guard returns the
sign-form value `h_ground − h`, which the framework root-finds, so the step
in which the crossing falls ends at the crossing itself, and the handler
sets the mode `contact`. The leaf publishes the mode as a `Bool`, a
`StopRequest` turns it into a stop request, and the run ends at that
boundary ([§13.5][s13-5]). The termination record names the requester's path and
port and the reason `"touchdown"`, and the final state has `h = 0` to
within the localization tolerance rather than one step below it, which is
the difference between this and a `Junction` computing `h ≤ 0`, whose
request would be sampled at the next frame top.

<!-- citation link definitions — generated by tools/linkify.jl; do not edit -->
[s10-4]: ../spec.md#104-localization-mechanics
[s13-5]: ../spec.md#135-termination-is-a-state-not-an-exception
[s13-7]: ../spec.md#137-tooling-consequences-face-routes-and-the-component-library
[s14-10]: ../spec.md#1410-linearization-tap-selectors-one-seeded-pass-a-pure-query
[s14-7]: ../spec.md#147-the-trim-problem-namedtuple-decisions-declared-reads-named-residuals
[s14-8]: ../spec.md#148-the-trim-service-solver-seam-scratch-stores-commit-and-report
[s2-3]: ../spec.md#23-events-two-detection-policies
