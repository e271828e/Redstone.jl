old: ### 12.4 Shutdown protocol
tag: F

old: A run ends when its time is up, when someone stops it, or when the model itself says so.
tag: F

old: Whatever the cause, the same work has to happen.
tag: F

old: The loop has to stop on a boundary rather than mid-frame, every device task has to be woken out of whatever it was blocked on, and every resource acquired for the run has to be released before `run!` returns.
new: The loop has to stop on a boundary (a published consistency point). The task each device (any attached participant in the periphery) runs on has to be woken out of whatever it was blocked on. Every resource acquired for the run has to be released before `run!` returns.
tag: R
ruling: R10
note: F4 drops "rather than mid-frame"; split into three sentences for the glosses of boundary and device, the device link moved here from step (1), its first use

old: This section specifies that sequence, which it calls the tail throughout.
tag: F

old: It also specifies the two things that bracket the tail.
tag: F

old: One is the pre-spawn initialization at the top of a run, which is a step of this same protocol.
tag: F

old: The other is the operator interrupt, which enters the tail rather than bypassing it.
new: The other is the operator interrupt (Ctrl-C in an interactive session), which enters the tail rather than bypassing it.
tag: F
note: the operator interrupt's link moves here from step (1), its first use, with its gloss

old: #### The tail: the ordered sequence every stop takes
tag: F

old: Rule. Steps (1) through (5) below run in that order on every stop, whatever initiated it.
new: Steps (1) through (5) below run in that order on every stop, whatever initiated it (D-030).
tag: R
ruling: R3
newcites: D-030
note: the label goes; D-030's headline clause bold with its citation, D-030 Position "Shutdown: complete the boundary → publish final snapshot → sticky stopped status → wake framework waits → unblock! hook → join with named timeout"

old: Steps (6) and (7) specify what happens when a device task or the loop itself ends first.
tag: F

old: 1. Initiation. Three events start a shutdown: `t_end` is reached, a control-plane stop is issued, or a stop request the advance honours reads `STOP_REQUESTED` in the just-published snapshot.
new: 1. Initiation. Three events start a shutdown. Either `t_end` is reached, or a stop is issued on the control plane (the separate atomic surface carrying pause, pace and stop), or a stop request the advance honours reads `STOP_REQUESTED` in the just-published snapshot (D-316).
tag: R
ruling: R4
newcites: D-316
note: the step label unbolded; the colon becomes a sentence break; D-316 added (Position: every request ends the run at the first publication where it holds, unless the advance ignores it); control plane linked and glossed here, its first use (verifier); the stop-request and snapshot glosses follow in one sentence

old: The stop's issuers are the GUI, a device handle, code, or an operator interrupt (Ctrl-C, treated below).
new: The control-plane stop's issuers are a front end (D-310), a device handle, code, or an operator interrupt (Ctrl-C, treated below).
tag: R
ruling: R2
newcites: D-310
note: "the GUI" becomes "a front end", D-310 cited once in the section, here; "The stop's" becomes "The control-plane stop's", since the stop-request gloss now sits between it and its antecedent

old: The third event is model-detected termination (§13.5).
tag: F

old: The loop always completes the current boundary sequence and never stops mid-frame.
new: The loop never stops mid-boundary. It always completes the boundary sequence in progress, which a stop at `t` (the localized event time) places inside a frame, one iteration of the loop.
tag: R
ruling: R10
note: F4; `t*` linked and glossed at its first use (verifier); frame linked at this first use, its gloss an appositive (chapter pass P1-11)

old: It then publishes the final snapshot.
new: The loop then publishes the final snapshot.
tag: F
note: "It" spelled "The loop", since the frame's gloss now ends the sentence before it

old: Only then does it set the sticky stopped status.
tag: F

old: 2. Wake all framework waits.
tag: R
ruling: R4
note: step label unbolded

old: The waits are the next-snapshot wait and the pause.
new: The waits are the next-snapshot wait (`wait_next_snapshot(handle)`) and the pause.
tag: F
note: next-snapshot wait linked and glossed at its first use

old: Each waiter observes the stopped status and unwinds.
tag: F

old: A stop issued while paused therefore works.
tag: F

old: 3. Unblock device-specific blocking calls.
tag: R
ruling: R4

old: The hook is `unblock!(device)`, default no-op.
tag: F

old: A network input's override closes its own socket, which raises in the blocked task.
tag: F

old: The framework wrapper catches that raise and treats it as shutdown.
tag: F

old: This demotes FlightCore's EOT convention from essential shutdown mechanism to an optional wire-protocol courtesy between remote peers.
tag: F
note: R6 keeps "FlightCore's"

old: 4. Loop bodies exit.
tag: R
ruling: R4

old: The exit is the author's own `while running(handle)` loop, the authoring contract of §11.6.
tag: F

old: That authoring contract teaches two obligations: the predicate check and interruptible blocking.
new: That authoring contract teaches two obligations, the predicate check and interruptible blocking (D-373).
tag: C
newcites: D-373
note: D-373 bullet 2, "The two author obligations, the running(handle) predicate and interruptible blocking, are taught"; the colon becomes a comma

