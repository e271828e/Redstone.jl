module P
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
include(joinpath(W, "test_devices.jl"))
tryit(f) = try f() catch e; e end
function main()
    sim = Simulation(panel_model(); Δt_frame = 1//10)
    handle = attach!(sim, Pad("a"), Enumerated("in"))
    init!(sim, set(u = (in = 1.0, gain_in = 2.0)))
    snap = latest(sim)
    println("probe:A snapshot fields ", fieldnames(typeof(snap)))
    r = tryit(() -> port(snap, "nope", :x)); println("probe:B nopath ", r isa DiagnosticError ? typeof(r.carried) : r)
    r = tryit(() -> port(snap, "inner/g", :zzz)); println("probe:C badname ", typeof(r), " ", sprint(showerror, r)[1:min(end,200)])
    r = tryit(() -> port(snap, "inner/g", :e)); println("probe:D ok port ", r)
    r = tryit(() -> port(snap, "", :in)); println("probe:E root input ", r)
    r = tryit(() -> port(snap, "inner/g", :u)); println("probe:F input face below root ", typeof(r), " ", r isa Exception ? sprint(showerror, r)[1:min(end,200)] : r)
    # stale
    rec = snap.status.writers[1]
    println("probe:G rec ", rec.who, " hb=", rec.heartbeat, " ts=", rec.task_state, " stale(now=1.0)=", stale(rec; now = 1.0), " stale()=", stale(rec), " stale(now=3.0)=", stale(rec; now=3.0))
    println("probe:H stale(Int now) ", typeof(tryit(() -> stale(rec; now = 5))))
    println("probe:I harness/loop ", [(w.who, w.heartbeat, w.task_state, stale(w), orphaned(w)) for w in snap.status.writers[2:end]])
    # port_views
    views = port_views(handle)
    for k in sort(collect(keys(views)))
        v = views[k]; println("probe:V ", k, " src=", v.source, " live=", v.live, " slot=", v.slot, " inc=", repr(v.incumbent))
    end
    println("probe:J pending none ", pending(handle, 1))
    stage!(handle, "in" => 5.0)
    println("probe:K pending after stage ", pending(handle, 1), " peek ", peek(views[("", :in)], handle, snap))
    println("probe:K2 views has root input key? ", haskey(views, ("", :in)))
    stage!(handle, "zz" => 1.0, "gain_in" => 1.0)
    println("probe:L pending slot out of range ", typeof(tryit(() -> pending(handle, 0))), " ", typeof(tryit(() -> pending(handle, 9))))
    r = tryit(() -> report!(handle, ErrorException("x"))); println("probe:M report non-malformed ", typeof(r))
    println("probe:N wait before pub / latest ", latest(handle) === snap, " running=", running(handle))
    step!(sim)
    st = latest(sim).status
    println("probe:O after step writers ", [(w.who, w.recent |> length, w.suppressed, w.totals.out_of_claim, w.totals.type_mismatch) for w in st.writers])
    println("probe:P pacer ", st.pacer)
    println("probe:Q incumbent_status unknown ", incumbent_status(views[("inner/c", :u)], latest(sim)))
    println("probe:R KindCounts fields ", fieldnames(KindCounts), " KINDS ", length(Redstone.KINDS))
    println("probe:S Snapshot frame/boundary ", latest(sim).frame, " ", latest(sim).boundary)
    println("probe:T no-loop device ", typeof(tryit(() -> attach!(Simulation(panel_model(); Δt_frame=1//10), :notadevice, Enumerated("in")))))
    nothing
end
main()
end
