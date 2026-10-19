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

**A diagnostic is a plain value from a small closed set of
[kinds](#g-kind)** ([D-058][d-058]). [Appendix C][sC] enumerates that set
normatively. For each kind it records the kind name, the [payload](#g-payload)
fields, the owning section, the severity, where the kind is raised and under
which policy ([D-214][d-214]). That index is the reference the [§8.4][s8-4]
walkthroughs, run as acceptance tests, and the error-message work are written
against. Tests match on kind plus payload fields, never on message text, so
messages are pure presentation ([D-058][d-058]).

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
  [localized](#g-localized) event's crossing instant is bracketed by root-finding. Its
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
- `DeviceCrash`, a device crash ([§12.4][s12-4], [§13.4][s13-4]). A genuine bug takes the per-device
  crash path. The framework wrapper catches a device task's failure and reports
  `DeviceCrash`, and the run goes on without the device unless its attachment set
  [`should_abort`](#g-should_abort) (the per-attachment failure policy, an `attach!` keyword) ([§11.6][s11-6]).
- `UnboundedRun`, an unbounded run ([§13.5][s13-5]). It lands in the loop's own diagnostic
  cell, because `run!` mutates state ([D-255][d-255]).

### 13.3 Build primitives: `resolve` and the face-list accessors

The `input_passthrough` sketch ([§8.8][s8-8]) calls two of the primitives below without
defining them. This section gives the three forms, the two duties resolution
enforces, which client each duty binds and why, and the standing of
`resolve_terminal`.

**All three are normative in the forms given here** ([D-061][d-061]).

- `resolve(assembly, path::String) → AbstractComponent` resolves an immediate
  child, a container element's key segment included.
- `input_faces(c)` / `output_faces(c) → Vector{String}` return the stringified keys
  of a leaf's `u_types` / `y_types` (the key set is `T`-independent). For an [assembly](#g-assembly)
  they return the face names of `input_wires(c)` / `output_wires(c)`. Declaration
  order is preserved, which gives deterministic printouts and stable
  diagnostics.
- `resolve_terminal(assembly, path) → (component, name)` splits off a terminal
  path's final segment and resolves the prefix through `resolve`. The split is
  unambiguous because [face](#g-face) names (the names ports wear on their
  component's boundary) may contain dots but never slashes ([§8.6][s8-6]).

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

**Which rule applies depends on who is resolving** ([D-130][d-130]).
[D-083][d-083] separates the reads a build's correctness rests on from the
reads that only observe it. The same line runs through resolution. Three kinds
of client share one resolution, and each gets the rule its promises require.

| client | who resolves | what resolution enforces |
|---|---|---|
| wiring | connection declarations, in the structure step | the one-level rule: an immediate child and one of its faces |
| service | [condition](#g-condition) entries (the path-addressed sparse overlay that sets a build's state), trim `reads`, [taps](#g-taps) (the selector lists linearization seeds and reports), [device](#g-device) read [bindings](#g-binding) (the values passed at `attach!` that make a device framework-legible), log extraction by `series` ([§14.3][s14-3], [§14.7][s14-7], [§14.10][s14-10], [§11.2][s11-2], [D-406][d-406], [D-407][d-407]) | strict: no traversal past a generic child, checked at the authoring or mount level |
| inspection | [snapshot](#g-snapshot) (the immutable per-boundary publication) and log inspection ([D-310][d-310]) | the instance walk |

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

The scoping is one principle, not three concessions. What varies across
the three clients is not how far a client is trusted. It is what a violation
costs, and where the cost lands. An inspection client claims no
substitutability. It addresses one build's instances, and a broken inspection
read fails at its own site, harming only the observer. A wiring entry is
carried by the declaring *type* and compiled into every instantiation. That is
why its endpoints stop at the boundary. A wire reaching past one would fail at
substitution time, at a different site, for whoever exercised the substitution
the field advertised. That is the non-local failure class the error discipline
exists to eliminate ([§8.4][s8-4]). The rule is strict exactly where a promise
depends on it, and relaxed exactly where none is made ([D-083][d-083],
[D-130][d-130]). Strictness forbids nothing outright for a service path.
Declaring the field's concrete type restores the deep read legally, with the
hard-coding visible in the declaration itself. For wiring there is no deep
route left to restore, because the face chain is the route ([§6.1][s6-1]).

Which of the three treatments a client resolves under is internal framework
fact, never user-facing API ([D-130][d-130]). The two ways of applying one plan ([§14.4][s14-4])
use the same arrangement and have the same status.

Inside the framework only wiring resolution calls `resolve_terminal`. The
services and the readers split their own paths through the service walk
([§14.3][s14-3], [§14.4][s14-4]).

### 13.4 Runtime failures: one catch site, an execution cursor

A runtime failure of model code is a throw inside a [frame](#g-frame) (one iteration of the
loop) or inside [boundary zero](#g-boundary-zero). Boundary zero is the initialization [boundary](#g-boundary) (a
published consistency point), and it runs the ordinary boundary macro-sequence
with an empty integrate. The framework catches the failure at one site, records
where execution stood, and names how to reproduce it. This section covers, in
order, where a failure is caught, the runtime carrier, the interrupt, the
disposition, reproduction, boundary zero, the nonfinite check and device-side
failures.

#### Where a failure is caught

The [`Model`](#g-model) is the deployment and its executor at one scalar. **The `Model`'s `frame!`
wraps each whole frame, every boundary it settles included, in a single `try`**, and
its `init!` wraps boundary zero the same way ([D-317][d-317]). The code inside the `Model`'s
`try` is the guarded sequence. A boundary's macro-sequence runs integrate →
project → event iteration → [ticks](#g-tick) → publication. Ticks are the instants at which
discrete leaves run their stages and update. **`frame!` never wraps per stage or per
[component](#g-component)** (the unit of modeling, a leaf or an assembly of components) ([D-059][d-059]).
The loop wraps each frame in a `try` of its own, which decides the failure's
disposition (below) and builds no carrier ([D-317][d-317]).

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

```julia
# the cursor: one mutable field of the executor, overwritten per dispatch
mutable struct ExecutionCursor
    …    # what it records, per the prose above: component path
         # (component-list index), which function, and the boundary phase
end
```

#### The runtime carrier

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

Conformance failure ([§9.5][s9-5]) needs no separate path. At the table-write
point it throws as every fail-fast site does, a `DiagnosticError` holding the
one diagnostic, and it arrives at the same catch site ([D-235][d-235]).
**The catch site unwraps a single-diagnostic `DiagnosticError` thrown inside
the guarded sequence**, and the `StepError`'s `cause` is that diagnostic
([D-221][d-221]). That unwrapping is the species rule. A
[species](#g-species) of `StepError` is one whose `cause` is a diagnostic. The
conformance failure's species carries the field-diff [payload](#g-payload)
(the structured data a diagnostic carries beside its kind). The rule keeps the
catch site the only `StepError` constructor. A `StepError` arriving at the
catch site is therefore an invariant failure, while a runtime check stays a
plain thrower of its kind ([D-221][d-221]). A collected carrier has no single
kind and rides as `cause` unchanged. No runtime check throws one.

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

```julia
# the runtime carrier: its parameter the cause's type — a diagnostic's kind
# for a species, the exception model code threw otherwise
struct StepError{C <: Union{Diagnostic, Exception}} <: Exception
    cursor         # the cursor's frame at the catch
    t::Float64     # the clock at the failure
    boundary::Int  # the frame-entry boundary index: the replay pointer
    host::Symbol   # :boundary_zero under init!, :loop inside a frame
    cause::C
end
```

#### The interrupt

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

#### The disposition

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

#### Reproduction

Reproducibility holds by construction. Staged inputs are drained and recorded
to the [trace](#g-trace) (the primary record of a session) at the frame top,
*before* the boundary executes. So the failing boundary's inputs are already
in the trace when it fails. The error names the frame-entry boundary `k` to
replay to. `replay!(sim2, trc; to_boundary = k)` halts exactly at that frame
top ([D-128][d-128]). It halts in `:replay`, the
[input mode](#g-input-mode) that keeps the recording attached, so the failing
frame's record is still ahead of the simulation ([§12.7][s12-7],
[D-218][d-218]). `step!` then applies that record and re-executes the failing
frame under instrumentation, [localized](#g-localized) boundaries included.

```julia
replay!(sim2, trc; to_boundary = k)   # halt at the frame top; still :replay
step!(sim2; frames = 1)               # re-execute the failing frame, instrumented
```

#### Boundary zero

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

#### The nonfinite check

Divergence is not termination. Dynamics that blow up (ground penetration, an
unstable gain) produce NaNs that defeat guards. NaN comparisons are false, so no
declared guard will catch them. An `isfinite` pass over the flat state [buffer](#g-buffer) (the
contiguous vector backing all continuous state), run by the model after every
return from the integrator backend, fails fast as `NonfiniteState`, a `StepError`
species naming the component, the state leaf and the frame-entry boundary. It
catches diverging models generally, not just post-terminal ones.

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

**`ẋ` does not participate in the check** ([D-157][d-157]). A nonfinite
derivative contaminates its own state block's step result within that very
step. The `x` check at the next boundary is therefore the same detection with
identical component attribution. And `ẋ` buffers are integrator scratch. They
are written per stage, meaningful only inside a step, and not
boundary-consistent in the sense the check is stated over.

#### Device-side failures

Under domain separation, device-side user code fails in the
device's own domain, because loop bodies and mappings run on the device task
([§11.4][s11-4], [§11.6][s11-6]). It fails in two classes ([D-105][d-105]).
A genuine bug takes the per-device crash path. The wrapper reports
`DeviceCrash`, and the run goes on without the device unless its attachment
set [`should_abort`](#g-should_abort) (the per-attachment failure policy, an
`attach!` keyword) ([§11.6][s11-6]). The liveness heartbeat is how a hang
shows instead ([§12.2][s12-2]). An unmappable datum is not a failure at all.
The loop body tolerates and reports it as `MalformedDatum` ([§11.6][s11-6]).
Device code shares no mutable state with the model ([D-022][d-022]), so the
two failure domains never mix.

