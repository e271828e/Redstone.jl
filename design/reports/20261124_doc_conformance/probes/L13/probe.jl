# L13 probes: design/log.md entries of slice L13, read-only checks.
using Redstone, StaticArrays, ForwardDiff
const R = Redstone
const L = Redstone.Library
p(label, f) = try
    println(label, " => ", repr(f()))
catch err
    println(label, " => THROWS ", typeof(err), ": ", sprint(showerror, err)[1:min(end, 160)])
end

# D-225: a bare value as a StepError's cause fails the constructor.
cf = R.CursorFrame(nothing, :y_direct, :integrate, 0, 0)
p("D225 bare cause", () -> R.StepError(cf, 0.0, 0, :loop, 42))
p("D225 exception cause type", () -> typeof(R.StepError(cf, 0.0, 0, :loop, ArgumentError("x"))))
p("D225 collected cause isa", () -> R.StepError(cf, 0.0, 0, :loop, R.DiagnosticError(R.Diagnostic[])) isa R.StepError{<:Exception})

# D-312: Freeze bound, Constant/UnitDelay contracts.
p("D312 Freeze{Float32}", () -> L.Freeze{Float32}())
p("D312 Constant y_types", () -> R.y_types(L.Constant(1.0)))
p("D312 UnitDelay fields", () -> fieldnames(L.UnitDelay))
p("D312 input_faces UnitDelay", () -> R.input_faces(L.UnitDelay(0.0)))
p("D312 output_faces Freeze", () -> R.output_faces(L.Freeze{Float64}()))

# D-385: tracking with fixed infinite Tt refused; hold alone passes; scheduled Tt passes.
p("D385 tracking Inf Tt", () -> L.PID(; Kp = 1.0, tracking = true))
p("D385 hold alone", () -> typeof(L.PID(; Kp = 1.0, hold = true)))
p("D385 tracking AsPort Tt", () -> typeof(L.PID(; Kp = 1.0, Tt = L.AsPort(), tracking = true)))
p("D385 hold inputs", () -> keys(R.u_types(L.PID(; Kp = 1.0, hold = true, tracking = true))))
p("D385 vector engaged type", () -> R.u_types(L.PID(; Kp = SVector(1.0, 2.0), hold = true)).engaged)
p("D385 standby keyword", () -> L.PID(; Kp = 1.0, standby = true))

# D-413: an honoured request already terminal at boundary zero; t_end refusal order.
stopper() = R.Group((; k = L.Constant(true), stop = L.StopRequest(reason = "done"));
                    local_wires = ("k/y" => "stop/u",))
sim = R.Simulation(stopper(); Δt_frame = 1//10)
R.init!(sim)
R.run!(sim; t_end = 1.0)
rec = R.termination(sim)
println("D413 run source => ", rec.source, " t => ", rec.t)
p("D413 bad t_end", () -> R.run!(R.Simulation(stopper(); Δt_frame = 1//10) |> (s -> (R.init!(s); s)); t_end = -1.0))
s2 = R.Simulation(stopper(); Δt_frame = 1//10); R.init!(s2)
p("D413 bad t_end and bad path", () -> try
    R.run!(s2; t_end = -1.0, ignore_stop_requests = ("nope",))
catch err
    (typeof(err), err.carried.reason)
end)
s3 = R.Simulation(stopper(); Δt_frame = 1//10); R.init!(s3)
R.step!(s3)
println("D413 step source => ", R.termination(s3).source, " t => ", R.termination(s3).t)

# D-433: the kind marker and the names.
p("D433 Any", () -> R._kind_marker(Any))
p("D433 String", () -> R._kind_marker(String))
p("D433 AbstractFloat", () -> R._kind_marker(AbstractFloat))
p("D433 closure", () -> R._kind_marker(typeof(let a = 1.0; x -> x + a end)))
p("D433 Vector", () -> R._kind_marker(Vector{Float64}))
p("D433 NamedTuple", () -> R._kind_marker(typeof((a = 1.0, b = 2))))
p("D433 qualified PID", () -> R._qualified_name(typeof(L.PID(; Kp = 1.0))))
p("D433 type_string Float64", () -> R._type_string(Float64))
d_prim = R.descriptor(R.build(L.Constant(1.0)))
p("D433 primitive root node", () -> (length(d_prim.build.structure.nodes), keys(d_prim.build.structure.nodes[1])))

# D-434: no StepError method; failure body.
p("D434 descriptor(StepError)", () -> hasmethod(R.descriptor, Tuple{R.StepError}))
bad = try R.build(R.Group((; a = L.Constant(1.0)); local_wires = ("a/zz" => "a/qq",))) catch err err end
p("D434 failure body keys", () -> keys(R.descriptor(bad).failure))
p("D434 failure policy", () -> R.descriptor(bad).failure.policy)

# D-439: a DiscretePID's `fixed` opens into dotted entries.
p("D439 summary", () -> [q.name for q in R._parameters(L.DiscretePID(; Kp = 1.0))])
p("D439 empty NT", () -> (s = NamedTuple[]; R._summarize!(s, "e", (;)); s))
