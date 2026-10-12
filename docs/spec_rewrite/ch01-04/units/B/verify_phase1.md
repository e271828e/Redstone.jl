# Unit B verify, phase 1 (blind, from new.md only)

V1. The framework simulates hybrid causal systems. [D-001, D-002] (bold)
V2. Such a system has five parts.
V3. Part 1, continuous dynamics: ẋ = f(x, m, u, t) with algebraic outputs.
V4. This design's `f` also receives the published table. [§5.3]
V5. The composite map from x to ẋ is mathematically identical (to the textbook form). [§5.3]
V6. Part 2, multi-rate periodic discrete dynamics: s⁺ = g(s, u, t) at declared rates.
V7. Discrete outputs are held zero-order between ticks. [D-019]
V8. Gloss: a tick is an instant at which a discrete component's stages and update run.
V9. Part 3, zero-crossing events: guard functions with handlers, under two detection policies.
V10. Gloss: a guard function defines an event's predicate.
V11. Part 4, post-step manifold projection.
V12. The formalism includes an optional per-component hook x ← x_projection(x). [D-001] (bold)
V13. The hook is applied after each accepted step. [§5.3]
V14. The hook is applied after any handler reset of x. [§5.3]
V15. It covers quaternion renormalization, DCM orthonormalization and any other manifold-valued state.
V16. It is the cheap end of the projection-methods family from geometric integration.
V17. Part 5, external inputs: the runtime injects them asynchronously. [D-022]
V18. External inputs come from pilot controls or the network.
V19. Injection follows the staging rules of §11. [§11, D-022]
V20. Pointer: §2.1 gives the two policies, §2.2 the deliberate exclusions.
V21. Both policies share one declaration, a guard function plus a handler. [D-001, D-179] (bold)
V22. Only detection differs between the policies.
V23. A guard defines a predicate. [D-082, D-001] (bold)
V24. A guard has one of two forms: Bool-valued, or the sign of a continuous function.
V25. The sign convention is normative: positive = predicate holds.
V26. With sign value σ, holding means σ ≥ 0 (zero counts as holding).
V27. An event fires when its predicate transitions from not-holding to holding. [D-082, D-001] (bold)
V28. This is edge semantics, uniform across both forms.
V29. §10.6 states the bookkeeping of the prior.
V30. Gloss: the prior is each event's predicate sample stored at the previous boundary.
V31. The opposite crossing direction is declared as a second event with the negated guard. [D-082]
V32. Stall entry and exit are one such pair.
V33. A per-event `direction` keyword is recorded as a guarded addition, unbuilt. [D-180]
V34. Gloss: a guarded addition is a capability recorded with its shape so adoption stays additive.
V35. Which form an author declares is not a free choice.
V36. The guard's return type is the declared policy. [D-179]
V37. A Bool return declares boundary-detected; the sign form declares localized. [D-179]
V38. §10.4 states the rule, the exactness result that motivates the Bool form, and the gate idiom for localizing mixed predicates.
V39. Boundary-detected (cheap): each guard is checked for a not-holding → holding edge against its prior at step boundaries only. [§10.6]
V40. Gloss: boundaries are published consistency points.
V41. Boundary-detected: no root-finding and no step rejection.
V42. Boundary-detected: the handler fires at the end of the step in which the edge was observed.
V43. Boundary-detected cost: one guard evaluation per event per iteration round. [§10.6]
V44. Boundary-detected is fully compatible with fixed-step real-time execution.
V45. Localized (precise): the framework finds the crossing instant by root-finding. [D-018]
V46. Localized serves events where timing precision genuinely matters.
V47. §10.4 gives localized mechanics.
V48. Detection policy never depends on real-time pacing. [§10.7, D-080]
V49. The pacer inserts waits between completed frames.
V50. The pacer never alters the boundary sequence.
V51. This arrangement gives step-boundary logic well-defined semantics. [D-179]
V52. The crossing defines the transition. [D-179]
V53. Detection resolution is an execution-policy detail. [D-179]
V54. Time events and state events differ in how their instants are found.
V55. The discrete tier's ticks are time events. [D-220] (bold)
V56. A tick is an instant at which a discrete component's stages and update run. (repeat of V8)
V57. Ticks are declared by `sample_times`.
V58. Tick instants are known in advance and scheduled. [§10.5]
V59. Everything declared through StateEvent(guard, handler) is a state event.
V60. A state event's instant is unknown and must be detected, by boundary check or localization.
V61. That is why the declaration is named `state_events`. [§8.2, D-220]
V62. The criterion is detection versus scheduling, not which fields a guard reads.
V63. A guard over an input is still a state event.
V64. The formalism deliberately excludes three constructs. [D-001] (bold)
V65. No DAEs or algebraic constraints. [D-001]
V66. The actual need (behind DAEs) is state manifolds. [D-001]
V67. Projection (the optional per-component hook) covers state manifolds. [D-001]
V68. No SDEs or stochastic integrators. [D-001]
V69. Noise processes such as Dryden/von Kármán turbulence and sensor noise are modeled as ordinary RNG-driven discrete processes, i.e. shaping filters. [D-001]
V70. Gloss: RNG is a random number generator; Dryden and von Kármán are two standard atmospheric turbulence models.
V71. That modeling is faithful to how the noise processes are specified.
V72. That modeling is cheap.
V73. One consequence is elevated to a framework guarantee: deterministic replay.
V74. Gloss: replay is re-running the ordinary loop on a recorded input trace.
V75. RNG state lives in component discrete state s, never in ambient globals. [D-231]
V76. The same seed gives a bit-identical trajectory. [D-231]
V77. No unconditional per-step hook, because its semantics depend on step size. [D-001]
V78. So there is no equivalent of f_step!, FlightCore's per-step hook. [D-001]
V79. Every current use of f_step! decomposes into one of two mechanisms.
V80. Projection covers quaternion renormalization.
V81. Boundary-detected events cover engine phase transitions and the stall hysteresis latch.
V82. Gloss: boundary-detected events are checked for edges at step boundaries only, no root-finding.
V83. For one group of uses the mapping tightens semantics.
V84. Level-triggered cross-component resets become edge-triggered events.
V85. Flight.jl resets the gear's friction regulator while !wow (no weight on wheels) holds. [§5.3, D-001, D-141]
V86. Here that reset becomes an event on the touchdown edge. [§5.3, D-001, D-141]
