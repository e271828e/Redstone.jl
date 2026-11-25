module K7b
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const T = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/"
include(T * "imports.jl"); include(T * "fixtures.jl"); include(T * "utils.jl")

p(args...) = println("PROBE ", args...)

# --- single rate: TickCounter y = n, s_update n+1
sim = Simulation(single(TickCounter()); Δt_frame = 1//10)
init!(sim)
p("after init! state=", state(sim,"c").n, " port=", port(sim,"c",:n), " (s(1) after init)")   # probe:A
step!(sim; frames = 3)
p("k=3 port=", port(sim,"c",:n), " state=", state(sim,"c").n, " nlogged=", length(logged(sim)))
chk = checkpoint(sim)
p("checkpoint fields ", fieldnames(typeof(chk.state)), " s=", chk.state.s)
p("snapshot fields ", fieldnames(typeof(latest(sim))))
sim.run.frame |> x -> p("run.frame ", x)
n0 = length(logged(sim))
restore!(sim, chk)
p("restore! logged ", length(logged(sim)), " latest t=", latest(sim).t, " boundary=", latest(sim).boundary, " (chk t=", chk.state.t, ")")
p("restored port=", port(sim,"c",:n), " state=", state(sim,"c").n)
step!(sim)
p("after step port=", port(sim,"c",:n), " (recording would publish 4) state=", state(sim,"c").n)
# recorded continuation
ref = Simulation(single(TickCounter()); Δt_frame = 1//10); init!(ref); step!(ref; frames = 4)
p("ref k=4 port=", port(ref,"c",:n), " state=", state(ref,"c").n)
# condition from copied
copied = state(ref, "c")   # not used
s_copied = chk.state.s[1]
p("s_copied ", s_copied)
sim2 = Simulation(single(TickCounter()); Δt_frame = 1//10)
init!(sim2, at("c", set(s = s_copied)); t0 = 3//10)
p("init! from copy port=", port(sim2,"c",:n), " state=", state(sim2,"c").n, " recording had port 3 state 4 at t_k")
step!(sim2; frames = 3)
ref3 = Simulation(single(TickCounter()); Δt_frame = 1//10); init!(ref3); step!(ref3; frames = 6)
p("3 frames later copy port=", port(sim2,"c",:n), " recording port=", port(ref3,"c",:n), " (counter reads +1 every tick?)")
# sketch form: positional t_k and model
try
    m = Model(single(TickCounter()); Δt_frame = 1//10)
    init!(m, at("c", set(s = s_copied)), 3//10)
    p("positional t0 accepted")
catch e
    p("positional t0: ", typeof(e), " ", sprint(showerror, e)[1:min(end,200)])
end
try
    sc = Simulation(single(TickCounter()); Δt_frame = 1//10)
    init!(sc.model, set())
catch e
    p("init!(claimed model): ", typeof(e), " ", sprint(showerror, first(Base.catch_stack())[1])[1:min(end,160)])
end
# overlay!
sim3 = Simulation(single(TickCounter()); Δt_frame = 1//10); init!(sim3); step!(sim3; frames = 3)
nb = length(logged(sim3)); tb = latest(sim3).t; bb = latest(sim3).boundary
overlay!(sim3, at("c", set(s = (n = 10,))))
p("overlay: logged ", nb, "->", length(logged(sim3)), " t ", tb, "->", latest(sim3).t, " port=", port(sim3,"c",:n), " state=", state(sim3,"c").n, " lifecycle=", lifecycle(sim3))
# overlay refused while built/running? errored
b = Simulation(single(TickCounter()); Δt_frame = 1//10)
try overlay!(b, set()) catch e; p("overlay on built: ", sprint(showerror, e)[1:min(end,150)]) end
# overlay header
p("trace header after overlay: ", sim3.run.trace === nothing ? nothing : typeof(sim3.run.trace.header))

# --- multirate
ml = Simulation(SampledLoop(; ctl_rate = Relative(2)); Δt_frame = 1//200, Δt_base = 1//100)
init!(ml, set(u = (ref = 0.7,)))
for k in 0:9
    p("ml frame ", k, " cell u=", port(ml,"ctl",:u), " store acc=", state(ml,"ctl").acc)
    step!(ml)
end
# condition at non-due frame: lattice re-anchor
ml2 = Simulation(SampledLoop(; ctl_rate = Relative(2)); Δt_frame = 1//200, Δt_base = 1//100)
init!(ml2, set(u = (ref = 0.7,))); step!(ml2; frames = 5)
acc = state(ml2,"ctl").acc
ml3 = Simulation(SampledLoop(; ctl_rate = Relative(2)); Δt_frame = 1//200, Δt_base = 1//100)
init!(ml3, combine(set(u = (ref = 0.7,)), at("ctl", set(s = (acc = acc,)))); t0 = 5//200)
p("ml3 at boundary zero: cell u=", port(ml3,"ctl",:u), " acc=", state(ml3,"ctl").acc, "  ml2 store acc=", acc)
end # module
