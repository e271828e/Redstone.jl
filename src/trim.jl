# The trim service (§14.7, §14.8): the problem value the aircraft author ships,
# the solver seam it is driven across, the in-house Levenberg–Marquardt behind
# that seam, and the report it comes back as.
#
# Everything the service needs already exists one file up. The write side is
# the condition algebra's two ways of applying one plan — the dynamic walk for
# the one setup application, the specialized `apply!` for the iterations
# (§14.4, D-066) — and the read side is the compiled reader (readers.jl). What
# trim adds is the loop between them, the vectorization at its edges, and the
# discipline the whole section is about: **the simulation's stores have
# exactly one writer, the commit through boundary zero**. Every evaluation
# happens on scratch executors the invocation instantiates and discards
# (§9.2's one-owner rule, §14.8's scratch-store paragraph), so a solve that
# does not converge leaves the simulation bit-for-bit untouched — "never
# initialized" included.
#
# The seeded-half machinery — `_scratch`, `_establish_frozen!` — is model.jl's,
# shared with linearize.jl, which runs the same two-half scratch world (D-213)
# without a commit.
#
# The service takes the `Model{Float64}` that holds the operating point
# (D-319). The simulation's method is sim.jl's: it gates on the lifecycle and
# hands `_verdict!` the simulation's own `init!` as the commit.

# --- the problem (§14.7) --------------------------------------------------------

# Design: §9.5, §14.4, §14.7, §14.8, §14.9, D-262.
# What the aircraft author ships. The field set is normative and closed
# (§14.7): there is no defaulting a half-specified problem into a solve. Order
# carries no semantics (§9.5), so a permuted bound spelling is a non-event
# rather than one variable's bound silently applied to another. `condition` is
# condition-valued (§14.9): a problem is an implicitly specified condition, and
# solving makes it explicit. The tolerances ride in the problem because a
# relocated problem carries its own convergence test (§14.7). Setup observes the
# check return's shape at the guess evaluation and can catch no more than that.
"""
    TrimProblem(; guess, lower, upper, condition, reads, residuals, tolerances,
                checks = _no_checks, check_tolerances = (;)) -> TrimProblem

The value a trim solves: the decisions to vary, the condition they set, and the
equations to satisfy.

A trim problem is a condition (the datum that says "set this build to this
state") given implicitly, as a function of decisions. [`trim!`](@ref) searches
the decisions for the point where every residual sits within its tolerance, and
commits the condition at that point. The first seven keywords are required, and
the two check keywords default to no checks.

# Keywords

- `guess`, `lower`, `upper`: the decisions' starting point and bounds, as
  `NamedTuple`s of `Float64` with one set of names. The names pair them, and
  setup reorders the bounds to `guess`'s order, so their spelling order does not
  matter.
- `condition`: a function of the decisions `d` that returns a condition.
  Everything fixed for the problem is closed over, and `d` is the one argument.
- `reads`: the read set (a [`Reads`](@ref) value, built by [`reads`](@ref))
  gathered after each evaluation.
- `residuals`: `residuals(reads::NamedTuple, d::NamedTuple) -> NamedTuple`, the
  residual system as named equations, never a scalar cost.
- `tolerances`: a `NamedTuple` of `Float64` with the residuals' names, each
  finite and positive. The problem carries its own convergence test, so the test
  moves with it when [`at`](@ref) scopes it.
- `checks`: `checks(reads::NamedTuple, d::NamedTuple) -> NamedTuple`, equations
  reported once at the committed state and never solved. The reads they use come
  from `reads`. The default returns `(;)`.
- `check_tolerances`: a `NamedTuple` of `Float64` with the checks' names. A
  check outside its tolerance warns `TrimCommitChecks`.

Constructing a problem validates nothing, since most of what it needs is only
checkable against a build: a selector (a deferred read naming one leaf) resolves
against a model, and the residual and check names are observed at one
evaluation at the guess. `trim!` checks the problem in two collecting passes,
and refuses it as `TrimProblemInvalid`. The first runs before any evaluation,
and the second checks the residual and check returns at the guess evaluation.
A check whose names depend on values, or that throws, fails at the commit after
the simulation has moved, as a residual does.
"""
struct TrimProblem{G,L,U,C,R,F,T,K,V}
    guess::G
    lower::L
    upper::U
    condition::C
    reads::R
    residuals::F
    tolerances::T
    checks::K
    check_tolerances::V
end

# The default check function: named, so the default problem's type prints as a name.
_no_checks(_, _) = (;)

