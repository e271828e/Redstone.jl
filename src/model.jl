# The model layer (§9.2, §12.6, D-317): a deployment materialized at one
# scalar, and everything done to it with no simulation around it — the frame's
# hooks, the doors, evaluation, the boundaries, the stepper seam's framework
# side, the reads, the one `StepError` constructor and the checkpoint's
# model-level half, with its two doors `checkpoint(model)` and `restore!(model,
# model_state)`. Every door that writes the model's status lives here; the one
# other writer is `frame!`'s catch site (frame.jl).

# Design: §9.1, §9.2, §9.4, §9.5, §9.7, §11.8, §12.1, §12.6, §14.3, Appendix C,
# D-254, D-256, D-317, D-318, D-320.
# Deploying and materializing are two steps (D-254). The scalar picks the
# activation the entries compile over, through `activation(deployment.build,
# T)`, which serves the nominal `Float64` entry the build inserted and derives
# and caches any other (§9.4). Any other `T` is refused before an activation is
# read (§9.2, §9.5, D-320). `chunk_size` is the unroll width `compile` takes,
# refused with reason `:range` (Appendix C). The two other forms are defined as
# the compositions. The deployment is held once, and through it the build, the
# schema authority a condition resolves against (§9.1, §14.3): a second
# reference would be an invariant with no enforcer (§12.1, D-256). Every buffer
# set has exactly one owner, so a service invocation instantiates an executor
# of its own from the same cached layouts rather than writing through this one
# (§9.2, §9.7). Only the model's own doors and catch sites write `status`, and
# `lifecycle(sim)` reads it (§12.6, D-317). `claimed` is set by
# `Simulation(model)` through a compare-and-swap (§9.2, §12.6, D-318). A
# simulation's drain folds `frame_diag` into the loop's account beside the
# loop's own cell (§11.8, D-317). The claim's gate refuses the internal `apply!`
# on a claimed model as well.
"""
    Model(deployment::Deployment, ::Type{T} = Float64; chunk_size = 16) -> Model{T}
    Model(build::Build, ::Type{T} = Float64; h, N_base = nothing, Δt_base = nothing,
          algorithm = RK4, firing_budget = 4, localization_tol = 1e-6,
          localization_budget = 8, kw...) -> Model{T}
    Model(root::AbstractComponent, ::Type{T} = Float64; kw...) -> Model{T}

A deployment materialized at one scalar type `T`, ready to be written, evaluated
and stepped.

It carries the [`Deployment`](@ref) and the [executor](@ref g-executor) built
from it at `T`, with its [buffers](@ref g-buffer). It runs nothing in real time,
talks to no [device](@ref g-device) and records nothing. A [`Simulation`](@ref)
does that around a `Model{Float64}`. One deployment backs many models, and each
model owns its buffers alone.

`T` is `Float64` or a `ForwardDiff.Dual`, into which a `Float64` embeds exactly.
Any other `T` is refused as `ArgumentInvalid` with reason `:scalar`, before
anything is compiled.

`Model(build; kw...)` is `Model(Deployment(build; grid keywords...), T;
chunk_size)`, and `Model(root; kw...)` calls [`build`](@ref) first. The grid,
algorithm and event keywords are `Deployment`'s, documented and refused as
`DeploymentInvalid` there. `h` is required, as for [`Deployment`](@ref).

A model holds five values, each a field.

- `deployment`: the deployment it materializes, and through it the build.
- `exec`: the executor this model owns, with its stepper and its buffers.
- `status`: `:built` until [boundary zero](@ref g-boundary-zero) completes, and
  `:consistent` once it has completed or a state has been restored. A throw
  inside a [frame](@ref g-frame) writes `:inconsistent`, and a throw inside
  boundary zero writes `:built`. Only the model's own calls write it.
- `claimed`: set once a `Simulation` takes the model, and never cleared, so a
  simulation owns its model and never shares it. The model's own calls that
  write, such as [`init!`](@ref), [`frame!`](@ref), [`restore!`](@ref),
  [`overlay!`](@ref) and [`trim!`](@ref), refuse a claimed model as
  `ArgumentInvalid`.
- `frame_diag`: the frame's own [diagnostic cell](@ref g-diagnostic-cell), where
  the [chattering](@ref g-chattering) and [firing-budget](@ref g-firing-budget)
  reports go. A simulation collects it at each frame top beside its own.

# Keywords

- `chunk_size`: the executor's unroll width, an integer of at least 1, refused
  as `ArgumentInvalid` otherwise. It never changes the trajectory.

See also [`Deployment`](@ref), [`Simulation`](@ref), [`init!`](@ref),
[`frame!`](@ref).
"""
mutable struct Model{T,E}
    const deployment::Deployment
    const exec::E
    @atomic status::Symbol
    @atomic claimed::Bool
    const frame_diag::DiagCell
end

function Model(deployment::Deployment, ::Type{T} = Float64; chunk_size = 16) where {T}
    T === Float64 || T <: ForwardDiff.Dual || throw(DiagnosticError(
        ArgumentInvalid(call = :Model, reason = :scalar, argument = :T, value = T)))
    # The call's keyword is not a deployment parameter, so it is an
    # `ArgumentInvalid`, collected as the call's one throw (Appendix C, D-256).
    diags = Diagnostic[]
    chunk_size isa Integer && chunk_size ≥ 1 ||
        push!(diags, ArgumentInvalid(call = :Model, reason = :range,
                                     argument = :chunk_size, value = chunk_size))
    isempty(diags) || throw(DiagnosticError(diags))
    act = activation(deployment.build, T)
    exec = compile(deployment.build, act, deployment.schedule; chunk_size = Int(chunk_size),
                   algorithm = deployment.algorithm)
    Model{T,typeof(exec)}(deployment, exec, :built, false, DiagCell(EMPTY_DIAG))
end

