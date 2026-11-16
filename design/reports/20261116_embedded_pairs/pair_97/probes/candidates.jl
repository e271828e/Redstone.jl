# The candidate steppers; the includer imports the seam's names.
# Counters shared by every probe stepper.
mutable struct Counts
    attempts::Int
    accepted::Int
    stage_sweeps::Int     # evaluate! calls that ran the sweep
    stage_rhs::Int        # evaluate! calls (each runs the rhs block)
end
Counts() = Counts(0, 0, 0, 0)

# A: the package's BS3, wrapped, counting by reading `model.fresh` before the attempt.
struct CountedBS3 <: AbstractAlgorithm
    inner::BS3
end
Redstone.proposes(::CountedBS3) = true
struct CountedBS3Stepper{T} <: AbstractStepper
    inner::BS3Stepper{T}
    c::Counts
end
Redstone.bind_stepper(a::CountedBS3, ::Type{T}, n::Int) where {T} =
    CountedBS3Stepper{T}(bind_stepper(a.inner, T, n), Counts())
for f in (:propose, :checkpoint_stepper, :reset_stepper!, :discontinuity!, :startpoint, :arrival_derivative)
    @eval Redstone.$f(s::CountedBS3Stepper) = Redstone.$f(s.inner)
end
Redstone.restore_stepper!(s::CountedBS3Stepper, c) = restore_stepper!(s.inner, c)
function Redstone.attempt!(s::CountedBS3Stepper, model::Model, h)
    s.c.attempts += 1
    s.c.stage_sweeps += model.fresh ? 3 : 4
    s.c.stage_rhs += 4
    ok = attempt!(s.inner, model, h)
    s.c.accepted += ok
    ok
end

# The probe stepper: BS3's three stages and controller, with a selectable estimate.
#   kind :bs3   -> BS3's four-stage estimate (A, reimplemented; must match CountedBS3)
#   kind :emb   -> e = s·(1, -3, 2), the three-stage embedded family (B)
#   kind :alsh  -> e = (0, 4/9, 0) as OrdinaryDiffEq's Alshina3 ships it (C)
struct Probe <: AbstractAlgorithm
    kind::Symbol
    s::Float64
    reltol::Float64
    abstol::Float64
end
Probe(kind, s = 0.0; reltol, abstol = reltol / 1000) = Probe(kind, s, reltol, abstol)
Redstone.proposes(::Probe) = true
mutable struct ProbeStepper{T} <: AbstractStepper
    const alg::Probe
    const x₀::Vector{T}
    const k₁::Vector{T}
    const k₂::Vector{T}
    const k₃::Vector{T}
    const k₄::Vector{T}
    proposal::Float64
    memory::Float64
    const c::Counts
    # per accepted step: (t, h, x0, xtrial, estimate vector, scaled error)
    const trace::Vector{Any}
    tracing::Bool
end
Redstone.bind_stepper(a::Probe, ::Type{T}, n::Int) where {T} =
    ProbeStepper{T}(a, ntuple(_ -> zeros(T, n), 5)..., Inf, 0.0, Counts(), Any[], false)
Redstone.propose(s::ProbeStepper) = s.proposal
Redstone.checkpoint_stepper(s::ProbeStepper) = (s.proposal, s.memory)
Redstone.restore_stepper!(s::ProbeStepper, (p, m)::Tuple{Float64,Float64}) = (s.proposal = p; s.memory = m; nothing)
Redstone.reset_stepper!(s::ProbeStepper) = (s.proposal = Inf; s.memory = 0.0; nothing)
Redstone.discontinuity!(s::ProbeStepper) = (s.memory = 0.0; nothing)
Redstone.startpoint(s::ProbeStepper) = (s.x₀, s.k₁)
Redstone.arrival_derivative(s::ProbeStepper) = s.alg.kind === :bs3 ? s.k₄ : nothing

@inline function counted_evaluate!(s::ProbeStepper, model::Model)
    s.c.stage_sweeps += !model.fresh
    s.c.stage_rhs += 1
    evaluate!(model)
end

const E_BS3 = (-5 / 72, 1 / 12, 1 / 9, -1 / 8)