TrimProblem(; guess, lower, upper, condition, reads, residuals, tolerances,
            checks = _no_checks, check_tolerances = (;)) =
    TrimProblem(guess, lower, upper, condition, reads, residuals, tolerances, checks,
                check_tolerances)

# Design: §14.9, D-277, D-278.
"""
    at(prefix::AbstractString, problem::TrimProblem) -> TrimProblem

Scope a trim problem under `prefix`, so that its paths resolve below that path.

`at` lifts the [`TrimProblem`](@ref) field by field. The `condition` function is
wrapped, so that each condition it returns is scoped under `prefix`. The `reads`
field is a read set (a [`Reads`](@ref) value naming each selector it reads). It
takes `prefix` at the front of its mount chain, the prefixes it is mounted
under. Every other field holds no path and passes through, the two check fields
included.

A `reads` field that is not a read set passes through untouched, so that
`trim!`'s setup names it. When `reads` is a read set, the lift refuses only an
empty prefix, as `ReadSetMisuse` from `at` on the read set.
"""
at(prefix::AbstractString, problem::TrimProblem) = TrimProblem(
    guess = problem.guess, lower = problem.lower, upper = problem.upper,
    condition = d -> at(prefix, problem.condition(d)),
    reads = problem.reads isa Reads ? at(prefix, problem.reads) : problem.reads,
    residuals = problem.residuals, tolerances = problem.tolerances,
    checks = problem.checks, check_tolerances = problem.check_tolerances)

"""
The service's own seeding tag (§9.4): an activation is keyed by a *concrete*
scalar, and `Dual{TrimTag,Float64,N}` is the one trim seeds its decisions
through. Owning the tag is what keeps a trim activation distinguishable from a
linearization's or a user's own.
"""
struct TrimTag end

# --- the report (§14.8) ---------------------------------------------------------

# Design: §14.5, §14.8, D-070, D-158, D-262.
# Non-convergence is an expected outcome: hitting the infeasible edge of an
# envelope is information, so it is reported, not thrown. There is no
# `committed` flag: a converged solve is always committable (§14.8), so the
# absence of the commit is the absence of `committed_residuals`. `saturated` is
# the classic CG-limit diagnostic (D-070). The backend's counts are
# authoritative over nothing (D-158).
"""
    TrimReport

The outcome of a trim: the verdict, the solution, and the numbers the verdict
was read off.

[`trim!`](@ref) returns a report, a value to read and never an exception to
catch. A solve that does not converge returns one too. A malformed problem is a
different case, and `trim!` refuses it at setup. A report holds these fields.

- `converged`: whether every residual sits within its tolerance at the returned
  point, tested by `trim!` in the residuals' own units. This verdict alone
  gates the commit.
- `solution`: the decisions at the returned point, shaped as `guess`, so the
  next problem can start from it through `merge`.
- `residuals`, `tolerances`: the residuals at the returned point, beside the
  tolerances they were tested against.
- `committed_residuals`: the residuals read again at the committed state, or
  `nothing` when nothing was committed. A converged solve always commits, so
  this field also tells whether the commit happened.
- `committed_checks`: the checks at the committed state, read from the same
  sweep. It is `(;)` when the problem declares no checks, and `nothing` when
  nothing was committed. A check outside its tolerance warns `TrimCommitChecks`.
- `status`, `n_evaluations`, `n_iterations`: the backend's own, recorded
  verbatim and deciding nothing. `:bypassed` is the status of a problem with no
  decisions, which makes no backend call.
- `saturated`: the decisions sitting at a bound at the returned point, as
  `(name, :lower)` or `(name, :upper)`.
- `fired_events`: the events boundary zero (the initialization boundary) fired
  at the commit, as `(path, name)`. A non-empty list means the committed stores
  sit past the events' handlers rather than at the reported solution, and a
  `TrimCommitEvents` warning comes with it.
"""
struct TrimReport
    converged::Bool
    solution::NamedTuple
    residuals::NamedTuple
    tolerances::NamedTuple
    committed_residuals::Union{Nothing,NamedTuple}
    committed_checks::Union{Nothing,NamedTuple}
    status::Symbol
    n_evaluations::Int
    n_iterations::Int
    saturated::Vector{Tuple{Symbol,Symbol}}
    fired_events::Vector{Tuple{String,Symbol}}
end

# --- the backend seam (§14.8) ---------------------------------------------------

