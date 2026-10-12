# §4.3's sketch (spec 577–583) run against the package, with the struct
# definitions, state and stages it implies; plus §4.3's port-holding claims.
using Redstone, StaticArrays
include(joinpath(@__DIR__, "..", "..", "..", "..", "test", "imports.jl"))
import Redstone: StopFlag

struct KinPose{T}; p::SVector{3,T}; q_eb::SVector{4,T}; end   # stand-in
struct RQuat{T}; v::SVector{4,T}; end                          # stand-in, isbits

struct Kinematics <: AbstractComponent end
x_init(::Kinematics) = (p = zeros(SVector{3}), q = SVector{4}(1.0, 0, 0, 0))
x_deriv(::Kinematics, (; x)) = (p = zeros(SVector{3}), q = zeros(SVector{4}))
# the block's declaration, verbatim
y_types(::Kinematics) = (pose = KinPose{Float64}, q_eb = RQuat{Float64})
y_state(::Kinematics, (; x)) = (pose = KinPose(x.p, x.q), q_eb = RQuat(x.q))

struct Vehicle <: AbstractComponent; kin::Kinematics; end
local_wires(::Vehicle) = ()
# the block's declaration, verbatim
output_wires(::Vehicle) = ("kin/pose" => "pose", "kin/q_eb" => "q_eb")

kinds(e) = e isa DiagnosticError ? (e.carried isa AbstractVector ? [typeof(d) for d in e.carried] : typeof(e.carried)) : typeof(e)
report(label, f) = try r = f(); println(label, " → ok: ", r) catch e; println(label, " → ", typeof(e), " ", try kinds(e) catch; "" end) end

b = build(Vehicle(Kinematics()))
println("built: ", typeof(b))
sim = Simulation(Vehicle(Kinematics()); h = 1//100)
init!(sim)
snap = latest(sim)
report("cell kin.pose", () -> port(snap, "kin", :pose))
report("cell kin.q_eb", () -> port(snap, "kin", :q_eb))


# "Bare-struct returns are rejected" (D-036)
struct Bare <: AbstractComponent end
x_init(::Bare) = (a = 0.0,)
x_deriv(::Bare, (; x)) = (a = 0.0,)
y_types(::Bare) = (pose = KinPose{Float64},)
y_state(::Bare, (; x)) = KinPose(zeros(SVector{3}), SVector{4}(1.0, 0, 0, 0))
report("bare-struct return", () -> build(Bare()))

# "Name collisions across a component's stages are a build error"
struct Both <: AbstractComponent end
x_init(::Both) = (a = 0.0,)
x_deriv(::Both, (; x)) = (a = 0.0,)
u_types(::Both) = (e = Float64,)
y_types(::Both) = (o = Float64,)
y_state(::Both, (; x)) = (o = x.a,)
y_direct(::Both, (; x, u)) = (o = u.e,)
report("same port from both stages", () -> build(Both()))

# "a stage result outside the contract is a build error" (§4.2)
struct Extra <: AbstractComponent end
x_init(::Extra) = (a = 0.0,)
x_deriv(::Extra, (; x)) = (a = 0.0,)
y_types(::Extra) = (o = Float64,)
y_state(::Extra, (; x)) = (o = x.a, w = 1.0)
report("undeclared return field", () -> build(Extra()))

# "A mutable type anywhere in a port value is refused"
mutable struct Cache; v::Float64; end
struct Mut <: AbstractComponent end
x_init(::Mut) = (a = 0.0,)
x_deriv(::Mut, (; x)) = (a = 0.0,)
y_types(::Mut) = (c = Cache,)
y_state(::Mut, (; x)) = (c = Cache(0.0),)
report("mutable port type", () -> build(Mut()))

# "a StopFlag nested in a port of another type ... is refused"
struct Wrap; f::StopFlag; end
struct Nest <: AbstractComponent end
x_init(::Nest) = (a = 0.0,)
x_deriv(::Nest, (; x)) = (a = 0.0,)
y_types(::Nest) = (w = Wrap,)
y_state(::Nest, (; x)) = (w = Wrap(Redstone.NO_STOP),)
report("nested StopFlag", () -> build(Nest()))

# "A Symbol is an opaque leaf too ... a Symbol mode publishes like any other"
struct Sym <: AbstractComponent end
x_init(::Sym) = (a = 0.0,)
m_init(::Sym) = (mode = :idle,)
x_deriv(::Sym, (; x)) = (a = 0.0,)
y_types(::Sym) = (mode = Symbol,)
y_state(::Sym, (; m)) = (mode = m.mode,)
report("Symbol mode port", () -> build(Sym()))
