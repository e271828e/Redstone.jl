## 13. Error discipline

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

### 13.1 Reporting policy: collect the checks, fail the evaluations fast

The build's failure sites split into two populations. That split settles the
choice between fail-fast and compiler-style reporting. Each population takes
the policy that fits it. This section covers, in order, the two populations
and their policies, the step barrier, the dependency rule that decides which
passes run past a failure, and the absence of cascade suppression.

**Declarative checks over collected structure collect, and user-code
evaluation fails fast** ([D-057][d-057]).

- The collecting checks are those for unconnected inputs, two producers, wire
  typos and type mismatches, [face](#g-face)-name uniqueness,
  `y_types`/state-field consistency and `sample_times` validation. Each is a
  pass over a list. The whole-tree obligation check literally computes *the
  set of* inputs whose obligation chain never terminates. Reporting every
  violation is the natural output of such a pass, and truncating to the first
  would be extra work. These failures also cluster in practice. A freshly
  written [assembly](#g-assembly) (pure composition, with no dynamics of its
  own) has five unwired inputs, and a renamed [port](#g-port) breaks three
  wires. Each of these passes returns its full violation list.
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

The build's steps are barriers ([D-259][d-259]). A step that produced any
error-severity diagnostic, from either population, throws before the next step
begins. Probing against unresolved wiring would be meaningless.

**Collection reaches the step barrier, under a dependency rule**
([D-229][d-229]). A declarative pass runs when the results it reads are clean.
It records every violation it finds and returns a total result. Every pass
that ran merges into the barrier's one throw.

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

**There is no cascade suppression within a step** ([D-057][d-057]). This is a
deliberate simplification. A wire typo'd as `:throtle` produces two errors.
One is a [did-you-mean](#g-did-you-mean) error (the offending name plus the
list-in-hand it should have matched). The other is an unconnected-input error
for the intended `throttle`. Both are reported in the one throw, and the
did-you-mean names the input the other error says is unfed, so the pairing
explains itself.

### 13.2 Diagnostics: structured values, one carrier exception

Both reporting policies move the same thing. What a collecting pass returns and
what a fail-fast site produces is in either case a *diagnostic*. The shape of
that value decides what an acceptance test can assert and what a user reads.

#### The diagnostic and its carrier

**A diagnostic is a plain value from a small closed set of [kinds](#g-kind)** ([D-058][d-058]). [Appendix
C][sC] enumerates that set normatively. For each kind it records the kind name, the
[payload](#g-payload) fields (the structured data a diagnostic carries beside its kind), the
owning section, the severity, where the kind is raised and under which policy
([D-214][d-214]). That index is the reference the [§8.4][s8-4] walkthroughs, run as acceptance
tests, and the error-message work are written against. Tests match on kind plus
payload fields, never on message text, so messages are pure presentation
([D-058][d-058]).

Each kind carries its own structured payload. The payload holds endpoint paths,
[face](#g-face) names, expected and observed types, and the *list-in-hand* a [did-you-mean](#g-did-you-mean)
needs. A did-you-mean is the offending name plus the list-in-hand it should have
matched. A kind *is* a Julia type.

**Severity is a property of the kind, not of the occurrence** ([D-214][d-214]). It is `error`
or `warning`, and it says whether an occurrence ever throws. It is read as
`severity(d)` and never stored per occurrence. The severity field of [Appendix C][sC] is
derived from it. Where an occurrence surfaces (build, service or runtime) and
how it is reported (collected, fail-fast, logged or rate-limited) are the *raised*
and *policy* fields of [Appendix C][sC]. Those two fields describe the occurrence, not
the kind. `BundleFieldError`, for example, is raised at the [probe](#g-probe) and, at runtime,
as a [species](#g-species) of the runtime carrier `StepError` ([§13.4][s13-4]). A species is a `StepError`
whose `cause` is a diagnostic.

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

```julia
# a diagnostic value: its kind is its identity, its payload is plain data
abstract type Diagnostic end
struct WireTypeMismatch <: Diagnostic   # one kind of the closed Appendix C set
    …                                   # payload fields per Appendix C: paths and
                                        # names as Strings, port types as types
end

# the carrier: one exception, its parameter the policy — a kind for a
# fail-fast throw, the collection type for a barrier's throw
struct DiagnosticError{P <: Union{Diagnostic, Vector{Diagnostic}}} <: Exception
    carried::P
    warnings::Vector{Diagnostic}   # the build's warnings so far, rendered with the throw
end
```

Two rendering rules are doctrine, not style ([D-058][d-058]).

- The first rule is *strings, never instances*. Diagnostics carry paths and names
  as strings, never [component](#g-component) instances and never component types. This is the
  lesson of FlightCore's `compact_backtrace`. Expected and observed *[port](#g-port)* types are
  the one payload exception, and they are small. Examples are a `Float64` against
  a `Bool`, and a NamedTuple field diff.
- The second rule is that the didactic style is policy. Every diagnostic states
  the fix or the lists-in-hand, not just the violation. Examples are "return
  `zero(x.ω)`, not `0`" and "no input `throtle`; did you mean `throttle`?", or the
  child's face list shown alongside the unknown name given to `except`.

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

**One exception type, the `FieldError`, is recognized rather than merely
framed** ([D-341][d-341]). A `FieldError` carries its type and field as data
(Julia ≥ 1.12). At the probe the framework matches them against the bundle's
own NamedTuple type, which the accessor holds. At the runtime catch site it
matches them against the bundle's field names, because the bundle's type
there is the activation's and is not in hand ([D-248][d-248]). A tuple the
author builds with the bundle's own names is indistinguishable from the
bundle at either site, and the diagnosis stays true of it. The result is the
bundle-law did-you-mean ([§5.2][s5-2]). It carries the legal field set and
classifies the miss as an undeclared store, a wrong [tier](#g-tier) (the
continuous or discrete side of the hybrid formalism), or a field illegal for
this function. Nothing is recovered by reading message text.

The probe raises the result as `BundleFieldError` ([Appendix C][sC],
[D-248][d-248]). An example message is "`systems/plant`: `x_deriv`
destructures `m`, but `systems/plant` declares no `m_init`". The message names
the component by its path. One law covers tier facts, stage legality and
declarations alike. The wrong-tier miss covers the state letters too
([D-195][d-195]). `x` and `m` are continuous-only, and `s` and `Δt` are
discrete-only, so destructuring any of the four on the wrong tier is a
wrong-tier fact. The bundle stays a bare NamedTuple ([D-074][d-074],
[D-341][d-341]). A getproperty-wrapper spelling is the recorded fallback,
should type-matched interception prove insufficient ([D-341][d-341]).

#### Where warnings live

**A warning raised while producing an [artifact](#g-artifact) lives on that
artifact** ([D-250][d-250]). A warning raised while mutating
[state](#g-state-single-owner) lives in that state's status. Logging is
presentation and never a home. An artifact is an immutable pure function of
its inputs. State is single-owner and mutated in place. That one criterion
places every warning the framework raises.

The build produces artifacts, so its warnings live on them. [§9.2][s9-2] states which
artifacts carry them, how `warnings(x)` reads the list, and how a step that throws
or completes presents them. The build's warning set holds `EmptyFaceSelection`
([§8.8][s8-8], [D-251][d-251]). The warning set of the [`Deployment`](#g-deployment) (the scalar-free artifact the
grid parameters fix) holds `GridUtilization` ([D-254][d-254]). The unconnected-output
warning stays rejected ([§6.1][s6-1], [D-084][d-084]), so the *collected*-warning category stays
open and empty. A warnings-as-errors switch is rejected, since a warning is a
fact about the model, not a defect ([D-250][d-250]).

A stopped-sim service returns an artifact, so its warnings live on it. `trim!`
returns a `TrimReport`, and `TrimCommitEvents`, `TrimCommitResiduals` and
`TrimCommitChecks` are that report's fields ([§14.8][s14-8]). The line the call prints at
return is presentation. `attach!` is the other side of the criterion. It mutates
the [roster](#g-roster) (the list of attached device entries). `EmptyGreedyClaim` therefore
lands in the roster entry's [diagnostic cell](#g-diagnostic-cell) (the per-writer cell for runtime
diagnostics and liveness) ([§11.6][s11-6], [D-250][d-250]).

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

The committed runtime warnings, in one place, are these.

- `ChatteringBudget`, for [chattering](#g-chattering) or localization-budget exhaustion ([§10.4][s10-4]). A
  [localized](#g-localized) event's crossing instant is bracketed by root-finding. The event's
  bracketing budget runs out at a [boundary](#g-boundary) (a published consistency point).
- `FiringBudget`, firing-budget exhaustion ([§10.6][s10-6]). An event has
  spent its `firing_budget` at a boundary, and its further edges there are
  dropped.
- `DebtReanchor`, a forgiven-debt re-anchor ([§10.7][s10-7]). The pacer
  abandons its accumulated debt and re-anchors its schedule.
- The write-surface and batch-entry violations ([§11.3][s11-3], [§11.4][s11-4]), all raised at
  staging. The [drain](#g-drain) (the frame-top swap that applies staged writes) checks
  nothing. `OutOfClaimEntry` ([§11.3][s11-3]) is an enumerated surface's binding drift, a
  name with no position in the attach-compiled schema. `ClaimedFaceEntry` ([§11.3][s11-3],
  [§11.4][s11-4]) is a harness write to a face claimed in the run's frozen partition, and
  it names the incumbent. The stopped-sim attach also fires it when it
  renormalizes a pending [batch](#g-batch). `EntryTypeMismatch` ([§11.4][s11-4]) is a value
  unconvertible to the declared type of its [root input](#g-root-input) (the root component's own
  input face), rejected at staging for every writer.
- `MalformedDatum`, a tolerated datum failure on the side of a [device](#g-device) (any
  attached participant in the periphery) ([§11.6][s11-6], [§13.4][s13-4]). It is emitted by the
  author's loop via `report!(handle, …)` into the device's own diagnostic cell
  ([§11.8][s11-8], [D-105][d-105]). It replaces FlightCore's `InputMappingError`.
- `ReplayDiscardedStaging`, staging discarded during [replay](#g-replay) (the ordinary loop
  re-driven from a recorded trace) ([§12.7][s12-7]). It reports a live batch found staged
  while the [trace](#g-trace) (the primary record of a session) feeds the drain.
- `ThreadBudget`, thread-budget tightness ([§12.2][s12-2], [D-401][d-401]). It
  is raised once per run, at `run!` or `replay!`, against the frozen roster.
- `DeviceJoinTimeout`, a device join timeout ([§12.4][s12-4]). A device task exceeds the
  shutdown join timeout and is abandoned by name rather than hanging `run!`. It
  arises after the terminal snapshot. It is therefore collected into the
  [termination record](#g-termination-record) (the stopped-sim value naming how the run ended) and
  presented through the logging backend, never carried into a status ([D-201][d-201],
  [D-203][d-203]).
- `DeviceCrash`, a device crash ([§12.4][s12-4], [§13.4][s13-4]). The framework wrapper catches a
  device task's failure, and the run goes on without the device unless its
  attachment set [`should_abort`](#g-should_abort) (the per-attachment failure policy, an `attach!`
  keyword) ([§11.6][s11-6]).
- `UnboundedRun`, an unbounded run ([§13.5][s13-5]). It lands in the loop's own diagnostic
  cell, because `run!` mutates state ([D-255][d-255]).
