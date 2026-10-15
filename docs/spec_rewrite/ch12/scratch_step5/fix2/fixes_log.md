# Chapter 12, step 5: editorial fixes, half 2

Fixer fix2 applied these edits to `units/F/new.md` and `units/G/new.md`, in
order, on top of `69a3191`. Each entry replaces its old text, verbatim and
found exactly once in the unit's file at that point of the sequence, with its
new text. Each edited paragraph is rewrapped to 80 rendered columns.

## 1. P2-1, unit F (edit and rewrap)

Old:

````text
This section settles what the [periphery](#g-periphery) (everything outside
the loop that exchanges data with it) may do to a running model. The
periphery's attached participants are its [devices](#g-device). The section
surveys FlightCore's mid-run mutations, states the clock criterion that maps
scripts to [components](#g-component) (units of modeling), eliminates
`user_callback!`, covers manual events and mid-run re-initialization, and ends
with the doctrine's final form.
````

New:

````text
This section settles what the [periphery](#g-periphery) (everything outside the loop that
exchanges data with it) may do to a running model. The periphery's attached
participants are its [devices](#g-device). The section surveys FlightCore's mid-run
mutations, states the clock criterion that maps scripts to [components](#g-component) (units of
modeling), eliminates FlightCore's per-step hook `user_callback!`, covers manual
events and mid-run re-initialization, and ends with the doctrine's final form.
````

## 2. P2-40, unit F (rewrap only)

Old:

````text
**A sim-time script becomes a
[scenario component](#g-scenario-component), and a wall-clock interaction
becomes a device** ([D-031][d-031]). A scenario component is an ordinary
periodic discrete component holding a sim-time script. Sim-time scripts are
model behavior, which is why they become scenario components. Both archetypes
are clocked by *sim time*, `t`, the trajectory. Mapping them to devices is
rejected ([D-031][d-031]). The clock is the criterion.
````

New:

````text
**A sim-time script becomes a [scenario component](#g-scenario-component), and a wall-clock interaction
becomes a device** ([D-031][d-031]). A scenario component is an ordinary periodic
discrete component holding a sim-time script. Sim-time scripts are model
behavior, which is why they become scenario components. Both archetypes are
clocked by *sim time*, `t`, the trajectory. Mapping them to devices is rejected
([D-031][d-031]). The clock is the criterion.
````

## 3. P2-2, unit F (rewrap only)

Old:

````text
- Inputs arrive fresh from the same [boundary](#g-boundary) (a published
  consistency point), by topological order. The callback ran post-step, one boundary
  staler.
````

New:

````text
- Inputs arrive fresh from the same [boundary](#g-boundary) (a published consistency point), by
  topological order. The callback ran post-step, one boundary staler.
````

## 4. P2-3, unit F (edit and rewrap)

Old:

````text
- In a scenario configuration the script drives the input ports of the
  avionics (the onboard flight systems). [§11.7][s11-7] therefore renders the
  corresponding GUI widgets read-only with its source shown. The
  port-resolution rule resolves FlightCore's demo-vs-GUI dead-slider fight
  ([§11.7][s11-7]).
````

New:

````text
- In a scenario configuration the script drives the input ports of the avionics
  (the onboard flight systems). [§11.7][s11-7] therefore renders the corresponding GUI
  widgets read-only, each showing its source. Its port-resolution rule resolves
  FlightCore's demo-vs-GUI dead-slider fight.
````

## 5. P2-5, unit F (edit and rewrap)

Old:

````text
**Mid-run re-initialization is not built** ([D-031][d-031]), because it is not
demonstrated. Initialization and trim are stopped-sim workflows (first-class
services, [§14][s14]). No concurrency perimeter exists there. There is no loop
and no devices, just plain single-task code. The shape of the
[guarded addition](#g-guarded-addition) (a capability the design admits but
does not build) is on record should demand appear. It would be a traced,
boundary-executed intervention command applied through
project → [sweep](#g-sweep) → publish, so that no consumer ever observes
un-decoded state.
````

New:

````text
**Mid-run re-initialization is not built** ([D-031][d-031]), because it is not
demonstrated. Initialization and trim are stopped-sim workflows, first-class
services of [§14][s14]. No concurrency perimeter exists there. There is no loop and no
devices, just plain single-task code. The shape of the [guarded addition](#g-guarded-addition) (a
capability the design admits but does not build) is on record should demand
appear. It would be a traced, boundary-executed intervention command applied
through project → [sweep](#g-sweep) → publish, so that no consumer ever observes un-decoded
state.
````

## 6. P2-6, unit F (edit and rewrap)

Old:

````text
**Mid-run re-initialization is not built** ([D-031][d-031]), because it is not
demonstrated. Initialization and trim are stopped-sim workflows, first-class
services of [§14][s14]. No concurrency perimeter exists there. There is no loop and no
devices, just plain single-task code. The shape of the [guarded addition](#g-guarded-addition) (a
capability the design admits but does not build) is on record should demand
appear. It would be a traced, boundary-executed intervention command applied
through project → [sweep](#g-sweep) → publish, so that no consumer ever observes un-decoded
state.
````

New:

````text
**Mid-run re-initialization is not built** ([D-031][d-031]), because it is not
demonstrated. Initialization and trim are stopped-sim workflows, first-class
services of [§14][s14]. No concurrency perimeter exists there. There is no loop and no
devices, just plain single-task code. The shape of the [guarded addition](#g-guarded-addition) (a
capability the design admits but does not build) is on record should demand
appear. It would be a traced, boundary-executed intervention command applied
through project → [sweep](#g-sweep) → publish, so that no consumer ever observes un-decoded
state. A sweep is one pass through the execution order against the current
state.
````

## 7. P2-7, unit F (edit and rewrap)

Old:

````text
This section specifies what a `Simulation` and its run own, the lifecycle a
simulation moves through, how it advances and restarts, and what it keeps of
its [devices](#g-device) (any attached participants in the periphery) across
runs. A simulation is in one of five lifecycle states, built, initialized,
running, stopped or errored. A *door* is an entry point that builds a run, and
there are three, `init!`, `restore!` and `replay!`. A run's `feed` is the
recording `replay!` attached, or `nothing`. The [input mode](#g-input-mode)
says where the next
[frame](#g-frame) (one grid step, the unit of scheduling) takes its inputs
from. In `:live` they come from the [staging cells](#g-staging-cell) (where
each device's pending batch waits between drains), and in `:replay` from the
attached recording.
````

New:

````text
This section specifies what a `Simulation` and its run own, the lifecycle a
simulation moves through, how it advances and restarts, what it keeps of its
[devices](#g-device) (any attached participants in the periphery) across runs, and the stop
policy each advance declares. A simulation is in one of five lifecycle states,
built, initialized, running, stopped or errored. A *door* is an entry point that
builds a run, and there are three, `init!`, `restore!` and `replay!`. A run's
`feed` is the recording `replay!` attached, or `nothing`. The [input mode](#g-input-mode) says
where the next [frame](#g-frame) (one grid step, the unit of scheduling) takes its inputs
from. In `:live` they come from the [staging cells](#g-staging-cell) (where each device's pending
batch waits between drains), and in `:replay` from the attached recording.
````

## 8. P2-8, unit F (edit and rewrap)

Old:

````text
This section specifies what a `Simulation` and its run own, the lifecycle a
simulation moves through, how it advances and restarts, what it keeps of its
[devices](#g-device) (any attached participants in the periphery) across runs, and the stop
policy each advance declares. A simulation is in one of five lifecycle states,
built, initialized, running, stopped or errored. A *door* is an entry point that
builds a run, and there are three, `init!`, `restore!` and `replay!`. A run's
`feed` is the recording `replay!` attached, or `nothing`. The [input mode](#g-input-mode) says
where the next [frame](#g-frame) (one grid step, the unit of scheduling) takes its inputs
from. In `:live` they come from the [staging cells](#g-staging-cell) (where each device's pending
batch waits between drains), and in `:replay` from the attached recording.
````

New:

````text
This section specifies what a `Simulation` and its run own, the lifecycle a
simulation moves through, how it advances and restarts, what it keeps of its
[devices](#g-device) (any attached participants in the periphery) across runs, and the stop
policy each advance declares. A simulation is in one of five lifecycle states,
built, initialized, running, stopped or errored. A *door* is an entry point that
builds a run, and there are three, `init!`, `restore!` and `replay!`. A run's
`feed` is the recording `replay!` attached, or `nothing`. The [input mode](#g-input-mode) says
where the next [frame](#g-frame) (one grid step, the unit of scheduling) takes its inputs
from.
````

## 9. P2-8, unit F (edit and rewrap)

Old:

````text
Four fields evolve during the run. `feed` is the recording `replay!` attached,
or `nothing`. `termination` is the record the loop's tail writes. `frame` and
`boundary` are the trajectory's counters, the frame index and the boundary
ordinal. `init!`, `restore!` and `replay!` construct a run, and nothing else
rebinds it. `live!` ([§12.7][s12-7]) and the halt at a recording's end write
`feed`. The loop's tail writes `termination` once, and `closed(run)` is
`termination !== nothing`. Each door sets the two counters as it builds the
run, `init!` to zero and `restore!` and `replay!` to the checkpoint's, and the
loop advances them ([D-317][d-317]). `restore!` of a bare state sets the frame
index to the state's frame and the boundary ordinal to zero, as `init!` does
([D-319][d-319]).
````

New:

````text
Four fields evolve during the run. `feed` is described above. `termination` is
the record the loop's tail writes. `frame` and `boundary` are the trajectory's
counters, the frame index and the boundary ordinal. `init!`, `restore!` and
`replay!` construct a run, and nothing else rebinds it. `live!` ([§12.7][s12-7]) and the
halt at a recording's end write `feed`. The loop's tail writes `termination`
once, and `closed(run)` is `termination !== nothing`. Each door sets the two
counters as it builds the run, `init!` to zero and `restore!` and `replay!` to
the checkpoint's, and the loop advances them ([D-317][d-317]). `restore!` of a bare state
sets the frame index to the state's frame and the boundary ordinal to zero, as
`init!` does ([D-319][d-319]).
````

## 10. P2-8, unit F (edit and rewrap)

Old:

````text
Beside the state, the run carries an input mode, `:live` or
`:replay`, read as `mode(sim)`. **The mode is read off the run's `feed`**,
`:replay` while a recording is attached and `:live` otherwise
([D-260][d-260]). The mode names where the next frame's [drain](#g-drain)
takes its [batches](#g-batch) from, the staging cells or the attached
recording ([§12.7][s12-7], [D-218][d-218]). The drain is the frame-top swap
that publishes staged device writes into the root inputs, and a batch is a
device's staged set of writes. State and mode are orthogonal. The state says
whether the simulation may advance, and the mode says what it will advance on.
````

New:

````text
Beside the state, the run carries an input mode, `:live` or `:replay`, read as
`mode(sim)`. **The mode is read off the run's `feed`**, `:replay` while a
recording is attached and `:live` otherwise ([D-260][d-260]). The mode names where the
next frame's [drain](#g-drain) takes its [batches](#g-batch) from, the [staging cells](#g-staging-cell) (where each
device's pending batch waits between drains) or the attached recording ([§12.7][s12-7],
[D-218][d-218]). The drain is the frame-top swap that publishes staged device writes into
the root inputs, and a batch is a device's staged set of writes. State and mode
are orthogonal. The state says whether the simulation may advance, and the mode
says what it will advance on.
````

## 11. P2-9, unit F (edit and rewrap)

Old:

````text
**[`Run`](#g-run) is what one run owns** ([D-255][d-255], [D-260][d-260], [D-317][d-317]).
It is a mutable struct of six fields. Two are `const` and last the run's whole
life. One is the [log](#g-log) (the retained sequence of published
snapshots). The other is the [trace](#g-trace) (the records of each frame's
drained inputs), which is `nothing` under the trace switch.
The door that builds the run takes the four recording keywords, `trace`,
`log`, `log_every` and `log_max` ([Appendix B][sB], [D-261][d-261]). A run's
recording is therefore that door's declaration, and the next door may declare
otherwise ([D-261][d-261]).
````

New:

````text
**[`Run`](#g-run) is what one run owns** ([D-255][d-255], [D-260][d-260], [D-317][d-317]). It is a mutable struct of
six fields. Two are `const` and last the run's whole life. One is the [log](#g-log) (the
retained sequence of published snapshots). The other is the [trace](#g-trace) (the records
of each frame's drained inputs), which is `nothing` under `trace = false`. The
door that builds the run takes the four recording keywords, `trace`, `log`,
`log_every` and `log_max` ([Appendix B][sB], [D-261][d-261]). A run's recording is therefore
that door's declaration, and the next door may declare otherwise ([D-261][d-261]).
````

## 12. P2-10, unit F (edit and rewrap)

Old:

````text
Four fields evolve during the run. `feed` is described above. `termination` is
the record the loop's tail writes. `frame` and `boundary` are the trajectory's
counters, the frame index and the boundary ordinal. `init!`, `restore!` and
`replay!` construct a run, and nothing else rebinds it. `live!` ([§12.7][s12-7]) and the
halt at a recording's end write `feed`. The loop's tail writes `termination`
once, and `closed(run)` is `termination !== nothing`. Each door sets the two
counters as it builds the run, `init!` to zero and `restore!` and `replay!` to
the checkpoint's, and the loop advances them ([D-317][d-317]). `restore!` of a bare state
sets the frame index to the state's frame and the boundary ordinal to zero, as
`init!` does ([D-319][d-319]).
````

New:

````text
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
````

## 13. P2-10, unit F (edit and rewrap)

Old:

````text
The origin `t₀` is not a run field ([D-260][d-260]). The executor's clock
holds it beside `t`. `init!` sets it on the clock before
[boundary zero](#g-boundary-zero), the initialization boundary
([§14.5][s14-5]). A [checkpoint](#g-checkpoint) (the `Model`'s state at a
frame top as one value) carries it with the clock ([§11.5][s11-5],
[D-273][d-273]). It is a `Float64`, as `h` and `t_end` are ([D-260][d-260]).
````

New:

````text
The origin `t₀` is not a run field ([D-260][d-260]). The executor's clock holds it beside
`t`. `init!` sets it on the clock before [boundary zero](#g-boundary-zero), the initialization
boundary ([§14.5][s14-5]). A checkpoint carries it with the clock ([§11.5][s11-5], [D-273][d-273]). It is a
`Float64`, as `h` and `t_end` are ([D-260][d-260]).
````

## 14. P2-11, unit F (edit and rewrap)

Old:

````text
The origin `t₀` is not a run field ([D-260][d-260]). The executor's clock holds it beside
`t`. `init!` sets it on the clock before [boundary zero](#g-boundary-zero), the initialization
boundary ([§14.5][s14-5]). A checkpoint carries it with the clock ([§11.5][s11-5], [D-273][d-273]). It is a
`Float64`, as `h` and `t_end` are ([D-260][d-260]).
````

New:

````text
The origin `t₀` is not a run field ([D-260][d-260]). The clock of the [executor](#g-executor) (the
compiled form of the stage execution order) holds it beside `t`. `init!` sets it
on the clock before [boundary zero](#g-boundary-zero), the initialization boundary ([§14.5][s14-5]). A
checkpoint carries it with the clock ([§11.5][s11-5], [D-273][d-273]). It is a `Float64`, as `h`
and `t_end` are ([D-260][d-260]).
````

## 15. P2-11, unit F (edit and rewrap)

Old:

````text
**`Simulation` is a mutable struct of four fields**, the
[`Model`](#g-model) (the deployment and its executor at one scalar), the run,
the data plane and the control plane ([D-317][d-317]). The
[control plane](#g-control-plane) is the atomic surface carrying pause, pace
and stop. The `Model` holds the [deployment](#g-deployment), the
[executor](#g-executor), its status and its
[diagnostic cell](#g-diagnostic-cell). The deployment is the scalar-free
artifact the grid parameters fix, carrying the build. The executor is the
compiled form of the stage execution order, and a diagnostic cell is a
writer's own holding place for runtime diagnostics. A simulation owns its `Model`,
claimed at construction and never shared ([§9.2][s9-2], [D-318][d-318]).
````

New:

````text
**`Simulation` is a mutable struct of four fields**, the [`Model`](#g-model) (the deployment
and its executor at one scalar), the run, the data plane and the control plane
([D-317][d-317]). The [control plane](#g-control-plane) is the atomic surface carrying pause, pace and stop.
The `Model` holds the [deployment](#g-deployment), the executor, its status and its
[diagnostic cell](#g-diagnostic-cell). The deployment is the scalar-free artifact the grid parameters
fix, carrying the build. A diagnostic cell is a writer's own holding place for
runtime diagnostics. A simulation owns its `Model`, claimed at construction and
never shared ([§9.2][s9-2], [D-318][d-318]).
````

## 16. P2-12, unit F (edit and rewrap)

Old:

````text
The origin `t₀` is not a run field ([D-260][d-260]). The clock of the [executor](#g-executor) (the
compiled form of the stage execution order) holds it beside `t`. `init!` sets it
on the clock before [boundary zero](#g-boundary-zero), the initialization boundary ([§14.5][s14-5]). A
checkpoint carries it with the clock ([§11.5][s11-5], [D-273][d-273]). It is a `Float64`, as `h`
and `t_end` are ([D-260][d-260]).
````

New:

````text
The origin `t₀` is not a run field ([D-260][d-260]). The clock of the [executor](#g-executor) (the
compiled form of the stage execution order) holds it beside `t`. `init!` sets it
on the clock before [boundary zero](#g-boundary-zero), the initialization boundary run as the
ordinary macro-sequence with an empty integrate ([§14.5][s14-5]). A checkpoint carries it
with the clock ([§11.5][s11-5], [D-273][d-273]). It is a `Float64`, as `h` and `t_end` are
([D-260][d-260]).
````

## 17. P2-12, unit F (edit and rewrap)

Old:

````text
**A `Simulation` moves through five states**, *built*, *initialized*, *running*,
and terminally *stopped* or *errored* ([§13.4][s13-4], [D-088][d-088]).
*Built* means [stores](#g-store) (the framework-owned homes of a component's
state) allocated and boundary zero not completed ([D-223][d-223]). It is the
cold state, and the state a throw inside boundary zero returns the simulation
to ([§13.4][s13-4]). *Initialized* means `init!` has completed boundary zero,
the initialization boundary run as the ordinary macro-sequence with an empty
integrate ([§14.5][s14-5]), or `restore!` or `replay!` has restored a
checkpoint.
````

New:

````text
**A `Simulation` moves through five states**, *built*, *initialized*, *running*,
and terminally *stopped* or *errored* ([§13.4][s13-4], [D-088][d-088]). *Built* means [stores](#g-store) (the
framework-owned homes of a component's state) allocated and boundary zero not
completed ([D-223][d-223]). It is the cold state, and the state a throw inside boundary
zero returns the simulation to ([§13.4][s13-4]). *Initialized* means `init!` has
completed boundary zero ([§14.5][s14-5]), or `restore!` or `replay!` has restored a
checkpoint.
````

## 18. P2-13, unit F (edit and rewrap)

Old:

````text
**`Simulation` is a mutable struct of four fields**, the [`Model`](#g-model) (the deployment
and its executor at one scalar), the run, the data plane and the control plane
([D-317][d-317]). The [control plane](#g-control-plane) is the atomic surface carrying pause, pace and stop.
The `Model` holds the [deployment](#g-deployment), the executor, its status and its
[diagnostic cell](#g-diagnostic-cell). The deployment is the scalar-free artifact the grid parameters
fix, carrying the build. A diagnostic cell is a writer's own holding place for
runtime diagnostics. A simulation owns its `Model`, claimed at construction and
never shared ([§9.2][s9-2], [D-318][d-318]).
````

New:

````text
**`Simulation` is a mutable struct of four fields**, the [`Model`](#g-model) (the deployment
and its executor at one scalar), the run, the data plane ([§11][s11]) and the control
plane ([D-317][d-317]). The [control plane](#g-control-plane) is the atomic surface carrying pause, pace and
stop. The `Model` holds the [deployment](#g-deployment), the executor, its status and its
[diagnostic cell](#g-diagnostic-cell). The deployment is the scalar-free artifact the grid parameters
fix, carrying the build. A diagnostic cell is a writer's own holding place for
runtime diagnostics. A simulation owns its `Model`, claimed at construction and
never shared ([§9.2][s9-2], [D-318][d-318]).
````

## 19. P2-13, unit F (edit and rewrap)

Old:

````text
Every other value belongs to one of the four ([D-256][d-256]). The build is
reached through the deployment, never held twice. The grid parameters, the
[schedule](#g-schedule) (the typed per-component `(D, Φ, Δt)` tick table) and
the event parameters are the deployment's ([§9.2][s9-2]). `chunk_size`, the
stepper and the arrival buffers are the executor's. `join_timeout` is
`Control`'s ([§12.1][s12-1]). The loop's diagnostic cell, its account and the
published holder are the plane's, and the frame's own diagnostic cell is the
`Model`'s
([§11.8][s11-8]). The log, the trace and the two counters are the run's. The
stop policy, with its `t_end` and ignored requesters, is the advance's
argument, and the [termination record](#g-termination-record) (the stopped-sim
value naming how the run ended) keeps the terminating one ([D-260][d-260]).
The pacer's schedule and counters are `run!`'s own, created per call and
passed to the loop and its publications as the policy is. The status of each
[snapshot](#g-snapshot) (the immutable per-boundary publication) carries the
pacer's frozen record ([§10.7][s10-7], [D-269][d-269]).
````

New:

````text
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
````

## 20. P2-40, unit F (rewrap only)

Old:

````text
Deviceless, `run!` is fully synchronous, and [§11.1][s11-1] says where the
loop and the device tasks run and defines the
[unattended run](#g-unattended-run) (a run with empty staging and no snapshot
readers).
````

New:

````text
Deviceless, `run!` is fully synchronous, and [§11.1][s11-1] says where the loop and the
device tasks run and defines the [unattended run](#g-unattended-run) (a run with empty staging and no
snapshot readers).
````

## 21. P2-16, unit F (edit and rewrap)

Old:

````text
The frame-top drain still runs, so `step!` frames stay bit-identical to `run!`
frames. In a stepping session the staging cell written is the
[harness cell](#g-harness-cell) (the always-present staging cell of the
harness writer). The harness write path is `stage!(sim, "face" => value, …)`,
and [§11.3][s11-3] specifies that [harness writer](#g-harness-writer).
Staged batches are ordinary batches. They are traced, so replay and
bit-identity hold, and they are applied at the next frame top.
````

New:

````text
The frame-top drain still runs, so `step!` frames stay bit-identical to `run!`
frames. In a stepping session the staging cell written is the [harness cell](#g-harness-cell) (the
always-present staging cell of the [harness writer](#g-harness-writer)). The harness write path is
`stage!(sim, "face" => value, …)`, and [§11.3][s11-3] specifies the writer. Staged
batches are ordinary batches. They are traced, so replay and bit-identity hold,
and they are applied at the next frame top.
````

## 22. P2-17, unit F (edit and rewrap)

Old:

````text
Termination policy is honored throughout, as bit-identity requires. `t_end`
reached, or a [stop request](#g-stop-request) (an output port of the framework
enum `StopFlag`) [holding](#g-edge-semantics) at frame 3 of
`step!(sim; frames = 10)`, ends the run there through the ordinary
[§12.4][s12-4] tail and leaves the simulation `stopped`. `step!` therefore
returns the number of frames *actually advanced*. That is the requested count
in the ordinary case, and fewer when the run terminated inside the call. That
return is how a harness detects the truncation without inspecting the clock.
````

New:

````text
The stop policy is honoured throughout, as bit-identity requires. `t_end`
reached, or a [stop request](#g-stop-request) (an output port of the framework enum `StopFlag`)
[holding](#g-edge-semantics) at frame 3 of `step!(sim; frames = 10)`, ends the run there through the
ordinary [§12.4][s12-4] tail and leaves the simulation `stopped`. `step!` therefore
returns the number of frames *actually advanced*. That is the requested count in
the ordinary case, and fewer when the run terminated inside the call. That
return is how a harness detects the truncation without inspecting the clock.
````

## 23. P2-18, unit F (edit and rewrap)

Old:

````text
The stop policy is honoured throughout, as bit-identity requires. `t_end`
reached, or a [stop request](#g-stop-request) (an output port of the framework enum `StopFlag`)
[holding](#g-edge-semantics) at frame 3 of `step!(sim; frames = 10)`, ends the run there through the
ordinary [§12.4][s12-4] tail and leaves the simulation `stopped`. `step!` therefore
returns the number of frames *actually advanced*. That is the requested count in
the ordinary case, and fewer when the run terminated inside the call. That
return is how a harness detects the truncation without inspecting the clock.
````

New:

````text
The stop policy is honoured throughout, as bit-identity requires. `t_end`
reached, or a [stop request](#g-stop-request) (an output port of the framework enum `StopFlag`)
[holding](#g-edge-semantics) (publishing `STOP_REQUESTED`) at frame 3 of `step!(sim; frames = 10)`,
ends the run there through the ordinary [§12.4][s12-4] tail and leaves the simulation
`stopped`. `step!` therefore returns the number of frames *actually advanced*.
That is the requested count in the ordinary case, and fewer when the run
terminated inside the call. That return is how a harness detects the truncation
without inspecting the clock.
````

## 24. P2-40, unit F (rewrap only)

Old:

````text
**The stop policy is declared per advance** ([D-255][d-255], [D-316][d-316]).
`t_end` and `ignore_stop_requests` are keywords of `run!`, `replay!` and
`step!`. Each call builds and validates the
[`StopPolicy`](#g-stop-policy) (the immutable value of `t_end` plus the
ignored requester paths) it passes to the loop ([§13.5][s13-5],
[D-255][d-255], [D-316][d-316]). The value lives as long as the call, and
afterwards only on the termination record of the advance that ended the run
([D-260][d-260]). A second run, or a `step!` sequence between two runs, can
therefore stop on a different clock or honour a different set of stop
requests without a rebuild.
````

New:

````text
**The stop policy is declared per advance** ([D-255][d-255], [D-316][d-316]). `t_end` and
`ignore_stop_requests` are keywords of `run!`, `replay!` and `step!`. Each call
builds and validates the [`StopPolicy`](#g-stop-policy) (the immutable value of `t_end` plus the
ignored requester paths) it passes to the loop ([§13.5][s13-5], [D-255][d-255], [D-316][d-316]). The value
lives as long as the call, and afterwards only on the termination record of the
advance that ended the run ([D-260][d-260]). A second run, or a `step!` sequence between
two runs, can therefore stop on a different clock or honour a different set of
stop requests without a rebuild.
````

## 25. P2-22, unit G (edit and rewrap)

Old:

````text
This section specifies [replay](#g-replay), re-running the ordinary loop on a
recorded input [trace](#g-trace). A trace is the primary record of a session,
a fixed [trace header](#g-trace-header) plus the [batches](#g-batch) drained at
each [frame](#g-frame). A batch is a [device](#g-device)'s staged set of
writes, and a device is any attached participant in the periphery. A frame is
one iteration of the loop, from drain to publication. The [drain](#g-drain)
is the frame-top swap that applies staged device writes to the
[root inputs](#g-root-input). The root inputs are the root component's own
inputs, the only thing the periphery may write. `replay!` is the entry point
the [§11.5][s11-5] trace exists for:
````

New:

````text
This section specifies [replay](#g-replay), re-running the ordinary loop on a recorded input
[trace](#g-trace), so that a recorded session can be inspected, its errors reproduced and
its run continued live. A trace is the primary record of a session, a fixed
[trace header](#g-trace-header) plus the [batches](#g-batch) drained at each [frame](#g-frame). A batch is a [device](#g-device)'s
staged set of writes, and a device is any attached participant in the periphery.
A frame is one iteration of the loop, from drain to publication. The [drain](#g-drain) is
the frame-top swap that applies staged device writes to the [root inputs](#g-root-input). The
root inputs are the root component's own inputs, the only thing the periphery
may write. `replay!` is the entry point the trace exists for ([§11.5][s11-5]):
````

## 26. P2-10, unit G (edit and rewrap)

Old:

````text
The default form restores from the header. It restores the trace's
[checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one value),
the state the recording opened from. It runs no
[boundary zero](#g-boundary-zero) (the initialization boundary at `t₀`).
This form stands in the `init!` position of the lifecycle ([§12.6][s12-6]) and
does what `restore!` does, with the trace header as the checkpoint
([D-274][d-274]). There is no [condition](#g-condition) resolution, and the
totality ([§14.6][s14-6]) held when the recording's `init!` ran. A condition
is the datum that says "set this build to this state". Whatever fired at `t₀`
is part of the restored state, so nothing is applied twice and nothing is
skipped ([D-274][d-274]).
````

New:

````text
The default form restores from the header. It restores the trace's [checkpoint](#g-checkpoint)
(the `Model`'s state at a frame top, beside the run's frame index and boundary
ordinal), the state the recording opened from. It runs no [boundary zero](#g-boundary-zero) (the
initialization boundary at `t₀`). This form stands in the `init!` position of
the lifecycle ([§12.6][s12-6]) and does what `restore!` does, with the trace header as
the checkpoint ([D-274][d-274]). There is no [condition](#g-condition) resolution, and the totality
([§14.6][s14-6]) held when the recording's `init!` ran. A condition is the datum that
says "set this build to this state". Whatever fired at `t₀` is part of the
restored state, so nothing is applied twice and nothing is skipped ([D-274][d-274]).
````

## 27. P2-24, unit G (edit and rewrap)

Old:

````text
**`replay!` is the ordinary loop with exactly one substitution**, not a
second loop ([D-101][d-101], [D-274][d-274]). That is what keeps every
property proved of the loop true of replay. Its drain reads the trace, and
under the default form the loop starts from a restored state.
````

New:

````text
**`replay!` is the ordinary loop with exactly one substitution**, not a second
loop ([D-101][d-101], [D-274][d-274]). That is what keeps every property proved of the loop true
of replay. The substitution is the drain, which reads the trace. Under the
default form, `replay!(sim2, trc)` above, the loop also starts from a restored
state.
````

## 28. P2-25, unit G (edit and rewrap)

Old:

````text
The default form restores from the header. It restores the trace's [checkpoint](#g-checkpoint)
(the `Model`'s state at a frame top, beside the run's frame index and boundary
ordinal), the state the recording opened from. It runs no [boundary zero](#g-boundary-zero) (the
initialization boundary at `t₀`). This form stands in the `init!` position of
the lifecycle ([§12.6][s12-6]) and does what `restore!` does, with the trace header as
the checkpoint ([D-274][d-274]). There is no [condition](#g-condition) resolution, and the totality
([§14.6][s14-6]) held when the recording's `init!` ran. A condition is the datum that
says "set this build to this state". Whatever fired at `t₀` is part of the
restored state, so nothing is applied twice and nothing is skipped ([D-274][d-274]).
````

New:

````text
The default form restores from the header. It restores the trace's [checkpoint](#g-checkpoint)
(the `Model`'s state at a frame top, beside the run's frame index and boundary
ordinal), the state the recording opened from. It runs no [boundary zero](#g-boundary-zero) (the
initialization boundary at `t₀`). This form stands in the `init!` position of
the lifecycle ([§12.6][s12-6]) and does what `restore!` does, with the trace header as
the checkpoint ([D-274][d-274]). There is no [condition](#g-condition) resolution, and the
[root-input totality](#g-root-input-totality) (every root input must hold a value) ([§14.6][s14-6]) held when the
recording's `init!` ran. A condition is the datum that says "set this build to
this state". Whatever fired at `t₀` is part of the restored state, so nothing is
applied twice and nothing is skipped ([D-274][d-274]).
````

## 29. P2-26, unit G (edit and rewrap)

Old:

````text
The drain reads the trace. Each frame top applies the recording's batches for
that [frame ordinal](#g-frame-ordinal), the frame index a batch replays at
([D-101][d-101]). It does not swap the [staging cells](#g-staging-cell) of the
[roster](#g-roster) (the list of attached device entries). A staging cell is
where a device's pending write batch waits between drains. Ordinal keying is
exact because the frame sequence is itself deterministic under replay (`t*`
boundaries derive from state, [§10.4][s10-4]). Frame *k* of the replay *is*
frame *k* of the recording. Recorded batches apply verbatim, with no surface
re-check ([D-101][d-101]). The [write-surface](#g-write-surface) rule
([§11.3][s11-3]) ran at recording time. A write surface is the set of
[faces](#g-face) a writer's batch entries may reach, and a face is the name a
port wears on its component's boundary. [Claims](#g-claim) (the set of faces a
device may write) are a live-roster fact of the recorded session that replay
does not reconstruct.
````

New:

````text
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
````

## 30. P2-35, unit G (edit and rewrap)

Old:

````text
A mode that outlives the call makes a partial replay a resumable position
rather than the end of an operation ([D-218][d-218]). Whatever advances the
simulation next reads the same mode and finds the same records. That is what
lets the reproduction workflow of [§13.4][s13-4] run through the ordinary
entry points, with no replay-only spelling of `step!`. That workflow halts at
the frame top the error names, then `step!`s the failing frame on its
recorded inputs.
````

New:

````text
A mode that outlives the call makes a partial replay a resumable position rather
than the end of an operation ([D-218][d-218]). Whatever advances the simulation next
reads the same mode and finds the same records. That is what lets the
reproduction workflow of [§13.4][s13-4] run through the ordinary entry points, with no
replay-only spelling of `step!`.
````

## 31. P2-28, unit G (edit and rewrap)

Old:

````text
**In `:replay` the recording is the bound** ([D-218][d-218]). Every advance's
frame budget is capped at the recording's last frame, and `to_boundary = k`
caps it earlier. That keyword is the consumer of the replay pointer
([§13.4][s13-4]). `to_time` is the same cap addressed by time (below). Either
keyword names a frame from the one the feed starts from through the
recording's last. The feed starts from the header's frame under the default
form, and from the simulation's own under `restore = false` (below). Anything
else is refused (`ArgumentInvalid`).
````

New:

````text
**In `:replay` the recording is the bound** ([D-218][d-218]). Every advance's frame
budget is capped at the recording's last frame, and `to_boundary = k` caps it
earlier. That keyword is the consumer of the replay pointer ([§13.4][s13-4]). `to_time`
is the same cap addressed by time (below). Either keyword names a frame from the
one the feed starts from through the recording's last, and anything else is
refused (`ArgumentInvalid`). The feed starts from the header's frame under the
default form, and from the simulation's own under `restore = false` (below).
````

## 32. P2-30, unit G (edit and rewrap)

Old:

````text
`to_boundary = k` takes the frame-entry boundary index ([§13.4][s13-4]), a
count of frame tops. It is not the published-boundary ordinal that a
[snapshot](#g-snapshot) (the immutable per-boundary publication) carries
([§12.3][s12-3]). **Replay runs through frame `k` and halts exactly at the
frame top after it** ([D-128][d-128]). Replay therefore always halts at a
frame top. The frame-entry pointer ([§13.4][s13-4]) lands the same way. A
[localized](#g-localized) `t*` boundary inside the frame (the crossing instant
bracketed by root-finding over trial sweeps) is reproduced but not
stoppable-at ([D-128][d-128]). The trace stays frame-indexed, replay pointers
and error messages use the frame-entry boundary index, and snapshots carry the
published-boundary ordinal ([§10.4][s10-4]).
````

New:

````text
`to_boundary = k` takes the frame-entry boundary index ([§13.4][s13-4]), a count of frame
tops. It is not the published-boundary ordinal that a [snapshot](#g-snapshot) (the immutable
per-boundary publication) carries ([§12.3][s12-3]). **Replay runs through frame `k` and
halts exactly at the frame top after it** ([D-128][d-128]). Replay therefore always halts
at a frame top. The frame-entry pointer ([§13.4][s13-4]) lands the same way. A [localized](#g-localized)
`t*` boundary (the crossing instant bracketed by root-finding over trial sweeps)
inside the frame is reproduced but not stoppable-at ([D-128][d-128]). The trace stays
frame-indexed, replay pointers and error messages use the frame-entry boundary
index, and snapshots carry the published-boundary ordinal ([§10.4][s10-4]).
````

## 33. P2-31, unit G (edit and rewrap)

Old:

````text
Replay may also end earlier still under the ordinary policies, since `t_end`
and `ignore_stop_requests` are keywords of `replay!` exactly as of `run!`
([§12.6][s12-6], [D-255][d-255], [D-316][d-316]). A termination the recorded
session hit through a stop request reproduces itself anyway, deterministically
([D-127][d-127]). A replay honours requests by default too, and the trace
header records no policy. So a replay of a live run that ignored some must
pass the same `ignore_stop_requests`.
````

New:

````text
Replay may also end earlier still under the ordinary policies, since `t_end` and
`ignore_stop_requests` are keywords of `replay!` exactly as of `run!` ([§12.6][s12-6],
[D-255][d-255], [D-316][d-316]). A termination the recorded session hit through a [stop request](#g-stop-request) (an
output port of the framework enum `StopFlag`) reproduces itself anyway,
deterministically ([D-127][d-127]). A replay honours requests by default too, and the
trace header records no policy. So a replay of a live run that ignored some must
pass the same `ignore_stop_requests`.
````

## 34. P2-33, unit G (edit and rewrap)

Old:

````text
Validation is the other keywords'. The value must be real, finite and at
least `t₀`, and it must name a time the recording covers. The checks run
before the replay writes anything, the default form's restore included.
````

New:

````text
`to_time` is validated as the other keywords are. The value must be real, finite
and at least `t₀`, and it must name a time the recording covers. The checks run
before the replay writes anything, the default form's restore included.
````

## 35. P2-34, unit G (edit and rewrap)

Old:

````text
`live!` is the one call that moves the mode alone. The flip above is
automatic, and it happens only at the recording's end. `live!(sim)` performs
it by hand. **`live!` sets the mode to `:live` and detaches the recording's
remainder, touching nothing else** ([D-219][d-219]). The trajectory stands
where the replay left it, and so does the trace with its header, inherited
under the default form. The next `run!` or `step!` is therefore the live
continuation from the replayed boundary, and its drains append to the
re-recorded prefix. `live!` is a stopped-sim operation, legal only on an
`initialized` simulation in `:replay`. Every other state refuses under the
ordinary lifecycle gates ([§12.6][s12-6]), with `MissingInit` at `built` and
`ServiceLifecycle` in the rest. A simulation already `:live` refuses too, with
`ArgumentInvalid`. The call would have nothing to do, and a loud refusal beats
a silent no-op ([D-219][d-219]).
````

New:

````text
`live!` is the one call that moves the mode alone. The flip above is automatic.
`live!(sim)` performs it by hand. **`live!` sets the mode to `:live` and
detaches the recording's remainder, touching nothing else** ([D-219][d-219]). The
trajectory stands where the replay left it, and so does the trace with its
header, inherited under the default form. The next `run!` or `step!` is
therefore the live continuation from the replayed boundary, and its drains
append to the re-recorded prefix. `live!` is a stopped-sim operation, legal only
on an `initialized` simulation in `:replay`. Every other state refuses under the
ordinary lifecycle gates ([§12.6][s12-6]), with `MissingInit` at `built` and
`ServiceLifecycle` in the rest. A simulation already `:live` refuses too, with
`ArgumentInvalid`. The call would have nothing to do, and a loud refusal beats a
silent no-op ([D-219][d-219]).
````

## 36. P2-36, unit G (edit and rewrap)

Old:

````text
The trace `sim2` leaves behind is a complete recording of *itself*, the
replayed prefix out to t = 100 and then the frames flown live after it.
````

New:

````text
The trace `sim2` leaves behind is a complete recording of *itself*, the replayed
prefix out to t = 100 and then the frames flown live after it, since replay
re-records (below).
````

## 37. P2-35, unit G (edit and rewrap)

Old:

````text
A replay's halt leaves the simulation `initialized`, never `stopped`
([D-218][d-218]). That state is boundary-consistent and ready to advance, the
same state `step!` leaves ([§12.6][s12-6]). This is what makes three promised
workflows real ([D-101][d-101]). State-trajectory inspection asks "what was
the private state at t = 37.2?", and answers it by replaying there and reading
the live stores ([§11.2][s11-2]). Error reproduction replays to the
frame-entry boundary `k` the error names, then `step!`s the failing frame
under instrumentation ([§13.4][s13-4]). Continuation is `run!` after
`replay!`, a live session from the replayed boundary. After a full replay
that is the next call, the records exhausted at the halt. After a partial one
the remainder of the recording is consumed first, across as many `step!` and
`run!` calls as the caller makes, and the session goes live at the
recording's end. Or `live!` drops that remainder, and the continuation starts
at the halt.
````

New:

````text
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
````

## 38. P2-37, unit G (edit and rewrap)

Old:

````text
**[Pacing](#g-pacing) and the [control plane](#g-control-plane) are
unchanged** ([§10.7][s10-7], [§12.1][s12-1], [D-101][d-101]). The control
plane is the separate atomic surface carrying pause, pace and the stop word.
Pacing (waits inserted between completed frames, never altering the boundary
sequence) sits outside the semantics, so paused, slow-motion or real-time
replay is free. Paced replay with an attached visualizer *is* session
playback, and `replay!` takes `pace` and `margin` as `run!` does
([§12.1][s12-1], [D-269][d-269]). Stop truncates, as anywhere.
````

New:

````text
**[Pacing](#g-pacing) and the [control plane](#g-control-plane) are unchanged** ([§10.7][s10-7], [§12.1][s12-1], [D-101][d-101]). The
control plane is the separate atomic surface carrying pause, pace and stop.
Pacing (waits inserted between completed frames, never altering the boundary
sequence) sits outside the semantics, so paused, slow-motion or real-time replay
is free. Paced replay with an attached visualizer *is* session playback, and
`replay!` takes `pace` and `margin` as `run!` does ([§12.1][s12-1], [D-269][d-269]). Stop
truncates, as anywhere.
````

## 39. P2-40, unit G (rewrap only)

Old:

````text
**Validation is loud and up front** ([D-101][d-101]). Before the first frame,
the checkpoint's [deployment](#g-deployment) (the scalar-free artifact the
grid parameters fix) is compared against the target's. Its fingerprint, the
structural layout, is compared against the `Build`. The fingerprint covers
the store layout, the root-input faces, and what a copy by position relies on
([§11.5][s11-5]). The trace's batch entries are validated against the root
input-face list, and each batch's frame ordinal against the recording's
frames, from the one after the header's to the last ([D-217][d-217]). Each
writer's face-name → position schema, on the trace's `schemas` list
([§11.5][s11-5]), is validated in the same pass. A recorded schema that
disagrees with the target model's own root-input faces is a replay error. The
checks are attach-style, and a failure reports
[did-you-mean](#g-did-you-mean), the offending name plus the list-in-hand it
should have matched. The kinds are `CheckpointMismatch`,
`ReplaySchemaMismatch` and `ReplayUnknownFace` ([Appendix C][sC]). The pass
runs under both forms of `replay!`.
````

New:

````text
**Validation is loud and up front** ([D-101][d-101]). Before the first frame, the
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
````

## 40. P2-38, unit G (edit and rewrap)

Old:

````text
Under the default form the clock is *restored*, not compared. That form
restores `t₀` with the rest of the clock, so `replay!` takes no `t0` argument
([D-127][d-127]). Under `restore = false` the simulation's own clock runs, its
origin must equal the recording's, and the new trace's header is the
simulation's own checkpoint. The checkpoint holds no policy ([D-255][d-255]).
`t_end` and `ignore_stop_requests` are keywords of this `replay!` call,
validated per call as at `run!`.
````

New:

````text
Under the default form the clock is *restored*, not compared. That form restores
`t₀` with the rest of the clock, so `replay!` takes no `t0` argument ([D-127][d-127]).
Under `restore = false` the simulation's own clock runs, and its origin must
equal the recording's. The checkpoint holds no policy ([D-255][d-255]). `t_end` and
`ignore_stop_requests` are keywords of this `replay!` call, validated per call
as at `run!`.
````

## 41. P2-23, unit G (edit and rewrap)

Old:

````text
Replaying against the same structure with changed parameters is the
what-if replay, the deterministic re-driving of the
recorded inputs through a modified model. It is spelled as `init!` of the
modified model under the authored condition, then
`replay!(sim, trc; restore = false)`. The trace is not self-sufficient for it.
Its checkpoint holds the recording model's state after boundary zero, so the
authored condition comes from outside ([D-274][d-274]). Bit-identity is
promised only against the identical build ([§2.4][s2-4]). What-if replay
promises determinism, never reproduction.
````

New:

````text
Replaying against the same structure with changed parameters is the what-if
replay. It is spelled as `init!` of the modified model under the authored
condition, then `replay!(sim, trc; restore = false)`. The trace is not
self-sufficient for it. Its checkpoint holds the recording model's state after
boundary zero, so the authored condition comes from outside ([D-274][d-274]).
Bit-identity is promised only against the identical build ([§2.4][s2-4]). What-if replay
promises determinism, never reproduction.
````

## 42. P2-39, unit G (rewrap only)

Old:

````text
`replay!(sim, trc; restore = false)` attaches the feed to the simulation as it
stands and restores nothing. The simulation must be `initialized`, at the
recording's `t₀`, and at a frame from the header's to one short of the
recording's last. A simulation that is not `initialized` meets the lifecycle
gate before any write, with `MissingInit` when it is `built` and
`ServiceLifecycle` in any other state. One whose origin or frame is off the
recording's is refused before any write as `CheckpointMismatch`, its clock
arm. One grid is thus an invariant of
every replay, and `to_time` has one meaning. The drain applies the records
from the frame after the simulation's own.
````

New:

````text
`replay!(sim, trc; restore = false)` attaches the feed to the simulation as it
stands and restores nothing. The simulation must be `initialized`, at the
recording's `t₀`, and at a frame from the header's to one short of the
recording's last. A simulation that is not `initialized` meets the lifecycle
gate before any write, with `MissingInit` when it is `built` and
`ServiceLifecycle` in any other state. One whose origin or frame is off the
recording's is refused before any write as `CheckpointMismatch`, its clock arm.
One grid is thus an invariant of every replay, and `to_time` has one meaning.
The drain applies the records from the frame after the simulation's own.
````
