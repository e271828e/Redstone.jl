### 12.5 Scripts and the mid-run mutation doctrine

What the consumers demonstrably mutate mid-run is surveyed here. FlightCore's
`user_callback!` has exactly two archetypes. The first is the timetable
script (c172_demos.jl:290: `elevator_offset` as a function of `t`). The
second is the synthetic pilot (c172_demos.jl:423, 525: a phase FSM reading
`y` and writing mode requests, references, flaps, wind). Both write only `u`
fields. No demo, test or GUI path pokes `x`/`s` mid-run, and `init!`/trim
appear only between construction and `run!` (c172_demos.jl:303).

**Sim-time scripts are model behavior, so they become
[scenario components](#g-scenario-component)** (ordinary periodic discrete
components holding a sim-time script). Both archetypes are clocked by *sim
time*, `t`, the trajectory. Mapping them to [devices](#g-device) is rejected
([D-031][d-031]). The clock is the criterion.

**Rule.** A sim-time script becomes a source or supervisor
[component](#g-component); a wall-clock interaction becomes a device.

A script mapped to a component is periodic discrete, with `K = 1` for
today's `dt = 0.02` callbacks. It executes synchronously in the loop,
deterministic paced or unpaced. It is replayed by recomputation, with no
[trace](#g-trace). A device, by contrast, is traced and replayed from the
trace.

**The component mapping is strictly richer than the callback it replaces.**

- The `Ref(:init)` phase closure becomes honest `s`, visible in
  [snapshots](#g-snapshot), logs and plots.
- Inputs arrive same-[boundary](#g-boundary) fresh by topological order. The
  callback ran post-step, one boundary staler.
- The pure timetable script is a one-liner reading the clock out of its
  [bundle](#g-bundle) (the NamedTuple of zero-copy views a component function
  receives). That one-liner is
  `y_direct(c, (; t)) = (; offset = profile(t))`, exact at its own
  [ticks](#g-tick), with no latching.
- In a scenario configuration the script drives the avionics' input
  [ports](#g-port). [§11.7][s11-7] therefore renders the corresponding GUI
  widgets read-only with its source shown. Today's demo-vs-GUI dead-slider fight
  is resolved by the port-resolution rule.

**`user_callback!` is eliminated** ([D-031][d-031]). It is the
[periphery](#g-periphery)'s `f_step!`, FlightCore's unconditional per-step
hook ([§2.5][s2-5]), and cheap composition leaves it
without justification. Its call sites migrate to scenario components, not
devices.

**Manual event triggering needs no mechanism.** It takes a
[root input](#g-root-input) plus a [boundary-detected](#g-boundary-detected)
[guard](#g-guard) reading that root input (an edge check at step boundaries
only, with no root-finding). That is already expressible in settled
machinery. The levels doctrine applies: latched commands or counters. The
demos' engine start/stop buttons are `u`-writes today.

**Mid-run re-initialization is not built, because it is not demonstrated.**
Initialization and trim are stopped-sim workflows (first-class services,
[§14][s14]). No concurrency perimeter exists there. There is no loop and no
devices, just plain single-task code. The guarded-addition shape is on
record should demand appear. It would be a traced, boundary-executed
intervention command applied through project → [sweep](#g-sweep) → publish,
so that no consumer ever observes un-decoded state.

**The doctrine, final form.** While a simulation runs, the periphery stages
root-input writes and issues control commands. Structurally, it does nothing
else. Anything that wants to poke the model mid-run is one of three things.
It is an *input* in disguise, so wire a root input and a guard. It is *model
behavior* in disguise, so add a scenario component. Or it is a *wall-clock
interaction*, so attach a device. Graceful termination follows the same
shape ([§13.5][s13-5]): a [stop request](#g-stop-request) declared in the
model, honoured unless the advance ignores it. Never a callback, and never a
thrown exception.

### 12.6 Run lifecycle and partial advance

**[`Run`](#g-run) is what one run owns** ([D-255][d-255], [D-260][d-260], [D-317][d-317]).
It is a mutable struct of six fields. Two are `const` and last the run's whole
life, the log and the [trace](#g-trace) (`nothing` under the trace switch).
The door that builds the run takes the four recording keywords, `trace`,
`log`, `log_every` and `log_max` ([Appendix B][sB], [D-261][d-261]), so a
run's recording is that door's declaration and the next door may declare
otherwise.
Four evolve during it. `feed` is the recording `replay!` attached, or
`nothing`. `termination` is the record the loop's tail writes. `frame` and
`boundary` are the trajectory's counters, the frame index and the boundary
ordinal. `init!`, `restore!` and `replay!` construct one, and nothing else
rebinds it. `live!` and the halt at a recording's end write `feed`. The
loop's tail writes `termination` once, and `closed(run)` is
`termination !== nothing`. Each door sets the two counters as it builds the
run, `init!` to zero and `restore!` and `replay!` to the checkpoint's, and
the loop advances them ([D-317][d-317]). `restore!` of a bare state sets the
frame index to the state's frame and the boundary ordinal to zero, as `init!`
does ([D-319][d-319]).
The origin `t₀` is not a run field. The executor's clock holds it beside `t`.
`init!` sets it on the clock before boundary zero ([§14.5][s14-5]), and a
[checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one
value) carries it with the clock ([§11.5][s11-5], [D-273][d-273]). It is a
`Float64`, as `h` and `t_end` are.

A `Simulation` is constructed with a **placeholder run**, an empty log, no
trace, no feed and no termination, which `init!`, `restore!` and `replay!`
replace ([D-255][d-255]). The field is always a `Run` and never `nothing`, so every
accessor has a run to read, and the lifecycle state below says whether that run
ever started. The placeholder carries no configuration and no compiled state
([D-261][d-261]). `init!` allocates fresh objects rather than clearing them.

**`Simulation` is a mutable struct of four fields**, the
[`Model`](#g-model) (the deployment and its executor at one scalar), the run, the
data plane and the [control plane](#g-control-plane) ([D-317][d-317]). The `Model`
holds the [deployment](#g-deployment) (the scalar-free artifact the grid
parameters fix, carrying the build), the [executor](#g-executor), its status
and its diagnostic cell. A simulation owns its `Model`, claimed at
construction and never shared ([§9.2][s9-2], [D-318][d-318]). Every other value belongs to one of the four
([D-256][d-256]). The build is reached through the
deployment, never held twice. The grid parameters, the [schedule](#g-schedule) (the typed
per-component `(D, Φ, Δt)` tick table) and the event parameters are the
deployment's ([§9.2][s9-2]). `chunk_size`, the stepper and the arrival buffers
are the executor's. `join_timeout` is `Control`'s ([§12.1][s12-1]). The loop's
[diagnostic cell](#g-diagnostic-cell), its account and the published holder
are the plane's, and the frame's own cell is the `Model`'s ([§11.8][s11-8]).
The log, the trace and the two counters are the run's. The
stop policy, with its `t_end` and ignored requesters, is the advance's argument, and
the [termination record](#g-termination-record) keeps the terminating one
([D-260][d-260]). The pacer's schedule and counters are `run!`'s own, created
per call and passed to the loop and its publications as the policy is, and
each snapshot's status carries their frozen record ([§10.7][s10-7], [D-269][d-269]).

**Rule.** A struct holds what it owns or what it must retain across calls. A
callee takes what it reads as an argument, never off a field added to the
container it already holds. An object is built after its inputs exist, and
the placeholder run above is the one exception ([D-261][d-261]).

A `Simulation` moves through five states: **built**, **initialized**,
**running**, and terminally **stopped** or **errored** ([§13.4][s13-4]).
**Built** means stores allocated and [boundary zero](#g-boundary-zero) not
completed. It is the cold state, and the state a throw inside boundary zero
returns the simulation to ([§13.4][s13-4]). **Initialized** means `init!`
has completed boundary zero, the initialization boundary run as the ordinary
macro-sequence with an empty integrate ([§14.5][s14-5]), or `restore!` or
`replay!` has restored a checkpoint.

**`lifecycle(sim)` derives the state rather than storing it** ([D-317][d-317]). It
reads three facts, the control plane's running flag, the `Model`'s status
and whether the run is closed. The status is `:built`, `:consistent` or
`:inconsistent`, and only the `Model`'s own doors and catch sites write it.
A claimed model's status is written only through its simulation's doors,
since the model's doors refuse a direct call on a claimed model ([D-318][d-318]).

| running flag | `Model` status | run closed | state |
|---|---|---|---|
| set | any | any | running |
| clear | `:built` | any | built |
| clear | `:inconsistent` | any | errored |
| clear | `:consistent` | no | initialized |
| clear | `:consistent` | yes | stopped |

Beside the state, the run carries an **[input mode](#g-input-mode)**,
`:live` or `:replay`, read as `mode(sim)`. It is read off the run's `feed`:
`:replay` while a recording is attached, `:live` otherwise ([D-260][d-260]).
The mode names where the next frame's [drain](#g-drain) takes its batches
from, the staging cells or the attached recording ([§12.7][s12-7]). State and mode are orthogonal. The
state says whether the simulation may advance, and the mode says what it
will advance on.

**Rule.** `init!` is mandatory.

`run!` or `step!` on a simulation whose [boundary](#g-boundary) zero has not
completed is an error in the kind set ([§13.2][s13-2]) naming `init!`. That
is distinct from `UninitializedInputs`, which fires *inside* `init!`
([§14.6][s14-6]). `restore!` and `replay!` are the two alternative entries.
Each restores a checkpoint and runs no boundary zero ([§12.7][s12-7],
[D-274][d-274]). A throw inside boundary zero, which only `init!` runs, leaves
the simulation `built` ([§13.4][s13-4]), so the next `run!` or `step!` meets
the same refusal.

**Where the loop runs.** The loop runs on the [calling task](#g-calling-task),
the task that invoked `run!`, and every rostered [device](#g-device) on a
spawned task ([§11.1][s11-1]). Deviceless, `run!` is fully synchronous. An
[unattended run](#g-unattended-run) is the same loop with empty staging
([§11.1][s11-1]). It is also what the synchronous rethrow presupposes
([§13.4][s13-4]).

**Partial advance.** `step!(sim; frames = 1)` advances whole frames
synchronously through the ordinary frame sequence ([drain](#g-drain),
integrate, boundaries, publication) and returns. A stepped simulation is
bit-identical to the same frames under `run!`, and it never waits, whatever
pace the control plane holds ([D-269][d-269]). `step!(sim; t_plus = 10.0)`
is the duration spelling, mutually exclusive with `frames`. It advances
whole frames until the boundary time first covers the duration, which is
the migration suite's advance-by-duration idiom.

Partial advance is the test-harness mode: advance, assert, advance. It
is equally the REPL mode: fly a while, inspect, continue. Neither is a
script, so the scenario-[component](#g-component) doctrine does not absorb
them ([§12.5][s12-5]).

**A stepping session is deviceless by construction.** Device tasks are
per-`run!` artifacts ([§11.1][s11-1]), and a device loop's
`while running(handle)` is false outside a run. Between `step!` calls the
simulation is in a stopped-sim state, `initialized` (below), so `attach!` is
legal there and does what it always does. It registers ([§11.3][s11-3]), and
the task appears at the next `run!`.

**The [frame-top drain](#g-drain) still runs**, so `step!` frames stay
bit-identical to `run!` frames. What it drains is the **harness
[cell](#g-harness-cell)**. The harness write path is
`stage!(sim, "face" => value, …)` ([§11.3][s11-3]), from any task, the calling
task included. Staged batches are ordinary batches. They are traced, so
[replay](#g-replay) and bit-identity hold. They are applied at the next
frame top. They are surface-checked like any writer's ([§11.3][s11-3]).

The read half is `latest(sim)`. It hands back the same immutable
[snapshot](#g-snapshot) value a device handle acquires ([§11.2][s11-2]),
navigated directly for assertions. Advance-assert-advance is `stage!` →
`step!` → `latest`. Both entry points work under `run!` too. The
[harness cell](#g-harness-cell), the always-present staging cell of the
harness writer, is not step-scoped. An inspection accessor leaves the
rejection of closure-based termination ([§13.5][s13-5]) untouched.

**Status, termination and the `run!` [seam](#g-seam).** Between `step!`
calls a simulation reports **initialized**. No loop task exists, so
`running` would lie. Nothing is terminal, so `stopped` would lie too. The
state reads "boundary-consistent and ready to advance", not "sitting at
boundary zero". `run!` may therefore follow `step!`, continuing from the
current boundary, and so may another `step!`.

Termination policy is honored throughout, as bit-identity requires. `t_end`
reached, or a [stop request](#g-stop-request) [holding](#g-edge-semantics) at
frame 3 of `step!(sim; frames = 10)`, ends the run there through the
ordinary [§12.4][s12-4] tail and leaves the simulation `stopped`. `step!`
therefore returns the number of frames **actually advanced**. That is the
requested count in the ordinary case, and fewer when the run terminated
inside the call. That return is how a harness detects the truncation without
inspecting the clock.

**Re-running: `stopped → init! → run!` remains the authored re-run.**
`init!` re-runs boundary zero from its condition. The warm restart is
`checkpoint` → `restore!` → `run!` ([§12.7][s12-7], [D-274][d-274]).
`restore!` is a door like `init!`, and it runs no boundary zero. Each builds
a fresh run, so the trace, the log and the
[termination record](#g-termination-record) ([§13.5][s13-5]) are new objects
rather than cleared ones, and each clears any batches still in
[staging cells](#g-staging-cell). The [recorders](#g-recorders) restart with
the run they record, and no stale batch survives to clobber the frame it
predates. `init!` and `restore!` also return the input mode to `:live`, and a
fresh `replay!` sets the mode exactly as it sets the trajectory. `live!` is
the fourth door, and the only one that moves the mode alone. It takes a
replaying simulation live where it stands ([§12.7][s12-7]). A terminal state
makes the mode moot. Nothing advances until one of those doors is taken
([D-218][d-218], [D-219][d-219]).

**`checkpoint` and `restore!` exist on the `Model` and on the `Simulation`,
and a `Checkpoint` is the `Model`'s state beside the run's cursor** ([D-319][d-319]).
`checkpoint(model)` returns the state alone, a `ModelState`. It holds the
flat buffer, the `s` and `m` stores, the whole signal table, the guard
priors, `t`, `t₀` and the fingerprint. It is legal at `:consistent` with the
clock on a grid top. `checkpoint(sim)` wraps that state with the run's frame
index and boundary ordinal ([D-274][d-274]). It is a stopped-sim
service, legal in `initialized` and `stopped` ([§14][s14]). It is refused wherever the
executor is not at the rest a published frame top leaves (`CheckpointMidFrame`,
[Appendix C][sC]). That is after a `t*` stop, which leaves the clock mid-frame with
the remainder abandoned, and after a frame abandoned unpublished ([§12.4][s12-4]). The
test is that the clock sits on a grid time and that the latest snapshot is of
that very boundary. `restore!(model, model_state)` checks the state's
fingerprint against the model. It also checks that the state's `t` is a grid
time `t₀ + k·h` of the state's own origin and step, and a state off its grid
is `CheckpointMidFrame`. Every mismatch of either kind is collected into one
throw before any write. The door then copies the state back, settles the
restored boundary through the hooks and writes `:consistent` last
([D-318][d-318]). `restore!(sim, cp)` takes the four recording keywords `init!` takes.
It checks the checkpoint's fingerprint against the simulation as replay checks
the trace header, and a mismatch is `CheckpointMismatch` ([§12.7][s12-7]). It checks
the state's `t` against its grid as the model's door does, collecting both
kinds into one throw. It then copies
the state back, opens a fresh run with the checkpoint as its trace header, and
publishes one snapshot at the checkpoint's `t`. It runs no sweep, evaluates no
guard, runs no update and resets no prior. The next frame is the original
lattice's next frame, because the clock came with the checkpoint. The boundary
ordinal continues, being the trajectory's ([§12.3][s12-3], [D-230][d-230]). The snapshot
`restore!` publishes is a re-publication. It carries the ordinal of the boundary
the checkpoint was taken at, and the next frame publishes under the next
ordinal, as it did in the original run. `restore!(sim, model_state)` is the
door a state prepared on a standalone model takes into a simulation
([§9.2][s9-2]). It takes the same keywords and makes the same fingerprint
check, and it refuses a state whose `t` is off the grid as
`CheckpointMidFrame`. It opens a fresh trajectory at the state's frame, and
the restored boundary publishes under ordinal 0, as boundary zero's does. A
standalone model published nothing, so the trajectory has no ordinals to
continue. A `Checkpoint` holds a `ModelState{Float64}`, so it is nominal by
type. A state taken at another scalar is refused by dispatch with the same
`CheckpointMismatch`, on either `restore!` that takes a bare state.

**Device attachments persist across re-initialization**, because attachment
is orthogonal to the run lifecycle ([§11.3][s11-3]). Persistence means
*roster* persistence. Binding, [claims](#g-claim) and device id survive.
Tasks and OS resources do not (the per-run topology, [§11.1][s11-1]; the
teardown, [§12.4][s12-4]). Each `run!` re-initializes every rostered device
and spawns its task. `attach!` while stopped only registers, and the task
appears at the next `run!`.

**Task topology follows the roster each time** ([§11.1][s11-1]). A front
end attached by hand is still rostered, so the next `run!` spawns its task
again.

**The stop policy is declared per advance.** `t_end` and
`ignore_stop_requests` are keywords of `run!`, `replay!` and `step!`, and each
call builds and validates the [`StopPolicy`](#g-stop-policy) (the immutable
value of `t_end` plus the ignored requester paths) it passes to the loop
([§13.5][s13-5], [D-255][d-255], [D-316][d-316]). The value lives as long as the call,
and afterwards only on the termination record of the advance that ended the
run ([D-260][d-260]). A second run, or a `step!` sequence between two runs,
can therefore stop on a different clock or honour a different set of stop
requests without a rebuild.

**`errored` is terminal** ([D-059][d-059]). Reproduction is trace replay
([§12.7][s12-7]), not resurrection.

