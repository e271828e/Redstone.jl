# Chapter 13 half-1 survey: run the half's code blocks and claims against the
# package. From the repository root:
#     julia --project=test -t 2 docs/spec_rewrite/ch13/scratch_survey/h1/run/blocks.jl
module H1Check
include(joinpath(@__DIR__, "..", "..", "..", "..", "..", "..", "test", "repl.jl"))
using Test

function check(label, f)
    try
        r = f()
        println("[ok]   ", label, " => ", r)
    catch e
        println("[FAIL] ", label, " => ", sprint(showerror, e)[1:min(end, 600)])
    end
end
caught(f) = try f(); nothing catch e; e end

single(c) = Group((; c = c))
fed(c, face) = Group((; c = c); input_wires = ("in" => "c/$face",))

println("== §13.2 sketch (10019–10032): Diagnostic and DiagnosticError")
check("Diagnostic is abstract", () -> isabstracttype(Diagnostic))
check("WireTypeMismatch <: Diagnostic", () -> WireTypeMismatch <: Diagnostic)
check("DiagnosticError fields", () -> fieldnames(DiagnosticError))
check("DiagnosticError parameter bound", () -> DiagnosticError.var.ub)

println("== §13.4 cursor sketch (10279–10285)")
check("ExecutionCursor is mutable", () -> ismutabletype(Redstone.ExecutionCursor))
check("ExecutionCursor fields", () -> fieldnames(Redstone.ExecutionCursor))

println("== §13.4 StepError sketch (10323–10333)")
check("StepError fields", () -> fieldnames(StepError))
check("StepError field types", () -> fieldtypes(StepError))
check("StepError parameter bound", () -> StepError.var.ub)

println("== §13.1 worked example: a typo'd wire")
struct TwoTypos <: AbstractComponent
    g1::Gain; s1::Sum; g2::Gain; s2::Sum
