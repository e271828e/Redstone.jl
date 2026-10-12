# Chapter 6 survey probes: run the chapter's code blocks, and the claims beside
# them, against the package. Run from the repository root:
#   julia --project=test docs/spec_rewrite/ch06/scratch_survey/probe.jl
include(joinpath(@__DIR__, "..", "..", "..", "..", "test", "repl.jl"))
using Redstone.Blocks: Junction, SumJunction, Constant, Freeze

kinds(f) = try f(); "builds" catch err
    err isa DiagnosticError ? join(sort(unique(string(nameof(typeof(d))) for d in diagnostics(err))), ", ") * " :: " *
        join((Redstone.message(d) for d in diagnostics(err)), " | ") : sprint(showerror, err) end
say(label, r) = println("PROBE ", rpad(label, 58), " => ", first(r, 700))

# ---- a parametric wrench, as §6.2 writes it (Wrench{Float64}) ----------------
struct Wrench{T <: Real}
    F::SVector{3, T}
    τ::SVector{3, T}
end
Wrench() = Wrench(zeros(SVector{3}), zeros(SVector{3}))
Base.:+(a::Wrench, b::Wrench) = Wrench(a.F + b.F, a.τ + b.τ)

# a walking contributor: continuous state, publishes a wrench
struct Contrib <: AbstractComponent
    k::Float64
end
x_init(::Contrib) = (q = 0.0,)
x_deriv(c::Contrib, (; x)) = (q = c.k,)
y_types(::Contrib) = (wrench = Wrench{Float64},)
y_state(c::Contrib, (; x)) = (wrench = Wrench(SVector(c.k + x.q, zero(x.q), zero(x.q)), SVector(zero(x.q), zero(x.q), zero(x.q))),)

# a promoting consumer of the total
struct Dyn <: AbstractComponent end
x_init(::Dyn) = (v = 0.0,)
u_types(::Dyn) = (wr_ext = Wrench{Float64},)
y_types(::Dyn) = (v = Float64,)
y_state(::Dyn, (; x)) = (v = x.v,)
x_deriv(::Dyn, (; u)) = (v = u.wr_ext.F[1],)

# ---- block 2 (1373–1384), verbatim, in its own module -----------------------
module Verbatim
import Redstone: AbstractComponent, x_init, u_types, y_types, y_direct
struct Junction{In, Out, N, F} <: AbstractComponent   # library-provided (§13.7)
    f::F                              # the fold, N-ary; instance data
end
const SumJunction{V, N} = Junction{V, V, N, typeof(+)}

x_init(::Junction) = (;)              # stateless, continuous: the empty store is the tier marker (§8.2)
u_types(::Junction{In, Out, N}) where {In, Out, N} =
    NamedTuple{ntuple(i -> Symbol(:in, i), N)}(ntuple(_ -> In, N))
y_types(::Junction{In, Out}) where {In, Out} = (out = Out,)
y_direct(j::Junction, (; u)) = (out = j.f(u...),)
end

# ---- block 3 (1403–1410): Systems with the verbatim local_wires --------------
struct Systems{J} <: AbstractComponent
    aero::Contrib
    pwp::Contrib
    ldg::Contrib
    wr_sum::J
    dynamics::Dyn
end
local_wires(::Systems) = (
    "aero/wrench" => "wr_sum/in1",
    "pwp/wrench"  => "wr_sum/in2",
    "ldg/wrench"  => "wr_sum/in3",
    "wr_sum/out"  => "dynamics/wr_ext",
)
sysof(j) = Systems(Contrib(1.0), Contrib(10.0), Contrib(100.0), j, Dyn())

