module CV9aProbe
using Test, StaticArrays, ForwardDiff
using Redstone
import Redstone: AbstractComponent, Group, StateEvent, DiagnosticError, ProbeDual, build, Deployment,
    x_init, s_init, u_types, y_types, y_state, y_direct, x_deriv, x_projection, state_events, port
using Redstone: Model
include("/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/imports.jl")

cl(err) = err.carried isa Redstone.Diagnostic ? [err.carried] : err.carried
function kinds(f)
    try
        f(); println("   no throw")
    catch err
        if err isa DiagnosticError
            println("   carried: ", [(nameof(typeof(d)), hasproperty(d, :reason) ? d.reason : nothing) for d in cl(err)])
        else
            println("   other: ", typeof(err), " ", sprint(showerror, err)[1:min(end,200)])
        end
    end
end

# 1. nameless port at an assembly exporting `y`
struct Ramp <: AbstractComponent end
x_init(::Ramp) = 0.0
y_types(::Ramp) = Float64
y_state(::Ramp, (; x)) = x
x_deriv(::Ramp, _) = 1.0
println("P1 nameless port at assembly exporting y")
try
    w = Group((; r = Ramp()); output_wires = ("r/y" => "y",))
    dep = Deployment(build(w); Δt_frame = 1//100, Δt_base = 1//100)
    m = Model(dep, Float64)
    println("  prim nameless: ", port(m, "r"))
    println("  asm nameless: ", port(m, ""))
catch err
    println("  threw ", typeof(err), " ", first(sprint(showerror, err), 250))
end
println("P1b unknown path")
try
    w = Group((; r = Ramp()); output_wires = ("r/y" => "y",))
    dep = Deployment(build(w); Δt_frame = 1//100, Δt_base = 1//100)
    m = Model(dep, Float64)
    port(m, "rr")
catch err
    println("  threw ", typeof(err), " ", err isa DiagnosticError ? [(typeof(d), hasproperty(d,:reason) ? d.reason : nothing) for d in cl(err)] : "")
end

# 2. x_projection probed at Dual
const SEEN = DataType[]
struct Proj <: AbstractComponent end
x_init(::Proj) = (r = SVector(1.0, 0.0),)
y_types(::Proj) = (c = Float64,)
y_state(::Proj, (; x)) = (c = x.r[1],)
x_deriv(::Proj, (; x)) = (r = SVector(0.0, 0.0),)
x_projection(::Proj, x) = (push!(SEEN, eltype(x.r)); x)
println("P2 x_projection probed at Dual")
build(Group((; p = Proj())); activations = (Float64, ProbeDual))
println("  scalars seen: ", unique(SEEN))

# 3. update pass: two components each returning a non-NamedTuple derivative
struct BadD1 <: AbstractComponent end
x_init(::BadD1) = (a = 1.0,)
y_types(::BadD1) = (y = Float64,)
y_state(::BadD1, (; x)) = (y = x.a,)
x_deriv(::BadD1, _) = 1.0
struct BadD2 <: AbstractComponent end
x_init(::BadD2) = (a = 1.0,)
y_types(::BadD2) = (y = Float64,)
y_state(::BadD2, (; x)) = (y = x.a,)
x_deriv(::BadD2, _) = (b = 1.0,)
println("P3 update pass: one non-NT return, one wrong field set")
kinds(() -> build(Group((; a = BadD1(), b = BadD2()))))

# 4. stage 1 non-NT for named outs, two components
struct BadS <: AbstractComponent end
x_init(::BadS) = (a = 1.0,)
y_types(::BadS) = (y = Float64,)
y_state(::BadS, (; x)) = 1.0
x_deriv(::BadS, _) = (a = 1.0,)
println("P4 stage-1 non-NT return, two components")
kinds(() -> build(Group((; a = BadS(), b = BadS()))))

# 5. completeness before update
struct Miss <: AbstractComponent end
x_init(::Miss) = (a = 1.0,)
y_types(::Miss) = (y = Float64, z = Float64)
y_state(::Miss, (; x)) = (y = x.a,)
x_deriv(::Miss, _) = 1.0
println("P5 missing port beside bad x_deriv")
kinds(() -> build(Group((; a = Miss()))))

# 6. EventHalfMissing
struct Proj2 <: AbstractComponent end
g_only(::Proj2, _) = 1.0
x_init(::Proj2) = (a = 1.0,)
x_deriv(::Proj2, _) = (a = 1.0,)
y_types(::Proj2) = (y = Float64,)
y_state(::Proj2, (; x)) = (y = x.a,)
h_missing(::Proj2, _) = (;)
state_events(::Proj2) = (e1 = StateEvent(g_only, h_missing), e2 = StateEvent(nothing, nothing), e3 = 5)
println("P6 EventHalfMissing")
try
    kinds(() -> build(Group((; a = Proj2()))))
catch err
    println(" ", err)
end
function onlyguard end
struct Proj3 <: AbstractComponent end
x_init(::Proj3) = (a = 1.0,)
x_deriv(::Proj3, _) = (a = 1.0,)
y_types(::Proj3) = (y = Float64,)
y_state(::Proj3, (; x)) = (y = x.a,)
g3(::Proj3, _) = 1.0
function nohandler end
state_events(::Proj3) = (e1 = StateEvent(g3, nohandler), e3 = 5)
println("P6b")
kinds(() -> build(Group((; a = Proj3()))))

# 7. MissingProbeValue and IllegalPortType leafless / handle
struct NoDef; a::Float64; NoDef(a) = new(a); end
struct UsesNoDef <: AbstractComponent end
x_init(::UsesNoDef) = nothing
u_types(::UsesNoDef) = (c = NoDef,)
y_types(::UsesNoDef) = (y = Float64,)
y_direct(::UsesNoDef, (; u)) = (y = u.c.a,)
println("P7 MissingProbeValue")
kinds(() -> build(Group((; a = UsesNoDef()); input_wires = ("c" => "a/c",))))

# 8. guard returning wrong form
struct G4 <: AbstractComponent end
x_init(::G4) = (a = 1.0,)
x_deriv(::G4, _) = (a = 1.0,)
y_types(::G4) = (y = Float64,)
y_state(::G4, (; x)) = (y = x.a,)
g4(::G4, _) = 1
h4(::G4, _) = (;)
state_events(::G4) = (e = StateEvent(g4, h4),)
println("P8 GuardForm")
kinds(() -> build(Group((; a = G4()))))

# 9. handler bad key
struct H5 <: AbstractComponent end
x_init(::H5) = (a = 1.0,)
x_deriv(::H5, _) = (a = 1.0,)
y_types(::H5) = (y = Float64,)
y_state(::H5, (; x)) = (y = x.a,)
g5(::H5, _) = true
h5(::H5, _) = (q = 1.0, m = 2.0)
state_events(::H5) = (e = StateEvent(g5, h5),)
println("P9 HandlerReturnKey")
kinds(() -> build(Group((; a = H5()))))

# 10. warnings channel and structure on late throw
println("P10 late throw carries structure")
try build(Group((; a = Miss()))) catch err; println("  structure: ", err.structure === nothing ? nothing : typeof(err.structure)); end
try build(Group((; a = Ramp())); activations = (Int,)) catch err; println("  Int activation: ", typeof(err), " ", first(sprint(showerror, err), 200)); end

# 11. root input cell before init!
struct Sc <: AbstractComponent end
x_init(::Sc) = nothing
u_types(::Sc) = Float64
y_types(::Sc) = Float64
y_direct(::Sc, (; u)) = -2.0 * u
println("P11 root input cell before init!")
try
    w = Group((; c = Sc()); input_wires = ("in" => "c/u",))
    m = Model(Deployment(build(w); Δt_frame = 1//100, Δt_base = 1//100), Float64)
    println("  root input: ", port(m, "", :in), "  out: ", port(m, "c"))
catch err
    println("  threw ", typeof(err), " ", first(sprint(showerror, err), 200))
end
end