# The two sugar forms, each *defined as* the composition (§9.2, D-254).
Model(build::Build, ::Type{T} = Float64; h = nothing, N_base = nothing,
      Δt_base = nothing, algorithm = RK4, firing_budget = 4,
      localization_tol = 1e-6, localization_budget = 8, kw...) where {T} =
    Model(Deployment(build; h, N_base, Δt_base, algorithm, firing_budget,
                     localization_tol, localization_budget), T; kw...)
Model(root::AbstractComponent, ::Type{T} = Float64; kw...) where {T} =
    Model(build(root), T; kw...)

# --- the seeded-half scratch world (§14.8, D-213) ------------------------------
# Shared by the two stopped-sim services, trim.jl and linearize.jl, which run
# the same two-half scratch world, with and without a commit.

# One scratch model: the same buffer set the model owns, at whatever scalar,
# from the same cached activation and the same deployment — and it dies with
# the call (§9.2, §14.8, glossary `scratch`, D-317).
_scratch(model::Model, ::Type{T}) where {T} =
    Model(model.deployment, T; chunk_size = model.exec.chunk_size)

# D-213's copy: a frozen component's stages are outside the seeded activation's
# executable set (§9.4), so its output cells can only come from the nominal half
# — where the authored `s` has just been published by the establishment round.
# A discrete producer's cells are pinned `Float64` at every activation, so this
# is a value copy; the zero-partial embedding happens where a continuous
# consumer reads them (§14.3).
function _establish_frozen!(seeded_exec::Executor, act::Activation{T},
                            nominal_exec::Executor, build::Build) where {T}
    for (ci, entry) in enumerate(build.structure.components)
        _frozen(entry.tier, T) || continue
        path = entry.path
        for name in _ports(build.outputs.components[ci])
            scatter_cell!(seeded_exec.store, act.layout.addr[(path, name)],
                     gather_cell(nominal_exec.store, nominal_exec.act.layout.addr[(path, name)]))
        end
    end
    nothing
end

# Design: §10.4, §11.2, D-317.
# A subtype is a struct with concrete fields, built once per advance. §11.2's
# rule that every boundary publishes before integration resumes is a contract
# on `settled!`. The simulation's hooks are `LoopHooks` (sim.jl).
"""
    FrameHooks

The abstract type of the hooks a model's [frame](@ref g-frame) calls at its top
and at each settled [boundary](@ref g-boundary).

[`frame!`](@ref) takes one `FrameHooks` value, as do the model's
[`init!`](@ref), [`restore!`](@ref) and [`overlay!`](@ref), and calls two
functions on it.

- [`frame_top!`](@ref) runs first, before the frame touches any state. It is
  where external inputs arrive.
- [`settled!`](@ref) runs at every settled boundary before integration resumes:
  each [localized](@ref g-localized) event time [`t*`](@ref g-t), the frame-top
  boundary that ends the frame, [boundary zero](@ref g-boundary-zero) under
  `init!`, and the boundary `overlay!` or `restore!` settles. It returns whether
  to abandon the frame's remainder, and a `true` is `frame!`'s return.

A subtype defines a method of each. Every boundary publishes before integration
resumes, so a subtype that publishes [snapshots](@ref g-snapshot) does it in
`settled!`. [`NoHooks`](@ref) does nothing and never abandons, for a model
stepped on its own. A [`Simulation`](@ref) passes hooks of its own, which apply
the staged input [batches](@ref g-batch) at the frame top and publish a snapshot
at each settled boundary.
"""
abstract type FrameHooks end

# Design: D-317.
"""
    NoHooks() -> NoHooks

The hooks of a model stepped on its own, which do nothing and never abandon a
[frame](@ref g-frame).

`NoHooks()` is the default `hooks` of [`frame!`](@ref) and of the model's
[`init!`](@ref), [`restore!`](@ref) and [`overlay!`](@ref). Its
[`frame_top!`](@ref) does nothing and its [`settled!`](@ref) returns `false`, so
a frame stepped with it always runs to its end and publishes nothing. See
[`FrameHooks`](@ref) for what hooks do.
"""
struct NoHooks <: FrameHooks end

# Design: §10.4, §13.4, D-317.
"""
    frame_top!(::NoHooks) -> Nothing

Do nothing at the top of a model's [frame](@ref g-frame), before the frame
touches any state.

A model stepped on its own takes no staged inputs, so its frame starts from the
state as it stands. See [`FrameHooks`](@ref) for the contract every method
keeps, and [`settled!`](@ref) for the other hook.
"""
frame_top!(::NoHooks) = nothing

# Design: §10.4, §13.4, D-317.
"""
    settled!(::NoHooks) -> Bool

Publish nothing at a settled [boundary](@ref g-boundary) of a model's
[frame](@ref g-frame), and return `false`.

A model stepped on its own publishes no [snapshot](@ref g-snapshot). It never
abandons the remainder of a frame, so [`frame!`](@ref) runs every frame to its
end. See [`FrameHooks`](@ref) for the contract every method keeps, and
[`frame_top!`](@ref) for the other hook.
"""
settled!(::NoHooks) = false

# The claim's gate at the top of each model door (D-318): a claimed model
# refuses every hooks but its simulation's. The `LoopHooks` method (sim.jl)
# returns `nothing`, so dispatch compiles the check away on the loop's path.
_claimed_gate(model::Model, ::FrameHooks, call::Symbol) =
    (@atomic :acquire model.claimed) && throw(DiagnosticError(ArgumentInvalid(
        call = call, reason = :claimed, argument = :model)))

