# §5.2's bundle-law example: `x_deriv` of `Foo` destructures `m`, but `Foo` declares no `m_init`.
import Redstone: x_init, y_types, y_state, x_deriv
struct Foo <: AbstractComponent end
x_init(::Foo) = (q = 0.0,)
y_types(::Foo) = (q = Float64,)
y_state(::Foo, (; x)) = (q = x.q,)
x_deriv(::Foo, (; x, m)) = (q = -x.q,)
try
    build(Foo())
catch e
    println(typeof(e))
    d = e isa DiagnosticError ? e.carried : e
    println(typeof(d))
    println(d isa Vector ? join(Redstone.message.(d), "\n") : Redstone.message(d))
end
# a stateless continuous leaf: does its bundle carry `x`?
struct Stateless <: AbstractComponent end
x_init(::Stateless) = (;)
Redstone.u_types(::Stateless) = (a = Float64,)
y_types(::Stateless) = (b = Float64,)
Redstone.y_direct(::Stateless, (; x, u)) = (b = u.a,)
try
    build(Group((s = Stateless(),); input_wires = "a" => "s/a", output_wires = "s/b" => "b"))
catch e
    d = e isa DiagnosticError ? e.carried : e
    println(d isa Vector ? join(Redstone.message.(d), "\n") : Redstone.message(d))
end
