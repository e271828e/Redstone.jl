### 11.3 Inbound: root inputs, claims and the frozen roster

**The [write surface](#g-write-surface) (the set of faces a writer's batch
entries may reach) is [root inputs](#g-root-input).** A root input *is* the
root [component](#g-component)'s own input [face](#g-face), an assembly's
`input_wires` key or a primitive's `u_types` key ([§8.2][s8-2],
[§8.6][s8-6]). It is routed inward to consumers and produced by no component.
At every non-root level an input face is fed by the parent's wire, and at the
root there is no parent. No dedicated vocabulary is needed.

A root input is usefully read as the output face of the one producer the
build never sees: the [periphery](#g-periphery) and the services. On that
reading, root-input exclusivity (below) is that producer's one-writer right,
and the totality ([§14.6][s14-6]) is its completeness obligation.

Root inputs are sources to the build-time ordering, constants within a
frame, and the *only* thing the periphery may write. The GUI reaches them
through the resolution ([§11.7][s11-7]), and control commands are not writes
([§12.1][s12-1]). [Devices](#g-device), mappings, the [trace](#g-trace) and
the GUI write path address root inputs by **face name** ([§8.6][s8-6]).
Structural slash paths never cross the periphery's *write* boundary. The
write side speaks the root [contract](#g-contract)'s names only. The read
side chooses per binding. It uses slash paths in inspection reads, and face
names in integration reads and in service reads
([§11.2][s11-2]/[§13.5][s13-5]/[§14.4][s14-4]).

**Root-input exclusivity: one writer per root input at any time.** A device [claims](#g-claim) its root inputs at attach, and
claiming an already-claimed root input is an attach-time error. Detaching
releases the claims. A released root input's GUI widgets are live again from
the next run ([§11.7][s11-7]). Exclusivity replaces any cross-device conflict
*policy*, such as attachment-order precedence at [drain](#g-drain)
([D-044][d-044]). Per-device [cells](#g-staging-cell), the CAS merge and the
atomicswap drain all stay. They serve atomicity and
[coalescing](#g-coalescing), not arbitration.

**Why.** A second live writer on one root input makes the applied value a
timing artifact, as the worked example in [§11.4][s11-4] shows. The usual
pair is a stream and its mirror, a joystick axis and the GUI slider showing
it. Claiming the stream settles that pair with no concurrent writing.

**A claim is what a device *may* write, not what it will.** Data-dependent
write-sets are ordinary. A UDP/JSON peer writes whichever subset of faces the
incoming message names, and `map_input` is arbitrary user code the framework
never inspects. Such a device therefore claims the **binding's enumerated
allowed set**, the faces the binding table lists, whether or not any given
batch touches them. The claim is registered at attach exactly as a joystick's
is. A broad claim costs liveness. Every enumerated face is claimed for the
device's whole attachment, so the derived-liveness rule ([§11.7][s11-7])
renders the device's GUI widget read-only even on faces the peer never
writes. Narrow the binding to narrow the claim. The enumeration *is* the
interface.

**Every writer has a write surface, and the periphery enforces it.** A batch
entry reaches a root input **iff the named face is inside the writer's
surface**. Anything else is discarded with a runtime warning
([§13.2][s13-2]). Because surfaces are static per run (the
[roster](#g-roster) freeze, below), enforcement runs entirely at *staging*,
the earliest site, on the writer's own task. The drain performs no checks at
all. **Every device's surface is its claim set**, and a claim set has two
*sources*:

- **Returned.** The binding enumerates the faces. It declares
  `is_input(b) = true`, `claims(b)` ([§11.6][s11-6]) is called once at
  attach, and what it names is staked. Such a claim is static for the
  attachment and exclusively its own, since claims are disjoint by
  construction. It is binding-bounded even where no one else is involved. A
  mapping that has drifted onto an unenumerated face is a diagnosable anomaly
  (`OutOfClaimEntry`), never a silent write, claimed or not.
- **Computed.** The binding declares `is_greedy(b) = true` ([§11.6][s11-6])
  and the framework computes the claim at attach: all root-input faces minus
  the union of the rostered claims, the unclaimed complement at that instant.
  This is the shipped GUI's claim ([§11.7][s11-7]), everything unclaimed,
  without configuration. It is disjoint from every incumbent claim by
  construction, so exclusivity validates trivially and nothing downstream can
  tell the two sources apart. A complement that comes out empty is legal and
  useless, and `attach!` records `EmptyGreedyClaim` in the roster entry's
  [diagnostic cell](#g-diagnostic-cell) ([§11.6][s11-6], [§11.8][s11-8],
  [D-250][d-250]).

**The periphery resolves root faces against the activation's cell layout
alone** ([D-261][d-261]). The layout carries the root faces in structure
order with their probe values, beside the address table, so both of the
build's lookup families, [schema and layout](#g-schema-vs-layout), read it
there, and writers, claims and the harness compile against it. The services
take their schema from the `Build` itself ([§14.3][s14-3]); the periphery
never needs an authored fact the layout does not hold.

One claim mechanism, two claim sources. The source is exhausted at the attach
point. Past it, validation, roster-entry storage, shape compilation
([§11.4][s11-4]), the drain, the trace and detach-releases-claims treat a
computed claim exactly as a returned one. The GUI is therefore not an
exception but an ordinary enumerated writer whose enumeration the framework
performed. Attaching the greedy claimant last is the idiom. Its computed
claim is taken at the attach point and never recomputed, so attachment order
is decisive by design. Opportunistic writing by autonomous devices does
not exist. A device that wants a face enumerates it, and greediness is an
explicit declaration, never a default. Cross-writer races on one root input
therefore cannot arise structurally, because every claim is exclusive,
whatever its source. That is what keeps drain order a diagnostic fact (below)
and lets a drained GUI value simply stay ([§11.7][s11-7]).

**One framework-owned remainder: the
[harness writer](#g-harness-writer).** Beside the roster sits a
**task-free entry point**, `stage!(sim, "face" => value, …)`, the harness/REPL
write path ([§12.6][s12-6]). It stages a batch from the
[calling task](#g-calling-task) itself (the task that invoked `run!`). Its
always-present cell is drained, traced and surface-checked exactly as any
device's. The harness writer's surface is the one thing in the design that is
*derived* rather than claimed. It is the unclaimed complement, the faces no
rostered device speaks for. That surface is recomputed at every stopped-sim
roster change, and is therefore as fixed within a run as any claim set. A
`stage!` write to a claimed face is rejected at staging
(`ClaimedFaceEntry`, naming the incumbent). A rostered greedy claimant
empties that surface outright. The greedy claim is itself a rostered claim,
so the complement it leaves is empty and every `stage!` in such a session is
rejected that way ([D-192][d-192]). There is one seam, a batch staged while
stopped whose face a subsequent `attach!` claims, and the attach itself
renormalizes it away (below). The [harness cell](#g-harness-cell) (the
always-present staging cell of the harness writer) drains **last**, by
convention. With every surface disjoint the order is unobservable, so the
rule exists to make the trace read the same way every time, not to arbitrate
anything.

**Root-input initial values are owned by the init/trim services.** Input
declarations are bare types ([§8.2][s8-2]) and carry no defaults, yet a root
input unfed by any device must hold a defined value from the first frame. No
declaration constant could own that value, because the trim service writes
root-input values it *solved for*, such as throttle and elevator. Export-entry defaults were rejected ([D-047][d-047]).
`init!` establishes every root input, and the
[trace header](#g-trace-header) captures the result. Totality is enforced
pre-write at every complete-world application: `init!`, trim setup, trim
commit ([§14.6][s14-6]).

**The roster is frozen per run: attach and detach are stopped-sim
operations.** `attach!`/`detach!` are legal in the `built`, `initialized`
and `stopped` states ([§12.6][s12-6]) and an error while `running`. That
error is `ServiceLifecycle` ([Appendix C][sC]), the same kind that gates the
[§14][s14] services. The list is exhaustive. An `errored` simulation refuses
both with the same kind. A roster change configures the next run, and an
errored simulation has none ([§13.6][s13-6], [D-232][d-232]). The prohibition
includes pause. Pause is a control-plane state *inside* a run
([§12.1][s12-1]), and a surface that could move while paused would move
mid-run. The roster (entries, claims, attachment order) is therefore a plain
immutable value the loop reads once at `run!`. The partition of the root face
set into per-writer surfaces plus the harness remainder is a static,
inspectable fact of the run. It is printable before the run starts and valid
until it ends (printable like the face routes, [§13.7][s13-7]). No republication
machinery exists. There is no atomic roster reference, no per-frame
acquire-load, no next-frame attachment granularity and no sequence numbers.
Attachment order is the roster's own order. The trace still tags entries
with a stable device id, never a roster index, because ids read across runs,
where the roster does change. Attach validation, claim registration and the
staging-shape compilation (below) all run at the attach point, which makes
`attach!`/`detach!` stopped-sim configuration operations beside `init!` and
trim ([§14][s14]). While a simulation runs, its configuration (build, roster,
claims, surfaces) is immutable. The doctrine ([§12.5][s12-5]) extends to its
final form. The running periphery stages writes and issues control commands,
*and nothing else changes*.

**Device identity, ids and roster admission.** Identity is the device
instance. The same object (`===`) may occupy at most one roster entry. Two
instances of the same type, two joysticks say, are two devices. The stable
device id the trace, heartbeat and diagnostics speak is assigned at
`attach!`, monotonic per `Simulation` and never reused. It lives exactly as
long as the entry: across runs (roster persistence, [§12.6][s12-6]), until
`detach!`.

Admission is a two-part check at the attach point, in order:

```
# each line: the condition that rejects the attach → the diagnostic it raises
identity   this instance is already rostered
               → AlreadyAttached      (names the entry and its binding)
claims     face exclusivity: this device's claim set meets a rostered claim
               → ClaimConflict        (names two distinct devices)
```

An already-rostered instance is rejected rather than silently absorbed,
because rebinding has an explicit spelling: `detach!` then `attach!`, both
legal at any stopped-sim point. Either a silent no-op or a silent rebind
would discard a binding the caller handed over. Running the claims check
after the identity check is what makes `ClaimConflict` always
name two *distinct* devices, never a device colliding with its own earlier
attachment.

**Device death does not detach.** A mid-run crash, voluntary exit or unplug
([§11.6][s11-6], [§12.4][s12-4]) ends the device's *task*. The cell stops
filling, the [§12.2][s12-2] heartbeat shows the death by name, and the roster
entry, claims included, persists to the end of the run. The
[orphaned claims](#g-orphaned-claims) are the accepted cost of
[the freeze](#g-the-freeze). The device's root inputs hold their
last-drained values and no other writer inherits them. The read-only widgets
([§11.7][s11-7]) render the orphan visibly ("claimed by `T16000M` — task
dead"), never mysteriously. Recovery is between runs: stop, `detach!`, and
either `init!` (fresh trajectory) or `replay!`-to-end then `run!`
(continuation from the interrupted boundary, [§12.7][s12-7]). The death is an
anomaly, not a surface event.

One deliberate asymmetry is on record as a
**[guarded addition](#g-guarded-addition)** (a capability the design admits
but does not build). A pure reader claims nothing. Examples are a binding
declaring `is_output` alone ([§11.6][s11-6]), a visualizer or a telemetry
tap. Attaching one mid-run would therefore move no writer's surface. A
dynamic reader list would touch only [§12.3][s12-3] wakeups, the heartbeat
and the shutdown join, never the drain, and it is cleanly severable from the
freeze should the join-a-running-session workflow find a customer. The
[§12.2][s12-2] thread-budget warning runs once per run, at either door,
against the frozen population.

