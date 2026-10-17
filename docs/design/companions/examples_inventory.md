# The examples package: the admission guidelines and the inventory

*A companion record, not normative text. The ground truth is `spec.md`
[§13.7][s13-7] (the library, whose packaging question the examples share), [§8.1][s8-1] (the
extension-only surface) and [§9.7][s9-7] (the precompile workload), with decisions
[D-226][d-226] and [D-313][d-313]. If this document and the spec ever disagree, the spec wins.
It was written on 2026-10-15, when the first release's work order was
settled, and revised on 2026-10-18, when the examples moved out of the
package into an environment of their own. It keeps the reasoning behind that
placement, the guidelines that keep the examples examples, and the sketch of
the first one. The physics and the control design of the first example are
`longitudinal_aircraft.md`.*

## 1. Why the examples live in their own environment

The examples are the package `RedstoneExamples`, in the repository's
`examples/` directory, one file per example. Its `Project.toml` is a
workspace root of its own, with `examples/test` as its member, so
`Pkg.test` works from `--project=examples` as it does from the repository
root. It reaches `Redstone` through a `[sources]` entry with `path = ".."`,
never through membership in the root workspace, and keeps its own manifest.
`Redstone`'s manifest therefore never lists what only an example needs, and
the gate (`implementation.md`, "Running the suite") installs and loads none
of it.

Two placements were weighed before this one.

- **A submodule `Redstone.Examples`, as the library is `Redstone.Blocks`.**
  It was the first choice, for three reasons, and the move out of the
  package answers each.
  - *An example in the package is tested.* So is one in its own package:
    `examples/test` pins every example, and CI runs it as a workflow of its
    own beside the gate.
  - *The precompile workload needs a model the package can see.* It does,
    and that model need not be an example. The workload's target is the
    generic machinery, which [§9.7][s9-7] prices at about 9 s whatever the model,
    and a closed loop of library blocks alone exercises every generic path
    without a new component type. `pending.md` queues the workload so.
  - *The example is the first consumer that uses only the public surface.*
    A separate package is the purer form of that consumer: it depends on
    `Redstone` as a user's package does, and its names are not `Redstone`'s
    API, so the exported-name audit ([D-226][d-226]) is smaller by them.

  What tipped it is dependencies. A tutorial wants a Riccati solver and a
  plotting package, and the guideline that kept them out of `Redstone`
  would have shipped the LQR gains as literals, with the script that
  produced them living elsewhere. In their own environment the examples
  compute the gains they use.
- **A bare examples directory of scripts.** Rejected because a script
  nobody runs rots; an example is a package with a testset or it is not an
  example.

The names are reached after `using RedstoneExamples`. Whether the package
exports them is decided with its first release; until then it exports
nothing, as `Redstone` does ([D-226][d-226]), and the tutorial imports by name. Every
name in it is API of the examples package, under the naming convention like
any other, with the docstring saying that an example is didactic and may
change in a minor version.

**Getting the examples.** The installed `Redstone` carries `examples/`
inside its package directory, whether it came from a URL or from the
registry, so a reader has two routes.

    # From a clone, the examples and, later, the tutorial scripts beside them.
    git clone https://github.com/e271828e/Redstone.jl
    julia --project=Redstone.jl/examples -e 'using Pkg; Pkg.instantiate()'
    julia --project=Redstone.jl/examples
    julia> using Redstone, RedstoneExamples

    # From an installed Redstone, without a clone.
    julia> using Redstone, Pkg
    julia> Pkg.activate(temp = true)
    julia> Pkg.develop([PackageSpec(path = pkgdir(Redstone)),
                        PackageSpec(path = joinpath(pkgdir(Redstone), "examples"))])
    julia> using Redstone, RedstoneExamples

The second route goes through a temporary environment because Pkg makes an
installed package directory read-only, so `examples/` cannot be activated
in place. Both packages are developed, since `Redstone` must be a direct
dependency of the environment for `using Redstone` to resolve in `Main`;
developing the examples alone loads them, through the `[sources]` path,
but leaves `Redstone` unreachable. Both routes were run end to end on
2026-10-18.

## 2. The admission guidelines

An example joins the inventory by judgement against these guidelines,
weighed as the library's are ([D-313][d-313]). The practical tripwire is size: an
example needing a quaternion library, an atmosphere model or a landing
gear with more than one state is no longer an example, and belongs in a
package built on the framework.

- **Self-contained.** One file, its physics in that file, no helpers
  shared between examples. Two examples that want the same helper copy
  it.
- **No dependency in `Redstone`.** Anything an example needs joins the
  examples environment, never `Redstone`'s. The gain design and the
  tutorial's plotting live there.
- **Walked through and pinned.** Every example is the subject of a
  tutorial chapter and of a testset. One without a tutorial is a fixture,
  and belongs in `test/`.
- **Any domain.** The home domain supplies the first example. A cart-pole,
  a thermal loop or a DC motor would pass the same guidelines, and the
  package stays flat until a second domain arrives.
- **A plant that reads in one screen.** The example teaches the framework,
  not the domain. The example's file is longer than its plant, since it
  also carries the trim problem, the tap set, the closed loop and the
  descent the tutorial's layers walk through, each a plain function beside
  the plant. The measurement model the compile-cost and garbage reports
  want may grow from an example by subsystems a newcomer should not have to
  read, and then it is a second file, not the tutorial's.

## 3. The inventory

| Example | Status | Role |
|---|---|---|
| `Longitudinal`, a three-degree-of-freedom aircraft | shipped | the tutorial's subject, the static inspector's first diagram, the model the compile-time and garbage measurements run on |

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

