# The longitudinal aircraft: the physics and the control design

*A companion record, not normative text. It gives the background of the
first example, `Longitudinal` in `examples/`, whose place and guidelines are
`examples_inventory.md`: the model and its parameters, the trim problem, the
linearization and its modes, the loops the tutorial builds and the
approach it flies. The framework mechanisms it leans on are `spec.md` [§14.7][s14-7]
and [§14.8][s14-8] (trim), [§14.10][s14-10] (linearization), [§13.5][s13-5] (termination) and [§13.7][s13-7]
(the library), and the controllers' design is `pid_anti_windup.md` and
`lqr_tracker.md`. Written on 2026-10-18 from the prototype that fixed the
example's numbers, which the testset pins. Sections 4 and 5 were revised on
2026-11-18 for the loops of the tutorial's chapters 4 to 8.*

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

The problem runs on `aircraft()`, the plant as the one child `plant` of a
`Group` whose `input_wires` hand it the root inputs. A leaf may be the root
on its own ([D-208][d-208]), with its `u_types` as the root inputs and the empty
path as its address. The wrapper is there only for the path: in the closed
loops the plant must sit under a group, at `"plant"`, and
with the open loop placing it there too, the trim condition, the taps and
every reader in the tutorial and the testset keep one spelling across the
chapters. `approach` alone moves the plant, to `"vehicle/plant"`.

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
time to change. The `γ` and `q` rows read the angles through `α = θ − γ`
alone, so their `γ` and `θ` entries are equal and opposite. Freezing `V`
and writing `α̇ = θ̇ − γ̇ = q − γ̇` gives the two-state system

    α̇ = q − 2.469 α
    q̇ = −20.42 α − 3.675 q

whose characteristic polynomial `s² + 6.14 s + 29.5` has `ωn = 5.43 rad/s`
and `ζ = 0.566`, the full matrix's fast pair to three figures. The
`20.42` is `−Mα`, the static stiffness `−q̄ S c̄ Cmα / Iyy`, the `3.675`
the pitch damping `−Mq` and the `2.469` the lift slope's `−Zα / V`, so the
short period is a mass on a spring whose stiffness is the static margin and
whose damping is `Cmq` plus the lift curve.

**The phugoid.** On the time scale of half a minute the aircraft exchanges
kinetic and potential energy. Lanchester's estimate holds the angle of
attack at its trim value and gives `ωn = √2 g / V = 0.277 rad/s` and
`ζ = 1 / (√2 L/D) = 0.067` with `L/D = CL / CD = 10.5`. The full matrix's
slow pair is at `ωn = 0.231 rad/s`, a period of 27.3 s, and `ζ = 0.067`.

The frequency estimate is 20% high because the angle of attack does not
hold. On this time scale the pitching moment stays balanced,
`Mα Δα + Mq q = 0`, and the aircraft pitches with its flight path,
`q = γ̇`. So the angle of attack gives way against the path's curvature,
`Δα = −(Mq / Mα) γ̇ = −0.180 γ̇`, and the lift it takes away slows the
path by the factor `1 + 2.469 × 0.180 = 1.444`. That is the short period's
stiffness over its static part, `29.5 / 20.42`. The frequency falls by its
square root, to `0.277 / 1.202 = 0.231 rad/s`. With `Cmq = 0` the factor is
one and the model's slow pair sits at `0.277 rad/s`, Lanchester's value.

The speed dependence of drag in the first row of `A` gives the mode its
damping and leaves its frequency alone, and the thrust of this model does
not vary with speed. The damping estimate agrees to two figures at these
parameters and not in general: with `Cmq = 0` the model's `ζ` is 0.050.
The figures of these two paragraphs come from
`increments/20261119_tutorial_pages/probe_phugoid.jl`.

The tutorial's open-loop run shows this mode directly: from
`55 m/s` at the trim controls the airspeed swings between 46 and 55 m/s and
crosses the trim airspeed every 13.6 s, half the period, while the altitude
rises 46 m above the start.

## 4. The closed loop

The tutorial closes the loop in three steps, each a function of the
example's file. `pitch_hold` is one PID on the pitch angle. `autopilot` is
the cascade with its actuators and its sensing. `piloted` puts an engage
switch between the cascade and the actuators. All three are built from
library components ([§13.7][s13-7]) and one leaf of the example's own,
`Measurement`. From `autopilot` on the model is a `Group` of groups beside
the plant. Each group exports the signals
that cross its boundary as faces and keeps the rest inside, so the root level
reads as the loop's block diagram and each group as one of its boxes.

