# The simulation around its model (§9.1, §9.2, §12.6): the runtime that drives
# a `Model{Float64}`. The framework owns the loop; the one delegated operation
# is "advance the continuous state from `t` by `h`", across the stepper seam
# (§10.2) that model.jl holds beside the phase-body accessor (§9.7).

# Design: §11.6, §12.4, §13.4, §13.5, §13.6, Appendix B, D-203, D-268, D-316.
# §13.5's termination sources (D-203): the diagnostic convention applied to the
# run's outcome — each kind is its identity, its payload plain data — without
# joining Appendix C's diagnostic set, the record being outcome, not warning.
# `EndTimeReached` carries nothing: the record's own `t` is the fact, and the
# configured bound lives with the policy. `ModelRequestedStop` carries the
# requester that ended the run, its component path, port and reason: the first
# honoured request read holding, in roster order (D-316). `ControlRequestedStop`
# carries its issuer — `:code` from `stop!(sim)`, the requesting device's name
# from `stop!(handle)`, or `:interrupt`, the operator's stop (§12.4, D-268),
# requested at one of the frame loop's unmask points, by the init bracket or
# §11.6's wrapper when one leaves a device's `init!` or loop body, or by §13.4's
# defensive carve-out when one reaches the catch site — through the same
# first-writer-wins word, so an earlier issuer keeps it. `LoopError` is §13.6's
# abnormal entry, `exception` the retained cause — a `StepError` from the frame
# loop's one catch site (§13.4), which carries the raw cause in turn.
"""
    TerminationSource

The abstract type of the typed source that ended a run.

A [`TerminationRecord`](@ref), which [`termination`](@ref) returns, holds one
in its `source` field. Each source is a struct whose fields say how the run
ended, and there are four.

- [`EndTimeReached`](@ref): the run completed the [frame](@ref g-frame) that
  reached its `t_end`.
- [`ModelRequestedStop`](@ref): an honoured [stop request](@ref g-stop-request)
  ended the run, and the source names the requester.
- [`ControlRequestedStop`](@ref): the calling code, a [device](@ref g-device) or
  Ctrl-C stopped the run, and the source names the issuer.
- [`LoopError`](@ref): a failure inside the loop aborted the run, and the
  source holds the failure.

A caller tells them apart by type, as in
`termination(sim).source isa EndTimeReached`.
"""
abstract type TerminationSource end

# Design: §13.5, D-203.
"""
    EndTimeReached

The termination source of a run that completed the [frame](@ref g-frame)
reaching its `t_end`.

It carries no fields. The
[termination record](@ref g-termination-record)'s own `t` is the time reached,
and the bound is the record's `policy.t_end`. Read the record with
[`termination`](@ref).
"""
struct EndTimeReached <: TerminationSource end

# Design: §13.5, D-203, D-316.
"""
    ModelRequestedStop

The termination source of a run ended by an honoured
[stop request](@ref g-stop-request).

The source carries the requester's [component](@ref g-component) `path`, its
`port` and its `reason`. When several honoured requests hold at once, it names
the first in the build's order of requesters. Read the record with
[`termination`](@ref).
"""
struct ModelRequestedStop <: TerminationSource
    path::String
    port::Symbol
    reason::String
end
ModelRequestedStop(requester::Requester) =
    ModelRequestedStop(requester.path, requester.port, requester.reason)

# Design: §12.1, §12.4, §13.5, D-203, D-268.
"""
    ControlRequestedStop

The termination source of a run stopped by the calling code, a
[device](@ref g-device) or Ctrl-C.

It carries the stop's `issuer`: `:code` from `stop!(sim)`, the requesting
device's name from `stop!(handle)`, or `:interrupt` for Ctrl-C. The first issuer
wins, so an earlier stop keeps its issuer. Read the record with
[`termination`](@ref).
"""
struct ControlRequestedStop <: TerminationSource
    issuer::Union{Symbol,String}
end

# Design: §12.4, §13.4, §13.5, §13.6, Appendix B, D-203.
# The failed boundary is discarded by construction: publication is a boundary's
# last act, so it published nothing and the previous snapshot is already final.
"""
    LoopError

The termination source of a run aborted by a failure inside the loop.

`LoopError` is the abnormal source. A run ends with it when a
[frame](@ref g-frame) throws, which leaves the simulation `errored`, and the
previous [snapshot](@ref g-snapshot) is the run's final one. `exception` holds
the failure as the loop caught it: a wrapper whose `cause` is the raw error,
beside the time and the place in the frame where it was thrown.

By the time a caller can read the source, the [tail](@ref g-tail) has already
run. [`run!`](@ref) says how a failed run ends, and [`termination`](@ref) how
its record is read.
"""
struct LoopError <: TerminationSource
    exception::Any
end

"""
The stop policy one advance declares (§13.5, D-255, D-316): the clock bound and
the requester paths the advance ignores, built and validated by `run!`,
`replay!` and `step!` per call and passed to the loop as that advance's
argument — from the call to the record, and nowhere else (D-260). The ignore
mask compiled from it is not part of it: it travels beside it as the loop's
own argument (D-261). It lives as
long as the call, and afterwards only on the termination record of the advance
that ended the run. `ControlRequestedStop` is outside it: the policy is what
the caller declares, the stop word is what anyone can issue (§12.1).
"""
struct StopPolicy
    t_end::Float64            # Inf = no clock bound
    ignored::Vector{String}   # requester paths not honoured, in the order given
end

# Design: §9.4, §12.6, §13.5, Appendix B, D-201, D-203, D-233, D-255, D-260,
# D-317.
# The run's *outcome*, and the policy of the advance that ended it, so a
# stopped simulation answers "why did it stop?", and "how did the stop go?",
# without its consumer reconstructing either from the clock or the log stream
# (D-203). `t` is a `Float64` since only a nominal model runs (§9.4, D-317),
# always present since boundary zero precedes every record (D-233). `policy` is
# the terminating advance's `StopPolicy`, so `EndTimeReached`'s bound is read off
# the record rather than off a constructor default that no longer exists
# (D-255). `source` is the typed source above. `residue` is what the run's-end
# sweep collected, recorded here and presented through the logging backend,
# never published (D-201, D-203). The record lives on the `Run`, written once by
# the loop's tail, so a fresh run starts without one (§12.6, D-255), and it is
# the policy's one lasting home (D-260).
"""
    TerminationRecord

The record of how a run ended: its final time, its
[stop policy](@ref g-stop-policy), its source and its residue.

[`termination`](@ref) returns it once the run has ended. The
[termination record](@ref g-termination-record) is written once, as the run
ends, and every call that opens a run starts it without one. A record holds
these fields.

- `t`: the [boundary](@ref g-boundary) time of the run's final
  [snapshot](@ref g-snapshot), as a `Float64`.
- `policy`: the stop policy of the advance that ended the run.
- `source`: the typed source that ended the run, such as
  [`EndTimeReached`](@ref) or [`ModelRequestedStop`](@ref) with its
  fields.
- `residue`: the diagnostics the writers reported after the final snapshot,
  collected as the run ended. They are logged, and never published.
"""
struct TerminationRecord
    t::Float64
    policy::StopPolicy
    source::TerminationSource
    residue::Vector{ResidueRecord}
end

# Design: §11.5, §12.6, Appendix B, D-218, D-255, D-260, D-261, D-317.
# The state one run owns: what lasts from one door to the next and the state
# that evolves in between, and nothing else. The log and the trace are fixed by
# the constructing entry point. Four fields evolve: the attached recording, the
# termination record the loop's tail writes once, and the trajectory's two
# counters, which the door sets as it builds the run and the loop advances
# (D-317). `init!`, `restore!` and `replay!` construct one and rebind `sim.run`;
# nothing else rebinds it. A change of mode is a *write* to the run, not a
# change of run: `live!`, and the flip at a recording's end, both clear `feed`
# (D-218, D-260).
#
# The input mode is read, never stored: `mode(sim)` is `:replay` while a feed is
# attached and `:live` otherwise, so the two can never disagree. The trace is
# `nothing` under §11.5's kill switch, which is where that switch now rides.
#
# The origin and the stop policy are not fields here (D-260). The clock holds
# `t₀`, which `init!` sets and a checkpoint carries; the policy is the advance's
# argument, carried from the call to the record's assembly and dropped there.
#
# A `Simulation` is built with a placeholder run, an empty log, no trace, no
# feed and no termination. It carries no configuration: the recording keywords
# are the doors' (D-261).
"""
    Run

The state of one run: its [log](@ref g-log), its [trace](@ref g-trace), its
outcome and its two counters.

A simulation's current run is `sim.run`, and [`closed`](@ref) takes it.
[`init!`](@ref), [`overlay!`](@ref), [`restore!`](@ref) and [`replay!`](@ref)
each replace it with a fresh one, and nothing else does. A simulation starts
with an empty run, so every read finds one, and [`lifecycle`](@ref) says
whether that run ever started.

The run's contents are read through the simulation. [`logged`](@ref) returns
the log. [`trace`](@ref) returns a copy of the trace, and [`termination`](@ref)
the record of how the run ended. [`mode`](@ref) says whether a recording is
attached. The two counters are the [frame](@ref g-frame) index and the
[boundary](@ref g-boundary) ordinal, which [`checkpoint`](@ref) returns beside
the model's state.
"""
mutable struct Run
    const log::SnapshotLog                        # §11.2's retained snapshots
    const trace::Union{Nothing,Trace}             # §11.5's recording, `nothing` under the switch
    feed::Union{Nothing,ReplayFeed}               # the attached recording: the mode's one source
    termination::Union{Nothing,TerminationRecord}   # the tail's one write (§13.5)
    frame::Int                                    # the frame index, completed frames since `t₀`
    boundary::Int    # the published-boundary ordinal (§12.3, D-230); boundary zero = 0
end

# Design: §12.6, §13.5, Appendix B.
"""
    closed(run::Run) -> Bool

Return `true` once the run has ended and its
[termination record](@ref g-termination-record) is written.

`sim.run` holds the state of the current run: its [log](@ref g-log), its
[trace](@ref g-trace) and its outcome. `closed(sim.run)` answers whether the run
itself is over, while [`lifecycle`](@ref) answers for the simulation. For why it
ended, see [`termination`](@ref).
"""
closed(run::Run) = run.termination !== nothing

# Design: §9.2, §11.2, §11.3, §12.1, §12.3, §12.4, §12.6, §14.3, D-255, D-256,
# D-260, D-317.
# The four things a simulation is; every other value belongs to one of them.
# `model` carries the deployment and the nominal executor (§9.2, D-317), and the
# build is held once, through `sim.model.deployment.build`, the schema authority
# a condition resolves against (§14.3). `plane` is the §11.3 roster, the harness
# and loop writers and §11.2's published holder. `control` is §12.1's stop word,
# pause flag and two knobs, §12.4's sticky status and join cap, and §12.3's wait
# (devices.jl). `run` is §12.6's run state, the one field a door rebinds (D-255,
# D-260).
"""
    Simulation{E}

The runtime that drives a `Model{Float64}`, exchanges data with its
[devices](@ref g-device) and records its current run.

A simulation holds four values, each a field.

- `model`: the [`Model`](@ref) it runs, with its deployment and its build. `E`
  is the type of the model's compiled [executor](@ref g-executor).
- `plane`: the state through which the loop and the devices exchange data. It
  holds the [roster](@ref g-roster) and the paths that write the model's inputs.
  It also holds the latest [snapshot](@ref g-snapshot).
- `control`: the [control plane](@ref g-control-plane). [`pause!`](@ref),
  [`resume!`](@ref), [`pace!`](@ref), [`margin!`](@ref) and [`stop!`](@ref)
  write it from any task.
- `run`: the current run, with its [log](@ref g-log), its [trace](@ref g-trace)
  and its outcome. Only [`init!`](@ref), [`overlay!`](@ref), [`restore!`](@ref)
  and [`replay!`](@ref) replace it, each with a fresh one.
"""
mutable struct Simulation{E}
    const model::Model{Float64,E}
    const plane::DataPlane
    const control::Control
    run::Run
end

# Design: §9.2, §9.4, §12.4, §12.6, §13.5, Appendix B, D-198, D-255, D-256,
# D-260, D-261, D-317, D-318.
# Only the nominal model runs, since the `Float64` activation is the only one
# that runs in real time (§9.4); a model at any other scalar is a service's
# scratch, stepped frame by frame with no ticks and no events. The three other
# forms are defined as the compositions through a `Float64` model. Entry
# compilation lives behind the deployment because `Δt`, `D` and `Φ` are entry
# data, and one `Build` backs many deployments. `join_timeout` defaults to 5,
# generous for GUI teardown and socket closes, short enough that an abandoned
# join reads as a diagnosed timeout rather than a hang (D-198). It is the one
# operational keyword: never trajectory-determining, because the trajectory has
# ended at the final snapshot before any join begins, yet not a view policy
# either; it tunes the tail's wall-clock patience, nothing more. §13.5's
# termination policy is declared per advance and is no keyword here (D-255):
# each advance builds and validates the `StopPolicy` it passes to the loop
# (D-260). The recording keywords configure the run's log and trace, which the
# doors build, so the doors take them (§12.6, Appendix B, D-261).
"""
    Simulation(model::Model{Float64}; join_timeout = 5.0) -> Simulation
    Simulation(deployment::Deployment; join_timeout = 5.0,
               chunk_size = 16) -> Simulation
    Simulation(build::Build; h, N_base = nothing, Δt_base = nothing,
               algorithm = RK4, firing_budget = 4, localization_tol = 1e-6,
               localization_budget = 8, kw...) -> Simulation
    Simulation(root::AbstractComponent; kw...) -> Simulation

Construct a simulation around a `Model{Float64}`, with no
[device](@ref g-device) attached and an empty run.

The simulation also owns a fresh [control plane](@ref g-control-plane). A
simulation claims its model once and never shares it. A model at any other
scalar type is a `MethodError` here. A model already claimed by a simulation, or
whose status is not `:built`, is refused as `ArgumentInvalid` before anything is
allocated.

The other three forms compose through a `Float64` model.
`Simulation(deployment; join_timeout, chunk_size)` is
`Simulation(Model(deployment; chunk_size); join_timeout)`.
`Simulation(build; kw...)` is
`Simulation(Deployment(build; grid keywords...); other keywords...)`, and
`Simulation(root; kw...)` calls [`build`](@ref) first. The grid, algorithm and
event keywords are [`Deployment`](@ref)'s, documented and refused as
`DeploymentInvalid` there, and `chunk_size` is [`Model`](@ref)'s. `h` is
required, as for [`Deployment`](@ref).

# Keywords

- `join_timeout`: the limit, in seconds of wall clock, on joining the device
  tasks when a run shuts down. A positive real, refused as `ArgumentInvalid`
  otherwise. It never changes the trajectory.

The [stop policy](@ref g-stop-policy) and the recording are not configured here.
`t_end` and `ignore_stop_requests` are keywords of each advance, [`run!`](@ref),
[`replay!`](@ref) and [`step!`](@ref). `trace`, `log`, `log_every` and `log_max`
are keywords of the calls that open a run, [`init!`](@ref), [`overlay!`](@ref),
[`restore!`](@ref) and [`replay!`](@ref).
"""
function Simulation(model::Model{Float64,E}; join_timeout = 5.0) where {E}
    # This call's own keyword is not a deployment parameter, so it is an
    # `ArgumentInvalid` (D-256, Appendix C), collected as the call's one throw
    # (§9.1, D-229). The stop policy and the recording keywords are not among
    # them (D-255, D-261). The model's two refusals join them, a status other
    # than `:built` and a claim already taken. The claim itself is a
    # compare-and-swap after the collection, so a race lost there throws
    # `:claimed` alone, and nothing is allocated before it succeeds (§9.2, D-318).
    diags = Diagnostic[]
    join_timeout isa Real && join_timeout > 0 ||
        push!(diags, ArgumentInvalid(call = :Simulation, reason = :range,
                                     argument = :join_timeout, value = join_timeout))
    model_status = @atomic :acquire model.status
    model_status === :built ||
        push!(diags, ArgumentInvalid(call = :Simulation, reason = :not_built,
                                     argument = :model, value = model_status))
    (@atomic :acquire model.claimed) &&
        push!(diags, ArgumentInvalid(call = :Simulation, reason = :claimed, argument = :model))
    isempty(diags) || throw(DiagnosticError(diags))
    (@atomicreplace model.claimed false => true).success ||
        throw(DiagnosticError(ArgumentInvalid(call = :Simulation, reason = :claimed,
                                              argument = :model)))
    # §12.6's placeholder run (D-255, D-261): an empty log at the defaults that
    # nothing reads and no trace, so every accessor has a run to read. It
    # carries no configuration; the first door builds the run that records.
    run = Run(SnapshotLog(true, 1, typemax(Int)), nothing, nothing, nothing, 0, 0)
    Simulation{E}(model, DataPlane(model.exec.act.layout),
                  Control(Float64(join_timeout)), run)
end

# The three sugar forms, each *defined as* the composition through a `Float64`
# model (§9.2, D-254, D-317): every existing call site deploys and materializes
# in one call, and nothing in the artifact is lost by composing.
Simulation(deployment::Deployment; join_timeout = 5.0, chunk_size = 16) =
    Simulation(Model(deployment; chunk_size); join_timeout)
Simulation(build::Build; h = nothing, N_base = nothing,
           Δt_base = nothing, algorithm = RK4, firing_budget = 4,
           localization_tol = 1e-6, localization_budget = 8, kw...) =
    Simulation(Deployment(build; h, N_base, Δt_base, algorithm, firing_budget,
                          localization_tol, localization_budget); kw...)
Simulation(root::AbstractComponent; kw...) = Simulation(build(root); kw...)

warnings(sim::Simulation) = warnings(sim.model)

