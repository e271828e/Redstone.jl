# Linearize

```@meta
CurrentModule = Redstone
```

In this chapter you linearize the trimmed aircraft and read its two modes
from the eigenvalues. The short period is a pitch oscillation of about 1.4 s,
and the phugoid's period matches the run of
[chapter 1](aircraft.md). The
two time scales then decide how the run integrates. The step must follow
the fast mode, even when only the slow one shows.

The chapter starts from the trimmed aircraft of [chapter 2](trim.md).

```@example linearize
using Redstone
import Redstone: Simulation, trim!, set
import RedstoneExamples: Longitudinal, aircraft, level_flight

sim = Simulation(aircraft(); Δt_frame = 1//100)
solution = trim!(sim, level_flight(); baseline = set()).solution
```

## The tap set

A linearization perturbs some quantities and watches others. The
[taps](@ref g-taps) name them, each with a [selector](@ref g-selector).
The states to perturb go under `x`, selected with [`get_state`](@ref), the
[root inputs](@ref g-root-input) under `u`, selected with
[`get_input`](@ref), and the outputs to watch under `y`. Each list's order
fixes the rows and columns of the matrices.
[`linearize`](@ref) works at the simulation's current state, here the
committed trim, and returns ``\dot x = A x + B u`` in deviations from it.
This chapter needs the states and the controls only, so the tap set has no
outputs.

```@example linearize
import Redstone: taps, get_state, get_input, linearize

aircraft_taps = taps(
    x = (V = get_state("plant", :V), γ = get_state("plant", :γ), θ = get_state("plant", :θ),
         q = get_state("plant", :q), h = get_state("plant", :h)),
    u = (δe = get_input(:δe), δt = get_input(:δt)))
linearization = linearize(sim, aircraft_taps)
round.(linearization.A; digits = 4)
```

```@example linearize
round.(linearization.B; digits = 4)
```

## Exact Jacobians

`linearize` differentiates the model's own code by automatic
differentiation. It needs no perturbation size, and each entry is exact up
to the rounding of the arithmetic. Two entries can be checked by eye. The
altitude's rate ``V \sin\gamma`` changes with ``\gamma`` at ``V \cos\gamma
= 50``, and the pitch angle's rate is ``q`` itself. Nothing depends on the
altitude, since the density is constant, so the last column is zero. The
indices follow the tap set's order of the states.

```@example linearize
V, γ, θ, q, h = 1:5   # the rows and columns of A, in the tap set's order

(linearization.A[h, γ], linearization.A[θ, q], linearization.A[:, h])
```

[`x_deriv`](@ref) is an ordinary function, so you can call it yourself. The block
below differentiates the `x_deriv` of [chapter 1](aircraft.md) by plain
central differences at the trim, and compares the result with the
framework's derivative through the built model.

```@example linearize
import Redstone: x_deriv
using LinearAlgebra: I

x₀, u₀ = linearization.x₀, linearization.u₀
f(v) = collect(x_deriv(Longitudinal(), (x = NamedTuple{keys(x₀)}(Tuple(v)), u = u₀)))
v₀, ε = collect(x₀), 1e-6
A_fd = reduce(hcat, [(f(v₀ + ε * e) - f(v₀ - ε * e)) / 2ε for e in eachcol(I(5))])
maximum(abs, A_fd - linearization.A)
```

The largest gap is about 1.5e-10, the error of the differences
themselves, which depends on the choice of ε. The framework's derivative
needs no ε.

## The modes

Each complex pair of eigenvalues of ``A`` is an oscillating mode. Its
natural frequency ``\omega_n = |\lambda|``, the magnitude of the
eigenvalue, is the frequency the mode would have with no damping. Its
damping ratio is ``\zeta = -\mathrm{Re}\,\lambda / |\lambda|``. The
oscillation you see has the damped frequency, the imaginary part
``\mathrm{Im}\,\lambda``, and its period is ``2\pi / \mathrm{Im}\,\lambda``.
The zero eigenvalue is the altitude, which integrates the climb rate and
feeds nothing back.