# Design: §14.8.
# A pinned signature, value-passed. The backend sees vectors and never names:
# the declared side is canonical on both ends and the service has canonicalized
# before packing, so the solution unpacks by the order it was given. The
# Jacobian is requested by argument, so a Jacobian-free backend always passes
# `nothing` and there is still exactly one evaluation method to implement.
"""
    solve(backend, eval!, d0, lower, upper, tol) -> NamedTuple

Run the backend's search over packed decision vectors, and return the point it
reaches.

`solve` is the backend seam (the one method a trim solver implements). A new
backend type adds one method, `solve(backend::MyBackend, eval!, d0, lower,
upper, tol)`, and [`trim!`](@ref) calls it with vectors, never names. The
decisions are packed in `guess`'s order and the residuals in `tolerances`'
order, and the returned point unpacks by that order.

`eval!(r, J, d)` evaluates the problem at the decisions `d`, in place. It always
fills the residual vector `r`, and fills the Jacobian `J` only when
`J !== nothing`. A backend that needs no Jacobian always passes `nothing`.

`d0`, `lower` and `upper` are `Vector{Float64}`s in `guess`'s order, with `±Inf`
for an unbounded side, and `d0` already lies within the bounds. A backend that
ignores bounds ignores the two vectors. `tol` holds the tolerances in
`tolerances`' order. A backend may stop on it, but it decides nothing: `trim!`
tests convergence itself at the returned point.

The method returns `(; d, status, n_evaluations, n_iterations)`: the point
reached, a status symbol and the two counts. The status set is open, and the
[`TrimReport`](@ref) records it verbatim.
"""
function solve end

# Design: §10.2, §14.8.
# In-house, dense, about 100 lines: the §10.2 stepper precedent applied to the
# solver (a tiny needed core against a heavy dependency), sharpened by the fact
# that the per-residual physical tolerances are a convergence test no external
# package spells natively. Under this view "the tolerances are the stopping
# criterion" (§14.8), so the damping loop tests exactly what the service will
# re-test. A raw `norm(r)` sums forces against moments, and on a problem whose
# residuals differ by orders of magnitude in physical scale it can reject every
# projected step short of a point the box test would accept.
"""
    LevenbergMarquardt(; maxiter::Integer = 100,
                       λ₀::Real = 1e-3) -> LevenbergMarquardt

The default trim backend, a dense Levenberg–Marquardt solver that stops on the
problem's own tolerances.

Each iteration solves `(JᵀJ + λ·diag(JᵀJ)) δ = −Jᵀr` for a step, and projects
the step onto the bounds. A step is accepted when it lowers the normalized
residual norm `‖r ./ tol‖`. `λ` then shrinks by a factor of 10, and a rejected
step grows it by 10. The descent test and the stopping rule both measure the
residuals in their tolerances' units, the test [`trim!`](@ref) applies to the
result.

The solver stops with status `:converged` when every residual is within its
tolerance, `all(abs.(r) .≤ tol)`. It stops with `:maxiter` after `maxiter`
iterations. It stops with `:stalled` when no step lowers the residual norm: the
step is not finite, it falls below the rounding scale of the decisions it would
move, or every trial is rejected until the damping passes its ceiling.

# Keywords

- `maxiter`: the most iterations the solver runs.
- `λ₀`: the starting damping factor.

See also [`solve`](@ref).
"""
struct LevenbergMarquardt
    maxiter::Int
    λ₀::Float64
end

LevenbergMarquardt(; maxiter::Integer = 100, λ₀::Real = 1e-3) =
    LevenbergMarquardt(Int(maxiter), Float64(λ₀))

# The damping bracket. Below `λMIN` the damped normal equations are the
# undamped ones to rounding; above `λMAX` the step is `−Jᵀr/λ·diag` scaled into
# the noise, and a rejection there is a stall rather than a slower descent.
const LM_λMIN = 1e-12
const LM_λMAX = 1e12

_within(r, tol) = all(i -> abs(r[i]) ≤ tol[i], eachindex(r))

# The residual norm in the tolerances' own units — the descent test, measured
# where the box test is (§14.8). Written as a fold rather than `norm(r ./ tol)`
# so it costs no temporary.
_scaled_norm(r, tol) = sqrt(sum(i -> (r[i] / tol[i])^2, eachindex(r)))

