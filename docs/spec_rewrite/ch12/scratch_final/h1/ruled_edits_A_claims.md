# Unit A claims: chapter 12 heading and roadmap, §12.1, §12.2, §12.3.

old: ## 12. Runtime periphery: lifecycle and orchestration
tag: X

old: Where §11 fixes how data crosses the loop boundary, this chapter covers the machinery that drives the loop itself
new: This chapter specifies the machinery that drives the loop itself, taking the loop of §10 and the data plane of §11 as given.
tag: R
ruling: R1
newcites: §10 §11
note: context sentence in chapter 11's form; "the loop boundary" goes. The glossary links on control plane and replay move to §12.1 and §12.3.

old: the control plane and the scheduling primitives, the shutdown protocol, and the run lifecycle from `init!` through replay.
new: §12.1 covers the control plane; §12.2 loop scheduling, in turn its wait primitive, its yields, the thread budget and the liveness heartbeat; §12.3 the next-snapshot wait; §12.4 the shutdown protocol; §12.5 scripts and the mid-run mutation doctrine; §12.6 the run lifecycle from `init!`, and partial advance; and §12.7 replay, where the trace re-drives the ordinary loop.
tag: R
ruling: R1
newcites: §12.1 §12.2 §12.3 §12.4 §12.5 §12.6 §12.7
note: roadmap sentence; every word from the old opening or a section title (§12.2, §12.3, §12.5, §12.6, §12.7 titles); "the liveness heartbeat" is §12.2's fourth `####` label (chapter pass P1-25).

old: ### 12.1 Control plane
tag: X

old: Control is not staging, structurally.
new: It is not staging, structurally (D-022).
tag: R
ruling: R3
newcites: D-022
note: M1, now the context; row 19's bold goes since §11.1 bolds D-022; D-022's Position parenthetical carries it. The plane is named by apposition in the sentence before, which now opens the section (chapter pass P1-15).

added: , the control plane.

old: Staged writes apply at drains, and a paused loop drains nothing, so un-pause via staging would deadlock by construction.
new: Staged writes apply at drains (the frame-top swaps that apply staged device writes), and a paused loop drains nothing, so un-pause via staging would deadlock by construction.
tag: M
note: M1.

added: (the frame-top swaps that apply staged device writes)

