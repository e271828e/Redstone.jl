# K6e verifier probe: pid_anti_windup.md claims against the code at W.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
include(joinpath(pwd(), "test", "imports.jl"))
include(joinpath(pwd(), "test", "fixtures.jl"))
poke!(sim, face, v) = (Redstone.scatter_cell!(sim.model.exec.store, sim.model.exec.act.layout.addr[("", Symbol(face))], v); nothing)
const ONLY128 = get(ENV, "ONLY128", "") == "1"
const L = Redstone.Library
pr(tag, x) = println(tag, " => ", repr(x))
function tryb(f)
    try
        f()
    catch e
        e isa DiagnosticError ? diagnostics(e) : e
    end
end

function loop_samples(read, model, t_end)
    sim = Simulation(model; Δt_frame = 1//100)
    init!(sim, set())
    [(step!(sim; frames = 10); read(sim)) for _ in 1:round(Int, 10 * t_end)]
end
settling_time(samples) = (findlast(s -> abs(s - 5.0) > 0.05, samples) + 1) / 10

ONLY128 || begin
# --- 003/010: the saturated equilibrium of back-calculation
let c = PID(Kp = 1.0, Ki = 0.5, Tt = 1.0, u_min = -1.0, u_max = 1.0)
    m = Group((; controller = c); input_wires = ("r" => "controller/r", "y" => "controller/y"),
              output_wires = ("controller/u" => "u", "controller/u_raw" => "u_raw"))
    sim = Simulation(m; Δt_frame = 1//100)
    init!(sim, set(u = (r = 3.0, y = 0.5)))
    step!(sim; frames = 4000)
    u, ur = port(sim, "", :u), port(sim, "", :u_raw)
    pr("003 u, u_raw, u+Tt*e, u+Tt*Ki*e", (u, ur, u + 1.0 * 2.5, u + 1.0 * 0.5 * 2.5))
end

# --- 022/112: the gate and the reference over the table
for (hold, track) in ((false, false), (false, true), (true, false), (true, true))
    c = PID(Kp = 1.0, Tt = 1.0, hold = hold, tracking = track)
    conds = hold ? (("free", Int8(0), true), ("limited+", Int8(1), true), ("limited-", Int8(-1), true),
                    ("not engaged, code 1", Int8(1), false), ("not engaged, code 0", Int8(0), false)) :
                   (("no hold", nothing, nothing),)
    for (name, code, eng) in conds
        u = merge((r = 3.0, y = 0.5), hold ? (saturation = code, engaged = eng) : (;), track ? (v = 7.0,) : (;))
        y = (u = 1.0, u_raw = 2.0)
        pr("022 Hold=$hold Track=$track $name: (ε at e=2.5, ref [u=1, v=7])",
           (L.gated_error(c, 2.5, u), L.correction_reference(c, u, y)))
    end
end

# --- 058: the cascade table
function pid_cascade(controller; hold = false, tracking = false)
    wires = Pair{String, String}[
        "reference/y" => "controller/r", "position/y" => "controller/y",
        "controller/u" => "error/in1", "velocity/y" => "error/in2",
        "error/y" => "inner/u", "inner/out" => "actuator/u",
        "actuator/y" => "velocity/u", "velocity/y" => "position/u"]
    hold && push!(wires, "inner/saturation" => "controller/saturation", "engaged/y" => "controller/engaged")
    tracking && push!(wires, "velocity/y" => "controller/v")
    kids = (reference = Step(t_step = 0.5, after = 5.0), controller = controller,
            error = Junction{Float64, Float64, 2}(-), inner = LimitedIntegrator(lower = -1.2, upper = 1.2),
            actuator = FirstOrderLag(τ = 0.1), velocity = FirstOrderLag(τ = 1.0), position = Integrator())
    Group(merge(kids, hold ? (engaged = Constant(true),) : (;));
          local_wires = Tuple(wires), output_wires = ("position/y" => "y",))
end
for (label, hold, track, Tt) in (("none", false, false, Inf), ("hold", true, false, Inf),
                                 ("track Tt=2", false, true, 2.0), ("track Tt=0.5", false, true, 0.5),
                                 ("hold+track Tt=2", true, true, 2.0), ("hold+track Tt=0.5", true, true, 0.5))
    s = loop_samples(sim -> port(sim, "", :y),
                     pid_cascade(PID(Kp = 0.5, Ki = 0.1, Tt = Tt, hold = hold, tracking = track); hold = hold, tracking = track), 60)
    pr("058 $label (peak, settled)", (round(maximum(s); digits = 2), settling_time(s)))
end

# --- 061/062: linearizations at a free point
function lin(hold, track)
    c = PID(Kp = 1.0, Ki = 0.5, Kd = 0.2, τd = 0.1, Tt = 1.0, u_min = -1.0, u_max = 1.0, hold = hold, tracking = track)
    inputs = ["r" => "controller/r", "y" => "controller/y"]
    hold && append!(inputs, ["saturation" => "controller/saturation", "engaged" => "controller/engaged"])
    track && push!(inputs, "v" => "controller/v")
    m = Group((; controller = c); input_wires = Tuple(inputs), output_wires = ("controller/u" => "u",))
    sim = Simulation(m; Δt_frame = 1//100)
    op = merge((r = 0.0, y = 0.0), hold ? (saturation = Int8(0), engaged = true) : (;), track ? (v = 0.0,) : (;))
    init!(sim, set(u = op))
    ru = track ? (r = get_input(:r), y = get_input(:y), v = get_input(:v)) : (r = get_input(:r), y = get_input(:y))
    l = linearize(sim, taps(x = (q = get_state("controller", :q), yf = get_state("controller", :yf)), u = ru, y = (u = get_face(:u),)))
    (A = l.A, B = l.B, C = l.C, D = l.D)
end
for (h, t) in ((false, false), (true, false), (false, true), (true, true))
    pr("061/062 Hold=$h Track=$t", lin(h, t))
end
println("061 expected plain: A=[0 0;0 -10] B=[0.5 -0.5;0 10] C=[1 2] D=[1 -3]")

# --- 073: discrete D term at τd = 0
let c = DiscretePID(Kp = 0.0, Kd = 1.0, τd = 0.0), Δt = 0.1
    s = s_init(c)
    ys = (0.3, 0.7, 1.6, 1.2)
    for k in eachindex(ys)
        u = (r = 0.0, y = ys[k])
        out = y_direct(c, (; s, u, Δt))
        prev = k == 1 ? 0.0 : ys[k - 1]
        pr("073 k=$k u_raw, -(y_k - y_{k-1})/Δt", (out.u_raw, -(ys[k] - prev) / Δt))
        s = s_update(c, (; s, u, y = out, Δt))
    end
    pr("085 s_init(DiscretePID)", s_init(DiscretePID(Kp = 1.0)))
    pr("137 y_state(DiscretePID)", y_state(DiscretePID(Kp = 1.0, u_max = 1.0), (; s = (q = 0.0, yf = 0.0, saturated = Int8(1)))))
    pr("137 y_types(DiscretePID)", y_types(DiscretePID(Kp = 1.0)))
    pr("084 y_state(DiscreteLimitedIntegrator)", y_state(DiscreteLimitedIntegrator(lower = -1.0, upper = 1.0), (; s = 1.0)))
end

# --- 081: where the shared methods live
for f in (L.signal_ports, L.gated_error, L.correction_reference, u_types, y_types, L.parameters)
    ms = [m for m in methods(f) if occursin("PID", string(m.sig)) || occursin("AntiWindup", string(m.sig))]
    pr("081 $(nameof(f)) methods", [string(m.sig) for m in ms])
end

# --- 087/090: vector components and saturation_type
for T in (Freeze{SVector{2, Float64}}(), DiscreteIntegrator(s0 = SVector(0.0, 0.0)), Backlash(width = SVector(1.0, 1.0)),
          LimitedDoubleIntegrator(lower = SVector(-1.0, -1.0), upper = SVector(1.0, 1.0)))
    pr("087 vector component", typeof(T))
end
pr("090 saturation_type", (L.saturation_type(Float64), L.saturation_type(SVector{3, Float64})))
pr("090 LimitedDoubleIntegrator y_types", y_types(LimitedDoubleIntegrator(lower = -1.0, upper = 1.0)))

# --- 098: the broadcast idiom
let given = (Kp = [1, 2], Ki = 1, Kd = 0.0, τd = 0.1, Tt = Inf, u_min = -Inf, u_max = Inf, b = 1.0, c = 0.0)
    c = PID(; given...)
    shape = L.shape_zero(given)
    idiom = map(v -> Float64.(L.as_static(v) .+ shape), given)
    pr("098 fixed == Float64.(value .+ shape)", (c.fixed == idiom, map(typeof, c.fixed) == map(typeof, idiom)))
end

# --- 106
let c = PID(Kp = 1.0, Ki = AsPort(), u_min = AsPort())
    pr("106 merge order", keys(merge(c.fixed, (r = 0.0, y = 0.0, Ki = 0.5, u_min = -1.0))))
    pr("106 parameters", L.parameters(c, (r = 0.0, y = 0.0, Ki = 0.5, u_min = -1.0)))
end

# --- 116: a schedule read from a state
let m = Group((reference = Step(t_step = 0.5, after = 5.0),
               controller = PID(Kp = AsPort(), Ki = 0.5, Kd = 0.2, Tt = 1.0), gain = Integrator(x0 = 1.0), plant = Integrator());
              local_wires = ("reference/y" => "controller/r", "plant/y" => "controller/y",
                             "controller/u" => "gain/u", "gain/y" => "controller/Kp", "controller/u" => "plant/u"))
    pr("116 Kp from an integrator of the own u builds", tryb(() -> build(m)) isa Build)
end

# --- 132: a scalar flag into a vector PID's engaged
let mk(eng, extra = (;), wires = ()) = Group(merge((reference = Constant(SVector(1.0, 2.0)),
            controller = PID(Kp = SVector(1.0, 1.0), hold = true), free = Constant(SVector{2, Int8}(0, 0)),
            plant = Integrator(x0 = SVector(0.0, 0.0))), extra);
            local_wires = ("reference/y" => "controller/r", "plant/y" => "controller/y",
                           "free/y" => "controller/saturation", "controller/u" => "plant/u", wires...))
    r1 = tryb(() -> build(mk(nothing, (flag = Constant(true),), ("flag/y" => "controller/engaged",))))
    pr("132 scalar Bool into SVector{2,Bool} engaged", r1 isa Build ? "builds" : r1)
    r2 = tryb(() -> build(mk(nothing, (flag = Constant(true), bcast = Fn{Bool, SVector{2, Bool}}(f -> SVector(f, f))),
                             ("flag/y" => "bcast/u", "bcast/y" => "controller/engaged"))))
    pr("132 broadcast flag", r2 isa Build ? "builds" : r2)
end

end # ONLY128
# --- 128: the switchover bumps
function sib(a, b; kis = false)
    wires = Pair{String, String}["ref_a/y" => "a/r", "ref_b/y" => "b/r", "plant/y" => "a/y", "plant/y" => "b/y",
        "a/u" => "sel/in1", "b/u" => "sel/in2", "sel/y" => "plant/u", "sel/y" => "delay/u",
        "delay/y" => "a/v", "delay/y" => "b/v"]
    kis && append!(wires, ["kia/y" => "a/Ki", "kib/y" => "b/Ki"])
    kids = (ref_a = Step(t_step = 0.5, after = 5.0), ref_b = Constant(2.0), a = a, b = b, sel = Switch{Float64}(),
            plant = DiscreteIntegrator(), delay = UnitDelay(0.0))
    Group(merge(kids, kis ? (kia = Fn{Bool, Float64}(m -> m ? 0.5 : 0.0), kib = Fn{Bool, Float64}(m -> m ? 0.0 : 0.5)) : (;));
          input_wires = ("mode" => (kis ? ("sel/select", "kia/u", "kib/u") : ("sel/select",)),), local_wires = Tuple(wires))
end
function bump(model)
    sim = Simulation(model; Δt_frame = 1//100)
    init!(sim, set(u = (mode = false,)))
    step!(sim; frames = 200)
    before = port(sim, "sel")
    poke!(sim, "mode", true)
    step!(sim; frames = 1)
    abs(port(sim, "sel") - before)
end
g = (Kp = 1.0, Kd = 0.2, τd = 0.1)
pr("128 tracking always Tt=1", tryb(() -> bump(sib(DiscretePID(; g..., Ki = 0.5, Tt = 1.0, tracking = true),
                                                   DiscretePID(; g..., Ki = 0.5, Tt = 1.0, tracking = true)))))
for Tt in (1.0, 0.1)
    pr("128 Ki zero off command Tt=$Tt", tryb(() -> bump(sib(DiscretePID(; g..., Ki = AsPort(), Tt = Tt, tracking = true),
                                                         DiscretePID(; g..., Ki = AsPort(), Tt = Tt, tracking = true); kis = true))))
end
