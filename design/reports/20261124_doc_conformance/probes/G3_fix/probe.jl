# G3 fixer probes. Run from the pinned worktree with --project=test.
using Redstone, ForwardDiff, StaticArrays
import Redstone: AbstractComponent, x_init, u_types, y_types, y_state, y_direct, x_deriv,
    build, Model, Group, DiagnosticError, message, port, probe_value

section(s) = println("\n== ", s)
function catchmsg(f)
    try
        r = f(); return "OK: " * first(string(typeof(r)), 60)
    catch err
        err isa DiagnosticError ?
            join([string(nameof(typeof(d))) * " " * message(d)
                  for d in (err.carried isa Vector ? err.carried : [err.carried])], " | ") :
            sprint(showerror, err)[1:min(end, 300)]
    end
end

struct Shaft <: AbstractComponent end
x_init(::Shaft) = (ω = 1.0,)
y_types(::Shaft) = (P = Float64, M_shaft = Float64)
y_state(::Shaft, (; x)) = (P = x.ω, M_shaft = 0)
x_deriv(::Shaft, (; x)) = (ω = -x.ω,)

struct BareRamp <: AbstractComponent end
x_init(::BareRamp) = (q = 0.0,)
y_types(::BareRamp) = Float64
y_state(::BareRamp, (; x)) = x.q
x_deriv(::BareRamp, (; x)) = (q = 1.0,)

section("S9c-132 message, root and nested")
println(catchmsg(() -> build(Shaft())))
println(catchmsg(() -> build(Group((; shaft = Shaft())))))

section("S9b-280 probe_value(SVector)")
println(probe_value(SVector{3,Float64}))

section("CV9a-011 port with no name")
m = Model(Group((; a = Group((; r = BareRamp()); output_wires = ("r/y" => "y",)))); Δt_frame = 1)
println("a/r: ", catchmsg(() -> port(m, "a/r")))
println("a:   ", catchmsg(() -> port(m, "a")))
println("root: ", catchmsg(() -> port(m, "")))
m2 = Model(BareRamp(); Δt_frame = 1)
println("primitive root: ", catchmsg(() -> port(m2, "")))

section("CV9b-047 chunk_size")
for c in (0, 1.5, 1)
    println(c, " => ", catchmsg(() -> Model(BareRamp(); Δt_frame = 1, chunk_size = c)))
end

section("K9b-067 convert(Float64, Dual)")
println(catchmsg(() -> convert(Float64, ForwardDiff.Dual(1.0, 1.0))))
println(which(convert, (Type{Float64}, ForwardDiff.Dual{Nothing,Float64,1})))
