# The examples submodule: the admission guidelines and the inventory

*A companion record, not normative text. The ground truth is `spec.md`
[§13.7][s13-7] (the library, whose submodule is the precedent) and [§8.1][s8-1] (the
extension-only surface), with decisions [D-226][d-226] and [D-313][d-313]. If this document
and the spec ever disagree, the spec wins. It was written on 2026-10-15,
when the first release's work order was settled, to keep the reasoning
that puts the examples inside the package, the guidelines that keep them
examples, and the sketch of the first one.*

## 1. Why the examples ship inside the package

The examples are the submodule `Redstone.Examples`, one file per example,
as the library is `Redstone.Blocks` ([§13.7][s13-7], [D-313][d-313]). An examples directory
was weighed and rejected, for three reasons.

- **An example in a directory rots. An example in the package is tested.**
  Each example has a testset like any other file: the model builds, the
  trim converges to known values, the linearization's modes match, the
  run ends as expected. The example cannot drift from the framework, and
  the tutorial that walks through it cannot drift either.
- **The precompile workload needs a model the package can see.** A
  workload only exercises code visible while the package precompiles
  ([§9.7][s9-7]), so the model it runs lives inside the package. The first example
  is that model.
- **The example is the first consumer that uses only the public surface.**
  The fixtures carry the rule that no name there is known to `src/`. The
  examples carry the mirror: they import exactly as a user would, through
  the public names and nothing else, as the library does against the
  extension-only surface ([§8.1][s8-1]). An example that needs an internal name
  has found a gap for the exported-name audit.

The names are reached as `Examples.Longitudinal` after `using Redstone`,
or unqualified after `using Redstone.Examples`, which resolves whether or
not the root exports the submodule's name. The submodule exports its
models and declares them `public`. Whether the root exports `Examples` is
the audit's question, since the module exports nothing until the audit
runs ([D-226][d-226]). Every name in the submodule is API at registration, under
the naming convention like any other, with the docstring saying that an
example is didactic and may change in a minor version.

## 2. The admission guidelines

An example joins the inventory by judgement against these guidelines,
weighed as the library's are ([D-313][d-313]). The practical tripwire is that an
example needing a quaternion library, an atmosphere model or a landing
gear with more than one state is no longer an example, and belongs in a
package built on the framework.

- **Self-contained.** One file, its physics in that file, no helpers
  shared between examples. Two examples that want the same helper copy
  it.
- **No new dependencies.** The physics uses what the package already has.
  Plotting stays in the tutorial.
- **Walked through and pinned.** Every example is the subject of a
  tutorial chapter and of a testset. One without a tutorial is a fixture,
  and belongs in `test/`.
- **Any domain.** The home domain supplies the first example. A cart-pole,
  a thermal loop or a DC motor would pass the same guidelines, and the
  submodule stays flat until a second domain arrives.
- **Simple enough to read in one screen.** The example teaches the
  framework, not the domain. The measurement model the compile-cost and
  garbage reports want may grow from an example by subsystems a newcomer
  should not have to read, and then it is a second file, not the
  tutorial's.

## 3. The inventory

| Example | Status | Role |
|---|---|---|
| `Longitudinal`, a three-degree-of-freedom aircraft | planned | the tutorial's subject, the static inspector's first diagram, the precompile workload's model |

### `Longitudinal`

A point-mass aircraft in the vertical plane with a pitch degree of
freedom. The states are airspeed `V`, flight path angle `γ`, pitch angle
`θ`, pitch rate `q` and altitude `h`. The inputs are elevator `δe` and
throttle `δt`. The outputs are the states and the angle of attack
`α = θ − γ`, all from the state, so the plant has no feedthrough. The
physics is a textbook polar and a propeller law, about a dozen lines:
lift `L = q̄ S (CL0 + CLα α)`, drag `D = q̄ S (CD0 + k CL²)`, pitching
moment `M = q̄ S c̄ (Cm0 + Cmα α + Cmq q c̄ / 2V + Cmδe δe)`, thrust
`T = δt T_max`, with constant density. The equations of motion are

    V̇ = (T cos α − D) / m − g sin γ
    γ̇ = (L + T sin α) / (m V) − g cos γ / V
    θ̇ = q
    q̇ = M / Iyy
    ḣ = V sin γ

The declarations, to show the size:

```julia
struct Longitudinal <: AbstractComponent
    m::Float64; S::Float64; c̄::Float64; Iyy::Float64; T_max::Float64; ρ::Float64
    CL0::Float64; CLα::Float64; CD0::Float64; k::Float64
    Cm0::Float64; Cmα::Float64; Cmq::Float64; Cmδe::Float64
end

x_init(::Longitudinal) = (V = 50.0, γ = 0.0, θ = 0.0, q = 0.0, h = 1000.0)
u_types(::Longitudinal) = (δe = Float64, δt = Float64)
y_types(::Longitudinal) = (V = Float64, θ = Float64, q = Float64, h = Float64, α = Float64)
```

A planar quadrotor was weighed as the alternative, with no aerodynamics
to explain and a larger robotics audience. It lost because hover trim is
one line and the linearization is a double integrator, where the aircraft
gives a real trim problem ([§14.7][s14-7]), modes a reader knows by name, and the
home domain.

**The layers.** The tutorial peels the one model in order, each chapter
adding a layer. The README shows layers 2, 4 and 5 condensed, with the
plot and the diagram, after the quick start it already has, and links to
the tutorial for the rest.

1. Author the plant: the declarations and the stages, nothing else.
2. Build and run open loop from an off-trim state, log, plot the phugoid.
   The README's first picture.
3. Trim at level flight at a given airspeed: angle of attack, elevator
   and throttle solved together.
4. Linearize at the trim, print the eigenvalues, name the short period and
   the phugoid, design gains from the matrices. The tracker's "gains
   designed outside" workflow, demonstrated.
5. Close the loop with library blocks in a group: a first-order lag with a
   rate limiter and saturation as the actuator, a discrete cascade at
   50 Hz under a faster plant step, pitch rate inside, pitch attitude
   outside, altitude outermost, airspeed through throttle, a step
   reference, white noise on the sensed altitude, a switch between the
   PID cascade and the LQR tracker for a bumpless engage. The static
   inspector's diagram and the README's second picture.
6. Fly a descent to touchdown: a localized gear-contact guard and a stop
   request ([§13.5][s13-5]), the termination record and its reason.
7. Replay from the recorded trace, bit-identical.
8. Bind a device to the elevator and run paced. Tutorial only, and shown
   in the README as the binding's few lines until the live inspector
   gives a recording.

**The testset's pins.** The model builds under the nominal and the
linearization activations. The trim converges to values pinned at a
tolerance. The linearization's eigenvalues give a short-period pair and a
phugoid pair with pinned frequencies and dampings. The touchdown run ends
with the expected stop reason. The closed loop of layer 5 holds its
altitude reference within a tolerance.

<!-- citation link definitions — generated by tools/linkify.jl; do not edit -->
[d-226]: ../decisions.md#d-226--reach-the-public-surface-by-qualified-name-until-the-export-audit
[d-313]: ../decisions.md#d-313--admit-a-library-block-by-judgement-against-three-guidelines
[s13-5]: ../spec.md#135-termination-is-a-state-not-an-exception
[s13-7]: ../spec.md#137-tooling-consequences-face-routes-and-the-component-library
[s14-7]: ../spec.md#147-the-trim-problem-namedtuple-decisions-declared-reads-named-residuals
[s8-1]: ../spec.md#81-position-a-declarative-trait-layer-in-plain-julia-no-macros
[s9-7]: ../spec.md#97-the-compiled-executor