function run_sum(sys)
    sim = Simulation(sys; h = 1//100)
    init!(sim, fragment())
    step!(sim; t_plus = 2//100)
    (port(sim, "wr_sum", :out), port(sim, "aero", :wrench) + port(sim, "pwp", :wrench) + port(sim, "ldg", :wrench))
end

println("== block 2 and block 3")
say("verbatim Junction, SumJunction{Wrench{Float64},3}(+)", kinds(() -> run_sum(sysof(Verbatim.SumJunction{Wrench{Float64}, 3}(+)))))
r = run_sum(sysof(Verbatim.SumJunction{Wrench{Float64}, 3}(+)))
say("  sum equals contributors' sum", string(r[1] == r[2], "  ", r[1].F))
say("library SumJunction{Wrench{Float64},3}()", kinds(() -> run_sum(sysof(SumJunction{Wrench{Float64}, 3}()))))
say("Dual activation, library junction", kinds(() -> build(sysof(SumJunction{Wrench{Float64}, 3}()); activations = (Float64, LinearizeDual))))
say("verbatim block: Junction{In,Out,N}(f) (1389)", kinds(() -> Verbatim.Junction{Float64, Float64, 2}(max)))
say("library: Junction{In,Out,N}(f)", kinds(() -> Junction{Float64, Float64, 2}(max)))
say("1400: SumJunction{Wrench, 3} (unparametrized)", kinds(() -> build(sysof(SumJunction{Wrench, 3}()))))

# a stale arity: a fourth slot no one wires
say("forgotten contributor: SumJunction{W,4}", kinds(() -> build(sysof(SumJunction{Wrench{Float64}, 4}()))))
# a double-wired slot
struct SystemsDouble{J} <: AbstractComponent
    aero::Contrib; pwp::Contrib; ldg::Contrib; wr_sum::J; dynamics::Dyn
end
local_wires(::SystemsDouble) = ("aero/wrench" => "wr_sum/in1", "pwp/wrench" => "wr_sum/in1",
    "ldg/wrench" => "wr_sum/in3", "wr_sum/out" => "dynamics/wr_ext")
say("double-wired slot in1", kinds(() -> build(SystemsDouble(Contrib(1.0), Contrib(2.0), Contrib(3.0), SumJunction{Wrench{Float64}, 3}(), Dyn()))))

# fold order is positional: a non-commutative fold
struct Fold3 <: AbstractComponent
    a::Ramp; b::Constant{Float64}; c::Constant{Float64}; j::Junction{Float64, Float64, 3, F} where F
end
local_wires(::Fold3) = ("a/out" => "j/in1", "b/out" => "j/in2", "c/out" => "j/in3")
let s = Simulation(Fold3(Ramp(1.0), Constant(2.0), Constant(3.0), Junction{Float64, Float64, 3}((x, y, z) -> 100x + 10y + z)); h = 1//100)
    init!(s, fragment()); say("positional fold 100*in1+10*in2+in3", string(port(s, "j", :out)))
end

# ---- the zero-contributor spelling (1486–1487) -------------------------------
struct Bare <: AbstractComponent
    zero_wr::Constant{Wrench{Float64}}
    dynamics::Dyn
end
local_wires(::Bare) = ("zero_wr/out" => "dynamics/wr_ext",)
say("Constant(Wrench()) → dynamics/wr_ext", kinds(() -> build(Bare(Constant(Wrench()), Dyn()))))
say("  under a Dual activation", kinds(() -> build(Bare(Constant(Wrench()), Dyn()); activations = (Float64, LinearizeDual))))
struct BareUnfed <: AbstractComponent
    dynamics::Dyn
    other::Contrib
end
local_wires(::BareUnfed) = ()
say("no producer for wr_ext, not handed up", kinds(() -> build(BareUnfed(Dyn(), Contrib(1.0)))))

# ---- block 1 (1256–1261): one-level routing with fan-out ---------------------
struct Strut <: AbstractComponent end
x_init(::Strut) = (z = 0.0,)
u_types(::Strut) = (trn_field = Float64,)
y_types(::Strut) = (wr = Float64,)
y_state(::Strut, (; x)) = (wr = x.z,)
x_deriv(::Strut, (; u)) = (z = u.trn_field,)
struct Ldg <: AbstractComponent
    left::Strut; right::Strut; nose::Strut
end
local_wires(::Ldg) = ()
input_wires(::Ldg) = ("trn" => ("left/trn_field", "right/trn_field", "nose/trn_field"),)
struct Sys1 <: AbstractComponent
    ldg::Ldg
end
local_wires(::Sys1) = ()
input_wires(::Sys1) = ("trn" => "ldg/trn",)
struct Cessna <: AbstractComponent
    systems::Sys1
end
local_wires(::Cessna) = ()
input_wires(::Cessna) = ("trn" => "systems/trn",)
cessna() = Cessna(Sys1(Ldg(Strut(), Strut(), Strut())))
println("== block 1 and §6.1's path, fan-in and obligation rules")
say("level-by-level trn routing, fan-out at Ldg", kinds(() -> build(cessna())))
let b = build(cessna()); say("  root inputs", string(b.structure.root_inputs)) end
struct CessnaDeep <: AbstractComponent
    systems::Sys1
end
local_wires(::CessnaDeep) = ()
input_wires(::CessnaDeep) = ("trn" => "systems/ldg/trn",)
say("deep endpoint systems/ldg/trn", kinds(() -> build(CessnaDeep(Sys1(Ldg(Strut(), Strut(), Strut()))))))
struct CessnaTypo <: AbstractComponent
    systems::Sys1
end
local_wires(::CessnaTypo) = ()
input_wires(::CessnaTypo) = ("trn" => "systems/trnn",)
say("unknown face systems/trnn", kinds(() -> build(CessnaTypo(Sys1(Ldg(Strut(), Strut(), Strut()))))))

# two producers across levels: Ldg2 hands `nose/trn_field` up AND a sibling feeds it
struct Src1 <: AbstractComponent end
x_init(::Src1) = (;)
y_types(::Src1) = (out = Float64,)
y_state(::Src1, _) = (out = 1.0,)
struct Ldg2 <: AbstractComponent
    left::Strut; nose::Strut; src::Src1
end
local_wires(::Ldg2) = ("src/out" => "nose/trn_field",)
input_wires(::Ldg2) = ("trn" => ("left/trn_field", "nose/trn_field"),)
struct Top2 <: AbstractComponent
    ldg::Ldg2; s::Src1
end
local_wires(::Top2) = ("s/out" => "ldg/trn",)
say("sibling wire + input_wires to one child input", kinds(() -> build(Top2(Ldg2(Strut(), Strut(), Src1()), Src1()))))

# an unfed child input inside a sub-assembly, never handed up
struct Ldg3 <: AbstractComponent
    left::Strut; nose::Strut
end
local_wires(::Ldg3) = ()
input_wires(::Ldg3) = ("trn" => "left/trn_field",)
struct Top3 <: AbstractComponent
    ldg::Ldg3; s::Src1
end
local_wires(::Top3) = ("s/out" => "ldg/trn",)
say("nose/trn_field neither wired nor handed up", kinds(() -> build(Top3(Ldg3(Strut(), Strut()), Src1()))))
# handed up to the root and fed by nobody: a root input
struct Top4 <: AbstractComponent
    ldg::Ldg3
end
local_wires(::Top4) = ()
input_wires(::Top4) = ("trn" => "ldg/trn",)
say("chain ends at the root's input face", kinds(() -> build(Top4(Ldg3(Strut(), Strut())))))
# handed up one level, the parent declares nothing for it (not the root)
struct Mid5 <: AbstractComponent
    ldg::Ldg3
end
local_wires(::Mid5) = ()
input_wires(::Mid5) = ("trn" => "ldg/trn",)
struct Top5 <: AbstractComponent
    m::Mid5; other::Src1
end
local_wires(::Top5) = ()
say("face handed up to a non-root level, unfed there", kinds(() -> build(Top5(Mid5(Ldg3(Strut(), Strut())), Src1()))))
# unconnected outputs: legal, no warning
let b = build(Group((; s = Src1(), t = Src1())))
    say("unconnected outputs: warnings on the Build", string(b.warnings))
end

# ---- the wire type clauses -------------------------------------------------
struct PinnedIn <: AbstractComponent end
x_init(::PinnedIn) = (q = 0.0,)
u_types(::PinnedIn) = (a = Pinned{Float64},)
y_types(::PinnedIn) = (q = Float64,)
y_state(::PinnedIn, (; x)) = (q = x.q,)
x_deriv(::PinnedIn, (; u)) = (q = u.a,)
struct Walker <: AbstractComponent end
x_init(::Walker) = (w = 1.0,)
y_types(::Walker) = (out = Float64,)
y_state(::Walker, (; x)) = (out = x.w,)
x_deriv(::Walker, _) = (w = 0.0,)
println("== §6.1's type clauses")
say("walking producer → Pinned entry, continuous consumer", kinds(() -> build(Group((; w = Walker(), p = PinnedIn()); local_wires = ("w/out" => "p/a",)))))
say("Constant (pinned) → Pinned entry", kinds(() -> build(Group((; w = Constant(1.0), p = PinnedIn()); local_wires = ("w/out" => "p/a",)))))
say("walking → Freeze → Pinned entry", kinds(() -> build(Group((; w = Walker(), f = Freeze{Float64}(), p = PinnedIn()); local_wires = ("w/out" => "f/in", "f/out" => "p/a")))))
struct DiscIn <: AbstractComponent end
s_init(::DiscIn) = (n = 0.0,)
u_types(::DiscIn) = (a = Pinned{Float64},)
s_update(::DiscIn, (; s, u)) = (n = u.a,)
y_types(::DiscIn) = (n = Float64,)
y_state(::DiscIn, (; s)) = (n = s.n,)
say("walking → discrete consumer (plain Float64 entry)", kinds(() -> build(Group((; w = Walker(), d = Redstone.Blocks.UnitDelay(0.0)); local_wires = ("w/out" => "d/in",), sample_times = (d = Relative(1),)))))
say("walking → discrete consumer, Pinned entry", kinds(() -> build(Group((; w = Walker(), d = DiscIn()); local_wires = ("w/out" => "d/a",), sample_times = (d = Relative(1),)))))
struct IntIn <: AbstractComponent end
x_init(::IntIn) = (;)
u_types(::IntIn) = (a = Int,)
y_types(::IntIn) = (o = Int,)
y_direct(::IntIn, (; u)) = (o = u.a,)
say("Float64 producer → Int entry", kinds(() -> build(Group((; w = Walker(), i = IntIn()); local_wires = ("w/out" => "i/a",)))))
