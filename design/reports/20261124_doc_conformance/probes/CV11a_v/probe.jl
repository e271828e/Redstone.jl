# CV11a verifier probes, run from the pinned worktree with --project=test.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
const R = Redstone
two_root_inputs() = Group((; s = Sum(sa = 1.0, sb = 1.0));
                    input_wires = ("a" => "s/a", "b" => "s/b"))
mutable struct Loopless <: AbstractDevice end
p(tag, x) = println(rpad(tag, 6), " ", x)

# P1 (002): the staging cell compares batch identity; an equal twin box fails the CAS.
let cell = R.StagingCell{Int}(Base.RefValue{Int}(1))
    twin = Base.RefValue{Int}(1)
    r = @atomicreplace cell.pending twin => Base.RefValue{Int}(2)
    p("P1a", (equal_twin_replace_success = r.success,))
    held = @atomic cell.pending
    r2 = @atomicreplace cell.pending held => Base.RefValue{Int}(3)
    p("P1b", (identical_replace_success = r2.success, now = (@atomic cell.pending)[]))
    old = @atomicswap cell.pending = nothing
    p("P1c", (swap_returned = old[], after = (@atomic cell.pending)))
end

# P2 (044): KindCounts' fields against KINDS' order through `_kind`.
p("P2a", (fieldnames = fieldnames(R.KindCounts),))
p("P2b", (kinds_mapped = map(R._kind, R.KINDS), equal = map(R._kind, R.KINDS) == fieldnames(R.KindCounts)))
p("P2c", (DiagValue_is_union_of_KINDS = R.DiagValue == Union{R.KINDS...},))

# P3 (014, 026): writer names in the status, and the harness's two out-of-surface kinds.
let sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
    stage!(sim, "a" => 5.0)                        # stopped staging, then a claim on `a`
    handle = attach!(sim, Pad("p"), Enumerated("a"))
    init!(sim, set(u = (a = 0.0, b = 0.0)))
    p("P3a", (who = [w.who for w in latest(sim).status.writers], handle_who = handle.who))
    stage!(sim, "a" => 1.0, "flaps" => 2.0, "b" => 3.0)
    run!(sim; t_end = 0.1)
    h = writer_status(latest(sim), "harness")
    p("P3b", [(typeof(d), getfield(d, :face), d isa ClaimedFaceEntry ? (d.incumbent, d.site) : d.incumbent) for d in h.recent])
    p("P3c", (b = port(sim, "", :b), harness_totals_claimed = h.totals.claimed_face, out_of_claim = h.totals.out_of_claim))
    # P8 (065): gather on a handle with no output side.
    e = failure(() -> gather(handle, latest(sim)))
    d = R.diagnostic(e)
    p("P8", (typeof(d), d.reason, d.device))
    # P10 (040): the snapshot's port method by address.
    snap = latest(sim)
    p("P10a", (snap_port_b = port(snap, "", :b), snap_port_s = port(snap, "s", :e),
               methods = length(methods(port, Tuple{R.Snapshot,String,Union{Nothing,Symbol}}))))
    # P11 (076): the handle's fields and type parameters.
    p("P11a", (fields = fieldnames(typeof(handle)), params = typeof(handle).parameters))
    p("P11b", (published_type = typeof(handle.published), latest_field = fieldnames(R.Published)))
end

# P4 (021): `stale` on a never-beaten device record, at a small `now` and at time().
let rec = R.WriterStatus("device 1 (Pad)", R.DiagValue[], R.KindCounts(), R.KindCounts(), 0.0, :done)
    p("P4", (now_1 = stale(rec; now = 1.0), now_2 = stale(rec; now = 2.0), now_3 = stale(rec; now = 3.0),
             now_time = stale(rec), STALE_S = R.STALE_S))
end

# P5 (016): the loop's residue folds two cells, so its record can exceed DIAG_RING.
let account = R.WriterAccount(), c1 = R.DiagCell(R.EMPTY_DIAG), c2 = R.DiagCell(R.EMPTY_DIAG)
    for _ in 1:17
        R.report_cell!(c1, R.UnboundedRun(Inf, String[]))
    end
    for _ in 1:17
        R.report_cell!(c2, R.UnboundedRun(Inf, ["frame"]))
    end
    R._fold!(account, c1); R._fold!(account, c2)
    residue = R.ResidueRecord[]
    R._residue!(residue, "loop", account)
    rec = only(residue)
    p("P5a", (recent = length(rec.recent), DIAG_RING = R.DIAG_RING, suppressed_total = R._total(rec.suppressed)))
    quiet = R.ResidueRecord[]
    R._residue!(quiet, "harness", R.WriterAccount())
    p("P5b", (quiet_records = length(quiet),))
end

# P7 (056): a device with no loop method at attach!.
let sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
    e = failure(() -> attach!(sim, Loopless(), Enumerated()))
    d = R.diagnostic(e)
    p("P7a", (typeof(d), d.reason, d.device, length(sim.plane.roster)))
    e2 = failure(() -> R.loop(Loopless(), nothing))
    p("P7b", (direct_call = typeof(e2),))
end

# P9 (074): DeviceCrash's constructors.
p("P9", (one_arg = typeof(failure(() -> R.DeviceCrash(ErrorException("x")))),
         two_arg = typeof(R.DeviceCrash(ErrorException("x"), false)),
         fields = fieldnames(R.DeviceCrash)))

# P12 (046): log!'s signature.
p("P12", [m.sig for m in methods(R.log!)])