# §13.5's clock bound, validated identically at the three binding sites, and an
# `ArgumentInvalid` at each: `t_end` is a keyword of the advance, never a
# deployment parameter (D-255, D-256). `call` is the site that named it, and
# the throw is fail-fast — an advance is one call, so the bound refuses before
# the ignored requesters are looked at. `Inf` is a value, not an absence: it is the
# default every advance states, and `_frames_to` maps it onto the frame loop's
# unbounded budget.
_t_bound(t_end, call::Symbol) = (t_end isa Real && t_end ≥ 0) ? Float64(t_end) :
    throw(DiagnosticError(ArgumentInvalid(call = call, reason = :range,
                                          argument = :t_end, value = t_end)))

# §12.1's two knobs (D-269), validated identically at the four calls that take
# them, `run!`, `replay!`, `pace!` and `margin!`: the pace a positive real and
# the margin a non-negative one, `Inf` admitted by both.
_pace_value(p, call::Symbol) = (p isa Real && p > 0) ? Float64(p) :
    throw(DiagnosticError(ArgumentInvalid(call = call, reason = :range,
                                          argument = :pace, value = p)))
_margin_value(value, call::Symbol) = (value isa Real && value ≥ 0) ? Float64(value) :
    throw(DiagnosticError(ArgumentInvalid(call = call, reason = :range,
                                          argument = :margin, value = value)))

_t_end_frame(sim::Simulation, t_end::Float64) =
    _frames_to(t_end, sim.model.exec.clock.t₀, sim.model.deployment.h)

# §13.5's ignore-list validation and compilation, run identically at the three
# binding sites — `run!`, `replay!` and `step!` (§12.7, D-316): `:all` expands
# to every requester path, and any other value is an iterable of component
# paths, each naming a requester on the roster. `site` is the one the refusal
# names (D-249). Duplicates collapse, in the order given. The mask has one entry
# per requester, `true` where its path is ignored. The pass records into the
# list it is given and always returns the pair.
function _ignored_requests(layout::Layout, ignore_stop_requests, diags::Vector{Diagnostic};
                           site::Symbol)
    candidates = unique!([requester.path for requester in layout.requesters])   # roster order
    ignored = String[]
    if ignore_stop_requests === :all
        append!(ignored, candidates)
    else
        for requested in ignore_stop_requests
            requester_path = string(requested)
            if !(requester_path in candidates)
                push!(diags, StopRequestInvalid(path = requester_path, site = site,
                                                candidates = candidates))
                continue
            end
            requester_path in ignored || push!(ignored, requester_path)
        end
    end
    (ignored, Bool[requester.path in ignored for requester in layout.requesters])
end

# Each advance declares its own ignore list in a call of its own, so a fresh
# list thrown here is that call's one barrier (§13.1, D-229).
function _ignored_requests(layout::Layout, ignore_stop_requests; site::Symbol)
    diags = Diagnostic[]
    r = _ignored_requests(layout, ignore_stop_requests, diags; site)
    isempty(diags) || throw(DiagnosticError(diags))
    r
end

# §13.5's one binder, shared by `run!`, `replay!` and `step!` (D-255): the
# advance's declared pair validated into the immutable value the call then
# carries as its argument (D-260), and the ignore mask returned beside it as
# the loop's second argument (D-261, D-316). The bound refuses first —
# `_t_bound` is fail-fast, and the paths are a collecting pass behind it — so a
# call naming both a bad bound and a bad path is refused for the bound.
function _bind_policy(sim::Simulation, t_end, ignore_stop_requests, site::Symbol)
    bound = _t_bound(t_end, site)
    (ignored, ignore_mask) = _ignored_requests(sim.model.exec.act.layout, ignore_stop_requests; site)
    (StopPolicy(bound, ignored), ignore_mask)
end

# Design: §11.3, §12.6, §13.4, §13.6, Appendix B, D-223, D-317.
# `:built` is the cold state (§13.4, D-223). Derived, never stored (D-317): a
# set running flag reads `:running`; with it clear, the model's `:built` reads
# `:built`, its `:inconsistent` reads `:errored`, and its `:consistent` reads
# `:initialized` while the run is open and `:stopped` once it is closed. The
# flag and the status are acquire loads, and every writer stores the run's
# termination and the model's status before it clears the flag.
"""
    lifecycle(sim::Simulation) -> Symbol

Return the simulation's lifecycle state, one of five symbols.

The state is derived at each read and never stored, and any task may read it.
The five states are these.

- `:built`: the [buffers](@ref g-buffer) are allocated and
  [boundary zero](@ref g-boundary-zero) has not completed. A throw inside
  boundary zero returns the simulation here.
- `:initialized`: consistent at a [boundary](@ref g-boundary) and ready to
  advance. [`init!`](@ref) establishes it, and a completed [`step!`](@ref)
  returns to it.
- `:running`: [`run!`](@ref) or `step!` holds the loop. The
  [roster](@ref g-roster) is frozen with it.
- `:stopped`: the run has ended, and its
  [termination record](@ref g-termination-record) is written.
- `:errored`: a failure inside the loop left the model's state inconsistent.

`:stopped` and `:errored` are the two terminal states. [`mode`](@ref) reads the
[input mode](@ref g-input-mode) beside it.
"""
function lifecycle(sim::Simulation)
    (@atomic :acquire sim.control.running) && return :running
    model_status = @atomic :acquire sim.model.status
    model_status === :built && return :built
    model_status === :inconsistent && return :errored
    closed(sim.run) ? :stopped : :initialized
end

# Design: §12.6, §12.7, D-218, D-219, D-260.
# The mode is read off the run's `feed`, never stored: the recording is attached
# for exactly as long as the mode is `:replay`, so one field states both and the
# two cannot drift apart. State and mode are orthogonal: the state says whether
# the simulation may advance, the mode says what it will advance on.
"""
    mode(sim::Simulation) -> Symbol

Return the [input mode](@ref g-input-mode), `:live` or `:replay`.

Under `:live` they come from the [staging cells](@ref g-staging-cell), which
[`stage!`](@ref) and the [devices](@ref g-device) write. Under `:replay` they
come from the recording that [`replay!`](@ref) attached. The mode is independent
of the lifecycle state (`:built`, `:initialized`, `:running`, `:stopped` or
`:errored`), which says whether the simulation may advance at all.

While the mode is `:replay`, the recording bounds every advance: no advance runs
past its last [frame](@ref g-frame), and the mode returns to `:live` when an
advance halts there. Every call that opens a run resets the mode with the
trajectory: [`init!`](@ref), [`overlay!`](@ref), [`restore!`](@ref) and a fresh
`replay!`. [`live!`](@ref) changes it alone, and only while the simulation may
advance. In a terminal state the mode does not matter, since nothing advances
until a call opens a new run.
"""
mode(sim::Simulation) = sim.run.feed === nothing ? :live : :replay

# Design: §12.6, §13.5, D-203, D-255.
# The record is the run's outcome. No lifecycle gate is needed for the
# `nothing`: `init!`, `restore!` and `replay!` each build a fresh run, so no
# record of a previous one is reachable here.
"""
    termination(sim::Simulation) -> Union{Nothing,TerminationRecord}

Return the current run's [termination record](@ref g-termination-record), or
`nothing` while the run is open.

The termination record is a [`TerminationRecord`](@ref), and its `source` field
holds the [`TerminationSource`](@ref) that ended the run.

The record is written once, as the run ends, and `closed(sim.run)` turns `true`
with it. Each call that opens a run starts it without a record, so a record of
an earlier run is never returned.
"""
termination(sim::Simulation) = sim.run.termination

# The record's assembly (§13.5, D-203), once per advance entry in its
# outermost `finally`, after the sweep has the residue in hand. `t` is the
# final snapshot's boundary time: both entries
# refuse a `built` simulation and every door publishes, so the snapshot
# exists (D-233). `policy` is this advance's, arriving as the argument the call
# built — the terminating one, the one that explains the stop, and this is
# where it stops travelling (D-255, D-260).
_record(sim::Simulation, policy::StopPolicy, source::TerminationSource,
        residue::Vector{ResidueRecord}) =
    TerminationRecord(latest(sim).t, policy, source, residue)

# §13.5's sampling read, after every publication: the `StopFlag` buffer of the
# just-published snapshot, scanned in roster order, the first honoured request
# holding wins and its requester is returned (D-316). `ignore_mask` is
# index-aligned with the roster and so with the buffer, by `_bind_policy`
# (D-261). The roster is read on a hit only.
function _stop_hit(sim::Simulation, ignore_mask::Vector{Bool})
    all(ignore_mask) && return nothing          # none honoured, the empty roster included
    # asserted, since the plane's type does not fix the snapshot's
    snapshot = latest(sim)::Snapshot{Float64,typeof(sim.model.exec.store)}
    buffer = getfield(snapshot.store.stores, STOP_FLAG_KEY).buffer
    for i in eachindex(ignore_mask)
        !ignore_mask[i] && buffer[i] === STOP_REQUESTED &&
            return sim.model.exec.act.layout.requesters[i]
    end
    nothing
end

# The shared entry gate of the two advance entries (§12.6), and of `live!`
# beside them (D-219): only `:initialized` admits one, and each refusal names
# its own way out — the `:running` sentence discriminating on the op, since
# `live!` meets a running loop as a stopped-sim operation.
function _assert_advanceable(sim::Simulation, op::Symbol)
    lifecycle_state = lifecycle(sim)
    lifecycle_state === :initialized && return nothing
    lifecycle_state === :built && throw(DiagnosticError(
        MissingInit(op = op, status = lifecycle_state)))
    lifecycle_state === :running && throw(DiagnosticError(
        ServiceLifecycle(op = op, status = :running, legal = collect(ADVANCE_LEGAL))))
    lifecycle_state === :stopped && throw(DiagnosticError(
        ServiceLifecycle(op = op, status = :stopped, legal = collect(ADVANCE_LEGAL))))
    throw(DiagnosticError(ServiceLifecycle(op = op, status = :errored, legal = collect(ADVANCE_LEGAL))))
end

"""
The §11.3 freeze, keyed on the simulation's lifecycle (§12.6), as two gates.
The readers' gate, `assert_stopped`, refuses exactly while `run!` or `step!`
holds the simulation `:running` — which spans the tail, so a roster change
cannot race the joins — and admits every other state, `:errored` included:
post-mortem inspection of a terminally stopped simulation is reading (§13.6).
The roster's gate, `assert_configurable`, adds `:errored` to the refusals
(D-232): a roster change configures the next run, and an errored simulation
has none. Both take the simulation and read its `lifecycle` (D-317).
"""
assert_stopped(sim::Simulation, op::Symbol) =
    lifecycle(sim) === :running ?
    throw(DiagnosticError(ServiceLifecycle(op = op, status = :running,
                                           legal = collect(READER_LEGAL)))) : nothing

function assert_configurable(sim::Simulation, op::Symbol)
    lifecycle_state = lifecycle(sim)
    lifecycle_state === :running && throw(DiagnosticError(ServiceLifecycle(
        op = op, status = :running, legal = collect(STOPPED_SIM_LEGAL))))
    lifecycle_state === :errored && throw(DiagnosticError(ServiceLifecycle(
        op = op, status = :errored, legal = collect(STOPPED_SIM_LEGAL))))
    nothing
end

# The model's doors on the simulation, each forwarded to its model (model.jl, D-317).
phase_bodies(sim::Simulation) = phase_bodies(sim.model)
apply!(sim::Simulation, plan::ConditionPlan) = _apply_plan!(sim.model, plan)
@inline evaluate!(sim::Simulation) = evaluate!(sim.model)
@inline boundary!(sim::Simulation, tick::Int) = boundary!(sim.model, tick)
@inline offtick_boundary!(sim::Simulation) = offtick_boundary!(sim.model)
@inline boundary_zero!(sim::Simulation) = boundary_zero!(sim.model)
@inline integrate!(sim::Simulation, h) = integrate!(sim.model, h)

# What every door opens wholesale beside the state (§12.6): the §11.8 accounts
# reset, every staged batch dropped so none survives into the trajectory it
# predates (§11.4), and the stop word cleared. `restore!` and `replay!` take
# this alone, the clock and the priors coming with the checkpoint (D-274). The
# log, the trace, the feed and the termination record are *not* cleared here:
# each door builds a fresh `Run` behind this call, and a fresh run is all four at
# once (D-255). The diagnostic *cells* are deliberately untouched: a rejection
# recorded while stopped is a fact about what happened.
function _reset_periphery!(sim::Simulation)
    _reset_accounts!(sim, sim.plane.roster)   # a new trajectory opens a fresh account (§11.8)
    for entry in sim.plane.roster     # §12.6: no staged batch survives into the
        @atomic _handle(entry).writer.cell.pending = nothing   # trajectory it predates
    end
    @atomic sim.plane.harness.cell.pending = nothing
    @atomic sim.control.stop_issuer = nothing
    nothing
end

# The four recording keywords, and `replay!`'s `restore` beside them, validated
# as the door's own `ArgumentInvalid`s and collected into one throw (§9.1,
# D-229, D-261). Called after the door's lifecycle gate and before its first
# write, so a refused keyword writes nothing.
function _check_recording(call::Symbol, trace_switch, log_switch, log_every, log_max,
                          restore = true)
    diags = Diagnostic[]
    _arg(argument, v) = push!(diags, ArgumentInvalid(call = call, reason = :range,
                                                     argument = argument, value = v))
    trace_switch isa Bool || _arg(:trace, trace_switch)
    log_switch isa Bool || _arg(:log, log_switch)
    log_every isa Integer && log_every ≥ 1 || _arg(:log_every, log_every)
    (log_max isa Integer && log_max ≥ 1) || log_max === Inf || _arg(:log_max, log_max)
    restore isa Bool || _arg(:restore, restore)
    isempty(diags) || throw(DiagnosticError(diags))
    nothing
end

# The run one door opens (§12.6, D-255, D-260, D-261): the door's four recording
# keywords configure it, and nothing is read off the run the last door left,
# so the fresh run gets a log and a trace of its own rather than cleared ones
# and the next door may declare otherwise. Under the switch the trace is
# `nothing`, nothing is recorded and `trace(sim)` refuses for the switch.
# `header` is the checkpoint the run opens from, `nothing` from `init!`, which
# writes it after boundary zero's first publication (D-274). `frame` and
# `boundary` are the run's two counters as the door sets them, zero from `init!`
# and the checkpoint's from `restore!` and `replay!` (D-317). The trace's length
# starts at the frame index, so its records carry the trajectory's own frame
# ordinals. `feed` goes in at construction: `nothing` from `init!` and
# `restore!`, the compiled recording from `replay!`. `_install_writers!` then
# compiles the drain's thunks against the new trace for the trajectory about to
# open.
function _open_run!(sim::Simulation, header, schemas, feed, frame::Int, boundary::Int,
                    trace_switch::Bool, log_switch::Bool, log_every::Int, log_max)
    trc = trace_switch ? Trace(header, schemas, TraceBatch[], frame) : nothing
    sim.run = Run(SnapshotLog(log_switch, log_every,
                                 log_max === Inf ? typemax(Int) : Int(log_max)),
                     trc, feed, nothing, frame, boundary)
    _install_writers!(sim.plane, sim.model.exec.store, trc)
    nothing
end

