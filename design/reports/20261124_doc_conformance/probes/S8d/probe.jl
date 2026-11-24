# S8d probe: spec.md §8.6 (3907-4325). Run from the worktree with --project=test.
using Redstone, StaticArrays, LinearAlgebra
import Redstone: AbstractComponent, x_init, s_init, u_types, y_types, y_state, y_direct, x_deriv,
    s_update, x_projection, local_wires, input_wires, output_wires, sample_times, Relative, Group,
    input_passthrough, build, diagnostics, message, DiagnosticError, input_faces, output_faces, resolve

show_fail(tag, f) = try
    r = f(); println(tag, " => OK ", typeof(r))
    r
catch e
    if e isa DiagnosticError
        for d in diagnostics(e)
            println(tag, " => ", nameof(typeof(d)), " ", filter(p -> p.first in (:reason, :endpoint, :invariant, :site, :declaration, :found, :wanted, :port, :faces, :candidates, :face), [k => getfield(d, k) for k in fieldnames(typeof(d))]))
            println("     ", message(d))
        end
    else
        println(tag, " => THROW ", sprint(showerror, e)[1:min(end,300)])
    end
    nothing
end

# --- fixtures ---
struct Integ <: AbstractComponent end
x_init(::Integ) = (q = 0.0,)
u_types(::Integ) = (u = Float64,)
y_types(::Integ) = (y = Float64,)
y_state(::Integ, (; x)) = (y = x.q,)
x_deriv(::Integ, (; x, u)) = (q = u.u,)

struct Gn <: AbstractComponent end
x_init(::Gn) = nothing
u_types(::Gn) = (u = Float64,)
y_types(::Gn) = (y = Float64,)
y_direct(::Gn, (; u)) = (y = 2 * u.u,)

struct GB <: AbstractComponent end      # bare both sides
x_init(::GB) = nothing
u_types(::GB) = Float64
y_types(::GB) = Float64
y_direct(::GB, (; u)) = 2 * u

struct A1 <: AbstractComponent; a::Integ; b::Gn; end
local_wires(::A1) = ("a/y" => "b/u",)
input_wires(::A1) = ("cmd" => "a/u",)
output_wires(::A1) = ("b/y" => "out",)
println("--- good assembly root")
b = show_fail("A1", () -> build(A1(Integ(), Gn())))
b === nothing || println("root_inputs ", b.structure.root_inputs)

struct BarePair <: AbstractComponent; a::Integ; b::Gn; end
local_wires(::BarePair) = "a/y" => "b/u"
input_wires(::BarePair) = ("cmd" => "a/u",)
show_fail("barepair", () -> build(BarePair(Integ(), Gn())))
struct BarePairIn <: AbstractComponent; a::Integ; b::Gn; end
local_wires(::BarePairIn) = ("a/y" => "b/u",)
input_wires(::BarePairIn) = "cmd" => "a/u"
output_wires(::BarePairIn) = ()
show_fail("barepair_in", () -> build(BarePairIn(Integ(), Gn())))
println("--- Group takes bare Pair")
show_fail("group_barepair", () -> build(Group((; a = Integ(), b = Gn()); local_wires = "a/y" => "b/u", input_wires = "cmd" => "a/u")))
println("--- non-collection")
show_fail("string", () -> build(Group((; a = Integ(), b = Gn()); local_wires = ("a/y" => "b/u",), input_wires = ("cmd" => "a/u", 3))))

struct Empt <: AbstractComponent; a::Integ; end
local_wires(::Empt) = ()
input_wires(::Empt) = ("cmd" => (),)
show_fail("emptytuple", () -> build(Empt(Integ())))

struct OneSeg <: AbstractComponent; a::Integ; b::Gn; end
local_wires(::OneSeg) = ("a" => "b/u",)
input_wires(::OneSeg) = ("cmd" => "a/u",)
show_fail("oneseg_src", () -> build(OneSeg(Integ(), Gn())))
struct OneSeg2 <: AbstractComponent; a::Integ; b::Gn; end
local_wires(::OneSeg2) = ("a/y" => "b",)
input_wires(::OneSeg2) = ("cmd" => "a/u",)
show_fail("oneseg_dst", () -> build(OneSeg2(Integ(), Gn())))

