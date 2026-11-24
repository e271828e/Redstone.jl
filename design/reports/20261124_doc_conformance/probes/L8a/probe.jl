# L8a probe: log.md D-039..D-215 Position claims not settled by a test line.
using Redstone
import Redstone: AbstractComponent, x_init, u_types, y_types, y_direct, y_state, x_deriv,
    local_wires, input_wires, output_wires, Group, build, DiagnosticError, diagnostics,
    classify, ASSEMBLY, ClassUnreadable, UnknownPort, combine, set, ConditionNodeMisuse,
    input_passthrough, UnknownFaceSelection

failure(f) = try f(); nothing catch e; e end
ds(e) = e isa DiagnosticError ? (e.carried isa Vector ? e.carried : [e.carried]) : [e]

struct G1 <: AbstractComponent; k::Float64; end
x_init(::G1) = nothing
u_types(::G1) = (e = Float64,)
y_types(::G1) = (out = Float64,)
y_direct(c::G1, (; u)) = (out = c.k * u.e,)

# D-039: an assembly with empty local_wires classifies as an assembly
struct EmptyAsm <: AbstractComponent; a::G1; end
local_wires(::EmptyAsm) = ()
println("P1 classify empty local_wires: ", classify("", EmptyAsm(G1(1.0))))
# D-039/D-164: neither family -> ClassUnreadable naming both families
struct Nothing2 <: AbstractComponent; k::Float64; end
e = failure(() -> classify("c", Nothing2(1.0)))
println("P2 neither: ", typeof(e), " ", e isa DiagnosticError ? (only(ds(e)).assembly_family, only(ds(e)).leaf_family) : "")

# D-041: local_wires strictly child-to-child: a local wire naming a face (no slash) as source
e = failure(() -> build(Group((; a = G1(1.0), b = G1(2.0)); local_wires = ("in" => "b/e",),
                              input_wires = ("x" => "a/e",))))
println("P3 local wire from non-child: ", e === nothing ? "built" : [typeof(d) for d in ds(e)])
println("P3b messages: ", e === nothing ? "" : [Redstone.message(d) for d in ds(e)])

# D-113: typo'd source port is UnknownPort at the source end
e = failure(() -> build(Group((; a = G1(1.0), b = G1(2.0)); local_wires = ("a/outt" => "b/e",),
                              input_wires = ("x" => "a/e",))))
println("P4 typo source: ", [(typeof(d), d isa UnknownPort ? (d.endpoint, d.path, d.candidates) : nothing) for d in ds(e)])

# D-117: qualified definition (`Redstone.y_direct(...) = ...`) declares as an import would
struct Q1 <: AbstractComponent end
Redstone.x_init(::Q1) = nothing
Redstone.u_types(::Q1) = (e = Float64,)
Redstone.y_types(::Q1) = (out = Float64,)
Redstone.y_direct(::Q1, (; u)) = (out = 2u.e,)
println("P5 qualified definition builds: ", build(Group((; q = Q1()); input_wires = ("x" => "q/e",))) isa Redstone.Build)

# D-113: combine of a node and a NamedTuple -> ConditionNodeMisuse, type and node kinds in hand
e = failure(() -> combine(set(x = (; a = 1.0)), (; q = 1.0)))
d = only(ds(e)) ; println("P6 combine misuse: ", typeof(d), " ", d.observed, " ", d.in_hand)

# D-046/D-209: dot-prefix default for passthrough labels
g = Group((; aircraft = G1(1.0)))
println("P7 input_passthrough default: ", input_passthrough(g, "aircraft"))
println("P7b output_passthrough default: ", Redstone.output_passthrough(g, "aircraft"))
# D-113: both selectors
e = failure(() -> input_passthrough(g, "aircraft"; except = ("e",), only = ("e",)))
d = only(ds(e)); println("P8 both selectors: ", typeof(d), " ", d.reason)

# D-210: empty tuple routing
e = failure(() -> build(Group((; a = G1(1.0)); input_wires = ("x" => "a/e", "dead" => ()))))
println("P9 empty routing: ", [(typeof(d), d isa UnknownPort ? d.endpoint : nothing) for d in ds(e)])

# D-046: face name uniqueness across input and output wires, and a non-empty face name
e = failure(() -> build(Group((; a = G1(1.0)); input_wires = ("" => "a/e",))))
println("P10 empty face: ", [(typeof(d), getfield(d, :invariant)) for d in ds(e) if d isa Redstone.FaceNameIllegal])

# D-041: direction declared by method: an input_wires entry routed to an output port
e = failure(() -> build(Group((; a = G1(1.0)); input_wires = ("x" => "a/out",))))
println("P11 input face onto output port: ", [typeof(d) for d in ds(e)])