function solve(backend::LevenbergMarquardt, eval!, d0::Vector{Float64},
               lower::Vector{Float64}, upper::Vector{Float64}, tol::Vector{Float64})
    n_decisions, n_residuals = length(d0), length(tol)
    d, r, J = copy(d0), zeros(n_residuals), zeros(n_residuals, n_decisions)
    d_trial, r_trial, J_trial = similar(d), similar(r), similar(J)
    eval!(r, J, d)
    n_evaluations, λ = 1, backend.λ₀

    for iteration in 1:backend.maxiter
        _within(r, tol) &&
            return (; d, status = :converged, n_evaluations, n_iterations = iteration - 1)
        # The normal equations of the linearized step, with Marquardt's own
        # scaling: the damping rides the curvature of each column rather than
        # the identity, so a decision the residuals barely respond to is not
        # frozen by the same λ that steadies a stiff one. A zero column — a
        # decision whose Jacobian entries all vanished, the saturated-actuator
        # case §14.7 names — takes the floor and keeps the system definite.
        JᵀJ, Jᵀr = J' * J, J' * r
        damping = Diagonal(max.(diag(JᵀJ), LM_λMIN))
        current_norm = _scaled_norm(r, tol)
        accepted = false
        while true
            δ = (JᵀJ + λ * damping) \ (-Jᵀr)
            all(isfinite, δ) || break
            @. d_trial = clamp(d + δ, lower, upper)          # step projection onto the box
            # A step the decisions cannot represent is the end of the descent,
            # whatever the residuals still are: reported as its own status, not
            # dressed up as convergence or as an exhausted iteration count.
            maximum(abs, d_trial .- d) ≤ eps(maximum(abs, d) + 1.0) && break
            eval!(r_trial, J_trial, d_trial)
            n_evaluations += 1
            if _scaled_norm(r_trial, tol) < current_norm
                d .= d_trial; r .= r_trial; J .= J_trial
                λ = max(λ / 10, LM_λMIN)
                accepted = true
                break
            end
            λ *= 10
            λ > LM_λMAX && break
        end
        accepted || return (; d, status = :stalled, n_evaluations,
                             n_iterations = iteration)
    end
    (; d, status = _within(r, tol) ? :converged : :maxiter, n_evaluations,
       n_iterations = backend.maxiter)
end

# --- setup validation (§14.7, §13.1) --------------------------------------------
# One collecting pass over what a build can answer, then the guess evaluation,
# which is where the residual return is observed. Both throws are §13.1's
# collecting form: `TrimProblemInvalid` values for the problem's own fields,
# with the read set's `ReadResolution` values spliced in beside them — the read
# keeps its own kind and the *problem* is what the setup is refusing, which is
# what `_resolve_reads` was factored apart for.

function _report_trim!(diags::Vector{Diagnostic})
    isempty(diags) && return nothing
    throw(DiagnosticError(diags))
end

_trim_violation(field::Symbol, reason::Symbol; kw...) =
    TrimProblemInvalid(; field = field, reason = reason, kw...)

# `guess`, `lower` and `upper`: NamedTuples, one key set between them, all
# fields `Float64`. The key-set comparison is by *set*, order being no
# mismatch — the canonicalization below pairs a permuted spelling by name.
function _check_decisions!(diags::Vector{Diagnostic}, problem::TrimProblem)
    named = true
    for (name, field_value) in
            ((:guess, problem.guess), (:lower, problem.lower), (:upper, problem.upper))
        field_value isa NamedTuple && continue
        push!(diags, _trim_violation(name, :not_a_namedtuple; observed = typeof(field_value)))
        named = false
    end
    named || return nothing
    for (name, field_value) in ((:lower, problem.lower), (:upper, problem.upper))
        Set(keys(field_value)) == Set(keys(problem.guess)) ||
            push!(diags, _trim_violation(name, :key_set; names = collect(keys(field_value)),
                                         expected = collect(keys(problem.guess))))
    end
    for (name, field_value) in
            ((:guess, problem.guess), (:lower, problem.lower), (:upper, problem.upper))
        _check_floats!(diags, name, field_value)
    end
    # And the box has to admit a point at all. Checked per decision, over the
    # pairs that survived the two checks above, because an inverted pair is a
    # box no projection can honor — `clamp` would answer the upper bound and
    # the report would name a saturation nobody authored.
    for key in keys(problem.guess)
        (haskey(problem.lower, key) && haskey(problem.upper, key) &&
         problem.lower[key] isa Float64 && problem.upper[key] isa Float64) || continue
        problem.lower[key] ≤ problem.upper[key] ||
            push!(diags, _trim_violation(:lower, :inverted_box; key = key,
                                         value = problem.lower[key], bound = problem.upper[key]))
    end
    nothing
end

