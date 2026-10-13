### D-367 — Replace the start gate with spawning inside `run!`

**Status.** ratified

**Position.** Spawning device tasks inside `run!` replaces the start gate.
First-boundary synchronization is §12.3's counter-plus-condition predicate
wait.

**Spec.** §11.1

**Rationale.** This restates a clause of D-093's Rationale, the one on the
start gate, which D-093's Position does not state. That Position rules that
`run!` spawns the tasks, not that the spawn replaces the gate. The entry
decides nothing new.

**Rejected.** None beyond D-093's list.

### D-368 — Bound the snapshot log by count, with a finite default, a doubling stride and kept endpoints

**Status.** ratified

**Position.** Six rulings on the snapshot log's retention bound, `log_max`.

- The bound is a count, not a memory budget. A count is exact and converts
  to memory through one measured number, while byte accounting over shared
  immutable snapshots is fuzzy and platform-dependent.
- The default is 65536 (2¹⁶), finite unconditionally, with `Inf` the
  explicit opt-out. No modal rule keys the default on `t_end`.
- When the log fills, the effective retention stride doubles, to
  `log_every · 2^k` after *k* generations. The bound holds while coverage
  stays global.
- The guarantees are normative and the mechanism is a sketch. Normatively,
  the retained count never exceeds `log_max`, coverage is global at the
  effective stride, and the endpoints are kept.
- The boundary-zero and terminal snapshots are retained unconditionally under
  any `log_every` and any `log_max`, and they do not count against the bound.
- `log_max` is a view policy, not trajectory-determining. It stays outside
  the trace header's deployment block, and replay neither records nor
  compares it.

**Spec.** §11.2

**Rationale.** Each bullet restates what D-137's Rationale recorded outside
its Position, from "A count, not a memory budget" to the view policy. D-137's
Position states only that the bound exists. Its annotation moves `log_max` to
the doors that build a run (D-261), which no bullet contradicts. The entry
decides nothing new.

**Rejected.** None beyond D-137's list.

### D-369 — The diagnostic channel's rate limit, drain take, frozen status, presentation and quiet frame

**Status.** ratified

**Position.** Seven rulings on the per-writer diagnostic channel.

- The ring's bound is the rate limit. An emission past capacity within a
  frame is not stored and its kind's count increments, so the earliest in the
  frame are retained. No rate-limit constant exists to tune.
- The loop takes each diagnostic cell with `atomicswap` at the frame-top
  drain, §11.4's own point. It swaps in a shared empty sentinel, so the take
  on a quiet frame allocates nothing and no load-only path goes untested.
- The published framework status is a concrete frozen value. Per writer it
  carries `recent` (the boundary's drained ring), `suppressed` (the per-kind
  counts the ring refused that boundary), `totals` (the loop-owned cumulative
  per-writer × per-kind counters, copied into each status) and `heartbeat`.
  §11.2's binding rule holds by construction, because the swap gives the
  loop exclusive ownership of the batch before publication.
- Presentation is separate from channel policy. A renderer prints a writer ×
  kind up to 25 cumulative occurrences and then switches to count-only
  display, while counts accumulate regardless.
- The terminal snapshot carries the final cumulative counters, so an
  unattended run's diagnostic account survives its own shutdown.
- The per-kind counters are a fixed-shape isbits record, never a `Dict`,
  which Appendix C's closed kind set licenses.
- Nothing on a quiet frame scales with diagnostic activity.

**Spec.** §11.8

**Rationale.** Each bullet restates what an existing entry recorded outside
its Position. The first six were recorded in D-136's Rationale, and the
presentation bullet also in D-136's rejection of a render threshold baked
into the channel. The quiet frame was recorded in D-241's Rationale, as the
invariant the status vector keeps. Later entries amend other parts of
D-136's Rationale, and no bullet restates those parts. The heartbeat is read
at publication (D-240), the status costs one small vector per publication
(D-241), and the harness writer and the `Model` have cells of their own
(D-200, D-317). D-193 adds `task_state` beside `heartbeat`, and D-201 closes
the terminal account at the final frame top. The entry decides nothing new.

