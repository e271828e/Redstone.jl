# Scratch: builds inventory.json for unit G1. Run from docs/spec_rewrite.
import json, re, os
CITE = re.compile(r'§\d+(?:\.\d+)?|D-\d{3}|Appendix [A-D]')
C = []


def c(old, new=None, tag="F", ruling=None, newcites=None, note=None, move=None):
    new = old if new is None else new
    d = {"old": old, "new": new, "where": "new", "cites": sorted(set(CITE.findall(old))), "tag": tag}
    nc = sorted(set(CITE.findall(new))) if newcites is None else newcites
    if set(nc) != set(d["cites"]): d["newcites"] = nc
    if ruling: d["ruling"] = ruling
    if move: d["move"] = move
    if note: d["note"] = note
    C.append(d)


# Heading and context (M58 moves the degenerate-uses paragraph up into it)
c("### 11.6 Devices: one authoring contract, no taxonomy")
c("FlightCore's input/output/GUI trichotomy is lock choreography, not modeling.")
c("With no lock, the protocol the taxonomy encoded has no referent (D-025).")
# The handle
c("#### Every attached device receives the same handle",
  "Every attached device receives the same handle.", "X",
  note="the old claim-heading becomes the paragraph's first sentence; the label is 'The device handle'")
c("The handle carries the two primitive capabilities, read and stage, plus control access (observe running, request shutdown).",
  "The handle carries the two primitive capabilities, read and stage, plus control access (observe running, request shutdown) (D-025).",
  "C", note="D-025 Position: 'uniform handle with read (snapshot / next-boundary) + stage + control capabilities'")
c("Read returns the latest snapshot, optionally waiting for the next boundary (§12.3).",
  "Read returns the latest snapshot (the immutable per-boundary publication). It can optionally wait for the next boundary (a published consistency point) first (§12.3).",
  note="split for the two glosses, which are listed in added")
c("A handle outlives its roster entry as an object only.",
  "A handle outlives its roster entry as an object only (D-244).", "C",
  note="the bold's D-citation moves into its sentence; D-244 stays at the paragraph's end too")
c("`detach!` retires the entry and the compiled writer behind it, but the caller may still hold the handle `attach!` returned.",
  "`detach!` retires the roster entry and the compiled writer behind it, but the caller may still hold the handle `attach!` returned.",
  "R", "R10-F65")
c("Its two write primitives, `stage!` and `report!`, then refuse by name (`DeviceContractMismatch`, Appendix C).")
c("A batch staged there would land in a cell no drain reads,",
  "A batch staged there would land in a staging cell, and no drain (the frame-top swap that applies staged device writes to the root inputs) reads that cell.",
  "R", "R10-F65", note="bare 'cell' becomes 'staging cell'; the drain's gloss is R13's")
c("and a report would land in a diagnostic cell no frame top folds.",
  "A report would land in a diagnostic cell (each writer's bounded ring of diagnostics and its heartbeat). No frame top (the start of one loop iteration) folds that cell.",
  note="split for the glosses of diagnostic cell and frame, both linked here at their first use")
c("Silence is the hidden-bug class this section tolerates nowhere.")
c("The read primitives stay legal, since they read the simulation's shared state and nothing of the entry's (D-244).",
  "The read primitives stay legal, since they read the simulation's shared state and nothing of the roster entry's (D-244).",
  "R", "R10-F65")
# should_abort (M57: moved down after "should_close dissolves")
c("`should_abort` is an `attach!` keyword, defaulting to `false`.",
  "`should_abort` is an `attach!` keyword, defaulting to `false` (D-138).", "C", move="M57",
  note="the bold gains D-138, whose Rationale gives should_abort its declaration site, 'an attach! keyword, default false'")
c("It is per-attachment, never a device property.", move="M57", tag="M")
c("The same joystick is advisory in one deployment and decisive in another.", move="M57", tag="M")
c("With it clear, a device's departure is reported and the run continues without it.",
  "With `should_abort` clear, a device's departure is reported and the run continues without it.", "M", move="M57",
  note="'it' spelled out: the antecedent is three sentences back")
