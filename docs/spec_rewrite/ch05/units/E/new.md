### 5.4 Artificial loops and the escape hatch

A [component](#g-component) that bundles a no-[feedthrough](#g-feedthrough) output with a feedthrough output (one
with an instantaneous input→output dependence) in one atomic evaluation unit can
be [port](#g-port)-level acyclic yet admit no evaluation order. Simulink calls this an
"artificial algebraic loop". A genuine cycle in the instantaneous dependency
graph is a different case, the [algebraic loop](#g-algebraic-loop) of [§5.5][s5-5]. The canonical artificial
loop in this domain is rigid-body dynamics. Velocity out is pure state, and
acceleration out is feedthrough from total force. **The remedy ladder for
artificial loops has three rungs** ([D-140][d-140]). The [two-stage split](#g-stage-function) (the two output
stages every component provides) resolves the rigid-body case, and it is the
rung that absorbs most artificial loops.

What survives the split is the case where a single component's stage-2 outputs
cross-couple through a neighbor. That case is port-level acyclic and stage-level
cyclic. The [feedthrough tracer](#g-feedthrough-tracer) (the instrument that classifies a rejected cycle
as real or artificial, [§5.6][s5-6]) labels it artificial. The ladder's other two rungs
are two remedies, and they apply in this order.

- Re-factor the [contract](#g-contract) (a component's declared interface).
  Before moving any code, re-examine the cycle's wires. An input the neighbor
  consumes *only in a fallback branch* is the archetypal false dependency. The
  neighbor is computing, on the component's behalf, a fallback whose semantics
  belong on the component's own side of the boundary. Move the branch to its
  natural owner and the wire disappears.

  The canonical instance is the strut/steering pair of Flight.jl's landing
  gear. The strut hands the contact-point velocity azimuth `ψ_v` to the
  steering model and consumes the `ψ_sw` the steering model returns. The
  steering model consumes `ψ_v` only in its disengaged, castoring branch.
  Castoring, however, is free-swiveling wheel physics. It is the strut's
  business, not the steering law's.

  ```
  # before
  strut ──ψ_v──▶ steering        # ψ_v consumed only by the castoring branch
  steering ─────▶ strut          # the pair of wires is the cycle

  # after
  steering ──(engaged, ψ_cmd)──▶ strut
  strut:  ψ_sw = engaged ? ψ_cmd : ψ_v    # nothing flows back
  ```

  Re-factoring the steering contract to emit `(engaged, ψ_cmd)`, and computing
  `ψ_sw = engaged ? ψ_cmd : ψ_v` inside the strut, deletes the backward wire
  outright. The factoring survives substitution. That is the test that it
  records structure rather than dodging the diagnostic ([D-140][d-140]). A stateful
  steering actuator produces `ψ_cmd` from its own state and still needs nothing
  from the strut (`companions/migration_outline.md` records the migration).
- Split the component. This is the residual remedy, taken when both halves
  genuinely belong to the component and the split documents real structure.
  Its cost is stated where it bites. Visibility ([§8.3][s8-3]) is binary, so
  every intermediate shared across the new boundary is declared in `y_types`,
  and is therefore public, connectable and substitution-relevant. The
  mitigating idiom is the granularity guideline ([§4.3][s4-3]), which the split
  case satisfies trivially, with one producing stage and one consumer. The
  idiom spells out as one struct-valued bundle port, a `StrutGeometry`-shaped
  value in the strut example, not N loose ports. The bundle port's type is then
  contract. That is a real cost, but a bounded and honest one. No visibility
  level is added for the orphaned intermediates ([D-194][d-194]).
  [D-034][d-034] and [D-055][d-055] stay closed, and with them the `unlisted`
  presentational flag and the `Private(T)` wrapper, the two visibility
  spellings they reject.

The build diagnostic offers both exits explicitly ([D-140][d-140]). It reads "cycle
through `systems/aero` is artificial at port level — split the component, or
narrow the neighbor's contract". The dead hop is the member with the input [face](#g-face)
(the name a port wears on its component's boundary) that it does not route to
the output port. The diagnostic carries the dead hop ([D-245][d-245]) as a separate field
of its [payload](#g-payload) (the structured data a diagnostic carries) rather than dotting it
onto the path ([§8.6][s8-6], [§13.2][s13-2]).

The component split is rare, and the ladder is what earns that word rather than
asserting it ([D-140][d-140]). The two-stage split dissolves the common shapes, and the
contract re-factoring absorbs the false wires. What is left for the component
split is cycles whose halves really are one component's own work.

One consequence of stage-2 conservatism (the presumption that every stage-2
output depends on every wired input, [§5.3][s5-3]) is worth recording. An input
consumed only by `x_deriv`, never by `y_direct`, still creates a feedthrough
edge if the component has stage-2 outputs. In practice such components are
integrator-shaped and have no stage-2 outputs. The remedy, if ever needed, is
the same ladder.

### 5.5 Algebraic loop policy: reject at build time

A genuine cycle in the instantaneous dependency graph is an
[algebraic loop](#g-algebraic-loop). **An algebraic loop is a build error**
([D-005][d-005]). The build reports it as `AlgebraicCycle`
([Appendix C][sC]). The diagnostic names every wire of the loop as a terminal
pair in the canonical slash form of [§8.6][s8-6], as in
`aero/F → dyn/F, dyn/a → aero/a`.

The user breaks the cycle explicitly, by one of three routes. They can insert
dynamics, insert an explicit unit delay, or restructure. The α-filter idiom (a
filter state inserted in the loop) is one way to insert dynamics, and it is
already standard practice in the domain.

The unit delay, `UnitDelay` ([§13.7][s13-7]), carries a caveat. It changes the model's
[tier](#g-tier) structure (its split into continuous and discrete sides). The broken signal
becomes discrete, sampled on a period on the scale of [`Δt_base`](#g-dt_base) (the base tick
period, an integer multiple of the continuous step). That is a modeling
decision, not a transparent wire. The diagnostic states this caveat rather than
offering the delay as a free remedy ([§13.7][s13-7]). Implicit delays and per-step
numerical loop solving are both closed ([D-005][d-005]).

Implicit *algebraic balances* inside a [component](#g-component), such as a turbomachinery
operating point, remain the component author's business. They are local, owned
and bounded. Rejecting framework-level loops does not forbid such models.
