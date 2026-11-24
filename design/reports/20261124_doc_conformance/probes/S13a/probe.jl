# S13a probe: spec §13.1-§13.3 claims.
import Redstone
import Redstone: AbstractComponent, Group, build, DiagnosticError, Diagnostic, severity,
    resolve, resolve_terminal, input_faces, output_faces, x_init, s_init, u_types, y_types,
    y_state, y_direct, x_deriv, s_update, local_wires, input_wires, output_wires,
    PathResolution, UnknownPort, UnconnectedInput, BundleFieldError, UserCodeFraming,
    diagnostics, diagnostic, kinds, warnings, ClassMixed, StepError, InternalInvariant,
    EmptyFaceSelection, input_passthrough, ClassUnreadable, IllegalWireEntry
using StaticArrays

struct Acc <: AbstractComponent end
x_init(::Acc) = 1.0
u_types(::Acc) = (u = Float64,)
y_types(::Acc) = (y = Float64,)
y_state(::Acc, (; x)) = (y = x,)
x_deriv(::Acc, (; x, u)) = u.u - x

struct Neg <: AbstractComponent end
x_init(::Neg) = nothing
u_types(::Neg) = (a = Float64, b = Float64)
y_types(::Neg) = (y = Float64, z = Float64)
y_direct(::Neg, (; a, b)) = (y = a, z = b)   # wrong: no u bundle names -> fieldless
struct BareS <: AbstractComponent end
x_init(::BareS) = nothing
u_types(::BareS) = Float64
y_types(::BareS) = Float64
y_direct(::BareS, (; u)) = -2.0 * u

struct Bad <: AbstractComponent end         # reads m with no m_init
x_init(::Bad) = 1.0
y_types(::Bad) = (y = Float64,)
y_state(::Bad, (; x)) = (y = x,)
x_deriv(::Bad, (; x, m)) = 0.0

struct BadTier <: AbstractComponent end      # destructures s on a continuous component
x_init(::BadTier) = 1.0
y_types(::BadTier) = (y = Float64,)
y_state(::BadTier, (; x, s)) = (y = x,)
x_deriv(::BadTier, (; x)) = 0.0

struct Boom <: AbstractComponent end
x_init(::Boom) = 1.0
y_types(::Boom) = (y = Float64,)
y_state(::Boom, (; x)) = error("boom")
x_deriv(::Boom, (; x)) = 0.0

struct Dotted <: AbstractComponent end
x_init(::Dotted) = nothing
u_types(::Dotted) = (;)
y_types(::Dotted) = (y = Float64,)
y_direct(::Dotted, _) = (y = 1.0,)

function try_build(label, f)
    println("--- ", label)
    try
        f()
        println("no throw")
    catch err
        println(typeof(err))
        err isa DiagnosticError && showerror(stdout, err)
        println()
        return err
    end
end

# deep resolution
inner = Group((; acc = Acc(), neg = Neg()); local_wires = ("acc/y" => "neg/a",),
              input_wires = ("u" => "acc/u",), output_wires = ("neg/y" => "o",))
outer = Group((; sub = inner, s = BareS()); local_wires = ("sub/o" => "s/u",),
              input_wires = ("u" => "sub/u",), output_wires = ("s/y" => "out",))
println("probe:resolve child: ", resolve(outer, "sub") === outer.children.sub)
for p in ("sub/acc", "", "nope", "sub/")
    e = try_build("resolve $p", () -> resolve(outer, p))
    e isa DiagnosticError && println("  reason=", e.carried.reason, " type=", typeof(e))
end
println("probe:resolve_terminal ", resolve_terminal(outer, "sub/u")[2], " | child alone: ",
        repr(resolve_terminal(outer, "sub")[2]))
e = try_build("resolve_terminal deep", () -> resolve_terminal(outer, "sub/acc/u"))
e isa DiagnosticError && println("  reason=", e.carried.reason)
e = try_build("resolve_terminal trailing slash", () -> resolve_terminal(outer, "sub/"))
e isa DiagnosticError && println("  reason=", e.carried.reason)

println("probe:input_faces prim ", input_faces(Neg()), " ", output_faces(Neg()))
println("probe:bare ", input_faces(BareS()), " ", output_faces(BareS()))
println("probe:assembly ", input_faces(inner), " ", output_faces(inner), " ", typeof(input_faces(inner)))
println("probe:faces fresh ", input_faces(Neg()) !== input_faces(Neg()))

# container element
struct Ctr{U} <: AbstractComponent
    units::U
end
local_wires(::Ctr) = ()
input_wires(::Ctr) = ("u" => "units/a/u",)
output_wires(::Ctr) = ()
ctr = Ctr((a = Acc(), b = Acc()))
println("probe:container ", resolve(ctr, "units/a") === ctr.units.a)

# collected: typo'd wire -> 2 errors
typo = Group((; acc = Acc(), neg = Neg()); local_wires = ("acc/y" => "neg/a", "acc/yy" => "neg/b"),
             input_wires = ("u" => "acc/u",), output_wires = ("neg/y" => "o",))
e = try_build("typo wire", () -> build(typo))
println("probe:kinds ", e isa DiagnosticError ? kinds(e) : nothing, " ", typeof(e))

# probes
e = try_build("bundle m", () -> build(Bad()))
e isa DiagnosticError && println("probe:bfe ", e.carried.reason, " ", typeof(e))
e = try_build("bundle s on continuous", () -> build(BadTier()))
e isa DiagnosticError && println("probe:bfe tier ", e.carried.reason, " ", typeof(e))
e = try_build("user boom", () -> build(Boom()))
e isa DiagnosticError && println("probe:framing ", typeof(e), " ", e.carried.fn, " ", e.carried.bundle)

# structural failure alone: mixed class + wire typo elsewhere
struct Mixed <: AbstractComponent end
x_init(::Mixed) = 1.0
local_wires(::Mixed) = ()
y_types(::Mixed) = (y = Float64,)
x_deriv(::Mixed, (; x)) = 0.0
y_state(::Mixed, (; x)) = (y = x,)
mixroot = Group((; m = Mixed(), acc = Acc(), neg = Neg()); local_wires = ("acc/yy" => "neg/a",),
                input_wires = ("u" => "acc/u",), output_wires = ("neg/y" => "o",))
e = try_build("mixed class + typo", () -> build(mixroot))
println("probe:mixed ", e isa DiagnosticError ? (typeof(e), length(e.carried isa Vector ? e.carried : [e.carried])) : nothing)

# wire declaration not a collection of pairs
nonpair = Group((; acc = Acc()); local_wires = (), input_wires = "u", output_wires = ())
e = try_build("wire non-collection", () -> build(nonpair))

# severity
println("probe:severity ", severity(EmptyFaceSelection(who="a", path="", selector=:except, names=String[], candidates=String[])),
        " ", severity(PathResolution(entry="e", spelling="s", reason=:x)))
# a warning-bearing build
println("probe:Dotted face names ", output_faces(Dotted()))
println("probe:done")
