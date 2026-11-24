# S13a_v probes: verifier for slice S13a (§13.1–§13.3). Run from W with --project=test.
include(joinpath(pwd(), "test", "RedstoneTests.jl"))

@eval RedstoneTests begin

# fixtures local to the probe
struct ThrowDeriv <: AbstractComponent end
x_init(::ThrowDeriv) = (q = 0.0,)
y_types(::ThrowDeriv) = (y = Float64,)
y_state(::ThrowDeriv, (; x)) = (y = x.q,)
x_deriv(::ThrowDeriv, (; x)) = error("boom")

struct ThrowDecl <: AbstractComponent end
x_init(::ThrowDecl) = error("decl boom")
y_types(::ThrowDecl) = (y = Float64,)

struct ReadsM <: AbstractComponent end
x_init(::ReadsM) = (q = 0.0,)
y_types(::ReadsM) = (y = Float64,)
y_state(::ReadsM, (; x)) = (y = x.q,)
x_deriv(::ReadsM, (; x, m)) = (q = 1.0,)

struct LateReadsM <: AbstractComponent end
x_init(::LateReadsM) = (q = 0.0,)
y_types(::LateReadsM) = (y = Float64,)
y_state(::LateReadsM, (; x)) = (y = x.q,)
x_deriv(::LateReadsM, b) = b.t > 0.05 ? (q = b.m,) : (q = 1.0,)

struct TwoMixed <: AbstractComponent
    kids::NamedTuple
    more::NamedTuple
end
local_wires(::TwoMixed) = ()

function show_err(label, err)
    println("== ", label, ": ", typeof(err))
    if err isa DiagnosticError{Vector{Diagnostic}}
        println("   kinds: ", kinds(err), "  n = ", length(diagnostics(err)))
        for d in diagnostics(err); println("   - ", typeof(d), ": ", message(d)); end
    elseif err isa DiagnosticError
        println("   ", message(err.carried))
    end
    err isa DiagnosticError && println("   structure field: ", typeof(err.structure))
end

# P1 (002, 011): unfed inputs and a wire typo collect into one throw
show_err("P1a unfed", failure(() -> build(Group((; a = Gain(1.0), b = Gain(2.0))))))
show_err("P1b typo", failure(() -> build(Group((; a = Gain(1.0), b = Gain(2.0));
                                         local_wires = ("a/out" => "b/ee",),
                                         input_wires = ("u" => "a/e",)))))
# P2 (002, 080): user code fails fast, framed
show_err("P2a probed throw", failure(() -> build(single(ThrowDeriv()))))
show_err("P2b declaration throw", failure(() -> build(single(ThrowDecl()))))
# P3 (020): two mixed containers on one component, one collection throw
show_err("P3 two mixed", failure(() -> build(single(TwoMixed((a = Gain(1.0), b = 2.0), (c = Gain(1.0), d = 3.0))))))
# P4 (029): deployment validation collects every check whose premise holds
b_ok = build(fed(Plant()))
show_err("P4 deployment", failure(() -> Deployment(b_ok; Δt_frame = 1//100, firing_budget = 0, localization_budget = 0, attempt_budget = 0)))
# P5 (049, 089, 099, 067): BundleFieldError at the probe; structure attached past the structure step
show_err("P5 probe BundleFieldError", failure(() -> build(single(ReadsM()))))
# P6 (049, 058, 089): runtime species
sim = Simulation(single(LateReadsM()); Δt_frame = 1//100)
init!(sim)
e6 = failure(() -> run!(sim; t_end = 0.2))
println("== P6 runtime: ", typeof(e6), "  cause: ", typeof(e6.cause))
e6.cause isa Diagnostic && println("   ", message(e6.cause))
# P8 (164): resolve_terminal
rt1 = resolve_terminal(SampledLoop(), "plant/y")
println("== P8 resolve_terminal plant/y: ", typeof(rt1), " ", typeof(rt1[1]), " ", repr(rt1[2]))
rt2 = resolve_terminal(SampledLoop(), "plant")
println("   plant: ", typeof(rt2[1]), " ", repr(rt2[2]))
show_err("   past", failure(() -> resolve_terminal(GenericHold(SampledLoop()), "inner/plant/y")))
# P9 (173): a generic child's port through the service walk
gsim = Simulation(GenericHold(SampledLoop()); Δt_frame = 1//50)
init!(gsim, combine(at("inner/plant", set(x = (q = SVector(0.3, 0.1),))), set(u = (ref = 1.0,))))
evaluate!(gsim.model.exec)
gb = gsim.model.deployment.build
r = gather_reads(_compile_reads(reads(y = get_output("inner/plant", :y)), gb), gsim.model.exec)
println("== P9 generic child port via service walk: ", r)
# P10 (182): snapshot inspection by the address table
snap = latest(gsim)
println("== P10 snapshot port inner/plant y: ", port(snap, "inner/plant", :y))
show_err("   unknown", failure(() -> port(snap, "inner/plnt", :y)))
end