end
local_wires(::TwoTypos) = ("g1/ot" => "s1/a", "g2/ot" => "s2/a")
input_wires(::TwoTypos) = ("e1" => "g1/e", "b1" => "s1/b", "e2" => "g2/e", "b2" => "s2/b")
check("two typos: order of kinds and paths in the carrier", () -> begin
    err = caught(() -> build(TwoTypos(Gain(1.0), Sum(), Gain(1.0), Sum())))
    (typeof(err), [(nameof(typeof(d)), Redstone.path(d)) for d in diagnostics(err)])
end)
check("two typos: rendered order", () -> begin
    err = caught(() -> build(TwoTypos(Gain(1.0), Sum(), Gain(1.0), Sum())))
    [first(split(l, ':')) * " " * (occursin("s1", l) || occursin("g1", l) ? "(1)" : "(2)")
     for l in split(sprint(showerror, err), '\n')[2:end]]
end)
check("@test_throws DiagnosticError{Kind} for a fail-fast service throw", () -> begin
    m = Model(fed(Gain(1.0), "e"); h = 1//10)
    e = caught(() -> step!(Simulation(fed(Gain(1.0), "e"); h = 1//10)))
    typeof(e)
end)

println("== §13.2 bundle-law did-you-mean at the probe")
struct DestructuresM <: AbstractComponent end
x_init(::DestructuresM) = (q = 0.0,)
y_types(::DestructuresM) = (q = Float64,)
y_state(::DestructuresM, (; x)) = (q = x.q,)
x_deriv(::DestructuresM, (; x, m)) = (q = 1.0,)
check("x_deriv destructuring m with no m_init", () -> begin
    err = caught(() -> build(Group((; plant = DestructuresM()))))
    d = err isa DiagnosticError{<:Diagnostic} ? diagnostic(err) : only(diagnostics(err))
    (typeof(err), nameof(typeof(d)), d.reason, sprint(showerror, err))
end)

println("== §13.4 the recipe (10345–10348): replay to the pointer, then step!")
check("recipe at pointer 3", () -> begin
    sim = Simulation(fed(Tripwire(0.35), "arm"); h = 1//10)
    init!(sim, set(u = (in = false,)))
    step!(sim; frames = 3)
    stage!(sim, "in" => true)
    err = caught(() -> step!(sim))
    k = err.boundary
    trc = trace(sim)
    sim2 = Simulation(fed(Tripwire(0.35), "arm"); h = 1//10)
    init!(sim2, set(u = (in = false,)))
    replay!(sim2, trc; to_boundary = k)            # halt at the frame top; still :replay
    halted = (lifecycle(sim2), mode(sim2))
    err2 = caught(() -> step!(sim2; frames = 1))   # re-execute the failing frame
    (k = k, t = err.t, host = err.host, halted = halted, same = typeof(err2) === typeof(err) &&
     err2.cursor == err.cursor && err2.boundary == k, after = lifecycle(sim2))
end)
check("StepError.t mid-integration (is it a boundary time?)", () -> begin
    sim = Simulation(fed(Tripwire(0.05), "arm"); h = 1//10)
    init!(sim, set(u = (in = true,)))
    err = caught(() -> run!(sim; t_end = 1.0))
    (err.t, err.cursor, err.boundary, err.host)
end)

println("== §13.4 boundary zero")
check("throw inside boundary zero", () -> begin
    sim = Simulation(fed(Mine(), "sig"); h = 1//10)
    err = caught(() -> init!(sim, set(u = (in = true,))))
    tr = caught(() -> trace(sim))
    rs = caught(() -> run!(sim))
    st = caught(() -> step!(sim))
    (typeof(err), err.boundary, err.host, err.t, lifecycle(sim), termination(sim),
     typeof(tr), typeof(rs), typeof(st))
end)
check("restore! after a boundary-zero failure", () -> begin
    sim = Simulation(fed(Mine(), "sig"); h = 1//10)
    init!(sim, set(u = (in = false,)))
    cp = checkpoint(sim)
    caught(() -> init!(sim, set(u = (in = true,))))
    l0 = lifecycle(sim)
    restore!(sim, cp)
    (l0, lifecycle(sim))
end)

println("== §13.4 disposition")
check("run! deviceless rethrows; rostered returns errored", () -> begin
    a = Simulation(fed(Tripwire(0.15), "arm"); h = 1//10)
    init!(a, set(u = (in = true,)))
    ea = caught(() -> run!(a; t_end = 1.0))
    b = Simulation(fed(Tripwire(0.15), "arm"); h = 1//10)
    init!(b, set(u = (in = true,)))
    attach!(b, Pad("p"), NoClaim())
    init!(b, set(u = (in = true,)))
    eb = caught(() -> run!(b; t_end = 1.0))
    (typeof(ea), lifecycle(a), eb, lifecycle(b), typeof(termination(b).source))
end)
check("step! with a device attached always rethrows", () -> begin
    b = Simulation(fed(Tripwire(0.15), "arm"); h = 1//10)
    attach!(b, Pad("p"), NoClaim())
    init!(b, set(u = (in = true,)))
    e = caught(() -> step!(b; frames = 5))
    (typeof(e), lifecycle(b))
end)

println("== §13.4 nonfinite sweep")
diverging() = Group((div = Diverger(), con = Consumer());
                    local_wires = ("div/q" => "con/in",), input_wires = ("in" => "div/arm",))
check("NonfiniteState names the diverged block", () -> begin
    sim = Simulation(diverging(); h = 1//10)
    init!(sim, set(u = (in = true,)))
    e = caught(() -> run!(sim; t_end = 1.0))
    (typeof(e), e.cause.path, e.cause.leaf, e.cause.t, e.cause.boundary)
end)

println("== §13.4 bare value thrown by model code")
struct BareThrow <: AbstractComponent end
x_init(::BareThrow) = (q = 0.0,)
y_types(::BareThrow) = (q = Float64,)
y_state(::BareThrow, (; x)) = (q = x.q,)
x_deriv(::BareThrow, (; x, t)) = t > 0.05 ? throw(42) : (q = 1.0,)
check("throw(42) inside a frame", () -> begin
    sim = Simulation(single(BareThrow()); h = 1//10)
    init!(sim)
    e = caught(() -> run!(sim; t_end = 1.0))
    (typeof(e), lifecycle(sim))
end)

println("== §13.3 primitives")
check("resolve one level", () -> nameof(typeof(resolve(SampledLoop(), "plant"))))
check("resolve two levels", () -> begin
    e = caught(() -> resolve(Group((; i = SampledLoop())), "i/plant"))
    e === nothing ? "resolved" : (typeof(e), diagnostic(e).reason)
end)
check("resolve_terminal", () -> resolve_terminal(SampledLoop(), "plant/u"))
check("face lists", () -> (input_faces(Sum()), output_faces(SampledLoop()), input_faces(SampledLoop())))

println("== §13.3 inspection client: a device read binding past a generic seam")
struct GenericHold{L <: AbstractComponent} <: AbstractComponent
    inner::L
end
local_wires(::GenericHold) = ()
input_wires(::GenericHold) = ("ref" => "inner/ref",)
output_wires(::GenericHold) = ("inner/y" => "y",)
check("attach! Readout(get_state(\"inner/plant\", :q)) on GenericHold", () -> begin
    sim = Simulation(GenericHold(SampledLoop()); h = 1//50)
    e = caught(() -> attach!(sim, Pad("t"), Readout(q = get_state("inner/plant", :q))))
    e === nothing ? "attached" :
        (typeof(e), [(nameof(typeof(d)), hasproperty(d, :reason) ? d.reason : nothing)
                     for d in (e isa DiagnosticError{<:Diagnostic} ? [diagnostic(e)] :
                               diagnostics(e))])
end)

println("== §13.2 warnings(x)")
check("warnings on Build, Deployment, Model, Simulation", () -> begin
    sim = Simulation(fed(Gain(1.0), "e"); h = 1//10)
    (hasmethod(warnings, Tuple{Build}), hasmethod(warnings, Tuple{Deployment}),
     hasmethod(warnings, Tuple{Model}), hasmethod(warnings, Tuple{Simulation}))
end)
end
