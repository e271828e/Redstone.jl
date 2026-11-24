# K9b probe: frozen_discrete_walkthrough.md and handle_walk_walkthrough.md
using StaticArrays, ForwardDiff, LinearAlgebra
import Redstone
import Redstone.Library: Freeze
import Redstone: AbstractComponent, Group, Pinned, Simulation, Model, build, init!, run!,
    integrate!, port, state, set, linearize, taps, get_state, get_face, get_input, DiagnosticError,
    diagnostics, message, x_init, s_init, x_deriv, s_update, y_state, y_direct, u_types, y_types,
    ws_init, local_wires, LinearizeDual, ProbeDual, retype, retype_entry

D8 = ForwardDiff.Dual{Nothing,Float64,8}
function tryit(f)
    try
        r = f()
        return r
    catch err
        return err
    end
end
dlist(err) = err.carried isa Vector ? err.carried : [err.carried]
kindsof(err) = err isa DiagnosticError ? [(typeof(d).name.name, first(message(d), 400)) for d in dlist(err)] : err
show1(label, x) = println("PROBE ", label, " => ", x)

# ---------------- frozen discrete: A -> B -> C ----------------
struct CompA <: AbstractComponent end
x_init(::CompA) = (q = 1.0,)
x_deriv(::CompA, (; x)) = (q = -x.q,)
y_types(::CompA) = (a = Float64,)
y_state(::CompA, (; x)) = (a = x.q,)

struct CompB <: AbstractComponent end          # discrete, ticks each frame
s_init(::CompB) = (n = 0.0,)
u_types(::CompB) = (a = Float64,)
y_types(::CompB) = (b = Float64,)
y_direct(::CompB, (; u)) = (b = 3 * u.a,)
s_update(::CompB, (; s)) = (n = s.n + 1,)

struct CompC <: AbstractComponent end
x_init(::CompC) = (z = 0.0,)
u_types(::CompC) = (b = Float64,)
x_deriv(::CompC, (; u)) = (z = u.b,)
y_types(::CompC) = (c = Float64,)
y_state(::CompC, (; x)) = (c = x.z,)

chain() = Group((; a = CompA(), b = CompB(), c = CompC());
                local_wires = ("a/a" => "b/a", "b/b" => "c/b"))
