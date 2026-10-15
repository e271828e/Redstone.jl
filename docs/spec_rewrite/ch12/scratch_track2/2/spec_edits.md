### C1. D-401 (§12.1)

Old:

```
by contrast, is cleared at the top of each run, because a stop belongs to the
run it ended. A pause left set by a run that stopped while paused would
```

New:

```
by contrast, is cleared at the top of each run ([D-401][d-401]), because a stop belongs
to the run it ended. A pause left set by a run that stopped while paused would
```

### C2. D-399 (§12.1)

Old:

```
owns), not to `Control` ([§12.6][s12-6], [D-255][d-255]). The control plane is
```

New:

```
owns), not to `Control` ([§12.6][s12-6], [D-255][d-255], [D-399][d-399]). The control plane is
```

### C3. D-386 (§12.2)

Old:

```
structurally absent from framework tasks.
```

New:

```
structurally absent from framework tasks ([D-386][d-386]).
```

### C4. D-392 (§12.2)

Old:

```
attached device entries ([§11.3][s11-3]). Tight means fewer threads than the roster plus
one. Every rostered device is a task, and the [calling task](#g-calling-task) (the task that
invoked `run!`) hosts the loop, so a run occupies one task more than its roster
([D-310][d-310]). The sizing guidance behind the remedy is one thread for the loop and
headroom for compute-heavy or blocking-ccall devices. I/O backed by libuv (the
I/O library under Julia's tasks) yields. Raw blocking ccalls pin their thread
for the duration. There is no pinning and there are no sticky tasks.
```

New:

```
attached device entries ([§11.3][s11-3], [D-392][d-392]). Tight means fewer threads than the
roster plus one. Every rostered device is a task, and the [calling task](#g-calling-task) (the task
that invoked `run!`) hosts the loop, so a run occupies one task more than its
roster ([D-310][d-310]). The sizing guidance behind the remedy is one thread for the loop
and headroom for compute-heavy or blocking-ccall devices. I/O backed by libuv
(the I/O library under Julia's tasks) yields. Raw blocking ccalls pin their
thread for the duration. There is no pinning and there are no sticky tasks.
```

### C5. D-395 (§12.2)

Old:

```
is advisory. It is a liveness display and a record, never a kill trigger,
never a detach. It must also tolerate a device legitimately parked in a
```

New:

```
is advisory ([D-395][d-395]). It is a liveness display and a record, never a kill
trigger, never a detach. It must also tolerate a device legitimately parked in a
```

### C6. D-389 (§12.4)

Old:

```
run-scoped observables. A device unplugged while stopped surfaces as the
```

New:

```
run-scoped observables ([D-389][d-389]). A device unplugged while stopped surfaces as the
```

### C7. D-396 (§12.4)

Old:

```
([D-138][d-138], [Appendix C][sC]). Its [payload](#g-payload) (the
```

New:

```
([D-138][d-138], [D-396][d-396], [Appendix C][sC]). Its [payload](#g-payload) (the
```

### C8. D-396 (§12.4)

Old:

```
top ([D-138][d-138]). That needs no machinery. Its `task_state` reads `:done` from the
```

New:

```
top ([D-138][d-138], [D-396][d-396]). That needs no machinery. Its `task_state` reads `:done` from the
```

### C9. D-396 (§12.4)

Old:

```
The claims of a failed device persist to run end ([D-138][d-138]). This is the
```

New:

```
The claims of a failed device persist to run end ([D-138][d-138], [D-396][d-396]). This is the
```

### C10. D-396 (§12.4)

Old:

```
([D-138][d-138]). With the flag clear, which is the default
```

New:

```
([D-138][d-138], [D-396][d-396]). With the flag clear, which is the default
```

### C11. D-394 (§12.4)

Old:

```
([D-132][d-132]). [Unattended runs](#g-unattended-run), those with empty
```

New:

```
([D-132][d-132], [D-394][d-394]). [Unattended runs](#g-unattended-run), those with empty
```

### C12. D-394 (§12.4)

Old:

