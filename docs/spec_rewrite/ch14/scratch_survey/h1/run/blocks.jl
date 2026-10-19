# Chapter 14 half-1 survey: run the half's code blocks and probe its claims.
# Run from the repository root:  julia --project=test -t 2 docs/spec_rewrite/ch14/scratch_survey/h1/run/blocks.jl
module H1Check

include(joinpath(@__DIR__, "..", "..", "..", "..", "..", "..", "test", "repl.jl"))
using Test, BenchmarkTools

caught(f) = try f(); nothing catch e; e end
ds(e) = e.carried isa AbstractVector ? e.carried : [e.carried]
kinds(e) = e isa DiagnosticError ? map(d -> nameof(typeof(d)), ds(e)) : typeof(e)
macro say(label, ex)
    quote
        v = try
            $(esc(ex))
        catch err
            "THREW " * sprint(showerror, err)[1:min(end, 300)]
        end
        println(rpad($(esc(label)), 64), " => ", v)
    end
end

println("== block 11412-11416: the node-type sketch")
@say("Fragment fields", fieldnames(Fragment))
@say("Scoped fields/types", (fieldnames(Scoped), fieldtypes(Scoped{Int})))
@say("Combined bound", fieldtypes(Combined{Tuple{Int}}))
@say("Override (fourth kind, not in the sketch)", (fieldnames(Redstone.Override),))
@say("set(x=..) isbits", isbits(set(x = (q = 1.0,), u = (u = 2.0,))))
@say("at(..) isbits (prefix String)", isbits(at("a", set())))

println("== blocks 11395-11406: a condition method and an owner's pull (stand-ins)")
module Phase
@enum T stopped running
end
struct PistonEngine <: AbstractComponent
    ω_rated::Float64
end
Redstone.x_init(::PistonEngine) = (ω = 0.0,)
Redstone.m_init(::PistonEngine) = (phase = Phase.stopped,)
Redstone.u_types(::PistonEngine) = (throttle = Float64,)
Redstone.y_types(::PistonEngine) = (ω = Float64,)
Redstone.y_state(::PistonEngine, (; x)) = (ω = x.ω,)
Redstone.x_deriv(::PistonEngine, (; x, u)) = (ω = u.throttle - 0.01 * x.ω,)

struct Aero <: AbstractComponent end
Redstone.x_init(::Aero) = (α_filt = 0.0, β_filt = 0.0)
Redstone.y_types(::Aero) = (α = Float64,)
Redstone.y_state(::Aero, (; x)) = (α = x.α_filt,)
Redstone.x_deriv(::Aero, (; x)) = (α_filt = -x.α_filt, β_filt = -x.β_filt)

struct Powerplant <: AbstractComponent
    engine::PistonEngine
end
Redstone.local_wires(::Powerplant) = ()
Redstone.input_wires(::Powerplant) = ("throttle" => "engine/throttle",)
Redstone.output_wires(::Powerplant) = ("engine/ω" => "ω",)

struct C172XSystems <: AbstractComponent
    pwp::Powerplant
    aero::Aero
end
Redstone.local_wires(::C172XSystems) = ()
Redstone.input_wires(::C172XSystems) = ("throttle" => "pwp/throttle",)

# block 11395-11398, verbatim
condition(eng::PistonEngine; n_eng) =
    set(x = (ω = n_eng * eng.ω_rated,), m = (phase = Phase.running,))
# block 11402-11406, verbatim
condition(sys::C172XSystems; n_eng, α_a, β_a) = combine(
    at("pwp/engine", condition(sys.pwp.engine; n_eng)),
    at("aero",       set(x = (α_filt = α_a, β_filt = β_a))))

