# L9b probe: runtime checks for the log slice D-256 … D-471.
module L9bProbe
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const T = joinpath(@__DIR__, "..", "..", "..", "..", "..", "test")
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))

tag(s, v) = println(rpad(s, 6), " ", v)
err(f) = try; f(); :no_throw; catch e; e; end
diag1(e) = e isa DiagnosticError ? diagnostic(e) : e
plain(x) = sprint(show, MIME("text/plain"), x)

const R = Redstone
fb = build(feedback_model())
mr = build(MultiRate())
dep_fb = Deployment(fb; Δt_frame = 1//100)
dep_mr = Deployment(mr; Δt_frame = 1//500)

# P1: model doors and simulation forwarding methods
for f in (:init!, :apply!, :evaluate!, :integrate!, :boundary!, :offtick_boundary!, :boundary_zero!,
          :frame!, :phase_bodies, :warnings, :port, :state, :modes, :checkpoint, :restore!, :trim!, :linearize)
    fn = getfield(R, f)
    sig(m) = Base.unwrap_unionall(m.sig).parameters
    onmodel = any(m -> length(sig(m)) ≥ 2 && Base.unwrap_unionall(sig(m)[2]) isa DataType && Base.unwrap_unionall(sig(m)[2]).name === Base.typename(R.Model), methods(fn))
    onsim = any(m -> length(sig(m)) ≥ 2 && Base.unwrap_unionall(sig(m)[2]) isa DataType && Base.unwrap_unionall(sig(m)[2]).name === Base.typename(R.Simulation), methods(fn))
    tag("P1", (f, :model => onmodel, :sim => onsim))
end

# P2: Simulation of a non-Float64 model is a MethodError
mdual = Model(dep_fb, ProbeDual)
tag("P2", typeof(err(() -> Simulation(mdual))))

# P3: the Model scalar door
e = diag1(err(() -> Model(dep_fb, Float32)))
tag("P3a", (typeof(e), getfield.(Ref(e), (:call, :reason, :argument, :value))))
e = diag1(err(() -> Model(dep_fb, ForwardDiff.Dual{Nothing,Float32,1})))
tag("P3b", (typeof(e), e isa ArgumentInvalid ? e.reason : nothing))
tag("P3c", typeof(Model(dep_fb, ForwardDiff.Dual{Nothing,ProbeDual,1})).name.name)

# P4: the claim
m = Model(dep_fb)
sim = Simulation(m)
e = err(() -> Simulation(m))
tag("P4a", [(typeof(d), d.reason) for d in diagnostics(e)])
m2 = Model(dep_fb); init!(m2, set(u = (ref = 0.0,)))
e = err(() -> Simulation(m2))
tag("P4b", [(typeof(d), d.reason) for d in diagnostics(e)])
e = diag1(err(() -> init!(sim.model, set(u = (ref = 0.0,)))))
tag("P4c", (typeof(e), e isa ArgumentInvalid ? (e.call, e.reason) : nothing))
e = diag1(err(() -> frame!(sim.model, 1)))
tag("P4d", (typeof(e), e isa ArgumentInvalid ? (e.call, e.reason) : nothing))
tag("P4e", err(() -> evaluate!(sim.model)))

# P5: lifecycle
tag("P5a", lifecycle(sim))
e = diag1(err(() -> trace(sim)))
tag("P5b", typeof(e))
init!(sim, set(u = (ref = 0.0,)))
tag("P5c", lifecycle(sim))
run!(sim; t_end = 0.05)
tag("P5d", (lifecycle(sim), closed(sim.run), sim.run.frame, sim.run.boundary))
cp = checkpoint(sim)
tag("P5e", (typeof(cp), fieldnames(Checkpoint), fieldnames(ModelState), cp.frame, cp.boundary))

# P6: checkpoint(model) at :built, restore at another scalar
mb = Model(dep_fb)
e = diag1(err(() -> checkpoint(mb)))
tag("P6a", (typeof(e), e isa ServiceLifecycle ? (e.op, e.legal) : nothing))
md = Model(dep_fb, ProbeDual); init!(md, set(u = (ref = 0.0,)))
sd = checkpoint(md)
e = diag1(err(() -> restore!(Model(dep_fb), sd)))
tag("P6b", (typeof(e), e isa CheckpointMismatch ? (e.what, e.expected, e.found) : nothing))
tag("P6c", occursin("Model", sprint(showerror, err(() -> restore!(Model(dep_fb), sd)))))
e = diag1(err(() -> restore!(sim, sd)))
tag("P6d", (typeof(e), e isa CheckpointMismatch ? (e.what, e.expected, e.found) : nothing))
# a Dual model steps frame by frame
tag("P6e", err(() -> frame!(md, 1)))
tag("P6f", (md.exec.events === nothing, typeof(md.exec.events)))

# P7: the algorithm token
tag("P7", (sprint(show, RK4()), RK4() == RK4(), hash(RK4()) == hash(RK4()), sprint(show, Heun())))

# P8: Deployment refusals and defaults
e = err(() -> Deployment(fb; Δt_frame = 1//100, h_max = 1//100, h_min = 1//150))
tag("P8a", [(d.parameter, d.reason, d.related) for d in diagnostics(e)])
e = err(() -> Deployment(fb; Δt_frame = 1//100, localization_tol = Inf))
tag("P8b", [(d.parameter, d.reason) for d in diagnostics(e)])
e = err(() -> Deployment(fb))
tag("P8c", [(typeof(d), d.parameter, d.reason) for d in diagnostics(e)])
tag("P8d", typeof(err(() -> Deployment(fb; Δt_frame = 1//100, N_base = 1))))
tag("P8e", (dep_fb.Δt_base == dep_fb.Δt_frame, hasfield(Deployment, :grid), hasfield(Deployment, :N_base)))

# P9: show
s = plain(fb.structure)
tag("P9a", (occursin("grid:", s), occursin("anchors:", s)))
s = plain(dep_fb)
tag("P9b", (occursin("Δt_base:", s), occursin("chart", s), occursin("grid", s)))
tag("P9c", plain(dep_fb))
s = plain(fb)
lines = split(s, '\n')
tag("P9d", (findfirst(l -> occursin("Outputs:", l), lines), findfirst(l -> occursin("feedthrough:", l), lines),
             findfirst(l -> occursin("Events:", l), lines)))

# P10: descriptor
dsc = descriptor(fb)
tag("P10a", (keys(dsc), dsc.format_version, dsc.kind))
tag("P10b", dsc.build.structure.root_inputs)
dd = descriptor(dep_mr)
tag("P10c", (keys(dd), haskey(dd.deployment, :build)))
end
