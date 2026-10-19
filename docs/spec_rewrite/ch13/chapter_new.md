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
the [generic-holding](#g-generic-holding) rule, which governs the deep paths a service or a reader is
given. It is enforced by the service walk, which follows *declared field types*
alongside instances. Every service and the read resolver run it over an authored
path. A segment that traverses *past* a generically-held field (one whose declared
type is non-concrete) is a diagnostic, even though the concrete instance in hand
would resolve it. Resolving *to* a generic child is legal, as access at the level
of a [port](#g-port) (one declared input or output). An unknown segment errors with the
sibling field list in hand. Paths are validated before anything runs on them,
and renames break loudly ([D-061][d-061]).

**Which rule applies depends on who is resolving** ([D-130][d-130]). [D-083][d-083] separates the
reads a build's correctness rests on from the reads that only observe it. The
same line runs through resolution. Three clients share one resolution, and each
gets the rule its promises require.

| client | who resolves | what resolution enforces |
|---|---|---|
| wiring | connection declarations, in the structure step | the one-level rule: an immediate child and one of its faces |
| service | [condition](#g-condition) entries (the path-addressed sparse overlay that sets a build's state), trim `reads`, [taps](#g-taps) (the selector lists linearization seeds and reports), [device](#g-device) read [bindings](#g-binding) (the values passed at `attach!` that make a device framework-legible), log extraction by `series` ([§14.3][s14-3], [§14.7][s14-7], [§14.10][s14-10], [§11.2][s11-2], [D-406][d-406], [D-407][d-407]) | strict: no traversal past a generic child, checked at the authoring or mount level |
| inspection | [snapshot](#g-snapshot) (the immutable per-boundary publication) and log inspection | the instance walk |

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
defining question. The stop scan, the one read a run acts on, belongs to [§13.5][s13-5].

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

Inside the framework only wiring resolution calls `resolve_terminal`. Condition
addressing ([§14.3][s14-3]) and the readers ([§14.4][s14-4], [D-406][d-406]) split their own paths through
the service walk.

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
evaluation's product, the output port names each stage produces and the
execution order) carries. The second is which function is running, one of
`y_state`, `y_direct`, `x_deriv`, `s_update`, a [guard](#g-guard) (the declared function defining an
event's predicate), a handler, or `x_projection`. The third is the boundary phase,
one of the frame-top drain, integration stage *k*, the arrival [sweep](#g-sweep) (one pass
through the execution order), the θ = 0 validation, a localization trial,
projection, event round *r*, or the ticks. Maintaining the cursor costs one cheap
store per dispatch on a single-tasked executor, with no allocation and no
exception handlers. It covers every user-code surface uniformly, including the
forgettable ones. Those are the evaluations of the [RHS](#g-flow) (the continuous
derivative function) at interior RK stage points and the guard evaluations at
the trial points of ITP or Brent root-finding ([§10.4][s10-4]).

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
    cursor         # the cursor frame: the cursor's copy at the catch
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

### 13.5 Termination is a state, not an exception

This section specifies how a model ends its own run, how an advance chooses
which stop requests to honour, and what the run records when it ends.
FlightCore's `SimulationTermination` idiom (model code throws, and the loop
catches and logs it as informational) **has no counterpart here** ([D-060][d-060]). **Graceful
termination is model state, never an exception** ([D-060][d-060]). It reaches the loop
through declared machinery. The discipline is that **exceptions from model code
are always abnormal** ([D-060][d-060]).

The wall-clock channel, through a front end's stop button ([D-310][d-310]), a
device handle or code, is orthogonal and untouched. That is the operator path
of the [control plane](#g-control-plane) (the separate atomic surface carrying
pause, pace and stop). The sim-time, model-detected channel specified here
meets it at [§12.4][s12-4] and nowhere else.

The section covers, in order, detection and publication, placement and
requesters, the policy per advance, the scan and the source order, unbounded
runs, the termination record, ignored requests and post-terminal dynamics, and
the rejected mechanisms beside the reads a run acts on.

#### Detection and publication

Detection is ordinary [guard](#g-guard) (the declared function defining an event's
predicate), handler and mode machinery ([D-060][d-060]). If the stop should be localized,
declare the [predicate](#g-predicate) (a `Bool`-valued form, or the sign of a continuous
function) as a sign-form event. Such an event is [localized](#g-localized) (the crossing instant
bracketed by root-finding over trial sweeps). A landing-gear strut's touchdown
overload is precisely a zero-crossing. The [boundary](#g-boundary) (a published consistency
point) is localized to the crossing, and the handler sets `m.crashed`. The
[snapshot](#g-snapshot) (the immutable per-boundary publication) at the crossing instant
carries the touchdown state.

Publication is a [stop request](#g-stop-request), an output [port](#g-port) (the addressable unit of the
model) of the framework enum `StopFlag`, declared where the stop's `Bool` is
detected. **A port whose type is exactly `StopFlag` is a stop request**, whoever
publishes it ([D-316][d-316]). The enum is `@enum StopFlag NO_STOP STOP_REQUESTED`. An
enum is one leaf, pinned at every activation ([§4.3][s4-3]), and [cells](#g-cell) (typed entries of
the signal table) are stored per element type ([§9.7][s9-7]), so every request in the
model lands in one `StopFlag` block. The stop's `Bool` is gathered at the
boundary of the assembly that owns it, in one visible block. The landing gear
`Ldg` from the example of [§6.1][s6-1] ORs its three legs through a junction (the
ownership idiom, [§6.2][s6-2]; the library, [§13.7][s13-7]). It wires the result into a
`StopRequest` child, described below. No level above it re-exports anything,
because the loop reads the request where it is.

**The library spelling is `StopRequest`** ([D-316][d-316]). It is a stateless
continuous leaf in the mould of `Constant` ([§13.7][s13-7]). Its one input is
the stop's `Bool`, its one output the flag, and its reason is instance data.

```julia
# StopRequest — a stateless continuous leaf; its reason is instance data
struct StopRequest <: AbstractComponent
    reason::String
end
StopRequest(; reason = "") = StopRequest(reason)
x_init(::StopRequest) = (;)
u_types(::StopRequest) = (request = Bool,)
y_types(::StopRequest) = (flag = StopFlag,)
y_direct(::StopRequest, (; u)) = (flag = u.request ? STOP_REQUESTED : NO_STOP,)
stop_reason(c::StopRequest) = c.reason
```

Its output is consumed by nobody, which [§6.1][s6-1] allows silently ([D-084][d-084]).
`StopRequest` is continuous, so it refreshes at every boundary, `t*` included
([§10.4][s10-4], [D-316][d-316]). Assemblies are virtual for execution and rate scopes touch
discrete children only, so one leaf sits anywhere in the tree ([§10.5][s10-5], [D-019][d-019]).
Fed by a discrete detector, it sees the tick at the tick's own boundary, because
the boundary sweep walks the full execution order in topological order ([§10.5][s10-5],
[D-147][d-147]). The block holds no privilege. Any [component](#g-component) (the unit of modeling, a
leaf or an assembly of components) may publish a `StopFlag` port directly.

#### Placement and requesters

Placement is checked at build. **Two placements are `IllegalPortType`** ([D-316][d-316]). A
`StopFlag` leaf nested inside a port of another type is refused with reason
`:stop_flag_nested`, and a root input whose type carries a `StopFlag` anywhere
with reason `:stop_flag_at_root`. The first is refused because the build lists
requests per port, so a request inside a struct field or a static array would
have no listing of its own. The second is refused because a request is the
model's, never an operator's. A `StopFlag` input port places nothing and is left
alone.

**The build records one `Requester(path, port, reason)` per `StopFlag` output
port**, as the `requesters` of the activation's cell layout, index-aligned with
the `StopFlag` block ([D-316][d-316]). This list is the requester roster (the build's
list of stop requests, one `Requester(path, port, reason)` per `StopFlag` output
port, in build order), and it names every request. The requester at index `i`
owns the block's offset `i - 1`. The reason is the publishing component's
`stop_reason`, an optional declaration with default `""` ([§8.2][s8-2]). One reason
serves all of a component's requests. It is instance data on the component,
never a port value.

#### The policy per advance

[§12.6][s12-6] declares the stop policy per advance, with `t_end` and
`ignore_stop_requests` as keywords of `run!`, `replay!` and `step!`, and gives
the value's lifetime. Each of the three calls takes `Inf` and `()` as the
defaults ([D-255][d-255]). The defaults belong to the calls that take the policy. With no
constructor defaults the [trace header](#g-trace-header) (the trace's fixed preamble) has no policy
to record ([§11.5][s11-5]). The [termination record](#g-termination-record) (the stopped-sim value naming how the
run ended) carries the policy that actually ended the run. The ignore list sits
beside `t_end` at the same declaration site.

**Every request is honoured unless the advance ignores it** ([D-316][d-316]).
`ignore_stop_requests = :all` ignores every requester. An iterable of
strings names requesters by component path. Each path is validated against
the requester roster on every call, and duplicates collapse, in the order
given. A path naming no requester is `StopRequestInvalid`, collected over the
given paths ([Appendix C][sC]). A `t_end` that is not a non-negative real is
`ArgumentInvalid`, refused before the ignore list is read.

Each advance builds a [`StopPolicy`](#g-stop-policy) (the immutable value of `t_end` plus the
ignored requester paths), and passes it to the loop with an ignore mask, one
`Bool` per requester, as a second argument ([D-316][d-316]). A `t*` hit reaches the loop
as the return value of the `Model`'s `frame!`, a `Bool` saying whether the frame
was abandoned, never as a field of the policy or of the [execution cursor](#g-execution-cursor) (the
field recording where execution stands) ([D-261][d-261], [D-317][d-317]). The loop then reads the
requester off the snapshot it just published.

#### The scan and the source order

**After *every* published boundary the loop scans the `StopFlag` block of the
snapshot it just published**, in requester roster order ([D-316][d-316]).
Grid boundaries, `t*` ([§10.4][s10-4]) and [boundary zero](#g-boundary-zero)
(the initialization boundary at `t₀`) ([§14.5][s14-5]) all count. The first
honoured request reading `STOP_REQUESTED` initiates [§12.4][s12-4] shutdown
with *this* snapshot as the final one. The terminal snapshot is the terminal
state. There is no roll-back, and nothing [§12.4][s12-4] does not already do.
That terminal snapshot's status carries the run's final cumulative diagnostic
counters ([§11.8][s11-8]).

Every advance checks the latest snapshot for an honoured request before its
first frame. After `init!` that snapshot is boundary zero's, so an authored
[condition](#g-condition) (the path-addressed sparse overlay that sets a build's state) already
terminal ends the run at `t₀` with that snapshot final, integrating nothing. A
run that starts later ends where it started, advancing no frame.

**The sources are consulted in a fixed order** ([D-203][d-203]). The loop checks a pending
control stop at frame top, then `t_end`, then the stop requests at each
publication. When two sources hold at one boundary, the termination record names
the first in that order ([D-203][d-203]).

Authors are taught that stop requests are sampled at completed boundaries, and
that a stop that must be localized needs a sign-form event. Both shapes of the
stop's `Bool` feeding a request work without framework latching. A handler-set
`m` flag is sticky by nature. A transient stage-2 Bool is caught because the
loop reacts to the first request it reads holding. Compound stop logic composes
in-model, as a monitor component reading the relevant signals and feeding one
request. That is the same move [§12.5][s12-5] made for scripts.

#### Unbounded runs

**An unbounded run is allowed** ([D-255][d-255]). `run!(sim)` with `t_end = Inf` and no
honoured request is the interactive session's ordinary shape, and the [operator
interrupt](#g-operator-interrupt) (Ctrl-C, read as a control-plane stop) is its escape ([§12.4][s12-4]). The
model may have no requester, or the advance may ignore them all. `run!` raises
`UnboundedRun` before the loop starts, into the loop's own [diagnostic cell](#g-diagnostic-cell) (the
per-writer cell for runtime diagnostics and liveness), and the status record
carries it ([§11.8][s11-8], [D-255][d-255], [D-316][d-316]). Its message says which of the two cases holds.
The advisory fires in `:live` only. A `run!` in `:replay` is bounded by the
recording, whatever its policy says ([§12.7][s12-7], [D-218][d-218]).

```julia
sim = Simulation(world; h = 1//50)          # no policy here: the deployment has none

init!(sim, cond); run!(sim; t_end = 60)                     # every request honoured
init!(sim, cond); run!(sim; t_end = 60,
                        ignore_stop_requests = ("ldg/stop",))  # one requester ignored, by path
init!(sim, cond); step!(sim; frames = 100)                  # Inf and (), the defaults
init!(sim, cond); run!(sim; ignore_stop_requests = :all)    # unbounded: UnboundedRun, then fly
```

#### The termination record

**The termination record names the source, as a typed value** ([D-203][d-203]). The run's
termination record carries its *outcome*, and the `StopPolicy` of the advance that
ended it ([D-255][d-255], [D-260][d-260]). The record holds four things, the final boundary time,
the terminating policy, the source and the tail residue (the post-account
diagnostics the run's-end sweep folds in). [§11.8][s11-8] specifies that sweep. **The time
is always present**, because boundary zero precedes every record and a throw
inside boundary zero writes none ([§12.6][s12-6], [D-233][d-233]). The source follows the
diagnostic convention, so its type is its identity and its payload is plain data
([§13.2][s13-2], [D-203][d-203]). There are four source types.

- `EndTimeReached` means `t_end`'s frame completed. It has no payload. The
  record's own `t` is the fact, and the bound that was configured is in the
  record's own policy.
- `ModelRequestedStop` means an honoured stop request read `STOP_REQUESTED`.
  The payload is the requester's component path, its port and its reason.
  When two requests hold at one boundary, the record names the first in
  requester roster order ([D-316][d-316]).
- `ControlRequestedStop` means a control-plane stop. The payload is its
  issuer, the requesting device, `:code` or `:interrupt` ([§12.1][s12-1]).
- `LoopError` means the abnormal entry of [§13.6][s13-6]. The payload is the
  propagated cause. A throw inside the frame reaches the record with the
  `Model` already marked `:inconsistent` by its own catch, and the simulation
  reads `errored`. A loop fault outside the frame, in the pacer, a yield or
  the tail, closes the run as `stopped` with the `Model` consistent at its
  last settled boundary, since only the `Model`'s own catch sites mark it
  ([D-317][d-317]). The record covers both exactly alike.

A `stopped` simulation therefore answers "why did it stop?" without its
consumer reconstructing the answer from the clock. It answers "how did the
stop go?" from the same value. **The operator interrupt is a tag on an
ordinary stop**, not a source type of its own, because nothing failed
([D-203][d-203]). [Appendix C][sC] gains nothing from it.

#### Ignored requests and post-terminal dynamics

An ignored request is still a cell in every snapshot, so the log records when
validity broke even on a run that continued ([D-316][d-316]). Two uses share
the mechanism, validity breakdown and scenario completion. The reason string
is what tells a reader which, and the framework never will.

Post-terminal dynamics are the model's job, and that is a feature. `robot2d`,
FlightApps' self-balancing robot in Flight.jl, *throws* `LostBalance`, a
`SimulationTermination`, past 45° of tilt, because it has no other way to say
"my dynamics are no longer meaningful". Here it declares the fall as an event,
switches to a frozen mode, and feeds `fallen` to a stop request. The frozen mode
is a mode-dependent `x_deriv`, machinery the model already has. Honoured, the
request ends the sim at the fall. Ignored, the sim integrates a frozen robot,
which is well-defined, unlike an uncaught throw. The discipline forces models to
have well-defined terminal states, which is better modeling ([D-060][d-060]).

#### Rejected mechanisms and the reads a run acts on

The rejected mechanisms, litigated in [D-060][d-060] and [D-316][d-316], are predicate closures
such as `stop_when = snap -> …`, root-type-declared stop policy, `terminal`
event flags, a control-plane capability for components, observation-by-path (an
advance naming a deep path into any public output), and the `Bool` face
re-exported level by level to the root and named by the advance. The per-advance
policy is not the root-type-declared one, and the re-exported face fell to stop
requests. [D-060][d-060] also rejected [blessed](#g-blessed) (explicitly sanctioned where a neighboring
practice is forbidden) terminal types scanned from the tree, an arm the stop
request supersedes on its own terms.

Rejecting observation-by-path separates inspection from the reads a run acts on,
a line [D-316][d-316] narrows. Inspection is human-facing, has no effect on run
semantics, and legitimately sees every public cell. The log retaining the full
table, a front end's panels rendering a component's ports, and inspection under
[replay](#g-replay) (the ordinary loop re-driven from a recorded trace) are all inspection. A
read the run acts on changes what the run *does*, and it reads only what the model
declared for it, never an arbitrary cell. The stop scan is the one such read. It
reads the `StopFlag` block, which holds nothing but the requests their authors
declared by type. [§13.3][s13-3] scopes path resolution by client, on a line of its own.
The ignore list addresses the `Build`'s requester roster, a build product like
the root-input list. It binds at an advance, a stopped-sim point where
conditions already address state by path ([§14.1][s14-1]). The requester is loud at
inspection, since the requester roster and the termination record name it. A
substitution that changes when runs end is answered by the ignore list ([D-060][d-060]),
and disabling is one keyword. The trigger is the author's knowledge and the
ignore list the integrator's. Output devices are the other half of the same
doctrine. Their reads are inspection on snapshot paths ([§11.2][s11-2]), though attach
resolves them strictly, as [§13.3][s13-3]'s service clients ([D-406][d-406]).

### 13.6 Abnormal shutdown: one tail, two entries

A failure on the loop's side can arrive in the middle of a
[boundary](#g-boundary) (a published consistency point). The run must still
end through the shutdown tail of [§12.4][s12-4], which starts from a final
[snapshot](#g-snapshot) (the immutable per-boundary publication). This
section gives the abnormal path, the reason it is safe, the two entries
charted, the record it writes, tail hygiene, and what an errored simulation
keeps and refuses.

**The abnormal path discards the failed boundary, promotes the previous snapshot
to final, and rejoins the ordinary tail** ([D-030][d-030]). The protocol becomes one tail
with two entry points. Graceful entry follows a *completed* final boundary, and
abnormal entry follows a *discarded* one. Everything downstream of "final
snapshot" runs identically. That covers sticky stopped, waiters woken through
the boundary-counter plus `Condition` path, the hooks `unblock!` and
`shutdown!`, and named joins with timeout. Those waiters observe stopped rather
than a new boundary, so no [device](#g-device) (an attached participant in the periphery) is
left with a hanging task.

The abnormal path is safe because the boundary is all-or-nothing outside the
loop ([D-030][d-030]). That is why a `StepError` cannot break [§12.4][s12-4]. [Sweeps](#g-sweep) (passes
through the execution order) write into table blocks. Integration intermediates
live in framework-owned integrator buffers, never in the scratch of a [component](#g-component)
(the unit of modeling, a leaf or an assembly of components). That scratch is its
[workspace](#g-workspace) (declared by allocation and excluded from state semantics), as [§7.3][s7-3]
defines it. The only externally visible act is snapshot publication at the very
end of the sequence. A boundary that throws has published nothing. The last
*published* snapshot is a complete, consistent boundary by construction, and it is
still the newest thing any device, logger or waiter has seen.

```
  graceful entry                      abnormal entry
  final boundary completes            failed boundary discarded
  final snapshot published            previous snapshot promoted to final
             |                                   |
             +-----------------+-----------------+
                               |
                       "final snapshot"
                               |
       sticky stopped → waiters woken → unblock! and shutdown!
                     → named joins with timeout
```

This fills the seat [§12.4][s12-4] reserved for it. A loop-side failure runs
the same protocol from the catch path ([D-030][d-030]). The
[termination record](#g-termination-record) (the stopped-sim value naming how
the run ended) covers this entry too. Its source is `LoopError`, and the
payload is the propagated cause ([§13.5][s13-5], [D-203][d-203]).

Tail hygiene follows from the hooks being user code too. Each is individually
caught and logged. Shutdown therefore runs to completion even if a device's
hook misbehaves. The join timeout already bounds a hook that hangs rather than
throws.

What is lost is quarantined. A throw inside the frame leaves the [stores](#g-store) (the
framework-owned homes of a component's `x`, `s` and `m`) possibly holding
mid-boundary values, such as a half-written `m` or integration intermediates.
They are retained on the errored simulation for post-mortem inspection. An
errored simulation is terminal, not resumable, and the reproduction tool is
[trace](#g-trace) [replay](#g-replay) (the ordinary loop re-driven from a recorded trace), not
resurrection ([§12.6][s12-6], [D-059][d-059], [D-387][d-387]). A trace is a session's record of its drained
inputs. The stopped-sim services enforce that non-resumability by refusing an
errored simulation outright (`ServiceLifecycle`, [§14][s14]). Operations on the [roster](#g-roster)
(the list of attached device entries) refuse it with them ([§11.3][s11-3], [D-232][d-232]).
Inspection is reading, but `attach!` configures a run that cannot follow. The
published record (snapshot chain, log, trace) ends at the last consistent
boundary. Nothing downstream of the sim ever sees half a boundary.

### 13.7 Tooling consequences: face routes and the component library

Generic-holding [contracts](#g-contract) (each a component's declared interface) are a
structural customer of computed interface connections, which are therefore
prominent in this section. [D-062][d-062] makes three tooling commitments for them,
namely the passthrough helpers' predicate, the routes `show(::Structure)` prints
for each root [face](#g-face) (the name a port wears on its component's boundary), and a
standard library of [components](#g-component) (the units of modeling, each a leaf or an
assembly of components). The section covers the predicate and the face routes
first, then the standard component library and the component test rig.

The passthrough helpers take a predicate. `select` is the third
selector beside `except` and `only`, on `input_passthrough` and
`output_passthrough` alike ([§8.8][s8-8], [D-251][d-251]). It stays explicit at
the declaration site, evaluated at build, and printable. That is the
[blessed](#g-blessed) (explicitly sanctioned where a neighboring practice is
forbidden) side of the auto-bubbling line, where the author writes down the
*rule* and the build evaluates it into inspectable data. Auto-bubbling means
promoting an unconnected input automatically to a
[root input](#g-root-input), one of the root component's own input faces
([D-322][d-322]).

Every artifact renders itself through `show` ([§9.2][s9-2], [D-257][d-257]). [`Structure`](#g-structure) (the
structure step's product, the components, wires, faces and tiers) has one.
**`show(::Structure)` owes face routes** ([D-257][d-257]). For every root face, that means
the resolved chain down to the producing terminal, printed as one line per chain
(`crashed → aircraft/crashed → aircraft/monitor/out`). Once faces are computed
rather than hand-listed, "what does this face actually reach" is a question the
artifact must answer, not the reader. `show(::Structure)` derives each face's
routing chain from the declared wires and prints the root's routes ([D-257][d-257],
[D-315][d-315]). Each line joins the hops with `→` and ends at the terminal. An input
face that fans out prints one line per consumer. The wiring diagnostics name
endpoints in the same slash form.

#### The standard component library

A standard component library makes good on the junction promise
([§6.2][s6-2]). That promise rests on explicit junctions being *cheap*. A
junction hand-written per arity per type is not cheap. The junctions, summing
junctions and Bool gates alike, are the library's seed ([D-062][d-062]).

**A block joins the library's inventory by judgement against three guidelines**
([D-313][d-313]). The guidelines ask whether a block is domain-agnostic and generally
useful, whether it has didactic value, and whether its implementation is
difficult to get right. None is a requirement. They are weighed, not satisfied
one by one, and a listed block is built whenever wanted. A one-line expression
such as a gain earns no block, because a separate component costs a build entry,
a cell, a gather and a scatter ([§9.7][s9-7]). Domain components, such as aerodynamics,
engines or sensors, belong in separate packages built on the framework.
Simulink's library is a language, while this is a toolbox.

The starting inventory holds the `Junction`, with `SumJunction{V, N}`, `Or{N}`
and `And{N}` as its named forms, `UnitDelay{V}`, `Constant{V}`, `Freeze{V}` and
`StopRequest`. The shipped list, and the Simulink mapping that prunes it, live
in `companions/library_inventory.md`. `UnitDelay` is the spelling the second
loop-breaking remedy ([§5.5][s5-5]) needs. `Constant{V}` is the source block ([D-143][d-143]).
`Freeze{V}` is the declared stop-gradient ([D-266][d-266]). `StopRequest` is the library
spelling of a [stop request](#g-stop-request) (an output port of the framework enum `StopFlag`)
([§13.5][s13-5], [D-316][d-316]).

The library is the submodule `Redstone.Blocks`, `Group` included, written
against the extension-only surface ([§8.1][s8-1]) as a user's component file
is ([D-313][d-313]). A workspace sub-package or a separate repository is an
after-release question.

One member is admitted by persona. `Group` is the on-the-fly
[assembly](#g-assembly) (pure composition, with no dynamics of its own), and
its declaration-layer treatment lives in [§8.5][s8-5] ([D-184][d-184]). `Group`
serves the model assembler, for whom topology is data rather than a named
type. It needs no rule the declaration layer does not already have.

The doctrine is that **library blocks are ordinary components**, with no
framework privileges and no special vocabulary ([D-062][d-062]). Ordinary
status is what keeps [schema authority](#g-schema-authority) total
(declarations define structure; evaluation only checks conformance). That
same status makes the library a permanent ergonomics
[torture test](#g-torture-test), a maximally awkward case spelled against the
declaration rules to validate them. If a three-input OR gate is painful to
write under the declaration rules, the rules are wrong.

**Arity and port types come from type parameters** ([D-311][d-311]).
`Junction{In, Out, N, F}` builds `(in1 = In, …, inN = In)` programmatically
and applies the fold its instance holds, so `Or{N}` is the junction at `|`
and `And{N}` at `&`, each a constant alias. A gate exists for its consumer,
which wants one consolidated `Bool` input instead of several. That is a
derivation [§8.2][s8-2] blesses, and an early validation that the contract
functions support parametric components.

```julia
struct Junction{In, Out, N, F} <: AbstractComponent
    f::F                              # the fold, N-ary; instance data
end
const SumJunction{V, N} = Junction{V, V, N, typeof(+)}

x_init(::Junction) = (;)              # stateless, continuous: the empty store is the tier marker (§8.2)
u_types(::Junction{In, Out, N}) where {In, Out, N} =
    NamedTuple{ntuple(i -> Symbol(:in, i), N)}(ntuple(_ -> In, N))
y_types(::Junction{In, Out}) where {In, Out} = (out = Out,)
y_direct(j::Junction, (; u)) = (out = j.f(u...),)
```

The parameters are the nominal port types and the arity, as in
`SumJunction{Wrench{Float64}, 3}`, and the fold is instance data
([D-311][d-311]). `Wrench` is FlightPhysics' force-and-torque type, here
parametrized by its scalar type as a walked type of [§7.2][s7-2].
`SumJunction{V, N}` is the `Junction` at `+`. A custom fold, such as a
weighted blend or a mass-properties composition, is written at the site as
`Junction{In, Out, N}(f)`, which infers `F`.

The junction is a continuous leaf, so its contract is written at nominal
`Float64` and the [leaf walk](#g-leaf-walk) (the framework's derivation of per-activation types
from a declared nominal type) retypes it ([§8.2][s8-2], [D-263][d-263]). An input entry at
`Wrench{Float64}` is the tolerant form a promoting consumer writes. Walking,
frozen and root-input contributors are all admissible behind it.

A named site-specific junction documents a fixed contributor set better than
generated input ports, at the price of hard-coding it into a type ([D-037][d-037]). An
example is `u_types(::VehicleWrenchSum) = (aero = …, ldg = …, pwp = …)`, whose
input entries name the aerodynamics, landing-gear and powerplant children of the
`Systems` assembly ([§6.2][s6-2]). The generic positional form remains the tool for
configuration-variable sites. Both are plain components, and the framework is
not involved.

**Wrench, mass properties and internal angular momentum each get their own
junction, never one bundled contribution struct** ([D-037][d-037],
[D-323][d-323]). Contributors are ragged, each publishing only some of the
three quantities. A bundled struct would force zero-filled identity values
through every port, the "silently sum nothing" hazard in a new coat.

A `sum_ports!`-style helper would instantiate a junction, wire it and export
its total in one call. **Such a helper is
[guarded-addition](#g-guarded-addition) sugar** (a capability the design
admits but does not build), added when real models show the pattern repeated
([D-037][d-037]).

[Tier](#g-tier)-transparency falls out of settled semantics ([D-062][d-062]), a tier being the
continuous or discrete side of the hybrid formalism. A stateless continuous
`y_direct` recomputes every [sweep](#g-sweep) (one pass through the execution order). Fed
discrete signals held by a zero-order hold, its output therefore changes only at
[ticks](#g-tick) (the instants at which a discrete component's stages and update run). No
tier-neutral variant is needed.

`UnitDelay{V}` is a discrete leaf at `K = 1`. It is the tier's native
`z⁻¹` ([§10.6][s10-6]), the shape an anti-windup chain's previous-saturation
port hand-writes (`companions/pid_anti_windup.md`). It needs no framework
support.

```julia
# UnitDelay{V} — a discrete leaf at K = 1; its initial value is instance data
struct UnitDelay{V} <: AbstractComponent
    v0::V
end
s_init(d::UnitDelay) = (v = d.v0,)
u_types(::UnitDelay{V}) where {V} = (in = V,)
y_types(::UnitDelay{V}) where {V} = (out = V,)
y_state(::UnitDelay, (; s)) = (out = s.v,)   # publishes the stored value
s_update(::UnitDelay, (; u)) = (v = u.in,)    # stores the incoming one
```

**The delay holds its initial value as instance data** ([D-312][d-312]), so
`UnitDelay(v0)` needs no `zero` method on `V`. The store is isbits by rule
([D-231][d-231]), which bounds `V`.

`UnitDelay`'s tier semantics are the point, and they must be stated wherever the
remedy is recommended ([D-348][d-348]). Inserting a `UnitDelay` into a *continuous* loop
moves that signal onto the discrete tier and inserts a [`Δt_base`](#g-dt_base)-scale
zero-order hold into the model's mathematics, `Δt_base` being the base tick
period. That is a modeling decision, because the delayed signal is genuinely
sampled rather than a transparent wire. The cycle diagnostic ([§13.8][s13-8]) therefore
says so rather than offering the remedy as free.

`Constant{V}` has no inputs, no state, and a stage-1 body returning the value
the instance holds ([D-143][d-143]).

```julia
# Constant{V} — a stateless continuous leaf; its value is instance data
struct Constant{V} <: AbstractComponent
    value::V
end
x_init(::Constant) = (;)                       # the empty store declares the tier (§8.2)
y_types(::Constant{V}) where {V} = (out = Pinned{V},)
y_state(c::Constant, _) = (out = c.value,)     # the value the instance holds
```

`Constant` is a stateless continuous leaf, so the tier-transparency argument
above already covers discrete consumers. No discrete variant is needed
([D-143][d-143]). **The leaf is deliberately [pinned](#g-walked) at that
value's own type** ([D-312][d-312]), because the block's output *is* its
stored value. A `Constant{Float64}` declares a `Pinned{Float64}` port and
means it. A constant is never seeded, so it carries zero partials under any
`Dual` [activation](#g-activation) (the build's typed products at a given
scalar type), and the pinned port says so where a walking one would promote
the value and declare less. The honest pin is spelled rather than inferred.
The same holds for every library block whose output depends on neither its
continuous state nor a walking input, such as a step source or a relay, and
each declares its `out` pinned ([D-312][d-312]).

Two uses need `Constant` ([D-143][d-143]), though a listed block needs none to be built
([D-313][d-313]). The zero-contributor configurations ([§6.2][s6-2]) are one. There, a required
aggregate input has no physical contributor, and the zero total must be spelled
as a wire. The rig stub below is the other. The block's value is instance data,
like junction arity, not an overridable default ([D-143][d-143]). A configuration wanting
an externally settable source uses a root input ([§11.3][s11-3]), which keeps the block
from drifting into a back-door input default. A handle that references bulk data
never surfaces as a root input ([D-237][d-237]); a rig holds such a handle through a
[constant source](#g-constant-source) (a `Constant` holding it) instead ([§14.9][s14-9], [D-364][d-364]).

`Freeze{V}` feeds a walking producer into a pinned entry, which the walk clause
([§6.1][s6-1]) otherwise refuses ([D-266][d-266]).

```julia
# Freeze{V} — a stateless continuous leaf; tolerant in, pinned out
struct Freeze{V <: Union{Real, StaticArray{<:Tuple, <:Real}}} <: AbstractComponent end
x_init(::Freeze) = (;)
u_types(::Freeze{V}) where {V} = (in = V,)
y_types(::Freeze{V}) where {V} = (out = Pinned{V},)
y_direct(::Freeze, (; u)) = (out = ForwardDiff.value.(u.in),)   # leafwise strip, by broadcast
```

At nominal the strip is the identity, so the block costs one gather and one
scatter. **`V` is a `Real` or a `StaticArray` of them, constrained at the type**
([D-312][d-312]), so a struct-valued freeze is refused at the spelling until a model
needs one. Under a `Dual` activation the block drops the partials, and its
output satisfies the pinned entry. What the wire then declares is a zero
coupling in every Jacobian along that path ([D-266][d-266]), the modeling decision [§14.10][s14-10]
asks an author to state on the page rather than bury mid-expression. A sampler
is the other non-walking source, and it changes the model, holding the value
between ticks ([§10.5][s10-5]). The block is for a continuous value the consumer cannot
differentiate through. Where the coupling matters to the Jacobian, the local
rule ([§14.10][s14-10]) is the answer, not this block.

#### The component test rig

The [component test rig](#g-component-test-rig) is the library's companion idiom. Exercising a leaf alone
needs no rig of its own. Any component may be the root of a build, and its input
faces then become the model's root inputs ([§8.2][s8-2], [D-208][d-208]). Ordinary [conditions](#g-condition)
(path-addressed sparse overlays that set a build's state) feed them. So do
[devices](#g-device) (attached participants in the periphery). Every output is observable in
the table of each [snapshot](#g-snapshot), the immutable per-boundary publication. The rig is a
one-child assembly whose `input_wires` surface the child's entire input face
set, as `input_passthrough(rig, "child")` verbatim ([§8.8][s8-8]). What it buys is a
place to wire something *beside* the component under test.

The demonstrated need is the root-input rule ([§8.2][s8-2]). An [abstract entry](#g-abstract-entry) (an
`u_types` entry admitting any concrete producer face), such as the illustrative
`terrain = AbstractTerrainField`, cannot surface as a root input, because
abstract-at-root is a build error, `AbstractAtRoot` ([§8.2][s8-2], [Appendix C][sC]). The rig
therefore satisfies that entry *inside* the rig ([D-120][d-120]). In the sketch below, the
component under test is `Strut`, an illustrative landing-gear strut whose
terrain input is abstract. **A concrete stub child is wired to the face**, and the
concrete remainder is exposed via
`input_passthrough(rig, "strut"; except = ("terrain",))` ([D-120][d-120]). The stub
provides `SampleTerrainField`, an illustrative concrete terrain.

```julia
struct StrutRig <: AbstractComponent    # the rig: component under test + stub
    strut::Strut
    stub::Constant{SampleTerrainField}  # the test handle, held as instance data
end

local_wires(::StrutRig) = ("stub/out" => "strut/terrain",)
input_wires(rig::StrutRig) =
    (input_passthrough(rig, "strut"; except = ("terrain",))...,)
```

That stub child is typically just a `Constant` holding the test handle, which
makes it the source block's first shipped instance ([D-143][d-143]). Bespoke
stubs remain ordinary components wherever the double must compute something.

The rig adds zero new machinery, because wiring and `except` already exist
([D-120][d-120]). It is structural substitutability doing its job. An abstract entry
declares that a substitute must be chosen. The rig chooses its test double
explicitly, as ordinary inspectable code. That is precisely the isolation the
rig exists to provide.

The rig is [`design_world`](#g-design_world)'s little sibling
([§14.9][s14-9]). Where `design_world(ac)` mounts an aircraft in a minimal
world for trim and linearization, the rig mounts one component behind its own
root faces for unit tests and open-loop probing. The machinery is deliberately
ordinary end to end, with no framework support. That makes the rig, like the
library blocks, a standing ergonomics test of the declaration rules.

### 13.8 Cycle diagnosis: feedthrough tracing

The build rejects an [algebraic loop](#g-algebraic-loop) (a genuine cycle in the instantaneous
dependency graph) ([§5.5][s5-5], [D-005][d-005]), and tracing is diagnostic only, never relied on
for correctness ([D-012][d-012]). Tracing improves error messages and verification. When
the build finds a cycle, it triggers the [feedthrough tracer](#g-feedthrough-tracer) (the set-propagation
instrument that tracks which inputs a value depends on) to classify that cycle.
A genuine cycle gets "break it with a state, a stage-1 (`y_state`) port, or a
`UnitDelay`", and an artificial one gets the remedy ladder ([§5.4][s5-4], [D-140][d-140]). Where
the diagnostic recommends a unit delay, it states the delay's [tier](#g-tier) caveat rather
than offering it as a free remedy ([§5.5][s5-5], [§13.7][s13-7], [D-348][d-348]). A tier is the continuous
or discrete side of the hybrid formalism. The parts below cover, in order, how a
cycle is detected and named, the tracer's two modes, what tracing touches, how
classification runs and decides, and the caveats and hints the diagnostic
carries.

#### Detection and naming

A cycle surfaces as a topological-sort stall in the nominal evaluation, the
build's second step and the one evaluation that feeds structure
([§9.1][s9-1]). The stalled subgraph is decomposed into strongly connected
components (SCCs). **Each nontrivial SCC names one cyclic cluster exactly**
([D-012][d-012]). Each cluster becomes one diagnostic, an `AlgebraicCycle`
error ([Appendix C][sC]). The diagnostic presents the cluster's members and
the wires among them as one readable loop of terminal pairs in the canonical
slash form ([§8.6][s8-6]), as in `aero/F → dyn/F, dyn/a → aero/a`. Neither
the raw stall residue nor a single back edge names the cluster correctly
([D-012][d-012]).

#### The tracer's two modes

**The feedthrough tracer has two modes**, and they degrade gracefully
([D-349][d-349]). Both are set-tracers. A traced value carries a set of input
indices, its tracer tags.

- The *global* (value-blind) set-tracer is a `Real` subtype that carries a set
  of input indices, unioned by every operation. It has
  may-depend semantics, a sound over-approximation. A saturated `clamp` still
  reports, and $u^2$ at $u = 0$ still reports. It is exact, in one evaluation.
  It requires the traced stage-2 code to be free of branches and lookups on
  *input-tainted* values.
- The *sampled* set-tracer (the log's *local* mode) at sampled states is the
  fallback whenever the global tracer hits an undecidable branch, such as
  piecewise friction, stall blending or any gridded lookup at an input-tainted
  coordinate. It reports the dependence pattern of the taken paths, sampled
  across randomized states. Its only misses are untaken branches ([D-012][d-012], [D-349][d-349]).

#### What tracing touches

**Only *inputs* are seeded** ([D-349][d-349]), so branching on state, modes, parameters or time
never interferes. Stage-2 functions also receive state views, but neither those
nor the stage-1 hand-down are ever seeded. Stage-1 functions are never traced,
since there is nothing to seed. Derivatives, [guards](#g-guard) (the declared functions
defining each event's predicate), handlers and [projections](#g-projection) (the optional
per-component hook `x ← x_projection(x)`) are outside tracing's jurisdiction
entirely.

A known tracer blind spot is documented. Value-severing operations pass
dependence through a bare `Int` index, as a nearest-neighbor lookup does.
Linear and cubic interpolation are immune, because dependence flows through
the fractional weights.

**Dual-cleanliness in CI effectively guarantees traceability** ([D-349][d-349]). Dual-clean
means passing the `T = Dual` sweep of [§7.2][s7-2], `Dual` being ForwardDiff's dual
number. The guarantee holds because both modes ride the same `T <: Real`
genericity as `Dual`.

#### Classification

Classification needs no [execution order](#g-execution-order), the order in
which the stage functions run ([D-012][d-012]). It runs inside the nominal
evaluation's failure path, where no execution order exists. None is needed,
because each SCC member is evaluated *once, in isolation*, at the
[probe](#g-probe) point (the initial state, where the build probes every user
function). That evaluation reads state views from the `x_init`, `s_init` and
`m_init` declarations, out-of-cycle cell values from the acyclic prefix's probe
values, and in-cycle cell values synthesized through `probe_value`
([§9.3][s9-3]) under tracer tags. The tracer's product is a per-member
dependence set rather than a value, so no ordering has to be valid for the
labels to come out right.

Classification touches no activation machinery. There is no [activation](#g-activation) (the
build's typed products at a given scalar type), no layouts and no table. The
cycle classifier uses the *per-member* variant of tracing (the log's *local*
variant), an order-free trace at the probe point ([D-012][d-012]). The "tracer
activation" ([§9.4][s9-4]) names the other variant ([D-012][d-012]), the global set-tracer run as
an ordinary activation. The two must not be conflated. The per-member variant is
not the sampled mode. A member's map may come from either mode.

**The traced maps decide the verdict as one graph question over the cluster**
([D-245][d-245]). The verdict is the one [§5.4][s5-4] defines. Every wire
holds. A hop inside a member runs from the [face](#g-face) (the name a port
wears on its component's boundary) that one wire enters to the port the next
wire leaves. The hop holds iff that member's map routes the face to the port.
The loop is real iff a cycle survives in that graph. It is artificial iff none
does, because every cycle through the cluster crosses a dead hop, at a
component whose stage-2 function does not in fact route that input to that
output. **The diagnostic lists every dead hop under either verdict**, so a
real loop still shows the chords the trace found false ([D-245][d-245]). For a
simple cycle this reduces to the expected reading, that the loop is real iff
every hop survives.

#### Caveats and hints the diagnostic carries

The diagnostic carries the tracer's caveats rather than assuming them away.
**The trace speaks for the branch taken at the probe point**, the
diagnostic-only doctrine ([D-012][d-012], [D-343][d-343]). **Discrete members
trace structurally**, because the discrete tier's plain, wholesale-pinning
declarations admit no tracer scalar ([D-012][d-012]). **The remedy hint is
offered only for continuous members** ([D-140][d-140], [D-343][d-343]),
because structural tracing is sound as a may-depend answer but never sharp.
**The hops through a continuous face or port declared with no
[walking](#g-walked) leaf trace structurally too** ([D-245][d-245],
[D-343][d-343]), because such a face or port admits no tracer scalar either.
A walking leaf is one whose type follows the activation scalar.

**The diagnostic records the source of each member's map** ([D-245][d-245]).
The source is the global tracer, sampled states or structure. A reader can
thus weigh a dead hop found on a few sampled paths against one found exactly.
The hint itself is to split this component, *or* to narrow the neighbor's
[contract](#g-contract) (its declared interface) when the dead hop's input is
consumed only in a fallback branch. Those are the ladder's two remedies
([§5.4][s5-4], [D-140][d-140], [D-343][d-343]).

The build diagnostic offers both exits explicitly ([D-140][d-140], [D-343][d-343]). For a loop
between `systems/aero` and `systems/dyn` it reads "artificial at port level:
`systems/aero`'s `F` does not route `a`; split `systems/aero`, or narrow the
neighbor's contract if `a` is consumed only in a fallback branch". The dead hop
runs from the member's input face that its stage-2 function does not route to
the output port. The diagnostic carries the dead hop ([D-245][d-245]) as a separate field
of its [payload](#g-payload) (the structured data a diagnostic carries) rather than dotting
the hop onto the path ([§8.6][s8-6], [§13.2][s13-2]).

If a member's evaluation itself throws, the diagnostic ships with its members
and wires alone, unclassified. Classification is a bonus on the cycle error,
never its precondition ([D-012][d-012]).

---

