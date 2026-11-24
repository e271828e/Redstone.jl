using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test/imports.jl"))
include(joinpath(W, "test/fixtures.jl"))
three_root_inputs() = Group((; s = Sum(sa = 1.0, sb = 1.0), g = Gain(2.0));
                            input_wires = ("a" => "s/a", "b" => "s/b", "c" => "g/e"))
macro p(tag, ex)
    quote
        r = try $(esc(ex)) catch e; e end
        println("probe[", $(string(tag)), "] ", r isa Exception ? sprint(showerror, r) : repr(r))
    end
end
sim = Simulation(three_root_inputs(); Δt_frame = 1//10)
init!(sim, set(u = (a = 0.0, b = 0.0, c = 0.0)))
t0 = trace(sim)
@p 10_header_fields (fieldnames(Trace), fieldnames(Checkpoint), fieldnames(Redstone.ModelState))
@p 11_frames0 (t0.frames, length(t0.batches), t0.schemas, t0.header.frame, t0.header.boundary)
@p 12_header_has_inputs [f => gather_cell(t0.header.state.table, sim.model.exec.act.layout.addr[("", f)]) for (f,_) in sim.model.exec.act.layout.root_inputs]
@p 13_scalarfree (typeof(t0), typeof(t0.header.state))
stage!(sim, "b" => 1.0); step!(sim)
tr = trace(sim)
@p 14_record (tr.batches, tr.frames)
# allocations of _record!
b = Redstone.Batch((0.0,1.0,0.0),(false,true,false))
trc = Redstone.Trace(nothing, Pair{String,Vector{Symbol}}[], Redstone.TraceBatch[], 1)
Redstone._record!(trc, 1, b)
@p 15_alloc @allocated Redstone._record!(trc, 1, b)
# allocation of record with 3 entries
b3 = Redstone.Batch((0.0,1.0,2.0),(true,true,true))
Redstone._record!(trc, 1, b3)
@p 16_alloc3 @allocated Redstone._record!(trc, 1, b3)
# --- devices / roster
dev = Pad("p")
h = attach!(sim, dev, Enumerated("a"))
tr2 = trace(sim)
@p 20_schemas_after_attach tr2.schemas
@p 21_nonlive_trace_len_unchanged (tr2.frames, length(tr2.batches))
@p 22_t0_detached length(t0.schemas)
stage!(h, "a" => 5.0)
@p 23_pending pending(h, 1)
@p 24_out_of_claim (stage!(h, "b" => 1.0); nothing)
step!(sim)
@p 25_tr trace(sim).batches[end]
detach!(sim, dev)
@p 26_stage_after_detach stage!(h, "a" => 1.0)
@p 27_report_after_detach report!(h, MalformedDatum("x"))
@p 28_read_after_detach latest(h) === latest(sim)
@p 29_schemas_after_detach trace(sim).schemas
# conformance
struct NoSides2 <: AbstractBinding end
struct NoEnum2 <: AbstractBinding end
is_input(::NoEnum2) = true
struct GP <: AbstractBinding end
is_input(::GP) = true; is_greedy(::GP) = true; claims(::GP) = ("a",)
struct Src <: AbstractBinding end
is_greedy(::Src) = true
struct Dr <: AbstractBinding end
is_output(::Dr) = true; claims(::Dr) = ("a",)
struct Dr2 <: AbstractBinding end
is_input(::Dr2) = true; claims(::Dr2) = ("a",); reads(::Dr2) = (;)
struct OutNo <: AbstractBinding end
is_output(::OutNo) = true
struct DefaultG <: AbstractBinding end
@p 30_defaults (is_input(DefaultG()), is_output(DefaultG()), is_greedy(DefaultG()))
for b in (NoSides2(), NoEnum2(), GP(), Src(), Dr(), Dr2(), OutNo())
    try attach!(sim, Pad("q"), b); println("probe[31] ", typeof(b), " attached OK")
    catch e
        d = e.carried isa Vector ? e.carried[1] : e.carried
        println("probe[31] ", typeof(b), " => ", typeof(d), " ", getfield(d, :reason), " | ", Redstone.message(d))
    end
end
# which doc: device with no loop
mutable struct NoLoop <: AbstractDevice end
@p 32_noloop attach!(sim, NoLoop(), Enumerated("a"))
# empty claims
hn = attach!(sim, Pad("n"), NoClaim())
@p 33_empty_out_of_claim (stage!(hn, "a" => 1.0); step!(sim); [typeof(x) for x in trace(sim).batches[end:end]])
detach!(sim, hn.b === nothing ? nothing : sim.plane.roster[end].dev)
# greedy: second greedy empty claim
g1 = Pad("g1"); g2 = Pad("g2")
hg1 = attach!(sim, g1, Greedy())
@p 34_greedy_claim hg1.writer.faces
hg2 = attach!(sim, g2, Greedy())
@p 35_greedy2_claim hg2.writer.faces
stage!(sim, "a" => 1.0)
step!(sim)
st = latest(sim).status
@p 36_status [ (w.who, w.totals) for w in st.writers if occursin("device", w.who)]
detach!(sim, g1); detach!(sim, g2)
# harness gets claim complement
@p 37_harness sim.plane.harness.faces
# greedy with explicit claims alongside
ha = attach!(sim, Pad("e1"), Enumerated("a"))
hb = attach!(sim, Pad("e2"), Enumerated("b"))
@p 38_two_enumerated (ha.writer.faces, hb.writer.faces)
hg = attach!(sim, Pad("g3"), Greedy())
@p 39_greedy_after (hg.writer.faces)
for e in collect(sim.plane.roster); detach!(sim, e.dev); end
# claims returning Symbols / duplicates / unknown
@p 40_dups (attach!(sim, Pad("d"), Enumerated("a","a")).writer.faces)
@p 41_unknown attach!(sim, Pad("u"), Enumerated("zz"))
for e in collect(sim.plane.roster); detach!(sim, e.dev); end
# TableBinding
tb = TableBinding(stick_y = (face = "a", deadzone = 0.05, expo = 0.6),
                  throttle = (face = "b",), trigger = (face = "c",))
@p 50_tb (claims(tb), is_input(tb), is_output(tb), is_greedy(tb))
@p 51_mi map_input((stick_y = 0.5, throttle = 0.3, trigger = 2), tb)
@p 52_mi_alloc (map_input((stick_y = 0.5, throttle = 0.3), tb); @allocated map_input((stick_y = 0.5, throttle = 0.3), tb))
@p 53_bad TableBinding(a = 3, b = (deadzone = 2.0,), c = (face = 1,))
@p 54_bad_diags (try TableBinding(a = 3, b = (deadzone = 2.0,), c = (face = 1,)) catch e; length(e.carried) end)
@p 55_tbtype TableBinding(a = (face="x",)) isa AbstractBinding
@p 56_unknown_channel map_input((nope = 1.0,), tb)
@p 57_which which(map_input, Tuple{typeof((stick_y=0.5,)), typeof(tb)}).module
# Readout / reads
r = Readout(; y = get_output("", :y))
@p 60_reads_fallback (try reads(DefaultG()) catch e; e.carried.reason end)
# device loop / crash / should_abort
mutable struct Crasher <: AbstractDevice; log::Vector{Symbol}; mode::Symbol; end
init!(d::Crasher) = (push!(d.log, :init); d.mode === :initthrow && error("init boom"); nothing)
shutdown!(d::Crasher) = (push!(d.log, :shutdown); nothing)
function loop(d::Crasher, handle)
    d.mode === :crash && error("loop boom")
    d.mode === :malformed && (report!(handle, MalformedDatum("bad")); while running(handle); wait_next_snapshot(handle); end)
    d.mode === :wait && (while running(handle); wait_next_snapshot(handle); end)
    nothing
end
for mode in (:crash, :initthrow, :malformed)
    for abort in (false, true)
        s = Simulation(three_root_inputs(); Δt_frame = 1//10)
        init!(s, set(u = (a = 0.0, b = 0.0, c = 0.0)))
        c = Crasher(Symbol[], mode)
        attach!(s, c, Enumerated("a"); should_abort = abort)
        # a second wait-device so the run keeps going
        w = Crasher(Symbol[], :wait); attach!(s, w, NoClaim())
        src = try run!(s; t_end = 1.0); catch e; e end
        println("probe[70] mode=", mode, " abort=", abort, " log=", c.log, " frame=", s.run.frame, " lifecycle=", lifecycle(s))
        st = latest(s).status
        println("probe[71]   ", [(w.who, w.task_state, w.totals) for w in st.writers if occursin("device", w.who)])
    end
end
# Trace length after restore!
s = Simulation(three_root_inputs(); Δt_frame = 1//10)
init!(s, set(u = (a = 0.0, b = 0.0, c = 0.0)))
step!(s; frames = 3)
cp = checkpoint(s)
restore!(s, cp)
@p 80_restore (trace(s).frames, trace(s).header.frame, length(trace(s).schemas))
step!(s; frames = 2)
@p 81_after (trace(s).frames, [b.frame for b in trace(s).batches])
@p 82_cp_stepper (cp.state.stepper, fieldnames(typeof(cp.state)))
@p 83_fingerprint fieldnames(Redstone.Fingerprint)
# overlay header
overlay!(s, set(u = (a = 0.5,)))
@p 84_overlay (trace(s).header.frame, trace(s).frames, trace(s).header.state.table !== nothing)
# trace=false
s2 = Simulation(three_root_inputs(); Δt_frame = 1//10)
init!(s2, set(u = (a = 0.0, b = 0.0, c = 0.0)); trace = false)
@p 85_tracefalse trace(s2)
# trace keyword default
@p 86_kw (methods(init!, (Simulation,)) |> first |> x -> x.sig)
# replay cap
tr3 = trace(s)
s3 = Simulation(three_root_inputs(); Δt_frame = 1//10)
replay!(s3, tr3)
@p 87_replay (s3.run.frame, tr3.frames, lifecycle(s3))
@p 88_replay_step step!(s3; frames = 100)
@p 89_replay_frame (s3.run.frame)
# deployment fields
@p 90_deployment fieldnames(Deployment)
@p 91_run_kw (methods(run!) |> collect |> x -> map(m -> m.sig, x))
@p 92_term (try; s4 = Simulation(three_root_inputs(); Δt_frame = 1//10); init!(s4, set(u=(a=0.0,b=0.0,c=0.0))); run!(s4; t_end = 0.3); termination(s4) catch e; e end)
# is greedy & is_input one-line: roster entry fields
@p 93_entry fieldnames(Redstone.RosterEntry)
@p 94_handle_fields fieldnames(typeof(hg))
@p 95_handle_prims (hasmethod(running, Tuple{typeof(hg)}), hasmethod(stop!, Tuple{typeof(hg)}), hasmethod(latest, Tuple{typeof(hg)}))
@p 96_ab (AbstractDevice, AbstractBinding, subtypes(AbstractBinding))
@p 97_should_close isdefined(Redstone, :should_close)
@p 98_sides isdefined(Redstone, :sides)
@p 99_IME isdefined(Redstone, :InputMappingError)
println("---- second section")
@p 100_allocs (@allocations Redstone._record!(trc, 1, b), @allocations Redstone._record!(trc, 1, b3))
sg = Simulation(three_root_inputs(); Δt_frame = 1//10)
init!(sg, set(u = (a = 1.0, b = 2.0, c = 3.0)))
hr = attach!(sg, Pad("r"), Readout(; zed = get_output("g", "out"), alpha = get_input("a"), mid = get_output("s", "e")))
snap = latest(sg)
@p 101_gather (gather(hr, snap), keys(gather(hr, snap)))
@p 102_gather_alloc (gather(hr, snap); @allocated gather(hr, snap))
@p 103_gather_noout (gather(attach!(sg, Pad("n2"), NoClaim()), snap))
@p 104_binding_alloc (binding(hr) === hr.b, typeof(hr))
@p 105_get_face_input attach!(sg, Pad("n3"), Readout(v = get_face("a")))
@p 106_mount_at attach!(sg, Pad("n4"), Readout(v = get_input("a")))
# greedy + reads legal
struct GreedyRead <: AbstractBinding end
is_input(::GreedyRead) = true; is_greedy(::GreedyRead) = true; is_output(::GreedyRead) = true
reads(::GreedyRead) = (; q = get_input("a"))
@p 107_greedy_reads (attach!(sg, Pad("gr"), GreedyRead()).writer.faces)
@p 108_loop_fallback (try Redstone.loop(Pad("x"), nothing) catch e; e isa DiagnosticError ? "diag" : sprint(showerror, e) end)
let
    f1() = Redstone._record!(trc, 1, b)
    f3() = Redstone._record!(trc, 1, b3)
    f1(); f3()
    n1 = @allocations f1()
    n3 = @allocations f3()
    println("probe[109_nalloc] one entry: ", n1, " three entries: ", n3)
end
