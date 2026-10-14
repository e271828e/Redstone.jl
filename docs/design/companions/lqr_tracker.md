# The LQR tracker: the law, the cascade and the two tiers

*A companion record, not normative text. The ground truth is `spec.md`
[§13.7][s13-7] (the library), [§5.3][s5-3] and [§5.4][s5-4] (feedthrough and artificial loops), [§7.3][s7-3]
(the discrete store), [§14.8][s14-8] (trim) and [§14.10][s14-10] (linearization), with decisions
[D-313][d-313] and [D-383][d-383]. If this document and the spec ever disagree, the spec wins.
It was written on 2026-10-14, when the tracker was admitted to the library,
to keep the derivation the block implements, the cascade architecture it
serves, and the reasoning that chose what the block carries and what it
leaves to the design script.*

The block descends from the `LQR` model of Flight.jl's FlightPhysics and the
notes written for it. The law is the same. What the framework replaces is
everything around the law: how the gains reach the block, how a controller
not in command stays ready, and how saturation is reported up a cascade.
Section 1 states the problem, section 2 the equilibrium reference and the
feedforward, section 3 the integral action, section 4 the law the block
implements and its ports, section 5 what FlightPhysics did and what the
framework does instead, section 6 the saturation code and the cascade,
section 7 the standby axis and the switchover wiring with the probe's
numbers, section 8 what stays in the design script, and section 9 the
decision.

## 1. The problem

A nonlinear plant `ẋ = f(x, u)` publishes outputs, and a designer picks a
subset `z = h(x, u)` to command, the *command variables*. For an aircraft `z`
might be airspeed and altitude, or the two control commands themselves when
the tracker is a stability augmentation loop. The goal is to drive `z` to a
reference `z_ref` near a trim point `(x_trim, u_trim)`, where
`f(x_trim, u_trim) = 0` and `z_trim = h(x_trim, u_trim)`.

A *linear quadratic regulator* (LQR) is the state feedback `Δu = -K Δx` that
minimizes a quadratic cost in the state and the input of the linearized
plant. Its gain `K` comes from a Riccati equation, and the closed loop
`A - B K` it leaves is asymptotically stable. A regulator drives the state to
zero. A *tracker* drives `z` to a nonzero reference, which needs an
equilibrium to regulate about and a feedforward to reach it.

## 2. The equilibrium reference and the feedforward

Linearizing about the trim point gives

```
Δẋ = A Δx + B Δu
Δz = C Δx + D Δu
```

with `Δx = x - x_trim`, `Δu = u - u_trim` and `Δz = z - z_trim`. The target
is `Δz* = z_ref - z_trim`. The equilibrium `(Δx*, Δu*)` that holds it solves

```
[ A  B ] [ Δx* ]   [ 0   ]
[ C  D ] [ Δu* ] = [ Δz* ]
```

The matrix is `(n_x + n_z) × (n_x + n_u)`, so it is square only when
`n_z = n_u`, one command per control input. That is the case the block is
designed for. With fewer commands than inputs the equilibrium is
underdetermined, a minimum-norm choice through a pseudo-inverse is one
design decision among several, and the block takes no part in it. With the
matrix square, it is invertible when `A` and the Schur complement
`S = D - C A⁻¹ B` are, and the blocks of the inverse that matter are

```
M_22 = S⁻¹            Δu* = M_22 Δz*
M_12 = -A⁻¹ B M_22    Δx* = M_12 Δz*
```

These are the `Nu` and `Nx` of Franklin, Powell and Emami-Naeini's reference
input with full state feedback, [§7.4][s7-4] of *Feedback Control of Dynamic
Systems*. The sign of `M_12` follows from `0 = A Δx* + B Δu*`; the
FlightPhysics notes drop it, and their design script is unaffected because
it inverts the whole matrix numerically.

Regulating about the equilibrium, `Δu - Δu* = -K (Δx - Δx*)`, and
substituting the two blocks gives the law

