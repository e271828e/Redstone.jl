# CV8_v probes: verifier for slice CV8 (assembly.jl, declare.jl coverage). Run from W with --project=test.
module ShadowMod
using Redstone
import Redstone: x_init
struct Shad <: Redstone.AbstractComponent end
x_init(::Shad) = (a = 0.0,)
x_deriv(::Shad, b) = (a = 0.0,)      # forgotten import: a foreign x_deriv
end

module P
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
const W = pwd()
include(joinpath(W, "test", "imports.jl"))
import Redstone: transparent_container, ws_init, x_projection, input_faces, output_faces, sample_times
include(joinpath(W, "test", "fixtures.jl"))
include(joinpath(W, "test", "utils.jl"))
const R = Redstone
p(label, x) = println(rpad(label, 34), " => ", x)
dl(e) = e.carried isa Vector ? e.carried : [e.carried]
kinds_of(e) = e isa R.DiagnosticError ? [(nameof(typeof(d)), hasfield(typeof(d), :reason) ? d.reason : (hasfield(typeof(d), :invariant) ? d.invariant : nothing)) for d in dl(e)] : (typeof(e), sprint(showerror, e)[1:min(end, 200)])

# --- types ---
struct Nothing1 <: AbstractComponent; g::Gain; end                     # neither family, holds a component
struct InputOnly <: AbstractComponent end; input_wires(::InputOnly) = ("a" => "b/u",)
struct Both <: AbstractComponent end; local_wires(::Both) = (); x_init(::Both) = (a = 0.0,); u_types(::Both) = (u = Float64,)
struct MixedT <: AbstractComponent; kids::Tuple; end                    # transparent field is mixed
local_wires(::MixedT) = (); transparent_container(::MixedT) = :kids
struct TwoT <: AbstractComponent; a::NamedTuple; b::NamedTuple; end
local_wires(::TwoT) = (); transparent_container(::TwoT) = (:a, :b)
struct Roster{U<:Tuple} <: AbstractComponent; units::U; end
local_wires(::Roster) = ("units/1/out" => "units/2/e",); input_wires(::Roster) = ("in" => "units/1/e",)
output_wires(::Roster) = ("units/2/out" => "y",)
struct BadWires <: AbstractComponent; g::Gain; end
local_wires(::BadWires) = (); input_wires(::BadWires) = "in" => "g/e"
# discrete with nested Pinned
struct DiscNested <: AbstractComponent end
s_init(::DiscNested) = (n = 0,); s_update(::DiscNested, (; s)) = (n = s.n,)
u_types(::DiscNested) = (a = SVector{2,Pinned{Float64}},); y_types(::DiscNested) = (n = Int,)
y_state(::DiscNested, (; s)) = (n = s.n,)
struct ContNested <: AbstractComponent end
x_init(::ContNested) = nothing; u_types(::ContNested) = (a = SVector{2,Pinned{Float64}},)
y_types(::ContNested) = (o = Float64,); y_direct(::ContNested, (; u)) = (o = 0.0,)
struct DiscTop <: AbstractComponent end
s_init(::DiscTop) = (n = 0,); s_update(::DiscTop, (; s)) = (n = s.n,)
u_types(::DiscTop) = (a = Pinned{Float64},); y_types(::DiscTop) = (n = Int,); y_state(::DiscTop, (; s)) = (n = s.n,)
# s_init variants
struct SNoUpd <: AbstractComponent end; s_init(::SNoUpd) = (n = 0,); y_types(::SNoUpd) = (n = Int,)
struct SWithX <: AbstractComponent end; s_init(::SWithX) = (n = 0,); s_update(::SWithX, (; s)) = (n = s.n,)
x_init(::SWithX) = (a = 0.0,); y_types(::SWithX) = (n = Int,); y_state(::SWithX, (; s)) = (n = s.n,)
struct SWithXd <: AbstractComponent end; s_init(::SWithXd) = (n = 0,); s_update(::SWithXd, (; s)) = (n = s.n,)
x_deriv(::SWithXd, b) = (n = 0.0,); y_types(::SWithXd) = (n = Int,); y_state(::SWithXd, (; s)) = (n = s.n,)
struct SNoUpdX <: AbstractComponent end; s_init(::SNoUpdX) = (n = 0,); x_init(::SNoUpdX) = (a = 0.0,); y_types(::SNoUpdX) = (n = Int,)
# state leaves
struct Leaves <: AbstractComponent end
x_init(::Leaves) = (a = (b = 1.0,), m = 1, e = 1.0f0, w = 1.0 + 2.0im)
x_deriv(::Leaves, (; x)) = x
# projection
struct ProjDisc <: AbstractComponent end
s_init(::ProjDisc) = (n = 0,); s_update(::ProjDisc, (; s)) = (n = s.n,); y_types(::ProjDisc) = (n = Int,)
y_state(::ProjDisc, (; s)) = (n = s.n,); x_projection(::ProjDisc, x) = x
struct ProjNone <: AbstractComponent end
x_init(::ProjNone) = nothing; y_types(::ProjNone) = (o = Float64,); y_state(::ProjNone, b) = (o = 0.0,)
x_projection(::ProjNone, x) = x
struct ProjBad <: AbstractComponent end
x_init(::ProjBad) = (q = 0.0,); x_deriv(::ProjBad, (; x)) = (q = 1.0,); y_types(::ProjBad) = (q = Float64,)
y_state(::ProjBad, (; x)) = (q = x.q,); x_projection(::ProjBad, x) = (v = x.q,)
const PCOUNT = Ref(0)
struct ProjCount <: AbstractComponent end
x_init(::ProjCount) = (q = 0.0,); x_deriv(::ProjCount, (; x)) = (q = 1.0,); y_types(::ProjCount) = (q = Float64,)
y_state(::ProjCount, (; x)) = (q = x.q,)
x_projection(::ProjCount, x) = (PCOUNT[] += 1; x)
# rates
struct RateA{A} <: AbstractComponent; c::TickCounter; r::A; end
local_wires(::RateA) = (); sample_times(c::RateA) = (c = c.r,)
# faces
struct BareP <: AbstractComponent end
x_init(::BareP) = nothing; u_types(::BareP) = Float64; y_types(::BareP) = Float64; y_direct(::BareP, (; u)) = u

