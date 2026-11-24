module P
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
using ComponentArrays
using Base.CoreLogging: with_logger
const T = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/"
include(T * "imports.jl")
include(T * "fixtures.jl")
include(T * "utils.jl")

const PEND_G_L = 9.81
pr(tag, x) = println("PROBE ", tag, " => ", x)
function err(f)
    try; f(); nothing; catch e; e; end
end
ds(e) = e isa DiagnosticError ? (e.carried isa Diagnostic ? [e.carried] : e.carried) : e
function guard(tag, f)
    try f() catch e; pr(tag * " CRASH", sprint(showerror, e)[1:min(end, 400)]) end
end

lin_pend() = Group((; s = Sum(), c = Pendulum()); local_wires = ("s/e" => "c/u",),
                   input_wires = ("τ" => "s/a", "d" => "s/b"),
                   output_wires = ("c/θ" => "θ", "s/e" => "u_eff"))
lin_point(θ = 0.3) = combine(at("c", condition(Pendulum(); θ = θ)),
                             set(u = (τ = PEND_G_L * sin(θ), d = 0.0)))

# --- 002/203: condition is a function of d; commit = init!(override(baseline, condition(d*)))
guard("203", () -> begin
    sim = Simulation(fed(Pendulum()); Δt_frame = 1//10)
    calls = Ref(0)
    cond = d -> (calls[] += 1; combine(at("c", condition(Pendulum(); θ = 0.5)), set(u = (in = d.u,))))
    p = TrimProblem(; guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,),
        condition = cond, reads = reads(w = get_deriv("c", :ω)),
        residuals = (r, d) -> (torque = r.w,), tolerances = (torque = 1e-9,))
    base = set(u = (in = 0.0,))
    rep = trim!(sim, p; baseline = base)
    pr("203 converged", rep.converged)
    pr("002 condition called", calls[])
    ref = Simulation(fed(Pendulum()); Δt_frame = 1//10)
    init!(ref, override(base, cond(rep.solution)))
    pr("203 same checkpoint x", checkpoint(sim).state.x == checkpoint(ref).state.x)
    ta, tb = checkpoint(sim).state.table, checkpoint(ref).state.table
    pr("203 table stores", (ta.stores, tb.stores))
    pr("203 same s/m/t", (isequal(checkpoint(sim).state.s, checkpoint(ref).state.s), checkpoint(sim).state.t == checkpoint(ref).state.t))
    # non-converging: no commit
    sim2 = Simulation(fed(Pendulum()); Δt_frame = 1//10)
    p2 = TrimProblem(; guess = (u = 0.0,), lower = (u = 0.0,), upper = (u = 0.1,),
        condition = cond, reads = reads(w = get_deriv("c", :ω)),
        residuals = (r, d) -> (torque = r.w,), tolerances = (torque = 1e-9,))
    rep2 = trim!(sim2, p2; baseline = base)
    pr("203 nonconv converged/lifecycle", (rep2.converged, lifecycle(sim2)))
end)

# --- 011/013/022/185: at on problem, read set, tap set, node
guard("013", () -> begin
    r = reads(a = get_state("c", :θ))
    r1 = at("wing", r); r2 = at("lead", r1)
    pr("013 Reads?", (r1 isa Reads, r1.prefixes, r2.prefixes, r2.selectors === r.selectors))
    pr("013 not Scoped", !(r1 isa Scoped))
    e = err(() -> at("", r)); pr("022 at empty on reads", (typeof(ds(e)[1]), ds(e)[1].reason))
    p = TrimProblem(; guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,),
        condition = d -> set(u = (in = d.u,)), reads = r,
        residuals = (r, d) -> (q = r.a,), tolerances = (q = 1e-9,))
    pm = at("wing", p)
    pr("011 problem lift reads prefixes", pm.reads.prefixes)
    pr("011 problem lift condition", typeof(pm.condition((u = 1.0,))))
    pr("011 other fields same", (pm.guess === p.guess, pm.residuals === p.residuals, pm.tolerances === p.tolerances, pm.checks === p.checks))
    e = err(() -> at("", p)); pr("022 at empty on problem", e === nothing ? nothing : (typeof(ds(e)[1]), ds(e)[1].reason))
    tp = taps(x = (a = get_state("c", :θ),))
    e = err(() -> at("", tp)); pr("022 at empty on taps", (typeof(ds(e)[1]), ds(e)[1].reason))
    pn = TrimProblem(; guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,),
        condition = d -> set(u = (in = d.u,)), reads = (a = get_state("c", :θ),),
        residuals = (r, d) -> (q = r.a,), tolerances = (q = 1e-9,))
    pnm = at("wing", pn)
    pr("011 non-Reads reads passes through", pnm.reads === pn.reads)
    e = err(() -> at("wing", (a = get_state("c", :θ),)))
    pr("011 spec sketch's at(prefix, non-Reads)", (typeof(ds(e)[1]), ds(e)[1].reason))
    e = err(() -> at("", pn)); pr("022 at empty on problem w/ non-Reads reads", e === nothing ? "no throw" : typeof(ds(e)[1]))
    pr("011 at String vs SubString", typeof(at(SubString("wing", 1), p)))
    node = set(x = (θ = 1.0,))
    sc = at("c", node)
    pr("185 Scoped stores", (sc isa Scoped, fieldnames(Scoped), getfield(sc, 1), getfield(sc, 2) === node))
end)

