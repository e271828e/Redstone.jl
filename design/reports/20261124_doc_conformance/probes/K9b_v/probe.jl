# K9b verifier probes. Run from W with --project=test.
using Redstone, StaticArrays, ForwardDiff
import Redstone: AbstractComponent, x_init, s_init, u_types, y_types, y_state, y_direct, x_deriv,
    Pinned, Group, build, Build, DiagnosticError, diagnostics, AlgebraicCycle, LinearizeDual,
    Simulation, init!, linearize, taps, get_state, retype, leaf_types
using Redstone.Library: Freeze, UnitDelay
p(tag, x) = println(tag, " => ", x)
catcherr(f) = try f(); nothing catch e; e end
showdiags(tag, e) = e isa DiagnosticError ? foreach(d -> p(tag, (typeof(d), sprint(show, d)[1:min(end, 300)])), diagnostics(e)) : p(tag, e === nothing ? "no error" : sprint(showerror, e)[1:min(end, 400)])

# --- frozen discrete walkthrough -------------------------------------------
struct CA <: AbstractComponent end
x_init(::CA) = (q = 1.0,)
y_types(::CA) = (y = Float64,)
y_state(::CA, (; x)) = (y = x.q,)
x_deriv(::CA, (; x)) = (q = -x.q,)

struct DG <: AbstractComponent end               # discrete feedthrough B
s_init(::DG) = nothing
u_types(::DG) = (e = Float64,)
y_types(::DG) = (o = Float64,)
y_direct(::DG, (; u)) = (o = 2u.e,)

struct CG <: AbstractComponent end               # continuous feedthrough, for contrast
x_init(::CG) = nothing
u_types(::CG) = (e = Float64,)
y_types(::CG) = (o = Float64,)
y_direct(::CG, (; u)) = (o = 2u.e,)

struct CC <: AbstractComponent end
x_init(::CC) = (q = 0.0,)
u_types(::CC) = (u = Float64,)
y_types(::CC) = (q = Float64,)
y_state(::CC, (; x)) = (q = x.q,)
x_deriv(::CC, (; x, u)) = (q = u.u - x.q,)

