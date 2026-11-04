using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
include(joinpath(@__DIR__, "..", "..", "..", "..", "test", "imports.jl"))
struct LW <: AbstractComponent; x; z; zr; t; end
local_wires(::LW) = ("x/y" => "t/x", "z/y" => "t/z", "zr/y" => "t/z_ref")
kw = (K_fbk = SMatrix{1,1}(1.0), K_fwd = SMatrix{1,1}(1.0), K_int = SMatrix{1,1}(1.0))
mk(t) = LW(Constant(SVector(0.0)), Constant(SVector(0.0)), Constant(SVector(1.0)), t)
function msg(label, f)
    try
        println("OK ", label, " => ", f())
    catch e
        println("THROW ", label, " :: ", first(split(sprint(showerror, e), "\nStack"))[1:min(end,500)])
    end
end
let sim = Simulation(mk(LQRTracker(; kw...)); h = 1//10)
    init!(sim, set()); step!(sim; frames = 2)
    for sel in (get_state("t", :q), get_state("t", :x), get_state("t"), get_state("t", "[1]"), get_state("t", "q"))
        msg("LQR $sel", () -> series(sim, reads(v = sel)).columns.v[end])
    end
end
let sim = Simulation(mk(DiscreteLQRTracker(; kw...)); h = 1//10)
    init!(sim, set()); step!(sim; frames = 2)
    for sel in (get_state("t", :q), get_state("t", "q[1]"))
        msg("DLQR $sel", () -> series(sim, reads(v = sel)).columns.v[end])
    end
end
# a stale probe with a fake record
msg("stale with heartbeat 0.0, now=1.0", () -> stale(Redstone.WriterStatus("x", Any[], 0, Dict(), 0.0, :running); now = 1.0))
