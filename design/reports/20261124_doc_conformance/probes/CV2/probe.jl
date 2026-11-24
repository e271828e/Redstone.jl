# CV2 probe: tracer, descriptor and the sim.jl termination surface.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test", "imports.jl"))
include(joinpath(W, "test", "fixtures.jl"))
include(joinpath(W, "test", "utils.jl"))
failure(f) = try f(); nothing catch e e end

println("== A tracer")
T = Redstone.Tracer{true}
x = T(1.0)
try Float64(x); println("A1 Float64 of untagged global: no throw") catch e println("A1 ", typeof(e)) end
try (x < T(2.0)); println("A2 untagged compare: ok") catch e println("A2 ", typeof(e)) end

println("== B failure descriptor")
err = failure(() -> build(Group((d = DerivativeFed(), g = Gain(1.0));
    local_wires = ("d/y" => "g/e", "g/out" => "d/b"), input_wires = "a" => "d/a")))
dsc = Redstone.descriptor(err)
println("B1 keys ", keys(dsc), " fv=", dsc.format_version, " kind=", dsc.kind)
println("B2 failure keys ", keys(dsc.failure), " policy=", dsc.failure.policy)
println("B3 diag keys ", keys(dsc.failure.diagnostics[1]))
println("B4 cycle ", dsc.failure.diagnostics[1].cycle)
println("B5 message ", dsc.failure.diagnostics[1].message)
err1 = failure(() -> build(Group((a = Gain(1.0),); local_wires = ("a/out" => "a/nope",))))
println("B6 single-fail policy ", Redstone.descriptor(err1).failure.policy, " ", typeof(err1))

println("== C build descriptor")
b = build(Group((; k = Constant(1.0), sum = SumJunction{Float64, 2}()); local_wires = ("k/y" => "sum/in1", "k/y" => "sum/in2")))
dsb = Redstone.descriptor(b)
println("C1 keys ", keys(dsb), " ", keys(dsb.build))
println("C2 type rows ", [r.name for r in dsb.build.structure.types])
println("C3 node keys ", keys(dsb.build.structure.nodes[2]))
println("C4 redstone_version ", dsb.redstone_version)

println("== D sim")
sim = Simulation(Group((c = Constant(1.0),)); Δt_frame = 1//10)
init!(sim)
println("D1 step! ", step!(sim; frames = 3), " pacer ", latest(sim).status.pacer)
println("D2 both_given ", carried(@test_throws DiagnosticError{ArgumentInvalid} step!(sim; frames = 1, t_plus = 1.0)).reason)
println("D3 replay both ", try carried(@test_throws DiagnosticError{ArgumentInvalid} replay!(sim, trace(sim); to_boundary = 1, to_time = 0.1)).reason catch e e end)

println("== E source order at entry")
world = Group((c = Constant(true), s = StopRequest(reason = "x")); local_wires = ("c/y" => "s/u",))
sim2 = Simulation(world; Δt_frame = 1//10)
init!(sim2)
stop!(sim2)
println("E1 step! after stop!, request holding: ", step!(sim2), " ", termination(sim2).source)
sim3 = Simulation(world; Δt_frame = 1//10)
init!(sim3)
println("E2 run! request holding at entry: ", (run!(sim3); termination(sim3).source))
sim4 = Simulation(Group((c = Constant(1.0),)); Δt_frame = 1//10)
init!(sim4)
stop!(sim4)
println("E3 step! after stop!, no request: ", step!(sim4), " ", termination(sim4).source)
sim5 = Simulation(Group((c = Constant(1.0),)); Δt_frame = 1//10)
init!(sim5)
println("E4 ignore symbols: ", try (run!(sim5; t_end = 0.2, ignore_stop_requests = (:nope,))) catch e typeof(e) end)
sim6 = Simulation(world; Δt_frame = 1//10)
init!(sim6)
println("E5 ignore by symbol path: ", try (run!(sim6; t_end = 0.2, ignore_stop_requests = (:s,)); termination(sim6).source) catch e typeof(e) end)
