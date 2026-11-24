# L8a verifier probes (read-only). Run from the pinned worktree with --project=test.
using Redstone, StaticArrays
import Redstone: AbstractComponent, AbstractDevice, AbstractBinding, x_init, s_init, u_types, y_types,
    y_state, y_direct, x_deriv, local_wires, input_wires, output_wires, transparent_container,
    is_input, is_output, claims, reads, loop, Group, DiagnosticError, Deployment, Simulation,
    input_passthrough, output_passthrough, stage!, detach!, attach!, step!, init!, set, at

function show_err(label, f)
    try
        r = f()
        println(label, " => OK: ", r)
    catch e
        if e isa DiagnosticError
            ds = e.carried isa Vector ? e.carried : [e.carried]
            println(label, " => DiagnosticError: ", join([string(typeof(d), " ", d) for d in ds], " | "))
        else
            println(label, " => ", typeof(e), ": ", sprint(showerror, e)[1:min(end, 200)])
        end
    end
end

struct PGain <: AbstractComponent
    k::Float64
end
x_init(::PGain) = nothing
u_types(::PGain) = (e = Float64,)
y_types(::PGain) = (out = Float64,)
y_direct(c::PGain, (; u)) = (out = c.k * u.e,)

# L8a-001: a field declared `::Any` holding a component
struct AnyHolder <: AbstractComponent
    c::Any
    p::Float64
end
local_wires(::AnyHolder) = ()
println("L8a-001 children(Any-typed field) = ", Redstone.children("", AnyHolder(PGain(1.0), 2.0)))
println("L8a-001 fieldtype(AnyHolder, :c) = ", fieldtype(AnyHolder, :c))

# L8a-010/011
println("L8a-010 isdefined exports/u_connections/input_wires/output_wires = ",
        isdefined(Redstone, :exports), " ", isdefined(Redstone, :u_connections), " ",
        isdefined(Redstone, :input_wires), " ", isdefined(Redstone, :output_wires))
show_err("L8a-011 input_wires entry naming an output", () ->
    Redstone.build(Group((; g = PGain(1.0)); input_wires = ("x" => "g/out",), output_wires = ("g/out" => "o",))))

# L8a-012: an assembly declaring a face type is a class error; face type from endpoint
struct TypedAsm <: AbstractComponent
    g::PGain
end
local_wires(::TypedAsm) = ()
y_types(::TypedAsm) = (o = Float64,)
show_err("L8a-012 assembly declaring y_types", () -> Redstone.build(TypedAsm(PGain(1.0))))

# L8a-018
println("L8a-018 Deployment fields = ", fieldnames(Deployment))
println("L8a-018 Simulation fields = ", fieldnames(Simulation))

# L8a-020: empty face name
show_err("L8a-020 empty face name", () ->
    Redstone.build(Group((; g = PGain(1.0)); input_wires = ("" => "g/e",), output_wires = ("g/out" => "o",))))
show_err("L8a-020 slash face name", () ->
    Redstone.build(Group((; g = PGain(1.0)); input_wires = ("a/b" => "g/e",), output_wires = ("g/out" => "o",))))

# local_types family
println("L8a-030 isdefined local_types/output_types/u_types = ", isdefined(Redstone, :local_types), " ",
        isdefined(Redstone, :output_types), " ", isdefined(Redstone, :u_types))
struct ExtraReturn <: AbstractComponent end
x_init(::ExtraReturn) = nothing
u_types(::ExtraReturn) = (e = Float64,)
y_types(::ExtraReturn) = (out = Float64,)
y_direct(::ExtraReturn, (; u)) = (out = u.e, scratch = 2u.e)
show_err("L8a-031 stage returning undeclared field", () ->
    Redstone.build(Group((; g = ExtraReturn()); input_wires = ("e" => "g/e",), output_wires = ("g/out" => "o",))))

# L8a-044
println("L8a-044 isdefined capture/checkpoint/overlay! = ", isdefined(Redstone, :capture), " ",
        isdefined(Redstone, :checkpoint), " ", isdefined(Redstone, :overlay!))

# L8a-048
SJ = Redstone.Library.SumJunction
show_err("L8a-048 SumJunction()", () -> SJ())
show_err("L8a-048 SumJunction{Float64,2}()", () -> typeof(SJ{Float64,2}()))