# --- 043: isbits handle as an ordinary root input
struct HandleQ; k::Float64; end
query(h::HandleQ, z) = h.k * z
Redstone.probe_value(::Type{HandleQ}) = HandleQ(1.0)
struct EnvUser <: AbstractComponent end
x_init(::EnvUser) = (q = 1.0,)
u_types(::EnvUser) = (env = HandleQ,)
y_types(::EnvUser) = (q = Float64,)
y_state(::EnvUser, (; x)) = (q = x.q,)
x_deriv(::EnvUser, (; x, u)) = (q = -query(u.env, x.q),)
guard("043", () -> begin
    g = Group((; c = EnvUser()); input_wires = ("env" => "c/env",))
    sim = Simulation(g; Δt_frame = 1//10)
    pr("043 root inputs", sim.model.deployment.build.structure.root_inputs)
    pr("043 isbits", isbitstype(HandleQ))
    e = err(() -> init!(sim, set()))
    pr("043 uncovered", e === nothing ? nothing : (typeof(ds(e)[1]), ds(e)[1].faces))
    init!(sim, set(u = (env = HandleQ(2.0),)))
    pr("043 init ok", lifecycle(sim))
    lin = linearize(sim, taps(x = (q = get_state("c", :q),)))
    pr("043 linearize A", lin.A)
end)

# --- 059: seeded tap step rules
struct IntState <: AbstractComponent end
x_init(::IntState) = (q = 1.0, v = SVector(1.0, 2.0))
y_types(::IntState) = (q = Float64,)
y_state(::IntState, (; x)) = (q = x.q,)
x_deriv(::IntState, (; x)) = (q = -x.q, v = -x.v)
struct F32Consumer <: AbstractComponent end
x_init(::F32Consumer) = (q = 0.0,)
u_types(::F32Consumer) = (w = Float32,)
y_types(::F32Consumer) = (q = Float64,)
y_state(::F32Consumer, (; x)) = (q = x.q,)
x_deriv(::F32Consumer, (; x, u)) = (q = u.w - x.q,)
guard("059", () -> begin
    sim = Simulation(single(IntState()); Δt_frame = 1//10)
    init!(sim)
    lin = linearize(sim, taps(x = (v1 = get_state("c", "v[1]"), q = get_state("c", :q))))
    pr("059 index step ok", lin.A)
    e = err(() -> linearize(sim, taps(x = (v = get_state("c", :v),))))
    pr("059/249 whole SVector x tap", [(typeof(d), d.reason) for d in ds(e)])
    sim2 = Simulation(fed(F32Consumer(), "w"); Δt_frame = 1//10)
    init!(sim2, set(u = (in = 1.0f0,)))
    e = err(() -> linearize(sim2, taps(u = (w = get_input(:in),))))
    pr("059 Float32 u tap", [(typeof(d), d.reason, d.declared) for d in ds(e)])
end)

# --- 069/123: discrete store in x; root input a discrete consumer reads
lin_sampled() = Group((; ctl = DiscreteAccumulator(1.0), c = Pendulum());
                      local_wires = ("ctl/u" => "c/u",), input_wires = ("in" => "ctl/e",))
lin_sampled_point() = combine(at("ctl", set(s = (acc = 4.0,))),
                              at("c", condition(Pendulum(); θ = asin(4.0 / PEND_G_L))),
                              set(u = (in = 0.0,)))
guard("069", () -> begin
    sim = Simulation(lin_sampled(); Δt_frame = 1//10)
    e = err(() -> linearize(sim, taps(x = (acc = get_state("ctl", :acc),)); about = lin_sampled_point()))
    d = ds(e)[1]
    pr("069 discrete x tap", (typeof(d), d.reason, d.tap, d.path, d.field, :tier in fieldnames(typeof(d))))
    pr("069 message", Redstone.message(d))
    e = err(() -> linearize(sim, taps(u = (in = get_input(:in),)); about = lin_sampled_point()))
    d = ds(e)[1]
    pr("123 discrete consumer root input", (typeof(d), d.reason, d.pinning))
    # cell type at seeded activation: frozen Float64?
    b = sim.model.deployment.build
    act = Redstone.activation(b, LinearizeDual)
    pr("123 seeded cell type", Redstone._port_type(act.layout.addr[("", :in)]))
end)

# --- 113: fan-out meet
guard("113", () -> begin
    g = Group((; h = Gain(1.0), g = PinnedGain(), c = Pendulum(), z = Pendulum());
              local_wires = ("g/out" => "c/u", "h/out" => "z/u"), input_wires = ("τ" => ("h/e", "g/e"),))
    sim = Simulation(g; Δt_frame = 1//10)
    e = err(() -> linearize(sim, taps(u = (τ = get_input(:τ),)); about = set(u = (τ = 0.0,))))
    d = ds(e)[1]
    pr("113 fan-out meet", (typeof(d), d.reason, d.pinning))
end)

# --- 082/091/103: checkpoint conversion, scratch, unseeded constant
guard("082", () -> begin
    sim = Simulation(lin_pend(); Δt_frame = 1//10)
    init!(sim, lin_point())
    cp_before = checkpoint(sim)
    xbuf_before = copy(sim.model.exec.xbuf)
    lin = linearize(sim, taps(x = (θ = get_state("c", :θ), ω = get_state("c", :ω)), u = (τ = get_input(:τ),),
                             y = (u_eff = get_face(:u_eff),)))
    pr("082 u₀ is checkpoint value", (lin.u₀, PEND_G_L * sin(0.3)))
    pr("103 D (d unseeded)", (lin.D, size(lin.B)))
    pr("091 sim untouched", (sim.model.exec.xbuf == xbuf_before, checkpoint(sim).state.x == cp_before.state.x, lifecycle(sim)))
    lin2 = linearize(sim, taps(x = (θ = get_state("c", :θ), ω = get_state("c", :ω)), u = (τ = get_input(:τ),),
                              y = (u_eff = get_face(:u_eff),)))
    pr("091 repeatable", lin2.A == lin.A && lin2.B == lin.B)
    # instrument: count Model constructions? check _scratch returns a fresh model each call
    m1 = Redstone._scratch(sim.model, Float64); m2 = Redstone._scratch(sim.model, Float64)
    pr("091 _scratch fresh", (m1 !== m2, m1.exec.xbuf !== m2.exec.xbuf, m1.exec.xbuf !== sim.model.exec.xbuf))
end)

# --- 133/221: labeled with empty lists
guard("133", () -> begin
    sim = Simulation(lin_pend(); Δt_frame = 1//10)
    init!(sim, lin_point())
    bare = labeled(linearize(sim, taps(x = (θ = get_state("c", :θ),))))
    pr("133 types", [(f, typeof(getfield(bare, f))) for f in (:ẋ₀, :x₀, :u₀, :y₀, :A, :B, :C, :D)])
    onlyu = labeled(linearize(sim, taps(u = (τ = get_input(:τ),))))
    pr("133 only u types", [(f, typeof(getfield(onlyu, f))) for f in (:ẋ₀, :x₀, :u₀, :y₀, :A, :B, :C, :D)])
end)

# --- 168: freeze door, Pinned output
struct StripOut <: AbstractComponent end
x_init(::StripOut) = nothing
u_types(::StripOut) = (e = Float64,)
y_types(::StripOut) = (out = Pinned{Float64},)
y_direct(::StripOut, (; u)) = (out = 2ForwardDiff.value(u.e),)
struct LeakOut <: AbstractComponent end
x_init(::LeakOut) = nothing
u_types(::LeakOut) = (e = Float64,)
y_types(::LeakOut) = (out = Pinned{Float64},)
y_direct(::LeakOut, (; u)) = (out = 2u.e,)
guard("168", () -> begin
    g = Group((; s = StripOut()); input_wires = ("in" => "s/e",), output_wires = ("s/out" => "out",))
    sim = Simulation(g; Δt_frame = 1//10)
    lin = linearize(sim, taps(u = (in = get_input(:in),), y = (out = get_face(:out),)); about = set(u = (in = 1.0,)))
    pr("168 frozen output D row", lin.D)
    g2 = Group((; s = LeakOut()); input_wires = ("in" => "s/e",), output_wires = ("s/out" => "out",))
    e = err(() -> begin
        sim2 = Simulation(g2; Δt_frame = 1//10)
        linearize(sim2, taps(u = (in = get_input(:in),), y = (out = get_face(:out),)); about = set(u = (in = 1.0,)))
    end)
    pr("168 leak", e === nothing ? nothing : sprint(showerror, e)[1:min(end, 500)])
end)

# --- 194/212: init! trace kw; restore!(sim, ModelState)
guard("194", () -> begin
    sim = Simulation(fed(Pendulum()); Δt_frame = 1//10)
    init!(sim, set(u = (in = 0.0,)); trace = false)
    e = err(() -> trace(sim))
    pr("194 trace=false", e === nothing ? nothing : (typeof(ds(e)[1]), ds(e)[1].reason))
    pr("194 default", Base.kwarg_decl(first(methods(init!, (Simulation, Any)))))
    pr("212 method", hasmethod(restore!, Tuple{Simulation, ModelState{Float64}}))
    m = Model(fed(Pendulum()); Δt_frame = 1//10)
    init!(m, set(u = (in = 0.0,)))
    st = checkpoint(m)
    pr("212 state type", typeof(st))
    sim3 = Simulation(fed(Pendulum()); Δt_frame = 1//10)
    restore!(sim3, st)
    pr("212 restored lifecycle", lifecycle(sim3))
end)

# --- 230/239/242/249/258/267/276: diagnostics
guard("diag", () -> begin
    pr("230 fields", fieldnames(ConditionResolution))
    e = err(() -> combine(set(), (a = 1,)))
    pr("239 ConditionNodeMisuse", (typeof(e.carried), Redstone.severity(e.carried)))
    sim = Simulation(lin_pend(); Δt_frame = 1//10)
    e = err(() -> init!(sim, set(u = (τ = 0.0,))))
    pr("242 UninitializedInputs", (typeof(e.carried), e.carried, Redstone.severity(e.carried), lifecycle(sim)))
    e = err(() -> reads(a = 1))
    pr("276 not_a_selector", (typeof(e.carried), e.carried.reason, e.carried.label))
    p = TrimProblem(; guess = (u = 0,), lower = (u = -Inf,), upper = (u = Inf,),
        condition = d -> set(u = (in = d.u,)), reads = reads(w = get_deriv("c", :ω)),
        residuals = (r, d) -> (q = r.w,), tolerances = (q = 1e-9,))
    sim2 = Simulation(fed(Pendulum()); Δt_frame = 1//10)
    e = err(() -> trim!(sim2, p; baseline = set(u = (in = 0.0,))))
    pr("258 field_types", [(typeof(d), d.field, d.reason, d.bad) for d in ds(e)])
    # 267: checks that fail at the committed state
    sim3 = Simulation(fed(Pendulum()); Δt_frame = 1//10)
    p3 = TrimProblem(; guess = (u = 0.0,), lower = (u = -Inf,), upper = (u = Inf,),
        condition = d -> combine(at("c", condition(Pendulum(); θ = 0.5)), set(u = (in = d.u,))),
        reads = reads(w = get_deriv("c", :ω)),
        residuals = (r, d) -> (torque = r.w,), tolerances = (torque = 1e-9,),
        checks = (r, d) -> (always = 1.0,), check_tolerances = (always = 1e-9,))
    logger = Test.TestLogger()
    rep = with_logger(() -> trim!(sim3, p3; baseline = set(u = (in = 0.0,))), logger)
    pr("267 converged", rep.converged)
    pr("267 log records", [(r.level, first(string(r.message), 80)) for r in logger.logs])
    pr("267 severity", Redstone.severity(TrimCommitChecks(checks = Tuple{Symbol,Float64,Float64}[])))
end)
end
