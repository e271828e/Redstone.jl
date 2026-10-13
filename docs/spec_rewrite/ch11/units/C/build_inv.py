"""Scratch: build inventory.json for unit C. Run from docs/spec_rewrite."""
import json, re, sys
sys.path.insert(0, "checks")
from norm import norm, units

O = norm(open("ch11/units/C/old.md").read())
NEWRAW = open("ch11/units/C/new.md").read()
N = norm(NEWRAW); NU = units(NEWRAW)
CITE = re.compile(r'§\d+(?:\.\d+)?|D-\d{3}|Appendix [A-D]')
G2 = "units/G2/old.md"; H = "units/H/old.md"

# (old, new, tag, extra)  extra: dict with ruling / where
C = [
 ("### 11.3 Inbound: root inputs, claims and the frozen roster", "### 11.3 Inbound: root inputs, claims and the frozen roster", "X", {}),
 ("The write surface (the set of faces a writer's batch entries may reach) is root inputs.", "The write surface is the set of faces a writer's batch entries may reach. Its members are root inputs", "F", {}),
 ("A root input is the root component's own input face, an assembly's `input_wires` key or a primitive's `u_types` key (§8.2, §8.6).", "A root input is the root component's own input face, an assembly's `input_wires` key or a primitive's `u_types` key (§8.2, §8.6, D-208).", "C", {}),
 ("It is routed inward to consumers and produced by no component.", "It is routed inward to consumers and produced by no component.", "F", {}),
 ("At every non-root level an input face is fed by the parent's wire, and at the root there is no parent. No dedicated vocabulary is needed.", "At every non-root level an input face is fed by the parent's wire, and at the root there is no parent. No dedicated vocabulary is needed.", "F", {}),
 ("A root input is usefully read as the output face of the one producer the build never sees: the periphery and the services.", "A root input is usefully read as the output face of the one producer the build never sees, the periphery and the services.", "F", {}),
 ("On that reading, root-input exclusivity (below) is that producer's one-writer right, and the totality (§14.6) is its completeness obligation.", "On that reading, root-input exclusivity (below) is that producer's one-writer right, and the totality (§14.6) is its completeness obligation.", "F", {}),
 ("Root inputs are sources to the build-time ordering, constants within a frame,", "Root inputs are sources to the build-time ordering, and they are constants within a frame", "F", {}),
 ("and the only thing the periphery may write.", "They are the only thing the periphery may write (D-031).", "C", {}),
 ("The GUI reaches them through the resolution (§11.7), and control commands are not writes (§12.1).", "The GUI reaches them through the resolution (§11.7), and control commands are not writes (§12.1).", "F", {}),
 ("Devices, mappings, the trace and the GUI write path address root inputs by face name (§8.6).", "Devices, mappings, the trace and the GUI write path address root inputs by face name (§8.6).", "F", {}),
 ("Structural slash paths never cross the periphery's write boundary.", "Structural slash paths never reach the periphery's writes.", "R", {"ruling": "R10"}),
 ("The write side speaks the root contract's names only.", "The write side speaks the names of the root's contract, the interface the root component declares, and no others (D-129).", "C", {}),
 ("The read side chooses per binding. It uses slash paths in inspection reads, and face names in integration reads and in service reads (§11.2/§13.5/§14.4).", "The read side chooses per binding (the value passed at `attach!` that makes a device framework-legible). It uses slash paths in inspection reads, and face names in integration reads and in service reads (§11.2/§13.5/§14.4).", "F", {}),
 ("Root-input exclusivity: one writer per root input at any time.", "Root-input exclusivity permits at most one writer per root input at any time (D-044).", "C", {}),
 ("A device claims its root inputs at attach, and claiming an already-claimed root input is an attach-time error. Detaching releases the claims.", "A device claims its root inputs (stakes them as faces it may write) at attach, and claiming an already-claimed root input is an attach-time error. Detaching releases the claims.", "F", {}),
 ("A released root input's GUI widgets are live again from the next run (§11.7).", "A released root input's GUI widgets are live again from the next run (§11.7).", "F", {}),
 ("Exclusivity replaces any cross-device conflict policy, such as attachment-order precedence at drain (D-044).", "Exclusivity replaces any cross-device conflict policy (D-044), such as attachment-order precedence at the drain", "F", {}),
 ("Per-device cells, the CAS merge and the atomicswap drain all stay. They serve atomicity and coalescing, not arbitration.", "Per-device staging cells (where each device's pending batch waits between drains), the CAS merge and the atomicswap drain all stay. They serve atomicity and coalescing (the CAS merge keeping one pending batch per device), not arbitration.", "F", {}),
 ("Why. A second live writer on one root input makes the applied value a timing artifact, as the worked example in §11.4 shows.", "Exclusivity holds because a second live writer on one root input makes the applied value a timing artifact, as the worked example in §11.4 shows.", "F", {}),
 ("The usual pair is a stream and its mirror, a joystick axis and the GUI slider showing it. Claiming the stream settles that pair with no concurrent writing.", "The usual pair is a stream and its mirror, a joystick axis and the GUI slider showing it. Claiming the stream settles that pair with no concurrent writing.", "F", {}),
 ("A claim is what a device may write, not what it will.", "A claim is what a device may write, not what it will.", "F", {}),
 ("Data-dependent write-sets are ordinary. A UDP/JSON peer writes whichever subset of faces the incoming message names, and `map_input` is arbitrary user code the framework never inspects.", "Data-dependent write-sets are ordinary. A UDP/JSON peer writes whichever subset of faces the incoming message names, and `map_input` is arbitrary user code the framework never inspects.", "F", {}),
 ("Such a device therefore claims the binding's enumerated allowed set, the faces the binding table lists, whether or not any given batch touches them.", "Such a device therefore claims the binding's enumerated allowed set, the faces the binding table lists, whether or not any given batch touches them.", "F", {}),
 ("The claim is registered at attach exactly as a joystick's is.", "The claim is registered at attach exactly as a joystick's is.", "F", {}),
 ("A broad claim costs liveness. Every enumerated face is claimed for the device's whole attachment, so the derived-liveness rule (§11.7)", "A broad claim costs liveness. Every enumerated face is claimed for the device's whole attachment, so the derived-liveness rule (GUI widget liveness, baked once at run start, §11.7)", "F", {}),
 ("renders the device's GUI widget read-only even on faces the peer never writes.", "renders the GUI's widgets read-only even on faces the peer never writes.", "R", {"ruling": "R10"}),
 ("Narrow the binding to narrow the claim. The enumeration is the interface.", "Narrow the binding to narrow the claim. The enumeration is the interface.", "F", {}),
 ("Every writer has a write surface, and the periphery enforces it.", "Every writer has a write surface, and the periphery enforces it.", "F", {}),
 ("A batch entry reaches a root input iff the named face is inside the writer's surface.", "A batch entry reaches a root input iff the named face is inside the writer's surface (D-044).", "C", {}),
 ("Anything else is discarded with a runtime warning (§13.2).", "Anything else is discarded with a runtime warning (§13.2).", "F", {}),
 ("Because surfaces are static per run (the roster freeze, below),", "Because surfaces are static per run under the roster freeze (attach and detach only while stopped, below),", "F", {}),
 ("enforcement runs entirely at staging, the earliest site, on the writer's own task. The drain performs no checks at all.", "enforcement runs entirely at staging, the earliest site, on the writer's own task. The drain performs no checks at all.", "F", {}),
 ("Every device's surface is its claim set, and a claim set has two sources:", "Every device's surface is its claim set, and a claim set has two sources (D-174):", "C", {}),
 ("- Returned. The binding enumerates the faces.", "- A returned claim is enumerated by the binding.", "F", {}),
 ("It declares `is_input(b) = true`, `claims(b)` (§11.6) is called once at attach, and what it names is staked.", "The binding declares `is_input(b) = true`, `claims(b)` (§11.6) is called once at attach, and what it names is staked.", "F", {}),
 ("Such a claim is static for the attachment and exclusively its own,", "Such a claim is static for the attachment and exclusively its own,", "F", {}),
 ("since claims are disjoint by construction.", "since the attach-time exclusivity check keeps claims disjoint.", "R", {"ruling": "R10"}),
 ("It is binding-bounded even where no one else is involved. A mapping that has drifted onto an unenumerated face is a diagnosable anomaly (`OutOfClaimEntry`), never a silent write, claimed or not.", "It is binding-bounded even where no one else is involved. A mapping that has drifted onto an unenumerated face is a diagnosable anomaly (`OutOfClaimEntry`), never a silent write, claimed or not.", "F", {}),
 ("- Computed. The binding declares `is_greedy(b) = true` (§11.6) and the framework computes the claim at attach:", "- A computed claim is computed by the framework at attach, when the binding declares `is_greedy(b) = true` (§11.6).", "F", {}),
 ("all root-input faces minus the union of the rostered claims, the unclaimed complement at that instant.", "It is all root-input faces minus the union of the rostered claims, the unclaimed complement at that instant.", "F", {}),
 ("This is the shipped GUI's claim (§11.7),", "This is the standard GUI binding's claim (§11.6),", "R", {"ruling": "R23"}),
 ("everything unclaimed, without configuration.", "everything unclaimed, without configuration.", "F", {}),
 ("It is disjoint from every incumbent claim by construction, so exclusivity validates trivially and nothing downstream can tell the two sources apart.", "It is disjoint from every incumbent claim by construction, so exclusivity validates trivially and nothing downstream can tell the two sources apart.", "F", {}),
 ("A complement that comes out empty is legal and useless,", "A complement that comes out empty is legal and useless.", "F", {}),
 ("and `attach!` records `EmptyGreedyClaim`", "`attach!` records an `EmptyGreedyClaim` warning for it (§11.6).", "R", {"ruling": "R5"}),
 ("in the roster entry's diagnostic cell (§11.6, §11.8, D-250).", "records `EmptyGreedyClaim` (Appendix C, a warning naming the device and its binding) in the roster entry's diagnostic cell.", "M", {"where": G2, "ruling": "R5"}),
 ("The periphery resolves root faces against the activation's cell layout alone (D-261).", "The periphery resolves root faces against the activation's cell layout alone (D-261).", "F", {}),
 ("The layout carries the root faces in structure order with their probe values, beside the address table, so both of the build's lookup families, schema and layout, read it there, and writers, claims and the harness compile against it.", "The layout carries the root faces in structure order with their probe values, beside the address table, so both of the build's lookup families, schema and layout, read it there, and writers, claims and the harness compile against it.", "F", {}),
 ("The services take their schema from the `Build` itself (§14.3); the periphery never needs an authored fact the layout does not hold.", "The services take their schema from the `Build` itself (§14.3). The periphery never needs an authored fact the layout does not hold.", "F", {}),
 ("One claim mechanism, two claim sources.", "There is one claim mechanism with two claim sources.", "F", {}),
 ("The source is exhausted at the attach point. Past it, validation, roster-entry storage, shape compilation (§11.4), the drain, the trace and detach-releases-claims treat a computed claim exactly as a returned one.", "The source is exhausted at the attach point. Past it, validation, roster-entry storage, the compilation of shape, shim, merge and scatter (§11.4), the drain, the trace (§11.5) and detach-releases-claims treat a computed claim exactly as a returned one (D-174).", "R", {"ruling": "R5"}),
 ("The GUI is therefore not an exception but an ordinary enumerated writer whose enumeration the framework performed.", "The GUI is therefore not an exception but an ordinary enumerated writer whose enumeration the framework performed.", "F", {}),
 ("Attaching the greedy claimant last is the idiom.", "Attaching the greedy claimant last is the idiom (D-192).", "C", {}),
 ("Its computed claim is taken at the attach point and never recomputed, so attachment order is decisive by design.", "Its computed claim is taken at the attach point and never recomputed, so attachment order is decisive by design.", "F", {}),
 ("Opportunistic writing by autonomous devices does not exist.", "Opportunistic writing by autonomous devices does not exist (D-044).", "C", {}),
 ("A device that wants a face enumerates it, and greediness is an explicit declaration, never a default.", "A device that wants a face enumerates it, and greediness is an explicit declaration, never a default.", "F", {}),
 ("Cross-writer races on one root input therefore cannot arise structurally, because every claim is exclusive, whatever its source.", "Cross-writer races on one root input therefore cannot arise structurally, because every claim is exclusive, whatever its source.", "F", {}),
 ("That is what keeps drain order a diagnostic fact (below) and lets a drained GUI value simply stay (§11.7).", "That is what keeps drain order a diagnostic fact (§11.4) and lets a drained GUI value simply stay (§11.7).", "R", {"ruling": "R10"}),
 ("One framework-owned remainder: the harness writer.", "One framework-owned remainder sits beside the roster, the harness writer", "F", {}),
 ("Beside the roster sits a task-free entry point,", "It is a task-free entry point,", "F", {}),
 ("`stage!(sim, \"face\" => value, …)`,", "`stage!(sim, \"face\" => value, …)`", "R", {"ruling": "R18"}),
 ("the harness/REPL write path (§12.6).", "the harness/REPL write path (§12.6, D-096), called as follows.", "C", {}),
 ("It stages a batch from the calling task itself (the task that invoked `run!`).", "It stages a batch from any task, the calling task (the task that invoked `run!`) included (D-200).", "R", {"ruling": "R4"}),
 ("Its always-present cell is drained, traced and surface-checked exactly as any device's.", "is drained, traced and surface-checked exactly as any device's.", "F", {}),
 ("The harness writer's surface is the one thing in the design that is derived rather than claimed.", "The harness writer's surface is the one thing in the design that is derived rather than claimed (D-174).", "C", {}),
 ("It is the unclaimed complement, the faces no rostered device speaks for. That surface is recomputed at every stopped-sim roster change, and is therefore as fixed within a run as any claim set.", "It is the unclaimed complement, the faces no rostered device speaks for. That surface is recomputed at every stopped-sim roster change, and is therefore as fixed within a run as any claim set.", "F", {}),
 ("A `stage!` write to a claimed face is rejected at staging (`ClaimedFaceEntry`, naming the incumbent).", "A `stage!` write to a claimed face is rejected at staging (`ClaimedFaceEntry`, naming the incumbent, D-174).", "C", {}),
 ("A rostered greedy claimant empties that surface outright. The greedy claim is itself a rostered claim, so the complement it leaves is empty and every `stage!` in such a session is rejected that way (D-192).", "A rostered greedy claimant empties that surface outright. The greedy claim is itself a rostered claim, so the complement it leaves is empty and every `stage!` in such a session is rejected that way (D-192).", "F", {}),
 ("There is one seam, a batch staged while stopped whose face a subsequent `attach!` claims, and the attach itself renormalizes it away (below).", "There is one edge case, a batch staged while stopped whose face a subsequent `attach!` claims, and the attach itself renormalizes it away (§11.4).", "R", {"ruling": "R10"}),
 ("The harness cell (the always-present staging cell of the harness writer)", "Its always-present staging cell, the harness cell,", "F", {}),
 ("drains last, by convention.", "The harness cell drains last, by convention (D-174).", "C", {}),
 ("With every surface disjoint the order is unobservable, so the rule exists to make the trace read the same way every time, not to arbitrate anything.", "With every surface disjoint the order is unobservable, so the rule exists to make the trace read the same way every time, not to arbitrate anything.", "F", {}),
 ("Root-input initial values are owned by the init/trim services.", "The init/trim services own root-input initial values (D-047).", "C", {}),
 ("Input declarations are bare types (§8.2) and carry no defaults, yet a root input unfed by any device must hold a defined value from the first frame.", "Input declarations are bare types (§8.2) and carry no defaults, yet a root input unfed by any device must hold a defined value from the first frame.", "F", {}),
 ("No declaration constant could own that value, because the trim service writes root-input values it solved for, such as throttle and elevator. Export-entry defaults were rejected (D-047).", "No declaration constant could own that value, because the trim service writes root-input values it solved for, such as throttle and elevator. Export-entry defaults were rejected (D-047).", "F", {}),
 ("`init!` establishes every root input, and the trace header captures the result.", "`init!` establishes every root input, and the trace header (the trace's fixed preamble, a checkpoint `init!` takes) captures the result.", "F", {}),
 ("Totality is enforced pre-write at every complete-world application: `init!`, trim setup, trim commit (§14.6).", "Totality is enforced pre-write at every complete-world application, namely `init!`, trim setup and trim commit (§14.6, D-149).", "C", {}),
 ("The roster is frozen per run: attach and detach are stopped-sim operations.", "The roster is frozen per run (D-106). Attach and detach are stopped-sim operations.", "C", {}),
 ("`attach!`/`detach!` are legal in the `built`, `initialized` and `stopped` states (§12.6) and an error while `running`.", "`attach!`/`detach!` are legal in the `built`, `initialized` and `stopped` states (§12.6) and an error while `running`.", "F", {}),
 ("That error is `ServiceLifecycle` (Appendix C), the same kind that gates the §14 services.", "That error is `ServiceLifecycle` (Appendix C, D-108), the same kind that gates the §14 services.", "C", {}),
 ("The list is exhaustive. An `errored` simulation refuses both with the same kind. A roster change configures the next run, and an errored simulation has none (§13.6, D-232).", "The list is exhaustive. An `errored` simulation refuses both with the same kind. A roster change configures the next run, and an errored simulation has none (§13.6, D-232).", "F", {}),
 ("The prohibition includes pause. Pause is a control-plane state inside a run (§12.1), and a surface that could move while paused would move mid-run.", "The prohibition includes pause. Pause is a control-plane state inside a run (§12.1), and a surface that could move while paused would move mid-run.", "F", {}),
 ("The roster (entries, claims, attachment order) is therefore a plain immutable value", "The roster (entries, claims, attachment order) is therefore a plain immutable value.", "F", {}),
 ("the loop reads once at `run!`.", "The loop reads it once at `run!`,", "F", {}),
 ("The partition of the root face set into per-writer surfaces plus the harness remainder is a static, inspectable fact of the run.", "The partition of the root face set into per-writer surfaces plus the harness remainder is a static, inspectable fact of the run (D-106).", "C", {}),
 ("It is printable before the run starts and valid until it ends (printable like the face routes, §13.7).", "It is printable before the run starts and valid until it ends (printable like the face routes, §13.7).", "F", {}),
 ("No republication machinery exists. There is no atomic roster reference, no per-frame acquire-load, no next-frame attachment granularity and no sequence numbers.", "and nothing republishes it (D-087).", "R", {"ruling": "R6"}),
 ("Attachment order is the roster's own order.", "Attachment order is the roster's own order.", "F", {}),
 ("The trace still tags entries with a stable device id, never a roster index, because ids read across runs, where the roster does change.", "The trace still tags each record with a stable device id, never a roster index, because ids read across runs, where the roster does change (D-087).", "C", {}),
 ("Attach validation, claim registration and the staging-shape compilation (below) all run at the attach point,", "Attach validation, claim registration and the staging-shape compilation (§11.4) all run at the attach point.", "R", {"ruling": "R10"}),
 ("which makes `attach!`/`detach!` stopped-sim configuration operations beside `init!` and trim (§14).", "That makes `attach!`/`detach!` stopped-sim configuration operations beside `init!` and trim (§14).", "F", {}),
 ("While a simulation runs, its configuration (build, roster, claims, surfaces) is immutable.", "While a simulation runs, its configuration (build, roster, claims, surfaces) is immutable.", "F", {}),
 ("The doctrine (§12.5) extends to its final form.", "The mid-run mutation doctrine (§12.5) extends to its final form.", "F", {}),
 ("The running periphery stages writes and issues control commands, and nothing else changes.", "The running periphery stages writes and issues control commands, and nothing else changes (D-031).", "C", {}),
 ("Device identity, ids and roster admission.", "#### Device identity and admission", "X", {}),
 ("Identity is the device instance. The same object (`===`) may occupy at most one roster entry. Two instances of the same type, two joysticks say, are two devices.", "Identity is the device instance. The same object (`===`) may occupy at most one roster entry. Two instances of the same type, two joysticks say, are two devices.", "F", {}),
 ("The stable device id the trace, heartbeat and diagnostics speak is assigned at `attach!`, monotonic per `Simulation` and never reused.", "The stable device id the trace, heartbeat and diagnostics speak is assigned at `attach!`, monotonic per `Simulation` and never reused.", "F", {}),
 ("It lives exactly as long as the entry: across runs (roster persistence, §12.6), until `detach!`.", "It lives exactly as long as its roster entry, across runs (roster persistence, §12.6) and until `detach!`.", "F", {}),
 ("Admission is a two-part check at the attach point, in order:", "Admission is a two-part check at the attach point, in order:", "F", {}),
 ("``` # each line: the condition that rejects the attach → the diagnostic it raises identity this instance is already rostered → AlreadyAttached (names the entry and its binding) claims face exclusivity: this device's claim set meets a rostered claim → ClaimConflict (names two distinct devices) ```", "``` # each line: the condition that rejects the attach → the diagnostic it raises identity this instance is already rostered → AlreadyAttached (names the entry and its binding) claims face exclusivity: this device's claim set meets a rostered claim → ClaimConflict (names two distinct devices) ```", "F", {}),
 ("An already-rostered instance is rejected rather than silently absorbed, because rebinding has an explicit spelling: `detach!` then `attach!`, both legal at any stopped-sim point.", "An already-rostered instance is rejected rather than silently absorbed, because rebinding has an explicit spelling, `detach!` then `attach!`, both legal at any stopped-sim point.", "F", {}),
 ("Either a silent no-op or a silent rebind would discard a binding the caller handed over.", "Either a silent no-op or a silent rebind would discard a binding the caller handed over.", "F", {}),
 ("Running the claims check after the identity check is what makes `ClaimConflict` always name two distinct devices, never a device colliding with its own earlier attachment.", "Running the claims check after the identity check is what makes `ClaimConflict` always name two distinct devices, never a device colliding with its own earlier attachment.", "F", {}),
 ("Device death does not detach.", "Device death does not detach (D-106).", "C", {}),
 ("A mid-run crash, voluntary exit or unplug (§11.6, §12.4) ends the device's task.", "A mid-run crash, voluntary exit or unplug (§11.6, §12.4) ends the device's task.", "F", {}),
 ("The cell stops filling, the §12.2 heartbeat shows the death by name, and the roster entry, claims included, persists to the end of the run.", "The staging cell stops filling, the §12.2 heartbeat shows the death by name, and the roster entry, claims included, persists to the end of the run.", "F", {}),
 ("The orphaned claims are the accepted cost of the freeze.", "The orphaned claims (the claims of a device whose task died mid-run) are the accepted cost of the freeze.", "F", {}),
 ("The device's root inputs hold their last-drained values and no other writer inherits them.", "The device's root inputs hold their last-drained values and no other writer inherits them.", "F", {}),
 ("The read-only widgets (§11.7) render the orphan visibly", "The read-only widgets render the orphan visibly, never mysteriously (§11.7).", "R", {"ruling": "R5"}),
 ("(\"claimed by `T16000M` — task dead\")", "renders the fact in its source label (\"claimed by `T16000M` — task dead\")", "M", {"where": H, "ruling": "R5"}),
 (", never mysteriously.", "render the orphan visibly, never mysteriously", "F", {}),
 ("Recovery is between runs:", "Recovery is between runs.", "F", {}),
 ("stop, `detach!`, and either `init!` (fresh trajectory) or `replay!`-to-end then `run!` (continuation from the interrupted boundary, §12.7).", "It takes a stop, a `detach!`, and either `init!` (fresh trajectory) or `replay!`-to-end then `run!`, which continues from the interrupted boundary (§12.7).", "F", {}),
 ("The death is an anomaly, not a surface event.", "The death is an anomaly, not a surface event.", "F", {}),
 ("One deliberate asymmetry is on record as a guarded addition (a capability the design admits but does not build).", "One deliberate asymmetry is on record as a guarded addition (a capability the design admits but does not build).", "F", {}),
 ("A pure reader claims nothing. Examples are a binding declaring `is_output` alone (§11.6), a visualizer or a telemetry tap.", "A pure reader claims nothing. Examples are a binding declaring `is_output` alone (§11.6), a visualizer or a telemetry tap.", "F", {}),
 ("Attaching one mid-run would therefore move no writer's surface.", "Attaching one mid-run would therefore move no writer's surface (D-106).", "C", {}),
 ("A dynamic reader list would touch only §12.3 wakeups, the heartbeat and the shutdown join, never the drain,", "A dynamic reader list would touch only §12.3 wakeups, the heartbeat and the shutdown join, never the drain.", "F", {}),
 ("and it is cleanly severable from the freeze should the join-a-running-session workflow find a customer.", "The addition is cleanly severable from the freeze should the join-a-running-session workflow find a customer.", "F", {}),
 ("The §12.2 thread-budget warning runs once per run,", "The §12.2 thread-budget warning runs once per run,", "F", {}),
 ("at either door,", "at `run!` or `replay!`,", "R", {"ruling": "R10"}),
 ("against the frozen population.", "against the frozen population.", "F", {}),
]