# `tolerances` and `check_tolerances`, `name` saying which: a NamedTuple of
# `Float64`s, each finite and strictly positive.
# Positivity is essential rather than cosmetic. A tolerance is the half-width
# of the box its residual or check has to sit in, so zero and negative name no
# box at all. A residual's tolerance fails louder still: the acceptance test
# measures `‖r ./ tol`‖ (§14.8), so a non-positive one sends the descent test
# to `Inf`/`NaN`, rejects every trial step and returns `:stalled` at the guess.
# Nothing divides by a check tolerance, and a non-positive one names no box all
# the same. Either is a malformed problem, named here.
function _check_tolerances!(diags::Vector{Diagnostic}, name::Symbol, tolerances)
    if !(tolerances isa NamedTuple)
        push!(diags, _trim_violation(name, :not_a_namedtuple; observed = typeof(tolerances)))
        return nothing
    end
    _check_floats!(diags, name, tolerances)
    for key in keys(tolerances)
        tolerance = tolerances[key]
        tolerance isa Float64 || continue   # the type violation is already named above
        (isfinite(tolerance) && tolerance > 0) ||
            push!(diags, _trim_violation(name, :nonpositive_tolerance; key = key,
                                         value = tolerance))
    end
    nothing
end

function _check_floats!(diags::Vector{Diagnostic}, name::Symbol, field_value::NamedTuple)
    bad = Pair{Symbol,Any}[k => typeof(field_value[k]) for k in keys(field_value)
                           if !(field_value[k] isa Float64)]
    isempty(bad) || push!(diags, _trim_violation(name, :field_types; bad = bad))
    nothing
end

# The read set: a `reads(…)` value whose selectors resolve against this build.
# Its violations are §14.4's own `ReadResolution` values, spliced into this list
# as they are — the read is named as authored, with the list in hand — because
# here the *problem* is what is malformed (§14.8) and one throw reports both
# halves of it.
function _check_reads!(diags::Vector{Diagnostic}, problem::TrimProblem, build::Build)
    if !(problem.reads isa Reads)
        push!(diags, _trim_violation(:reads, :not_a_read_set; observed = typeof(problem.reads)))
        return nothing
    end
    (reader, read_violations) = _resolve_reads(problem.reads, build, Float64)
    append!(diags, read_violations)
    reader
end

# The residual or check return, `name` saying which, observed at the setup
# guess evaluation (§14.7): its key set is its tolerances' — order free, the
# return being reordered to it — and every field is a real scalar, both being
# named *equations*. Returns the violations for the caller to report.
function _check_equations(name::Symbol, returned, tolerances::NamedTuple)
    diags = Diagnostic[]
    if !(returned isa NamedTuple)
        push!(diags, _trim_violation(name, :not_a_namedtuple; observed = typeof(returned)))
    else
        Set(keys(returned)) == Set(keys(tolerances)) ||
            push!(diags, _trim_violation(name, :key_set; names = collect(keys(returned)),
                                         expected = collect(keys(tolerances))))
        bad = Pair{Symbol,Any}[k => typeof(returned[k]) for k in keys(returned)
                               if !(returned[k] isa Real)]
        isempty(bad) || push!(diags, _trim_violation(name, :field_types; bad = bad))
    end
    diags
end

# --- the service (§14.8) ---------------------------------------------------------