```
Δu = K_fwd Δz* - K_fbk Δx        K_fwd = M_22 + K M_12,   K_fbk = K
u  = u_trim + K_fwd (z_ref - z_trim) - K_fbk (x - x_trim)
```

Because the closed loop is stable, `Δx` converges to `Δx*`, and at that
point `Δz = Δz*` on the linear model. On the plant the model error leaves a
steady offset, which is what section 3 removes.

## 3. Integral action

For the subset `z_i` of the commands that must settle with zero error, the
state is augmented with the integral of their error, `ξ̇ = z_i - z_i*`, and
the LQR is designed for the augmented plant

```
A_aug = [ A    0 ]      B_aug = [ B   ]      K_aug = [ K_x  K_ξ ]
        [ C_i  0 ]              [ D_i ]
```

MATLAB's `lqi` is this design, one integrator per tracked output. The law
becomes `u = u_trim + K_fwd Δz* - K_x Δx - K_ξ ξ` with
`K_fwd = M_22 + K_x M_12`, and a disturbance that shifts the equilibrium is
absorbed by `ξ`, since the stable closed loop still forces `ξ̇ = 0`.

The block does not integrate `ξ`. It moves `K_ξ` inside the integral,

```
u_int = -∫ K_ξ (z_i - z_i*) dτ = ∫ K_int (z_ref - z) dτ
```

where `K_int` is `n_u × n_z`, its columns zero for the commands that are not
integrated and taken from `-K_ξ` for those that are. The integrator is then
`n_u` wide, one channel per control input, which buys two things. Saturation
is handled per input, since each channel's windup is its own. And the
integral is held in output units, so a scheduled `K_int` changes only future
accumulation and never jumps the command, the grouping `pid_anti_windup.md`
section 4 chose for the PID's `Ki`. That matters more here than for the PID,
since every tracker of the C172 is scheduled over airspeed and altitude.

## 4. The law the block implements

Two blocks over one supertype, `LQRTrackerBlock{NX, NU, NZ, Hold, Track,
Standby, Fixed}`, mirror `PIDBlock`: `LQRTracker` on the continuous tier and
`DiscreteLQRTracker` on the discrete one. The law, on both:

```
u_raw = u_trim + K_fwd (z_ref - z_trim) - K_fbk (x - x_trim) + q
u     = clamp(u_raw, u_min, u_max)
q̇     = gate(K_int (z_ref - z)) + (ref - u_raw) / Tt            continuous
q⁺    = q + Δt gate(K_int (z_ref - z)) + β (ref - u_raw)         discrete
```

with `β = 1 - exp(-Δt / Tt)`, `Δt` the component's own period ([§10.5][s10-5]). The
integrator input `K_int (z_ref - z)` is `n_u` wide, so the PID's gate and
reference rule apply to it channel by channel, over the same three axes
(`pid_anti_windup.md`, sections 4 and 11):

- **hold** adds the input `saturation`, an `SVector{NU, Int8}` code from the
  path downstream, and gates each channel whose code agrees with the sign of
  its integrator input;
- **tracking** adds the input `v`, an `SVector{NU, Float64}`, as the
  correction's reference, with the hold's fallback to own `u` while the code
  is zero;
- **standby** adds the `Bool` input `engaged`, and `v` where tracking has not
  already added it. While not engaged the integrator input is zero and the
  reference is `v` whatever the code, so `u_raw` converges to `v` at rate
  `1/Tt` and engagement is bumpless.

Own windup goes through the correction against the block's own fresh `u`
with `Tt`, as for the PID; `Tt = Inf` switches it off and `Tt = 0` is the
clamping scheme on the discrete tier. The signal ports are `x` at
`SVector{NX, Float64}` and `z` and `z_ref` at `SVector{NZ, Float64}`, the
FlightPhysics names, because `z` is a chosen command subset and not the
measurement the PID's `y` names. The outputs `u` and `u_raw` come from stage
2 at `SVector{NU, Float64}`, and the discrete block adds `saturated` from
stage 1 (section 6).

