## 2. Formalism

The framework simulates **[hybrid causal systems](#g-hybrid-causal-system)**. Such a system has five parts.

- **Continuous dynamics.** $\dot{x} = f(x, m, u, t)$ with algebraic outputs.
- **Multi-rate periodic discrete dynamics.** $s^{+} = g(s, u, t)$ at declared
  rates, with outputs held zero-order between [ticks](#g-tick).
- **Zero-crossing events.** [Guard](#g-guard) functions with handlers, under two detection
  policies, stated below.
- **Post-step manifold [projection](#g-projection).** An optional per-[component](#g-component) hook `x ←
  x_projection(x)`, applied after each accepted step. It covers quaternion
  renormalization, DCM orthonormalization and any other manifold-valued state.
  It is the cheap end of the projection-methods family from geometric
  integration.
- **External inputs.** The runtime injects them asynchronously, from pilot
  controls or the network, under the staging rules of [§11][s11].

### 2.1 Events: two detection policies

Both policies share one declaration, a [guard](#g-guard) function plus a handler. Only
detection differs.

- **[Boundary-detected](#g-boundary-detected) (cheap).** The framework checks each guard for a
  not-holding → [holding](#g-edge-semantics) edge against its [prior](#g-prior) ([§10.6][s10-6]) at step [boundaries](#g-boundary) only.
  There is no root-finding and no step rejection. The handler fires at the end
  of the step in which the edge was observed. The cost is one guard evaluation
  per event per step. This policy is fully compatible with fixed-step real-time
  execution.
- **[Localized](#g-localized) (precise).** The framework finds the crossing instant by
  root-finding. This policy serves events where timing precision genuinely
  matters. [§10.4][s10-4] gives the mechanics.

Detection policy never depends on real-time [pacing](#g-pacing) ([§10.7][s10-7]).

**Time events and state events.** The discrete [tier](#g-tier)'s [ticks](#g-tick), declared by
`sample_times`, are [time events](#g-time-event). Their instants are known in advance and
scheduled ([§10.5][s10-5]). Everything declared through `StateEvent(guard, handler)` is a
[state event](#g-state-event). Its instant is unknown and must be detected, by boundary check or
by localization. That is why the declaration is named `state_events` ([§8.2][s8-2]). The
criterion is detection versus scheduling, not which fields a guard reads. A
guard over an input is still a state event.

This arrangement gives step-boundary logic *well-defined semantics*. The
crossing defines the transition. Detection resolution is an execution-policy
detail.

A guard defines a **[predicate](#g-predicate)**. It does so in one of two forms, either a
`Bool`-valued form or the sign of a continuous function under the normative
convention **positive = predicate holds**. Writing the guard's sign value `σ`,
holding means `σ ≥ 0`.

An event fires when its predicate transitions from not-holding to holding. This
is [edge semantics](#g-edge-semantics), and it is uniform across both forms. [§10.6][s10-6] states the prior
bookkeeping. The opposite crossing direction is declared as a second event with
the negated guard. Stall entry and exit are one such pair.

Which form an author declares is not a free choice. **The guard's return type is
the declared policy.** A `Bool` return declares boundary-detected, and the sign
form declares localized ([D-179][d-179]). [§10.4][s10-4] states the rule, the exactness result
that motivates the `Bool` form, and the gate idiom for localizing mixed
predicates.

### 2.2 Exclusions (deliberate)

- **No DAEs / algebraic constraints.** The actual need is state manifolds, and
  [projection](#g-projection) covers it ([D-001][d-001]).
- **No SDEs / stochastic integrators.** Noise processes such as Dryden/von
  Kármán turbulence and sensor noise are modeled as ordinary RNG-driven discrete
  processes, that is, shaping filters. That modeling is faithful to how they are
  specified, and it is cheap. One consequence is elevated to a framework
  guarantee, **deterministic [replay](#g-replay)**. RNG state lives in [component](#g-component) discrete
  state (`s`), never in ambient globals, so the same seed gives a bit-identical
  trajectory.
- **No unconditional per-step hook**, so no `f_step!` equivalent. Every current
  use decomposes into one of two mechanisms. Projection covers quaternion
  renormalization. [Boundary-detected](#g-boundary-detected) events (checked for edges at step
  boundaries only, no root-finding) cover engine phase transitions and the stall
  hysteresis latch. For one class the mapping tightens semantics.
  Level-triggered cross-component resets become edge-triggered events. The gear
  friction regulator under `!wow` is one such reset ([§5.3][s5-3], [D-001][d-001]).

---