c("With it set, that departure also requests a sim stop (§12.4).", move="M57", tag="M")
c("A departure is the loop body returning, a crash, or a failed `init!`.", move="M57", tag="M")
c("A hardware-in-the-loop rig attaches its plant interface with it set, since a run without that device is meaningless.", move="M57", tag="M")
# Degenerate uses (M58: moved up into the context paragraph)
c("Input-only and output-only devices are degenerate uses, not framework classes.",
  "A device may be input-only or output-only, and those are degenerate uses, not framework classes (D-025).",
  "C", move="M58", note="D-025 Position: 'input-only/output-only as degenerate uses'; the device gloss is its own added sentence before it (verifier fix)")
c("A bidirectional network peer is one device with one socket and one lifecycle, not two framework devices sharing state.", move="M58", tag="M")
c("The GUI is an ordinary device, the paradigm one, and it uses every capability.",
  "The GUI is an ordinary device, the paradigm one, and it uses every capability of the handle below.", "M", move="M58",
  note="pointer added: the handle's capabilities are now listed after this sentence")
c("Its one genuine peculiarity is not taxonomic: read-modify-write widgets (§11.7).",
  "Its one genuine peculiarity, read-modify-write widgets, is not taxonomic (§11.7).", "M", move="M58",
  note="mid-sentence colon removed")
# The authoring contract
C.append({"old": "#### The authoring contract: four functions, one optional", "new": "#### The authoring contract: four functions, one optional",
          "where": "units/G1/deleted.md", "cites": [], "tag": "R", "ruling": "R22",
          "note": "D-366 reverses the claim; the new label is 'The authoring contract' (listed in added)"})
c("A device is a user type subtyping the framework's neutral root: `MyDevice <: AbstractDevice`.",
  "A device is a user type subtyping the framework's neutral root, `MyDevice <: AbstractDevice` (D-177).", "C",
  note="D-177 Position: 'every device subtypes AbstractDevice ... mandatorily'")
c("That is one mandatory word, and it costs nothing, because the periphery has no competing hierarchy to inherit from.",
  "That is one mandatory word, and it costs nothing, because the periphery has no competing hierarchy to inherit from.",
  note="periphery's link and gloss moved to its first use, in the context paragraph")
c("What it buys is `attach!`'s dispatch gate below.",
  "What it buys is `attach!`'s dispatch gate (D-177).", "R", "R18",
  note="'below' dropped: the attach! signature (R18) now follows at once; D-177 Position: 'so attach!(...) gates at dispatch'")
c("The framework asks for", "The framework asks for four functions.", "R", "R22",
  note="the count of the block's functions; which are optional is now D-366's sentence after the block")
c("`init!(dev) # per-run resource acquisition — calling task, before spawn (§12.4) loop(dev, handle) # the task body: owns its own wait structure shutdown!(dev) # per-run resource release — guaranteed on every exit path unblock!(dev) # optional hook, default no-op: make a blocked loop return (§12.4)`",
  "`init!(dev) # per-run resource acquisition — calling task, before spawn (§12.4) loop(dev, handle) # the task body: owns its own wait structure shutdown!(dev) # per-run resource release — guaranteed on every exit path unblock!(dev) # make a blocked loop return (§12.4)`",
  "R", "R22", note="code block; the unblock! comment edited by ruling, 'optional hook, default no-op' now carried by the sentence after the block")
c("The framework owns everything around them.", "The framework owns everything around the four functions (D-102).", "C",
  note="D-102 Position: 'author-owned loop body inside a framework-owned bracket'")
c("The wrapper is the shutdown protocol (§12.4) made structural:",
  "The wrapper is the shutdown protocol (§12.4) made structural.")
c("`init!(dev) # its own bracket, pre-spawn (§12.4): a throw # here is shutdown! + DeviceCrash by name task = Threads.@spawn try loop(dev, handle) catch e report!(entry, DeviceCrash(e)) # §12.4(6): sim continues, device absent finally shutdown!(dev) # any exit path: OS resources released mark_dead!(...) # heartbeat only — claims stay, §11.3 end`",
  "`init!(dev) # its own bracket, pre-spawn (§12.4): a throw # here is shutdown! + DeviceCrash by name task = Threads.@spawn try loop(dev, handle) catch e report!(entry, DeviceCrash(e)) # §12.4(6): sim continues, device absent finally shutdown!(dev) # any exit path: OS resources released # no dead-marking: task_state shows the end, claims stay, §11.3 end`",
  tag="R", ruling="R21", note="code block; the mark_dead! line becomes a comment by ruling")
