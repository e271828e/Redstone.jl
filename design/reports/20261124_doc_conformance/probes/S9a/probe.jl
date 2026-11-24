# S9a probes: spec §9 preamble, §9.1, §9.2 (The Build)
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/imports.jl")
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/fixtures.jl")
const R = Redstone
function tryit(label, f)
    try
        r = f()
        println("probe[$label] OK: ", r)
        r
    catch e
        if e isa DiagnosticError
            ds = e.carried isa Diagnostic ? [e.carried] : e.carried
            println("probe[$label] DiagnosticError: ", [(typeof(d), hasproperty(d, :reason) ? d.reason : nothing) for d in ds])
        else
            println("probe[$label] EXC ", typeof(e), ": ", first(sprint(showerror, e), 200))
        end
        nothing
    end
end
# --- P1: fields of artifacts
println("probe:P1 Build ", fieldnames(Build), " Structure ", fieldnames(Structure),
        " Outputs ", fieldnames(Outputs), " Events ", fieldnames(Events),
        " Deployment ", fieldnames(Deployment), " Schedule ", fieldnames(Schedule))
println("probe:P1 ismutable Build=", ismutable(Build), " Structure=", ismutable(Structure))
w = SampledLoop(ctl_rate = Relative(2))
b = build(w)
println(b)
show(stdout, MIME"text/plain"(), b.structure); println()
show(stdout, MIME"text/plain"(), b.outputs); println()
show(stdout, MIME"text/plain"(), b.events); println()
println("probe:P1 activations keys ", collect(keys(b.activations)))
println("probe:P1 structure.scopes ", b.structure.scopes, " rates ", b.structure.components[2].rates)
println("probe:P1 levels ", [(l.path, [(c.segment, c.field) for c in l.children], l.wires) for l in b.structure.levels])
# --- P2: sugar forms
dep = Deployment(b; Δt_frame = 1//10)
println("probe:P2 dep ", typeof(dep), " ", fieldnames(typeof(dep.schedule)))
m = Model(dep, Float64);  println("probe:P2 Model ", typeof(m).parameters[1])
s1 = Simulation(m);       println("probe:P2 Simulation(model) ", typeof(s1))
s2 = Simulation(dep);     println("probe:P2 Simulation(dep)")
s3 = Simulation(b; Δt_frame = 1//10); println("probe:P2 Simulation(build)")
s4 = Simulation(w; Δt_frame = 1//10); println("probe:P2 Simulation(world)")
tryit("P2 second claim", () -> Simulation(m))
tryit("P2 init! claimed", () -> R.init!(m))
tryit("P2 frame! claimed", () -> R.frame!(m))
tryit("P2 Model Float32", () -> Model(dep, Float32))
m2 = tryit("P2 Model Dual", () -> Model(dep, ForwardDiff.Dual{R.ProbeTag,Float64,1}))
println("probe:P2 sim of Dual model: ", m2 === nothing ? "n/a" : try Simulation(m2) catch e; typeof(e) end)
# Build reuse: the same build backs a second deployment
println("probe:P2 same build ", Deployment(b; Δt_frame = 1//5).build === b, " ", dep.build === b)
# --- P3: activations lazily filled
a = R.activation(b, R.ProbeDual)
println("probe:P3 activations keys ", collect(keys(b.activations)), " warnings ", warnings(b))
# --- P4: barriers - structure-step error vs stage code error
struct Thrower <: AbstractComponent end
x_init(::Thrower) = nothing
u_types(::Thrower) = (a = Float64,)
y_types(::Thrower) = (y = Float64,)
y_direct(::Thrower, (; u)) = error("stage ran")
bad = Group((t = Thrower(), g = Gain(1.0)); local_wires = ("g/out" => "t/a", "t/yy" => "g/e"))
tryit("P4 typo+thrower", () -> build(bad))
bad2 = Group((t = Thrower(), g = Gain(1.0)); local_wires = ("g/out" => "t/a", "t/y" => "g/e"))
tryit("P4 thrower alone", () -> build(bad2))
# two producers cross-level, unconnected
g2 = Group((g = Gain(1.0), h = Gain(2.0)); local_wires = ("g/out" => "h/e",), input_wires = ("r" => ("h/e", "g/e")))
tryit("P4 two producers", () -> build(g2))
g3 = Group((g = Gain(1.0), h = Gain(2.0)); local_wires = ("g/out" => "h/e",))
tryit("P4 unconnected", () -> build(g3))
# --- P5: empty store, shadowing
struct EmptyS <: AbstractComponent end
x_init(::EmptyS) = (;)
u_types(::EmptyS) = (a = Float64,)
y_types(::EmptyS) = (y = Float64,)
tryit("P5 EmptyStore", () -> build(EmptyS()))
struct NoStore <: AbstractComponent end
y_types(::NoStore) = (y = Float64,)
tryit("P5 no store", () -> build(NoStore()))
struct Stateless <: AbstractComponent end
x_init(::Stateless) = nothing
tryit("P5 stateless no outputs", () -> build(Stateless()))
struct StoreNoUpd <: AbstractComponent end
x_init(::StoreNoUpd) = (q = 1.0,)
y_types(::StoreNoUpd) = (y = Float64,)
tryit("P5 store w/o update", () -> build(StoreNoUpd()))
struct BadLeaf <: AbstractComponent end
x_init(::BadLeaf) = (q = 1,)
y_types(::BadLeaf) = (y = Float64,)
x_deriv(::BadLeaf, (; x)) = (q = 1.0,)
tryit("P5 x leaf Int", () -> build(BadLeaf()))
struct BadS <: AbstractComponent end
s_init(::BadS) = (q = [1.0],)
y_types(::BadS) = (y = Float64,)
s_update(::BadS, (; s)) = (q = s.q,)
tryit("P5 s field vector", () -> build(BadS()))
struct BareX <: AbstractComponent end
x_init(::BareX) = 1.0
y_types(::BareX) = Float64
x_deriv(::BareX, (; x)) = -x
y_state(::BareX, (; x)) = x
tryit("P5 bare store ok", () -> build(BareX()).structure.root_inputs)
# --- P6: rate folding
mk(rt) = Group((a = DiscreteAccumulator(1.0), g = Gain(1.0)); local_wires = ("g/out" => "a/e",), input_wires = ("r" => "g/e"), sample_times = (a = rt,))
bb = build(mk(Relative(3, 1)))
println("probe:P6 timing ", [(e.path, e.timing) for e in bb.structure.components])
d6 = Deployment(bb; Δt_frame = 1//10)
println("probe:P6 schedule ", d6.schedule.rows[1].D, d6.schedule.rows[1].Φ, " base ", d6.Δt_base)
bb2 = build(mk(Absolute(1//20, 1//40)))
println("probe:P6 anchored ", [(e.path, e.timing) for e in bb2.structure.components], bb2.structure.anchors)
show(stdout, MIME"text/plain"(), bb2.structure); println()
tryit("P6 range relative", () -> build(Group((o = Group((a = DiscreteAccumulator(1.0), g = Gain(1.0)); local_wires = ("g/out" => "a/e",), input_wires = ("r" => "g/e"), sample_times = (a = Relative(typemax(Int)÷2),)),); input_wires = ("r" => "o/r"), sample_times = (o = Relative(10),))))
tryit("P6 range nested ", () -> build(Group((o = Group((a = DiscreteAccumulator(1.0), g = Gain(1.0)); local_wires = ("g/out" => "a/e",), input_wires = ("r" => "g/e"), sample_times = (a = Relative(typemax(Int)÷2),)),); input_wires = ("r" => "o/r"), sample_times = (o = Relative(3),))))
p1, p2 = 4611686018427387847, 4611686018427387817  # large odd numbers (probably not prime; only size matters)
tryit("P6 gcd no Rational{Int}", () -> build(Group((a = DiscreteAccumulator(1.0), b = DiscreteAccumulator(1.0), g = Gain(1.0)); local_wires = ("g/out" => ("a/e","b/e"),), input_wires = ("r" => "g/e"), sample_times = (a = Absolute(1//p1), b = Absolute(1//p2)))))
tryit("P6 anchor count overflow", () -> build(Group((a = DiscreteAccumulator(1.0), b = DiscreteAccumulator(1.0), g = Gain(1.0)); local_wires = ("g/out" => ("a/e","b/e"),), input_wires = ("r" => "g/e"), sample_times = (a = Absolute(1//3), b = Absolute(1//(3^38)))))) 
tryit("P6 violations", () -> build(mk(Relative(0))))
tryit("P6 key continuous", () -> build(Group((p = Plant(), g = Gain(1.0)); local_wires = ("g/out" => "p/u",), input_wires = ("r" => "g/e"), sample_times = (p = Relative(2),))))
# Deployment refuses finer base
tryit("P6 deployment fine base", () -> Deployment(bb2; Δt_frame = 1//20, Δt_base = 1//(2^62)))
# --- P7: face tables
println("probe:P7 terminal_producer ", R.terminal_producer(bb.structure, ("a", :e)), R.terminal_producer(bb.structure, ("", :r)))
println("probe:P7 face_routes ", R.face_routes(bb.structure, ("", :r)))
# --- P8: Outputs/Events content, feedthrough not carried
b8 = build(feedback_model())
println("probe:P8 outputs ", [(c.path, c.stage1, c.stage2) for c in b8.outputs.components], b8.outputs.order)
println("probe:P8 outputs fields ", fieldnames(R.ComponentOutputs), " events ", fieldnames(R.ComponentEvents))
b9 = build(Group((t = Trigger(0.5),); input_wires = ("r" => "t/sig",)))
println("probe:P9 ", b9.events.components)