# Design: §13.4, §14.3, §14.5, §14.6, D-223, D-317.
# The model's door into `:consistent`. The plan method, `init!(model,
# plan::ConditionPlan; t0, hooks)`, does the writes alone, so the simulation's
# `init!` can resolve before it touches its run. It hosts §13.4's catch around
# boundary zero (D-223), where a throw takes the one `StepError` constructor
# with the frame from the cursor. Nothing reads the return of `settled!(hooks)`
# here. An interrupt is not model code failing, and has no stop path here.
"""
    init!(model::Model, condition = set(); t0::Real = 0.0,
          hooks::FrameHooks = NoHooks()) -> Nothing

Initialize the model from a [condition](@ref g-condition) on the declared
defaults, and run [boundary zero](@ref g-boundary-zero) at `t0`.

`init!` resets the state to the declared defaults, applies the condition's
overrides and sets the clock to `t0`. It sets every event [prior](@ref g-prior)
to not [holding](@ref g-edge-semantics). It then runs boundary zero, which
settles through `settled!(hooks)`, and the model's status becomes `:consistent`.

The condition is built with [`set`](@ref) and its combinators.
[Root inputs](@ref g-root-input) have no declared default, so the condition must
give every one of them a value.

# Keywords

- `t0`: the start time, any real, held as a `Float64` origin.
- `hooks`: the [`FrameHooks`](@ref) boundary zero settles through,
  [`NoHooks`](@ref) for a model stepped on its own.

The condition resolves, and its root inputs are checked, before any write. A
condition that does not resolve against the build is refused as
`ConditionResolution`, and a root input it leaves without a value as
`UninitializedInputs`. A model claimed by a [`Simulation`](@ref) is refused as
`ArgumentInvalid`. A throw inside boundary zero arrives as a `StepError` at
`t0`, with pointer 0 and host `:boundary_zero`, and writes the status back to
`:built`. An [interrupt](@ref g-operator-interrupt) writes `:built` too, and
propagates unwrapped.
"""
function init!(model::Model{T}, condition = set(); kw...) where {T}
    _claimed_gate(model, get(kw, :hooks, NoHooks()), :init!)       # the claim is said first (D-318)
    plan = resolve_condition(condition, model.deployment.build, T)   # both refusals precede every write
    assert_total(plan, model.deployment.build.structure, :init!)     # (§14.6): all-or-nothing
    init!(model, plan; kw...)
end

function init!(model::Model{T}, plan::ConditionPlan; t0::Real = 0.0,
               hooks::FrameHooks = NoHooks()) where {T}
    _claimed_gate(model, hooks, :init!)
    exec = model.exec
    establish_defaults!(exec.xbuf, exec.sstores, exec.mstores,
                        model.deployment.build.structure.components,
                        activation(model.deployment.build, T).decls)   # D-063's reset
    _apply_plan!(model, plan)
    exec.clock.t = Float64(t0)        # the origin at the door, into the deployment's scalar (D-260)
    exec.clock.t₀ = Float64(t0)       # exact: the clock's origin is a `Float64` too
    fill!(exec.events.prior, false)   # every prior not-holding (§10.6)
    try
        boundary_zero!(model)
    catch err
        @atomic :release model.status = :built
        err isa InterruptException && rethrow()
        rethrow(_wrap_step(model, 0, :boundary_zero, err))
    end
    settled!(hooks)                   # the boundary-zero snapshot (§11.2, §14.5)
    @atomic :release model.status = :consistent   # boundary zero completed (D-317)
    nothing
end

# Design: §12.6, §14.1, §14.3, D-429.
# The state what-if on a model at rest, settled by boundary zero's tail with the
# discrete stages and updates skipped (`_settle!`). The plan method,
# `overlay!(model, plan::ConditionPlan; hooks)`, writes alone, so the
# simulation's `overlay!` can resolve before it touches its run. A plan carries
# the merge base it was resolved with: one resolved with the default `bases`
# merges a partial store entry onto the declared default.
"""
    overlay!(model::Model, condition = set();
             hooks::FrameHooks = NoHooks()) -> Nothing

Write a [condition](@ref g-condition) onto the model's state at rest, and settle
the result through the hooks.

The condition overwrites the [stores](@ref g-store) it names. Every other store,
the clock and the event [priors](@ref g-prior) are kept. A partial store entry
merges onto the current store rather than the declared default.
[Root-input](@ref g-root-input) entries write the root inputs'
[cells](@ref g-cell), and none is required, since every root input already holds
a value.

The overlaid state then settles. An overlaid `x` is projected and events fire
until none is left to fire, but no discrete output stage and no `s_update` runs.
An overlaid discrete store is therefore the state of the
[component](@ref g-component)'s next [tick](@ref g-tick), and its held output
stays until that tick. An event the overlay moves into
[holding](@ref g-edge-semantics) fires at once. The settled
[boundary](@ref g-boundary) goes through `settled!(hooks)`, and the status
returns to `:consistent`.

# Keywords

- `hooks`: the [`FrameHooks`](@ref) the settled boundary goes through,
  [`NoHooks`](@ref) for a model stepped on its own.

`overlay!` asks what [`checkpoint`](@ref) asks: the model `:consistent`, its
clock on a [frame top](@ref g-frame). Otherwise it is refused as
`ServiceLifecycle` or `CheckpointMidFrame`. The condition resolves against the
build with [`init!`](@ref)'s diagnostics, so one that does not resolve is
refused as `ConditionResolution`. A model claimed by a [`Simulation`](@ref) is
refused as `ArgumentInvalid`. A throw inside the settling arrives as a
`StepError` with host `:overlay` and the frame the clock sits at. It writes the
status back to `:built`, with the stores partly written as a failed
[boundary zero](@ref g-boundary-zero) leaves them.
"""
function overlay!(model::Model{T}, condition = set(); kw...) where {T}
    _claimed_gate(model, get(kw, :hooks, NoHooks()), :overlay!)
    _assert_at_rest(model, :overlay!)   # the stores are the merge base, so the gate precedes the resolve
    plan = resolve_condition(condition, model.deployment.build, T;
                             bases = _store_values(model.exec))
    overlay!(model, plan; kw...)
end

function overlay!(model::Model, plan::ConditionPlan; hooks::FrameHooks = NoHooks())
    _claimed_gate(model, hooks, :overlay!)
    k = _assert_at_rest(model, :overlay!)
    _apply_plan!(model, plan)
    try
        _settle!(model; fresh = false)
    catch err
        @atomic :release model.status = :built
        err isa InterruptException && rethrow()
        rethrow(_wrap_step(model, k, :overlay, err))
    end
    settled!(hooks)                   # the overlay boundary's snapshot (§11.2, §12.6)
    @atomic :release model.status = :consistent
    nothing
