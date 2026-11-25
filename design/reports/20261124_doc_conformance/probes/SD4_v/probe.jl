# SD4 verifier probes, run from the pinned worktree with --project=test.
using Test
const T = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(T, "repl.jl"))
include(joinpath(T, "utils.jl"))

pr(tag, v) = println(tag, " => ", v)
tryit(f) = try f() catch e e end

# SD4-001: at stores the prefix beside the node, applies nothing.
frag = set(x = (θ = 0.1, ω = 0.0))
sc = at("c", frag)
pr("SD4-001 typeof", typeof(sc)); pr("SD4-001 fields", (sc.prefix, sc.node === frag))

# SD4-042: the prefix is the author's literal, by reference.
lit = "pwp/engine"
pr("SD4-042 prefix === literal", at(lit, frag).prefix === lit)
pr("SD4-042 isbits(frag)", isbits(frag))
f42(d) = combine(at("c", set(x = (θ = d, ω = 0.0))), set(u = (in = 4.0,)))
f42(0.1); pr("SD4-042 alloc rebuild", @allocated(f42(0.2)))

# SD4-019: duplicate leaf names both origins.
m = Model(fed(Pendulum()); Δt_frame = 1//10)
e = tryit(() -> init!(m, combine(at("c", set(x = (θ = 0.1,))), at("c", set(x = (θ = 0.2,))), set(u = (in = 0.0,)))))
d = e isa DiagnosticError ? diagnostics(e) : e
pr("SD4-019", d)

# SD4-061: override variadic.
o = override(set(u = (in = 0.0,)), at("c", set(x = (θ = 0.1,))), at("c", set(x = (θ = 0.3,))))
pr("SD4-061 layers", length(o.layers))
m2 = Model(fed(Pendulum()); Δt_frame = 1//10); init!(m2, o)
pr("SD4-061 θ after override", state(m2, "c"))

# SD4-022/023/030: a one-child rig exporting the whole input face set; a
# condition covers root inputs by face, here the child's local face.
rig = Group((; c = Plant()); input_wires = g -> input_passthrough(g, "c"))
b = build(rig)
pr("SD4-023 root inputs", b.structure.root_inputs, ); pr("SD4-023 child faces", input_faces(Plant()))
m3 = Model(rig; Δt_frame = 1//10)
r = tryit(() -> init!(m3, at("c", set(x = (q = SVector(0.0, 2.0),), u = (u = 1.5,)))))
pr("SD4-030 init by local face", r isa Exception ? r : (port(m3, "c", :power), m3.exec.clock.t))

# SD4-070: totality refused before any write.
m4 = Model(fed(Pendulum()); Δt_frame = 1//10)
e = tryit(() -> init!(m4, at("c", set(x = (θ = 0.1,)))))
pr("SD4-070", (typeof(e), e isa DiagnosticError ? diagnostic(e) : nothing, (@atomic m4.status)))

# SD4-088: attach!/detach! legal built, initialized, stopped.
two_root_inputs() = Group((; s = Sum(sa = 1.0, sb = 1.0)); input_wires = ("a" => "s/a", "b" => "s/b"))
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
pr("SD4-088 built", (lifecycle(sim), tryit(() -> attach!(sim, Pad("d1"), Enumerated("a")))) )
pr("SD4-088 detach built", tryit(() -> detach!(sim, sim.plane.roster[end].device)))

# SD4-097/052: at on taps and on a trim problem.
tp = taps(x = (θ = get_state("c", :θ),), y = (θ = get_output("c", :θ),))
pr("SD4-097", typeof(at("rig", tp)))
pr("SD4-052", typeof(at("rig", TrimProblem(guess = (θ = 0.1,), lower = (θ = -1.0,), upper = (θ = 1.0,),
    condition = d -> set(x = (θ = d.θ,)), reads = reads(a = get_deriv("c", :ω)),
    residuals = (r, d) -> (a = r.a,), tolerances = (a = 1e-9,)))))

# SD4-125/127: the cursor's fields.
pr("SD4-125 cursor fields", fieldnames(typeof(m4.exec.cursor)))

# SD4-138: payload field types of a few kinds.
for K in (UnknownPort, UnconnectedInput, DuplicateConditionLeaf)
    pr("SD4-138 $(nameof(K))", collect(zip(fieldnames(K), fieldtypes(K))))
end

# SD4-164: a trim report's fields; does it carry warnings?
pr("SD4-164 TrimReport fields", fieldnames(TrimReport))
pr("SD4-164 warnings(::TrimReport) method", hasmethod(warnings, Tuple{TrimReport}))

# SD4-155: termination record time.
s5 = Simulation(fed(Pendulum()); Δt_frame = 1//10)
init!(s5, combine(at("c", set(x = (θ = 0.1, ω = 0.0))), set(u = (in = 0.0,))))
run!(s5; t_end = 0.3)
pr("SD4-155", (termination(s5).t, latest(s5).t))

# SD4-174: phase-body seams.
pr("SD4-174", keys(phase_bodies(m4)))