println("--- bare contract endpoint names the face")
struct BareChain <: AbstractComponent; g::GB; h::GB; end
local_wires(::BareChain) = ("g/y" => "h/u",)
input_wires(::BareChain) = ("in" => "g/u",)
output_wires(::BareChain) = ("h/y" => "out",)
show_fail("barechain", () -> build(BareChain(GB(), GB())))
struct BareChain2 <: AbstractComponent; g::GB; h::GB; end
local_wires(::BareChain2) = ("g" => "h/u",)
input_wires(::BareChain2) = ("in" => "g/u",)
show_fail("barechain_oneseg", () -> build(BareChain2(GB(), GB())))

println("--- face names")
struct Slash <: AbstractComponent; a::Integ; b::Gn; end
local_wires(::Slash) = ("a/y" => "b/u",)
input_wires(::Slash) = ("x/y" => "a/u",)
output_wires(::Slash) = ("b/y" => "out",)
show_fail("slash", () -> build(Slash(Integ(), Gn())))
struct EmptyFace <: AbstractComponent; a::Integ; b::Gn; end
local_wires(::EmptyFace) = ("a/y" => "b/u",)
input_wires(::EmptyFace) = ("" => "a/u",)
output_wires(::EmptyFace) = ("b/y" => "out",)
show_fail("emptyface", () -> build(EmptyFace(Integ(), Gn())))
struct Dup <: AbstractComponent; a::Integ; b::Gn; end
local_wires(::Dup) = ("a/y" => "b/u",)
input_wires(::Dup) = ("same" => "a/u",)
output_wires(::Dup) = ("b/y" => "same",)
show_fail("dup", () -> build(Dup(Integ(), Gn())))
struct EmptyKey <: AbstractComponent end
x_init(::EmptyKey) = nothing
u_types(::EmptyKey) = NamedTuple{(Symbol(""),)}((Float64,))
y_types(::EmptyKey) = (y = Float64,)
y_direct(::EmptyKey, (; u)) = (y = 1.0,)
show_fail("emptykey", () -> build(EmptyKey()))
struct DotFace <: AbstractComponent; a::Integ; b::Gn; end
local_wires(::DotFace) = ("a/y" => "b/u",)
input_wires(::DotFace) = ("pilot.throttle_axis" => "a/u",)
output_wires(::DotFace) = ("b/y" => "out",)
show_fail("dotface", () -> build(DotFace(Integ(), Gn())))

println("--- direction")
struct WrongL <: AbstractComponent; a::Integ; b::Gn; end
local_wires(::WrongL) = ("a/u" => "b/u",)
input_wires(::WrongL) = ("cmd" => "a/u",)
show_fail("wrong_src", () -> build(WrongL(Integ(), Gn())))
struct WrongD <: AbstractComponent; a::Integ; b::Gn; end
local_wires(::WrongD) = ("a/y" => "b/y",)
show_fail("wrong_dst", () -> build(WrongD(Integ(), Gn())))
struct WrongO <: AbstractComponent; a::Integ; b::Gn; end
local_wires(::WrongO) = ("a/y" => "b/u",)
input_wires(::WrongO) = ("cmd" => "a/u",)
output_wires(::WrongO) = ("b/u" => "out",)
show_fail("wrong_out", () -> build(WrongO(Integ(), Gn())))
struct WrongI <: AbstractComponent; a::Integ; b::Gn; end
local_wires(::WrongI) = ("a/y" => "b/u",)
input_wires(::WrongI) = ("cmd" => "b/y",)
show_fail("wrong_in", () -> build(WrongI(Integ(), Gn())))
println("--- two producers by same output face")
struct TwoOut <: AbstractComponent; a::Integ; b::Gn; end
local_wires(::TwoOut) = ("a/y" => "b/u",)
input_wires(::TwoOut) = ("cmd" => "a/u",)
output_wires(::TwoOut) = ("b/y" => "out", "a/y" => "out")
show_fail("twoout", () -> build(TwoOut(Integ(), Gn())))
println("--- fan-out through boundary, and boundary-fed + local-fed")
struct Fan <: AbstractComponent; a::Integ; c::Integ; end
local_wires(::Fan) = ()
input_wires(::Fan) = ("cmd" => ("a/u", "c/u"),)
b = show_fail("fan", () -> build(Fan(Integ(), Integ())))
b === nothing || println("root_inputs ", b.structure.root_inputs)
struct Twice <: AbstractComponent; a::Integ; b::Gn; end
local_wires(::Twice) = ("a/y" => "b/u",)
input_wires(::Twice) = ("cmd" => "a/u", "v" => "b/u")
show_fail("twice", () -> build(Twice(Integ(), Gn())))

