# Prototype behind D-473, run on 2026-11-21 against d8089d7, before any change to
# `Group`. `DGroup` is a stand-in with the copy constructor and the wire keywords
# that take a function of the group, so the repo stayed untouched.
#   julia --project=examples design/increments/20261121_group_promotion/probe_deferred_keywords.jl
using Redstone, RedstoneExamples
import Redstone: AbstractComponent, local_wires, input_wires, output_wires, sample_times,
                 transparent_container, input_passthrough, output_passthrough, build
import Redstone.Library: StopRequest
const RE = RedstoneExamples

# a stand-in for Group with the two proposed fixes, so the repo stays untouched
struct DGroup{C <: NamedTuple, W, I, O, R <: NamedTuple} <: AbstractComponent
    children::C
    local_wires::W
    input_wires::I
    output_wires::O
    sample_times::R
end
DGroup(children; local_wires = (), input_wires = (), output_wires = (), sample_times = (;)) =
    DGroup(children, local_wires, input_wires, output_wires, sample_times)
DGroup(g::DGroup; children = g.children, local_wires = g.local_wires, input_wires = g.input_wires,
       output_wires = g.output_wires, sample_times = g.sample_times) =
    DGroup(children; local_wires, input_wires, output_wires, sample_times)

_entries(wires::Pair) = (wires,)
_entries(wires) = wires
_declared(f::Function, g) = _entries(f(g))
_declared(wires, g) = _entries(wires)
local_wires(g::DGroup)  = _declared(g.local_wires, g)
input_wires(g::DGroup)  = _declared(g.input_wires, g)
output_wires(g::DGroup) = _declared(g.output_wires, g)
sample_times(g::DGroup) = g.sample_times
transparent_container(::DGroup) = :children

solution = (θ = 0.02, δe = -0.05, δt = 0.4)
kids() = (; vehicle = RE.piloted(solution), gear = RE.GroundContact(), stop = StopRequest(reason = "touchdown"))
wires = ("vehicle/h" => "gear/h", "gear/contact" => "stop/u")

g = DGroup(kids(); input_wires = g -> input_passthrough(g, "vehicle"; prefix = ""), local_wires = wires)

println("1. the field holds: ", g.input_wires isa Function ? "a function" : "data")
println("2. the accessor returns: ", input_wires(g))
println("3. same as today's approach: ", input_wires(g) == input_wires(RE.approach(solution)))
b = build(g)
println("4. builds: ", b isa Redstone.Build, ", warnings: ", length(b.warnings))

println("5. a selector that keeps nothing, inside the build:")
w = DGroup(g; output_wires = g -> output_passthrough(g, "vehicle"; select = _ -> false))
bw = build(w)
foreach(d -> println("   on the build's list: ", Redstone.logline(d)), bw.warnings)

println("6. swap the child, keep the function:")
swapped = DGroup(g; children = merge(g.children, (; vehicle = RE.autopilot(solution))))
println("   ", input_wires(swapped))