# Design: §9.4, §14.5, §14.6, §14.7, §14.8, D-205, D-213, D-318, D-319.
# The scratch world comes in two halves (D-213). Every invocation instantiates
# its own executors from the build's cached layouts and discards them with the
# call. Setup checks §14.6's root-input totality against the build's faces
# before any evaluation. The establishment round is boundary zero's sweep with
# every discrete output stage admitted, due or not (D-205), with no projection,
# no guards and no `s_update`. The seeded set is written by the specialized
# `apply!`, and its frozen cells are copied from the nominal set as zero-partial
# constants: at the seeded activation the discrete tier never runs (§9.4), so
# nothing there can derive a discrete output cell from the authored `s`, and
# without the copy those cells would hold the build probe's synthesized values,
# a fabricated zero being a fine probe input and a terrible flight condition
# (§14.6's barrier, reaching the scratch world). The iterations are raw write,
# sweep and read cycles at the seeded activation, the continuous chain and
# `x_deriv` alone, with no boundaries and no events (§14.5). The commit is the
# same composite over the same baseline as setup, so its totality is setup's and
# the check is structurally unfailable through this path. The zero-decision
# problem is free (§14.8). The commit is the model's own `init!`, so the claim
# is checked first (D-318, D-319).
"""
    trim!(model::Model{Float64}, problem::TrimProblem; baseline, t0::Real = 0.0,
          backend = LevenbergMarquardt()) -> TrimReport

Solve a trim problem on the model, and commit the solution through `init!`.

`trim!` searches the [`TrimProblem`](@ref)'s decisions for a point where every
residual sits within its tolerance. Every evaluation runs on scratch stores
(working storage the call creates and discards), so the search never writes the
model. Setup layers the problem's condition (the datum that says "set this build
to this state") at the guess over the baseline, as
`override(baseline, problem.condition(guess))`. It then runs one establishment
round: the sweep of boundary zero (the initialization boundary), with every
discrete output stage run and no projection, events or discrete update. Each
iteration then writes the decisions, sweeps the continuous chain and reads the
residuals, with no boundaries and no events. The discrete tier (the discrete
side of the hybrid model) does not run during the search, so its outputs hold
the values the
establishment round gave them. The Jacobian is exact, carried by dual numbers
through the same evaluation.

The verdict is `trim!`'s own. After the backend returns, `trim!` evaluates once
more at the returned point and tests each residual against its tolerance, in the
residuals' own units. That test sets the report's `converged`, whatever status
the backend gave. A solve that does not converge commits nothing and leaves the
model as it was, its status included: a `:built` model stays `:built`.
Non-convergence is reported in the [`TrimReport`](@ref), never thrown.

A converged solve commits through the model's own [`init!`](@ref), as
`init!(model, override(baseline, problem.condition(solution)); t0)`. Boundary
zero can then move the committed stores off the solved point, through
`x_projection` or an event whose guard already holds. `trim!` surfaces both: the
events fired, in the report's `fired_events` with a `TrimCommitEvents` warning,
and the residuals read again at the committed state, with a
`TrimCommitResiduals` warning when they leave their tolerances. The checks are
read from the same boundary-zero sweep, and `TrimCommitChecks` warns of those
outside their tolerances.

A problem with no decisions, `guess = (;)`, is legal. It skips the backend, its
establishment round is its one evaluation, and the ordinary tolerance test
decides. It answers whether the operating point is already an equilibrium, and
commits as usual when it is.

# Keywords

- `baseline`: the baseline (a full-coverage condition, layered under tweaks)
  the problem's condition is layered over, at setup and at the commit. Required.
  Together with the problem's condition at the guess, it must give every root
  input (the root component's own input faces) a value.
- `t0`: the start time of the committing boundary zero, any real, held as a
  `Float64` origin.
- `backend`: the solver, any value with a [`solve`](@ref) method.
  [`LevenbergMarquardt`](@ref) is the default.

The problem is checked in two collecting passes, each refused as
`TrimProblemInvalid`. The first runs before any evaluation, with the read set's
own `ReadResolution` failures beside the problem's faults. The second checks
the residual and check returns at the guess evaluation, and again at the first
seeded one. A root input the baseline and the guess's condition leave
without a value is refused as `UninitializedInputs`. A model a
[`Simulation`](@ref) has claimed is refused as `ArgumentInvalid`, before any
check. So is a second argument that is not a `TrimProblem`, and a model at a
scalar type other than `Float64`.
"""
function trim!(model::Model{Float64}, problem::TrimProblem; baseline,
               t0::Real = 0.0, backend = LevenbergMarquardt())
    _claimed_gate(model, NoHooks(), :trim!)   # the claim is said first: the call commits (D-318)
    solved = _solve_problem(model, problem; baseline, backend)
    _verdict!(model, problem, baseline, solved,
              condition -> init!(model, condition; t0 = Float64(t0)))
end

trim!(::Model, other; kw...) = throw(DiagnosticError(
    ArgumentInvalid(call = :trim!, argument = :problem, reason = :not_a_problem,
                    value = string(typeof(other)))))

# A model at another scalar: the commit needs the nominal world (D-319).
trim!(::Model{T}, ::TrimProblem; kw...) where {T} = throw(DiagnosticError(
    ArgumentInvalid(call = :trim!, reason = :non_nominal, value = "Model{$T}")))

