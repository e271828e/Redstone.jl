# CV12 verifier probes, run from the pinned worktree with --project=test.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
const T = joinpath(pwd(), "test")
include(joinpath(T, "imports.jl"))
include(joinpath(T, "fixtures.jl"))
include(joinpath(T, "utils.jl"))

replay_model(k = 4.0) =
    Group((plant = Plant(; ω = 2.0, ζ = 0.1), ctl = Gain(k), sum = Sum(),
           acc = DiscreteAccumulator(1.0), b = Bouncer(1.0, 0.32));
          local_wires = ("ctl/out" => "plant/u", "sum/e" => "ctl/e", "plant/y" => "sum/b"),
          input_wires = ("ref" => "sum/a", "rate" => "acc/e"),
          output_wires = ("b/q" => "bq", "acc/u" => "u"))
cond0 = set(u = (ref = 1.0, rate = 0.0))
_ds(e) = e isa DiagnosticError{Vector{Diagnostic}} ? diagnostics(e) : [getfield(e, 1)]
kinds(f) = try f(); "no throw" catch e; e isa DiagnosticError ? [(nameof(typeof(d)), hasproperty(d, :reason) ? d.reason : (hasproperty(d, :what) ? d.what : nothing)) for d in _ds(e)] : typeof(e) end
p(tag, v) = println(tag, " => ", v)

# CV12-001
p("001 fieldnames", fieldnames(Simulation))

