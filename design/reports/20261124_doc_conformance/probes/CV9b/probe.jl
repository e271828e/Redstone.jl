using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test", "imports.jl"))
include(joinpath(W, "test", "fixtures.jl"))
using Redstone: u_types, y_types, x_init, input_wires, output_wires, local_wires, sample_times

function try_(label, f)
    try
        r = f()
        println(label, " => OK ", repr(r)[1:min(end,160)])
    catch e
        c = e isa DiagnosticError ? e.carried : e
        println(label, " => THROW ", typeof(e), " ", c isa Vector ? [(typeof(x), hasproperty(x,:reason) ? x.reason : nothing) for x in c] :
                (c isa Diagnostic ? (typeof(c), hasproperty(c,:reason) ? c.reason : nothing, hasproperty(c,:argument) ? c.argument : nothing) : sprint(showerror, c)[1:min(end,200)]))
    end
end

# --- Model
println("P1 fields: ", fieldnames(Model))
root = feedback_model()
b = build(root)
try_("P2 chunk_size=0", () -> Model(b; Δt_frame = 1//10, chunk_size = 0))
try_("P3 scalar Float32", () -> Model(b, Float32; Δt_frame = 1//10))
try_("P4 scalar Float32 + bad kw (composed)", () -> Model(b, Float32; Δt_frame = -1))
try_("P5 scalar Float32 + missing Δt_frame (root)", () -> Model(root, Float32))
dep = Deployment(b; Δt_frame = 1//10)
try_("P6 scalar bad + chunk_size bad (deployment)", () -> Model(dep, Float32; chunk_size = 0))
try_("P7 chunk_size 2.0", () -> Model(dep; chunk_size = 2.0))
m = Model(dep)
println("P8 status ", m.status, " claimed ", m.claimed, " fresh ", m.fresh)
try_("P9 checkpoint at :built", () -> checkpoint(m))
try_("P10 init! no value", () -> init!(m))
init!(m, set(u = (ref = 0.0,)))
println("P11 status ", m.status)
try_("P12 port root path", () -> port(m, "", :ref))
try_("P12b port root path noname", () -> port(m, ""))
try_("P13 port assembly output", () -> port(m, "plant", :y))
try_("P14 port unknown", () -> port(m, "plant", :zzz))
try_("P15 port noname named contract", () -> port(m, "plant"))
try_("P16 port unknown path", () -> port(m, "nope/x", :y))
try_("P17 state plant", () -> state(m, "plant"))
try_("P18 state root (assembly)", () -> state(m, ""))
try_("P19 state ctl (stateless)", () -> state(m, "ctl"))
try_("P20 modes ctl", () -> modes(m, "ctl"))
try_("P21 state nope", () -> state(m, "nope"))
try_("P22 warnings", () -> warnings(m))
pb = phase_bodies(m)
println("P23 phase_bodies keys ", keys(pb))
try_("P24 init! t0=NaN", () -> init!(m, set(u = (ref = 0.0,)); t0 = NaN))
println("P24b status after refused t0: ", m.status)
cp = checkpoint(m)
println("P25 cp type ", typeof(cp))
try_("P26 restore", () -> restore!(m, cp))
m2 = Model(dep, Float64)
try_("P27 restore onto :built", () -> restore!(m2, cp))
println("P27b status ", m2.status)
mD = Model(dep, ForwardDiff.Dual{Nothing,Float64,1})
try_("P28 restore scalar mismatch", () -> restore!(mD, cp))
try_("P29 overlay! at built", () -> overlay!(Model(dep), set(u=(ref=1.0,))))
try_("P30 overlay!", () -> overlay!(m, set(u = (ref = 1.0,))))
# claim
mc = Model(dep)
sim = Simulation(mc)
m_ = m; m = mc
println("P31 claimed ", m.claimed)
try_("P32 init! claimed", () -> init!(m, set(u = (ref = 0.0,))))
try_("P33 overlay claimed", () -> overlay!(m))
try_("P34 restore claimed", () -> restore!(m, cp))
try_("P35 checkpoint claimed", () -> checkpoint(m))
m = m_
try_("P36 frame! claimed", () -> frame!(mc, 1))
try_("P36b trim claimed", () -> Redstone.trim!(mc, nothing))
# restore with bad hand-built t0
try_("P37 hand-built bad t0 state", () -> begin
    mm = Model(dep); 
    bad = Redstone.ModelState{Float64}(cp.xbuf, cp.s, cp.m, cp.stores, cp.priors, cp.stepper, cp.t, 1e-4, cp.deployment, cp.layout)
    restore!(mm, bad)
end)
println("P37b ModelState fields: ", fieldnames(Redstone.ModelState))

# --- Structure
s = b.structure
println("S1 fields ", fieldnames(Structure))
println("S2 anchors ", s.anchors, " scopes ", s.scopes, " root_inputs ", s.root_inputs, " root_types ", s.root_types)
println("S3 levels ", [(l.path, [(c.segment, c.field) for c in l.children], l.wires) for l in s.levels])
println("S4 components ", [(c.path, c.tier, c.timing) for c in s.components])
show(stdout, MIME("text/plain"), s); println()
println("S5 terminal_producer ", Redstone.terminal_producer(s, ("plant", :u)), " ", Redstone.terminal_producer(s, ("sum", :a)))
println("S6 face_routes ", Redstone.face_routes(s, ("", :ref)))
println("S7 membership ", [Redstone.membership(c) for c in s.levels[1].children])
# prim root
pb2 = build(Plant())
println("S8 prim root levels ", pb2.structure.levels, " root_inputs ", pb2.structure.root_inputs, " root_types ", pb2.structure.root_types)

# group with container
struct SampledC <: AbstractComponent end
s_init(::SampledC) = 0
y_types(::SampledC) = (n = Int,)
y_state(::SampledC, (; s)) = (n = s,)
s_update(::SampledC, (; s)) = s + 1
import Redstone: s_init, y_state, s_update
g = Group((; a = SampledC(), b = SampledC()); sample_times = (a = Relative(2), b = Absolute(1//2, 0)))
bs = build(g)
println("S9 anchors ", bs.structure.anchors, " scopes ", bs.structure.scopes)
show(stdout, MIME("text/plain"), bs.structure); println()
# rates violations
for (lab, st) in [("deep key", (var"a/b" = Relative(2),)), ("unknown", (zz = Relative(2),)), ("bare int", (a = 2,)),
                  ("mult", (a = Relative(0),)), ("phase", (a = Relative(2, 2),)), ("period", (a = Absolute(0, 0),)),
                  ("offset", (a = Absolute(1, 1),)), ("shape", [1]), ("range", (a = Relative(typemax(Int)÷2+1),))]
    try_("R $lab", () -> build(Group((; a = SampledC()); sample_times = st)))
end
try_("R continuous child", () -> build(Group((; p = Plant()); sample_times = (p = Relative(2),), input_wires = ("u" => "p/u",))))
try_("R two-level range", () -> build(Group((; k = Group((; a = SampledC()); sample_times = (a = Relative(typemax(Int)÷2+1),))); sample_times = (k = Relative(3),))))
# wires
try_("W bare pair", () -> build(Group((; a = Gain(1.0)); input_wires = "u" => "a/e")))
try_("W string", () -> build(Group((; a = Gain(1.0)); input_wires = "u")))
try_("W nonpair", () -> build(Group((; a = Gain(1.0)); input_wires = (1,))))
try_("W face slash", () -> build(Group((; a = Gain(1.0)); input_wires = ("u/x" => "a/e",))))
try_("W face empty", () -> build(Group((; a = Gain(1.0)); input_wires = ("" => "a/e",))))
try_("W face collision", () -> build(Group((; a = Gain(1.0)); input_wires = ("u" => "a/e",), output_wires = ("a/out" => "u",))))
try_("W direction", () -> build(Group((; a = Gain(1.0), b = Gain(1.0)); local_wires = ("a/e" => "b/e",), input_wires=("u"=>"a/e",))))
try_("W one-segment", () -> build(Group((; a = Gain(1.0), b = Gain(1.0)); local_wires = ("a" => "b/e",), input_wires=("u"=>"a/e",))))
try_("W empty route", () -> build(Group((; a = Gain(1.0)); input_wires = ("u" => (),))))
try_("W two producers", () -> build(Group((; a = Gain(1.0), b = Gain(1.0)); local_wires = ("b/out" => "a/e",), input_wires = ("u" => "a/e", "v" => "b/e"))))
try_("W unconnected", () -> build(Group((; a = Gain(1.0), b = Gain(1.0)); local_wires = ("b/out" => "a/e",))))
# primitive root collision
struct Coll <: AbstractComponent end
x_init(::Coll) = nothing
u_types(::Coll) = (q = Float64,)
y_types(::Coll) = (q = Float64,)
Redstone.y_direct(::Coll, (; u)) = (q = u.q,)
try_("W root collision", () -> build(Coll()))
# resolve_authored via condition path
try_("C deep path", () -> init!(Model(dep), set(u=(ref=0.0,)) ; t0 = 0))
try_("C at deep", () -> init!(Model(dep), combine(set(u=(ref=0.0,)), at("plant/zz", set(x=(q=SVector(0.0,0.0),))))))
try_("C at deep2", () -> init!(Model(dep), combine(set(u=(ref=0.0,)), at("plant/q/zz", set(x=(q=SVector(0.0,0.0),))))))

println("---- second batch")
try_("Q1 port root y", () -> port(m, "", :y))
try_("Q2 hand-built bad t0", () -> begin
    mm = Model(dep)
    bad = Redstone.ModelState{Float64}(cp.x, cp.s, cp.m, cp.table, cp.prior, cp.stepper, cp.t, 1e-4, cp.deployment, cp.layout)
    restore!(mm, bad)
end)
b2 = build(bare_world())
D1 = ForwardDiff.Dual{Nothing,Float64,1}
mf = Model(b2; Δt_frame = 1//10)
md = Model(b2, D1; Δt_frame = 1//10)
println("Q3 events nominal ", length(mf.exec.events.prior), " dual ", length(md.exec.events.prior))
println("Q4 events body keys ", [keys(v) for (k, v) in phase_bodies(mf).events])
println("Q4b projections ", keys(phase_bodies(mf).projections))
try_("Q5 state tick", () -> (init!(mf, set(u = (u = 0.0, p = 0.0))); state(mf, "tick")))
try_("Q6 modes latch", () -> modes(mf, "latch"))
try_("Q7 state latch", () -> state(mf, "latch"))
try_("Q8 integrate!", () -> Redstone.integrate!(mf, 0.05))
try_("Q9 checkpoint mid-frame", () -> checkpoint(mf))
try_("Q10 overlay mid-frame", () -> overlay!(mf))
# Model(build,T) scalar after Deployment kw errors
try_("Q11 Model(root,Int) valid kw", () -> Model(bare_world(), Int; Δt_frame = 1//10))
try_("Q12 init! DuplicateConditionLeaf", () -> init!(mf, combine(set(u=(u=0.0,p=0.0)), set(u=(u=1.0,)))))
try_("Q13 init! frame hooks", () -> init!(mf, set(u=(u=0.0,p=0.0)); hooks = NoHooks()))
println("Q14 status ", mf.status)
println("Q15 frame_top!/settled! ", Redstone.frame_top!(NoHooks()), Redstone.settled!(NoHooks()))
println("Q16 comps paths ", [c.path for c in b2.structure.components], " levels ", [l.path for l in b2.structure.levels])
# resolve_authored
diags = Diagnostic[]
r = Redstone.resolve_authored("e", "", b2.structure.levels[1].instance, "plant/zz", b2.structure, diags)
println("Q17 resolve_authored ", r, " ", [(typeof(d), d.reason, d.candidates) for d in diags])
# nested container
cg = Group((; kids = [SampledC(), SampledC()]))
bc = build(cg)
println("Q18 container segs ", [(c.segment, c.field, Redstone.membership(c)) for c in bc.structure.levels[1].children])
println("Q19 anchor 2 absolute under container bare key: ")
cg2 = Group((; kids = [SampledC(), SampledC()]); sample_times = (kids = Absolute(1//2, 0),))
bc2 = build(cg2)
println(bc2.structure.anchors, " ", [(c.path, c.timing) for c in bc2.structure.components])
