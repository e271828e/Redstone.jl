# S8a independent verification probes. Run from the pinned worktree:
#   JULIA_LOAD_PATH="@" julia --startup-file=no --project=test <this file>
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools, Test
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test", "imports.jl"))
include(joinpath(W, "test", "fixtures.jl"))
include(joinpath(W, "test", "utils.jl"))

show_err(f) = try
    f(); "no throw"
catch e
    e isa DiagnosticError ? sprint(showerror, e) : "OTHER: " * sprint(showerror, e)
end

# S8a-001: stage functions are generic functions extended by ordinary methods.
println("P001 y_state generic: ", typeof(Redstone.y_state) <: Function, " methods=",
        length(methods(Redstone.y_state)), " y_direct methods=", length(methods(Redstone.y_direct)))

# S8a-039: the DeclarationShadowed message, at a child path and at the root.
println("P039 child: ", show_err(() -> build(single(ForgottenImport.Update.Leaf()))))
println("P039 root:  ", show_err(() -> build(ForgottenImport.Inventory.Leaf())))

# S8a-034: the check runs before class reading, on a child as well as the root.
println("P034 passthrough child: ",
        show_err(() -> build(PassthroughOverForgotten(ForgottenImport.Inventory.Leaf()))))

# S8a-045: a declaration bound inside a `let` leaves no module binding to find.
module LocalCase
import Redstone
import Redstone: AbstractComponent
struct C <: AbstractComponent end
let
    y_types(::C) = (y = Float64,)
    x_init(::C) = nothing
    y_state(::C, _) = (y = 1.0,)
    global local_y = y_state(C(), nothing)
end
end
println("P045 local call: ", LocalCase.local_y, " foreign=",
        Redstone.foreign_declarations(LocalCase.C()))
println("P045 build: ", show_err(() -> build(single(LocalCase.C()))))

# S8a-082: a bare one-leaf store builds and runs; S8a-092: `nothing` declares a stateless primitive.
module BareCase
import Redstone: AbstractComponent, x_init, y_types, y_state, x_deriv
struct BareInt <: AbstractComponent
    x0::Float64
end
x_init(c::BareInt) = c.x0
y_types(::BareInt) = (y = Float64,)
y_state(::BareInt, (; x)) = (y = x,)
x_deriv(::BareInt, (; x)) = -x
struct Stateless <: AbstractComponent end
x_init(::Stateless) = nothing
y_types(::Stateless) = (y = Float64,)
y_state(::Stateless, _) = (y = 2.0,)
end
let sim = Simulation(single(BareCase.BareInt(1.0)); Δt_frame = 1//100)
    init!(sim); run!(sim; t_end = 0.1)
    println("P082 bare state: ", state(sim, "c"), " port y=", port(sim, "c", :y))
end
let sim = Simulation(single(BareCase.Stateless()); Δt_frame = 1//100)
    init!(sim); run!(sim; t_end = 0.02)
    println("P092 stateless continuous y=", port(sim, "c", :y))
end
let m = build(Group((; c = DiscreteMap()); input_wires = ("a" => "c/a",)))
    println("P092 stateless discrete builds: ", typeof(m))
end

# S8a-112: the workspace-plus-snapshot idiom (Smoother) ticks allocation-free with an isbits `s`.
let sim = Simulation(Group((; sm = Smoother(0.5), src = ModedSource());
                           local_wires = ("src/out" => "sm/a", "src/out" => "sm/b"));
                     Δt_frame = 1//10)
    init!(sim); run!(sim; t_end = 0.3)
    s = state(sim, "sm")
    println("P112 s: ", typeof(s), " isbits=", isbitstype(typeof(s)))
    bodies = phase_bodies(sim)
    body = bodies.ticks
    body(); body(1)
    println("P112 ticks alloc: ", @ballocated($body()), " / ", @ballocated($body(1)))
end
