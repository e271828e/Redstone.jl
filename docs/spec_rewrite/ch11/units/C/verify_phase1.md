# Unit C verify, phase 1 (blind read of new.md)

Context paragraph (L3-10)
- V1 The periphery writes into a running model through its root inputs alone. (glossary link)
- V2 Each root input has one writer at any time.
- V3 The assignment of root inputs to writers is fixed for a whole run, because the roster is frozen per run.
- V4 Section parts listed in order (pointer, not a claim).

The write surface (L12-43)
- V5 The write surface is the set of faces a writer's batch entries may reach; its members are root inputs (inputs no component produces).
- V6 A root input is the root component's own input face, an assembly's `input_wires` key or a primitive's `u_types` key. [§8.2, §8.6, D-208]
- V7 A component is the unit of modeling; a face is the name a port wears on its component's boundary (gloss).
- V8 A root input is routed inward to consumers and produced by no component.
- V9 At every non-root level an input face is fed by the parent's wire; at root there is no parent. No dedicated vocabulary is needed.
- V10 A root input is usefully read as the output face of the one producer the build never sees (periphery and services).
- V11 On that reading, exclusivity is that producer's one-writer right, totality [§14.6] its completeness obligation.
- V12 Root inputs are sources to build-time ordering and constants within a frame.
- V13 Root inputs are the only thing the periphery may write. [D-031]
- V14 The GUI reaches them through the resolution. [§11.7]
- V15 Control commands are not writes. [§12.1]
- V16 Four parties address root inputs by face name: devices, mappings, the trace, the GUI write path. [§8.6]
- V17 The trace is the primary record of a session (gloss).
- V18 Structural slash paths never reach the periphery's writes.
- V19 The write side speaks the names of the root's contract and no others. [D-129]
- V20 The read side chooses per binding: slash paths in inspection reads; face names in integration and service reads. [§11.2/§13.5/§14.4]
- V21 A binding is the value passed at `attach!` that makes a device framework-legible (gloss).

Exclusivity and claims (L45-78)
- V22 BOLD: Root-input exclusivity allows one writer per root input at any time. [D-044]
- V23 A device claims its root inputs at attach.
- V24 Claiming an already-claimed root input is an attach-time error.
- V25 Detaching releases the claims.
- V26 A released root input's GUI widgets are live again from the next run. [§11.7]
- V27 Exclusivity replaces any cross-device conflict policy, e.g. attachment-order precedence at the drain. [D-044]
- V28 The drain is the frame-top swap that applies staged device writes (gloss).
- V29 Per-device staging cells, the CAS merge and the atomicswap drain all stay; they serve atomicity and coalescing, not arbitration.
- V30 Coalescing = CAS merge keeping one pending batch per device (gloss).
- V31 Exclusivity holds because a second live writer makes the applied value a timing artifact; worked example in §11.4.
- V32 The usual pair is a stream and its mirror (joystick axis, GUI slider). Claiming the stream settles it with no concurrent writing.
- V33 A claim is what a device may write, not what it will. Data-dependent write-sets are ordinary.
- V34 A UDP/JSON peer writes whichever subset the message names; `map_input` is arbitrary user code the framework never inspects.
- V35 Such a device therefore claims the binding's enumerated allowed set, whether or not a given batch touches them; registered at attach like a joystick's.
- V36 A broad claim costs liveness: every enumerated face is claimed for the whole attachment, so derived liveness (baked once at run start, §11.7) renders widgets read-only even on faces the peer never writes.
- V37 Narrow the binding to narrow the claim. The enumeration is the interface.

