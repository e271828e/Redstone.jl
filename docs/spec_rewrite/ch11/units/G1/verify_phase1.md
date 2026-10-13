# G1 verify, phase 1 (blind read of new.md)

V1 FlightCore's input/output/GUI trichotomy is lock choreography, not modeling.
V2 With no lock, the protocol the taxonomy encoded has no referent [D-025].
V3 Input-only and output-only devices are degenerate uses, not framework classes [D-025].
V4 (gloss) devices are attached participants in the periphery.
V5 A bidirectional network peer is one device with one socket and one lifecycle, not two framework devices sharing state.
V6 The GUI is an ordinary device, the paradigm one, using every handle capability.
V7 The GUI's one genuine peculiarity, read-modify-write widgets, is not taxonomic [§11.7].
V8 Every attached device receives the same handle.
V9 The handle carries two primitive capabilities, read and stage, plus control access (observe running, request shutdown) [D-025].
V10 Read returns the latest snapshot (immutable per-boundary publication).
V11 Read can optionally wait for the next boundary first [§12.3].
V12 Each attached device has a roster entry (its record in the list of attached devices).
V13 BOLD: A handle outlives its roster entry as an object only [D-244].
V14 detach! retires the roster entry and the compiled writer behind it; the caller may still hold the handle attach! returned.
V15 After detach!, stage! and report! refuse by name (DeviceContractMismatch) [Appendix C].
V16 A batch staged there would land in a staging cell no drain reads (drain gloss: frame-top swap applying staged device writes to root inputs).
V17 A report would land in a diagnostic cell (gloss: each writer's bounded ring of diagnostics and heartbeat) that no frame top folds.
V18 Silence is the hidden-bug class this section tolerates nowhere.
V19 Read primitives stay legal after detach!, since they read the sim's shared state and nothing of the roster entry's [D-244].
V20 A device is a user type subtyping AbstractDevice, the framework's neutral root [D-177].
V21 That is one mandatory word and costs nothing because the periphery has no competing hierarchy [D-177 implied].
V22 What it buys is attach!'s dispatch gate [D-177].
V23 Signature: attach!(sim, dev::AbstractDevice, binding::AbstractBinding; should_abort = false).
V24 attach! takes the device with its binding (value making a device framework-legible, described below).
V25 should_abort keyword is the per-attachment failure policy, covered after the loop bodies.
V26 The framework asks for four functions: init!, loop, shutdown!, unblock!.
V27 init!: per-run resource acquisition, on the calling task, before spawn (§12.4).
V28 loop: task body, owns its own wait structure.
V29 shutdown!: per-run release, guaranteed on every exit path.
V30 unblock!: makes a blocked loop return (§12.4).
V31 BOLD: Only loop is mandatory [D-366].
V32 init!, shutdown!, unblock! are optional hooks defaulting to no-ops.
V33 attach! refuses a device with no loop method (DeviceContractMismatch) [D-216].
V34 The framework owns everything around them [D-102].
V35 The wrapper is the shutdown protocol (§12.4) made structural.
V36 Wrapper sketch: init! in its own pre-spawn bracket; a throw there is shutdown! + DeviceCrash by name.
V37 Sketch: loop is spawned in try; catch reports DeviceCrash(e) to entry; sim continues, device absent (§12.4(6)).
V38 Sketch: finally runs shutdown! on any exit path; no dead-marking; task_state shows the end; claims stay (§11.3).
V39 BOLD: shutdown! must tolerate a partially initialized device [D-138].
V40 The release guarantee holds on the one path outside the wrapper too.
V41 The initialization step (§12.4) brackets each init! [D-138].
V42 A device that threw half-way through acquisition goes straight to shutdown!, so nothing opened leaks.
V43 The obligation is "close only what is open".
V44 Same defensiveness shutdown! owes the crash path, where a loop body may die at any point.
V45 init! is not asked to clean up after itself.
V46 The bracket does once for every device what would otherwise be duplicated in each and enforced in none.
V47 BOLD: The same tolerance covers a repeated call [D-268].
V48 The wrapper runs shutdown! once on every exit path.
V49 When an operator interrupt (Ctrl-C) reaches run! before its tail, run! releases each never-spawned device directly, advancing a cursor after each shutdown! returns, retrying from where an interrupt cut it [§12.4, D-268].
V50 An interrupt between a shutdown!'s return and the cursor advance repeats that call rather than leak, so each such interrupt adds one call.
V51 A shutdown! closing only what is open is idempotent by construction; a repeated call costs nothing and is never reported.
V52 BOLD: The tolerance also covers a call with no init! before it [D-268].
V53 The init step lists each device for release before its init! begins, so no interrupt can leave an initialized device unlisted [§12.4, D-268].
V54 An interrupt between listing and init! therefore releases a device that opened nothing.
V55 Such a shutdown! does nothing there, and the call is never reported.
V56 The wrapper makes one discrimination.
V57 BOLD: An InterruptException is never a DeviceCrash [D-132].
V58 The operator interrupt is a control-plane stop, not a failure [D-132].
V59 The wrapper forwards the stop and lets the body leave through running(handle) [§12.4(4)].
V60 No crash report, and no should_abort consultation, since a stop is already requested.
V61 One device contract means author-owned loop bodies.
V62 A framework-owned hook loop would have to ask each device what it waits on, the rejected taxonomy resurrected as a trait [D-102].
V63 Under the author-owned body every wait structure is ordinary user code from handle primitives.
V64 T16000M is FlightCore's type for the Thrustmaster T16000M joystick.
V65 Sketches map data through the binding's map_input and map_output, described below.
V66 Sketch T16000M: timer-driven, full write-set; sleep then stage!(handle, map_input(...)...).
V67 Sketch UDPInput: source-driven; recv blocks; unblock! closes the socket; is_eot → return (voluntary exit); datum error → report! MalformedDatum; else rethrow → wrapper → DeviceCrash.
V68 Sketch Telemetry: boundary-driven output; wait_next_snapshot returns on stop (§12.3); send map_output(gather(...)).
V69 A bidirectional peer composes both halves itself with an inner reader task in its own domain, rather than a select engine in the framework.
V70 Two idioms are author obligations the framework can only teach and diagnose, never force [Appendix A, D-102].
V71 The idioms: loop on running(handle), and make blocking calls interruptible (unblock! or timeouts).
V72 A forgotten predicate check surfaces as DeviceJoinTimeout with the device's name.
V73 A stall surfaces as a stale heartbeat [§12.2].
V74 Liveness timestamps ride inside handle primitives, stored in the device's diagnostic cell [§11.8]; the framework observes activity without owning the loop.
V75 BOLD: should_close dissolves [D-102].
V76 A window ✕ or peer EOT is the loop body returning.
V77 The wrapper's exit path releases OS resources and consults should_abort.
V78 Nothing marks the device dead beyond its record; task ended, task_state says so at next publication, heartbeat goes stale [§12.2].
V79 Claims (sets of faces a device may write) and roster entry persist to run end (the freeze) [§11.3, D-106].
V80 This is §12.4(6)'s case.
V81 The GUI implements the same authoring contract.
V82 BOLD: should_abort is an attach! keyword, defaulting to false [D-138].
V83 It is per-attachment, never a device property.
V84 Same joystick advisory in one deployment, decisive in another.
V85 should_abort clear: departure reported, run continues without it.
V86 should_abort set: departure also requests a sim stop [§12.4].
V87 A departure is the loop body returning, a crash, or a failed init!.
V88 A HIL rig attaches its plant interface with it set, since a run without it is meaningless.
V89 A datum unmappable for environmental reasons (truncated datagram, malformed JSON, out-of-range field) is a bad datum, tolerated in the loop body [D-105].
V90 The body catches it, stages nothing, calls report!(handle, MalformedDatum(cause)) and continues.
V91 Tolerance is bounded by the device's diagnostic cell (ring and suppressed counts §11.8; stream §13.2), and what it records is visible next to a live heartbeat.
V92 Any other exception propagates; wrapper turns it into DeviceCrash [§12.4].
V93 Classification is the author's because only they know their parser.
V94 FlightCore's InputMappingError docstring assigned it the same way.
V95 Under author-owned loop no framework per-iteration catch site exists; framework's contribution is the diagnostic channel, not the catch.
V96 A marked exception type is not provided [D-105].
V97 report! writes device-attributed runtime warnings into that device's diagnostic cell, the single-writer entry point into the runtime warning stream [§13.2, §11.8, D-160], and nothing more.
V98 It is not a general user-diagnostics channel.
V99 Tolerating everything hides bugs as "device attached, nothing happens".
V100 Tolerating nothing kills a live telemetry link on its first truncated datagram, and since tasks are per-run artifacts [D-093], for the rest of the run.
