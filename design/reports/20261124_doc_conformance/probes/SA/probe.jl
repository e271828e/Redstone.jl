using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test/imports.jl"))
include(joinpath(W, "test/fixtures.jl"))
using Test
single(c) = Group((; c = c))
port(sim, p, f) = Main.port(sim, p, f)
println("probe:10 --- A: counter due at boundary zero, authored 0")
sim = Simulation(single(TickCounter()); Δt_frame = 1//10)
init!(sim)
println("A state=", state(sim, "c"), " cell n=", port(sim, "c", :n), " boundary=", latest(sim).boundary)
println("probe:15 --- B: phased Relative(2,1)")
g = Group((; c = TickCounter()); sample_times = (; c = Relative(2, 1)))
sb = Simulation(g; Δt_frame = 1//10)
init!(sb)
println("B0 state=", state(sb, "c"), " cell=", port(sb, "c", :n), " t=", latest(sb).t)
step!(sb; t_plus = 1//10)
println("B1 t=", latest(sb).t, " state=", state(sb, "c"), " cell=", port(sb, "c", :n))
step!(sb; t_plus = 1//10)
println("B2 t=", latest(sb).t, " state=", state(sb, "c"), " cell=", port(sb, "c", :n))
step!(sb; t_plus = 1//10)
println("B3 t=", latest(sb).t, " state=", state(sb, "c"), " cell=", port(sb, "c", :n))
println("probe:30 --- C: overlay!")
run!(sim; t_end = 0.3)
println("C pre state=", state(sim, "c"), " cell=", port(sim, "c", :n), " ord=", latest(sim).boundary, " lifecycle=", lifecycle(sim))
overlay!(sim, at("c", set(s = (n = 10,))))
println("C post state=", state(sim, "c"), " cell=", port(sim, "c", :n), " ord=", latest(sim).boundary, " lifecycle=", lifecycle(sim))
step!(sim; t_plus = 1//10)
println("C step state=", state(sim, "c"), " cell=", port(sim, "c", :n))
println("probe:38 --- D: copy store via init!")
sd = Simulation(single(TickCounter()); Δt_frame = 1//10)
init!(sd, at("c", set(s = (n = 4,))))
println("D state=", state(sd, "c"), " cell=", port(sd, "c", :n))
cnt0 = sd.control.counter
init!(sd)
println("D reinit ord=", latest(sd).boundary, " counter ", cnt0, " -> ", sd.control.counter)
println("probe:44 --- E: unwired contributor")
function tryb(f)
    try; f(); println("  built ok"); catch e
        e isa DiagnosticError ? println("  ", join(string.(typeof.(diagnostics(e))), ","), " :: ", sprint(showerror, e)[1:min(end,200)]) : println("  other ", typeof(e)); end
end
tryb(() -> build(Group((; a = Constant(1.0), b = Constant(2.0), s = SumJunction{Float64,3}());
      local_wires = ("a/y" => "s/in1", "b/y" => "s/in2"))))
println("E2 contributor output unwired:")
tryb(() -> build(Group((; a = Constant(1.0), b = Constant(2.0), c = Constant(3.0), s = SumJunction{Float64,2}());
      local_wires = ("a/y" => "s/in1", "b/y" => "s/in2"))))
println("probe:55 --- F: fold order")
sf = Simulation(Group((; a = Constant(1.0e16), b = Constant(1.0), c = Constant(-1.0e16), s = SumJunction{Float64,3}());
      local_wires = ("a/y" => "s/in1", "b/y" => "s/in2", "c/y" => "s/in3")); Δt_frame = 1//10)
init!(sf)
println("F ", port(sf, "s"), " (left fold = 0.0)")
sf2 = Simulation(Group((; a = Constant(1.0e16), b = Constant(1.0), c = Constant(-1.0e16), s = SumJunction{Float64,3}());
      local_wires = ("a/y" => "s/in3", "b/y" => "s/in2", "c/y" => "s/in1")); Δt_frame = 1//10)
init!(sf2)
println("F2 ", port(sf2, "s"))
println("probe:66 --- G: Integrator reset at t0 holding")
println("probe:67 --- H: sign guard algebra")
u = 0.0
println("H -u>=0: ", -u >= 0, " ; gated: ", (u < 0 ? -u : -one(u)) >= 0)
println("probe:70 --- I: UnitDelay in continuous loop diagnostic")
try
    build(Group((; i = Integrator(), d = UnitDelay(0.0));
        local_wires = ("i/y" => "d/u", "d/y" => "i/u")))
    println("I built ok")
catch e
    println("I ", e isa DiagnosticError ? typeof.(diagnostics(e)) : typeof(e))
end
try
    build(Group((; f = Fn{Float64,Float64}(x -> x), g = Fn{Float64,Float64}(x -> x));
        local_wires = ("f/y" => "g/u", "g/y" => "f/u")))
catch e
    println("I2 ", sprint(showerror, e)[1:min(end,400)])
end
println("probe:100 --- J: phased counter authored 7: cell at t0")
sj = Simulation(Group((; c = TickCounter()); sample_times = (; c = Relative(2, 1))); Δt_frame = 1//10)
init!(sj, at("c", set(s = (n = 7,))))
println("J state=", state(sj, "c"), " cell=", port(sj, "c", :n))
println("probe:105 --- K: fold order")
mk(w) = Simulation(Group((; a = Constant(1.0e16), b = Constant(1.0), c = Constant(1.0), s = SumJunction{Float64,3}());
      local_wires = ("a/y" => "s/in$(w[1])", "b/y" => "s/in$(w[2])", "c/y" => "s/in$(w[3])")); Δt_frame = 1//10)
for w in ((1,2,3), (2,3,1))
    s = mk(w); init!(s); println("K ", w, " => ", port(s, "s"))
end
println("probe:110 --- L: reset already holding at t0")
sl = Simulation(Group((; i = Integrator(x0 = 0.5, reset = true));
     input_wires = ("u" => "i/u", "r" => "i/reset")); Δt_frame = 1//10)
init!(sl, combine(at("i", set(x = 2.0)), set(u = (u = 0.0, r = true))))
println("L reset-high at t0: x=", state(sl, "i"))
init!(sl, combine(at("i", set(x = 2.0)), set(u = (u = 0.0, r = false))))
println("L reset-low at t0: x=", state(sl, "i"))
println("probe:118 --- M: ordinals after init! twice and ignore")
println("M ord=", latest(sl).boundary)