**Rejected.** None beyond the source entries' lists.

### D-370 — The greedy claim's corollaries for the empty remainder, front ends, the harness surface and liveness

**Status.** ratified

**Position.** Four corollaries of the greedy claim source.

- A second greedy attach finds an empty complement and stakes an empty claim.
  The claim is legal, §11.6's honest may-write-nothing degenerate, and the
  attach records the diagnostic `EmptyGreedyClaim`.
- Partial-claims GUI bindings are legal, and so are several interactive front
  ends with explicit disjoint claims, such as a web console claiming the
  autopilot faces beside a local GUI claiming the stick faces.
- The harness writer is the sole remaining derived surface. Its
  framework-owned `stage!(sim, ...)` entry point and always-present cell
  cover the unclaimed complement, recomputed at every stopped-sim `attach!`
  and `detach!`. The pending-batch renormalization seam applies to it alone.
  `ClaimedFaceEntry` is narrowed to it, and an enumerated writer's
  out-of-surface entry, the GUI's included, is the ordinary
  `OutOfClaimEntry`.
- A widget is live iff its port's feed chain terminates in a root input
  inside the GUI's own claim.

**Spec.** §11.3, §11.4, §11.6, §11.7

**Rationale.** Each bullet restates what D-174's Rationale recorded outside
its Position. The first two restate its first paragraph, the third its
harness-writer paragraph and the fourth its liveness paragraph. D-174 says
root slot where the spec now says root input. Two clauses of those
paragraphs are left out. The singleton `needs_calling_task` fell with D-310,
and the harness cell's drain-last convention is D-096's Position. D-250
moves `EmptyGreedyClaim` into the roster entry's diagnostic cell. The entry
decides nothing new.

**Rejected.** None beyond D-174's list.

### D-371 — Check binding sides both ways at attach, and keep the empty enumeration a degenerate

**Status.** ratified

**Position.** Two binding rulings.

- The obligations a binding's side traits create are enforced both ways at
  attach, by the error fallbacks `claims(::AbstractBinding)` and
  `reads(::AbstractBinding)` and by a bidirectional conformance check.
  `is_input && !is_greedy` calls `claims(b)` once. `is_input && is_greedy`
  computes the claim, and a defined `claims` method is an error. `is_output`
  calls `reads(b)`. Declaring neither side, or `is_greedy` without
  `is_input`, is an error. So is a specific `claims` or `reads` method defined
  for the binding type while its trait is false, detected by `which` against
  the fallback at a stopped-sim service point. A missing method under a true
  trait and a defined method under a false trait both report
  `BindingContractMismatch`, naming the trait and the method at fault.
- `is_input(b) = true` with `claims(b) = ()` is the honest may-write-nothing
  degenerate. The maximal surface still requires the explicit `is_greedy`
  declaration.

**Spec.** §11.6

**Rationale.** Each bullet restates what D-177's Rationale recorded outside
its Position. The first restates its conformance check, from "a
bidirectional conformance check at attach" to `BindingContractMismatch`. The
second restates the empty-enumeration doctrine D-177 records as surviving
untouched. D-177's Position declares the traits but not their enforcement.
D-216's Position adds the binding that declares neither side to
`BindingContractMismatch`, one case of the check, not the check. The entry
decides nothing new.

**Rejected.** None beyond D-177's list.

### D-372 — Make `shutdown!` tolerate a partially initialized device

**Status.** ratified

**Position.** `shutdown!` must tolerate a partially initialized device and
close only what is open, the same defensiveness the crash path already
demands. The obligation is taught (§11.6, Appendix A).

**Spec.** §11.6

**Rationale.** This restates the taught obligation D-138's Rationale records
outside its Position. It follows from the bracket that Position rules. A
throw in `init!` sends the device straight to `shutdown!`, so release is
unconditional. D-268's Position quotes "close only what is open" from §11.6
for a repeated call and for a call with no `init!` before it. The entry
decides nothing new.

