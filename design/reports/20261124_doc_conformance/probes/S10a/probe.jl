# S10a probe: spec §10 preamble, §10.1-§10.3 (stepper seam, notices, floor, freshness).
import Redstone
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/imports.jl")
import Redstone: x_init, x_deriv, y_types, y_state, s_init, s_update, u_types, evaluate!, _phase!,
    checkpoint, restore!, overlay!, init!, frame!, step!, Model, Simulation, build, diagnostics
macro show_(ex) :(println(rpad($(string(ex)), 60), " => ", repr($(esc(ex))))) end
function failure(f)
    try f(); return nothing catch e; return e end
end

struct BareRamp <: AbstractComponent end
x_init(::BareRamp) = 0.0
y_types(::BareRamp) = Float64
y_state(::BareRamp, (; x)) = x
x_deriv(::BareRamp, _) = 1.0

struct Decay <: AbstractComponent
    k::Float64
end
x_init(::Decay) = 1.0
y_types(::Decay) = Float64
y_state(::Decay, (; x)) = x
x_deriv(c::Decay, (; x)) = -c.k * x

struct NaNRate <: AbstractComponent end
x_init(::NaNRate) = 1.0
y_types(::NaNRate) = Float64
y_state(::NaNRate, (; x)) = x
x_deriv(::NaNRate, _) = NaN

struct TickCounter <: AbstractComponent end
s_init(::TickCounter) = (n = 0,)
y_types(::TickCounter) = (n = Int,)
y_state(::TickCounter, (; s)) = (n = s.n,)
s_update(::TickCounter, (; s)) = (n = s.n + 1,)

# ---- a scripted proposing backend (Heun through the seam) ----
struct StubAlg <: AbstractAlgorithm
    h::Float64          # standing proposal
    reject::Bool        # reject every attempt
    factor::Float64     # rejection proposes factor*h
end
StubAlg(h; reject = false, factor = 0.9) = StubAlg(h, reject, factor)
proposes(::StubAlg) = true
mutable struct Stub{T} <: AbstractStepper
    alg::StubAlg
    x₀::Vector{T}; k₁::Vector{T}; k₂::Vector{T}
    proposal::Float64
    proposed::Int
    log::Vector{Any}       # (attempt ordinal in step, h, clock, fresh) per attempt
    notices::Vector{Float64}
    carried_resets::Int
end
bind_stepper(a::StubAlg, ::Type{T}, n::Int) where {T} =
    Stub{T}(a, zeros(T, n), zeros(T, n), zeros(T, n), a.h, 0, Any[], Float64[], 0)
propose(s::Stub) = (s.proposed += 1; s.proposal)
checkpoint_stepper(s::Stub) = (s.proposal, s.proposed)
restore_stepper!(s::Stub, (p, n)::Tuple{Float64,Int}) = (s.proposal = p; s.proposed = n; nothing)
reset_stepper!(s::Stub) = (s.proposal = s.alg.h; s.proposed = 0; s.carried_resets += 1; nothing)
discontinuity!(s::Stub) = (push!(s.notices, length(s.log)); nothing)
startpoint(s::Stub) = (s.x₀, s.k₁)
function attempt!(s::Stub, model, h)
    exec = model.exec
    x, ẋ = exec.xbuf, exec.ẋbuf
    t = exec.clock.t
    push!(s.log, (exec.cursor.attempt, h, t, model.fresh))
    copyto!(s.x₀, x)
    evaluate!(model); copyto!(s.k₁, ẋ)
    x .= s.x₀ .+ h .* s.k₁; exec.clock.t = t + h
    evaluate!(model); copyto!(s.k₂, ẋ)
    exec.xnext .= s.x₀ .+ (h / 2) .* (s.k₁ .+ s.k₂)
    if s.alg.reject
        s.proposal = s.alg.factor * h
        return false
    end
    s.proposal = s.alg.h
    true
end

