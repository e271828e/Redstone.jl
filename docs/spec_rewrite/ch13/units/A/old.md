## 13. Error discipline

[§8.4][s8-4] fixed what must be caught and where. [§9][s9] fixed when each fact
is checked. This section fixes how failures are *reported*. It covers the
reporting policy, the diagnostic representation, the runtime failure story,
the seam between "the model reached a terminal state" and "the run should
end", the tooling and component library that follow, and the diagnosis of a
rejected cycle.
Two lessons FlightCore paid for ground it. The first is the compact-backtrace
discipline, needed because parameterized model types make rendered output
unreadable. The second is the `SimulationTermination` machinery, which
[§13.5][s13-5] replaces.

### 13.1 Reporting policy: collect the checks, fail the evaluations fast

The build's failure sites split into two populations. That split settles the
choice between fail-fast and compiler-style reporting. Each population takes
the policy that fits it.

- **Declarative checks over collected structure collect.** These are the
  checks for unconnected inputs, two producers, wire typos and type mismatches,
  [face](#g-face)-name uniqueness, `y_types`/state-field consistency and
  `sample_times` validation. Each is a pass over a list. The whole-tree
  obligation check literally computes *the set of* inputs whose obligation
  chain never terminates. Reporting every violation is the natural output of
  such a pass, and truncating to the first would be extra work. These failures
  also cluster in practice. A freshly written [assembly](#g-assembly) has five
  unwired inputs, and a renamed [port](#g-port) breaks three wires. Each of
  these passes returns its full violation list.
- **User-code evaluation fails fast.** User code runs in three places. The first
  is the interface-connection bodies in the structure step (the build's first
  step, declaration reading only). The other two are the stage-1
  [probes](#g-probe) and the probe chain of the nominal evaluation
  ([§9.1][s9-1]). When user code throws, there is no
  meaningful rest of the collection to report. A failed `input_wires`
  leaves the parent's face derivation undefined. A failed stage-2 probe starves
  every downstream probe of its wired inputs, because [probe values](#g-probe-value) flow
  topologically ([§9.3][s9-3]). The first
  user-code exception aborts the phase ([D-057][d-057]).

The build's steps are barriers. A step that produced any error-severity
diagnostic, of either kind, throws before the next step begins. Probing
against unresolved wiring would be meaningless.

**Rule.** Collection reaches the step barrier, under a dependency rule. A
declarative pass runs when the results it reads are clean. It records every
violation it finds and returns a total result. Every pass that ran merges into
the barrier's one throw ([D-229][d-229]).

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

**There is no cascade suppression within a step.** This is a deliberate
simplification ([D-057][d-057]). A wire typo'd as `:throtle` produces two
errors. One is a [did-you-mean](#g-did-you-mean) error (the offending name plus
the list-in-hand it should have matched). The other is an unconnected-input
error for the intended `throttle`. Both are reported. They render adjacently,
because diagnostics sort by path, and the pairing explains itself.

### 13.2 Diagnostics: structured values, one carrier exception

Both reporting policies move the same thing. What a collecting pass returns and
what a fail-fast site produces is in either case a *diagnostic*. The shape of
that value decides what an acceptance test can assert and what a user reads.

**Rule.** A diagnostic is a plain value from a small closed set of
[kinds](#g-kind) ([D-058][d-058]). **[Appendix C][sC]** enumerates that set
normatively. For each kind it records the kind name, the [payload](#g-payload)
fields, the owning section, the severity, where the kind is raised and under
which policy. That index is the artifact the [§8.4][s8-4] acceptance tests and
the error-message work are written against. Each kind carries its own
structured payload. The payload holds endpoint paths, [face](#g-face) names,
expected and observed types, and the *list-in-hand* a
[did-you-mean](#g-did-you-mean) needs (the offending name plus the list it
should have matched). A kind *is* a Julia type. Severity is a property of the
kind, not of the occurrence. It is `error` or `warning`, and it says whether an
occurrence ever throws. It is read as `severity(d)` and never stored per
occurrence. The severity field of [Appendix C][sC] is derived from it. Where an
occurrence surfaces (build, service or runtime) and how it is reported
(collected, fail-fast, logged or rate-limited) are the *raised* and *policy*
fields of [Appendix C][sC]. Those two fields describe the occurrence, not the
kind. `BundleFieldError`, for example, is raised at the probe and as a
`StepError` [species](#g-species) thereafter.

Checking passes return diagnostics. The step barrier (each of the build's
three steps throws before the next begins) throws a single
`DiagnosticError` wrapping the collection. A fail-fast site throws the same
carrier holding one diagnostic. **The carrier's type parameter spells the
policy.** It is the diagnostic's kind for a fail-fast throw and
`Vector{Diagnostic}` for a collected one. A test therefore asserts policy and
kind at once with `@test_throws DiagnosticError{Kind}` ([D-222][d-222]). The
runtime carrier follows the same rule. `StepError{C}` carries the type of its
`cause`, so a species is `StepError{Kind}` ([§13.4][s13-4], [D-225][d-225]).
`showerror` renders a collection compiler-style, grouped by kind and sorted by
path. It renders a single diagnostic as its own line.

```julia
# a diagnostic value: its kind is its identity, its payload is plain data
abstract type Diagnostic end
struct WireTypeMismatch <: Diagnostic   # one kind of the closed Appendix C set
    …                                   # payload fields per Appendix C: paths and
                                        # names as Strings, port types as types
end

# the carrier: one exception, its parameter the policy — a kind for a
# fail-fast throw, the collection type for a barrier's batch
struct DiagnosticError{P <: Union{Diagnostic, Vector{Diagnostic}}} <: Exception
    carried::P
end
```

A user-code exception is wrapped in a framing diagnostic, `UserCodeFraming`,
with the original exception as `cause`. The frame carries the
[component](#g-component) path, the function that threw, and the
[probe](#g-probe) context, which is the [bundle](#g-bundle)'s field names (the
bundle is the NamedTuple of zero-copy views a component function receives)
and the synthesized inputs as a spelling, never as values ([D-248][d-248]). The
didactic frame therefore renders first and the raw throw second. The framed
set is every user-authored method the build invokes. The declarations of
[§8.2][s8-2] and the probed functions of [§9.3][s9-3] are framed alike, each
reached through one framing accessor rather than a bare call. A declaration
takes no bundle, so only the plain frame applies to it. Three exceptions pass
through the frame unwrapped, because none of them is user code failing. They
are a `DiagnosticError` carrier a check inside the call threw, an
`InternalInvariant`, and an `InterruptException`. At runtime the same throw
reaches [§13.4][s13-4]'s one catch site instead. There a `FieldError` matched
as below becomes a `BundleFieldError` species, and any other exception rides
as the `StepError`'s `cause`.

One class of exception is recognized rather than merely framed. A `FieldError`
carries its type and field as data (Julia ≥ 1.12). At the probe the framework matches them
against the bundle's own NamedTuple type, which the accessor holds. At the
runtime catch site it matches them against the bundle's field names, because
the bundle's type there is the activation's and is not in hand ([D-248][d-248]).
A tuple the author builds with the bundle's own names is indistinguishable
from the bundle at either site, and the diagnosis stays true of it. The result
is the bundle-law did-you-mean ([§5.2][s5-2]). It carries the legal field set
and classifies the miss as an undeclared store, a wrong [tier](#g-tier), or a
field illegal for this function. Nothing is recovered by reading message text.

The probe raises the result as `BundleFieldError` ([Appendix C][sC],
[D-248][d-248]). An example message is "`systems/plant`: `x_deriv`
destructures `m`, but `systems/plant` declares no `m_init`". The message names
the component by its path. One law covers tier facts, stage legality and
declarations alike. The wrong-tier class covers the state letters too
([D-195][d-195]). `x` and `m` are continuous-only, and `s` and `Δt` are
discrete-only, so destructuring any of the four on the wrong tier is a
wrong-tier fact. The bundle stays a bare NamedTuple ([D-074][d-074],
[D-341][d-341]). A getproperty-wrapper spelling is the recorded fallback,
should type-matched interception prove insufficient ([D-341][d-341]).

The [§8.4][s8-4] walkthroughs, run as acceptance tests, target diagnostics.
Tests match on kind plus payload fields, never on message text. Messages are
therefore pure presentation.

Two rendering rules are doctrine, not style.

- **Strings, never instances.** Diagnostics carry paths and names as strings,
  never component instances and never component types. This is the
  `compact_backtrace` lesson. Expected and observed *[port](#g-port)* types are
  the one payload exception, and they are small. Examples are a `Float64`
  against a `Bool`, and a NamedTuple field diff.
- **The didactic style is policy.** Every diagnostic states
  the fix or the lists-in-hand, not just the violation. Examples are "return
  `zero(x.ω)`, not `0`" and "no input `throtle`; did you mean `throttle`?", or
  the child's face list shown alongside the unknown `except` entry.

**Rule.** A warning raised while producing an artifact lives on that artifact.
A warning raised while mutating state lives in that state's status. Logging is
presentation and never a home ([D-250][d-250]). An
[artifact](#g-artifact) is an immutable pure function of its inputs.
[State](#g-state-single-owner) is single-owner and mutated in place. That one
criterion places every warning the framework raises.

**The build produces artifacts, so its warnings live on them.** `Build` and
[`Deployment`](#g-deployment) (the scalar-free artifact the grid parameters
fix) carry `warnings`, and `warnings(x)` reads the list ([§9.2][s9-2]).
A step that throws renders its
warnings with the collection it throws. One that completes carries them on the
artifact, and the entry point logs each once at return. The build's warning set
holds `EmptyFaceSelection` ([§8.8][s8-8]), and the deployment's holds
`GridUtilization`. The unconnected-output warning stays
rejected ([§6.1][s6-1], [D-084][d-084]), so the *collected*-warning slot stays
open and empty. A warnings-as-errors CI switch could be added, but is not
built.

**The runtime mutates state, so its warnings live in that state's status.** The
stream is per-occurrence. The per-writer [diagnostic cells](#g-diagnostic-cell)
(the single-writer cell each writer owns for diagnostics and heartbeat) carry
it ([§11.8][s11-8]). The rate limit lives in the cells, as a structural bound
rather than a policy layered over the stream. The bound is a bounded ring plus
per-kind suppressed counts, drained at frame top. So "rate-limited wherever its
source can repeat" holds of every kind below without any kind arranging it. The
stream surfaces through the published [framework status](#g-framework-status)
([§11.2][s11-2]). The [§10.7][s10-7] pacer diagnostics and the [§12.2][s12-2]
liveness heartbeats ride in the same [cells](#g-diagnostic-cell) and surface
beside it. The stream is never collected, since there is no collection to
join. Nothing in the argument of [D-084][d-084] applies to it. That decision is
about what the *build* warns on.

**A stopped-sim service returns an artifact, so its warnings live on it.**
`trim!` returns a `TrimReport`, and `TrimCommitEvents`, `TrimCommitResiduals`
and `TrimCommitChecks` are that report's fields ([§14.8][s14-8]). The line the
call prints at return is presentation. `attach!` is the other side of the
criterion. It mutates the roster, so `EmptyGreedyClaim` lands in
the roster entry's cell ([§11.6][s11-6]). The committed
runtime warnings, in one place, are these.

- **[Chattering](#g-chattering), or localization-budget exhaustion**
  ([§10.4][s10-4]). A [localized](#g-localized) event's bracketing budget runs
  out at a [boundary](#g-boundary).
- **Firing-budget exhaustion** ([§10.6][s10-6]). An event has spent its
  `firing_budget` at a boundary, and its further edges there are dropped.
- **Forgiven-debt re-anchor** ([§10.7][s10-7]). The pacer abandons its
  accumulated debt and re-anchors its schedule.
- **The write-surface and entry violations** ([§11.3][s11-3], [§11.4][s11-4]), all raised at
  staging. The [drain](#g-drain) checks nothing. `OutOfClaimEntry` is an
  enumerated surface's binding drift, a name with no position in the
  attach-compiled schema. `ClaimedFaceEntry` is a harness write to a face
  claimed in the run's frozen partition, and it names the incumbent. The
  stopped-sim attach also fires it when it renormalizes a pending
  [batch](#g-batch). `EntryTypeMismatch` is a value unconvertible to its
  [root input](#g-root-input)'s declared type, rejected at staging for every
  writer.
- **A tolerated [device](#g-device)-side datum failure** ([§11.6][s11-6],
  [§13.4][s13-4]). `MalformedDatum` is emitted by the author's loop via
  `report!(handle, …)` into the device's own cell ([§11.8][s11-8]). It succeeds
  `InputMappingError`.
- **Staging discarded during [replay](#g-replay)** ([§12.7][s12-7]).
  `ReplayDiscardedStaging` reports a live batch found staged while the
  [trace](#g-trace) feeds the drain.
- **Thread-budget tightness** ([§12.2][s12-2]). Raised once per run, at
  `run!` or `replay!`, against the frozen [roster](#g-roster).
- **Device join timeout** ([§12.4][s12-4]). A device task exceeds the shutdown
  join timeout and is abandoned by name rather than hanging `run!`. It arises
  after the terminal snapshot. It is therefore collected into the
  [termination record](#g-termination-record) and presented through the
  logging backend, never carried into a status ([D-201][d-201],
  [D-203][d-203]).
- **Device crash** ([§12.4][s12-4], [§13.4][s13-4]). The framework wrapper
  catches a device task's failure, and the sim continues with the device
  absent.
- **Unbounded run** ([§13.5][s13-5]). `run!` is called in `:live` with
  `t_end = Inf` and no honoured stop request. A `run!` in `:replay` is bounded by
  the recording and raises nothing. `UnboundedRun` lands in the loop's own
  cell, because `run!` mutates state ([D-255][d-255]).

