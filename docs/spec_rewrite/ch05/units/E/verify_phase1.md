# Unit E verify, phase 1 (blind read of new.md)

V1. A component bundling a no-feedthrough output with a feedthrough output in one atomic evaluation unit can be port-level acyclic yet admit no evaluation order.
V2. Simulink calls this an "artificial algebraic loop".
V3. A genuine cycle in the instantaneous dependency graph is a different case, the algebraic loop of §5.5.
V4. The canonical artificial loop in this domain is rigid-body dynamics.
V5. (Rigid body) velocity out is pure state.
V6. (Rigid body) acceleration out is feedthrough from total force.
V7. **The remedy ladder for artificial loops has three rungs** [D-140]. (bold)
V8. The two-stage split (two output stages every component provides) resolves the rigid-body case.
V9. The two-stage split is the rung that absorbs most artificial loops.
V10. What survives the split: a single component's stage-2 outputs cross-couple through a neighbor.
V11. That case is port-level acyclic and stage-level cyclic.
V12. The feedthrough tracer (diagnostic that classifies a rejected cycle, §5.6) labels it artificial.
V13. The ladder's other two rungs are two remedies, applied in order (re-factor, then split).
V14. Rung: re-factor the contract (a component's declared interface).
V15. Before moving code, re-examine the cycle's wires.
V16. An input the neighbor consumes only in a fallback branch is the archetypal false dependency.
V17. The neighbor computes, on the component's behalf, a fallback whose semantics belong on the component's own side.
V18. Moving the branch to its natural owner makes the wire disappear.
V19. Canonical instance: strut/steering pair of Flight.jl's landing gear.
V20. Strut hands ψ_v (contact-point velocity azimuth) to steering and consumes the ψ_sw steering returns.
V21. Steering consumes ψ_v only in its disengaged, castoring branch.
V22. Castoring is free-swiveling wheel physics; strut's business, not the steering law's.
V23. Diagram (before/after), untyped fence.
V24. Re-factoring the steering contract to emit (engaged, ψ_cmd) and computing ψ_sw inside the strut deletes the backward wire outright.
V25. The factoring survives substitution.
V26. Surviving substitution is the test that it records structure rather than dodging the diagnostic [D-140].
V27. A stateful steering actuator produces ψ_cmd from its own state and still needs nothing from the strut.
V28. migration_outline.md records the migration.
V29. Rung: split the component; residual remedy, taken when both halves genuinely belong to the component and the split documents real structure.
V30. Its cost is stated where it bites.
V31. Visibility (§8.3) is binary.
V32. So every intermediate shared across the new boundary is declared in y_types, hence public, connectable, substitution-relevant.
V33. Mitigating idiom is the granularity guideline (§4.3), which the split case satisfies trivially with one producing stage and one consumer.
V34. The idiom spells out as one struct-valued bundle port (StrutGeometry-shaped value in the strut example), not N loose ports.
V35. The bundle port's type is then contract.
V36. That is a real cost, but bounded and honest.
V37. No visibility level is added for orphaned intermediates [D-194].
V38. D-034 and D-055 (unlisted, Private(T)) stay closed.
V39. The build diagnostic offers both exits explicitly [D-140].
V40. Quoted diagnostic: "cycle through `systems/aero` is artificial at port level — split the component, or narrow the neighbor's contract".
V41. The dead hop is the member with the input face (name a port wears on its component's boundary) it does not route to the output port.
V42. The diagnostic carries the dead hop as a separate payload field rather than dotting it onto the path [§8.6, §13.2, D-245].
V43. The component split is rare, and the ladder earns that word rather than asserting it [D-140].
V44. Two-stage split dissolves the common shapes.
V45. Contract re-factoring absorbs the false wires.
V46. Left for component split: cycles whose halves really are one component's own work.
V47. Stage-2 conservatism defined: presumption every stage-2 output depends on every wired input (§5.3).
V48. Consequence: an input consumed only by x_deriv, never y_direct, still creates a feedthrough edge if the component has stage-2 outputs.
V49. In practice such components are integrator-shaped and have no stage-2 outputs.
V50. The remedy, if ever needed, is the same ladder.
V51. A genuine cycle in the instantaneous dependency graph is an algebraic loop.
V52. **An algebraic loop is a build error** [D-005]. (bold)
V53. The build reports it as AlgebraicCycle (Appendix C).
V54. The diagnostic names every wire of the loop as a terminal pair in canonical slash form (§8.6), e.g. `aero/F → dyn/F, dyn/a → aero/a`.
V55. The user breaks the cycle explicitly by one of three routes: insert dynamics, insert explicit unit delay (UnitDelay, §13.7), or restructure.
V56. Dynamics route is the α-filter idiom, a filter state inserted in the loop.
V57. α-filter idiom is already standard practice in the domain.
V58. Unit delay changes the model's tier structure.
V59. Broken signal becomes discrete, sampled on a Δt_base-scale period (base tick period, integer multiple N_base·h).
V60. That is a modeling decision, not a transparent wire.
V61. The diagnostic states this caveat rather than offering the delay as a free remedy (§13.7).
V62. Implicit delays and per-step numerical loop solving are both closed [D-005].
V63. Implicit algebraic balances inside a component (e.g. turbomachinery operating point) remain the component author's business.
V64. They are local, owned and bounded.
V65. Rejecting framework-level loops does not forbid such models.
