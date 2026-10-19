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

### 13.3 Build primitives: `resolve` and the face-list accessors

The `input_passthrough` sketch ([§8.8][s8-8]) calls two of the primitives below
without defining them. All three are normative in the forms given here.

- `resolve(assembly, path::String) → AbstractComponent` is the getfield walk along
  `/`-segments.
- `input_faces(c)` / `output_faces(c) → Vector{String}` return the stringified
  keys of a leaf's `u_types` / `y_types` (the key set is
  `T`-independent). For an [assembly](#g-assembly) they return the entries of
  `input_wires(c)` / `output_wires(c)`. Declaration order is
  preserved, which gives deterministic printouts and stable diagnostics.
- `resolve_terminal(assembly, path) → (component, name)` splits off a terminal
  path's final segment and resolves the prefix through `resolve`. The split is
  unambiguous because [face](#g-face) names may contain dots but never slashes
  ([§8.6][s8-6]).

**The walk enforces two duties, and they belong to different clients.** The
first is the one-level rule ([§6.1][s6-1]). A connection endpoint resolves to
an immediate child and one of its [faces](#g-face). A wiring path reaching
further is a build error, `PathResolution`, whatever the declared field types
along it. The second is the generic-holding rule, which governs the deep paths the read side
still writes. The walk follows *declared field types* alongside instances. A
segment that traverses **past** a generically-held field (one whose declared
type is non-concrete) is a diagnostic, even though the concrete instance in
hand would resolve it. Resolving *to* a generic child is [port](#g-port)-level
access and legal. An unknown segment errors with the sibling field list in
hand. Paths are validated at build time, and renames break loudly
([D-061][d-061], [D-130][d-130]).

**Which rule applies depends on who is resolving.** [D-083][d-083]
separates the reads a build's correctness rests on from the reads that only
observe it. The same line runs through resolution. Three kinds of client share
one primitive, and each gets the rule its promises require. The two ways of
applying one plan ([§14.4][s14-4]) use the same arrangement.

| client | who resolves | what the walk enforces |
|---|---|---|
| **wiring** | connection declarations, in the structure step | the one-level rule: an immediate child and one of its faces |
| **service** | [condition](#g-condition) entries (the path-addressed sparse overlay that sets a build's state), trim `reads`, [taps](#g-taps) ([§14.3][s14-3], [§14.7][s14-7], [§14.10][s14-10]) | strict: no traversal past a generic child, checked **at the authoring or mount level** |
| **inspection** | [device](#g-device) read [bindings](#g-binding), GUI panels, [snapshot](#g-snapshot) and log inspection ([§11.2][s11-2], [§11.7][s11-7]) | the instance walk |

Each client's treatment has its own warrant. Wiring is what the law
([§6.1][s6-1]) is stated for, so wiring resolution applies that law verbatim.
Under one-level routing the generic-holding question never arises there,
because an endpoint stops before any field it could traverse past. Service
paths are checked at the authoring or mount level for two reasons. First, the
locality law is an authoring-level law, and absolute paths are a compiled
derivative ([§14.2][s14-2]). Second, the mount itself checks a mount prefix,
where the problem's authored names resolve through the export chain from the
mount point ([§14.9][s14-9]). So the service check covers the authored path
below that prefix. Inspection walks instances instead. A generic
[seam](#g-seam) is not an error for a client that never claimed
substitutability. "What is in *this* build" is inspection's defining question.
Drift still stays loud. An unknown path or name is refused at attach, as a
`PathResolution` or a `ReadResolution`, with a [did-you-mean](#g-did-you-mean) (the offending
name plus the list-in-hand it should have matched) ([§13.3][s13-3], [D-406][d-406]).

**The scoping is one principle, not three concessions.** What varies across
the three clients is not how far a client is trusted. It is what a violation
costs, and where the cost lands. An inspection client claims no
substitutability. It addresses one build's instances, and a broken binding
fails at attach, at its own site, harming only the observer. A wiring entry is
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

Which of the three rules a client resolves under is internal framework fact,
never user-facing API. The two ways of applying one plan ([§14.4][s14-4]) have
the same status.

`resolve_terminal` is first-class because five clients share it across the
three rules. Wiring resolution is one. Condition addressing ([§14.3][s14-3])
and tap resolution ([§14.10][s14-10]) are service clients. Device-binding
validation ([§11.2][s11-2]) and snapshot inspection are inspection clients.
The result is one splitter and one did-you-mean site.

### 13.4 Runtime failures: one catch site, an execution cursor

**Where caught.** The frame of the [`Model`](#g-model) (the deployment and
its executor at one scalar) wraps each execution of the
[boundary](#g-boundary) macro-sequence (integrate → project → event
iteration → [ticks](#g-tick) → publication) in a single `try`. It never
wraps per stage or per [component](#g-component) ([D-059][d-059]). The loop
wraps each frame in a `try` of its own, which decides the failure's
disposition (below) and builds no carrier ([D-317][d-317]). Framing
information does not need
to be *caught* into existence. The [executor](#g-executor) (the compiled
form of the stage [execution order](#g-execution-order)) maintains an
**[execution cursor](#g-execution-cursor)**, a plain mutable field of the
executor recording where execution stands in the compiled order. The cursor records three facts. The first is the component path, an index into
the execution order that [`Outputs`](#g-outputs) (the nominal evaluation's product, the port
classes and the execution order) carries ([D-253][d-253]). The second is which function is running:
`y_state`, `y_direct`, `x_deriv`, `s_update`, a [guard](#g-guard), a handler,
or `x_projection`. The third is the boundary phase: integration stage *k*,
event round *r*, a localization evaluation at trial time, or tick. Maintaining
the cursor costs one cheap store per dispatch on a single-tasked executor, with
no allocation and no exception frames. It covers every user-code surface
uniformly, including the forgettable ones. Those are the [RHS](#g-flow)
evaluations at interior RK stage points, the guard evaluations at ITP/Brent
trial points, and the environment closures.

```julia
# the cursor: one mutable field of the executor, overwritten per dispatch
mutable struct ExecutionCursor
    …    # what it records, per the prose above: component path
         # (execution-order index), which function, and the boundary phase
end
```

**How handled.** The catch site wraps the original exception in `StepError`,
the runtime counterpart of the `DiagnosticError` carrier. A `StepError` carries
five things: the cursor's frame, the boundary time, the **frame-entry boundary
index**, the host of the catch, and the original exception as `cause`. The
frame-entry boundary index is the [replay](#g-replay) pointer. It names the
frame-top boundary at which the failing frame began. That frame top is a grid
boundary or [boundary zero](#g-boundary-zero) (the initialization boundary: the
ordinary macro-sequence with an empty integrate), and it is always a legal
replay halt ([§12.7][s12-7]). The host names the catch that took the throw. It
is `:loop` for a throw inside a frame, and `:boundary_zero` for a throw inside
the boundary zero that `init!` runs. A `StepError` is rendered with compact
frames per the doctrine ([§13.2][s13-2]).

Conformance failure ([§9.5][s9-5]) needs no separate path. At the table-write
point it throws as every fail-fast site does, a `DiagnosticError` holding the
one diagnostic, and it arrives at the same catch site. **The species rule.**
The catch site unwraps a single-diagnostic `DiagnosticError` thrown inside the
guarded sequence, and the `StepError`'s `cause` is that diagnostic. A
[species](#g-species) of `StepError` is one whose `cause` is a diagnostic. The
conformance failure's species carries the field-diff [payload](#g-payload).
The rule keeps the catch site the only `StepError` constructor. A `StepError`
arriving at the catch site is therefore an invariant failure, while a runtime
check stays a plain thrower of its kind ([D-221][d-221]). A collected carrier
has no single kind and rides as `cause` unchanged. No runtime check throws
one.

**The cause's type is the carrier's parameter.** `StepError{C}` takes the type
of its `cause`, bounded to a diagnostic or an exception. A species is therefore
`StepError{Kind}`, and a raw throw is `StepError{ArgumentError}` and the like.
`isa StepError` matches both ([D-225][d-225]). A test asserts a species as
`@test_throws StepError{ConformanceFailure}`, the runtime spelling of the build
carrier's idiom ([§13.2][s13-2]). A collected carrier riding as `cause` is an
exception and falls under that arm. A bare value thrown deliberately by model
code is neither, and the constructor refuses it unframed. The framework does
not handle that throw ([D-225][d-225]).

```julia
# the runtime carrier: its parameter the cause's type — a diagnostic's kind
# for a species, the exception model code threw otherwise
struct StepError{C <: Union{Diagnostic, Exception}} <: Exception
    cursor         # the cursor's frame at the catch
    t::Float64     # the boundary time
    boundary::Int  # the frame-entry boundary index: the replay pointer
    host::Symbol   # :boundary_zero under init!, :loop inside a frame
    cause::C
end
```

Reproducibility holds by construction. Staged inputs are drained and recorded
to the [trace](#g-trace) at the frame top, *before* the boundary executes. So
the failing boundary's inputs are already in the trace when it fails. The error
names the frame-entry boundary `k` to replay to.
`replay!(sim2, trc; to_boundary = k)` halts exactly at that frame top. It halts
in `:replay`, the input mode that keeps the recording attached, so the failing
frame's record is still ahead of the simulation ([§12.7][s12-7]). `step!` then
applies that record and re-executes the failing frame under instrumentation,
[localized](#g-localized) boundaries included.

```julia
replay!(sim2, trc; to_boundary = k)   # halt at the frame top; still :replay
step!(sim2; frames = 1)               # re-execute the failing frame, instrumented
```

**Boundary zero is caught too, under the service's disposition.** Boundary zero
runs inside `init!`, a stopped-sim service, not inside the loop. The
simulation's `init!` calls `init!` on its `Model`, which runs boundary zero.
Its macro-sequence executes the same user-code surfaces the frame's does,
with the cursor maintained through them, so the `Model`'s `init!` hosts the
same catch ([D-317][d-317]). A throw inside boundary zero arrives as a
`StepError` from the one constructor. Its frame comes from the cursor, its
time is `t₀`, and the species rule applies. Any throw inside boundary zero
writes the `Model`'s status back to `:built`, which returns the simulation's
lifecycle to `built` ([§12.6][s12-6]). An `InterruptException` inside
boundary zero is not model code failing, and it has no stop path to take in a
service. The host therefore lets it propagate raw, unwrapped. The pointer is
`0`. A throw inside boundary
zero leaves no trace and no [checkpoint](#g-checkpoint) (the `Model`'s state
at a frame top as one value). The run `init!` opened stays
behind, empty and with no trace header, and the run before it is gone. Nothing
can use it, since `trace(sim)` and the advances refuse a `built` simulation.
`init!` takes the trace header only after boundary zero publishes ([§11.5][s11-5]). The
reproduction of a boundary-zero failure is `init!` under the same condition
([D-274][d-274]). Boundary zero is frame one's entry boundary too, so a
frame-one failure carries the same pointer. The carrier's `host` tells the two
apart, and the rendered recipe reads it. A frame-one failure has a trace, and
the halt-then-`step!` recipe above holds for it at pointer `0`. The halt
restores the header and stops there, and `step!` re-executes frame one from
the record. Boundary zero's disposition differs from the loop's as well.
Nothing was published and no advance was under way, so there is no tail to
take and no snapshot to promote. The
simulation returns to `built`. `run!` and `step!` refuse it and name `init!`
([§12.6][s12-6]), while `init!`, `restore!` and `replay!` remain legal. The remedy for a
condition that fails at `t₀` is a corrected condition, and `init!`
re-establishes every store before it applies one ([§14.1][s14-1]). No [termination record](#g-termination-record)
is written. The stores may hold the half-transitioned `t₀` state until the next
`init!` resets them. They are retained for inspection, as an errored
simulation's are ([§13.6][s13-6]). `trim!`'s commit is an `init!` ([§14.8][s14-8]) and inherits
the rule ([D-223][d-223]).

**The one exception never wrapped.** An `InterruptException` is not model code
failing. It is the operator's stop command ([§12.4][s12-4]). So the catch site
discriminates it and routes it to the stop path. The run takes the ordinary
graceful tail and ends `stopped`, never `errored` under a `StepError`. With the
boundary masking in force ([§12.4][s12-4]) a single interrupt never reaches
the branch. It is deferred to a frame-top or wait unmask point, and never
raises inside the guarded sequence. Julia's forced throw after repeated
interrupts does reach it, and the branch's disposition is `stopped` with the
frame abandoned ([§12.4][s12-4], [D-268][d-268]). The branch is kept for that
case and defensively, because the cost of being wrong about the masking is a
terminally errored session in place of a clean stop.

**Disposition.** The `Simulation` ends in a terminal status, `stopped` or
`errored`, with the exception retrievable. A synchronous
[unattended run](#g-unattended-run) (a run with empty staging and no snapshot
readers) rethrows after the shutdown tail completes, so CI fails honestly. An
interactive session logs the rendered error and surfaces the status through
the control plane and GUI. `run!` and `replay!` discriminate the two by the
[roster](#g-roster) ([D-268][d-268]). With no device rostered the run is
unattended and rethrows. With one or more it logs the rendered error through
the logging backend and returns, the lifecycle reading `errored` and
`termination(sim)` retaining the cause. `step!` is deviceless by construction
([§12.6][s12-6]) and always rethrows.

**The nonfinite check.** Divergence is not termination. Dynamics that blow up
(ground penetration, an unstable gain) produce NaNs that defeat guards. NaN
comparisons are false, so no declared condition will catch them. A loop-level
`isfinite` [sweep](#g-sweep) over `x` at boundaries fails fast as a `StepError`
species, naming the offending component's state block and the boundary. It
catches diverging models generally, not just post-terminal ones.

*Placement is the whole value.* The sweep is the boundary's **first act**. It
runs immediately after integrate returns, before `x_projection` and before
the boundary sweep. Run there, `NonfiniteState` names the component whose own
block diverged. Run later, the NaN has already propagated. It reaches an
innocent downstream component through the ordinary signal path and surfaces as
that component's lookup-table `DomainError`, or as an `InexactError` in its
conversion. That is the error-locality inversion ([§8.4][s8-4]), designed out
of the build tier and quietly reintroduced at runtime. One `isfinite` pass over
a flat [buffer](#g-buffer) is cheap enough that placement, not cost, decides.

*Scope: `ẋ` does not participate* ([D-157][d-157]). A nonfinite derivative
contaminates its own state block's step result within that very step. The `x`
check at the next boundary is therefore the same detection with identical
component attribution. And `ẋ` buffers are integrator scratch. They are
written per stage, meaningful only inside a step, and not boundary-consistent
in the sense the check is stated over.

**Domain separation.** [Device](#g-device)-side user code fails in the device's
own domain, because loop bodies and mappings run on the device task
([§11.4][s11-4], [§11.6][s11-6]). It fails in two classes. A genuine bug takes
the per-device crash path (liveness heartbeat, `DeviceCrash`) while the sim
keeps running. An unmappable datum is not a failure at all. The loop body
tolerates and reports it (`MalformedDatum`, [§11.6][s11-6]). The two failure
domains never mix. That is exactly what the no-shared-mutable-model decision
bought.

### 13.5 Termination is a state, not an exception

FlightCore's `SimulationTermination` idiom (model code throws, and the loop
catches and logs it as informational) has **no counterpart here**
([D-060][d-060]). The discipline is that **exceptions from model code are
always abnormal**. Graceful termination is model *state*, and it reaches the
loop through declared machinery.

- **Detection** is ordinary [guard](#g-guard)/handler/mode machinery. If the
  stop should be localized, declare the [predicate](#g-predicate) as a
  sign-form event. Such an event is [localized](#g-localized) (the crossing
  instant bracketed by root-finding over trial sweeps). Touchdown overload is
  precisely a zero-crossing. The boundary is localized to the crossing, the
  handler sets `m.crashed`, and the [snapshot](#g-snapshot) at the crossing
  instant carries the touchdown state.
- **Publication** is a [stop request](#g-stop-request) (an output port of
  the framework enum `StopFlag`), declared where the condition is detected.
  **A port whose type is exactly `StopFlag` is a stop request, whoever
  publishes it** ([D-316][d-316]). The enum is `@enum StopFlag NO_STOP STOP_REQUESTED`.
  An enum is one leaf, pinned at every activation ([§4.3][s4-3]), and cells are
  stored per element type ([§9.7][s9-7]), so every request in the model lands in one
  `StopFlag` block. The condition is gathered at its owning boundary in one
  visible block. `Ldg` ORs its three legs through a junction (the ownership
  idiom, [§6.2][s6-2]; the library, [§13.7][s13-7]) and wires the result into a `StopRequest`
  child, the library's spelling of a request (below). No level above it
  re-exports anything, because the loop reads the request where it is.
- **Placement** is checked at build. **A `StopFlag` leaf nested inside a
  port of another type is `IllegalPortType`, and so is a root input whose
  type carries a `StopFlag` anywhere** ([D-316][d-316]). The first is refused because the build rosters
  requests per port, so a request inside a struct field or a static array
  would have no entry of its own. The second is refused because a request is
  the model's, never an operator's. The operator's path is the
  [control plane](#g-control-plane) ([§12.1][s12-1]). A `StopFlag` input port places
  nothing and is left alone.
- **The roster** names every request. **The build records one
  `Requester(path, port, reason)` per `StopFlag` output port, as the
  `requesters` of the activation's cell layout, index-aligned with the
  `StopFlag` block** ([D-316][d-316]). Entry `i` owns the block's offset `i - 1`, and
  roster order is build order. The reason is the publishing component's
  `stop_reason`, an optional declaration with default `""` ([§8.2][s8-2]). One
  reason serves all of a component's requests. It is instance data on the
  component, never a port value.
- **Policy** is declared per advance. `t_end` and `ignore_stop_requests` are
  keywords of `run!` and `replay!`, with `Inf` and `()` as defaults, and
  `step!` states the same defaults itself ([D-255][d-255]). **Every request is
  honoured unless the advance ignores it** ([D-316][d-316]).
  `ignore_stop_requests = :all` ignores every requester. An iterable of
  strings names requesters by component path. Each path is validated against
  the roster on every call, and duplicates collapse, in the order given. A
  path naming no requester is `StopRequestInvalid`, collected over the given
  paths ([Appendix C][sC]). Each advance builds a
  **[`StopPolicy`](#g-stop-policy)**,
  the immutable value of `t_end` plus the ignored requester paths, and passes
  it to the loop with an ignore mask, one `Bool` per requester, as a second
  argument ([D-261][d-261]). The value lives as long as the
  call, and afterwards only on the termination record of the advance that
  ended the run ([§12.6][s12-6], [D-260][d-260]). A `t*` hit reaches the
  loop as `frame!`'s return value, a `Bool` saying whether the frame was
  abandoned, never as a field of the policy or of the
  [execution cursor](#g-execution-cursor) ([D-261][d-261], [D-317][d-317]). The loop
  then reads the requester off the snapshot it just published.
  After *every* published boundary the loop scans the `StopFlag` block of
  the snapshot it just published, in roster order. Grid boundaries, `t*`
  ([§10.4][s10-4]) and [boundary zero](#g-boundary-zero) ([§14.5][s14-5]) all count. The first
  honoured request reading `STOP_REQUESTED` initiates [§12.4][s12-4] shutdown with
  *this* snapshot as the final one. The terminal snapshot is the terminal
  state. There is no roll-back, and nothing [§12.4][s12-4] does not already do. That
  terminal snapshot's status carries the run's final cumulative diagnostic
  counters ([§11.8][s11-8]).
  `run!` therefore checks the boundary-zero snapshot before the first step. An
  authored [condition](#g-condition) (the path-addressed sparse overlay that
  sets a build's state) that is already terminal ends the run at `t₀` with
  that snapshot final, integrating nothing. The request is the author's and
  the override the integrator's, and the override sits beside `t_end` at the
  same declaration site.

**The library spelling is `StopRequest`.** It is a stateless continuous
leaf in the mould of `Constant` ([§13.7][s13-7]). Its one input is the `Bool`
condition, its one output the flag, and its reason is instance data.

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
`StopRequest` is continuous, so it refreshes at every boundary, `t*`
included. Assemblies are virtual for execution and rate scopes touch
discrete children only, so one leaf sits anywhere in the tree ([§10.5][s10-5],
[D-019][d-019]). Fed by a discrete detector, it sees the tick at the tick's own
boundary, because the boundary sweep walks the full execution order in
topological order ([§10.5][s10-5], [D-147][d-147]). The block holds no privilege. Any
component may publish a `StopFlag` port directly.

**An unbounded run is allowed.** `run!(sim)` with `t_end = Inf` and no
honoured request is the interactive session's ordinary shape, and the
[operator interrupt](#g-operator-interrupt) is its escape ([§12.4][s12-4]). The model
may have no requester, or the advance may ignore them all.
The loop raises `UnboundedRun` into its own [diagnostic cell](#g-diagnostic-cell),
and the status record carries it ([§11.8][s11-8], [D-255][d-255], [D-316][d-316]). Its message says
which of the two cases holds. The
advisory fires in `:live` only. A `run!` in `:replay` is bounded by the
recording, whatever its policy says ([§12.7][s12-7], [D-218][d-218]).

```julia
sim = Simulation(world; h = 0.02)          # no policy here: the deployment has none

init!(sim, cond); run!(sim; t_end = 60)                     # every request honoured
init!(sim, cond); run!(sim; t_end = 60,
                        ignore_stop_requests = ("ldg/stop",))  # one requester ignored, by path
init!(sim, cond); step!(sim; frames = 100)                  # Inf and (), the defaults
init!(sim, cond); run!(sim; ignore_stop_requests = :all)    # unbounded: UnboundedRun, then fly
```

**Why one binding site.** A `StopPolicy` is what the caller declares for one
advance, so it is a value that advance builds ([D-255][d-255]). The defaults
belong to the calls that take it. With no constructor defaults the
[trace header](#g-trace-header) has no policy to record ([§11.5][s11-5]), and
the termination record carries the policy that actually ended the run. This is
not the root-declared stop policy rejected below. Binding at the call moves the
policy one notch *later* along the same axis, more deployment-flavored rather
than less ([D-060][d-060]). The `stopped → init! → run!` cycle and the `step!`
idiom ([§12.6][s12-6]) are precisely where one `Simulation` wants different
stopping policies on different runs.

**The termination record names the source, as a typed value.** The run's
[termination record](#g-termination-record) carries its *outcome*, and the
`StopPolicy` of the advance that ended it ([D-255][d-255]). The record
holds four things, the final boundary time, the terminating policy, the source
and the tail residue.
The tail residue is the post-account diagnostics the run's-end sweep folds in
([§11.8][s11-8]). The time is always present, because boundary zero precedes
every record and a throw inside boundary zero writes none ([§12.6][s12-6],
[D-233][d-233]). The source follows the diagnostic convention, so its kind is
its identity and its payload is plain data ([§13.2][s13-2]). It has four
kinds.

- `EndTimeReached` means `t_end`'s frame completed. It has no payload. The
  record's own `t` is the fact, and the bound that was configured is in the
  record's own policy.
- `ModelRequestedStop` means an honoured stop request read `STOP_REQUESTED`.
  The payload is the requester's component path, its port and its reason.
  When two requests hold at one boundary, the record names the first in
  roster order ([D-316][d-316]).
- `ControlRequestedStop` means a control-plane stop. The payload is its issuer
  ([§12.1][s12-1]): the requesting device, `:code`, or `:interrupt`.
- `LoopError` means the abnormal entry of [§13.6][s13-6]. The payload is the
  propagated cause. A throw inside the frame reaches the record with the
  `Model` already marked `:inconsistent` by its own catch, and the simulation
  reads `errored`; a loop fault outside the frame, in the pacer, a yield or
  the tail, closes the run as `stopped` with the `Model` consistent at its
  last settled boundary, since only the `Model`'s own catch sites mark it
  ([D-317][d-317]). The record covers both exactly alike.

A `stopped` simulation therefore answers "why did it stop?" without its
consumer reconstructing the answer from the clock. It answers "how did the
stop go?" from the same value. The
[operator interrupt](#g-operator-interrupt) is a tag on an ordinary stop, not
a [kind](#g-kind) of its own, because nothing failed. [Appendix C][sC] gains
nothing from it.

**Rule.** The sources are consulted in a fixed order. The loop checks a pending
control stop at frame top, then `t_end`, then the stop requests at each
publication. When two sources hold at one boundary, the recorded source is the
first in that order ([D-203][d-203]).

The taught contract is this. **Stop requests are sampled at completed
boundaries; declare a sign-form event if you need the stop localized.** Both
shapes of the condition feeding a request work without framework latching. A
handler-set `m` flag is sticky by nature. A transient stage-2 Bool is caught
because the loop reacts to the first request it reads holding. Compound stop
logic composes in-model, as a monitor [component](#g-component) reading the
relevant signals and feeding one request. That is the same move [§12.5][s12-5] made
for scripts.

An ignored request is still a cell in every snapshot, so the log records when
validity broke even on a run that continued. Two uses share the mechanism,
validity breakdown and scenario completion. The reason string is what tells a
reader which, and the framework never will.

Post-terminal dynamics are the model's job, and that is a feature. Today
`robot2d` *throws* when it falls, because it has no other way to say "my
dynamics are no longer meaningful". Here it declares the fall as an event,
switches to a frozen mode, and feeds `fallen` to a stop request. The frozen
mode is a mode-dependent `x_deriv`, machinery the model already has.
Honoured, the request ends the sim at the fall. Ignored, the sim integrates a
frozen robot, which is well-defined, unlike an uncaught throw. The discipline
forces models to have well-defined terminal states, which is better modeling.

The rejected mechanisms are litigated in [D-060][d-060] and [D-316][d-316]. They are predicate
closures (`stop_when = snap -> …`), root-type-declared stop policy,
`terminal` event flags, a [control-plane](#g-control-plane) capability for
[components](#g-component), and observation-by-path (an advance naming a deep
path into any public output). The `Bool` face re-exported level by level to
the root and named by the advance fell to stop requests ([D-316][d-316]). [D-060][d-060] also
rejected [blessed](#g-blessed) terminal types scanned from the tree. The stop
request supersedes that arm on its own terms. The requester is loud at
inspection, since the roster and the termination record name it.
Substitution is answered by the override, and disabling is one keyword. The
trigger is the author's knowledge and the override the integrator's.

The observation-by-path line leaves doctrine behind it, narrowed by [D-316][d-316].
**Inspection** is human-facing, has no effect on run semantics, and
legitimately sees every public [cell](#g-cell). The log retaining the full
table, GUI panels rendering a component's [ports](#g-port), and
[replay](#g-replay) inspection are all inspection. **A read the run acts on**
changes what the run *does*, and it reads only what the model declared for
it, never an arbitrary cell. The stop scan is the one such read. It reads the
`StopFlag` block, which holds nothing but the requests their authors declared
by type. The ignore list addresses the `Build`'s requester roster, a build
product like the root-input list. It binds at an advance, a stopped-sim point
where conditions already address state by path ([§14.1][s14-1]). Output devices are
the other half of the same doctrine. Their reads are inspection bindings on
snapshot paths ([§11.2][s11-2]).

The wall-clock channel (GUI stop button, device handle, code) is orthogonal
and untouched. That is the [control plane](#g-control-plane)'s operator path.
The sim-time, model-detected channel specified here meets it at
[§12.4][s12-4] and nowhere else.

### 13.6 Abnormal shutdown: one tail, two entries

**The [boundary](#g-boundary) is all-or-nothing outside the sim task.** That is
why a `StepError` cannot break [§12.4][s12-4]. [Sweeps](#g-sweep) write into
table blocks. Integration intermediates live in framework-owned integrator
buffers, never in a [component](#g-component)'s [workspace](#g-workspace) as
[§7.3][s7-3] defines it. The only externally visible act is
[snapshot](#g-snapshot) publication at the very end of the sequence. A
boundary that throws has published nothing. The last *published* snapshot is a
complete, consistent boundary by construction, and it is still the newest
thing any [device](#g-device), logger or waiter has seen.

The abnormal path therefore **discards the failed boundary, promotes the
previous snapshot to final, and rejoins the ordinary tail.** The protocol
becomes one tail with two entry points. Graceful entry follows a *completed*
final boundary, and abnormal entry follows a *discarded* one. Everything
downstream of "final snapshot" runs identically: sticky stopped, waiters woken
through the boundary-counter plus `Condition` path, `unblock!`/close hooks,
and named joins with timeout. Those waiters observe stopped rather than a new
boundary, so no device task hangs.

```
  graceful entry                      abnormal entry
  final boundary completes            failed boundary discarded
  final snapshot published            previous snapshot promoted to final
             |                                   |
             +-----------------+-----------------+
                               |
                       "final snapshot"
                               |
       sticky stopped → waiters woken → unblock!/close hooks
                     → named joins with timeout
```

This fills the seat [§12.4][s12-4] reserved for it. A loop-side failure runs
the same protocol from the catch path. The
[termination record](#g-termination-record) covers this entry too. Its source
is `LoopError`, and the payload is the propagated cause ([§13.5][s13-5],
[D-203][d-203]).

Tail hygiene follows from the hooks being user code too. Each is individually
caught and logged. Shutdown therefore runs to completion even if a device's
hook misbehaves. The join timeout already bounds a hook that hangs rather than
throws.

What is lost is quarantined. The state [stores](#g-store) may hold
mid-boundary values (a half-written `m`, integration intermediates). They are
retained on the errored `Simulation` for post-mortem inspection, but an
errored sim is terminally stopped, not resumable. The reproduction tool is
[trace](#g-trace) [replay](#g-replay), not resurrection. The stopped-sim
services enforce that non-resumability by refusing an errored simulation
outright (`ServiceLifecycle`, [§14][s14]). The roster operations refuse it
with them ([§11.3][s11-3], [D-232][d-232]). Inspection is reading, but
`attach!` configures a run that cannot follow. The published record (snapshot
chain, log, trace) ends at the last consistent boundary. Nothing downstream of
the sim ever sees half a boundary.

### 13.7 Tooling consequences: face routes and the component library

Termination chains are the second structural customer of computed interface
connections, after generic-holding [contracts](#g-contract). Computed
connections are therefore prominent in this section. Two commitments follow, a
library and an idiom.

The passthrough helpers take a predicate. `select` is the third
selector beside `except` and `only`, on `input_passthrough` and
`output_passthrough` alike ([§8.8][s8-8], [D-251][d-251]). It stays explicit at
the declaration site, evaluated at build, and printable. That is the
[blessed](#g-blessed) side of the auto-bubbling line, where the author writes
down the *rule* and the build evaluates it into inspectable data.

**Every artifact renders itself through `show`** ([§9.2][s9-2], [D-257][d-257]). [`Structure`](#g-structure) (the
structure step's product, the components, wires, faces and tiers) has one. So
does [`Outputs`](#g-outputs) (the nominal evaluation's product, the port classes and the execution order).
So does [`Events`](#g-events) (the nominal evaluation's event tables), which
prints each component's event names with their policies.
So does [`Schedule`](#g-schedule) (the typed per-component `(D, Φ, Δt)` tick table). So do `Build`
and [`Deployment`](#g-deployment) (the scalar-free artifact the grid parameters fix). There are no
accessor functions returning the tables alongside. `show(::Build)`'s parts
include the events. Between the outputs table and the events table it prints a
line of the [feedthrough](#g-feedthrough) edges (instantaneous input→output
dependences). The edges are derived from the structure's connections and the
producers' stage-2 names ([D-261][d-261]).

**`show(::Structure)` owes [face](#g-face) routes.** For every root face,
that means the resolved chain down to the producing terminal, printed as one
line per chain (`crashed → aircraft/crashed → aircraft/monitor/out`). Once
faces are computed rather than hand-listed, "what does this face actually
reach" is a question the artifact must answer, not the reader.
`show(::Structure)` derives each face's routing chain from the declared wires
and prints the root's routes ([D-257][d-257], [D-315][d-315]). Each line joins the hops with `→` and ends
at the terminal. An input face that fans out prints one line per consumer. The
same rendering serves the wiring diagnostics, which already carry endpoint
paths.

#### The standard component library

**A standard [component](#g-component) library makes good on the junction
promise ([§6.2][s6-2]).** That promise rests on explicit junctions being
*cheap*. A junction hand-written per arity per type is not cheap. The
junctions, summing junctions and Bool gates alike, are the library's seed
([D-062][d-062]).

The starting inventory holds the
`Junction`, with `SumJunction{V, N}`, `Or{N}` and `And{N}` as its named
forms, `UnitDelay{V}`, `Constant{V}`, `Freeze{V}` and `StopRequest`. `UnitDelay` is the spelling the second
loop-breaking remedy ([§5.5][s5-5]) needs. `Constant{V}` is the source block.
`Freeze{V}` is the declared stop-gradient ([D-266][d-266]). `StopRequest` is
the library spelling of a [stop request](#g-stop-request) (a port that ends
the run when it reads `STOP_REQUESTED`, [§13.5][s13-5], [D-316][d-316]). The request
is its port's `StopFlag` type, which any component may publish, so the block
holds no privilege.
**A block joins the library's inventory by judgement against three
guidelines** ([D-313][d-313]). The guidelines ask whether a block is
domain-agnostic and generally useful, whether it has didactic value, and
whether its implementation is difficult to get right. None is a
requirement. They are weighed, not satisfied one by one, and a listed block
is built whenever wanted. The inventory, and the Simulink mapping that
prunes it, is `companions/library_inventory.md`. A one-line expression such
as a gain earns no block, because a separate component costs a build entry,
a cell, a gather and a scatter ([§9.7][s9-7]). Domain components, such as
aerodynamics, engines or sensors, belong in separate packages built on the
framework. Simulink's library is a language, while this is a toolbox.

The library is the submodule `Redstone.Blocks`, `Group` included, written
against the extension-only surface ([§8.1][s8-1]) as a user's component file
is ([D-313][d-313]). A workspace sub-package or a separate repository is an
after-release question.

One member is admitted by persona rather than by need. `Group` is the
on-the-fly [assembly](#g-assembly), and its declaration-layer treatment lives
in [§8.5][s8-5] ([D-184][d-184]). `Group` serves the model assembler, for whom
topology is data rather than a named type. It needs no rule the declaration
layer does not already have.

The doctrine is that **library blocks are ordinary components**, with no
framework privileges and no special vocabulary. Ordinary status is what keeps
[schema authority](#g-schema-authority) total (declarations define structure;
evaluation only checks conformance). That same status makes the library a
permanent ergonomics [torture test](#g-torture-test). If a three-input OR gate
is painful to write under the declaration rules, the rules are wrong.

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

The junction is a continuous leaf, so its contracts are written at nominal
`Float64` and the leaf walk retypes them ([§8.2][s8-2]). An input entry at
`Wrench{Float64}` is the tolerant form a promoting consumer writes. Walking,
frozen and root-input contributors are all admissible behind it.

A named site-specific junction documents a fixed contributor set better than
generated slots, at the price of hard-coding it into a type ([D-037][d-037]).
An example is `u_types(::VehicleWrenchSum) = (aero = …, ldg = …, pwp = …)`.
The generic positional form remains the tool for configuration-variable
sites. Both are plain components, and the framework is not involved.

Wrench, mass properties and internal angular momentum each get their own
junction, never one bundled contribution struct ([D-037][d-037],
[D-323][d-323]). Contributors are ragged, each publishing only some of the
three quantities. A bundled struct would force zero-filled identity values
through every port, the "silently sum nothing" hazard in a new coat.

A `sum_ports!`-style helper would instantiate a junction, wire it and export
its total in one call. **Such a helper is
[guarded-addition](#g-guarded-addition) sugar** (a capability the design
admits but does not build), added when real models show the pattern repeated
([D-037][d-037]).

[Tier](#g-tier)-transparency falls out of settled semantics. A stateless
continuous `y_direct` recomputes every [sweep](#g-sweep). Fed ZOH-held
discrete signals, its output therefore changes only at [ticks](#g-tick). No
tier-neutral class is needed.

`UnitDelay{V}` is a **discrete** leaf at `K = 1`. It is the tier's native
`z⁻¹` ([§10.6][s10-6]), the shape an anti-windup chain's previous-saturation
port hand-writes. It needs no framework support.

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

`UnitDelay`'s tier semantics are the point, and they must be stated wherever
the remedy is recommended ([D-348][d-348]). Inserting a `UnitDelay` into a *continuous*
loop moves that signal onto the discrete tier and inserts a `Δt_base`-scale ZOH
into the model's mathematics. That is a modeling decision, because the delayed
signal is genuinely sampled rather than a transparent wire. The cycle
diagnostic ([§13.8][s13-8]) therefore says so rather than offering the remedy
as free.

`Constant{V}` is the **source block**. It has no inputs, no state, and a
stage-1 body returning the value the instance holds.

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
above already covers discrete consumers. No discrete variant is needed. The
block's output *is* its stored value, so **the leaf is deliberately
[pinned](#g-walked) at that value's own type** ([D-312][d-312]). A
`Constant{Float64}` declares a `Pinned{Float64}` port and means it. A
constant is never seeded, so it carries zero partials under any `Dual`
[activation](#g-activation) (the build's typed products at a given scalar
type), and the pinned port says so where a walking one would promote the
value and declare less. The honest pin is spelled rather than inferred.
The same holds for every library block whose output depends on neither its
continuous state nor a walking input, such as a step source or a relay, and
each declares its `out` pinned ([D-312][d-312]).

`Freeze{V}` is the **declared stop-gradient**. It feeds a walking producer
into a pinned entry, which the walk clause ([§6.1][s6-1]) otherwise refuses.

```julia
# Freeze{V} — a stateless continuous leaf; tolerant in, pinned out
struct Freeze{V <: Union{Real, StaticArray{<:Tuple, <:Real}}} <: AbstractComponent end
x_init(::Freeze) = (;)
u_types(::Freeze{V}) where {V} = (in = V,)
y_types(::Freeze{V}) where {V} = (out = Pinned{V},)
y_direct(::Freeze, (; u)) = (out = ForwardDiff.value.(u.in),)   # leafwise strip, by broadcast
```

At nominal the strip is the identity, so the block costs one gather and one
scatter. **`V` is a `Real` or a `StaticArray` of them, constrained at the
type** ([D-312][d-312]), so a struct-valued freeze is refused at the spelling
until a model needs one. Under a `Dual` activation it drops the partials, and its output
satisfies the pinned entry. What the wire then declares is a zero coupling in
every Jacobian along that path, the modelling decision [§14.10][s14-10] asks an
author to state on the page rather than bury mid-expression. A sampler is the
other non-walking source, and it changes the model, holding the value between
[ticks](#g-tick) ([§10.5][s10-5]); the block is for a continuous value the consumer cannot
differentiate through. Where the coupling matters to the Jacobian, the local
rule ([§14.10][s14-10]) is the answer, not this block.

Two demonstrated needs admit `Constant` under the inventory's demonstrated-need
charter. The zero-contributor configurations ([§6.2][s6-2]) are one. There, a
required aggregate input has no physical contributor, and the zero total must
be spelled as a wire. The rig stub below is the other. The block's value is
instance data, like junction arity, not an overridable default. A
configuration wanting an externally settable source uses a
[root input](#g-root-input) ([§11.3][s11-3]). That keeps the block from
drifting into a back-door input default.

#### The component test rig

**The [component test rig](#g-component-test-rig) is the library's companion
idiom.** Exercising a leaf alone needs no rig of its own. Any component may be
the root of a build, and its input [faces](#g-face) then become the model's
root inputs ([§8.2][s8-2], [D-208][d-208]). Ordinary conditions and
[devices](#g-device) feed them, and every output is observable in the
[snapshot](#g-snapshot) table. The rig is a one-child assembly whose
`input_wires` surface the child's entire input face set, as
`input_passthrough(rig, "child")` verbatim ([§8.8][s8-8]). What it buys is a
place to wire something *beside* the component under test.

The demonstrated need is the root-input rule ([§8.2][s8-2]). An *abstract*
input entry (`terrain = AbstractTerrainField`, [§8.2][s8-2]) cannot surface as
a root input, because abstract-at-root is a build error. The rig therefore
satisfies that entry *inside* the rig. A concrete stub child (a
`SampleTerrainField` provider) is wired to the face, and the concrete
remainder is exposed via
`input_passthrough(rig, "strut"; except = ("terrain",))`.

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
makes it the source block's first shipped instance. Bespoke stubs remain
ordinary components wherever the double must compute something.

The rig adds zero new machinery, because wiring and `except` already exist. It
is the substitutability contract doing its job. An
[abstract entry](#g-abstract-entry) (an `u_types` entry admitting any
concrete producer face) declares that a substitute must be chosen. The rig
chooses its test double explicitly, as ordinary inspectable code. That is
precisely the isolation the rig exists to provide.

The rig is [`design_world`](#g-design_world)'s little sibling
([§14.9][s14-9]). Where `design_world(ac)` mounts an aircraft in a minimal
world for trim and linearization, the rig mounts one component behind a root
contract for unit tests and open-loop probing. The machinery is deliberately
ordinary end to end, with no framework support. That makes the rig, like the
library blocks, a standing ergonomics test of the declaration rules.

### 13.8 Cycle diagnosis: feedthrough tracing

The build rejects an algebraic loop ([§5.5][s5-5]), and tracing is diagnostic
only, never relied on for correctness ([D-012][d-012]). Tracing improves error
messages and verification. When the build finds a cycle, it triggers the
[feedthrough tracer](#g-feedthrough-tracer) (the set-propagation instrument
that tracks which inputs a value depends on) to classify that cycle. A genuine
cycle gets "break it with a state, a stage-1 (`y_state`) port, or a
`UnitDelay`", and an artificial one gets the remedy ladder
([§5.4][s5-4]). Where the diagnostic recommends a unit delay, it states the
delay's tier caveat rather than offering it as a free remedy ([§5.5][s5-5],
[§13.7][s13-7], [D-348][d-348]). The parts below cover, in order, how a cycle
is detected and named, the tracer's two modes and what tracing touches, how
classification runs and decides, and the caveats and hints the diagnostic
carries.

#### Detection and naming

A cycle surfaces as a topological-sort stall in the [nominal](#g-nominal)
evaluation (the build's second step, the one evaluation that feeds structure).
The stalled subgraph is decomposed into strongly connected components (SCCs).
**Each nontrivial SCC names one cyclic cluster exactly** ([D-012][d-012]).
Each cluster becomes one diagnostic, an `AlgebraicCycle` error
([Appendix C][sC]). The diagnostic presents the cluster's members and the wires
among them as one readable loop of terminal pairs in the canonical slash form
([§8.6][s8-6], `aero/F → dyn/F, dyn/a → aero/a`). Neither the raw stall residue
nor a single back edge names the cluster correctly ([D-012][d-012]).

#### The tracer's two modes

**The feedthrough tracer has two modes**, and they degrade gracefully
([D-349][d-349]). Both are set-tracers. A traced value carries a set of input indices,
its tracer tags.

- The *global* (value-blind) set-tracer is a `Real` subtype that carries a set
  of input indices, unioned by every operation. It has
  may-depend semantics, a sound over-approximation. A saturated `clamp` still
  reports, and $u^2$ at $u = 0$ still reports. It is exact, in one evaluation.
  It requires the traced stage-2 code to be free of branches and lookups on
  *input-tainted* values.
- The *local* (primal-carrying) set-tracer at sampled states is the fallback
  whenever the global tracer hits an undecidable branch, such as piecewise
  friction, stall blending or any gridded lookup at an input-tainted
  coordinate. It reports the dependence pattern of the taken paths, sampled
  across randomized states. Its only misses are untaken branches
  ([D-012][d-012], [D-349][d-349]).

#### What tracing touches

**Only *inputs* are seeded** ([D-349][d-349]), so branching on state, modes, parameters or
time never interferes. Stage-2 functions also receive state views, but neither
those nor the stage-1 hand-down are ever seeded. Stage-1 functions are never
traced, since there is nothing to seed. Derivatives, [guards](#g-guard) (the declared
functions defining each event's predicate), handlers and [projections](#g-projection) are outside
tracing's jurisdiction entirely.

A known tracer blind spot is documented. Value-severing operations pass
dependence through a bare `Int` index, as a nearest-neighbor lookup does.
Linear and cubic interpolation are immune, because dependence flows through the
fractional weights.

**Dual-cleanliness in CI effectively guarantees traceability**
([D-349][d-349]). Dual-clean means passing the `T = Dual` sweep of
[§7.2][s7-2]. The guarantee holds because both modes ride the same
`T <: Real` genericity as `Dual`, ForwardDiff's dual number.

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

Classification touches no activation machinery. There is no [activation](#g-activation) (the
build's typed products at a given scalar type), no layouts and no table. The
cycle classifier uses the *local* variant of tracing ([D-012][d-012]), the order-free
per-member trace at the probe point. The "tracer activation" ([§9.4][s9-4]) names the
other variant ([D-012][d-012]), the global set-tracer run as an ordinary activation. The
two must not be conflated. The local variant is not the local set-tracer mode. A
member's map may come from either mode.

#### Caveats and hints the diagnostic carries

The diagnostic carries the tracer's caveats rather than assuming them away. The
trace speaks for the branch taken at the probe point (the diagnostic-only
doctrine, [D-012][d-012], [D-343][d-343]). **Discrete members trace structurally**, because the
discrete [tier](#g-tier)'s plain, wholesale-pinning declarations admit no tracer scalar
([D-012][d-012]). Structural tracing is sound as a may-depend answer but never sharp, so
the remedy hint is offered only for continuous members ([D-140][d-140], [D-343][d-343]). A
continuous face or port declared with no [walking](#g-walked) leaf (one whose type follows
the activation scalar) admits no tracer scalar either, so the hops through it
trace structurally too ([D-245][d-245], [D-343][d-343]).

**The diagnostic records the source of each member's map** ([D-245][d-245]). The source is
the global tracer, sampled states or structure. A reader can thus weigh a dead
hop found on a few sampled paths against one found exactly. The hint itself is
to split this component, *or* to narrow the neighbor's [contract](#g-contract) (its declared
interface) when the dead hop's input is consumed only in a fallback branch.
Those are the ladder's two remedies ([§5.4][s5-4], [D-140][d-140], [D-343][d-343]).

The build diagnostic offers both exits explicitly ([D-140][d-140],
[D-343][d-343]). For a loop between `systems/aero` and `systems/dyn` it reads
"artificial at port level: `systems/aero`'s `F` does not route `a`; split
`systems/aero`, or narrow the neighbor's contract if `a` is consumed only in a
fallback branch". The dead hop is the member with the input face that it does
not route to the output port.
The diagnostic carries the dead hop ([D-245][d-245]) as a separate field of
its [payload](#g-payload) (the structured data a diagnostic carries) rather
than dotting the hop onto the path ([§8.6][s8-6], [§13.2][s13-2]).

If a member's evaluation itself throws, the diagnostic ships with its members
and wires alone, unclassified. Classification is a bonus on the cycle error,
never its precondition ([D-012][d-012]).

---