# Design: §10.5, §10.6, §11.2, §11.4, §11.5, §11.8, §12.6, §12.7, §13.4, §13.5,
# §13.6, §14.1, §14.3, §14.5, §14.6, Appendix B, D-029, D-038, D-063, D-205,
# D-218, D-223, D-255, D-260, D-261, D-274.
# The condition is §14.1's overlay, and its base is always the declared
# defaults: `init!` re-establishes the three state homes, `xbuf` and the `s`/`m`
# stores, from `x_init`/`s_init`/`m_init` before applying anything (D-063).
# Nothing re-seeds the cells, and nothing needs to: boundary zero derives every
# one of them (D-205). The order is resolve (§14.3), then root-input totality
# against the build's root input faces (§14.6), then the writes; the services
# path contains no call to `probe_value`. `t0` is a service argument, never a
# condition entry, since time is not a store of any component (§14.5). It is
# held as a `Float64` origin on the clock (D-260) while the clock's `t` stays in
# the model's scalar, so a `Dual` model takes `t0 = 0.25` like any other.
# Boundary zero is an ordinary boundary with an empty integrate (§10.5, §14.5),
# run with the sweep's one amendment: every discrete output stage publishes, due
# or not (D-205, `boundary_zero!`), while the `s_update` calls keep the gate at
# index 0, which admits exactly the components with `Φ = 0`, implemented by
# nothing. It establishes every event prior as not-holding (§10.6), so a firing
# at `t₀` is derived, not asserted, and a re-run resets all three registers from
# scratch. A re-run is a new trajectory and therefore a new `Run` (§12.6,
# D-255): the log and the trace are fresh objects rather than cleared ones, and
# the log's boundary zero lands as a first endpoint of its own (§11.2). The
# trace header is the checkpoint taken last (§11.5, D-274). It holds the state
# boundary zero left, the resolved stores and the root-input cells as values
# rather than the authored overlay (D-038), and replay restores it rather than
# re-running boundary zero (§12.7). The input trace is on by default because it
# is primary data and the log derived: given the initial state and the trace the
# log is recomputable, never the reverse, and an untraced interactive session is
# unreproducible permanently (D-029). The switch covers the memory-constrained
# marathon session, and nothing else: no sampling, no rolling window.
# `log_max`'s 65536 = 2¹⁶ is about 22 minutes at 50 Hz and full density before
# anything is dropped. The four keywords are view policies: recording reads the
# drained batch, and retention is reference bookkeeping over what publication
# already built. They configure the run this call builds, and `restore!` and
# `replay!` take the same four (§12.6, Appendix B, D-261); they validate under
# `ArgumentInvalid` at `call = :init!`, after the lifecycle gate and before any
# write. `init!` is §12.6's door into `initialized` from an authored condition.
# `restore!` and `replay!` (§12.7) stand in the same lifecycle position with a
# checkpoint in the condition's place (D-274), and share the periphery's opening
# with it. The §13.5 termination record and the input mode's return to `:live`
# (§12.6, D-218) are the new run itself, and no stale batch survives to clobber
# the boundary zero it predates (§11.4). The diagnostic cells are deliberately
# not cleared: a rejection recorded while stopped is a fact about what happened,
# not a stale input (§11.8). An `errored` simulation is terminally stopped
# (§13.6): reproduction is trace replay, not resurrection. A throw inside
# boundary zero leaves no checkpoint (§13.4, D-223, D-274).
"""
    init!(sim::Simulation, condition = set(); t0::Real = 0.0, trace = true,
          log = true, log_every = 1, log_max = 65536) -> Nothing

Initialize the simulation from a [condition](@ref g-condition) on the declared
defaults, and run [boundary zero](@ref g-boundary-zero) at `t0`.

`init!` resets the state to the declared defaults, applies the condition's
overrides, sets the clock to `t0` and runs boundary zero. The condition is a
sparse overlay addressed by [component](@ref g-component) path, built with
[`set`](@ref) and its combinators. [Root inputs](@ref g-root-input) have no
declared default, so the condition must give every one of them a value.

Boundary zero derives every output's value from the state. Every event starts as
not [holding](@ref g-edge-semantics), so an event that already holds in the
initialized state fires at `t0`. Calling `init!` again resets the state and the
events from scratch, and such an event fires again at the new `t0`.

`init!` opens a fresh run, with a new [log](@ref g-log) and a new
[trace](@ref g-trace) rather than cleared ones, and the
[input mode](@ref g-input-mode) back at `:live`. It clears the
[stop word](@ref g-stop-word). It also drops every [batch](@ref g-batch) still
waiting, so nothing staged earlier reaches the new trajectory. Stage after
`init!` and before [`run!`](@ref), and the batch waits for the first
[frame](@ref g-frame). The [diagnostic cells](@ref g-diagnostic-cell) are not
cleared. A rejection recorded while stopped therefore still reaches the status
of the next run's first [snapshot](@ref g-snapshot). The
[trace header](@ref g-trace-header) is the [checkpoint](@ref g-checkpoint) taken
after boundary zero publishes, and [`replay!`](@ref) restores it rather than
running boundary zero again.

`init!` is the only call that runs boundary zero, and a completed boundary zero
is what [`run!`](@ref) and [`step!`](@ref) need. [`restore!`](@ref) and
[`replay!`](@ref) are the alternatives, which start from a checkpoint in the
condition's place. To start again from a saved state, call
[`checkpoint`](@ref), then `restore!`, then `run!`.

# Keywords

- `t0`: the start time, any real, held as a `Float64` origin. Time is a keyword,
  never a condition [entry](@ref g-entry).
- `trace`: record the input trace of this run. Turn it off only to save memory
  in a long session, since an untraced session can never be reproduced.
- `log`: keep the snapshot log of this run.
- `log_every`: keep every `log_every`-th published [boundary](@ref g-boundary)
  in the log, an integer of at least 1.
- `log_max`: the most snapshots the log keeps between its first and latest, an
  integer of at least 1, or `Inf` for no bound. The first and the latest
  snapshots are always kept, and at the bound the log thins its middle by
  doubling its stride.

The four recording keywords never change the trajectory: two runs that differ
only in them produce bitwise-identical trajectories. Each configures the run
this call opens, and the next run follows whatever its own call declares.
[`overlay!`](@ref), [`restore!`](@ref) and [`replay!`](@ref) take the same four.

`init!` is refused as `ServiceLifecycle` while the simulation is `running`, and
once it is `errored`. A recording keyword out of range is refused as
`ArgumentInvalid`, a condition that does not resolve against the build as
`ConditionResolution`, and a root input the condition leaves without a value as
`UninitializedInputs`. Every refusal comes before any write, so a refused
`init!` leaves the simulation exactly as it was. A throw inside boundary zero
arrives as a `StepError` with pointer 0 and leaves the simulation `built`, with
no trace, and `init!`, `restore!` and `replay!` legal again. `init!` under the
same condition reproduces it.
"""
function init!(sim::Simulation, condition = set(); t0::Real = 0.0, trace = true,
               log = true, log_every = 1, log_max = 65536)
    lifecycle_state = lifecycle(sim)
    lifecycle_state === :running && throw(DiagnosticError(
        ServiceLifecycle(op = :init!, status = :running, legal = collect(STOPPED_SIM_LEGAL))))
    lifecycle_state === :errored && throw(DiagnosticError(
        ServiceLifecycle(op = :init!, status = :errored, legal = collect(STOPPED_SIM_LEGAL))))
    _check_recording(:init!, trace, log, log_every, log_max)   # the run's keywords (D-261)
    plan = resolve_condition(condition, sim.model.deployment.build, Float64)   # both refusals precede every write
    assert_total(plan, sim.model.deployment.build.structure, :init!)   # (§14.6): all-or-nothing
    _reset_periphery!(sim)
    _open_run!(sim, nothing, Pair{String,Vector{Symbol}}[], nothing, 0, 0, trace, log,
               Int(log_every), log_max)   # the fresh run, its header not yet taken (§12.6)
    # The model's door does the writes and boundary zero, which publishes
    # through `settled!`; nothing reads its return there, so the mask is empty
    # (§11.2, §14.5, D-317).
    init!(sim.model, plan; t0, hooks = LoopHooks(sim, sim.plane.roster, nothing, Bool[]))
    # §11.5's header: the checkpoint at the end of boundary zero, so a throw
    # inside it leaves no header and no trace to hand back (D-274)
    trc = sim.run.trace
    trc === nothing ||
        (trc.header = Checkpoint(checkpoint(sim.model), sim.run.frame, sim.run.boundary))
    nothing
end

# Design: §12.4, §12.6, D-273, D-274, D-319, D-429.
# The state is `checkpoint(sim.model)`, wrapped with the run's two counters. A
# `t*` stop abandons the frame's remainder with the clock inside the frame, and
# the loop integrates whole frames, so a checkpoint there would have no next
# frame to continue on. A frame an interrupt from model code abandoned published
# nothing (§12.4).
"""
    checkpoint(sim::Simulation) -> Checkpoint

Return the simulation's state at the [frame top](@ref g-frame) its clock rests
on, with the run's two counters.

A [checkpoint](@ref g-checkpoint) holds the state [buffer](@ref g-buffer), the
`s` and `m` [stores](@ref g-store) and the whole
[signal table](@ref g-signal-table). The checkpoint also holds the event
[priors](@ref g-prior) and the clock's `t` and `t₀`. Last, it holds the
[fingerprint](@ref g-fingerprint). Beside it are the run's two counters, its
frame index and its [boundary](@ref g-boundary) ordinal. [`restore!`](@ref) puts
it back. A checkpoint is not a [condition](@ref g-condition) and enters no
condition expression; to write a condition onto a stopped run, use
[`overlay!`](@ref).

`checkpoint` is legal while the simulation is `initialized` or `stopped`, its
stores committed and consistent, and refused as `ServiceLifecycle` while it is
`built`, `running` or `errored`. It is refused as `CheckpointMidFrame` with the
clock off a frame top, or with that frame top unpublished. A stop at a
[localized](@ref g-localized) event time [`t*`](@ref g-t) leaves the clock
inside the frame. A frame an [interrupt](@ref g-operator-interrupt) from model
code abandoned may leave the stores mid-boundary, whatever the clock reads.
"""
function checkpoint(sim::Simulation)
    _assert_at_rest(sim, :checkpoint)
    Checkpoint(checkpoint(sim.model), sim.run.frame, sim.run.boundary)
end

# The rest a `checkpoint` reads and an `overlay!` writes on (§12.6, D-274,
# D-429): a stopped-sim state, `initialized` or `stopped`, with the clock on a
# frame top and that top published. A frame top is exactly the time the loop
# writes there, `_grid_time` in the clock's scalar, whatever the origin; a `t*`
# stop leaves the clock short of it. At rest the latest snapshot is that top's,
# which an abandoned frame never published, a `t*` boundary it did publish
# included.
function _assert_at_rest(sim::Simulation, op::Symbol)
    lifecycle_state = lifecycle(sim)
    lifecycle_state in (:initialized, :stopped) || throw(DiagnosticError(ServiceLifecycle(
        op = op, status = lifecycle_state, legal = [:initialized, :stopped])))
    clock = sim.model.exec.clock
    frame = sim.run.frame
    t_frame = _grid_time(sim.model, frame)
    published = latest(sim)
    clock.t == oftype(clock.t, t_frame) && published.frame == frame &&
        published.t == clock.t ||
        throw(DiagnosticError(CheckpointMidFrame(t = _seconds(clock.t), t_frame = t_frame,
                                                 frame = frame)))
    nothing
end

# Design: §12.6, D-223, D-261, D-273, D-429.
# §12.6's state what-if, the sibling of the input what-if, a restore followed by
# `stage!`. A door beside `init!`, `restore!` and `replay!`, handling the
# periphery as `restore!` does. The overlaid state settles through the model's
# `overlay!`: projection and the event phase to quiescence, with no discrete
# output stage and no `s_update` (D-273). The settling publishes under the
# stopped run's last ordinal, as `restore!` re-publishes.
"""
    overlay!(sim::Simulation, condition = set(); trace = true, log = true,
             log_every = 1, log_max = 65536) -> Nothing

Write a [condition](@ref g-condition) onto the simulation's state at rest, and
open a fresh run from the result.

The condition overwrites the [stores](@ref g-store) it names. Every other store,
the clock and the event [priors](@ref g-prior) are kept. The
[harmonic grid](@ref g-harmonic-grid) is kept too. A partial store entry merges
onto the current store, and [root-input](@ref g-root-input) entries are allowed,
with no need to cover every root input. The overlaid state then settles: the
[components](@ref g-component)' `x_projection` hooks run and events fire until
none is left to fire, but no discrete output stage and no `s_update` runs. An
overlaid discrete store is therefore the state of the component's next
[tick](@ref g-tick), and its held output stays until that tick. An event the
overlay moves into [holding](@ref g-edge-semantics) fires at once, before the
next integration step.

The settling publishes one [snapshot](@ref g-snapshot) at the stopped run's `t`.
The new run's [trace header](@ref g-trace-header) is the
[checkpoint](@ref g-checkpoint) taken after it, so [`replay!`](@ref) reproduces
the overlaid trajectory with no record of the overlay. To change the inputs
rather than the state, use [`restore!`](@ref) followed by [`stage!`](@ref).

Like `restore!`, `overlay!` drops every [batch](@ref g-batch) still waiting, so
nothing staged before it reaches the new run. It also clears the
[stop word](@ref g-stop-word).

The four recording keywords are [`init!`](@ref)'s, and configure the run this
call opens.

`overlay!` is legal where [`checkpoint`](@ref) is: the simulation `initialized`
or `stopped`, its clock on a published [frame top](@ref g-frame). Otherwise it
is refused as `ServiceLifecycle` or `CheckpointMidFrame`. A recording keyword
out of range is refused as `ArgumentInvalid`. The condition resolves before
anything is written, and one that does not resolve is refused as
`ConditionResolution`. A throw inside the settling arrives as a `StepError` with
host `:overlay`, and leaves the simulation `built` with no trace header, as a
failed [boundary zero](@ref g-boundary-zero) does.
"""
function overlay!(sim::Simulation, condition = set(); trace = true, log = true,
                  log_every = 1, log_max = 65536)
    _assert_at_rest(sim, :overlay!)
    _check_recording(:overlay!, trace, log, log_every, log_max)   # the run's keywords (D-261)
    plan = resolve_condition(condition, sim.model.deployment.build, Float64;
                             bases = _store_values(sim.model.exec))   # the refusals precede every write
    _reset_periphery!(sim)
    _open_run!(sim, nothing, Pair{String,Vector{Symbol}}[], nothing, sim.run.frame,
               sim.run.boundary, trace, log, Int(log_every), log_max)
    sim.run.boundary -= 1   # the settling re-publishes the stopped run's last ordinal
    overlay!(sim.model, plan; hooks = LoopHooks(sim, sim.plane.roster, nothing, Bool[]))
    # §11.5's header: the checkpoint after the settling, so a throw inside it
    # leaves no header and replay needs no knowledge of the overlay (D-429)
    trc = sim.run.trace
    trc === nothing ||
        (trc.header = Checkpoint(checkpoint(sim.model), sim.run.frame, sim.run.boundary))
    nothing
end

# The door body `restore!` and `replay!` share (§12.6, §12.7, D-274): first
# the periphery's opening, a fresh run with the checkpoint detached as its
# header, and the boundary ordinal stepped back; then the model's inner restore,
# which copies the checkpoint's state back, publishes one snapshot through the
# hooks and writes `:consistent` last. No boundary zero, no sweep, no guard, no
# update, no prior reset. A checkpoint is taken after the publication of its
# boundary, so its ordinal is one past that boundary's; the snapshot
# re-publishes it under the same ordinal, and the trajectory's ordinals
# continue as the original's did (§12.3, D-230). The counters come with the
# checkpoint into the run this opens (D-317). Nothing reads the hook's return,
# so the mask is empty.
function _enter_checkpoint!(sim::Simulation, cp::Checkpoint, schemas, feed,
                            trace_switch::Bool, log_switch::Bool, log_every::Int,
                            log_max)
    _reset_periphery!(sim)
    _open_run!(sim, trace_switch ? _detach(cp) : nothing, schemas, feed, cp.frame, cp.boundary,
               trace_switch, log_switch, log_every, log_max)
    sim.run.boundary -= 1
    _restore_state!(sim.model, cp.state; hooks = LoopHooks(sim, sim.plane.roster, nothing, Bool[]))
    nothing
end

# Design: §9.2, §12.3, §12.6, D-230, D-261, D-274, D-318, D-319.
# §12.6's warm restart, a door beside `init!` and `replay!`. The fingerprint is
# checked against this simulation as replay checks a trace's header, and the
# clock against its own grid as the model's door checks it. The model's inner
# restore copies the state back, publishes one snapshot and writes `:consistent`
# last. No boundary zero runs: no sweep, no guard, no update and no prior reset.
# `restore!(sim, model_state)` is the door a state prepared on a standalone
# model takes into a simulation (§9.2, D-319). Its grid check names the frame
# `k` the state's clock sits inside, read as `checkpoint(model)` reads it, and
# the run's ordinal reads 1 after the restored boundary. A state taken at
# another scalar is refused by dispatch.
"""
    restore!(sim::Simulation, cp::Checkpoint; trace = true, log = true,
             log_every = 1, log_max = 65536) -> Nothing
    restore!(sim::Simulation, model_state::ModelState{Float64}; trace = true,
             log = true, log_every = 1, log_max = 65536) -> Nothing

Restore a [checkpoint](@ref g-checkpoint) into the simulation, and open a fresh
run from it.

`restore!` starts again from a saved state: [`checkpoint`](@ref), then
`restore!`, then [`run!`](@ref). It drops every [batch](@ref g-batch) still
waiting. It opens a fresh run with the checkpoint as its
[trace header](@ref g-trace-header), and copies the state back. It then
publishes one [snapshot](@ref g-snapshot) at the checkpoint's `t`. No
[boundary zero](@ref g-boundary-zero) runs, so an event
[holding](@ref g-edge-semantics) at the checkpoint does not fire again. The
clock comes with the checkpoint, so the next [frame](@ref g-frame) is the
original's next frame and the [boundary](@ref g-boundary) ordinal continues the
original's count. The [input mode](@ref g-input-mode) returns to `:live`.

`restore!(sim, model_state)` takes a [`ModelState`](@ref) prepared on a
standalone [`Model`](@ref) into the simulation. It opens a fresh trajectory at
the frame the state's clock stands at. The restored boundary publishes under
ordinal 0, as boundary zero's does, since a standalone model published nothing
and there is no count to continue.

The four recording keywords are [`init!`](@ref)'s, and configure the run this
call opens.

`restore!` is legal where `init!` is: refused as `ServiceLifecycle` while
`running`, and once `errored`. A recording keyword out of range is refused as
`ArgumentInvalid`. A checkpoint whose [fingerprint](@ref g-fingerprint) or
deployment does not match this simulation is refused as `CheckpointMismatch`,
and one whose clock is off its own grid as `CheckpointMidFrame`, all collected
into one throw before any write. A `ModelState` taken at a scalar other than
`Float64` is refused as `CheckpointMismatch`.
"""
function restore!(sim::Simulation, cp::Checkpoint; trace = true, log = true,
                  log_every = 1, log_max = 65536)
    lifecycle_state = lifecycle(sim)
    lifecycle_state === :running && throw(DiagnosticError(
        ServiceLifecycle(op = :restore!, status = :running, legal = collect(STOPPED_SIM_LEGAL))))
    lifecycle_state === :errored && throw(DiagnosticError(
        ServiceLifecycle(op = :restore!, status = :errored, legal = collect(STOPPED_SIM_LEGAL))))
    _check_recording(:restore!, trace, log, log_every, log_max)   # the run's keywords (D-261)
    diags = Diagnostic[]
    _check_checkpoint!(diags, sim.model, cp.state)
    _check_grid!(diags, cp.state)
    isempty(diags) || throw(DiagnosticError(diags))
    _enter_checkpoint!(sim, cp, Pair{String,Vector{Symbol}}[], nothing, trace, log,
                       Int(log_every), log_max)
    nothing
end

function restore!(sim::Simulation, model_state::ModelState{Float64}; trace = true, log = true,
                  log_every = 1, log_max = 65536)
    lifecycle_state = lifecycle(sim)
    lifecycle_state === :running && throw(DiagnosticError(
        ServiceLifecycle(op = :restore!, status = :running, legal = collect(STOPPED_SIM_LEGAL))))
    lifecycle_state === :errored && throw(DiagnosticError(
        ServiceLifecycle(op = :restore!, status = :errored, legal = collect(STOPPED_SIM_LEGAL))))
    _check_recording(:restore!, trace, log, log_every, log_max)   # the run's keywords (D-261)
    diags = Diagnostic[]
    _check_checkpoint!(diags, sim.model, model_state)
    k = _check_grid!(diags, model_state)   # the frame the state's clock sits inside
    isempty(diags) || throw(DiagnosticError(diags))
    # a fresh trajectory at frame `k`, its restored boundary under ordinal 0
    _enter_checkpoint!(sim, Checkpoint(model_state, k, 1), Pair{String,Vector{Symbol}}[],
                       nothing, trace, log, Int(log_every), log_max)
    nothing
