# A model at a `Dual`: sensitivities along a trajectory

*A companion explainer, not normative text. The ground truth is `spec.md`
[§9.2][s9-2] (the `Model` at another scalar and what it computes across frames), [§9.4][s9-4]
(the executable set of a `Dual` activation), [§8.2][s8-2] (where partials enter),
[§10.2][s10-2] (the step sequence under a `Dual`) and [§14.10][s14-10] (the sampled-data
extension), with decisions [D-317][d-317] (the public model at another scalar), [D-481][d-481]
(its `init!`) and [D-461][d-461] (the error norm). If this document and the spec ever
disagree, the spec wins. It was written on 2026-11-26, after the increment
that made `init!` establish the frozen cells at a `Dual`, to record what a
user can do with such a model and where it stops. Every number below is the
output of `design/prototypes/dual_model_uses.jl`.*

`trim!` and `linearize` differentiate the model at one instant. They build
their own `Dual` scratch, and the caller never sees it. This note is about
the other route. A user materializes a `Model` at a `Dual`, seeds it through
`init!`, steps it with `frame!`, and reads the partials of a whole
trajectory. Sections 1 to 3 work one model through. Section 4 lists further
uses as sketches. Sections 5 and 6 show the limit and how to check a run
against it.

## 1. What the model computes

Three facts set the scope.

**Partials enter through the condition.** At a `Dual`, a state leaf and a
root input follow the scalar, so `init!` accepts a seeded value at either
([§8.2][s8-2]). A component's constructor fields are constants. A parameter that is
to be differentiated has to be a root input.

**Only the continuous side runs.** The executable set at a `Dual` is the
continuous output stages, `x_deriv` and `x_projection` ([§9.4][s9-4]). No discrete
stage runs, no tick runs, and no event fires. `init!` establishes each
discrete output once, from the authored state ([D-481][d-481]). The model then
integrates the continuous dynamics with those outputs held ([§9.2][s9-2]).

**The steps are the nominal model's.** An adaptive method's error norm reads
the values alone ([§10.2][s10-2], [D-461][d-461]). The `Dual` model takes the steps its
`Float64` twin takes, and the partials differentiate that fixed sequence of
steps. They are the exact derivatives of the trajectory the simulation
computes, which is the stepper's approximation of the flow.

## 2. A worked run

The model is one pendulum under a torque, the torque a root input:

```julia
struct Pendulum <: AbstractComponent end
x_init(::Pendulum) = (θ = 0.0, ω = 0.0)
u_types(::Pendulum) = (u = Float64,)
y_types(::Pendulum) = (θ = Float64, ω = Float64)
y_state(::Pendulum, (; x)) = (θ = x.θ, ω = x.ω)
x_deriv(::Pendulum, (; x, u)) = (θ = x.ω, ω = -9.81 * sin(x.θ) - 0.5 * x.ω + u.u)

open_loop() = Group((; c = Pendulum()); input_wires = ("τ" => "c/u",))
```

Three directions are seeded, one each for $\theta_0$, $\omega_0$ and $\tau$.
The model then runs 100 frames of 10 ms:

```julia
const D = ForwardDiff.Dual{UsesTag,Float64,3}
seed(v, k) = D(v, ForwardDiff.Partials(ntuple(i -> Float64(i == k), 3)))
point(θ, ω, τ) = combine(at("c", set(x = (θ = θ, ω = ω))), set(u = (τ = τ,)))

dual = Model(open_loop(), D; Δt_frame = 1//100)
init!(dual, point(seed(1.0, 1), seed(0.0, 2), seed(0.5, 3)))
for k in 1:100
    frame!(dual, k)
end
state(dual, "c")      # θ and ω at t = 1, each a D
```

`UsesTag` is an empty struct. The later snippets use two helpers of the
script, `values_of` and `jacobian_of`, which take the value parts and the
partials of a state as a vector and a matrix.

The value parts are the state at $t = 1$, and the partials are its Jacobian
to the three seeds:

$$x(1) = \begin{pmatrix} -0.649141 \\ -0.375628 \end{pmatrix}, \qquad
\frac{\partial x(1)}{\partial(\theta_0, \omega_0, \tau)} =
\begin{pmatrix} -0.652595 & 0.048438 & 0.194154 \\
                -1.02409 & -0.853401 & 0.0516062 \end{pmatrix}$$

The first two columns are the state transition matrix $\Phi(1, 0)$. The third
is the response of the final state to a constant torque. The script checks
the result three ways.

- **The twin.** A `Float64` model takes the same `init!` and the same frames.
  The `Dual` model's values equal its state at all 100 frame tops, bit for
  bit.
