# Unit A verify, phase 1 (blind list of new.md assertions)

Opening
- V1. Ch 11 specifies the data plane: how data crosses between the loop (§10) and the periphery (GUI, input devices, network I/O, logging).
- V2. Ch 11 takes root inputs (§8.6) as given.
- V3. §11.1 covers the architecture that replaces FlightCore's shared mutable model.
- V4. §11.2 covers the outbound data channel, snapshot publication.
- V5. §11.3, §11.4, §11.5 cover the inbound data channel: root inputs, claims and frozen roster; per-device staging and drain; input trace.
- V6. §11.6 covers the device authoring contract.
- V7. §11.7 covers the GUI write path.
- V8. §11.8 covers the third cross-task channel, runtime diagnostics and liveness.
- V9. The machinery that drives the loop follows in §12.

§11.1 intro
- V10. Everything in the periphery runs on tasks the loop does not control.
- V11. Every one of them wants the data the loop is stepping.
- V12. FlightCore's answer is one big lock.
- V13. In FlightCore's sim.jl, SimControl and the live Model are guarded by io_lock.
- V14. FlightCore has one task per attached interface reading or mutating the model under it.
- V15. That lock enforces the boundary-visibility rule (§10.3), because it is only ever free between steps.
- V16. Transplanting it was rejected on three structural costs [D-022].
- V17. One of the three is decisive for everything below.
- V18. Under a lock, input timing is scheduler-determined and unrecorded.
- V19. There is then no defined input trace.
- V20. Bit-identical replay (§12.7) is then unachievable in principle for interactive runs.
- V21. Pointer: section sets out five planes, two rules, task topology, one consequence for execution modes.

Frame
- V22. The replacement has five planes.
- V23. Its unit of account is the frame (one grid step, §10.1).
- V24. Each frame is one loop iteration: drain, then integrate, then boundary sequence, then publish.
- V25. Drain gloss: the frame-top swap that applies staged device writes to the root inputs.
- V26. A frame is what step! counts.
- V27. The frame is the ordinal that keys the trace [D-101].
- V28. "Per frame" means this throughout the document.
- V29. Kinematic reference frames are a different word and always appear compounded (b frame, ECEF frame).

Planes
- V30. Staging is the inbound path.
- V31. Devices submit pending input writes at any wall-clock moment (§11.4).
- V32. Devices never touch live root inputs.
- V33. (bold) The drain is exactly one point in each frame, at its top [D-022].
- V34. At the drain the loop takes the staged batches and applies them to the root inputs.
- V35. The drain never happens at a t* boundary (§10.4).
- V36. Between drains the loop owns its data exclusively.
- V37. No lock is held during stepping, ever.
- V38. Publication is the outbound path.
- V39. At the end of each boundary sequence the loop publishes an immutable snapshot [D-022].
- V40. Readers observe it without coordinating with the loop (§11.2).
- V41. (bold) Control places pause, pace and stop on a separate few-word atomic surface [§12.1, D-022].
- V42. Task topology places one loop on the calling task (the task that invoked run!) [D-310].
- V43. Task topology places one spawned task per rostered device [D-310].
- V44. All these tasks are run-scoped [D-310].

Rules
- V45. Two rules bind the implementation.
- V46. (bold) Every handoff is one atomic reference operation [D-022].
- V47. Staging cell gloss: where a device's pending write batch waits between drains.
- V48. Staging cells and the published reference reduce their mutable surface to single words, release/acquire @atomic fields.
- V49. The GC is the reclamation mechanism.
- V50. An object a reader still holds is reachable and therefore never recycled.
- V51. That dissolves the reclamation problem (hazard pointers, epochs, RCU grace periods) that makes these patterns hard in non-GC languages.
- V52. Deep immutability of the exchanged objects is what makes this sound.
- V53. (bold) No user code, no unbounded work, ever, inside a framework critical section [D-022].
- V54. FlightCore's pathologies are all "arbitrary code under a shared lock".
- V55. Mappings run on device tasks.
- V56. Rendering runs against snapshots.
- V57. The loop's frame contains framework and model code only.
- V58. A stalled device produces stale snapshots and late staging.
- V59. A stalled device cannot stall the loop.
- V60. Two residual pre-existing exposures: GC pauses and OS scheduling.
- V61. The pacer's debt absorption is the mitigation for both.

Topology
- V62. Pointer: the fifth plane carries the most machinery.
- V63. (bold) Device tasks are run-scoped [D-093].
- V64. run! spawns one task per roster entry after device init!.
- V65. §12.4 joins them all at every stop (§12.6).
- V66. attach! never spawns.
- V67. attach! registers, in a stopped-sim state only (§11.3).
- V68. The task appears at the next run!.
- V69. (bold) The loop runs on the calling task [D-310].
- V70. Every rostered device runs on a spawned task.
- V71. The synchronous rethrow (§13.4) presupposes this.
- V72. It lets parallel unattended sweeps thread run! inline with no nested task fan-out.
- V73. One immutable Build is shared across the workers [§9.2, D-282].
- V74. Each Simulation owns its own buffers (§9.4).
- V75. Pre-materializing activations with build(world; activations = …) [§9.4, D-135] leaves no worker synchronizing on anything.
- V76. run! blocks its caller until the run ends.
- V77. Which devices get a task is fixed after initialization [D-310].
- V78. It is derived from the frozen roster and the outcomes of device init! [D-310].
- V79. It is never derived from run!'s keywords [D-310].
- V80. A device whose init! failed gets no task [§12.4, D-138].
- V81. (bold) Spawn-inside-run! is the start gate [D-093].
- V82. A task exists only once the run it serves exists.
- V83. Any first-boundary synchronization a device needs is the counter-plus-condition predicate wait (§12.3).
- V84. It is never a Base.Event latch.

Consequence
- V85. Recorded here because it collapses an API axis.
- V86. Interactive and unattended simulation stop being different execution modes [D-022].
- V87. An unattended run is the same loop with empty staging and no snapshot readers.
- V88. A replayed interactive session is the same loop with staging fed from a recording (§11.5, §12.7).
