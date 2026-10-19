import sys; sys.path.insert(0, "ch13/scratch_step5/fix1")
from claims_edit import C
c = C("A")
c.rep('new: §13.1 covers the reporting policy; §13.2 the diagnostic representation; §13.3 the build primitives, `resolve` and the face-list accessors; §13.4 the runtime failure story; §13.5 the distinction between "the model reached a terminal state" and "the run should end"; §13.6 abnormal shutdown, one tail with two entries; §13.7 the tooling and component library that follow; and §13.8 the diagnosis of a rejected cycle.',
      'new: §13.1 covers the reporting policy; §13.2 the diagnostic representation; §13.3 the build primitives and how path resolution is scoped by client; §13.4 how a runtime failure is caught, carried and reproduced; §13.5 the distinction between "the model reached a terminal state" and "the run should end"; §13.6 abnormal shutdown, one tail with two entries; §13.7 the tooling and component library that follow; and §13.8 the diagnosis of a rejected cycle.')
c.rep('note: roadmap sentence naming §13.1–§13.8 in order. §13.3 and §13.6 take their subjects from their titles ("Build primitives: `resolve` and the face-list accessors"; "Abnormal shutdown: one tail, two entries"). "the seam between" becomes "the distinction between": seam is reserved for a narrow, named interface.',
      'note: roadmap sentence naming §13.1–§13.8 in order. §13.6 takes its subject from its title ("Abnormal shutdown: one tail, two entries"). Step 5 (P1-1): §13.3\'s subject is its main one, client-scoped resolution, and §13.4\'s "the runtime failure story" is named by its parts. "the seam between" becomes "the distinction between": seam is reserved for a narrow, named interface.')
c.rep("new: The nominal evaluation runs every user function once, through the stage-1 probes (the build's single evaluations of a user function with real values) and the probe chain.",
      "new: The nominal evaluation runs every user function once, through the stage-1 probes (the build's single evaluations of a user function) and the probe chain.")
c.rep("added: (the build's single evaluations of a user function with real values)",
      "added: (the build's single evaluations of a user function)")
c.rep("added: The activation at `T` runs the continuous tier's functions.",
      "added: The activation at the scalar type `T` runs the continuous tier's functions.")
c.rep("old: An unreadable or mixed class or a malformed container is such a failure.",
      "old: An unreadable or mixed class or a malformed container is such a failure.",
      "new: An unreadable or mixed class (a component's primitive-vs-assembly status) or a malformed container is such a failure.")
c.after("new: An unreadable or mixed class (a component's primitive-vs-assembly status) or a malformed container is such a failure.",
        "added: (a component's primitive-vs-assembly status)")
c.rep("old: The payload holds endpoint paths, face names, expected and observed types, and the list-in-hand a did-you-mean needs (the offending name plus the list it should have matched).",
      "old: The payload holds endpoint paths, face names, expected and observed types, and the list-in-hand a did-you-mean needs (the offending name plus the list it should have matched).",
      "new: The payload holds endpoint paths, face names, expected and observed types, and the list-in-hand a did-you-mean needs. A did-you-mean is the offending name plus the list-in-hand it should have matched.",
      "note: step 5 (P1-5): the gloss becomes its own sentence in the glossary's words, so it follows did-you-mean.")
c.rep("new: `BundleFieldError`, for example, is raised at the probe and as a `StepError` species (a `StepError` whose `cause` is a diagnostic) thereafter.",
      "new: `BundleFieldError`, for example, is raised at the probe and, at runtime, as a species of the runtime carrier `StepError` (§13.4).",
      "newcites: §13.4",
      "note: step 5 (P1-6): \"thereafter\" is the runtime, and `StepError` is introduced as the runtime carrier with its home.")
c.rep("added: (a `StepError` whose `cause` is a diagnostic)",
      "added: A species is a `StepError` whose `cause` is a diagnostic.")
c.rep("new: A fail-fast site throws the same carrier exception holding one diagnostic.",
      "new: A fail-fast site throws the same carrier exception (the single exception diagnostics travel in when thrown) holding one diagnostic.")
c.after("new: A fail-fast site throws the same carrier exception (the single exception diagnostics travel in when thrown) holding one diagnostic.",
        "added: (the single exception diagnostics travel in when thrown)")
c.rep("new: The first is strings, never instances.", "new: The first rule is strings, never instances.")
c.rep("new: The second is that the didactic style is policy.", "new: The second rule is that the didactic style is policy.")
c.rep("old: The unconnected-output warning stays rejected (§6.1, D-084), so the collected-warning slot stays open and empty.",
      "old: The unconnected-output warning stays rejected (§6.1, D-084), so the collected-warning slot stays open and empty.",
      "new: The unconnected-output warning stays rejected (§6.1, D-084), so the collected-warning category stays open and empty.")
c.rep("new: `EmptyGreedyClaim` therefore lands in the roster entry's diagnostic cell (the single-writer cell each writer owns for diagnostics and heartbeat) (§11.6, D-250).",
      "new: `EmptyGreedyClaim` therefore lands in the roster entry's diagnostic cell (the per-writer cell for runtime diagnostics and liveness) (§11.6, D-250).")