end

# A state taken on a model at another scalar (D-319).
restore!(::Simulation, ::ModelState{T}; kw...) where {T} =
    throw(DiagnosticError(CheckpointMismatch(what = :scalar, expected = T, found = Float64)))

# Design: §14.8, D-319.
# The trim service on a simulation, a stopped-sim service legal in `built`,
# `initialized` and `stopped`. It runs the model's solve.
"""
    trim!(sim::Simulation, problem::TrimProblem; baseline, t0::Real = 0.0,
          backend = LevenbergMarquardt()) -> TrimReport

Solve a trim problem on the simulation's model, and commit the solution through
`init!`.

`trim!` solves the [`TrimProblem`](@ref) on the simulation's [`Model`](@ref). A
solve that converges commits through `init!(sim, …)` at `t0`, so the commit
opens a fresh run and takes the [trace header](@ref g-trace-header) as
[`init!`](@ref) does. A solve that does not converge leaves the simulation as it
was, its lifecycle state included. The returned [`TrimReport`](@ref) says which
happened. The keywords mean what they mean on the model's method.

`trim!` is legal where `init!` is: refused as `ServiceLifecycle` while
`running`, and once `errored`. A second argument that is not a `TrimProblem` is
refused as `ArgumentInvalid`.
"""
function trim!(sim::Simulation, problem::TrimProblem; baseline,
               t0::Real = 0.0, backend = LevenbergMarquardt())
    lifecycle_state = lifecycle(sim)
    lifecycle_state === :running && throw(DiagnosticError(ServiceLifecycle(
        op = :trim!, status = :running, legal = collect(STOPPED_SIM_LEGAL))))
    lifecycle_state === :errored && throw(DiagnosticError(ServiceLifecycle(
        op = :trim!, status = :errored, legal = collect(STOPPED_SIM_LEGAL))))
    solved = _solve_problem(sim.model, problem; baseline, backend)
    _verdict!(sim.model, problem, baseline, solved,
              condition -> init!(sim, condition; t0 = Float64(t0)))
end

trim!(sim::Simulation, other; kw...) = trim!(sim.model, other; kw...)

# Design: §14, §14.10, D-319.
"""
    linearize(sim::Simulation, tap_set::Taps; about = nothing, t0 = nothing,
              width::Int = 8) -> Linearization

Return the linearization of the simulation's model at an operating point.

By default the operating point is `checkpoint(sim)`, the simulation's state at
the [frame top](@ref g-frame) its clock rests on. `about`, a
[condition](@ref g-condition) with `t0` beside it, places the operating point
anywhere else. The query runs the model's method over that point and writes
nothing on the simulation. The keywords mean what they mean on the model's
method.

The default form is legal where [`checkpoint`](@ref) is: refused as
`ServiceLifecycle` unless the simulation is `initialized` or `stopped`. It is
refused as `CheckpointMidFrame` with the clock off a frame top, or with that
frame top unpublished. The `about` form is legal where [`init!`](@ref) is. A
second argument that is not a tap set from [`taps`](@ref) is refused as
`ArgumentInvalid`, and so are a `width` below 1 and a `t0` without `about`.
"""
function linearize(sim::Simulation, tap_set::Taps; about = nothing,
                   t0 = nothing, width::Int = LINEARIZE_WIDTH)
    _check_linearize_call(about, t0, width)
    # §14's two rows: the default form inherits `checkpoint`'s precondition, the
    # explicit one `init!`'s legality. Both before any resolution. The gate names
    # `linearize` for both forms, so `checkpoint` is left the mid-frame refusal.
    lifecycle_state = lifecycle(sim)
    legal = about === nothing ? [:initialized, :stopped] : collect(STOPPED_SIM_LEGAL)
    lifecycle_state in legal ||
        throw(DiagnosticError(ServiceLifecycle(op = :linearize, status = lifecycle_state,
                                               legal = legal)))
    operating_point = about === nothing ? checkpoint(sim).state : nothing
    _linearize(sim.model, tap_set, operating_point, about, t0, width)
end

linearize(sim::Simulation, other; kw...) = linearize(sim.model, other; kw...)

"""
Replay's entry pass (§12.7), called by `replay!` below before any state is
touched, so every refusal precedes every write. The pass runs in two
stages, and the split is one of order rather than of policy — each stage
collects within itself: the header's own disagreements with this build are
thrown before a single record is looked at, because a record resolved through a
schema this model has already contradicted would report noise; the records are
then collected in turn, so a trace with three bad entries reports three.
(Both stages collect, as Appendix C's column reads, D-217.) What
comes back is the whole recording normalized to compiled scatters against *this*
layout — the conversion paid once, off the loop (D-101).

The scalar needs no check: a `Trace` holds a `Checkpoint`, nominal by type, and
a simulation runs a `Model{Float64}` (D-317, D-319).

Under `restore = false` the clock joins the header's stage: the feed runs on
the simulation's own clock, so its origin must be the recording's, and its
frame one the recording can feed from.
"""
function _compile_feed(sim::Simulation, trc::Trace, restore::Bool = true)
    faces = Symbol[f for (f, _) in sim.model.exec.act.layout.root_inputs]
    diags = Diagnostic[]
    _check_checkpoint!(diags, sim.model, trc.header.state)
    if !restore
        clock = sim.model.exec.clock
        trc.header.state.t₀ == clock.t₀ || push!(diags, CheckpointMismatch(
            what = :clock, name = :t₀, expected = trc.header.state.t₀, found = clock.t₀))
        feedable = trc.header.frame:(trc.frames - 1)  # the frames the simulation may stand at
        sim.run.frame in feedable || push!(diags, CheckpointMismatch(
            what = :clock, name = :frame, expected = feedable, found = sim.run.frame))
    end
    _check_schemas!(diags, faces, trc.schemas)
    isempty(diags) || throw(DiagnosticError(diags))     # the header before the entries
    records = _compile_records!(diags, sim, trc, faces)
    isempty(diags) || throw(DiagnosticError(diags))
    ReplayFeed(records, 1, trc.frames)
end

# Design: §10.4, §11.1, §11.5, §12.4, §12.6, §12.7, §13.4, §13.5, D-218, D-219,
# D-261, D-268, D-269, D-274.
# Replay is the ordinary loop with exactly one substitution, not a separate
# execution mode, which is what keeps every property proved of the loop true of
# a replay. `replay!` stands in `init!`'s lifecycle position and does what
# `restore!` does with the trace's header as the checkpoint: the state the
# recording opened from, boundary zero's results included, so nothing is applied
# twice and nothing skipped (D-274). The recorded batches apply with no surface
# re-check, since the write-surface rule ran at recording time; `drain!` drops
# the live staging cells. Ordinal keying is exact because the frame sequence is
# itself deterministic. The entry pass runs under both forms, since a deployment
# mismatch is never a what-if. `to_boundary` is §13.4's replay pointer, defined
# as running through the frame that publishes boundary `k`. Every frame top is a
# grid boundary (§10.4), so the halt is exactly at `run.frame == k`, and §10.4
# keeps the two indices apart. `to_time` is the same halt addressed by time
# (D-219); its floor is the deliberate opposite of `t_end`'s reach-or-exceed
# rule (§12.4): `t_end` bounds a run, `to_time` positions an inspection, and the
# point of halting is to stand before the anomaly. `pace` and `margin` are
# `run!`'s too (§12.7, D-269): paced replay is session playback. Ending
# `initialized` is what makes replay-to-inspect, replay-to-`k−1`-then-`step!`
# and `run!`-continuation real. A §13.5 source firing first ends it `stopped`,
# and a loop-side throw is disposed of by the roster as under `run!` (§13.4,
# D-268). The recording and the input mode outlive the call (§12.6, D-218): a
# partial replay is a resumable position, not the end of an operation, which is
# what makes §13.4's reproduction workflow run through the ordinary entry
# points. The new trace appends this simulation's writers under §11.5's growth
# rule, so the re-drained batches keep the recording's own writer indices while
# a continuation's live drains record under this session's own. The run records
# under `init!`'s four keywords with the same defaults (D-261). Rostered devices
# init, spawn and consume snapshots normally (§11.1): they are readers here, and
# a session that wants live input is a continuation, not a replay. The halt's
# range checks follow the entry pass.
"""
    replay!(sim::Simulation, trc::Trace; to_boundary = nothing, to_time = nothing,
            pace = Inf, margin = 0.002, t_end = Inf, ignore_stop_requests = (),
            trace = true, log = true, log_every = 1, log_max = 65536,
            restore = true) -> Nothing

Re-drive a recorded session through the ordinary loop, with the recording
supplying every [frame](@ref g-frame)'s inputs.

[Replay](@ref g-replay) differs from [`run!`](@ref) in two places only. It
starts from the [trace's header](@ref g-trace-header) as [`restore!`](@ref)
does. No [boundary zero](@ref g-boundary-zero) runs, so nothing is applied
twice. At each frame top, it applies the recording's [batches](@ref g-batch) for
that frame verbatim. It drops whatever sits in the live
[staging cells](@ref g-staging-cell) with a `ReplayDiscardedStaging` warning.
The replayed trajectory is bit-identical to the recorded one.

The replay halts at the recording's end, or earlier at `to_boundary` or
`to_time`, always at a frame top. A replay that halts there ends `initialized`,
never `stopped`, so it can be inspected, stepped with [`step!`](@ref) or
continued with `run!`. A termination source that fires first ends it `stopped`,
like any run. A failure inside the loop ends it `errored`, rethrown when no
[device](@ref g-device) is rostered and logged when one is, as under `run!`.

The recording stays attached after the call, in the `:replay`
[input mode](@ref g-input-mode). A later `step!` or `run!` goes on consuming the
records from the halt, and no advance runs past the recording's last frame. The
mode returns to `:live`, the recording detaching with it, when an advance halts
at that last frame; [`live!`](@ref) detaches it earlier.

Replay records a new [trace](@ref g-trace) that inherits the old header, so its
replayed prefix is bit-identical to the recording and a live continuation
appends to it. Rostered devices initialize, run and read
[snapshots](@ref g-snapshot) as in any run, but their writes are dropped.

`restore = false` attaches the recording to the simulation as it stands, and
restores nothing. The simulation must be `initialized`, at the recording's `t₀`,
and at a frame from the header's up to one short of the recording's last; the
records apply from the frame after its own. This form replays a modified model
initialized under the authored [condition](@ref g-condition), or seeks:
`restore!` a [checkpoint](@ref g-checkpoint) the recording passed through, then
replay from the next frame. The new trace's header is then this simulation's own
checkpoint, the state the replay starts from.

# Keywords

- `to_boundary`: halt after the frame that publishes [boundary](@ref g-boundary)
  `k`, a whole number from the frame the replay starts at up to the recording's
  length. An event boundary [localized](@ref g-localized) inside a frame is
  reproduced, but a replay cannot halt there.
- `to_time`: the same halt by time, at the last frame top at or before it,
  `k = ⌊(to_time − t₀)/h⌋` against the header's `t₀`. A time between two frame
  tops halts at the earlier one. Mutually exclusive with `to_boundary`.
- `pace`, `margin`: as for [`run!`](@ref). A paced replay is bit-identical to an
  unpaced one.
- `t_end`, `ignore_stop_requests`: this replay's
  [stop policy](@ref g-stop-policy), as for `run!`, with the same defaults. When
  neither binds, the recording bounds the replay. A live run that ignored some
  requests replays under the same `ignore_stop_requests`.
- `trace`, `log`, `log_every`, `log_max`: as for [`init!`](@ref), with the same
  defaults. Under `trace = false` nothing is re-recorded.
- `restore`: `false` to attach the recording without restoring its header.

`replay!` is refused as `ServiceLifecycle` while `running`, and once `errored`,
as `init!` is. Under `restore = false` it needs an `initialized` simulation, and
is refused as `MissingInit` when `built` and as `ServiceLifecycle` otherwise. A
keyword out of range, or both `to_boundary` and `to_time`, is refused as
`ArgumentInvalid`, and an ignored path that names no requester as
`StopRequestInvalid`. A header that does not match this simulation is refused as
`CheckpointMismatch` or `ReplaySchemaMismatch` before any record is read, and
the records' own mismatches, such as `ReplayUnknownFace`, are then collected
into one throw. Every refusal comes before any write.
"""
function replay!(sim::Simulation, trc::Trace; to_boundary = nothing,
                 to_time = nothing, pace = Inf, margin = 0.002, t_end = Inf,
                 ignore_stop_requests = (),
                 trace = true, log = true, log_every = 1, log_max = 65536,
                 restore = true)
    control = sim.control
    if restore !== false     # a non-`Bool` is refused with the keywords below
        lifecycle_state = lifecycle(sim)
        lifecycle_state === :running && throw(DiagnosticError(
            ServiceLifecycle(op = :replay!, status = :running, legal = collect(STOPPED_SIM_LEGAL))))
        lifecycle_state === :errored && throw(DiagnosticError(
            ServiceLifecycle(op = :replay!, status = :errored, legal = collect(STOPPED_SIM_LEGAL))))
    else
        _assert_advanceable(sim, :replay!)   # the feed joins a trajectory in progress (§12.7)
    end
    _check_recording(:replay!, trace, log, log_every, log_max, restore)   # the run's keywords (D-261)
    p, margin_seconds = _pace_value(pace, :replay!), _margin_value(margin, :replay!)   # D-269
    to_boundary === nothing || to_time === nothing ||     # two spellings of one halt (D-219)
        throw(DiagnosticError(ArgumentInvalid(call = :replay!, reason = :both_given)))
    # The entry pass, every refusal of which precedes every write. It runs ahead
    # of the halt's range checks, which read the two clocks it compares: a halt
    # beside a simulation off the recording's clock is refused for the clock.
    feed = _compile_feed(sim, trc, restore)
    # §13.4's pointer, in grid boundaries: whole, no earlier than the frame the
    # feed starts from — the header's, or the simulation's own under `restore =
    # false` — and no further than the recording reaches; every frame top is
    # one, so it counts frames
    first_frame = restore ? trc.header.frame : sim.run.frame
    to_boundary === nothing || (to_boundary isa Integer && to_boundary ≥ first_frame &&
        to_boundary ≤ trc.frames) || throw(DiagnosticError(
            ArgumentInvalid(call = :replay!, reason = :range, argument = :to_boundary,
                            value = to_boundary)))
    if to_time !== nothing
        # D-219's time spelling of the same pointer, floored onto the last frame
        # top at or before it: the *header's* `t₀` as the origin and the
        # *header's* `h` as the stride — the recording's own grid, so
        # `k ≤ trc.frames` names a boundary of the recording, and a target
        # bound at a different `h` never gets here, the entry pass above
        # having refused it honestly (`CheckpointMismatch`, never a false
        # word about a time the recording covers). `_frame_at` carries the
        # slack: without it the plain floor would halt one boundary short of
        # the one named.
        t₀ = trc.header.state.t₀
        to_time isa Real && isfinite(to_time) && to_time ≥ t₀ || throw(DiagnosticError(
            ArgumentInvalid(call = :replay!, reason = :range, argument = :to_time,
                            value = to_time)))
        to_boundary = _frame_at(Float64(to_time), t₀, trc.header.state.deployment.h)
        first_frame ≤ to_boundary ≤ trc.frames || throw(DiagnosticError(   # outside the feed
            ArgumentInvalid(call = :replay!, reason = :range, argument = :to_time,
                            value = to_time)))
    end
    (policy, ignore_mask) = _bind_policy(sim, t_end, ignore_stop_requests, :replay!)   # this advance's policy, validated
    # The restore, and the new run with the substitution in it: the recording
    # goes in at construction and the mode is read off it, so entering `:replay`
    # *is* constructing this run with a feed (§12.6, D-260). It outlives this
    # call — the halt below detaches it only where it lands at the recording's
    # last frame (§12.7, D-218). The policy is not the run's either: it is this
    # call's argument, carried to the loop and to the record (§13.5, D-260).
    # Under this call's `trace`, the new trace inherits the checkpoint detached
    # and the recording's own schema entries, so neither the growth below nor a
    # continuation's writes ever reach the `Trace` the caller holds.
    cp = restore ? trc.header : Checkpoint(checkpoint(sim.model), sim.run.frame, sim.run.boundary)
    _enter_checkpoint!(sim, cp, trace ? copy(trc.schemas) : Pair{String,Vector{Symbol}}[],
                       feed, trace, log, Int(log_every), log_max)
    # the records at or before the frame the feed starts from are behind it: a
    # seek skips them, and the cursor only advances from here
    feed.next = something(findfirst(record -> record.frame > cp.frame, feed.records),
                          length(feed.records) + 1)
    upto = to_boundary === nothing ? trc.frames : Int(to_boundary)
    @atomic control.pace = p                    # the advance's knobs, written at entry (§12.1)
    @atomic control.margin = margin_seconds
    _run_body!(sim, policy, ignore_mask, upto, _t_end_frame(sim, policy.t_end))
    nothing
end

# Design: §12.6, §12.7, D-218, D-219.
# §12.6's third door, and the only one that moves the input mode alone. The
# automatic flip is D-218's, and it fires only at the recording's end: right for
# an unattended reproduction, wrong for the rewrite workflow, where the caller
# wants the remainder abandoned rather than consumed. The lifecycle gate is the
# advance entries' (§12.6): `:built` refuses for want of a door into
# `initialized`, `:running` because the loop owns the stores, and both terminal
# states because nothing advances from them. A silent no-op on a `:live`
# simulation would let the caller believe a recording was dropped that was never
# attached.
"""
    live!(sim::Simulation) -> Nothing

Detach the rest of an attached recording, and set the
[input mode](@ref g-input-mode) to `:live`.

Nothing else changes. The trajectory stands at the [replay](@ref g-replay)'s
halt, and the run's [trace](@ref g-trace) keeps its header and the
[batches](@ref g-batch) it re-recorded. The next [`run!`](@ref) or
[`step!`](@ref) is therefore the live continuation from the replayed
[boundary](@ref g-boundary), and its inputs append to the replayed prefix, so
the session leaves one seamless recording of itself.

The input mode returns to `:live` on its own only at the recording's end.
`live!` abandons the rest instead: interrupt a session at `t = 110`,
`replay!(sim2, trc; to_time = 100.0)`, inspect, `live!`, and fly the last ten
seconds again.

`live!` is legal only on an `initialized` simulation in the `:replay` mode. It
is refused as `MissingInit` when `built`, and as `ServiceLifecycle` while
`running`, `stopped` or `errored`. A simulation already `:live` is refused as
`ArgumentInvalid`, since it has no recording to drop.
"""
function live!(sim::Simulation)
    _assert_advanceable(sim, :live!)
    run = sim.run
    run.feed === nothing && throw(DiagnosticError(
        ArgumentInvalid(call = :live!, reason = :not_replaying)))
    # §12.6: the mode is read off the feed, so dropping the recording *is* the
    # flip — the same run, with its log, its trace and its record (D-260)
    run.feed = nothing
    nothing