println("--- containers")
struct Cont <: AbstractComponent; a::Integ; gs::Tuple{Gn,Gn}; end
local_wires(::Cont) = ("a/y" => "gs/2/u", "a/y" => "gs/1/u")
input_wires(::Cont) = ("cmd" => "a/u",)
output_wires(::Cont) = ("gs/2/y" => "out",)
b = show_fail("cont", () -> build(Cont(Integ(), (Gn(), Gn()))))
b === nothing || println("paths ", [c.path for c in b.structure.components])
struct ContN <: AbstractComponent; a::Integ; gs::NamedTuple{(:red, :blue), Tuple{Gn,Gn}}; end
local_wires(::ContN) = ("a/y" => "gs/red/u", "a/y" => "gs/blue/u")
input_wires(::ContN) = ("cmd" => "a/u",)
b = show_fail("contN", () -> build(ContN(Integ(), (red = Gn(), blue = Gn()))))
b === nothing || println("paths ", [c.path for c in b.structure.components])
# deeper than face
struct Deep <: AbstractComponent; a::Integ; i::A1; end
local_wires(::Deep) = ("a/y" => "i/b/u",)
input_wires(::Deep) = ("cmd" => "a/u",)
show_fail("deep", () -> build(Deep(Integ(), A1(Integ(), Gn()))))

println("--- name transparent")
struct Tr <: AbstractComponent; a::Integ; gs::NamedTuple{(:red, :blue), Tuple{Gn,Gn}}; end
local_wires(::Tr) = ("a/y" => "red/u", "a/y" => "blue/u")
input_wires(::Tr) = ("cmd" => "a/u",)
Redstone.transparent_container(::Tr) = :gs
show_fail("transparent_try", () -> build(Tr(Integ(), (red = Gn(), blue = Gn()))))

println("--- root primitive")
struct RootBoth <: AbstractComponent end
x_init(::RootBoth) = nothing
u_types(::RootBoth) = (u = Float64,)
y_types(::RootBoth) = (u = Float64,)
y_direct(::RootBoth, (; u)) = (u = u.u,)
show_fail("root_both", () -> build(RootBoth()))
struct RootBareBare <: AbstractComponent end
x_init(::RootBareBare) = nothing
u_types(::RootBareBare) = Float64
y_types(::RootBareBare) = Float64
y_direct(::RootBareBare, (; u)) = u
b = show_fail("root_barebare", () -> build(RootBareBare()))
b === nothing || println("root_inputs ", b.structure.root_inputs)
struct RootNamedBare <: AbstractComponent end
x_init(::RootNamedBare) = nothing
u_types(::RootNamedBare) = Float64
y_types(::RootNamedBare) = (u = Float64,)
y_direct(::RootNamedBare, (; u)) = (u = u,)
show_fail("root_namedbare", () -> build(RootNamedBare()))
struct RootNamedBare2 <: AbstractComponent end
x_init(::RootNamedBare2) = nothing
u_types(::RootNamedBare2) = (u = Float64,)
y_types(::RootNamedBare2) = Float64
y_direct(::RootNamedBare2, (; u)) = u.u
show_fail("root_namedbare2 (named u in, bare y)", () -> build(RootNamedBare2()))
println("below root: Gn named collision untouched")
struct Coll <: AbstractComponent end
x_init(::Coll) = nothing
u_types(::Coll) = (u = Float64,)
y_types(::Coll) = (u = Float64,)
y_direct(::Coll, (; u)) = (u = 2 * u.u,)
struct CollHost <: AbstractComponent; c::Coll; end
local_wires(::CollHost) = ()
input_wires(::CollHost) = ("in" => "c/u",)
show_fail("collbelow", () -> build(CollHost(Coll())))

println("--- passthrough")
struct IP <: AbstractComponent; a::A1; end
local_wires(::IP) = ()
input_wires(i::IP) = (input_passthrough(i, "a")...,)
println(input_wires(IP(A1(Integ(), Gn()))))
println(input_faces(A1(Integ(), Gn())), output_faces(A1(Integ(), Gn())))
println(input_passthrough(IP(A1(Integ(), Gn())), "a"; prefix = "", only = ("cmd",)))

println("--- promised errors on wrong-dir message")
show_fail("wrongdir msg", () -> build(WrongO(Integ(), Gn())))

