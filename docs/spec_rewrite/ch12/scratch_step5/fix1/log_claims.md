### P1-25, unit A, `units/A/claims.md`

Old:

````text
its yields and the thread budget; §12.3
````

New:

````text
its yields, the thread budget and the liveness heartbeat; §12.3
````

### P1-25, unit A, `units/A/claims.md`

Old:

````text
note: roadmap sentence; every word from the old opening or a section title (§12.2, §12.3, §12.5, §12.6, §12.7 titles).
````

New:

````text
note: roadmap sentence; every word from the old opening or a section title (§12.2, §12.3, §12.5, §12.6, §12.7 titles); "the liveness heartbeat" is §12.2's fourth `####` label (chapter pass P1-25).
````

### P1-15, unit A, `units/A/claims.md`

Old:

````text
new: The control plane (the separate few-word atomic surface carrying pause, pace and stop) is not staging, structurally (D-022).
````

New:

````text
new: It is not staging, structurally (D-022).
````

### P1-15, unit A, `units/A/claims.md`

Old:

````text
Gloss from the glossary's control-plane entry.

added: (the separate few-word atomic surface carrying pause, pace and stop)
````

New:

````text
The plane is named by apposition in the sentence before, which now opens the section (chapter pass P1-15).

added: , the control plane.
````

### P1-14, unit A, `units/A/claims.md`

Old:

````text
new: Staged writes apply at drains (the points where the loop applies staged device writes),
````

New:

````text
new: Staged writes apply at drains (the frame-top swaps that apply staged device writes),
````

### P1-14, unit A, `units/A/claims.md`

Old:

````text
added: (the points where the loop applies staged device writes)
````

New:

````text
added: (the frame-top swaps that apply staged device writes)
````

### P1-18, unit A, `units/A/claims.md`

Old:

````text
new: Riding outside the drain/trace path is safe for determinism
````

New:

````text
new: Riding outside the path through the drain and the trace, the primary record of a session, is safe for determinism
````

### P1-18, unit A, `units/A/claims.md`

Old:

