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
that door's declaration, and the next door may declare otherwise ([D-261][d-261], [D-400][d-400]).

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
the lifecycle state below says whether that run ever started ([D-399][d-399]). The
placeholder carries no configuration and no compiled state ([D-261][d-261]). `init!`
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
[replay](#g-replay), not resurrection ([§12.7][s12-7], [D-387][d-387]). Replay is the ordinary
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

Deviceless, `run!` is fully synchronous. [§11.1][s11-1] says where the loop and the
device tasks run, and defines the [unattended run](#g-unattended-run) (a run with empty staging and
no snapshot readers).

`step!(sim; frames = 1)` advances whole frames synchronously through the
ordinary frame sequence (drain, integrate, boundaries, publication) and
returns ([D-088][d-088], [D-388][d-388]). A stepped simulation is bit-identical to the same
frames under `run!` ([§2.4][s2-4]), and it never waits on the pacer, whatever
pace the control plane holds ([D-269][d-269]). `step!(sim; t_plus = 10.0)` is
the duration spelling ([D-390][d-390]). It is mutually exclusive with `frames`, and passing
both is `ArgumentInvalid`. It advances whole frames until the boundary time
first covers the duration, which is the migration suite's advance-by-duration
idiom.

Partial advance is the test-harness mode of advance, assert, advance. It is
equally the REPL mode of fly a while, inspect, continue. Neither is a script,
so the scenario-component doctrine does not absorb them ([§12.5][s12-5]).

**A stepping session is deviceless by construction** ([D-093][d-093], [D-389][d-389]). Device
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
([D-096][d-096], [D-390][d-390]). Both entry points work under `run!` too. The harness cell is
not step-scoped. An inspection accessor leaves the rejection of closure-based
termination untouched ([§13.5][s13-5], [D-096][d-096], [D-390][d-390]).

#### Status, termination and `run!` after `step!`

Between `step!` calls a simulation reports `initialized` ([D-088][d-088], [D-388][d-388]). No
loop task exists, so `running` would lie. Nothing is terminal, so `stopped`
would lie too. The state reads "boundary-consistent and ready to advance", not
"sitting at boundary zero". `run!` may therefore follow `step!`, continuing
from the current boundary, and so may another `step!`.

The stop policy is honoured throughout, as bit-identity requires. `t_end`
reached, or a [stop request](#g-stop-request) (an output port of the framework enum `StopFlag`)
[holding](#g-edge-semantics) (publishing `STOP_REQUESTED`) at frame 3 of `step!(sim; frames = 10)`,
ends the run there through the ordinary [§12.4][s12-4] tail and leaves the simulation
`stopped` ([D-388][d-388]). `step!` therefore returns the number of frames *actually
advanced*. That is the requested count in the ordinary case, and fewer when the
run terminated inside the call. That return is how a harness detects the
truncation without inspecting the clock.

#### Re-running and checkpoints

**`stopped → init! → run!` remains the authored re-run** ([D-088][d-088], [D-388][d-388]).
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
against the model, and a mismatch is `CheckpointMismatch`. It also checks that
the state's `t` is a grid time `t₀ + k·h` of the state's own origin and step,
and a state off its grid is `CheckpointMidFrame`. Every mismatch of either kind
is collected into one throw before any write. The entry point then copies the
state back, settles the restored boundary through the hooks and writes
`:consistent` last ([D-318][d-318], [D-319][d-319]).

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

**Device attachments persist across re-initialization** ([D-088][d-088], [D-388][d-388]), because
attachment is orthogonal to the run lifecycle ([§11.3][s11-3]). Persistence means
*roster* persistence, the [roster](#g-roster) being the list of attached device entries.
Binding, [claims](#g-claim) (the set of faces a device may write) and device id survive.
Tasks and OS resources do not, the per-run topology being specified in [§11.1][s11-1] and
the teardown in [§12.4][s12-4]. Each `run!` re-initializes every rostered device and
spawns a task for each whose `init!` succeeds ([§11.1][s11-1], [D-093][d-093]). `attach!` while
stopped only registers, and the task appears at the next `run!`.

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


### 12.7 Replay: the trace re-drives the ordinary loop

This section specifies [replay](#g-replay), re-running the ordinary loop on a recorded input
[trace](#g-trace), so that a recorded session can be inspected, its errors reproduced and
its run continued live. A trace is the primary record of a session, a fixed
[trace header](#g-trace-header) plus the [batches](#g-batch) drained at each [frame](#g-frame). A batch is a [device](#g-device)'s
staged set of writes, and a device is any attached participant in the periphery.
A frame is one iteration of the loop, from drain to publication. The [drain](#g-drain) is
the frame-top swap that applies staged device writes to the [root inputs](#g-root-input). The
root inputs are the root component's own inputs, the only thing the periphery
may write. `replay!` is the entry point the trace exists for ([§11.5][s11-5]):

```julia
trc  = trace(sim)                     # the recorded session: header + per-frame batches
sim2 = Simulation(world)              # the same build
replay!(sim2, trc)                    # restore the header, then re-drive every recorded frame
replay!(sim2, trc; to_boundary = k)   # partial: the §13.4 replay-pointer idiom
replay!(sim2, trc; to_time = 100.0)   # partial: the same halt addressed by time
cp   = checkpoint(sim)                # the state at a frame-top rest
restore!(sim2, cp)                    # that state alone: a warm restart, no feed
```

The parts below cover the one substitution replay makes, halting and the
[input mode](#g-input-mode) (where the drain takes its batches from) across
halts, what stays the loop's, and the validation up front. They then cover the
[what-if replay](#g-what-if-replay), re-driving the recorded inputs through a
modified model, with the `restore = false` form, which attaches the feed to
the simulation as it stands. The rejected shapes close the section.

#### One substitution

**`replay!` is the ordinary loop with exactly one substitution**, not a second
loop ([D-101][d-101], [D-274][d-274]). That is what keeps every property proved of the loop true
of replay. The substitution is the drain, which reads the trace. Under the
default form, `replay!(sim2, trc)` above, the loop also starts from a restored
state.

The default form restores from the header. It restores the trace's [checkpoint](#g-checkpoint)
(the `Model`'s state at a frame top, beside the run's frame index and boundary
ordinal), the state the recording opened from. It runs no [boundary zero](#g-boundary-zero) (the
initialization boundary at `t₀`). This form stands in the `init!` position of
the lifecycle ([§12.6][s12-6]) and does what `restore!` does, with the trace header as
the checkpoint ([D-274][d-274]). There is no [condition](#g-condition) resolution, and the
[root-input totality](#g-root-input-totality) (every root input must hold a value) ([§14.6][s14-6]) held when the
recording's `init!` ran. A condition is the datum that says "set this build to
this state". Whatever fired at `t₀` is part of the restored state, so nothing is
applied twice and nothing is skipped ([D-274][d-274], [D-402][d-402]).

The drain reads the trace. Each frame top applies the recording's batches for
that [frame ordinal](#g-frame-ordinal), the frame index a batch replays at ([D-101][d-101]). It does not swap
the [staging cells](#g-staging-cell) of the [roster](#g-roster) (the list of attached device entries). A staging
cell is where a device's pending write batch waits between drains. Ordinal
keying is exact because the frame sequence is itself deterministic under replay
(`t*` boundaries derive from state, [§10.4][s10-4]). Frame *k* of the replay *is* frame
*k* of the recording. Recorded batches apply verbatim, with no surface re-check
([D-101][d-101]). The [write-surface](#g-write-surface) rule (the bound on the [faces](#g-face) a writer's batch entries
may reach) ([§11.3][s11-3]) ran at recording time, and [claims](#g-claim) (the set of faces a device
may write) are a live-roster fact of the recorded session that replay does not
reconstruct. A face is the name a port wears on its component's boundary.

A simulation is in one of two input modes, `:live` or `:replay`, and **the mode
decides which source that one drain branch reads** ([D-218][d-218]). Under `:live` it
reads the staging cells, and under `:replay` the attached recording. **`replay!`
attaches the recording and enters `:replay`** ([D-218][d-218]). `step!` and `run!`
consume it from there, frame by frame, exactly as the drain paragraph above
describes. There is still one loop and one drain ([D-218][d-218]).

A mode that outlives the call makes a partial replay a resumable position rather
than the end of an operation ([D-218][d-218], [D-397][d-397]). Whatever advances the simulation
next reads the same mode and finds the same records. That is what lets the
reproduction workflow of [§13.4][s13-4] run through the ordinary entry points, with no
replay-only spelling of `step!`.

#### Halting, and the mode across halts

**In `:replay` the recording is the bound** ([D-218][d-218]). Every advance's frame
budget is capped at the recording's last frame, and `to_boundary = k` caps it
earlier. That keyword is the consumer of the replay pointer ([§13.4][s13-4]). `to_time`
is the same cap addressed by time (below). Either keyword names a frame from the
one the feed starts from through the recording's last, and anything else is
refused (`ArgumentInvalid`). The feed starts from the header's frame under the
default form, and from the simulation's own under `restore = false` (below).

`to_boundary = k` takes the frame-entry boundary index ([§13.4][s13-4]), a count of frame
tops. It is not the published-boundary ordinal that a [snapshot](#g-snapshot) (the immutable
per-boundary publication) carries ([§12.3][s12-3]). **Replay runs through frame `k` and
halts exactly at the frame top after it** ([D-128][d-128]). Replay therefore always halts
at a frame top. A [localized](#g-localized) `t*` boundary (the crossing instant bracketed by
root-finding over trial sweeps) inside the frame is reproduced but not
stoppable-at ([D-128][d-128]). The trace stays frame-indexed, replay pointers and error
messages use the frame-entry boundary index, and snapshots carry the
published-boundary ordinal ([§10.4][s10-4], [§12.3][s12-3]).

Replay may also end earlier still under the ordinary policies, since `t_end` and
`ignore_stop_requests` are keywords of `replay!` exactly as of `run!` ([§12.6][s12-6],
[D-255][d-255], [D-316][d-316]). A termination the recorded session hit through a [stop request](#g-stop-request) (an
output port of the framework enum `StopFlag`) reproduces itself anyway,
deterministically ([D-127][d-127], [D-393][d-393]). A replay honours requests by default too, and
the trace header records no policy. So a replay of a live run that ignored some
must pass the same `ignore_stop_requests`.

**`to_time` halts at the last frame top at or before the time given**, the same
halt addressed by time, and it is mutually exclusive with `to_boundary` ([D-219][d-219]).
It computes `k = ⌊(to_time − t₀)/h⌋` against the header's `t₀`, under either
form. A time falling between two frame tops floors onto the earlier one.

The rounding is the deliberate opposite of `t_end`'s, which ends a run at the
first grid boundary reaching or exceeding it ([§12.4][s12-4]). `t_end` bounds
a run, and `to_time` positions an inspection. The point of halting is to
stand *before* the anomaly, so a halt that stepped past it would defeat the
call ([D-219][d-219]).

`to_time` is validated as the other keywords are. The value must be real, finite
and at least `t₀`, and it must name a time the recording covers. The checks run
before the replay writes anything, the default form's restore included.

The halt flips the mode only at the recording's end. A frame budget that runs
out halts the loop at a frame top, leaving the simulation `initialized`
([§12.6][s12-6]). **The mode becomes `:live` exactly when that halt lands at
the recording's last frame**, with the records exhausted ([D-218][d-218]). It
stays `:replay` otherwise, and the next `step!` or `run!` goes on consuming
the recording. So no advance ever flips mid-run. A `run!` whose `t_end` lies
past the recording halts at the last recorded frame, now `:live`, and the
*next* call is the live continuation ([D-218][d-218]).

`live!` is the one call that moves the mode alone. The flip above is automatic.
`live!(sim)` performs it by hand. **`live!` sets the mode to `:live` and
detaches the recording's remainder, touching nothing else** ([D-219][d-219]). The
trajectory stands where the replay left it, and so does the trace with its
header, inherited under the default form. The next `run!` or `step!` is
therefore the live continuation from the replayed boundary, and its drains
append to the re-recorded prefix ([D-398][d-398]). `live!` is a stopped-sim operation,
legal only on an `initialized` simulation in `:replay`. Every other state refuses
under the ordinary lifecycle gates ([§12.6][s12-6]), with `MissingInit` at `built` and
`ServiceLifecycle` in the rest. A simulation already `:live` refuses too, with
`ArgumentInvalid`. The call would have nothing to do, and a loud refusal beats a
silent no-op ([D-219][d-219]).

That call is what makes the rewrite workflow real. An interactive session is
interrupted at t = 110, and the last ten seconds are to be flown again:

```julia
trc  = trace(sim)                     # the interrupted session, out to t = 110
sim2 = Simulation(world)
replay!(sim2, trc; to_time = 100.0)   # halt at the last frame top at or before 100
latest(sim2)                          # inspect the boundary landed on
live!(sim2)                           # drop the remainder; the mode is :live
run!(sim2; t_end = 130.0)             # live from t = 100, re-recording onward
```

The trace `sim2` leaves behind is a complete recording of *itself*, the replayed
prefix out to t = 100 and then the frames flown live after it, since replay
re-records (below).

A replay's halt leaves the simulation `initialized`, never `stopped` ([D-218][d-218]).
That state is boundary-consistent and ready to advance, the same state `step!`
leaves ([§12.6][s12-6]). This is what makes three promised workflows real ([D-101][d-101]).
State-trajectory inspection asks "what was the private state at t = 37.2?", and
answers it by replaying there and reading the live stores ([§11.2][s11-2]). Error
reproduction replays to the frame-entry boundary `k` the error names, then
`step!`s the failing frame on its recorded inputs, under instrumentation
([§13.4][s13-4]). Continuation is `run!` after `replay!`, a live session from the
replayed boundary. After a full replay that is the next call, the records
exhausted at the halt. After a partial one the remainder of the recording is
consumed first, across as many `step!` and `run!` calls as the caller makes, and
the session goes live at the recording's end. Or `live!` drops that remainder,
and the continuation starts at the halt.

#### What stays the loop's

**Replay re-records** ([D-101][d-101], [D-391][d-391]). The drain records normally. Under the
default form the new trace inherits the old header and accumulates the
re-drained batches, a bit-identical prefix. Under `restore = false` the new
trace's header is the simulation's own checkpoint (below). A
replayed-then-continued session therefore leaves behind a complete, valid
trace of *itself*, with no special stitching.

**[Pacing](#g-pacing) and the [control plane](#g-control-plane) are unchanged** ([§10.7][s10-7], [§12.1][s12-1], [D-101][d-101], [D-391][d-391]). The
control plane is the separate atomic surface carrying pause, pace and stop.
Pacing (waits inserted between completed frames, never altering the boundary
sequence) sits outside the semantics, so paused, slow-motion or real-time replay
is free. Paced replay with an attached visualizer *is* session playback, and
`replay!` takes `pace` and `margin` as `run!` does ([§12.1][s12-1], [D-269][d-269]). Stop
truncates, as anywhere.

Devices are readers ([D-218][d-218]). Rostered devices init and spawn normally
([§11.1][s11-1]) and consume snapshots ([§11.2][s11-2], [§12.3][s12-3]). That
is the visualizer case. But no live staging cell is drained while the
simulation is in `:replay`. A batch found staged is discarded with a
rate-limited warning (`ReplayDiscardedStaging`, [Appendix C][sC]). Mixing live
writes into a replay would destroy the property replay exists to provide. A
session that wants live input is a continuation (`run!` after replay), not a
replay.

#### Validation up front

**Validation is loud and up front** ([D-101][d-101], [D-391][d-391]). Before the first frame, the
checkpoint's [deployment](#g-deployment) (the scalar-free artifact the grid parameters fix) is
compared against the target's. Its fingerprint, the structural layout, is
compared against the `Build`. The fingerprint covers the store layout, the
root-input faces, and what a copy by position relies on ([§11.5][s11-5]). The trace's
batch entries are validated against the root input-face list, and each batch's
frame ordinal against the recording's frames, from the one after the header's to
the last ([D-217][d-217]). Each writer's face-name → position schema, on the trace's
`schemas` list ([§11.5][s11-5]), is validated in the same pass. A recorded schema that
disagrees with the target model's own root-input faces is a replay error. The
checks are attach-style, and a failure reports [did-you-mean](#g-did-you-mean), the offending name
plus the list-in-hand it should have matched. The kinds are
`CheckpointMismatch`, `ReplaySchemaMismatch` and `ReplayUnknownFace`
([Appendix C][sC]). The pass runs under both forms of `replay!`.

The same pass pays the trace-record conversion in reverse. Every writer's
sparse records ([§11.5][s11-5]) are normalized to positional batches against
the trace's `schemas` list, once, off the loop ([D-101][d-101], [D-391][d-391],
[D-176][d-176]). Replay has the whole trace in hand before frame 1. The replay
drain therefore applies compiled scatters exactly as the live drain does, and
no face name is resolved per frame under replay either.

*Structural* mismatch is an error. *Parametric* difference is not
([D-101][d-101], [D-391][d-391]).

**The checkpoint check compares two deployments as values** ([D-254][d-254]).
The checkpoint carries the recorded run's `Deployment`, the target
simulation's `Model` carries its own, and the check is their comparison, on
the *structural* side of that line. The value covers the
trajectory-determining parameters, `Δt_base`, `h`, `N_base`, the algorithm,
`localization_tol`, `localization_budget` ([§10.4][s10-4]) and
`firing_budget` ([§10.6][s10-6], [D-133][d-133]). It also covers the
[schedule](#g-schedule) (the typed per-component `(D, Φ, Δt)` tick table) with
every column, the anchor and rate-chain columns included. A rate re-declared
through a different anchor at the same tick table is therefore a different
deployment, and the replay is refused. The refusal costs one re-recording in
a rare case, and it keeps the equality a plain value equality rather than one
that ignores two of a row's columns. Mismatch is `CheckpointMismatch` with a
deployment-parameter discriminator, never a what-if ([D-127][d-127]). A
deployment change moves the times at which the frame-ordinal batches apply.
That is different inputs, not a modified model. The event trio (the
localization pair and `firing_budget`) is compared for exactly the same reason
the grid parameters are. It moves the trajectory, so a run that differs in it
is not re-driving the recorded one. Comparison by value is what makes the
check one expression rather than a field-by-field walk.

Under the default form the clock is *restored*, not compared. That form restores
`t₀` with the rest of the clock, so `replay!` takes no `t0` argument ([D-127][d-127]).
Under `restore = false` the simulation's own clock runs, and its origin must
equal the recording's. The checkpoint holds no policy ([D-255][d-255]). `t_end` and
`ignore_stop_requests` are keywords of this `replay!` call, validated per call
as at `run!`.

The dispositions, by trace content:

| trace content | disposition |
|---|---|
| the checkpoint's fingerprint: store layout, root-input faces, and what a copy by position relies on | compared against the `Build` |
| the recorded `Deployment`, carrying `Δt_base`, `h`, `N_base`, the algorithm, `localization_tol`, `localization_budget`, `firing_budget` | compared as a value against the deployment the target simulation's `Model` carries |
| each writer's face-name → position schema (on the trace's `schemas` list) | validated against the target model's root-input faces: disagreement is a replay error |
| the checkpoint's state | restored under the default form; no boundary zero |
| the clock | restored under the default form, `replay!` takes no `t0`; under `restore = false` the simulation's own clock runs, its origin equal to the recording's |
| `t_end`, `ignore_stop_requests` | absent from the checkpoint; each `replay!` call declares its own ([§13.5][s13-5]) |

#### What-if replay and `restore = false`

Replaying against the same structure with changed parameters is the what-if
replay. It is spelled as `init!` of the modified model under the authored
condition, then `replay!(sim, trc; restore = false)`. The trace is not
self-sufficient for it. Its checkpoint holds the recording model's state after
boundary zero, so the authored condition comes from outside ([D-274][d-274]).
Bit-identity is promised only against the identical build ([§2.4][s2-4]). What-if replay
promises determinism, never reproduction.

`replay!(sim, trc; restore = false)` attaches the feed to the simulation as it
stands and restores nothing. The simulation must be `initialized`, at the
recording's `t₀`, and at a frame from the header's to one short of the
recording's last. A simulation that is not `initialized` meets the lifecycle
gate before any write, with `MissingInit` when it is `built` and
`ServiceLifecycle` in any other state. One whose origin or frame is off the
recording's is refused before any write as `CheckpointMismatch`, its clock arm.
One grid is thus an invariant of every replay, and `to_time` has one meaning.
The drain applies the records from the frame after the simulation's own.

This form is a door like the default one, an entry point that builds a run
([§12.6][s12-6]). It builds a fresh run under the recording keywords, takes
the simulation's own checkpoint as the new trace's header, and publishes one
snapshot. That form serves the what-if of a modified model initialized under
the authored condition (above). It also serves a seek, `restore!` of a
checkpoint the recording passed through followed by the feed from the next
frame ([D-274][d-274], [D-402][d-402]).

#### Rejected shapes

Three shapes are rejected for the record ([D-101][d-101]). They are a
`run!(sim; replay = trc)` flag, a synthetic playback device staging the
recorded batches, and replay ending `stopped`. The input mode clarifies that
decision's drain substitution rather than replacing it, and carries its own
rejected shapes ([D-218][d-218]).

---

# Part IV — Failure and services

Part IV covers what happens when things go wrong, and what a stopped simulation
can be asked to do. [§13][s13] is the error discipline. It fixes which failures
are collected and which fail fast, and the diagnostic value both produce. It
fixes the single runtime catch site and the execution cursor that locates a
failure inside a frame. And it explains why graceful termination is model state
rather than an exception, and how a rejected cycle is diagnosed. [§14][s14]
is the stopped-sim services.
[§14.1][s14-1]–[§14.6][s14-6] build the condition (a path-addressed overlay on
the declared defaults) and apply it through boundary zero. Applying a condition
is the initialization service. [§14.7][s14-7]–[§14.10][s14-10] build trim and
linearization on that same foundation.

Part IV assumes both earlier parts. [§9.1][s9-1] and [§9.2][s9-2] already fixed when each check
runs, so [§13][s13] fixes only how a failure is reported once it happens.
[§8.6][s8-6] supplies the paths a condition addresses. [§9.4][s9-4] supplies the
activations trim and linearization run on. [§10.6][s10-6] supplies the
macro-sequence that boundary zero re-runs with an empty integrate.

## 13. Error discipline
