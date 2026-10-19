# Chapter 13, step 5: editorial fixes, half 1 (units A and B)

The editorial fixer's log for units A and B. Sources: the EDITORIAL findings
of `chapter_pass_1.md` and `chapter_pass_2.md` that fall in units A and B, and
`step5_carry.md`'s rewraps for A and B. Pass 2 has no EDITORIAL finding in A
or B. Each entry replaces one whole paragraph, list item or table pair of
`units/<U>/new.md` at `5f21eba`. Apply the entries in order; each old text
occurs exactly once. Every replaced paragraph is rewrapped to 80 rendered
columns, link markup, backticks and asterisks collapsed; the table rows are
exempt. The `claims.md` changes that keep every span matching follow the
entries, as unified diffs against `5f21eba`; `inventory.json` is regenerated
by `checks/build_inventory.py`.

## Unit A

### 1. P1-1 (unit A, lines 3–15 at `5f21eba`)

Roadmap subjects of §13.3 and §13.4.

Old:

~~~~
This chapter fixes how a failure is reported once it happens, and what the
framework offers around it, taking as given what must be caught and where
([§8.4][s8-4]) and when each fact is checked ([§9][s9]). [§13.1][s13-1] covers
the reporting policy; [§13.2][s13-2] the diagnostic representation;
[§13.3][s13-3] the build primitives, `resolve` and the face-list accessors;
[§13.4][s13-4] the runtime failure story; [§13.5][s13-5] the distinction
between "the model reached a terminal state" and "the run should end";
[§13.6][s13-6] abnormal shutdown, one tail with two entries; [§13.7][s13-7] the
tooling and component library that follow; and [§13.8][s13-8] the diagnosis of
a rejected cycle. Two lessons FlightCore paid for ground this chapter. The first
is the compact-backtrace discipline, needed because parameterized model types
make rendered output unreadable. The second is the `SimulationTermination`
machinery, which [§13.5][s13-5] replaces.
~~~~

New:

~~~~
This chapter fixes how a failure is reported once it happens, and what the
framework offers around it, taking as given what must be caught and where ([§8.4][s8-4])
and when each fact is checked ([§9][s9]). [§13.1][s13-1] covers the reporting policy; [§13.2][s13-2] the
diagnostic representation; [§13.3][s13-3] the build primitives and how path resolution is
scoped by client; [§13.4][s13-4] how a runtime failure is caught, carried and reproduced;
[§13.5][s13-5] the distinction between "the model reached a terminal state" and "the run
should end"; [§13.6][s13-6] abnormal shutdown, one tail with two entries; [§13.7][s13-7] the
tooling and component library that follow; and [§13.8][s13-8] the diagnosis of a rejected
cycle. Two lessons FlightCore paid for ground this chapter. The first is the
compact-backtrace discipline, needed because parameterized model types make
rendered output unreadable. The second is the `SimulationTermination` machinery,
which [§13.5][s13-5] replaces.
~~~~

### 2. P1-2, P1-3 (unit A, lines 38–49 at `5f21eba`)

Probe gloss shortened; `T` introduced.

Old:

