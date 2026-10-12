# Unit D verify, phase 1 (blind assertion list from new.md)

V1. The section asks why there are two leaf classes at all.
V2. One all-in-one primitive could carry continuous state, modes and discrete state, with `x_deriv`, events and `s_update`.
V3. Under that alternative, a purely continuous or discrete component would fall out of whichever facets an author declares.
V4. A component's class (its primitive-vs-assembly status) is already read off declaration shape. [§8.5]
V5. So the question is whether the two declaration sets should be exclusive.
V6. They are exclusive. [D-056, D-263]
V7. (bold) The split is between time bases, not state classes. [D-056]
V8. The continuous component is already hybrid.
V9. It carries modes `m`, guards and handlers. [§3.1]
V10. A guard is a function that defines an event's predicate (gloss).
V11. What separates the classes is sweep-driven versus tick-driven execution.
V12. A sweep is one pass through the execution order against the current state (gloss).
V13. A tick is an instant at which a discrete component's stages and update run (gloss).
V14. The settled rules force a merged component's two halves to communicate exactly as two siblings do. [D-056]
V15. There is one home per datum; no store mirrors another. [§5.2]
V16. `x_deriv` sees only the continuous state.
V17. `s_update` sees only the discrete state.
V18. `s⁺` is decoded only at the owner's next tick, because `s_update` runs last.
V19. That deferred decode makes ticks→events structurally impossible. [D-020]
V20. That deferred decode also terminates the iteration at each boundary. [§10.6]
V21. A boundary is a published consistency point (gloss). [§10.6]
V22. Cross-tier influence inside a merged component still routes through published table cells. [D-056]
V23. A tier is the continuous or discrete side of the formalism (gloss).
V24. A cell is one typed entry of the signal table (gloss).
V25. Therefore the all-in-one component is an assembly of two primitives in a trench coat. [D-056]
V26. An assembly is a component of pure composition (gloss).
V27. The all-in-one component buys no expressiveness.
V28. It incurs costs of its own, which D-056 enumerates. [D-056]
V29. One of those costs is not bookkeeping.
V30. The sampling interface is the ZOH plus the one-sample `z⁻¹` delay.
V31. The sampling interface is the most bug-prone boundary in a flight-control stack.
V32. A monolith swallows it.
V33. The split keeps it a visible wire.
V34. A strapdown IMU is the strongest challenge mounted against the split.
V35. §8.6 spells this IMU in full, with its notation. [§8.6]
V36. Its direct formulation integrates raw increments continuously: `ẋ.ϑ_c = ω_ic_c`, `ẋ.υ_c = f_c_c`, the coning attitude increment `q_c_cc`, and the sculling integral `ẋ.υ_c_sc = q_c_cc(f_c_c)`.
V37. Then, at the IMU's own Δt, a discrete step reads the integrals, publishes the sample, and zeroes them.
V38. In interval terms these piecewise quantities are integrals over [t_{k-1}, t_k] with weights re-anchored at each reset.
V39. ϑ_c and υ_c are integrals of ω and f over the interval, running from zero.
V40. q_c_cc = q_{c_{k-1}→c(t)} runs from identity.
V41. υ_c_sc = ∫ R^{c_{k-1}}_c f^c dt, rotation anchored at interval start.
V42. The differencing idiom of §8.6 recovers exactly these forms from the cumulative stores, term by term. [§8.6]
V43. The reset is periodic, not condition-triggered, so events are the wrong mechanism. [D-056]
V44. The reset is a discrete-tier write into continuous state, exactly the operation this design forbids. [D-056]
V45. `s_update` writes only its own `s`.
V46. Guard-driven handlers are the sole resetters of continuous state. [D-141]
V47. Integrate-and-dump falls squarely into the crack between the classes.
V48. It is tightly coupled continuous and periodic dynamics in one physical instrument.
V49. Algebra removes the reset. [§8.6]
V50. Every interval-relative integral becomes a cumulative one. 
V51. A discrete sampler differences consecutive samples against its latch. [D-056]
V52. §8.6 spells that idiom, its exactness condition and the resulting assembly in full. [§8.6]
V53. The strongest counterexample landed on the two-class taxonomy with less code than the direct formulation.
V54. It keeps the same thirteen integral scalars and the same math, minus the reset block.
V55. It brings three structural gains.
V56. First, the sampling interface became a wire.
V57. Second, the error model became a discrete sibling, making the truth/corrupted sample pair separately loggable.
V58. Third, linearization got sane.
V59. Activation = the build's typed products at a given scalar type (gloss).
V60. Under a `Dual` activation the discrete tier is held. [§8.2]
V61. "Integrators that never reset" is the cumulative formulation.
V62. The framework's rules pushed the IMU into the only form that the framework's own linearization semantics could coherently handle.
V63. (bold) The one recorded, unbuilt escape hatch is a tick-triggered handler on continuous components. [D-056]
V64. Such a handler is a periodic event.
V65. It is a guarded addition (gloss: a capability the design admits but does not build).
V66. It is for interval-relative dynamics that ever neither factor algebraically nor tolerate the latch-back wire.
V67. In that wire, the integrals consume the sampler's published latch. [§8.6]
V68. No known case needs the escape hatch. [D-056]
