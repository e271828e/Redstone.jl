module H1Check
include(joinpath("/Users/miguel/.julia/dev/Redstone.jl/test", "repl.jl"))
using Test
fed(c, face) = Group((; c = c); input_wires = ("in" => "c/$face",))
two_root_inputs() = Group((; s = Sum(sa = 1.0, sb = 1.0)); input_wires = ("a" => "s/a", "b" => "s/b"))
diag(e) = e isa DiagnosticError ? e : rethrow(e)
function kind_of(f)
    try f(); return :none
    catch e
        e isa DiagnosticError || return typeof(e)
        return typeof(e).parameters[1]
    end
end

@testset "h1 checks" begin
  # 7289-7295 admission block: identity before claims
  sim = Simulation(two_root_inputs(); h = 1//10)
  d1 = Pad("d1"); attach!(sim, d1, Enumerated("a"))
  k = kind_of(() -> attach!(sim, d1, Enumerated("a")))
  println("re-attach same instance, overlapping claim: ", k); @test k == AlreadyAttached
  k = kind_of(() -> attach!(sim, Pad("d2"), Enumerated("a")))
  println("other instance, overlapping claim: ", k); @test k <: Vector
  # §11.3 does not name AttachUnknownFace: an enumeration naming a nonexistent face
  k = kind_of(() -> attach!(sim, Pad("d3"), Enumerated("flaps")))
  println("enumeration naming nonexistent face: ", k)
  # §11.3 does not name NotAttached
  k = kind_of(() -> detach!(sim, Pad("ghost"))); println("detach unrostered: ", k)
  # ids monotonic, never reused
  h2 = attach!(sim, Pad("d4"), Enumerated("b")); println("roster ids: ", [e.id for e in sim.plane.roster])
  detach!(sim, sim.plane.roster[end].dev)
  attach!(sim, Pad("d5"), Enumerated("b")); println("after detach+attach ids: ", [e.id for e in sim.plane.roster])

  # 7379-7394 sketch, concrete instance: merge newest-wins per face, mask OR
  B = Redstone.Batch
  pending  = B((1.0, 2.0, 3.0), (true, false, true))
  incoming = B((9.0, 8.0, 0.0), (false, true, true))
  merged = Redstone._merge(pending, incoming)
  println("merged: ", merged)
  @test merged.staged == (1.0, 8.0, 0.0) && merged.mask == (true, true, true)

  # harness staging: untouched survive, re-staged newest
  sim = Simulation(two_root_inputs(); h = 1//10)
  init!(sim, fragment(u = (a = 0.0, b = 0.0)))
  stage!(sim, "a" => 1.0); stage!(sim, "b" => 2.0); stage!(sim, "a" => 3.0)
  step!(sim; frames = 1)
  println("after drain a,b = ", port(sim, "", :a), ", ", port(sim, "", :b))
  @test port(sim, "", :a) == 3.0 && port(sim, "", :b) == 2.0
  # EntryTypeMismatch at staging
  stage!(sim, "a" => "nope"); step!(sim; frames = 1)
  st = only(w for w in latest(sim).status.writers if w.who == "harness")
  println("harness totals after bad value: ", st.totals)

  # snapshot fields 6901-6903
  s = latest(sim); println("snapshot fields: ", fieldnames(typeof(s)), " frame=", s.frame, " boundary=", s.boundary)

  # D-192: greedy rostered empties harness surface; stage! -> ClaimedFaceEntry
  sim = Simulation(two_root_inputs(); h = 1//10)
  attach!(sim, Pad("gui"), Greedy())
  init!(sim, fragment(u = (a = 0.0, b = 0.0)))
  stage!(sim, "a" => 5.0); step!(sim; frames = 1)
  st = only(w for w in latest(sim).status.writers if w.who == "harness")
  println("harness under greedy: a=", port(sim, "", :a), " totals=", st.totals)
  # second greedy: EmptyGreedyClaim in the entry's cell
  attach!(sim, Pad("gui2"), Greedy())
  println("second greedy writer faces: ", sim.plane.roster[end].handle.writer.faces)

  # log_max default, re-decimation, endpoints 7000-7062
  sim = Simulation(fed(Plant(), "u"); h = 1//10)
  init!(sim, fragment(u = (in = 1.0,)))
  println("log_max default: ", sim.run.log.log_max, " (typemax? ", sim.run.log.log_max == typemax(Int), ")")
  init!(sim, fragment(u = (in = 1.0,)); log_max = 4)
  step!(sim; frames = 20)
  fr = [x.frame for x in logged(sim)]
  println("log_max=4 after 20 frames, retained frames: ", fr)
  @test fr[1] == 0 && fr[end] == 20 && length(fr) <= 4 + 2

  # roster frozen while running (7253-7256)
  sim = Simulation(two_root_inputs(); h = 1//10)
  init!(sim, fragment(u = (a = 0.0, b = 0.0)))
  res = Ref{Any}(nothing)
  t = Threads.@spawn (sleep(0.05); res[] = kind_of(() -> attach!(sim, Pad("late"), Enumerated("a"))); stop!(sim))
  run!(sim; pace = 1.0, t_end = 5.0)
  wait(t); println("attach! while running: ", res[])
end
end