# =====================================================================
# the strapdown IMU of the spec, with stubs for FlightPhysics' names
# =====================================================================
println("=== IMU")
struct FrameTransform end
struct RQ; v::SVector{4,Float64}; end
RQuat{T} = RQ
RQ(v; normalization = true) = RQ(SVector{4,Float64}(v))
(q::RQ)(f) = f
Base.adjoint(q::RQ) = q
Base.:∘(a::RQ, b::RQ) = RQ(a.v)
RVec(q::RQ) = SVector{3,Float64}(q.v[2], q.v[3], q.v[4])
module Attitude; dt(q, ω) = [0.0 * ω[1], ω[1], ω[2], ω[3]]; end
Base.@kwdef struct IMUSample
    ω̄_ic_c::SVector{3,Float64}; f̄_c_c::SVector{3,Float64}
    ϑ_c::SVector{3,Float64}; ϑ_c_cc::SVector{3,Float64}
    υ_c::SVector{3,Float64}; υ_c_sc::SVector{3,Float64}
end
const IMUIntegrals_Θ = nothing
struct IMUIntegrals <: AbstractComponent
    t_bc::FrameTransform
end
x_init(::IMUIntegrals) = (Θ = zeros(SVector{3}), q = SVector{4}(1.0, 0, 0, 0),
                          Υ = zeros(SVector{3}), V = zeros(SVector{3}))
u_types(::IMUIntegrals) =
    (q_eb = SVector{4,Float64}, r_eb_e = SVector{3,Float64}, ω_eb_b = SVector{3,Float64},
     a_ib_b = SVector{3,Float64}, α_ib_b = SVector{3,Float64})
y_types(::IMUIntegrals) =
    (Θ = SVector{3,Float64}, q = SVector{4,Float64},
     Υ = SVector{3,Float64}, V = SVector{3,Float64},
     ω_ic_c = SVector{3,Float64}, f_c_c = SVector{3,Float64})
y_state(::IMUIntegrals, (; x)) = (; x.Θ, x.q, x.Υ, x.V)
y_direct(::IMUIntegrals, (; u)) = (ω_ic_c = u.ω_eb_b, f_c_c = u.a_ib_b)
function x_deriv(imu::IMUIntegrals, (; x, y))
    q = RQuat(x.q, normalization = false)
    (Θ = y.ω_ic_c, q = SVector{4}(Attitude.dt(q, y.ω_ic_c)), Υ = y.f_c_c, V = q(y.f_c_c))
end
x_projection(imu::IMUIntegrals, x) = (; x..., q = normalize(x.q))

struct IMUSampler <: AbstractComponent end
s_init(::IMUSampler) = (Θ = zeros(SVector{3}), q = SVector{4}(1.0, 0, 0, 0),
                        Υ = zeros(SVector{3}), V = zeros(SVector{3}))
u_types(::IMUSampler)  = (Θ = SVector{3,Float64}, q = SVector{4,Float64},
                         Υ = SVector{3,Float64}, V = SVector{3,Float64})
y_types(::IMUSampler) = (sample = IMUSample,)
function y_direct(smp::IMUSampler, (; s, u, Δt))
    q_s = RQuat(s.q, normalization = false);  q_u = RQuat(u.q, normalization = false)
    ϑ_c = u.Θ - s.Θ;  υ_c = u.Υ - s.Υ
    Δq  = q_s' ∘ q_u
    υ_c_sc = q_s'(u.V - s.V)
    (; sample = IMUSample(; ω̄_ic_c = ϑ_c / Δt, f̄_c_c = υ_c / Δt,
                            ϑ_c, ϑ_c_cc = RVec(Δq)[:], υ_c, υ_c_sc))
end
s_update(smp::IMUSampler, (; u)) = (Θ = u.Θ, q = u.q, Υ = u.Υ, V = u.V)

struct IMUErrorModel <: AbstractComponent end     # stub: the spec leaves it open
s_init(::IMUErrorModel) = (n = 0.0,)
s_update(::IMUErrorModel, (; s)) = s
u_types(::IMUErrorModel) = (sample = IMUSample,)
y_types(::IMUErrorModel) = (sample_meas = IMUSample,)
y_direct(::IMUErrorModel, (; u)) = (sample_meas = u.sample,)

struct IMU <: AbstractComponent
    integrals::IMUIntegrals
    sampler::IMUSampler
    errors::IMUErrorModel
