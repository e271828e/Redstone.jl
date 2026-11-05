show_err(f) = try; r = f(); println("  -> ok: ", r); catch e; println("  -> ", typeof(e), ": ", first(sprint(showerror, e), 300)); end
fsrc() = Source(t -> 1000.0 * t)   # value of u encodes t
function seq(model, path, n; h=1//10, face=nothing, st=true, init=set())
    sim = Simulation(model; h=h); init!(sim, init)
    out = Any[face===nothing ? port(sim,path) : port(sim,path,face)]
    sts = Any[st ? state(sim,path) : nothing]
    for i in 1:n
        step!(sim; t_plus=h)
        push!(out, face===nothing ? port(sim,path) : port(sim,path,face)); push!(sts, st ? state(sim,path) : nothing)
    end
    (out, sts)
end