chain(b) = Group((; a = CA(), b = b, c = CC()); local_wires = ("a/y" => "b/e", "b/o" => "c/u"))
lt = taps(x = (a = get_state("a", :q), c = get_state("c", :q)))
for (tag, b) in (("discrete B", DG()), ("continuous B", CG()))
    sim = Simulation(chain(b); Δt_frame = 1//10); init!(sim)
    lin = linearize(sim, lt)
    p("K9b-012 A via $tag", lin.A)
end

# K9b-014 a loop closed through a discrete feedthrough B
struct CF <: AbstractComponent end                # continuous feedthrough A
x_init(::CF) = nothing
u_types(::CF) = (e = Float64,)
y_types(::CF) = (o = Float64,)
y_direct(::CF, (; u)) = (o = u.e + 1.0,)
loop_dg = Group((; a = CF(), b = DG()); local_wires = ("a/o" => "b/e", "b/o" => "a/e"))
showdiags("K9b-014 loop through discrete y_direct", catcherr(() -> build(loop_dg)))
loop_ud = Group((; a = CF(), d = UnitDelay(0.0)); local_wires = ("a/o" => "d/u", "d/y" => "a/e"))
p("K9b-014 loop through UnitDelay (y_state)", catcherr(() -> build(loop_ud)) === nothing ? "builds" : "refused")

# --- handle walkthrough ----------------------------------------------------
struct DeckField{T}
    heave::T
    pitch::T
    grid::Matrix{Float64}
end
const GRID = [0.1 * i for i in 1:10, j in 1:10]
function height(f::DeckField, p::SVector{3})
    x = p[1] * cos(f.pitch) - p[3] * sin(f.pitch)
    y = p[2]
    i, j = floor(Int, x), floor(Int, y)
    a, b = x - i, y - j
    g = f.grid
    z = (1 - a) * (1 - b) * g[i, j] + a * (1 - b) * g[i+1, j] +
        (1 - a) * b * g[i, j+1] + a * b * g[i+1, j+1]
    return z + f.heave
end
const SEEN = Ref{Any}(nothing)
struct Gear <: AbstractComponent end
x_init(::Gear) = (p = SVector(3.5, 4.5, 2.0),)
x_deriv(::Gear, (; x)) = (p = zero(x.p),)
u_types(::Gear) = (terrain = DeckField{Float64},)
y_types(::Gear) = (clearance = Float64,)
function y_direct(g::Gear, (; x, u))
    eltype(x.p) === Float64 || (SEEN[] = (typeof(u.terrain.heave), typeof(u.terrain.pitch), eltype(x.p)))
    (; clearance = x.p[3] - height(u.terrain, x.p))
end
struct StaticTerrain <: AbstractComponent
    datum::Float64
    grid::Matrix{Float64}
end
x_init(::StaticTerrain) = nothing
y_types(::StaticTerrain) = (terrain = Pinned{DeckField{Float64}},)
y_direct(c::StaticTerrain, _) = (; terrain = DeckField(c.datum, 0.0, c.grid))
struct SeaMotion <: AbstractComponent
    grid::Matrix{Float64}
end
x_init(::SeaMotion) = (heave = 0.1, pitch = 0.05)
x_deriv(::SeaMotion, (; x)) = (heave = -x.heave, pitch = -x.pitch)
y_types(::SeaMotion) = (terrain = DeckField{Float64},)
y_state(c::SeaMotion, (; x)) = (; terrain = DeckField(x.heave, x.pitch, c.grid))
struct PinnedSea <: AbstractComponent             # the moving deck, pinned
    grid::Matrix{Float64}
end
x_init(::PinnedSea) = (heave = 0.1, pitch = 0.05)
x_deriv(::PinnedSea, (; x)) = (heave = -x.heave, pitch = -x.pitch)
y_types(::PinnedSea) = (terrain = Pinned{DeckField{Float64}},)
y_state(c::PinnedSea, (; x)) = (; terrain = DeckField(x.heave, x.pitch, c.grid))

acts = (Float64, LinearizeDual)
static_rig = Group((; t = StaticTerrain(0.0, GRID), g = Gear()); local_wires = ("t/terrain" => "g/terrain",))
sea_rig = Group((; t = SeaMotion(GRID), g = Gear()); local_wires = ("t/terrain" => "g/terrain",))
pinned_rig = Group((; t = PinnedSea(GRID), g = Gear()); local_wires = ("t/terrain" => "g/terrain",))
showdiags("K9b-023 static terrain -> gear", catcherr(() -> build(static_rig; activations = acts)))
SEEN[] = nothing
showdiags("K9b-023 sea motion -> gear", catcherr(() -> build(sea_rig; activations = acts)))
p("K9b-034 types seen in gear y_direct under Dual (heave, pitch, eltype p)", SEEN[])
showdiags("K9b-027 pinned moving deck -> gear", catcherr(() -> build(pinned_rig; activations = acts)))
sim = Simulation(sea_rig; Δt_frame = 1//10); init!(sim)
p("K9b-027 sea rig ∂ẋ_gear... (A over heave,pitch)", linearize(sim, taps(x = (h = get_state("t", :heave), q = get_state("t", :pitch)))).A)

# K9b-041 the Matrix{T} grid: does any rule refuse the copy?
struct DeckFieldT{T}
    heave::T
    pitch::T
    grid::Matrix{T}
end
p("K9b-041 retype(LinearizeDual, DeckFieldT{Float64})", retype(LinearizeDual, DeckFieldT{Float64}))
p("K9b-041 its grid field", fieldtype(retype(LinearizeDual, DeckFieldT{Float64}), :grid))
struct H{G}; grid::G; end
p("K9b-041 retype(LinearizeDual, H{Matrix{Float64}}) (mutable parameter)", retype(LinearizeDual, H{Matrix{Float64}}))
struct SeaT <: AbstractComponent
    grid::Matrix{Float64}
end
x_init(::SeaT) = (heave = 0.1, pitch = 0.05)
x_deriv(::SeaT, (; x)) = (heave = -x.heave, pitch = -x.pitch)
y_types(::SeaT) = (terrain = DeckFieldT{Float64},)
y_state(c::SeaT, (; x)) = (; terrain = DeckFieldT{typeof(x.heave)}(x.heave, x.pitch, c.grid))  # copies the grid
struct GearT <: AbstractComponent end
x_init(::GearT) = (q = 0.0,)
x_deriv(::GearT, (; x, u)) = (q = u.terrain.heave + u.terrain.grid[1, 1] - x.q,)
u_types(::GearT) = (terrain = DeckFieldT{Float64},)
y_types(::GearT) = (q = Float64,)
y_state(::GearT, (; x)) = (q = x.q,)
rigT = Group((; t = SeaT(GRID), g = GearT()); local_wires = ("t/terrain" => "g/terrain",))
showdiags("K9b-041 Matrix{T} grid producer builds under Dual?", catcherr(() -> build(rigT; activations = acts)))

# K9b-052 / K9b-055 Freeze
showdiags("K9b-052 Freeze{DeckField{Float64}}", catcherr(() -> Freeze{DeckField{Float64}}))
d = LinearizeDual(1.5, ForwardDiff.Partials(ntuple(i -> Float64(i), Redstone.LINEARIZE_WIDTH)))
p("K9b-055 Freeze y_direct on a Dual", y_direct(Freeze{Float64}(), (; u = d)))
p("K9b-055 y_types(Freeze{Float64}())", y_types(Freeze{Float64}()))

# K9b-065 / K9b-067 MixedRight
struct MixedRight{T}
    a::T
    b::Float64
end
MRD = retype(LinearizeDual, MixedRight{Float64})
p("K9b-065 retype", MRD)
p("K9b-065 leaf_types", leaf_types(MRD))
e = catcherr(() -> MixedRight{LinearizeDual}(d, d))
p("K9b-067 constructing with a Dual b", sprint(showerror, e)[1:min(end, 300)])
p("K9b-067 which(convert, (Type{Float64}, LinearizeDual))", which(convert, (Type{Float64}, LinearizeDual)))
