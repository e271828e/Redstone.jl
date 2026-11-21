# Probe behind D-473, run on 2026-11-21 against d8089d7, before any change to `Group`.
# It shows the two rough edges: a rebuild that forgets `sample_times` builds in
# silence, and a passthrough helper run outside a build warns to the log.
#   julia --project=examples design/increments/20261121_group_promotion/probe_edges.jl
using Redstone, RedstoneExamples
import Redstone.Library: Group
import Redstone: input_passthrough, input_wires, output_wires, local_wires, sample_times, build
const RE = RedstoneExamples
solution = (θ = 0.02, δe = -0.05, δt = 0.4)

# edge 2: the two-step workaround against approach's hand-written inputs
model = RE.approach(solution)
shell = Group(model.children)
computed = input_passthrough(shell, "vehicle"; prefix = "")
println("two-step equals hand-written: ", computed == input_wires(model))
println(computed)

# where a helper's warning goes outside a build
println("--- warning outside a build")
input_passthrough(shell, "vehicle"; select = _ -> false)

# edge 1: what a rebuild that forgets sample_times does
sel = RE.selection(solution)
forgot = Group(sel.children; local_wires = local_wires(sel), input_wires = input_wires(sel),
               output_wires = output_wires(sel))
println("--- forgotten sample_times")
println("original rates: ", sample_times(sel))
println("rebuilt rates:  ", sample_times(forgot))
b = try build(forgot) catch err; err end
println("rebuilt builds: ", b isa Redstone.Build, b isa Redstone.Build ? "" : sprint(showerror, b)[1:min(end, 600)])
