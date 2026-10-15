### 12.5 Scripts and the mid-run mutation doctrine

This section settles what the [periphery](#g-periphery) (everything outside the loop that
exchanges data with it) may do to a running model. The periphery's attached
participants are its [devices](#g-device). The section surveys FlightCore's mid-run
mutations, states the clock criterion that maps scripts to [components](#g-component) (units of
modeling), eliminates FlightCore's per-step hook `user_callback!`, covers manual
events and mid-run re-initialization, and ends with the doctrine's final form.

What the consumers demonstrably mutate mid-run is surveyed here. The line
references are to `c172_demos.jl`, FlightCore's demo file. FlightCore's
`user_callback!` has exactly two archetypes. The first is the timetable
script, `elevator_offset` as a function of `t` (c172_demos.jl:290). The second
is the synthetic pilot, a phase FSM (finite-state machine) reading `y` and
writing mode requests, references, flaps and wind (c172_demos.jl:423, 525).
Both write only `u` fields. No demo, test or GUI path pokes `x`/`s` mid-run,
and `init!`/trim appear only between construction and `run!`
(c172_demos.jl:303).

**A sim-time script becomes a [scenario component](#g-scenario-component), and a wall-clock interaction
becomes a device** ([D-031][d-031]). A scenario component is an ordinary periodic
discrete component holding a sim-time script. Sim-time scripts are model
behavior, which is why they become scenario components. Both archetypes are
clocked by *sim time*, `t`, the trajectory. Mapping them to devices is rejected
([D-031][d-031]). The clock is the criterion.

A script mapped to a component is periodic discrete, with `K = 1` for the
`dt = 0.02` callbacks FlightCore had, `K` being the multiplier in
`Relative(K)` ([§10.5][s10-5]). It executes synchronously in the loop,
deterministic paced or unpaced. It is replayed by recomputation, with no
[trace](#g-trace) (the records of each frame's drained inputs). A device, by
contrast, is traced and replayed from the trace.

The component mapping is strictly richer than the callback it replaces.

- The callback's `Ref(:init)` phase closure becomes honest `s`, which a
  [port](#g-port) (one declared name with its cell) can publish to
  [snapshots](#g-snapshot), logs and plots. A snapshot is the immutable
  per-boundary publication.
- Inputs arrive fresh from the same [boundary](#g-boundary) (a published consistency point), by
  topological order. The callback ran post-step, one boundary staler.
- The pure timetable script is a one-liner reading the clock out of its
  [bundle](#g-bundle) (the NamedTuple of zero-copy views a component function
  receives). That one-liner is `y_direct(c, (; t)) = (; offset = profile(t))`,
  exact at its own [ticks](#g-tick), with no latch state of its own. A tick
  is an instant at which a discrete component's stages and update run.
- In a scenario configuration the script drives the input ports of the avionics
  (the onboard flight systems). [§11.7][s11-7] therefore renders the corresponding GUI
  widgets read-only, each showing its source. Its port-resolution rule resolves
  FlightCore's demo-vs-GUI dead-slider fight.

**`user_callback!` is eliminated** ([D-031][d-031]). It is the periphery's
`f_step!`, FlightCore's unconditional per-step hook ([§2.5][s2-5]), and cheap
composition leaves it without justification. Its call sites migrate to
scenario components, not devices.

**Manual event triggering needs no mechanism** ([D-031][d-031]). It takes a
[root input](#g-root-input) (the root component's own input face) plus a
[boundary-detected](#g-boundary-detected) [guard](#g-guard) (an edge check at
step boundaries only, with no root-finding) reading that root input. That is
already expressible in settled machinery. The levels doctrine applies
([§11.4][s11-4]), with latched commands or counters. The engine start/stop
buttons of FlightCore's demos were `u`-writes.

**Mid-run re-initialization is not built** ([D-031][d-031]), because it is not
demonstrated. Initialization and trim are stopped-sim workflows, first-class
services of [§14][s14]. No concurrency perimeter exists there. There is no loop and no
devices, just plain single-task code. The shape of the [guarded addition](#g-guarded-addition) (a
capability the design admits but does not build) is on record should demand
appear. It would be a traced, boundary-executed intervention command applied
through project → [sweep](#g-sweep) → publish, so that no consumer ever observes un-decoded
state. A sweep is one pass through the execution order against the current
state.

In the doctrine's final form, while a simulation runs, **the periphery stages
root-input writes and issues control commands** ([§2.2][s2-2],
[D-031][d-031]). Structurally, it does nothing else. Anything that wants to
poke the model mid-run is one of three things.

- It is an *input* in disguise, so wire a root input and a guard.
- It is *model behavior* in disguise, so add a scenario component.
- It is a *wall-clock interaction*, so attach a device.

Graceful termination follows the same shape ([§13.5][s13-5]). It is a
[stop request](#g-stop-request) (an output port of the framework enum
`StopFlag`) declared in the model, honoured unless the advance ignores it
([D-316][d-316]). It is never a callback, and never a thrown exception
([D-060][d-060]).

### 12.6 Run lifecycle and partial advance

This section specifies what a `Simulation` and its run own, the lifecycle a
simulation moves through, how it advances and restarts, what it keeps of its
[devices](#g-device) (any attached participants in the periphery) across runs, and the stop
policy each advance declares. A simulation is in one of five lifecycle states,
built, initialized, running, stopped or errored. A *door* is an entry point that
builds a run, and there are three, `init!`, `restore!` and `replay!`. A run's
`feed` is the recording `replay!` attached, or `nothing`. The [input mode](#g-input-mode) says
where the next [frame](#g-frame) (one grid step, the unit of scheduling) takes its inputs
from.

#### The run and the simulation

**[`Run`](#g-run) is what one run owns** ([D-255][d-255], [D-260][d-260], [D-317][d-317]). It is a mutable struct of
six fields. Two are `const` and last the run's whole life. One is the [log](#g-log) (the
retained sequence of published snapshots). The other is the [trace](#g-trace) (the records
of each frame's drained inputs), which is `nothing` under `trace = false`. The
door that builds the run takes the four recording keywords, `trace`, `log`,
`log_every` and `log_max` ([Appendix B][sB], [D-261][d-261]). A run's recording is therefore
that door's declaration, and the next door may declare otherwise ([D-261][d-261]).

Four fields evolve during the run. `feed` is described above. `termination` is
the record the loop's tail writes. `frame` and `boundary` are the trajectory's
counters, the frame index and the boundary ordinal. `init!`, `restore!` and
`replay!` construct a run, and nothing else rebinds it. `live!` ([§12.7][s12-7]) and the
halt at a recording's end write `feed`. The loop's tail writes `termination`
once, and `closed(run)` is `termination !== nothing`. Each door sets the two
counters as it builds the run, `init!` to zero and `restore!` and `replay!` to
those of the [checkpoint](#g-checkpoint) (the `Model`'s state at a frame top, beside the run's
frame index and boundary ordinal), and the loop advances them ([D-317][d-317]).
`restore!` of a bare state sets the frame index to the state's frame and the
boundary ordinal to zero, as `init!` does ([D-319][d-319]).

The origin `t₀` is not a run field ([D-260][d-260]). The clock of the [executor](#g-executor) (the
compiled form of the stage execution order) holds it beside `t`. `init!` sets it
on the clock before [boundary zero](#g-boundary-zero), the initialization boundary run as the
ordinary macro-sequence with an empty integrate ([§14.5][s14-5]). A checkpoint carries it
with the clock ([§11.5][s11-5], [D-273][d-273]). It is a `Float64`, as `h` and `t_end` are
([D-260][d-260]).

**A `Simulation` is constructed with a placeholder run** ([D-255][d-255]). The
placeholder is an empty log, no trace, no feed and no termination, and
`init!`, `restore!` and `replay!` replace it ([D-255][d-255]). The field is
always a `Run` and never `nothing`, so every accessor has a run to read, and
the lifecycle state below says whether that run ever started. The placeholder
carries no configuration and no compiled state ([D-261][d-261]). `init!`
allocates fresh objects rather than clearing them ([D-255][d-255]).

**`Simulation` is a mutable struct of four fields**, the [`Model`](#g-model) (the deployment
and its executor at one scalar), the run, the data plane ([§11][s11]) and the control
plane ([D-317][d-317]). The [control plane](#g-control-plane) is the atomic surface carrying pause, pace and
stop. The `Model` holds the [deployment](#g-deployment), the executor, its status and its
[diagnostic cell](#g-diagnostic-cell). The deployment is the scalar-free artifact the grid parameters
fix, carrying the build. A diagnostic cell is a writer's own holding place for
runtime diagnostics. A simulation owns its `Model`, claimed at construction and
never shared ([§9.2][s9-2], [D-318][d-318]).

Every other value belongs to one of the four ([D-256][d-256]). The build is reached
through the deployment, never held twice. The grid parameters, the [schedule](#g-schedule) (the
typed per-component `(D, Φ, Δt)` tick table) and the event parameters are the
deployment's ([§9.2][s9-2]). `chunk_size`, the stepper and the arrival buffers are the
executor's. `join_timeout` is `Control`'s ([§12.1][s12-1]). The loop's diagnostic cell,
its account and the published-snapshot holder ([§11.2][s11-2]) are the data plane's, and
the frame's own diagnostic cell is the `Model`'s ([§11.8][s11-8]). The log, the trace and
the two counters are the run's. The stop policy, with its `t_end` and ignored
requesters, is the advance's argument, and the [termination record](#g-termination-record) (the
stopped-sim value naming how the run ended) keeps the terminating one ([D-260][d-260]).
The pacer's schedule and counters are `run!`'s own, created per call and passed
to the loop and its publications as the policy is. The status of each [snapshot](#g-snapshot)
(the immutable per-boundary publication) carries the pacer's frozen record
([§10.7][s10-7], [D-269][d-269]).

**A struct holds what it owns or what it must retain across calls**
([D-261][d-261]). A callee takes what it reads as an argument, never off a
field added to the container it already holds. **An object is built after its
inputs exist**, and the placeholder run above is the one exception
([D-261][d-261]).

#### Lifecycle states and the input mode

**A `Simulation` moves through five states**, *built*, *initialized*, *running*,
and terminally *stopped* or *errored* ([§13.4][s13-4], [D-088][d-088]). *Built* means [stores](#g-store) (the
framework-owned homes of a component's state) allocated and boundary zero not
completed ([D-223][d-223]). It is the cold state, and the state a throw inside boundary
zero returns the simulation to ([§13.4][s13-4]). *Initialized* means `init!` has
completed boundary zero ([§14.5][s14-5]), or `restore!` or `replay!` has restored a
checkpoint.

**`lifecycle(sim)` derives the state rather than storing it** ([D-317][d-317]).
It reads three facts, the control plane's running flag, the `Model`'s status
and whether the run is closed. The status is `:built`, `:consistent` or
`:inconsistent`, and only the `Model`'s own entry points and catch sites write
it. A claimed model's status is written only through its simulation's entry
points, since the model's entry points refuse a direct call on a claimed model
([D-318][d-318]).

| running flag | `Model` status | run closed | state |
|---|---|---|---|
| set | any | any | running |
| clear | `:built` | any | built |
| clear | `:inconsistent` | any | errored |
| clear | `:consistent` | no | initialized |
| clear | `:consistent` | yes | stopped |

**`errored` is terminal** ([D-059][d-059]). Reproduction is trace
[replay](#g-replay), not resurrection ([§12.7][s12-7]). Replay is the ordinary
loop re-driven from the trace.

Beside the state, the run carries an input mode, `:live` or `:replay`, read as
`mode(sim)`. **The mode is read off the run's `feed`**, `:replay` while a
recording is attached and `:live` otherwise ([D-260][d-260]). The mode names where the
next frame's [drain](#g-drain) takes its [batches](#g-batch) from, the [staging cells](#g-staging-cell) (where each
device's pending batch waits between drains) or the attached recording ([§12.7][s12-7],
[D-218][d-218]). The drain is the frame-top swap that publishes staged device writes into
the root inputs, and a batch is a device's staged set of writes. State and mode
are orthogonal. The state says whether the simulation may advance, and the mode
says what it will advance on.

**`init!` is mandatory** ([D-088][d-088]). `run!` or `step!` on a simulation
whose boundary zero has not completed is `MissingInit`, an error in the kind
set ([§13.2][s13-2]) naming `init!`. That is distinct from
`UninitializedInputs`, which fires *inside* `init!` ([§14.6][s14-6]).
`restore!` and `replay!` are the two alternative doors. Each restores a
checkpoint and runs no boundary zero ([§12.7][s12-7], [D-274][d-274]). A throw
inside boundary zero, which only `init!` runs, leaves the simulation `built`
([§13.4][s13-4], [D-223][d-223]), so the next `run!` or `step!` meets the same
refusal.

#### Partial advance

Deviceless, `run!` is fully synchronous, and [§11.1][s11-1] says where the loop and the
device tasks run and defines the [unattended run](#g-unattended-run) (a run with empty staging and no
snapshot readers).

`step!(sim; frames = 1)` advances whole frames synchronously through the
ordinary frame sequence (drain, integrate, boundaries, publication) and
returns ([D-088][d-088]). A stepped simulation is bit-identical to the same
frames under `run!` ([§2.4][s2-4]), and it never waits on the pacer, whatever
pace the control plane holds ([D-269][d-269]). `step!(sim; t_plus = 10.0)` is
the duration spelling. It is mutually exclusive with `frames`, and passing
both is `ArgumentInvalid`. It advances whole frames until the boundary time
first covers the duration, which is the migration suite's advance-by-duration
idiom.

Partial advance is the test-harness mode of advance, assert, advance. It is
equally the REPL mode of fly a while, inspect, continue. Neither is a script,
so the scenario-component doctrine does not absorb them ([§12.5][s12-5]).

**A stepping session is deviceless by construction** ([D-093][d-093]). Device
tasks are per-`run!` artifacts ([§11.1][s11-1]), and a device loop's
`while running(handle)` is false outside a run. Between `step!` calls the
simulation is in a stopped-sim state, `initialized` (below), so `attach!` is
legal there and does what it always does. It registers ([§11.3][s11-3]), and
the task appears at the next `run!`.

The frame-top drain still runs, so `step!` frames stay bit-identical to `run!`
frames. In a stepping session the staging cell written is the [harness cell](#g-harness-cell) (the
always-present staging cell of the [harness writer](#g-harness-writer)). The harness write path is
`stage!(sim, "face" => value, …)`, and [§11.3][s11-3] specifies the writer. Staged
batches are ordinary batches. They are traced, so replay and bit-identity hold,
and they are applied at the next frame top.

The read half is `latest(sim)`. It hands back the same immutable snapshot
value a device handle acquires ([§11.2][s11-2]), navigated directly for
assertions. Advance-assert-advance is `stage!` → `step!` → `latest`
([D-096][d-096]). Both entry points work under `run!` too. The harness cell is
not step-scoped. An inspection accessor leaves the rejection of closure-based
termination untouched ([§13.5][s13-5], [D-096][d-096]).

#### Status, termination and `run!` after `step!`

Between `step!` calls a simulation reports `initialized` ([D-088][d-088]). No
loop task exists, so `running` would lie. Nothing is terminal, so `stopped`
would lie too. The state reads "boundary-consistent and ready to advance", not
"sitting at boundary zero". `run!` may therefore follow `step!`, continuing
from the current boundary, and so may another `step!`.

The stop policy is honoured throughout, as bit-identity requires. `t_end`
reached, or a [stop request](#g-stop-request) (an output port of the framework enum `StopFlag`)
[holding](#g-edge-semantics) (publishing `STOP_REQUESTED`) at frame 3 of `step!(sim; frames = 10)`,
ends the run there through the ordinary [§12.4][s12-4] tail and leaves the simulation
`stopped`. `step!` therefore returns the number of frames *actually advanced*.
That is the requested count in the ordinary case, and fewer when the run
terminated inside the call. That return is how a harness detects the truncation
without inspecting the clock.

#### Re-running and checkpoints

**`stopped → init! → run!` remains the authored re-run** ([D-088][d-088]).
`init!` re-runs boundary zero from its [condition](#g-condition) (a
path-addressed overlay that sets the build to a state). The warm restart is
`checkpoint` → `restore!` → `run!` ([§12.7][s12-7], [D-274][d-274]).
`restore!` is a door like `init!`, and it runs no boundary zero. Each builds a
fresh run, so the trace, the log and the termination record ([§13.5][s13-5])
are new objects rather than cleared ones, and each clears any batches still in
staging cells. The [recorders](#g-recorders) (the trace and the log jointly)
restart with the run they record, and no stale batch survives to clobber the
frame it predates.

`init!` and `restore!` also return the input mode to `:live`, and a fresh
`replay!` sets the mode exactly as it sets the trajectory. `live!` is the one
call that moves the mode alone. It takes a replaying simulation live where it
stands ([§12.7][s12-7]). A terminal state makes the mode moot. From `stopped`,
nothing advances until `init!`, `restore!` or `replay!` opens a new run, and
`errored` is terminal ([D-218][d-218], [D-219][d-219]).

`checkpoint` and `restore!` exist on the `Model` and on the `Simulation`, and
**a `Checkpoint` is the `Model`'s state beside the run's cursor**
([D-319][d-319]). `checkpoint(model)` returns the state alone, a
`ModelState`. It holds the flat buffer, the `s` and `m` stores, the whole
signal table, the guard priors, `t`, `t₀`, the fingerprint (the structural
layout) and the deployment. It is legal at `:consistent` with the clock on a
grid top. `checkpoint(sim)` wraps that state with the run's frame index and
boundary ordinal ([D-319][d-319]). It is a stopped-sim service, legal in
`initialized` and `stopped` ([§14][s14]), and refused as `ServiceLifecycle` in
any other state. It is refused wherever the executor is not at the rest a
published frame top leaves (`CheckpointMidFrame`, [Appendix C][sC]). That is
after a `t*` stop, which leaves the clock mid-frame with the remainder
abandoned, and after a frame abandoned unpublished ([§12.4][s12-4]). The test
is that the clock sits on a grid time and that the latest snapshot is of that
very boundary.

`restore!(model, model_state)` checks the state's fingerprint and deployment
against the model. It also checks that the state's `t` is a grid time
`t₀ + k·h` of the state's own origin and step, and a state off its grid is
`CheckpointMidFrame`. Every mismatch of either kind is collected into one
throw before any write. The entry point then copies the state back, settles
the restored boundary through the hooks and writes `:consistent` last
([D-318][d-318], [D-319][d-319]).

`restore!(sim, cp)` takes the four recording keywords `init!` takes. It checks
the state's fingerprint and deployment against the simulation as replay checks
the [trace header](#g-trace-header) (the trace's fixed preamble), and a
mismatch is `CheckpointMismatch` ([§12.7][s12-7]). It checks the state's `t`
against its grid as the model's entry point does, collecting both kinds into
one throw. It then copies the state back, opens a fresh run with the
checkpoint as its trace header, and publishes one snapshot at the
checkpoint's `t`. It runs no [sweep](#g-sweep) (one pass through the execution order against
the current state), evaluates no guard, runs no update and
resets no prior. The next frame is the original lattice's next frame, because
the clock came with the checkpoint. The boundary ordinal continues, being the
trajectory's ([§12.3][s12-3], [D-274][d-274]). The snapshot `restore!`
publishes is a re-publication. It carries the ordinal of the boundary the
checkpoint was taken at, and the next frame publishes under the next ordinal,
as it did in the original run.

`restore!(sim, model_state)` is the door a state prepared on a standalone
model takes into a simulation ([§9.2][s9-2], [D-319][d-319]). It takes the
same keywords and makes the same check of the state's fingerprint and
deployment, and it refuses a state whose `t` is off the grid as
`CheckpointMidFrame`. It opens a fresh trajectory at the state's frame, and
the restored boundary publishes under ordinal 0, as boundary zero's does. A
standalone model published nothing, so the trajectory has no ordinals to
continue. A `Checkpoint` holds a `ModelState{Float64}`, so it is nominal by
type. A state taken at another scalar is refused by dispatch with the same
`CheckpointMismatch`, on either `restore!` that takes a bare state.

#### Device attachments across runs

**Device attachments persist across re-initialization** ([D-088][d-088]),
because attachment is orthogonal to the run lifecycle ([§11.3][s11-3]).
Persistence means *roster* persistence, the [roster](#g-roster) being the list
of attached device entries. Binding, [claims](#g-claim) (the set of faces a
device may write) and device id survive. Tasks and OS resources do not, the
per-run topology being specified in [§11.1][s11-1] and the teardown in
[§12.4][s12-4]. Each `run!` re-initializes every rostered device and spawns
its task ([D-093][d-093]). `attach!` while stopped only registers, and the
task appears at the next `run!`.

Which devices get a task at each `run!` is decided as [§11.1][s11-1]
specifies. **A front end attached by hand is still rostered**
([D-310][d-310]), so the next `run!` spawns its task again.

#### The stop policy per advance

**The stop policy is declared per advance** ([D-255][d-255], [D-316][d-316]). `t_end` and
`ignore_stop_requests` are keywords of `run!`, `replay!` and `step!`. Each call
builds and validates the [`StopPolicy`](#g-stop-policy) (the immutable value of `t_end` plus the
ignored requester paths) it passes to the loop ([§13.5][s13-5], [D-255][d-255], [D-316][d-316]). The value
lives as long as the call, and afterwards only on the termination record of the
advance that ended the run ([D-260][d-260]). A second run, or a `step!` sequence between
two runs, can therefore stop on a different clock or honour a different set of
stop requests without a rebuild.

