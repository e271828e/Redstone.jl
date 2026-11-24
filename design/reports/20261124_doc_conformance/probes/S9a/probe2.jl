# S9a probe 2: trial binding and deployment overflow
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/imports.jl")
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/fixtures.jl")
const R = Redstone
function tryit(label, f)
    try
        r = f(); println("probe[$label] OK"); r
    catch e
        if e isa DiagnosticError
            ds = e.carried isa Diagnostic ? [e.carried] : e.carried
            println("probe[$label] DiagnosticError: ", [(typeof(d), hasproperty(d, :reason) ? d.reason : nothing, hasproperty(d, :key) ? d.key : nothing, hasproperty(d, :parameter) ? d.parameter : nothing) for d in ds])
        else
            println("probe[$label] EXC ", typeof(e), ": ", first(sprint(showerror, e), 300))
        end
        nothing
    end
end
two(st) = Group((a = DiscreteAccumulator(1.0), b = DiscreteAccumulator(1.0), g = Gain(1.0));
      local_wires = ("g/out" => "a/e", "g/out" => "b/e"), input_wires = ("r" => "g/e"), sample_times = st)
p1, p2 = 4611686018427387847, 4611686018427387817
tryit("gcd no Rational{Int}", () -> build(two((a = Absolute(1//p1), b = Absolute(1//p2)))))
tryit("anchor count overflow", () -> build(two((a = Absolute(5), b = Absolute(1//3^39)))))
tryit("Relative typemax", () -> build(two((a = Relative(typemax(Int)),))))
tryit("anchor ok, relative overflow beneath", () -> build(Group((o = Group((a = DiscreteAccumulator(1.0), g = Gain(1.0)); local_wires = ("g/out" => "a/e",), input_wires = ("r" => "g/e"), sample_times = (a = Relative(2^40),)),); input_wires = ("r" => "o/r"), sample_times = (o = Absolute(1//3^23),))))
w = Group((o = Group((a = DiscreteAccumulator(1.0), g = Gain(1.0)); local_wires = ("g/out" => "a/e",), input_wires = ("r" => "g/e"), sample_times = (a = Relative(2^31),)),); input_wires = ("r" => "o/r"), sample_times = (o = Absolute(1),))
bw = tryit("trial passes", () -> build(w))
bw === nothing || tryit("deployment fine base", () -> Deployment(bw; Δt_frame = 1, Δt_base = 1//2^40))
bw === nothing || tryit("deployment ok base", () -> Deployment(bw; Δt_frame = 1, Δt_base = 1//2^20))
# the shadow check, class
