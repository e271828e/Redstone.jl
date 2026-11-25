# S6a independent verification probes. Run from the pinned worktree:
#   JULIA_LOAD_PATH="@" julia --startup-file=no --project=test <this file>
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools, Test
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test", "imports.jl"))
include(joinpath(W, "test", "fixtures.jl"))
include(joinpath(W, "test", "utils.jl"))

show_err(f) = try
    f(); "no throw"
catch e
    e isa DiagnosticError ? sprint(showerror, e) : "OTHER: " * sprint(showerror, e)
end

# Hooks keeping every settled boundary's clock and the continuous state there.
mutable struct ProbeHooks{M} <: FrameHooks
    model::M
    clocks::Vector{Float64}
    xs::Vector{Vector{Float64}}
end
ProbeHooks(m) = ProbeHooks(m, Float64[], Vector{Float64}[])
frame_top!(::ProbeHooks) = false
settled!(h::ProbeHooks) = (push!(h.clocks, ForwardDiff.value(h.model.exec.clock.t));
                           push!(h.xs, ForwardDiff.value.(copy(h.model.exec.xbuf))); false)

# A forward-Euler recording backend: every step length and every step's start state.
struct Rec <: AbstractAlgorithm end
struct RecStepper{T} <: AbstractStepper
    x₀::Vector{T}; k₁::Vector{T}; lengths::Vector{Float64}; starts::Vector{Vector{Float64}}
end
bind_stepper(::Rec, ::Type{T}, n::Int) where {T} = RecStepper{T}(zeros(T, n), zeros(T, n), Float64[], Vector{Float64}[])
propose(::RecStepper) = nothing
checkpoint_stepper(::RecStepper) = nothing
restore_stepper!(::RecStepper, ::Nothing) = nothing
reset_stepper!(::RecStepper) = nothing
function attempt!(s::RecStepper, model::Model, h)
    push!(s.lengths, ForwardDiff.value(h)); push!(s.starts, ForwardDiff.value.(copy(model.exec.xbuf)))
    copyto!(s.x₀, model.exec.xbuf); evaluate!(model); copyto!(s.k₁, model.exec.ẋbuf)
    model.exec.xnext .= s.x₀ .+ h .* s.k₁
    true
end
startpoint(s::RecStepper) = (s.x₀, s.k₁)
proposes(::Rec) = false

