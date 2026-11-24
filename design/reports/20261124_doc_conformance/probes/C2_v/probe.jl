# C2_v probes: run from W with JULIA_LOAD_PATH="@" julia --project=test
module C2VProbe
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))

ds(err) = err === nothing ? nothing : err.carried isa Vector ? err.carried : [err.carried]
show_ds(tag, err) = (println(tag, " => ", err === nothing ? "no error" : typeof(err));
                     err isa DiagnosticError && for d in ds(err)
                         println("    ", typeof(d), " severity=", Redstone.severity(d), " ",
                                 join(["$f=$(repr(getfield(d, f)))" for f in fieldnames(typeof(d))], " "))
                     end; err !== nothing && !(err isa DiagnosticError) && println("    ", sprint(showerror, err)))

mk() = Simulation(Plant(); Δt_frame = 1//10)

# C2-001: run! before init!
show_ds("C2-001 run! before init!", failure(() -> run!(mk(); t_end = 1.0)))
# C2-010: overlay! / restore! on a built sim
show_ds("C2-010 overlay! at :built", failure(() -> overlay!(mk(), set(u = (u = 0.0,)))))
# C2-019: step! ignore list
let sim = mk(); init!(sim, set(u = (u = 0.0,)))
    show_ds("C2-019 step! ignore", failure(() -> step!(sim; ignore_stop_requests = ["nope"])))
end
# C2-028/037: h_min missing under BS3, h_min above half h_max
show_ds("C2-028 BS3 no h_min", failure(() -> Simulation(Plant(); Δt_frame = 1//10, algorithm = BS3())))
show_ds("C2-028 h_min > h_max/2", failure(() -> Simulation(Plant(); Δt_frame = 1//10, algorithm = BS3(), h_min = 1//10)))
show_ds("C2-037 Δt_base unit too fine", failure(() -> Simulation(Group((; t = BareTicker())); Δt_frame = 1//(2^61 - 1), Δt_base = 1//(2^61 + 1))))
# C2-076: greedy without input
struct GreedyNoInput <: AbstractBinding end
Redstone.is_greedy(::GreedyNoInput) = true
Redstone.is_output(::GreedyNoInput) = true
show_ds("C2-076 greedy no input", failure(() -> Redstone.check_binding(GreedyNoInput())))
# C2-113: set payload nothing
show_ds("C2-113 set(x = nothing)", failure(() -> set(x = nothing)))
# C2-250: at("", reads)
show_ds("C2-250 at empty on reads", failure(() -> at("", reads(a = get_output("", :y)))))
# C2-240: trim! with no TrimProblem
let sim = mk()
    show_ds("C2-240 trim!(sim, 1)", failure(() -> trim!(sim, 1; baseline = set(u = (u = 0.0,)))))
end
# C2-139: carrier shape of UninitializedInputs
show_ds("C2-139 init! uncovered", failure(() -> init!(mk())))
# C2-231: TableBinding refusal carries the entry key
show_ds("C2-231 TableBinding", failure(() -> TableBinding(stick = (face = :u, bogus = 1))))
# C2-104: duplicate leaf collected
show_ds("C2-104 duplicate", failure(() -> init!(mk(), combine(set(u = (u = 0.0,)), set(u = (u = 1.0,))))))
end
