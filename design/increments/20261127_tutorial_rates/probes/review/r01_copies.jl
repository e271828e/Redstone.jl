# r01: my copies of the builders fly bit-identically to the source's at the shipped values, so the
# figures below that vary a knob vary only that knob.
include(joinpath(@__DIR__, "r00_common.jl"))
solution = trim_solution()
a = climb(RE.autopilot(solution), solution); b = climb(my_autopilot(solution), solution)
cols(s, p) = series(s, reads(h = get_output(p == "" ? "plant" : "$p/plant", :h), V = get_output(p == "" ? "plant" : "$p/plant", :V), q = get_output(p == "" ? "plant" : "$p/plant", :q))).columns
println("autopilot copy identical: ", cols(a, "") == cols(b, ""))
p1 = hand_sim(RE.piloted(solution), solution)
p2 = hand_sim(my_piloted(solution), solution)
println("piloted copy identical: ", cols(p1, "") == cols(p2, ""))
