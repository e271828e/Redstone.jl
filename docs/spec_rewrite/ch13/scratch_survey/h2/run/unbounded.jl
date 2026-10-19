# Checks that §13.5's unbounded run raises UnboundedRun into the loop's cell.
module H2Unbounded
include(joinpath(@__DIR__, "..", "..", "..", "..", "..", "..", "test", "repl.jl"))
s = Simulation(overloaded(); h = 1//50); init!(s)
t = Threads.@spawn run!(s; pace = 1.0, ignore_stop_requests = :all)
sleep(1.0); stop!(s); wait(t)
snaps = logged(s)
println(length(snaps), " snapshots; second status: ", snaps[2].status)
io = IOBuffer(); show(io, MIME"text/plain"(), snaps[2].status); println(String(take!(io)))
end
