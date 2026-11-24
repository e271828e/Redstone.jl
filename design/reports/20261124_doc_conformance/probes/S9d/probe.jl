module S9d
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
macro P(ex) # print value with line
    :(println("probe:", $(__source__.line), "  ", $(string(ex)), " => ", repr($(esc(ex)))))
end

# --- roster
fb = Simulation(feedback_model(); Δt_frame = 1//100)
b = phase_bodies(fb)
@P keys(b)
@P b.ticks()
@P b.ticks(3)
@P (isempty(b.events), isempty(b.projections))
@P typeof(b.rhs).name.name
@P (b.rhs(3); :ok)                       # rhs takes an index? 
@P map(n -> @ballocated($(b[n])()), (:sweep_1,:sweep_2,:rhs,:ticks))
@P map(n -> @ballocated($(b[n])(1)), (:sweep_1,:sweep_2,:rhs,:ticks))
@P Redstone.phase_bodies(fb.model) === b
# --- multirate
mr = Simulation(MultiRate(); Δt_frame = 1//500); init!(mr)
bm = phase_bodies(mr)
for n in (:sweep_1,:sweep_2,:rhs,:ticks)
    body = getfield(bm, n)
    println("probe:", @__LINE__, "  ", n, " interior=", map(typeof, walked(body,:interior)) .|> (t->t.name.name),
        " boundary=", [e isa Gated ? (:Gated, typeof(e.entry).name.name, e.D, e.Φ) : typeof(e).name.name for c in body.boundary for e in c.entries])
end
@P fieldnames(typeof(first(bm.sweep_2.boundary).entries[end]))
# tiers in stage 1
s1 = [e for c in bm.sweep_1.boundary for e in c.entries]
@P [(e isa Gated ? :disc : :cont, (e isa Gated ? e.entry : e).path) for e in s1]
s2 = [e for c in bm.sweep_2.boundary for e in c.entries]
@P [(e isa Gated ? :disc : :cont, (e isa Gated ? e.entry : e).path) for e in s2]
@P [(e isa Gated ? e.entry : e).path for e in [e for c in bm.ticks.boundary for e in c.entries]]
# arity: zero-arg has no discrete
@P any(e isa Gated for c in bm.sweep_2.interior for e in c.entries)
@P (length(bm.sweep_2.interior), length(bm.sweep_2.boundary))
# isolation: ticks entries advance state w/o clock advance
tc = Simulation(single(TickCounter()); Δt_frame = 1//10); init!(tc)
t0 = tc.model.exec.clock.t
n0 = state(tc, "c").n
bt = phase_bodies(tc)
bt.ticks(1)
@P (t0, tc.model.exec.clock.t, n0, state(tc, "c").n, port(tc,"c",:n))
bt.sweep_1(1)
@P port(tc,"c",:n)
@P ((latest(tc).frame), tc.model.exec.clock.t)
# two instances share entry type, one body
forty = Group(NamedTuple{ntuple(i -> Symbol(:m, i), 40)}(ntuple(_ -> feedback_model(), 40));
              input_wires = ("ref" => ntuple(i -> "m$(i)/ref", 40),))
f = Simulation(forty; Δt_frame = 1//100)
ents = walked(f.model.exec.bodies.sweep_2, :interior)
@P (length(ents), length(unique(typeof.(ents))), length(f.model.exec.bodies.sweep_2.interior), f.model.exec.chunk_size)
@P ismutable(first(f.model.exec.bodies.sweep_2.interior))
@P ismutable(f.model.exec.events)
@P (typeof(first(f.model.exec.bodies.sweep_2.interior)).name.name)
# Entry fields
@P fieldnames(StageEntry)
@P fieldnames(Redstone.RHSEntry)
@P fieldnames(Redstone.UpdateEntry)
# Gate semantic at negative differences
@P (-1 - 2) % 4
# store per eltype
@P keys(tc.model.exec.store.stores)
@P keys(mr.model.exec.store.stores)
@P typeof(first(first(b.sweep_2.interior).entries).outputs)
@P fieldnames(Redstone.CellAddr)
# handle field
# Dual activation: a scratch model at another scalar
dm = Model(feedback_model(), D8; Δt_frame = 1//100)
@P keys(dm.exec.bodies)
@P Model(feedback_model(); Δt_frame = 1//100).exec.chunk_size
@P (try Model(feedback_model(); Δt_frame = 1//100, chunk_size=0); catch e; typeof(e) end)
rm = Simulation(Group((; rot = Rotor(), saw = Sawtooth(1.0))); Δt_frame = 1//100); init!(rm)
br = phase_bodies(rm)
@P (keys(br.events), keys(br.projections))
rd = Model(Group((; rot = Rotor(), saw = Sawtooth(1.0))), D8; Δt_frame = 1//100)
@P (length(rd.exec.bodies.events), length(rd.exec.bodies.projections), length(rd.exec.events.prior))
# opaque leaf: handle stored whole, inline in array, no allocation
@P Base.allocatedinline(HeightField)
hm = Simulation(handle_model(); Δt_frame = 1//100); init!(hm)
@P keys(hm.model.exec.store.stores)
hb = phase_bodies(hm)
@P map(n -> @ballocated($(hb[n])()), (:sweep_1,:sweep_2,:rhs,:ticks))
@P Redstone._opaque(Base.RefValue{Float64})
@P Redstone._opaque(HeightField)
# discrete tier with rate: ticks gate
d = Simulation(Group((; c = TickCounter()); sample_times = (c = Relative(2),)); Δt_frame = 1//10, Δt_base = 1//10); init!(d)
bd = phase_bodies(d)
@P [(e isa Gated ? (e.D, e.Φ) : :plain) for c in bd.ticks.boundary for e in c.entries]
@P [(e isa Gated ? (e.D, e.Φ) : :plain) for c in bd.sweep_1.boundary for e in c.entries]
@P (length(bd.ticks.interior), length(bd.sweep_1.interior), length(bd.sweep_2.interior))
n0 = state(d, "c").n
bd.ticks(1); a = state(d, "c").n
bd.ticks(2); b2 = state(d, "c").n
@P (n0, a, b2)
@P map(n -> @ballocated($(bd[n])()), (:sweep_1,:sweep_2,:rhs,:ticks))
@P map(n -> @ballocated($(bd[n])(2)), (:sweep_1,:sweep_2,:rhs,:ticks))
# Establish marker admits all
@P (bd.sweep_1(Redstone.ESTABLISH); :ok)
# log retention by reference and sizehint
@P fieldnames(Redstone.SnapshotLog)
end