sys = C172XSystems(Powerplant(PistonEngine(250.0)), Aero())
b = build(sys)
tree = combine(condition(sys; n_eng = 0.8, α_a = 0.05, β_a = 0.0), set(u = (throttle = 0.5,)))
plan = resolve_condition(tree, b)
@say("owner pull resolves (deep at \"pwp/engine\")", plan isa ConditionPlan)
sim = Simulation(sys; h = 1//10)
init!(sim, tree)
@say("engine ω after init!", state(sim, "pwp/engine"))
@say("engine mode after init!", sim.model.exec.mstores[findfirst(c -> c.path == "pwp/engine", b.structure.components)][])
@say("aero x after init!", state(sim, "aero"))
@say("tree construction allocates (@ballocated)", @ballocated(condition($sys; n_eng = 0.8, α_a = 0.05, β_a = 0.0)))
f() = condition(sys; n_eng = 0.8, α_a = 0.05, β_a = 0.0); f()
@say("tree construction allocates (2nd call)", @allocated(f()))
@say("pull to a child with no method", typeof(caught(() -> condition(Aero(); x = 1))))

println("== §14.2 claims")
@say("at(\"\", node)", kinds(caught(() -> at("", set()))))
@say("at(\"\", node) reason", ds(caught(() -> at("", set())))[1].reason)
@say("set(x = 3.0): a second composition-time validation", (kinds(caught(() -> set(x = 3.0))), ds(caught(() -> set(x = 3.0)))[1].reason))
@say("combine(set(), (q=1,))", kinds(caught(() -> combine(set(), (q = 1.0,)))))
e = caught(() -> resolve_condition(combine(at("aero", set(x = (α_filt = 1.0,))), at("aero", set(x = (α_filt = 2.0,)))), b))
@say("combine collision kind", kinds(e))
println("    message: ", Redstone.message(ds(e)[1]))
e = caught(() -> resolve_condition(combine(set(u = (throttle = 1.0,)), at("pwp", set(u = (throttle = 2.0,)))), b))
@say("two spellings of one root input collide", kinds(e))
e = caught(() -> resolve_condition(at("pwp", set(u = (ω = 1.0,))), b))
@say("u payload naming an output face", (kinds(e), ds(e)[1].reason))
e = caught(() -> resolve_condition(at("pwp/engine", set(u = (throttle = 1.0,))), b))
@say("u payload at engine, fed through pwp's face (export chain)", e === nothing)
@say("combine is not Base.merge", combine !== Base.merge)

println("== §14.1 claims")
e = caught(() -> resolve_condition(at("aero", set(x = (α = 1.0,))), b))
@say("condition naming an output", (kinds(e), ds(e)[1].reason, ds(e)[1].role))
e = caught(() -> resolve_condition(combine(at("aero", set(x = (nope = 1.0,))), at("nowhere", set(x = (q = 1.0,)))), b))
@say("collecting form: two violations, one throw", kinds(e))
e = caught(() -> resolve_condition(at("pwp", set(x = (ω = 1.0,))), b))
@say("assembly path", (kinds(e), ds(e)[1].reason))

println("== §14.3 claims")
# converter cases at a Dual activation
T = ForwardDiff.Dual{Nothing,Float64,1}
b2 = build(sys; activations = (T,))
pl = resolve_condition(combine(at("aero", set(x = (α_filt = 0.1, β_filt = ForwardDiff.Dual{Nothing}(0.2, 1.0)))), set(u = (throttle = 0.5,))), b2, T)
@say("Float64 leaf at Dual activation -> zero partial", pl.xs[1][2])
@say("Dual leaf at Dual activation -> partials kept", pl.xs[2][2])
@say("s/m store write is a whole merged value", plan.stores)

println("== §14.4 claims")
cp = compile_plan(tree, b)
@say("compile_plan", typeof(cp).name.name)
sim2 = Simulation(sys; h = 1//10)
apply!(sim2.model.exec, cp, tree)
@say("specialized apply! allocs (@ballocated)", @ballocated(apply!($(sim2.model.exec), $cp, $tree)))
e = caught(() -> apply!(sim2.model.exec, cp, set()))
@say("shape drift (tree type)", (kinds(e), ds(e)[1].reason))
mk(p) = combine(at(p, condition(sys.pwp.engine; n_eng = 0.8)), at("aero", set(x = (α_filt = 0.05, β_filt = 0.0))), set(u = (throttle = 0.5,)))
cp2 = compile_plan(mk("pwp/engine"), b)
e = caught(() -> apply!(sim2.model.exec, cp2, mk("pwp/xngine")))
@say("shape drift (prefix)", (kinds(e), ds(e)[1].reason))
@say("computed equal prefix pairs", caught(() -> apply!(sim2.model.exec, cp2, mk(string("pwp/", "engine")))) === nothing)
# selectors
@say("get_state(\"kin\", :θ) vs \"θ\"", (get_state("kin", :θ), get_state("kin", "θ")))
r = caught(() -> Redstone._compile_reads(reads(a = get_state("aero", :α_filt)), b, Float64; source = :table))
@say("store selector under a table source", (kinds(r), ds(r)[1].reason))
r = Redstone._compile_reads(at("pwp", reads(a = get_state("engine", :ω), w = get_face(:ω))), b, Float64)
@say("store + face selectors under the executor source", typeof(r).name.name)
r = caught(() -> Redstone._compile_reads(reads(a = get_deriv("aero", "α_filt.x")), b, Float64))
@say("get_deriv with a .name step on a continuous field", (kinds(r), ds(r)[1].reason))

println("== §14 heading: the lifecycle table")
s3 = Simulation(sys; h = 1//10)
@say("checkpoint at built", kinds(caught(() -> checkpoint(s3))))
@say("init! at built", caught(() -> init!(s3, tree)) === nothing)
@say("checkpoint at initialized", typeof(checkpoint(s3)).name.name)
m = Model(Deployment(b; h = 1//10))
@say("checkpoint(model) at :built", kinds(caught(() -> checkpoint(m))))
@say("restore!(model, state) at :built", caught(() -> restore!(m, checkpoint(s3).state)) === nothing)
s4 = Simulation(sys; h = 1//10)
@say("claimed model refuses init!", kinds(caught(() -> init!(s4.model, tree))))
@say("claimed model checkpoint (a read) at :built", kinds(caught(() -> checkpoint(s4.model))))

println("== §14.6 claims")
s5 = Simulation(sys; h = 1//10)
e = caught(() -> init!(s5, condition(sys; n_eng = 0.8, α_a = 0.05, β_a = 0.0)))
@say("init! without root-input coverage", (kinds(e), lifecycle(s5)))
tri_ = Group((; plant = Plant(), ctl = DiscreteAccumulator(3.0)); input_wires = ("u" => "plant/u", "e" => "ctl/e"))
s6 = Simulation(tri_; h = 1//10)
e = caught(() -> init!(s6, set()))
@say("UninitializedInputs faces, declaration order", ds(e)[1].faces)
lin = Simulation(tri_; h = 1//10)
e = caught(() -> linearize(lin, taps(x = (q1 = get_state("plant", "q[1]"),), u = (u = get_input(:u),), y = (;)); about = set(u = (u = 1.0,))))
@say("linearize about=: a fourth totality site", (kinds(e), e isa DiagnosticError ? ds(e)[1].op : nothing))
end