# shutdown!'s tolerances
c("`shutdown!` must tolerate a partially initialized device.",
  "`shutdown!` must tolerate a partially initialized device (D-138).", "C",
  note="D-138 Rationale: 'a new taught obligation: shutdown! must tolerate a partially initialized device'")
c("The release guarantee holds on the one path outside this wrapper too.")
c("The initialization step (§12.4) brackets each `init!`,",
  "The initialization step (§12.4) brackets each `init!` (D-138).", "C",
  note="D-138 Position: 'each call in its own bracket'")
c("and a device that threw half-way through acquisition goes straight back to `shutdown!`, so nothing it did manage to open is leaked.",
  "A device that threw half-way through acquisition goes straight back to `shutdown!`, so nothing it did manage to open is leaked.")
c("The obligation that follows is \"close only what is open\".")
c("That is the same defensiveness `shutdown!` already owes the crash path, where a loop body may die at any point in its own life.")
c("`init!` is correspondingly not asked to clean up after itself.")
c("The bracket does once, for every device, what would otherwise be duplicated in each and enforced in none.")
c("The same tolerance covers a repeated call.", "The same tolerance covers a repeated call (D-268).", "C",
  note="the bold's D-citation moves into its sentence; D-268 bullet 6")
c("The wrapper runs `shutdown!` once on every exit path and records the release just after it returns. An operator interrupt landing between the two makes the run's tail run `shutdown!` again rather than leak the device (§12.4, D-268). The tail's own call can be cut the same way, so each such interrupt adds one call.",
  "The wrapper runs `shutdown!` once on every exit path. When an operator interrupt (Ctrl-C in an interactive session) reaches `run!` before its tail, `run!` releases directly, not through a wrapper, each device it never spawned, advancing a cursor after each `shutdown!` returns, and retries from where an interrupt cut it (§12.4, D-268). An interrupt landing between a `shutdown!`'s return and the cursor's advance repeats that call rather than leak the device, so each such interrupt adds one call.",
  "R", "R20", note="R31 rewords its clause on unspawned devices; restated as the code has it (src/sim.jl 1212-1227); operator interrupt linked with its gloss")
c("A `shutdown!` that closes only what is open is idempotent by construction, so a repeated call costs nothing and is never reported.")
c("The tolerance also covers a call with no `init!` before it.",
  "The tolerance also covers a call with no `init!` before it (D-268).", "C",
  note="the bold's D-citation moves into its sentence; D-268 bullet 7")
c("The initialization step lists each device for release before its `init!` begins, so that no interrupt can leave an initialized device unlisted (§12.4, D-268).")
c("An operator interrupt landing between the listing and the `init!` therefore releases a device that opened nothing.")
c("A `shutdown!` that closes only what is open does nothing there, and the call is never reported.")
# The operator interrupt
c("The wrapper makes one discrimination.")
c("An `InterruptException` is never a `DeviceCrash`.", "An `InterruptException` is never a `DeviceCrash` (D-132).", "C",
  note="D-132 Rationale: 'the device wrapper never turns one into DeviceCrash'")
c("Under the spawned-loop topology the calling task is the one running a device loop body inline, the GUI's (§11.1). An operator Ctrl-C therefore raises there, inside user code that did nothing wrong.",
  "The operator interrupt is a control-plane stop, not a failure (D-132).", "R", "R14",
  note="stale topology replaced by D-132 Position's reason; the §11.1 citation is dropped")
c("The wrapper forwards the control-plane stop", note="kept by R25")
C.append({"old": "and lets the body leave through the ordinary `running(handle)` predicate (§12.4(4)).",
          "new": "and lets the body leave through the ordinary `running(handle)` predicate (§12.4(4))",
          "where": "units/G1/deleted.md", "cites": ["§12.4"], "tag": "R", "ruling": "R25"})
c("There is no crash report for what is not a crash, and no `should_abort` consultation, since a stop is already requested.")
# Loop bodies
c("#### The author owns the loop body; the framework owns the bracket", "#### The author-owned loop body", "X",
  note="claim-heading becomes a topic label; both halves are stated in the text (D-102 sentences)")
