### 14.10 Linearization: tap selectors, one seeded pass, a pure query

`linearize` computes the matrices `A`, `B`, `C` and `D` about an operating
point in one seeded evaluation, and it commits nothing. What it seeds and
reads is a [tap set](#g-taps) (three labeled lists declaring what
linearization seeds and reports). This section covers, in order, the tap set,
the operating point, the seeded pass, the leaves the pass seeds and the leaves
it holds frozen, the returned value, the guidance on coordinates, the recorded
sampled-data extension, and declared non-participation with the local
derivative rule.

#### The tap set

Flight.jl's per-aircraft `XStateSpace`/`UStateSpace`/`YStateSpace` structs,
plus the `get_*_ss`/`assign_*_ss!` shuttle methods, run to ~150 lines of
bookkeeping per variant. All of it becomes three [selector](#g-selector)
lists (the closed family of deferred reads resolving against a source).
**The three lists are declared together as one tap set,
`taps(x = …, u = …, y = …)`** ([D-072][d-072], [D-272][d-272]). Membership is
closed per list. The `x` list takes `get_state`, the `u` list `get_input`,
and the `y` list `get_output` and `get_face` ([§14.4][s14-4]). The NamedTuple
key is the label control design slices by.

**A tap names one scalar** ([D-272][d-272]). Its [leaf address](#g-leaf-address) (the field name with dotted and
bracketed steps below it) resolves to one scalar leaf ([§14.4][s14-4], [D-276][d-276]). So a
vector leaf yields *named scalars*, one tap per element. A seeded tap, in the `x` or
`u` list, reaches its scalar through one index step at most and never a `.name`
step, because a seed is written into a whole state field or [root input](#g-root-input) (the
root's own input face), or into one array element of it. A seeded tap's leaf is
exactly `Float64`. Any other seeded address is rejected at resolution as a
`TapResolution`. A `y` tap is a read and takes any leaf address. A tap resolving to
a vector or a struct is rejected at resolution as a `TapResolution`, and so is a
member in the wrong list. A second tap resolving to a site already seeded is
rejected naming the earlier label, since one site is one column and a second
seed there would overwrite the first ([D-272][d-272]).

```julia
taps(x = (p = get_state("vehicle/dynamics", "ω_eb_b[1]"),
          θ = get_state("vehicle/kinematics", :θ_nb), …),
     u = (throttle_cmd = get_input(:throttle),
          wind_n = get_input("wind[1]"), …),
     y = (EAS = get_output("vehicle/airflow", :EAS), …))
```

The three lists are validated at resolution, with [did-you-mean](#g-did-you-mean) errors (the
offending name plus the list-in-hand it should have matched). Those errors are
the selectors' own `ReadResolution` ([D-406][d-406]). The `x` list is validated against the
`x_init` [stores](#g-store) of the continuous [tier](#g-tier) (the continuous or discrete side of the
hybrid formalism), the `u` list against [faces](#g-face), and the `y` list against `y_types`. **An
`x` tap naming a discrete store is rejected at resolution** as a `TapResolution`, with
the tap and its tier in hand ([D-197][d-197]). That is the no-silent-zeros rule ([§9.5][s9-5]).
The discrete tier is frozen ([§8.2][s8-2]), so its only possible partials are zeros. The
rejection's next-move guidance points at the recorded step-map extension below.
The lists compile to offsets once, and relocate whole via `at(prefix, taps)`
([D-072][d-072]). The shuttle layer's successor is that compiled writer/reader pair, and
**no hand-written state-space mapping remains** ([§7.1][s7-1], [D-072][d-072]).

#### The operating point

**Linearization is a pure query** ([D-072][d-072]). It commits nothing and
runs no [boundary zero](#g-boundary-zero) (the initialization boundary, the
ordinary macro-sequence with an empty integrate). It works only on
[scratch](#g-scratch) buffers (mutable working storage whose contents are
never authoritative), and nothing it computes becomes authoritative.
Flight.jl's restore-the-trim dance, the re-`assign!` after the `FiniteDiff`
package dirtied the model, has no successor.

**The default operating point is the [checkpoint](#g-checkpoint)** of the simulation or the [`Model`](#g-model) (a
deployment materialized at one scalar type) as it stands ([D-274][d-274], [D-319][d-319]). A
checkpoint is the `Model`'s state at a frame top as one value. It is
`checkpoint(sim)` on a simulation and `checkpoint(model)` on a `Model`, each restored
into the scratch world with no boundary zero ([§12.6][s12-6], [D-274][d-274], [D-319][d-319]). The frozen
tier's [cells](#g-cell) (the typed entries of the signal table) are the checkpoint's held
cells. After a `trim!` commit, `linearize(sim, taps)` or `linearize(model, taps)` is
about the trim point with nothing re-specified. **`about = <condition>`, with `t0`
beside it, linearizes anywhere else without touching the sim**, its coverage
checked as [§14.6][s14-6] requires ([D-272][d-272]). `t0` is admitted only there, and a `t0` passed
without `about` is an `ArgumentInvalid`.

#### The seeded pass

Each invocation instantiates its own scratch store set, the trim service's
mechanism verbatim ([§14.8][s14-8]), and establishes the operating point in it (above).
**It then runs the seeded `Dual` evaluation**, one direction per `x` tap and per `u` tap,
in groups of `width` directions per pass ([D-072][d-072]). **`width` is a keyword of `linearize`,
default 8** ([D-272][d-272]). The default width's scalar type is named. A build can
therefore pre-materialize its [activation](#g-activation) (the build's typed products at a given
scalar type) through `activations` ([§9.4][s9-4]), and a tap set of any size then
linearizes with no compile at the keyboard ([D-272][d-272]). Value parts give `ẋ₀` and `y₀`.
Partials give `A` and `B` against the `x`- and `u`-seeds, and `C` and `D` against the same
seeds read at `y`. All four come out simultaneously, exact to machine precision.
`linearization_walkthrough.md` runs the pass on a two-state model, seed by seed.

```
  x-taps ─┐                                         ┌─ value parts → ẋ₀, y₀
          ├─ seed directions → one Dual evaluation ─┤
  u-taps ─┘          (chunked internally)           └─ partials    → A, B, C, D
```

That seeded evaluation replaces Flight.jl's four `FiniteDiff` Jacobians, their
step-size heuristics and ~4n perturbed evaluations.

#### Seeded and frozen leaves

**Unseeded states sit constant at the operating point**, and so do unseeded root
inputs ([D-072][d-072]). Establishing the operating point embeds their `Float64` values as
zero-partial constants. The discrete tier is frozen with zero partials, which is
precisely "linearize with the discrete state held" ([§8.2][s8-2]). Partials enter
through per-invocation seeding, one rule for `x` and root inputs alike ([§7.2][s7-2],
[D-297][d-297]). [§8.2][s8-2] states which root inputs the schema leaves seedable ([D-295][d-295]). A root
input whose input entry is declared `Pinned` is declaredly unseedable, and its
cell is frozen at every activation.

**Selecting such a root input as a `B`-matrix tap is rejected at tap resolution** as a
`TapResolution`, with the offending input entry in hand, rather than silently
yielding a zero column ([D-295][d-295], [D-296][d-296]). Under fan-out the rejection names the
pinning consumer, not the face alone. A root input is unseedable whenever any
one of its consumers demands frozen, which is the fan-out meet ([§8.2][s8-2], [D-168][d-168]).
The author's next move is to promote that leaf to a tolerant input entry, or to
route the tap around it. Either move depends on knowing which leaf froze the
root input. A discrete consumer pins its input entry by tier, not by declaration
([§8.2][s8-2]), so a root input it reads is unseedable at every activation with nothing
to promote. The rejection then names the tier, and the next move is to tap the
continuous cell that consumer drives, or the recorded step map below ([D-272][d-272]).

The table sets seeded and frozen leaves side by side.

| leaf | in the one pass | what fixes it |
|---|---|---|
| a state leaf named by an `x` tap | seeded, one direction | per-invocation seeding |
| any other state leaf | sits constant at the operating point | per-invocation seeding |
| a root input named by a `u` tap | seeded, one direction | per-invocation seeding |
| any other seedable root input | constant, its `Float64` value embedded as a zero-partial constant | per-invocation seeding |
| a root input whose input entry is declared `Pinned` | frozen at every activation, and rejected as a `B`-matrix tap | the schema: a declaration |
| a root input a discrete consumer reads | frozen at every activation, and rejected as a `B`-matrix tap | the tier |
| any discrete-tier leaf | frozen, zero partials | the tier |

#### The returned value

**`linearize` returns a `Linearization` value** ([D-072][d-072], [D-272][d-272]). It holds `ẋ₀`, `x₀`, `u₀` and
`y₀` as NamedTuples under the tap labels, `A`, `B`, `C` and `D` as matrices, and the three
label sets of the taps ([D-272][d-272]). On that data, FlightPhysics'
`subsystem`/`delete_vars` survive as pure label-indexed matrix slicing, with no
model involvement. Flight.jl's `c172x_ctl` LQR (linear-quadratic regulator)
pipeline consumes it with cosmetic changes. **FlightPhysics' `LinearizedSS`, the
[component](#g-component), survives separately, as an ordinary [continuous component](#g-continuous-component)** in the
migrated library ([D-072][d-072]). Its `x_init` is the state vector, its faces are labeled,
and the affine update lives in `y_direct`/`x_deriv`. It has no privileges, and its
schema is everyone else's.

#### Coordinate guidance

The recorded guidance is that linearization taps should select
minimal-coordinate mechanizations ([D-072][d-072]). Perturbing Euler-angle states is
meaningful where seeding quaternion components steps off the unit-norm manifold.
This is why Flight.jl's C172X design code linearizes the aircraft's `{NED}`
variant, the one built on north-east-down (NED) kinematics. [`design_world(ac)`](#g-design_world)
(the thin rig that mounts an aircraft for trim and linearization) rigs that
variant, promoting implicit practice to stated rule. The coordinate choice
belongs to the tap author, not the framework.

#### The sampled-data extension

**The sampled-data `Dual` activation is [recorded, not built](#g-recorded-not-built)**, a worked-out extension
deliberately left unimplemented with its seams named ([D-073][d-073]). The frozen-exact
doctrine is consumer-scoped, not a capability wall. Trim and linearization
differentiate the continuous dynamics with the discrete state held, and for that
a frozen discrete output (a zero-order-hold constant with zero partials) is the
exact answer, as [§7.2][s7-2] states ([D-072][d-072]). The frozen discrete cell is not an AD
limitation on the signal path. It is the true zero of an instantaneous
dependence that the hybrid semantics never had. The signal flow through a
discrete component is temporal, not instantaneous, and AD follows the actual
data movement. `frozen_discrete_walkthrough.md` works the three-component chain
through.

Differentiating "through" the discrete side means differentiating a
*different object*. That object is the sampled-data step map
$\Phi : ((x_k, s_k), \mathrm{inputs}) \to (x_{k+1}, s_{k+1})$, taken over the
model's *whole* state, both letters at once. One evaluation of $\Phi$
integrates one period, then runs the [due](#g-due) [ticks](#g-tick). The
extension is additive along existing [seams](#g-seam).

- [Walked](#g-walked)-leaf parametrization of the discrete tier's real-scalar
  state leaves. Counters and enums stay pinned, like `m`.
- Opt-in participation on discrete components, with frozen-exact staying the
  default. A participating component opts in through an explicit trait, and
  that trait turns the walk on for its [contracts](#g-contract) (its declared
  interface). Its `Float64` leaves follow the scalar and `Pinned` keeps its
  meaning, exactly as on the continuous tier ([§8.2][s8-2]). Participation
  therefore stays authored per leaf on that tier too, and no declaration
  changes shape, which gives graceful migration with no flag day.
- One new activation, "continuous chain + `x_deriv` + the discrete tier's
  output stages + `s_update`" ([§9.4][s9-4]).
- Forward sensitivities through the in-house RK steppers, for free. That is a
  payoff of owning the loop ([§10.1][s10-1]).
- **A distinct `s`-tap list sits beside the `x` list**, labeling the step
  map's state blocks $\partial(x^+, s^+)/\partial(x, s)$ ([D-197][d-197]). The
  `x` list keeps its continuous meaning unchanged.

The honest limit is that $\Phi$ is differentiable only where the event pattern
is locally constant. Exactness across a firing needs saltation corrections (the
jump terms a sensitivity takes across an event). The scope is therefore
event-quiescent operating points, which trim points already are, because [guards](#g-guard)
at commit see to that ([§14.5][s14-5]). The scope comes with a loud diagnostic if an
event fires inside a differentiated step. Two consumers wait. The first is the
closed-loop trim extension ([§14.7][s14-7]), whose `s_update(s) - s = 0` residuals would
currently need the derivative-free fallback, since a frozen `s_update` has no
Jacobian columns. The second is exact discrete-time linearization of the full
loop, which is digital design on the exact discretized plant instead of
continuous linearization plus Tustin's discretization.

#### Declared non-participation

Both halves of non-participation have a spelling ([D-263][d-263]). The output half is the
freeze door, which declares a leaf frozen under differentiation as [§8.2][s8-2] and [§9.5][s9-5]
spell it ([D-286][d-286]). An opaque wrapper, such as an FMU (a Functional Mock-up Unit,
a packaged external model) or a C aerodynamic table, and a deliberately severed
coupling can therefore both say so in the schema, instead of showing up in
Jacobians as unexplained zero rows. The conformance check holds them to it at
every activation ([D-286][d-286]). The input half is the FFI door ([§8.2][s8-2]). A consumer's
`Pinned` input entry declares "never hand me partials", enforced at the wire
([§6.1][s6-1], [D-263][d-263]). At a root input, such an input entry *is* the forbid-seeding marker
itself. That marker carries semantics rather than mere protection, because it
types the root-input cell at every activation. An unseeded root input is
therefore a *choice*, where a `Pinned`-entry root input is a *declaration* ([D-295][d-295]).

An implementation that cannot take `Dual`s has a third move. The marker records
that a leaf carries no partials, not that an implementation cannot propagate
them. **A component that must participate keeps its input entry tolerant and
supplies its own local derivative inside the stage** ([D-266][d-266]). A C table or an FMU
whose coupling matters to the Jacobian is such a component. It evaluates at the
value and obtains a local Jacobian by whatever means it has, such as a finite
difference at a step its own grid suggests or the table's analytic slope. It
then chains that Jacobian onto the incoming partials ([D-266][d-266]).

```julia
lookup(tb, u::Float64) = c_lookup(tb, u)                      # nominal: straight to the table

function lookup(tb, u::ForwardDiff.Dual{Tag}) where {Tag}      # Dual: the local rule
    u0 = ForwardDiff.value(u)
    y0 = c_lookup(tb, u0)
    h  = sqrt(eps(u0))                                         # or a step the table's grid suggests
    dy = (c_lookup(tb, u0 + h) - y0) / h
    return ForwardDiff.Dual{Tag}(y0, dy * ForwardDiff.partials(u))
end
```

The block strips the partials with `ForwardDiff.value` mid-expression, which [§9.5][s9-5]
leaves legal at an unpinned leaf, and the seeded pass sees the component as an
ordinary differentiable one. The derivative is finite-difference in quality on
this one component and exact everywhere else. **Linearization keeps this one
mechanism and no perturbation-based fallback** ([D-266][d-266]). The derivative-free trim
fallback ([§14.8][s14-8]) would serve problems with no Jacobian columns, a case
linearization does not have. `handle_walk_walkthrough.md` places the rule beside
the `Freeze` block ([§13.7][s13-7]) and the pinned input entry.

What stays recorded is only the remaining tooling over the schema's declared
non-participation. One piece is pinned-face validation by the tap declaration,
where selecting a declared-frozen output is a warning. The other is a
[feedthrough](#g-feedthrough)-graph lint, where a frozen output fed by participating inputs names
the severed coupling. Both are additive when a consumer shows up, with no flag
day. Until then the declared pins and the visible zero rows suffice.

---