```
([D-132][d-132]). The reason is that an `InterruptException` is delivered asynchronously.
An interrupt landing in the middle of a [sweep](#g-sweep) (one pass through the execution
order) would therefore destroy the boundary this protocol is built on
completing. It would also leave [stores](#g-store) (the framework-owned homes of a
```

New:

```
([D-132][d-132], [D-394][d-394]). The reason is that an `InterruptException` is delivered
asynchronously. An interrupt landing in the middle of a [sweep](#g-sweep) (one pass through
the execution order) would therefore destroy the boundary this protocol is built
on completing. It would also leave [stores](#g-store) (the framework-owned homes of a
```

### C13. D-401 (§12.4)

Old:

```
([D-268][d-268]). The frame's own throw is the disposition
```

New:

```
([D-268][d-268], [D-401][d-401]). The frame's own throw is the disposition
```

### C14. D-401 (§12.4)

Old:

```
**A forced throw reaches the defensive arm** ([D-268][d-268]). Julia stops deferring
```

New:

```
**A forced throw reaches the defensive arm** ([D-268][d-268], [D-401][d-401]). Julia stops deferring
```

### C15. D-394 (§12.4)

Old:

```
immediately** ([D-132][d-132]). That is (5)'s abandonment path taken at once,
```

New:

```
immediately** ([D-132][d-132], [D-394][d-394]). That is (5)'s abandonment path taken at once,
```

### C16. D-400 (§12.6)

Old:

```
that door's declaration, and the next door may declare otherwise ([D-261][d-261]).
```

New:

```
that door's declaration, and the next door may declare otherwise ([D-261][d-261], [D-400][d-400]).
```

### C17. D-399 (§12.6)

Old:

```
the lifecycle state below says whether that run ever started. The placeholder
carries no configuration and no compiled state ([D-261][d-261]). `init!`
```

New:

```
the lifecycle state below says whether that run ever started ([D-399][d-399]). The
placeholder carries no configuration and no compiled state ([D-261][d-261]). `init!`
```

### C18. D-387 (§12.6)

Old:

```
[replay](#g-replay), not resurrection ([§12.7][s12-7]). Replay is the ordinary
```

New:

```
[replay](#g-replay), not resurrection ([§12.7][s12-7], [D-387][d-387]). Replay is the ordinary
```

### C19. D-388 (§12.6)

Old:

```
returns ([D-088][d-088]). A stepped simulation is bit-identical to the same
```

New:

```
returns ([D-088][d-088], [D-388][d-388]). A stepped simulation is bit-identical to the same
```

### C20. D-390 (§12.6)

Old:

```
the duration spelling. It is mutually exclusive with `frames`, and passing
```

New:

```
the duration spelling ([D-390][d-390]). It is mutually exclusive with `frames`, and passing
```

### C21. D-389 (§12.6)

Old:

```
**A stepping session is deviceless by construction** ([D-093][d-093]). Device
```

New:

```
**A stepping session is deviceless by construction** ([D-093][d-093], [D-389][d-389]). Device
```

### C22. D-390 (§12.6)

Old:

```
([D-096][d-096]). Both entry points work under `run!` too. The harness cell is
```

New:

```
([D-096][d-096], [D-390][d-390]). Both entry points work under `run!` too. The harness cell is
```

### C23. D-390 (§12.6)

Old:

```
termination untouched ([§13.5][s13-5], [D-096][d-096]).
```

New:

```
termination untouched ([§13.5][s13-5], [D-096][d-096], [D-390][d-390]).
```

### C24. D-388 (§12.6)

Old:

```
Between `step!` calls a simulation reports `initialized` ([D-088][d-088]). No
```

New:

```
Between `step!` calls a simulation reports `initialized` ([D-088][d-088], [D-388][d-388]). No
```

### C25. D-388 (§12.6)

Old:

```
`stopped`. `step!` therefore returns the number of frames *actually advanced*.
That is the requested count in the ordinary case, and fewer when the run
terminated inside the call. That return is how a harness detects the truncation
without inspecting the clock.
```