end

# Design: §10.3, §10.4, §10.7, §11.1, §11.2, §11.3, §11.8, §12.1, §12.2, §12.4,
# §12.6, §13.4, §13.5, §13.6, D-255, D-268, D-269, D-310, D-316, D-317.
# Each frame is §11.1's anatomy under §11.1's task topology and §12.4's bracket
# and tail. On a loop-side failure the failed boundary published nothing, so the
# last published snapshot is already the promoted final one; the tail runs
# identically and the cause is retained on the record. §13.4's disposition is
# read off the roster (D-268); with no device rostered the run is unattended. An
# interrupt inside the tail collapses the joins and leaves the loop's source
# standing. One deferred to the end of the masked bookkeeping propagates out of
# `run!` raw, the simulation already terminal (D-268). The run's shape, in
# order: the policy is built and the §11.3 freeze rises, the lifecycle's
# `:running` spanning the tail; the stop word is cleared, a fresh run owing
# nothing to the last one's stop; the thread budget is checked once against the
# frozen roster, `replay!` checking the same way (§12.2); the §12.4 init bracket
# runs per roster entry on the calling task; one task is spawned per live entry,
# and the loop runs on the calling task (§11.1, D-310); the loop advances until
# a termination source fires; and the tail closes the run with the sticky status
# after the final snapshot, the waits woken, `unblock!`, and the join under
# `join_timeout`. Inside the loop, `frame!` carries each grid step `[tₖ₋₁, tₖ]`
# through the §10.4 localization loop, firing any `t*` boundaries it brackets on
# the way. The frame-top boundary (§10.3) is a base tick every `N_base` frames,
# where the gate reads the tick index, and the empty-due-set boundary in
# between. The drain runs at the frame top only, never at a `t*` boundary
# (§10.4), while publication follows every boundary sequence (§11.2), through
# the frame's `settled!` hook before integration resumes (D-317). The grid is
# driven by the frame index (§12.4). Every run creates its pacer and anchors it
# as the loop starts. Under a finite pace it waits at each frame top, after the
# control plane is consulted, for the frame's deadline off the anchor; the frame
# after an anchor runs at once. The two knobs are written to the control plane
# at entry (§12.1, D-269).
"""
    run!(sim::Simulation; pace = Inf, margin = 0.002, t_end = Inf,
         ignore_stop_requests = ()) -> Nothing

Advance the simulation [frame](@ref g-frame) by frame until a termination source
ends the run.

A frame applies the staged inputs at its top, integrates one step and settles
every [boundary](@ref g-boundary) it reaches. It publishes a
[snapshot](@ref g-snapshot) at each. The run ends when one of three sources
fires. The first is `t_end`, when the frame that reaches it completes. The
second is an honoured [stop request](@ref g-stop-request) holding in a published
snapshot. The third is a stop through the [control plane](@ref g-control-plane),
seen at a frame top. A stop request ends the run at the boundary that published
it, an event boundary inside a frame included, and that snapshot is the final
one. `t_end` ends the run at the first frame top at or past it, in whole frames
from `t₀`. `run!` blocks its caller until the run ends.

Each rostered [device](@ref g-device) is initialized and given a task of its own
as the run starts, and shut down as it ends; the loop itself runs on the
[calling task](@ref g-calling-task). The run leaves the simulation `stopped`,
with the record that says why readable through [`termination`](@ref). In the
`:replay` [input mode](@ref g-input-mode) the recording also bounds the run. A
run that consumes the last record halts there `initialized`, with no
[termination record](@ref g-termination-record), and the mode turns `:live`. A
failure inside the loop leaves it `errored` instead, the cause kept on the
record. With no device rostered, `run!` then rethrows the failure; with one or
more, it logs the failure and returns. Ctrl-C is a stop, never a failure: caught
at a frame top or during a pause, it ends the run `stopped` with
`ControlRequestedStop(:interrupt)`.

# Keywords

- `pace`: simulated seconds per wall-clock second, a positive real. `Inf`, the
  default, never waits, and `1` is real time. [`pace!`](@ref) retunes it during
  the run.
- `margin`: the seconds of each [pacing](@ref g-pacing) wait spent spinning
  rather than sleeping, a non-negative real. [`margin!`](@ref) retunes it during
  the run.
- `t_end`: the time at which this advance ends the run, a non-negative real or
  `Inf`.
- `ignore_stop_requests`: the stop requests this advance does not honour, `:all`
  or the paths of the requesting [components](@ref g-component). The default
  `()` honours every request.

`t_end` and `ignore_stop_requests` declare this call's
[stop policy](@ref g-stop-policy) alone, validated per call. A live run with
`t_end = Inf` and no honoured request ends only through the control plane,
Ctrl-C included. It is allowed, and the loop reports `UnboundedRun` into its own
[diagnostic cell](@ref g-diagnostic-cell). The pace inserts wall time between
frames and nothing else, so a paced run is bit-identical to an unpaced one. A
frame that overruns leaves debt, and debt past five frames' budget is forgiven
with a `DebtReanchor` warning in the loop's cell. Every snapshot's status
carries the pacer's record. With fewer threads than rostered devices plus one,
the loop reports `ThreadBudget` into its cell.

`run!` needs an `initialized` simulation. It is refused as `MissingInit` when
`built`, since [`init!`](@ref) or another call that opens a run must come first,
and as `ServiceLifecycle` when `running`, `stopped` or `errored`. A keyword out
of range is refused as `ArgumentInvalid`, and an ignored path that names no
requester as `StopRequestInvalid`.
"""
function run!(sim::Simulation; pace = Inf, margin = 0.002, t_end = Inf,
              ignore_stop_requests = ())
    _assert_advanceable(sim, :run!)
    p, margin_seconds = _pace_value(pace, :run!), _margin_value(margin, :run!)   # D-269
    (policy, ignore_mask) = _bind_policy(sim, t_end, ignore_stop_requests, :run!)   # this advance's, carried (D-260)
    # §13.5's advisory (D-255, D-316): a live run bounded by neither clock nor
    # honoured request ends only by the operator interrupt, so the loop says so
    # once, into its own cell. A `:replay` run is bounded by the recording
    # (D-218), so the warning would be false there.
    mode(sim) === :live && isinf(policy.t_end) && all(ignore_mask) &&
        report_cell!(sim.plane.loop_diag, UnboundedRun(policy.t_end, copy(policy.ignored)))
    @atomic sim.control.pace = p                # the advance's knobs, written at entry (§12.1)
    @atomic sim.control.margin = margin_seconds
    # a live run owes its end to a §13.5 source alone, so its frame budget is
    # unbounded here; in `:replay` the recording binds it (`_run_body!`, D-218)
    _run_body!(sim, policy, ignore_mask, typemax(Int), _t_end_frame(sim, policy.t_end))
    nothing
end

# §12.7's bound (D-218): while the mode is `:replay` the recording caps every
# advance's frame budget, `to_boundary` capping it earlier — so no advance ever
# runs past the records and goes on live, and every frame of a session is either
# record-driven or live before it runs.
function _replay_bound(sim::Simulation, upto::Int)
    feed = sim.run.feed
    feed === nothing ? upto : min(upto, feed.frames)
end

# §12.7's flip (D-218), at the one place the terminal disposition already lives:
# the mode becomes `:live` exactly when the halt consumed the recording's last
# frame, the records exhausted and the recording detached with them; short of
# that it stays `:replay`, and the next `step!` or `run!` goes on consuming the
# recording. An `errored` exit leaves both as they stand: the frame was
# abandoned mid-execution, nothing advances from a terminal state, and `init!`
# and `replay!` are the resets.
function _settle_mode!(sim::Simulation)
    run = sim.run
    feed = run.feed
    feed === nothing && return nothing
    # the detach is the flip: the mode is the feed's absence (§12.6, D-260)
    run.frame ≥ feed.frames && (run.feed = nothing)
    nothing
end

# The run's body: the §11.3 freeze, §12.4's bracket, §11.1's topology, the tail
# and §13.5's terminal disposition — everything from `:running` to the terminal
# store, shared verbatim by `run!` and `replay!` because D-101's claim is that
# replay *is* this loop. `ignore_mask` is the policy compiled against the
# requester roster, the loop's own argument (D-261, D-316); `upto` is the
# frame budget, `t_end_frame` the `t_end` frame.
# The pacer is created here, one per call, and handed to the loop as the ignore
# mask is (§10.7, §12.6, D-269). So is the roster, copied at the freeze and read by
# the run alone, never off the plane (§11.3). The §12.2 thread-budget check runs
# here too, after the freeze, so either entry point checks once per run against the
# frozen roster. The doors that build a run publish with the plane's roster, as
# every stopped-sim reader reads it.
#
# The terminal mapping is `step!`'s. `source === nothing` means the budget ran
# out rather than a source firing, which only a bounded advance can reach — a
# `replay!`, or any run in `:replay`, where the recording is the bound (D-218) —
# and it lands `initialized` at a frame top, §12.7's promise. A §13.5 source is
# `stopped` with the record, a throw `errored` with the cause retained. The mode
# settles here too, on every exit but the errored one. §13.4's disposition of
# that throw is read off the roster here, so both doors share it (D-268):
# with no device rostered it is rethrown; with one or more it is logged once
# the record is written, and the call returns.
function _run_body!(sim::Simulation, policy::StopPolicy, ignore_mask::Vector{Bool},
                    upto::Int, t_end_frame::Int)
    plane, control = sim.plane, sim.control
    upto = _replay_bound(sim, upto)             # §12.7: the recording bounds a replaying run
    roster = RosterEntry[]                    # the run's roster, filled at the freeze below
    source, cause = nothing, nothing          # `cause`: the loop's throw, stored first
    logged_cause = nothing                    # the cause, its backtrace if taken, when not rethrown
    # the interrupt arm below reads these four
    live, tasks = RosterEntry[], nothing
    returned, tail_ran = false, false
    pacer = Pacer()                           # this call's schedule and counters (D-269)
    try
        # The §11.3 freeze: the roster is fixed for the run. The `try`'s first
        # statement, so an interrupt past it meets the masked bookkeeping and
        # never leaves the lifecycle `running` (§12.4).
        @atomic :release control.running = true
        @atomic control.stop_issuer = nothing # ahead of any safepoint: the arm reads the word
        append!(roster, plane.roster)         # read once (§11.3)
        _reset_accounts!(sim, roster)         # §11.8: totals count since the run began
        report_thread_budget!(plane, roster, Threads.nthreads())  # §12.2: one check per run, either entry point
        _init_devices!(sim, roster, live)     # §12.4's pre-spawn bracket, attachment order
        @atomic control.stopped = false
        # Masked, so a deferred interrupt raises with every task spawned and
        # registered, and the tail can join them (§12.4). The loop runs here,
        # on the calling task (§11.1, D-310).
        Base.sigatomic_begin()
        tasks = _spawn!(live)
        _register_tasks!(plane, live, tasks)
        Base.sigatomic_end()
        try
            source = _advance!(sim, ignore_mask, upto, t_end_frame, roster, pacer)[1]
            returned = true
        catch err
            # stored before the `finally`, whose wait an interrupt can cut
            err isa InterruptException || (cause = err)
            rethrow()
        finally
            _finish!(sim)                     # tail (1)–(2), even off a loop-side throw
            tail_ran = true
            _tail!(sim, live, tasks)          # tail (3)–(5)
        end
    catch err
        loop_failure = nothing                # the loop's throw and its backtrace, from the arm below
        if err isa InterruptException
            # The operator's stop landing outside the loop's own unmask points —
            # the bracket's edges, an escape from the bracket's own catch, the
            # spawn mask's end, the moments between the loop's return and the
            # tail — is a stop, never a `LoopError` (§12.4, D-268). The arm's
            # head runs masked: the fallback source, and the `:interrupt` stop
            # unless an earlier issuer holds the stop word, which ends a loop a
            # forced raise left scheduled and unbound. A loop that returned
            # keeps its outcome, a source or a budget halt alike. Where the
            # interrupt came before the tail, the tail runs here, unmasked so a
            # later interrupt collapses its joins, and retried from where an
            # interrupt cut it. An entry never spawned is released directly,
            # which finds every entry whose `init!` began and that the bracket
            # has not released, since the bracket lists each first; a spawned
            # one through its wrapper once the tail wakes it. What is left only
            # a forced raise reaches. One inside the spawn mask reopens that
            # window: a spawned wrapper's `shutdown!` also runs in the direct
            # release, concurrently, its task never registered or joined, and
            # later entries are never spawned. One between `_tail!`'s return
            # and the flag's store reruns `_tail!`; one between a `shutdown!`'s
            # return and its cursor repeats that call. The rest are the few
            # instructions between a `catch` and its next `try`.
            while true                        # an interrupt arriving within the head
                try                           # raises at its unmask: the head reruns
                    Base.sigatomic_begin()
                    returned || (source = ControlRequestedStop(something((@atomic control.stop_issuer), :interrupt)))
                    returned || _request_stop!(control, :interrupt)
                    Base.sigatomic_end()
                    break
                catch err                     # rebinds the outer `err`; nothing below reads it
                    err isa InterruptException || rethrow()
                end
            end
            if !tail_ran
                # §12.4 lets no interrupt out of the tail, and `_tail!`'s own
                # collapse covers only its lines: a retry resumes the steps
                # where an interrupt cut them, `_finish!` being idempotent.
                direct_releases = 0           # entries of `live` the direct release shut down
                joins_settled = false         # `_tail!` returned: every join done or reported
                while true
                    try
                        _finish!(sim)
                        if tasks === nothing  # nothing was spawned: release each entry here
                            for i in direct_releases+1:length(live)
                                _shutdown!(live[i])
                                direct_releases = i
                            end
                        elseif !joins_settled
                            _tail!(sim, live, tasks)
                            joins_settled = true
                        end
                        break
                    catch err                 # rebinds the outer `err`; nothing below reads it
                        err isa InterruptException || rethrow()
                    end
                end
            end
        else
            # an interrupt after this store propagates raw out of `run!`, the run
            # landed `errored` with its record written, the disposition skipped
            cause = err                       # first: the backtrace allocates, a safepoint
            loop_failure = (err, catch_backtrace())
        end
        if cause !== nothing
            # §13.4's disposition, by the roster (D-268): unattended, CI fails honestly
            isempty(roster) && rethrow(cause)
            # bare where an interrupt cut the inner `finally` and no backtrace was taken
            logged_cause = loop_failure === nothing ? cause : loop_failure
        end
    finally
        # The bookkeeping lands whatever arrives: masked, a raise deferred to
        # its end propagating raw, the simulation already terminal (§12.4, D-268).
        Base.sigatomic_begin()
        @atomic control.stopped = true
        residue = _sweep_tail!(sim, roster)   # the run's last take (§11.8): what landed past
                                              # the final frame top — recorded and presented,
                                              # never published (D-201, D-203)
        # Under the lock `_status` reads the registry under (§12.2).
        @lock control.wake empty!(plane.run_tasks)
        if cause !== nothing
            # §13.6's abnormal entry: the failed boundary is discarded by
            # construction — publication is a boundary's last act, so it
            # published nothing and the previous snapshot is already final. The
            # source retains the cause as the frame loop wrapped it — a
            # `StepError` against the execution cursor (§13.4) — and the
            # record itself is assembled here, after the sweep (D-203). The
            # model's catch already wrote its status, which reads `errored`
            # (D-317).
            error_source = LoopError(cause)
            sim.run.termination = _record(sim, policy, error_source, residue)
        else
            _settle_mode!(sim)                # §12.7's flip, at the halt (D-218)
            # A source fired: the record closes the run, and the flag's clearing
            # reads `stopped`. Otherwise the frame budget ran out, a replay ended
            # at a frame top (§12.7), and the open run reads `initialized`.
            if source !== nothing && lifecycle(sim) === :running
                sim.run.termination = _record(sim, policy, source, residue)
            end
        end
        @atomic :release control.running = false   # once, after the record and the status
        Base.sigatomic_end()
    end
    logged_cause === nothing ||
        @error "the run ended errored; the cause is retained on termination(sim) (§13.4, §13.6)" *
               " and the simulation refuses every advance (§12.6)" exception = logged_cause
    nothing
end

# The per-run reset (§11.8): every writer's account starts the run — and, from
# init!, the trajectory — at zero. The cells are deliberately not touched: a
# batch reported or staged while stopped waits for the first frame top's
# drain, exactly as a staged input batch waits (§11.4).
function _reset_accounts!(sim::Simulation, roster::Vector{RosterEntry})
    for entry in roster
        _reset!(entry.account)
    end
    _reset!(sim.plane.harness_account)
    _reset!(sim.plane.loop_account)
    nothing
end

# §12.2's one check per run, against the frozen roster: the run occupies
# one task per rostered device plus the loop, whichever task hosts which,
# and tight is fewer threads than that. Reported into the loop's own cell,
# so the first frame top drains it into the first snapshot's status; a
# deviceless run never warns. The thread count is an argument for the test
# that drives the check below the machine's count. `step!` spawns no task and
# never checks.
function report_thread_budget!(plane::DataPlane, roster::Vector{RosterEntry}, threads::Int)
    device_tasks = length(roster)
    threads < device_tasks + 1 &&
        report_cell!(plane.loop_diag, ThreadBudget(threads, device_tasks))
    nothing
