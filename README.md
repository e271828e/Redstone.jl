# Redstone.jl

[![Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://e271828e.github.io/Redstone.jl/dev/)
[![CI](https://github.com/e271828e/Redstone.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/e271828e/Redstone.jl/actions/workflows/CI.yml)
[![Coverage](https://codecov.io/gh/e271828e/Redstone.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/e271828e/Redstone.jl)

Redstone is a Julia framework for modeling and simulating hierarchical hybrid
systems. A model is written as a tree of components that exchange values
through directed ports, mixing continuous dynamics, multi-rate periodic
discrete dynamics and events. Its home domain is aircraft guidance, navigation
and control, but the formalism is domain-neutral.

## Features

- Continuous dynamics on fixed or adaptive steps, with events located by
  root-finding or checked at step boundaries.
- Multi-rate periodic discrete dynamics, held zero-order between ticks.
- An execution order derived from declared feedthrough. Algebraic loops are
  build errors that name the cycle.
- Zero-allocation stepping and type stability, both asserted by the test suite.
- A runtime data plane for devices, GUIs and scripts, with staged writes,
  snapshot reads and no shared mutable model.
- Bit-identical replay from a recorded input trace.
- Initialization, trim and linearization, with exact
  automatic-differentiation Jacobians.
- Checkpoint and restore of a stopped simulation, checked against its
  deployment.
- Real-time pacing against the wall clock, with pause and resume.
- A standard component library: integrators and limited integrators, lags,
  linear systems in `s` and `z`, relays, delays, noise, and PID and LQR tracking
  controllers with anti-windup, hold and bumpless engage.
- Structured diagnostics from a closed set of kinds, reported where the
  mistake was made.

The browser inspector is in progress in a separate package,
[RedstoneInspector.jl](https://github.com/e271828e/RedstoneInspector.jl).
The live inspector and the cockpit come after the first release.

## Status

Redstone is under active development and is not yet registered. Its API may
change without notice. The module exports nothing yet, so every name is
imported explicitly. Redstone requires Julia 1.13 or later.

## Installation

```julia
using Pkg
Pkg.add(url = "https://github.com/e271828e/Redstone.jl")
```

## Quick start

A continuous plant under a discrete PI controller running at 50 Hz:

```julia
using Redstone
import Redstone: AbstractComponent, x_init, s_init, u_types, y_types,
    y_state, y_direct, x_deriv, s_update            # extended by components
import Redstone: Absolute, Simulation, init!, run!, set, port, state, build
import Redstone.Library: Group

struct Plant <: AbstractComponent
    ω::Float64
    ζ::Float64
end

x_init(::Plant) = (q = 0.0, v = 0.0)
u_types(::Plant) = Float64                           # one input `u`, declared bare
y_types(::Plant) = (y = Float64, power = Float64)

y_state(::Plant, (; x)) = (y = x.q,)                 # stage 1: state only
y_direct(::Plant, (; x, u)) = (power = u * x.v,)     # stage 2: reads inputs
x_deriv(p::Plant, (; x, u)) =
    (q = x.v, v = -p.ω^2 * x.q - 2p.ζ * p.ω * x.v + u)

struct PI <: AbstractComponent
    k_p::Float64
    k_i::Float64
end

s_init(::PI) = 0.0                                   # one state `s`, declared bare
u_types(::PI) = (ref = Float64, meas = Float64)
y_types(::PI) = Float64                              # one output `y`, declared bare

y_direct(c::PI, (; s, u)) = c.k_p * (u.ref - u.meas) + s
s_update(c::PI, (; s, u, Δt)) = s + c.k_i * Δt * (u.ref - u.meas)

loop(feedback) = Group((plant = Plant(2.0, 0.3), ctl = PI(3.0, 2.0));
    local_wires = ("ctl/y" => "plant/u", "plant/$feedback" => "ctl/meas"),
    input_wires = "ref" => "ctl/ref",
    output_wires = "plant/y" => "y",
    sample_times = (ctl = Absolute(1//50),))

sim = Simulation(loop("y"); Δt_frame = 1//1000)   # frames of 1 ms
init!(sim, set(u = (ref = 1.0,)))
run!(sim; t_end = 10.0)

port(sim, "plant", :y)    # 0.9654…
state(sim, "plant")       # (q = 0.9654…, v = 0.0120…)
```

A component adds methods to the framework's functions. Julia accepts a new
method only for a name that is imported explicitly or written qualified, as
in `Redstone.x_init`. The other names are imported only because the module
exports nothing yet.

Each component has two output stages. `y_state` sees only the state, and
`y_direct` also sees the inputs. The build derives the execution order
from that split. Feeding back the plant's stage-2 `power` port instead of `y`
closes an algebraic loop, and the build refuses the tree:

```
julia> build(loop("power"))
ERROR: DiagnosticError: 1 diagnostics
  AlgebraicCycle: algebraic loop among `plant`, `ctl`: plant/power → ctl/meas, ctl/y → plant/u — real: direct dependencies run all the way around it (`ctl` assumed from its declarations, the rest checked exactly from their code); break it with a state, a `y_state` port, or a `UnitDelay`, which makes the signal discrete, sampled every base tick and held in between (§5.5)
```

## Documentation

Redstone has no user manual yet. The
[documentation](https://e271828e.github.io/Redstone.jl/dev/) holds the
first chapters of a tutorial, the API reference and a glossary. The design is written down in full:

- [`design/spec.md`](https://github.com/e271828e/Redstone.jl/blob/master/design/spec.md)
  is the normative specification.
- [`design/log.md`](https://github.com/e271828e/Redstone.jl/blob/master/design/log.md)
  records every design decision and the alternatives it rejected.
- [`design/companions/`](https://github.com/e271828e/Redstone.jl/tree/master/design/companions)
  holds worked explainers, among them `library_inventory.md`, the standard
  library and its admission rule.
- [`design/pending.md`](https://github.com/e271828e/Redstone.jl/blob/master/design/pending.md)
  is the work order toward the first release.

[`examples/`](https://github.com/e271828e/Redstone.jl/tree/master/examples)
is a separate package with a larger worked model, a longitudinal aircraft
under LQR and PID control.