old: Riding outside the drain/trace path is safe for determinism precisely because §10.7 put pacing outside the semantics.
new: Riding outside the path through the drain and the trace, the primary record of a session, is safe for determinism precisely because §10.7 put pacing (the pacer's wall-clock waits) outside the semantics (D-021).
tag: C
newcites: §10.7 D-021
note: M1; D-021's Position "Pacing outside the semantics".

added: (the pacer's wall-clock waits)

added: , the primary record of a session,

old: Control changes when frames execute, never what they compute, and stop merely truncates the trajectory.
new: Control changes when frames (iterations of the loop) execute, never what they compute, and stop merely truncates the trajectory.
tag: M
note: M1.

added: (iterations of the loop)

added: This section covers, in order, when the loop reads the plane, the stop and its issuer, the pause, pace and `margin`, and the fields of `Control`, the periphery's own type that holds the control plane (D-256).
# Control's introduction: D-256's "To the periphery's own types: `join_timeout` into `Control`"; D-255's Rejected equates Control and the control plane (log 10105).

old: Pause, un-pause, pace changes, `margin` changes and stop are a few scalar fields on a separate atomic surface.
new: Pause, un-pause, pace changes, `margin` changes and stop are a few fields on a separate atomic surface
tag: R
ruling: B20
note: opens the section (chapter pass P1-15); the control plane is named by apposition after it. "scalar" goes, since `Control` also holds a `Threads.Condition` and the boundary counter (B20); "a", not the proposal's "that", which had no antecedent once P1-15 made the sentence the section's first.

old: The loop consults them at frame top.
new: The loop consults the control plane at frame top, the start of each frame.
note: "them" becomes "the control plane", the fields now a paragraph back (chapter pass P1-15).
tag: F

added: the start of each frame

old: A change issued while a frame runs or waits is observed at the next frame top, at most one frame budget `h/p` later (D-269).
new: A change issued while a frame runs or waits is observed at the next frame top, at most one frame budget (`h/p`, the step over the pace) later (D-269).
tag: F
note: `p` is introduced 50 lines on, so `h/p` takes a gloss (chapter pass P1-27).

added: , the step over the pace

old: The pause block is the one wait that wakes at once (below).
new: The pause block, described with the pause verbs below, is the one wait that wakes at once.
tag: R
ruling: R10
note: F8, "(below)" given its target, the pause paragraph.

old: `margin` (§10.7) rides here for the same reason `pace` does.
new: `margin` (§10.7) rides on the control plane for the same reason `pace` does.
tag: M
note: M2; "here" becomes "on the control plane" since the sentence moved.

old: It tunes the wait, never the arithmetic, so retuning the coarse/spin split mid-run is safe by construction.
tag: M
note: M2.

old: The stop's issuers are the operator's channels (GUI button, device handle, calling code) and, in an interactive session, Ctrl-C.
new: The stop's issuers are the operator's channels and, in an interactive session, Ctrl-C. The operator's channels are a front end's button, the handle of a device (any attached participant in the periphery) and calling code (D-310).
tag: R
ruling: R2
newcites: D-310
note: M3; "GUI button" becomes "a front end's button", D-310 cited once in §12.1. The list leaves the parentheses so the device gloss can sit in them.

added: (any attached participant in the periphery)

old: An operator interrupt is caught at one of the loop's unmask points and sets exactly this stop, with no separate entry point involved (§12.4).
new: An operator interrupt (Ctrl-C read as a control-plane stop) sets exactly this stop, with no separate entry point involved (§12.4, D-132). The loop catches it at one of its unmask points, where a deferred Ctrl-C is raised (§12.4).
tag: C
newcites: D-132 §12.4
note: M3; split in two. D-132's Position "a control-plane stop"; "no separate entry point" rests on D-132's Rejected list. The unmask-point gloss points at §12.4.

added: (Ctrl-C read as a control-plane stop)

added: where a deferred Ctrl-C is raised

old: The stop word carries its issuer.
new: The stop word carries its issuer (D-203). The stop word is the control plane's stop command, one atomic word holding its issuer.
tag: R
ruling: R15
newcites: D-203
note: D-203 bullet 3, the citation was two sentences on; the second sentence is R11's gloss in R15's wording, which §12.4's gloss also uses (step 6, step5_carry.md).

old: Each issuing site writes its identity (the device's name, `:code`, or `:interrupt`) by compare-and-swap from empty, and the first writer wins.
tag: F

old: The loop's frame-top read consults the word for non-empty, so the recorded issuer is the request that actually initiated the tail.
new: The loop's frame-top read consults the word for non-empty, so the recorded issuer is the request that actually initiated the tail, the ordered shutdown sequence of §12.4.
tag: F
newcites: §12.4
note: "the tail" glossed at first use with its pointer.

added: the ordered shutdown sequence of §12.4

old: It lands in the termination record's `ControlRequestedStop` (§13.5, D-203).
new: The issuer lands in the termination record (the stopped-sim value naming how the run ended) as its `ControlRequestedStop`'s payload (§13.5, D-203).
tag: F
note: "It" becomes "The issuer" after the tail's gloss; the issuer is the source's payload (§13.5, D-203 bullet 1).

added: (the stopped-sim value naming how the run ended)

old: `ControlRequestedStop` sits outside the stop policy (D-255).
tag: F

old: The policy is what the caller declares for one advance (§13.5); the stop word is what anyone can issue at any moment.
new: The policy is what the caller declares for one advance (§13.5). The stop word is what anyone can issue at any moment.
tag: F

old: Beside pause, pace and `margin`, `Control` keeps the stop word, the running flag, the wait and the shutdown tail's `join_timeout` (§12.4, D-256, D-317).
new: Beside pause, pace and `margin`, `Control` keeps the stop word, the sticky stopped status, the running flag (D-317) and the wait (§12.3). `Control` also keeps the shutdown tail's `join_timeout` (§12.4, D-256).
tag: R
ruling: R10
newcites: §12.3 §12.4 D-256 D-317
note: F7 adds the sticky stopped status. M4 moves the paragraph to the end. The bold narrows to D-256 bullet 3's clause; D-317's running flag is bold at §12.6 (lifecycle derivation, same bullet). The wait points at §12.3.

old: The lifecycle state is not stored, and `lifecycle(sim)` derives it (§12.6).
tag: M
note: M4.

old: A run's outcome is not a control surface, so `termination` belongs to the `Run` (the state one run owns) (§12.6, D-255) and not here.
new: A run's outcome is not a control surface, so `termination` belongs to the `Run` (the state one run owns), not to `Control` (§12.6, D-255).
tag: M
note: M4; "here" becomes "`Control`" since the paragraph moved.

old: The control plane is what anyone may poke.
tag: M
note: M4.

old: While paused the loop blocks on a condition (notified on un-pause and stop), not a spin.
new: While paused the loop blocks on a condition variable (notified on un-pause and stop), not a spin.
tag: M
note: it closed M1's paragraph; it joins the pause paragraph, which the pause-block sentence's "below" names (F8). "condition" is reserved, so "condition variable".

old: The pause is two verbs on the simulation (D-268).
tag: F

old: `pause!(sim)` sets the pause flag and `resume!(sim)` clears it, from any task and in any lifecycle state; `paused(sim)` reads it.
new: `pause!(sim)` sets the pause flag and `resume!(sim)` clears it, from any task and in any lifecycle state. `paused(sim)` reads it.
tag: F

old: The loop consults the flag at frame top, so a `pause!` issued before `run!` starts the run paused at its first frame top.
tag: F

old: A stop issued while paused wakes the loop, which observes the stop word and enters the tail with no further frame (§12.4).
tag: F

old: `step!` shares the frame top and blocks the same way, until `resume!` or a stop from another task.
tag: F

added: A paused run is still running. The lifecycle reads `running`, and the roster (the list of attached device entries) stays frozen (D-106).

old: Rule. The tail clears the pause flag beside the sticky stopped status.
new: The tail clears the pause flag beside the sticky stopped status (D-268).
tag: C
newcites: D-268
note: label goes; bold headline with D-268 bullet 1.

old: The flag is never cleared at a run's start.
tag: F

old: Why. The stop word is cleared at the top of each run because a stop belongs to the run it ended.
new: The stop word, by contrast, is cleared at the top of each run, because a stop belongs to the run it ended.
tag: F
note: label goes; a plain connective.

old: A pause left set by a run that stopped while paused would instead hold the next run at its first frame top, on a flag nobody remembers setting.
tag: F

old: Clearing it in the tail removes that trap and keeps the start-paused spelling above.
tag: F

old: The handle carries no pause (§11.6).
new: The device handle carries no pause (§11.6).
tag: F

old: Whether it gains the control verbs for the bridge is pending (`pending.md`, D-310).
new: Whether it gains the control verbs for the bridge (§11.7) is pending (`pending.md`, D-310).
tag: F
newcites: §11.7 D-310
note: a pointer to where §11.7 introduces the bridge.

old: Pace and `margin` are two more verbs and two readers (D-269).
tag: F

old: `pace!(sim, p)` and `margin!(sim, m)` set them from any task in any lifecycle state, and `pace(sim)` and `margin(sim)` read them.
tag: F

old: `run!` and `replay!` take both as keywords and write them at entry, the advance's declaration as `t_end` is, `Inf` and 2 ms by default (Appendix B).
new: `run!` and `replay!` take both as keywords and write them when called. Both are declared by the advance, as `t_end` is. `pace` defaults to `Inf` and `margin` to 2 ms (Appendix B, D-133).
tag: C
newcites: Appendix B D-133
note: split in three; bare "entry" becomes "when called" (chapter pass P1-26); D-269 bullet 2 sets `pace`'s default, D-133's Position `margin` = 2 ms (bold at §10.7, plain here).

old: `step!` takes neither and never waits.
new: `step!` takes neither and never waits on the pacer.
tag: R
ruling: B1
note: F79's scope, as §12.6 states it; `step!` blocks while paused (this section).

old: A stepping session is the harness mode (§12.6), and its frames are bit-identical to `run!`'s by §10.7's invariant.
tag: F

old: `pace` is a positive real, `Inf` admitted, and `margin` a non-negative real, `Inf` admitted.
tag: F

old: Each of the four calls refuses anything else under `ArgumentInvalid` (Appendix C).
new: The two setters and the two keywords refuse anything else under `ArgumentInvalid` (Appendix C).
tag: R
ruling: R10
note: F8.

old: ### 12.2 Loop scheduling: wait primitive, yields, thread budget
tag: X

old: §10.7 fixed the shape of the pacer's wait, hybrid sleep-then-spin, and leaves the choice of the coarse phase's primitive to this section.
tag: F

old: That choice is a scheduling decision rather than an arithmetic one.
tag: F

old: It settles what else can run while a frame waits.
new: It settles what else can run while a frame (one iteration of the loop) waits.
tag: F

added: (one iteration of the loop)

old: It is made here, together with the two questions that trail it: whether a frame is guaranteed to yield at all, and how many threads a session needs.
new: It is made here, together with the two questions that trail it, whether a frame is guaranteed to yield at all and how many threads a session needs.
tag: F
note: the colon goes.

added: The section ends with the liveness heartbeat that makes a starved device diagnosable.

added: The coarse phase's primitive

old: Rule. The coarse phase uses task-yielding `sleep`. There is no `systemsleep` variant (D-027).
new: The coarse phase uses task-yielding `sleep`, and there is no `systemsleep` variant (D-027).
tag: F
note: label goes; bold headline with D-027.

old: Why. What the choice buys is the wait slot.
new: What the choice buys is the wait slot.
tag: F
note: label goes.

old: `sleep` releases the loop's thread, which makes the pacer's wait the natural scheduling window for co-resident device tasks.
new: `sleep` releases the loop's thread, which makes the pacer's wait the natural scheduling window for the co-resident tasks of devices (the attached participants in the periphery).
tag: F

added: (the attached participants in the periphery)

old: The design already spends that slot twice, as the staging slot (§10.7) and as the drain source (§11.4).
new: The design already spends that slot twice, as the staging slot (§10.7) and as what the drain (the frame-top swap that applies staged device writes) takes (§11.4).
tag: F

added: (the frame-top swap that applies staged device writes)

old: A `systemsleep` variant for dedicated-thread hard-RT deployments is a guarded addition (a capability the design admits but does not build).
new: A `systemsleep` variant for dedicated-thread hard real-time deployments is a guarded addition (a capability the design admits but does not build).
tag: R
ruling: R6
note: "hard-RT" expanded.

added: The per-frame yield

old: Rule. With devices attached, every frame yields at least once.
new: With devices attached, every frame yields at least once (D-027).
tag: C
newcites: D-027
note: label goes; bold headline. D-027's Position.

old: Why. The rule is semantically free. Pacing, and hence yielding, is outside the semantics (§10.7).
new: The rule is semantically free, because pacing (the waits inserted between completed frames), and hence yielding, is outside the semantics (§10.7, D-021).
tag: C
newcites: §10.7 D-021
note: label goes; D-021's Position.

added: (the waits inserted between completed frames)

old: The yield is implicit in the coarse-phase `sleep` whenever that phase runs.
tag: F

old: An explicit `yield()` covers the frames where it does not run: unpaced runs, and pure-spin frames with budget ≤ margin.
new: An explicit `yield()` covers the frames where it does not run, namely unpaced runs and pure-spin frames with budget ≤ margin.
tag: F
note: the colon goes. F19: not changed toward the code.

old: The spin phase itself never yields.
new: The spin phase itself never yields (D-027).
tag: C
newcites: D-027
note: D-027's Position "spin never yields".

old: Yielding there would trade its µs precision for scheduler noise.
tag: F

old: The consequence is a bound on thread occupancy.
tag: F

old: The loop holds a thread for at most one frame before the scheduler can run anyone else.
tag: F

old: Julia's cooperative-scheduler freeze requires a thread monopolist, a never-yielding task that holds its thread forever, and that precondition is structurally absent from framework tasks.
new: Julia's scheduler is cooperative, and a stall of that scheduler requires a thread monopolist, a never-yielding task that holds its thread forever. That precondition is structurally absent from framework tasks.
tag: R
ruling: R10
note: F16, "freeze" in the scheduler sense becomes "the scheduler stall"; here "a stall of that scheduler", so the next section's "The scheduler stall" has its antecedent (chapter pass P1-30).

added: The thread budget

old: Rule. The thread budget is a documented sizing rule and a startup warning, not a hard error (D-027).
new: The thread budget is a documented sizing rule and a startup warning, not a hard error (D-027).
tag: F
note: label goes; bold headline.

old: The freeze FlightCore's `nthreads` error prevented cannot reproduce here, for two reasons.
new: The scheduler stall FlightCore's `nthreads` error prevented cannot reproduce here, for two reasons.
tag: R
ruling: R10
note: F16 names this line; R2 keeps the rest of the passage as written (E2).

old: The loop yields every frame.
tag: R
ruling: R2
note: E2, as written.

old: Nothing couples a stall to anyone else, the GUI least of all.
tag: R
ruling: R2
note: E2, as written.

old: It waits on nothing, ever.
tag: R
ruling: R2
note: E2, as written.

old: It uses a snapshot acquire-load, its own staging cell and atomic control.
tag: R
ruling: R2
note: E2, as written; no glosses added, since R2 allows a rewrap only. The snapshot link moves to the next sentence's "stale snapshots" with its gloss (B16); the staging-cell link stays.

old: Under any starvation, then, the front end keeps rendering and the stop button keeps working.
tag: R
ruling: R2
note: E2, as written.

old: Undersized sessions degrade to laggy inputs and stale snapshots, which are visible, recoverable states.
new: Undersized sessions degrade to laggy inputs and stale snapshots (the immutable per-boundary publications), which are visible, recoverable states.
tag: R
ruling: B16
note: the section's snapshot link, moved here from the E2 sentence before, takes §12.3's gloss in the plural.

added: (the immutable per-boundary publications)

old: A run warns, at `run!` or `replay!`, when `Threads.nthreads()` is tight for the attached population, naming the `julia -t` remedy.
new: At `run!` or `replay!`, a run warns under `ThreadBudget` (Appendix C) when `Threads.nthreads()` is tight for the attached population, naming the `julia -t` remedy.
tag: R
ruling: R10
newcites: Appendix C
note: F15 names `ThreadBudget`.

old: That is one check per run, against the frozen roster (§11.3).
new: That is one check per run, against the frozen roster, the list of attached device entries (§11.3).
tag: F
note: the gloss is an appositive, so it and the citation are not two touching parentheses (chapter pass P1-20).

added: , the list of attached device entries

old: Tight means fewer threads than the roster plus one.
tag: F

old: Every rostered device is a task, and the calling task hosts the loop, so a run occupies one task more than its roster.
new: Every rostered device is a task, and the calling task (the task that invoked `run!`) hosts the loop, so a run occupies one task more than its roster (D-310).
tag: C
newcites: D-310
note: D-310 bullet 1 carries the topology.

added: (the task that invoked `run!`)

old: The sizing guidance behind the remedy is one thread for the loop and headroom for compute-heavy or blocking-ccall devices.
tag: F

old: libuv-backed I/O yields.
new: I/O backed by libuv (the I/O library under Julia's tasks) yields.
tag: R
ruling: R6

old: Raw blocking ccalls pin their thread for the duration.
tag: F

old: There is no pinning and there are no sticky tasks.
tag: F

added: The liveness heartbeat

old: Liveness heartbeat. Since starvation is survivable, it must be diagnosable.
new: Since starvation is survivable, it must be diagnosable (D-027).
tag: C
newcites: D-027
note: the lead-in becomes the `####` label "The liveness heartbeat". D-027's Position "per-device liveness heartbeat in framework status".

old: The record is the published framework status, the frozen diagnostics value each snapshot carries beside the table.
tag: F

old: It includes per-device liveness (the liveness timestamp and the device's `task_state`) next to the pacer diagnostics.
tag: F

old: The mechanism is the per-writer cell, specified in full by §11.8, plus the device `Task` handles the loop already owns, and nothing besides.
new: The mechanism is the per-writer diagnostic cell (D-136), specified in full by §11.8, plus the device `Task` handles the loop already owns, and nothing besides.
tag: C
newcites: §11.8 D-136
note: bare "cell" is reserved, so "diagnostic cell". D-136's Position, placed at the cell; the handles are D-193's, cited next sentence. The gloss takes its own sentence after it, so gloss and citation are not two touching parentheses and D-136 does not move onto the handles (chapter pass P1-20).

added: A diagnostic cell is a writer's own holding place for runtime diagnostics and liveness.

old: The cell carries the single liveness timestamp.
new: It carries the single liveness timestamp.
note: "It" is the diagnostic cell of the gloss sentence before.
tag: F

old: The loop reads `task_state` off those handles where it publishes (D-193).
tag: F

old: A starved, blocked or crashed device task shows in the GUI as a stale heartbeat with a name on it, not as mysteriously frozen physics.
new: A starved, blocked or crashed device task shows in a front end as a stale heartbeat with a name on it, not as mysteriously frozen physics (D-310).
tag: R
ruling: R2
newcites: D-310

old: Rule. `task_state` has three values.
new: `task_state` has three values (D-270).
tag: C
newcites: D-270
note: label goes; bold headline. Rests on D-270's 2026-09-28 annotation.

old: Outside a run every device reads `:none`.
tag: F

old: Inside a run a device reads `:running` while its task lives and `:done` once that task has ended, whether the body returned or the wrapper caught its crash (§11.6).
tag: F

old: A device whose `init!` threw, and so spawned no task, reads `:done` as well.
tag: F

old: The record's crash count tells a crash from a return.
tag: F

old: `orphaned` on a record is exactly `:done` (§11.7, D-270).
tag: F

old: Stale means a liveness timestamp more than 2 s behind wall clock.
new: Stale means a liveness timestamp more than 2 s behind wall clock (D-133).
tag: C
newcites: D-133
note: R3; D-133's Position lists the 2 s threshold as its own semicolon-separated default, as §10.7 bolds the 2 ms `margin`.

old: The threshold is deliberately loose, because the heartbeat is advisory.
tag: F

old: It is a liveness display and a record, never a kill trigger, never a detach.
tag: F

old: It must also tolerate a device legitimately parked in a blocking read between rare data.
tag: F

old: ### 12.3 The next-snapshot wait
tag: X

old: Rate-matched output devices (telemetry, disk streaming) act once per boundary.
new: Rate-matched output devices (attached participants in the periphery), such as telemetry and disk streaming, act once per boundary.
tag: F
note: the examples leave the parentheses for the device gloss.

added: (attached participants in the periphery)

added: A boundary is a published consistency point.

old: What they need from the framework is a way to learn that a boundary has happened without polling for it.
tag: F

added: The next-snapshot wait (a device's blocking wait for the next publication) is that way.

added: This section gives its two artifacts, the loop's side, the device's side, its newest-wins semantics, and how the counter differs from the other two indices, in that order.

old: Rule. Two artifacts provide it: a monotonic boundary counter, the loop's own, plus one `Threads.Condition`.
new: Two artifacts provide the wait, a monotonic boundary counter plus one `Threads.Condition` (D-028). The boundary counter is the loop's own.
tag: C
newcites: D-028
note: R3, D-028's first ruling bold; the bold term goes, and "the loop's own" opens the gloss sentences.

old: The counter counts published boundaries, that is grid, `t` and boundary zero (§10.1, §10.4), not frames.
new: It counts published boundaries, that is grid, `t` and boundary zero (the initialization boundary at `t₀`), not frames (§10.1, §10.4).
note: the citation moves to the clause's end, off the gloss (chapter pass P1-20).
tag: F

added: (the initialization boundary at `t₀`)

old: Consecutive wakes are therefore not necessarily `h` apart.
tag: F

old: The loop's publication is `lock; counter += 1; notify; unlock`, nanoseconds of framework-only code.
tag: M
note: M5.

old: Waiters never block it.
tag: M
note: M5.

old: One parked in `wait` has released the lock as part of parking.
tag: M
note: M5.

old: Rule. The order of the two publications is normative.
new: The order of the two publications is normative.
tag: R
ruling: B6
note: M5; label goes. Plain, since D-114's bold moves to the next sentence, which states the order (B6).

old: The release-store of `latest` (§11.2) happens before the counter increment under the lock.
new: The release-store of `latest`, the atomic reference readers acquire-load (§11.2), happens before the counter increment under the lock (D-114).
tag: R
ruling: B6
newcites: §11.2 D-114
note: M5; R3, D-114's publication order bold, on the sentence that states the order (B6). The gloss is an appositive and §11.2 stays on `latest`, since §11.2 does not state the order (chapter pass P1-20).

added: , the atomic reference readers acquire-load

old: `# the loop, at every published boundary @atomic latest = snap # 1. release-store: the snapshot becomes reachable (§11.2) lock(cond) do # 2. only then the counter, under the lock counter += 1 notify(cond) # parked waiters wake and re-test their predicate end`
tag: M
note: M5; the publication-order sketch, verbatim.

old: `counter > last_seen` therefore implies that `latest` holds at least that boundary, and a waiter can never wake onto a stale snapshot.
new: The device side's test `counter > last_seen` (below) therefore implies that `latest` holds at least that boundary, and a waiter can never wake onto a snapshot (the immutable per-boundary publication) that is stale.
tag: M
note: M5; the predicate now precedes the device side, so it points below. "test", since the full predicate adds `&& running` (chapter pass P1-28).

added: The device side's test

added: (the immutable per-boundary publication)

old: The converse, observing a newer snapshot than the increment that woke you, is expected and correct.
new: The converse is expected and correct. A waiter may observe a newer snapshot than the increment that woke it.
tag: M
note: M5; "you" becomes "the waiter".

old: Newest wins.
tag: M
note: M5.

old: The device side is `wait_next_snapshot(handle)`, which blocks until `counter > last_seen && running` under the canonical predicate-loop idiom.
tag: F

old: That idiom handles waiters at different paces, frames skipped while transmitting, and shutdown, all with no per-frame reset.
new: That idiom handles waiters at different paces, boundaries skipped while transmitting, and shutdown, all with no per-frame reset.
tag: R
ruling: B2
note: R10's F17 covers every instance; the counter counts boundaries.

old: Shutdown works because §12.4 wakes all waiters and each predicate then routes its owner out.
new: Shutdown works because §12.4 wakes all waiters and each predicate then routes its owner out (D-028).
tag: C
newcites: §12.4 D-028
note: D-028's Position "shutdown-interruptible via the predicate".

old: Semantics: newest-wins, no queues.
new: The wait's semantics are newest-wins, no queues (D-028).
tag: C
newcites: D-028
note: M6; R3, D-028's second ruling (semicolon-separated) bold; the labelled lead-in becomes a headline clause.

old: A slow consumer skips frames and always receives the current world.
new: A slow consumer skips boundaries and always receives the current world.
tag: R
ruling: R10
note: F17; M6.

old: This mirrors the inbound side.
tag: M
note: M6.

old: Coalescing to the newest batch (in) and to the newest snapshot (out) are the same ZOH decision.
new: Inbound coalescing (the compare-and-swap merge that leaves one pending batch per device) keeps the newest level per face, and the wait delivers the newest snapshot, the same zero-order hold (ZOH) decision.
tag: R
ruling: R10
note: F17, and R6 expands ZOH; M6.

added: (the compare-and-swap merge that leaves one pending batch per device)

old: No backpressure exists in either direction, and the loop never waits on anyone.
tag: M
note: M6.

old: Per-consumer every-boundary queues are rejected (D-028).
tag: M
note: M6; one-clause verdict with its citation (R6).

old: A `Base.Event` latch is the wrong primitive here (D-028).
tag: F
note: R6 verdict kept.

old: Conditions carry no facts, only "look again".
new: Condition variables carry no facts, only "look again".
tag: F
note: "condition" is reserved.

old: The facts that matter, the counter and `running`, live in state each waiter tests privately.
tag: F

old: Two indices, and where each lives.
new: Two indices number the publications, and each lives in its own place.
tag: X
note: the bold lead-in becomes a plain topic sentence.

old: The snapshot carries the trajectory's published-boundary ordinal with `t`.
tag: F

old: Boundary zero is 0, and every publication after it, grid or `t`, counts one.
tag: F

old: Any holder of a snapshot therefore indexes it without consulting the loop, whether the log or a post-run inspector.
new: Any holder of a snapshot therefore indexes it without consulting the loop, whether the log (the retained sequence of published snapshots) or a post-run inspector.
tag: F
note: the log takes its §12.3 link and gloss (chapter pass P1-19).

added: (the retained sequence of published snapshots)

old: A new trajectory restarts the ordinal at zero, with everything else `init!` resets.
tag: F

old: The boundary counter is a different number.
tag: F

old: It is the loop's monotone count of every publication it has ever made, never reset across trajectories, and its absolute value is nowhere normative.
tag: F

old: It exists for the wait predicate alone, and it is never reset because a waiter's `last_seen` must never run ahead of it (D-230).
tag: F

old: An error's replay pointer is a third index, the frame-entry boundary index of §13.4, a frame count that names no `t` boundary.
new: An error's pointer for replay (the ordinary loop re-driven from the trace) is a third index, the frame-entry boundary index of §13.4, a frame count that names no `t` boundary (D-128).
tag: C
newcites: §13.4 D-128
note: D-128's Position respells the replay pointer as the frame-entry boundary index.

added: (the ordinary loop re-driven from the trace)

old: The GUI does not use the wait.
tag: R
ruling: R2
note: E2, as written.

old: Being VSync-paced, it reads `latest` at each render.
tag: R
ruling: R2
note: E2, as written.