From `autopilot` on the model also states no seconds ([§8.7][s8-7]). One
constant, `sensor_multipliers`, holds each sensor's period in base ticks,
1 for the IMU, 4 for the INS and 20 for the air data system. `sensing`
gives each sensor its multiplier as a `Relative` entry, and `cascade` gives
the same multiplier to each controller that sensor feeds, so a controller
ticks with its sensor. The roots declare no rates, and the deployment's
base tick sets every one ([§6.3][s6-3], [§9.2][s9-2]). The testset deploys
these models at a frame of 2.5 ms and a base tick of 5 ms. The plant then
steps at 2.5 ms, the IMU and the pitch-rate loop run at 200 Hz, the INS and
the attitude loop at 50 Hz, and the air data system with the altitude and
airspeed loops at 10 Hz. The rates this section quotes are those. The last
part of this section is `closed_loop`, the older model with two
controllers, which the tutorial's optional last chapter flies.

**The pitch hold**, `pitch_hold`. One PID reads the pitch angle `θ` and
commands the elevator, with `Kp = −2.0` and `Ki = −1.0`, under the root
inputs `θ_ref` and `δt`. The gains are negative because a positive
elevator pitches the nose down. The controller is the continuous `PID`, or
with `discrete = true` the `DiscretePID` at 50 Hz, the same law on the
discrete tier. At trim the error is zero, so the integral term alone
carries the elevator and starts at the trim value `δe`. It is the state
`x.q` of the `PID` and the store `s.q` of the `DiscretePID`.

The continuous loop linearizes from `θ_ref` at the trim ([§14.10][s14-10]).
The taps are the plant's `V`, `γ`, `θ` and `q` and the integral term. The
altitude is left out, since its pure integrator would make `A` singular.
The eigenvalues are

    −2.047 ± 8.064i     −1.392     −0.642     −0.052

and the DC gain from `θ_ref` to `θ` is 1. The fast pair is the short
period, moved from `ωn = 5.43 rad/s` and `ζ = 0.566` to `ωn = 8.32 rad/s`
and `ζ = 0.246`. The discrete loop refuses the same call. The discrete
tier holds the integral term and the reference the controller reads, so
each of the two taps comes back as a `TapResolution`. The loop is
therefore designed in continuous time and deployed in discrete time.

From the trim with the reference 0.05 rad above it, at 0.0699 rad, and
with the plant stepping at 5 ms, the
pitch angle peaks at 0.0799 rad under the continuous controller and at
0.0820 rad under the discrete one. The two responses stay within
0.0021 rad of each other.

**The actuators**, `actuators`. Each control passes through a discrete
`RateLimiter` and a continuous `FirstOrderLag`: the elevator at 1 rad/s and
50 ms, the throttle at 0.5 /s and 0.5 s. Their initial values are the trim's.
The limiters declare no rate and tick at the base tick. The group takes
`δe_cmd` and `δt_cmd` and publishes `δe` and `δt`.

**The sensing**, `sensing`. The cascade reads measurements, each a variable
of the plant plus Gaussian white noise, so the plots show sensors and not
states. There are three sensors, each a group: the IMU measures the pitch
rate `q`, the INS the pitch angle `θ`, and the air data system the altitude
`h` and the airspeed `V`. A sensor is configured to the rate of the loop it
feeds. Its group takes its multiplier, and the children inside take the
group's rate. `Measurement`, a stateless discrete leaf ([§3.2][s3-2]), adds
a noise to the measured signal and holds the sum between its ticks, and the
group publishes it with the suffix `_meas`. Each `GaussianWhiteNoise` ticks
with its sensor, has its own seed, and takes its strength as a two-sided
density through the keyword `noise_psd`:

| Measurement | Density | Per sample |
|---|---|---|
| `q` | 2.0e-8 rad² s⁻¹ | 0.002 rad/s at 200 Hz |
| `θ` | 5.0e-9 rad² s | 0.0005 rad at 50 Hz |
| `h` | 1.8e-3 m² s | 0.134 m at 10 Hz |
| `V` | 4.0e-5 m² s⁻¹ | 0.02 m/s at 10 Hz |

