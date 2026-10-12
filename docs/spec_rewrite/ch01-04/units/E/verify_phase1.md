# Unit E verify, phase 1 (blind)

Atomic assertions in units/E/new.md, with attached citations.

## Opening
- V1. This chapter gives the port, the addressable unit through which components exchange immutable values.
- V2. §4.1 states the immutable value semantics of signals.
- V3. §4.2 states why consumers see ports, not stages.
- V4. §4.3 gives the table mechanics and port granularity.
- V5. §4.4 gives function-valued signals for environment access.

## §4.1
- V6. (bold) Ports exchange immutable values. [D-004]
- V7. The values are typically isbits structs (floats, SVectors, enums, nested immutables).
- V8. The framework owns a signal table.
- V9. The table has one concretely typed cell per output port in the flattened model.
- V10. Every component provides two output stages, y_state/y_direct.
- V11. These exist on either tier.
- V12. Tier gloss: the continuous or discrete side of the hybrid formalism.
- V13. A producer's output stage function returns a named tuple of fresh values.
- V14. The framework writes each of those values into its cell.
- V15. Consumers read cells.
- V16. These names are binding throughout this document.
- V17. (bold) A bare cell is the table entry, and only that. [D-121]
- V18. A store is the framework-owned home of one of a component's state letters, x, s or m. [§7.1, §7.3, D-302]
- V19. An x store is a range of the buffer.
- V20. Buffer gloss: the contiguous vector backing all continuous state.
- V21. Stores are not cells.
- V22. A staging cell is a distinct compound term. [D-121]
- V23. It is the inbound register of §11.4.
- V24. There is one per device.
- V25. Device gloss: any attached participant outside the loop, such as the GUI.
- V26. Unlike a table cell, a staging cell is mutated frame by frame.
- V27. It sits outside the table's publish-once discipline.
- V28. A root input is a source cell fed by the periphery rather than by a producer. [§11.3]
- V29. Periphery gloss: everything outside the loop that exchanges data with it.
- V30. (bold) The signal requirement, stated precisely, is immutability plus frozen references. [D-243, D-231]
- V31. Signals may reference bulk data (§4.4) provided that data is read-only for the duration of the run.
- V32. isbits is the common case, not the rule.
- V33. The signal requirement has four consequences.
- V34. There is no aliasing, ever.
- V35. Nothing can be mutated under a consumer's feet.
- V36. Concurrent reads from the GUI and logging threads are safe by construction.
- V37. Isbits payloads allocate nothing.
- V38. Because named tuples of isbits are isbits.
- V39. Each cell has a definite freshness, tied to its producer's position in the execution order. [D-004]
- V40. Execution order gloss: the order in which the stage functions run.

## §4.2
- V41. The port is the addressable unit.
- V42. A component's outputs appear to consumers, the GUI and logs as one flat namespace of ports, such as "dyn/vel" and "dyn/f_c_c". [D-040]
- V43. A reader reaches a leaf inside a port value through the port's leaf address. [§14.4, D-276]
- V44. Leaf address gloss: the field name with dotted and bracketed steps below it.
- V45. Which output stage computes which port is an ordering annotation.
- V46. It is invisible outside the component.
- V47. Moving an output between stages is non-breaking for consumers.
- V48. No wire, log or panel sees it.
- V49. The build does see it.
- V50. Because the feedthrough graph and stage membership change. [§9.1]
- V51. Feedthrough gloss: the graph of instantaneous input-to-output dependences.
- V52. Which ports exist at all is a declaration-layer decision.
- V53. The output contract is the public interface. [D-034]
- V54. Contract gloss: the ports a component declares in y_types.
- V55. There are no private intermediates.
- V56. A value a later function needs is a declared port like any other. [D-194]
- V57. A stage result outside the contract is a build error (UndeclaredReturnField). [§5.2, §8.3]
- V58. A presentational unlisted flag, skipped in logs and GUI but still connectable, is closed. [D-016, D-034]

## §4.3
- V59. §4.2 fixed the port as the addressable unit.
- V60. Four questions remain (what a port is on the boundary; how values travel into and out of cells; what a port may hold; how much a port should carry).
- V61. Cell gloss: the typed entries of the signal table.
- V62. The last question has two answers, one owed to readers of a port and one to writers.
- V63. A component's ports are its signal endpoints.
- V64. Each has one cell and one producer.
- V65. (bold) Its faces are the names those ports wear on the component's boundary. [D-172]
- V66. For a leaf the two coincide.
- V67. Assembly gloss: pure composition of child components.
- V68. For an assembly every face aliases an interior port through its boundary declarations. [§8.6]
- V69. An assembly face never creates an endpoint.
- V70. The distinction is class-blind. [D-172]
- V71. Wiring and the periphery address a child's faces without knowing whether it is primitive or composite.
- V72. Periphery gloss repeated (everything outside the loop that exchanges data with it).
- V73. The port is the atomic unit of the entire periphery.
- V74. It is one cell.
- V75. It is one root input (gloss: a source cell the periphery feeds).
- V76. It is one staged write.
- V77. It is one device claim. [§11.3]
- V78. Claim gloss: the set of faces a device may write.
- V79. It is one trace address.
- V80. Trace gloss: the trace is the primary record of a session.
- V81. It is one GUI liveness verdict. [§11.7]
- V82. Scatter/gather is the whole protocol.
- V83. A stage function (y_state/y_direct) returns a named tuple on either tier, continuous or discrete.
- V84. The framework scatters each field into that port's concretely typed cell.
- V85. Every reader gathers views from cells.
- V86. The readers are the next stage x_deriv/s_update, guards, wired consumers and snapshot capture.
- V87. Guard gloss: the function defining an event's predicate.
- V88. Snapshot gloss: the immutable per-boundary publication.
- V89. (bold) The aggregate y is a merge semantically and virtual physically. [D-036]
- V90. Semantically, a component's y is the merge of its stage products, merge(y_x, y_xu) continuous and merge(y_s, y_su) discrete. [§5.2]
- V91. y carries declared ports only.
- V92. Physically no such object exists.
- V93. y is reconstructed per call from cells.
- V94. As register-level field loads at zero cost for isbits.
- V95. y is never stored as an object.
- V96. Name collisions across a component's stages are a build error (ProducedByTwoStages). [§8.3]
