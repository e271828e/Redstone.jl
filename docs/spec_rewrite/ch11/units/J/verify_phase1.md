# Unit J verify, phase 1 (blind): assertions in new.md

Intro
- V1 The chapter's two data channels are specified down to their memory ordering.
- V2 The runtime warning stream [§13.2] and liveness heartbeat [§12.2] are a third channel, crossing between the same tasks.

Writers and readers
- V3 Whichever task stages writes OutOfClaimEntry, ClaimedFaceEntry, EntryTypeMismatch at staging [§11.4].
- V4 Staging happens on a device task (device = any attached participant in the periphery), or through the harness writer (framework-owned write path `stage!(sim, …)`) [D-200].
- V5 Device tasks write MalformedDatum from the author's loop body via `report!(handle, …)` [§11.6].
- V6 The loop writes DebtReanchor and UnboundedRun.
- V7 The frame the loop runs writes ChatteringBudget and FiringBudget [D-317]. Frame = one iteration of the loop.
- V8 `attach!` writes EmptyGreedyClaim as it adds a device to the roster (list of attached device entries) [§11.3]; the value goes into the roster entry being created.
- V9 `attach!` mutates the roster, so its warning lives in the roster's status rather than on an artifact [D-250].
- V10 The device's task does not exist until `run!`, so the new roster entry's cell has no other writer yet.
- V11 The loop reads the diagnostics and folds them into the published framework status (the diagnostics value each snapshot carries) [§11.2].
- V12 Hence they reach every snapshot (immutable per-boundary publication).
- V13 An unspecified structure with those writers is exactly the arbitrary shared mutable state §11.1's two rules exist to eliminate [§11.1].
- V14 So the channel gets §11.4's mechanism, not one of its own.

