module H2Check
include(joinpath(@__DIR__, "..", "..", "..", "..", "..", "..", "test", "repl.jl"))
using Test

roots() = Group((; s = Sum(sa = 1.0, sb = 1.0), g = Gain(2.0));
                input_wires = ("a" => "s/a", "b" => "s/b", "c" => "g/e"))
world = roots()
u0 = fragment(u = (a = 0.0, b = 0.0, c = 0.0))
chk(name, f) = try
    r = f(); println("PASS? ", name, " => ", r)
catch e
    println("ERR  ", name, " => ", sprint(showerror, e)[1:min(end, 400)])
end

# ---- block 1, 9489-9497 -----------------------------------------------------
sim = Simulation(world; h = 1//1)
init!(sim, u0)
for k in 1:20
    k % 3 == 0 && stage!(sim, "a" => Float64(k))
    step!(sim)
end
trc = trace(sim)
println("recording frames = ", trc.frames, " batches = ", length(trc.batches))
sim2 = Simulation(world; h = 1//1)
chk("replay! full ends initialized, :live", () -> (replay!(sim2, trc); (lifecycle(sim2), mode(sim2), sim2.run.frame, latest(sim2).t)))
chk("bit-identical final", () -> latest(sim2).store.stores[1].buffer == latest(sim).store.stores[1].buffer )
chk("replay to_boundary=7", () -> (replay!(sim2, trc; to_boundary = 7); (lifecycle(sim2), mode(sim2), sim2.run.frame, latest(sim2).t, latest(sim2).boundary)))
chk("then step! consumes recording", () -> (n = step!(sim2; frames = 100); (n, mode(sim2), sim2.run.frame)))
chk("replay to_time=7.5 floors", () -> (replay!(sim2, trc; to_time = 7.5); (sim2.run.frame, latest(sim2).t)))
chk("to_time beyond recording refused", () -> replay!(sim2, trc; to_time = 25.0))
chk("to_boundary beyond recording refused", () -> replay!(sim2, trc; to_boundary = 25))
chk("both given refused", () -> replay!(sim2, trc; to_boundary = 3, to_time = 3.0))
sim3 = Simulation(world; h = 1//1); init!(sim3, u0); step!(sim3; frames = 5)
cp = checkpoint(sim)
chk("restore! warm restart", () -> (restore!(sim2, cp); (lifecycle(sim2), mode(sim2), sim2.run.frame, sim2.run.boundary, latest(sim2).boundary, latest(sim2).t)))
chk("restore! next frame publishes next ordinal", () -> (step!(sim2); (latest(sim2).boundary, latest(sim2).t, latest(sim).boundary, latest(sim).t)))

# ---- block 2, 9618-9625: the rewrite workflow (t = 110 by t_end, h = 1) -------
s1 = Simulation(world; h = 1//1); init!(s1, u0)
for k in 1:110
    k % 7 == 0 && stage!(s1, "b" => Float64(k))
    step!(s1)
end
trc1 = trace(s1)
println("session frames ", trc1.frames, " t = ", latest(s1).t)
s2 = Simulation(world; h = 1//1)
chk("replay to_time=100", () -> (replay!(s2, trc1; to_time = 100.0); (latest(s2).t, mode(s2), lifecycle(s2))))
chk("live!", () -> (live!(s2); mode(s2)))
chk("live! again refuses", () -> live!(s2))
chk("run! t_end=130", () -> (run!(s2; t_end = 130.0); (latest(s2).t, lifecycle(s2), trace(s2).frames, trace(s2).header.frame)))
chk("trace of itself: prefix == recording's first 100 frames",
    () -> [b.frame for b in trace(s2).batches] == [b.frame for b in trc1.batches if b.frame <= 100])

# ---- restore = false -----------------------------------------------------------
s4 = Simulation(world; h = 1//1)
chk("restore=false on built", () -> replay!(s4, trc1; restore = false))
init!(s4, u0)
chk("restore=false at header frame", () -> (replay!(s4, trc1; restore = false, to_boundary = 10); (s4.run.frame, mode(s4))))
s5 = Simulation(world; h = 1//1); init!(s5, u0; t0 = 0.5)
chk("restore=false off t0", () -> replay!(s5, trc1; restore = false))
s6 = Simulation(world; h = 1//2); 
chk("deployment mismatch h", () -> replay!(s6, trc1))
chk("to_boundary earlier than feed start (restore=false at frame 10)", () -> begin
    s7 = Simulation(world; h = 1//1); init!(s7, u0); step!(s7; frames = 10)
    replay!(s7, trc1; restore = false, to_boundary = 5) end)

# ---- §12.6 lifecycle --------------------------------------------------------------
s8 = Simulation(world; h = 1//1)
chk("built state", () -> (lifecycle(s8), mode(s8)))
chk("step! on built", () -> step!(s8))
chk("run! on built", () -> run!(s8))
init!(s8, u0)
chk("step! frames & t_plus both", () -> step!(s8; frames = 2, t_plus = 1.0))
chk("step! t_plus = 2.5 advances", () -> (n = step!(s8; t_plus = 2.5); (n, latest(s8).t)))
chk("step! truncated by t_end", () -> (n = step!(s8; frames = 10, t_end = 5.0); (n, lifecycle(s8), latest(s8).t)))
chk("live! on stopped", () -> live!(s8))
chk("checkpoint on stopped", () -> (checkpoint(s8).frame))
s9 = Simulation(world; h = 1//1); init!(s9, u0); step!(s9; frames = 3)
ms = checkpoint(s9.model)
s10 = Simulation(world; h = 1//1)
chk("restore! bare state", () -> (restore!(s10, ms); (s10.run.frame, s10.run.boundary, latest(s10).boundary, latest(s10).frame)))
chk("init! returns mode :live after replay", () -> begin
    s11 = Simulation(world; h = 1//1); replay!(s11, trc1; to_boundary = 3); m1 = mode(s11)
    init!(s11, u0); (m1, mode(s11)) end)
chk("restore! returns mode :live", () -> begin
    s11 = Simulation(world; h = 1//1); replay!(s11, trc1; to_boundary = 3); m1 = mode(s11)
    restore!(s11, cp); (m1, mode(s11)) end)
chk("restore! clears staged batch", () -> begin
    s12 = Simulation(world; h = 1//1); init!(s12, u0); stage!(s12, "a" => 9.0)
    restore!(s12, cp); step!(s12); latest(s12) end)

# ---- §12.5 inline: the timetable one-liner -----------------------------------------
@eval struct Timetable <: AbstractComponent end
@eval Redstone.s_init(::Timetable) = (;)
@eval Redstone.y_types(::Timetable) = (offset = Float64,)
@eval profile(t) = 2t
@eval Redstone.y_direct(c::Timetable, (; t)) = (; offset = profile(t))
chk("timetable script", () -> begin
    s = Simulation(Timetable(); h = 1//2); init!(s); step!(s; frames = 3)
    (latest(s).t, latest(s).store) end)
chk("replay with t_end inside recording", () -> begin
    s = Simulation(world; h = 1//1); replay!(s, trc1; t_end = 5.0)
    (lifecycle(s), mode(s), latest(s).t) end)
chk("stage! while :replay then step!: discarded", () -> begin
    s = Simulation(world; h = 1//1); replay!(s, trc1; to_boundary = 3)
    stage!(s, "c" => 42.0); step!(s); (mode(s), latest(s).store.stores[1].buffer, s.run.frame) end)
chk("run! in :replay with t_end past the recording halts at last frame", () -> begin
    s = Simulation(world; h = 1//1); replay!(s, trc1; to_boundary = 100)
    run!(s; t_end = 200.0); (lifecycle(s), mode(s), latest(s).t) end)
chk("trace(sim) after replay: header inherited", () -> begin
    s = Simulation(world; h = 1//1); replay!(s, trc1; to_boundary = 50)
    t = trace(s); (t.header.frame, t.frames, length(t.batches)) end)
end