The altitude's density is that of 0.3 m per sample at 50 Hz, so the
sensor's band ends at its loop's Nyquist frequency. An air data system at
50 Hz read by loops at 10 Hz is decimated with no anti-aliasing. The
altitude loop then holds one 0.3 m sample for five of the sensor's periods,
and the late altitude error more than doubles. On the 50 m step described
below, with the late errors read once the transient is over:

| Air data and its loops | Late altitude error (m) | Late airspeed error (m/s) | Peak (m) |
|---|---|---|---|
| air data at 50 Hz, its loops at 10 Hz | 0.1693 | 0.0509 | 1050.141 |
| air data and its loops at 50 Hz | 0.0589 | 0.0191 | 1050.059 |
| air data and its loops at 10 Hz | 0.0795 | 0.0235 | 1050.063 |

**The cascade**, `cascade`. Four `DiscretePID`s, each with the hold
axis (`pid_anti_windup.md`, section 4), and each at the rate of the sensor
it reads:

| Loop | Rate | Reads | Commands | `Kp`, `Ki` | Limits |
|---|---|---|---|---|---|
| pitch rate | 200 Hz | `q_meas` | elevator | −0.2, −0.4 | ±0.5 rad |
| pitch attitude | 50 Hz | `θ_meas` | pitch rate | 2.0, 0.5 | ±0.5 rad/s |
| altitude | 10 Hz | `h_meas` | pitch attitude | 0.01, 0.001 | ±0.26 rad |
| airspeed | 10 Hz | `V_meas` | throttle | 0.2, 0.05 | 0 to 1 |

The signs follow `Cmδe < 0`: a positive elevator pitches down, so the
innermost gains are negative. The inner loop's crossover sits near the
short period's frequency, where `|24.5 Kp| ≈ 5 rad/s`, and each outer loop
is slower by a factor of three to ten, the usual spacing that lets each be
designed as if the loop inside it were ideal. The altitude loop closes
through `ḣ ≈ V γ`, so one metre of error asks for 0.01 rad of pitch and
the loop's bandwidth is about 0.5 rad/s.

Each PID's hold input is wired from the PID inside it: the attitude
loop reads the rate loop's `saturated` code and the altitude loop the
attitude loop's, so an outer integrator stops winding when the inner
command is on its limit. The two innermost PIDs read a constant zero code
and back-calculate against their own limits. The chain stays inside the
group: what crosses its boundary is the references, the measurements, the
flag `engaged`, and the two commands it publishes as `δe` and `δt`.

The chain works across the three rates. On the 50 m step the attitude loop
never reaches its limits. With those limits cut to ±0.05 rad/s it stays
limited for 1.76 s at the three rates, and for 1.92 s with every loop, the
IMU and the INS at 50 Hz and the air data still at 10 Hz, and nothing winds
or stalls. With no hold it stays limited for 2.14 s. The figure counts the
samples on the limit, and the sensors' noise knocks the command off the
limit and back. With every noise off the three read 2.20, 2.24 and 2.98 s.

`cascade(standby = true)` adds the tracking axis, with the tracking
reference of `pid_anti_windup.md` section 11, so that a cascade not in
command follows the command in force. The two innermost controllers track
the inputs `δe_track` and `δt_track`, which the group then also takes.
Each outer controller tracks the measured variable of the loop inside it,
pitch attitude for the altitude loop and pitch rate for the attitude loop.
Every `Tt` is 0.02 s, a time constant in seconds whatever the controller's
period. `autopilot` builds the cascade without its standby
and holds `engaged` true through a `Constant`.

**The initial conditions.** `cruise(solution)` is `autopilot`'s. It writes
the plant's trim pitch angle beside its level state and the root inputs at
the trim references, 1000 m and 50 m/s, and seeds the stores of three of
the four PIDs through `at` and `set(s = …)`. A `DiscretePID`'s store
is `(q, yf, saturated)`, the integral term, the derivative filter's state
and the clamp code, all zero by default. At trim every loop's error is
zero: `h_ref = h`, the attitude reference is the altitude loop's output,
which equals `θ`, the rate reference is the attitude loop's output, which
equals `q = 0`, and `V_ref = V`. With `b = 1` and `Kd = 0` the law
`u = Kp (b r − y) + q − Kd d` reduces to `u = q`, so a PID sits still only
if its integral term already holds the trim value of what it commands. The
altitude loop's is seeded at `θ`, the pitch-rate loop's at `δe` and the
airspeed loop's at `δt`; the attitude loop commands a pitch rate, zero at
trim, and keeps its default. Without the
seeds the rate loop would command zero elevator, the actuator would slew
away from the trim and the integrators would wind until they found it
again, a transient of many seconds. `yf` is set to its fixed point, the
measurement each PID reads, 1000 for the altitude loop, 0 for the rate
loop and 50 for the airspeed loop; with `Kd = 0` it never reaches the
output, and the seed only spares the filter the start-up jump that
`pid_anti_windup.md` section 9 lists. A store overlay merges onto `s_init`
([§14.3][s14-3]), so `cruise` names `q` and `yf` and leaves `saturated` at
its default. The loop then starts at rest at the trim: with the noise off
the altitude drifts by less than 3e-10 m over 60 s. `hand_flown(solution)`
is `piloted`'s, `cruise`'s with the pilot's commands at the trim and
`engage` false.