# The solve, from the setup checks through the verdict's evaluation, on scratch
# models alone; the commit is the caller's (D-319). The bypassed zero-decision
# problem and the solved one return the same packing, what `_verdict!` reads.
function _solve_problem(model::Model{Float64}, problem::TrimProblem; baseline, backend)
    build = model.deployment.build
    diags = Diagnostic[]
    _check_decisions!(diags, problem)
    _check_tolerances!(diags, :tolerances, problem.tolerances)
    _check_tolerances!(diags, :check_tolerances, problem.check_tolerances)
    reader = _check_reads!(diags, problem, build)
    _report_trim!(diags)                       # one collected throw, before any evaluation

    guess, tolerances = problem.guess, problem.tolerances
    decision_names, residual_names = keys(guess), keys(tolerances)
    N = length(decision_names)
    tol = Float64[tolerances[k] for k in residual_names]

    # --- the nominal half (D-213) ------------------------------------------------
    nominal_exec = _scratch(model, Float64).exec
    plan = resolve_condition(override(baseline, problem.condition(guess)), build, Float64)
    assert_total(plan, build.structure, :trim!)    # (§14.6): pre-evaluation, all-or-nothing
    apply!(nominal_exec, plan)
    _round!(nominal_exec, ESTABLISH)          # every discrete output stage, due or not
    nominal_exec.bodies.rhs()
    gathered = gather_reads(reader, nominal_exec)
    r0 = problem.residuals(gathered, guess)
    c0 = problem.checks(gathered, guess)
    # Both returns, observed where §14.7 says, in one collected throw.
    append!(diags, _check_equations(:residuals, r0, tolerances))
    append!(diags, _check_equations(:checks, c0, problem.check_tolerances))
    _report_trim!(diags)

    if N == 0
        # The solver is bypassed outright: the establishment round above is the
        # one evaluation, and the ordinary box test decides (§14.8).
        r = Float64[NamedTuple{residual_names}(r0)[k] for k in residual_names]
        return (; solution = guess, r, tol, status = :bypassed, n_evaluations = 1,
                n_iterations = 0, saturated = Tuple{Symbol,Symbol}[], reader)
    end

    # --- the seeded half ---------------------------------------------------------
    T = ForwardDiff.Dual{TrimTag,Float64,N}
    act = activation(build, T)                # the cached activation (§9.4)
    seeded_exec = _scratch(model, T).exec
    _establish_frozen!(seeded_exec, act, nominal_exec, model.deployment.build)
    # The names enter the closure as types: captured as a `Tuple` of `Symbol`s,
    # they would leave every `NamedTuple` `eval!` builds to runtime dispatch.
    decision_keys, residual_keys = Val(decision_names), Val(residual_names)
    d_dual = _seeded(decision_keys, guess, T)
    seeded_plan = compile_plan(override(baseline, problem.condition(d_dual)), build, T)
    seeded_reader = _compile_reads(problem.reads, build, T)

    # One evaluation: write the decisions through the shape-compiled plan, sweep,
    # gather, and take `r` off the values and `J` off the partials of one and the
    # same seeded pass (§14.7).
    #
    # §14.7's return check runs a second time on the *first* seeded evaluation.
    # The nominal guess evaluation observes the return at `Float64`; a residual
    # lambda that branches on the scalar it is handed — on `eltype`, on a
    # method that has no `Dual` arm — can answer a different key set here, and
    # without the re-check the reorder below raises a bare `ErrorException`
    # from `NamedTuple{residual_names}` instead of the collected `TrimProblemInvalid`
    # that names what is wrong. Once only: the per-iteration path takes one `Bool`
    # load and no work at all.
    checked = Ref(false)
    function eval!(r::Vector{Float64}, J, d::Vector{Float64})
        decisions = _seeded(decision_keys, d, T)
        apply!(seeded_exec, seeded_plan, override(baseline, problem.condition(decisions)))
        evaluate!(seeded_exec)
        raw = problem.residuals(gather_reads(seeded_reader, seeded_exec), decisions)
        if !checked[]
            checked[] = true
            _report_trim!(_check_equations(:residuals, raw, tolerances))
        end
        residuals = _named(residual_keys, raw)
        for i in eachindex(r)
            residual = residuals[i]
            r[i] = ForwardDiff.value(residual)
            J === nothing && continue
            for j in 1:N
                J[i, j] = ForwardDiff.partials(residual, j)
            end
        end
        nothing
    end

    lower = Float64[problem.lower[k] for k in decision_names]
    upper = Float64[problem.upper[k] for k in decision_names]
    # The guess enters the box here, once. §14.8 honors bounds by step
    # projection, and a backend's returns that never *step* — the
    # already-within-tolerance return, a stall at the first iteration — would
    # otherwise hand back the unprojected guess: an out-of-box point committed
    # as converged, with `saturated` empty because it sits at no bound. Every
    # point the backend sees and returns lies in the box because the one it
    # starts from does.
    d0 = clamp.(Float64[guess[k] for k in decision_names], lower, upper)
    out = solve(backend, eval!, d0, lower, upper, tol)

    # The verdict, at the backend's returned point and in the service's own
    # units: one residual evaluation, noise against the solve that produced it.
    r = zeros(Float64, length(tol))
    eval!(r, nothing, out.d)
    (; solution = NamedTuple{decision_names}(Tuple(out.d)), r, tol, status = out.status,
       n_evaluations = out.n_evaluations, n_iterations = out.n_iterations,
       saturated = _saturated(decision_names, out.d, lower, upper), reader)