- **Finite differences.** Central differences of the `Float64` run, with a
  step of `1e-6` on each seed, match every entry to `3.9e-10`.
- **Liouville's formula.** The pendulum's Jacobian has the constant trace
  $-0.5$, so $\det \Phi(1, 0) = e^{-0.5} = 0.606530660$. The partials give
  $0.606530668$. The gap is the stepper's error over the second, not the
  differentiation's.

## 3. One period: the discretized plant

Run one frame from a seeded point. The partials of the state at the frame's
end are $[A_d \;\; B_d]$, the discretization of the plant over one period
under a held input. The usual route to the same matrices is `linearize` and
a matrix exponential:

```julia
model = Model(open_loop(), D; Δt_frame = 1//50)
init!(model, point(seed(θ, 1), seed(ω, 2), seed(τ, 3)))
frame!(model, 1)
flow = jacobian_of(state(model, "c"))             # [A_d  B_d], from the flow

lin = linearize(Model(open_loop(); Δt_frame = 1//50), tap_set; about = point(θ, ω, τ))
held = exp([lin.A lin.B; zeros(1, 3)] / 50)[1:2, :]   # the instant's A and B, exponentiated
```

The two agree at an equilibrium and differ away from one:

| point $(\theta, \omega, \tau)$ | largest difference between `flow` and `held` |
|---|---|
| at rest, $(0, 0, 0)$ | `2.3e-08` |
| in motion, $(1, 2, 0.5)$ | `3.2e-03` |

At rest the trajectory stays at the point, so the Jacobian of the flow is the
exponential of the Jacobian there. The `2.3e-08` left is the integration
error of one frame. In motion the state travels during the period, and $A$
changes along the way. The exponential freezes $A$ at the start of the
period. The `Dual` model differentiates the frame as it was integrated, so
`flow` is the exact Jacobian of the step the simulation takes.

The stretch up to the next tick is also the horizon over which a sampled law
in the loop does no harm, since the real system holds its discrete outputs
between ticks too (section 5).

## 4. Other uses

None of the sketches in this section was run. Each needs only the doors
sections 2 and 3 already use.

**The state transition matrix over a horizon.** Seed every state leaf and
step to $T$, as section 2 does. Three consumers read $\Phi(T, 0)$.

- Floquet analysis of a periodic orbit. With $T$ the period, the eigenvalues
  of $\Phi(T, 0)$ are the orbit's multipliers. The orbit is stable when they
  lie inside the unit circle, the unit multiplier of an unforced orbit
  aside.
- Linear covariance analysis. A dispersion $P_0$ on the initial state
  arrives as $\Phi P_0 \Phi^\top$, from one run in place of a Monte Carlo
  campaign.
- The prediction step of an extended Kalman filter built against the same
  model, which needs the Jacobian of the state across one filter period.

**Shooting.** A periodic operating point solves $x(T; x_0) - x_0 = 0$.
`trim!` cannot pose it, since its residuals read one instant. Newton's
iteration on the shooting residual needs $\Phi(T, 0) - I$, which one `Dual`
run gives together with the residual:

```julia
init!(dual, at("c", set(x = (θ = seed(x0[1], 1), ω = seed(x0[2], 2)))))
for k in 1:n_frames
    frame!(dual, k)
end
xT = state(dual, "c")
r = values_of(xT) - x0                # the residual
J = jacobian_of(xT)[:, 1:2] - I       # its Jacobian
x0 -= J \ r
```

The same loop solves a two-point boundary value problem, with the residual
read at the far end.

**Output-error identification.** Gauss–Newton on measured data needs
$\partial y(t_k)/\partial\theta$ at every sample, for the unknown parameters
$\theta$. Feed the parameters as root inputs, seed one direction each, and
read the partials of the measured outputs at each frame top with `port`.

**Second order.** The `Model` constructor accepts a `Dual` over a `Dual` at
any depth ([D-320][d-320]). A nested seed gives the Hessian of a terminal cost for a
Newton optimizer. It also gives the derivative of a Jacobian to a parameter,
which is what a gain schedule interpolates.

## 5. The limit, shown

Close the loop around the pendulum with a sampled proportional law:

```julia
struct SampledGain <: AbstractComponent
    k::Float64
end
s_init(::SampledGain) = nothing            # declares the discrete tier
u_types(::SampledGain) = (θ = Float64,)
y_types(::SampledGain) = (u = Float64,)
y_direct(c::SampledGain, (; u)) = (u = -c.k * u.θ,)

closed_loop() = Group((; c = Pendulum(), ctl = SampledGain(4.0));
                      local_wires = ("c/θ" => "ctl/θ", "ctl/u" => "c/u"))
```