**The engage switch**, `selection`. A `Switch` per control selects the
cascade's command while the autopilot is engaged and the pilot's
otherwise. The pilot's commands `δe_pilot` and `δt_pilot` and the flag
`engage` are root inputs of `piloted`. The selected commands leave the
group twice, as they are for the actuators and one tick old through a
`UnitDelay` at the base tick as `δe_prev` and `δt_prev`, which the cascade's
`δe_track` and `δt_track` read. The cascade runs all the time. While the
pilot flies it tracks the pilot's commands, so at the engage every
integrator holds nearly the value that reproduces the current command.
Without the delays the tracking wires close an algebraic loop through each
switch, and the build refuses the model with two `AlgebraicCycle`
diagnostics, both real ([§13.8][s13-8]): the pitch-rate loop with the elevator's
switch, and the airspeed loop with the throttle's.

The flag is latched. One staged `engage` would otherwise reach the
continuous switches at the next frame, the pitch-rate loop at its next
200 Hz tick, the attitude loop at its next 50 Hz tick and the outer loops
at their next 10 Hz tick. Staged at 30 s, those are 30.0025, 30.005, 30.02
and 30.1 s. So `selection` holds `engage` in a `UnitDelay` at the air data
system's multiplier, the cascade's slowest rate. Each multiplier divides
that one, so a tick of the latch is a tick of every controller. The
switches read the
latch, and it leaves the group as the face `engaged` for the cascade, so
the switches and all four controllers act at the same tick. The cost is a
delay of up to two ticks of the slowest rate: an `engage` staged at 30 s
acts at 30.2 s.

**What the loops do.** The references, the pilot's commands and the flag
are root inputs, so the scenario belongs to the run, not to the model. The
testset stages each write while the simulation is stopped at the write's
nominal time. A staged batch applies at the top of the next frame, and a
discrete component reads it at its next tick.

Under `autopilot`, a 50 m step in the altitude reference, written in the
initial condition, is within 1 m by 24.3 s and peaks at 1050.06 m. The
airspeed strays from 50 m/s by up to 3.92 m/s, at 3.73 s. After 75 s the
altitude stays within 0.080 m of the reference and the airspeed within
0.024 m/s.

Under `piloted` the pilot holds the trim, pulls the elevator 0.02 rad
over `[5, 7)` s and engages the autopilot at 30 s. By hand the altitude
runs between 988.0 and 1016.7 m. Meanwhile the standby cascade stays
within 0.0048 rad of the pilot's elevator over `[8, 30)` s, and within
0.0255 of the throttle over `[5, 30)` s, whose loop ticks at 10 Hz and
reads the airspeed's noise through its `Kp`. At
30.2 s, when the latch engages the cascade, the selected elevator command
jumps by 0.00063 rad and the throttle command by 0.0106, which its rate
limiter passes in five ticks of 0.0025. Behind its actuator the elevator
moves by 3.1e-5 rad in the 2.5 ms after the switch. For scale, the
elevator command's largest change between two of its ticks
over `[80, 90)` s is 0.0024 rad. The autopilot then
recaptures 1000 m and holds it within 0.060 m over `[80, 90)` s.

The testset pins the eigenvalues, the DC gain, the refusal and the step of
the pitch hold. Under `autopilot` it pins the rest at the trim, that no
model from there on holds an anchor, the schedule's multipliers, the three
rates as the log shows them, the hold after 75 s, the peak, the airspeed
excursion, and each sensor's grid and noise. Under `piloted` it pins the
refused loop, the staged
writes, the standby gaps of the innermost and the outer loops, the instant
the latch moves the switches, the jumps and the recapture.