One cell per writer
- V15 (bold) Each writer has one diagnostic cell (own holding place for runtime diagnostics) [D-136, D-200].
- V16 One per rostered device, one for the harness writer, one for the loop [D-200].
- V17 The Model (deployment and executor at one scalar) owns one more; its frame writes chattering and firing-budget reports there.
- V18 The drain (frame-top swap applying staged device writes to root inputs) folds that cell into the loop's account beside the loop's own [D-317].
- V19 Device, loop and Model cells each have a single writer, by the same ownership argument as staging cells (each device's atomic holding place for pending writes).
- V20 No locking, no arbitration, no new primitive [D-136].
- V21 The harness writer's cell is written from whichever task stages, as its staging cell is; the same CAS append arbitrates [D-200].
- V22 The harness cell carries no heartbeat, and its status record no task_state, because it has no task.
- V23 A cell holds a bounded accumulation and one atomic liveness timestamp.
- V24 The accumulation is a ring of diagnostic values, capacity 16, plus a per-kind count of what the ring could not hold [D-136]. Kind = a diagnostic's identity in the closed set.

Bound and drain
- V25 (bold) The ring's bound is the rate limit [D-136].
- V26 Emission past capacity within one frame: value not stored; its kind's suppressed count increments.
- V27 Drop policy retains the earliest in the frame; excess becomes counts.
- V28 First occurrences carry diagnostic content; the hundredth is noise the count already reports.
- V29 Rate limiting "wherever its source can repeat" [§13.2] is therefore a structural property of the channel, not a layered policy.
- V30 A chattering model (exhausting per-frame localization budget) or flooding peer costs at most sixteen retained values and one integer increment per kind per frame, whatever its source does.
- V31 No writer can starve another, because cells are disjoint.
- V32 (bold) The cells are taken at the same drain §11.4 specifies [D-136].
- V33 One atomicswap per cell at frame top, same point and same indivisible-take argument as the staging drain.
- V34 The loop swaps in a shared empty sentinel; a quiet frame gets the sentinel back.
- V35 That allocates nothing and leaves no load-only path untested on healthy runs.
- V36 The take makes publication sound: the taken ring is the loop's exclusively before it is reachable from a snapshot.
- V37 Binding rule: nothing reachable from a published snapshot is ever written again [§11.2]; holds by construction.
- V38 The live accumulator is never reachable from a published value.

Heartbeat
- V39 Heartbeat rides in the same cell as an atomic timestamp field [D-136].
- V40 Device task stores it on every loop pass from inside the handle primitives; framework observes activity without owning the loop body [§11.6].
- V41 The loop acquire-loads it at publication, when assembling the status [D-240].
- V42 No separate liveness channel, no second registry.
- V43 Alive device = cell carrying a recent timestamp; 2 s staleness threshold [§12.2] is read against this field.
- V44 Heartbeat is not a diagnostic kind; a field, always present, never enumerated in Appendix C.

Published status
- V45 (bold) The published framework status is a concrete frozen value [D-136].
- V46 Per writer it carries four things.
- V47 `recent` is the ring the frame's drain took, carried by the first publication after that drain, at most sixteen values.
- V48 `suppressed` is the per-kind counts the ring refused in that drain.
- V49 `totals` is cumulative per-writer × per-kind counts since run start, owned privately by the loop, copied into each status.
- V50 `heartbeat` rides beside `task_state`, which the loop reads off its own device Task handle at publication [§12.2, D-193].
- V51 Pacer diagnostics ride beside the per-writer records [§10.7].
- V52 Record shape: WriterStatus {who::String, recent::Vector{DiagValue}, suppressed::KindCounts, totals::KindCounts, heartbeat::Union{Nothing,Float64}, task_state::Union{Nothing,Symbol}}.
- V53 DiagValue is any value of the closed kind set; KindCounts is the per-kind counter record the allocation rules describe.
- V54 Delta plus total makes the status legible at any reading cadence: a 60 Hz GUI sees each occurrence once in `recent`; an occasional sampler reads a complete account from `totals`.
- V55 Nothing is lost by not looking.
- V56 `who` is the only attribution a value has; a renderer presents each value under its record's writer [D-228].

Presentation
- V57 (bold) Presentation is where `maxlog` lives [D-136].
- V58 A renderer prints a writer × kind up to 25 cumulative occurrences, then count-only display (example given).
- V59 That threshold is presentation policy, not channel policy; counts accumulate regardless; nothing recorded depends on it; choice belongs to the renderer.
- V60 The channel's own bound is the normative one.

Run's end
- V61 (bold) The terminal snapshot carries the run's final cumulative counters [§12.4, §13.5, D-136].
- V62 So an unattended run (empty staging, no snapshot readers) still answers "what went wrong, how often" from its shutdown's published value.
- V63 Final means final at the last frame top [D-201]; account closes with the drain preceding the terminal publication.
- V64 What lands after can reach no snapshot; e.g. a device exit-path report and the tail's DeviceJoinTimeout [§12.4].
- V65 So the loop takes each cell once more at run's end, keeping the next run's account clean.
- V66 That last take is folded into the termination record (stopped-sim value naming how the run ended) as the tail residue [§13.5].
- V67 Per writer, tail residue = final ring and its suppressed counts.
- V68 The take is presented through the standard logging backend; loud and recorded, never published [D-201, D-203].

Allocation
- V69 (bold) On a quiet frame nothing allocated scales with diagnostic activity [D-241].
- V70 Sentinel swap allocates nothing.
- V71 Per-writer status costs one small vector of records per publication, beside the per-boundary snapshot allocation §11.2 accepts [§11.2].
- V72 Same GC-over-reuse trade: roster-sized vector rather than snapshot type per roster size [D-241].
- V73 (bold) Per-kind counters are a fixed-shape isbits record, never a Dict [D-136].
- V74 The closed kind set (Appendix C) licenses that, making counter layout a type rather than a lookup.
- V75 On a noisy frame values are allocated at emission on the writer's task.
- V76 A drained non-empty ring is frozen into the snapshot and never written again, so the writer allocates a fresh ring lazily at next emission; on the writer's task.
- V77 Same GC-over-reuse trade §11.2 makes rejecting preallocated snapshot buffers.
- V78 Rate limit is therefore an allocation bound too; one ring of sixteen per writer per boundary worst case; the rest integer increments.
- V79 Zero-allocation invariant, scoped to the stepping loop [§9.8, D-305], is untouched; cells sit on the framework side with publication and logging.

Composition with the log
- V80 The log (retained sequence of published snapshots) retains snapshot references, so totals is monotone across logged snapshots.
- V81 So log_every decimation (keep-every-kth) loses which boundary an occurrence fell on, never how many [§11.2].
- V82 D-136 lists the rejected alternatives (pointer).