The nine parameters are the roster `K_fbk` (`NU × NX`), `K_fwd` and `K_int`
(`NU × NZ`), `x_trim`, `u_trim`, `z_trim`, and `Tt`, `u_min` and `u_max` per
channel, broadcast to `SVector{NU}` from a scalar. Any of them may be an
input port in place of a field by `AsPort()`, the PID's rule, which is how a
gain schedule reaches the block. The matrices are static with their length
parameters, the trap `linear_blocks.md` section 4 records; a field declared
`SMatrix{NU, NX, Float64}` is abstract and boxes at every sweep.

`u` is a stage-2 output, so every input is a feedthrough edge whether
`y_direct` reads it or not ([§5.4][s5-4]). The state vector `x` is assembled from
quantities the plant publishes from state, a `Pack` or a user leaf over the
plant's outputs, and `z` is often a selection of the same, so neither closes
a loop. A `v` or a `z_ref` wired through a memoryless function of the own
`u` does, and the refusal is the PID's.

## 5. What FlightPhysics did, and what the framework does instead

The FlightPhysics `LQR` model implements section 3's law on the discrete
tier with conditional integration. Four mechanisms around it do not
transfer, and each has a counterpart the library already ships.

- **Parameters assigned by a lookup every tick.** The gains and the trim
  triple were mutable fields, overwritten from an interpolation table before
  each step. Here parameters are instance data, and a scheduled one is a
  port fed by an ordinary upstream component publishing `SMatrix` values. A
  linearization then sees the coupling through the schedule, which the
  overwritten version could not show, and a model that wants the schedule
  frozen at its nominal value routes the port through `Freeze` ([§14.10][s14-10]).
- **A reset on every mode change.** FlightPhysics re-initialized the
  incoming tracker's integrator and bumped the outer PIDs' integrators by
  hand, inside the control law's sequencing. The standby axis replaces both:
  a block not in command follows the selected command through `v`, so it is
  ready when engaged, with no reset and no sequencing (section 7).
- **A halt against the block's own previous code.** The integrator stopped
  when its input pushed further into the block's own saturation, read from
  the previous tick. Here the own clamp is handled by back-calculation
  against the fresh `u`, and the halt survives as the hold's gate against an
  external code.
- **A saturation output read by the outer loops.** Kept, on the discrete
  tier, in the form section 6 gives.

## 6. The saturation code and the cascade

The C172's longitudinal and lateral control laws are cascades: in each
mode one or more PIDs command a reference to an inner tracker, and the
tracker reports its saturation to every PID above it, so that an outer
integrator pushing a channel further into its limit stops. The outer loops
need the fact "the inner command saturated", known at the inner block at the
tick it happens. The actuator model downstream reports a position limit,
which coincides with the command's only because the tracker's clamp copies
the actuator's range, and only when the actuator is a moded block that
publishes a code at all.

**Tracking alone does not replace the code.** An outer block could follow
the achieved value instead, through `v`. Following the actuator position
couples the outer integrator to the actuator lag during every free
transient, the `Tt` squeeze of `pid_anti_windup.md` section 3, and that
companion's cascade table ranks tracking alone as the weakest variant and
hold with tracking as the best. Following the inner block's `u` meets a
second problem: `u` is stage 2, so the outer `u` to the inner `z_ref` and the
inner `u` back to the outer `v` is an algebraic cycle, classified real on the
discrete tier, and a `UnitDelay` has to break it.

