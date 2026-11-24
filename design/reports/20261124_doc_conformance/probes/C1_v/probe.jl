# C1 verifier probes, run from the pinned worktree with --project=test.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
include(joinpath(pwd(), "test", "imports.jl"))
include(joinpath(pwd(), "test", "fixtures.jl"))
include(joinpath(pwd(), "test", "utils.jl"))

show_err(tag, err) = println(tag, " => ", typeof(err),
    err isa DiagnosticError ? string(" structure=", typeof(err.structure),
        err.carried isa Vector ? string(" kinds=", kinds(err)) : "") : "")

# P1 (C1-047, C1-122): kinds of the "Declaration and wiring" group raised past the structure step.
struct NoProbe{T}; a::T; end
struct NeedsNoProbe <: AbstractComponent end
x_init(::NeedsNoProbe) = nothing
u_types(::NeedsNoProbe) = (q = NoProbe{Float64},)
y_types(::NeedsNoProbe) = (out = Float64,)
y_direct(::NeedsNoProbe, (; u)) = (out = 0.0,)
err = failure(() -> build(Group((; c = NeedsNoProbe()); input_wires = ("in" => "c/q",))))
show_err("P1a MissingProbeValue", err)

struct SymIn <: AbstractComponent end
x_init(::SymIn) = nothing
u_types(::SymIn) = (q = Symbol,)
y_types(::SymIn) = (out = Float64,)
y_direct(::SymIn, (; u)) = (out = 0.0,)
err = failure(() -> build(Group((; c = SymIn()); input_wires = ("in" => "c/q",))))
show_err("P1b handle_at_root", err)
err isa DiagnosticError && println("P1b payload: ", only(diagnostics(err)))

struct ProjNoState <: AbstractComponent end
x_init(::ProjNoState) = nothing
y_types(::ProjNoState) = (out = Float64,)
y_state(::ProjNoState, _) = (out = 0.0,)
x_projection(::ProjNoState, x) = x
err = failure(() -> build(single(ProjNoState())))
show_err("P1c no_manifold", err)
err isa DiagnosticError && println("P1c payload: ", diagnostics(err))

# P2 (C1-058): the handed chain, innermost first.
struct Inner2 <: AbstractComponent; g::Gain; end
local_wires(::Inner2) = ()
input_wires(::Inner2) = ("ie" => "g/e",)
output_wires(::Inner2) = ("g/out" => "io",)
struct Outer2 <: AbstractComponent; k::Inner2; end
local_wires(::Outer2) = ()
input_wires(::Outer2) = ("oe" => "k/ie",)
output_wires(::Outer2) = ("k/io" => "oo",)
err = failure(() -> build(Group((; m = Outer2(Inner2(Gain(1.0)))))))
show_err("P2 UnconnectedInput", err)
err isa DiagnosticError && println("P2 payload: ", diagnostics(err))

# P3 (C1-065): WireTypeMismatch over bare contracts on both sides.
struct BareIntOut <: AbstractComponent end
x_init(::BareIntOut) = nothing
y_types(::BareIntOut) = Int
y_state(::BareIntOut, _) = 0
struct BareBoolIn <: AbstractComponent end
x_init(::BareBoolIn) = nothing
u_types(::BareBoolIn) = Bool
y_types(::BareBoolIn) = (out = Float64,)
y_direct(::BareBoolIn, (; u)) = (out = 0.0,)
err = failure(() -> build(Group((; p = BareIntOut(), c = BareBoolIn()); local_wires = ("p/y" => "c/u",))))
show_err("P3 WireTypeMismatch", err)
err isa DiagnosticError && (d = only(diagnostics(err)); println("P3 face=", repr(d.face), " producer_port=", repr(d.producer_port)))

# P4 (C1-086): Pinned and unpinned consumers of one root input.
r = failure(() -> build(Group((; a = PinnedGain(), b = Gain(1.0)); input_wires = ("e" => ("a/e", "b/e"),))))
println("P4 tolerance mix => ", r === nothing ? "built" : typeof(r))

# P5 (C1-131): a primitive root, bare u_types and a named `u` output.
struct RootClash <: AbstractComponent end
x_init(::RootClash) = nothing
u_types(::RootClash) = Float64
y_types(::RootClash) = (u = Float64,)
y_direct(::RootClash, (; u)) = (u = u,)
err = failure(() -> build(RootClash()))
show_err("P5 FaceNameCollision", err)
err isa DiagnosticError && println("P5 payload: ", diagnostics(err))

# P6 (C1-205, C1-209): two ports written twice; two ports never produced.
struct TwiceTwo <: AbstractComponent end
x_init(::TwiceTwo) = (q = 0.0,)
u_types(::TwiceTwo) = (e = Float64,)
y_types(::TwiceTwo) = (a = Float64, b = Float64)
y_state(::TwiceTwo, (; x)) = (a = x.q, b = x.q)
y_direct(::TwiceTwo, (; u)) = (a = u.e, b = u.e)
x_deriv(::TwiceTwo, _) = (q = 0.0,)
err = failure(() -> build(fed(TwiceTwo(), "e")))
show_err("P6a ProducedByTwoStages", err)
err isa DiagnosticError && println("P6a payload: ", err.carried)
struct Unproduced <: AbstractComponent end
x_init(::Unproduced) = (q = 0.0,)
y_types(::Unproduced) = (a = Float64, b = Float64, c = Float64)
y_state(::Unproduced, (; x)) = (c = x.q,)
x_deriv(::Unproduced, _) = (q = 0.0,)
err = failure(() -> build(single(Unproduced())))
show_err("P6b DeclaredNotProduced", err)
err isa DiagnosticError && println("P6b payload: ", diagnostics(err))

# P7 (C1-011, C1-232): BundleFieldError at the probe, fail-fast.
struct ReadsM <: AbstractComponent end
x_init(::ReadsM) = (q = 0.0,)
y_types(::ReadsM) = (out = Float64,)
y_state(::ReadsM, (; x)) = (out = x.q,)
x_deriv(::ReadsM, (; m)) = (q = 0.0,)
err = failure(() -> build(single(ReadsM())))
show_err("P7 BundleFieldError", err)
err isa DiagnosticError && println("P7 payload: ", err.carried, " severity=", severity(err.carried))
