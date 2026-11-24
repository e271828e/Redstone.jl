# L13 verifier probes. Run from the pinned worktree:
#   JULIA_LOAD_PATH="@" julia --startup-file=no --project=test <this file>
module L13Probe
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
const L = Redstone.Library

say(id, x) = println(id, " | ", x)
function attempt(id, f)
    try
        say(id, f())
    catch err
        say(id, "THREW " * sprint(showerror, err)[1:min(end, 400)])
    end
end

# L13-001/012: two typo'd wires batch into one collected carrier, grouped by kind.
bad = Group((; a = Gain(1.0), b = Gain(2.0));
            local_wires = ("a/outt" => "b/e", "b/out" => "a/ee"))
attempt("L13-001", () -> begin
    err = try build(bad); nothing catch e; e end
    (typeof(err), err isa DiagnosticError{Vector{Diagnostic}} ? typeof.(diagnostics(err)) : nothing)
end)
attempt("L13-012", () -> let err = try build(bad); nothing catch e; e end
    replace(sprint(showerror, err), '\n' => " ⏎ ")[1:min(end, 300)]
end)

# L13-003: a throw out of an output_wires body aborts as one UserCodeFraming.
struct ThrowsFaces <: AbstractComponent
    g::Gain
end
Redstone.local_wires(::ThrowsFaces) = ()
Redstone.output_wires(::ThrowsFaces) = error("boom")
attempt("L13-003", () -> let err = try build(ThrowsFaces(Gain(1.0))); nothing catch e; e end
    (typeof(err), err isa DiagnosticError{UserCodeFraming} ? diagnostic(err).fn : nothing,
     isdefined(Redstone, :exports))
end)

# L13-010: the carrier's name.
attempt("L13-010", () -> (isdefined(Redstone, :BuildError), isdefined(Redstone, :DiagnosticError)))

# L13-067: at on a read set returns a Reads, never a Scoped.
attempt("L13-067", () -> let r = at("a", reads(v = get_output("b", :out)))
    (typeof(r), r.prefixes)
end)

# L13-083/085/087/088/089/090/092: the leaf components.
attempt("L13-083", () -> (Redstone.y_types(L.Constant(1.0)), fieldnames(L.Constant)))
attempt("L13-085", () -> (fieldnames(L.UnitDelay), Redstone.s_init(L.UnitDelay(0.5))))
attempt("L13-088", () -> let b = build(Group((; r = Ramp(0.0), d = L.UnitDelay(0.0));
                                            local_wires = ("r/out" => "d/u",),
                                            output_wires = ("d/y" => "y",)))
    "wires r/out => d/u and d/y => y build"
end)
attempt("L13-088b", () -> build(Group((; r = Ramp(0.0), d = L.UnitDelay(0.0));
                                      local_wires = ("r/out" => "d/in",))))
for (tag, v) in (("sym", :a), ("int", 1), ("str", "s"), ("vec", [1.0]))
    attempt("L13-087 $tag", () -> (build(L.UnitDelay(v)); "builds"))
end
attempt("L13-089", () -> Redstone.y_direct(L.Freeze{Float64}(),
                                           (; u = ForwardDiff.Dual(1.0, 2.0))))
for T in (Float64, SVector{2, Float64}, Float32, Int, SVector{2, Float32}, MVector{2, Float64})
    attempt("L13-090 $T", () -> (L.Freeze{T}(); "accepted"))
end
attempt("L13-092", () -> (Redstone.u_types(L.Freeze{Float64}()), Redstone.y_types(L.Freeze{Float64}())))

# L13-093/094: the library's module and Group's home.
attempt("L13-093", () -> (isdefined(Redstone, :Blocks), isdefined(Redstone, :Library),
                          parentmodule(L.PID)))
attempt("L13-094", () -> (parentmodule(Group), isdefined(L, :Group)))

# L13-111..135: the controllers.
attempt("L13-112", () -> (supertype(L.LQRTracker), isdefined(L, :LQRTrackerBlock),
                          isdefined(L, :PIDBlock), supertype(L.PID)))
attempt("L13-118", () -> L.PID(Kp = 1.0, standby = true))
attempt("L13-126", () -> (Redstone.u_types(L.PID(Kp = 1.0, hold = true)),
                          Redstone.u_types(L.PID(Kp = SVector(1.0, 2.0), hold = true))))