**The discrete tier makes the FlightPhysics mechanism legitimate.** The
objection to a code from a clamp is that it flips inside a step, a mode made
silently ([§2.3][s2-3]). On the discrete tier the code lives in the store: `s_update`
writes it from `u_raw` against the limits, the `Int8` code `saturation_code`
produces for the limited integrators, and `y_state` publishes it as
`saturated` at the next tick. The name is apart from the hold's input
`saturation` because a root's input and output faces share one name space
([§8.6][s8-6], [D-210][d-210]), and one name on both would refuse the block alone as a
root ([D-384][d-384]). It flips only on a tick boundary, which the gate's doctrine asks for,
and its publication from stage 1 breaks the cascade cycle structurally. The
code is one tick stale, as FlightPhysics's was, so an outer integrator takes
one extra step before the hold engages. The block itself never reads its
own code; its own windup is the correction's. `DiscretePID` publishes the
same code, so a PID commanding a PID has the same story.

**The continuous block publishes no code.** A continuous code would need a
mode and hit and leave events per channel, the `LimitedIntegrator` pattern
at `4N` events and a localization per crossing, for a consumer that does
not exist: the continuous block's use is to close the loop in the continuous
domain so `linearize` recovers the designed closed loop. Guards may read `y`,
so the moded variant is feasible if a continuous cascade ever wants it.

**The precedents.** A signed limit status reported up a cascade is standard
practice in two unrelated industries. Foundation Fieldbus's PID function
block carries a limit status on `BKCAL_OUT` to the upstream block's
`BKCAL_IN`, which limits the upstream reset contribution when the downstream
block cannot act, and DeltaV names the option "Dynamic Reset Limit". PX4's
control allocator publishes a per-actuator `int8` saturation status with
signed arms, and its rate controller stops integrating per axis in the
direction of the saturation; ArduPilot's `AC_PID` takes a `limit` flag and
integrates only when the update would reduce the integrator. Simulink's PID
block has no such input, and its tracking port pays the coupling the hold
avoids.

An outer PID over one channel takes its code through `Unpack{Int8, NU}`,
one `Int8` per component.

## 7. The standby axis and the switchover wiring

`pid_anti_windup.md` section 11 records why the hold and tracking axes could
not express a controller that holds on the inner code while in command and
follows the selected command while not, and the standby axis that does. The
trackers need it as the PIDs do: the C172 switches among three longitudinal
trackers, and the two not in command follow the selected command through
`v`.

**The wiring.** Sibling controllers feed a `Switch` selected by the mode,
and the selected command goes down to the plant and back to every sibling's
`v`. The `Switch` reads both inputs in `y_direct`, so structurally its output
depends on each input, and sibling 1's `u` reaches the `Switch` and the
`Switch` output reaches sibling 1's `v`, a cycle through sibling 1 itself.
The remedy is a `UnitDelay` on the `Switch` output, fanned to every `v`. A
block in standby then follows the selected command one tick old, and a block
engaged sees its own one-tick-old output as `v`, which standby's engaged arm
ignores unless a hold with a nonzero code selects it.

**The probe.** On 2026-10-14, before the brief, the wiring was built from
shipped blocks against the tree at 53f35d0: two `DiscretePID`s with
`tracking = true`, a `Switch` on a root input `mode`, a `DiscreteIntegrator`
plant, at `h = 1//100`. The standby law was emulated with `Ki = AsPort()`
fed zero while not in command, since the shipped tracking variant has no
`engaged` port.

| probe | result |
|---|---|
| discrete siblings, `v` from the `Switch` output | `AlgebraicCycle`, classification `:real` |
| the same through a `UnitDelay` | builds |
| continuous siblings, `v` from the `Switch` output | `AlgebraicCycle`, classification `:artificial` |
| the same through a `UnitDelay` | builds |
| the engaged sibling tracking its own one-tick-old output, against a plain PID, over 4 s | plant outputs within `0.021` on a response of about `6` |
| switchover after 2 s with the other sibling in command, plain siblings | bump `4.76` |
| the same, tracking always, `Tt = 1` | bump `1.92` |
| the same, `Ki` zero while not in command, `Tt = 1` | bump `0.70` |
| the same, `Ki` zero while not in command, `Tt = 0.1` | bump `0.002` |