Both models start from $\theta_0 = 0.5$ at rest and run frames of 20 ms, the
law ticking once a frame. After `init!` both hold $u = -2$, which [D-481][d-481]
establishes at the `Dual`. Then:

| frame | $\theta$ nominal | $\theta$ at the `Dual` | difference | $u$ nominal | $u$ at the `Dual` |
|---|---|---|---|---|---|
| 1 | 0.498664209489 | 0.498664209489 | 0 | −1.99466 | −2.00 |
| 2 | 0.494680216246 | 0.494679151475 | −1.1e-06 | −1.97872 | −2.00 |
| 3 | 0.488092283941 | 0.488084866974 | −7.4e-06 | −1.95237 | −2.00 |
| 5 | 0.467345056714 | 0.467271737264 | −7.3e-05 | −1.86938 | −2.00 |
| 10 | 0.375374727201 | 0.373999943494 | −1.4e-03 | −1.50150 | −2.00 |
| 50 | −0.354446401270 | −0.767817488870 | −4.1e-01 | 1.41779 | −2.00 |

The first frame is identical. At its end the nominal model runs the law's
tick and the torque moves. The `Dual` model runs no tick, so it integrates
the second frame under the old torque, and the two part from there. Nothing
reports it ([§9.2][s9-2]).

The `Dual` model is not wrong about what it computes. Its values equal, bit
for bit at every frame, those of the open-loop pendulum of section 2 under a
constant torque of $-2$. Its partials are that held system's sensitivities.
They are the wrong answer only to the closed-loop question, which is a
question about the sampled-data step map of [§14.10][s14-10].

Two more boundaries of the same kind:

- **Events.** No guard runs at a `Dual` ([§9.4][s9-4]). A model that would cross one
  keeps integrating the dynamics from before the firing. The script does not
  show this case.
- **Seeds behind a discrete reader.** A root input that only a discrete
  component reads is pinned, and a seed has no path from it into the
  continuous side. This is the frozen cell's exact zero, which
  `frozen_discrete_walkthrough.md` works through.

So the scope is a horizon over which no discrete output would change and no
event would fire. That covers a purely continuous model, a model whose
discrete outputs are constant over the horizon, and any model up to the
first tick after `t₀`.

## 6. Checking a run

The `Float64` twin is the complete check, and the user builds it from the
same doors:

```julia
nominal = Model(deployment)
dual = Model(deployment, D)
init!(nominal, condition)
init!(dual, seeded_condition)
for k in 1:n_frames
    frame!(nominal, k)
    frame!(dual, k)
    # compare ForwardDiff.value of the dual's states with the nominal's
end
```

A skipped tick and a missed event both show as a difference in the values,
at the first frame top after they matter. On the three models of this note
the agreement before that point is bitwise. That is not promised in general.
Under a `Dual`, a component's in-place math runs through Julia's generic
fallbacks in place of BLAS ([§9.4][s9-4]), so a component with array arithmetic may
differ from its twin in the last bits. Compare to a tolerance there. A
difference that grows from one frame to the next is the limit of section 5,
not rounding.

## 7. Where this stops

Differentiating through a tick needs the discrete stages and `s_update` to
see the `Dual`, and the real leaves of `s` to carry partials. That is the
sampled-data extension, recorded and not built ([§14.10][s14-10], [D-073][d-073]). What a
`Dual` model carries today is the continuous block of that step map,
$\partial x^+/\partial x$ and the partials to the seeded root inputs.
Section 3 computes exactly that block.

<!-- citation link definitions — generated by tools/linkify.jl; do not edit -->
[d-073]: ../log.md#d-073--companion-sketches-carry-the-settled-condition-algebra-design
[d-317]: ../log.md#d-317--split-the-model-from-the-simulation-and-run-only-the-nominal-one
[d-320]: ../log.md#d-320--admit-only-a-scalar-into-which-float64-embeds-exactly-at-the-model-door
[d-461]: ../log.md#d-461--ship-bogackishampine-32-under-proportional-integral-control-as-the-first-adaptive-backend
[d-481]: ../log.md#d-481--establish-the-frozen-cells-at-init-on-a-model-at-a-non-nominal-scalar
[s10-2]: ../spec.md#102-the-stepper-seam
[s14-10]: ../spec.md#1410-linearization-tap-selectors-one-seeded-pass-a-pure-query
[s8-2]: ../spec.md#82-the-declaration-inventory
[s9-2]: ../spec.md#92-the-build-and-deployment-artifacts
[s9-4]: ../spec.md#94-activations-executable-sets-laziness-caching
