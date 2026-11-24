# S9a verifier probe: run from the pinned worktree with --project=test.
using Redstone, StaticArrays
include(joinpath(pwd(), "test", "imports.jl"))
import Redstone: x_init, s_init, m_init, ws_init, u_types, y_types, y_state, y_direct,
                 x_deriv, s_update, x_projection, state_events

const CALLS = Dict{Symbol,Int}()
bump(k) = (CALLS[k] = get(CALLS, k, 0) + 1; nothing)
show_calls(label) = (println(label, " ", sort(collect(CALLS); by = first)); empty!(CALLS))

struct Cnt <: AbstractComponent end
x_init(::Cnt) = (bump(:x_init); (q = 0.0,))
m_init(::Cnt) = (bump(:m_init); (on = false,))
ws_init(::Cnt, ::Type{T}) where {T} = (bump(:ws_init); (buf = zeros(T, 2),))
u_types(::Cnt) = (u = Float64,)
y_types(::Cnt) = (y = Float64, p = Float64)
y_state(::Cnt, (; x)) = (bump(:y_state); (y = x.q,))
y_direct(::Cnt, (; u)) = (bump(:y_direct); (p = u.u,))
x_deriv(::Cnt, (; u)) = (bump(:x_deriv); (q = u.u,))
x_projection(::Cnt, x) = (bump(:x_projection); x)
cguard(::Cnt, (; x)) = (bump(:guard); x.q - 1.0)
chandler(::Cnt, b) = (bump(:handler); (m = (on = true,),))
state_events(::Cnt) = (e = StateEvent(cguard, chandler),)

struct DCnt <: AbstractComponent end
s_init(::DCnt) = (bump(:s_init); (n = 0,))
y_types(::DCnt) = (k = Int,)
y_state(::DCnt, (; s)) = (bump(:d_y_state); (k = s.n,))
s_update(::DCnt, (; s)) = (bump(:s_update); (n = s.n + 1,))

struct BadStore <: AbstractComponent end
s_init(::BadStore) = (name = "abc",)
y_types(::BadStore) = (k = Int,)
y_state(::BadStore, (; s)) = (k = 1,)
s_update(::BadStore, (; s)) = s

struct NoStore <: AbstractComponent end
y_types(::NoStore) = (k = Float64,)
y_direct(::NoStore, _) = (k = 1.0,)

world() = Group((; c = Cnt(), d = DCnt()); input_wires = ("u" => "c/u",))

function refusal(f)
    try
        f(); return "no throw"
    catch err
        err isa Redstone.DiagnosticError || return "other: $(typeof(err)) $(sprint(showerror, err))"
        return [(typeof(d).name.name, d) for d in err.carried]
    end
end

empty!(CALLS)
b = build(world())
show_calls("021 build counts:")
println("019/177 methods: ", methods(Redstone._nominal), " | ", methods(Redstone._activate))
println("105 timings: ", [(e.path, e.timing) for e in b.structure.components])
println("141 Structure fields: ", fieldnames(Redstone.Structure), " root_inputs=", b.structure.root_inputs)
println("195 Build fields: ", fieldnames(Build))
println("186 Deployment concrete/no params: ", isconcretetype(Deployment), " ", fieldtypes(Deployment))

dep = Deployment(b; Δt_frame = 1//10)
empty!(CALLS)
m = Model(dep)
show_calls("029 Model(dep) counts:")
empty!(CALLS)
m2 = Model(dep, Redstone.ProbeDual)
show_calls("029 Model(dep, ProbeDual) counts:")

# 030 / 204 / 213
sim = Simulation(m)
println("030 Simulation(model) -> ", typeof(sim).name.name)
println("213 second claim: ", refusal(() -> Simulation(m)))
sim2 = Simulation(dep)
println("204 Simulation(dep) model: ", typeof(sim2.model) <: Model{Float64}, " claimed=", sim2.model.claimed)
# 222: standalone model state into a simulation through restore!
ms = Model(dep); init!(ms, set(u = (u = 0.0,))); st = checkpoint(ms)
println("222 constructor on initialized model: ", refusal(() -> Simulation(ms)))
sim3 = Simulation(Model(dep))
println("222 restore! into sim: ", refusal(() -> restore!(sim3, st)), " lifecycle=", Redstone.lifecycle(sim3))

# 050 / 051 / 010: typo'd destination
r = refusal(() -> build(Group((; c = Cnt(), d = DCnt()); input_wires = ("u" => "c/uu",))))
println("050/051/010 typo: ", r)
for (k, d) in r
    k === :UnknownPort && println("   candidates = ", d.candidates, " msg: ", Redstone.message(d))
end
# typo'd source in local_wires
r = refusal(() -> build(Group((; c = Cnt(), c2 = Cnt()); local_wires = ("c/yy" => "c2/u",),
                               input_wires = ("u" => "c/u",))))
for (k, d) in r
    k === :UnknownPort && println("051 source typo candidates = ", d.candidates, " endpoint=", d.endpoint)
end

# 069
println("069 isbits: ", refusal(() -> build(BadStore())))
# 087
println("087 no store: ", refusal(() -> build(NoStore())))
# 096
println("096 Absolute(0): ", refusal(() -> build(Group((; d = DCnt()); sample_times = (d = Absolute(0),)))))
# 114: composed divisor past Int
inner = Group((; d = DCnt()); sample_times = (d = Relative(2^40),))
println("114 overflow: ", refusal(() -> build(Group((; g = inner); sample_times = (g = Relative(2^40),)))))
# 132: gcd past Rational{Int}
p1, p2 = 4294967291, 4294967279
println("132 no common Rational: ", refusal(() -> build(Group((; a = DCnt(), z = DCnt());
        sample_times = (a = Absolute(1//p1), z = Absolute(1//p2))))))
