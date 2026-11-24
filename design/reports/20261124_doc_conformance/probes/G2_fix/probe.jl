# G2 fixer probe: re-checks the behaviour behind the G2 rows, run from W with --project=test.
using Redstone, StaticArrays, ForwardDiff, Test
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
import Redstone: s_init, message, diagnostics, diagnostic
ds(e) = e isa DiagnosticError{Vector{Diagnostic}} ? diagnostics(e) : [diagnostic(e)]
tryit(f) = try f(); "no error" catch err err end
kinds(e) = e isa DiagnosticError ? [(nameof(typeof(d)), hasproperty(d, :reason) ? d.reason : hasproperty(d, :invariant) ? d.invariant : hasproperty(d, :site) ? d.site : :-) for d in ds(e)] : e
msgs(e) = e isa DiagnosticError ? [message(d) for d in ds(e)] : e

module MyEngine
using Redstone
struct Engine <: Redstone.AbstractComponent end
Redstone.x_init(::Engine) = (q = 0.0,)
Redstone.y_types(::Engine) = (q = Float64,)
Redstone.y_state(::Engine, (; x)) = (q = x.q,)
x_deriv(::Engine, _) = (q = 1.0,)
end
println("S8a-039: ", msgs(tryit(() -> build(Group((; engine = MyEngine.Engine()))))))

d1 = ForwardDiff.Dual{Nothing}(1.0, 1.0)
retann(x)::SVector{3,Float64} = SVector(x, x, x)
e = tryit(() -> retann(d1)); println("S8b-071: ", typeof(e), " ", first(sprint(showerror, e), 90))
struct GCH; a::Float64; end
e = tryit(() -> GCH(d1)); println("S8b-167 ctor: ", typeof(e), " ", first(sprint(showerror, e), 90))
struct Hardcoded <: AbstractComponent end
x_init(::Hardcoded) = (q = 0.0,)
y_types(::Hardcoded) = (c = Pinned{GCH},)
y_state(::Hardcoded, (; x)) = (c = GCH(x.q),)
x_deriv(::Hardcoded, _) = (q = 1.0,)
e = tryit(() -> build(Group((; c = Hardcoded())); activations = (Float64, ForwardDiff.Dual{Nothing,Float64,1})))
println("S8b-167 build: ", kinds(e), " ", e isa DiagnosticError ? first(msgs(e)[1], 200) : "")

struct XS <: AbstractComponent end
x_init(::XS) = (q = 0.0,); y_types(::XS) = (q = Float64,); y_state(::XS, (; x)) = (q = x.q,)
s_update(::XS, _) = (q = 1.0,)
struct SX <: AbstractComponent end
s_init(::SX) = (q = 0.0,); y_types(::SX) = (q = Float64,); y_state(::SX, (; s)) = (q = s.q,)
x_deriv(::SX, _) = (q = 1.0,)
struct SN <: AbstractComponent end
s_init(::SN) = (q = 0.0,); y_types(::SN) = (q = Float64,); y_state(::SN, (; s)) = (q = s.q,)
for c in (XS(), SX(), SN()); println("S8c-036 ", nameof(typeof(c)), ": ", kinds(tryit(() -> build(Group((; c)))))); end

println("S8c-119: ", typeof(tryit(() -> Redstone.Library.PID(kp = 2.0))), " / ", typeof(Redstone.Library.PID(Kp = 2.0)))

println("S8d-037: ", kinds(tryit(() -> build(Group((; a = Gain(1.0), b = Gain(2.0));
    input_wires = ("in" => ("a/e", "b/e"),), output_wires = ("a/out" => "o", "b/out" => "o"))))))

gs = Group((; s = Sum()); input_wires = ("a" => "s/a", "b" => "s/b"))
println("S8e-122: ", msgs(tryit(() -> input_passthrough(gs, "s"; except = ("a",), only = ("b",)))))
for o in (("a",), ("a", "b"))
    r = Redstone.Diagnostic[]
    out = Base.CoreLogging.with_logger(Base.CoreLogging.NullLogger()) do
        input_passthrough(gs, "s"; only = o)
    end
    println("S8e-131 only=$o: ", out)
end
println("S8e-131 bad only: ", kinds(tryit(() -> input_passthrough(gs, "s"; only = ("zz",)))))