function Redstone.attempt!(s::ProbeStepper, model::Model, h)
    exec = model.exec
    x, ẋ, xtrial = exec.xbuf, exec.ẋbuf, exec.xnext
    (; x₀, k₁, k₂, k₃, k₄, alg) = s
    (; kind, reltol, abstol) = alg
    s.c.attempts += 1
    t = exec.clock.t
    copyto!(x₀, x)
    counted_evaluate!(s, model); copyto!(k₁, ẋ)
    _stage_point!(x, x₀, k₁, h / 2); exec.clock.t = t + h / 2
    counted_evaluate!(s, model); copyto!(k₂, ẋ)
    _stage_point!(x, x₀, k₂, 3h / 4); exec.clock.t = t + 3h / 4
    counted_evaluate!(s, model); copyto!(k₃, ẋ)
    @inbounds for i in eachindex(xtrial)
        xtrial[i] = x₀[i] + h * (2 / 9 * k₁[i] + 1 / 3 * k₂[i] + 4 / 9 * k₃[i])
    end
    if kind === :bs3
        copyto!(x, xtrial); exec.clock.t = t + h
        counted_evaluate!(s, model); copyto!(k₄, ẋ)
    end
    hv = _seconds(h)
    err = 0.0
    est = s.tracing ? zeros(length(xtrial)) : Float64[]
    @inbounds for i in eachindex(xtrial)
        x₁ = _seconds(xtrial[i])
        e = if kind === :bs3
            hv * (E_BS3[1] * _seconds(k₁[i]) + E_BS3[2] * _seconds(k₂[i]) +
                  E_BS3[3] * _seconds(k₃[i]) + E_BS3[4] * _seconds(k₄[i]))
        elseif kind === :emb
            hv * alg.s * (_seconds(k₁[i]) - 3 * _seconds(k₂[i]) + 2 * _seconds(k₃[i]))
        else
            hv * (4 / 9) * _seconds(k₂[i])
        end
        s.tracing && (est[i] = e)
        scale = abstol + reltol * max(abs(_seconds(x₀[i])), abs(x₁))
        err = max(err, abs(e) / scale)
        isfinite(x₁) || (err = Inf)
    end
    if !isfinite(err)
        s.proposal = hv * 0.2
        return false
    elseif err > 1
        s.proposal = hv * max(0.2, 0.9 / cbrt(err))
        return false
    end
    factor = s.memory == 0.0 ? 0.9 / cbrt(err) : 0.9 * err^-(0.7 / 3) * s.memory^(0.4 / 3)
    s.proposal = hv * clamp(factor, 0.2, 10.0)
    s.memory = max(err, 1e-4)
    s.c.accepted += 1
    s.tracing && push!(s.trace, (Float64(_seconds(t)), hv, Float64.(_seconds.(x₀)), Float64.(_seconds.(xtrial)), est, err))
    true
end
# Note: a floor-forced acceptance (attempt! returns false, the Model accepts) is not
# counted in `accepted` above; `floors` from writer_status reports those.

counts(st) = st isa CountedBS3Stepper ? st.c : st.c

# The candidates, by label, at a tolerance.
candidate(label, tol) =
    label == "A"     ? CountedBS3(BS3(reltol = tol, abstol = tol / 1000)) :
    label == "A'"    ? Probe(:bs3; reltol = tol) :
    label == "B_mid" ? Probe(:emb, 2 / 9; reltol = tol) :      # b̂ = (0, 1, 0)
    label == "B_1/9" ? Probe(:emb, 1 / 9; reltol = tol) :      # b̂ = (1/3, 0, 2/3) or (1/9, 2/3, 2/9)
    label == "B_4/9" ? Probe(:emb, 4 / 9; reltol = tol) :      # b̂ = (-2/9, 5/3, -4/9)
    label == "C"     ? Probe(:alsh; reltol = tol) :
    error(label)

# Floor warnings over a run, from the loop writer's totals.
floor_total(sim) = writer_status(latest(sim), "loop").totals.step_floor

# Log-log interpolation of work at a target error along a curve (err, work), errors sorted.
function work_at(errs, works, target)
    p = sortperm(errs)
    e, w = log10.(errs[p]), log10.(works[p])
    lt = log10(target)
    (lt < e[1] || lt > e[end]) && return NaN
    i = searchsortedlast(e, lt)
    i == length(e) && return 10^w[end]
    θ = (lt - e[i]) / (e[i+1] - e[i])
    10^(w[i] + θ * (w[i+1] - w[i]))
end