end

# The merge bases read off a model at rest (§14.1, D-429): the stores as they
# stand, in `_store_bases`' order, `nothing` where a component has none.
_store_values(exec::Executor) =
    [(store, ci, st === nothing ? nothing : st[])
     for ci in eachindex(exec.sstores) for (store, st) in ((:s, exec.sstores[ci]), (:m, exec.mstores[ci]))]

# The public door gates; the simulation's forwarding method and `init!` take
# the inner one (D-318).
apply!(model::Model, plan::ConditionPlan) =
    (_claimed_gate(model, NoHooks(), :apply!); _apply_plan!(model, plan))
_apply_plan!(model::Model, plan::ConditionPlan) = apply!(model.exec, plan)

# Design: §9.8.
# These are the bodies the loop runs, not re-derivations, which is what makes
# the §9.8 measurement honest. The empty `ticks` compiles to a no-op whose
# `@ballocated` assertion passes vacuously.
"""
    phase_bodies(model::Model) -> NamedTuple
    phase_bodies(sim::Simulation) -> NamedTuple

Return the compiled [phase bodies](@ref g-measurement-seam) the loop runs, bound
over the model's own [buffers](@ref g-buffer).

The bodies are the ones the loop runs, not copies, so an allocation measurement
over them measures the loop itself. A simulation's are its model's. The named
tuple holds four bodies, `sweep_1`, `sweep_2`, `rhs` and `ticks`, and two
dictionaries of zero-argument callables over the same buffers. `events` holds
the [guard](@ref g-guard) and the handler of each event, keyed by
`(path, name)`, and `projections` the `x_projection` call of each
[component](@ref g-component), keyed by path. The set is fixed: a model with no
discrete components still gets `ticks`, which does nothing, so code over the
bodies needs no branch per model.
"""
phase_bodies(model::Model) = model.exec.bodies

# --- the grid (§10.4) ----------------------------------------------------------
# Frame tops are `t₀ + k·h`, computed from the index and never accumulated; the
# frame driver (frame.jl), the checkpoint and the loop all read it from here.

"""Frame top `k`, computed from the index and `t₀` — never accumulated (§10.4).
The origin and the stride are both `Float64`, so the top is one too, and the
clock write below converts it into the deployment's scalar (D-260)."""
_grid_time(model::Model, k::Int) = model.exec.clock.t₀ + k * model.deployment.h

# Whole frames from the origin `t₀` until the grid boundary `t₀ + k·h` first
# reaches the bound `t` (§12.4, §12.6), and its floor sibling, the last
# boundary at or before `t`. Both carry a slack of a few ulps in frame units,
# at the larger of `|t|` and `|t₀|`, since `t₀ + k·h` and `t - t₀` both round
# at that magnitude. `0.3/0.1` is `2.9999999999999996`, and at `t₀ = -0.3` the
# loop writes frame 3's time as `5.6e-17`, whose own ulps absorb none of that.
# `t` and `t₀` are any reals; the step is `Float64` (D-260).
_frame_slack(t::Real, t₀::Real, h::Float64) = 4 * eps(max(abs(t), abs(t₀))) / h
function _frames_to(t::Real, t₀::Real, h::Float64)
    isinf(t) && return typemax(Int)
    max(0, ceil(Int, (t - t₀) / h - _frame_slack(t, t₀, h)))
end
_frame_at(t::Real, t₀::Real, h::Float64) = floor(Int, (t - t₀) / h + _frame_slack(t, t₀, h))

# --- evaluation ---------------------------------------------------------------

"""
One RHS evaluation: *evaluating the RHS means running the sweep* (§5.3). The
interior variant of each sweep block, then the `x_deriv` block
against the complete fresh table. Leaves `ẋbuf` holding the derivative of
whatever `xbuf` holds.
"""
@inline function evaluate!(exec::Executor)
    exec.cursor.index += 1          # §13.4: the stage ordinal counts RHS evaluations,
    exec.bodies.sweep_1()           # so the backends stay untouched
    exec.bodies.sweep_2()
    exec.bodies.rhs()
    nothing
end

@inline evaluate!(model::Model) = evaluate!(model.exec)

"""
The boundary macro-sequence at a base tick, final form (§5.3, §10.6):

> integrate → project → [sweep → guards → handlers] iterated to quiescence
> (under the firing budget) → all due `s_update` calls

Integration has just written the state, so projection runs first — between the
write and its decode; the event phase then iterates with the due set fixed for
the whole boundary, and the due updates run last, after quiescence, reading
post-transition values off the settled table. Output stages before updates, so
a discrete component's cells carry `y[k]` computed from `s[k]` while
`s_update` produces `s[k+1]` — the sampled-data recursion, ordered by
construction rather than by convention.

The three boundary routines run on the model, and the event phase reports a
`FiringBudget` into the model's `frame_diag` (§11.8, D-317).
"""
@inline function boundary!(model::Model, tick::Int)
    cursor = model.exec.cursor
    _phase!(cursor, :project)
    _projects!(model.exec.events, model.exec.xbuf)
    event_phase!(model, tick)
    _phase!(cursor, :ticks)
    model.exec.bodies.ticks(tick)
    nothing
end

"""
The macro-sequence at a step boundary that is *not* a base tick: the tick
counter has not advanced, so the due set is empty — and emptiness is arity
selection, never a sentinel index failing every gate (§10.5, D-185). The
zero-arg interior bodies are exactly the boundary walk with every discrete
entry gated out, so consistency is restored and nothing discrete can move;
projection and the event phase run in full — every step boundary is a boundary
(§10.4).
"""
@inline function offtick_boundary!(model::Model)
    _phase!(model.exec.cursor, :project)
    _projects!(model.exec.events, model.exec.xbuf)
    event_phase!(model, nothing)
    nothing
end

