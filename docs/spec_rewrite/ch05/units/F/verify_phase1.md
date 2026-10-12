# Unit F, phase 1 (blind): assertions in new.md

V1. Tracing is diagnostic only [D-012] (bold).
V2. Tracing is never relied on for correctness [D-012].
V3. Ordering correctness comes exclusively from the structural two-stage split.
V4. Tracing improves error messages and verification.
V5. When the build finds a cycle, it triggers the feedthrough tracer to classify that cycle.
V6. The feedthrough tracer is the set-propagation instrument that does the tracing (gloss).
V7. A genuine cycle gets "insert a state".
V8. An artificial cycle gets the remedy ladder [§5.4].
V9. (Pointer) the parts below cover detection/naming, two modes, what tracing touches, classification, caveats.
V10. A cycle surfaces as a topological-sort stall in the nominal evaluation.
V11. The nominal evaluation is the build's second step (gloss).
V12. The nominal evaluation is the one evaluation that feeds structure (gloss).
V13. The stalled subgraph is decomposed into SCCs.
V14. Each nontrivial SCC names one cyclic cluster exactly [D-012] (bold).
V15. Each cluster becomes one diagnostic, an AlgebraicCycle error [Appendix C].
V16. The diagnostic presents members and wires among them as one readable loop of terminal pairs in canonical slash form [§8.6], example `aero/F → dyn/F, dyn/a → aero/a`.
V17. Neither raw stall residue nor a single back edge names the cluster correctly [D-012].
V18. The feedthrough tracer has two modes.
V19. The two modes degrade gracefully.
V20. The global set-tracer is value-blind.
V21. The global set-tracer is a Real subtype carrying a set of input indices.
V22. That set is "its tracer tags" (gloss).
V23. The set is unioned by every operation.
V24. Global tracer has may-depend semantics, a sound over-approximation.
V25. A saturated clamp still reports.
V26. u^2 at u = 0 still reports.
V27. The global tracer is exact, in one evaluation.
V28. It requires traced stage-2 code free of branches and lookups on input-tainted values.
V29. The local set-tracer is primal-carrying and runs at sampled states.
V30. The local tracer is the fallback whenever the global tracer hits an undecidable branch.
V31. Examples of undecidable branches: piecewise friction, stall blending, any gridded lookup at an input-tainted coordinate.
V32. The local tracer reports the dependence pattern of taken paths, sampled across randomized states.
V33. Its only misses are untaken branches [D-012].
V34. Only inputs are seeded.
V35. So branching on state, modes, parameters or time never interferes.
V36. Stage-2 functions also receive state views, never seeded.
V37. The stage-1 hand-down is never seeded.
V38. Stage-1 functions are never traced, since there is nothing to seed.
V39. Derivatives, guards, handlers and projections are outside tracing's jurisdiction entirely.
V40. Guards are the declared functions defining each event's predicate (gloss).
V41. A known tracer blind spot is documented.
V42. Value-severing operations pass dependence through a bare Int index, as a nearest-neighbor lookup does (the blind spot).
V43. Linear and cubic interpolation are immune, because dependence flows through fractional weights.
V44. Both modes ride the same T <: Real genericity as Dual.
V45. Dual is ForwardDiff's dual number (gloss).
V46. Dual-cleanliness in CI (passing the T = Dual sweep of §7.2) effectively guarantees traceability.
V47. Classification needs no execution order [D-012] (bold).
V48. Execution order is the order in which stage functions run (gloss).
V49. Classification runs inside the nominal evaluation's failure path, where no execution order exists.
V50. None is needed because each SCC member is evaluated once, in isolation, at the probe point.
V51. The probe point is the initial state, where the build probes every user function (gloss).
V52. That evaluation reads state views from x_init, s_init, m_init declarations.
V53. Out-of-cycle cell values come from the acyclic prefix's probe values.
V54. In-cycle cell values are synthesized through probe_value [§9.3] under tracer tags.
V55. The tracer's product is a per-member dependence set rather than a value.
V56. So no ordering has to be valid for labels to come out right.
V57. The traced maps decide the verdict as one graph question over the cluster [D-245] (bold).
V58. Every wire holds.
V59. A hop inside a member runs from the face one wire enters to the port the next wire leaves.
V60. A face is the name a port wears on its component's boundary (gloss).
V61. The hop holds iff the member's map routes the face to the port.
V62. The loop is real iff a cycle survives in that graph.
V63. It is artificial [§5.4] iff none does.
V64. Artificial means every cycle through the cluster crosses a dead hop, at a component whose stage-2 function does not in fact route that input to that output.
V65. The diagnostic lists every dead hop under either verdict [D-245] (bold).
V66. So a real loop still shows the chords the trace found false.
V67. For a simple cycle this reduces to: loop is real iff every hop survives.
V68. Classification touches no activation machinery: no activation, no layouts, no table.
V69. An activation is the build's typed products at a given scalar type (gloss).
V70. The cycle classifier uses the local variant of tracing [D-012].
V71. The local variant is the order-free per-member trace at the probe point.
V72. The "tracer activation" [§9.4] names the other variant [D-012].
V73. The other variant is the global set-tracer run as an ordinary activation.
V74. The two must not be conflated.
V75. The local variant's name is unrelated to the local set-tracer mode.
V76. A member's map may come from either mode.
V77. The diagnostic carries the tracer's caveats rather than assuming them away.
V78. The trace speaks for the branch taken at the probe state (diagnostic-only doctrine) [D-012].
V79. Discrete members trace structurally [D-012] (bold).
V80. Because the discrete tier's plain, wholesale-pinning declarations admit no tracer scalar [D-012].
V81. Structural tracing is sound as a may-depend answer but never sharp.
V82. So the remedy hint is offered only for continuous members [D-140].
V83. A continuous face or port declared with no walking leaf admits no tracer scalar either.
V84. A walking leaf is one whose type follows the activation scalar (gloss).
V85. So hops through such a face/port trace structurally too [D-245].
V86. The diagnostic records the source of each member's map [D-245] (bold).
V87. The source is global tracer, sampled states, or structure.
V88. A reader can thus weigh a dead hop found on a few sampled paths against one found exactly.
V89. The hint is to split this component, or narrow the neighbor's contract when the dead hop's input is consumed only in a fallback branch [§5.4, D-140].
V90. A contract is a component's declared interface (gloss).
V91. If a member's evaluation throws, the diagnostic ships with members and wires alone, unclassified.
V92. Classification is a bonus on the cycle error, never its precondition [D-012] (bold).

Bolds: V1, V14, V47, V57, V65, V79, V86, V92 (eight).