**Rejected.** None beyond D-138's list.

### D-373 — Dissolve `should_close`, and teach the device loop's two obligations

**Status.** ratified

**Position.** Two device-loop rulings.

- `should_close` dissolves into the loop body returning, a voluntary exit.
- The two author obligations, the `running(handle)` predicate and
  interruptible blocking, are taught (Appendix A) and diagnosed
  (`DeviceJoinTimeout`, a stale heartbeat), never forced.

**Spec.** §11.6

**Rationale.** Each bullet restates a clause of D-102's Rationale that its
Position does not state. D-030's Position names the predecessor's
`should_close` path, not its dissolution. The entry decides nothing new.

**Rejected.** None beyond D-102's list.

### D-374 — Keep a dead device rostered, guard mid-run readers, and compile the drain against the roster

**Status.** ratified

**Position.** Three roster-freeze rulings.

- Device death mid-run is not detach. The task dies, the heartbeat reports
  it, and the claims and roster entry persist to run end. Orphans are
  recovered between runs, by a stop, a `detach!` and `init!`, or by `replay!`
  to the end and a `run!` continuation.
- Mid-run attach for pure readers is a guarded addition. A pure reader has
  no input half, claims nothing and moves no surface. A dynamic reader list
  would touch only §12.3's wakeups, the heartbeat and the shutdown join,
  never the drain.
- The drain is fully compilable against the frozen roster. The
  specialization is an implementation freedom, not an obligation.

**Spec.** §11.3, §11.4, §11.6

**Rationale.** Each bullet restates a clause of D-106's Rationale that its
Position does not state. The first reverses D-087's zombie-claims rejection,
as D-106 records. D-106's clause that all write-surface checks move to
staging and the drain is pure application is not restated, because D-044's
Position states it. The entry decides nothing new.

**Rejected.** None beyond D-106's list.

### D-375 — Identify a device by its instance, and admit it on identity then claims

**Status.** ratified

**Position.** Device identity and admission stand as D-109 ruled them, less
its affinity check.

- Identity is the instance (`===`). An instance occupies at most one roster
  entry, and two instances of one type are two devices.
- The stable device id is assigned at `attach!`. It is monotonic per
  `Simulation`, never reused, and lives with its roster entry across runs.
- Admission is a two-part check at attach. Identity comes first
  (`AlreadyAttached`, rebinding being `detach!` then `attach!`), then claims
  (`ClaimConflict`, always between distinct devices).

**Spec.** §11.3

**Rationale.** This restates the identity and admission halves of D-109's
Position. D-310 superseded D-109, and its Rationale records that these
halves survive: identity by instance, the stable id at attach,
`AlreadyAttached` and `ClaimConflict`. D-109's affinity third,
`CallerTaskConflict`, fell with D-310's withdrawal of `needs_calling_task`,
so admission has two parts. The entry decides nothing new.

**Rejected.**
- *Idempotent no-op on re-`attach!` of a rostered device:* silently discards
  the binding the caller handed over, the warn-but-continue pattern (D-109).
- *Silent double-rostering of claim-free readers:* two tasks racing on one
  device instance's own state, and a double `init!`/`shutdown!` on one OS
  resource (D-109).

### D-376 — Give the services ownership of root-input initial values

**Status.** ratified

**Position.** The services own root-input initial values. Neither export
entries nor face declarations carry root-input defaults.

**Spec.** §11.3

**Rationale.** This restates the reasons of two rejections that no Position
states. D-047's Rejected list refuses initial values as export-entry
defaults, because trim writes values it solved for and "services own
initialization". D-068's refuses face-declaration defaults. D-068's Position
has the services enforce coverage before writing anything, which assumes the
ownership but does not state it. The sources say slot where the spec now
says root input. The entry decides nothing new.

**Rejected.**
- *Root-input initial values as export-entry defaults:* trim writes values
  it solved for (D-047).
- *Face-declaration defaults:* condition data inside the wiring contract,
  reopening the bare-types rule and the competing-defaults problem (D-068).