```@example linearize
using LinearAlgebra: eigvals

λs = eigvals(linearization.A)
```

```@example linearize
mode(λ) = (ωn = abs(λ), ζ = -real(λ) / abs(λ), period = 2π / imag(λ))

phugoid, short_period = mode.(sort(filter(λ -> imag(λ) > 0, λs); by = abs))
```

The short period is fast and well damped. The phugoid is slow and lightly
damped, which is why [chapter 1](aircraft.md)'s run still swings after two
minutes. Its period from the eigenvalue is 27.3 s, the period measured on
the run.

```@example linearize
phugoid.period
```

## The step

The run integrates each [frame](@ref g-frame) in steps. The default method,
[`RK4`](@ref), takes each frame in equal steps no longer than `h_max`, and
in one step when `h_max` is not set. `h_max`, the method and the frame are
keywords of the [`Deployment`](@ref), which [`Simulation`](@ref) passes on. An
explicit method like `RK4` stays stable only while the step is short
against the fastest mode. The short period's ``|\lambda|`` of 5.43 rad/s puts that
limit well under a second, though a two-minute run shows only the phugoid.

The function below flies [chapter 1](aircraft.md)'s flight, 5 m/s above
trim, under the deployment keywords it is given. It compares the airspeed
at each whole second with the run at [chapter 1](aircraft.md)'s frame of
1/100 s. Each step ends at a
[snapshot](@ref g-snapshot), so the [log](@ref g-log)'s length counts the
steps.

```@example linearize
import Redstone: at, combine, init!, run!, series, reads, get_output

off_trim = combine(at("plant", set(x = (V = 55.0, θ = solution.θ))),
                   set(u = (δe = solution.δe, δt = solution.δt)))

function fly(; deployment...)
    flight_sim = Simulation(aircraft(); deployment...)
    init!(flight_sim, off_trim)
    run!(flight_sim; t_end = 120.0)
    series(flight_sim, reads(V = get_output("plant", :V)))
end

reference = fly(Δt_frame = 1//100)
V_at(flight, t) = flight.columns.V[findfirst(==(t), flight.t)]
compare(flight) = (steps = length(flight.t) - 1,
                   error = maximum(t -> abs(V_at(flight, t) - V_at(reference, t)), 0.0:1.0:120.0))
```

A frame of one second with one step per frame is past the limit. The
short period grows instead of decaying, and the run stops on the first
state that is no longer finite.

```@repl linearize
fly(Δt_frame = 1)
```

The frame need not be the step. `h_max` bounds the step inside each frame,
and a tenth of a second follows the short period closely.

```@example linearize
compare(fly(Δt_frame = 1, h_max = 1//10))
```

An adaptive method chooses each step from an error estimate.
[`BS3`](@ref) needs a floor for its steps, `h_min`, and refuses to run
without one.

```@repl linearize
import Redstone: BS3
fly(Δt_frame = 1, algorithm = BS3())
```

With a floor of a millisecond it takes about a third as many steps as the
fixed method, at its default tolerances.

```@example linearize
compare(fly(Δt_frame = 1, algorithm = BS3(), h_min = 1//1000))
```

A fixed step is the one you choose from the eigenvalues, and it costs the
same on every run. The adaptive step finds its own length, and its error
follows the tolerances rather than the step.

## The package's tap set

The examples package ships a tap set as `longitudinal_taps()`. Its states
and controls are this chapter's, so its ``A`` and ``B`` are the same.

```@example linearize
import RedstoneExamples

package_linearization = linearize(sim, RedstoneExamples.longitudinal_taps())
(package_linearization.A == linearization.A, package_linearization.B == linearization.B)
```

To start from this chapter's end, import the tap set with the problem and
the aircraft:

```julia
import RedstoneExamples: Longitudinal, aircraft, level_flight, longitudinal_taps
```
