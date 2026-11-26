# Probe: a Simulation after a throw at trim!'s committed-state evaluation.
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/hosted_catch_review/test"
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
include(joinpath(W, "imports.jl"))
include(joinpath(W, "utils.jl"))
import Redstone: logged, latest, termination, closed
say(t, x) = println(rpad(t, 48), " => ", x)
shape(f) = try r = f(); "returns " * repr(typeof(r)) catch e
    string(nameof(typeof(e)), ": ", first(split(sprint(showerror, e), '\n'), 4) |> l -> join(l, " | "))
end

struct FlipLag <: AbstractComponent end
x_init(::FlipLag) = (v = 1.0,)
y_types(::FlipLag) = (v = Float64,)
y_state(::FlipLag, (; x)) = (v = x.v,)
x_deriv(::FlipLag, (; x)) = (v = sqrt(x.v) - 1,)
x_projection(::FlipLag, x) = (v = -abs(x.v),)

problem = TrimProblem(; guess = (v = 1.0,), lower = (v = -Inf,), upper = (v = Inf,),
    condition = d -> at("c", set(x = (v = d.v,))), reads = reads(v̇ = get_deriv("c", :v)),
    residuals = (r, d) -> (rate = r.v̇,), tolerances = (rate = 1e-9,))

for prior in (:built, :initialized, :stopped)
    println("=== prior lifecycle: ", prior)
    sim = Simulation(single(FlipLag()); Δt_frame = 1//10)
    if prior !== :built
        init!(sim, at("c", set(x = (v = 4.0,))))   # projection moves to -4, sqrt(-4) at frame 1 though
    end
    say("lifecycle before", lifecycle(sim))
    err = failure(() -> trim!(sim, problem; baseline = set()))
    say("thrown", typeof(err))
    println(sprint(showerror, err))
    say("lifecycle after", lifecycle(sim))
    say("model.status", sim.model.status)
    say("state c", state(sim, "c"))
    say("run closed", closed(sim.run))
    say("run.trace header", sim.run.trace === nothing ? nothing : typeof(sim.run.trace.header))
    say("termination", termination(sim))
    say("trace(sim)", shape(() -> trace(sim)))
    say("logged(sim)", shape(() -> length(logged(sim))))
    say("latest(sim)", shape(() -> latest(sim).t))
    say("checkpoint(sim)", shape(() -> checkpoint(sim)))
    say("step!(sim)", shape(() -> step!(sim; frames = 1)))
    say("linearize(sim) default", shape(() -> linearize(sim, taps(x = (v = get_state("c", :v),), u = (;), y = (;)))))
    say("show(sim)", sprint(show, MIME"text/plain"(), sim) |> s -> replace(first(s, 300), '\n' => " | "))
    say("init!(sim) again", shape(() -> init!(sim, at("c", set(x = (v = 0.0,))))))
    say("lifecycle after init!", lifecycle(sim))
    say("trace after init!", shape(() -> trace(sim)))
    say("logged after init!", shape(() -> length(logged(sim))))
end