# CV8-002 / CV8-103: class
e = failure(() -> build(Nothing1(Gain(1.0))))
d = only(dl(e)); p("103 Unreadable fields", (d.type, d.found, d.assembly_family, d.leaf_family, d.holds_components))
d = only(dl(failure(() -> build(InputOnly())))); p("002 InputOnly", (nameof(typeof(d)), d.found))
d = only(dl(failure(() -> build(Both())))); p("002 Both", (nameof(typeof(d)), d.declarations))

# CV8-089: shadowed
e = failure(() -> build(Main.ShadowMod.Shad()))
p("089 shadowed", e isa R.DiagnosticError ? [(nameof(typeof(d)), d.path, d.names, d.parent_module) for d in dl(e)] : e)

# CV8-109: mixed container named transparent
p("109 mixed+transparent", kinds_of(failure(() -> build(MixedT((TickCounter(), 1.0))))))
# CV8-048: two transparent containers
p("048 tuple return", let e = failure(() -> build(TwoT((x = TickCounter(),), (y = TickCounter(),)))); e isa R.DiagnosticError ? kinds_of(e) : (typeof(e), sprint(showerror, e)[1:min(end, 300)]) end)

# CV8-037: container element face in one level
st = build(Roster((Gain(2.0), Gain(3.0)))).structure
p("037 roster paths", paths(st))