end
local_wires(::IMU) = (
    "integrals/Θ" => "sampler/Θ", "integrals/q" => "sampler/q",
    "integrals/Υ" => "sampler/Υ", "integrals/V" => "sampler/V",
    "sampler/sample" => "errors/sample",
)
input_wires(imu::IMU) = (
    input_passthrough(imu, "integrals")...,
)
output_wires(::IMU) = (
    "sampler/sample" => "sample",
    "errors/sample_meas" => "sample_meas",
)
sample_times(::IMU) = (sampler = Relative(1), errors = Relative(1))

imu = IMU(IMUIntegrals(FrameTransform()), IMUSampler(), IMUErrorModel())
println("passthrough: ", input_wires(imu))
bi = show_fail("IMU", () -> build(imu))
if bi !== nothing
    println("root_inputs ", bi.structure.root_inputs)
    println("tiers ", [(c.path, c.tier) for c in bi.structure.components])
    println("timings ", [(c.path, c.timing) for c in bi.structure.components])
    println("faces out ", output_faces(imu), " in ", input_faces(imu))
    act = Redstone.activation(bi, Float64)
    println("layout addrs ", sort!(string.(collect(keys(act.layout.addr)))))
end
# --- the two failure claims
struct IMUbad1 <: AbstractComponent; integrals::IMUIntegrals; sampler::IMUSampler; errors::IMUErrorModel; end
local_wires(::IMUbad1) = local_wires(imu)
input_wires(i::IMUbad1) = (input_passthrough(i, "integrals")...,)
output_wires(::IMUbad1) = ("sampler/sample" => "sample", "errors/sample" => "sample_meas")
sample_times(::IMUbad1) = (sampler = Relative(1), errors = Relative(1))
show_fail("IMU errors/sample in output_wires", () -> build(IMUbad1(imu.integrals, imu.sampler, imu.errors)))
struct IMUbad2 <: AbstractComponent; integrals::IMUIntegrals; sampler::IMUSampler; errors::IMUErrorModel; end
local_wires(::IMUbad2) = local_wires(imu)
input_wires(i::IMUbad2) = (input_passthrough(i, "integrals")..., "x" => "errors/sample")
output_wires(::IMUbad2) = output_wires(imu)
sample_times(::IMUbad2) = (sampler = Relative(1), errors = Relative(1))
show_fail("IMU errors/sample in input_wires", () -> build(IMUbad2(imu.integrals, imu.sampler, imu.errors)))
struct IMUbad3 <: AbstractComponent; integrals::IMUIntegrals; sampler::IMUSampler; errors::IMUErrorModel; end
local_wires(::IMUbad3) = local_wires(imu)
input_wires(i::IMUbad3) = (input_passthrough(i, "integrals")...,)
output_wires(::IMUbad3) = output_wires(imu)
sample_times(::IMUbad3) = (integrals = Relative(1), sampler = Relative(1), errors = Relative(1))
show_fail("IMU sample_times on integrals", () -> build(IMUbad3(imu.integrals, imu.sampler, imu.errors)))
# no sample_times at all: default
struct IMUnone <: AbstractComponent; integrals::IMUIntegrals; sampler::IMUSampler; errors::IMUErrorModel; end
local_wires(::IMUnone) = local_wires(imu)
input_wires(i::IMUnone) = (input_passthrough(i, "integrals")...,)
output_wires(::IMUnone) = output_wires(imu)
bn = show_fail("IMU no sample_times", () -> build(IMUnone(imu.integrals, imu.sampler, imu.errors)))
bn === nothing || println("timings ", [(c.path, c.timing) for c in bn.structure.components])

# latch-back wire joins local_wires as one ordinary pair: add sampler latch port + integrals consuming it? skip

# Group with 3 declarations using the same helper
println("--- transparent paths")
bt = show_fail("tr_ok", () -> build(Tr(Integ(), (red = Gn(), blue = Gn()))))
bt === nothing || println([c.path for c in bt.structure.components])
println("--- bundle sets")
println(Redstone.LEGAL_BUNDLE)