"""
Boundary zero's macro-sequence (§14.5, D-205): the ordinary one, with the
sweep's discrete entries admitted **due or not**. Every output stage runs and
publishes — from the authored `s` and the `t₀` table, in the ordinary sorted
walk — so the `t₀` snapshot carries the authored world fully evaluated and no
published cell holds the probe's synthesized values (§14.6's barrier extended
from the root inputs to the whole table).

The `s_update` calls keep the ordinary gate at index 0, which under the
canonical residue admits exactly `Φ = 0` (§10.5): that evaluation is
establishment, not a scheduled sample, and an offset component's first
*consumed* sample stays its `Φ·Δt_base` tick's. A component frozen at a
non-nominal activation has no entries here at all (§9.4's executable set), so
its pinned cells keep the carried nominal products — at boundary zero as
everywhere.

Never called bare: the model's `init!` (above) hosts it, the one door
that runs it (D-274), wrapping a throw as §13.4's catch does (D-223, D-317).
"""
@inline boundary_zero!(model::Model) = _settle!(model; fresh = true)

# The settling routine both doors call (§14.5, §12.6, D-429): boundary zero's
# tail, projection and the event phase to quiescence, with one flag. Fresh, the
# sweep admits every discrete output stage and the due updates run, boundary
# zero's two amendments (D-205, D-067). Continuing, under `overlay!`, the sweep
# is the off-tick one with every discrete entry gated out and no update runs:
# an overlaid store is the next tick's state and its held cell stays (D-273).
# The priors are the doors' business: `init!` resets them, `overlay!` keeps
# them, so only a guard the overlay moved into holding fires here.
@inline function _settle!(model::Model; fresh::Bool)
    cursor = model.exec.cursor
    _phase!(cursor, :project)
    _projects!(model.exec.events, model.exec.xbuf)
    if fresh
        event_phase!(model, ESTABLISH)
        _phase!(cursor, :ticks)
        model.exec.bodies.ticks(0)
    else
        event_phase!(model, nothing)
    end
    nothing
end

# One iteration round's sweep: the whole gated schedule (§10.6), in the due-set
# arity the boundary fixed — never the update laws, which wait for quiescence.
@inline _round!(exec::Executor, tick::Int) =
    (exec.bodies.sweep_1(tick); exec.bodies.sweep_2(tick); nothing)
@inline _round!(exec::Executor, ::Nothing) =
    (exec.bodies.sweep_1(); exec.bodies.sweep_2(); nothing)
# Boundary zero's round: the whole schedule, gated by nothing (§14.5, D-205).
@inline _round!(exec::Executor, tick::Establish) =
    (exec.bodies.sweep_1(tick); exec.bodies.sweep_2(tick); nothing)
@inline _round!(model::Model, tick) = _round!(model.exec, tick)

"""
The event phase (§10.6): [sweep → guards → handlers] iterated to quiescence,
the fixed point where a round of handlers fires nothing. The first round always
runs — it is the boundary sweep that restores table consistency — so a model
with no events degenerates to exactly that sweep, with no register work at all.

An event fires in a round iff its predicate is observed holding, the sample
observed before it was not-holding, and its firing count for this boundary is
below the budget; at most one event fires per component per round, the first
eligible in declaration order — priority with re-decision. The one register
subtlety is D-191's: an eligible-but-blocked event's last-observed sample is
*not* overwritten, so the edge it presented stands into the next round. Budget
exhaustion degrades rather than throwing: the event's further edges at this
boundary are lost under a `FiringBudget` warning, at most once per event per
boundary, while every other event iterates untouched. At quiescence the prior
is updated unconditionally from the final samples — every prior an honest
observation of a settled boundary.
"""
function event_phase!(model::Model, tick)
    events, cursor = model.exec.events, model.exec.cursor
    _phase!(cursor, :round, 1)       # §13.4: the boundary sweep is round 1, and the guard
    _round!(model, tick)            # walk and the fire walk of a round carry its index
    n_events = length(events.prior)
    n_events == 0 && return nothing
    copyto!(events.last, events.prior)
    fill!(events.count, 0)
    fill!(events.warned, false)
    budget = model.deployment.firing_budget
    while true
        _guards!(events, model.exec.store, model.exec.xbuf)
        fill!(events.comp_fired, false)
        any_fired = false
        for i in 1:n_events
            edge = !events.last[i] && events.now[i]
            eligible = edge && events.count[i] < budget
            if edge && !eligible && !events.warned[i]
                events.warned[i] = true       # at most one report per event per boundary
                (path, name) = events.names[i]
                # the frame's own cell (§11.8, D-317): folded at the next frame top
                report_cell!(model.frame_diag,
                             FiringBudget(path, name, _seconds(model.exec.clock.t), budget,
                                          events.count[i]))
            end
            firing = eligible && !events.comp_fired[events.owner[i]]
            events.fire[i] = firing
            if firing
                events.comp_fired[events.owner[i]] = true
                events.count[i] += 1
                any_fired = true
            end
            # A blocked edge stays unconsumed (D-191): only the eligible-but-
            # blocked sample stands; every other event takes this round's.
            (eligible && !firing) || (events.last[i] = events.now[i])
        end
        any_fired || break
        _fire!(events, model.exec.store, model.exec.xbuf)
        cursor.index += 1
        _round!(model, tick)
    end
    copyto!(events.prior, events.last)
    nothing
end

# --- the stepper seam, framework side (§10.2) ----------------------------------

"""
    integrate!(model, h)
    integrate!(sim, h)

Advance the continuous state from `t` by `h`, delegated across the stepper
seam to whichever backend the deployment bound (stepper.jl). The seam is never
entered empty: with no continuous state the step degenerates to advancing `t`,
the backend is simply not called, and no backend contract has to say what it
would do at N = 0.
"""
@inline function integrate!(model::Model, h)
    _phase!(model.exec.cursor, :integrate)     # §13.4: `evaluate!` counts the stages from here
    isempty(model.exec.xbuf) ? (model.exec.clock.t += h) : integrate!(model.exec.stepper, model, h)
    _check_finite!(model)
    nothing
end