**The two-controller loop**, `closed_loop`. The tutorial's optional last
chapter flies the cascade beside an LQR tracker, with a switch between the
two. This model predates the functions above and wires its own groups,
`sensing`, `pid_controller`, `lqr_controller`, `selection` and `actuators`
beside the plant, under the root inputs `h_ref`, `V_ref` and `mode`.
Everything discrete in it runs at 50 Hz, each component on an anchor of
its own. Its `pid_controller` is the cascade above with its standby, at
that one rate and reading `θ`, `q` and `V` from the plant, and what crosses
that group's boundary is
the references, the measurements, the mode, the delayed commands it
tracks, and its two commands. Its `sensing` is a 50 Hz sensor, noise of
0.3 m per sample summed by the `altimeter` junction. `trimmed(solution)`
is its initial condition: `cruise`'s seeds with the full stores written,
and the cascade in command. The tracker carries `x_trim`, `u_trim` and
`z_trim` as parameters, so its integral state is zero at trim. The rest of
this section is about this model.

Every tracking time constant `Tt` is one period, 0.02 s, the tracker's
included. A controller not in command follows the selected command with a lag
that grows with `Tt` and with the rate at which its own law moves, so a
short `Tt` keeps the tracker, the altitude loop and the airspeed loop
within about 0.015 of the command once a maneuver's fast part is over,
and within a few hundredths during it, past the first tenth of a second
after a reference step. The pitch-rate
and attitude loops, whose references move with the measured state, sit a
few hundredths of a radian off however short `Tt` is. A controller in command
back-calculates against its limits, and at one period each tick closes
`1 − e⁻¹`, about two thirds, of a limited integrator's excess.

**The LQR tracker**, `lqr_controller`. A `DiscreteLQRTracker` over the full
state `x = (V, γ, θ, q, h)` commanding both controls, with the command vector
`z = (h, V)`, designed by `lqr_tracker.md`'s sections 2 and 3. The group
packs the state, the measurement and the reference vectors from the scalar
faces it takes, unpacks the command into `δe` and `δt`, and negates `mode`
into the tracker's `engaged` vector, so the tracker's vector shape never
crosses a boundary. The state is
augmented with the integrals of both command errors, and the gain comes
from `ControlSystemsBase`'s `lqr` with diagonal weights by Bryson's rule, an
acceptable excursion per state and per input:

    V: 5 m/s     γ, θ: 0.05 rad     q: 0.2 rad/s     h: 20 m
    ∫h: 100 m s     ∫V: 25 m     δe: 0.2 rad     δt: 0.3

`K_fbk` is the state half of the augmented gain, `K_int` the integral
half, and `K_fwd = M_22 + K_fbk M_12` with the two blocks read off the
inverse of the full `[A B; C D]`; the Schur-complement form of section 2
needs `A⁻¹`, which the zero altitude eigenvalue denies. The trim triple is
the linearization's operating point. The tracker's own limits are those of
the cascade's innermost loops, ±0.5 rad on the elevator and 0 to 1 on the
throttle, and its hold input reads a zero code.

**Its selection and the bumpless switch.** A `Switch` per
control selects the cascade's command while the root input `mode` holds, and
the tracker's otherwise. Both controllers run all the time, and the one not
in command tracks the one that is (`pid_anti_windup.md`, section 11): `mode`
is the cascade's `engaged` input and, negated, the tracker's, and the selected
commands leave the group twice, as they are for the actuators and one tick
old through a `UnitDelay` as `δe_prev` and `δt_prev`, which each innermost
PID of the cascade and the tracker read as their tracking input. The two
outer loops of the cascade track the measured variable of the loop inside
them, pitch attitude for the altitude loop and pitch rate for the attitude
loop, so when the cascade is re-engaged every integrator holds nearly the
value that reproduces the current command.

The switch is bumpless in steady flight. During a maneuver the standby lags
the command by a few hundredths of a radian at one period, more while the
command slews fast. With the cascade in command, the
standby tracker stays within about 0.034 rad of the elevator command over
the climb after its first half second. It peaks at 0.43 rad right after
the reference step, since the step moves the tracker's own law in one
tick, is back under 0.1 rad within 60 ms, its third tick after the step,
and sits within 0.015 rad after
`t = 10 s`. At a switch to the tracker at 60 s, in steady flight, the
elevator's largest frame-to-frame change is 3.45e-4, below the 5.05e-4 of
jitter the altitude noise induces in steady cascade flight. At a switch at
10 s, mid-climb, the command jumps by 1.1e-2 and the actuator, behind its
rate limit, by 1.5e-3. A hand-back to the cascade at 10 s, once the
pull-up is over, jumps the command by 2.3e-3. Handed back during the
pull-up itself, at 7 s, the command would jump by about 0.09 rad, the
standby having sat 0.15 rad behind a command slewing at up to about
4 rad/s, and the actuator's rate limit would take about a tenth of a
second to catch up.

