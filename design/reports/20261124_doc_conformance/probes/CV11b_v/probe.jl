# CV11b verifier probes. Run from W with --project=test.
module P
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
include(joinpath(@__DIR__, "..", "..", "..", "..", "..", "..", "Redstone.jl-worktrees", "doc_conformance", "test", "imports.jl"))
include(joinpath(@__DIR__, "..", "..", "..", "..", "..", "..", "Redstone.jl-worktrees", "doc_conformance", "test", "fixtures.jl"))
const R = Redstone

# CV11b-059: fingerprint fields
model = Model(bare_world(); Δt_frame = 1//10)
init!(model, set(u = (u = 0.0, p = 0.0)))
fp = checkpoint(model).layout
println("059 sizes=", fp.sizes)
println("059 root_faces=", fp.root_faces)
println("059 paths=", fp.paths)
println("059 xtypes=", fp.xtypes); println("059 stypes=", fp.stypes); println("059 mtypes=", fp.mtypes)
println("059 addrs sorted=", issorted(first.(fp.addrs)), " n=", length(fp.addrs), " first=", fp.addrs[1])
println("059 events=", fp.events, " prior_len=", length(model.exec.events.prior))
println("070 ModelState fields=", fieldnames(ModelState))

# CV11b-062: t after k frames is the float nearest t0 + k*Δt, a typed decimal matches
m2 = Simulation(bare_world(); Δt_frame = 1//10)
init!(m2, set(u = (u = 0.0, p = 0.0)))
for f in 1:3; step!(m2); end
st = checkpoint(m2).state
println("062 t=", st.t, " t===0.3: ", st.t === 0.3, " accum 0.1+0.1+0.1=", 0.1+0.1+0.1, " t0=", st.t₀)

# CV11b-030: _handle allocates nothing
sim = Simulation(bare_world(); Δt_frame = 1//10)
h = attach!(sim, Pad("a"), Enumerated("u"))
e = sim.plane.roster[1]
R._handle(e); R._handle(e)
println("030 handle allocs=", @allocated(R._handle(e)), " isa=", R._handle(e) isa DeviceHandle)

# CV11b-041: writer schema order
attach!(sim, Pad("b"), Greedy())
println("041 schemas=", R._writer_schemas(sim.plane))

# CV11b-011: greedy claim is the remainder; empty remainder warns
sim3 = Simulation(bare_world(); Δt_frame = 1//10)
attach!(sim3, Pad("a"), Enumerated("u"))
hg = attach!(sim3, Pad("g"), Greedy())
println("011 greedy faces=", hg.writer.faces, " is_greedy default=", is_greedy(Enumerated("u")))

# CV11b-020: reads not a NamedTuple / not selectors
struct BadReads1 <: AbstractBinding end
R.is_output(::BadReads1) = true
R.reads(::BadReads1) = [1]
struct BadReads2 <: AbstractBinding end
R.is_output(::BadReads2) = true
R.reads(::BadReads2) = (a = 1,)
for b in (BadReads1(), BadReads2())
    try
        attach!(Simulation(bare_world(); Δt_frame = 1//10), Pad("x"), b)
        println("020 no throw")
    catch err
        println("020 ", typeof(err), " ", [(typeof(d), d.reason) for d in (err.carried isa AbstractVector ? err.carried : [err.carried])])
    end
end

# CV11b-026: DeviceContractMismatch :no_loop
mutable struct NoLoop <: AbstractDevice end
try
    attach!(Simulation(bare_world(); Δt_frame = 1//10), NoLoop(), Enumerated("u"))
catch err
    println("026 ", [(typeof(d), d.reason) for d in (err.carried isa AbstractVector ? err.carried : [err.carried])])
end

# CV11b-002: hooks default to no-ops
println("002 init!=", init!(Pad("z")), " shutdown!=", shutdown!(Pad("z")), " unblock!=", unblock!(Pad("z")))

# CV11b-050: pace/margin written at run! entry, pace! any state
s5 = Simulation(bare_world(); Δt_frame = 1//10)
pace!(s5, 2.0); margin!(s5, 0.01)
println("050 built-state pace=", pace(s5), " margin=", margin(s5), " lifecycle=", lifecycle(s5))
init!(s5, set(u = (u = 0.0, p = 0.0)))
run!(s5; t_end = 0.2)
println("050 after run! pace=", pace(s5), " margin=", margin(s5))
end