end

_register_tasks!(plane::DataPlane, entries::Vector{RosterEntry}, tasks::Vector{Task}) =
    (for (entry, task) in zip(entries, tasks); plane.run_tasks[entry.id] = task; end; nothing)

# --- §12.4's run bracket: the init bracket, the tail and the sweep -----------
# On the calling task, once per run, around the spawn and the wrapper that
# devices.jl holds; `_run_body!` above runs them in order.

"""
§12.4's pre-spawn initialization bracket, a step of the shutdown protocol
taken at the top of a run: `init!` once per roster entry, in attachment
order, on the calling task, each call in its own bracket. A throw goes
straight back to `shutdown!` — which is why `shutdown!` owes tolerance of a
partially initialized device — is reported as the ordinary `DeviceCrash`,
and spawns no task: the device is dead from the run's first frame, its
claims persisting to run end and the orphaned root inputs holding their values.
With `should_abort` set the failure requests a stop, already pending when
the loop would start: the run advances zero frames and ends through the same
tail, every remaining entry still getting its `init!`/`shutdown!` pair
uniformly. An `InterruptException` is the operator's stop, not a crash, as in
the wrapper (D-268): the device is released and spawns no task, the
`:interrupt` stop is set in place of the report, and the run ends at its
first frame top the same way. Fills the run's `live`, the entries from which
§11.1's topology is derived — derived *after* initialization, never from the
roster alone. Each entry is listed before its `init!` begins, and removed on a
throw right after the bracket releases it, ahead of the arms, so an interrupt
escaping the bracket leaves in `live` every entry whose `init!` began and that
the bracket has not released, where `run!`'s arm releases it. Listing after
`init!` would leak the device whose `init!` had just returned (§11.6, D-268).
"""
function _init_devices!(sim::Simulation, roster, live)
    for entry in roster
        push!(live, entry)
        try
            init!(entry.dev)
        catch err
            _shutdown!(entry)
            pop!(live)                        # released, so an interrupt in an arm can't repeat it
            if err isa InterruptException
                _request_stop!(entry.handle.control, :interrupt)   # the operator's stop (§12.4, D-268)
            else
                # addressed by the entry: no task holds a handle yet (§12.4)
                report!(entry, DeviceCrash(err, entry.should_abort))
                entry.should_abort && stop!(entry.handle)
            end
        end
    end
    nothing
end

# Spawn the wrapper, one run-scoped task per entry (§11.1): inside `run!`
# only, never at `attach!` — a task exists only once the run it serves does.
# The §12.3 registers are refreshed first, on the calling task.
# Tail steps (1)'s close and (2) (§12.4): the final snapshot is whatever the
# loop last published; the sticky status flips only after it, the pause flag
# clears beside it (§12.1, D-268), and the notify under the lock wakes every
# §12.3 waiter, whose predicate routes it out. Idempotent, and run on §13.6's
# catch path too, so no device task is left parked when the loop throws.
function _finish!(sim::Simulation)
    control = sim.control
    @atomic control.stopped = true
    @atomic control.paused = false
    lock(control.wake)
    try
        notify(control.wake)
    finally
        unlock(control.wake)
    end
    nothing
end

"""
Tail steps (3)–(5) (§12.4), on the calling task, after `_finish!` has set
the sticky status and woken the waits: `unblock!` per spawned entry — the
override's own blocking call returns; a throw out of the hook is warned and
the tail proceeds — then the join under one shared `join_timeout` deadline,
D-198's one patience for the whole tail. A task exceeding what remains of
the deadline is abandoned rather than left to hang `run!`, reported by name
under `DeviceJoinTimeout` into the loop's own cell (D-203): the terminal
snapshot precedes the join by construction, so the run's-end sweep — not a
drain — is what collects it, into the termination record and the logging
backend.

An interrupt reaching the tail, in the `unblock!` loop or the join, collapses
it (§12.4, D-268): the remaining joins are abandoned at once, every entry
whose task is not done reported by name exactly as the cap's path reports
it, and nothing propagates. The run still ends `stopped`.
"""
function _tail!(sim::Simulation, entries::Vector{RosterEntry}, tasks::Vector{Task})
    settled = 0                                 # entries the join has joined or reported
    try
        for entry in entries
            try
                unblock!(entry.dev)
            catch err
                err isa InterruptException && rethrow()
                @warn "unblock! of $(_who(entry)) threw; its task can now exit only " *
                      "through the join timeout (§12.4)" exception = (err, catch_backtrace())
            end
        end
        deadline = time() + sim.control.join_timeout
        for (i, (entry, task)) in enumerate(zip(entries, tasks))
            remaining = deadline - time()
            joined = istaskdone(task) ||
                (remaining > 0 &&
                 timedwait(() -> istaskdone(task), remaining; pollint = min(0.01, remaining)) === :ok)
            joined || _report_join_timeout!(sim, entry)
            settled = i
        end
    catch err
        err isa InterruptException || rethrow()
        # (5)'s abandonment, taken at once. A further interrupt cuts one report
        # short and the loop resumes past the entries settled, so none leaves.
        while true
            try
                for i in settled+1:length(tasks)
                    istaskdone(tasks[i]) || _report_join_timeout!(sim, entries[i])
                    settled = i
                end
                break
            catch err                           # rebinds the outer `err`; nothing below reads it
                err isa InterruptException || rethrow()
            end
        end
    end
    nothing
end

# Tail step (5)'s abandonment report, into the loop's own cell (D-203).
function _report_join_timeout!(sim::Simulation, entry::RosterEntry)
    snapshot = latest(sim)                      # after init!, never nothing (§14.5)
    report_cell!(sim.plane.loop_diag,
                 DeviceJoinTimeout(_who(entry), sim.control.join_timeout,
                                   _seconds(snapshot.t), snapshot.boundary))
end

"""
The run's last sweep (§11.8), in `run!`'s outermost `finally`: one more take
per cell, folding what landed after the final frame top — a crash caught on
the way out, a report from a device's exit path, the tail's own
`DeviceJoinTimeout` — into the accounts, so the per-run record is complete
and nothing leaks into the next run's status. The terminal snapshot is
already out, so no snapshot can carry this residue: it is collected into the
returned `ResidueRecord`s — the termination record's third field — and
presented through the logging backend, the record's renderer (D-201, D-203).
The terminal status's account is therefore complete up to its own frame top,
and the tail's remainder is loud *and* recorded, still never published.
"""
function _sweep_tail!(sim::Simulation, roster)
    plane = sim.plane
    residue = ResidueRecord[]
    for entry in roster
        _fold!(entry.account, _handle(entry).diag_cell)
        _residue!(residue, _who(entry), entry.account)
    end
    _fold!(plane.harness_account, plane.harness_diag)
    _residue!(residue, "harness", plane.harness_account)
    _fold!(plane.loop_account, plane.loop_diag)
    _fold!(plane.loop_account, sim.model.frame_diag)   # the frame's own cell (§11.8, D-317)
    _residue!(residue, "loop", plane.loop_account)
    residue
end

# One writer's take: a quiet account contributes no record; a noisy one hands
# its pending vector over — the account re-arms the shared empty, so the
# record's vector is never written again — and is rendered entry by entry.
function _residue!(residue::Vector{ResidueRecord}, who::String, account::WriterAccount)
    isempty(account.recent) && _total(account.suppressed) == 0 && return nothing
    record = ResidueRecord(who, account.recent, account.suppressed)
    push!(residue, record)
    for occurrence in record.recent
        @warn "$(nameof(typeof(occurrence))) from $who, past the final snapshot's " *
              "account: $(message(occurrence))"
    end
    suppressed_count = _total(record.suppressed)
    suppressed_count > 0 &&
        @warn "$suppressed_count more suppressed occurrence(s) from $who past the final " *
              "snapshot's account (§11.8)"
    account.recent = EMPTY_RECENT
    account.suppressed = KindCounts()
    nothing
end

# The loop's hooks (§11.2, §11.4, §13.5, D-317), one per advance and one per
# `init!`: the top hook is the drain, and the settled hook publishes the
# boundary, then samples the stop requests off that snapshot. Which request
# holds is the loop's to read again; the model learns only whether one does.
struct LoopHooks{S<:Simulation} <: FrameHooks
    sim::S
    roster::Vector{RosterEntry}     # the run's copy (§11.3)
    pacer::Union{Nothing,Pacer}     # the run's, `nothing` under `step!` and `init!` (§10.7)
    ignore_mask::Vector{Bool}       # the advance's policy against the requesters (D-316)
end

# The simulation's own doors pass the claim's gate, which is model.jl's (D-318).
_claimed_gate(::Model, ::LoopHooks, ::Symbol) = nothing

# Design: §11.2, §11.4, §13.4, §13.5, D-317.
# The top hook is the drain. `LoopHooks` is internal, so the method has no
# docstring on the public `frame_top!` page. It applies the staged input batches
# at the top of a simulation's frame, before the frame touches any state. A
# simulation passes its model a `LoopHooks`, its own `FrameHooks`, and the
# model's frame calls `frame_top!` first. This method runs the drain (the single
# point at the top of each frame where the loop takes the staged inputs). It
# applies the batch waiting in each staging cell, or under replay the
# recording's batches for the frame. A batch is a staged set of face ⇒ value
# writes. A staging cell is the per-device holding place where pending writes
# wait. See `settled!` for the other hook.
frame_top!(hooks::LoopHooks) = drain!(hooks.sim, hooks.roster)

# Design: §11.2, §11.4, §13.4, §13.5, D-317.
# The settled hook publishes the boundary, then samples the stop requests off
# that snapshot. Which request holds is the loop's to read again; the model
# learns only whether one does. `LoopHooks` is internal, so the method has no
# docstring on the public `settled!` page. It publishes the settled boundary's
# snapshot, and returns whether an honoured stop request holds in it. The model
# calls `settled!` at every settled boundary before integration resumes: each
# localized event boundary, the frame top's, that of boundary zero (the
# initialization boundary), and the boundary `overlay!` or `restore!` settles.
# This method publishes the snapshot (the immutable per-boundary publication).
# It then reads the snapshot's stop requests, the `StopFlag` output ports,
# skipping those the advance ignores. A `true` makes the frame abandon its
# remainder, and the run ends with this snapshot as its final one. See
# `frame_top!` for the other hook.
settled!(hooks::LoopHooks) =
    (publish!(hooks.sim, hooks.roster, hooks.pacer);
     _stop_hit(hooks.sim, hooks.ignore_mask) !== nothing)

# The frame loop, shared by both advance entries (§12.6: a stepped frame is
# bit-identical to a run frame because this is the same code) — returns
# `(source, frames advanced)`, the §13.5 source `nothing` exactly when the
# frame budget `upto` ran out, which only `step!` binds finitely. The
# consultation order is normative (D-203; the recorded source of a boundary
# where two sources hold is the first in it): the stop word at frame top
# (§12.1 — the loop never stops mid-frame, so a stop observed here leaves the
# last published boundary as the final snapshot, §12.4(1)); `t_end`'s frame
# completed; and the stop requests at every publication — the entry check first
# (a boundary-zero or authored condition already terminal advances nothing,
# §13.5), then after each frame's own publications, where a hit arrives as
# `frame!`'s `true` with the frame's remainder already abandoned, and the
# requester is read again off the snapshot the hook just published (D-261,
# D-317: never a field of the policy or the cursor). `ignore_mask` is the
# policy compiled against the requester roster, bound beside it and carried to
# the sampling read in the hooks (D-316).
# The frame top opens with the pause block, ahead of the stop word: the loop
# parks there while paused, and a stop wakes it onto the word's read, so a
# stop issued while paused ends the run with no further frame (§12.1, D-268).
# With devices rostered every frame yields at least once (§12.2, the unpaced
# case): the explicit yield is the co-resident device tasks' scheduling slot.
# The pacer (§10.7, D-269), `nothing` from `step!`, which never waits, is
# anchored as the loop starts, re-anchored when the pause block parked (the
# un-pause clears its debt), and waits after the yield for the frame's
# deadline, the coarse phase's `sleep` a further unmask point. It reads the
# control plane at frame top alone, so a stop or pause issued during its wait
# lands at the next frame top.
#
# §12.4's mask (D-268): delivery is deferred from the drain through the
# frame's last publication, the frame's `try` inside the mask, so an operator
# interrupt never lands mid-boundary. The unmask points are the mask's end,
# after the frame counted and its requests were read, and the unmasked frame top,
# the pause block, the yield and the pacer's wait among them; one `try` per
# iteration holds both, entered unmasked. Caught there, the interrupt yields
# to a request the publication found holding (§13.5's order) and otherwise sets
# the `:interrupt` stop. A frame that throws arrives as the `StepError` the
# model's catch built, still masked, then unmasks: its throw is the
# disposition, a pending interrupt is consumed, and
# the run ends `errored` (§12.4, §13.4). Every `try` exit, normal or not,
# restores the sigatomic count its entry saw, so the mask's two ends sit
# outside the frame's `try`.
function _advance!(sim::Simulation, ignore_mask::Vector{Bool}, upto::Int,
                   t_end_frame::Int, roster::Vector{RosterEntry}, pacer::Union{Nothing,Pacer})
    plane, control, clock, run = sim.plane, sim.control, sim.model.exec.clock, sim.run
    h = sim.model.deployment.h
    hooks = LoopHooks(sim, roster, pacer, ignore_mask)   # one per advance (D-317)
    advanced = 0
    requester = _stop_hit(sim, ignore_mask)
    requester === nothing || return (ModelRequestedStop(requester), advanced)
    pacer === nothing || anchor!(pacer, _seconds(clock.t), @atomic control.pace)   # the run's first
    while true
        failure = nothing                     # the failed frame's `StepError`, once built
        try
            parked = wait_resume!(control)    # the pause block: an unmask point (§12.4)
            pacer === nothing || !parked || isinf(pacer.pace) ||   # un-pause re-anchors (§10.7)
                reanchor!(pacer, _seconds(clock.t), @atomic control.pace)
            issuer = @atomic control.stop_issuer
            issuer === nothing || return (ControlRequestedStop(issuer), advanced)
            run.frame < t_end_frame || return (EndTimeReached(), advanced)
            run.frame < upto || return (nothing, advanced)
            isempty(roster) || yield()
            pacer === nothing ||              # the pacer's wait: an unmask point (§12.4)
                wait_deadline!(control, pacer, plane.loop_diag, _seconds(clock.t), h)
            Base.sigatomic_begin()                 # §12.4: masked across the boundary sequence
            try
                # the index advances first and the drain runs as the frame's top
                # hook, so a batch taken at the top of frame `k` is recorded at
                # `k` (§11.5, D-317)
                k = (run.frame += 1)
                hit = frame!(sim.model, k, hooks)
                # the snapshot the hook sampled is the latest, so the read repeats
                # it (§13.5, D-317)
                requester = hit ? _stop_hit(sim, ignore_mask) : nothing
                # a frame counts once it has published a boundary — which a `t*`
                # stop hit has done, its remainder abandoned; the carve-out below
                # is what makes the count observable, a throw carrying no return
                # value out
                advanced += 1
            catch err
                # The frame failed, so its throw is the disposition (§12.4, §13.4).
                # The model's catch built the `StepError` still masked, since the
                # species rule runs declarations, and it is carried in `failure`
                # across the unmask: a pending raise lands in the arm below, which
                # throws it. §13.4's one exception never wrapped is kept
                # defensively: a synchronous throw from model code, the mask
                # deferring only a signal. The frame is abandoned unpublished, the
                # stores possibly mid-boundary, and the run takes the stop path
                # (§12.4).
                err isa InterruptException || (failure = err)
                Base.sigatomic_end()
                failure === nothing && return (_interrupt_source(control, nothing), advanced)
                rethrow(failure)                   # the model's backtrace kept
            end
            Base.sigatomic_end()                   # the mask's end: a deferred raise lands here
        catch err
            err isa InterruptException || rethrow()
            # a frame that failed with the interrupt pending ends errored under
            # its own `StepError`, the interrupt consumed (§12.4, §13.4, D-268)
            failure === nothing || throw(failure)
            # `requester` is this frame's where the raise came at the mask's end,
            # and `nothing` at the frame top, a holding request having returned
            return (_interrupt_source(control, requester), advanced)
        end
        requester === nothing || return (ModelRequestedStop(requester), advanced)
    end
end

# The source an operator interrupt caught in the frame loop records (§12.4,
# D-268): a request the frame's publication found holding was consulted first
# and wins; otherwise the `:interrupt` stop, through the stop word so an
# earlier issuer keeps it.
function _interrupt_source(control::Control, requester::Union{Nothing,Requester})
    requester === nothing || return ModelRequestedStop(requester)
    _request_stop!(control, :interrupt)
    ControlRequestedStop(something(@atomic control.stop_issuer))
end

