# Unit B verify, phase 1 (blind read of new.md)

V1. Once both endpoints of a wire resolve, two clauses type-check it. [§8.2]
V2. The first clause is the nominal bound check. [#g-nominal]
V3. Nominal means the Float64 activation (the build's typed products at a given scalar type) and a declaration's Float64 face. [#g-activation]
V4. The bound check is stated over declaration evaluations.
V5. The producer's declaration at Float64 must be <: the consumer's input entry at Float64. [D-078]
V6. The bound check is one uniform rule; it degenerates to exact equality for a concrete entry.
V7. A bound-check violation is WireTypeMismatch.
V8. The second clause is the walk-compatibility clause; it applies to a continuous consumer only.
V9. A walking producer leaf (one the producer left unpinned) requires an unpinned entry. [#g-walked]
V10. A pinned producer leaf (declared Pinned) satisfies either entry.
V11. Causal: because frozen values embed upward under any activation.
V12. A discrete consumer takes the bound check alone.
V13. So a continuous producer feeding a discrete consumer is unconditionally legal, for the reason §8.2 gives. [§8.2, D-295, D-263]
V14. The producer's declaration and the entry are plain declarations the walk retypes.
V15. So the walk clause is decided in the structure step by retyping them at a marker scalar.
V16. That is declaration reading; no user stage code runs. [§9.1]
V17. Definition: an abstract entry is an input entry whose declared type is abstract. [#g-abstract-entry]
V18. (bold) The walk clause decides an abstract entry on the whole declaration. [D-236]
V19. Causal: because its leaves cannot be enumerated. [D-236]
V20. Test: producer's declaration at the marker, or the same with every pinned leaf lifted to the marker, must be <: the entry at the marker. [D-236]
V21. The walk clause admits an opaque leaf on the same terms.
V22. An opaque leaf is a handle stored whole. [§4.3]
V23. An opaque leaf has no scalar position to embed through, and the walk clause does not need one.
V24. (bold) A frozen handle arriving at an unpinned entry is the producer's cell, gathered as stored. [#g-cell, D-264]
V25. Gloss: cell = its output's entry in the signal table.
V26. The consumer's own arithmetic promotes whatever it reads from it.
V27. A discrete producer of a handle pins wholesale.
V28. A discrete producer of a handle is admitted the same way.
V29. (bold) The identity rule for an opaque leaf governs a store, never a wire. [§9.5, D-264]
V30. Consequence of that rule: a component that re-emits a frozen handle pins that output too. [D-264]
V31. So a handle's pin is a property of its chain. [D-264]
V32. A walk-clause violation is WalkingFaceAtFrozenEntry, naming both endpoints, the leaf and both declared leaf types.
V33. The message carries both remedies, quoted: "remove the entry's `Pinned` if the consumer promotes; feed it from a non-walking source if the freeze is genuine".
V34. The Freeze block is the one-line spelling of the second remedy. [§13.7, D-266]
V35. The walk clause gives the two contract sides their failure asymmetry. [#g-contract]
V36. A pin written at an entry whose consumer really promotes fails at the first nominal build, at the wire, with both endpoints named. [D-263]
V37. Causal: it fails there because an input has a build-time counterparty.
V38. The output side has no build-time counterparty.
V39. So a pin written at a leaf that really participates lurks until the first Dual activation. 
V40. It lurks loudly, never silently. [§8.2, D-286]
V41. Fan-out is free; one producer may feed many consumers.
V42. (bold) Every input port takes exactly one connection, with no exceptions. [D-170]
V43. Aggregation is done by junctions. [§6.2]
V44. The rule spans levels. [D-170]
V45. A child input fed by a local wire at its own level and handed up through its parent's input_wires is a two-producers build error, TwoProducers.
V46. Routing a face upward cannot silently double-feed.
V47. There is no auto-bubbling of unconnected inputs. [D-043]
V48. Unconnected input ports are a build error, with no silent defaults.
V49. The check is a whole-tree property, not per-declaration. [D-048]
V50. Both this check and the two-producers check are decided at the root. [D-048]
V51. Causal: since neither is decidable below it. [D-048]
V52. Within a single assembly declaration an unfed child input is awaiting a wire from above: a local wire or an input_wires entry handing the obligation up one level. [§8.6]
V53. The error UnconnectedInput fires at the root build for any input whose obligation chain never terminates.
V54. The one legitimate terminus fed by no component is the root component's own input face, a root input. [#g-component, #g-root-input, §11.3, D-208]
V55. (bold) Unconnected output ports are legal, silently, with no build-time warning. [D-084]
