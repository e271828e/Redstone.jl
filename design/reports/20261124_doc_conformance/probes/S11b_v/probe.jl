# S11b verifier probes. Run from W with --project=test.
using Test
include(joinpath(pwd(), "test", "repl.jl"))
using Redstone
two_root_inputs() = Group((; s = Sum(sa = 1.0, sb = 1.0));
                    input_wires = ("a" => "s/a", "b" => "s/b"))
hring(sim) = (@atomic sim.plane.harness_diag.batch).ring
dring(h) = (@atomic h.diag_cell.batch).ring
say(tag, x...) = println(tag, " => ", x...)

mutable struct Boom <: AbstractDevice; n::Int; end
Redstone.loop(::Boom, handle) = error("boom")

# P1 (001/010): a non-root face and a slash path through the harness writer
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
init!(sim, set(u = (a = 0.0, b = 0.0)))
stage!(sim, "s/a" => 5.0, "s/y" => 1.0)
say("P1 harness slash/internal", [(typeof(d), d.face) for d in hring(sim)])
step!(sim; frames = 1)
say("P1 port a after", port(sim, "", :a))
r = try attach!(sim, Pad("x"), Enumerated("s/a")); "attached" catch e; typeof(diagnostic(e)) end
say("P1 slash claim at attach", r)

# P2 (019/028): claim registered at attach; device out-of-claim, claimed or not
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
h1 = attach!(sim, Pad("j"), Enumerated("a"))
say("P2 claimedby after attach", sim.plane.claimedby)
h2 = attach!(sim, Pad("peer"), Enumerated())
init!(sim, set(u = (a = 0.0, b = 0.0)))
stage!(h2, "a" => 1.0, "b" => 2.0)
say("P2 device out-of-claim kinds", [(typeof(d), d.face, d.incumbent) for d in dring(h2)])

# P3 (038): no greedy default
struct InOnly <: AbstractBinding end
Redstone.is_input(::InOnly) = true
Redstone.claims(::InOnly) = ("a",)
say("P3 default is_greedy", is_greedy(InOnly()), " ", is_greedy(Enumerated("a")))
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
h = attach!(sim, Pad("q"), InOnly())
say("P3 non-greedy claim", h.writer.faces)

# P4 (047): stopped harness batch renormalized at attach
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
init!(sim, set(u = (a = 0.0, b = 0.0)))
stage!(sim, "a" => 7.0, "b" => 8.0)
attach!(sim, Pad("late"), Enumerated("a"))
say("P4 renorm diag", [(typeof(d), d.face, d.site) for d in hring(sim)])
say("P4 harness faces", sim.plane.harness.faces)
step!(sim; frames = 1)
say("P4 ports a,b", (port(sim, "", :a), port(sim, "", :b)))

# P5 (056): attach/detach from a running loop
mutable struct Midrun <: AbstractDevice; sim::Any; out::Vector{Any}; end
function Redstone.loop(dev::Midrun, handle)
    push!(dev.out, try attach!(dev.sim, Pad("m"), Enumerated("b")); :ok catch e; typeof(diagnostic(e)) end)
    push!(dev.out, try detach!(dev.sim, dev); :ok catch e; typeof(diagnostic(e)) end)
    stop!(handle); nothing
end
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
md = Midrun(sim, Any[])
attach!(sim, md, NoClaim())
init!(sim, set(u = (a = 0.0, b = 0.0)))
run!(sim; t_end = 10.0)
say("P5 mid-run attach/detach", md.out)

# P6 (058): roster types
say("P6 RosterEntry mutable?", ismutabletype(Redstone.RosterEntry), " roster type ", typeof(sim.plane.roster))

# P7 (066): two instances one type
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
ha = attach!(sim, Pad("j"), Enumerated("a")); hb = attach!(sim, Pad("j"), Enumerated("b"))
say("P7 two Pads", (ha.who, hb.who, length(sim.plane.roster)))

# P8 (075): death does not detach
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
attach!(sim, Boom(0), Enumerated("a"))
init!(sim, set(u = (a = 0.0, b = 0.0)))
Test.collect_test_logs() do; run!(sim; t_end = 0.5); end
say("P8 roster after crash", ([e.id for e in sim.plane.roster], sim.plane.claimedby, sim.plane.harness.faces))

# P9 (084/115/133): merge newest wins, convert, type mismatch
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
h = attach!(sim, Pad("g"), Enumerated("a", "b"))
init!(sim, set(u = (a = 0.0, b = 0.0)))
stage!(h, "a" => 1, "b" => 2.0); stage!(h, "a" => 3.0)
say("P9 pending merged", (@atomic h.writer.cell.pending)[])
stage!(h, "b" => "nope")
say("P9 mismatch", [(typeof(d), d.face) for d in dring(h)])
step!(sim; frames = 1)
say("P9 ports", (port(sim, "", :a), port(sim, "", :b)))
t = Threads.@spawn (stage!(h, "a" => 4.0); current_task())
say("P9 stage on other task ok", (fetch(t) !== current_task(), (@atomic h.writer.cell.pending)[]))

# P10 (096): map_input returns pairs
tb = TableBinding(x = (face = "a",), y = (face = :b, deadzone = 0.1))
mi = map_input((x = 0.5, y = 0.5), tb)
say("P10 map_input", (mi, typeof(mi)))

# P11 (106/124): greedy writer compiled like any, from layout types
sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
attach!(sim, Pad("e"), Enumerated("a"))
hg = attach!(sim, Pad("gui"), Greedy())
say("P11 greedy writer", (hg.writer.faces, hg.writer.types, typeof(hg.writer), sim.plane.harness.faces))