println("=== tier-neutral exports")
struct Dd <: AbstractComponent end
s_init(::Dd) = (n = 0.0,)
u_types(::Dd) = (u = Float64,)
y_types(::Dd) = (y = Float64,)
y_state(::Dd, (; s)) = (y = s.n,)
s_update(::Dd, (; u)) = (n = u.u,)
bneu = show_fail("neutral", () -> build(Group((; i = Integ(), g = Gn(), d = Dd());
    local_wires = ("i/y" => "g/u",), input_wires = ("c" => "i/u", "s" => "d/u"),
    output_wires = ("i/y" => "cont", "g/y" => "stateless", "d/y" => "disc"))))

println("=== freshness sim")
import Redstone: Simulation, init!, run!, port, state, set
sim = Simulation(imu; Δt_frame = 1//50)
vals = (var"integrals.q_eb" = SVector(1.0,0,0,0), var"integrals.r_eb_e" = zeros(SVector{3}),
        var"integrals.ω_eb_b" = zeros(SVector{3}), var"integrals.a_ib_b" = SVector(0.0,0,1.0),
        var"integrals.α_ib_b" = zeros(SVector{3}))
init!(sim, set(u = vals))
run!(sim; t_end = 0.06)
smp = port(sim, "sampler", :sample)
println("t=0.06 υ_c=", smp.υ_c, " υ_c_sc=", smp.υ_c_sc, " ϑ_c=", smp.ϑ_c, " s.V=", state(sim, "sampler").V, " x.V=", state(sim, "integrals").V)

println("=== latch-back wire")
struct LIntegrals <: AbstractComponent end
x_init(::LIntegrals) = (V = zeros(SVector{3}),)
u_types(::LIntegrals) = (f = SVector{3,Float64}, latch = SVector{3,Float64})
y_types(::LIntegrals) = (V = SVector{3,Float64},)
y_state(::LIntegrals, (; x)) = (V = x.V,)
x_deriv(::LIntegrals, (; x, u)) = (V = u.f .+ 0.0 .* (x.V .- u.latch),)
struct LSampler <: AbstractComponent end
s_init(::LSampler) = (V = zeros(SVector{3}),)
u_types(::LSampler) = (V = SVector{3,Float64},)
y_types(::LSampler) = (latch = SVector{3,Float64},)
y_direct(::LSampler, (; s, u, Δt)) = (latch = u.V,)
s_update(::LSampler, (; u)) = (V = u.V,)
struct LB <: AbstractComponent; integrals::LIntegrals; sampler::LSampler; end
local_wires(::LB) = ("integrals/V" => "sampler/V", "sampler/latch" => "integrals/latch")
input_wires(::LB) = ("f" => "integrals/f",)
output_wires(::LB) = ("sampler/latch" => "latch",)
show_fail("latchback", () -> build(LB(LIntegrals(), LSampler())))

println("=== boundary zero latches s <- integrals(t0)")
struct LI0 <: AbstractComponent end
x_init(::LI0) = (V = SVector(1.0, 2.0, 3.0),)
u_types(::LI0) = (f = SVector{3,Float64},)
y_types(::LI0) = (V = SVector{3,Float64},)
y_state(::LI0, (; x)) = (V = x.V,)
x_deriv(::LI0, (; x, u)) = (V = u.f,)
struct LB0 <: AbstractComponent; integrals::LI0; sampler::LSampler; end
local_wires(::LB0) = ("integrals/V" => "sampler/V",)
input_wires(::LB0) = ("f" => "integrals/f",)
sim0 = Simulation(LB0(LI0(), LSampler()); Δt_frame = 1//50)
init!(sim0, set(u = (f = zeros(SVector{3}),)))
println("s after init! = ", state(sim0, "sampler").V, "  (authored s = 0)")
println("--- leading slash")
struct LS <: AbstractComponent; a::Integ; b::Gn; end
local_wires(::LS) = ("/a/y" => "b/u",)
input_wires(::LS) = ("cmd" => "a/u",)
show_fail("leading slash", () -> build(LS(Integ(), Gn())))
println("--- Group input fan through nested + path read of container element")
bc = build(Cont(Integ(), (Gn(), Gn())))
println(Redstone.port(Redstone.Simulation(Cont(Integ(), (Gn(), Gn())); Δt_frame = 1//50), "gs/2", :y))

println("=== primitive port name with slash")
struct SlashPort <: AbstractComponent end
x_init(::SlashPort) = nothing
u_types(::SlashPort) = NamedTuple{(Symbol("a/b"),)}((Float64,))
y_types(::SlashPort) = (y = Float64,)
y_direct(::SlashPort, (; u)) = (y = 1.0,)
show_fail("slashport", () -> build(SlashPort()))
