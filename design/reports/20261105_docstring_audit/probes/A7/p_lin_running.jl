module P
include(joinpath(pwd(), "design/reports/20261105_docstring_audit/probes/A7/common.jl"))
function main()
    model = Model(Group((; c = Pendulum()); input_wires = ("in" => "c/u",)); h = 1//100)
    sim = Simulation(model)
    init!(sim, combine(at("c", set(x = (θ = 0.3, ω = 0.0))), set(u = (in = 0.0,))))
    attach!(sim, TailProbe(), NoClaim())
    task = Threads.@spawn run!(sim; t_end = 3.0e5)
    deadline = time() + 60
    while lifecycle(sim) !== :running && !istaskdone(task) && time() < deadline
        yield()
    end
    println("lifecycle ", lifecycle(sim), " model status ", model.status)
    tp = taps(x = (θ = get_state("c", :θ), ω = get_state("c", :ω)))
    outcomes = Dict{String,Int}()
    ts = Float64[]
    for i in 1:300
        try
            l = linearize(model, tp)
            outcomes["answered"] = get(outcomes, "answered", 0) + 1
            push!(ts, l.x₀.θ)
        catch e
            k = e isa DiagnosticError ? string(typeof(e)) : string(typeof(e), ":", first(sprint(showerror, e), 80))
            outcomes[k] = get(outcomes, k, 0) + 1
        end
        yield()
    end
    println("outcomes on the claimed running model: ", outcomes)
    println("x₀.θ distinct: ", length(unique(ts)))
    try
        linearize(sim, tp)
    catch e
        println("the simulation's method: ", typeof(e), " status ", diagnostic(e).status)
    end
    stop!(sim)
    t = time()
    while !istaskdone(task) && time() - t < 60
        sleep(0.05)
    end
    println("task done ", istaskdone(task))
end
main()
end