Two lessons beyond the classifications. Tracking without the error gated
off leaves `u_raw = v + Tt Ki e` in standby, which is most of the `1.92`.
And a standby block chases a moving target with lag `Tt`, since its `v` and
its own proportional term both move while the other block flies the plant,
so the standby `Tt` should be short. On the discrete tier `Tt = 0` follows
exactly, the FlightPhysics reset applied every tick, and `Tt = Inf` follows
nothing, which is why a fixed infinite `Tt` is refused with `standby = true`
([D-383][d-383]). The emulation's `Tt = 0` row is not reported: with the shipped
variant the block in command tracked itself at `β = 1`, which the standby
law's engaged arm rules out.

## 8. What stays in the design script

The block takes designed gains, as `StateSpace` takes matrices. `trim!`
finds the trim point and `linearize` returns the `Linearization`, whose
`x₀`, `u₀` and `y₀` under their tap labels are `x_trim`, `u_trim` and
`z_trim`, and whose `A`, `B`, `C` and `D` feed section 2's inverse and the
Riccati solve, `lqr` in ControlSystemsBase. `K_fwd` needs the inverse alone,
and it stays outside the block with the rest: a helper reading a
`Linearization` is a design-script convenience, not library material, and
the Riccati solve brings a dependency the package does not want. The tap
labels are the user's bookkeeping; the model packs `x` in the same order.

The acceptance tests follow. The continuous block closing the loop on a
`StateSpace` plant linearizes to `A - B K_fbk`. Without integral action and
with section 2's feedforward, a step in `z_ref` settles with zero error on
the linear plant. With `K_int` from section 3's augmented design, the closed
loop agrees with the augmented one. These are numeric agreements with the
textbook procedures, and the block's novelty is deliberately none.

## 9. The decision

[D-383][d-383] admits the two blocks under [D-313][d-313]'s guidelines and rules the four
points this companion argues: the gains come from outside, the saturation
code is published on the discrete tier alone from stage 1 off the store, the
standby axis joins the PID's two on all four controller blocks, and the
ports keep the FlightPhysics names. Against the guidelines, the tracker is
domain-agnostic, it is the one block that shows the trim and linearize
pipeline closing on itself, its matrices and its per-channel windup are
easy to get wrong, and the C172 hand-writes it five times. It is not
composable from the library: the integral path is an `n_z → n_u` matrix map,
and the vector PID's `Ki` is componentwise.

<!-- citation link definitions — generated by tools/linkify.jl; do not edit -->
[d-210]: ../decisions.md#d-210--tighten-the-input-boundary-class-uniform-face-uniqueness-and-no-empty-routing
[d-313]: ../decisions.md#d-313--admit-a-library-block-by-judgement-against-three-guidelines
[d-383]: ../decisions.md#d-383--admit-the-lqr-tracker-with-a-standby-axis-and-a-discrete-saturation-code-on-the-controller-blocks
[d-384]: ../decisions.md#d-384--publish-the-discrete-controllers-saturation-code-as-saturated
[s10-5]: ../spec.md#105-multi-rate-tick-scheduling
[s13-7]: ../spec.md#137-tooling-consequences-face-routes-and-the-component-library
[s14-10]: ../spec.md#1410-linearization-tap-selectors-one-seeded-pass-a-pure-query
[s14-8]: ../spec.md#148-the-trim-service-solver-seam-scratch-stores-commit-and-report
[s2-3]: ../spec.md#23-events-two-detection-policies
[s5-3]: ../spec.md#53-structural-feedthrough-stage-roles-execution-order-and-step-boundaries
[s5-4]: ../spec.md#54-artificial-loops-and-the-escape-hatch
[s7-3]: ../spec.md#73-discrete-state-modes-and-workspace
[s7-4]: ../spec.md#74-the-computerintegrator-split
[s8-6]: ../spec.md#86-paths-wiring-and-faces
