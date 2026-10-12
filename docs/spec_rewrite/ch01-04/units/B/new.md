## 2. Formalism

**The framework simulates [hybrid causal systems](#g-hybrid-causal-system)**
([D-001][d-001], [D-002][d-002]). Such a system has five parts.

- Continuous dynamics. $\dot{x} = f(x, m, u, t)$ with algebraic outputs. This
  design's `f` also receives the published signal table, and the composite map
  from `x` to $\dot{x}$ is mathematically identical to the textbook form's ([§5.3][s5-3]).
- Multi-rate periodic discrete dynamics. $s^{+} = g(s, u, t)$ at declared rates,
  with outputs held zero-order between [ticks](#g-tick) ([D-019][d-019]). A tick is an instant at
  which a discrete component's stages and update run.
- Zero-crossing events. [Guard](#g-guard) functions (each defining an event's
  predicate) with handlers, under two detection policies.
- Post-step manifold [projection](#g-projection). **The formalism includes an
  optional per-[component](#g-component) hook, `x ← x_projection(x)`**
  ([D-001][d-001]). It is applied after each accepted step and after any
  handler reset of `x` ([§5.3][s5-3]). It covers quaternion renormalization,
  direction cosine matrix (DCM) orthonormalization and any other
  manifold-valued state. It is the cheap end of the projection-methods family
  from geometric integration.
- External inputs. The runtime injects them asynchronously, from pilot
  controls or the network, under the staging rules of [§11][s11]
  ([D-022][d-022]).

[§2.1][s2-1] gives the two event-detection policies, and [§2.2][s2-2] the
exclusions taken deliberately.

### 2.1 Events: two detection policies

**Events have two detection policies** ([D-001][d-001]). Both policies share
one declaration, a [guard](#g-guard) function plus a handler ([D-179][d-179]).
Only detection differs.

**A guard defines a [predicate](#g-predicate)** ([D-082][d-082],
[D-001][d-001]). It does so in one of two forms, either a `Bool`-valued form or
the sign of a continuous function under the normative convention positive =
predicate holds. Writing the guard's sign value `σ`, holding means `σ ≥ 0`.

**An event fires when its predicate transitions from not-holding to holding**
([D-082][d-082], [D-001][d-001]). This is [edge semantics](#g-edge-semantics), and it is uniform across both forms.
[§10.6][s10-6] states the bookkeeping of the [prior](#g-prior). The prior is each event's predicate
sample stored at the previous [boundary](#g-boundary) (a published consistency point). The
opposite crossing direction is declared as a second event with the negated guard
([D-082][d-082]). Stall entry and exit are one such pair. [D-180][d-180] records a per-event
`direction` keyword as a [guarded addition](#g-guarded-addition) (a capability the design admits but does
not build).

Which form an author declares is not a free choice. The guard's return type is
the declared policy. A `Bool` return declares
[boundary-detected](#g-boundary-detected), and the sign form declares
[localized](#g-localized) ([D-179][d-179]). [§10.4][s10-4] states the rule,
the exactness result that motivates the `Bool` form, and the gate idiom for
localizing mixed predicates. The two policies follow.

- Boundary-detected (cheap). The framework checks each guard for a not-holding →
  holding edge against its prior ([§10.6][s10-6]) at step boundaries only. There is no
  root-finding and no step rejection. The handler fires at the end of the step
  in which the edge was observed. The cost is one guard evaluation per event per
  round of the boundary's event iteration ([§10.6][s10-6]). This policy is fully
  compatible with fixed-step real-time execution.
- Localized (precise). The framework finds the crossing instant by
  root-finding ([D-018][d-018]). This policy serves events where timing
  precision genuinely matters. [§10.4][s10-4] gives the mechanics.

Detection policy never depends on real-time [pacing](#g-pacing)
([§10.7][s10-7], [D-080][d-080]). The pacer inserts waits between completed
frames and never alters the boundary sequence.

The two-policy arrangement gives step-boundary logic *well-defined semantics*. The
crossing defines the transition ([D-179][d-179]). Detection resolution is an
execution-policy detail.

Time events and state events differ in how their instants are found. **The
discrete [tier](#g-tier)'s [ticks](#g-tick) are [time events](#g-time-event)** ([D-220][d-220]). A tier is one side of the hybrid
formalism, continuous or discrete. Ticks are declared by `sample_times`. Their
instants are known in advance and scheduled ([§10.5][s10-5]). Everything declared through
`StateEvent(guard, handler)` is a [state event](#g-state-event). Its instant is unknown and must be
detected, by boundary check or by localization. That is why the declaration is
named `state_events` ([§8.2][s8-2], [D-220][d-220]). The criterion is detection versus scheduling,
not which fields a guard reads. A guard over an input is still a state event.

### 2.2 Exclusions (deliberate)

**The formalism deliberately excludes three constructs** ([D-001][d-001]).

- No differential-algebraic equations (DAEs) or algebraic constraints. The
  actual need is state manifolds, and [projection](#g-projection), the optional
  per-component hook `x ← x_projection(x)`, covers it ([D-001][d-001]).
- No stochastic differential equations (SDEs) or stochastic integrators. Noise
  processes, such as sensor noise and Dryden/von Kármán turbulence, are modeled
  as shaping filters ([D-001][d-001]), that is, as ordinary discrete processes driven by
  a random number generator (RNG). That modeling is faithful to how the noise
  processes are specified, and it is cheap. One consequence is elevated to a
  framework guarantee, deterministic [replay](#g-replay) (re-running the ordinary loop on a
  recorded input trace). RNG state lives in [component](#g-component) discrete state `s`, never in
  ambient globals, so the same seed gives a bit-identical trajectory ([D-231][d-231]).
- No unconditional per-step hook, because its semantics depend on the step
  size ([D-001][d-001]). So there is no equivalent of `f_step!`, FlightCore's
  per-step hook. Every current use of `f_step!` decomposes into one of two
  mechanisms. Projection covers quaternion renormalization.
  [Boundary-detected](#g-boundary-detected) events (checked for edges at step
  boundaries only, no root-finding) cover engine phase transitions and the
  stall hysteresis latch. For one group of uses the mapping tightens
  semantics. Level-triggered cross-component resets become edge-triggered
  events. Flight.jl resets the gear's friction regulator while `!wow` (no
  weight on wheels) holds; here that reset becomes an event on the touchdown
  edge ([§5.3][s5-3], [D-001][d-001], [D-141][d-141]).

---