# L8a-051: typo'd source port
show_err("L8a-051 typo'd source port", () ->
    Redstone.build(Group((; a = PGain(1.0), b = PGain(1.0));
        local_wires = ("a/outt" => "b/e",), input_wires = ("e" => "a/e",), output_wires = ("b/out" => "o",))))

# L8a-062 / L8a-105
println("L8a-062 isdefined faces/declaration_error = ", isdefined(Redstone, :faces), " ", isdefined(Redstone, :declaration_error))
inner = Group((; g = PGain(1.0)); input_wires = ("e" => "g/e", "f" => "g/e"), output_wires = ("g/out" => "o", "g/out" => "p"))
outer = Group((; inner))
show_err("L8a-062 input_passthrough except+only", () -> input_passthrough(outer, "inner"; except = ("e",), only = ("f",)))
show_err("L8a-105 output_passthrough except+only", () -> output_passthrough(outer, "inner"; except = ("o",), only = ("p",)))
show_err("L8a-105 output_passthrough prefix/sep/except", () -> output_passthrough(outer, "inner"; prefix = "X", sep = "_", except = ("o",)))
show_err("L8a-105 output_passthrough only", () -> output_passthrough(outer, "inner"; only = ("o",)))

# L8a-073/074: sides by trait, not method presence
struct ClaimsOnly <: AbstractBinding end
claims(::ClaimsOnly) = ("e",)
show_err("L8a-073 binding defining claims, no is_input trait", () -> Redstone.check_binding(ClaimsOnly()))
struct InNoClaims <: AbstractBinding end
is_input(::InNoClaims) = true
show_err("L8a-073 is_input true, no claims method", () -> claims(InNoClaims()))

mutable struct Idle <: AbstractDevice end
loop(::Idle, handle) = nothing
struct InBinding <: AbstractBinding end
is_input(::InBinding) = true
claims(::InBinding) = ("e",)
root = Group((; g = PGain(2.0)); input_wires = ("e" => "g/e", "f" => "g/e2"), output_wires = ("g/out" => "o",))
root = Group((; g = PGain(2.0)); input_wires = ("e" => "g/e",), output_wires = ("g/out" => "o",))
sim = Simulation(root; Δt_frame = 1//10)
show_err("L8a-123 detach! of a device never attached", () -> detach!(sim, Idle()))
show_err("L8a-023 stage!(sim, \"e\" => 1.0)", () -> stage!(sim, "e" => 1.0))
dev = Idle()
h = attach!(sim, dev, InBinding())
println("L8a-074 claim after attach: claimedby = ", sim.plane.claimedby)
show_err("L8a-074 stage!(sim, \"e\" => 1.0) after device claims e", () -> stage!(sim, "e" => 1.0))

# L8a-083: nonfinite x
struct Blowup <: AbstractComponent end
x_init(::Blowup) = (q = 1.0,)
y_types(::Blowup) = (y = Float64,)
y_state(::Blowup, (; x)) = (y = x.q,)
x_deriv(::Blowup, (; x)) = (q = NaN,)
bsim = Simulation(Group((; b = Blowup()); output_wires = ("b/y" => "y",)); Δt_frame = 1//10)
init!(bsim)
show_err("L8a-083 step! with NaN derivative", () -> step!(bsim))

# L8a-090/091/094
println("L8a-090 parentmodule(Group) = ", parentmodule(Group), "; isdefined(Library, :Group) = ", isdefined(Redstone.Library, :Group))
println("L8a-091 Group type params = ", Group.body.body.body.body.body.parameters, " ; fieldnames = ", fieldnames(Group))
fg = Group((; g = PGain(1.0)); input_wires = g -> ("e" => "g/e",))
println("L8a-094 field holds = ", typeof(fg.input_wires), "; input_wires(fg) = ", input_wires(fg))

# L8a-095/098
dep = Deployment(Redstone.build(root); Δt_frame = 1//10)
println("L8a-095 Deployment has schedule: ", typeof(dep.schedule))

# L8a-114: empty sibling container reserves nothing
struct Shadow{K,A} <: AbstractComponent
    kids::K
    aux::A
end
local_wires(::Shadow) = ()
transparent_container(::Shadow) = :kids
show_err("L8a-114 bare key `aux` vs empty sibling container `aux = ()`", () ->
    first.(Redstone.children("", Shadow((; aux = PGain(1.0)), ()))))
show_err("L8a-114 bare key `aux` vs non-empty sibling container", () ->
    first.(Redstone.children("", Shadow((; aux = PGain(1.0)), (PGain(2.0),)))))
