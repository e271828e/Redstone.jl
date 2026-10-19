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