# CV12-012 mode after each door
sim = Simulation(replay_model(); Δt_frame = 1//10)
init!(sim, cond0); p("012 after init!", mode(sim))
stage!(sim, "ref" => 2.0); step!(sim; frames = 4)
trc = trace(sim); cp = checkpoint(sim)
overlay!(sim, set(u = (ref = 3.0,))); p("012 after overlay!", mode(sim))
restore!(sim, cp); p("012 after restore!", mode(sim))
sim2 = Simulation(replay_model(); Δt_frame = 1//10)
replay!(sim2, trc; to_boundary = 2); p("012 replay! to 2", (mode(sim2), lifecycle(sim2)))
sim3 = Simulation(replay_model(); Δt_frame = 1//10)
init!(sim3, cond0)
replay!(sim3, trc; restore = false, to_boundary = 2); p("012 replay! restore=false to 2", (mode(sim3), lifecycle(sim3)))
# CV12-068 live! changes nothing else
r_before = sim3.run; f_before = sim3.run.frame; t_before = latest(sim3).t
live!(sim3); p("068 live!", (mode(sim3), sim3.run === r_before, sim3.run.frame == f_before, latest(sim3).t == t_before, lifecycle(sim3)))

# CV12-017 doors clear the stop word; step! does not
for (door, f) in (("init!", s -> init!(s, cond0)), ("overlay!", s -> overlay!(s)),
                  ("restore!", s -> restore!(s, checkpoint(s))))
    s = Simulation(replay_model(); Δt_frame = 1//10); init!(s, cond0); step!(s)
    stop!(s); f(s)
    p("017 stop! then $door then step!", (step!(s), lifecycle(s)))
end
s = Simulation(replay_model(); Δt_frame = 1//10); init!(s, cond0)
stop!(s); p("017/094 stop! then step! (no door)", (step!(s), lifecycle(s), termination(s).source))

# CV12-024 overlay! keeps other stores, clock, priors
s = Simulation(replay_model(); Δt_frame = 1//10); init!(s, cond0)
stage!(s, "rate" => 1.0); step!(s; frames = 3)
acc_before = state(s, "acc"); b_before = state(s, "b"); plant_before = state(s, "plant")
t_before = s.model.exec.clock.t; prior_before = copy(s.model.exec.events.prior)
overlay!(s, at("plant", set(x = (q = SVector(0.5, 0.0),))))
p("024 overlay! keeps", (state(s, "acc") == acc_before, state(s, "b") == b_before,
    s.model.exec.clock.t == t_before, s.model.exec.events.prior == prior_before,
    state(s, "plant"), plant_before))

# CV12-033 overlay! refusals
p("033 unknown path", kinds(() -> overlay!(s, at("nope", set(x = (q = 1.0,))))))
p("033 undeclared field", kinds(() -> overlay!(s, at("plant", set(x = (zz = 1.0,))))))
p("033 duplicate", kinds(() -> overlay!(s, combine(set(u = (ref = 1.0,)), set(u = (ref = 2.0,))))))
p("033 bare NamedTuple", kinds(() -> overlay!(s, (u = (ref = 1.0,),))))

# CV12-044 restore! of a non-Float64 ModelState
dual_model = Model(replay_model(), D8; Δt_frame = 1//10)
init!(dual_model, cond0)
p("044 dual ModelState", kinds(() -> restore!(Simulation(replay_model(); Δt_frame = 1//10), checkpoint(dual_model))))

# CV12-094 stop! issuer in a run
s = Simulation(replay_model(); Δt_frame = 1//10); init!(s, cond0)
task = Threads.@spawn run!(s; pace = 1.0)
while lifecycle(s) !== :running; yield(); end
sleep(0.3); stop!(s); wait(task)
p("094 run! + stop!", termination(s).source)

# CV12-103 pause flag
s = Simulation(replay_model(); Δt_frame = 1//10)
pause!(s); init!(s, cond0); p("103 pause! then init! keeps", paused(s))
restore!(s, checkpoint(s)); p("103 restore! keeps", paused(s))
stop!(s); step!(s); p("103 stopping step! clears", (paused(s), lifecycle(s)))
s = Simulation(replay_model(); Δt_frame = 1//10); pause!(s); init!(s, cond0)
task = Threads.@spawn run!(s)
while lifecycle(s) !== :running; yield(); end
sleep(0.2); p("103 run! paused at first top", (paused(s), s.run.frame)); stop!(s); wait(task)
p("103 run! shut down clears", (paused(s), lifecycle(s)))
s = Simulation(replay_model(); Δt_frame = 1//10); pause!(s)
task = Threads.@spawn replay!(s, trc)
while lifecycle(s) !== :running; yield(); end
sleep(0.2); stop!(s); wait(task)
p("103 replay! shut down clears", (paused(s), lifecycle(s)))

# CV12-114 margin in every state
s = Simulation(replay_model(); Δt_frame = 1//10)
p("114 margin built", (margin(s), lifecycle(s)))
margin!(s, 0.5); init!(s, cond0); p("114 margin initialized", margin(s))
s2 = Simulation(replay_model(); Δt_frame = 1//10); init!(s2, cond0)
task = Threads.@spawn run!(s2; pace = 1.0, margin = 0.01)
while lifecycle(s2) !== :running; yield(); end
p("114 margin running", (margin(s2), lifecycle(s2))); stop!(s2); wait(task)
p("114 margin stopped", (margin(s2), lifecycle(s2)))

# CV12-124 stage! merges, newest wins per face
s = Simulation(replay_model(); Δt_frame = 1//10); init!(s, cond0)
stage!(s, "ref" => 5.0, "rate" => 7.0); stage!(s, "ref" => 6.0)
step!(s)
p("124 merged", (port(s, "", :ref), port(s, "", :rate)))

# CV12-144 Series fields
s = Simulation(replay_model(); Δt_frame = 1//10); init!(s, cond0); step!(s; frames = 3)
ser = series(s, reads(q = get_output("b", :q)))
p("144 Series field types", [(f, typeof(getfield(ser, f))) for f in fieldnames(Series)])
p("144 column length vs t", (length(ser.q), length(ser.t)))

# CV12-148 series refusals
p("148 bare NamedTuple", kinds(() -> series(s, (q = get_output("b", :q),))))
for lab in (:t, :frame, :boundary, :columns)
    p("148 label $lab", kinds(() -> series(s, reads(; lab => get_output("b", :q)))))
end
