module Probe
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test", "imports.jl"))
include(joinpath(W, "test", "fixtures.jl"))
using Redstone: severity, Diagnostic, DiagnosticError

function show_diags(label, f)
    println("--- ", label)
    try
        f()
        println("  built without error")
    catch err
        if err isa DiagnosticError
            println("  carrier warnings: ", [nameof(typeof(w)) for w in err.warnings])
            for d in (err.carried isa Vector ? err.carried : [err.carried])
                print("  ", nameof(typeof(d)), ": ")
                println(join(("$n=$(repr(getfield(d, n)))" for n in fieldnames(typeof(d))), ", "))
            end
        else
            println("  other: ", typeof(err))
        end
    end
end

# bare producer/consumer
struct BP <: AbstractComponent end
x_init(::BP) = nothing
y_types(::BP) = Float64
y_direct(::BP, _) = 1.0
struct BC <: AbstractComponent end
x_init(::BC) = nothing
u_types(::BC) = Int
y_types(::BC) = Float64
y_direct(::BC, (; u)) = 1.0

show_diags("bare wire mismatch (WireTypeMismatch face names)",
    () -> build(Group((; p = BP(), c = BC()); local_wires = ("p/y" => "c/u",))))
struct BadWires <: AbstractComponent
    p::BP
    c::BC
end
local_wires(::BadWires) = "p/y" => "c/u"
show_diags("bare pair local_wires (IllegalWireEntry)", () -> build(BadWires(BP(), BC())))
struct BadWires2 <: AbstractComponent
    p::BP
    c::BC
end
local_wires(::BadWires2) = ("p/y" => "c/u", 3)
input_wires(::BadWires2) = "abc"
show_diags("not_a_pair / not_a_collection", () -> build(BadWires2(BP(), BC())))
show_diags("child segment alone (UnknownPort port nothing)",
    () -> build(Group((; p = BP(), c = BC()); local_wires = ("p" => "c/u",))))
show_diags("empty input_wires tuple (UnknownPort :connection)",
    () -> build(Group((; p = BP(), c = BC()); local_wires = ("p/y" => "c/u",), input_wires = ("a" => (),))))

struct TwoStage <: AbstractComponent end
x_init(::TwoStage) = (q = 0.0,)
y_types(::TwoStage) = (a = Float64, b = Float64)
y_state(::TwoStage, (; x)) = (a = x.q, b = x.q)
y_direct(::TwoStage, (; x)) = (a = 1.0, b = 2.0)
x_deriv(::TwoStage, (; x)) = (q = 0.0,)
show_diags("ProducedByTwoStages", () -> build(TwoStage()))

struct Miss <: AbstractComponent end
x_init(::Miss) = nothing
y_types(::Miss) = (a = Float64, b = Float64)
y_direct(::Miss, _) = (a = 1.0,)
show_diags("DeclaredNotProduced", () -> build(Miss()))

struct NoClass <: AbstractComponent; kid::Plant; end
show_diags("ClassUnreadable", () -> build(NoClass(Plant())))

struct DeadS <: AbstractComponent end
x_init(::DeadS) = nothing
y_types(::DeadS) = (a = Float64,)
y_direct(::DeadS, _) = (;)
show_diags("DeadStage", () -> build(DeadS()))

struct GF <: AbstractComponent end
x_init(::GF) = (q = 0.0,)
y_types(::GF) = (a = Float64,)
y_state(::GF, (; x)) = (a = x.q,)
x_deriv(::GF, (; x)) = (q = 0.0,)
gf_guard(::GF, (; x)) = 1
gf_handler(::GF, (; x)) = (x = (q = 0.0,),)
Redstone.state_events(::GF) = (e = StateEvent(gf_guard, gf_handler),)
show_diags("GuardForm", () -> build(GF()))

struct ES <: AbstractComponent end
x_init(::ES) = (;)
y_types(::ES) = (a = Float64,)
y_direct(::ES, _) = (a = 1.0,)
show_diags("EmptyStore", () -> build(ES()))

# the passthrough warning rides the Build
struct Kid <: AbstractComponent end
x_init(::Kid) = nothing
u_types(::Kid) = (a = Float64,)
y_types(::Kid) = (b = Float64,)
y_direct(::Kid, (; u)) = (b = u.a,)
struct Outer <: AbstractComponent
    kid::Kid
end
local_wires(::Outer) = ()
input_wires(c::Outer) = input_passthrough(c, "kid"; except = ("a",))
output_wires(c::Outer) = output_passthrough(c, "kid")
show_diags("EmptyFaceSelection (warning on the Build)", () -> (b = build(Outer(Kid())); println("  warnings: ", [nameof(typeof(w)) for w in warnings(b)])))

println("--- severity methods")
for m in methods(severity)
    println("  ", m.sig)
end

end