old: Steps (2) and (3) are what make every blocking point interruptible.
new: Steps (2) and (3) are the framework's half. They wake its own waits and call each device's `unblock!`.
tag: R
ruling: R10
note: F12

old: The wrapper's `finally shutdown!(device)` is guaranteed on every exit path.
tag: F

old: 5. Join under the `join_timeout` cap.
tag: R
ruling: R4

old: The cap lives on `Control`, the tail's own owner (§12.1, D-256).
tag: F

old: It is a keyword of the `Simulation` constructor, a positive real in seconds of wall clock, defaulting to 5 (Appendix B).
tag: F

added: The constructor refuses any other value as `ArgumentInvalid`.

old: A device task exceeding it is reported by name, through the §12.2 heartbeat.
new: A device task exceeding the cap is reported by name in a `DeviceJoinTimeout` diagnostic (Appendix C).
tag: R
ruling: R10
newcites: Appendix C
note: F5 drops the heartbeat clause and names the diagnostic; "it" becomes "the cap" after the inserted ArgumentInvalid sentence (F15)

old: It is then abandoned with a `DeviceJoinTimeout` diagnostic (Appendix C) rather than left to hang `run!`.
new: It is then abandoned rather than left to hang `run!`.
tag: R
ruling: R10
newcites: Appendix C
note: F5; the kind and its Appendix C pointer move into the sentence before

old: The diagnostic is written to the loop's own cell, collected by the run's-end sweep into the termination record and presented through the logging backend, with the terminal snapshot preceding the join (D-201, D-203).
new: The diagnostic is written to the loop's own diagnostic cell, a writer's own holding place for runtime diagnostics and liveness (D-203). The run's-end sweep, the loop's last pass over every diagnostic cell, collects the diagnostic into the termination record (the stopped-sim value naming how the run ended). The logging backend presents the diagnostic, with the terminal snapshot preceding the join (D-201, D-203).
tag: R
ruling: R3
note: D-203 bullet 4's headline clause bold (row 111); bare "cell" becomes "diagnostic cell", whose link and gloss move here from old 9024, its new first use; termination record glossed; split into three sentences, "it" spelled "the diagnostic" twice (verifier); the cell takes §12.2's gloss as an appositive, off the citation (chapter pass P1-14, P1-20); the run's-end sweep is glossed from D-201, "the loop sweeps every cell once more at the run's end" (chapter pass P1-13)

old: 6. Device-initiated paths.
tag: R
ruling: R4

old: A device exits voluntarily when its loop body returns, at a window ✕ or a peer EOT.
tag: F
note: R2 keeps "window ✕"

old: No `should_close` hook exists (§11.6).
tag: F

old: With `should_abort` set, the wrapper's exit path also requests a sim stop.
new: With `should_abort` (the per-attachment failure policy, an `attach!` keyword) set, the wrapper's exit path also requests a sim stop.
tag: F
note: `should_abort` linked and glossed at its first use in the section, the glossary's words (chapter pass P1-19)

added: (the per-attachment failure policy, an `attach!` keyword)

old: Otherwise the sim continues with the device's task absent.
tag: F