Write surfaces and claim sources (L80-126)
- V38 Every writer has a write surface and the periphery enforces it.
- V39 BOLD: A batch entry reaches a root input iff the face is inside the writer's surface. [D-044]
- V40 Anything else is discarded with a runtime warning. [§13.2]
- V41 Because surfaces are static per run under the freeze (attach/detach only while stopped), enforcement runs entirely at staging on the writer's own task.
- V42 The drain performs no checks at all.
- V43 BOLD: Every device's surface is its claim set, and a claim set has two sources. [D-174]
- V44 Returned claim: binding declares `is_input(b) = true`; `claims(b)` [§11.6] called once at attach; named faces staked.
- V45 Returned claim is static for the attachment and exclusively its own (attach check keeps claims disjoint).
- V46 It is binding-bounded even where no one else is involved; a drifted mapping onto an unenumerated face is a diagnosable anomaly (`OutOfClaimEntry`), never a silent write, claimed or not.
- V47 An enumeration naming a face outside the root's input faces is refused at attach (`AttachUnknownFace`). [D-216]
- V48 Computed claim: computed at attach when binding declares `is_greedy(b) = true` [§11.6]; all root-input faces minus union of rostered claims, at that instant.
- V49 This is the standard GUI binding's claim [§11.6], without configuration.
- V50 Disjoint by construction; exclusivity validates trivially; nothing downstream can tell sources apart.
- V51 An empty complement is legal and useless; `attach!` records an `EmptyGreedyClaim` warning. [§11.6]
- V52 One claim mechanism, two sources; source exhausted at the attach point.
- V53 Past attach: validation, roster storage, shape compilation [§11.4], drain, trace, detach-release treat computed same as returned. [D-174]
- V54 The GUI is therefore an ordinary enumerated writer whose enumeration the framework performed.
- V55 Attaching the greedy claimant last is the idiom. [D-192]
- V56 Its computed claim is taken at attach and never recomputed, so attachment order is decisive by design.
- V57 Opportunistic writing by autonomous devices does not exist. [D-044]
- V58 A device that wants a face enumerates it; greediness is explicit, never default.
- V59 Cross-writer races therefore cannot arise structurally, because every claim is exclusive.
- V60 That keeps drain order a diagnostic fact and lets a drained GUI value simply stay. [§11.7]

Harness writer and layout (L128-166)
- V61 One framework-owned remainder sits beside the roster, the harness writer (surface derived, not claimed).
- V62 It is a task-free entry point, the harness/REPL write path [§12.6, D-096], `stage!(sim, "face" => value, …)`.
- V63 It stages a batch from any task, the calling task included. [D-200]
- V64 Its always-present harness cell is drained, traced and surface-checked exactly as any device's.
- V65 The harness writer's surface is the one thing in the design that is derived rather than claimed. [D-174]
- V66 It is the unclaimed complement.
- V67 Recomputed at every stopped-sim roster change; fixed within a run.
- V68 A `stage!` write to a claimed face is rejected at staging (`ClaimedFaceEntry`, naming the incumbent). [D-044]
- V69 A rostered greedy claimant empties that surface; every `stage!` in such a session is rejected that way. [D-192]
- V70 Edge case: batch staged while stopped whose face a later `attach!` claims; the attach renormalizes it away. [§11.4]
- V71 BOLD: The harness cell drains last, by convention. [D-174]
- V72 With every surface disjoint the order is unobservable; the rule exists for trace consistency, not arbitration.
- V73 BOLD: The periphery resolves root faces against the activation's cell layout alone. [D-261]
- V74 The layout carries root faces in structure order with probe values, beside the address table; both lookup families read it there; writers, claims, harness compile against it.
- V75 The services take their schema from the `Build` itself. [§14.3]
- V76 The periphery never needs an authored fact the layout does not hold.

Root-input initial values (L168-179)
- V77 BOLD: The init/trim services own root-input initial values. [D-047]
- V78 Input declarations are bare types [§8.2], carry no defaults; an unfed root input must hold a defined value from the first frame.
- V79 No declaration constant could own it, because trim writes values it solved for (throttle, elevator).
- V80 Export-entry defaults were rejected. [D-047]
- V81 `init!` establishes every root input; the trace header (fixed preamble, a checkpoint `init!` takes) captures it.
- V82 Totality is enforced pre-write at every complete-world application: `init!`, trim setup, trim commit. [§14.6, D-149]