New:

```
`stopped` ([D-388][d-388]). `step!` therefore returns the number of frames *actually
advanced*. That is the requested count in the ordinary case, and fewer when the
run terminated inside the call. That return is how a harness detects the
truncation without inspecting the clock.
```

### C26. D-388 (§12.6)

Old:

```
**`stopped → init! → run!` remains the authored re-run** ([D-088][d-088]).
```

New:

```
**`stopped → init! → run!` remains the authored re-run** ([D-088][d-088], [D-388][d-388]).
```

### C27. D-388 (§12.6)

Old:

```
**Device attachments persist across re-initialization** ([D-088][d-088]), because
```

New:

```
**Device attachments persist across re-initialization** ([D-088][d-088], [D-388][d-388]), because
```

### C28. D-402 (§12.7)

Old:

```
applied twice and nothing is skipped ([D-274][d-274]).
```

New:

```
applied twice and nothing is skipped ([D-274][d-274], [D-402][d-402]).
```

### C29. D-397 (§12.7)

Old:

```
than the end of an operation ([D-218][d-218]). Whatever advances the simulation next
reads the same mode and finds the same records. That is what lets the
```

New:

```
than the end of an operation ([D-218][d-218], [D-397][d-397]). Whatever advances the simulation
next reads the same mode and finds the same records. That is what lets the
```

### C30. D-393 (§12.7)

Old:

```
deterministically ([D-127][d-127]). A replay honours requests by default too, and the
trace header records no policy. So a replay of a live run that ignored some must
pass the same `ignore_stop_requests`.
```

New:

```
deterministically ([D-127][d-127], [D-393][d-393]). A replay honours requests by default too, and
the trace header records no policy. So a replay of a live run that ignored some
must pass the same `ignore_stop_requests`.
```

### C31. D-398 (§12.7)

Old:

```
append to the re-recorded prefix. `live!` is a stopped-sim operation, legal only
on an `initialized` simulation in `:replay`. Every other state refuses under the
ordinary lifecycle gates ([§12.6][s12-6]), with `MissingInit` at `built` and
```

New:

```
append to the re-recorded prefix ([D-398][d-398]). `live!` is a stopped-sim operation,
legal only on an `initialized` simulation in `:replay`. Every other state refuses
under the ordinary lifecycle gates ([§12.6][s12-6]), with `MissingInit` at `built` and
```

### C32. D-391 (§12.7)

Old:

```
**Replay re-records** ([D-101][d-101]). The drain records normally. Under the
```

New:

```
**Replay re-records** ([D-101][d-101], [D-391][d-391]). The drain records normally. Under the
```

### C33. D-391 (§12.7)

Old:

```
**[Pacing](#g-pacing) and the [control plane](#g-control-plane) are unchanged** ([§10.7][s10-7], [§12.1][s12-1], [D-101][d-101]). The
```

New:

```
**[Pacing](#g-pacing) and the [control plane](#g-control-plane) are unchanged** ([§10.7][s10-7], [§12.1][s12-1], [D-101][d-101], [D-391][d-391]). The
```

### C34. D-391 (§12.7)

Old:

```
**Validation is loud and up front** ([D-101][d-101]). Before the first frame, the
```

New:

```
**Validation is loud and up front** ([D-101][d-101], [D-391][d-391]). Before the first frame, the
```

### C35. D-391 (§12.7)

Old:

```
the trace's `schemas` list, once, off the loop ([D-101][d-101],
```

New:

```
the trace's `schemas` list, once, off the loop ([D-101][d-101], [D-391][d-391],
```

### C36. D-391 (§12.7)

Old:

```
*Structural* mismatch is an error. *Parametric* difference is not
([D-101][d-101]).
```

New:

```
*Structural* mismatch is an error. *Parametric* difference is not
([D-101][d-101], [D-391][d-391]).
```

### C37. D-402 (§12.7)

Old:

```
frame ([D-274][d-274]).
```

New:

```
frame ([D-274][d-274], [D-402][d-402]).
```
