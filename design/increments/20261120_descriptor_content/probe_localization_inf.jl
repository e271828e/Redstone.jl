# A framework throw inside a step, framed as a component's (`pending.md`,
# Unordered). Run from a session opened with `test/repl.jl`, for `Bouncer`,
# and with the `isfinite` condition of D-470 removed from `Deployment`'s check
# of `localization_tol` in `src/deployment.jl`, since the constructor now
# refuses the value. The run throws at the bouncer's first crossing.
sim = Simulation(Group((; c = Bouncer(1.0, 0.315))); Δt_frame = 1//10, localization_tol = Inf)
println("deployed with localization_tol = Inf")
init!(sim)
try
    run!(sim; t_end = 2.0)
    println("run! returned; modes = ", modes(sim, "c"))
catch err
    println("run! threw ", typeof(err))
    showerror(stdout, err, catch_backtrace()); println()
end