c("One device contract means author-owned loop bodies.")
c("A framework-owned hook loop would have to ask each device what it waits on, which is the rejected taxonomy resurrected as a trait (D-102).")
c("Under the author-owned body, every wait structure is ordinary user code composed from handle primitives:",
  "Under the author-owned body, every wait structure is ordinary user code composed from handle primitives.")
c("function loop(dev::T16000M, handle) # timer-driven, full write-set while running(handle) sleep(dev.Δt_poll) stage!(handle, map_input(poll_axes(dev), binding(handle))) end end",
  "function loop(dev::T16000M, handle) # timer-driven, full write-set while running(handle) sleep(dev.Δt_poll) stage!(handle, map_input(poll_axes(dev), binding(handle))...) end end",
  "R", "R10-F56", note="code block, part 1; the splat added")
c("function loop(dev::UDPInput, handle) # source-driven, data-dependent while running(handle) datum = recv(dev.socket) # blocks; unblock! closes the socket is_eot(datum) && return # voluntary exit try stage!(handle, map_input(datum, binding(handle))) catch e is_datum_error(dev, e) || rethrow() # a bug → wrapper → DeviceCrash report!(handle, MalformedDatum(e)) # garbage → visible, bounded, alive end end end",
  "function loop(dev::UDPInput, handle) # source-driven, data-dependent while running(handle) datum = recv(dev.socket) # blocks; unblock! closes the socket is_eot(datum) && return # voluntary exit try stage!(handle, map_input(datum, binding(handle))...) catch e is_datum_error(dev, e) || rethrow() # a bug → wrapper → DeviceCrash report!(handle, MalformedDatum(e)) # garbage → visible, bounded, alive end end end",
  "R", "R10-F56", note="code block, part 2; the splat added")
c("function loop(dev::Telemetry, handle) # boundary-driven output while running(handle) snap = wait_next_snapshot(handle) # §12.3; returns on stop send(dev.socket, map_output(gather(handle, snap), binding(handle))) end end",
  note="code block, part 3, verbatim")
c("A bidirectional peer composes both halves itself, with an inner reader task inside its own domain, rather than forcing a select engine into the framework.")
c("Two idioms are author obligations the framework can only teach and diagnose, never force (Appendix A): loop on `running(handle)`, and make blocking calls interruptible (`unblock!`, or timeouts).",
  "Two idioms are author obligations the framework can only teach and diagnose, never force (Appendix A, D-102). The author must loop on `running(handle)` and must make blocking calls interruptible (`unblock!`, or timeouts).",
  "C", note="colon removed; D-102 Rationale: the two author obligations are 'taught (Appendix A) and diagnosed ..., never forced'")
c("A forgotten predicate check surfaces as `DeviceJoinTimeout` with the device's name.")
c("A stall surfaces as a stale heartbeat (§12.2).")
c("Liveness timestamps ride inside the handle primitives, which store them in the device's own diagnostic cell (§11.8), so the framework observes activity without owning the loop.")
c("`should_close` dissolves.", "FlightCore's device hook `should_close` dissolves (D-102).", "C",
  note="D-102 Rationale: 'should_close dissolves into the loop body returning'")
c("A window ✕ or peer EOT is the loop body returning.")
c("The wrapper's exit path releases the device's OS resources, marks it dead for the heartbeat and consults `should_abort`.",
  "The wrapper's exit path releases the device's OS resources and consults `should_abort`. Nothing marks the device dead beyond its record. The task has ended, `task_state` says so at the next publication, and its heartbeat goes stale (§12.2).",
  "R", "R21", note="src/devices.jl 395-399")
c("Claims and the roster entry persist to run end (the freeze, §11.3).",
  "Claims and the roster entry persist to run end (the freeze, §11.3, D-106).",
  "C", note="D-106 Rationale: 'claims and roster entry persist to run end'; claim linked with its gloss, roster's link moved to its first use")