````text
added: (the pacer's wall-clock waits)
````

New:

````text
added: (the pacer's wall-clock waits)

added: , the primary record of a session,
````

### P1-16, unit A, `units/A/claims.md`

Old:

````text
added: This section covers, in order, when the loop reads the plane, the stop and its issuer, the pause, pace and `margin`, and the fields of `Control`, one of the periphery's own types (D-256), the one that holds the control plane.
````

New:

````text
added: This section covers, in order, when the loop reads the plane, the stop and its issuer, the pause, pace and `margin`, and the fields of `Control`, the periphery's own type that holds the control plane (D-256).
````

### P1-15, unit A, `units/A/claims.md`

Old:

````text
new: Pause, un-pause, pace changes, `margin` changes and stop are a few scalar fields on that separate atomic surface.
tag: F
````

New:

````text
new: Pause, un-pause, pace changes, `margin` changes and stop are a few scalar fields on a separate atomic surface
tag: F
note: opens the section (chapter pass P1-15); the control plane is named by apposition after it.
````

### P1-15, unit A, `units/A/claims.md`

Old:

````text
old: The loop consults them at frame top.
new: The loop consults them at frame top, the start of each frame.
````

New:

````text
old: The loop consults them at frame top.
new: The loop consults the control plane at frame top, the start of each frame.
note: "them" becomes "the control plane", the fields now a paragraph back (chapter pass P1-15).
````

### P1-27, unit A, `units/A/claims.md`

Old:

````text
old: A change issued while a frame runs or waits is observed at the next frame top, at most one frame budget `h/p` later (D-269).
tag: F
````

New:

````text
old: A change issued while a frame runs or waits is observed at the next frame top, at most one frame budget `h/p` later (D-269).
new: A change issued while a frame runs or waits is observed at the next frame top, at most one frame budget (`h/p`, the step over the pace) later (D-269).
tag: F
note: `p` is introduced 50 lines on, so `h/p` takes a gloss (chapter pass P1-27).

added: , the step over the pace
````

### P1-17, unit A, `units/A/claims.md`

Old:

````text
new: The stop word carries its issuer (D-203). The stop word is the control plane's stop command, one atomic word holding its issuer.
````

New:

````text
new: The stop word carries its issuer (D-203). The stop word is the control plane's stop command, held in one atomic word.
````

### P1-17, unit A, `units/A/claims.md`

Old:

````text
the second sentence is R11's gloss as R15 words it.
````

New:

````text
the second sentence is R11's gloss as R15 words it, less "holding its issuer", which the bold states (chapter pass P1-17).
````

### P1-26, unit A, `units/A/claims.md`

Old:

````text
new: `run!` and `replay!` take both as keywords and write them at entry. Both
````

New:

````text
new: `run!` and `replay!` take both as keywords and write them when called. Both
````

### P1-26, unit A, `units/A/claims.md`

Old:

````text
note: split in three; D-269 bullet 2 sets `pace`'s default,
````

New:

````text
note: split in three; bare "entry" becomes "when called" (chapter pass P1-26); D-269 bullet 2 sets `pace`'s default,
````

### P1-30, unit A, `units/A/claims.md`

Old:

````text
new: Julia's scheduler is cooperative, and the scheduler stall requires a thread monopolist,
````

New:

````text
new: Julia's scheduler is cooperative, and a stall of that scheduler requires a thread monopolist,
````

### P1-30, unit A, `units/A/claims.md`

Old:

````text
note: F16, "freeze" in the scheduler sense becomes "the scheduler stall".
````

New:

````text
note: F16, "freeze" in the scheduler sense becomes "the scheduler stall"; here "a stall of that scheduler", so the next section's "The scheduler stall" has its antecedent (chapter pass P1-30).
````

### P1-20, unit A, `units/A/claims.md`

Old:

````text
new: That is one check per run, against the frozen roster (the list of attached device entries) (§11.3).
tag: F

added: (the list of attached device entries)
````

New:

````text
new: That is one check per run, against the frozen roster, the list of attached device entries (§11.3).
tag: F
note: the gloss is an appositive, so it and the citation are not two touching parentheses (chapter pass P1-20).

added: , the list of attached device entries
````

### P1-20, unit A, `units/A/claims.md`

Old:

````text
new: The mechanism is the per-writer diagnostic cell (a writer's own holding place for runtime diagnostics and liveness) (D-136), specified in full by §11.8,
````

New:

````text
new: The mechanism is the per-writer diagnostic cell (D-136), specified in full by §11.8,
````

### P1-20, unit A, `units/A/claims.md`

Old:

````text
D-136's Position, placed at the cell; the handles are D-193's, cited next sentence.

added: (a writer's own holding place for runtime diagnostics and liveness)
````

New:

````text
D-136's Position, placed at the cell; the handles are D-193's, cited next sentence. The gloss takes its own sentence after it, so gloss and citation are not two touching parentheses and D-136 does not move onto the handles (chapter pass P1-20).

added: A diagnostic cell is a writer's own holding place for runtime diagnostics and liveness.
````

### P1-20, unit A, `units/A/claims.md`

Old:

````text
old: The cell carries the single liveness timestamp.
new: The diagnostic cell carries the single liveness timestamp.
````

New:

````text
old: The cell carries the single liveness timestamp.
new: It carries the single liveness timestamp.
note: "It" is the diagnostic cell of the gloss sentence before.
````

### P1-20, unit A, `units/A/claims.md`

Old:

````text
new: It counts published boundaries, that is grid, `t` and boundary zero (the initialization boundary at `t₀`) (§10.1, §10.4), not frames.
````

New:

````text
new: It counts published boundaries, that is grid, `t` and boundary zero (the initialization boundary at `t₀`), not frames (§10.1, §10.4).
note: the citation moves to the clause's end, off the gloss (chapter pass P1-20).
````

### P1-20, unit A, `units/A/claims.md`

Old:

````text
new: The release-store of `latest` (the atomic reference readers acquire-load) (§11.2) happens before the counter increment under the lock.
````

New:

````text
new: The release-store of `latest`, the atomic reference readers acquire-load (§11.2), happens before the counter increment under the lock.
````

### P1-20, unit A, `units/A/claims.md`

Old:

````text
note: M5; the bold on "before" goes.

added: (the atomic reference readers acquire-load)
````

New:

````text
note: M5; the bold on "before" goes. The gloss is an appositive and §11.2 stays on `latest`, since §11.2 does not state the order (chapter pass P1-20).

added: , the atomic reference readers acquire-load
````

### P1-28, unit A, `units/A/claims.md`

Old:

````text
new: The device side's predicate, `counter > last_seen` (below), therefore implies
````

New:

````text
new: The device side's test `counter > last_seen` (below) therefore implies
````

### P1-28, unit A, `units/A/claims.md`

Old:

````text
note: M5; the predicate now precedes the device side, so it points below.

added: The device side's predicate
````

New:

````text
note: M5; the predicate now precedes the device side, so it points below. "test", since the full predicate adds `&& running` (chapter pass P1-28).

added: The device side's test
````

### P1-29, unit A, `units/A/claims.md`

Old:

````text
new: Inbound coalescing (the CAS merge that leaves one pending batch per device)
````

New:

````text
new: Inbound coalescing (the compare-and-swap merge that leaves one pending batch per device)
````

### P1-29, unit A, `units/A/claims.md`

Old:

````text
added: (the CAS merge that leaves one pending batch per device)
````

New:

````text
added: (the compare-and-swap merge that leaves one pending batch per device)
````

### P1-19, unit A, `units/A/claims.md`

Old:

````text
old: Any holder of a snapshot therefore indexes it without consulting the loop, whether the log or a post-run inspector.
tag: F
````

New:

````text
old: Any holder of a snapshot therefore indexes it without consulting the loop, whether the log or a post-run inspector.
new: Any holder of a snapshot therefore indexes it without consulting the loop, whether the log (the retained sequence of published snapshots) or a post-run inspector.
tag: F
note: the log takes its §12.3 link and gloss (chapter pass P1-19).

added: (the retained sequence of published snapshots)
````

### P1-11, unit B, `units/B/claims.md`

Old:

````text
which a stop at `t` (the localized event time) places inside a frame.
tag: R
ruling: R10
note: F4; `t*` linked and glossed at its first use (verifier); frame linked, its gloss in the next sentence
````

New:

````text
which a stop at `t` (the localized event time) places inside a frame, one iteration of the loop.
tag: R
ruling: R10
note: F4; `t*` linked and glossed at its first use (verifier); frame linked at this first use, its gloss an appositive (chapter pass P1-11)
````

### P1-11, unit B, `units/B/claims.md`

Old:

````text
note: "It" spelled "The loop", since the frame's gloss sentence now sits before it
````

New:

````text
note: "It" spelled "The loop", since the frame's gloss now ends the sentence before it
````

### P1-11, unit B, `units/B/claims.md`

Old:

````text
added: A frame is one iteration of the loop.
````

New:

````text
added: , one iteration of the loop.
````

### P1-14, P1-20, P1-13, unit B, `units/B/claims.md`

Old:

````text
new: The diagnostic is written to the loop's own diagnostic cell (each writer's bounded ring of diagnostics and its heartbeat) (D-203). The run's-end sweep collects the diagnostic into
````

New:

````text
new: The diagnostic is written to the loop's own diagnostic cell, a writer's own holding place for runtime diagnostics and liveness (D-203). The run's-end sweep, the loop's last pass over every diagnostic cell, collects the diagnostic into
````

### P1-14, P1-20, P1-13, unit B, `units/B/claims.md`

Old:

````text
split into three sentences, "it" spelled "the diagnostic" twice (verifier)
````

New:

````text
split into three sentences, "it" spelled "the diagnostic" twice (verifier); the cell takes §12.2's gloss as an appositive, off the citation (chapter pass P1-14, P1-20); the run's-end sweep is glossed from D-201, "the loop sweeps every cell once more at the run's end" (chapter pass P1-13)
````

### P1-14, P1-20, P1-13, unit B, `units/B/claims.md`

Old:

````text
added: (each writer's bounded ring of diagnostics and its heartbeat)
````

New:

````text
added: , a writer's own holding place for runtime diagnostics and liveness

added: , the loop's last pass over every diagnostic cell,
````

### P1-19, unit B, `units/B/claims.md`

Old:

````text
old: With `should_abort` set, the wrapper's exit path also requests a sim stop.
tag: F
````

New:

````text
old: With `should_abort` set, the wrapper's exit path also requests a sim stop.
new: With `should_abort` (the per-attachment failure policy, an `attach!` keyword) set, the wrapper's exit path also requests a sim stop.
tag: F
note: `should_abort` linked and glossed at its first use in the section, the glossary's words (chapter pass P1-19)

added: (the per-attachment failure policy, an `attach!` keyword)
````

### P1-24, unit B, `units/B/claims.md`

Old:

````text
old: The run takes whole frames until the boundary time first covers the duration.
tag: M
note: M7
````

New:

````text
old: The run takes whole frames until the boundary time first covers the duration.
new: The run ends at the first grid boundary whose time reaches or exceeds `t_end` (D-133). The run takes whole frames only
newcites: D-133
tag: M
note: M7; the sentence goes as a third statement of the landing, held by the bold and the whole-frames sentence, and verbatim §12.6's `t_plus` rule, which the pointer before it names (chapter pass P1-24)
````

### P1-21, unit B, `units/B/claims.md`

Old:

````text
new: The default of five seconds is generous for front-end window teardown and socket closes.
````

New:

````text
new: The `join_timeout` default of five seconds is generous for front-end window teardown and socket closes.
````

### P1-21, unit B, `units/B/claims.md`

Old:

````text
the labelled lead-in folds into the topic sentence

````

New:

````text
the labelled lead-in folds into the topic sentence; the default is named, its step (5) mention far back (chapter pass P1-21)

````

### P1-23, unit B, `units/B/claims.md`

Old:

````text
old: That is the disposition §10.4 gives its own two constants, extended here to an operational one (D-198).
tag: F
````

New:

````text
old: That is the disposition §10.4 gives its own two constants, extended here to an operational one (D-198).
new: That is the disposition §10.4 gives its own two constants, extended here to an operational one.
newcites: §10.4
tag: F
note: D-198, cited at the bold the sentence before, is not repeated (chapter pass P1-23)
````

### P1-22, unit B, `units/B/claims.md`

Old:

````text
old: Deployment contexts legitimately differ in patience.
tag: F
````

New:

````text
old: Deployment contexts legitimately differ in patience.
new: Usage contexts legitimately differ in patience.
tag: F
note: at a sentence's start "Deployment" read as the type, two sentences before `Deployment` (chapter pass P1-22)
````

### P1-22, unit B, `units/B/claims.md`

Old:

````text
old: An unattended sweep wants to fail fast, a test battery exercising the abandonment path faster still, while a device with slow teardown may warrant more.
tag: F
````

New:

````text
old: An unattended sweep wants to fail fast, a test battery exercising the abandonment path faster still, while a device with slow teardown may warrant more.
new: A series of runs nobody watches wants to fail fast, a test battery exercising the abandonment path faster still, while a device with slow teardown may warrant more.
tag: F
note: "sweep" names one pass through the execution order in this section; "nobody watches", not "unattended runs", since that term's link and gloss come later in the section (chapter pass P1-22)
````

### P1-20, unit B, `units/B/claims.md`

Old:

````text
Those values are well-defined by root-input totality (every root input must hold a value) (§14.6).
````

New:

````text
Those values are well-defined by root-input totality, the rule that every root input must hold a value (§14.6).
````

### P1-20, unit B, `units/B/claims.md`

Old:

````text
the semicolon parenthetical splits into a gloss and the citation
````

New:

````text
the semicolon parenthetical splits into an appositive gloss and the citation (chapter pass P1-20)
````

### P1-20, unit B, `units/B/claims.md`

Old:

````text
added: (every root input must hold a value)
````

New:

````text
added: , the rule that every root input must hold a value
````

### P1-31, unit B, `units/B/claims.md`

Old:

````text
old: This protocol already has that path.
tag: F
````

New:

````text
old: This protocol already has that path.
new: This protocol already has that path,
tag: F
note: moved after the mechanism and joined to its conclusion (chapter pass P1-31)
````

### P1-31, unit B, `units/B/claims.md`

Old:

````text
new: The loop reads that stop at the frame top, before any frame, so the run advances no frame.
````

New:

````text
new: The loop reads it there, before any frame, so the run advances no frame.
````

### P1-31, unit B, `units/B/claims.md`

Old:

````text
§13.5 stays cited later in the paragraph
````

New:

````text
§13.5 stays cited later in the paragraph; "that stop at the frame top" becomes "it there", the sentence now following the one that names both (chapter pass P1-31)
````

### P1-31, unit B, `units/B/claims.md`

Old:

````text
old: No new exit protocol is needed, therefore.
tag: F
````

New:

````text
old: No new exit protocol is needed, therefore.
new: so no new exit protocol is needed.
tag: F
````

### P1-13, unit B, `units/B/claims.md`

Old:

````text
whose terminal snapshot is the one the run started from and whose termination record's tail residue holds the `DeviceCrash`.
tag: R
ruling: R8
note: the run publishes nothing after the failure;
````

New:

````text
whose terminal snapshot is the one the run started from and whose termination record's tail residue (the diagnostics the run's-end sweep folds in) holds the `DeviceCrash`.
tag: R
ruling: R8
note: tail residue glossed from §13.5, "the post-account diagnostics the run's-end sweep folds in", with no citation so the sentence still ends on the `DeviceCrash` before the next "It" (chapter pass P1-13); the run publishes nothing after the failure;
````

### P1-13, unit B, `units/B/claims.md`

Old:

````text
added: (the primary record of a session)
````

New:

````text
added: (the primary record of a session)

added: (the diagnostics the run's-end sweep folds in)
````

### P1-12, unit B, `units/B/claims.md`

Old:

````text
old: The stop already rides on the control plane, the separate atomic surface carrying pause, pace and stop (§12.1).
tag: F
````

New:

````text
old: The stop already rides on the control plane, the separate atomic surface carrying pause, pace and stop (§12.1).
new: The stop already rides on the control plane (§12.1).
tag: F
note: the appositive repeated step (1)'s gloss in the same section (chapter pass P1-12)
````

### P1-20, unit B, `units/B/claims.md`

Old:

````text
It would also leave half-written stores (the framework-owned homes of a component's state) (§13.6).
````

New:

````text
It would also leave stores (the framework-owned homes of a component's state) half-written (§13.6).
````

### P1-20, unit B, `units/B/claims.md`

Old:

````text
note: split for the glosses of sweep and store

````

New:

````text
note: split for the glosses of sweep and store; "half-written" moves after the gloss, so gloss and citation do not touch (chapter pass P1-20)

````

### P1-33, unit B, `units/B/claims.md`

Old:

````text
old: The published record is consistent, since the frame published nothing.
tag: F
````

New:

````text
old: The published record is consistent, since the frame published nothing.
new: What the run published is consistent, since the frame published nothing.
tag: F
note: "the record" bare means the termination record in this section (chapter pass P1-33)
````

### P1-20, unit B, `units/B/claims.md`

Old:

````text
new: as after a throw inside boundary zero (the initialization boundary, the ordinary macro-sequence with an empty integrate) (§13.4).
````

New:

````text
new: as after a throw inside boundary zero, the initialization boundary, which runs the ordinary macro-sequence with an empty integrate (§13.4).
````

### P1-20, unit B, `units/B/claims.md`

Old:

````text
one sentence, as in the old, so "such a run" keeps its antecedent (verifier)
````

New:

````text
one sentence, as in the old, so "such a run" keeps its antecedent (verifier); the gloss is an appositive clause, off the citation (chapter pass P1-20)
````

### P1-20, unit B, `units/B/claims.md`

Old:

````text
added: (the initialization boundary, the ordinary macro-sequence with an empty integrate)
````

New:

````text
added: , the initialization boundary, which runs the ordinary macro-sequence with an empty integrate
````