prig() = Group((; c = Plant()); input_wires = ("in" => "c/u",))
# --- S6a-001: a Model is a deployment at one scalar type
m = Model(prig(); Δt_frame = 1//10)
println("P001 Model{Float64}: ", typeof(m) <: Model{Float64}, " Dual: ",
        typeof(Model(prig(), D8; Δt_frame = 1//10)) <: Model{D8},
        " Float32: ", show_err(() -> Model(prig(), Float32; Δt_frame = 1//10)))

# --- S6a-025: two policies, read off the guard's return form
b = build(Group((; s = Sawtooth(1.0), f = Follower()); input_wires = ("go" => "f/go",)))
println("P025 policies: ", [(c.path, c.policies) for c in b.events.components])

# --- S6a-034: the origin exact, each clock the float nearest its instant
m = Model(prig(); Δt_frame = 1//10)
init!(m, set(u = (in = 0.0,)); t0 = -3//10)
println("P034 t₀ type: ", typeof(m.exec.clock.t₀), " value ", m.exec.clock.t₀)
cl = Float64[]
for k in 1:5; frame!(m, k); push!(cl, m.exec.clock.t); end
nearest = [Float64(big(-3//10) + big(k) * big(1//10)) for k in 1:5]
println("P034 clocks ", cl, " nearest ", nearest, " equal ", cl == nearest)
m2 = Model(prig(); Δt_frame = 1//10)
init!(m2, set(u = (in = 0.0,)); t0 = -0.3)
for k in 1:3; frame!(m2, k); end
println("P034 float origin -0.3 → frame 3 clock ", m2.exec.clock.t, " (exact origin gives ", cl[3], ")")
println("P034 t0=1e-4 refused: ", show_err(() -> init!(Model(prig(); Δt_frame = 1//10),
                                                        set(u = (in = 0.0,)); t0 = 1e-4)))

# --- S6a-043 / S6a-053: every step end is a boundary; clocks strictly increase
m = Model(Group((; c = Plant(), a = TickCounter()); input_wires = ("in" => "c/u",),
                sample_times = (; a = Absolute(7//100)));
          Δt_frame = 1//10, Δt_base = 1//100, h_max = 1//40, algorithm = Rec())
init!(m, set(u = (in = 0.0,)); t0 = 1//4)
h = ProbeHooks(m)
for k in 1:3; frame!(m, k, h); end
println("P043 steps ", length(m.exec.stepper.lengths), " settled ", length(h.clocks),
        " clocks ", h.clocks)
println("P053 strictly increasing: ", all(diff(h.clocks) .> 0))
# adaptive
ma = Model(Group((; c = Plant(), a = TickCounter()); input_wires = ("in" => "c/u",),
                 sample_times = (; a = Absolute(7//100)));
           Δt_frame = 1//10, Δt_base = 1//100, h_max = 1//20, h_min = 1//1000, algorithm = BS3())
init!(ma, set(u = (in = 1.0,)))
ha = ProbeHooks(ma)
for k in 1:5; frame!(ma, k, ha); end
println("P053 adaptive boundaries ", length(ha.clocks), " strictly increasing: ", all(diff(ha.clocks) .> 0))
# localized: t* inside
ml = Model(single(Bouncer(1.0, 0.32)); Δt_frame = 1//10, algorithm = Rec())
init!(ml)
hl = ProbeHooks(ml)
for k in 1:5; frame!(ml, k, hl); end
println("P043 localized clocks ", hl.clocks)
# refusal: a clock that cannot keep boundaries apart
println("P053 t0=2^60 refused: ", show_err(() -> init!(Model(prig(); Δt_frame = 1//10),
                                                        set(u = (in = 0.0,)); t0 = 2^60)))
mlast = Model(prig(); Δt_frame = 1//10)
init!(mlast, set(u = (in = 0.0,)); t0 = 2^45)
lf = Redstone._last_frame(mlast)
println("P053 last frame from 2^45: ", lf, " frame! past it: ", show_err(() -> frame!(mlast, lf + 1)))

# --- S6a-062: a restored run keeps the clock and the origin
m = Model(prig(); Δt_frame = 1//10)
init!(m, set(u = (in = 1.0,)); t0 = 1//4)
frames!(m, 3)
st = checkpoint(m)
fresh = Model(m.deployment)
restore!(fresh, st)
println("P062 restored t ", fresh.exec.clock.t, " == ", m.exec.clock.t, " t₀ ", fresh.exec.clock.t₀,
        " == ", m.exec.clock.t₀)
frames!(fresh, 2); frames!(m, 2)
println("P062 continued t equal ", fresh.exec.clock.t == m.exec.clock.t)

# --- S6a-071: a Dual model freezes its discrete tier, takes the same steps
rig = Group((; c = Plant(), a = TickCounter()); input_wires = ("in" => "c/u",),
            sample_times = (; a = Absolute(7//100)))
mf = Model(rig; Δt_frame = 1//10, Δt_base = 1//100, h_max = 1//40, algorithm = Rec())
md = Model(rig, D8; Δt_frame = 1//10, Δt_base = 1//100, h_max = 1//40, algorithm = Rec())
init!(mf, set(u = (in = 0.0,))); init!(md, set(u = (in = D8(0.0),)))
frames!(mf, 3); frames!(md, 3)
println("P071 counter Float64 ", state(mf, "a").n, " Dual ", state(md, "a").n,
        " same lengths ", mf.exec.stepper.lengths == md.exec.stepper.lengths)

# --- S6a-080: each step starts from the state the last boundary left
mb = Model(single(Bouncer(1.0, 0.32)); Δt_frame = 1//10, algorithm = Rec())
init!(mb)
hb = ProbeHooks(mb)
for k in 1:8; frame!(mb, k, hb); end
starts = mb.exec.stepper.starts
println("P080 bouncer: boundaries ", length(hb.xs), " attempts ", length(starts))
# every boundary's x (after reset) is the start of some later attempt, in order
ok = true; j = 1
for (i, x) in enumerate(hb.xs[1:end-1])
    global j, ok
    idx = findnext(s -> s == x, starts, j)
    idx === nothing && (ok = false; println("   boundary ", i, " x=", x, " not a step start"))
    idx === nothing || (j = idx)
end
println("P080 every boundary's state starts the next step: ", ok,
        " resets seen: ", count(x -> x[1] == 0.0, hb.xs))
mr = Model(single(Rotor(; r₀ = SVector(2.0, 0.0))); Δt_frame = 1//10, algorithm = Rec())
init!(mr)
frames!(mr, 3)
println("P080 rotor step starts on the circle: ",
        all(s -> isapprox(hypot(s...), 1.0; atol = 1e-15), mr.exec.stepper.starts))

# --- S6a-007, S6a-011, S6a-089, S6a-098: the simulation
replay_model(k = 4.0) =
    Group((plant = Plant(; ω = 2.0, ζ = 0.1), ctl = Gain(k), sum = Sum(),
           acc = DiscreteAccumulator(1.0), b = Bouncer(1.0, 0.32));
          local_wires = ("ctl/out" => "plant/u", "sum/e" => "ctl/e", "plant/y" => "sum/b"),
          input_wires = ("ref" => "sum/a", "rate" => "acc/e"),
          output_wires = ("b/q" => "bq", "acc/u" => "u"))
snap_cells(s) = Any[gather_cell(s.store, s.layout.addr[k]) for k in sort!(collect(keys(s.layout.addr)))]
same_traj(a, b) = length(a) == length(b) &&
    all(x.t == y.t && x.frame == y.frame && snap_cells(x) == snap_cells(y) for (x, y) in zip(a, b))

sim = Simulation(replay_model(); Δt_frame = 1//10)
println("P089 stage! before init!: ", show_err(() -> stage!(sim, "ref" => 9.0)))
init!(sim, set(u = (ref = 1.0, rate = 0.0)))
stage!(sim, "ref" => 2.0)
step!(sim; frames = 3)
stage!(sim, "rate" => 1.0)
step!(sim; frames = 5)
trc = trace(sim)
twin = Simulation(replay_model(); Δt_frame = 1//10)
init!(twin, set(u = (ref = 0.0, rate = 0.0)))
replay!(twin, trc)
println("P007 replay bit-identical: ", same_traj(logged(twin), logged(sim)))
# adaptive replay
asim = Simulation(replay_model(); Δt_frame = 1//10, h_max = 1//20, h_min = 1//1000, algorithm = BS3())
init!(asim, set(u = (ref = 1.0, rate = 0.0)))
stage!(asim, "ref" => 2.0); step!(asim; frames = 3); stage!(asim, "rate" => 1.0); step!(asim; frames = 5)
atwin = Simulation(replay_model(); Δt_frame = 1//10, h_max = 1//20, h_min = 1//1000, algorithm = BS3())
replay!(atwin, trace(asim))
println("P007 adaptive replay bit-identical: ", same_traj(logged(atwin), logged(asim)))

println("P011 after run: port(latest) bq=", port(latest(sim), "", :bq), " plant/y=",
        port(latest(sim), "plant", :y), " logged[3] plant/y=", port(logged(sim)[3], "plant", :y))

# during a run: a reader task reading by path while run! is paced
dsim = Simulation(replay_model(); Δt_frame = 1//10)
init!(dsim, set(u = (ref = 1.0, rate = 0.0)))
seen = Float64[]
staged_ok = Ref(true)
runner = Threads.@spawn run!(dsim; t_end = 1.0, pace = 1)
for _ in 1:40
    s = latest(dsim)
    push!(seen, s.t); port(s, "plant", :y)
    try stage!(dsim, "ref" => 1.5) catch; staged_ok[] = false end
    sleep(0.02)
end
wait(runner)
println("P011 reads during run: distinct t seen ", length(unique(seen)), " lifecycle ", lifecycle(dsim))
println("P089 stage! during run threw: ", !staged_ok[])

# pace and pause do not change the trajectory
function run_with(f)
    s = Simulation(replay_model(); Δt_frame = 1//10)
    init!(s, set(u = (ref = 1.0, rate = 1.0)))
    f(s)
    logged(s)
end
ref_log = run_with(s -> run!(s; t_end = 1.0))
paced_log = run_with(s -> run!(s; t_end = 1.0, pace = 5))
paused_log = run_with() do s
    pause!(s)
    t = Threads.@spawn run!(s; t_end = 1.0, pace = 2)
    sleep(0.2); resume!(s); sleep(0.1); pause!(s); sleep(0.2); resume!(s)
    wait(t)
end
stepped_log = run_with(s -> (step!(s; frames = 4); step!(s; frames = 6)))
println("P098 paced == unpaced ", same_traj(paced_log, ref_log), " paused == unpaced ",
        same_traj(paused_log, ref_log), " stepped == run ", same_traj(stepped_log, ref_log))
stopped = run_with() do s
    t = Threads.@spawn run!(s; pace = 1)
    sleep(0.35); stop!(s); wait(t)
end
n = length(stopped)
println("P098 stopped prefix (", n, " snaps) equals unstopped prefix ",
        same_traj(stopped, ref_log[1:min(n, length(ref_log))]))
