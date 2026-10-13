### 3.1. §11.1, old line 6884: D-367

Old:

````text
**Spawn-inside-`run!` is the start gate** ([D-093][d-093]). A task exists only once the
run it serves exists. Any first-boundary synchronization a device needs is the
counter-plus-condition predicate wait ([§12.3][s12-3]), never a `Base.Event` latch.
````

New:

````text
**Spawn-inside-`run!` is the start gate** ([D-093][d-093], [D-367][d-367]). A task exists only
once the run it serves exists. Any first-boundary synchronization a device needs
is the counter-plus-condition predicate wait ([§12.3][s12-3]), never a `Base.Event`
latch.
````

### 3.2. §11.2, old line 7014: D-368

Old:

````text
default is 65536 (2¹⁶), with `Inf` the explicit opt-out ([D-137][d-137]). The four
````

New:

````text
default is 65536 (2¹⁶), with `Inf` the explicit opt-out ([D-137][d-137], [D-368][d-368]). The four
````

### 3.3. §11.2, old line 7021: D-368

Old:

````text
**The bound is a count, not a memory budget** ([D-137][d-137]). Snapshots are immutable
object graphs ([§4.1][s4-1]) with internal sharing. A [field handle](#g-field-handle) (an immutable query
object consumers evaluate at their own arguments, [§4.4][s4-4]) rides as a reference to
build-time-frozen data ([§9.8][s9-8]). Byte accounting over snapshots is therefore fuzzy
and platform-dependent. A count is exact. It converts to memory through one
number the user can measure once, `Base.summarysize` of a single snapshot.
````

New:

````text
**The bound is a count, not a memory budget** ([D-137][d-137], [D-368][d-368]). Snapshots are
immutable object graphs ([§4.1][s4-1]) with internal sharing. A [field handle](#g-field-handle) (an
immutable query object consumers evaluate at their own arguments, [§4.4][s4-4]) rides as
a reference to build-time-frozen data ([§9.8][s9-8]). Byte accounting over snapshots is
therefore fuzzy and platform-dependent. A count is exact. It converts to memory
through one number the user can measure once, `Base.summarysize` of a single
snapshot.
````

### 3.4. §11.2, old line 7028: D-368

Old:

````text
**The default is finite unconditionally** ([D-137][d-137]). It is not a modal rule keyed
on `t_end`. A finite run shorter than the bound never notices the bound, and one
number is easier to hold than two regimes. At 50 Hz and full density, 2¹⁶
boundaries is about 22 minutes before anything is dropped at all.
````

New:

````text
**The default is finite unconditionally** ([D-137][d-137], [D-368][d-368]). It is not a modal rule
keyed on `t_end`. A finite run shorter than the bound never notices the bound,
and one number is easier to hold than two regimes. At 50 Hz and full density,
2¹⁶ boundaries is about 22 minutes before anything is dropped at all.
````

### 3.5. §11.2, old line 7034: D-368

Old:

````text
([D-137][d-137]). A rolling window, with the recent past at full density and the start of
the session forgotten, was rejected ([D-137][d-137]). Instead the log re-decimates
progressively. After *k* generations the effective stride is `log_every · 2^k`.
The whole run stays plottable, and what coarsens is density, never extent.
````

New:

````text
([D-137][d-137], [D-368][d-368]). A rolling window, with the recent past at full density and the
start of the session forgotten, was rejected ([D-137][d-137]). Instead the log
re-decimates progressively. After *k* generations the effective stride is
`log_every · 2^k`. The whole run stays plottable, and what coarsens is density,
never extent.
````

### 3.6. §11.2, old line 7044: D-368

Old:

````text
**The guarantees are normative, not the mechanism** ([D-137][d-137]). There are three.
The bound is respected continuously, and the retained count never exceeds
````

New:

````text
**The guarantees are normative, not the mechanism** ([D-137][d-137], [D-368][d-368]). There are
three. The bound is respected continuously, and the retained count never exceeds
````

### 3.7. §11.2, old line 7047: D-368

Old:

````text
retained unconditionally** ([D-137][d-137]).
````

New:

````text
retained unconditionally** ([D-137][d-137], [D-368][d-368]).
````

### 3.8. §11.2, old line 7081: D-368

Old:

````text
policy, not a trajectory-determining one** ([D-137][d-137]). Like `log` and `log_every`
it stays out of the trace header's [`Deployment`](#g-deployment) (the scalar-free artifact the
grid parameters fix), and replay neither records nor compares it ([§11.5][s11-5], [§12.7][s12-7]).
Sizing follows. A finite `log_max` is the log's `sizehint!` ([§9.8][s9-8]).
````

New:

````text
policy, not a trajectory-determining one** ([D-137][d-137], [D-368][d-368]). Like `log` and
`log_every` it stays out of the trace header's [`Deployment`](#g-deployment) (the scalar-free
artifact the grid parameters fix), and replay neither records nor compares it
([§11.5][s11-5], [§12.7][s12-7]). Sizing follows. A finite `log_max` is the log's `sizehint!`
([§9.8][s9-8]).
````

### 3.9. §11.3, old line 7262: D-370

Old:

````text
rather than claimed ([D-174][d-174]). It is the unclaimed complement, the faces no
````

New:

````text
rather than claimed ([D-174][d-174], [D-370][d-370]). It is the unclaimed complement, the faces no
````

### 3.10. §11.3, old line 7266: D-370

Old:

````text
naming the incumbent, [D-174][d-174]). A rostered greedy claimant empties that surface
outright. The greedy claim is itself a rostered claim, so the complement it
leaves is empty and every `stage!` in such a session is rejected that way
````

New:

````text
naming the incumbent, [D-174][d-174], [D-370][d-370]). A rostered greedy claimant empties that
surface outright. The greedy claim is itself a rostered claim, so the complement
it leaves is empty and every `stage!` in such a session is rejected that way
````

### 3.11. §11.3, old line 7287: D-376

Old:

````text
**The init/trim services own root-input initial values** ([D-047][d-047]). Input
````

New:

````text
**The init/trim services own root-input initial values** ([D-047][d-047], [D-376][d-376]). Input
````

### 3.12. §11.3, old line 7327: D-375

Old:

````text
Identity is the device instance. The same object (`===`) may occupy at most one
roster entry. Two instances of the same type, two joysticks say, are two
devices. The stable device id the trace, heartbeat and diagnostics speak is
````

New:

````text
Identity is the device instance ([D-375][d-375]). The same object (`===`) may occupy at
most one roster entry. Two instances of the same type, two joysticks say, are
two devices. The stable device id the trace, heartbeat and diagnostics speak is
````

### 3.13. §11.3, old line 7334: D-375

Old:

````text
Admission is a two-part check at the attach point, in order:
````

New:

````text
Admission is a two-part check at the attach point, in order ([D-375][d-375]):
````

### 3.14. §11.3, old line 7354: D-374

Old:

````text
**Device death does not detach** ([D-106][d-106]). A mid-run crash, voluntary exit or
unplug ([§11.6][s11-6], [§12.4][s12-4]) ends the device's *task*. The staging cell stops filling,
the heartbeat ([§12.2][s12-2]) shows the death by name, and the roster entry, claims
included, persists to the end of the run. The [orphaned claims](#g-orphaned-claims) (the claims of a
device whose task died mid-run) are the accepted cost of the freeze. The
````

New:

````text
**Device death does not detach** ([D-106][d-106], [D-374][d-374]). A mid-run crash, voluntary exit
or unplug ([§11.6][s11-6], [§12.4][s12-4]) ends the device's *task*. The staging cell stops
filling, the heartbeat ([§12.2][s12-2]) shows the death by name, and the roster entry,
claims included, persists to the end of the run. The [orphaned claims](#g-orphaned-claims) (the claims
of a device whose task died mid-run) are the accepted cost of the freeze. The
````

### 3.15. §11.3, old line 7371: D-374

Old:

````text
Attaching one mid-run would therefore move no writer's surface ([D-106][d-106]). A
````

New:

````text
Attaching one mid-run would therefore move no writer's surface ([D-106][d-106], [D-374][d-374]). A
````

### 3.16. §11.4, old line 7526: D-370

Old:

````text
The harness cell gets the same treatment ([D-174][d-174]). Under the [roster freeze](#g-the-freeze)
````

New:

````text
The harness cell gets the same treatment ([D-174][d-174], [D-370][d-370]). Under the [roster freeze](#g-the-freeze)
````

### 3.17. §11.4, old line 7555: D-370

Old:

````text
([D-174][d-174]). And a value that cannot convert to its root input's declared type is
discarded with `EntryTypeMismatch` ([Appendix C][sC], [D-105][d-105]), at the same spot.
````

New:

````text
([D-174][d-174], [D-370][d-370]). And a value that cannot convert to its root input's declared
type is discarded with `EntryTypeMismatch` ([Appendix C][sC], [D-105][d-105]), at the same
spot.
````

### 3.18. §11.4, old line 7559: D-044

Old:

````text
only the drain can know, and the drain is pure application ([D-106][d-106]).
````

New:

````text
only the drain can know, and the drain is pure application ([D-106][d-106], [D-044][d-044]).
````

### 3.19. §11.4, old line 7576: D-374

Old:

````text
([D-106][d-106]). The staging cells and their scatters form a heterogeneous but *known*
tuple the frame function can specialize on, which means zero dynamic dispatch at
frame top. That is the same per-configuration compile trade the [executor](#g-executor) (the
compiled form of the stage execution order, [§9.7][s9-7]) already makes, now incurred
only at stopped-sim attach points. The specialization is an implementation
freedom the freeze creates, not an obligation ([D-106][d-106]). Iterating a roster array
costs a handful of dispatches per frame and remains acceptable.
````

New:

````text
([D-106][d-106], [D-374][d-374]). The staging cells and their scatters form a heterogeneous but
*known* tuple the frame function can specialize on, which means zero dynamic
dispatch at frame top. That is the same per-configuration compile trade the
[executor](#g-executor) (the compiled form of the stage execution order, [§9.7][s9-7]) already makes,
now incurred only at stopped-sim attach points. The specialization is an
implementation freedom the freeze creates, not an obligation ([D-106][d-106], [D-374][d-374]).
Iterating a roster array costs a handful of dispatches per frame and remains
acceptable.
````

### 3.20. §11.5, old line 7759: D-260

Old:

````text
index of the last drain on the live trace ([D-217][d-217]), frozen into the value
````

New:

````text
index of the last drain on the live trace ([D-217][d-217], [D-260][d-260]), frozen into the value
````

### 3.21. §11.6, old line 7878: D-372

Old:

````text
**`shutdown!` must tolerate a partially initialized device** ([D-138][d-138]). The
````

New:

````text
**`shutdown!` must tolerate a partially initialized device** ([D-138][d-138], [D-372][d-372]). The
````

### 3.22. §11.6, old line 7956: D-373

Old:

````text
never force ([Appendix A][sA], [D-102][d-102]). The author must loop on `running(handle)` and
must make blocking calls interruptible (`unblock!`, or timeouts). A forgotten
predicate check surfaces as `DeviceJoinTimeout` with the device's name. A stall
surfaces as a stale heartbeat ([§12.2][s12-2]). Liveness timestamps ride *inside* the
handle primitives, which store them in the device's own diagnostic cell ([§11.8][s11-8]),
so the framework observes activity without owning the loop.

FlightCore's device hook **`should_close` dissolves** ([D-102][d-102]). A window ✕ or
peer EOT is the loop body returning, which is [§12.4][s12-4](6)'s case. The wrapper's
````

New:

````text
never force ([Appendix A][sA], [D-102][d-102], [D-373][d-373]). The author must loop on
`running(handle)` and must make blocking calls interruptible (`unblock!`, or
timeouts). A forgotten predicate check surfaces as `DeviceJoinTimeout` with the
device's name. A stall surfaces as a stale heartbeat ([§12.2][s12-2]). Liveness
timestamps ride *inside* the handle primitives, which store them in the device's
own diagnostic cell ([§11.8][s11-8]), so the framework observes activity without owning
the loop.

FlightCore's device hook **`should_close` dissolves** ([D-102][d-102], [D-373][d-373]). A window ✕
or peer EOT is the loop body returning, which is [§12.4][s12-4](6)'s case. The wrapper's
````

### 3.23. §11.6, old line 7970: D-374

Old:

````text
to run end (the freeze, [§11.3][s11-3], [D-106][d-106]). The GUI implements the same authoring
contract.
````

New:

````text
to run end (the freeze, [§11.3][s11-3], [D-106][d-106], [D-374][d-374]). The GUI implements the same
authoring contract.
````

### 3.24. §11.6, old line 8067: D-371

Old:

````text
([D-177][d-177]). `claims` and `reads` have error-throwing fallbacks on the root. A
declared side whose method was never written therefore fails loudly at the
````

New:

````text
([D-177][d-177], [D-371][d-371]). `claims` and `reads` have error-throwing fallbacks on the root.
A declared side whose method was never written therefore fails loudly at the
````

### 3.25. §11.6, old line 8120: D-370

Old:

````text
**A second greedy attach stakes the empty remainder** ([D-174][d-174]). The complement is
computed against the roster as it stands. A greedy binding attached after
another has already swallowed everything therefore gets the empty claim. That
claim is legal, being the honest may-write-nothing degenerate below, and it is
useless, which is worth saying out loud. The attach succeeds and records
`EmptyGreedyClaim` ([Appendix C][sC], a warning naming the device and its binding) in
the roster entry's diagnostic cell. `attach!` mutates the roster, so the warning
lives in that state's status and surfaces through the status record ([§11.8][s11-8],
[D-250][d-250]). The log line at return is presentation. That is the one honest reading
of "you asked for what is left and nothing was left".

**Several interactive front ends may be rostered at once** ([D-174][d-174]). A web
````

New:

````text
**A second greedy attach stakes the empty remainder** ([D-174][d-174], [D-370][d-370]). The
complement is computed against the roster as it stands. A greedy binding
attached after another has already swallowed everything therefore gets the empty
claim. That claim is legal, being the honest may-write-nothing degenerate below,
and it is useless, which is worth saying out loud. The attach succeeds and
records `EmptyGreedyClaim` ([Appendix C][sC], a warning naming the device and its
binding) in the roster entry's diagnostic cell. `attach!` mutates the roster, so
the warning lives in that state's status and surfaces through the status record
([§11.8][s11-8], [D-250][d-250]). The log line at return is presentation. That is the one honest
reading of "you asked for what is left and nothing was left".

**Several interactive front ends may be rostered at once** ([D-174][d-174], [D-370][d-370]). A web
````

### 3.26. §11.6, old line 8151: D-371

Old:

````text
([D-177][d-177]). Its writes are still binding-bounded, so drift onto any face is
````

New:

````text
([D-177][d-177], [D-371][d-371]). Its writes are still binding-bounded, so drift onto any face is
````

### 3.27. §11.7, old line 8233: D-370

Old:

````text
root input lies inside the GUI's own claim ([D-174][d-174]) in the run's frozen surface
partition (root-input exclusivity, [§11.3][s11-3]). The feed chain is walked through
[local wires](#g-local-wire) (wires with both ends inside one assembly) and interface connections
across *all* levels, not just the local assembly. The claim may have been
computed from the unclaimed complement under `is_greedy`. It may instead have
been enumerated by a partial-claims [binding](#g-binding) (the value passed at `attach!`,
````

New:

````text
root input lies inside the GUI's own claim ([D-174][d-174], [D-370][d-370]) in the run's frozen
surface partition (root-input exclusivity, [§11.3][s11-3]). The feed chain is walked
through [local wires](#g-local-wire) (wires with both ends inside one assembly) and interface
connections across *all* levels, not just the local assembly. The claim may have
been computed from the unclaimed complement under `is_greedy`. It may instead
have been enumerated by a partial-claims [binding](#g-binding) (the value passed at `attach!`,
````

### 3.28. §11.8, old line 8441: D-369

Old:

````text
**The ring's bound *is* the rate limit** ([D-136][d-136]). When a writer emits past the
ring's capacity within one frame, the value is not stored and its kind's
suppressed count increments. The drop policy retains the earliest in the frame,
and the excess becomes counts. The first occurrences are the ones with
````

New:

````text
**The ring's bound *is* the rate limit** ([D-136][d-136], [D-369][d-369]). When a writer emits
past the ring's capacity within one frame, the value is not stored and its
kind's suppressed count increments. The drop policy retains the earliest in the
frame, and the excess becomes counts. The first occurrences are the ones with
````

### 3.29. §11.8, old line 8453: D-369

Old:

````text
**The diagnostic cells are taken at the same drain [§11.4][s11-4] specifies** ([D-136][d-136]).
The loop performs one `atomicswap` per diagnostic cell at frame top, at the same
point and under the same indivisible-take argument as the staging drain. What
the loop swaps *in* is a shared *empty sentinel*, so a quiet frame swaps the
sentinel in and gets the sentinel back. That allocates nothing, and it leaves no
load-only code path that goes untested on healthy runs.
````

New:

````text
**The diagnostic cells are taken at the same drain [§11.4][s11-4] specifies** ([D-136][d-136],
[D-369][d-369]). The loop performs one `atomicswap` per diagnostic cell at frame top, at
the same point and under the same indivisible-take argument as the staging
drain. What the loop swaps *in* is a shared *empty sentinel*, so a quiet frame
swaps the sentinel in and gets the sentinel back. That allocates nothing, and it
leaves no load-only code path that goes untested on healthy runs.
````

### 3.30. §11.8, old line 8480: D-369

Old:

````text
**The published framework status is a concrete frozen value** ([D-136][d-136]). Per
writer it carries four things beside `who`. `recent` is the ring the frame's
````

New:

````text
**The published framework status is a concrete frozen value** ([D-136][d-136], [D-369][d-369]).
Per writer it carries four things beside `who`. `recent` is the ring the frame's
````

### 3.31. §11.8, old line 8519: D-369

Old:

````text
channel policy** ([D-136][d-136]). Counts keep accumulating regardless, nothing recorded
depends on it, and the choice belongs to whoever renders. The channel's own
bound, above, is the one that is normative.
````

New:

````text
channel policy** ([D-136][d-136], [D-369][d-369]). Counts keep accumulating regardless, nothing
recorded depends on it, and the choice belongs to whoever renders. The channel's
own bound, above, is the one that is normative.
````

### 3.32. §11.8, old line 8526: D-369

Old:

````text
[§13.5][s13-5], [D-136][d-136]). An [unattended run](#g-unattended-run) (a run with empty staging and no snapshot
readers) that nobody watched therefore still answers "what went wrong, and how
often" from the value its own shutdown published. Final means final at the last
frame top ([D-201][d-201]). The account closes with the drain that preceded the terminal
publication. What lands after it can reach no snapshot. Examples are a report
from a device's exit path and the tail's own `DeviceJoinTimeout` ([§12.4][s12-4]). So the
loop takes each diagnostic cell once more at the run's end, keeping the next
run's account clean.
````

New:

````text
[§13.5][s13-5], [D-136][d-136], [D-369][d-369]). An [unattended run](#g-unattended-run) (a run with empty staging and no
snapshot readers) that nobody watched therefore still answers "what went wrong,
and how often" from the value its own shutdown published. Final means final at
the last frame top ([D-201][d-201]). The account closes with the drain that preceded the
terminal publication. What lands after it can reach no snapshot. Examples are a
report from a device's exit path and the tail's own `DeviceJoinTimeout` ([§12.4][s12-4]).
So the loop takes each diagnostic cell once more at the run's end, keeping the
next run's account clean.
````

### 3.33. §11.8, old line 8543: D-369

Old:

````text
**On a quiet frame nothing allocated scales with diagnostic activity** ([D-241][d-241]).
The sentinel swap allocates nothing. **The per-writer status costs one small
vector of records per publication** ([D-241][d-241]), beside the snapshot allocation per
[boundary](#g-boundary) (a published consistency point) that [§11.2][s11-2] already accepts. That is the
same GC-over-reuse trade, a roster-sized vector rather than a snapshot type per
roster size ([D-241][d-241]).
````

New:

````text
**On a quiet frame nothing allocated scales with diagnostic activity** ([D-241][d-241],
[D-369][d-369]). The sentinel swap allocates nothing. **The per-writer status costs one
small vector of records per publication** ([D-241][d-241]), beside the snapshot
allocation per [boundary](#g-boundary) (a published consistency point) that [§11.2][s11-2] already
accepts. That is the same GC-over-reuse trade, a roster-sized vector rather than
a snapshot type per roster size ([D-241][d-241]).
````

### 3.34. §11.8, old line 8551: D-369

Old:

````text
([D-136][d-136]). The closed kind set ([Appendix C][sC]) licenses that, because it makes the
counter layout a type rather than a lookup.
````

New:

````text
([D-136][d-136], [D-369][d-369]). The closed kind set ([Appendix C][sC]) licenses that, because it makes
the counter layout a type rather than a lookup.
````