The parameters, the trim, the modes and the control design are
`longitudinal_aircraft.md`. The declarations, to show the size:

```julia
struct Longitudinal <: AbstractComponent
    m::Float64; S::Float64; c̄::Float64; Iyy::Float64; T_max::Float64; ρ::Float64
    CL0::Float64; CLα::Float64; CD0::Float64; k::Float64
    Cm0::Float64; Cmα::Float64; Cmq::Float64; Cmδe::Float64
end

x_init(::Longitudinal) = (V = 50.0, γ = 0.0, θ = 0.0, q = 0.0, h = 1000.0)
u_types(::Longitudinal) = (δe = Float64, δt = Float64)
y_types(::Longitudinal) = (V = Float64, γ = Float64, θ = Float64, q = Float64, h = Float64, α = Float64)
```

A planar quadrotor was weighed as the alternative, with no aerodynamics
to explain and a larger robotics audience. It lost because hover trim is
one line and the linearization is a double integrator, where the aircraft
gives a real trim problem ([§14.7][s14-7]), modes a reader knows by name, and the
home domain.

**The file's surface.** Beside the plant, one more component and the plain
functions the tutorial's layers call, each the subject of one chapter:

- `GroundContact(; h_ground = 0.0)`, the leaf whose localized guard fires
  at touchdown and whose `Bool` output feeds a `StopRequest`;
- `aircraft()`, the plant alone under the root inputs `δe` and `δt`;
- `level_flight(; V, h)`, the trim problem of level flight, and
  `longitudinal_taps()`, the tap set of the five states, the two inputs
  and the outputs `h` and `V`;
- `lqr_gains(linearization; qx, qξ, r)`, the tracker's three gains from a
  linearization, by `lqr_tracker.md`'s sections 2 and 3;
- `closed_loop(solution, gains; cascade, h_step, noise_σ)`, layer 5's
  model, and `trimmed(solution)`, its initial condition, which seeds the
  three integrators whose trim value is not zero through `fragment(s = …)`
  beside the plant's state;
- `descent()`, the aircraft with the gear and the stop request.

**The layers.** The tutorial peels the one model in order, each chapter
adding a layer. The README shows layers 2, 4 and 5 condensed, with the
plot and the diagram, after the quick start it already has, and links to
the tutorial for the rest.

1. Author the plant: the declarations and the stages, nothing else.
2. Build and run open loop from an off-trim state, log, plot the phugoid.
   The README's first picture.
3. Trim at level flight at a given airspeed: pitch angle, elevator
   and throttle solved together.
4. Linearize at the trim, print the eigenvalues, name the short period and
   the phugoid, design gains from the matrices. The tracker's "gains
   designed outside" workflow, demonstrated.
5. Close the loop with library blocks in a group: a rate limiter and a
   first-order lag as each actuator, a discrete cascade at 50 Hz under a
   faster plant step, pitch rate inside, pitch attitude outside, altitude
   outermost, airspeed through throttle, a step reference, white noise on
   the sensed altitude, and a switch between the PID cascade and the LQR
   tracker on a pinned `Source{Bool}` over a predicate of time for a
   bumpless engage. The static
   inspector's diagram and the README's second picture.
6. Fly a descent to touchdown: a localized gear-contact guard and a stop
   request ([§13.5][s13-5]), the termination record and its reason.
7. Replay from the recorded trace, bit-identical.
8. Bind a device to the open-loop aircraft's elevator and run paced.
   Tutorial only, and shown in the README as the binding's few lines until
   the live inspector gives a recording.

**The testset's pins.** The aircraft, the closed loop and the descent build
under the nominal and the linearization activations. The trim converges to
the pitch angle, elevator and throttle `longitudinal_aircraft.md` gives,
at a tolerance. The linearization's eigenvalues give the short-period and
the phugoid pair at the pinned frequencies and dampings, and one eigenvalue
at zero. The open-loop run from an off-trim airspeed crosses the trim
airspeed at half the phugoid's period. The closed loop rests at the trim
under either controller with no step and no noise. It holds a step in the
altitude reference within a tolerance under either controller, and also
when the switch hands command to the tracker in steady flight or mid-climb
or hands it back to the cascade, with the cascade's peak below a bound and
the tracker's above one. During the climb each block not in command stays within a
pinned gap of what it tracks. The elevator's frame-to-frame jump at the
switch in steady flight stays below the jitter the sensor noise induces,
and the jumps mid-climb and around the hand-back stay below pinned bounds.
The sensed altitude's noise has the declared standard deviation, to 10%.
The descent ends with the touchdown's stop
reason at the pinned time, with the altitude at zero to within the
localization tolerance. The closed loop's phase bodies allocate nothing.

<!-- citation link definitions — generated by tools/linkify.jl; do not edit -->
[d-226]: ../decisions.md#d-226--reach-the-public-surface-by-qualified-name-until-the-export-audit
[d-313]: ../decisions.md#d-313--admit-a-library-block-by-judgement-against-three-guidelines
[s13-5]: ../spec.md#135-termination-is-a-state-not-an-exception
[s13-7]: ../spec.md#137-tooling-consequences-face-routes-and-the-component-library
[s14-7]: ../spec.md#147-the-trim-problem-namedtuple-decisions-declared-reads-named-residuals
[s8-1]: ../spec.md#81-position-a-declarative-trait-layer-in-plain-julia-no-macros
[s9-7]: ../spec.md#97-the-compiled-executor
