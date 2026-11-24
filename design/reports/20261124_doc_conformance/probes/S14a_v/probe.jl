# S14a_v independent verifier probes (read-only, worktree W at bd471af7).
using Test, BenchmarkTools
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test/imports.jl"))
include(joinpath(W, "test/fixtures.jl"))
include(joinpath(W, "test/utils.jl"))
using Redstone: set, at, combine, override, init!, resolve_condition, build, checkpoint, step!, Simulation

function P(label, f)
    r = try f() catch e; e end
    if r isa DiagnosticError
        ds = r.carried isa Vector ? r.carried : [r.carried]
        println(label, " => ", [(nameof(typeof(d)), hasproperty(d, :reason) ? d.reason : nothing) for d in ds])
    elseif r isa Exception
        println(label, " => EXC ", typeof(r))
    else
        println(label, " => ", r)
    end
end

# 001: modes on a discrete component
struct DiscWithModes <: AbstractComponent end
Redstone.s_init(::DiscWithModes) = (n = 0,)
Redstone.m_init(::DiscWithModes) = (phase = :idle,)
Redstone.y_types(::DiscWithModes) = (y = Float64,)
Redstone.y_state(::DiscWithModes, (; s)) = (y = Float64(s.n),)
Redstone.s_update(::DiscWithModes, (; s)) = (n = s.n + 1,)
P("001 discrete+m_init build", () -> (build(Group((; d = DiscWithModes()))); :built))
tri() = Group((; plant = Plant(), ctl = DiscreteAccumulator(3.0), trig = Trigger(0.5));
              local_wires = ("plant/y" => "trig/sig",), input_wires = ("u" => "plant/u", "e" => "ctl/e"))
tb = build(tri())
P("001 m on discrete ctl", () -> resolve_condition(at("ctl", set(m = (phase = :x,))), tb))
P("001 m on continuous trig ok", () -> resolve_condition(combine(at("trig", set(m = (state = :armed,))), set(u = (u = 0.0, e = 0.0))), tb) isa Redstone.ConditionPlan)

# 023/024: set payload checks at composition
P("023 set(x=1.0)", () -> set(x = 1.0) isa Redstone.Fragment)
P("023 set(s=(1,2), m=\"str\")", () -> set(s = (1, 2), m = "str") isa Redstone.Fragment)
P("024 set(x=nothing)", () -> set(x = nothing))
P("024 set(u=[1.0])", () -> set(u = [1.0]) isa Redstone.Fragment)

# 049: selector defaults
P("049 get_state default leaf", () -> Redstone.get_state("a").leaf)
P("049 get_input default leaf", () -> Redstone.get_input().leaf)
P("049 get_face default leaf", () -> Redstone.get_face().leaf)

# 010 + 067 + 076: offset pair, boundary zero, checkpoint, t0 default
offset_pair() = Group((; hold = ZOH(), off = DiscreteAccumulator(1.0));
                      local_wires = ("hold/out" => "off/e",),
                      input_wires = ("in" => "hold/in",),
                      output_wires = ("hold/out" => "held", "off/u" => "acc"),
                      sample_times = (; hold = Relative(2, 1), off = Relative(2, 1)))
sim = Simulation(offset_pair(); Δt_frame = 1//100)
total = combine(at("off", set(s = (acc = 7.0,))), set(u = (in = 3.0,)))
init!(sim, total)
P("067 held published at t0", () -> Redstone.port(sim, "", :held))
P("067 acc published at t0", () -> Redstone.port(sim, "", :acc))
P("067 offset s_update did not run", () -> Redstone.state(sim, "off").acc)
P("076 default t0 clock", () -> sim.model.exec.clock)
P("076 init! kw default", () -> Base.kwarg_decl(first(methods(Redstone.init!, (Redstone.Model, Redstone.ConditionPlan)))))
ck = checkpoint(sim)
P("010 combine(checkpoint)", () -> combine(ck))
P("010 at(p, checkpoint)", () -> at("off", ck))
P("010 init!(sim, checkpoint)", () -> init!(sim, ck))
P("010 set(s=checkpoint) resolves", () -> init!(sim, combine(total, at("off", set(s = ck)))))
