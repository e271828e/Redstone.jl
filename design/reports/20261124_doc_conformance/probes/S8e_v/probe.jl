# S8e_v probe: rate scopes (§8.7) and passthrough helpers (§8.8), run from W.
include(joinpath(pwd(), "test", "repl.jl"))
using Base.CoreLogging: with_logger, NullLogger
catcher(f) = try f(); nothing catch e; e end
diag1(e) = e isa DiagnosticError{Vector{Diagnostic}} ? only(diagnostics(e)) : e isa DiagnosticError ? diagnostic(e) : e
show_d(tag, e) = (d = diag1(e); println(tag, " => ", typeof(d), " reason=", hasproperty(d, :reason) ? d.reason : "-", "\n   msg: ", d isa Diagnostic ? message(d) : sprint(showerror, d)))

println("== S8e-011 bare rational / integer in sample_times")
for v in (1//2, 2)
    show_d("value $v", catcher(() -> build(Group((; c = TickCounter()); sample_times = (; c = v)))))
end

println("== S8e-021 key on continuous child")
show_d("cont key", catcher(() -> build(Group((; c = Gain(1.0)); input_wires = ("in" => "c/e",),
                                           sample_times = (; c = Relative(2))))))

println("== S8e-032 Absolute inexact reals")
for args in ((0.02,), (π,), (big"0.5",), (1//50, 0.1), (1//50, π))
    e = catcher(() -> Absolute(args...)); d = diag1(e)
    println("Absolute$(args) => ", d.reason, " arg=", d.argument, " | ", message(d))
end
println("Absolute(Int8(1)//Int8(50)) => ", Absolute(Int8(1)//Int8(50)))

println("== S8e-041 Relative :not_a_count")
for args in ((0.5,), (1//2,), (2.0,), (2//1,), (2, 1//2), (π,))
    e = catcher(() -> Relative(args...)); d = diag1(e)
    println("Relative$(args) => ", d.reason, " names Absolute: ", occursin("Absolute", message(d)))
end

println("== S8e-075 Δt in the discrete bundle")
struct DtProbe <: AbstractComponent end
s_init(::DtProbe) = (dt = 0.0,)
y_types(::DtProbe) = (a = Float64, b = Float64)
y_state(::DtProbe, (; s, Δt)) = (a = Δt,)
y_direct(::DtProbe, (; s, Δt)) = (b = Δt,)
s_update(::DtProbe, (; s, Δt)) = (dt = Δt,)
sim = Simulation(Group((; p = DtProbe()); sample_times = (; p = Relative(3))); Δt_frame = 1//100)
init!(sim)
println("y_state Δt=", port(sim, "p", :a), " y_direct Δt=", port(sim, "p", :b))
step!(sim; frames = 3)
println("after update: s.dt via y_state ", port(sim, "p", :a))
println("bundle_names y_state discrete: ", bundle_names(y_state, DtProbe(), DISCRETE, ()))
println("bundle_names y_state continuous Plant: ", bundle_names(y_state, Plant(), CONTINUOUS, ()))

println("== S8e-066 finer scope and the grid report")
coarse = Group((; fcs = Group((; inner = TickCounter(), outer = TickCounter());
                              sample_times = (; inner = Relative(1), outer = Relative(5))));
               sample_times = (; fcs = Absolute(1//250)))
fine = Group((; fcs = Group((; inner = TickCounter(), outer = TickCounter());
                            sample_times = (; inner = Relative(2), outer = Relative(10, 1))));
             sample_times = (; fcs = Absolute(1//500)))
for (tag, root) in (("coarse", coarse), ("fine", fine))
    s = Simulation(root; Δt_frame = 1//500, Δt_base = :derive)
    dep = s.model.deployment
    println(tag, ": Δt_base=", dep.Δt_base, " rows=", [(r.path, r.D, r.Φ) for r in dep.schedule.rows],
            " warnings=", [(typeof(w), severity(w)) for w in warnings(s)])
end
relonly(fine) = Group((; fcs = Group((; inner = TickCounter(), outer = TickCounter());
                      sample_times = fine ? (; inner = Relative(2), outer = Relative(10)) :
                                            (; inner = Relative(1), outer = Relative(5))));
                      sample_times = (; fcs = Relative(fine ? 1 : 2)))
for f in (false, true)
    s = Simulation(relonly(f); Δt_frame = 1//500)
    println("relative-only fine=$f rows=", [(r.path, r.D, r.Φ) for r in s.model.deployment.schedule.rows],
            " warnings=", typeof.(warnings(s)))
end

println("== S8e-110 / 139 passthrough labels")
g = Group((; integrator = BareAccumulator()); input_wires = ("in" => "integrator/u",))
println(input_passthrough(g, "integrator"), " ", output_passthrough(g, "integrator"))
println(input_passthrough(g, "integrator"; prefix = ""), " ", output_passthrough(g, "integrator"; prefix = ""))
println(output_passthrough(g, "integrator"; prefix = "env", sep = "_"))

println("== S8e-119 / 122 multiple selectors")
gs = Group((; s = Sum()); input_wires = ("a" => "s/a", "b" => "s/b"))
for kw in ((except = ("a",), only = ("b",)), (except = ("a",), select = _ -> true),
           (only = ("a",), select = _ -> true))
    e = catcher(() -> input_passthrough(gs, "s"; kw...)); d = diag1(e)
    println(keys(kw), " => ", typeof(d), " ", d.reason, " names=", d.names, "\n   msg: ", message(d))
end
e = catcher(() -> output_passthrough(gs, "s"; except = ("e",), only = ("e",)))
println("output_passthrough two selectors => ", typeof(diag1(e)), " ", diag1(e).reason)

println("== S8e-096 / 129 / 131 empty selections")
for (tag, f) in (("select none", g -> (input_passthrough(g, "s"; select = _ -> false)..., "xa" => "s/a", "xb" => "s/b")),
                 ("except all", g -> (input_passthrough(g, "s"; except = ("a", "b"))..., "xa" => "s/a", "xb" => "s/b")),
                 ("only all", g -> input_passthrough(g, "s"; only = ("a", "b"))),
                 ("only one", g -> (input_passthrough(g, "s"; only = ("a",))..., "b" => "s/b")),
                 ("bare call", g -> input_passthrough(g, "s")))
    b = with_logger(NullLogger()) do
        build(Group((; s = Sum()); input_wires = f))
    end
    ws = warnings(b)
    println(tag, " => warnings ", [(typeof(w), severity(w), w.who, w.path, w.selector, w.names, w.candidates) for w in ws if w isa EmptyFaceSelection])
end
struct Faceless <: AbstractComponent end
s_init(::Faceless) = (n = 0,)
y_types(::Faceless) = (n = Int,)
y_state(::Faceless, (; s)) = (n = s.n,)
s_update(::Faceless, (; s)) = (n = s.n + 1,)
b = with_logger(NullLogger()) do
    build(Group((; f = Faceless()); input_wires = g -> input_passthrough(g, "f")))
end
println("bare call faceless => warnings ", typeof.(warnings(b)))

println("== S8e-167 generic holding")
struct GWorld <: AbstractComponent
    aircraft::AbstractComponent
    sink::Gain
end
local_wires(::GWorld) = ("aircraft/pose" => "sink/e",)
e = catcher(() -> build(GWorld(TickCounter(), Gain(1.0))))
for d in diagnostics(e)
    println(typeof(d), " entry=", hasproperty(d, :entry) ? d.entry : "-", "\n   msg: ", message(d))
end
println("generic holding with a concrete child having the face: ",
        typeof(catcher(() -> build(GWorld(Group((; p = Plant()); input_wires = ("u" => "p/u",), output_wires = ("p/y" => "pose",)), Gain(1.0))))))