ADDED = [
 "the compilation of shape, shim, merge and scatter",
 "the trace (§11.5)",
 "the interface the root component declares",
 "(the value passed at `attach!` that makes a device framework-legible)",
 "(stakes them as faces it may write)",
 "(where each device's pending batch waits between drains)",
 "(the CAS merge keeping one pending batch per device)",
 "(GUI widget liveness, baked once at run start,",
 "(attach and detach only while stopped,",
 "(the trace's fixed preamble, a checkpoint `init!` takes)",
 "(the claims of a device whose task died mid-run)",
 "(the inputs no component produces).",
 "A component is the unit of modeling, and a face is the name a port wears on its component's boundary.",
 "The trace is the primary record of a session.",
 "(the one writer whose surface is derived, not claimed).",
 "The periphery (everything outside the loop that exchanges data with it) writes into a running model through its root inputs alone.",
 "The periphery's writers include devices (any attached participants in the periphery).",
 "Each root input has at most one writer at any time, and the assignment of root inputs to writers is fixed for a whole run, because the roster (the list of attached device entries) is frozen per run.",
 "The section's parts, in order, cover the write surface, exclusivity and claims, write surfaces and claim sources, the harness writer and the layout, root-input initial values, the frozen roster, device identity and admission, device death, and mid-run readers.",
 "#### The write surface", "#### Exclusivity and claims", "#### Write surfaces and claim sources",
 "#### The harness writer and the layout", "#### Root-input initial values", "#### The frozen roster",
 "#### Device death and orphaned claims", "#### Mid-run readers",
 "(one iteration of the loop).",
 "(the frame-top swap that applies staged device writes to the root inputs).",
 "An enumeration naming a face outside the root's input faces is refused at attach (`AttachUnknownFace`, D-216).",
 "Detaching a device the roster does not hold is an error (`NotAttached`, D-215).",
]

claims = []
bad = 0
for i, (o, n, tag, ex) in enumerate(C, 1):
    where = ex.get("where", "new")
    cites = sorted(set(CITE.findall(o)))
    d = {"id": f"C-{i:03d}", "old": o, "new": n, "where": where, "cites": cites}
    if o not in O: print("OLD?", d["id"], o[:60]); bad += 1
    if where == "new":
        us = [x for x in NU if n in x]
        if not us: print("NEW?", d["id"], n[:60]); bad += 1
        else:
            nc = set(CITE.findall(n)) | (set(cites) & set(CITE.findall(us[0])))
            lost = set(cites) - set(CITE.findall(us[0]))
            if lost: print("CITE DROPPED", d["id"], lost)
            if nc != set(cites): d["newcites"] = sorted(nc)
    else:
        if set(cites): d["newcites"] = []
    d["tag"] = tag
    if "ruling" in ex: d["ruling"] = ex["ruling"]
    claims.append(d)
for a in ADDED:
    if a not in N: print("ADDED?", a[:60]); bad += 1
json.dump({"claims": claims, "added": ADDED}, open("ch11/units/C/inventory.json", "w"), indent=1, ensure_ascii=False)
print("built", len(claims), "bad", bad)
