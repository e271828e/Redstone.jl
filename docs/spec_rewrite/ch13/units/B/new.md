### 13.3 Build primitives: `resolve` and the face-list accessors

The `input_passthrough` sketch ([§8.8][s8-8]) calls two of the primitives below
without defining them. **All three are normative in the forms given here**
([D-061][d-061]). This section gives the three forms, the two duties
resolution enforces, which client each duty binds and why, and the standing
of `resolve_terminal`.

- `resolve(assembly, path::String) → AbstractComponent` resolves an immediate
  child, a container element's key segment included.
- `input_faces(c)` / `output_faces(c) → Vector{String}` return the stringified
  keys of a leaf's `u_types` / `y_types` (the key set is
  `T`-independent). For an [assembly](#g-assembly) they return the entries of
  `input_wires(c)` / `output_wires(c)`. Declaration order is
  preserved, which gives deterministic printouts and stable diagnostics.
- `resolve_terminal(assembly, path) → (component, name)` splits off a terminal
  path's final segment and resolves the prefix through `resolve`. The split is
  unambiguous because [face](#g-face) names (the names ports wear on their
  component's boundary) may contain dots but never slashes ([§8.6][s8-6]).

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

**Which rule applies depends on who is resolving** ([D-130][d-130]).
[D-083][d-083] separates the reads a build's correctness rests on from the
reads that only observe it. The same line runs through resolution. Three kinds
of client share one resolution, and each gets the rule its promises require.

| client | who resolves | what resolution enforces |
|---|---|---|
| wiring | connection declarations, in the structure step | the one-level rule: an immediate child and one of its faces |
| service | [condition](#g-condition) entries (the path-addressed sparse overlay that sets a build's state), trim `reads`, [taps](#g-taps), [device](#g-device) read [bindings](#g-binding), log extraction by `series` ([§14.3][s14-3], [§14.7][s14-7], [§14.10][s14-10], [§11.2][s11-2], [D-406][d-406], [D-407][d-407]) | strict: no traversal past a generic child, checked at the authoring or mount level |
| inspection | [snapshot](#g-snapshot) and log inspection ([D-310][d-310]) | the instance walk |

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

Which of the three rules a client resolves under is internal framework fact,
never user-facing API ([D-130][d-130]). The two ways of applying one plan
([§14.4][s14-4]) use the same arrangement and have the same status.

Inside the framework only wiring resolution calls `resolve_terminal`. The
services and the readers split their own paths through the service walk
([§14.3][s14-3], [§14.4][s14-4]).

### 13.4 Runtime failures: one catch site, an execution cursor

A runtime failure of model code is a throw inside a [frame](#g-frame) (one iteration of the
loop) or inside [boundary zero](#g-boundary-zero), the initialization
boundary, which runs the ordinary macro-sequence with an empty integrate. The
framework catches it at one site, records where execution stood, and names
how to reproduce it. This section covers, in order, where a failure is
caught, the runtime carrier, the interrupt, the disposition, reproduction,
boundary zero, the nonfinite check and device-side failures.

#### Where a failure is caught

**The [`Model`](#g-model)'s `frame!` wraps each whole frame, every
[boundary](#g-boundary) it settles included, in a single `try`**, and its
`init!` wraps boundary zero the same way ([D-317][d-317]). The `Model` is the
deployment and its executor at one scalar. A boundary's macro-sequence runs
integrate → project → event iteration → [ticks](#g-tick) → publication.
**`frame!` never wraps per stage or per [component](#g-component)**
([D-059][d-059]). The loop wraps each frame in a `try` of its own, which
decides the failure's disposition (below) and builds no carrier
([D-317][d-317]).

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

```julia
# the cursor: one mutable field of the executor, overwritten per dispatch
mutable struct ExecutionCursor
    …    # what it records, per the prose above: component path
         # (component-list index), which function, and the boundary phase
end
```

#### The runtime carrier

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

#### The disposition

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

#### The nonfinite check

Divergence is not termination. Dynamics that blow up (ground penetration, an
unstable gain) produce NaNs that defeat guards. NaN comparisons are false, so
no declared guard will catch them. An `isfinite` pass over the flat state
[buffer](#g-buffer), run by the model after every return from the integrator
backend, fails fast as `NonfiniteState`, a `StepError` species naming the
component, the state leaf and the frame-entry boundary. It catches diverging
models generally, not just post-terminal ones.

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