**What this loop does.** The references and the mode are root inputs, so the
scenario belongs to the run, not to the model: the testset's helper steps the
simulation to one frame before 5 s, stages `h_ref` at 1050 m, steps on to one
frame before the switch time if there is one, stages `mode`, and runs to
120 s. A staged batch applies at the top of the next frame, and the ticks at a
boundary settle in the frame that reaches it, so staging one frame before a
tick is what puts the write on that tick. From trim, a 50 m
step in the altitude reference at
`t = 5 s` is held within 0.1 m by `t = 80 s` by either controller, the
cascade with no overshoot and the tracker with about 2 m. During the climb
the airspeed strays from 50 m/s by up to about 4 m/s under the cascade and
about 1 m/s under the tracker, and after `t = 80 s` it stays within
0.02 m/s. The testset pins the hold after `t = 80 s`, the two peaks, the
equilibrium at trim, the standby's tracking during the climb, the jumps at
the two switches and at the hand-back, and the sensor noise.

## 5. The approach and the touchdown

`approach` nests `piloted` whole as the child `vehicle` and adds the
ground and a stop request, under the same five root inputs. Its flight
begins as section 4's, by hand and then engaged, and is the same to the
bit over the first 60 s. From there the run lowers the altitude reference
by 0.15 m every 0.1 s, one write per tick of the altitude loop. That is a
sink rate of 1.5 m/s at 50 m/s, a glide angle of
`sin γ = −1.5 / 50 = −0.03`. The reference is a root input, so the run
stages the descent and the model carries no ramp. The cascade follows the
descending reference within 0.26 m from 160 s to the last second, and the
airspeed stays between 49.969 and 50.029 m/s over the same span. No loop
saturates. There is no flare: the aircraft meets the ground at
`γ = −0.0303`, after 726.6 s.

The ground is a `GroundContact` leaf wired from the vehicle's altitude,
which `piloted` exports as the face `h`. Its
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

The same flight is the subject of the replay and of the checkpoint.
Replayed from its trace on a fresh simulation ([§12.7][s12-7]), the whole flight
comes back to the bit and stops at the same instant. A checkpoint taken at
60 s, the top of the descent, restores into a fresh simulation ([§12.6][s12-6]).
Flown from there at 2 m/s it touches down at 560.0 s, and flown at 1.5 m/s
again it gives the first touchdown to the bit. A checkpoint is checked
against its deployment, so one taken on `piloted` alone is refused here as
`CheckpointMismatch`. That is why the checkpoint is taken on this model.

<!-- citation link definitions — generated by tools/linkify.jl; do not edit -->
[d-208]: ../log.md#d-208--root-inputs-are-the-root-components-input-faces-whatever-its-class
[s10-4]: ../spec.md#104-localization-mechanics
[s12-6]: ../spec.md#126-run-lifecycle-and-partial-advance
[s12-7]: ../spec.md#127-replay-the-trace-re-drives-the-ordinary-loop
[s13-5]: ../spec.md#135-termination-is-a-state-not-an-exception
[s13-7]: ../spec.md#137-tooling-consequences-face-routes-and-the-component-library
[s13-8]: ../spec.md#138-cycle-diagnosis-feedthrough-tracing
[s14-10]: ../spec.md#1410-linearization-tap-selectors-one-seeded-pass-a-pure-query
[s14-3]: ../spec.md#143-resolution-flatten-validate-compile-once
[s14-7]: ../spec.md#147-the-trim-problem-namedtuple-decisions-declared-reads-named-residuals
[s14-8]: ../spec.md#148-the-trim-service-solver-seam-scratch-stores-commit-and-report
[s2-3]: ../spec.md#23-events-two-detection-policies
[s3-2]: ../spec.md#32-periodic-discrete-component
[s6-3]: ../spec.md#63-rates-down-the-hierarchy
[s8-7]: ../spec.md#87-rate-scopes
[s9-2]: ../spec.md#92-the-build-and-deployment-artifacts
