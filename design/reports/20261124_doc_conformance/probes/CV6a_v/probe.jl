# CV6a verifier probes, run against W at cb398676.
using Redstone, StaticArrays, ForwardDiff
const R = Redstone
p(label, f) = try println(label, " => ", repr(f())) catch e; println(label, " THROWS ", typeof(e), ": ", sprint(showerror, e)[1:min(end,300)]) end

println("--- CV6a-043 TableBinding construction")
p("good", () -> R.TableBinding(a = (face = "x", deadzone = 0.1, expo = 0.5), b = (face = :y,)))
p("many bad", () -> R.TableBinding(a = (face = "x", deadzone = 1.0), b = 3, c = (face = 1,),
                                 d = (foo = 1,), e = (face = "z", expo = 1.5, bar = 2)))
p("many bad count", () -> try R.TableBinding(a = (face = "x", deadzone = 1.0), b = 3, c = (face = 1,),
                                 d = (foo = 1,), e = (face = "z", expo = 1.5, bar = 2)) catch e
                                 [(d.entry, d.reason) for d in e.carried] end)
p("non-numeric deadzone", () -> R.TableBinding(a = (face = "x", deadzone = "a")))
p("non-numeric expo", () -> R.TableBinding(a = (face = "x", expo = :big)))
p("deadzone 0 ok, expo 1 ok", () -> R.TableBinding(a = (face = "x", deadzone = 0, expo = 1)))
p("deadzone -0.1", () -> try R.TableBinding(a = (face = "x", deadzone = -0.1)) catch e; [(d.entry, d.reason) for d in e.carried] end)

println("--- CV6a-052 _condition")
tb = R.TableBinding(dz = (face = "a", deadzone = 0.2), ex = (face = "b", expo = 1.0),
                    both = (face = "c", deadzone = 0.5, expo = 0.5), raw = (face = "d",))
p("dz 0.1", () -> R._condition(0.1, tb.table.dz))
p("dz 0.6 (expect 0.5)", () -> R._condition(0.6, tb.table.dz))
p("dz 2.0 clamp", () -> R._condition(2.0, tb.table.dz))
p("dz -1.0", () -> R._condition(-1.0, tb.table.dz))
p("ex 0.5 (expect 0.125)", () -> R._condition(0.5, tb.table.ex))
p("both 0.75 (m=0.5 -> 0.5*0.5+0.5*0.125=0.3125)", () -> R._condition(0.75, tb.table.both))
p("both -3 clamp -> -1", () -> R._condition(-3, tb.table.both))
p("raw 7 passthrough", () -> R._condition(7, tb.table.raw))
p("raw 0.5f0 passthrough type", () -> typeof(R._condition(0.5f0, tb.table.raw)))
p("map_input", () -> R.map_input((raw = 3, dz = 0.6), tb))

println("--- CV6a-019 nleaves")
struct HasSym; s::Symbol; end
@enum Col red green
p("nleaves Float64", () -> R.nleaves(Float64))
p("nleaves Tuple{Int,Bool,Float64}", () -> R.nleaves(Tuple{Int,Bool,Float64}))
p("nleaves NamedTuple{(:a,:c),Tuple{Int,Col}}", () -> R.nleaves(NamedTuple{(:a,:c),Tuple{Int,Col}}))
p("nleaves HasSym", () -> R.nleaves(HasSym))
p("nleaves Symbol", () -> R.nleaves(Symbol))

println("--- CV6a-022 leaf_eltypes")
struct Mix; n::Int; v::SVector{2,Float64}; b::Bool; m::Int; end
p("leaf_types Mix", () -> R.leaf_types(Mix))
p("leaf_eltypes Mix", () -> R.leaf_eltypes(Mix))

println("--- CV6a-032 retype_value")
const D = ForwardDiff.Dual{Nothing,Float64,2}
struct PoseNP; x::Float64; end
struct PoseP{T}; x::T; n::Int; end
p("nt mix Float32", () -> R.retype_value(Float32, (h = 1.0, n = 3, b = true, g = red, s = :k)))
p("SVector Dual", () -> typeof(R.retype_value(D, SVector(1.0, 2.0))))
p("PoseP Float32", () -> R.retype_value(Float32, PoseP(1.0, 2)))
p("PoseNP Float32", () -> R.retype_value(Float32, PoseNP(1.0)))
p("PoseNP Dual", () -> R.retype_value(D, PoseNP(1.0)))
p("opaque HasSym", () -> R.retype_value(Float32, HasSym(:q)))

println("--- CV6a-011 capture_stores allocations")
b1 = R.StoreBundle((; Float64 = R.CellStore(zeros(4))))
b2 = R.StoreBundle((; Float64 = R.CellStore(zeros(4)), Int64 = R.CellStore(zeros(Int, 2))))
b3 = R.StoreBundle((; Float64 = R.CellStore(zeros(4)), Int64 = R.CellStore(zeros(Int, 2)),
                    Bool = R.CellStore(falses(3) |> collect)))
f(b) = R.capture_stores(b)
f(b1); f(b2); f(b3)
p("allocs 1 eltype", () -> @allocations f(b1))
p("allocs 2 eltypes", () -> @allocations f(b2))
p("allocs 3 eltypes", () -> @allocations f(b3))
p("allocs copy one vector", () -> (v = zeros(4); copy(v); @allocations copy(v)))

println("--- CV6a-015 activation_scalar")
p("activation_scalar", () -> R.activation_scalar(R.Clock{Float32}()))
