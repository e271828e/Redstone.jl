### 11.8 Diagnostics and liveness: the per-writer cell

The chapter's two data channels are specified down to their memory ordering.
The runtime warning stream ([§13.2][s13-2]) and the liveness heartbeat
([§12.2][s12-2]) are a third, and they cross the same task boundaries. They
are written at staging by whichever task stages (`OutOfClaimEntry`,
`ClaimedFaceEntry` and `EntryTypeMismatch`, [§11.4][s11-4], on a
[device](#g-device) task or through the harness writer, [D-200][d-200]).
They are written by the device tasks (`MalformedDatum` from the author's loop
body via `report!(handle, …)`, [§11.6][s11-6]), by the loop itself
(`DebtReanchor`, `UnboundedRun`), and by the frame the loop runs
(`ChatteringBudget`, `FiringBudget`).
They are written at `attach!` too, into the roster entry being created
(`EmptyGreedyClaim`, [§11.3][s11-3]). `attach!` mutates the roster, so its
warning lives in the roster's status rather than on an artifact
([D-250][d-250]). The device's task does not exist until `run!`, so that cell
has no other writer yet. They are read by the loop, which folds them into the
published [framework status](#g-framework-status) ([§11.2][s11-2]) and hence
into every [snapshot](#g-snapshot). An unspecified structure with those writers is
exactly the arbitrary shared mutable state the two rules ([§11.1][s11-1])
exist to eliminate, so it gets the mechanism [§11.4][s11-4] already
established, not one of its own.

**One [diagnostic cell](#g-diagnostic-cell) per writer: one per rostered
device, one for the harness writer, one for the loop itself
([D-200][d-200]).** The [`Model`](#g-model) (the deployment and its
executor at one scalar) owns one more. Its frame writes the chattering and
firing-budget reports there, and the drain folds that cell into the loop's
account beside the loop's own ([D-317][d-317]). A device's
[cell](#g-diagnostic-cell), the loop's and the `Model`'s each have a single
writer, the same ownership argument as the
[staging cells](#g-staging-cell). There is no locking, no arbitration and no
new primitive. The harness writer's cell is written from whichever task
stages, exactly as its staging cell is, and the same CAS append arbitrates.
It carries no heartbeat, and its status record no `task_state`, because it
has no task of its own to be alive or dead. The cell holds a **bounded
accumulation** and one atomic liveness timestamp. The accumulation is a
small ring of diagnostic values, capacity **16**, plus a per-kind count of
what the ring could not hold.

**That bound *is* the rate limit.** When a writer emits past the ring's
capacity within one frame, the entry is not stored and its kind's suppressed
count increments. The drop policy retains the earliest in the frame, and the
excess becomes counts. The first occurrences are the ones with diagnostic
content, and the hundredth is noise the count already reports. Rate-limiting
"wherever its source can repeat" ([§13.2][s13-2]) is therefore not a policy
layered over the stream but a structural property of the channel that
carries it. A [chattering](#g-chattering) model or a peer flooding malformed
datagrams costs at most sixteen retained values and one integer increment
per kind per frame, whatever its source does. No writer can starve another,
because the cells are disjoint.

**This [drain](#g-drain) is the same drain [§11.4][s11-4] specifies.** One
`atomicswap` per cell at frame top, at the same point and under the same
indivisible-take argument as the staging drain. What the loop swaps *in* is
a shared **empty sentinel**, so a quiet frame swaps the sentinel in and gets
the sentinel back. That allocates nothing, and it leaves no load-only code
path that goes untested on healthy runs. The take is also what makes
publication sound. The batch is exclusively the loop's before it is ever
reachable from a snapshot, so the binding rule ([§11.2][s11-2]), that nothing
reachable from a published snapshot is ever written again, holds by
construction. The live accumulator is never reachable from a published
value.

**The heartbeat rides in the same cell**, as an atomic timestamp field. The
device task stores it on every loop pass from inside the handle primitives
([§11.6][s11-6]: the framework observes activity without owning the loop
body), and the loop acquire-loads it at publication, when it assembles the
status ([D-240][d-240]). There is no separate liveness channel and no second
registry. A device that is alive is a device whose cell carries a recent
timestamp, and the 2 s staleness threshold ([§12.2][s12-2]) is read against
this field. The heartbeat is not a diagnostic kind. It is a field, always
present, never enumerated in [Appendix C][sC].

**The published framework status is a concrete frozen value.** Per writer it
carries four things. `recent` is the ring this boundary drained, at most
sixteen entries. `suppressed` is the per-kind counts the ring refused this
boundary. `totals` is the cumulative per-writer × per-kind counts since the
run began, owned privately by the loop and *copied* into each status. And
`heartbeat` rides beside the `task_state` the loop reads off its own device
`Task` handle at publication ([§12.2][s12-2]). Beside the per-writer records
ride the pacer diagnostics ([§10.7][s10-7]). Delta plus total is what makes
the status legible at any reading cadence. A GUI panel refreshing at 60 Hz
sees each occurrence once in `recent`, while a consumer that samples
occasionally still reads a complete account from `totals`. Nothing is lost
by not looking. The record's `who` is the only attribution a value has, so a
renderer presents each value under its record's writer ([D-228][d-228]).

**Presentation is where `maxlog` lives.** A status renderer prints a given
writer × kind up to **25** cumulative occurrences and then switches to
count-only display ("`MalformedDatum` from `UDPInput#3`: 1 482
occurrences"). That threshold is presentation policy, not channel policy.
Counts keep accumulating regardless, nothing recorded depends on it, and the
choice belongs to whoever renders. The channel's own bound, above, is the
one that is normative.

**The terminal snapshot carries the run's final cumulative counters**
([§12.4][s12-4], [§13.5][s13-5]). An [unattended run](#g-unattended-run) (a
run with empty staging and no snapshot readers) that nobody watched
therefore still answers "what went wrong, and how often" from the value its
own shutdown published. Final means final at the last frame top
([D-201][d-201]). The account closes with the drain that preceded the
terminal publication. What lands after it can reach no snapshot. Examples
are a report from a device's exit path and the tail's own
`DeviceJoinTimeout` ([§12.4][s12-4]). So the loop takes each cell once more
at the run's end, keeping the next run's account clean. That last take is
folded into the [termination record](#g-termination-record) as the tail
residue, per writer the final ring and its suppressed counts
([§13.5][s13-5]), and presented through the standard logging backend. It is
loud *and* recorded, and still never published ([D-201][d-201],
[D-203][d-203]).

**Allocation.** On a quiet frame **nothing allocated scales with diagnostic
activity**. The sentinel swap allocates nothing, and the per-writer status
costs one small vector of records per publication beside the per-boundary
snapshot allocation [§11.2][s11-2] already accepts. That is the same
GC-over-reuse trade, a roster-sized vector rather than a snapshot type per
roster size ([D-241][d-241]). The per-kind counters are a **fixed-shape
isbits record, never a `Dict`**. The closed kind set ([Appendix C][sC])
licenses that, because it makes the counter layout a type rather than a
lookup. On a noisy frame the diagnostic values are allocated at emission, on
the writer's own task. A drained non-empty ring is frozen into the snapshot
and can never be written again, so the writer allocates a fresh ring lazily
at its next emission. That cost, too, lands on the writer's task, and it is
the same GC-over-reuse trade [§11.2][s11-2] makes when it rejects
preallocated snapshot buffers. The rate limit is therefore an allocation
bound as well. One ring of sixteen entries per writer per boundary is the
worst case, and everything past it is an integer increment. The
zero-allocation invariant ([§9.8][s9-8]), scoped to the model
[sweep](#g-sweep), is untouched. The cells sit on the framework side of that
scope with publication and logging.

One composition with the log is worth stating once. Because the log retains
snapshot references ([§11.2][s11-2]), `totals` is monotone across logged
snapshots. So `log_every` [decimation](#g-decimation) (the log's
keep-every-kth retention policy) loses *which* boundary within a skipped
stretch an occurrence fell on, never *how many* occurrences there were.

Rejected: a shared queue under a lock, a status referencing the live
accumulator, ring reuse by double-buffering, and unbounded accumulation
([D-136][d-136]).

---

