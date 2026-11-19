# Trim

```@meta
CurrentModule = Redstone
```

In this chapter you find the pitch angle, the elevator and the throttle
that hold the aircraft in level flight at 50 m/s. You state the question as
a [`TrimProblem`](@ref), solve it with [`trim!`](@ref), and read the
report. The solver's answer lands within 1% of an estimate by hand.

The chapter starts from the aircraft of [chapter 1](aircraft.md).

```@example trim
using Redstone
import RedstoneExamples: Longitudinal, aircraft
```

## Level flight

Level flight at a given airspeed and altitude fixes four of the five
states. The flight path angle ``\gamma`` and the pitch rate ``q`` are zero,
and ``V`` and ``h`` take the values asked for. Three rates must then
vanish, ``\dot V = \dot\gamma = \dot q = 0``. The other two follow, since
``\dot\theta = q`` and ``\dot h = V \sin\gamma``. Three equations need three
unknowns. They are the pitch angle ``\theta``, which equals the angle of
attack when ``\gamma = 0``, the elevator ``\delta_e`` and the throttle
``\delta_t``.

## The problem

A trim problem names its unknowns, the decisions, with a guess and bounds.
Its `condition` is a function that turns the decisions into a
[condition](@ref g-condition), the values the model starts from. Here it
writes the pitch angle into the plant's state, beside the held airspeed and
altitude, a level flight path and no pitch rate. It writes the two controls
into the [root inputs](@ref g-root-input).
`reads` names what the solver looks at after each evaluation, a
[read set](@ref g-read-set) built by [`reads`](@ref), here of three derivatives read with
[`get_deriv`](@ref). `residuals` turns the reads into
the equations to zero, and `tolerances` says how close to zero is enough.

```@example trim
import Redstone: TrimProblem, set, at, combine, reads, get_deriv

level_flight(; V = 50.0, h = 1000.0) = TrimProblem(
    guess = (θ = 0.0, δe = 0.0, δt = 0.5),
    lower = (θ = -0.3, δe = -0.5, δt = 0.0),
    upper = (θ = 0.3, δe = 0.5, δt = 1.0),
    condition = d -> combine(
        at("plant", set(x = (V = V, γ = 0.0, θ = d.θ, q = 0.0, h = h))),
        set(u = (δe = d.δe, δt = d.δt))),
    reads = reads(V̇ = get_deriv("plant", :V), γ̇ = get_deriv("plant", :γ), q̇ = get_deriv("plant", :q)),
    residuals = (derivatives, d) -> (V̇ = derivatives.V̇, γ̇ = derivatives.γ̇, q̇ = derivatives.q̇),
    tolerances = (V̇ = 1e-9, γ̇ = 1e-9, q̇ = 1e-9))
```

## The solution

`trim!` solves the problem on a simulation's model. A solve that converges
commits its answer through [`init!`](@ref), so the simulation is ready to
run from the trim. The commit lays the problem's condition over a
[baseline](@ref g-baseline), a condition for whatever the problem leaves
out. This problem writes the plant's whole state and both root inputs, so
the baseline is empty.

```@example trim
import Redstone: Simulation, trim!

sim = Simulation(aircraft(); Δt_frame = 1//100)
report = trim!(sim, level_flight(); baseline = set())
(status = report.status, iterations = report.n_iterations, solution = report.solution)
```

The solver converges in four iterations. The report also carries the
residuals at the answer, each well inside its tolerance.

```@example trim
report.residuals
```

[`state`](@ref) reads the plant's committed state.

```@example trim
import Redstone: state

state(sim, "plant")
```

## The check

The estimate by hand ignores the small tilt of the thrust. Lift balances
weight, which gives the lift coefficient and so the angle of attack. The
moment vanishes, which gives the elevator. Thrust balances drag, which
gives the throttle. The
[companion](https://github.com/e271828e/Redstone.jl/blob/master/design/companions/longitudinal_aircraft.md#2-trim)
sets out the three steps.

```@example trim
const g = 9.81

plant = Longitudinal()
q̄ = 0.5 * plant.ρ * 50.0^2
CL = plant.m * g / (q̄ * plant.S)
α = (CL - plant.CL0) / plant.CLα
estimate = (θ = α,
            δe = (plant.Cm0 + plant.Cmα * α) / -plant.Cmδe,
            δt = q̄ * plant.S * (plant.CD0 + plant.k * CL^2) / plant.T_max)
```

The solution differs from the estimate by these percentages:

```@example trim
map((solved, estimated) -> 100 * (solved / estimated - 1), report.solution, estimate)
```

All three are within 1%. The largest gap is in the pitch angle, where the
thrust's tilt adds a little lift.

## A trim that fails

At 20 m/s the aircraft needs more angle of attack than the problem's upper
bound on ``\theta`` allows. The solver stops against the bound and says so.
It commits nothing, so the simulation stays as it was.

```@example trim
import Redstone: lifecycle

slow_sim = Simulation(aircraft(); Δt_frame = 1//100)
slow = trim!(slow_sim, level_flight(V = 20.0); baseline = set())
(status = slow.status, saturated = slow.saturated, residuals = slow.residuals, lifecycle = lifecycle(slow_sim))
```

## The package's problem

The examples package ships this chapter's problem as `level_flight()`.
Solved on a fresh simulation, it gives the same answer as yours at 50 m/s.

```@example trim
import RedstoneExamples

package_report = trim!(Simulation(aircraft(); Δt_frame = 1//100), RedstoneExamples.level_flight(); baseline = set())
package_report.solution == report.solution
```

To start from this chapter's end, import the problem with the aircraft:

```julia
import RedstoneExamples: Longitudinal, aircraft, level_flight
```