end

# --- the pieces the service is built out of --------------------------------------

# The decisions at the seeded activation: field `i` carrying the unit partial in
# slot `i`, which is what makes one sweep yield `r` and `J` together (§14.7).
# `decisions` is indexed positionally, so the packed vector and the guess
# NamedTuple seed through the same code.
_seeded(::Val{decision_names}, decisions,
        ::Type{ForwardDiff.Dual{TG,Float64,N}}) where {decision_names,TG,N} =
    NamedTuple{decision_names}(
        ntuple(i -> ForwardDiff.Dual{TG}(Float64(decisions[i]),
                                         ntuple(j -> Float64(i == j), Val(N))...),
               Val(N)))

# A returned `NamedTuple` reordered to the names the type carries.
_named(::Val{names}, values::NamedTuple) where {names} = NamedTuple{names}(values)

# The decisions sitting at a bound at the returned point (§14.8): the comparison
# is exact because the projection assigns the bound itself, and an infinite
# bound is never met by a finite decision.
function _saturated(decision_names::Tuple, d::Vector{Float64}, lower::Vector{Float64},
                    upper::Vector{Float64})
    out = Tuple{Symbol,Symbol}[]
    for i in eachindex(d)
        d[i] == lower[i] ? push!(out, (decision_names[i], :lower)) :
        d[i] == upper[i] && push!(out, (decision_names[i], :upper))
    end
    out
end

# The verdict, the commit and the report, shared by both forms — the solved
# problem and the bypassed zero-decision one, which differ in how they got their
# residual vector and in nothing after it (§14.8). `commit!` takes the committed
# condition into the caller's own `init!`, the model's or the simulation's, and
# the committed world is read off `model.exec` either way (D-319).
function _verdict!(model::Model, problem::TrimProblem, baseline, solved::NamedTuple, commit!)
    (; solution, r, tol, status, n_evaluations, n_iterations, saturated, reader) = solved
    residual_names = keys(problem.tolerances)
    residuals = NamedTuple{residual_names}(Tuple(r))
    converged = _within(r, tol)
    converged || return TrimReport(false, solution, residuals, problem.tolerances, nothing,
                                   nothing, status, n_evaluations, n_iterations, saturated,
                                   Tuple{String,Symbol}[])

    commit!(override(baseline, problem.condition(solution)))

    # The commit's fired events, read off the per-boundary counts right after
    # `init!` returns — they are reset at the next boundary, and there is none
    # (§10.6, §14.5).
    events = model.exec.events
    fired = Tuple{String,Symbol}[events.names[i] for i in eachindex(events.count)
                                 if events.count[i] > 0]
    isempty(fired) || @warn logline(TrimCommitEvents(events = fired))

    # The committed-state residuals, nearly free: that boundary's sweep has just
    # run, so the declared reads need only gather from it — with one `rhs` for
    # the derivative reads, `ẋbuf` being integrator scratch and this a service
    # evaluation (§14.4, §14.8).
    model.exec.bodies.rhs()
    gathered = gather_reads(reader, model.exec)
    committed = NamedTuple{residual_names}(problem.residuals(gathered, solution))
    out_of_tolerance = Tuple{Symbol,Float64,Float64}[
        (k, Float64(committed[k]), tol[i]) for (i, k) in enumerate(residual_names)
        if !(abs(committed[k]) ≤ tol[i])]
    isempty(out_of_tolerance) ||
        @warn logline(TrimCommitResiduals(residuals = out_of_tolerance))

    # The committed-state checks, from the same gather (§14.8, D-262): a check
    # outside its tolerance means the point is not the one the problem asked for.
    check_tolerances = problem.check_tolerances
    check_names = keys(check_tolerances)
    committed_checks = NamedTuple{check_names}(problem.checks(gathered, solution))
    checks_out_of_tolerance = Tuple{Symbol,Float64,Float64}[
        (k, Float64(committed_checks[k]), check_tolerances[k]) for k in check_names
        if !(abs(committed_checks[k]) ≤ check_tolerances[k])]
    isempty(checks_out_of_tolerance) ||
        @warn logline(TrimCommitChecks(checks = checks_out_of_tolerance))

    TrimReport(true, solution, residuals, problem.tolerances, committed, committed_checks,
               status, n_evaluations, n_iterations, saturated, fired)
end