sim = Simulation(chain(); Δt_frame = 1//50)
init!(sim, set())
run!(sim; t_end = 0.02)
a0 = port(sim, "a", :a); b0 = port(sim, "b", :b)
show1("F nominal at 0.02: a, b, b==3a", (a0, b0, b0 == 3a0))
integrate!(sim, 0.003)
a1 = port(sim, "a", :a); b1 = port(sim, "b", :b)
show1("F at 0.023: a moved, b held, b==3*a(0.02)", (a1 != a0, b1 == b0, b1 == 3a0))

simL = Simulation(chain(); Δt_frame = 1//50)
init!(simL, set())
lin = tryit(() -> linearize(simL, taps(x = (q = get_state("a", :q), z = get_state("c", :z)), u = (;), y = (;))))
show1("F linearize A (rows q,z; cols q,z)", lin isa Exception ? first(sprint(showerror, lin), 300) : lin.A)

dm = Model(build(chain()), D8; Δt_frame = 1//50)
show1("F dual model b cell type", typeof(port(dm, "b", :b)))
show1("F dual model a cell type", typeof(port(dm, "a", :a)))

# loop through discrete B vs continuous B
struct AFT <: AbstractComponent end   # continuous with feedthrough
x_init(::AFT) = (q = 1.0,)
x_deriv(::AFT, (; x)) = (q = -x.q,)
u_types(::AFT) = (b = Float64,)
y_types(::AFT) = (a = Float64,)
y_direct(::AFT, (; x, u)) = (a = x.q + u.b,)
struct BC <: AbstractComponent end    # continuous feedthrough
x_init(::BC) = nothing
u_types(::BC) = (a = Float64,)
y_types(::BC) = (b = Float64,)
y_direct(::BC, (; u)) = (b = 3 * u.a,)
loopD = Group((; a = AFT(), b = CompB()); local_wires = ("a/a" => "b/a", "b/b" => "a/b"))
loopC = Group((; a = AFT(), b = BC()); local_wires = ("a/a" => "b/a", "b/b" => "a/b"))
show1("F loop through discrete B builds", tryit(() -> build(loopD) isa Redstone.Build))
r = tryit(() -> build(loopC))
show1("F loop through continuous feedthrough B", r isa DiagnosticError ? [typeof(d).name.name for d in dlist(r)] : typeof(r))

# a discrete B fed by a walking A: legal wire
show1("F continuous A into discrete B entry builds at Float64", tryit(() -> build(chain()) isa Redstone.Build))

# ---------------- handle walk ----------------
struct DeckField{T}
    heave::T
    pitch::T
    grid::Matrix{Float64}
end

function height(f::DeckField, p::SVector{3})
    x = p[1] * cos(f.pitch) - p[3] * sin(f.pitch)
    y = p[2]
    i, j = floor(Int, x), floor(Int, y)
    a, b = x - i, y - j
    g = f.grid
    z = (1 - a) * (1 - b) * g[i, j]   + a * (1 - b) * g[i+1, j] +
        (1 - a) * b       * g[i, j+1] + a * b       * g[i+1, j+1]
    return z + f.heave
end

grid = [0.1 * i for i in 1:10, j in 1:10]
# section 2 numbers: seeds heave and aircraft x
P = ForwardDiff.Dual{:act,Float64,2}
heave = P(0.0, ForwardDiff.Partials((1.0, 0.0)))
pitch = P(0.0, ForwardDiff.Partials((0.0, 0.0)))
px = P(2.3, ForwardDiff.Partials((0.0, 1.0)))
p = SVector(px, P(3.4), P(5.0))
f = DeckField(heave, pitch, grid)
h = height(f, p)
show1("H typeof grid", typeof(f.grid))
show1("H typeof h", typeof(h))
show1("H partials (heave, x)", ForwardDiff.partials(h))
a = P(0.3, ForwardDiff.Partials((0.0, 1.0)))
show1("H a*g partial == g*partials(a)", ForwardDiff.partials(a * grid[2, 3]) == grid[2, 3] * ForwardDiff.partials(a))
show1("H floor(Int, Dual) type", typeof(floor(Int, px)))
show1("H Float64(Dual w/ partials)", tryit(() -> Float64(px)))
show1("H Float64(Dual zero partials)", tryit(() -> Float64(P(1.0))))
show1("H convert(Float64, Dual)", tryit(() -> convert(Float64, px)))
show1("H zeros write Dual", tryit(() -> (v = zeros(2); v[1] = px; v)))

# components
struct Gear <: AbstractComponent end
x_init(::Gear) = (p = SVector(2.3, 3.4, 5.0),)
x_deriv(::Gear, (; x)) = (p = zero(x.p),)
u_types(::Gear) = (terrain = DeckField{Float64},)
y_types(::Gear) = (clearance = Float64,)
y_direct(g::Gear, (; x, u)) = (; clearance = x.p[3] - height(u.terrain, x.p))

struct StaticTerrain <: AbstractComponent
    datum::Float64
    grid::Matrix{Float64}
end
x_init(::StaticTerrain) = nothing
y_types(::StaticTerrain) = (terrain = Pinned{DeckField{Float64}},)
y_direct(c::StaticTerrain, _) = (; terrain = DeckField(c.datum, 0.0, c.grid))

struct UnpinnedStatic <: AbstractComponent
    datum::Float64
    grid::Matrix{Float64}
end
x_init(::UnpinnedStatic) = nothing
y_types(::UnpinnedStatic) = (terrain = DeckField{Float64},)
y_direct(c::UnpinnedStatic, _) = (; terrain = DeckField(c.datum, 0.0, c.grid))

struct SeaMotion <: AbstractComponent
    grid::Matrix{Float64}
end
x_init(::SeaMotion) = (heave = 0.0, pitch = 0.0)
x_deriv(::SeaMotion, (; x)) = (heave = 0.0, pitch = 0.0)
y_types(::SeaMotion) = (terrain = DeckField{Float64},)
y_state(c::SeaMotion, (; x)) = (; terrain = DeckField(x.heave, x.pitch, c.grid))

struct DiscTerrain <: AbstractComponent
    grid::Matrix{Float64}
end
s_init(::DiscTerrain) = nothing
y_types(::DiscTerrain) = (terrain = DeckField{Float64},)
y_direct(c::DiscTerrain, (; t)) = (; terrain = DeckField(0.0, 0.0, c.grid))

struct LegacyGround <: AbstractComponent end
x_init(::LegacyGround) = nothing
u_types(::LegacyGround) = (terrain = Pinned{DeckField{Float64}},)
y_types(::LegacyGround) = (f = Float64,)
y_direct(::LegacyGround, (; u)) = (; f = u.terrain.heave)

gear_with(src) = Group((; src = src, gear = Gear());
                       local_wires = ("src/terrain" => "gear/terrain",),
                       output_wires = ("gear/clearance" => "clearance",))

for (name, src) in (("static", StaticTerrain(0.5, grid)), ("sea", SeaMotion(grid)), ("disc", DiscTerrain(grid)))
    b = tryit(() -> build(gear_with(src)))
    show1("H gear fed by $name builds", b isa Redstone.Build ? true : kindsof(b))
    if b isa Redstone.Build
        m = tryit(() -> Model(b, D8; Δt_frame = 1//10))
        show1("H $name dual model terrain cell type", m isa Model ? typeof(port(m, "src", :terrain)) : m)
        m isa Model && show1("H $name dual clearance type", typeof(port(m, "gear", :clearance)))
    end
end
bu = tryit(() -> Model(build(gear_with(UnpinnedStatic(0.5, grid))), D8; Δt_frame = 1//10))
show1("H unpinned static terrain at dual", bu isa Model ? typeof(port(bu, "src", :terrain)) :
      (bu isa DiagnosticError ? [(typeof(d).name.name, message(d)) for d in dlist(bu)] : bu))

# linearize through the walk
s2 = Simulation(gear_with(SeaMotion(grid)); Δt_frame = 1//10)
init!(s2, set())
lin2 = tryit(() -> linearize(s2, taps(x = (heave = get_state("src", :heave), p = get_state("gear", "p[1]")),
                                      u = (;), y = (clearance = get_face(:clearance),))))
show1("H sea linearize C", lin2 isa Exception ? lin2 : (lin2.x_labels, lin2.C))

s3 = Simulation(gear_with(StaticTerrain(0.5, grid)); Δt_frame = 1//10)
init!(s3, set())
lin3 = tryit(() -> linearize(s3, taps(x = (p = get_state("gear", "p[1]"),), u = (;), y = (clearance = get_face(:clearance),))))
show1("H static linearize C", lin3 isa Exception ? lin3 : lin3.C)

# legacy
lm = Group((; deck = SeaMotion(grid), legacy = LegacyGround()), local_wires = ("deck/terrain" => "legacy/terrain",))
e = tryit(() -> build(lm))
show1("H deck into legacy", e isa DiagnosticError ? [(typeof(d).name.name, message(d)) for d in dlist(e)] : e)
lm2 = Group((; deck = StaticTerrain(0.5, grid), legacy = LegacyGround()), local_wires = ("deck/terrain" => "legacy/terrain",))
show1("H static into legacy builds", tryit(() -> build(lm2) isa Redstone.Build))

# Freeze on a handle
show1("H Freeze{DeckField{Float64}}", tryit(() -> Freeze{DeckField{Float64}}))
show1("H Freeze{Float64}", tryit(() -> Freeze{Float64}))

# tied signature
height_tied(f::DeckField{T}, p::SVector{3,T}) where {T} = 0.0
struct TiedGear <: AbstractComponent end
x_init(::TiedGear) = (p = SVector(2.3, 3.4, 5.0),)
x_deriv(::TiedGear, (; x)) = (p = zero(x.p),)
u_types(::TiedGear) = (terrain = DeckField{Float64},)
y_types(::TiedGear) = (clearance = Float64,)
y_direct(g::TiedGear, (; x, u)) = (; clearance = height_tied(u.terrain, x.p))
tg = Group((; src = StaticTerrain(0.5, grid), gear = TiedGear()), local_wires = ("src/terrain" => "gear/terrain",))
show1("H tied build nominal", tryit(() -> build(tg) isa Redstone.Build))
r = tryit(() -> Model(build(tg), D8; Δt_frame = 1//10))
show1("H tied at dual", r isa DiagnosticError ? [(typeof(d).name.name, message(d)) for d in dlist(r)] : (r isa Model ? :ok : r))
r = tryit(() -> build(tg; activations = (Float64, ProbeDual)))
show1("H tied with ProbeDual activation", r isa DiagnosticError ? [(typeof(d).name.name) for d in dlist(r)] : (r isa Exception ? r : :ok))
# same with tied but walking producer (sea): no error
tg2 = Group((; src = SeaMotion(grid), gear = TiedGear()), local_wires = ("src/terrain" => "gear/terrain",))
r = tryit(() -> Model(build(tg2), D8; Δt_frame = 1//10))
show1("H tied with sea", r isa Model ? :ok : r)

# Float64 buffer in stage
struct BufGear <: AbstractComponent end
x_init(::BufGear) = (q = 1.0,)
x_deriv(::BufGear, (; x)) = (q = 0.0,)
y_types(::BufGear) = (y = Float64,)
y_state(::BufGear, (; x)) = (buf = zeros(2); buf[1] = x.q; (; y = buf[1]))
r = tryit(() -> Model(build(Group((; b = BufGear()))), D8; Δt_frame = 1//10))
show1("H Float64 buffer at dual", r isa DiagnosticError ? [(typeof(d).name.name, message(d)) for d in dlist(r)] : (r isa Model ? :ok : typeof(r)))

# workspace: ws_init(c, T)
struct WsComp <: AbstractComponent end
x_init(::WsComp) = (q = 1.0,)
x_deriv(::WsComp, (; x)) = (q = 0.0,)
ws_init(::WsComp, ::Type{T}) where {T} = zeros(T, 2)
y_types(::WsComp) = (y = Float64,)
y_state(::WsComp, (; x, ws)) = (ws[1] = x.q; (; y = ws[1]))
r = tryit(() -> Model(build(Group((; b = WsComp()))), D8; Δt_frame = 1//10))
show1("H ws_init(c,T) at dual", r isa Model ? :ok : r)

# forwarding
struct Forward <: AbstractComponent end
x_init(::Forward) = nothing
u_types(::Forward) = (terrain = DeckField{Float64},)
y_types(::Forward) = (terrain = DeckField{Float64},)
y_direct(::Forward, (; u)) = (; terrain = u.terrain)
fw = Group((; src = StaticTerrain(0.5, grid), fw = Forward(), gear = Gear());
           local_wires = ("src/terrain" => "fw/terrain", "fw/terrain" => "gear/terrain"))
show1("H forward builds nominal", tryit(() -> build(fw) isa Redstone.Build))
r = tryit(() -> Model(build(fw), D8; Δt_frame = 1//10))
show1("H forward at dual", r isa DiagnosticError ? [(typeof(d).name.name, message(d)) for d in dlist(r)] : (r isa Model ? :ok : r))
struct FwdScalar <: AbstractComponent end
x_init(::FwdScalar) = nothing
u_types(::FwdScalar) = (v = Float64,)
y_types(::FwdScalar) = (v = Float64,)
y_direct(::FwdScalar, (; u)) = (; v = u.v)
struct PinnedSrc <: AbstractComponent end
x_init(::PinnedSrc) = nothing
y_types(::PinnedSrc) = (v = Pinned{Float64},)
y_direct(::PinnedSrc, _) = (; v = 1.0)
struct SinkS <: AbstractComponent end
x_init(::SinkS) = nothing
u_types(::SinkS) = (v = Float64,)
y_types(::SinkS) = (w = Float64,)
y_direct(::SinkS, (; u)) = (; w = 2 * u.v)
fs = Group((; src = PinnedSrc(), fw = FwdScalar(), k = SinkS()); local_wires = ("src/v" => "fw/v", "fw/v" => "k/v"))
r = tryit(() -> Model(build(fs), D8; Δt_frame = 1//10))
show1("H scalar forward at dual", r isa Model ? (typeof(port(r, "fw", :v)), typeof(port(r, "k", :w))) : r)

# local rule
c_lookup(tb, u) = sin(u)
struct Table <: AbstractComponent end
x_init(::Table) = nothing
u_types(::Table) = (u = Float64,)
y_types(::Table) = (y = Float64,)
y_direct(tb::Table, (; u)) = (; y = lookup(tb, u.u))
lookup(tb, u::Float64) = c_lookup(tb, u)
function lookup(tb, u::ForwardDiff.Dual{Tag}) where {Tag}
    u0 = ForwardDiff.value(u)
    y0 = c_lookup(tb, u0)
    h  = sqrt(eps(u0))
    dy = (c_lookup(tb, u0 + h) - y0) / h
    return ForwardDiff.Dual{Tag}(y0, dy * ForwardDiff.partials(u))
end
struct Osc <: AbstractComponent end
x_init(::Osc) = (q = 0.7,)
x_deriv(::Osc, (; x)) = (q = 0.0,)
y_types(::Osc) = (q = Float64,)
y_state(::Osc, (; x)) = (; q = x.q)
tm = Group((; o = Osc(), t = Table()); local_wires = ("o/q" => "t/u",), output_wires = ("t/y" => "y",))
s4 = Simulation(tm; Δt_frame = 1//10)
init!(s4, set())
lin4 = tryit(() -> linearize(s4, taps(x = (q = get_state("o", :q),), u = (;), y = (y = get_face(:y),))))
show1("H local rule C vs cos(0.7)", lin4 isa Exception ? lin4 : (lin4.C, cos(0.7)))

# section 6
struct Mixed{T}
    a::T
    b::Int
end
struct MixedRight{T}
    a::T
    b::Float64
end
struct TwoParam{A,B}
    a::A
    b::B
end
show1("S6 retype MixedRight", retype(D8, MixedRight{Float64}))
show1("S6 retype Mixed", retype(D8, Mixed{Float64}))
show1("S6 retype_entry Pinned", retype_entry(D8, Pinned{Mixed{Float64}}))
show1("S6 MixedRight ctor with Dual b", tryit(() -> MixedRight(px, px)))
show1("S6 MixedRight ctor with Dual a, Float b", typeof(tryit(() -> MixedRight(px, 2.0))))
show1("S6 MixedRight{P}(px, px) explicit", tryit(() -> MixedRight{P}(px, px)))
struct ProdM <: AbstractComponent end
x_init(::ProdM) = (q = 1.0,)
x_deriv(::ProdM, (; x)) = (q = 0.0,)
y_types(::ProdM) = (m = MixedRight{Float64},)
y_state(::ProdM, (; x)) = (; m = MixedRight(x.q, 2.0))
r = tryit(() -> Model(build(Group((; p = ProdM()))), D8; Δt_frame = 1//10))
show1("S6 MixedRight cell at dual", r isa Model ? typeof(port(r, "p", :m)) : r)
struct ProdBad <: AbstractComponent end
x_init(::ProdBad) = (q = 1.0,)
x_deriv(::ProdBad, (; x)) = (q = 0.0,)
y_types(::ProdBad) = (m = MixedRight{Float64},)
y_state(::ProdBad, (; x)) = (; m = MixedRight(x.q, x.q))
r = tryit(() -> Model(build(Group((; p = ProdBad()))), D8; Δt_frame = 1//10))
show1("S6 MixedRight bad b at dual", r isa DiagnosticError ? [(typeof(d).name.name, message(d)) for d in dlist(r)] : (r isa Model ? :ok : r))
r2 = tryit(() -> build(Group((; p = ProdBad())); activations = (Float64, ProbeDual)))
show1("S6 MixedRight bad b ProbeDual", r2 isa DiagnosticError ? [(typeof(d).name.name) for d in dlist(r2)] : (r2 isa Exception ? r2 : :ok))
struct ProdNested <: AbstractComponent end
x_init(::ProdNested) = nothing
y_types(::ProdNested) = (m = TwoParam{Float64,Pinned{Float64}},)
y_direct(::ProdNested, _) = (; m = TwoParam(1.0, 2.0))
r = tryit(() -> build(Group((; p = ProdNested()))))
show1("S6 nested marker", r isa DiagnosticError ? [(typeof(d).name.name, message(d)) for d in dlist(r)] : (r isa Exception ? r : :ok))
struct ProdPinMixed <: AbstractComponent end
x_init(::ProdPinMixed) = (q = 1.0,)
x_deriv(::ProdPinMixed, (; x)) = (q = 0.0,)
y_types(::ProdPinMixed) = (m = Pinned{Mixed{Float64}},)
y_state(::ProdPinMixed, (; x)) = (; m = Mixed(2.0, 3))
r = tryit(() -> Model(build(Group((; p = ProdPinMixed()))), D8; Δt_frame = 1//10))
show1("S6 Pinned{Mixed{Float64}}", r isa Model ? typeof(port(r, "p", :m)) : (r isa DiagnosticError ? [(typeof(d).name.name) for d in dlist(r)] : r))
struct ProdMixed <: AbstractComponent end
x_init(::ProdMixed) = (q = 1.0,)
x_deriv(::ProdMixed, (; x)) = (q = 0.0,)
y_types(::ProdMixed) = (m = Mixed{Float64},)
y_state(::ProdMixed, (; x)) = (; m = Mixed(x.q, 3))
r = tryit(() -> Model(build(Group((; p = ProdMixed()))), D8; Δt_frame = 1//10))
show1("S6 Mixed cell at dual", r isa Model ? typeof(port(r, "p", :m)) : r)

# grid-as-T handle copies
struct DeckT{T}
    heave::T
    grid::Matrix{T}
end
show1("H retype DeckT", retype(D8, DeckT{Float64}))
show1("H fieldtypes DeckT{D8}", fieldtypes(retype(D8, DeckT{Float64})))
show1("H retype Matrix{Float64} entry", retype(D8, Matrix{Float64}))
println("DONE")
# extra: loop through discrete B with stage-1 output
struct BS <: AbstractComponent end
s_init(::BS) = (n = 0.0,)
u_types(::BS) = (a = Float64,)
y_types(::BS) = (b = Float64,)
y_state(::BS, (; s)) = (b = s.n,)
s_update(::BS, (; s, u)) = (n = s.n + u.a,)
loopS = Group((; a = AFT(), b = BS()); local_wires = ("a/a" => "b/a", "b/b" => "a/b"))
show1("F loop through discrete y_state B builds", tryit(() -> build(loopS) isa Redstone.Build))

# pinned moving deck: without strip, with strip
struct PinnedSea <: AbstractComponent
    grid::Matrix{Float64}
end
x_init(::PinnedSea) = (heave = 0.0, pitch = 0.0)
x_deriv(::PinnedSea, (; x)) = (heave = 0.0, pitch = 0.0)
y_types(::PinnedSea) = (terrain = Pinned{DeckField{Float64}},)
y_state(c::PinnedSea, (; x)) = (; terrain = DeckField(x.heave, x.pitch, c.grid))
r = tryit(() -> Model(build(gear_with(PinnedSea(grid))), D8; Δt_frame = 1//10))
show1("H pinned sea no strip at dual", r isa Model ? :ok : kindsof(r))
struct PinnedSeaStrip <: AbstractComponent
    grid::Matrix{Float64}
end
x_init(::PinnedSeaStrip) = (heave = 0.0, pitch = 0.0)
x_deriv(::PinnedSeaStrip, (; x)) = (heave = 0.0, pitch = 0.0)
y_types(::PinnedSeaStrip) = (terrain = Pinned{DeckField{Float64}},)
y_state(c::PinnedSeaStrip, (; x)) = (; terrain = DeckField(ForwardDiff.value(x.heave), ForwardDiff.value(x.pitch), c.grid))
s5 = Simulation(gear_with(PinnedSeaStrip(grid)); Δt_frame = 1//10)
init!(s5, set())
r = tryit(() -> linearize(s5, taps(x = (heave = get_state("src", :heave), p1 = get_state("gear", "p[1]")), u = (;), y = (clearance = get_face(:clearance),))))
show1("H pinned sea strip linearize C", r isa Exception ? first(sprint(showerror, r), 300) : r.C)
# MixedRight leaves
show1("S6 MixedRight{D8} fieldtypes", fieldtypes(MixedRight{D8}))
println("DONE2")
