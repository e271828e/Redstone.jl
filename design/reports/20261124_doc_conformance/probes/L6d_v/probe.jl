# L6d_v verifier probe. Run from the pinned worktree with --project=test.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
include(joinpath(pwd(), "test", "imports.jl"))

function show_err(label, f)
    try
        r = f()
        println(label, " => OK: ", r)
    catch err
        if err isa DiagnosticError
            println(label, " => ", typeof(err), " :: ", sprint(showerror, err)[1:min(end, 300)])
        else
            println(label, " => ", typeof(err), " :: ", sprint(showerror, err)[1:min(end, 300)])
        end
    end
end

# --- components ---------------------------------------------------------------
struct PSrc <: AbstractComponent end
x_init(::PSrc) = nothing
y_types(::PSrc) = (y = Float64,)
y_state(::PSrc, _) = (y = 1.0,)

struct PSink <: AbstractComponent end
x_init(::PSink) = nothing
u_types(::PSink) = (a = Float64,)
y_types(::PSink) = (z = Float64,)
y_direct(::PSink, (; u)) = (z = u.a,)

struct PTick <: AbstractComponent end
s_init(::PTick) = (n = 0,)
y_types(::PTick) = (n = Int,)
y_state(::PTick, (; s)) = (n = s.n,)
s_update(::PTick, (; s)) = (n = s.n + 1,)

struct PBareEmpty <: AbstractComponent end
x_init(::PBareEmpty) = nothing
y_types(::PBareEmpty) = Float64
y_state(::PBareEmpty, _) = (;)

struct PNamedEmpty <: AbstractComponent end
x_init(::PNamedEmpty) = nothing
y_types(::PNamedEmpty) = (y = Float64,)
y_state(::PNamedEmpty, _) = (;)

struct PNamedScalar <: AbstractComponent end
x_init(::PNamedScalar) = nothing
y_types(::PNamedScalar) = (y = Float64,)
y_state(::PNamedScalar, _) = 1.0

struct PBareValue <: AbstractComponent end
x_init(::PBareValue) = nothing
y_types(::PBareValue) = Float64
y_state(::PBareValue, _) = 2.0

struct PKw <: AbstractComponent end
x_init(::PKw) = nothing
y_types(::PKw) = (y = Float64,)
y_state(::PKw; kw...) = (y = 1.0,)

struct PWs <: AbstractComponent end
x_init(::PWs) = nothing
ws_init(::PWs, ::Type{T}) where {T} = (buf = zeros(T, 2),)
y_types(::PWs) = (y = Float64,)
y_state(::PWs, (; ws)) = (y = 1.0,)

struct PNoWs <: AbstractComponent end
x_init(::PNoWs) = nothing
y_types(::PNoWs) = (y = Float64,)
y_state(::PNoWs, _) = (y = 1.0,)

@enum PColor PRED PGREEN
struct PMade
    a::Int
end
PMade() = PMade(7)

println("== names (decl drift checks)")
for n in (:faces, :passthrough, :input_passthrough, :output_passthrough, :Merged, :Combined, :Override,
          :merge, :combine, :input_connections, :output_connections, :child_connections,
          :input_wires, :output_wires, :local_wires, :output_types, :input_types, :u_types, :y_types,
          :output_state, :y_state, :RootSlotTypeConflict, :RootInputTypeConflict, :Dataflow, :Outputs,
          :stop_on, :StopFlag, :Period, :Hz, :Blocks, :Library, :sweep_hx)
    println("  isdefined(Redstone, :$n) = ", isdefined(Redstone, n))
end
println("  Library: LinearSystem=", isdefined(Redstone.Library, :LinearSystem),
        " AbstractLinearSystem=", isdefined(Redstone.Library, :AbstractLinearSystem),
        " AntiWindupController=", isdefined(Redstone.Library, :AntiWindupController),
        " PIDController=", isdefined(Redstone.Library, :PIDController))
println("  phase body names: ", keys(phase_bodies(Simulation(Group((; t = PTick())); Δt_frame = 1//10))))

println("== L6d-001: two wires into one input")
show_err("fan-in", () -> build(Group((; a = PSrc(), b = PSrc(), k = PSink());
                                     local_wires = ("a/y" => "k/a", "b/y" => "k/a"))))

println("== L6d-011: probe_value chain")
println("  Float64 ", probe_value(Float64), " Bool ", probe_value(Bool), " enum ", probe_value(PColor),
        " SVector ", probe_value(SVector{2,Float64}), " T() ", probe_value(PMade))

println("== L6d-039: Constant")
println("  y_types(Constant(1.0)) = ", y_types(Constant(1.0)))

println("== L6d-022: unexported face unwritable")
g22 = Group((; a = PSrc(), k = PSink()); local_wires = ("a/y" => "k/a",))
s22 = Simulation(g22; Δt_frame = 1//10)
show_err("internally wired u", () -> init!(s22, at("k", set(u = (a = 3.0,)))))
g22b = Group((; k = PSink()); input_wires = ("ext" => "k/a",))
s22b = Simulation(g22b; Δt_frame = 1//10)
show_err("exported u via at", () -> (init!(s22b, at("k", set(u = (a = 3.0,)))); port(s22b, "", :ext)))

println("== L6d-024: deep at into nested child")
g24 = Group((; inner = Group((; t = PTick()))))
s24 = Simulation(g24; Δt_frame = 1//10)
show_err("deep at", () -> (init!(s24, at("inner/t", set(s = (n = 5,)))); state(s24, "inner/t")))

println("== L6d-091/066: boundary zero with phased tick")
g91 = Group((; p0 = PTick(), p1 = PTick()); sample_times = (; p0 = Relative(2, 0), p1 = Relative(2, 1)))
s91 = Simulation(g91; Δt_frame = 1//10)
init!(s91)
println("  after init!: p0 port n=", port(s91, "p0", :n), " state n=", state(s91, "p0").n,
        "; p1 port n=", port(s91, "p1", :n), " state n=", state(s91, "p1").n)

println("== L6d-147: ticks body in isolation")
s147 = Simulation(Group((; t = PTick())); Δt_frame = 1//10)
init!(s147)
t_before = latest(s147).t; n_before = state(s147, "t").n
b147 = phase_bodies(s147)
b147.ticks(0)
println("  state n before=", n_before, " after ticks(0)=", state(s147, "t").n,
        " clock t=", s147.model.exec.clock.t, " (before ", t_before, ")")
show_err("step! after isolated ticks", () -> (step!(s147); (port(s147, "t", :n), state(s147, "t").n)))

println("== L6d-125/126: stage return shapes")
show_err("named, returns scalar", () -> build(PNamedScalar()))
show_err("named, returns (;)", () -> build(PNamedEmpty()))
show_err("bare, returns (;)", () -> build(PBareEmpty()))
show_err("bare, returns value", () -> (b = build(PBareValue()); :built))

println("== L6d-182: keyword slurping stage")
println("  has_stage(y_state, PKw()) = ", has_stage(y_state, PKw()))
show_err("build kw-slurping", () -> build(PKw()))

println("== L6d-173: ws iff ws_init")
println("  PWs y_state bundle: ", bundle_names(y_state, PWs(), CONTINUOUS, ()))
println("  PNoWs y_state bundle: ", bundle_names(y_state, PNoWs(), CONTINUOUS, ()))
println("  PTick s_update bundle: ", bundle_names(s_update, PTick(), DISCRETE, ()))

println("== L6d-103/107: primitive root")
show_err("primitive root inputs", () -> build(PSink()).structure.root_inputs)
show_err("assembly root inputs", () -> build(g22b).structure.root_inputs)
