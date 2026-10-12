# §4.4's sketch (spec 649–655), filled in so it runs: the plain map, the
# one-line stage, a bulk-data handle as an opaque leaf, and the abstract entry.
using Redstone, StaticArrays
include(joinpath(@__DIR__, "..", "..", "..", "..", "test", "imports.jl"))

struct ISAField; T_sl::Float64; p_sl::Float64; wind::SVector{3,Float64}; end
abstract type AbstractTerrainField end
struct TerrainField <: AbstractTerrainField; h::Vector{Float64}; end   # bulk data, frozen
airdata(f::ISAField, z) = f.p_sl * exp(-z / 8000)
height(t::TerrainField, i) = t.h[i]

struct Atmosphere <: AbstractComponent end
u_types(::Atmosphere) = (T_sl = Float64, p_sl = Float64, wind = SVector{3,Float64})
y_types(::Atmosphere) = (field = ISAField,)
x_init(::Atmosphere) = (;)
# the map: plain, pure, public — callable outside any sweep
atmospheric_field(atm::Atmosphere; T_sl, p_sl, wind) = ISAField(T_sl, p_sl, wind)
# the swept output stage: one line, nothing but the call
y_direct(atm::Atmosphere, (; u)) = (; field = atmospheric_field(atm; T_sl = u.T_sl, p_sl = u.p_sl, wind = u.wind))

const GRID = [0.0, 1.0, 2.0]
struct Terrain <: AbstractComponent end
x_init(::Terrain) = (;)
y_types(::Terrain) = (trn = TerrainField,)
y_state(::Terrain, (;)) = (; trn = TerrainField(GRID))

struct Strut <: AbstractComponent end
x_init(::Strut) = (z = 100.0,)
x_deriv(::Strut, (; x)) = (z = 0.0,)
u_types(::Strut) = (atm = ISAField, terrain = AbstractTerrainField)
y_types(::Strut) = (p = Float64, gnd = Float64)
y_direct(::Strut, (; x, u)) = (p = airdata(u.atm, x.z), gnd = height(u.terrain, 2))

struct World <: AbstractComponent; env::Atmosphere; trn::Terrain; strut::Strut; end
local_wires(::World) = ("env/field" => "strut/atm", "trn/trn" => "strut/terrain")
input_wires(::World) = ("T_sl" => "env/T_sl", "p_sl" => "env/p_sl", "wind" => "env/wind")

w = World(Atmosphere(), Terrain(), Strut())
b = build(w); println("built: ", b)
sim = Simulation(w; h = 1//100)
init!(sim, fragment(u = (T_sl = 288.15, p_sl = 101325.0, wind = SVector(0.0, 0.0, 0.0))))
s = latest(sim)
println("strut p = ", port(s, "strut", :p), ", gnd = ", port(s, "strut", :gnd))
println("same handle outside a sweep: ",
        atmospheric_field(Atmosphere(); T_sl = 288.15, p_sl = 101325.0, wind = SVector(0.0, 0.0, 0.0)) === port(s, "env", :field))
println("handle shares the frozen grid: ", port(s, "trn", :trn).h === GRID)