# The boundary's first act (D-157, §13.4): one pass over the flat state buffer,
# immediately after the backend returns and before anything reads the state —
# `frame!`'s bare path and every segment of a localized frame alike, which is
# why the site is the seam's framework side and not the frame loop. `ẋ` does
# not participate: a nonfinite derivative contaminates its own block's step
# result within that very step, so this is the same detection with the same
# attribution, and `ẋ` is integrator scratch besides.
@inline function _check_finite!(model::Model)
    x = model.exec.xbuf
    @inbounds for i in eachindex(x)
        isfinite(x[i]) || _nonfinite(model, i)      # the throw is the cold path
    end
    nothing
end

# The owner of `flat_index` and its leaf within that component's block, both
# read off the layout's `xblocks`. Thrown as a fail-fast `DiagnosticError`, which
# the catch site's species rule unwraps into the `StepError`'s `cause`.
@noinline function _nonfinite(model::Model, flat_index::Int)
    exec = model.exec
    xblocks = exec.act.layout.xblocks
    owner = findfirst(b -> flat_index in b, xblocks)::Int
    cursor = exec.cursor                    # the phase stays `:integrate`, but the sweep is the
    cursor.comp = owner; cursor.fn = :none  # framework's own act between the stages and the
    cursor.index = 0                        # boundary — no stage of its own, so no ordinal
    x_leaf_names = leaf_names(typeof(exec.act.decls[owner].x))
    throw(DiagnosticError(NonfiniteState(
        path = model.deployment.build.structure.components[owner].path,
        leaf = x_leaf_names[flat_index - first(xblocks[owner]) + 1],
        value = exec.xbuf[flat_index],
        t = _seconds(exec.clock.t),
        # the frame-entry index, off the grid time the clock sits on: every
        # `integrate!` inside `frame!` ends at one, so rounding is exact at any
        # scalar. The counters are the run's, which the model never sees (D-317)
        boundary = round(Int, (_seconds(exec.clock.t) - exec.clock.t₀) / model.deployment.h) - 1)))
end

# Design: §9.2, §11.8, D-250.
"""
    warnings(model::Model) -> Vector{Diagnostic}
    warnings(sim::Simulation) -> Vector{Diagnostic}

Return the warnings raised while the model's build and deployment were
constructed.

The list is the build's warnings followed by the deployment's, and a
simulation's list is its model's. A warning raised while a run changes state
goes to the status each [snapshot](@ref g-snapshot) carries, so nothing raised
at run time is listed here.
"""
warnings(model::Model) = vcat(warnings(model.deployment.build), warnings(model.deployment))

# --- reading and writing the table outside the loop ---------------------------
# Path-addressed, dictionary-driven, deliberately off the measured path: these
# are boundary-time operations, never called from inside a phase body. Paths are
# §8.6's canonical strings, and an assembly's own path addresses its faces —
# which resolve to the cells they derive from.

# Design: §7.3, D-317.
"""
    port(model::Model, path::String, name::Symbol)

Return a [port](@ref g-port)'s current value in the model's
[signal table](@ref g-signal-table).

A port is addressed by its [component](@ref g-component)'s path and its name. An
[assembly](@ref g-assembly)'s own path addresses its output
[faces](@ref g-face), which resolve to the [cells](@ref g-cell) they derive
from, and the empty path the [root inputs](@ref g-root-input). A simulation's
`port(sim, path, name)` reads its model's. To read a port off a published
[snapshot](@ref g-snapshot) instead, use `port(snapshot, path, name)`.
"""
port(model::Model, path::String, name::Symbol) =
    gather_cell(model.exec.store, model.exec.act.layout.addr[(path, name)])

# Design: §7.3, D-317.
"""
    state(model::Model, path::String)
    state(sim::Simulation, path::String)

Return the state of the [component](@ref g-component) at `path`, from whichever
[store](@ref g-store) holds it.

A [continuous component](@ref g-continuous-component)'s state is its `x`, read
from the model's flat state [buffer](@ref g-buffer). A discrete component's is
its `s`, read from its own store. A simulation's state is its model's. For a
component's modes, see [`modes`](@ref).
"""
function state(model::Model{T}, path::String) where {T}
    ci = index_of(model.deployment.build.structure, path)
    model.exec.sstores[ci] === nothing || return model.exec.sstores[ci][]
    _tier(i) = model.deployment.build.structure.components[i].tier
    _decls(i) = declarations(model.deployment.build.structure.components[i].instance, _tier(i), T)
    x_offset = 0
    for i in 1:(ci-1)
        _tier(i) === CONTINUOUS && (x_offset += nleaves(typeof(_decls(i).x)))
    end
    reconstruct(typeof(_decls(ci).x), model.exec.xbuf, x_offset)
end

# Design: §7.3, D-317.
"""
    modes(model::Model, path::String)
    modes(sim::Simulation, path::String)

Return the modes of the [component](@ref g-component) at `path`, from its `m`
[store](@ref g-store).

The read changes nothing: only the component's event handlers write its modes.
A simulation's modes are its model's. For the rest of a component's state, see
[`state`](@ref).
"""
modes(model::Model, path::String) =
    model.exec.mstores[index_of(model.deployment.build.structure, path)][]

# The one `StepError` constructor (§13.4, D-059): the frame from the cursor, the
# clock at the failure, the frame-entry boundary as the replay pointer, the host
# its caller names, and the cause under the species rule below. Nothing inside
# the sequence throws a `StepError`, so one arriving here is an invariant firing,
# not a re-wrap. Two callers reach it, both the model's catch sites (D-317):
# `frame!` (frame.jl) as `:loop`, and the model's `init!` and `overlay!`
# (above) around their settling as `:boundary_zero` and `:overlay` (D-223,
# D-429). It stays the only constructor.
function _wrap_step(model::Model, entry_boundary::Int, host::Symbol, err)
    err isa StepError && throw(InternalInvariant(
        "a StepError reached the catch site (§13.4), which is its only constructor — " *
        "something inside the boundary sequence wrapped one"))
    cursor = model.exec.cursor
    StepError(CursorFrame(cursor.comp == 0 ? nothing :
                              model.deployment.build.structure.components[cursor.comp].path,
                          cursor.fn, cursor.phase, cursor.index),
              _seconds(model.exec.clock.t), entry_boundary, host, _species(model, err))
