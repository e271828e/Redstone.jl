### D-024 — Inbound staging: per-device atomic batch cells

**Status.** ratified

**Position.** Inbound staging: one atomic batch cell per device; complete
writers overwrite, sparse writers CAS-merge own cell (retry bounded by drain
interception); drain by `atomicswap` in attachment order; conflicts resolved by
slot exclusivity (D-044); levels-never-deltas doctrine; mappings pure, on the
device task; device-tagged replayable input trace.

**Spec.** §11.4

**Rationale.** Recorded only through the rejections below.

**Rejected.**
- *Superseded position — attachment order as the cross-device conflict
  precedence policy (the earlier design of record):* superseded by slot
  exclusivity, which removes the conflict instead of ranking it (the per-device
  cells, CAS merge and drain are retained for atomicity and coalescing).
- *Per-slot cells:* conflicts by hardware store order — run-to-run behavioral
  variance; cross-device peek; no trace tag; atomic-width fallback on
  wide slots.
- *Shared batch stack:* temporal conflict order; unbounded pending under pause,
  taxing peeks.
- *Ordered write queue:* preserves intra-frame order nothing downstream can
  observe.

### D-025 — One uniform device kind

**Status.** ratified

**Position.** One device kind: uniform handle with read (snapshot /
next-boundary) + stage + control capabilities; input-only/output-only as
degenerate uses; bidirectional peer = one device; GUI an ordinary device
(main-thread affinity and RMW widgets its only peculiarities).

**Spec.** §11.6

**Rationale.** Recorded only through the rejections below.

**Rejected.**
- *Input/output/GUI taxonomy:* lock choreography artifact — blocking rules of
  `get_data!`/`extract_output` under `io_lock`; forces bidirectional peers into
  two devices sharing a socket and shutdown.
- *Special-cased GUI interface:* `sync = 0` + render-under-lock ceremony,
  obsolete without the lock.

### D-026 — GUI write path: panels name their own ports

**Status.** ratified

**Position.** GUI write path: per-component panels name own ports; build-time
resolution to root input slots; live vs first-class read-only rendering (with
its wiring source shown); own-pending-else-snapshot peek; active widgets stage
on interaction events (D-047).

**Spec.** §11.7

**Rationale.** Recorded only through the rejections below.

**Rejected.**
- *Superseded position — staging every render pass (the earlier design of
  record):* its motivating contest (two writers racing within a frame) died
  with slot exclusivity, and as insurance it masks invariant violations at
  render rate.
- *Slot-naming panels:* kills reuse across configurations.
- *Always-hot widgets:* FlightCore's dead slider — visually live, silently
  overwritten.
- *Cross-device peek:* re-couples devices for sub-perceptual benefit.
- *Stage-on-change only:* streaming device reasserts control mid-grab.

### D-038 — Snapshot and log: derived trajectory, primary trace header

**Status.** ratified

**Position.** Snapshot = boundary table (private cells included,
presentation-filtered) + `t` + status — no state stores; trace header = full
`(x, m, z)` at `init!` (primary data); state trajectory = derived
(replay-to-inspect); checkpointing = opt-in log policy, guarded; post-run
continuation reads live stores; log retention = the trace's plain kill switch
plus keep-every-kth decimation (`log_every` — adopted in round 3, previously a
guarded addition) — admissible precisely because the log is derived
(recomputable by replay), so D-029's anti-decimation argument does not reach
it; publication and tracing are unaffected.

**Spec.** §11.2, §11.5

**Rationale.** Recorded only through the rejections below.

**Rejected.**
- *Per-boundary full-state capture:* systematically records derived data —
  D-029's asymmetry reversed.
- *State wanted in logs via capture rather than declaration:* publicity is the
  honest remedy, priced at one auto-published cell per sweep.
- *Dev auto-publish-all-state as default:* a diagnostic mode, kin to workspace
  NaN-poisoning, not semantics.

### D-044 — Slot exclusivity and the write-surface rule

**Status.** ratified

**Position.** Slot exclusivity: one writer per root slot at a time; device
claims at attach, conflict = attach-time error, release on detach; per-device
cells/CAS/drain retained for atomicity and coalescing. Generalized as the
write-surface rule (§11.3): an entry reaches a slot iff the face is inside the
writer's surface, else discard + warn — under the D-106 roster freeze every
surface is static per run, so all checks run at staging and the drain checks
nothing; enumerated surfaces (a device's claim set — binding-bounded even on
unclaimed faces, `OutOfClaimEntry`) vs. the derived interactive surface (GUI +
`stage!`: the unclaimed set, shared, re-derived only at stopped-sim roster
changes — a write to a claimed face is `ClaimedFaceEntry` at staging;
`StaleInteractiveEntry` and its moved-between-staging-and-drain scenario are
dead); autonomous opportunistic writing does not exist, so cross-writer races
structurally cannot arise and drain order stays diagnostic.

**Spec.** §11.3, §11.4, §11.6, §11.7

**Rationale.** Recorded only through the rejections below.

**Rejected.**
- *Cross-device attachment-order precedence as conflict policy:* resolves races
  the C172X demo's cast (`flight_case_studies.md`) shows nobody wants — every dual writer is a stream shadowed by
  a mirror.
- *FlightCore-style concurrent multi-device writing of one input:* a bug
  surface, not a feature.
- *Discard-outside-the-claim as literal drain rule:* an empty claim set would
  discard every GUI write.
- *Ownership-only discard (claimed-by-another):* leaves enumerated bindings
  unenforced at the drain and reopens unclaimed multi-writer races.
- *Unclaimed-surface opportunism "for any device":* reinstates the rejected
  attachment-order policy; breaks §11.7's stays-put and sole-writer arguments.

### D-045 — Periphery input semantics: derived liveness, conditioning, mappings, edge logic

**Status.** ratified

**Position.** Periphery input semantics are settled on five points — liveness,
conditioning, mappings, edge logic and pokeability:

- GUI liveness is fully derived: transitive root-slot resolution ∧ slot
  unclaimed.
- Faces carry writer-independent post-conditioning semantics, the GUI-parity
  test.
- Mappings are declarative binding data with per-axis conditioning params,
  living on the device task.
- Edge logic is staged counters plus model-state accumulators.
- Unexported ports are unpokeable.

**Spec.** §4.3, §11.4, §11.6, §11.7

**Rationale.** Recorded only through the rejections below.

**Rejected.**
- *Per-port "GUI-controlled" markings:* the export chain is the marking, owned
  by the right author.
- *Nominally-connected + GUI override channel:* second write path; breaks frame
  purity and trace; done right it collapses into root slots.
- *Conditioning in-model:* fails GUI-parity — sliders and scripts would be
  deadzoned.
- *Shaping as per-device mapping code:* aircraft semantics duplicated per
  device — today's demonstrated smell.
