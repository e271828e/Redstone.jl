# S9d2 verifier probe. Run from the pinned worktree:
#   JULIA_LOAD_PATH="@" julia --startup-file=no --project=test P          (default -O2)
#   JULIA_LOAD_PATH="@" julia --startup-file=no --project=test -O0 P      (-O0 rows)
using Test, Redstone, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
import Redstone: x_projection, CellAddr, Chunk, PhaseBody

const OPT = Base.JLOptions().opt_level
say(id, msg) = println("[$id] O$OPT ", msg)

# A discrete component in all three tick-sensitive blocks.
struct Tri <: AbstractComponent end
s_init(::Tri) = (n = 0,)
u_types(::Tri) = (in = Float64,)
y_types(::Tri) = (n = Int, out = Float64)
y_state(::Tri, (; s)) = (n = s.n,)
y_direct(::Tri, (; u)) = (out = u.in,)
s_update(::Tri, (; s)) = (n = s.n + 1,)

# Projection at both positions: count calls and firings.
const PROJ = Ref(0)
const FIRE = Ref(0)
struct PB <: AbstractComponent end
x_init(::PB) = (q = 0.0,)
y_types(::PB) = (q = Float64,)
y_state(::PB, (; x)) = (q = x.q,)
x_deriv(::PB, (; x)) = (q = 1.0,)
pb_guard(::PB, (; x)) = x.q ≥ 0.25
pb_handler(::PB, (; x)) = (FIRE[] += 1; (x = (q = 0.0,),))
state_events(::PB) = (reset = StateEvent(pb_guard, pb_handler),)
x_projection(::PB, x) = (PROJ[] += 1; x)

# Numeric twin of handle_model: the handle port as a Float64.
struct NTerrain <: AbstractComponent end
s_init(::NTerrain) = nothing
y_types(::NTerrain) = (terrain = Float64,)
y_direct(::NTerrain, args) = (terrain = 1.0,)
struct NQuery <: AbstractComponent end
x_init(::NQuery) = nothing
u_types(::NQuery) = (terrain = Float64,)
y_types(::NQuery) = (h = Float64,)
y_direct(::NQuery, (; u)) = (h = u.terrain + 2.0,)
numeric_twin() = Group((; src = NTerrain(), q = NQuery()); local_wires = ("src/terrain" => "q/terrain",))
# Int twin: a second, isbits eltype block in place of the handle's.
struct ITerrain <: AbstractComponent end
s_init(::ITerrain) = nothing
y_types(::ITerrain) = (terrain = Int,)
y_direct(::ITerrain, args) = (terrain = 1,)
struct IQuery <: AbstractComponent end
x_init(::IQuery) = nothing
u_types(::IQuery) = (terrain = Int,)
y_types(::IQuery) = (h = Float64,)
y_direct(::IQuery, (; u)) = (h = u.terrain + 2.0,)
int_twin() = Group((; src = ITerrain(), q = IQuery()); local_wires = ("src/terrain" => "q/terrain",))

xhash(v) = string(hash(reinterpret(UInt64, collect(Float64, v))), base = 16)