old: Its cell stops filling, and the loop is structurally indifferent.
new: Its staging cell (where the device's pending write batch waits between drains) stops filling, and the loop is structurally indifferent.
tag: F
note: the link always pointed at #g-staging-cell; "staging" spelled out since bare cell is reserved, with its gloss

old: Its roster entry and its claims persist to run end, because §11.3 freezes the roster for the run and death is not detach.
tag: F

added: The roster is the list of attached device entries, and a claim is the set of faces a device may write.

old: The orphaned root inputs hold their last-drained values, visibly (§11.7).
new: The orphaned root inputs (the root component's own input faces) hold their last-drained values, visibly (§11.7).
tag: F

old: A crashing device task is caught by the framework wrapper and follows the same path, logged with the device's name (`DeviceCrash`, Appendix C).
tag: F

old: 7. Loop-side failure.
tag: R
ruling: R4

old: A failure on the loop's own side runs steps (1) through (5) from the catch path, specified in §13.6.
new: A failure on the loop's own side runs steps (1) through (5) from the catch path (D-030). §13.6 specifies that path,
tag: C
newcites: D-030 §13.6
note: D-030 Position, "loop failure runs the same protocol from the catch path"

old: The failed boundary is discarded and the previous snapshot is promoted to final.
new: which discards the failed boundary and promotes the previous snapshot to final.
tag: M
note: survey 1's M11, trimmed to a clause on the §13.6 pointer; §13.6 bolds it

old: FlightCore's `SimulationTermination` catch path was the precedent, though the exception-based termination idiom itself has no place here (§13.5).
new: FlightCore's `SimulationTermination` catch path was the precedent. The exception-based termination idiom itself has no place here (§13.5, D-060).
tag: C
newcites: §13.5 D-060
note: split at "though"; D-060 Position "no SimulationTermination exception type", which stands (D-316's Supersedes line)

old: Devices therefore unwind cleanly regardless of who died.
tag: F

old: The ordered part, in one line:
tag: F

old: > (1) stop observed → current boundary completed → final snapshot published > → sticky `stopped` set → (2) framework waits woken → (3) `unblock!` > per device → (4) loop bodies return, each through its wrapper's > `finally shutdown!` → (5) join under the `join_timeout` cap → `run!` > returns
tag: R
ruling: R4
note: the chart verbatim, its five step numbers unbolded

old: Why the final snapshot goes out before the status is set.
new: The final snapshot goes out before the status is set.
tag: X
note: the labelled lead-in becomes a plain topic sentence

old: Publishing first guarantees that output devices can flush the true final state.
tag: F

old: The status in that terminal snapshot carries the run's cumulative diagnostic counters (§11.8), the warning account of a run nobody watched, complete up to that snapshot's own frame top.
tag: F

old: What the tail itself produces comes later by construction.
new: It comes later by construction.
tag: X
note: the subject moves into the bold sentence before it, so the bold names its subject (verifier)

old: It is folded into the termination record and presented through the logging backend, never published (D-201, D-203).
new: What the tail itself produces is folded into the termination record and presented through the logging backend, never published (D-201, D-203).
tag: R
ruling: R3
note: D-201's headline bold here (row 125), its subject spelled out and placed before the consequence sentence (verifier)

old: Rule. That terminal snapshot is retained in the log unconditionally, under any `log_every` and any `log_max` (§11.2).
new: That terminal snapshot is retained in the log (the retained sequence of published snapshots) unconditionally, under any `log_every` and any `log_max` (§11.2, D-368).
tag: R
ruling: R3
newcites: §11.2 D-368
note: row 126 plain with its citation, D-368 bullet 5; log linked and glossed

old: `t_end` lands on the grid.
tag: M
note: survey 1's M7 moves the t_end paragraph up to follow the chart; the bold lead-in becomes a plain topic sentence

old: The run ends at the first grid boundary whose time reaches or exceeds `t_end`.
new: The run ends at the first grid boundary whose time reaches or exceeds `t_end` (D-133).
tag: R
ruling: R3
newcites: D-133
note: M7; D-133 Position, "t_end's landing rule ...: the run ends at the first grid boundary whose time reaches or exceeds t_end", bold

old: Whole frames only, never a shortened final step, which grid integrity forbids (§10.4; `tₖ = t₀ + k·h`, indexed and never accumulated).
new: The run takes whole frames only, never a shortened final step, which grid integrity forbids (§10.4). Each grid time is indexed, `tₖ = t₀ + k·h`, and never accumulated (§10.4).
tag: M
note: M7; the parenthetical with its semicolon becomes its own sentence

old: The final boundary may therefore overshoot `t_end` by up to `h`.
tag: M
note: M7

old: The termination record carries the actual final `t` (§13.5).
tag: M
note: M7

old: This is the `t_plus` spelling (§12.6) applied to the run's own clock.
tag: M
note: M7; R5 keeps the pointer, §12.6 holds the spelling

old: The run takes whole frames until the boundary time first covers the duration.
new: The run ends at the first grid boundary whose time reaches or exceeds `t_end` (D-133). The run takes whole frames only
newcites: D-133
tag: M
note: M7; the sentence goes as a third statement of the landing, held by the bold and the whole-frames sentence, and verbatim §12.6's `t_plus` rule, which the pointer before it names (chapter pass P1-24)

old: The two termination sources differ in kind.
new: The two termination sources differ in nature.
tag: M
note: M7; the bold lead-in becomes a plain topic sentence; "kind" reworded since the word is reserved

old: `t_end` is a grid fact, checked against boundary times on the grid.
tag: M
note: M7

old: Stop requests are checked at every published boundary, `t` included (§13.5).
tag: M
note: M7

old: Why the default is five seconds. It is generous for GUI window teardown and socket closes.
new: The `join_timeout` default of five seconds is generous for front-end window teardown and socket closes.
tag: R
ruling: R2
note: "GUI window teardown" becomes "front-end window teardown"; the labelled lead-in folds into the topic sentence; the default is named, its step (5) mention far back (chapter pass P1-21)

old: It is short enough that an abandoned join reads as a diagnosed timeout rather than a hang.
tag: F

old: The cap is deployment, not implementation.
new: The cap is a per-simulation setting, not an implementation constant (D-198).
tag: R
ruling: R10
newcites: D-198
note: F6; the bold lead-in becomes D-198's headline clause with its citation, D-198 Position "The shutdown tail's join cap becomes join_timeout, a Simulation ... keyword"

old: That is the disposition §10.4 gives its own two constants, extended here to an operational one (D-198).
new: That is the disposition §10.4 gives its own two constants, extended here to an operational one.
newcites: §10.4
tag: F
note: D-198, cited at the bold the sentence before, is not repeated (chapter pass P1-23)

old: Deployment contexts legitimately differ in patience.
new: Usage contexts legitimately differ in patience.
tag: F
note: at a sentence's start "Deployment" read as the type, two sentences before `Deployment` (chapter pass P1-22)

old: An unattended sweep wants to fail fast, a test battery exercising the abandonment path faster still, while a device with slow teardown may warrant more.
new: A series of runs nobody watches wants to fail fast, a test battery exercising the abandonment path faster still, while a device with slow teardown may warrant more.
tag: F
note: "sweep" names one pass through the execution order in this section; "nobody watches", not "unattended runs", since that term's link and gloss come later in the section (chapter pass P1-22)

old: The cap is not trajectory-determining, because the trajectory has ended at the final snapshot before any join begins.
tag: F

old: So, like `log_max` (§11.2), it lives on `Control` rather than the deployment, and replay neither records nor compares it (§11.5, §12.7).
new: So replay (the ordinary loop with the drain reading recorded batches) neither records nor compares the cap (§11.5, §12.7), just as for `log_max` (§11.2). The cap therefore lives on `Control`, not on the `Deployment` (D-256).
tag: R
ruling: R10
newcites: §11.5 §12.7 §11.2 D-256
note: F6; the likeness to log_max scoped to replay; replay linked and glossed; "it" spelled "the cap" twice, since the sentence split moved its antecedent

old: What survives the tail.
new: #### What survives the tail
tag: X
note: the bold lead-in becomes a #### topic label over the two paragraphs it opened

old: After (5) the task set is empty, device tasks being per-run artifacts (§11.1), and `shutdown!` has released each device's OS resources.
new: After (5) the task set is empty, since device tasks are per-run artifacts (§11.1, D-093). `shutdown!` has also released each device's OS resources.
tag: C
newcites: §11.1 D-093
note: D-093 Position, "Device tasks are per-run artifacts"; split in two

old: What survives a stop is the roster entry: binding, claims, stable device id (§11.3).
new: What survives a stop is the roster entry, with its binding, claims and stable device id (§11.3).
tag: F

old: Never a task, never a live resource.
new: A task never survives, and neither does a live resource.
tag: F

old: That holds for a device whose task died mid-run too, its entry being indistinguishable at this point from any other's.
new: That holds for a device whose task died mid-run too. Its roster entry is indistinguishable at this point from any other's.
tag: F
note: bare "entry" becomes "roster entry"

old: `stopped` is where `detach!` removes an entry and releases its claims.
new: Once stopped, `detach!` can remove a roster entry and release its claims (D-106).
tag: R
ruling: R10
newcites: D-106
note: F20; D-106 Position, attach!/detach! "legal in built/initialized/stopped"

old: The next run re-acquires everything.
tag: F
note: the bold lead-in becomes a plain topic sentence

old: The next `run!` re-runs device `init!`, since resource acquisition is per-run.
new: The next `run!` re-runs device `init!`, since resource acquisition is per-run (D-093).
tag: C
newcites: D-093
note: D-093 Position, "after per-run device init! (resource acquisition per run ...)"

old: FlightCore's create-a-new-socket-each-`init!` in network.jl is the precedent.
new: The precedent is FlightCore's network device, `network.jl`, which created a new socket at each `init!`.
tag: R
ruling: R6

old: It also spawns fresh tasks against the §12.3 counter, which is never re-armed.
new: The next `run!` also spawns fresh tasks against the §12.3 counter, which is never re-armed.
tag: F
note: "It" repeated as "The next run!", since the precedent sentence now sits between

old: Each task reads its `last_seen` off the counter at spawn.
tag: F

old: While stopped there are no device tasks at all, so voluntary exit and the §12.2 liveness heartbeat are run-scoped observables.
tag: F

old: A device unplugged while stopped surfaces as the next run's `init!` failure, disposed of by the initialization bracket below.
tag: F

old: #### Initialization: the pre-spawn bracket
tag: F

old: Initialization is a step of this protocol, taken at the top of a run. Rule.
new: Initialization is a step of this protocol, taken at the top of a run (D-138).
tag: R
ruling: R3
newcites: D-138
note: survey 1's M9; row 145 merges into row 146 as one ruling, bold once with D-138 (Position: "an explicit step of the §12.4 protocol, taken at the top of a run")

old: Before any task is spawned, the loop calls `init!` once per roster entry, in attachment order, on the calling task.
new: Before any task is spawned, the loop calls `init!` once per roster entry, in attachment order, on the calling task (the task that invoked `run!`).
tag: F
note: calling task linked and glossed

old: Each call sits in its own bracket.
tag: F

old: `for entry in roster # attachment order, calling task push!(live, entry) # listed for release before `init!` begins try init!(entry.device) catch e shutdown!(entry.device) # release, unconditionally (§11.6) pop!(live) # released, so unlisted if e isa InterruptException # the operator's stop, never a crash (below) stop!(control, :interrupt) else report!(entry, DeviceCrash(e)) # pre-spawn: the entry is the address, no handle yet entry.should_abort && stop!(control) end # no dead-marking: no task is spawned (§12.2) end end`
new: `for entry in roster # attachment order, calling task push!(live, entry) # listed for release before `init!` begins try init!(entry.device) catch e shutdown!(entry.device) # release, unconditionally (§11.6) pop!(live) # released, so unlisted if e isa InterruptException # the operator's stop, never a crash (below) stop!(control, :interrupt) else report!(entry, DeviceCrash(e, entry.should_abort)) # pre-spawn: the entry is the address, no task holds a handle yet entry.should_abort && stop!(entry.handle) end # no dead-marking: no task is spawned (§12.2) end end`
tag: R
ruling: R10, R19
note: F24, the two ruled code edits; R19, the comment "no handle yet" becomes "no task holds a handle yet"; nothing else in the block changes

old: Why the bracket. It is what makes "guaranteed on every exit path" (§11.6) true of the path outside that wrapper.
new: The bracket is what makes "guaranteed on every exit path" (§11.6) true of the path outside that wrapper.
tag: X
note: the labelled lead-in folds into the sentence's subject

old: A device that throws half-way through acquisition is handed back to `shutdown!` right there, so its partially acquired OS resources are released rather than leaked.
new: A device that throws half-way through acquisition is handed back to `shutdown!` right there, so its partially acquired OS resources are released rather than leaked (D-138).
tag: C
newcites: D-138
note: D-138 Position, "on a throw the framework calls shutdown!(dev) on the failing device right there"

old: That is exactly why `shutdown!` owes tolerance of a partially initialized device, a rule §11.6 teaches.
tag: F

old: The entry is listed for release before its `init!` begins (D-268).
new: The roster entry is listed for release before its `init!` begins (D-268).
tag: R
ruling: R3
note: row 151 plain with its citation, §11.6 bolds it; bare "entry" becomes "roster entry"

old: The bracket unlists it once its own `shutdown!` has returned.
tag: F

old: An operator interrupt that escapes the bracket therefore finds listed every device whose `init!` began and that the bracket has not released, and the run releases each before it ends.
tag: F

old: A device listed and not yet initialized can be released having opened nothing, which `shutdown!` tolerates (§11.6).
tag: F

old: The report is the ordinary `DeviceCrash`, not a kind of its own (Appendix C).
new: The report is the ordinary `DeviceCrash`, not a kind of its own (D-138, Appendix C).
tag: C
newcites: D-138 Appendix C
note: D-138 Rationale, "No new diagnostic kind"; Rationale-only, the bold kept

old: Its payload already carries everything an init-time failure has to say: the device id, the cause exception, and whether `should_abort` was set.
new: Its payload (the structured data a diagnostic carries beside its kind) already carries the cause exception and whether `should_abort` was set. The diagnostic cell it is written to names the device. That is everything an init-time failure has to say.
tag: R
ruling: R10
note: F11; the colon list becomes three sentences

old: The name is honest.
tag: F

old: A device that cannot acquire its resources has crashed before it lived.
tag: F

old: Rule. The report is written through the ordinary `report!(address, diagnostic)` entry point, addressed by the roster entry rather than by a handle.
new: The report is written through the ordinary `report!(address, diagnostic)` entry point, addressed by the roster entry rather than by a handle (D-189).
tag: C
newcites: D-189
note: the label goes; D-189 Position, "the first argument is the cell address ... the roster entry in §12.4's pre-spawn init bracket, where no handle exists yet", bold

old: There is no device task to hold a handle before the spawn.
tag: F

old: The address supplies the device identity either way, which is why no call passes a device id (§11.8).
tag: F

old: Rule. No task is spawned for a failed device, so it is dead from boundary zero (the initialization boundary: the ordinary macro-sequence with an empty integrate).
new: No task is spawned for a failed device, so it is dead from the run's first frame top (D-138).
tag: R
ruling: R8
newcites: D-138
note: the label goes and the sentence is plain, one ruling with the bracket's bold (D-138 Position, "no task being spawned"); the boundary-zero link and gloss move to its next use, in the forced-throw paragraph

old: That needs no machinery.
tag: F

old: Its diagnostic cell (the single-writer cell each writer owns for diagnostics and heartbeat) never receives a heartbeat timestamp. The cell therefore reads stale against the §12.2 threshold from the first frame (§11.8).
new: Its `task_state` reads `:done` from the first publication (§12.2). A device that never ran never beat, so its diagnostic cell also reads stale against the §12.2 threshold from the start (D-138).
tag: R
ruling: R10
newcites: §12.2 D-138
note: F10; the §11.8 pointer drops and D-138 is cited; the diagnostic cell's link and gloss moved to step (5)

old: Rule. The claims of a failed device persist to run end.
new: The claims of a failed device persist to run end (D-138).
tag: C
newcites: D-138
note: the label goes; D-138 Rationale, "its claims persist to run end"; plain, since §11.3 bolds death-is-not-detach (D-374)

old: This is the death-is-not-detach disposition (§11.3), applied one step earlier than (6)'s.
tag: F

old: The roster is frozen for the run, and the orphaned root inputs hold their initial values, well-defined by root-input totality (§14.6; every root input must hold a value).
new: The roster is frozen for the run, and the orphaned root inputs hold the values the run started with. Those values are well-defined by root-input totality, the rule that every root input must hold a value (§14.6).
tag: R
ruling: R8
note: "their initial values" becomes "the values the run started with"; the semicolon parenthetical splits into an appositive gloss and the citation (chapter pass P1-20)

old: An orphan of (6) holds a last drained batch instead.
tag: F

old: The run's disposition splits on `should_abort`, uniformly with (6).
new: The run's disposition splits on `should_abort`, uniformly with (6) (D-138).
tag: C
newcites: D-138
note: D-138 Rationale, "Run disposition splits on should_abort, uniformly with (6)"; Rationale-only, the bold kept

old: With the flag clear, which is the default (§11.6), the remaining entries initialize, the run starts, and the sim runs with that device absent from frame zero.
new: With the flag clear, which is the default (§11.6), the remaining roster entries initialize, the run starts, and the sim runs with that device absent from the run's first frame.
tag: R
ruling: R8

old: That is (6)'s "the sim continues with the device's task absent", shifted to `t₀`.
new: That is (6)'s "the sim continues with the device's task absent", shifted to the run's start.
tag: R
ruling: R8

old: With the flag set, the failure requests a control-plane stop, and that stop is simply already pending when the run reaches boundary zero.
new: With the flag set, the failure requests a control-plane stop, and that stop is simply already pending at the run's first frame top.
tag: R
ruling: R8

old: This protocol already has that path.
new: This protocol already has that path,
tag: F
note: moved after the mechanism and joined to its conclusion (chapter pass P1-31)

old: The boundary-zero check (§13.5) ends a run at `t₀` with that snapshot final, integrating nothing.
new: The loop reads it there, before any frame, so the run advances no frame.
tag: R
ruling: R8
note: the §13.5 boundary-zero check drops as the mechanism; the stop pending at the run's first frame top, read before any frame, replaces it (src/sim.jl, the frame-top read of the stop issuer); §13.5 stays cited later in the paragraph; "that stop at the frame top" becomes "it there", the sentence now following the one that names both (chapter pass P1-31)

old: No new exit protocol is needed, therefore.
new: so no new exit protocol is needed.
tag: F

old: The remaining entries still initialize, every rostered device getting its `init!`/`shutdown!` pair uniformly.
new: The remaining roster entries still initialize, every rostered device getting its `init!`/`shutdown!` pair uniformly.
tag: F

old: The run publishes boundary zero.
where: units/B/deleted.md
tag: R
ruling: R8

old: It ends `stopped` at `t₀` through this same tail, with the termination record naming the source (§13.5).
new: The run ends `stopped` where it started, through this same tail, with its termination record naming the device (§13.5).
tag: R
ruling: R8

old: What the operator is left with is an ordinary stopped simulation: a terminal snapshot, with the failure named in its diagnostic account.
new: What the operator is left with is an ordinary stopped simulation, whose terminal snapshot is the one the run started from and whose termination record's tail residue (the diagnostics the run's-end sweep folds in) holds the `DeviceCrash`.
tag: R
ruling: R8
note: tail residue glossed from §13.5, "the post-account diagnostics the run's-end sweep folds in", with no citation so the sentence still ends on the `DeviceCrash` before the next "It" (chapter pass P1-13); the run publishes nothing after the failure; the report reaches the record's residue through the run's-end sweep (verifier, src/sim.jl 1183–1185, 1420–1421, 1281); the simulation stays the sentence's subject so the next "It" keeps its antecedent

old: It is fully serviceable by §14 and resumable by the next `run!` (§12.6) once the device is plugged back in.
tag: R
ruling: R7
note: stays as written (E1)

old: Topology is derived after initialization, not from the roster alone (§11.1).
new: Topology is derived after initialization, not from the roster alone (§11.1).
where: units/B/deleted.md
tag: R
ruling: R5

old: A device whose `init!` failed spawns no task.
new: No task is spawned for a failed device
tag: R
ruling: R5
note: the topology paragraph goes; row 158 keeps this

old: The run proceeds without it, or ends at `t₀` when the device attached with `should_abort = true`.
new: The run's disposition splits on `should_abort`, uniformly with (6)
tag: R
ruling: R5
note: the topology paragraph goes; rows 163–164 keep both arms, the stop arm restated off t₀ by R8

old: Rule. An `InterruptException` inside a device's `init!` is the operator's stop, not that device's crash (D-268).
new: An `InterruptException` inside a device's `init!` is the operator's stop, not that device's crash (D-268).
tag: X
note: the label goes; the bold keeps its citation

old: The bracket releases the device through `shutdown!` as for any throw and spawns no task for it.
tag: F

old: In place of the `DeviceCrash` report it sets the `:interrupt` stop through the stop word, so the run's `should_abort` split above does not arise.
new: In place of the `DeviceCrash` report it sets the `:interrupt` stop through the stop word (the control plane's stop command, one atomic word holding its issuer). The run's `should_abort` split above therefore does not arise.
tag: R
ruling: R15
note: the stop word glossed at its first use in the section; split for the gloss, "so" kept as "therefore"

old: The remaining entries still initialize, and the run ends at its first frame top with zero frames advanced, through the pending-stop path above.
new: The remaining roster entries still initialize, and the run ends at its first frame top with zero frames advanced, through the pending-stop path above.
tag: F

old: The device wrapper makes the same discrimination for a raise inside a loop body (§11.6).
tag: F

old: #### The operator interrupt
tag: F

old: The operator interrupt is a stop, not a failure.
new: The operator interrupt is a stop, not a failure (D-132).
tag: R
ruling: R3
newcites: D-132
note: D-132 Position's first sentence, bold with its citation

old: Ctrl-C in an interactive session is a control-plane stop command issued by hand.
tag: F

old: The run completes the current boundary, publishes the final snapshot, takes this tail like any other stop, and ends `stopped`.
tag: F

old: The result is boundary-consistent.
tag: F

old: It is fully serviceable by the §14 stopped-sim services and resumable by the next `run!` (§12.6).
tag: R
ruling: R7
note: stays as written (E1)

old: The interrupt is the escape from a run nothing else can end. Such a run is deviceless, and it declares no stop of its own.
new: The interrupt is the escape from a run nothing else ends, and the deviceless run has no other.
tag: R
ruling: R10
note: F13

old: A run with no finite `t_end` and no honoured stop request is the configuration `UnboundedRun` names (Appendix C).
tag: F

old: The interrupt needs no entry point of its own.
new: The interrupt needs no entry point of its own (D-132).
tag: C
newcites: D-132
note: R6, the verdict keeps its citation; D-132 Rejected, "A public interrupt! entry point: redundant: the control plane already carries the stop"

old: The stop already rides on the control plane, the separate atomic surface carrying pause, pace and stop (§12.1).
new: The stop already rides on the control plane (§12.1).
tag: F
note: the appositive repeated step (1)'s gloss in the same section (chapter pass P1-12)

old: The exceptions-are-abnormal doctrine (§13) is untouched.
new: The exceptions-are-abnormal doctrine (§13.5, D-060) is untouched.
tag: R
ruling: R10
newcites: §13.5 D-060
note: F23; D-060 Position, "exceptions from model code always abnormal", which stands

old: That doctrine is about model code, while this is the one exception whose meaning the framework knows.
tag: F

old: Rule. Masking across the boundary is normative, not an implementation hint.
new: Masking across the boundary is normative, not an implementation hint (D-132).
tag: C
newcites: D-132
note: the label goes; D-132 Rationale, "Boundary masking is normative, not an implementation hint"; Rationale-only, the bold kept

old: Why. An `InterruptException` is delivered asynchronously.
new: The reason is that an `InterruptException` is delivered asynchronously.
tag: X
note: the label becomes a plain connective

old: An interrupt landing mid-sweep would therefore destroy the boundary this protocol is built on completing, and would leave half-written stores (§13.6).
new: An interrupt landing in the middle of a sweep (one pass through the execution order) would therefore destroy the boundary this protocol is built on completing. It would also leave stores (the framework-owned homes of a component's state) half-written (§13.6).
tag: F
note: split for the glosses of sweep and store; "half-written" moves after the gloss, so gloss and citation do not touch (chapter pass P1-20)

old: That forces a choice between `stopped` with dirty stores and a terminal `errored`.
tag: F

old: The `stopped`-with-consistent-stores guarantee is exactly what the masking buys.
tag: F

old: The loop masks delivery across the boundary macro-sequence, using Julia's `disable_sigint`, a sigatomic counter increment that is negligible per frame.
tag: F

old: It takes the deferred raise at the unmask points: the frame top, where it already consults the control plane (§12.1), and inside its wait and pause blocks.
new: It takes the deferred raise at the unmask points. They are the frame top, where it already consults the control plane (§12.1), and points inside its wait and pause blocks.
tag: F
note: the colon becomes a sentence break

old: All of those points are boundary-consistent.
tag: F

old: Caught at one of them, the interrupt sets the control-plane stop and enters this tail.
tag: F

old: The catch site (§13.4) therefore never sees it.
new: The catch site (§13.4) therefore never sees a single interrupt.
tag: R
ruling: R10
note: F14

old: A deferred interrupt yields to the frame's own stop request (D-268).
tag: F

old: Stop requests are consulted at each publication and the stop word at the next frame top (§13.5), and the deferred raise lands between the two.
tag: F

old: Where the frame's publication found an honoured request holding, that request is the recorded source and the interrupt is satisfied by the run ending.
tag: F

old: Where none held, the interrupt sets the stop word and the source is `ControlRequestedStop(:interrupt)`.
tag: F

old: A frame that throws with an interrupt pending ends `errored` (D-268).
tag: F

old: The frame's own throw is the disposition (§13.4).
tag: F

old: The catch wraps the cause under the mask and consumes the pending interrupt on its way out, and the run takes the abnormal entry under that `StepError` (§13.6).
new: The catch wraps the cause under the mask and consumes the pending interrupt on its way out. The run then takes the abnormal shutdown entry under that `StepError` (§13.6).
tag: F
note: split in two; "abnormal entry" becomes "abnormal shutdown entry", since entry is never bare (verifier)

old: The alternative, `stopped` over a half-written boundary, is what the masking exists to prevent.
tag: F

old: The interrupt is satisfied by the run ending.
tag: F

old: An interrupt after a frame's throw does not displace it (D-268).
tag: F

old: `run!`, `replay!` and `step!` store the loop's throw before an interrupt can displace it, and the masked bookkeeping below builds the record from that store.
tag: F

old: The run therefore ends `errored` under its `StepError` wherever a later interrupt lands.
tag: F

old: An interrupt that cuts the handling of the throw itself propagates out of the call raw, and the disposition of the failure is skipped (§13.4).
tag: F

old: The record is still written and the lifecycle is still `errored`.
tag: F

old: Rule. The tail's bookkeeping is masked too (D-268).
new: The tail's bookkeeping is masked too (D-268).
tag: X
note: the label goes; the headline clause bold with its citation

old: After the joins, the run's-end sweep, the termination record and the terminal lifecycle state are written under the same mask.
tag: F

old: An interrupt landing there would otherwise abort the sequence half-way and leave the lifecycle `running`, every service refusing.
tag: F

old: A raise deferred to the end of that bookkeeping propagates out of `run!` raw, the simulation already terminal.
tag: F

old: A forced throw reaches the defensive arm (D-268).
tag: F

old: Julia stops deferring after repeated SIGINTs in a short window, warns that it is forcing the throw, and raises inside the mask.
tag: F

old: That is the one way the branch §13.4 keeps is reached.
tag: F

old: The arm abandons the frame unpublished and the run ends `stopped`, the source `ControlRequestedStop(:interrupt)`.
tag: F

old: The published record is consistent, since the frame published nothing.
new: What the run published is consistent, since the frame published nothing.
tag: F
note: "the record" bare means the termination record in this section (chapter pass P1-33)

old: The stores may hold mid-boundary values until the next `init!` or `restore!` resets them,
new: The stores may hold mid-boundary values until the next `init!`, `restore!` or `replay!` resets them,
tag: R
ruling: R10
note: F22

old: as after a throw inside boundary zero (§13.4).
new: as after a throw inside boundary zero, the initialization boundary, which runs the ordinary macro-sequence with an empty integrate (§13.4).
tag: F
note: the boundary-zero link and gloss move here from old 9021; the gloss's colon becomes a comma; one sentence, as in the old, so "such a run" keeps its antecedent (verifier); the gloss is an appositive clause, off the citation (chapter pass P1-20)

old: `checkpoint` refuses such a run, since the executor no longer rests where its last snapshot was published (§12.6).
new: `checkpoint` refuses such a run as `CheckpointMidFrame`, since the executor (the compiled form of the stage execution order) no longer rests where its last snapshot was published (§12.6).
tag: R
ruling: R10
note: F15 names the kind; executor linked and glossed

old: The trace is the reproduction (§12.7).
new: The trace (the primary record of a session) is the reproduction (§12.7).
tag: F
note: trace linked and glossed

old: A second interrupt during the tail collapses the remaining joins immediately.
new: A second interrupt during the tail collapses the remaining joins immediately (D-132).
tag: C
newcites: D-132
note: D-132 Rationale, "A second interrupt during the tail collapses the remaining device joins immediately"; the bold lead-in widens to its headline clause; Rationale-only

old: That is (5)'s abandonment path taken at once, with devices still reported by name (`DeviceJoinTimeout`).
tag: F

old: The run still ends `stopped`.
tag: F

old: Escalation shortens the tail, never reclassifies the run.
tag: F

old: Nor can a second interrupt repair (5)'s honest asymmetry, since nothing can abandon the task `run!` stands on.
where: units/B/deleted.md
tag: R
ruling: R10
note: F3

old: Interactive-session scope, stated plainly.
new: The interrupt's scope is the interactive session.
tag: M
note: survey 1's M10 moves the scope paragraph up, after the opening paragraphs of the interrupt; the labelled lead-in becomes a plain topic sentence, from D-132 Rationale "Scope is the interactive session"

old: Outside the REPL, Julia's default (`exit_on_sigint(true)`) kills the process on SIGINT before any of this machinery runs.
tag: M
note: M10

old: The framework flips nothing process-global.
new: The framework flips nothing process-global (D-132).
tag: M
newcites: D-132
note: M10; R6, the verdict keeps its citation, D-132 Rejected "Process-global exit_on_sigint(false) set by the framework"

old: Unattended runs, those with empty staging and no snapshot readers, rely on `t_end` and stop requests, as they already must.
tag: M
note: M10

added: (a published consistency point)

added: (any attached participant in the periphery)

added: (Ctrl-C in an interactive session)

added: (the separate atomic surface carrying pause, pace and stop)

added: A stop request is an output port of the framework enum `StopFlag`, and a snapshot is the immutable per-boundary publication.

added: (the localized event time)

added: , one iteration of the loop.

added: (`wait_next_snapshot(handle)`)

added: , a writer's own holding place for runtime diagnostics and liveness

added: , the loop's last pass over every diagnostic cell,

added: (the stopped-sim value naming how the run ended)

added: (where the device's pending write batch waits between drains)

added: (the root component's own input faces)

added: (the retained sequence of published snapshots)

added: (the ordinary loop with the drain reading recorded batches)

added: (the task that invoked `run!`)

added: (the structured data a diagnostic carries beside its kind)

added: , the rule that every root input must hold a value

added: (the control plane's stop command, one atomic word holding its issuer)

added: The reason is that

added: (one pass through the execution order)

added: (the framework-owned homes of a component's state)

added: , the initialization boundary, which runs the ordinary macro-sequence with an empty integrate

added: (the compiled form of the stage execution order)

added: (the primary record of a session)

added: (the diagnostics the run's-end sweep folds in)