end

# The species rule (§13.4, D-221): a fail-fast carrier thrown inside the
# sequence arrives as its diagnostic unwrapped — which is what lets a runtime
# check (§9.5's conformance failure, the nonfinite sweep) be a plain thrower
# of its kind while the catch site stays the only wrap. A collected carrier has
# no single kind and rides as the cause it is.
_species(::Model, err) = err
_species(::Model, err::DiagnosticError{<:Diagnostic}) = err.carried

# §13.2's bundle-field match at runtime (D-248): a `FieldError` whose type is the
# bundle the cursor's function received is the bundle-law diagnostic, classified
# as at the probe. Any other `FieldError` is the author's own and rides as the
# cause it is. `UserCodeFraming` gets no runtime arm: the carrier already names
# the frame and the function through the cursor.
function _species(model::Model, err::FieldError)
    cursor = model.exec.cursor
    cursor.comp == 0 && return err
    ci, family = cursor.comp, cursor.fn
    comp_entry = model.deployment.build.structure.components[ci]
    comp, tier = comp_entry.instance, comp_entry.tier
    stage1_ports = tuple(model.deployment.build.outputs.components[ci].stage1...)
    # Reading the names invokes declarations, and a throw here would replace the
    # author's error, the cursor frame and the `StepError` with a frame of its own.
    legal_names = try
        family === :guard || family === :handler ?
            event_bundle_names(comp) :
        family === :y_state ?
            bundle_names(y_state, comp, tier, stage1_ports) :
        family === :y_direct ?
            bundle_names(y_direct, comp, tier, stage1_ports) :
        family === :x_deriv || family === :s_update ?
            bundle_names(update_of(tier), comp, tier, stage1_ports) :
        return err
    catch lookup_err
        lookup_err isa InterruptException && rethrow()
        return err
    end
    # By names, not by the exact type: the runtime bundle's value types differ
    # from the probe's at a non-nominal activation, and the names are the law's
    # invariant (§5.2).
    (err.type <: NamedTuple && fieldnames(err.type) == legal_names) || return err
    BundleFieldError(path = comp_entry.path, family = String(family),
                     tier = tier === CONTINUOUS ? :continuous : :discrete, field = err.field,
                     legal = collect(legal_names),
                     reason = classify_bundle_field(family, tier, err.field))
end

# The fingerprint off the model, one function for its two sides: the take
# writes it into the checkpoint and the check compares against it, since two
# spellings of one fingerprint would be a silent way for a restore to pass.
function _fingerprint(model::Model)
    exec = model.exec
    layout = exec.act.layout
    Fingerprint(copy(layout.sizes),
                Symbol[f for (f, _) in layout.root_inputs],
                String[entry.path for entry in model.deployment.build.structure.components],
                Any[isempty(decl.x) ? nothing : typeof(decl.x) for decl in exec.act.decls],
                Any[st === nothing ? nothing : typeof(st[]) for st in exec.sstores],
                Any[st === nothing ? nothing : typeof(st[]) for st in exec.mstores],
                sort!(Pair{Tuple{String,Symbol},Tuple{Any,Tuple}}[
                          key => (_port_type(addr), addr.offsets) for (key, addr) in layout.addr];
                      by = first),
                copy(exec.events.names))   # the priors' own index, empty off the nominal activation
end

# Design: §12.6, D-231, D-273, D-274, D-319, D-429.
# The stores are copied by value, being isbits (D-231). A `t*` abandon leaves
# the clock inside the frame, and the model steps whole frames, so a state taken
# there would have no next frame to continue on.
"""
    checkpoint(model::Model{T}) -> ModelState{T}

Return the model's state at the [frame top](@ref g-frame) its clock rests on.

The state, a [`ModelState`](@ref), holds the flat state [buffer](@ref g-buffer),
the `s` and `m` [stores](@ref g-store) and the whole
[signal table](@ref g-signal-table). It also holds the event
[priors](@ref g-prior). It holds the clock's `t` and `t₀`, and the
[fingerprint](@ref g-fingerprint). The stores are copied by value.
`checkpoint(sim)` wraps the same state with the run's frame index and
[boundary](@ref g-boundary) ordinal.

A model's state is not a [condition](@ref g-condition) and enters no condition
expression. [`restore!`](@ref) puts it back, and [`overlay!`](@ref) writes a
condition onto a model at rest.

`checkpoint` is legal while the model is `:consistent`, after [`init!`](@ref) or
a restore and before any throw. It is refused as `ServiceLifecycle` at `:built`
or `:inconsistent`. It is refused as `CheckpointMidFrame` with the clock off a
frame top, naming the frame the clock sits inside. A frame abandoned at a
[localized](@ref g-localized) event time [`t*`](@ref g-t) leaves the clock
there.
"""
function checkpoint(model::Model{T}) where {T}
    _assert_at_rest(model, :checkpoint)
    exec = model.exec
    clock = exec.clock
    s = Any[st === nothing ? nothing : st[] for st in exec.sstores]
    m = Any[st === nothing ? nothing : st[] for st in exec.mstores]
    checkpoint_stepper(exec.stepper)   # empty for a one-step method (stepper.jl)
    ModelState{T}(copy(exec.xbuf), s, m, capture_stores(exec.store), copy(exec.events.prior),
                  clock.t, clock.t₀, model.deployment, _fingerprint(model))
end