# Design: §11.4, §12.4, §12.6, §12.7, §13.4, §13.5, §13.6, D-218, D-255, D-268,
# D-269, D-316.
# §12.6's partial advance. The two entries share the one frame loop. A stepping
# session is deviceless by construction: device tasks are per-`run!` artifacts.
# The frame-top drain still runs, so a batch staged into a rostered device's
# cell is applied exactly as §11.4 says. A stop inside the call ends the run
# through the deviceless §12.4 tail, and `step!` always rethrows a loop-side
# failure, being deviceless by construction (§13.4, D-268).
"""
    step!(sim::Simulation; frames = nothing, t_plus = nothing, t_end = Inf,
          ignore_stop_requests = ()) -> Int

Advance the simulation by whole [frames](@ref g-frame), synchronously, and
return the number of frames advanced.

Each frame runs exactly as under [`run!`](@ref), so a stepped simulation is
bit-identical to the same frames under `run!`. The staged inputs still apply at
each frame's top, so `stage!(sim, …)`, then `step!`, then `latest(sim)` drives a
model and checks its response one step at a time. `step!` never waits for the
pacer, and the pacer record of its [snapshots](@ref g-snapshot) reads `Inf` and
zeros. It spawns no [device](@ref g-device) task and initializes no device, but
a [batch](@ref g-batch) staged into a rostered device's cell while stopped is
applied as usual.

Between calls the simulation stays `initialized`, so [`attach!`](@ref) is legal
there and `run!` may follow, continuing from the current
[boundary](@ref g-boundary). A termination source that fires inside the call
ends the run there: the simulation is left `stopped` with its
[termination record](@ref g-termination-record) set, and `step!` returns the
frames advanced before the stop. A return below the frames requested is how a
caller detects the stop without reading the clock. A failure inside the loop
leaves the simulation `errored`, and `step!` always rethrows it.

In the `:replay` [input mode](@ref g-input-mode) the frames take their inputs
from the recording, which bounds the advance. A `step!` past its end advances
only to the last recorded frame, returns fewer frames than asked and turns the
mode `:live`.

# Keywords

- `frames`: the number of frames to advance, an integer of at least 1. One frame
  when neither `frames` nor `t_plus` is given.
- `t_plus`: the duration to advance, a positive finite real, in whole frames
  until the boundary time first covers it. Mutually exclusive with `frames`.
- `t_end`, `ignore_stop_requests`: this advance's
  [stop policy](@ref g-stop-policy), as for [`run!`](@ref), with the same
  defaults, validated per call.

`step!` needs an `initialized` simulation, as `run!` does: it is refused as
`MissingInit` when `built`, and as `ServiceLifecycle` otherwise. Both `frames`
and `t_plus`, or either out of range, is refused as `ArgumentInvalid`, and an
ignored path that names no requester as `StopRequestInvalid`.
"""
function step!(sim::Simulation; frames = nothing, t_plus = nothing,
               t_end = Inf, ignore_stop_requests = ())
    control = sim.control
    _assert_advanceable(sim, :step!)
    # own keywords first, then the policy, then the write: `replay!`'s order too
    frames === nothing || t_plus === nothing ||
        throw(DiagnosticError(ArgumentInvalid(call = :step!, reason = :both_given)))
    if t_plus === nothing
        frame_count = frames === nothing ? 1 : frames
        frame_count isa Integer && frame_count ≥ 1 || throw(DiagnosticError(
            ArgumentInvalid(call = :step!, reason = :range, argument = :frames,
                            value = frame_count)))
        frame_count = Int(frame_count)
    else
        t_plus isa Real && isfinite(t_plus) && t_plus > 0 || throw(DiagnosticError(
            ArgumentInvalid(call = :step!, reason = :range, argument = :t_plus, value = t_plus)))
        t = sim.model.exec.clock.t                  # the frame top the duration counts from
        frame_count = max(1, _frames_to(t + Float64(t_plus), t, sim.model.deployment.h))
    end
    (policy, ignore_mask) = _bind_policy(sim, t_end, ignore_stop_requests, :step!)   # this advance's policy (§13.5, D-255)
    t_end_frame = _t_end_frame(sim, policy.t_end)
    roster = RosterEntry[]                    # the call's roster, filled at the freeze below
    source, advanced, cause = nothing, 0, nothing
    returned = false
    try
        # the freeze holds within the call; first in the `try`, as in `_run_body!`
        @atomic :release control.running = true
        append!(roster, sim.plane.roster)     # read once (§11.3)
        # §12.7: in `:replay` the recording is the bound, so a `step!` past its
        # end advances only to the last recorded frame and returns fewer frames
        # than asked — the truncation the caller reads (D-218)
        upto = _replay_bound(sim, sim.run.frame + frame_count)
        (source, advanced) = _advance!(sim, ignore_mask, upto, t_end_frame, roster, nothing)
        returned = true
    catch err
        if err isa InterruptException
            # The operator's stop landing outside the loop's unmask points is a
            # stop, as in `_run_body!` (§12.4, D-268): a loop that returned
            # keeps its outcome, and `:interrupt` is the source only where it
            # had not. The `finally` lands it `stopped`. A second interrupt in
            # the stop request leaves `source` unset and lands `initialized` at
            # a consistent frame top, the stop word set: no loop is left running.
            # `step!` never clears the word, so the next `step!` ends at once,
            # no frame advanced, the lifecycle `stopped`.
            if !returned
                _request_stop!(control, :interrupt)
                source = ControlRequestedStop(something(@atomic control.stop_issuer))
            end
        else
            cause = err                       # stored first; the record is assembled
            rethrow()                         # below, after the sweep (D-203)
        end
    finally
        Base.sigatomic_begin()                # masked bookkeeping, as `run!`'s (§12.4, D-268)
        if cause !== nothing                  # §13.6, the stepped entry: same tail,
            _finish!(sim)                     # deviceless — waits woken, accounts swept
            # the model's catch already wrote its status, which reads `errored` (D-317)
            sim.run.termination = _record(sim, policy, LoopError(cause), _sweep_tail!(sim, roster))
        else
            _settle_mode!(sim)                # §12.7's flip, at the halt (D-218)
            if source !== nothing             # a §13.5 source fired inside the call:
                _finish!(sim)                 # the deviceless §12.4 tail, then terminal
                sim.run.termination = _record(sim, policy, source, _sweep_tail!(sim, roster))
            end                               # otherwise the run stays open: `initialized`
        end
        @atomic :release control.running = false   # once, after the record and the status
        Base.sigatomic_end()
    end
    advanced
end

# Design: §12.1, §12.4, §12.4(2), D-203.
# The calling code's spelling of the stop a device handle issues with
# `stop!(handle)`. A later issuer loses the first-wins CAS.
"""
    stop!(sim::Simulation) -> Nothing

Request a stop of the running loop, issued by the calling code, from any task.

`stop!` sets the [stop word](@ref g-stop-word). The loop sees it at the next
[frame top](@ref g-frame), completes that [boundary](@ref g-boundary), publishes
and shuts the run down. A loop waiting in a pause is woken and ends at that
frame top with no further frame. The source of the
[termination record](@ref g-termination-record) is then
`ControlRequestedStop(:code)`. A [device](@ref g-device) issues the same stop
through its [`DeviceHandle`](@ref), with `stop!(handle)`.

The first issuer wins, so a later stop changes nothing. On a `stopped`
simulation `stop!` has no effect, since the word is cleared before the next run
starts. A stop issued before [`run!`](@ref) is dropped too, since `run!` clears
the word as it starts. One issued before [`step!`](@ref) ends that call at once,
with 0 frames advanced and the simulation `stopped`, since `step!` never clears
the word.
"""
stop!(sim::Simulation) = _request_stop!(sim.control, :code)

# Design: §12.1, D-268.
"""
    pause!(sim::Simulation) -> Nothing

Pause the loop at the start of its next [frame](@ref g-frame), from any task and
in any lifecycle state.

`pause!` sets the pause flag of the [control plane](@ref g-control-plane). The
loop reads it at each frame top and waits there, the frame in flight completed
and published, until [`resume!`](@ref) or a stop. A `pause!` before
[`run!`](@ref) starts the run paused at its first frame top, and [`step!`](@ref)
waits the same way. The flag is cleared as a run shuts down, so a run never
hands its pause to the next.
"""
pause!(sim::Simulation) = (@atomic sim.control.paused = true; nothing)

# Design: §12.1, D-268.
"""
    resume!(sim::Simulation) -> Nothing

Clear the pause flag and wake a loop waiting at the start of its
[frame](@ref g-frame), from any task.

`resume!` is legal in any lifecycle state, and has no effect while the loop is
not paused. See [`pause!`](@ref).
"""
function resume!(sim::Simulation)
    control = sim.control
    @atomic control.paused = false
    lock(control.wake)
    try
        notify(control.wake)
    finally
        unlock(control.wake)
    end
    nothing
end

# Design: §12.1, D-268.
"""
    paused(sim::Simulation) -> Bool

Return whether the pause flag is set.

`paused` is legal in every lifecycle state. [`pause!`](@ref) sets the flag, and
[`resume!`](@ref) clears it.
"""
paused(sim::Simulation) = @atomic sim.control.paused

# Design: §10.7, §12.1, D-269.
"""
    pace!(sim::Simulation, p) -> Nothing

Set the pace, in simulated seconds per wall-clock second, from any task and in
any lifecycle state.

`p` is a positive real, `Inf` turning [pacing](@ref g-pacing) off, and anything
else is refused as `ArgumentInvalid`. The loop reads the pace at each
[frame top](@ref g-frame), restarts its schedule there and applies the new pace
forward, so a change made during a frame's wait takes effect at the next frame
top. [`run!`](@ref) and [`replay!`](@ref) write their own `pace` keyword as they
start, and [`step!`](@ref) never waits, whatever the pace.
"""
pace!(sim::Simulation, p) = (@atomic sim.control.pace = _pace_value(p, :pace!); nothing)

# Design: §10.7, §12.1, D-269.
"""
    margin!(sim::Simulation, m) -> Nothing

Set the margin, the seconds of each [pacing](@ref g-pacing) wait spent spinning
rather than sleeping, from any task.

`m` is a non-negative real, `0` for pure sleep and `Inf` for pure spin, and
anything else is refused as `ArgumentInvalid`. `margin!` is legal in any
lifecycle state. The margin tunes how a wait is spent, never when it ends, so a
change during a run leaves the pacing schedule as it was.
"""
margin!(sim::Simulation, m) =
    (@atomic sim.control.margin = _margin_value(m, :margin!); nothing)

# Design: §10.7, D-269.
"""
    pace(sim::Simulation) -> Float64

Return the pace, in simulated seconds per wall-clock second.

`pace` reads the [control plane](@ref g-control-plane), and is legal in every
lifecycle state. [`pace!`](@ref) sets it.
"""
pace(sim::Simulation) = @atomic sim.control.pace

# Design: §10.7, D-269.
"""
    margin(sim::Simulation) -> Float64

Return the margin, the seconds of each [pacing](@ref g-pacing) wait spent
spinning rather than sleeping.

`margin` reads the [control plane](@ref g-control-plane), and is legal in every
lifecycle state. [`margin!`](@ref) sets it.
"""
margin(sim::Simulation) = @atomic sim.control.margin

# --- the roster (§11.3): stopped-sim configuration -----------------------------

# Design: §11.1, §11.2, §11.3, §11.4, §11.6, §11.8, §12.4(6), §14.4, D-232,
# D-250.
# The roster is frozen per run, pause included. The binding's conformance check
# runs first (§11.6), then the two-part admission in spec order (§11.3):
# identity, then claims, so a `ClaimConflict` is always between two distinct
# devices. The greedy complement is computed at this instant and never
# recomputed. The entry's writer is compiled over the claim, and the harness
# writer's surface is recompiled to the complement that remains, renormalizing
# any pending harness batch (§11.4). `reads(new_binding)` is called once,
# resolved against the build and compiled to the one gather
# `gather(handle, snapshot)` runs (§11.2, §14.4). `should_abort` is §11.6's
# per-attachment failure policy, never a device property. The handle is
# devices.jl's, and the wrapper passes the same object to `loop(dev, handle)` on
# the device's task.
"""
    attach!(sim::Simulation, dev::AbstractDevice, new_binding::AbstractBinding;
            should_abort::Bool = false) -> DeviceHandle

Add a [device](@ref g-device) to the [roster](@ref g-roster) under a
[binding](@ref g-binding), and return the device's handle.

The roster is fixed for each run. `attach!` is therefore a
[stopped-sim](@ref g-stopped-sim) operation. It registers the device and spawns
nothing: the device's task starts with the next [`run!`](@ref).

The binding declares the device's sides. On the input side, the device's
[claim](@ref g-claim) is what the binding's [`claims`](@ref) returns, or, for a
binding declaring `is_greedy`, every [face](@ref g-face) no other device has
claimed at this moment. Attach a greedy device last: a second one gets an empty
claim, which is legal and warns `EmptyGreedyClaim`, into the device's
[diagnostic cell](@ref g-diagnostic-cell) and once as a logged warning. The
faces `stage!(sim, …)` may write shrink to what is left unclaimed. On the output
side, the binding's [`reads`](@ref) resolve against the build here, so a binding
that no longer matches its model fails at attach rather than sending wrong
values. An output-only binding claims nothing, and `stage!(sim, …)` keeps every
face.

The returned [`DeviceHandle`](@ref) is named by the device's stable id, and
carries what the device may do: read [snapshots](@ref g-snapshot), stage writes
and control the run. The device's `loop` receives the same handle.

# Keywords

- [`should_abort`](@ref g-should_abort): whether the device's departure also
  stops the run. Set, the device's loop returning, a crash or a failed `init!`
  requests a stop. Clear, the run continues without the device's task, and its
  claim holds until the run ends.

`attach!` is refused as `ServiceLifecycle` while `running`, and once `errored`,
since no run follows an errored simulation. A binding or device that breaks its
contract is refused as `BindingContractMismatch` or `DeviceContractMismatch`,
and a device instance already on the roster as `AlreadyAttached`; to rebind one,
[`detach!`](@ref) it first. A claimed name that is not a
[root input](@ref g-root-input) face is refused as `AttachUnknownFace`. A face
another device already claims is refused as `ClaimConflict`, and reads that do
not resolve as `ReadResolution`.
"""
function attach!(sim::Simulation, dev::AbstractDevice, new_binding::AbstractBinding;
                 should_abort::Bool = false)
    plane = sim.plane
    assert_configurable(sim, :attach!)
    check_binding(new_binding)
    check_device(dev, new_binding)
    for entry in plane.roster                          # identity, before claims (§11.3)
        entry.dev === dev && throw(DiagnosticError(AlreadyAttached(
            device = _typename(dev), incumbent = _who(entry),
            binding = _typename(binding(_handle(entry))))))
    end
    claim = is_input(new_binding) ?
        _claim(plane, sim.model.exec.act.layout, new_binding, _typename(dev)) : Symbol[]
    claim_diags = Diagnostic[]
    for face in claim                                 # claims: face exclusivity
        haskey(plane.claimedby, face) && push!(claim_diags, ClaimConflict(
            face = face, device = _typename(dev), incumbent = plane.claimedby[face]))
    end
    isempty(claim_diags) || throw(DiagnosticError(claim_diags))
    # The output side: reads → one gather, resolved before admission commits.
    gatherer = is_output(new_binding) ?
        _compile_binding_reads(reads(new_binding), typeof(new_binding),
                               sim.model.deployment.build) : nothing
    device_id = plane.next_id                             # assigned on admission alone: a
    plane.next_id += 1                             # rejected attach consumes no id
    writer = Writer(sim.model.exec.act.layout, claim)
    diag_cell = DiagCell(EMPTY_DIAG)                    # the device's diagnostic cell (§11.8)
    handle = DeviceHandle("device $device_id ($(_typename(dev)))", new_binding, writer,
                          plane.claimedby, sim.control, sim.plane.published, diag_cell,
                          gatherer, sim.model.deployment.build.structure, sim.model.exec.act.layout,
                          sim.control.counter, false)
    push!(plane.roster,
          RosterEntry(dev, device_id, _no_drain, should_abort, WriterAccount(), handle))
    # the thunk above is the sentinel: `reclaim!` appends the new writer set to
    # the trace's schema list and compiles every thunk against it (§11.5, D-261)
    reclaim!(plane, sim.model.exec.act.layout, sim.model.exec.store, sim.run.trace)
    if is_greedy(new_binding) && isempty(claim)
        # `attach!` mutates the roster, so the warning lives in the entry's own
        # cell (§11.3, §11.8, D-250): the first frame-top drain folds it into the
        # entry's account and every status from there on carries it. The line at
        # return stays, as presentation.
        empty_claim = EmptyGreedyClaim(device = "device $device_id ($(_typename(dev)))",
                                       binding = _typename(new_binding))
        report_cell!(diag_cell, empty_claim)
        @warn logline(empty_claim)
    end
    handle
end

# Design: D-244.
# The same stopped-sim gate as `attach!`. A pending undrained batch is discarded
# with the entry, detach being a deliberate reconfiguration.
"""
    detach!(sim::Simulation, dev::AbstractDevice) -> Nothing

Remove a [device](@ref g-device) from the [roster](@ref g-roster) and release
its [claim](@ref g-claim).

The [faces](@ref g-face) the device claimed return to the faces `stage!(sim, …)`
may write. A [batch](@ref g-batch) the device staged and the loop has not yet
applied is discarded. The [root inputs](@ref g-root-input) it fed keep their
last applied values. The device's id retires with its entry and is never reused.

The handle [`attach!`](@ref) returned stays valid for reads only: its `stage!`
and `report!` are refused as `DeviceContractMismatch` from here on.

`detach!` is refused as `ServiceLifecycle` while `running`, and once `errored`,
as `attach!` is. A device not on the roster is refused as `NotAttached`.
"""
function detach!(sim::Simulation, dev::AbstractDevice)
    plane = sim.plane
    assert_configurable(sim, :detach!)
    slot = findfirst(e -> e.dev === dev, plane.roster)
    slot === nothing && throw(DiagnosticError(NotAttached(
        device = _typename(dev), roster = [_who(e) for e in plane.roster])))
    @atomic :release plane.roster[slot].handle.detached = true   # D-244
    deleteat!(plane.roster, slot)
    reclaim!(plane, sim.model.exec.act.layout, sim.model.exec.store, sim.run.trace)
    nothing
end

# --- the data plane (§11): staging, the drain, publication ---------------------

# Design: §11.1, §11.3, §11.4, §11.8, D-192.
# The harness writer (§11.3). The coalescing policy is a CAS merge (§11.4).
# Every check runs here, on the writer's side. A device stages through the
# handle its `attach!` returned, `stage!(handle, writes...)` in devices.jl, the
# same shim against its own claim set.
"""
    stage!(sim::Simulation, writes::Pair...) -> Nothing

Stage a [batch](@ref g-batch) of [root-input](@ref g-root-input) writes through
the [harness writer](@ref g-harness-writer), from any task at any moment.

Each write is a `"face" => value` pair naming a root input. Together the writes
form a batch. The harness writer never touches a live root input. The batch
waits in its [staging cell](@ref g-staging-cell) and is applied at the top of
the next [frame](@ref g-frame) the loop advances. Batches merge, the newest
value winning per [face](@ref g-face), so a face not staged again keeps its
pending value.

A face outside the harness writer's [surface](@ref g-write-surface) is
discarded, as `ClaimedFaceEntry` when a rostered [device](@ref g-device)
[claims](@ref g-claim) it and as `OutOfClaimEntry` when nothing does. A rostered
greedy device leaves the harness writer no face at all. A value that does not
convert to the face's type is discarded as `EntryTypeMismatch`. The rest of the
batch stands, and the findings go to the harness writer's
[diagnostic cell](@ref g-diagnostic-cell), not to the caller. A device stages
through its [`DeviceHandle`](@ref) the same way, against its own claim.
"""
function stage!(sim::Simulation, writes::Pair...)
    plane = sim.plane
    harness = plane.harness
    batch = _normalize(harness, writes, plane.claimedby, plane.harness_diag)
    batch === nothing || stage_batch!(harness, batch)
    nothing