Frozen roster (L181-211)
- V83 BOLD: The roster is frozen per run. [D-106]
- V84 Attach/detach are stopped-sim operations; legal in `built`, `initialized`, `stopped` [§12.6]; error while `running`.
- V85 That error is `ServiceLifecycle` [Appendix C, D-108], same kind that gates §14 services.
- V86 The list is exhaustive; an `errored` simulation refuses both with the same kind; roster change configures the next run and an errored sim has none. [§13.6, D-232]
- V87 The prohibition includes pause; pause is a control-plane state inside a run [§12.1]; a surface movable while paused would move mid-run.
- V88 The roster (entries, claims, order) is a plain immutable value; loop reads it once at `run!`; nothing republishes it. [D-087]
- V89 The partition into per-writer surfaces plus harness remainder is a static, inspectable fact of the run [D-106]; printable before run, valid until end (like face routes, §13.7).
- V90 Attachment order is the roster's own order.
- V91 Trace tags each record with a stable device id, never a roster index, because ids read across runs where the roster changes. [D-087]
- V92 Attach validation, claim registration, staging-shape compilation [§11.4] run at attach point.
- V93 That makes attach!/detach! stopped-sim configuration ops beside init! and trim [§14].
- V94 While a sim runs, its configuration (build, roster, claims, surfaces) is immutable.
- V95 The mid-run mutation doctrine [§12.5] extends to its final form: running periphery stages writes and issues control commands, and nothing else changes. [D-031]

Device identity and admission (L213-239)
- V96 Identity is the device instance; same object (`===`) at most one roster entry.
- V97 Two instances of the same type are two devices.
- V98 Stable device id (trace, heartbeat, diagnostics) assigned at `attach!`, monotonic per `Simulation`, never reused.
- V99 It lives exactly as long as its roster entry, across runs (roster persistence, §12.6), until `detach!`.
- V100 Admission is a two-part check at attach, in order: identity → `AlreadyAttached` (names entry and binding); claims → `ClaimConflict` (names two distinct devices).
- V101 Already-rostered instance rejected rather than absorbed, because rebinding is spelled `detach!` then `attach!`, legal at any stopped-sim point.
- V102 A silent no-op or silent rebind would discard a binding the caller handed over.
- V103 Running claims after identity makes `ClaimConflict` always name two distinct devices.
- V104 Detaching a device the roster does not hold is an error (`NotAttached`). [D-215]

Device death (L241-254)
- V105 BOLD: Device death does not detach. [D-106]
- V106 Crash, voluntary exit, unplug [§11.6, §12.4] end the device's task.
- V107 Staging cell stops filling; §12.2 heartbeat shows death by name; roster entry and claims persist to end of run.
- V108 Orphaned claims are the accepted cost of the freeze.
- V109 Root inputs hold last-drained values; no other writer inherits them.
- V110 Read-only widgets render the orphan visibly, never mysteriously. [§11.7]
- V111 Recovery is between runs: stop, `detach!`, and either `init!` or `replay!`-to-end then `run!`, which continues from the interrupted boundary. [§12.7]
- V112 The death is an anomaly, not a surface event.

Mid-run readers (L256-267)
- V113 One deliberate asymmetry is on record as a guarded addition (admitted, not built).
- V114 A pure reader claims nothing: `is_output`-only binding [§11.6], visualizer, telemetry tap.
- V115 Attaching one mid-run would move no writer's surface. [D-106]
- V116 A dynamic reader list touches only §12.3 wakeups, heartbeat, shutdown join, never the drain.
- V117 The addition is cleanly severable from the freeze should the workflow find a customer.
- V118 The §12.2 thread-budget warning runs once per run at `run!` or `replay!` against the frozen population.