# The rest a `checkpoint` reads and an `overlay!` writes on (§12.6, D-274,
# D-429): the status `:consistent`, and the clock on a frame top. A frame top is
# exactly the time the loop writes there, `_grid_time` in the clock's scalar,
# and `_frames_to` names the frame the clock sits inside. Returns the frame.
function _assert_at_rest(model::Model, op::Symbol)
    model_status = @atomic :acquire model.status
    model_status === :consistent || throw(DiagnosticError(ServiceLifecycle(
        op = op, status = model_status, legal = [:consistent])))
    clock = model.exec.clock
    k = _frames_to(clock.t, clock.t₀, model.deployment.h)
    t_frame = _grid_time(model, k)
    clock.t == oftype(clock.t, t_frame) ||
        throw(DiagnosticError(CheckpointMidFrame(t = _seconds(clock.t), t_frame = t_frame,
                                                 frame = k)))
    k
end

# The fingerprint check the restoring doors and replay's entry pass share (§12.6,
# §12.7): the structural fingerprint compared field for field, then the two
# deployments as *values*, one `==` as D-254 asks, with `_walk_deployment!`
# (trace.jl) as its explanation. The clock is restored, never compared.
function _check_checkpoint!(diags::Vector{Diagnostic}, model::Model, model_state::ModelState)
    target = _fingerprint(model)
    recorded = model_state.layout
    recorded.sizes == target.sizes ||
        push!(diags, CheckpointMismatch(what = :store, name = :sizes,
                                        expected = recorded.sizes, found = target.sizes))
    recorded.paths == target.paths ||
        push!(diags, CheckpointMismatch(what = :store, name = :paths,
                                        expected = recorded.paths, found = target.paths))
    recorded.root_faces == target.root_faces ||
        push!(diags, CheckpointMismatch(what = :root_input,
                                        expected = recorded.root_faces,
                                        found = target.root_faces))
    # the per-component store types, only where the path lists agree on what a
    # component *index* means — otherwise the comparison would be by position
    # between two different models, and the path mismatch above is the honest fact
    if recorded.paths == target.paths
        for (i, path) in enumerate(target.paths)
            # the `x` type fixes the block's width and what each position holds
            recorded.xtypes[i] === target.xtypes[i] ||
                push!(diags, CheckpointMismatch(what = :store, path = path, name = :x,
                                                expected = recorded.xtypes[i],
                                                found = target.xtypes[i]))
            recorded.stypes[i] === target.stypes[i] ||
                push!(diags, CheckpointMismatch(what = :store, path = path, name = :s,
                                                expected = recorded.stypes[i],
                                                found = target.stypes[i]))
            recorded.mtypes[i] === target.mtypes[i] ||
                push!(diags, CheckpointMismatch(what = :store, path = path, name = :m,
                                                expected = recorded.mtypes[i],
                                                found = target.mtypes[i]))
        end
        recorded.addrs == target.addrs || _check_addresses!(diags, recorded.addrs, target.addrs)
        recorded.events == target.events ||
            push!(diags, CheckpointMismatch(what = :store, name = :events,
                                            expected = recorded.events, found = target.events))
    end
    model_state.deployment == model.deployment ||
        _walk_deployment!(diags, model_state.deployment, model.deployment)
    nothing
end

# The grid check every restore door shares (§12.6, D-319): the frame the state's
# clock sits inside, on its own origin and stride, by the arithmetic
# `checkpoint(model)` uses, a clock before `t₀` sitting in frame 0, and the
# clock exactly that frame's top in the state's scalar. Returns the frame.
function _check_grid!(diags::Vector{Diagnostic}, model_state::ModelState)
    t, t₀, h = model_state.t, model_state.t₀, model_state.deployment.h
    k = _frames_to(t, t₀, h)
    t_frame = t₀ + k * h
    t == oftype(t, t_frame) ||
        push!(diags, CheckpointMidFrame(t = _seconds(t), t_frame = t_frame, frame = k))
    k
end

# Design: §12.6, D-318, D-319.
# The mismatches are collected into one throw before any write. A state taken at
# another scalar is refused by dispatch.
"""
    restore!(model::Model{T}, model_state::ModelState{T};
             hooks::FrameHooks = NoHooks()) -> Nothing

Restore a model state into the model, and settle the restored
[boundary](@ref g-boundary) through the hooks.

`restore!` puts back a state that [`checkpoint`](@ref) took. It copies the state
back, settles the restored boundary through `settled!(hooks)`, and writes the
status `:consistent` last. No [boundary zero](@ref g-boundary-zero) runs. No
event [prior](@ref g-prior) resets either. The call accepts any status, so a
fresh `:built` model of the same deployment can take a state another model
produced.

# Keywords

- `hooks`: the [`FrameHooks`](@ref) the restored boundary settles through,
  [`NoHooks`](@ref) for a model stepped on its own.

A state whose [fingerprint](@ref g-fingerprint) or deployment does not match
this model is refused as `CheckpointMismatch`. One whose clock is off its own
grid is refused as `CheckpointMidFrame`, and all the mismatches come in one
throw before any write. A state taken at another scalar type is refused as
`CheckpointMismatch` too. A model claimed by a [`Simulation`](@ref) is refused
as `ArgumentInvalid`.
"""
function restore!(model::Model{T}, model_state::ModelState{T};
                  hooks::FrameHooks = NoHooks()) where {T}
    _claimed_gate(model, hooks, :restore!)
    diags = Diagnostic[]
    _check_checkpoint!(diags, model, model_state)
    _check_grid!(diags, model_state)
    isempty(diags) || throw(DiagnosticError(diags))
    _restore_state!(model, model_state; hooks)
end

# A state taken on a model at another scalar (D-319).
restore!(::Model{T}, ::ModelState{S}; kw...) where {T,S} =
    throw(DiagnosticError(CheckpointMismatch(what = :scalar, expected = S, found = T)))

# The inner restore, ungated, which the door above and the simulation's door
# body call (D-318, D-319), in `init!`'s shape: the state copied back, the
# restored boundary settled through `settled!(hooks)`, whose return nothing
# reads here, and the status written `:consistent` last.
function _restore_state!(model::Model, model_state::ModelState; hooks::FrameHooks = NoHooks())
    _restore_state!(model.exec, model_state)
    settled!(hooks)                   # the restored boundary's snapshot (§11.2, §12.6)
    @atomic :release model.status = :consistent
    nothing
end