end

"""
The drain (§11.4): exactly one point in each frame, at its top, where the loop
takes each staged batch with one `atomicswap(cell, nothing)` — an indivisible
take, so there is no lost-write window — and applies it through the entry's
compiled scatter, masked-off positions skipped, every check long since spent
at staging.
Cells drain in attachment order, the harness writer's last by convention:
with every surface disjoint the order is unobservable, so the rule exists to
make the record read the same way every time, not to arbitrate (§11.3). Never
at a `t*` boundary (§10.4). Between drains the loop owns its data exclusively,
and the frame's outcome is a pure function of the drained batches.

The drain is also the trace's conversion site (§11.5, D-176): the drained
tuple is the *coalesced* truth, so each taken batch is recorded sparse against
its writer's schema on the way through — inside the thunk, where the writer's
index is closed over — and the trace's own drain count, which is that ordinal,
is advanced here, once, before any thunk runs.

And it is the site of replay's one substitution (D-274): in `:replay` the drain reads
the *trace* instead of the cells (`_replay_drain!` below). The branch is the
whole of the substitution — the live path underneath is untouched, which is
what "the ordinary loop" means (§12.7) — and what selects it is the attached
recording, which is what the input mode the caller reads *is* (§12.6, D-260).
"""
function drain!(sim::Simulation, roster::Vector{RosterEntry})
    plane = sim.plane
    # one drain per frame, counted before any thunk runs, on both paths: the
    # count is the recording's length (§11.5) *and* the ordinal each record
    # takes (D-260). The loop has advanced the run's frame index to `k` before
    # `frame!` runs the drain as its top hook, so a batch taken at the top of
    # frame `k` is recorded — and replayed — at `k` (D-317).
    trc = sim.run.trace
    trc === nothing || (trc.frames += 1)
    feed = sim.run.feed
    feed === nothing || return _replay_drain!(sim, roster, feed)
    # The diagnostic cells drain at the same point (§11.8): retained values into the
    # pending delta, every occurrence into the totals.
    for entry in roster
        entry.drain()
        _fold!(entry.account, _handle(entry).diag_cell)
    end
    plane.harness_drain()
    _fold!(plane.harness_account, plane.harness_diag)
    _fold!(sim.plane.loop_account, sim.plane.loop_diag)
    _fold!(sim.plane.loop_account, sim.model.frame_diag)   # the frame's own cell (§11.8, D-317)
    nothing
end

"""
Replay's one substitution (D-274): the frame's inputs come from the recording, and
the live cells are drained only to be *dropped*.

Every cell is still taken — the same indivisible swap, in the same order — so
nothing accumulates behind the replay and the continuation that may follow
starts clean; what changes is that the batch is discarded rather than applied,
and reported on its own writer's cell (§11.8's attribution rule: the emitting
site knows whose cell it writes). Mixing a live write into a replay would
destroy the property replay exists to provide (§12.7), and the rate limit
§11.8 asks for is structural: the drain takes each cell once per frame, and
coalescing makes a taken batch at most one per writer per frame.

The feed then applies every record whose frame has arrived — the compiled
scatters `_compile_feed` built against *this* layout, so no name is resolved
here either — and re-records each one under the recording's own writer index,
the header having been inherited (§12.7). The cursor only advances: the feed is
in drain order, and the loop visits frames in it.

The frame ordinal is the run's frame index, which the loop has already
advanced to this frame, rather than read off the trace: the records are keyed
by it and the discard reports name it, and under the kill switch there is no
trace to read it from (D-260, D-317).
"""
function _replay_drain!(sim::Simulation, roster::Vector{RosterEntry}, feed::ReplayFeed)
    plane = sim.plane
    frame = sim.run.frame
    for entry in roster
        handle = _handle(entry)
        _discard_staged!(handle.writer, handle.diag_cell, frame)
        _fold!(entry.account, handle.diag_cell)        # the diagnostic fold is the live path's, unchanged
    end
    _discard_staged!(plane.harness, plane.harness_diag, frame)
    _fold!(plane.harness_account, plane.harness_diag)
    _fold!(sim.plane.loop_account, sim.plane.loop_diag)
    _fold!(sim.plane.loop_account, sim.model.frame_diag)   # the frame's own cell (§11.8, D-317)
    i, record_count = feed.next, length(feed.records)
    # keyed exactly: the records are stably sorted by `(frame, writer)`, the entry
    # pass has validated every ordinal into the recording's frames, `replay!` has
    # started the cursor past the frame the feed starts from, and the loop visits
    # each frame after it up to `upto` once — so `==` cannot strand the cursor, and
    # the records past a `to_boundary` truncation are correctly left unapplied
    while i ≤ record_count && feed.records[i].frame == frame
        replay_record = feed.records[i]
        replay_record.thunk()
        # the recording's own `TraceBatch`, re-recorded as an equal value rather
        # than shared: re-recording is not a re-conversion — the prefix is
        # bit-identical by construction — but the two traces are two values
        trc = sim.run.trace
        trc === nothing || push!(trc.batches,
                                 TraceBatch(replay_record.record.frame,
                                            replay_record.record.writer,
                                            copy(replay_record.record.entries)))
        i += 1
    end
    feed.next = i
    nothing
end

# One cell's take under a feed (§12.7): the batch is dropped, and what the drop
# cost — the faces it touched, read off the mask against the writer's schema —
# is reported on the writer's own diagnostic cell.
function _discard_staged!(writer::Writer, cell::DiagCell, frame::Int)
    ref = @atomicswap writer.cell.pending = nothing
    ref === nothing && return nothing
    mask = ref[].mask
    report_cell!(cell, ReplayDiscardedStaging(Symbol[writer.faces[i] for i in 1:length(mask)
                                                     if mask[i]],
                                              frame))
    nothing
end

"""
Publish this boundary (§11.2): build the snapshot in private memory — one
buffer copy, the framework side of §9.8's scope — then a single release-store
to `latest`. Runs only after the boundary sequence completes, so every
published table is boundary-consistent (§10.3), and the copy is what makes the
binding rule hold: nothing reachable from a published snapshot is ever written
again. The framework status is built here too (§11.8): each writer's record
takes the account's pending delta — so the drain's `recent` rides exactly one
snapshot, the first published after the frame top — beside the totals copy,
the heartbeat acquire-load and the `task_state` read off the run's `Task`
handle (D-193), fresh at every publication. Behind the store the snapshot
enters the log (§11.2) — logging dissolves into publication, retention being
the only thing the log adds — and the §12.3 counter increments under its
lock, *after* the release-store: the normative order, so a waiter observing
the new count finds at least this boundary in `latest`. The snapshot's
ordinal is the trajectory's, off the run (D-230, D-317); the counter is the
wait predicate's alone.
"""
function publish!(sim::Simulation, roster::Vector{RosterEntry},
                  pacer::Union{Nothing,Pacer} = nothing)
    control = sim.control
    run = sim.run
    snapshot = Snapshot(sim.model.exec.clock.t, run.frame, run.boundary,
                        capture_stores(sim.model.exec.store),
                        sim.model.exec.act.layout, _status(sim, roster, pacer))
    run.boundary += 1
    @atomic :release sim.plane.published.latest = snapshot
    # reloaded, so the log stores the box the release-store made (§9.8)
    log!(sim.run.log, (@atomic :monotonic sim.plane.published.latest)::Snapshot,
         typeof(snapshot))
    lock(control.wake)
    try
        control.counter += 1
        notify(control.wake)
    finally
        unlock(control.wake)
    end
    nothing
end

# One writer's record (§11.8): the account's pending delta is *taken* — the
# status owns the vector, the account re-arms the shared empty — and the
# totals, isbits, copy by read. `heartbeat` and `task_state` are `nothing` for
# the two writers with no task of their own.
function _writer_status(who::String, account::WriterAccount, heartbeat, task_state)
    status = WriterStatus(who, account.recent, account.suppressed, account.totals, heartbeat,
                          task_state)
    account.recent = EMPTY_RECENT
    account.suppressed = KindCounts()
    status
end

# The status assembly (§11.8, §11.2), on the publishing task: per-writer
# records in the drain's order — devices in attachment order, then the
# harness writer, then the loop itself — and the pacer's record beside them,
# `Inf` and zeros where no pacer runs (§10.7). A device with no registered task
# reads `:done` inside a run and `:none` outside one (§12.2); the sticky status
# is what tells the two apart, since `step!` holds `:running` with no task.
function _status(sim::Simulation, roster::Vector{RosterEntry}, pacer::Union{Nothing,Pacer})
    plane, control = sim.plane, sim.control
    no_task_state = (@atomic control.stopped) ? :none : :done
    statuses = Vector{WriterStatus}(undef, length(roster) + 2)
    for (i, entry) in enumerate(roster)
        task = @lock control.wake get(plane.run_tasks, entry.id, nothing)
        statuses[i] = _writer_status(_who(entry), entry.account, _heartbeat(_handle(entry).diag_cell),
                                     task === nothing ? no_task_state : _task_state(task))
    end
    statuses[end-1] = _writer_status("harness", plane.harness_account, nothing, nothing)
    statuses[end] = _writer_status("loop", sim.plane.loop_account, nothing, nothing)
    FrameworkStatus(statuses, PacerStatus(pacer))
end

# Design: §12.6.
# An acquire load. The calling task reads the same reference, §12.6's inspection
# read.
"""
    latest(sim::Simulation) -> Union{Nothing,Snapshot}

Return the most recently published [snapshot](@ref g-snapshot), or `nothing`
before anything is published.

A snapshot is a coherent view of the [signal table](@ref g-signal-table) at one
[boundary](@ref g-boundary). A reader on any task may hold it for as long as it
likes without coordinating with the loop, since nothing in it is ever written
again. Read a [port](@ref g-port) off it with `port(snapshot, path, name)`, one
of the methods of [`port`](@ref).
"""
latest(sim::Simulation) = @atomic :acquire sim.plane.published.latest

# Design: §11.2, §11.3.
# A stopped-sim read behind the §11.3 gate: the log is loop-task bookkeeping, so
# reading it beside a running loop is the same hazard class as a mid-run
# `attach!`. The switch gates retention wholesale.
"""
    logged(sim::Simulation) -> Vector{<:Snapshot}

Return the [log](@ref g-log)'s retained [snapshots](@ref g-snapshot), oldest
first.

The log keeps the run's first snapshot, a middle thinned to every `log_every`-th
[boundary](@ref g-boundary) or coarser once `log_max` is reached, and the latest
published snapshot, each once. The element type is the run's concrete snapshot
type, the type [`latest`](@ref) returns, whether the vector is empty or not. The
vector is empty before anything is published, and under `log = false`.

`logged` is refused as `ServiceLifecycle` while the simulation is `running`. A
reader beside a running loop reads `latest(sim)` instead, and keeps the
snapshots it needs itself. To gather the log into columns, see [`series`](@ref).
"""
function logged(sim::Simulation)
    assert_stopped(sim, :logged)
    snapshot_log = sim.run.log
    retained = Snapshot{Float64,typeof(sim.model.exec.store)}[]
    snapshot_log.first === nothing && return retained
    push!(retained, snapshot_log.first)
    for snapshot in snapshot_log.snaps
        snapshot === nothing || push!(retained, snapshot)
    end
    snapshot_log.last === retained[end] || push!(retained, snapshot_log.last)
    retained
end

# Design: §11.2, Appendix B, D-407.
"""
    Series

The [log](@ref g-log) gathered into columns: the [snapshots](@ref g-snapshot)'
stamps and one typed vector per labeled read.

[`series`](@ref) returns it, gathered over the snapshots that [`logged`](@ref)
returns, oldest first. A series holds these fields, each vector with one entry
per snapshot.

- `t`: the snapshots' [boundary](@ref g-boundary) times.
- `frame`: their [frame](@ref g-frame) indices.
- `boundary`: their boundary ordinals.
- `columns`: a `NamedTuple` keyed as the [read set](@ref g-read-set) labels its
  entries, each column a plain vector of the entry's leaf type.
"""
struct Series{NT<:NamedTuple}
    t::Vector{Float64}
    frame::Vector{Int}
    boundary::Vector{Int}
    columns::NT
end

# Design: §11.2, §11.3, §14.4, D-406, D-407.
# Post-run extraction through the read-selector family. The read set resolves
# for a table source through the one resolver every reader shares (§14.4,
# D-406). Resolution runs once per call and the gather is one typed loop per
# column; the labels never reach a compiled body, so a new label set costs no
# compilation, only a new leaf type or chain does.
"""
    series(sim::Simulation, read_set::Reads) -> Series

Gather the [log](@ref g-log)'s retained [snapshots](@ref g-snapshot) into one
typed column per entry of a [read set](@ref g-read-set).

The read set comes from [`reads`](@ref), or mounted under a prefix with
[`at`](@ref). It resolves against the build, and each entry is gathered over the
snapshots [`logged`](@ref) returns into a plain vector of the entry's type. The
returned [`Series`](@ref) holds the snapshots' `t`, `frame` and `boundary`
beside `columns`, a `NamedTuple` keyed as the read set labels its entries. A new
set of labels costs no compilation; only a new leaf type does.

`series` is refused as `ServiceLifecycle` while `running`, as `logged` is.
Before anything is published the columns are empty, typed all the same. A bare
`NamedTuple` of [selectors](@ref g-selector) in place of a read set is refused
as `ReadSetMisuse`, and a selector that does not resolve as `ReadResolution`.
"""
function series(sim::Simulation, @nospecialize(read_set::Reads))
    assert_stopped(sim, :series)
    reader = _compile_reads(read_set, sim.model.deployment.build, Float64; source = :table)
    snapshots = logged(sim)
    columns = Any[_column(snapshots, entry) for entry in reader.entries]
    Series([s.t for s in snapshots], [s.frame for s in snapshots], [s.boundary for s in snapshots],
           NamedTuple{keys(read_set.selectors)}(Tuple(columns)))
end

# A bare NamedTuple of selectors is the read side's §14.2 misuse, refused with
# the directive `reads` names rather than a `MethodError`, as `_compile_reads`
# and `taps` refuse it (readers.jl).
series(::Simulation, other) = throw(DiagnosticError(
    ReadSetMisuse(observed = typeof(other), reason = :not_a_read_set)))

# One column, the function barrier: specialized on the entry's leaf type and
# chain alone, the eltype read off the resolved chain so an empty log yields
# a typed empty vector.
function _column(snapshots::Vector, entry::CellRead{A,C}) where {A,C}
    column = Vector{_resolved_type(_port_type(entry.addr), C)}(undef, length(snapshots))
    for (i, snapshot) in enumerate(snapshots)
        column[i] = _read(entry, snapshot.store)
    end
    column
end

# Design: §11.5, §12.6, §12.7, §13.4, D-029, D-038, D-261, D-274.
# The value is detached from the run's live trace. `MissingInit` names the way
# out exactly as an advance entry's refusal does. The lifecycle is read first:
# `built` is the placeholder run, or an `init!` whose boundary zero threw before
# the header was taken, and never the switch.
"""
    trace(sim::Simulation) -> Trace

Return a copy of the current run's input [trace](@ref g-trace), the value
[`replay!`](@ref) takes.

The trace holds its header and a sparse record. The header is the
[checkpoint](@ref g-checkpoint) the run opened from. The record keeps every
[batch](@ref g-batch) the loop applied since. The trace also holds the
[frame ordinal](@ref g-frame-ordinal) of the last. The state trajectory, the
[log](@ref g-log) included, is derived from it, never the reverse. The copy is
detached from the run, so later [frames](@ref g-frame) never reach it.

`trace` is refused as `MissingInit` while the simulation is `built`: before
[`init!`](@ref) or another call that opens a run, or after an `init!` whose
[boundary zero](@ref g-boundary-zero) threw. That throw leaves no trace, and
`init!` under the same [condition](@ref g-condition) reproduces it. Under the
opening call's `trace = false` it is refused as `ArgumentInvalid`.
"""
function trace(sim::Simulation)
    lifecycle_state = lifecycle(sim)
    trc = sim.run.trace
    lifecycle_state === :built &&
        throw(DiagnosticError(MissingInit(op = :trace, status = lifecycle_state)))
    trc === nothing &&        # §11.5's kill switch, which rides on the run's trace (D-260)
        throw(DiagnosticError(ArgumentInvalid(call = :trace, reason = :disabled)))
    Trace(_detach(trc.header), copy(trc.schemas), copy(trc.batches), trc.frames)
end

# The table's reads on the simulation, each forwarded to its model (model.jl, D-317).

# Design: §7.3, D-317.
"""
    port(sim::Simulation, path::String, name::Symbol)

Return a [port](@ref g-port)'s current value in the simulation's
[signal table](@ref g-signal-table).

A port is addressed by its [component](@ref g-component)'s path and its name. An
[assembly](@ref g-assembly)'s own path addresses its output
[faces](@ref g-face), and the empty path the [root inputs](@ref g-root-input).
The read is its model's, as `port(model, path, name)` gives it. To read a port
off a published [snapshot](@ref g-snapshot) instead, use
`port(snapshot, path, name)`.
"""
port(sim::Simulation, path::String, name::Symbol) = port(sim.model, path, name)
state(sim::Simulation, path::String) = state(sim.model, path)
modes(sim::Simulation, path::String) = modes(sim.model, path)