~~~~
- User code runs in the build's first three steps ([§9.1][s9-1]). The
  structure step reads the declaration bodies, interface-connection bodies
  among them. The nominal evaluation runs every user function once, through
  the stage-1 [probes](#g-probe) (the build's single evaluations of a user
  function with real values) and the probe chain. The activation at `T` runs
  the continuous tier's functions. When user code throws, there is no
  meaningful rest of the collection to report. A failed `input_wires` leaves
  the parent's face derivation undefined. A failed stage-2 probe starves every
  downstream probe of its wired inputs, because [probe
  values](#g-probe-value) (the fabricated values a build-time probe runs on)
  flow topologically ([§9.3][s9-3]). The first user-code exception aborts the
  phase ([D-057][d-057]).
~~~~

New:

~~~~
- User code runs in the build's first three steps ([§9.1][s9-1]). The structure step
  reads the declaration bodies, interface-connection bodies among them. The
  nominal evaluation runs every user function once, through the stage-1 [probes](#g-probe)
  (the build's single evaluations of a user function) and the probe chain. The
  activation at the scalar type `T` runs the continuous tier's functions. When
  user code throws, there is no meaningful rest of the collection to report. A
  failed `input_wires` leaves the parent's face derivation undefined. A failed
  stage-2 probe starves every downstream probe of its wired inputs, because
  [probe values](#g-probe-value) (the fabricated values a build-time probe runs on) flow
  topologically ([§9.3][s9-3]). The first user-code exception aborts the phase ([D-057][d-057]).
~~~~

### 3. P1-4 (unit A, lines 60–75 at `5f21eba`)

Class linked and glossed.

Old:

~~~~
Whether a pass can run past a failure follows from what it reads. The
structure step's walk yields two results, the component list and the wiring.
A wire that fails to resolve is recorded and claims nothing, so the
obligation check reports its input as unfed. Tier and event checking read
only the component list, so they run and merge. A structural failure leaves
the subtree behind it unknown. An unreadable or mixed class or a malformed
container is such a failure. No pass can read past it, so it throws alone.
In the two evaluating steps the probe chain consumes each check's subject as
it goes. A check that reads a failed probe does not run, so the chain's
fail-fast follows from the same rule. Outside the build the unit is the
call. Deployment validation ([§9.2][s9-2]) runs every check whose premise
holds and throws once. The only partial results ever carried past a failure
are violation lists and a claim table with the failed wires absent. None of
the three steps therefore needs machinery for carrying partial internal
results across a failure. That machinery was the cost that kept this
decision open, and it never materializes.
~~~~

New:

~~~~
Whether a pass can run past a failure follows from what it reads. The structure
step's walk yields two results, the component list and the wiring. A wire that
fails to resolve is recorded and claims nothing, so the obligation check reports
its input as unfed. Tier and event checking read only the component list, so
they run and merge. A structural failure leaves the subtree behind it unknown.
An unreadable or mixed [class](#g-class) (a component's primitive-vs-assembly status) or a
malformed container is such a failure. No pass can read past it, so it throws
alone. In the two evaluating steps the probe chain consumes each check's subject
as it goes. A check that reads a failed probe does not run, so the chain's
fail-fast follows from the same rule. Outside the build the unit is the call.
Deployment validation ([§9.2][s9-2]) runs every check whose premise holds and throws
once. The only partial results ever carried past a failure are violation lists
and a claim table with the failed wires absent. None of the three steps
therefore needs machinery for carrying partial internal results across a
failure. That machinery was the cost that kept this decision open, and it never
materializes.
~~~~

### 4. P1-29 (unit A, lines 93–100 at `5f21eba`)

Payload glossed at its first use in §13.2.

Old:

~~~~
**A diagnostic is a plain value from a small closed set of
[kinds](#g-kind)** ([D-058][d-058]). [Appendix C][sC] enumerates that set
normatively. For each kind it records the kind name, the [payload](#g-payload)
fields, the owning section, the severity, where the kind is raised and under
which policy ([D-214][d-214]). That index is the reference the [§8.4][s8-4]
walkthroughs, run as acceptance tests, and the error-message work are written
against. Tests match on kind plus payload fields, never on message text, so
messages are pure presentation ([D-058][d-058]).
~~~~

New:

~~~~
**A diagnostic is a plain value from a small closed set of [kinds](#g-kind)** ([D-058][d-058]). [Appendix
C][sC] enumerates that set normatively. For each kind it records the kind name, the
[payload](#g-payload) fields (the structured data a diagnostic carries beside its kind), the
owning section, the severity, where the kind is raised and under which policy
([D-214][d-214]). That index is the reference the [§8.4][s8-4] walkthroughs, run as acceptance
tests, and the error-message work are written against. Tests match on kind plus
payload fields, never on message text, so messages are pure presentation
([D-058][d-058]).
~~~~

### 5. P1-5 (unit A, lines 102–105 at `5f21eba`)

Did-you-mean glossed in the glossary's words, in its own sentence.

Old:

~~~~
Each kind carries its own structured payload. The payload holds endpoint
paths, [face](#g-face) names, expected and observed types, and the
*list-in-hand* a [did-you-mean](#g-did-you-mean) needs (the offending name plus
the list it should have matched). A kind *is* a Julia type.
~~~~

New:

~~~~
Each kind carries its own structured payload. The payload holds endpoint paths,
[face](#g-face) names, expected and observed types, and the *list-in-hand* a [did-you-mean](#g-did-you-mean)
needs. A did-you-mean is the offending name plus the list-in-hand it should have
matched. A kind *is* a Julia type.
~~~~

### 6. P1-6 (unit A, lines 107–116 at `5f21eba`)

`StepError` introduced before the species gloss.

Old:

~~~~
**Severity is a property of the kind, not of the occurrence**
([D-214][d-214]). It is `error` or `warning`, and it says whether an occurrence
ever throws. It is read as `severity(d)` and never stored per occurrence. The
severity field of [Appendix C][sC] is derived from it. Where an occurrence
surfaces (build, service or runtime) and how it is reported (collected,
fail-fast, logged or rate-limited) are the *raised* and *policy* fields of
[Appendix C][sC]. Those two fields describe the occurrence, not the kind.
`BundleFieldError`, for example, is raised at the [probe](#g-probe) and as a `StepError`
[species](#g-species) (a `StepError` whose `cause` is a diagnostic)
thereafter.
~~~~

New:

~~~~
**Severity is a property of the kind, not of the occurrence** ([D-214][d-214]). It is `error`
or `warning`, and it says whether an occurrence ever throws. It is read as
`severity(d)` and never stored per occurrence. The severity field of [Appendix C][sC] is
derived from it. Where an occurrence surfaces (build, service or runtime) and
how it is reported (collected, fail-fast, logged or rate-limited) are the *raised*
and *policy* fields of [Appendix C][sC]. Those two fields describe the occurrence, not
the kind. `BundleFieldError`, for example, is raised at the [probe](#g-probe) and, at runtime,
as a [species](#g-species) of the runtime carrier `StepError` ([§13.4][s13-4]). A species is a `StepError`
whose `cause` is a diagnostic.
~~~~

### 7. P1-29, P1-30 (unit A, lines 118–129 at `5f21eba`)

Carrier exception glossed; paragraph rewrapped.

Old:

~~~~
Checking passes return diagnostics. The step barrier (each of the build's
three steps throws before the next begins) throws a single
`DiagnosticError` wrapping the collection. A fail-fast site throws the same
[carrier exception](#g-carrier-exception) holding one diagnostic. **The
carrier's type parameter spells the policy** ([D-222][d-222]). It is the
diagnostic's kind for a fail-fast throw and `Vector{Diagnostic}` for a
collected one. A test therefore asserts policy and kind at once with
`@test_throws DiagnosticError{Kind}`. The runtime carrier `StepError{C}` takes
a parameter of its own, the type of its `cause` ([§13.4][s13-4],
[D-225][d-225]). `showerror` renders a collection
compiler-style, grouped by kind and sorted by path. It renders a single
diagnostic as its own line.
~~~~

New:

~~~~
Checking passes return diagnostics. The step barrier (each of the build's three
steps throws before the next begins) throws a single `DiagnosticError` wrapping
the collection. A fail-fast site throws the same [carrier exception](#g-carrier-exception) (the single
exception diagnostics travel in when thrown) holding one diagnostic. **The
carrier's type parameter spells the policy** ([D-222][d-222]). It is the diagnostic's kind
for a fail-fast throw and `Vector{Diagnostic}` for a collected one. A test
therefore asserts policy and kind at once with
`@test_throws DiagnosticError{Kind}`. The runtime carrier `StepError{C}` takes a
parameter of its own, the type of its `cause` ([§13.4][s13-4], [D-225][d-225]). `showerror` renders a
collection compiler-style, grouped by kind and sorted by path. It renders a
single diagnostic as its own line.
~~~~

### 8. P1-7 (unit A, lines 149–153 at `5f21eba`)

First rendering rule named as a rule.

Old:

~~~~
- The first is strings, never instances. Diagnostics carry paths and names as
  strings, never [component](#g-component) instances and never component
  types. This is the lesson of FlightCore's `compact_backtrace`. Expected and
  observed *[port](#g-port)* types are the one payload exception, and they are
  small. Examples are a `Float64` against a `Bool`, and a NamedTuple field diff.
~~~~

New:

~~~~
- The first rule is *strings, never instances*. Diagnostics carry paths and names
  as strings, never [component](#g-component) instances and never component types. This is the
  lesson of FlightCore's `compact_backtrace`. Expected and observed *[port](#g-port)* types are
  the one payload exception, and they are small. Examples are a `Float64` against
  a `Bool`, and a NamedTuple field diff.
~~~~

### 9. P1-7 (unit A, lines 154–157 at `5f21eba`)

Second rendering rule named as a rule.

Old:

~~~~
- The second is that the didactic style is policy. Every diagnostic states
  the fix or the lists-in-hand, not just the violation. Examples are "return
  `zero(x.ω)`, not `0`" and "no input `throtle`; did you mean `throttle`?", or
  the child's face list shown alongside the unknown name given to `except`.
~~~~

New:

~~~~
- The second rule is that the didactic style is policy. Every diagnostic states
  the fix or the lists-in-hand, not just the violation. Examples are "return
  `zero(x.ω)`, not `0`" and "no input `throtle`; did you mean `throttle`?", or the
  child's face list shown alongside the unknown name given to `except`.
~~~~

### 10. P1-30 (unit A, lines 159–176 at `5f21eba`)

Line 168 rewrapped (138 columns).

Old:

~~~~
A user-code exception is wrapped in a framing diagnostic, `UserCodeFraming`,
with the original exception as `cause`. The framing carries the component
path, the function that threw, and the probe context, which is the
[bundle](#g-bundle)'s field names (the bundle is the NamedTuple of zero-copy
views a component function receives) and the synthesized inputs as a
spelling, never as values ([D-248][d-248]). The didactic framing therefore
renders first and the raw throw second. **The framed set is every
user-authored method the build invokes** ([D-248][d-248]). The declarations
of [§8.2][s8-2] and the probed functions of [§9.3][s9-3] are framed alike,
each reached through one framing accessor rather than a bare call. A declaration takes no bundle, so only the plain framing applies to it.
Three exceptions pass through the framing unwrapped, because none of them is
user code failing. They are a `DiagnosticError` carrier a check inside the
call threw, an `InternalInvariant` (the exception a framework self-check
raises, outside the kind set) ([D-215][d-215]), and an `InterruptException`.
At runtime the same throw reaches the one runtime catch site
([§13.4][s13-4]) instead. There a `FieldError` matched as below becomes a
`BundleFieldError` species, and any other exception rides as the
`StepError`'s `cause`.
~~~~

New:

~~~~
A user-code exception is wrapped in a framing diagnostic, `UserCodeFraming`, with
the original exception as `cause`. The framing carries the component path, the
function that threw, and the probe context, which is the [bundle](#g-bundle)'s field names
(the bundle is the NamedTuple of zero-copy views a component function receives)
and the synthesized inputs as a spelling, never as values ([D-248][d-248]). The didactic
framing therefore renders first and the raw throw second. **The framed set is
every user-authored method the build invokes** ([D-248][d-248]). The declarations of [§8.2][s8-2]
and the probed functions of [§9.3][s9-3] are framed alike, each reached through one
framing accessor rather than a bare call. A declaration takes no bundle, so only
the plain framing applies to it. Three exceptions pass through the framing
unwrapped, because none of them is user code failing. They are a `DiagnosticError`
carrier a check inside the call threw, an `InternalInvariant` (the exception a
framework self-check raises, outside the kind set) ([D-215][d-215]), and an
`InterruptException`. At runtime the same throw reaches the one runtime catch site
([§13.4][s13-4]) instead. There a `FieldError` matched as below becomes a `BundleFieldError`
species, and any other exception rides as the `StepError`'s `cause`.
~~~~

### 11. P1-8 (unit A, lines 211–220 at `5f21eba`)

"slot" becomes "category".

Old:

~~~~
The build produces artifacts, so its warnings live on them. [§9.2][s9-2]
states which artifacts carry them, how `warnings(x)` reads the list, and how
a step that throws or completes presents them. The build's warning set holds
`EmptyFaceSelection` ([§8.8][s8-8], [D-251][d-251]). The warning set of the
[`Deployment`](#g-deployment) (the scalar-free artifact the grid parameters
fix) holds `GridUtilization` ([D-254][d-254]). The
unconnected-output warning stays rejected ([§6.1][s6-1], [D-084][d-084]), so
the *collected*-warning slot stays open and empty. A warnings-as-errors switch
is rejected, since a warning is a fact about the model, not a defect
([D-250][d-250]).
~~~~

New:

~~~~
The build produces artifacts, so its warnings live on them. [§9.2][s9-2] states which
artifacts carry them, how `warnings(x)` reads the list, and how a step that throws
or completes presents them. The build's warning set holds `EmptyFaceSelection`
([§8.8][s8-8], [D-251][d-251]). The warning set of the [`Deployment`](#g-deployment) (the scalar-free artifact the
grid parameters fix) holds `GridUtilization` ([D-254][d-254]). The unconnected-output
warning stays rejected ([§6.1][s6-1], [D-084][d-084]), so the *collected*-warning category stays
open and empty. A warnings-as-errors switch is rejected, since a warning is a
fact about the model, not a defect ([D-250][d-250]).
~~~~

### 12. P1-12 (unit A, lines 222–229 at `5f21eba`)

Diagnostic cell glossed in Appendix D's words.

Old:

~~~~
A stopped-sim service returns an artifact, so its warnings live on it.
`trim!` returns a `TrimReport`, and `TrimCommitEvents`, `TrimCommitResiduals`
and `TrimCommitChecks` are that report's fields ([§14.8][s14-8]). The line the
call prints at return is presentation. `attach!` is the other side of the
criterion. It mutates the [roster](#g-roster) (the list of attached device
entries). `EmptyGreedyClaim` therefore lands in the roster entry's [diagnostic
cell](#g-diagnostic-cell) (the single-writer cell each writer owns for
diagnostics and heartbeat) ([§11.6][s11-6], [D-250][d-250]).
~~~~

New:

~~~~
A stopped-sim service returns an artifact, so its warnings live on it. `trim!`
returns a `TrimReport`, and `TrimCommitEvents`, `TrimCommitResiduals` and
`TrimCommitChecks` are that report's fields ([§14.8][s14-8]). The line the call prints at
return is presentation. `attach!` is the other side of the criterion. It mutates
the [roster](#g-roster) (the list of attached device entries). `EmptyGreedyClaim` therefore
lands in the roster entry's [diagnostic cell](#g-diagnostic-cell) (the per-writer cell for runtime
diagnostics and liveness) ([§11.6][s11-6], [D-250][d-250]).
~~~~

### 13. P1-9, P1-29 (unit A, lines 231–243 at `5f21eba`)

The stream given its antecedent; bare cells made diagnostic cells; framework status glossed.

Old:

~~~~
The runtime mutates state, so its warnings live in that state's status. The
stream is per-occurrence. The per-writer diagnostic cells carry it
([§11.8][s11-8], [D-136][d-136]). The rate limit lives in the cells, as a
structural bound rather than a policy layered over the stream. The bound is a
bounded ring plus per-kind suppressed counts, drained at frame top. So
"rate-limited wherever its source can repeat" holds of every kind below
without any kind arranging it. The stream surfaces through the published
[framework status](#g-framework-status) ([§11.2][s11-2]). The liveness
heartbeat ([§12.2][s12-2]) rides in the same cells, and the pacer's record
([§10.7][s10-7]) sits beside the writers' records in the status. The stream
is never collected, since there is no collection to join. Nothing in the
argument of [D-084][d-084] applies to it. That decision is about what the
*build* warns on.
~~~~

New:

~~~~
The runtime mutates state, so its warnings live in that state's status. These
warnings form a per-occurrence stream. The per-writer diagnostic cells carry it
([§11.8][s11-8], [D-136][d-136]). The rate limit lives in the diagnostic cells, as a structural
bound rather than a policy layered over the stream. The bound is a bounded ring
plus per-kind suppressed counts, drained at frame top. So "rate-limited wherever
its source can repeat" holds of every kind below without any kind arranging it.
The stream surfaces through the published [framework status](#g-framework-status) (the frozen value
each snapshot carries beside the signal table) ([§11.2][s11-2]). The liveness heartbeat
([§12.2][s12-2]) rides in the same diagnostic cells, and the pacer's record ([§10.7][s10-7]) sits
beside the writers' records in the status. The stream is never collected, since
there is no collection to join. Nothing in the argument of [D-084][d-084] applies to it.
That decision is about what the *build* warns on.
~~~~

### 14. P1-10, P1-29 (unit A, lines 247–250 at `5f21eba`)

The ChatteringBudget line no longer reads as three items; localized glossed in its own sentence.

Old:

~~~~
- `ChatteringBudget`, [chattering](#g-chattering), or localization-budget
  exhaustion ([§10.4][s10-4]). A [localized](#g-localized) event's bracketing
  budget runs out at a [boundary](#g-boundary) (a published consistency
  point).
~~~~

New:

~~~~
- `ChatteringBudget`, for [chattering](#g-chattering) or localization-budget exhaustion ([§10.4][s10-4]). A
  [localized](#g-localized) event's crossing instant is bracketed by root-finding. The event's
  bracketing budget runs out at a [boundary](#g-boundary) (a published consistency point).
~~~~

### 15. P1-29, P1-30, carry (unit A, lines 256–264 at `5f21eba`)

Drain and root input glossed; lines 260 and 263 rewrapped.

Old:

~~~~
- The write-surface and batch-entry violations ([§11.3][s11-3],
  [§11.4][s11-4]), all raised at staging. The [drain](#g-drain) checks
  nothing. `OutOfClaimEntry` ([§11.3][s11-3]) is an enumerated surface's
  binding drift, a name with no position in the attach-compiled schema.
  `ClaimedFaceEntry` ([§11.3][s11-3], [§11.4][s11-4]) is a harness write to a face claimed in the run's frozen partition, and it names
  the incumbent. The stopped-sim attach also fires it when it renormalizes a
  pending [batch](#g-batch). `EntryTypeMismatch` ([§11.4][s11-4]) is a value
  unconvertible to its [root input](#g-root-input)'s declared type, rejected at staging for
  every writer.
~~~~

New:

~~~~
- The write-surface and batch-entry violations ([§11.3][s11-3], [§11.4][s11-4]), all raised at
  staging. The [drain](#g-drain) (the frame-top swap that applies staged writes) checks
  nothing. `OutOfClaimEntry` ([§11.3][s11-3]) is an enumerated surface's binding drift, a
  name with no position in the attach-compiled schema. `ClaimedFaceEntry` ([§11.3][s11-3],
  [§11.4][s11-4]) is a harness write to a face claimed in the run's frozen partition, and
  it names the incumbent. The stopped-sim attach also fires it when it
  renormalizes a pending [batch](#g-batch). `EntryTypeMismatch` ([§11.4][s11-4]) is a value
  unconvertible to the declared type of its [root input](#g-root-input) (the root component's own
  input face), rejected at staging for every writer.
~~~~

### 16. P1-29, P1-9 (unit A, lines 265–268 at `5f21eba`)

Device glossed; the device's own diagnostic cell.

Old:

~~~~
- `MalformedDatum`, a tolerated [device](#g-device)-side datum failure
  ([§11.6][s11-6], [§13.4][s13-4]). It is emitted by the author's loop via
  `report!(handle, …)` into the device's own cell ([§11.8][s11-8],
  [D-105][d-105]). It replaces FlightCore's `InputMappingError`.
~~~~

New:

~~~~
- `MalformedDatum`, a tolerated datum failure on the side of a [device](#g-device) (any
  attached participant in the periphery) ([§11.6][s11-6], [§13.4][s13-4]). It is emitted by the
  author's loop via `report!(handle, …)` into the device's own diagnostic cell
  ([§11.8][s11-8], [D-105][d-105]). It replaces FlightCore's `InputMappingError`.
~~~~

### 17. P1-29 (unit A, lines 269–271 at `5f21eba`)

Replay and trace glossed.

Old:

~~~~
- `ReplayDiscardedStaging`, staging discarded during [replay](#g-replay)
  ([§12.7][s12-7]). It reports a live batch found staged while the
  [trace](#g-trace) feeds the drain.
~~~~

New:

~~~~
- `ReplayDiscardedStaging`, staging discarded during [replay](#g-replay) (the ordinary loop
  re-driven from a recorded trace) ([§12.7][s12-7]). It reports a live batch found staged
  while the [trace](#g-trace) (the primary record of a session) feeds the drain.
~~~~

### 18. P1-29 (unit A, lines 274–279 at `5f21eba`)

Termination record glossed.

Old:

~~~~
- `DeviceJoinTimeout`, a device join timeout ([§12.4][s12-4]). A device task
  exceeds the shutdown join timeout and is abandoned by name rather than
  hanging `run!`. It arises after the terminal snapshot. It is therefore
  collected into the [termination record](#g-termination-record) and
  presented through the logging backend, never carried into a status
  ([D-201][d-201], [D-203][d-203]).
~~~~

New:

~~~~
- `DeviceJoinTimeout`, a device join timeout ([§12.4][s12-4]). A device task exceeds the
  shutdown join timeout and is abandoned by name rather than hanging `run!`. It
  arises after the terminal snapshot. It is therefore collected into the
  [termination record](#g-termination-record) (the stopped-sim value naming how the run ended) and
  presented through the logging backend, never carried into a status ([D-201][d-201],
  [D-203][d-203]).
~~~~

### 19. P1-29 (unit A, lines 280–283 at `5f21eba`)

`should_abort` linked and glossed in §13.2.

Old:

~~~~
- `DeviceCrash`, a device crash ([§12.4][s12-4], [§13.4][s13-4]). A genuine
  bug takes the per-device crash path. The framework wrapper catches a device
  task's failure and reports `DeviceCrash`, and the run goes on without the
  device unless its attachment set `should_abort` ([§11.6][s11-6]).
~~~~

New:

~~~~
- `DeviceCrash`, a device crash ([§12.4][s12-4], [§13.4][s13-4]). A genuine bug takes the per-device
  crash path. The framework wrapper catches a device task's failure and reports
  `DeviceCrash`, and the run goes on without the device unless its attachment set
  [`should_abort`](#g-should_abort) (the per-attachment failure policy, an `attach!` keyword) ([§11.6][s11-6]).
~~~~

### 20. P1-9, P1-30 (unit A, lines 284–286 at `5f21eba`)

The loop's own diagnostic cell; the second blank line before §13.3 removed. The old text runs through line 286, the file's trailing blank line, so the file now ends with one newline and the assembled chapter has one blank line before §13.3.

Old:

~~~~
- `UnboundedRun`, an unbounded run ([§13.5][s13-5]). It lands in the loop's
  own cell, because `run!` mutates state ([D-255][d-255]).

~~~~

New:

~~~~
- `UnboundedRun`, an unbounded run ([§13.5][s13-5]). It lands in the loop's own diagnostic
  cell, because `run!` mutates state ([D-255][d-255]).
~~~~

## Unit B

### 21. P1-13 (unit B, lines 3–7 at `5f21eba`)

Context paragraph ends with the parts sentence; the bold sentence opens the list's lead-in.

Old:

~~~~
The `input_passthrough` sketch ([§8.8][s8-8]) calls two of the primitives below
without defining them. **All three are normative in the forms given here**
([D-061][d-061]). This section gives the three forms, the two duties
resolution enforces, which client each duty binds and why, and the standing
of `resolve_terminal`.
~~~~

New:

~~~~
The `input_passthrough` sketch ([§8.8][s8-8]) calls two of the primitives below without
defining them. This section gives the three forms, the two duties resolution
enforces, which client each duty binds and why, and the standing of
`resolve_terminal`.

**All three are normative in the forms given here** ([D-061][d-061]).
~~~~

### 22. P1-14 (unit B, lines 11–15 at `5f21eba`)

Bare "entries" becomes "face names" (D-061: face-name strings).

Old:

~~~~
- `input_faces(c)` / `output_faces(c) → Vector{String}` return the stringified
  keys of a leaf's `u_types` / `y_types` (the key set is
  `T`-independent). For an [assembly](#g-assembly) they return the entries of
  `input_wires(c)` / `output_wires(c)`. Declaration order is
  preserved, which gives deterministic printouts and stable diagnostics.
~~~~

New:

~~~~
- `input_faces(c)` / `output_faces(c) → Vector{String}` return the stringified keys
  of a leaf's `u_types` / `y_types` (the key set is `T`-independent). For an [assembly](#g-assembly)
  they return the face names of `input_wires(c)` / `output_wires(c)`. Declaration
  order is preserved, which gives deterministic printouts and stable
  diagnostics.
~~~~

### 23. P1-29 (unit B, lines 21–33 at `5f21eba`)

Port glossed.

Old:

~~~~
Resolution enforces two duties, and they belong to different clients. The
first is the one-level rule ([§6.1][s6-1], [D-207][d-207]). A connection
endpoint resolves to an immediate child and one of its faces. A wiring path
reaching further is a build error, `PathResolution`, whatever the declared
field types along it. The second is the [generic-holding](#g-generic-holding)
rule, which governs the deep paths the read side still writes. It is enforced
by the service walk, which follows *declared field types* alongside
instances. A segment that traverses *past* a generically-held field (one whose
declared type is non-concrete) is a diagnostic, even though the concrete
instance in hand would resolve it. Resolving *to* a generic child is
[port](#g-port)-level access and legal. An unknown segment errors with the
sibling field list in hand. Paths are validated before anything runs on them,
and renames break loudly ([D-061][d-061]).
~~~~

New:

~~~~
Resolution enforces two duties, and they belong to different clients. The first
is the one-level rule ([§6.1][s6-1], [D-207][d-207]). A connection endpoint resolves to an
immediate child and one of its faces. A wiring path reaching further is a build
error, `PathResolution`, whatever the declared field types along it. The second is
the [generic-holding](#g-generic-holding) rule, which governs the deep paths the read side still
writes. It is enforced by the service walk, which follows *declared field types*
alongside instances. A segment that traverses *past* a generically-held field (one
whose declared type is non-concrete) is a diagnostic, even though the concrete
instance in hand would resolve it. Resolving *to* a generic child is legal, as
access at the level of a [port](#g-port) (one declared input or output). An unknown segment
errors with the sibling field list in hand. Paths are validated before anything
runs on them, and renames break loudly ([D-061][d-061]).
~~~~

### 24. P1-29 (unit B, lines 43–44 at `5f21eba`)

Taps, bindings and snapshot glossed in the table (rows exempt from the wrap).

Old:

~~~~
| service | [condition](#g-condition) entries (the path-addressed sparse overlay that sets a build's state), trim `reads`, [taps](#g-taps), [device](#g-device) read [bindings](#g-binding), log extraction by `series` ([§14.3][s14-3], [§14.7][s14-7], [§14.10][s14-10], [§11.2][s11-2], [D-406][d-406], [D-407][d-407]) | strict: no traversal past a generic child, checked at the authoring or mount level |
| inspection | [snapshot](#g-snapshot) and log inspection ([D-310][d-310]) | the instance walk |
~~~~

New:

~~~~
| service | [condition](#g-condition) entries (the path-addressed sparse overlay that sets a build's state), trim `reads`, [taps](#g-taps) (the selector lists linearization seeds and reports), [device](#g-device) read [bindings](#g-binding) (the values passed at `attach!` that make a device framework-legible), log extraction by `series` ([§14.3][s14-3], [§14.7][s14-7], [§14.10][s14-10], [§11.2][s11-2], [D-406][d-406], [D-407][d-407]) | strict: no traversal past a generic child, checked at the authoring or mount level |
| inspection | [snapshot](#g-snapshot) (the immutable per-boundary publication) and log inspection ([D-310][d-310]) | the instance walk |
~~~~

### 25. P1-29 (unit B, lines 46–60 at `5f21eba`)

Seam glossed.

Old:

~~~~
Each client's treatment has its own warrant. Wiring is what the law
([§6.1][s6-1]) is stated for, so wiring resolution applies that law verbatim.
Under one-level routing the generic-holding question never arises there,
because an endpoint stops before any field it could traverse past. Service
paths are checked at the authoring or mount level for two reasons. First, the
locality law is an authoring-level law, and absolute paths are a compiled
derivative ([§14.2][s14-2]). Second, the mount itself checks a mount prefix,
where the problem's authored names resolve through the export chain from the
mount point ([§14.9][s14-9]). So the service check covers the authored path
below that prefix. Drift stays loud. A binding's unknown path or name is
refused at attach, as a `PathResolution` or a `ReadResolution`, with a
[did-you-mean](#g-did-you-mean) (the offending name plus the list-in-hand it
should have matched) ([D-406][d-406]). Inspection walks instances instead. A
generic [seam](#g-seam) is not an error for a client that never claimed
substitutability. "What is in *this* build" is inspection's defining question.
~~~~

New:

~~~~
Each client's treatment has its own warrant. Wiring is what the law ([§6.1][s6-1]) is
stated for, so wiring resolution applies that law verbatim. Under one-level
routing the generic-holding question never arises there, because an endpoint
stops before any field it could traverse past. Service paths are checked at the
authoring or mount level for two reasons. First, the locality law is an
authoring-level law, and absolute paths are a compiled derivative ([§14.2][s14-2]).
Second, the mount itself checks a mount prefix, where the problem's authored
names resolve through the export chain from the mount point ([§14.9][s14-9]). So the
service check covers the authored path below that prefix. Drift stays loud. A
binding's unknown path or name is refused at attach, as a `PathResolution` or a
`ReadResolution`, with a [did-you-mean](#g-did-you-mean) (the offending name plus the list-in-hand it
should have matched) ([D-406][d-406]). Inspection walks instances instead. A generic [seam](#g-seam)
(a narrow, named interface kept deliberately thin) is not an error for a client
that never claimed substitutability. "What is in *this* build" is inspection's
defining question.
~~~~

### 26. P1-17 (unit B, lines 78–80 at `5f21eba`)

"rules" becomes "treatments" for the three client treatments.

Old:

~~~~
Which of the three rules a client resolves under is internal framework fact,
never user-facing API ([D-130][d-130]). The two ways of applying one plan
([§14.4][s14-4]) use the same arrangement and have the same status.
~~~~

New:

~~~~
Which of the three treatments a client resolves under is internal framework
fact, never user-facing API ([D-130][d-130]). The two ways of applying one plan ([§14.4][s14-4])
use the same arrangement and have the same status.
~~~~

### 27. P1-19, P1-29, carry (unit B, lines 88–94 at `5f21eba`)

Boundary linked and glossed in its own sentence; "boundary macro-sequence"; the catch's antecedent named; line 88 rewrapped.

Old:

~~~~
A runtime failure of model code is a throw inside a [frame](#g-frame) (one iteration of the
loop) or inside [boundary zero](#g-boundary-zero), the initialization
boundary, which runs the ordinary macro-sequence with an empty integrate. The
framework catches it at one site, records where execution stood, and names
how to reproduce it. This section covers, in order, where a failure is
caught, the runtime carrier, the interrupt, the disposition, reproduction,
boundary zero, the nonfinite check and device-side failures.
~~~~

New:

~~~~
A runtime failure of model code is a throw inside a [frame](#g-frame) (one iteration of the
loop) or inside [boundary zero](#g-boundary-zero). Boundary zero is the initialization [boundary](#g-boundary) (a
published consistency point), and it runs the ordinary boundary macro-sequence
with an empty integrate. The framework catches the failure at one site, records
where execution stood, and names how to reproduce it. This section covers, in
order, where a failure is caught, the runtime carrier, the interrupt, the
disposition, reproduction, boundary zero, the nonfinite check and device-side
failures.
~~~~

### 28. P1-20, P1-24, P1-29 (unit B, lines 98–106 at `5f21eba`)

`Model` glossed before the bold; the guarded sequence introduced; ticks and component glossed.

Old:

~~~~
**The [`Model`](#g-model)'s `frame!` wraps each whole frame, every
[boundary](#g-boundary) it settles included, in a single `try`**, and its
`init!` wraps boundary zero the same way ([D-317][d-317]). The `Model` is the
deployment and its executor at one scalar. A boundary's macro-sequence runs
integrate → project → event iteration → [ticks](#g-tick) → publication.
**`frame!` never wraps per stage or per [component](#g-component)**
([D-059][d-059]). The loop wraps each frame in a `try` of its own, which
decides the failure's disposition (below) and builds no carrier
([D-317][d-317]).
~~~~

New:

~~~~
The [`Model`](#g-model) is the deployment and its executor at one scalar. **The `Model`'s `frame!`
wraps each whole frame, every boundary it settles included, in a single `try`**, and
its `init!` wraps boundary zero the same way ([D-317][d-317]). The code inside the `Model`'s
`try` is the guarded sequence. A boundary's macro-sequence runs integrate →
project → event iteration → [ticks](#g-tick) → publication. Ticks are the instants at which
discrete leaves run their stages and update. **`frame!` never wraps per stage or per
[component](#g-component)** (the unit of modeling, a leaf or an assembly of components) ([D-059][d-059]).
The loop wraps each frame in a `try` of its own, which decides the failure's
disposition (below) and builds no carrier ([D-317][d-317]).
~~~~

### 29. P1-21, P1-29 (unit B, lines 108–128 at `5f21eba`)

"Framing information" becomes "Where execution stood"; guard and RHS glossed.

Old:

~~~~
Framing information does not need to be *caught* into existence. The
[executor](#g-executor) (the compiled form of the stage
[execution order](#g-execution-order)) maintains an
[execution cursor](#g-execution-cursor), a plain mutable field of the
executor recording where execution stands in the compiled order
([D-059][d-059]). The cursor records three facts. The first is the
component, by its index in the structure's component list, the index the
execution order lists ([D-261][d-261]). That order is the one
[`Outputs`](#g-outputs) (the nominal evaluation's product, the port classes
and the execution order) carries. The second is which function is running,
one of `y_state`, `y_direct`, `x_deriv`, `s_update`, a [guard](#g-guard), a
handler, or `x_projection`. The third is the boundary phase, one of the
frame-top drain, integration stage *k*, the arrival [sweep](#g-sweep) (one pass
through the execution order), the θ = 0
validation, a localization trial, projection, event round *r*, or the ticks.
Maintaining the cursor costs one cheap store per dispatch on a single-tasked
executor, with no allocation and no exception handlers. It covers every
user-code surface uniformly, including the forgettable ones. Those are the
[RHS](#g-flow) evaluations at interior RK stage points and the guard
evaluations at the trial points of ITP or Brent root-finding
([§10.4][s10-4]).
~~~~

New:

~~~~
Where execution stood does not need to be *caught* into existence. The [executor](#g-executor)
(the compiled form of the stage [execution order](#g-execution-order)) maintains an [execution cursor](#g-execution-cursor),
a plain mutable field of the executor recording where execution stands in the
compiled order ([D-059][d-059]). The cursor records three facts. The first is the
component, by its index in the structure's component list, the index the
execution order lists ([D-261][d-261]). That order is the one [`Outputs`](#g-outputs) (the nominal
evaluation's product, the port classes and the execution order) carries. The
second is which function is running, one of `y_state`, `y_direct`, `x_deriv`,
`s_update`, a [guard](#g-guard) (the declared function defining an event's predicate), a
handler, or `x_projection`. The third is the boundary phase, one of the frame-top
drain, integration stage *k*, the arrival [sweep](#g-sweep) (one pass through the execution
order), the θ = 0 validation, a localization trial, projection, event round *r*,
or the ticks. Maintaining the cursor costs one cheap store per dispatch on a
single-tasked executor, with no allocation and no exception handlers. It covers
every user-code surface uniformly, including the forgettable ones. Those are the
evaluations of the [RHS](#g-flow) (the continuous derivative function) at interior RK stage
points and the guard evaluations at the trial points of ITP or Brent
root-finding ([§10.4][s10-4]).
~~~~

### 30. P1-23, P1-29 (unit B, lines 140–154 at `5f21eba`)

Cursor frame gloss no longer repeats its sentence; replay glossed in its own sentence.

Old:

~~~~
The catch site wraps the original exception in `StepError`, the runtime
counterpart of the `DiagnosticError` [carrier](#g-carrier-exception) (the
single exception diagnostics travel in when thrown). A `StepError` carries
five things. They are the cursor frame (the copy of the cursor a `StepError`
carries), the time, the frame-entry boundary index, the host of the catch,
and the original exception as `cause`. The time is the clock at the failure,
a boundary time in a boundary phase, the stage or trial time inside
integration. **The frame-entry boundary index is the [replay](#g-replay)
pointer** ([D-128][d-128]). It names the frame-top boundary at which the
failing frame began. That frame top is a grid boundary or boundary zero, and
it is always a legal replay halt ([§12.7][s12-7]). The host names the catch
that took the throw. It is `:loop` for a throw inside a frame, and
`:boundary_zero` for a throw inside the boundary zero that `init!` runs. A
`StepError` renders under the doctrine of [§13.2][s13-2]. The cursor frame
and the reproduction come first, the cause second, and names are strings.
~~~~

New:

~~~~
The catch site wraps the original exception in `StepError`, the runtime
counterpart of the `DiagnosticError` [carrier](#g-carrier-exception) (the single exception diagnostics
travel in when thrown). A `StepError` carries five things. They are the cursor
frame (the cursor's copy at the catch), the time, the frame-entry boundary
index, the host of the catch, and the original exception as `cause`. The time is
the clock at the failure, a boundary time in a boundary phase, the stage or
trial time inside integration. **The frame-entry boundary index is the [replay](#g-replay)
pointer** ([D-128][d-128]). Replay is the ordinary loop re-driven from a recorded trace.
The pointer names the frame-top boundary at which the failing frame began. That
frame top is a grid boundary or boundary zero, and it is always a legal replay
halt ([§12.7][s12-7]). The host names the catch that took the throw. It is `:loop` for a
throw inside a frame, and `:boundary_zero` for a throw inside the boundary zero
that `init!` runs. A `StepError` renders under the doctrine of [§13.2][s13-2]. The cursor
frame and the reproduction come first, the cause second, and names are strings.
~~~~

### 31. P1-21 (unit B, lines 170–180 at `5f21eba`)

"unframed" and "the framed path" reworded (R7).

Old:

~~~~
**The cause's type is the carrier's parameter** ([D-225][d-225]).
`StepError{C}` takes the type of its `cause`, bounded to a diagnostic or an
exception. A species is therefore `StepError{Kind}`, and a raw throw is
`StepError{ArgumentError}` and the like. `isa StepError` matches both
([D-225][d-225]). A test asserts a species as
`@test_throws StepError{ConformanceFailure}`, the runtime spelling of the build
carrier's idiom ([§13.2][s13-2]). A collected carrier riding as `cause` is an
exception and falls under that arm. A bare value thrown deliberately by model
code is neither, and the constructor refuses it unframed. The framework does
not handle that throw ([D-225][d-225]). The cursor frame and the pointer are
then lost, and the lifecycle does not move as it does on the framed path.
~~~~

New:

~~~~
**The cause's type is the carrier's parameter** ([D-225][d-225]). `StepError{C}` takes the type
of its `cause`, bounded to a diagnostic or an exception. A species is therefore
`StepError{Kind}`, and a raw throw is `StepError{ArgumentError}` and the like.
`isa StepError` matches both ([D-225][d-225]). A test asserts a species as
`@test_throws StepError{ConformanceFailure}`, the runtime spelling of the build
carrier's idiom ([§13.2][s13-2]). A collected carrier riding as `cause` is an exception and
falls under that arm. A bare value thrown deliberately by model code is neither,
and the constructor refuses it, so it leaves the catch unwrapped. The framework
does not handle that throw ([D-225][d-225]). The cursor frame and the pointer are then
lost, and the lifecycle does not move as it does when the catch builds a
`StepError`.
~~~~

### 32. P1-24 (unit B, lines 196–207 at `5f21eba`)

"the branch" becomes "the interrupt branch".

Old:

~~~~
An `InterruptException` is the one exception the catch site never wraps
([D-317][d-317]). It is not model code failing. It is the operator's stop
command ([§12.4][s12-4]). So the catch site discriminates it and routes it to
the stop path ([D-132][d-132]). The run takes the ordinary graceful tail and
ends `stopped`, never `errored` under a `StepError`. With the boundary masking
in force ([§12.4][s12-4]) a single interrupt never reaches the branch. It is
deferred to a frame-top, wait or pause-block unmask point ([§12.4][s12-4],
[D-294][d-294]), and never raises inside the guarded sequence. Julia's forced
throw after repeated interrupts does reach it, with the disposition
[§12.4][s12-4] gives it ([D-398][d-398]). The branch is kept for that case
and defensively, because the cost of being wrong about the masking is a
terminally errored session in place of a clean stop.
~~~~

New:

~~~~
An `InterruptException` is the one exception the catch site never wraps ([D-317][d-317]).
It is not model code failing. It is the operator's stop command ([§12.4][s12-4]). So the
catch site discriminates it and routes it to the stop path ([D-132][d-132]). The run
takes the ordinary graceful tail and ends `stopped`, never `errored` under a
`StepError`. With the boundary masking in force ([§12.4][s12-4]) a single interrupt never
reaches the interrupt branch. It is deferred to a frame-top, wait or pause-block
unmask point ([§12.4][s12-4], [D-294][d-294]), and never raises inside the guarded sequence.
Julia's forced throw after repeated interrupts does reach it, with the
disposition [§12.4][s12-4] gives it ([D-398][d-398]). The branch is kept for that case and
defensively, because the cost of being wrong about the masking is a terminally
errored session in place of a clean stop.
~~~~

### 33. P1-29, P1-30 (unit B, lines 211–221 at `5f21eba`)

Roster glossed; line 217 rewrapped (120 columns).

Old:

~~~~
The `Simulation` ends in a terminal status, `stopped` or `errored`, with the
exception retrievable ([D-059][d-059]). A synchronous
[unattended run](#g-unattended-run) (a run with empty staging and no snapshot
readers) rethrows after the shutdown tail completes, so CI fails honestly. An
interactive session logs the rendered error. **`run!` and `replay!`
discriminate the two by the [roster](#g-roster)** ([D-268][d-268]). With no
[device](#g-device) (any attached participant in the periphery) rostered the run is unattended and rethrows. With one or more it logs
the rendered error through the logging backend and returns, the lifecycle
reading `errored` and `termination(sim)` retaining the cause. `step!` is
deviceless by construction ([§12.6][s12-6], [D-389][d-389]) and always
rethrows.
~~~~

New:

~~~~
The `Simulation` ends in a terminal status, `stopped` or `errored`, with the exception
retrievable ([D-059][d-059]). A synchronous [unattended run](#g-unattended-run) (a run with empty staging and
no snapshot readers) rethrows after the shutdown tail completes, so CI fails
honestly. An interactive session logs the rendered error. **`run!` and `replay!`
discriminate the two by the [roster](#g-roster)** (the list of attached device entries)
([D-268][d-268]). With no [device](#g-device) (any attached participant in the periphery) rostered the
run is unattended and rethrows. With one or more it logs the rendered error
through the logging backend and returns, the lifecycle reading `errored` and
`termination(sim)` retaining the cause. `step!` is deviceless by construction
([§12.6][s12-6], [D-389][d-389]) and always rethrows.
~~~~

### 34. P1-26 (unit B, lines 243–255 at `5f21eba`)

The pointer `0` moved to the `StepError` it belongs to.

Old:

~~~~
**Boundary zero is caught too, under the service's disposition**
([D-223][d-223]). Boundary zero runs inside `init!`, a stopped-sim service,
not inside the loop. The simulation's `init!` calls `init!` on its `Model`,
which runs boundary zero. Its macro-sequence executes the same user-code
surfaces the frame's does, with the cursor maintained through them, so the
`Model`'s `init!` hosts the same catch ([D-317][d-317]). A throw inside
boundary zero arrives as a `StepError` from the one constructor. Its cursor
frame comes from the cursor, its time is `t₀`, and the species rule applies.
Any throw inside boundary zero writes the `Model`'s status back to `:built`,
which returns the simulation's lifecycle to `built` ([§12.6][s12-6]). An
`InterruptException` inside boundary zero is not model code failing, and it
has no stop path to take in a service. The host therefore lets it propagate
raw, unwrapped. The pointer is `0`.
~~~~

New:

~~~~
**Boundary zero is caught too, under the service's disposition** ([D-223][d-223]). Boundary
zero runs inside `init!`, a stopped-sim service, not inside the loop. The
simulation's `init!` calls `init!` on its `Model`, which runs boundary zero. Its
macro-sequence executes the same user-code surfaces the frame's does, with the
cursor maintained through them, so the `Model`'s `init!` hosts the same catch
([D-317][d-317]). A throw inside boundary zero arrives as a `StepError` from the one
constructor. Its cursor frame comes from the cursor, its time is `t₀`, its pointer
is `0`, and the species rule applies. Any throw inside boundary zero writes the
`Model`'s status back to `:built`, which returns the simulation's lifecycle to `built`
([§12.6][s12-6]). An `InterruptException` inside boundary zero is not model code failing,
and it has no stop path to take in a service. The host therefore lets it
propagate raw, unwrapped.
~~~~

### 35. P1-27 (unit B, lines 257–269 at `5f21eba`)

Condition linked and glossed after the bold.

Old:

~~~~
A throw inside boundary zero leaves no trace and no
[checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one
value). The run `init!` opened stays behind, empty and with no trace header,
and the run before it is gone. Nothing can use it, since `trace(sim)` and the
advances refuse a `built` simulation. `init!` takes the trace header only
after boundary zero publishes ([§11.5][s11-5]). **The reproduction of a
boundary-zero failure is `init!` under the same condition** ([D-274][d-274]).
Boundary zero is frame one's entry boundary too, so a frame-one failure
carries the same pointer. The carrier's `host` tells the two apart, and the
rendered recipe reads it. A frame-one failure has a trace, and the
halt-then-`step!` recipe above holds for it at pointer `0`. The halt restores
the header and stops there, and `step!` re-executes frame one from the
record.
~~~~

New:

~~~~
A throw inside boundary zero leaves no trace and no [checkpoint](#g-checkpoint) (the `Model`'s
state at a frame top as one value). The run `init!` opened stays behind, empty and
with no trace header, and the run before it is gone. Nothing can use it, since
`trace(sim)` and the advances refuse a `built` simulation. `init!` takes the trace
header only after boundary zero publishes ([§11.5][s11-5]). **The reproduction of a
boundary-zero failure is `init!` under the same [condition](#g-condition)** (the path-addressed
sparse overlay that sets a build's state) ([D-274][d-274]). Boundary zero is frame one's
entry boundary too, so a frame-one failure carries the same pointer. The
carrier's `host` tells the two apart, and the rendered recipe reads it. A
frame-one failure has a trace, and the halt-then-`step!` recipe above holds for it
at pointer `0`. The halt restores the header and stops there, and `step!`
re-executes frame one from the record.
~~~~

### 36. P1-29 (unit B, lines 271–282 at `5f21eba`)

Termination record glossed.

Old:

~~~~
Boundary zero's disposition differs from the loop's as well. Nothing was
published and no advance was under way, so there is no tail to take and no
snapshot to promote. The simulation returns to `built`. `run!` and `step!`
refuse it and name `init!` ([§12.6][s12-6]), while `init!`, `restore!` and
`replay!` remain legal. The remedy for a condition that fails at `t₀` is a
corrected condition, and `init!` re-establishes every [store](#g-store) (the
framework-owned home of one of a component's state letters) before it
applies one ([§14.1][s14-1]). No [termination record](#g-termination-record)
is written. The stores may hold the half-transitioned `t₀` state until the
next `init!`, `restore!` or `replay!` resets them. They are retained for
inspection, as an errored simulation's are ([§13.6][s13-6]). `trim!`'s commit
is an `init!` ([§14.8][s14-8]) and inherits the rule ([D-223][d-223]).
~~~~

New:

~~~~
Boundary zero's disposition differs from the loop's as well. Nothing was
published and no advance was under way, so there is no tail to take and no
snapshot to promote. The simulation returns to `built`. `run!` and `step!` refuse it
and name `init!` ([§12.6][s12-6]), while `init!`, `restore!` and `replay!` remain legal. The
remedy for a condition that fails at `t₀` is a corrected condition, and `init!`
re-establishes every [store](#g-store) (the framework-owned home of one of a component's
state letters) before it applies one ([§14.1][s14-1]). No [termination record](#g-termination-record) (the
stopped-sim value naming how the run ended) is written. The stores may hold the
half-transitioned `t₀` state until the next `init!`, `restore!` or `replay!` resets
them. They are retained for inspection, as an errored simulation's are ([§13.6][s13-6]).
`trim!`'s commit is an `init!` ([§14.8][s14-8]) and inherits the rule ([D-223][d-223]).
~~~~

### 37. P1-29 (unit B, lines 286–292 at `5f21eba`)

Buffer glossed.

Old:

~~~~
Divergence is not termination. Dynamics that blow up (ground penetration, an
unstable gain) produce NaNs that defeat guards. NaN comparisons are false, so
no declared guard will catch them. An `isfinite` pass over the flat state
[buffer](#g-buffer), run by the model after every return from the integrator
backend, fails fast as `NonfiniteState`, a `StepError` species naming the
component, the state leaf and the frame-entry boundary. It catches diverging
models generally, not just post-terminal ones.
~~~~

New:

~~~~
Divergence is not termination. Dynamics that blow up (ground penetration, an
unstable gain) produce NaNs that defeat guards. NaN comparisons are false, so no
declared guard will catch them. An `isfinite` pass over the flat state [buffer](#g-buffer) (the
contiguous vector backing all continuous state), run by the model after every
return from the integrator backend, fails fast as `NonfiniteState`, a `StepError`
species naming the component, the state leaf and the frame-entry boundary. It
catches diverging models generally, not just post-terminal ones.
~~~~

### 38. P1-28, P1-29, P1-30 (unit B, lines 294–303 at `5f21eba`)

The bold heads the paragraph; error locality glossed; line 296 rewrapped.

Old:

~~~~
Placement is the whole value. **The pass is the boundary's first act**
([D-157][d-157]). It runs immediately after integrate returns, before
`x_projection` and before the boundary sweep. Run there, `NonfiniteState` names the component whose
own block diverged. Run later, the NaN has already propagated. It reaches an
innocent downstream component through the ordinary signal path and surfaces as
that component's lookup-table `DomainError`, or as an `InexactError` in its
conversion. That is the [error-locality](#g-error-locality) inversion
([§8.4][s8-4]), designed out of the build and quietly reintroduced at
runtime. One `isfinite` pass over a flat buffer is cheap enough that
placement, not cost, decides.
~~~~

New:

~~~~
**The pass is the boundary's first act** ([D-157][d-157]), and that placement is the whole of
its value. The pass runs immediately after integrate returns, before
`x_projection` and before the boundary sweep. Run there, `NonfiniteState` names the
component whose own block diverged. Run later, the NaN has already propagated.
It reaches an innocent downstream component through the ordinary signal path and
surfaces as that component's lookup-table `DomainError`, or as an `InexactError` in
its conversion. That is the inversion of [error locality](#g-error-locality) (the property that a
mistake fails at the site of the mistake) ([§8.4][s8-4]), designed out of the build and
quietly reintroduced at runtime. One `isfinite` pass over a flat buffer is cheap
enough that placement, not cost, decides.
~~~~

## Unit A, `claims.md`

~~~~diff
diff --git a/docs/spec_rewrite/ch13/units/A/claims.md b/docs/spec_rewrite/ch13/units/A/claims.md
index 28ffa06..cb60c72 100644
--- a/docs/spec_rewrite/ch13/units/A/claims.md
+++ b/docs/spec_rewrite/ch13/units/A/claims.md
@@ -21,11 +21,11 @@ ruling: R1
 note: "This section" becomes "This chapter"; "once it happens" is the Part IV roadmap's (old 9902–9904); "what the framework offers around it" is R1's dictated clause.
 
 old: It covers the reporting policy, the diagnostic representation, the runtime failure story, the seam between "the model reached a terminal state" and "the run should end", the tooling and component library that follow, and the diagnosis of a rejected cycle.
-new: §13.1 covers the reporting policy; §13.2 the diagnostic representation; §13.3 the build primitives, `resolve` and the face-list accessors; §13.4 the runtime failure story; §13.5 the distinction between "the model reached a terminal state" and "the run should end"; §13.6 abnormal shutdown, one tail with two entries; §13.7 the tooling and component library that follow; and §13.8 the diagnosis of a rejected cycle.
+new: §13.1 covers the reporting policy; §13.2 the diagnostic representation; §13.3 the build primitives and how path resolution is scoped by client; §13.4 how a runtime failure is caught, carried and reproduced; §13.5 the distinction between "the model reached a terminal state" and "the run should end"; §13.6 abnormal shutdown, one tail with two entries; §13.7 the tooling and component library that follow; and §13.8 the diagnosis of a rejected cycle.
 tag: R
 ruling: R1
 newcites: §13.1 §13.2 §13.3 §13.4 §13.5 §13.6 §13.7 §13.8
-note: roadmap sentence naming §13.1–§13.8 in order. §13.3 and §13.6 take their subjects from their titles ("Build primitives: `resolve` and the face-list accessors"; "Abnormal shutdown: one tail, two entries"). "the seam between" becomes "the distinction between": seam is reserved for a narrow, named interface.
+note: roadmap sentence naming §13.1–§13.8 in order. §13.6 takes its subject from its title ("Abnormal shutdown: one tail, two entries"). Step 5 (P1-1): §13.3's subject is its main one, client-scoped resolution, and §13.4's "the runtime failure story" is named by its parts. "the seam between" becomes "the distinction between": seam is reserved for a narrow, named interface.
 
 old: Two lessons FlightCore paid for ground it.
 new: Two lessons FlightCore paid for ground this chapter.
@@ -108,16 +108,16 @@ ruling: R6
 note: F5. "the build's first step, declaration reading only" is carried by "the build's first three steps" and "reads the declaration bodies"; §9's table says "declaration bodies only".
 
 old: The other two are the stage-1 probes and the probe chain of the nominal evaluation (§9.1).
-new: The nominal evaluation runs every user function once, through the stage-1 probes (the build's single evaluations of a user function with real values) and the probe chain.
+new: The nominal evaluation runs every user function once, through the stage-1 probes (the build's single evaluations of a user function) and the probe chain.
 tag: R
 ruling: R6
 newcites: §9.1
 note: F5; §9.1 sits two sentences up in the same item.
 
-added: (the build's single evaluations of a user function with real values)
+added: (the build's single evaluations of a user function)
 # the glossary's probe entry: "the build's single evaluation of a user function with real values".
 
-added: The activation at `T` runs the continuous tier's functions.
+added: The activation at the scalar type `T` runs the continuous tier's functions.
 # F5's dictated wording (R6), from §9's step table.
 
 old: When user code throws, there is no meaningful rest of the collection to report.
@@ -186,8 +186,11 @@ old: A structural failure leaves the subtree behind it unknown.
 tag: F
 
 old: An unreadable or mixed class or a malformed container is such a failure.
+new: An unreadable or mixed class (a component's primitive-vs-assembly status) or a malformed container is such a failure.
 tag: F
 
+added: (a component's primitive-vs-assembly status)
+
 old: No pass can read past it, so it throws alone.
 tag: F
 
@@ -273,11 +276,13 @@ ruling: R3
 note: the bold on the link goes.
 
 old: For each kind it records the kind name, the payload fields, the owning section, the severity, where the kind is raised and under which policy.
-new: For each kind it records the kind name, the payload fields, the owning section, the severity, where the kind is raised and under which policy (D-214).
+new: For each kind it records the kind name, the payload fields (the structured data a diagnostic carries beside its kind), the owning section, the severity, where the kind is raised and under which policy (D-214).
 tag: C
 newcites: D-214
 note: D-214 Position splits the column into severity, raised and policy.
 
+added: (the structured data a diagnostic carries beside its kind)
+
 old: That index is the artifact the §8.4 acceptance tests and the error-message work are written against.
 new: That index is the reference the §8.4 walkthroughs, run as acceptance tests, and the error-message work are written against.
 tag: M
@@ -304,6 +309,8 @@ old: Each kind carries its own structured payload.
 tag: F
 
 old: The payload holds endpoint paths, face names, expected and observed types, and the list-in-hand a did-you-mean needs (the offending name plus the list it should have matched).
+new: The payload holds endpoint paths, face names, expected and observed types, and the list-in-hand a did-you-mean needs. A did-you-mean is the offending name plus the list-in-hand it should have matched.
+note: step 5 (P1-5): the gloss becomes its own sentence in the glossary's words, so it follows did-you-mean.
 tag: F
 
 old: A kind is a Julia type.
@@ -332,10 +339,12 @@ old: Those two fields describe the occurrence, not the kind.
 tag: F
 
 old: `BundleFieldError`, for example, is raised at the probe and as a `StepError` species thereafter.
-new: `BundleFieldError`, for example, is raised at the probe and as a `StepError` species (a `StepError` whose `cause` is a diagnostic) thereafter.
+new: `BundleFieldError`, for example, is raised at the probe and, at runtime, as a species of the runtime carrier `StepError` (§13.4).
+newcites: §13.4
+note: step 5 (P1-6): "thereafter" is the runtime, and `StepError` is introduced as the runtime carrier with its home.
 tag: F
 
-added: (a `StepError` whose `cause` is a diagnostic)
+added: A species is a `StepError` whose `cause` is a diagnostic.
 # the glossary's species entry: "a `StepError` whose `cause` is a diagnostic".
 
 old: Checking passes return diagnostics.
@@ -345,10 +354,12 @@ old: The step barrier (each of the build's three steps throws before the next be
 tag: F
 
 old: A fail-fast site throws the same carrier holding one diagnostic.
-new: A fail-fast site throws the same carrier exception holding one diagnostic.
+new: A fail-fast site throws the same carrier exception (the single exception diagnostics travel in when thrown) holding one diagnostic.
 tag: F
 note: "carrier exception" takes the section's #g-carrier-exception link, unlinked before (survey part F).
 
+added: (the single exception diagnostics travel in when thrown)
+
 old: The carrier's type parameter spells the policy.
 new: The carrier's type parameter spells the policy (D-222).
 tag: R
@@ -407,7 +418,7 @@ newcites: D-058
 note: M2, up to directly after the carrier block. D-058 Position, "paths and names as strings", and bullet 3, "The didactic style is policy".
 
 old: Strings, never instances.
-new: The first is strings, never instances.
+new: The first rule is strings, never instances.
 tag: M
 note: M2; the bold lead-in becomes a plain topic sentence (R3). "strings, never instances" verbatim.
 
@@ -430,7 +441,7 @@ tag: M
 note: M2.
 
 old: The didactic style is policy.
-new: The second is that the didactic style is policy.
+new: The second rule is that the didactic style is policy.
 tag: M
 note: M2; the bold lead-in becomes a plain topic sentence (R3). D-058 bullet 3 is a ruling of its own, but R5 bolds only D-058's closed set here.
 
@@ -621,6 +632,7 @@ newcites: D-254
 note: D-254 bullet 3, "`GridUtilization`, the last as a deployment warning under D-250". The gloss is row 60's, carried with the Deployment link.
 
 old: The unconnected-output warning stays rejected (§6.1, D-084), so the collected-warning slot stays open and empty.
+new: The unconnected-output warning stays rejected (§6.1, D-084), so the collected-warning category stays open and empty.
 tag: F
 note: D-084 plain (bold at §6.1).
 
@@ -656,7 +668,7 @@ added: (the list of attached device entries)
 # the glossary's roster entry: "the list of attached device entries".
 
 old: so `EmptyGreedyClaim` lands in the roster entry's cell (§11.6).
-new: `EmptyGreedyClaim` therefore lands in the roster entry's diagnostic cell (the single-writer cell each writer owns for diagnostics and heartbeat) (§11.6, D-250).
+new: `EmptyGreedyClaim` therefore lands in the roster entry's diagnostic cell (the per-writer cell for runtime diagnostics and liveness) (§11.6, D-250).
 tag: M
 newcites: §11.6 D-250
 note: M3; the diagnostic-cell link and its gloss move here from the runtime paragraph. D-250 bullet 5, "`EmptyGreedyClaim` moves … to the roster entry's diagnostic cell, since `attach!` mutates the roster"; repeated since M3 moves the paragraph away from the criterion's citation.
@@ -668,6 +680,7 @@ ruling: R3
 note: the bold lead-in goes plain; D-250's Position is bold at the criterion.
 
 old: The stream is per-occurrence.
+new: These warnings form a per-occurrence stream.
 tag: F
 
 old: The per-writer diagnostic cells (the single-writer cell each writer owns for diagnostics and heartbeat) carry it (§11.8).
@@ -677,6 +690,7 @@ newcites: §11.8 D-136
 note: the gloss and link moved up with M3. D-136 Position, "one per-writer diagnostic cell"; plain (bold at §11.8).
 
 old: The rate limit lives in the cells, as a structural bound rather than a policy layered over the stream.
+new: The rate limit lives in the diagnostic cells, as a structural bound rather than a policy layered over the stream.
 tag: F
 
 old: The bound is a bounded ring plus per-kind suppressed counts, drained at frame top.
@@ -686,10 +700,13 @@ old: So "rate-limited wherever its source can repeat" holds of every kind below
 tag: F
 
 old: The stream surfaces through the published framework status (§11.2).
+new: The stream surfaces through the published framework status (the frozen value each snapshot carries beside the signal table) (§11.2).
 tag: F
 
+added: (the frozen value each snapshot carries beside the signal table)
+
 old: The §10.7 pacer diagnostics and the §12.2 liveness heartbeats ride in the same cells and surface beside it.
-new: The liveness heartbeat (§12.2) rides in the same cells, and the pacer's record (§10.7) sits beside the writers' records in the status.
+new: The liveness heartbeat (§12.2) rides in the same diagnostic cells, and the pacer's record (§10.7) sits beside the writers' records in the status.
 tag: R
 ruling: R6
 note: F9; the duplicate diagnostic-cell link goes (F29).
@@ -707,14 +724,16 @@ old: The committed runtime warnings, in one place, are these.
 tag: F
 
 old: Chattering, or localization-budget exhaustion (§10.4).
-new: `ChatteringBudget`, chattering, or localization-budget exhaustion (§10.4).
+new: `ChatteringBudget`, for chattering or localization-budget exhaustion (§10.4).
 tag: R
 ruling: R8
 
 old: A localized event's bracketing budget runs out at a boundary.
-new: A localized event's bracketing budget runs out at a boundary (a published consistency point).
+new: A localized event's crossing instant is bracketed by root-finding. The event's bracketing budget runs out at a boundary (a published consistency point).
 tag: F
 
+added: A localized event's crossing instant is bracketed by root-finding.
+
 added: (a published consistency point)
 # the glossary's boundary entry: "a published consistency point".
 
@@ -741,8 +760,11 @@ ruling: R8
 note: bare "entry" is reserved; these are batch entries (§11.3 "a batch entry outside the surface"). One line for the three kinds, which share the staging clause, each kind with its own section (R24).
 
 old: The drain checks nothing.
+new: The drain (the frame-top swap that applies staged writes) checks nothing.
 tag: F
 
+added: (the frame-top swap that applies staged writes)
+
 old: `OutOfClaimEntry` is an enumerated surface's binding drift, a name with no position in the attach-compiled schema.
 new: `OutOfClaimEntry` (§11.3) is an enumerated surface's binding drift, a name with no position in the attach-compiled schema.
 tag: R
@@ -761,19 +783,23 @@ old: The stopped-sim attach also fires it when it renormalizes a pending batch.
 tag: F
 
 old: `EntryTypeMismatch` is a value unconvertible to its root input's declared type, rejected at staging for every writer.
-new: `EntryTypeMismatch` (§11.4) is a value unconvertible to its root input's declared type, rejected at staging for every writer.
+new: `EntryTypeMismatch` (§11.4) is a value unconvertible to the declared type of its root input (the root component's own input face), rejected at staging for every writer.
 tag: R
 ruling: R24
 newcites: §11.4
 note: Appendix C's section for the kind.
 
+added: (the root component's own input face)
+
 old: A tolerated device-side datum failure (§11.6, §13.4).
-new: `MalformedDatum`, a tolerated device-side datum failure (§11.6, §13.4).
+new: `MalformedDatum`, a tolerated datum failure on the side of a device (any attached participant in the periphery) (§11.6, §13.4).
 tag: R
 ruling: R8
 
+added: (any attached participant in the periphery)
+
 old: `MalformedDatum` is emitted by the author's loop via `report!(handle, …)` into the device's own cell (§11.8).
-new: It is emitted by the author's loop via `report!(handle, …)` into the device's own cell (§11.8, D-105).
+new: It is emitted by the author's loop via `report!(handle, …)` into the device's own diagnostic cell (§11.8, D-105).
 tag: C
 newcites: §11.8 D-105
 note: D-105 Position, "tolerated in the loop body (catch, stage nothing, `report(handle, MalformedDatum(cause))`, continue)"; plain (bold at §11.6).
@@ -784,16 +810,20 @@ tag: R
 ruling: R10
 
 old: Staging discarded during replay (§12.7).
-new: `ReplayDiscardedStaging`, staging discarded during replay (§12.7).
+new: `ReplayDiscardedStaging`, staging discarded during replay (the ordinary loop re-driven from a recorded trace) (§12.7).
 tag: R
 ruling: R8
 
+added: (the ordinary loop re-driven from a recorded trace)
+
 old: `ReplayDiscardedStaging` reports a live batch found staged while the trace feeds the drain.
-new: It reports a live batch found staged while the trace feeds the drain.
+new: It reports a live batch found staged while the trace (the primary record of a session) feeds the drain.
 tag: R
 ruling: R8
 note: the name moved to the line's head.
 
+added: (the primary record of a session)
+
 old: Thread-budget tightness (§12.2).
 new: `ThreadBudget`, thread-budget tightness (§12.2, D-401).
 tag: R
@@ -817,8 +847,11 @@ old: It arises after the terminal snapshot.
 tag: F
 
 old: It is therefore collected into the termination record and presented through the logging backend, never carried into a status (D-201, D-203).
+new: It is therefore collected into the termination record (the stopped-sim value naming how the run ended) and presented through the logging backend, never carried into a status (D-201, D-203).
 tag: F
 
+added: (the stopped-sim value naming how the run ended)
+
 old: Device crash (§12.4, §13.4).
 new: `DeviceCrash`, a device crash (§12.4, §13.4).
 tag: R
@@ -834,12 +867,14 @@ ruling: R6
 note: F10.
 
 old: and the sim continues with the device absent.
-new: and the run goes on without the device unless its attachment set `should_abort` (§11.6).
+new: and the run goes on without the device unless its attachment set `should_abort` (the per-attachment failure policy, an `attach!` keyword) (§11.6).
 tag: R
 ruling: R6
 newcites: §11.6
 note: F10; the path in one clause, pointing to §11.6 (R4).
 
+added: (the per-attachment failure policy, an `attach!` keyword)
+
 old: Unbounded run (§13.5).
 new: `UnboundedRun`, an unbounded run (§13.5).
 tag: R
@@ -858,7 +893,7 @@ tag: M
 note: R4; §13.5's "The advisory fires in `:live` only" carries "raises nothing".
 
 old: `UnboundedRun` lands in the loop's own cell, because `run!` mutates state (D-255).
-new: It lands in the loop's own cell, because `run!` mutates state (D-255).
+new: It lands in the loop's own diagnostic cell, because `run!` mutates state (D-255).
 tag: R
 ruling: R8
 note: kept as the warning criterion's case; the name moved to the line's head. D-255 cited only for the cell clause, which stands.
~~~~

## Unit B, `claims.md`

~~~~diff
diff --git a/docs/spec_rewrite/ch13/units/B/claims.md b/docs/spec_rewrite/ch13/units/B/claims.md
index 7dd234f..5dd8b04 100644
--- a/docs/spec_rewrite/ch13/units/B/claims.md
+++ b/docs/spec_rewrite/ch13/units/B/claims.md
@@ -29,7 +29,8 @@ tag: F
 
 old: For an assembly they return the entries of `input_wires(c)` / `output_wires(c)`.
 tag: F
-note: "entries" kept, per survey part E's carried item (Appendix D's fix)
+new: For an assembly they return the face names of `input_wires(c)` / `output_wires(c)`.
+note: step 5 (P1-14): bare "entries" becomes "the face names"; D-061's Position, "`input_faces`/`output_faces` return declaration-ordered face-name strings"
 
 old: Declaration order is preserved, which gives deterministic printouts and stable diagnostics.
 tag: F
@@ -77,8 +78,11 @@ tag: F
 note: the bold word "past" becomes italic, as "to" is in the next sentence
 
 old: Resolving to a generic child is port-level access and legal.
+new: Resolving to a generic child is legal, as access at the level of a port (one declared input or output).
 tag: F
 
+added: (one declared input or output)
+
 old: An unknown segment errors with the sibling field list in hand.
 tag: F
 
@@ -124,19 +128,25 @@ tag: F
 note: the bold row name goes plain (R3)
 
 old: | service | condition entries (the path-addressed sparse overlay that sets a build's state), trim `reads`, taps (§14.3, §14.7, §14.10) | strict: no traversal past a generic child, checked at the authoring or mount level |
-new: | service | condition entries (the path-addressed sparse overlay that sets a build's state), trim `reads`, taps, device read bindings, log extraction by `series` (§14.3, §14.7, §14.10, §11.2, D-406, D-407) | strict: no traversal past a generic child, checked at the authoring or mount level |
+new: | service | condition entries (the path-addressed sparse overlay that sets a build's state), trim `reads`, taps (the selector lists linearization seeds and reports), device read bindings (the values passed at `attach!` that make a device framework-legible), log extraction by `series` (§14.3, §14.7, §14.10, §11.2, D-406, D-407) | strict: no traversal past a generic child, checked at the authoring or mount level |
 tag: R
 ruling: R2, R25
 newcites: §14.3 §14.7 §14.10 §11.2 D-406 D-407
 note: device read bindings join the service row with §11.2 and D-406 (R2); the bold row name and the bold cell go plain (R3)
 
+added: (the selector lists linearization seeds and reports)
+
+added: (the values passed at `attach!` that make a device framework-legible)
+
 old: | inspection | device read bindings, GUI panels, snapshot and log inspection (§11.2, §11.7) | the instance walk |
-new: | inspection | snapshot and log inspection (D-310) | the instance walk |
+new: | inspection | snapshot (the immutable per-boundary publication) and log inspection (D-310) | the instance walk |
 tag: R
 ruling: R2
 newcites: D-310
 note: device read bindings move to the service row; "GUI panels" goes, D-310 cited once in the section (Position: "The built-in Julia GUI is parked"); §11.7, cited for the GUI panels, goes with them (R16)
 
+added: (the immutable per-boundary publication)
+
 old: Each client's treatment has its own warrant.
 tag: F
 
@@ -162,8 +172,11 @@ old: Inspection walks instances instead.
 tag: F
 
 old: A generic seam is not an error for a client that never claimed substitutability.
+new: A generic seam (a narrow, named interface kept deliberately thin) is not an error for a client that never claimed substitutability.
 tag: F
 
+added: (a narrow, named interface kept deliberately thin)
+
 old: "What is in this build" is inspection's defining question.
 tag: F
 
@@ -224,7 +237,7 @@ old: For wiring there is no deep route left to restore, because the face chain i
 tag: F
 
 old: Which of the three rules a client resolves under is internal framework fact, never user-facing API.
-new: Which of the three rules a client resolves under is internal framework fact, never user-facing API (D-130).
+new: Which of the three treatments a client resolves under is internal framework fact, never user-facing API (D-130).
 tag: C
 newcites: D-130
 note: D-130 Position: "which of the three a client falls under is internal, never user-facing API"
@@ -268,14 +281,20 @@ note: F2, cut as false; the did-you-mean stays in R2's moved sentence
 old: ### 13.4 Runtime failures: one catch site, an execution cursor
 tag: F
 
-added: A runtime failure of model code is a throw inside a frame (one iteration of the loop) or inside boundary zero,
+added: A runtime failure of model code is a throw inside a frame (one iteration of the loop) or inside boundary zero.
 
 old: (the initialization boundary: the ordinary macro-sequence with an empty integrate)
-new: the initialization boundary, which runs the ordinary macro-sequence with an empty integrate.
+new: Boundary zero is the initialization boundary (a published consistency point), and it runs the ordinary boundary macro-sequence with an empty integrate.
 tag: F
 note: boundary zero's link and gloss move to its new first use, the context paragraph; the colon becomes a relative clause; an appositive, since the sentence already holds the frame gloss
 
-added: The framework catches it at one site, records where execution stood, and names how to reproduce it.
+added: (a published consistency point)
+
+added: The framework catches the failure at one site, records where execution stood, and names how to reproduce it.
+
+added: The code inside the `Model`'s `try` is the guarded sequence.
+
+added: Ticks are the instants at which discrete leaves run their stages and update.
 
 added: This section covers, in order, where a failure is caught, the runtime carrier, the interrupt, the disposition, reproduction, boundary zero, the nonfinite check and device-side failures.
 
@@ -315,15 +334,19 @@ ruling: R6
 newcites: D-317
 
 old: It never wraps per stage or per component (D-059).
-new: `frame!` never wraps per stage or per component (D-059).
+new: `frame!` never wraps per stage or per component (the unit of modeling, a leaf or an assembly of components) (D-059).
 tag: R
 ruling: R5
 note: D-059 bold, Position "Runtime failures are caught at one site, around the boundary macro-sequence"; "It" spelled `frame!` (R7), since the chain sentence now sits between
 
+added: (the unit of modeling, a leaf or an assembly of components)
+
 old: The loop wraps each frame in a `try` of its own, which decides the failure's disposition (below) and builds no carrier (D-317).
 tag: F
 
 old: Framing information does not need to be caught into existence.
+new: Where execution stood does not need to be caught into existence.
+note: step 5 (P1-21): "framing" keeps its §13.2 sense (R7)
 tag: F
 
 old: The executor (the compiled form of the stage execution order) maintains an execution cursor, a plain mutable field of the executor recording where execution stands in the compiled order.
@@ -350,10 +373,12 @@ newcites: D-261
 note: F13; `Outputs` and its gloss kept in their own sentence; D-253 replaced by D-261 in the sentence before
 
 old: The second is which function is running: `y_state`, `y_direct`, `x_deriv`, `s_update`, a guard, a handler, or `x_projection`.
-new: The second is which function is running, one of `y_state`, `y_direct`, `x_deriv`, `s_update`, a guard, a handler, or `x_projection`.
+new: The second is which function is running, one of `y_state`, `y_direct`, `x_deriv`, `s_update`, a guard (the declared function defining an event's predicate), a handler, or `x_projection`.
 tag: F
 note: the colon becomes "one of"
 
+added: (the declared function defining an event's predicate)
+
 old: The third is the boundary phase: integration stage k, event round r, a localization evaluation at trial time, or tick.
 new: The third is the boundary phase, one of the frame-top drain, integration stage k, the arrival sweep (one pass through the execution order), the θ = 0 validation, a localization trial, projection, event round r, or the ticks.
 tag: R
@@ -369,12 +394,14 @@ old: It covers every user-code surface uniformly, including the forgettable ones
 tag: F
 
 old: Those are the RHS evaluations at interior RK stage points, the guard evaluations at ITP/Brent trial points, and the environment closures.
-new: Those are the RHS evaluations at interior RK stage points and the guard evaluations at the trial points of ITP or Brent root-finding (§10.4).
+new: Those are the evaluations of the RHS (the continuous derivative function) at interior RK stage points and the guard evaluations at the trial points of ITP or Brent root-finding (§10.4).
 tag: R
 ruling: R6
 newcites: §10.4
 note: F15 cuts "the environment closures"; R10 introduces ITP/Brent
 
+added: (the continuous derivative function)
+
 old: `# the cursor: one mutable field of the executor, overwritten per dispatch mutable struct ExecutionCursor … # what it records, per the prose above: component path # (execution-order index), which function, and the boundary phase end`
 new: `# the cursor: one mutable field of the executor, overwritten per dispatch mutable struct ExecutionCursor … # what it records, per the prose above: component path # (component-list index), which function, and the boundary phase end`
 tag: R
@@ -402,7 +429,7 @@ ruling: R6
 note: F12; the field list names "the time", and its sentence follows
 
 old: the frame-entry boundary index, the host of the catch, and the original exception as `cause`.
-new: They are the cursor frame (the copy of the cursor a `StepError` carries), the time, the frame-entry boundary index, the host of the catch, and the original exception as `cause`.
+new: They are the cursor frame (the cursor's copy at the catch), the time, the frame-entry boundary index, the host of the catch, and the original exception as `cause`.
 tag: R
 ruling: R7
 note: "the cursor's frame" becomes "the cursor frame", glossed at first use (R7); the count stays five; the bold term goes plain
@@ -415,8 +442,11 @@ newcites: D-128
 note: D-128 bold, its second Position sentence "`StepError`'s replay pointer is respelled the frame-entry boundary index"
 
 old: It names the frame-top boundary at which the failing frame began.
+new: The pointer names the frame-top boundary at which the failing frame began.
 tag: F
 
+added: Replay is the ordinary loop re-driven from a recorded trace.
+
 old: That frame top is a grid boundary or boundary zero
 new: That frame top is a grid boundary or boundary zero, and it is always a legal replay halt (§12.7).
 tag: F
@@ -510,12 +540,14 @@ old: A collected carrier riding as `cause` is an exception and falls under that
 tag: F
 
 old: A bare value thrown deliberately by model code is neither, and the constructor refuses it unframed.
+new: A bare value thrown deliberately by model code is neither, and the constructor refuses it, so it leaves the catch unwrapped.
+note: step 5 (P1-21): "unframed" is D-225's word for leaving the catch with no `StepError`; *frame* keeps R7's senses
 tag: F
 
 old: The framework does not handle that throw (D-225).
 tag: F
 
-added: The cursor frame and the pointer are then lost, and the lifecycle does not move as it does on the framed path.
+added: The cursor frame and the pointer are then lost, and the lifecycle does not move as it does when the catch builds a `StepError`.
 
 old: `# the runtime carrier: its parameter the cause's type — a diagnostic's kind # for a species, the exception model code threw otherwise struct StepError{C <: Union{Diagnostic, Exception}} <: Exception cursor # the cursor's frame at the catch t::Float64 # the boundary time boundary::Int # the frame-entry boundary index: the replay pointer host::Symbol # :boundary_zero under init!, :loop inside a frame cause::C end`
 new: `# the runtime carrier: its parameter the cause's type — a diagnostic's kind # for a species, the exception model code threw otherwise struct StepError{C <: Union{Diagnostic, Exception}} <: Exception cursor # the cursor's frame at the catch t::Float64 # the clock at the failure boundary::Int # the frame-entry boundary index: the replay pointer host::Symbol # :boundary_zero under init!, :loop inside a frame cause::C end`
@@ -550,6 +582,7 @@ old: The run takes the ordinary graceful tail and ends `stopped`, never `errored
 tag: F
 
 old: With the boundary masking in force (§12.4) a single interrupt never reaches the branch.
+new: With the boundary masking in force (§12.4) a single interrupt never reaches the interrupt branch.
 tag: F
 note: the catch-site clause M7 keeps; inbound §12.4 "never sees a single interrupt" relies on it
 
@@ -603,10 +636,13 @@ ruling: R6
 note: F18 cuts the clause; both claims false (D-310, D-317 bullet 7)
 
 old: `run!` and `replay!` discriminate the two by the roster (D-268).
+new: `run!` and `replay!` discriminate the two by the roster (the list of attached device entries) (D-268).
 tag: R
 ruling: R5
 note: D-268 bullet 5 bold, "`run!` discriminates §13.4's two dispositions by the roster"; `replay!` by its 2026-09-26 annotation
 
+added: (the list of attached device entries)
+
 old: With no device rostered the run is unattended and rethrows.
 new: With no device (any attached participant in the periphery) rostered the run is unattended and rethrows.
 tag: F
@@ -677,7 +713,7 @@ old: A throw inside boundary zero arrives as a `StepError` from the one construc
 tag: F
 
 old: Its frame comes from the cursor, its time is `t₀`, and the species rule applies.
-new: Its cursor frame comes from the cursor, its time is `t₀`, and the species rule applies.
+new: Its cursor frame comes from the cursor, its time is `t₀`, its pointer is `0`, and the species rule applies.
 tag: R
 ruling: R7
 
@@ -692,6 +728,8 @@ old: The host therefore lets it propagate raw, unwrapped.
 tag: F
 
 old: The pointer is `0`.
+new: its pointer is `0`
+note: step 5 (P1-26): moved into the sentence on the boundary-zero `StepError`'s fields, which it describes
 tag: F
 
 old: A throw inside boundary zero leaves no trace and no checkpoint (the `Model`'s state at a frame top as one value).
@@ -707,10 +745,13 @@ old: `init!` takes the trace header only after boundary zero publishes (§11.5).
 tag: F
 
 old: The reproduction of a boundary-zero failure is `init!` under the same condition (D-274).
+new: The reproduction of a boundary-zero failure is `init!` under the same condition (the path-addressed sparse overlay that sets a build's state) (D-274).
 tag: R
 ruling: R5
 note: D-274 bullet 7 bold, "Its reproduction is `init!` under the same condition"; no other chapter of the frozen spec bolds that bullet (§11.5 and §12.7 bold bullet 4)
 
+added: (the path-addressed sparse overlay that sets a build's state)
+
 old: Boundary zero is frame one's entry boundary too, so a frame-one failure carries the same pointer.
 tag: F
 
@@ -742,8 +783,11 @@ tag: F
 note: store linked and glossed at its first use; glossary "the framework-owned home of one of a component's state letters"
 
 old: No termination record is written.
+new: No termination record (the stopped-sim value naming how the run ended) is written.
 tag: F
 
+added: (the stopped-sim value naming how the run ended)
+
 old: The stores may hold the half-transitioned `t₀` state until the next `init!` resets them.
 new: The stores may hold the half-transitioned `t₀` state until the next `init!`, `restore!` or `replay!` resets them.
 tag: R
@@ -774,26 +818,30 @@ ruling: R19
 note: condition is §14's word
 
 old: A loop-level `isfinite` sweep over `x` at boundaries fails fast as a `StepError` species, naming the offending component's state block and the boundary.
-new: An `isfinite` pass over the flat state buffer, run by the model after every return from the integrator backend, fails fast as `NonfiniteState`, a `StepError` species naming the component, the state leaf and the frame-entry boundary.
+new: An `isfinite` pass over the flat state buffer (the contiguous vector backing all continuous state), run by the model after every return from the integrator backend, fails fast as `NonfiniteState`, a `StepError` species naming the component, the state leaf and the frame-entry boundary.
 tag: R
 ruling: R6
 note: F20 wording, F32's "state leaf", `NonfiniteState` named here; the wrong sweep link goes; buffer linked at this new first use
 
+added: (the contiguous vector backing all continuous state)
+
 old: It catches diverging models generally, not just post-terminal ones.
 tag: F
 
 old: Placement is the whole value.
 tag: F
-note: the italic label becomes a plain topic sentence
+new: and that placement is the whole of its value.
+note: the italic label became a plain topic sentence; step 5 (P1-28) joins it to the bold, which now heads the paragraph
 
 old: The sweep is the boundary's first act.
-new: The pass is the boundary's first act (D-157).
+new: The pass is the boundary's first act (D-157),
 tag: R
 ruling: R5
 newcites: D-157
 note: D-157's first ruling bold, "The nonfinite-`x` check is the boundary's first act"; "sweep" becomes "pass" (F20)
 
 old: It runs immediately after integrate returns, before `x_projection` and before the boundary sweep.
+new: The pass runs immediately after integrate returns, before `x_projection` and before the boundary sweep.
 tag: F
 
 old: Run there, `NonfiniteState` names the component whose own block diverged.
@@ -806,11 +854,13 @@ old: It reaches an innocent downstream component through the ordinary signal pat
 tag: F
 
 old: That is the error-locality inversion (§8.4), designed out of the build tier and quietly reintroduced at runtime.
-new: That is the error-locality inversion (§8.4), designed out of the build and quietly reintroduced at runtime.
+new: That is the inversion of error locality (the property that a mistake fails at the site of the mistake) (§8.4), designed out of the build and quietly reintroduced at runtime.
 tag: R
 ruling: R6
 note: F21; error locality linked at its first use
 
+added: (the property that a mistake fails at the site of the mistake)
+
 old: One `isfinite` pass over a flat buffer is cheap enough that placement, not cost, decides.
 tag: F
 
~~~~

## Findings left

- **RULING, not the fixer's:** P1-11, P1-15, P1-16, P1-18 and P1-25 in pass 1;
  P2-26 in pass 2, whose §13.3 half is unit B's.
- **P1-22, to RULING.** The `Outputs` gloss's "the port classes" stays: R19
  rules "Unit B's correction 4, the `Outputs` gloss, stays as written".
- **P1-19, its second half.** The context sentence keeps "a runtime failure of
  model code". Adding "or of device code in its own domain" would make the next
  sentence false: the one catch site does not catch device-side failures,
  since the device wrapper does. The parts sentence already names device-side
  failures.
- **P1-20, placed differently.** The `Model` sentence and its link open "Where
  a failure is caught", right before the bold, not the context paragraph. The
  context paragraph never names the `Model`, so this is still its first use in
  the section, and the bold now uses the bare term.
- **P1-29, partly.** Every link the finding names now has a gloss, except
  *chattering*. Appendix D's entry for it is the budget ("chattering /
  localization budget"), and the line's next sentences already say what runs
  out. *Tick*, *replay* (§13.4), *localized* (§13.2), *did-you-mean* (§13.2)
  and *species* (§13.2) take a gloss sentence: an inline gloss would sit in a
  bold, in an arrow chain, or in a sentence that already has a gloss. Links
  the finding does not name stay unglossed: in §13.1 face, port; in §13.2
  kind, probe, face, component, port, artifact, state, batch; in §13.3
  assembly, generic-holding, device; in §13.4 boundary zero, execution order,
  execution cursor, input mode, localized.
- **Antecedent repairs made with the edits.** In §13.4's context paragraph
  "The framework catches it" becomes "catches the failure", since "it" would
  now read as boundary zero. In P1-28's paragraph "It runs immediately after"
  becomes "The pass runs", since "it" would read as the value. In the
  `ChatteringBudget` line the localized gloss sentence is followed by "The
  event's bracketing budget", not "Its". After the replay gloss sentence, "It
  names the frame-top boundary" becomes "The pointer names".
