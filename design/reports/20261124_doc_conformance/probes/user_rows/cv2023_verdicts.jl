# CV2-023: does accepting an untagged operand at Float64(::Tracer{true}) change a
# verdict? Run once as shipped and once with the conversion routed through
# `_decide`, as `Int` and `Bool` are (ARGS[1] == "patched").
const TESTDIR = "/Users/miguel/.julia/dev/Redstone.jl/test"
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
include(joinpath(TESTDIR, "imports.jl")); include(joinpath(TESTDIR, "fixtures.jl")); include(joinpath(TESTDIR, "utils.jl"))
if get(ARGS, 1, "") == "patched"
    @eval Redstone Base.Float64(x::Tracer{true}) = (_decide(true, x.dependencies); x.value)
end
say(t, x) = println(rpad(t, 30), " => ", x)
table(q) = q > 0 ? 1.0 : 2.0

# kind 1: Float64 of a state value, the input routed plainly
struct OnState <: AbstractComponent; k::Float64; end
# kind 2: Float64 of the in-cycle input itself (tagged)
struct OnInput <: AbstractComponent end
# kind 3: Float64 of a state value, and the input multiplied by zero (a dead hop)
struct DeadHop <: AbstractComponent end
# kind 4: an abstract entry, so the face takes no tag, and Float64 of that input
struct Abstract <: AbstractComponent end
# kind 5: Float64 of a state value picks whether the input routes
struct Gate <: AbstractComponent end
# kind 6: a direct branch on state, closed at the probe state, no conversion
struct ClosedGate <: AbstractComponent end
# kind 7: the same gate behind Float64 of the state value
struct ClosedConv <: AbstractComponent end
# a plain walking member
struct Plain <: AbstractComponent end
for C in (OnState, OnInput, DeadHop, Abstract, Gate, ClosedGate, ClosedConv, Plain)
    @eval x_init(::$C) = (q = 0.0,)
    @eval y_types(::$C) = (y = Float64,)
    @eval x_deriv(::$C, (; x)) = (q = -x.q,)
    C === Abstract || @eval u_types(::$C) = (u = Float64,)
end
u_types(::Abstract) = (u = Real,)
y_direct(c::OnState, (; x, u)) = (y = c.k * u.u + table(Float64(x.q)),)
y_direct(::OnInput, (; x, u)) = (y = one(u.u) * table(Float64(u.u)) + x.q,)
y_direct(::DeadHop, (; x, u)) = (y = 0 * u.u + table(Float64(x.q)),)
y_direct(::Abstract, (; x, u)) = (y = x.q + 0.5 * Float64(u.u),)
y_direct(::Gate, (; x, u)) = (y = table(Float64(x.q)) > 1.5 ? u.u : zero(u.u),)
y_direct(::ClosedGate, (; x, u)) = (y = x.q > 0 ? u.u : zero(u.u),)
y_direct(::ClosedConv, (; x, u)) = (y = Float64(x.q) > 0 ? u.u : zero(u.u),)
y_direct(::Plain, (; x, u)) = (y = 2 * u.u + x.q,)
loop2(a, b) = Group((a = a, b = b); local_wires = ("a/y" => "b/u", "b/y" => "a/u"))
for (name, a) in (("state", OnState(2.0)), ("input", OnInput()), ("dead hop", DeadHop()),
                  ("abstract entry", Abstract()), ("state gate", Gate()), ("closed gate, direct", ClosedGate()), ("closed gate, Float64", ClosedConv()))
    e = failure(() -> build(loop2(a, Plain())))
    ds = e isa DiagnosticError ? (e.carried isa Vector ? e.carried : [e.carried]) : [e]
    for d in ds
        d isa AlgebraicCycle ? say(name, (d.classification, d.traced, d.dead)) : say(name, first(sprint(showerror, d), 300))
    end
end