attempt("L13-120", () -> L.PID(Kp = 1.0, hold = true))
attempt("L13-120b", () -> L.PID(Kp = 1.0, tracking = true))
attempt("L13-135", () -> (L.PID(Kp = 1.0, tracking = true, Tt = L.AsPort()); "scheduled Tt passes"))
attempt("L13-121", () -> (keys(Redstone.y_types(L.DiscretePID(Kp = 1.0))),
                          keys(Redstone.y_types(L.PID(Kp = 1.0)))))
pidht = L.PID(Kp = 1.0, Ki = 1.0, Tt = 0.5, hold = true, tracking = true)
y0 = (u = 0.2, u_raw = 0.3)
attempt("L13-119", () -> (
    L.gated_error(pidht, 0.7, (saturation = Int8(0), engaged = false, v = 5.0)),
    L.correction_reference(pidht, (saturation = Int8(0), engaged = false, v = 5.0), y0),
    L.correction_reference(L.PID(Kp = 1.0, hold = true), (saturation = Int8(1), engaged = false), y0)))

ramp_request(level, reason) =
    Group((; src = Ramp(0.0), trig = Trigger(level), stop = L.StopRequest(reason = reason));
          local_wires = ("src/out" => "trig/sig", "trig/on" => "stop/u"))
monitored() = ramp_request(0.35, "ramp at level")

# L13-155: an advance that starts with an honoured request holding ends where it started.
attempt("L13-155", () -> begin
    sim = Simulation(monitored(); Δt_frame = 1//10)
    init!(sim)
    step!(sim; frames = 5, ignore_stop_requests = :all)
    t_before, frames_before = latest(sim).t, sim.run.frame
    println("L13-155 pre | ", lifecycle(sim))
    run!(sim; t_end = 1.0)
    (t_before, latest(sim).t, frames_before, sim.run.frame, lifecycle(sim),
     typeof(termination(sim).source))
end)

# L13-173: the kind marker on abstract declarations.
attempt("L13-173", () -> (Redstone._kind_marker(Any), Redstone._kind_marker(String),
                          Redstone._kind_marker(AbstractFloat), Redstone._kind_marker(Real),
                          Redstone._kind_marker(AbstractVector{Float64})))

# L13-175/178/183/185/203: descriptor readings.
pidmodel = Group((; c = L.DiscretePID(Kp = 2.0, Ki = 1.0, Tt = 1.0), d = L.UnitDelay(0.0));
                 input_wires = ("r" => "c/r", "m" => "c/y", "k" => "d/u"),
                 output_wires = ("c/u" => "u",))
attempt("L13-175", () -> let body = descriptor(build(pidmodel)).build
    node = only(n for n in body.structure.nodes if n.path == "c")
    (node.type, get(node, :alias, nothing))
end)
attempt("L13-178", () -> let body = descriptor(build(pidmodel)).build
    [(r.name, r.pinned) for r in body.structure.root_inputs]
end)
attempt("L13-183", () -> let d = descriptor(build(Group((; s = L.SumJunction{Float64, 2}()); input_wires = ("a" => "s/in1", "b" => "s/in2"))))
    node = only(n for n in d.build.structure.nodes if n.path == "s")
    (keys(d), get(node, :alias, nothing))
end)
attempt("L13-185", () -> let body = descriptor(build(pidmodel)).build
    root = only(n for n in body.structure.nodes if n.path == "")
    (root.inputs, root.outputs)
end)
attempt("L13-203", () -> let body = descriptor(build(pidmodel)).build
    node = only(n for n in body.structure.nodes if n.path == "c")
    [p.name for p in node.parameters]
end)

# L13-194: a failure descriptor's diagnostic rows.
attempt("L13-194", () -> let err = try build(bad); nothing catch e; e end
    keys(first(descriptor(err).failure.diagnostics))
end)

# L13-221: stored positions in a deployment's descriptor.
attempt("L13-221", () -> let d = descriptor(Deployment(build(MultiRate()); Δt_frame = 1//500)).deployment
    (d.schedule.anchors, [(r.path, get(r, :anchor, missing), r.D) for r in d.schedule.rows],
     [(e.anchor, e.kind) for e in d.build.structure.grid.pool],
     [(p.prime, p.suppliers) for p in d.build.structure.grid.primes])
end)
end
