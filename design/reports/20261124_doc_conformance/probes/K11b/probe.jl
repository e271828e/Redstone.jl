using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))

world() = Group((; s = Sum(sa = 1.0, sb = 1.0), t = Sum(sa = 1.0, sb = 1.0));
    input_wires = ("throttle" => "s/a", "elevator" => "s/b", "flaps" => "t/a", "brake" => "t/b"))
fresh() = (sim = Simulation(world(); Δt_frame = 1//10);
           sim)
init0!(sim) = init!(sim, set(u = (throttle = 0.62, elevator = -0.03, flaps = 0.0, brake = 0.0)))
println("probe:input_faces ", input_faces(world()))
# 1 claims order / schema / mask
sim = fresh()
joy = Pad("joy")
hj = attach!(sim, joy, TableBinding(stick_y = (face = "elevator", expo = 0.6), throttle = (face = "throttle",)))
println("probe:claims ", sim.plane.roster[1].handle.writer.faces)
gui = Pad("gui")
hg = attach!(sim, gui, Greedy())
println("probe:greedy claim ", sim.plane.roster[2].handle.writer.faces, " harness ", sim.plane.harness.faces)
init0!(sim)
stage!(hj, map_input((stick_y = 0.5, throttle = 0.7), binding(hj))...)
stage!(hj, "throttle" => 0.7)
stage!(hj, "elevator" => -0.05)
p = @atomic hj.writer.cell.pending
println("probe:batch ", p[])
stage!(hg, "flaps" => 1.0)
stage!(hg, "throttle" => 0.1)   # claimed by joystick
println("probe:gui oob ", (@atomic hg.diag_cell.batch).ring)
stage!(sim, "nope" => 1.0)
stage!(sim, "flaps" => 1.0)
println("probe:harness ring ", (@atomic sim.plane.harness_diag.batch).ring)
step!(sim; frames = 1)
println("probe:inputs ", [port(sim, "", f) for f in (:throttle, :elevator, :flaps, :brake)])
trc = trace(sim)
println("probe:trace schemas ", trc.schemas)
println("probe:trace batches ", trc.batches)
println("probe:header ", typeof(trc.header), " ", fieldnames(typeof(trc.header)))
# 4 order: identity vs unknown face
e = try attach!(sim, joy, Enumerated("zzz")) catch e e end
println("probe:identity-vs-unknown ", typeof(e))
e = try attach!(sim, Pad("p3"), Enumerated("zzz", "throttle")) catch e e end
println("probe:unknown-vs-conflict ", typeof(e))
# greedy second
@test_logs (:warn, r"EmptyGreedyClaim") attach!(sim, Pad("gui2"), Greedy())
println("probe:empty greedy ", sim.plane.roster[end].handle.writer.faces)
# lifecycle states
println("probe:lifecycle ", lifecycle(sim))
# detach releases
detach!(sim, joy)
println("probe:harness after detach ", sim.plane.harness.faces)
# crash persists: Pad loop returns at once during run
sim2 = fresh(); d = Pad("d"); attach!(sim2, d, Enumerated("flaps")); init0!(sim2)
run!(sim2; t_end = 0.3)
println("probe:after run roster ", length(sim2.plane.roster), " ", lifecycle(sim2))
w = [(x.who, x.task_state) for x in latest(sim2).status.writers]
println("probe:status ", w)
println("probe:attach in stopped ", try (attach!(sim2, Pad("late"), Enumerated("brake")); :ok) catch e typeof(e) end)
