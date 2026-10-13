# Unit F, phase 1 (blind): assertions in new.md

V1. The input trace is the sequence of drained, device-tagged batches per frame. [glossary links]
V2. A device is any attached participant in the periphery.
V3. A batch is a device's staged set of writes.
V4. A frame is one iteration of the loop, from drain to publication.
V5. The trace extends the determinism end-to-end. [§10.7]
V6. Replay re-runs the ordinary loop on a recorded input trace.
V7. Replaying a recorded interactive session reproduces the trajectory bit-identically. [§2.4]
V8. In replay, staging is fed from the recording, with no devices or mappings present.
V9. (bold) The trace retains every batch sparse, in one record format. [D-176]
V10. The drain is the frame-top swap that applies staged device writes to the root inputs.
V11. At the drain each drained staging cell is scanned.
V12. A staging cell is the per-device holding place where a device's pending batch waits between drains.
V13. A staging cell's masked (touched) batch entries are recorded as (position => value) pairs.
V14. Pairs are keyed against the writer's face-name -> position schema in the `schemas` list.
V15. A face is the name a port wears on its component's boundary.
V16. The scan is O(surface-width), with one small allocation per drained batch.
V17. The rule is uniform because a claim's width is a fact about one binding, not about a category of writers.
V18. A binding is the value passed at `attach!` that makes a device framework-legible.
V19. A claim is the set of faces a device may write.
V20. A greedy claim is the unclaimed complement the framework computes at attach.
V21. A greedy claim is enumerated and as wide as the root contract.
V22. The root contract is the root's declared interface. [§11.3]
V23. Keying retention by claim source is rejected. [D-176]
V24. Every consumer handles one format instead of two.
V25. There is one record format at the trace's edge and no per-record format flag.
V26. There is one decoder in the edited-inputs what-if (replay with edited inputs), in disk serialization and in human inspection.
V27. There is one inverse conversion in replay.
V28. That work is paid once, up front, off the loop. [§12.7]
V29. The conversion site is the drain, not the staging shim.
V30. Reason: the drained tuple is the coalesced truth.
V31. A shim-side sparse log would need its own merge.
V32. The format's costs are recorded rather than argued away.
V33. On wide writers the conversion keeps the trace honest.
V34. Without it, a tuple as wide as the unclaimed surface carrying one edit would make trace size track surface width rather than information.
V35. At hundreds of faces, render-rate dragging would inflate the trace past the two-orders-below-the-log budget. [D-029]
V36. That budget justifies trace-on-by-default. [D-029]
V37. A component is the unit of modeling, a leaf or an assembly.
V38. On the dense component the conversion costs about 2x: a position beside every value where the positional tuple carried the value alone.
V39. That changes no order of magnitude.
V40. It leaves the budget standing for every writer at once. [D-029]
V41. The allocation is of the same sort the retention carve-out already admits. [§9.8]
V42. A boundary is a published consistency point.
V43. Per boundary the allocation is smaller than the log's snapshot.
V44. The snapshot is the immutable per-boundary publication.
V45. The log is the retained sequence of published snapshots.
V46. The snapshot is the carve-out's standing occupant.
V47. The snapshot is the one qualified exception to retains-what-was-already-allocated.
V48. The decision is reversible as pure implementation.
V49. The conversion is lossless in both directions.
V50. Hence verbatim retention could return as a per-record storage optimization if a marathon-session measurement asks for it.
V51. Such a return would leave the record semantics, the header and the replay path unchanged.
V52. The trace header is the trace's fixed preamble.
V53. A checkpoint is the Model's state at a frame top as one value.
V54. (bold) The header is the checkpoint `init!` takes at the end of boundary zero, after the first snapshot is published. [§12.6, D-274]
V55. Boundary zero is the initialization boundary at t0.
V56. A checkpoint holds x, the s and m stores, the whole signal table, the guard priors, t and t0, the frame and boundary counters, and the fingerprint. [D-319]
V57. The signal table is the collection of cells holding every produced signal.
V58. A prior is an event's stored predicate sample from the previous boundary.
V59. The executor's clock holds t and t0. [D-317]
V60. The run holds the frame index and the boundary ordinal. [D-317]
V61. The run is the state one run owns.
V62. The executor is the compiled form of the stage execution order.
V63. The header holds the stores and the root-input cells as values, never the sparse authored overlay.
V64. Root inputs are the root component's own input faces.
V65. Reason: replay must survive edits to declared defaults (primary-data doctrine). [D-038]
V66. An unfed `mixture = 0.5` never appears in any batch, so replay is broken without the root inputs. [D-047]
V67. The init/trim services own root-input initialization. [§14.6]
V68. The checkpoint's table holds the values those services wrote.
V69. The fingerprint is the structural layout.
V70. The deployment is the scalar-free artifact the grid parameters fix.
V71. Fingerprint and deployment are the header parts replay compares rather than restores. [§12.7]
V72. The header also carries the run's Deployment and the structural layout.
V73. The deployment comes from §9.2.
V74. It carries Δt_base, h, N_base, algorithm id, localization_tol, localization_budget [§10.4], firing_budget [§10.6, D-254].
V75. The layout is the store layout and the root-input faces the Build fixes.
V76. The Build is the artifact build(world) produces.
V77. The layout also holds what a copy by position relies on: each component's x type, each cell's address with type, and the event list in prior order.
V78. Deployment and layout are taken at the same instant as the state.
V79. The deployment holds no policy. [D-255]
V80. t_end and ignore_stop_requests are keywords of each advance. [§13.5, D-316]
V81. Only the terminating advance's policy explains the stop.
V82. So the termination record carries that policy.
V83. The termination record is the stopped-sim value naming how the run ended.
V84. The trajectory depends on the deployment exactly as on the stores. [§2.4]
V85. The Deployment constructor sits outside the Build. [§9.2]
V86. The checkpoint carries the clock, t0 included. [§14.5]
V87. Hence a header without them could not back the bit-identity claim. [§12.7]
V88. The header is what the artifact's run metadata names. [§13.5, Appendix B]
V89. Run metadata is the header's Deployment and t0.
V90. A checkpoint is the one full-state capture. [§12.6, D-274]
V91. It is taken by init! for the header and by checkpoint(sim) on demand. [§12.6, D-274]
V92. The header is the other half of what "given the initial state and the trace, the log is recomputable" requires.
V93. (bold) Trace is that fixed header plus two append-only lists, schemas and batches, and its length. [D-255]
V94. A trace records a Simulation, which runs only a Model{Float64}. [D-317]
V95. So Trace takes no scalar parameter. [D-317]
V96. The header is written once, by the door that builds the run, and never again.
V97. That is what makes it an artifact.
V98. The lists grow in place: batches at every drain, schemas at every roster change.
V99. The roster is the immutable list of attached devices.
V100. The length is the frame index of the last drain on the live trace. [D-217]
V101. The length is frozen into the value trace(sim) hands back. [D-217]
V102. The length advances at the top of each drain. [D-260]
V103. The frame ordinal every record of that drain carries is this value. [D-260]
V104. Under init! that value is the number of drains since the header was taken.
V105. A trace that restore! opens starts at the checkpoint's frame. [D-274]
V106. So its records keep the trajectory's own frame indices. [D-274]
V107. A recording whose last frames drained nothing still ran them. [§12.7, D-218]
V108. Every advance in :replay is capped at that frame. [§12.7, D-218]
V109. Each writer's face-name -> position schema lives in the schemas list.
V110. Positional records are meaningless without it.
V111. Replay does not reconstruct claims. [§12.7]
V112. (bold) The list only grows. [D-217]
V113. attach! and detach! push the current writer set onto it in place. [D-255]
V114. Reason: a roster change between advances recompiles the harness writer and the same face moves position. [§12.6]
V115. The harness writer is the framework-owned write path of the calling task.
V116. Earlier records keep their index.
V117. A record resolves only through its own schema entry.
V118. (bold) Trace recording is on by default. [D-029]
V119. init! builds a fresh trace with the run under its trace keyword. [§12.6, Appendix B, D-261]
V120. The trace is retrievable after the run.
V121. A plain kill switch covers memory-constrained marathon sessions.
V122. The deciding asymmetry: the trace is primary data, the log derived.
V123. Header plus batches are the primary record. [§11.2, D-038]
V124. Everything else, the state trajectory included, is derived. [§11.2, D-038]
V125. Given the initial state and the trace, the log is recomputable. [§2.4]
V126. That is what bit-identical replay means. [§2.4]
V127. An untraced interactive session is permanently unreproducible.
V128. The cost supports the default.
V129. The trace retains one small sparse record per drained batch, at drain-rate x device-count.
V130. That is tens of MB per hour worst case.
V131. That is two orders of magnitude below the snapshot log.
V132. There is no sampling and no rolling window. [D-029]