c.rep("old: The stream is per-occurrence.", "old: The stream is per-occurrence.", "new: These warnings form a per-occurrence stream.")
c.rep("old: The rate limit lives in the cells, as a structural bound rather than a policy layered over the stream.",
      "old: The rate limit lives in the cells, as a structural bound rather than a policy layered over the stream.",
      "new: The rate limit lives in the diagnostic cells, as a structural bound rather than a policy layered over the stream.")
c.rep("old: The stream surfaces through the published framework status (§11.2).",
      "old: The stream surfaces through the published framework status (§11.2).",
      "new: The stream surfaces through the published framework status (the frozen value each snapshot carries beside the signal table) (§11.2).")
c.after("new: The stream surfaces through the published framework status (the frozen value each snapshot carries beside the signal table) (§11.2).",
        "added: (the frozen value each snapshot carries beside the signal table)")
c.rep("new: The liveness heartbeat (§12.2) rides in the same cells, and the pacer's record (§10.7) sits beside the writers' records in the status.",
      "new: The liveness heartbeat (§12.2) rides in the same diagnostic cells, and the pacer's record (§10.7) sits beside the writers' records in the status.")
c.rep("new: `ChatteringBudget`, chattering, or localization-budget exhaustion (§10.4).",
      "new: `ChatteringBudget`, for chattering or localization-budget exhaustion (§10.4).")
c.rep("new: A localized event's bracketing budget runs out at a boundary (a published consistency point).",
      "new: A localized event's crossing instant is bracketed by root-finding. Its bracketing budget runs out at a boundary (a published consistency point).")
c.after("new: A localized event's crossing instant is bracketed by root-finding. Its bracketing budget runs out at a boundary (a published consistency point).",
        "added: A localized event's crossing instant is bracketed by root-finding.")
c.rep("old: The drain checks nothing.", "old: The drain checks nothing.", "new: The drain (the frame-top swap that applies staged writes) checks nothing.")
c.after("new: The drain (the frame-top swap that applies staged writes) checks nothing.", "added: (the frame-top swap that applies staged writes)")
c.rep("new: `EntryTypeMismatch` (§11.4) is a value unconvertible to its root input's declared type, rejected at staging for every writer.",
      "new: `EntryTypeMismatch` (§11.4) is a value unconvertible to the declared type of its root input (the root component's own input face), rejected at staging for every writer.")
c.after("new: `EntryTypeMismatch` (§11.4) is a value unconvertible to the declared type of its root input (the root component's own input face), rejected at staging for every writer.",
        "added: (the root component's own input face)")
c.rep("new: `MalformedDatum`, a tolerated device-side datum failure (§11.6, §13.4).",
      "new: `MalformedDatum`, a tolerated datum failure on the side of a device (any attached participant in the periphery) (§11.6, §13.4).")
c.after("new: `MalformedDatum`, a tolerated datum failure on the side of a device (any attached participant in the periphery) (§11.6, §13.4).",
        "added: (any attached participant in the periphery)")
c.rep("new: It is emitted by the author's loop via `report!(handle, …)` into the device's own cell (§11.8, D-105).",
      "new: It is emitted by the author's loop via `report!(handle, …)` into the device's own diagnostic cell (§11.8, D-105).")
c.rep("new: `ReplayDiscardedStaging`, staging discarded during replay (§12.7).",
      "new: `ReplayDiscardedStaging`, staging discarded during replay (the ordinary loop re-driven from a recorded trace) (§12.7).")
c.after("new: `ReplayDiscardedStaging`, staging discarded during replay (the ordinary loop re-driven from a recorded trace) (§12.7).",
        "added: (the ordinary loop re-driven from a recorded trace)")
c.rep("new: It reports a live batch found staged while the trace feeds the drain.",
      "new: It reports a live batch found staged while the trace (the primary record of a session) feeds the drain.")
c.after("new: It reports a live batch found staged while the trace (the primary record of a session) feeds the drain.",
        "added: (the primary record of a session)")
c.rep("old: It is therefore collected into the termination record and presented through the logging backend, never carried into a status (D-201, D-203).",
      "old: It is therefore collected into the termination record and presented through the logging backend, never carried into a status (D-201, D-203).",
      "new: It is therefore collected into the termination record (the stopped-sim value naming how the run ended) and presented through the logging backend, never carried into a status (D-201, D-203).")
c.after("new: It is therefore collected into the termination record (the stopped-sim value naming how the run ended) and presented through the logging backend, never carried into a status (D-201, D-203).",
        "added: (the stopped-sim value naming how the run ended)")
c.rep("new: and the run goes on without the device unless its attachment set `should_abort` (§11.6).",
      "new: and the run goes on without the device unless its attachment set `should_abort` (the per-attachment failure policy, an `attach!` keyword) (§11.6).")
c.after("new: and the run goes on without the device unless its attachment set `should_abort` (the per-attachment failure policy, an `attach!` keyword) (§11.6).",
        "added: (the per-attachment failure policy, an `attach!` keyword)")
c.rep("new: It lands in the loop's own cell, because `run!` mutates state (D-255).",
      "new: It lands in the loop's own diagnostic cell, because `run!` mutates state (D-255).")
c.save()