function main()
    if OPT >= 2
        # 001: Outputs fields
        b = build(feedback_model())
        say("001", "Outputs fields $(fieldnames(Outputs)); ComponentOutputs fields $(fieldnames(ComponentOutputs))")
        say("001", "first component $(b.outputs.components[1]); order $(b.outputs.order)")

        # 011/031/043: gates per component in each body
        tri = Group((; src = Ramp(0.0), tri = Tri()); local_wires = ("src/out" => "tri/in",),
                    sample_times = (; tri = Relative(3, 1)))
        sim = Simulation(tri; Δt_frame = 1//100, Δt_base = 1//100)
        rows = sim.model.deployment.schedule.rows
        say("011", "schedule rows $( [(r.path, r.D, r.Φ, r.Δt) for r in rows] )")
        bodies = phase_bodies(sim)
        for name in (:sweep_1, :sweep_2, :ticks, :rhs)
            body = bodies[name]
            gs = [(e.entry.path, e.D, e.Φ) for c in body.boundary for e in c.entries if e isa Gated]
            int = [e.path for c in body.interior for e in c.entries]
            say("043", "$name gated $gs ; interior $int")
        end
        init!(sim)
        n0 = sim.model.exec.sstores[findfirst(!isnothing, sim.model.exec.sstores)][].n
        ticked = Int[]
        for n in 0:7
            before = sim.model.exec.sstores[2][]
            bodies.ticks(n)
            after = sim.model.exec.sstores[2][]
            after != before && push!(ticked, n)
        end
        say("031", "ticks(n) advanced the store at n = $ticked (expect (n-1)%3==0)")

        # 021: CellAddr
        addr = first(values(sim.model.exec.act.layout.addr))
        say("021", "address type $(typeof(addr)) fields $(fieldnames(typeof(addr))) value $addr")

        # 042: rhs arity
        fsim = Simulation(feedback_model(); Δt_frame = 1//100)
        fb = phase_bodies(fsim)
        say("042", "rhs type $(typeof(fb.rhs).name.name); rhs(5) = $(repr(fb.rhs(5))); " *
                   "interior === boundary type: $(typeof(fb.rhs.interior) == typeof(fb.rhs.boundary))")

        # 063: default chunk size
        say("063", "default chunk_size $(fsim.model.exec.chunk_size)")

        # 084: empty bodies
        say("084", "feedback ticks() = $(repr(fb.ticks())), ticks(3) = $(repr(fb.ticks(3))), " *
                   "n entries $(length(walked(fb.ticks)))")
        tc = Simulation(single(TickCounter()); Δt_frame = 1//10)
        tb = phase_bodies(tc)
        for (lbl, bs) in (("feedback", fb), ("tickcounter", tb))
            for name in (:sweep_1, :sweep_2, :rhs, :ticks)
                body = bs[name]
                body(); body(0)
                say("084", "$lbl $name entries=$(length(walked(body))) alloc()=$(@ballocated($body())) alloc(1)=$(@ballocated($body(1)))")
            end
        end

        # 096: projection at both positions
        psim = Simulation(single(PB()); Δt_frame = 1//10)
        init!(psim; log = false)
        PROJ[] = 0; FIRE[] = 0
        run!(psim; t_end = 1.0)
        say("096", "10 frame boundaries: projections $(PROJ[]), firings $(FIRE[]) (both positions => 10 + firings)")

        # 106: handle snapshot allocation vs numeric twin
        for (lbl, m) in (("handle", handle_model()), ("numeric", numeric_twin()), ("int", int_twin()))
            s = Simulation(m; Δt_frame = 1//10)
            init!(s; log = false)
            st = s.model.exec.store
            capture_stores(st)
            ca = @allocations capture_stores(st)
            cb = @allocated capture_stores(st)
            pb = @ballocated publish!($s, $(s.plane.roster))
            say("106", "$lbl blocks $(keys(st.stores)) capture allocs $ca bytes $cb; publish! bytes $pb")
        end
    end

    # 073/074: -O0 and -O2 alike
    sim = Simulation(feedback_model(); Δt_frame = 1//100)
    init!(sim, set(u = (ref = 1.0,)); log = false)
    run!(sim; t_end = 3.0)
    say("074", "feedback xbuf hash $(xhash(sim.model.exec.xbuf)) xbuf $(sim.model.exec.xbuf)")
    rsim = Simulation(Group((; rot = Rotor(), saw = Sawtooth(1.0))); Δt_frame = 1//10)
    init!(rsim; log = false)
    run!(rsim; t_end = 5.0)
    say("074", "rotor+saw xbuf hash $(xhash(rsim.model.exec.xbuf)) xbuf $(rsim.model.exec.xbuf)")

    integrate!(sim, 1e-3)
    say("073", "integrate! alloc $(@ballocated(integrate!($sim, 1e-3)))")
    for name in (:sweep_1, :sweep_2, :rhs, :ticks)
        body = phase_bodies(sim)[name]
        body(); body(0)
        say("073", "$name alloc()=$(@ballocated($body())) alloc(1)=$(@ballocated($body(1)))")
    end
    model = Model(feedback_model(); Δt_frame = 1//100)
    init!(model, set(u = (ref = 0.7,)))
    frames!(model, 2)
    k = Ref(3)
    say("073", "Model frame! alloc $(@ballocated(frame!($model, k), setup = (k = $k[]; $k[] += 1), evals = 1))")
end

main()
