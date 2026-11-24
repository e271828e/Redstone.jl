module CV9bVProbe
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/"
include(W * "imports.jl")
include(W * "fixtures.jl")
include(W * "utils.jl")

function show_err(label, f)
    try
        r = f(); println(label, " => no throw: ", repr(r))
    catch err
        if err isa DiagnosticError
            ds = err.carried isa Redstone.Diagnostic ? [err.carried] : err.carried
            println(label, " => ", [(nameof(typeof(d)), hasproperty(d, :reason) ? d.reason :
                                     hasproperty(d, :invariant) ? d.invariant : hasproperty(d, :site) ? d.site : nothing,
                                     hasproperty(d, :argument) ? d.argument : hasproperty(d, :parameter) ? d.parameter : nothing)
                                    for d in ds])
        else
            println(label, " => other ", typeof(err), ": ", first(sprint(showerror, err), 160))
        end
    end
end

println("== P1 Model fields (CV9b-046)")
println(fieldnames(Model), " count=", fieldcount(Model))

b = build(bare_world())
dep = Deployment(b; Δt_frame = 1//10)
println("== P2 chunk_size refusals (CV9b-047)")
show_err("Model(dep; chunk_size=0)", () -> Model(dep; chunk_size = 0))
show_err("Model(dep; chunk_size=1.5)", () -> Model(dep; chunk_size = 1.5))
show_err("Model(dep; chunk_size=1)", () -> (Model(dep; chunk_size = 1); :ok))

println("== P3 scalar order (CV9b-049)")
show_err("Model(dep, Float32; chunk_size=0)", () -> Model(dep, Float32; chunk_size = 0))
show_err("Model(build, Float32; Δt_frame=-1)", () -> Model(b, Float32; Δt_frame = -1))
show_err("Model(build, Float32) no Δt_frame", () -> Model(b, Float32))
show_err("Model(build, Float32; Δt_frame=1//10, chunk_size=0)", () -> Model(b, Float32; Δt_frame = 1//10, chunk_size = 0))
show_err("Model(root, Float32; Δt_frame=-1)", () -> Model(bare_world(), Float32; Δt_frame = -1))
bad_root = Group((; a = BareAccumulator()); local_wires = ("zz/y" => "a/u",))
show_err("Model(bad root, Float32; Δt_frame=1//10)", () -> Model(bad_root, Float32; Δt_frame = 1//10))

println("== P4 claimed gate (CV9b-051)")
dep2 = Deployment(build(feedback_model()); Δt_frame = 1//50)
m2 = Model(dep2)
sim = Simulation(m2)
show_err("init! claimed", () -> init!(m2, set(u = (ref = 0.0,))))
show_err("overlay! claimed", () -> overlay!(m2, set()))
show_err("frame! claimed", () -> frame!(m2, 1))
show_err("apply! claimed", () -> apply!(m2, Redstone.resolve_condition(set(u = (ref = 0.0,)), m2.deployment.build, Float64)))
m3 = Model(dep2); init!(m3, set(u = (ref = 0.0,))); st3 = checkpoint(m3)
show_err("restore! claimed", () -> restore!(m2, st3))

println("== P5 state reads (CV9b-060)")
m = Model(dep)
init!(m, set(u = (u = 0.0, p = 0.0)))
for p in ("acc", "tick", "latch", "neg", "plant", "")
    show_err("state(m, \"$p\")", () -> state(m, p))
end
show_err("state(m, \"nope\")", () -> state(m, "nope"))
wd = Group((; dm = DiscreteMap(), tc = TickCounter()); input_wires = ("a" => "dm/a",))
md = Model(Deployment(build(wd); Δt_frame = 1//10, Δt_base = 1//10))
init!(md, set(u = (a = 1,)))
show_err("state(discrete stateless dm)", () -> state(md, "dm"))
show_err("state(tc)", () -> state(md, "tc"))

println("== P6 restore! hand-built origin (CV9b-064)")
st = checkpoint(m)
F = fieldnames(typeof(st))
vals = Any[getfield(st, f) for f in F]
vals[findfirst(==(:t₀), F)] = (typemax(Int) - 1) // 1
bad = typeof(st)(vals...)
show_err("restore!(m, bad origin)", () -> restore!(m, bad))
for o in (1//(2^61 - 1), typemax(Int)//7, -(typemax(Int) ÷ 2)//1, 2^62//1)
    show_err("_clock_integers($o)", () -> (Redstone._clock_integers(o, dep); :fits))
    v = copy(vals); v[findfirst(==(:t₀), F)] = o; v[findfirst(==(:t), F)] = Float64(o)
    show_err("restore!(m, origin $o)", () -> restore!(m, typeof(st)(v...)))
end

println("== P7 Structure (CV9b-008, CV9b-013)")
s = b.structure
println(fieldnames(Redstone.Structure), " ", fieldtypes(Redstone.Structure))
println("root_types=", s.root_types, " root_inputs=", s.root_inputs)
println("level children: ", [(c.segment, c.field, Redstone.membership(c)) for c in s.levels[1].children])

println("== P8 face names (CV9b-024/025)")
show_err("slash face", () -> build(Group((; a = BareAccumulator()); input_wires = ("x/y" => "a/u",))))
show_err("empty face", () -> build(Group((; a = BareAccumulator()); input_wires = ("" => "a/u",))))
show_err("collision", () -> build(Group((; a = BareAccumulator()); input_wires = ("q" => "a/u",), output_wires = ("a/y" => "q",))))

println("== P9 sample_times (CV9b-014/034)")
tc() = TickCounter()
show_err("Relative(0)", () -> build(Group((; c = tc()); sample_times = (; c = Relative(0)))))
show_err("Relative(2,2)", () -> build(Group((; c = tc()); sample_times = (; c = Relative(2, 2)))))
show_err("unknown key", () -> build(Group((; c = tc()); sample_times = (; zz = Relative(2)))))
show_err("non-wrapper", () -> build(Group((; c = tc()); sample_times = (; c = 3))))
show_err("Absolute(0)", () -> build(Group((; c = tc()); sample_times = (; c = Absolute(0//1)))))
show_err("Absolute τ≥Δt", () -> build(Group((; c = tc()); sample_times = (; c = Absolute(1//10, 1//10)))))
show_err("overflow nested, two elements", () -> build(Group((; g = Group((; a = tc(), b = tc()); sample_times = (; children = Relative(2^40)))); sample_times = (; g = Relative(2^40)))))
show_err("overflow nested, keyed each", () -> build(Group((; g = Group((; a = tc(), b = tc()); sample_times = (; a = Relative(2^40), b = Relative(2^40)))); sample_times = (; g = Relative(2^40)))))
end