# CV8-115/116: face lists
p("115 bare primitive", (input_faces(BareP()), output_faces(BareP())))
p("115 assembly", (input_faces(Roster((Gain(2.0), Gain(3.0)))), output_faces(Roster((Gain(2.0), Gain(3.0))))))
v = input_faces(Gain(1.0)); push!(v, "zz"); p("115 fresh", input_faces(Gain(1.0)))
p("116 no class", kinds_of(failure(() -> input_faces(Nothing1(Gain(1.0))))))
p("116 both", kinds_of(failure(() -> input_faces(Both()))))
p("116 bad wires", kinds_of(failure(() -> input_faces(BadWires(Gain(1.0))))))

# CV8-125: unknown names
p("125 unknown", kinds_of(failure(() -> input_passthrough(Roster((Gain(2.0), Gain(3.0))), "units/1"; except = ("zz",)))))
p("151 methods", methods(input_passthrough))

# CV8-126: state leaves
p("126 leaves", [(d.name, d.reason) for d in dl(failure(() -> build(single(Leaves()))))
                  if d isa IllegalStateLeaf])

# CV8-131: FaceNameIllegal
struct EmptyKey <: AbstractComponent end
@eval x_init(::EmptyKey) = nothing
@eval u_types(::EmptyKey) = NamedTuple{(Symbol(""),)}((Float64,))
@eval y_types(::EmptyKey) = (o = Float64,)
@eval y_direct(::EmptyKey, b) = (o = 0.0,)
p("131 empty key", kinds_of(failure(() -> build(single(EmptyKey())))))
p("131 slash face", kinds_of(failure(() -> build(Group((; g = Gain(1.0)); input_wires = ("a/b" => "g/e",))))))

# CV8-025: nested Pinned on both tiers; top Pinned on discrete
p("025 disc nested", kinds_of(failure(() -> build(single(DiscNested())))))
p("025 cont nested", kinds_of(failure(() -> build(single(ContNested())))))
p("132 disc top", kinds_of(failure(() -> build(single(DiscTop())))))

# CV8-013: s_init
p("013 no update", kinds_of(failure(() -> build(single(SNoUpd())))))
p("013 with x_init", kinds_of(failure(() -> build(single(SWithX())))))
p("013 with x_deriv", kinds_of(failure(() -> build(single(SWithXd())))))
p("013 no upd + x_init", kinds_of(failure(() -> build(single(SNoUpdX())))))

# CV8-052 / CV8-063: rate forms
p("052 Int8/BigInt/UInt8", (Relative(Int8(2)), Relative(big(3), UInt8(1)), Relative(true)))
p("052 float", kinds_of(failure(() -> Relative(2.0))))
for r in (Relative(0), Relative(2, 2), Relative(2, -1), Absolute(0), Absolute(-1//2), Absolute(1//2, 1//2), Absolute(1//2, -1//4))
    p("063 $(r)", kinds_of(failure(() -> build(RateA(TickCounter(), r)))))
end

# CV8-076: projection refusals
p("076 disc", kinds_of(failure(() -> build(single(ProjDisc())))))
p("076 empty", kinds_of(failure(() -> build(single(ProjNone())))))
p("076 bad return", kinds_of(failure(() -> build(single(ProjBad())))))

# CV8-078: projection call sites
m = Model(single(ProjCount()); Δt_frame = 1)
PCOUNT[] = 0; init!(m); p("078 after init!", PCOUNT[])
PCOUNT[] = 0; frame!(m, 1); p("078 after one frame", PCOUNT[])
PCOUNT[] = 0; overlay!(m); p("078 after overlay!", PCOUNT[])
m2 = Model(single(ProjCount()); Δt_frame = 1, h_max = 1//4, h_min = 1//2^20, algorithm = BS3())
init!(m2); PCOUNT[] = 0; frame!(m2, 1); p("078 one frame, h_max 1/4", PCOUNT[])

# CV8-107/098: reason vocabularies
p("107 ChildNameCollision reason", fieldtype(ChildNameCollision, :reason))
p("098 bundle classes", [R.classify_bundle_field(:x_deriv, R.CONTINUOUS, f) for f in (:m, :s, :zz)])
end
