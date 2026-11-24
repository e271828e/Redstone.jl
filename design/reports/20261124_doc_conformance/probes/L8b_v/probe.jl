# L8b verifier probes, run against the pinned worktree.
using Redstone, StaticArrays
const R = Redstone
const L = Redstone.Library
struct MixedAsm <: R.AbstractComponent; xs::Tuple{Any,Any}; end
Redstone.local_wires(::MixedAsm) = ()
p(id, x) = println(id, " | ", x)
tryp(id, f) = try p(id, f()) catch e; p(id, "THROWS " * first(sprint(showerror, e), 400)) end

p("001 names", names(Redstone))
p("001 isexported Group", Base.isexported(Redstone, :Group))
# 010 / 020 read from source
tryp("035 empty selection warning", () -> begin
    inner = R.Group((; k = L.Constant(1.0)); output_wires = "k/y" => "y")
    outer = R.Group((; inner); output_wires = g -> R.output_passthrough(g, "inner"; select = n -> false))
    b = R.build(outer)
    [typeof(w) for w in R.warnings(b)]
end)
tryp("035 bare silent", () -> begin
    inner = R.Group((; k = L.Constant(1.0)))
    outer = R.Group((; inner); input_wires = g -> R.input_passthrough(g, "inner"))
    R.warnings(R.build(outer))
end)
p("040-050 Deployment fields", fieldnames(R.Deployment))
p("050 Schedule fields", fieldnames(R.Schedule))
p("045 hasfield grid", hasfield(R.Deployment, :grid))
p("040 Simulation fields", fieldnames(R.Simulation))
p("040 Model params", R.Model)
tryp("053 Simulation(root; kw)", () -> typeof(R.Simulation(R.Group((; k = L.Constant(1.0), i = L.Integrator()); local_wires = ("k/y" => "i/u",)); Δt_frame = 1//100)))
tryp("063 Freeze tier", () -> begin
    b = R.build(R.Group((; k = L.Constant(1.0), f = L.Freeze{Float64}()); local_wires = ("k/y" => "f/u",)))
    [(e.path, e.tier) for e in b.structure.components]
end)
p("063 Freeze x_init/s_init", (R.x_init(L.Freeze{Float64}()), hasmethod(R.s_init, Tuple{L.Freeze{Float64}})))
p("070 pin hint", repr(R._pin_hint(R.Pinned{Float64}, Float64, Float64)), )
tryp("070 pin hint dual", () -> R._pin_hint(R.Pinned{Float64}, R.Pinned{Float64}, Float32))
tryp("073 mixed container", () -> begin
    R.build(MixedAsm((L.Constant(1.0), 3.0)))
end)
p("083 Group fields", fieldnames(R.Group))
p("083 Group(…; sample_times) kw", Base.kwarg_decl(first(methods(R.Group, (Any,)))))
tryp("083 rates kw", () -> R.Group((; k = L.Constant(1.0)); rates = (;)))
p("088 isdefined u_connections", (isdefined(R, :u_connections), isdefined(R, :input_wires), isdefined(R, :output_wires)))
p("091 Junction y_types", R.y_types(L.Junction{Float64, Float64, 2}(+)))
p("091 output_faces SumJunction", R.output_faces(L.SumJunction{Float64, 2}()))
p("095 zero-arg", (typeof(L.SumJunction{Float64, 3}()), typeof(L.Or{2}()), typeof(L.And{2}())))
p("098 output faces sample", [(T, R.output_faces(c)) for (T, c) in (("Integrator", L.Integrator()), ("UnitDelay", L.UnitDelay(0.0)), ("LimitedIntegrator", L.LimitedIntegrator(lower = -1.0, upper = 1.0)))])
p("105 DLI inputs", (R.input_faces(L.DiscreteLimitedIntegrator(lower = -1.0, upper = 1.0)), R.input_faces(L.DiscreteLimitedIntegrator(lower = -1.0, upper = 1.0, reset = true))))
p("107 Period/Hz defined", (isdefined(R, :Period), isdefined(R, :Hz), isdefined(L, :Period)))
tryp("107 Absolute huge", () -> R.Absolute(big(2)^70))
tryp("107 Absolute(0)", () -> R.Absolute(0))
p("125 Absolute default τ", R.Absolute(1//50))
tryp("125 Absolute float", () -> R.Absolute(0.02))
p("135 Library has Group", isdefined(L, :Group))
tryp("144 two bad decls", () -> begin
    g = R.Group((; k = L.Constant(1.0)); local_wires = 3, output_wires = "k/y" => "out")
    R.build(g)
end)