tickroot() = Group((; r = BareRamp(), a = TickCounter()); sample_times = (; a = Absolute(3//32)))
println("== P1: floor read by count; budget; at most budget+1 attempts; one StepFloor latch per frame")
m = Model(Group((; r = BareRamp())); Δt_frame = 1//8, h_min = 1//20, algorithm = StubAlg(0.01; reject = true))
init!(m); frame!(m, 1)
st = m.exec.stepper
println("lengths  ", [l[2] for l in st.log], "  expect two of ", 1/16)
println("floor_reported ", m.floor_reported, "  attempts/step ", [l[1] for l in st.log])
m = Model(Group((; r = BareRamp())); Δt_frame = 1//8, h_min = 1//1024, algorithm = StubAlg(0.01; reject = true))
init!(m); frame!(m, 1)
st = m.exec.stepper
println("attempt ordinals ", [l[1] for l in st.log][1:12])
println("hs of first step ", [l[2] for l in st.log if true][1:8])
println("last attempt of first step h = ", st.log[8][2], " vs r/floor(r/h_min) = ", (1/8) / floor((1/8) * 1024))
println("floor_reported ", m.floor_reported, "; default attempt_budget ", m.deployment.attempt_budget)
m = Model(Group((; r = BareRamp())); Δt_frame = 1//8, h_min = 1//1024, attempt_budget = 3, algorithm = StubAlg(0.01; reject = true))
init!(m); frame!(m, 1)
println("budget=3 attempt ordinals ", [l[1] for l in m.exec.stepper.log][1:6])
# r shorter than h_min: due instant 3/32 with tick; floor for the stretch 1/8-3/32=1/32 < h_min=1/20? h_min must be <= h_max/2 = 1/16
mt = Model(tickroot(); Δt_frame = 1//8, Δt_base = 1//32,
           h_min = 1//20, algorithm = StubAlg(0.01; reject = true))
init!(mt); frame!(mt, 1)
println("span 3/32 then 1/32 under h_min=1/20: lengths ", [l[2] for l in mt.exec.stepper.log])

println("== P2: propose asked before each step and after each rejected attempt; none when empty")
m = Model(Group((; r = BareRamp())); Δt_frame = 1//8, h_min = 1//1024, algorithm = StubAlg(1/16))
init!(m); frame!(m, 1)
println("steps ", length(m.exec.stepper.log), " proposed ", m.exec.stepper.proposed)
m = Model(Group((; r = BareRamp())); Δt_frame = 1//8, h_min = 1//1024, algorithm = StubAlg(1/16; reject = true, factor = 0.5), attempt_budget = 2)
init!(m); frame!(m, 1)
println("reject: attempts ", length(m.exec.stepper.log), " proposed ", m.exec.stepper.proposed)
m = Model(Group((; a = TickCounter())); Δt_frame = 1//10, h_min = 1//1024, algorithm = StubAlg(0.03))
init!(m); frame!(m, 1)
println("empty state: attempts ", length(m.exec.stepper.log), " proposed ", m.exec.stepper.proposed, " t ", m.exec.clock.t)
for p in (0.0, -0.1, 1e-20, Inf)
    m = Model(Group((; r = BareRamp())); Δt_frame = 1//8, h_min = 1//32, algorithm = StubAlg(p))
    init!(m; t0 = 1.0); frame!(m, 1)
    println("proposal ", p, " lengths ", [l[2] for l in m.exec.stepper.log])
end
m = Model(Group((; r = BareRamp())); Δt_frame = 1//8, h_min = 1//32, algorithm = StubAlg(NaN))
init!(m; t0 = 1.0)
e = failure(() -> frame!(m, 1))
println("NaN proposal: ", typeof(e), " cause ", typeof(e.cause), " status ", m.status)

println("== P3: notices")
mt = Model(tickroot(); Δt_frame = 1//8, Δt_base = 1//32,
           h_min = 1//1024, algorithm = StubAlg(1/16))
init!(mt)
st = mt.exec.stepper
println("after init!: notices ", st.notices, " resets ", st.carried_resets)
frame!(mt, 1); println("after frame 1 (tick at 3/32): notices ", st.notices, " log ", length(st.log))
n0 = length(st.notices)
frame!(mt, 2)
println("frame 2 notices new ", length(st.notices) - n0)
# a hook that writes
mutable struct WH <: FrameHooks; wrote::Bool; end
frame_top!(h::WH) = h.wrote
settled!(::WH) = false
mr = Model(Group((; r = BareRamp())); Δt_frame = 1//8, h_min = 1//1024, algorithm = StubAlg(1/16))
init!(mr); s = mr.exec.stepper; n0 = length(s.notices)
frame!(mr, 1, WH(false)); println("hook false: new notices ", length(s.notices) - n0, " fresh log ", [l[4] for l in s.log])
empty!(s.log); n0 = length(s.notices)
frame!(mr, 2, WH(true)); println("hook true: new notices ", length(s.notices) - n0, " fresh log ", [l[4] for l in s.log])
# overlay raises one; restore raises none and restores carried state
mr = Model(Group((; r = BareRamp())); Δt_frame = 1//8, h_min = 1//1024, algorithm = StubAlg(1/16))
init!(mr); s = mr.exec.stepper; frame!(mr, 1)
n0 = length(s.notices); overlay!(mr); println("overlay! new notices ", length(s.notices) - n0)
ck = checkpoint(mr)
s.proposal = 123.0; s.proposed = 99
n0 = length(s.notices); restore!(mr, ck); println("restore! new notices ", length(s.notices) - n0, " carried back ", (s.proposal, s.proposed))
resets = s.carried_resets; init!(mr); println("init! resets ", s.carried_resets - resets, " proposal ", s.proposal)

println("== P4: fresh flag across a Simulation advance (continued frames)")
sim = Simulation(Group((; r = BareRamp())); Δt_frame = 1//8, h_min = 1//1024, algorithm = StubAlg(1/16))
init!(sim); step!(sim; frames = 2)
s = sim.model.exec.stepper
println("fresh per attempt (frames of 2 steps each): ", [l[4] for l in s.log])
step!(sim; frames = 1)
println("after a second advance of one frame: ", [l[4] for l in s.log][end-1:end])
mf = Model(Group((; r = BareRamp())); Δt_frame = 1//8, h_min = 1//1024, algorithm = StubAlg(1/16))
init!(mf); frame!(mf, 1); frame!(mf, 2)
println("frame! twice (never continued): ", [l[4] for l in mf.exec.stepper.log])
# rejected attempts are not fresh
mj = Model(Group((; r = BareRamp())); Δt_frame = 1//8, h_min = 1//1024, algorithm = StubAlg(1/16; reject = true, factor = 0.5), attempt_budget = 2)
init!(mj); frame!(mj, 1)
println("reject: fresh log ", [l[4] for l in mj.exec.stepper.log][1:6])

println("== P5: tokens, deployment, protocol defaults")
b = build(Group((; r = BareRamp())))
@show_ Deployment(b; Δt_frame = 1//8).algorithm
@show_ Deployment(b; Δt_frame = 1//8).attempt_budget
@show_ BS3()
@show_ proposes(Redstone.RK4())
@show_ failure(() -> Redstone.RK4(1//100)) isa MethodError
e = failure(() -> Deployment(b; Δt_frame = 1//8, algorithm = BS3()))
println("BS3 no h_min: ", [(d.parameter, d.reason) for d in diagnostics(e)])
e = failure(() -> Deployment(b; Δt_frame = 1//8, algorithm = BS3(), h_min = 1//8 * 0.6 |> rationalize))
println("BS3 h_min above half: ", [(d.parameter, d.reason) for d in diagnostics(e)])
e = failure(() -> Deployment(b; Δt_frame = 1//8, algorithm = BS3(), h_min = 1//16))
println("BS3 h_min == half: ", e)
struct Bare <: AbstractStepper end
for f in (propose, checkpoint_stepper, reset_stepper!)
    println(f, " default? ", failure(() -> f(Bare())) isa MethodError)
end
println("restore_stepper! default? ", failure(() -> restore_stepper!(Bare(), nothing)) isa MethodError)
println("discontinuity! default ", discontinuity!(Bare()))
for A in (Redstone.RK4(), Redstone.Heun())
    mm = Model(Group((; r = BareRamp())); Δt_frame = 1//8, algorithm = A)
    init!(mm); s = mm.exec.stepper
    println(typeof(s), " propose ", propose(s), " checkpoint ", checkpoint_stepper(s), " reset ", reset_stepper!(s))
end
bm = Model(Group((; r = BareRamp())); Δt_frame = 1//8, h_min = 1//1024, algorithm = BS3())
init!(bm); s = bm.exec.stepper
println("BS3 after init!: propose ", propose(s), " ckpt ", checkpoint_stepper(s))

println("== P6: stages per attempt")
for (A, kw) in ((Redstone.RK4(), ()), (Redstone.Heun(), ()), (BS3(), (; h_min = 1//2^20)))
    mm = Model(Group((; d = Decay(1.0))); Δt_frame = 1//8, algorithm = A, kw...)
    init!(mm)
    _phase!(mm.exec.cursor, :integrate); mm.fresh = false
    ok = attempt!(mm.exec.stepper, mm, 1/64)
    println(typeof(A), " accepted ", ok, " stage evaluations ", mm.exec.cursor.index)
end

println("== P7: BS3 starting bound, nonfinite rejection, history")
bm = Model(Group((; d = Decay(1000.0))); Δt_frame = 1//10, h_min = 1//2^30, algorithm = BS3())
init!(bm); s = bm.exec.stepper
_phase!(bm.exec.cursor, :integrate)
ok = attempt!(s, bm, 0.1)
bound = 1 / (1000.0 / (0.8 * cbrt(1e-3)))
println("first attempt accepted ", ok, " proposal ", propose(s), " starting bound ", bound, " h*0.2 ", 0.1 * 0.2)
bm = Model(Group((; d = Decay(1.0))); Δt_frame = 1//10, h_min = 1//2^30, algorithm = BS3())
init!(bm); s = bm.exec.stepper
_phase!(bm.exec.cursor, :integrate)
ok = attempt!(s, bm, 0.05); println("mild: accepted ", ok, " proposal ", propose(s), " memory ", s.memory, " ckpt ", checkpoint_stepper(s))
discontinuity!(s); println("after notice memory ", s.memory, " proposal kept ", propose(s))
reset_stepper!(s); println("after reset ", checkpoint_stepper(s))
nm = Model(Group((; d = NaNRate())); Δt_frame = 1//10, h_min = 1//2^30, algorithm = BS3())
init!(nm); s = nm.exec.stepper
_phase!(nm.exec.cursor, :integrate)
ok = attempt!(s, nm, 0.05); println("NaN: accepted ", ok, " proposal ", propose(s), " == 0.2h: ", propose(s) == 0.2 * 0.05)

println("== P8: doors refuse a run whose clock cannot resolve the floor")
for A in (Redstone.RK4(), BS3())
    kw = A isa BS3 ? (; h_min = 1//10^9) : (;)
    mm = Model(Group((; r = BareRamp())); Δt_frame = 1//1, algorithm = A, kw...)
    e = failure(() -> init!(mm; t0 = 1e7))
    println(typeof(A), " init!(t0=1e7): ", e === nothing ? "ok" : typeof(e))
end

println("== P9: allocation of a warmed frame")
for A in (Redstone.RK4(), Redstone.Heun(), BS3())
    kw = A isa BS3 ? (; h_min = 1//2^20, h_max = 1//64) : (; h_max = 1//64)
    mm = Model(Group((; d = Decay(1.0))); Δt_frame = 1//8, algorithm = A, kw...)
    init!(mm); frame!(mm, 1); frame!(mm, 2)
    a = @allocated frame!(mm, 3)
    println(typeof(A), " frame! allocated ", a)
end

println("== P10: BS3 error test sample (passes iff scaled error ≤ 1)")
println("done")