c("§12.4(6) is literally \"the task body returned.\"", "This is §12.4(6)'s case.", "R", "R10-F60")
c("The GUI implements the same authoring contract.")
# Bad datum versus bug (M54: moved up after the loop bodies; it already follows them here)
c("#### Bad datum versus bug: two classes, two fates", move="M54", tag="M")
c("A datum that cannot be mapped for environmental reasons (a truncated datagram, malformed JSON, an out-of-range field) is a bad datum, tolerated in the loop body.",
  "A datum that cannot be mapped for environmental reasons (a truncated datagram, malformed JSON, an out-of-range field) is a bad datum, tolerated in the loop body (D-105).",
  "C", move="M54", note="D-105 cited at the rule; it stays at the next paragraph's end too")
c("The body catches it, stages nothing, calls `report!(handle, MalformedDatum(cause))` and continues.", move="M54", tag="M")
c("That tolerance is bounded by the device's own diagnostic cell (the ring and suppressed counts, §11.8; the stream, §13.2), and what it records is visible next to a live heartbeat.", move="M54", tag="M")
c("Any other exception propagates, and the wrapper turns it into `DeviceCrash` (§12.4).", move="M54", tag="M")
c("The classification is the author's, because only they know their parser.", move="M54", tag="M")
c("FlightCore's `InputMappingError` docstring assigned it the same way.", move="M54", tag="M")
c("What changes under the author-owned loop is that no framework per-iteration catch site exists, so the framework's contribution is the diagnostic channel, not the catch.", move="M54", tag="M")
c("A marked exception type is not provided (D-105).", move="M54", tag="M")
c("`report!(handle, …)` writes device-attributed runtime warnings into that device's diagnostic cell, the single-writer entry point into the runtime warning stream (§13.2, §11.8), and nothing more.",
  "`report!(handle, …)` writes device-attributed runtime warnings into that device's diagnostic cell, the single-writer entry point into the runtime warning stream (§13.2, §11.8, D-160), and nothing more.",
  "C", move="M54", note="D-160 Position: 'it writes device-attributed runtime warnings into the device's diagnostic cell'; the link whose displayed text was bare 'cell' is gone (F65), diagnostic cell being linked above")
c("It is not a general user-diagnostics channel.", move="M54", tag="M")
c("Tolerating everything hides bugs as \"device attached, nothing happens\".", move="M54", tag="M")
c("Tolerating nothing kills a live telemetry link on its first truncated datagram, and since tasks are per-run artifacts (D-093), kills it for the rest of the run.", move="M54", tag="M")

ADDED = [
    "#### The device handle",
    "A device is an attached participant in the periphery (everything outside the loop that exchanges data with it).",
    "of the handle below",
    "(the immutable per-boundary publication)",
    "(a published consistency point)",
    "Each attached device has a roster entry (its record in the list of attached devices).",
    "(the frame-top swap that applies staged device writes to the root inputs)",
    "(each writer's bounded ring of diagnostics and its heartbeat)",
    "(the start of one loop iteration)",
    "`attach!(sim::Simulation, dev::AbstractDevice, new_binding::AbstractBinding; should_abort::Bool = false)`",
    "`attach!` takes the device with its binding (the value that makes a device framework-legible, described below).",
    "Its keyword `should_abort` (the per-attachment failure policy) is covered after the loop bodies below.",
    "#### The authoring contract",
    "Only `loop` is mandatory (D-366). `init!`, `shutdown!` and `unblock!` are optional hooks, each defaulting to a no-op.",
    "`attach!` refuses a device with no `loop` method (`DeviceContractMismatch`, D-216).",
    "#### What `shutdown!` must tolerate",
    "(Ctrl-C in an interactive session)",
    "#### The operator interrupt",
    "In the sketches, `T16000M` is FlightCore's type for the Thrustmaster T16000M joystick, and `UDPInput` is FlightCore's UDP input device type.",
    "FlightCore's device hook",
    "The sketches map data through the binding's `map_input` and `map_output`, described below.",
    "A device's claim is the set of faces (the names ports wear on their component's boundary) it may write.",
]

for i, d in enumerate(C, 1): d["id"] = f"G1-{i:03d}"
C = [{"id": d.pop("id"), **d} for d in C]
out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "inventory.json")
json.dump({"claims": C, "added": ADDED}, open(out, "w"), indent=1, ensure_ascii=False)
print(len(C), "claims,", len(ADDED), "added")