- *Joystick-as-component and root-level `PilotInterface`* (`flight_case_studies.md`): replay
  same-build, single audit point, no natural home in `World`. Annotation (from
  the C172X case study's inline treatment, migrated): devices-as-components also duplicates
  §12.4's device lifecycle in component vocabulary and costs the drain its
  standing as the single audit point for external data, while the GUI stays
  irreducibly a staging device so inbound uniformity is unreachable either way
  — and the rejection rests on these invariants, not on §12.5's clock
  criterion, the scheme being internally consistent in an interactive paced
  world.
- **Bundled command faces** (`pilot_inputs` as one struct port): kills
  per-field claiming, liveness and trace tag — the port is the
  periphery's atomic unit on the write side too, §4.3 — and the routing
  convenience it bought under argument threading is the namespace prefix plus
  `input_passthrough` here.

### D-083 — Bind output-device reads to snapshot paths, not just faces

**Status.** ratified

**Position.** Output-device reads are snapshot-path bindings: writes speak the
root contract (faces, claims, exclusivity — service by definition), reads see
the whole table (inspection observation, the log/GUI/replay clients; local
cells accessible — presentation filters are defaults, not walls).

**Spec.** §11.2, §13.3, §13.5, §14.4

**Rationale.** Attach validation against the `Build` makes structural drift
loud; two-sided guidance — deep path = inspection (zero promises, right for
this build), exported output face = integration (curated writer-independent
meaning, the only shield against silent semantic drift under
same-path/same-type substitution); generic consumers bind faces, aircraft
families export conventional surfaces with wrapper types (`VelocityData` —
field meaning defined at the type; wrong quantity = deliberate lie, not drift)
as the checkable fraction of semantics; §13.5's observation-by-path rejection
rests on the service/inspection split alone.

**Rejected.**
- *Faces-only reads:* export bloat: the root contract as a peripheral dumping
  ground; no decoupling gained: diagnostic consumers are build-specific by
  nature; unenforceable: the log and GUI already see everything; and
  restricting reads does not create meaning-stability — exporting curated
  surfaces does.
- *Semantic validation machinery:* meaning is not in the schema; the
  wrapper-type idiom is the checkable fraction.

### D-093 — Spawn device tasks per run, not per attach

**Status.** ratified

**Position.** Device tasks are per-run artifacts (§11.1, §12.4, §12.6): `run!`
spawns one task per roster entry after per-run device `init!` (resource
acquisition per run — FlightCore's create-a-new-socket-each-`init!` in
network.jl the precedent; `attach!` never spawns — one semantics, register,
D-106).

**Spec.** §11.1, §11.6, §12.2, §12.3, §12.4, §12.6, §13.4

**Rationale.** §12.4 joins all tasks at every stop with `shutdown!` releasing
OS resources; what persists across `stopped → init! → run!` is the roster entry
(binding, claims, stable device id); spawn-inside-`run!` replaces the start
gate, and first-boundary synchronization is §12.3's counter-plus-condition
predicate wait; `should_close` and the §12.2 liveness heartbeat are run-scoped,
unplug-while-stopped surfaces as the next run's device-`init!` failure. The GUI
is the one rostered device *without* a spawned task — CImGui pins rendering to
the calling task, so the loop is the movable piece: with a calling-task device
rostered the loop moves to a spawned task for the run — roster-derived, `gui =
true` mere ensure-rostered sugar (D-109) — otherwise the loop runs on the
calling task (preserving §13.4's synchronous rethrow and inline threading of
parallel batch sweeps); `run!` blocks its caller either way. Stepping sessions
are deviceless by construction (`attach!` registers only, tasks appear at the
next `run!`); the write/read paths while stepping are D-096's harness writer;
`init!` discards staged batches along with trace and log.

**Rejected.**
- *`Event` start gate "as today":* §12.3's rejected primitive — the `io_start`
  reset race, re-imported for the re-run cycle §12.6 newly supports.
- *Persistent tasks parked across stops:* `while running(handle)` false from
  the first iteration; contradicts §12.4's guaranteed `finally shutdown!`;
  gives liveness and `should_close` no meaning while stopped.
- *Task handles or lifecycle state in the roster:* mixes mutable lifecycle into
  D-087's immutable roster value.
- *Always-spawned loop task FlightCore-style:* uniform topology whose only
  beneficiary is the GUI case: costs the §13.4 synchronous rethrow —
  `TaskFailedException` wrapping — inline `@threads` composability of batch
  sweeps, and direct interrupt delivery.
- *GUI as a genuinely spawned task pinned to thread 1:* falsifies §12.2's
  cannot-fail-to-be-scheduled argument; buys nothing CImGui permits.

### D-096 — Define the harness writer: `stage!`/`latest`/`step!` duration

**Status.** ratified

**Position.** The harness writer (§12.6, §11.3, §11.2): `stage!(sim, "face" =>
value, ...)` = task-free staging from the calling task into the interactive
writer (D-044's derived surface) — traced, surface-checked, drained *last* at
the frame top (the explicit hand of code beats a widget interaction; sequencing
within one writer, not cross-device policy), so the mutation doctrine
(staging and control, nothing else) and replay bit-identity hold.

**Spec.** §11.2, §11.3, §12.6

**Rationale.** `latest(sim)` = the current published snapshot, the same
immutable value device handles read; `step!` gains the duration spelling
`t_plus` (whole frames until the boundary time covers the duration, mutually
exclusive with `frames`); together the write/read halves of D-088's
advance-assert and fly-inspect idioms and the migration path for the suite's
dominant write-`u` → `step!` → assert idiom.

**Rejected.**
- *A special harness device:* a device with no task is `stage!` with extra
  ceremony.
- *`step!(sim; inputs = …)` drain-from-argument:* a second staging spelling
  with no `run!` analogue.
- *Direct slot pokes from the calling task:* §2.5/§12.5's rejected
  unrecorded-mutation idiom — breaks replay.
- *Leaving reads to device handles or the log:* the log can be off, a handle
  needs a device, and D-088's "inspect" must be spellable.
- *A public closure-evaluation API:* §13.5's rejected cost — an inspection
  *accessor* returning the immutable snapshot is not it.

### D-098 — Resolve selectors against a source before client policy

**Status.** ratified

**Position.** Selector source axis: a selector resolves against a *source*
before any client policy — table selectors
(`get_output`/`get_local`/`get_slot`/`get_face`) against boundary snapshots;
store selectors (`get_state`/`get_deriv`) only against live stores, which only
stopped-sim service evaluations, `capture` and post-run inspection ever hold.

**Spec.** §14.4

**Rationale.** A snapshot-bound reader naming a store selector is an
attach-time `ReadBindingUnresolved` (new `reason` payload field), didactic
style, remedy = declare the field public and read the auto-published port;
D-083's client split rides on top unchanged, D-095's family stays closed and
identically spelled.

**Rejected.**
- *Client-only validation:* D-095's original "diagnostic readers admit the
  whole family": an output device binding `get_state` passes attach — the
  schema knows the field — then has nothing to gather from at run time, the
  silent-garbage failure attach validation exists to prevent; `get_deriv` worse
  — `ẋ` is integrator scratch, not boundary-consistent.
- *Runtime resolution failure:* defers the error §11.2 and the C172X case study (`flight_case_studies.md`) deliberately moved
  to attach.
- *Snapshots carrying stores to make such bindings resolvable:* D-038 stands —
  the source axis enforces it.

### D-102 — Author-owned device loop inside a framework-owned bracket

**Status.** ratified

**Position.** Device authoring contract: author-owned loop body inside a
framework-owned bracket — a device implements `init!(dev)` (per-run resource
acquisition, calling task, pre-spawn), `loop(dev, handle)` (the task body,
owning its own wait structure, composed from handle primitives),
`shutdown!(dev)` (guaranteed via the wrapper's `finally`) and optional
`unblock!(dev)`.

**Spec.** §11.1, §11.6, §12.4, [Appendix A][sA]

**Rationale.** The wrapper is try/catch/finally with `DeviceCrash` on catch and
claims-release/detach on every exit; `should_close` dissolves into the loop
body returning (voluntary exit); the GUI implements the same contract, called
inline on the calling task (§11.1); heartbeat timestamps ride inside handle
primitives, so liveness needs no loop ownership; the two author obligations
(`running(handle)` predicate, interruptible blocking) are taught ([Appendix A][sA])
and diagnosed (`DeviceJoinTimeout`, stale heartbeat), never forced.

Annotation (2026-10-13): amended by D-366. Only `loop` is mandatory;
`init!`, `shutdown!` and `unblock!` are optional hooks with no-op defaults.

**Rejected.**
- *Framework-owned hook loop (FlightCore's shape):* its eight hooks were never
  sufficient alone, the loop came in three taxonomy-carried flavors; one kind
  would force a declared wait kind = the taxonomy as a trait; the bidirectional
  peer needs two waits a hook loop cannot serve without a select engine; the
  GUI fits no hook set.
- *A two-hook middle (`wait_datum` + `process`):* same failures, softer.

### D-103 — Detect a binding's sides by method presence at attach

**Status.** ratified

**Position.** Binding interface: a binding is a value whose type implements
`faces(b)`/`map_input(datum, b)` (input half: enumeration → claim; mapping
arbitrary and never inspected) and/or `selectors(b)`/`map_output(nt, b)`
(output half: §14.4 selectors compiled to one gather at attach); sides detected
by method presence at attach (the §8.5 declaration-shape idiom; `hasmethod` is
public stable API at a service point, not D-074's internal-reflection seam),
neither side = attach error.

**Spec.** §11.4, §11.6, §8.5, §14.4

**Rationale.** No datum-shape contract exists — the datum travels only between
`loop` and `map_input`, same author; binding is an `attach!` argument, never a
device field (narrowing the binding narrows the claim); `TableBinding` is the
one shipped data-driven type (entries in the type ⇒ per-table specialization),
its generic `map_input` owning §11.4's conditioning helper; `map_input` purity
taught: cross-datum state lives in the device struct, arrives inside the datum.

**Rejected.**
- *Abstract binding-type taxonomy:* resurrects the §11.6 kill one level down; a
  bidirectional binding cannot be two types at once.
- *A declared `sides(b)` trait:* redundant with the methods that must exist,
  one more thing to drift.
- *Per-device custom mapping code as the norm:* the table case is data, not
  code — one framework `map_input` serves every pairing.

### D-104 — Coalesce staged writes by CAS merge with per-attachment positional shape

**Status.** ratified

**Position.** Staged representation and coalescing: one policy — CAS merge,
newest wins per face (merge is always correct: complete writers get overwrite's
result, sparse writers are protected from its lost-write bug); enumerated
writers get a per-attachment fixed shape compiled at attach — positional tuple
over the claim set, `Union{Nothing,T}` isbits per face, `nothing` = not touched
(never reset), schema in the roster entry — giving positional merge, an
attach-compiled drain scatter (mirror of §11.2's gather), and `stage!`-side
normalization (name → position, convert, fill `nothing`) so authors return
sparse face ⇒ value pairs and the name-shaped dynamism is confined to one
framework conversion on the device task.

**Spec.** §11.2, §11.4

**Rationale.** The interactive writer gets the same treatment under the D-106
freeze — positional shape over the unclaimed set, recompiled at each
stopped-sim `attach!`/`detach!` (which also renormalizes pending batches:
reshape, discard newly-claimed faces with `ClaimedFaceEntry`) — one
representation, no name resolved inside the loop's frame; diagnostic sites all
at staging — `OutOfClaimEntry`, `ClaimedFaceEntry`, `EntryTypeMismatch` — and
the drain checks nothing (D-106); trace records match batch density (D-107);
user-proposed shape (fixed tuple with `nothing` markers), framework-relocated
normalization.

**Rejected.**
- *Name-keyed interactive batches, the earlier design of record:* justified
  only by the mid-session-mutable surface the D-106 freeze removed.
- *The `complete(binding)` overwrite opt-in, drafted then dropped:* under
  positional merge the fast path saves a pending-read and a tuple rebuild on
  the device task — not worth a declarable promise whose false direction loses
  writes; supersedes the earlier attach-flag sketch.
- *Author-built total tuples:* a padding form — the D-074 / handler-return-law
  disease.
- *Name-keyed batches everywhere:* dynamic dispatch in the drain, inside the
  loop's frame.
- *One build-wide shape over all root faces:* trace memory inflates by
  faces/entries, and only the interactive writer would need it.

### D-105 — Split device-side bad-datum handling into tolerated garbage and propagated crashes

**Status.** ratified

**Position.** Device-side bad-datum policy: two failure classes, two fates —
environmental garbage (truncated datagram, malformed JSON, out-of-range field)
is tolerated in the loop body (catch, stage nothing, `report(handle,
MalformedDatum(cause))`, continue; rate-limited per device — the `maxlog = 25`
successor), any other exception propagates to the wrapper as `DeviceCrash`.

**Spec.** §11.4, §11.6, §13.2, §13.4

**Rationale.** Classification is the author's, as FlightCore's
`InputMappingError` docstring already assigned it; `report(handle, …)` is
scoped to device-attributed runtime warnings, not a general user-diagnostics
channel; companion drain-family kind `EntryTypeMismatch` for values
unconvertible to the slot's declared type, checked at staging for every writer.

**Rejected.**
- *A marked exception type (`InputMappingError` successor):* vestigial under
  the author-owned loop, since no framework per-iteration catch site exists to
  consume it.
- *Spec silence:* the natural reading reproduces first-bad-packet-kills-device,
  for the whole run under D-093.
- *Tolerate-everything:* hides bugs as "device attached, nothing happens".

### D-106 — Freeze the device roster for the duration of a run

**Status.** ratified

**Position.** Roster freeze: `attach!`/`detach!` are stopped-sim operations —
legal in `built`/`initialized`/`stopped`, an error while `running`, pause
included (pause is inside a run) — so the roster and the partition of the root
face set into per-writer surfaces plus the interactive remainder are static,
inspectable facts of each run; attach has one semantics (register; tasks appear
at `run!`, D-093).

**Spec.** §11.3, §11.4, §11.6, §12.3, §12.5, §12.7

**Rationale.** All write-surface checks move to staging and the drain is pure
application, fully compilable against the frozen roster (specialization an
implementation freedom, not an obligation — the §9.7 per-configuration compile
trade); device death mid-run is not detach — the task dies, the heartbeat
reports it, claims and roster entry persist to run end (**reversal of D-087's
zombie-claims rejection**: that rejection served dynamic liveness derivation,
and with liveness baked per run the rationale inverts — a mid-run release would
move a surface nothing can soundly recompute); orphan recovery is between runs
(stop → `detach!` → `init!`, or `replay!`-to-end + `run!` continuation, §12.7);
§12.5's doctrine reaches final form — the running periphery stages writes and
issues control commands, and nothing else changes. **Guarded addition on
record**: mid-run attach for pure readers (no input half — claims nothing,
moves no surface; a dynamic reader list touches only §12.3 wakeups, heartbeat
and shutdown join, never the drain), cleanly severable should
join-a-running-session find a customer. Supporting fact: FlightCore has no
mid-run attach — every demo attaches before `run!`, and `run!` blocks its
caller in both designs, so the dropped capability had no demonstrated customer
and was barely reachable.

**Rejected.**
- *The earlier attach-anytime design of record:* D-087's republished-roster
  machinery, drain-time derived-surface membership checking via
  `StaleInteractiveEntry`, §11.7's mid-drag claim-transition policy, per-attach
  thread-budget re-checks — all priced for a hypothetical workflow.
- *Mid-run claim release on device death:* the reversed D-087 rejection — under
  a frozen surface it is the *release* that would be unsound.
- *Attach-while-paused:* a surface change inside a run — forfeits every
  staticity benefit at the moment it is exercised.
- *Reader exception adopted now rather than guarded:* no customer; the freeze
  stays maximally simple.

### D-107 — Match trace record density to batch density, not surface width

**Status.** ratified

**Position.** Trace records match batch density: enumerated writers' positional
batches are retained verbatim, zero-copy (claim-narrow, dense by nature); the
interactive writer's wide mostly-`nothing` tuple is converted at the drain on
retention — (position ⇒ value) pairs for the non-`nothing` entries, an
O(surface-width) scan and one small allocation at most once per frame, only on
interactive-active frames, inside the §9.8 retention carve-out the log already
occupies — so trace size tracks information, not surface width, preserving
D-029's two-orders-below-the-log budget at every world scale.

**Spec.** §9.8, §11.5, §12.7

**Rationale.** The header carries each writer's face-name → position schema
(positional records are meaningless without it and replay does not reconstruct
claims); replay pays the inverse conversion once, up front, in the §12.7
validation pass — no name resolved per frame under replay either; conversion
site is the drain, not the staging shim (the drained tuple is the coalesced
truth; a shim-side sparse log would need its own merge).

**Rejected.**
- *Verbatim retention of interactive positional batches:* size tracks surface
  width × edit rate — at hundreds of unclaimed faces, render-rate dragging
  inflates the trace past the budget that justifies trace-on-by-default; a
  mostly-`nothing` tuple is also schema-bound and hostile to inspection.
- *Sparse records for enumerated writers too:* their batches are dense — sparse
  encoding adds names for nothing.
- *Shim-side sparse recording:* needs its own merge to match coalescing.
- *Keeping name-keyed replay application:* re-imports the dynamic drain path
  replay exists to avoid.

### D-127 — Add a deployment block to the trace header for replay validation

**Status.** ratified

**Position.** The trace header gains a **deployment block** — `t₀`, `Δt_base`,
`h`, `n`, the algorithm identifier and the effective `t_end`/`stop_on` pair,
captured with the stores. §12.7's up-front pass treats it in two ways:
`Δt_base`/`h`/`n`/algorithm compared against the target's deployment binding
(widened to six by D-133: `localization_tol` and `event_budget` join both the
block and the comparison), mismatch = `ReplayHeaderMismatch` with a new
deployment-parameter discriminator — structural, never a what-if, since a
deployment change moves the times at which frame-ordinal batches apply
(different inputs, not a modified model); `t₀` applied rather than compared
(replay stands in the `init!` position and owns the anchor — no new `replay!`
argument); the termination pair recorded but never constraining (overrides bind
at replay as at `run!`, D-091).

**Spec.** §11.5, §12.7, §13.5, [Appendix B][sB], [Appendix C][sC]

**Rationale.** Defined as the artifact "run metadata" already named three times
without a home (§13.5 ×2, [Appendix B][sB]; D-091's obligation, now discharged).

**Rejected.**
- *Validating the whole block uniformly:* freezes `t_end`/`stop_on`, which
  §12.7 explicitly leaves overridable, and a recorded `stop_on` termination
  reproduces itself anyway.
- *An overridable deployment check to allow what-if-with-different-`h`:* not a
  what-if under §12.7's own definition — what-if replay promises the recorded
  inputs, and ordinal keying re-times them under a changed grid.
- *A separate `ReplayDeploymentMismatch` kind:* one validation pass, one
  carrier — the payload discriminator mirrors the store/slot split already
  there.

### D-132 — Treat operator interrupt (Ctrl-C) as a control-plane stop, not a failure

**Status.** ratified

**Position.** The operator interrupt (Ctrl-C) is a control-plane stop, not a
failure. It joins `t_end`, `stop_on` and the GUI/handle/code stop among
§12.4(1)'s initiation sources: the run completes the current boundary,
publishes the final snapshot, takes the ordinary graceful tail and ends
`stopped` — boundary-consistent, serviceable by the §14 services, resumable by
the next `run!`.

**Spec.** §10.7, §11.6, §12.4(1), §12.4(3), §12.4(5), §13.4, §13.5, §14, §14.8,
[Appendix C][sC]

**Rationale.** **Boundary masking is normative**, not an implementation hint:
because `InterruptException` is asynchronous, the loop masks delivery across
the boundary macro-sequence (Julia's `disable_sigint`, a sigatomic counter
increment per frame) and takes the deferred raise at the unmask points — frame
top, wait and pause blocks — all boundary-consistent; the
`stopped`-with-consistent-stores guarantee depends on it. Two discrimination
clauses fall out: §13.4's catch site never wraps an `InterruptException` in
`StepError` (routes it to the stop path; unreachable in practice under masking,
kept defensively), and §11.6's device wrapper never turns one into `DeviceCrash`
— in the spawned-loop topology Ctrl-C lands in the calling task's inline device
loop body (the GUI), which forwards the stop and exits through the ordinary
`running(handle)` predicate, no `should_abort` consultation. A **second**
interrupt during the tail collapses the remaining device joins immediately —
§12.4(5)'s abandonment path taken at once, devices still named — and the run
still ends `stopped`; escalation shortens the tail, never reclassifies the run,
and cannot repair §12.4(5)'s honest asymmetry (nothing can abandon the task
`run!` stands on). Scope is the **interactive session**: outside the REPL
Julia's default `exit_on_sigint(true)` kills the process on SIGINT first, the
framework flips nothing process-global, and unattended runs rely on
`t_end`/`stop_on` as they already must. The termination record tags the stop
source (§13.5), distinguishing it from `t_end`, `stop_on` and a
programmatic/GUI stop, with no new diagnostic kind; `UnboundedRun` ([Appendix C][sC])
names it as the sanctioned escape from the configuration it warns about; and
the services need no story of their own — an interrupt during a long `trim!`
unwinds an ordinary call over per-invocation scratch stores, no commit having
happened (§14.8). Precedent correction, recorded because it is easy to miscite:
FlightCore's `interrupt!` (iodevices.jl:36, its one override closing UDPInput's
socket at shutdown) is a per-device unblocking hook — the direct precedent of
§12.4(3)'s `unblock!`, not of this path; FlightCore has no
`InterruptException`/SIGINT handling anywhere.

**Rejected.**
- *Treating the interrupt as a runtime failure — the `StepError` path an
  unguarded Ctrl-C takes today:* destroys the session it means to pause:
  terminal `errored`, no services, no resume, and with mid-boundary delivery,
  dirty stores.
- *Pausing instead of stopping:* does not return the prompt in the synchronous
  deviceless case — the very run that has no other escape — and a paused run is
  not serviceable.
- *A public `interrupt!` entry point:* redundant: the control plane already
  carries the stop, and a function call is available to code that could have
  called `stop` anyway — the FlightCore name would also import an unrelated
  per-device meaning.
- *Process-global `exit_on_sigint(false)` set by the framework:* changing
  process-wide signal behavior behind the user's back, and wrong for the
  unattended runs that want the kill.
- *Escalation reclassifying the run as `errored`:* nothing is broken — the
  operator asked twice for the same stop.

### D-134 — Declare the interactive write-surface class via a binding marker method

**Status.** ratified

**Position.** The derived write side becomes **declared**: `interactive(b)` is
an optional marker method on the *binding* — the write-surface class is a
binding fact, not a device fact — probed at attach exactly like the other sides
(§11.6's method-presence idiom).

**Spec.** §11.2, §11.3, §11.4, §11.6, §11.7, §12.3, Appendices B/C/D

**Rationale.** Completes D-044's partition. `interactive` defined ⇒ derived
write side: no claims staked, and §11.4's positional staging shape compiled over
the unclaimed face set instead (that compilation already existed; it now has
its declared trigger). `interactive` and `faces` are **mutually exclusive** (a
surface cannot be enumerated and derived at once — attach-time error naming
both declarations); `interactive` is orthogonal to `selectors` (an interactive
front end may also drive a compiled output gather — legal, currently
uninstantiated, the plausible customer a narrow-wire interactive surface such
as a motorized control board); "neither ⇒ error" becomes "none of the three ⇒
attach-time error". **At most one interactive device per roster**, beside the
always-present harness cell: a fourth part of the attach-time admission check,
in `needs_calling_task`'s shape and error style (`InteractiveConflict`, naming
both the rostered holder and the candidate, exactly as `CallerTaskConflict`
does) — the derived surface is shared rather than partitioned, and the
singleton keeps intra-surface drain order trivial (interactive device, then
the harness cell last). The shipped GUI binding is the class's **sole shipped
instance**, declaring `interactive` only: no `faces` (its surface is computed),
no `selectors` (its read path is the handle's primitive read — VSync-paced
`latest` per render, §12.3 — with an ad-hoc render-time read set over the whole
snapshot in an inspection read's shape, §11.2, so the compiled gather has
nothing to do for it); `gui = true` becomes "attach the standard GUI device
under the standard interactive binding iff no interactive device is already
rostered" (D-109's idempotency, now stated against the class rather than the
type). Two non-reopenings are on record: §11.6's rejected `sides(b)` trait is
*not* what this marker revives — that rejection turns on redundancy with
methods that must exist anyway, and nothing analogous exists here, the derived
surface being computed, so no method's presence could witness the class and a
marker is the only possible declaration, not a second copy of a fact; and
D-044's rejection of unclaimed-surface opportunism "for any device" stands
unchanged — autonomous devices still enumerate, the interactive writer stays
human-mediated, singleton-limited and staging-checked (`ClaimedFaceEntry`
untouched). The marker makes the privileged class visible and checkable, not
open.

**Rejected.**
- *`faces(b) = :derived` (a sentinel return):* i.e. a dual-meaning enumeration
  contract — exactly the ambiguity the declaration vocabulary is built to
  refuse.
- *Empty-tuple-or-`nothing`-means-derived:* silent promotion of an accidentally
  empty enumeration — `faces` bodies are ordinary code, comprehensions included
  — to the interactive writer's *maximal* write surface: the silent-widening
  class this design refuses everywhere, and the most privileged classification
  must be the hardest to enter by accident; `faces(b) = ()` keeps its honest
  meaning, an inert enumerated device whose writes are still binding-bounded by
  `OutOfClaimEntry`.
- *A shipped concrete `InteractiveBinding` type:* edges toward the abstract
  binding-type taxonomy §11.6 already rejected, and abandons the method-presence
  idiom the other sides use.
- *Forbidding `interactive` + `selectors`:* orthogonal machinery, and a rule
  that would have to be unmade for the first narrow-wire interactive surface.
- *Leaving the class undeclared with the GUI special-cased:* the status quo
  under review — §11.3's "the GUI is not an exception but the resident of the
  second class" stays aspirational, the class has no membership test, and a
  second interactive front end has no spelling.

### D-136 — Unify diagnostics and liveness heartbeat into one per-writer diagnostic cell

**Status.** ratified

**Position.** Closing D-133's §13.2 deferral, the runtime diagnostic stream and
the liveness heartbeat get one mechanism — **one per-writer diagnostic cell**,
one per rostered device plus one for the loop itself, single-writer by the same
ownership argument as §11.4's staging cells (no lock, no arbitration, no new
primitive), holding a **bounded ring of 16 diagnostic values plus per-kind
suppressed counts** and an atomic heartbeat timestamp.

**Spec.** §9.8, §10.7, §11.1, §11.2, §11.4, §11.6, §11.8, §12.2, §12.4, §13.2, §13.5,
Appendices C/D

**Rationale.** The bound **is** the rate limit — an emission past capacity
within a frame is not stored and its kind's count increments, earliest-in-frame
retained — which homes §13.2's "rate-limited wherever its source can repeat" as
a structural property of the channel and discharges D-133's deferral with no
constant to tune. The loop takes each cell with `atomicswap` at the **frame-top
drain**, §11.4's own point, swapping in a **shared empty sentinel** so a quiet
frame allocates nothing and no load-only path goes untested; the heartbeat
rides in the same cell — stored on every loop pass from inside the handle
primitives (§11.6), acquire-loaded at the drain, §12.2's 2 s staleness read
against this field, and not a diagnostic kind. The published **framework status
becomes a concrete frozen value**: per writer `recent` (this boundary's drained
ring), `suppressed` (the per-kind counts the ring refused this boundary),
`totals` (loop-owned cumulative per-writer × per-kind counters, *copied* into
each status) and `heartbeat`, beside §10.7's pacer diagnostics — §11.2's binding
rule holding **by construction**, since the swap gives the loop exclusive
ownership of the batch before publication and the live accumulator is never
reachable from a snapshot. Presentation is separated from channel policy:
renderers print a writer × kind up to **25 cumulative occurrences** and then
switch to count-only display (the `maxlog` successor), counts accumulating
regardless; and the **terminal snapshot carries the final cumulative counters**
(§12.4(1), §13.5), so an unattended run's complete diagnostic account survives
its own shutdown. The allocation story is spec-stated: a quiet frame adds
**zero heap allocation**, the per-writer status riding inline in the
per-boundary snapshot allocation §11.2 already accepted — which requires the
per-kind counters to be a **fixed-shape isbits record, never a `Dict`**,
licensed by [Appendix C][sC]'s closed kind set — while a noisy frame allocates its
values at emission on the writer's own task and a **fresh ring** lazily at the
writer's next emission (the drained one being frozen into a snapshot and
unwritable thereafter), the same GC-over-reuse trade §11.2 made when it rejected
preallocated snapshot buffers; worst case per writer per boundary is therefore
one ring of 16, everything past it an integer increment, and §9.8's scoped
model-sweep zero-allocation invariant is untouched. Composition note, recorded
once: `totals` is monotone across logged snapshots, so `log_every` decimation
loses *which* boundary in a skipped stretch an occurrence fell on, never *how
many*.

**Rejected.**
- *A shared queue or buffer under a lock:* cross-task contention on the loop's
  own frame path and no single-writer ownership to reason from — the arbitrary
  shared mutable state §11.1's two rules exist to eliminate, reintroduced for
  the one structure that had escaped specification.
- *A status referencing the live accumulator:* the cheapest thing to write and
  a direct violation of §11.2's binding rule — a reader walking a structure its
  writer is still mutating.
- *Ring reuse by double-buffering:* reintroduces exactly the reader-liveness
  proof the GC provides for free — §11.2's own argument against preallocated
  snapshot buffers — to save an allocation incurred only on frames already
  doing something unusual.
- *Unbounded accumulation:* an unattended run with no status reader grows
  without bound, precisely the configuration the framework must survive, and a
  bound is what gives the drop policy a definition.
- *A separate heartbeat channel or liveness registry:* a second cross-task
  structure with the same writers, the same ownership question and the same
  drain point, for one timestamp.
- *A per-device rate-limit constant, D-133's deferred option:* the structure
  carrying the stream already bounds it — a tunable would name a policy the
  channel cannot violate anyway.
- *A render threshold baked into the channel:* what is recorded must not depend
  on who is looking; 25 is a renderer's number.

### D-137 — Bound snapshot-log retention by count, with amortized doubling stride

**Status.** ratified

**Position.** Snapshot-log retention gets a **bound**, `log_max` — the maximum
number of retained snapshot references, a new `Simulation` keyword beside
`log`/`log_every`.

**Spec.** §4.1, §4.4, §9.8, §10.7, §11.2, §11.5, §11.8, §12.4, §12.7, §13.5,
Appendices B/D

**Rationale.** **A count, not a memory budget**: snapshots are immutable object
graphs with internal sharing (§4.1, and §4.4 field handles riding as references
to build-time-frozen data, §9.8), so byte accounting over them is fuzzy and
platform-dependent, while a count is exact and converts to memory through one
number the user measures once (`Base.summarysize` of a single snapshot).
**Default 65536 (2¹⁶), finite unconditionally**, with `Inf` the explicit
opt-out — no modal rule keyed on `t_end`; a finite run shorter than the bound
never notices it, and at 50 Hz full density 2¹⁶ boundaries is ≈22 minutes
before the first drop. **When the log fills, the effective retention stride
doubles** — `log_every · 2^k` after k generations — so the bound holds while
coverage stays **global**: the whole run remains plottable at coarsening
density, which is D-038's division of labor carried through (the log's chief
consumer is the post-run plot of a session as a whole; full density over any
*segment* of interest is what replay from the trace recovers, §11.5, §12.7). The
licence is D-038's own asymmetry, a fortiori: a thinned log costs resolution in
a *view*, never a record, whereas D-029's refusal to thin the trace stands
untouched. Following D-135's precedent, **the guarantees are normative and the
mechanism a sketch**: normatively the retained count never exceeds `log_max`,
coverage is global at the effective stride, and the endpoints are kept; the
sketch is that the thinning is **amortized** — the stride doubles immediately
and each subsequent retained append also releases one predecessor of the
previous generation (a cursor over the odd indices, O(1) amortized, physical
compaction once per generation), the generation's thinning completing exactly
when its refill does. Amortization is a responsiveness choice: a one-shot
halving would make ~`log_max/2` *old-generation* snapshots unreachable at a
stroke, a major-GC burst worth a pacer-absorbed, `DebtReanchor`-visible hiccup
(§10.7) — exponentially rare, the wall-clock gap between generations doubling,
but needless — while the amortized form drops exactly one old snapshot per
retained append, the steady trickle a rolling window would produce anyway; the
loop's own work is pointer bookkeeping, microseconds either way and on the
framework side of §9.8's scope, publication staying wait-free with readers
never blocking. **The boundary-zero (§14.5) and terminal (§12.4(1), §13.5)
snapshots are retained unconditionally under any `log_every` and any `log_max`,
and do not count against the bound** — two extra references — so the run's
endpoints and, via the terminal status's final cumulative counters (§11.8,
D-136), its complete diagnostic account always survive. Compositions stated
once: `totals` monotonicity across logged snapshots (§11.8) is unaffected,
re-decimation losing *which* boundary in a stretch an occurrence fell on and
never *how many*; and `log_max` is a **view policy, not
trajectory-determining** — outside the trace header's deployment block, neither
recorded nor compared by replay (D-127, D-133's compared set untouched). §9.8's
`sizehint!` for the expected duration is reconciled: now capped by `log_max`,
which is also what defines the hint when `t_end = Inf`. No new diagnostic kind
— hitting the bound is stated policy, not an event to report.

**Rejected.**
- *A rolling window:* optimizes recent-past-at-full-density, which replay
  already serves, at the cost of the whole-run overview replay is expensive for
  — and it buys no responsiveness either, its steady-state drop rate being
  exactly the amortized form's.
- *A memory-based bound in bytes:* false precision over shared immutable graphs
  — the number would be platform-dependent and unauditable, where a count is
  exact and one measurement converts it.
- *A modal default, finite only when `t_end = Inf`:* a modal rule where one
  unconditional number suffices, and the finite-`t_end` run it exempts is the
  one that never reaches the bound anyway.
- *An unbounded default, the status quo under review:* gigabytes per hour at
  C172X scale and 50 Hz in the configuration [Appendix B][sB] calls the honest
  interactive default, ending in an OOM no diagnostic mentions.
- *One-shot halving as the normative mechanism:* an old-generation major-GC
  burst once per generation — pacer-absorbed and rare, but needless when
  amortization achieves the rolling window's trickle profile at the same
  asymptotic cost.
- *A diagnostic kind for reaching the bound:* a policy operating exactly as
  configured is not a warning, and the log's density is visible in the log
  itself.

### D-138 — Make device `init!` an explicit, bracketed step of the run-start protocol

**Status.** ratified

**Position.** Device `init!` becomes an **explicit step of the §12.4 protocol**,
taken at the top of a run — once per roster entry, in attachment order, on the
calling task, pre-spawn — with **each call in its own bracket**: on a throw the
framework calls `shutdown!(dev)` on the failing device right there, reports
`DeviceCrash` by name and marks it dead, no task being spawned.

**Spec.** §11.1, §11.3, §11.6, §11.8, §12.2, §12.4, §13.5, §14, §14.6, Appendices
A/B/C/D

**Rationale.** Release is therefore **unconditional**, which is what makes
§11.6's "guaranteed on every exit path" and §12.4's "`shutdown!` has released
each device's OS resources" true of the one path outside the wrapper, and it
carries a **new taught obligation** (§11.6, [Appendix A][sA]): `shutdown!` must
tolerate a **partially initialized** device — "close only what is open" — the
same defensiveness the crash path already demands. **No new diagnostic kind**:
`DeviceCrash`'s payload (device id, `cause`, whether `should_abort` was set)
already fits an init-time failure, [Appendix C][sC]'s gloss merely naming the site. A
failed device is **dead from boundary zero** with no dead-marking machinery of
its own — it never stores a heartbeat timestamp, so its cell reads stale
against §12.2's threshold from the first frame (§11.8, D-136) — and its **claims
persist to run end**: §11.3's death-is-not-detach disposition applied one step
earlier than §12.4(6)'s, the orphaned slots holding their initial values,
well-defined by §14.6's slot totality where a (6) orphan holds a last drained
batch. **Run disposition splits on `should_abort`, uniformly with (6)**: clear
(the default) the remaining entries initialize, the run starts and the sim runs
with the device absent from frame zero — (6)'s semantics shifted to `t₀`; set,
the failure requests a control-plane stop that is **already pending at boundary
zero**, so the run reuses §13.5's existing terminal-at-`t₀` path — remaining
entries still initialize, every rostered device getting its `init!`/`shutdown!`
pair uniformly, boundary zero is published, the run ends `stopped` at `t₀`
through the ordinary §12.4 tail and the termination record names the source.
**Topology is derived after initialization** (§11.1): a failed
`needs_calling_task` holder returns the loop to the calling task rather than
parking it on a device that will not exist. Finally `should_abort` gets the
**declaration site** it never had: an **`attach!` keyword, default `false`** —
matching (6)'s narrative default ("the sim continues with the device absent"; a
dead joystick must not kill a session) — with the **shipped GUI attaching
`should_abort = true`** (closing the window is the interactive session's
natural end) and `gui = true`'s standard attachment stating that value
([Appendix B][sB], D-134's sugar unchanged); [Appendix D][sD] gains the glossary entry.

**Rejected.**
- *Requiring `init!` to clean up after itself on failure:* an unenforced burden
  duplicated in every device, and unenforceable in exactly the half-built cases
  that matter — the bracket does it once, for all of them.
- *Short-circuit teardown on an aborting init failure, ending the run without
  publishing:* invents a second exit path beside §12.4's one tail and yields a
  `stopped` sim with no terminal snapshot — unserviceable by §14, with nothing
  for the log's unconditionally-retained endpoints to retain.
- *A dedicated init-failure diagnostic kind:* `DeviceCrash`'s payload and
  disposition already fit, and [Appendix C][sC]'s closed set pays for every addition.
- *Topology frozen from the roster before initialization, the status quo:*
  parks the loop on a spawned task and the calling task on a loop body for a
  device that does not exist.
- *`should_abort` defaulting to `true`:* a dead peripheral kills a session —
  the opposite of §12.4(6)'s stated intent.
- *Declaring `should_abort` in the device authoring contract as a fifth
  function or a trait:* it is an *attachment* fact — the same device is
  advisory in one deployment and relied on in another, and the contract is
  the place where per-deployment policy least belongs.
- *Leaving initialization failure at "reported by name through (6)'s crash
  path":* the clause under review — (6) is written about a task that has
  already spawned, so it answers none of release, disposition or topology.

### D-160 — Rename `report` to `report!`

**Status.** ratified

**Position.** **`report` renamed `report!`** — it writes device-attributed
runtime warnings into the device's diagnostic cell (§11.6, §11.8) and mutating
actions carry the bang, beside its already-banged contract neighbours `stage!`
and `mark_dead!`.

**Spec.** §11.6, §11.8

**Rationale.** A round-5 vocabulary finding (finding 2.1), per D-144's class
(3).

**Rejected.**
- *Keeping the bare spelling:* a mutating action in noun dress — the class
  violation D-144/D-146 exist to retire.

### D-168 — Root-slot fan-out tolerance combines by meet, not agreement

**Status.** ratified

**Position.** Root-slot fan-out under permissive entries combines **tolerance
by a meet, not by agreement**: the slot *type* stays the unique concrete
declaration among its consumers at nominal (`RootSlotTypeConflict` unchanged —
a tolerance difference is not a type conflict, `SVector{3,T}` and
`SVector{3,Float64}` both evaluating to `SVector{3,Float64}`), while the slot's
cells **pin at every activation if any consumer entry pins** and follow the
activation scalar only when every consumer tolerates.

**Spec.** §6.1, §11.3, §8.2, §14.10

**Rationale.** Mixed tolerance is a legitimate configuration rather than a
mistake — one command consumed by a promoting aerodynamics leaf and by an
AD-opaque table is §8.2's FFI door in use — and the meet is the only
assignment satisfying every consumer at once, forced by the direction of
embedding: a pinned cell feeds a `T` entry lawfully (zero-partial embedding,
§9.5) while a `Dual` arriving at a `Float64` entry is exactly what that entry
forbids; it is the mirror of §6.1's producer-side walk-compatibility clause.

The cost is stated where it is paid: such a slot is declaredly unseedable, and
a `B`-matrix tap selecting it is rejected at tap resolution naming the
**pinning consumer** and its entry (`TapResolution` payload extended), not the
face alone, because the author's next move — promote that leaf, or route the
tap around it — depends on knowing which leaf froze the slot.

Closes the fan-out gap left open by D-167.

Annotation (2026-09-08): read at the level of the whole root input, with the
two-candidate computation, per D-236.

**Rejected.**
- *Requiring agreement at the marker scalar (mixed = build error):* turns a
  legitimate model into an error whose only remedies are a duplicated slot or a
  false declaration, and makes one component's private AD limitation contagious
  across wiring its author does not control.
- *Join semantics (the slot walks if any consumer tolerates):* unsound in the
  direction that matters — it delivers `Dual`s to an entry that declared it
  cannot take them, the exact failure §6.1's clause exists to prevent, moved
  from build time to inside user math.
- *Per-tolerance-class slot cells (one cell per class):* duplicates the slot,
  defeating §11.3's one-cell-per-slot staging, the trace header's single type
  and `probe_value`'s single synthesis.

### D-176 — Unify trace retention on one sparse record format

**Status.** ratified

**Position.** Trace retention unifies on one sparse record format (supersedes
D-107's density rule): the verbatim-vs-sparse dichotomy is eliminated —
**every** writer's drained batch is sparse-converted at the drain into
(position ⇒ value) pairs against the header's schema, so the trace has one
consumer-facing record format, no per-entry format flag, and replay one
inverse-conversion path.

**Spec.** §9.8, §11.5, §12.7, [Appendix D][sD]

**Rationale.** Costs recorded where they are paid: ~2× trace size on the dense
component (two small values per touched face where the tuple held one, the
order unchanged and D-029's two-orders-below-the-log budget untouched); the
conversion allocates once per drained batch, in-class with §9.8's retention
carve-out and smaller than the log's per-boundary snapshot, which the carve-out
already covers. The decision is **reversible as pure implementation**:
conversion is lossless both ways, so verbatim retention could return as a
per-entry storage optimization without touching the record semantics, the
header or replay. Motivation: D-174 made "enumerated ⇒ claim-narrow ⇒ dense"
false — a greedy claim is enumerated and as wide as the root contract — so
density could only be re-keyed on the claim source, i.e. on a distinction D-174
exists to erase.

**Rejected.**
- *Keying retention by claim source:* a dichotomy needing re-justification at
  every change to the surface machinery, resting on a premise — enumerated
  means narrow — that `is_greedy` falsifies.
- *Deciding density per batch at the drain:* per-frame heterogeneous record
  formats, a format flag on every entry and two decoders in every consumer, for
  no customer that ever asked to tell the two apart.

### D-177 — Re-found the periphery on mandatory roots plus declared traits

**Status.** ratified

**Position.** The periphery's declaration idiom is re-founded on declared
traits over mandatory neutral roots: every device subtypes `AbstractDevice` and
every binding `AbstractBinding`, mandatorily, so `attach!(sim,
dev::AbstractDevice, binding::AbstractBinding; should_abort = false)` gates at
dispatch — §8.5's one-root rejection does not transfer, the periphery's
single-inheritance slot being vacant (no domain hierarchies compete for it) and
a binding's sidedness being its **public contract**, not the §8.3-hidden
implementation class a component's tier is.

**Spec.** §11.3, §11.6, §8.1, §8.3, §8.5, Appendices A/B/C, glossary [§D.6][sD-6]

**Rationale.** Binding sides are **declared by Bool traits** with framework
defaults on the root — `is_input`/`is_output` false, `is_greedy` false, the
claim-source selector *within* the input side — and the enumeration obligations
are enforced by **error fallbacks** (`claims(::AbstractBinding)`,
`reads(::AbstractBinding)`) plus a **bidirectional conformance check at
attach**: is_input && !is_greedy ⇒ `claims(b)` called once (a missing method
fires the fallback loudly); is_input && is_greedy ⇒ claim computed and a
defined `claims` method is an error; is_output ⇒ `reads(b)` called; neither
side declared ⇒ attach-time error; is_greedy && !is_input ⇒ error; and a
*specific* method of `claims`/`reads` defined for the binding type while the
corresponding trait is false ⇒ error, detected by `which` against the fallback
(§8.1's reflection class, run at a stopped-sim service point).
Trait-true-method-missing and method-defined-trait-false both report the new
diagnostic `BindingContractMismatch` (service), naming the trait and the method
at fault. `map_input`/`map_output` remain conventions of the author-owned loop
idiom the framework never calls — taught in [Appendix A][sA], never checked. What
this closes: under method-presence detection a bidirectional binding whose
`claims` was written *without* extending the framework generic (the §8.1
shadowing trap, one level down) degraded **silently to output-only** — the
device attached, staked nothing and wrote nothing; `is_input = true` now makes
the absence loud. The `sides(b)` rejection is **answered rather than ignored**:
its ground was redundancy with methods that must exist anyway, and redundancy
*with a cross-check* is drift detection, which is what the bidirectional check
makes of it — annotated inline where §11.6 lists the rejection. Side-encoding
supertypes stay rejected (a bidirectional binding cannot subtype two sides),
and the empty-enumeration doctrine survives untouched: `is_input(b) = true` +
`claims(b) = ()` is the honest may-write-nothing degenerate, while the maximal
surface still requires the explicit `is_greedy` declaration.

Annotation (2026-10-02): "§8.3-hidden" in the Position reads "§8.5-hidden":
§8.5 states that a component's class is implementation detail behind its
contract.

Annotation (2026-10-02): "§8.1's reflection class" in the Rationale reads
"§8.1's shadowing check", the `isdefined`/`!==` test §8.1 holds; §8.1 names
no reflection class.

**Rejected.**
- *Presence-only probing, the prior design of record:* silent partial
  degradation of a shadowed bidirectional binding, and `hasmethod` is the rarer
  Julia interface idiom beside the AbstractArray/IndexStyle pattern of roots
  plus traits.
- *Optional, unenforced supertypes:* a signal half the ecosystem skips is worse
  than no signal at all — the dispatch gate is the whole value.
- *Side-encoding supertypes `AbstractInputBinding`/`AbstractOutputBinding`:*
  unchanged from the standing rejection — a bidirectional binding cannot
  subtype two sides.
- *Annotation (from §11.6's inline treatment, migrated at the P3.2 rewrite,
  2026-08-14):* under presence detection the degradation was not merely silent
  but actively misdirecting — every diagnostic available pointed away from the
  missing import.

### D-203 — The termination record carries typed sources and the tail residue

**Status.** ratified

**Position.** The run's termination record is a three-field value — the final
boundary time, absent when no boundary ever ran; a typed source; the tail
residue — and this amends D-201's disposal clause: the run's-end sweep folds
the residue into the record *and* presents it through the logging backend,
still never published. The bundled rulings:

- The sources follow the diagnostic kind convention — kind is identity,
  payload plain data (§13.2) — without joining [Appendix C][sC]'s diagnostic set:
  `EndTimeReached` (no payload), `ModelRequestedStop` (the holding face),
  `ControlRequestedStop` (its issuer), and `LoopError` (the propagated
  cause). The record covers `errored` exactly as it covers `stopped` (§13.6).
- The operator interrupt stays a tag on an ordinary stop (§13.5): the
  `:interrupt` issuer arm of `ControlRequestedStop`, never a fifth kind.
- The control-plane stop word carries its issuer — the requesting device,
  `:code`, or `:interrupt` — written by compare-and-swap from empty,
  first writer wins (§12.1).
- `DeviceJoinTimeout` becomes an ordinary structured kind: written to the
  loop's own cell in tail step (5), collected by the run's-end sweep
  (§12.4, [Appendix C][sC]).
- Source consultation order is normative: a pending control stop at frame
  top, then `t_end`, then the stop faces at each publication — the recorded
  source of a boundary where two hold is the first in that order.
- `init!` clears the record with the trajectory (§12.6).

**Spec.** §11.8, §12.1, §12.4, §12.6, §13.5, §13.6, [Appendix C][sC]

**Rationale.** D-201 disposed of the tail window's diagnostics through
presentation because the termination record did not yet exist as machinery;
with it on the bench, presentation-only fails the unattended run — §11.8's own
audience for the terminal counters. Once `run!` returns, "did a device hang
the join?" was answerable only by whoever captured the log stream, and a
harness exercising the abandonment path had to scrape logs. The record is
none of D-201's three rejected disposals, which all stand: it is not a
publication — it follows no boundary sequence and sits on no data plane — it
is not cell retention across runs (`init!` clears it with the trajectory), and
it is not a drop. It is stopped-sim state on the diagnostic-observation side
of §13.5's own doctrine, and the precedent of carrying failure detail was
already spent when the abnormal path put the cause exception in the record.
The typed sources apply §13.2's convention to the outcome channel, dissolving
a flat record whose `exception` field applied only to the error case and
whose `face` field only to the stop-face case; construction simplifies with
them, the loop returning a source where it detects one and the record
assembled once, in the outermost `finally`, after the sweep has the residue
in hand. Issuer attribution is nearly free: every stop site knows its
identity — the handle carries the device name, the interrupt is caught at a
known unmask point — and the anonymous `Bool` was discarding it at the moment
of writing; first-CAS-wins matches the first-`true` doctrine for stop faces
and names the request that actually initiated the tail. The residue stays
bounded by construction: one final ring take per writer, at most sixteen
entries plus suppressed counts. The record's cost is nil on any path that
matters — it is built once per run, on the cold side of the final snapshot.

Annotation (2026-10-02): §7.2 never stated the clock's seed, and no spec
sentence states it today, so the fourth rejection's citation has no referent.
The rejection's other grounds stand.

Annotation (2026-10-08): amended by D-316. Stop requests replace the stop
faces. `ModelRequestedStop` carries the requester's path, port and reason,
and the source order reads the requests at each publication where it read
the faces. Two requests at one boundary resolve to the first in roster order.

**Rejected.**
- *Superseded position — presentation-only disposal (D-201):* honest but
  ephemeral; the tail's facts evaporated from the program at the moment it
  regained control. D-201's rejected list never weighed the record, which
  had not been built when it was adjudicated.
- *A fifth source kind for the interrupt:* §13.5 rules the interrupt a tag on
  an ordinary stop — nothing failed; a consumer that cares matches on the
  issuer, and a distinct type would quietly reverse a settled ruling for no
  gain.
- *A flat record with `nothing`-padded per-source fields (the prototype's
  first cut):* the shape §13.2 rejects for diagnostics — most fields
  meaningless for most sources, tests matching on a `Symbol` instead of a
  type.
- *`Float64` time with `NaN` for "no boundary ever ran":* time is generic —
  the clock is seeded `zero(T)` (§7.2) — and `NaN` is an in-band sentinel of
  the species D-202 rejects; absence spelled out-of-band instead.
- *Carrying the configured `t_end` in `EndTimeReached`'s payload:* the
  effective policy already lives in the run metadata (§11.5, §13.5); a second
  home for a fact that has one.
- *Termination sources as [Appendix C][sC] diagnostics:* the record is outcome, not
  warning — three of the four sources are healthy ends, and the interrupt
  sentence in §13.5 already ruled the appendix gains nothing here.

### D-216 — Conform Appendix C to the prototype's diagnostic sites

**Status.** ratified

**Position.** The first increment to raise every refusal as a kind is Appendix
C's first test, and the table moves where the sites showed it wrong.

- `StopFaceInvalid` and `ClaimConflict` are collected — over the given faces,
  over the device's claim set — and `ArgumentInvalid` collects over a
  `TableBinding`'s entry table; they sit beside `DeploymentInvalid`, already
  collected.
- `AttachUnknownFace` and `ReadBindingUnresolved` name the device by type: a
  refusal that precedes admission cannot carry the roster id admission assigns.
- `ConditionResolution`'s payload lists what its sub-kinds differ by;
  `DeploymentInvalid`'s parameter list gains the run-shaping keywords
  (`join_timeout`, `log`, `log_every`, `log_max`, `t_end`);
  `BindingContractMismatch` gains the binding declaring neither side.
- `DeviceContractMismatch` joins the set: the device twin of
  `BindingContractMismatch` (no `loop` method; `gather` against a binding with
  no output side).
- Every other payload the prototype carries short of its column stays as
  written: the column is the design, and the prototype records its own gaps.
  A selector carried as its rendered spelling is licensed — §13.2's rule is
  against instances and model types, and a spelling is a string.

**Spec.** §11.3, §11.6, §13.2, [Appendix C][sC]

**Rationale.** The payload and policy columns were untested design claims
until a site had to construct each value. Three findings needed the table to
move rather than the code. A check that runs over a list — the stop faces
given, the faces a device claims, the entries of a table — is collecting by
its shape, and making it throw on the first would discard violations the pass
already holds, the cost §13.1 exists to avoid. An id assigned at admission
cannot be in a refusal that keeps the device out. A column narrower than the
sub-kinds it names cannot be the acceptance contract for tests that match on
those sub-kinds' payload. Everything else — the wires on an `AlgebraicCycle`,
the declaration on a `FaceNameCollision`, the shadowing notes, the binding site
of a stop face — is data the design wants and the prototype does not yet
gather; the column keeps naming it and the prototype's absence list carries the
shortfall until a later increment closes it.

**Rejected.**
- *Making the three service checks fail-fast to match the column:* throws
  away violations the pass already has, against §13.1's reasoning.
- *Reserving a roster id before admission:* an id for a device the roster
  never held, in every refusal's payload.
- *Shrinking every column the prototype falls short of:* the table would
  document the prototype rather than the design, and the shortfalls would
  stop being visible as such.
- *A datum naming no channel as a kind (`bindings.jl`'s third plain error):*
  it runs on the device task inside the author's mapping, so it reaches the
  framework as the wrapper's `cause` — `MalformedDatum` / `DeviceCrash`
  territory, not a kind of its own.

### D-217 — Conform the trace and replay sections to the prototype's record

**Status.** ratified

**Position.** The first increment to record a trace and replay it is §11.5
and §12.7's first test, and the sections move where the mechanism showed them
short.

- The trace carries its length beside the header and the batches: the number
  of drains since the capture. A recording whose last frames drained nothing
  still ran them, and replay's frame budget is that count.
- The header's schema list only grows. Every capture and every roster change
  appends the current writer set, earlier records keep their index, and a
  record resolves only through its own schema entry.
- `ReplayUnknownFace` carries the bare position where the writer's schema has
  no name for it.
- The entry pass validates each batch's frame ordinal against the recording's
  length, as a `ReplayHeaderMismatch` discriminator, and the replay drain keys
  records to the frame exactly.
- `ReplayHeaderMismatch` and `ReplaySchemaMismatch` are collected.
- The header records the `t_end`/`stop_on` pair bound at construction. A run's
  effective bound is reported by its termination record when it fires.

**Spec.** §11.5, §12.7, §13.5, [Appendix B][sB], [Appendix C][sC]

**Rationale.** Positional records are meaningless without a schema, and the
header outlives a run: `attach!` and `detach!` are legal at every stopped
point between `init!` and the next advance (§12.6), and a roster change
recompiles the harness writer against a new complement, so the same face
moves position. A schema list that only grows keeps every recorded index
valid without rewriting a record. The same positional shape is why an
unresolvable entry has no name to report. A frame ordinal the entry pass does
not check lets a hand-edited record apply at a frame not its own, silently,
and re-record as if it were; §12.7 promises exact ordinal keying, so the check
belongs with the other up-front ones. The two header kinds collect for D-216's
reason: a check that runs over a list is collecting by its shape. The
termination pair is the one place the sections contradicted each other. §11.5
captured "the effective pair" at `init!`, while §13.5 binds a `run!` override
for that run only, after `init!` and possibly several times per trace. The
header can only hold what `init!` knows, and the termination record already
names what fired: `EndTimeReached` carries the final `t`, `ModelRequestedStop`
the holding face. Replay neither compares nor applies the pair, so nothing
rides on it.

**Rejected.**
- *A mutable termination slot in the header, rewritten at every advance:* one
  slot holds one run's pair, and the header stops being a single-instant
  capture, which §11.5 relies on.
- *Moving the pair out of the header into the termination record:* the next
  run overwrites the record, so the pair would leave the one persistent
  artifact.
- *Rewriting recorded positions at a roster change:* the values are recorded
  and the positions are the index into a schema; a rewrite is a second record
  format.
- *A feed cursor that applies any record at or before the current frame:* it
  masks a stale ordinal by applying it late, and under a `to_boundary`
  truncation it would sweep every record past the cut into the last replayed
  frame.

### D-252 — Remove auto-publishing: two port classes, exposed state returned by stage 1

**Status.** ratified

**Position.** A declared output is produced by stage 1 or by stage 2, and by
nothing else. A component exposes a state or mode field by returning it from
`output_state`. A declared output that no stage produces is
`DeclaredNotProduced`, everywhere and at every tier. `ProducedByTwoStages`
carries the component path and the port name; the two stages are the kind's
own, so the producer column goes with the third class. Supersedes D-016's
publication rule, D-152's successor in D-154's sequence, and D-169.

**Spec.** §5.2, §5.3, §7.1, §8.3, §9.1,
§9.3, §10.6, §11.2, §13.2, [Appendix B][sB],
[Appendix C][sC], [Appendix D][sD]

**Rationale.** Auto-publishing was a third port class the framework wrote.
It cost more than the line it saved. Stage 1's hand-down had to exclude the
published names (D-169), the classifier probed by name and type and silently
un-published a name held at another type, the executor grew a
`PublishEntry` beside the stage entries, the published set threaded through
every stratum and into `compile`'s key slicing, and a `ConformanceFailure`
arm existed only to refuse a `Float64`-pinned declaration of a walking field
at the `Dual` activation. Each piece was correct and each was there for one
convenience: not writing `output_state(c, (; x)) = (; q = x.q)`. The
2026-09-18 probe over the suite found nine of seventy-eight fixture
components relying on publication, six of them written to test it. The
remaining refusal already exists: `DeclaredNotProduced` names the declared
port, the stage products and the store fields, and its remedy becomes
"return it from `output_state`". With one writer per port the port model is
homogeneous, the `Dataflow` artifact (D-253) classifies by return alone, and
the trace and status surfaces stop distinguishing a framework write from a
stage write.

**Rejected.**
- *Keeping publication as it stood:* the machinery above, for one line per
  exposed field.
- *Opt-in publication sugar (a declaration listing fields to expose):* a
  second way to write `output_state`'s return, with the same classification
  seam.
- *A dev-mode flag publishing every state field (§11.7's note):* still
  possible as a debugging aid, but it would be a reader over the stores, not
  a port class; it is recorded, not built.
- *Refusing only at the root:* an unproduced port inside an assembly is the
  same silent zero, one level down.

### D-255 — `Run`, the trace split and `StopPolicy`

**Status.** ratified

**Position.** A run is state with a type of its own, and its policy is a
value bound per advance.

- `Run{T}` is a mutable struct with four `const` fields, `t₀`, `mode`, `log`
  and `trace`, and two writable ones, `policy` and `termination`. `init!`
  and `replay!` construct one; the loop's tail writes `termination` once.
  `closed(run)` is `termination !== nothing`.
- `Run` is a `Simulation` field beside `control`, so `Simulation` is a
  mutable struct. A `Simulation{T}` is constructed with a placeholder run
  (`t₀ = zero(T)`, `mode = :live`, empty log and trace, no termination) that
  `init!` and `replay!` replace; `Control.lifecycle` says whether it
  started. `termination` leaves `Control`, which keeps the stop word, the
  lifecycle and the wait. `init!` allocates fresh objects rather than
  clearing.
- `Trace{T}` is a fixed header plus two append-only lists, `schemas` and
  `batches`, and its length, the drains since the capture. The header loses
  its schema list; `attach!` and `detach!` push onto the list in place. The
  drain advances the length on the live trace, and `trace(sim)` freezes it
  into the value it hands back; no reader of the run needs it, every reader
  of the length reads a trace. The register keeps its cursor fields and the
  replay feed.
- `StopPolicy` replaces `RunPolicy`: an immutable value of `t_end` plus the
  stop faces and their addresses, built and validated by each advance and
  rebound on `Run.policy`. `hit` leaves it for the loop's scratch beside the
  cursor. `ControlRequestedStop` is outside the policy: the policy is what
  the caller declares, the stop word is what anyone can issue.
- `t_end` and `stop_on` leave the constructor and are keywords of `run!` and
  `replay!`, with `Inf` and no faces as defaults, validated per call.
  `step!` states the same defaults itself. §13.5's second binding site goes.
  A run with `Inf` and no faces is allowed and raises `UnboundedRun` into
  the loop's diagnostic cell, the status record carrying it.
- The trace header holds the `Deployment` and `t₀`, no policy. Only the
  terminating advance's policy explains the stop, and the termination record
  holds that one.

Supersedes D-091, D-217's header-records-the-constructor-pair bullet, and
D-060's "policy at `Simulation` construction" clause; D-060's rule that
termination is state, never an exception, stands.

**Spec.** §11.5, §12.1, §12.4, §12.6, §12.7, §13.5, [Appendix C][sC]

**Rationale.** The run was spread across the `Simulation`'s fields and the
control plane. `termination` sat on `Control` beside the stop word, so the
outcome of a run and the surface anyone may poke shared a struct;
`RunPolicy` was mutable because `hit` was written into it by the loop, so a
declared policy and a loop scratch shared a struct; the trace header grew
its schema list in place, so an artifact captured at `init!` was not
immutable; and `t_end`/`stop_on` had two homes, the constructor and the
call, which §13.5 called "the honest cost" of D-091. Each of those is the
state/artifact criterion violated once. A `Run` collects what one run owns.
Its `const` fields are the ones the constructing entry point fixes; its
writable ones are the ones the loop advances. A `StopPolicy` is what the
caller declares for one advance, so it is a value the advance builds, and
the defaults belong to the calls that take it. With no constructor defaults
the second binding site disappears and the trace header has no policy to
record; the terminating record carries the policy that ended the run, which
is the only one a replay reader needs. The placeholder run at construction
is preferred to a `nothing` field because every accessor then has a run to
read, and `lifecycle` already says whether it is meaningful. An unbounded
run is allowed because it is the interactive session's ordinary shape, with
`UnboundedRun` as its advisory and the operator interrupt as its escape
(§13.5); the advisory lives in the loop's cell because `run!` mutates state.

**Rejected.**
- *Constructor defaults for `t_end` and `stop_on` (D-091):* two homes for
  one fact, with a precedence rule to reconcile them.
- *A mutable `RunPolicy` carrying `hit`:* the declared policy and the loop's
  scratch in one struct.
- *`Run` as an immutable value rebuilt per frame:* the log and trace are
  append-only state; copying them per frame is the allocation §9.8 forbids.
- *`termination` staying on `Control`:* the control plane is what anyone
  may poke; a run's outcome is not.
- *A `Union{Nothing,Run}` field:* every accessor branches on a state
  `lifecycle` already reports.
- *Refusing an unbounded run:* the interactive session's ordinary shape
  would need a sentinel `t_end`.

Annotation (2026-10-08): amended by D-316. `stop_on` is
`ignore_stop_requests`, with `()` as its default, and `StopPolicy` is
`t_end` plus the ignored requester paths. `UnboundedRun` fires when no
requester is honoured.

### D-268 — Pause verbs on the simulation, and the interrupt's remaining windows

**Status.** ratified

**Position.** The pause is spelled `pause!(sim)`, `resume!(sim)` and
`paused(sim)`, and the operator interrupt is settled at the four places
§12.4's masking left open.

- `pause!` and `resume!` are legal from any task in any lifecycle state; the
  loop consults the flag at frame top and inside its wait and pause blocks;
  `step!` blocks while paused. The tail clears the flag beside the sticky
  stopped status, and no run start clears it. The handle carries no pause.
- A deferred interrupt raised at the unmask point yields to a stop face the
  frame's publication found holding: the face is the recorded source, and
  the interrupt sets the stop word only where none held.
- An `InterruptException` inside a device's `init!` is the operator's stop,
  not that device's crash: the bracket runs `shutdown!`, sets the
  `:interrupt` stop, reports no `DeviceCrash` and spawns no task; the other
  entries still initialize and the run ends at its first frame top.
- The tail's bookkeeping after the joins runs under the mask; a raise
  deferred to its end propagates raw out of `run!`, the simulation already
  terminal.
- `run!` discriminates §13.4's two dispositions by the roster: empty is
  unattended and rethrows, non-empty logs the rendered error and returns
  with the lifecycle `errored`. `step!` always rethrows.
- (Amended 2026-09-30, with the three windows around `run!`'s interrupt
  arm.) `shutdown!` may run more than once. The arm releases the
  calling-task entry itself when its wrapper never recorded the release, and
  an interrupt landing between the wrapper's `shutdown!` and that record runs
  it again. The arm's own release can be cut the same way, so each such
  interrupt adds one call. §11.6's "close only what is open" makes a
  repeated call harmless, and a leaked device would not be.
- (Amended 2026-10-01, with the init bracket's escape.) `shutdown!` may run
  on a device whose `init!` never began. The bracket lists each entry for
  release before its `init!`, so an interrupt that escapes the bracket finds
  every device that began initializing and that the bracket has not itself
  released. One landing between the listing and
  the `init!` releases a device that opened nothing. §11.6's "close only
  what is open" makes that call harmless, and listing after `init!` would
  leak the device whose `init!` had just returned.
- (Amended 2026-10-01, with the lost loop failure.) An interrupt after a
  frame's throw never displaces it. `run!`, `replay!` and `step!` store the
  loop's throw before anything can cut its handling, and the masked
  bookkeeping builds the `LoopError` from the store, so the run ends
  `errored`. An interrupt that cuts the handling itself propagates raw,
  §13.4's disposition skipped and the record written.

**Spec.** §11.6, §12.1, §12.4, §13.4, [Appendix B][sB]

**Rationale.** §12.1 named the pause as a control-plane field and §12.4 built
the interrupt on masking, but neither spelled the verbs, and the code built
the stop word and the two defensive discriminations of D-132 without the
pause or the mask. Building them raised four questions the text did not
answer, each small and each a trap if answered by default.

The verbs follow the stop's grammar, `stop!(sim)` beside `stop!(handle)`,
and the reader follows `running` and `closed`, bare predicates the API
already spells. The pause stays off the handle because §11.6 lists the
handle's control access as observe-running and request-stop, and the one
device that presses pause is the GUI, whose authoring surface §11.7 defers.

Clearing the flag in the tail rather than at a run's start is the one
disposition that both removes the trap and keeps a `pause!` before `run!`
meaningful. A run that stopped while paused, under the alternative, would
hand the next run a first frame top it never leaves.

The face-before-interrupt order is §13.5's consultation order applied to the
raise's actual position: the deferred raise lands after the frame's
publication, where the stop faces are read, and before the next frame top,
where the stop word is. Recording the face keeps the order one rule.

The init bracket's arm mirrors the wrapper's (D-132). Without it a Ctrl-C
during a slow `init!` would land the run `errored`, since the bracket sits
outside the frame loop's catch and its throw would reach `run!`'s outer
catch as a loop failure. The masked bookkeeping closes the last window: a
raise inside the outermost `finally` would leave the lifecycle `running`
with no run behind it, and every service refuses that state.

The roster is the discriminator because §12.6 defines the unattended run as
the deviceless one and §13.4's rethrow presupposes it. The discrimination
sits in `run!` alone since `step!` is deviceless by construction. A probe
under `Base.exit_on_sigint(false)` with `kill(getpid(), SIGINT)` confirmed
the mechanism the entries rely on: a signal inside `disable_sigint` is held
through a `sleep` and raises at the unmask, and one inside a `wait` on a
`Threads.Condition` raises in the wait with the lock released.

Annotation (2026-09-26): a frame that throws while an interrupt is pending
ends `errored` under its own `StepError`, the cause wrapped under the mask
and the pending interrupt consumed at the catch on its way out (§12.4, §13.4). Building the mask
showed that both naive shapes, the mask begun outside the frame's `try` and
the unmask in a `finally`, lose the frame's error to the deferred raise and
would end the run `stopped` over a half-written boundary.

Annotation (2026-09-26): two rulings the cold review raised. Julia's forced
throw after repeated SIGINTs reaches §13.4's defensive arm inside the mask,
so the arm is reachable; its disposition is `stopped` with the frame
abandoned, the published record consistent and the stores possibly
mid-boundary until the next `init!`, on boundary zero's precedent (§12.4).
And `replay!` discriminates the two dispositions by the roster as `run!`
does: the reasoning against `isinteractive()` applies unchanged, and the
deviceless reproduction still rethrows (§13.4).

Annotation (2026-10-02): amended by D-269. The loop reads the control
plane, the pause flag included, at frame top alone; the pause block is the one
wait woken at once.

**Rejected.**
- *`pause!(sim, flag::Bool)` as one verb:* two verbs read at the call site
  and match `stop!`; a Boolean argument spells the un-pause as a negation.
- *A pause on the handle now:* §11.6's handle contract does not carry it,
  and the only issuer is the deferred GUI; adding it later costs one method.
- *Clearing the pause at a run's start, as the stop word is:* removes the
  start-paused spelling without removing anything the tail's clearing does
  not.
- *`step!` ignoring the pause:* a second consultation rule for one frame
  loop, and §12.6's bit-identity claim rests on the loop being one code.
- *Recording the interrupt over a holding face:* contradicts §13.5's order,
  under which the face was consulted first.
- *Reporting an interrupt inside `init!` as `DeviceCrash`:* D-132's grounds;
  and with `should_abort` clear the run would start with the device dead and
  the operator's stop lost.
- *Leaving the tail's bookkeeping unmasked:* a lifecycle stuck at `running`
  with every service refusing is a bricked session, the outcome D-132 exists
  to prevent.
- *Swallowing a raise deferred past the bookkeeping:* the operator asked,
  and the simulation being terminal costs the raise nothing.
- *`isinteractive()` as the discriminator:* a deviceless run in the REPL
  would then hide its failure behind a log line, and a rostered device in a
  script would rethrow past the tail the devices already took; the roster
  states what the glossary defines.
- *Retrying the failure's handling so that an interrupt cutting it is
  swallowed (2026-10-01):* the run is already `errored` with the cause on its
  record, so the raw raise costs the log line or the rethrow alone, and a
  retrying `try` there is machinery for that alone.

### D-274 — Checkpoints: the executor's state as one value, restored without boundary zero

**Status.** ratified

**Position.** A `Checkpoint{T}` is the executor's state at a frame top,
taken by `checkpoint(sim)` and by `init!`, and put back by `restore!`. It
is the trace's header, and replay is a restore followed by the feed.

- A checkpoint holds the flat buffer `x`, the `s` and `m` stores, the whole
  signal table, the guard priors, the one event register that crosses a
  boundary, the clock in full (`t`, the frame index, the boundary ordinal,
  `t₀`), and the fingerprint, the deployment and the structural layout the
  trace header carries today. The derivative buffer, the arrival pair, the
  localization samples, which every frame rewrites before reading, the
  cursor and the periphery stay out. The stepper seam gets a checkpoint
  hook, empty for a single-step method.
- `checkpoint(sim)` is a stopped-sim service (§13.7): legal in
  `initialized` and `stopped`, refused while running, and refused when the
  executor sits mid-frame after a `t*` stop, the clock being past the frame
  top with the remainder abandoned.
- `restore!(sim, cp)` is a door beside `init!` and `replay!`: it checks the
  fingerprint as replay checks the header, copies the state back, opens a
  fresh run, publishes one snapshot, and runs no boundary zero. No sweep, no
  guard evaluation, no update, no prior reset. The next frame is the
  original lattice's next frame, since the clock came with the checkpoint;
  the boundary ordinal continues, being the trajectory's (§12.3, D-230).
- The trace header is the checkpoint `init!` takes at the end of boundary
  zero, after the first publication. `TraceHeader` retires into it; the
  header's resolved stores and root inputs are values still (D-038), the
  checkpoint's. Replay restores it and feeds the batches from frame 1, so
  D-101's two substitutions become one, and `init!` is the only door that
  runs boundary zero.
- The parametric what-if of §12.7 is spelled as `init!` of the modified
  model under the authored condition, followed by the trace's batches with
  its header set aside. The trace is no longer self-sufficient for it: the
  authored condition comes from outside. The edited-inputs what-if of
  §11.5 is unchanged.
- `linearize`'s default operating point is the checkpoint of the
  simulation as it stands (D-272), restored into the scratch world; the
  frozen tier's cells are the checkpoint's held cells, which is what D-213's
  establishment round approximated. `about = <condition>` stays for an
  authored point.
- A restore into a simulation of another activation is refused by
  dispatch, as a reader or a trace is.
- A throw inside boundary zero leaves no trace and no checkpoint, the
  simulation returning to `built` (D-223). The run `init!` opened
  stays behind, empty. Its reproduction is `init!` under the same
  condition. Frame one shares pointer 0, and the `StepError`'s `host` tells
  the two apart. The general recipe, restore to the pointer then `step!`,
  holds from pointer 0 for a frame's failure. (Amended 2026-09-30: the
  bullet started the general recipe at pointer 1, from the time one
  rendered text served both failures at pointer 0. The halt at pointer 0
  restores the header and runs no boundary zero, so frame one's record is
  still ahead of it and `step!` re-executes that frame.)

**Spec.** §10.2, §10.6, §11.5, §12.6, §12.7, §13.7, §14.8, §14.10, [Appendix B][sB]

**Rationale.** Once the state past the initial instant is a value of its
own, restoring it is a copy, and nothing can be one tick ahead: the held
cells, the priors and the clock are simply there. The identity of a
resume holds on any model by construction, multi-rate included, and no
component owes anything at a restore. Unifying the trace header with the
checkpoint follows from the shape: the header already held the stores, the
root inputs, the deployment and the layout, five of the checkpoint's
fields, and lacked only what boundary zero would derive. Taking it after
boundary zero instead of before hands replay a state to copy rather than a
condition to establish. The price is the parametric what-if's start: a
post-sequence header carries the recording model's held cells and priors
until each component's next tick and the next boundary, where the
pre-sequence header re-derived them under the modified model. Spelling
that what-if around `init!` under the authored condition is the more honest
form, §12.7 promising determinism and never reproduction, and it costs the
user the condition they authored anyway. §14.5's line that boundary zero's
firings are recomputed and never recorded loses its force without harm: the
checkpoint records the post-firing state faithfully and suppresses nothing,
which is all D-026's rule against masking insurance asks. The checkpoint is
also the on-disk unit the persistence deferral of §11.5 waited for, and a
long run becomes seekable, a checkpoint at boundary `k` plus the batches
from frame `k+1`.

Annotation (2026-10-09): amended by D-319. The state the first bullet lists
is now a `ModelState`, the clock's `t` and `t₀` among its fields, and the
frame index and the boundary ordinal are the run's counters, which a
`Checkpoint` carries beside it. A `Checkpoint` is nominal by type, so the
refusal by dispatch of a state from another activation sits on the two
`restore!` methods that take a bare state.

**Rejected.**
- *Two header kinds, the pre-sequence resolved condition for an authored
  opening and the checkpoint for a restored one:* one fingerprint, but a
  union type, two replay dispositions and two openings to keep in step,
  bought only for the parametric what-if's exactness at `t₀`.
- *A checkpoint that can be overridden like a condition:* the danger lives
  in the discrete tier, where a store and its held output move together;
  a narrow override of `x` and the root inputs is safe and is the one
  extension a mid-run trim would need, deferred until wanted.
- *A partial first frame after a `t*` checkpoint:* the loop integrates
  whole frames; refusing the mid-frame checkpoint keeps the lattice, and the
  extension waits for a use.

