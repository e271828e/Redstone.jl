# L6e probe: log entries D-010 .. D-478 (Position claims). Read-only.
using Redstone, StaticArrays, ForwardDiff
import Redstone: AbstractComponent, x_init, s_init, m_init, ws_init, u_types, y_types,
    y_state, y_direct, x_deriv, s_update, local_wires, input_wires, output_wires,
    sample_times, transparent_container, Group, Pinned, Relative, Absolute, ProbeDual,
    build, Deployment, Model, DiagnosticError, diagnostic, diagnostics, Simulation,
    init!, set, at, port, state, modes, linearize, taps, get_state, get_input, get_output

const R = Redstone
fail(f) = try f(); nothing catch err; err end
kinds(err) = err isa DiagnosticError ? [(nameof(typeof(d)), hasproperty(d, :reason) ? d.reason : nothing) for d in (try diagnostics(err) catch; [diagnostic(err)] end)] : typeof(err)
show_err(tag, err) = println(tag, " => ", kinds(err))
onediag(err) = err isa DiagnosticError{<:Redstone.Diagnostic} ? diagnostic(err) : first(diagnostics(err))

# --- fixtures ---------------------------------------------------------------------
struct Plant <: AbstractComponent end
x_init(::Plant) = (q = SVector(0.0, 0.0),)
u_types(::Plant) = (u = Float64,)
y_types(::Plant) = (y = Float64,)
y_state(::Plant, (; x)) = (y = x.q[1],)
x_deriv(::Plant, (; x, u)) = (q = SVector(x.q[2], -x.q[1] + u.u),)

struct Src <: AbstractComponent end
x_init(::Src) = (a = 1.0,)
y_types(::Src) = (out = Float64,)
y_state(::Src, (; x)) = (out = x.a,)
x_deriv(::Src, (; x)) = (a = -x.a,)

struct Tick <: AbstractComponent end
s_init(::Tick) = (n = 0, last = 0.0)
u_types(::Tick) = (u = Float64,)
y_types(::Tick) = (n = Int,)
y_state(::Tick, (; s)) = (n = s.n,)
s_update(::Tick, (; s, u)) = (n = s.n + 1, last = u.u)

# D-211: a custom assembly with a transparent container
struct Holder <: AbstractComponent
    kids::NamedTuple
    plant::Plant
end
transparent_container(::Holder) = :kids
local_wires(::Holder) = ("src/out" => "plant/u",)

struct Holder2 <: AbstractComponent   # collision: bare key `plant` vs field `plant`
    kids::NamedTuple
    plant::Plant
end
transparent_container(::Holder2) = :kids
local_wires(::Holder2) = ()

println("== D-010 / D-162 flat buffer, cell stores")
b = build(Group((; src = Src(), plant = Plant()); local_wires = ("src/out" => "plant/u",)))
sim = Simulation(b; Δt_frame = 1//100)
init!(sim)
m = sim.model
println("xbuf type: ", typeof(m.exec.xbuf))
println("state plant: ", typeof(state(sim, "plant")), " ismutable=", ismutable(state(sim, "plant")))
println("store bundle keys: ", keys(m.exec.store.stores))
addr = m.exec.act.layout.addr[("plant", :y)]
println("addr type: ", typeof(addr))

println("== D-211 transparent container")
println("Group transparent: ", transparent_container(Group((; a = Plant()))))
println("default: ", transparent_container(Plant()))
hb = fail(() -> build(Holder((; src = Src()), Plant())))
println("Holder build: ", hb === nothing ? "ok" : kinds(hb))
hpaths = [e.path for e in build(Holder((; src = Src()), Plant())).structure.components]
println("Holder paths: ", hpaths)
h2 = fail(() -> build(Holder2((; plant = Plant()), Plant())))
show_err("Holder2 collision", h2)
h2 isa DiagnosticError && println("  ", sprint(showerror, h2)[1:min(end, 400)])
# an undeclared container keeps its key segment
struct Plain <: AbstractComponent
    kids::NamedTuple
end
local_wires(::Plain) = ()
println("Plain paths: ", [e.path for e in build(Plain((; p = Src()))).structure.components])

println("== D-235 runtime conformance failure is a StepError species")
struct Flip <: AbstractComponent end
x_init(::Flip) = (a = 0.0,)
y_types(::Flip) = (y = Float64,)
y_state(::Flip, (; x)) = (y = x.a,)
x_deriv(::Flip, (; x, t)) = t > 0.05 ? (a = 1,) : (a = 1.0,)
fb = build(Group((; f = Flip())))
fsim = Simulation(fb; Δt_frame = 1//100)
init!(fsim)
ferr = fail(() -> Redstone.run!(fsim; t_end = 0.2))
println("run err type: ", typeof(ferr))
ferr !== nothing && println("  ", sprint(showerror, ferr)[1:min(end, 300)])
ferr isa R.StepError && println("  cause: ", typeof(ferr.cause))
println("model status: ", fsim.model.status)

println("== D-238 / D-264 embed-accept")
println(R._accepts(SVector{2,ProbeDual}, SVector{2,Float64}, ProbeDual))   # true
println(R._accepts(Float64, ProbeDual, ProbeDual))                          # false (pinned at P)
println(R._accepts(SVector{2,Float64}, SVector{2,Float64}, ProbeDual))      # true identity
println(R._accepts(SVector{2,ProbeDual}, SVector{2,Int}, ProbeDual))        # false
struct Handle{T}; data::Vector{T}; end
println("opaque store: ", R._accepts(Handle{ProbeDual}, Handle{Float64}, ProbeDual), " wire: ",
        R._accepts_wire(Handle{ProbeDual}, Handle{Float64}, ProbeDual))
println("retype Int param: ", R.retype(ProbeDual, SVector{2,Int}), " Float32: ", R.retype(ProbeDual, Complex{Float32}))
println("retype mutable: ", R.retype(ProbeDual, Base.RefValue{Float64}), " MVector: ", R.retype(ProbeDual, MVector{2,Float64}))

println("== D-190 / D-032")
println("derivative_type defined: ", isdefined(R, :derivative_type))
println("macros in Redstone names: ", filter(n -> startswith(string(n), "@"), names(R)))
println("ws_init defined, workspace defined: ", isdefined(R, :ws_init), " ", isdefined(R, :workspace))

println("== D-077 ws_init per activation")
const WS_CALLS = Ref(0)
struct WsComp <: AbstractComponent end
x_init(::WsComp) = (a = 0.0,)
y_types(::WsComp) = (y = Float64,)
y_state(::WsComp, (; x)) = (y = x.a,)
x_deriv(::WsComp, (; x, ws)) = (a = -x.a,)
ws_init(::WsComp, ::Type{T}) where {T} = (WS_CALLS[] += 1; (buf = zeros(T, 2),))
struct WsDisc <: AbstractComponent end
s_init(::WsDisc) = (n = 0,)
y_types(::WsDisc) = (n = Int,)
y_state(::WsDisc, (; s)) = (n = s.n,)
s_update(::WsDisc, (; s, ws)) = (println("  discrete ws eltype: ", eltype(ws.buf)); (n = s.n + 1,))
const DISC_T = Ref{Any}(nothing)
ws_init(::WsDisc, ::Type{T}) where {T} = (DISC_T[] = T; (buf = zeros(T, 1),))
WS_CALLS[] = 0
wb = build(Group((; w = WsComp(), d = WsDisc())); activations = (Float64, ProbeDual))
println("ws_init calls after build(Float64, ProbeDual): ", WS_CALLS[], " discrete got T=", DISC_T[])

println("== D-306 workspace is never a condition target")
wsim = Simulation(build(Group((; w = WsComp()))); Δt_frame = 1//100)
werr = fail(() -> init!(wsim, at("w", set(x = (buf = 1.0,)))))
show_err("condition naming ws field", werr)
werr isa DiagnosticError && println("  role: ", onediag(werr).role)
struct WsMat <: AbstractComponent end
x_init(::WsMat) = (a = 0.0,)
y_types(::WsMat) = (y = Float64,)
y_state(::WsMat, (; x)) = (y = x.a,)
x_deriv(::WsMat, (; x, ws)) = (a = -x.a,)
ws_init(::WsMat, ::Type{T}) where {T} = zeros(T, 2, 2)
msim = Simulation(build(Group((; w = WsMat()))); Δt_frame = 1//100)
merr = fail(() -> init!(msim, at("w", set(x = (bogus = 1.0,)))))
println("condition, undeclared field, Matrix ws: ", typeof(merr), " ", merr isa DiagnosticError ? kinds(merr) : sprint(showerror, merr)[1:min(end, 200)])

println("== D-283 / D-291 deployment")
struct Disc <: AbstractComponent end
s_init(::Disc) = (n = 0,)
y_types(::Disc) = (n = Int,)
y_state(::Disc, (; s)) = (n = s.n,)
s_update(::Disc, (; s)) = (n = s.n + 1,)
unanch = build(Group((; d = Disc())))
show_err("derive, unanchored", fail(() -> Deployment(unanch; Δt_frame = 1//10, Δt_base = :derive)))
println("default Δt_base with unanchored: ", Deployment(unanch; Δt_frame = 1//10).Δt_base)
anch = build(Group((; d = Disc(), e = Disc()); sample_times = (d = Absolute(1//10), e = Absolute(1//4, 1//20))))
dd = Deployment(anch; Δt_frame = 1, Δt_base = :derive)
println("derived Δt_base: ", dd.Δt_base)
aerr = fail(() -> Deployment(anch; Δt_frame = 1, Δt_base = 1//3))
show_err("non-dividing Δt_base", aerr)
aerr isa DiagnosticError && for d in diagnostics(aerr); println("  scope=", repr(d.scope), " key=", d.key, " reason=", d.reason); end
show_err("Δt_base float", fail(() -> Deployment(anch; Δt_frame = 1, Δt_base = 0.1)))
println("N_base keyword: ", typeof(fail(() -> Deployment(unanch; Δt_frame = 1//10, N_base = 1))))
# phases and the gate
ph = build(Group((; s = Group((; a = Disc(), b = Disc()); sample_times = (a = Relative(2, 0), b = Relative(2, 1)))); sample_times = (s = Relative(3, 1),)))
pd = Deployment(ph; Δt_frame = 1//10)
for r in pd.schedule.rows; println("  ", r.path, " D=", r.D, " Φ=", r.Φ, " Δt=", r.Δt); end
show_err("Relative(1,1)", fail(() -> build(Group((; a = Disc()); sample_times = (a = Relative(1, 1),)))))
println("Relative fields: ", fieldnames(Relative), " Absolute fields: ", fieldnames(Absolute))
println("Timing fields: ", fieldnames(R.Timing))
println("printed structure:")
println(sprint(show, MIME"text/plain"(), ph.structure)[1:min(end, 1200)])

println("== D-295 continuous -> discrete wire, Pinned root input")
cd = fail(() -> build(Group((; src = Src(), t = Tick()); local_wires = ("src/out" => "t/u",)); activations = (Float64, ProbeDual)))
println("cont->disc at ProbeDual: ", cd === nothing ? "ok" : kinds(cd))
struct PinIn <: AbstractComponent end
x_init(::PinIn) = (a = 0.0,)
u_types(::PinIn) = (u = Pinned{Float64},)
y_types(::PinIn) = (y = Float64,)
y_state(::PinIn, (; x)) = (y = x.a,)
x_deriv(::PinIn, (; x, u)) = (a = u.u - x.a,)
pb = build(Group((; p = PinIn()); input_wires = ("in" => "p/u",)))
psim = Simulation(pb; Δt_frame = 1//100)
init!(psim, set(u = (in = 1.0,)))
lerr = fail(() -> linearize(psim, taps(u = (i = get_input(:in),), y = (y = get_output("p", :y),))))
show_err("linearize u tap on Pinned root input", lerr)
# D-321: pin at an input whose consumer promotes, fed by a walking producer
struct Promoter <: AbstractComponent end
x_init(::Promoter) = (a = 0.0,)
u_types(::Promoter) = (u = Pinned{Float64},)
y_types(::Promoter) = (y = Float64,)
y_state(::Promoter, (; x)) = (y = x.a,)
x_deriv(::Promoter, (; x, u)) = (a = u.u - x.a,)
perr = fail(() -> build(Group((; src = Src(), p = Promoter()); local_wires = ("src/out" => "p/u",))))
show_err("walking producer -> Pinned input, nominal build", perr)
# D-321: re-emitting a frozen handle at an unpinned output
struct HandleOut <: AbstractComponent; h::Handle{Float64}; end
HandleOut() = HandleOut(Handle([1.0]))
x_init(::HandleOut) = (a = 0.0,)
y_types(::HandleOut) = (h = Handle{Float64},)
y_state(c::HandleOut, (; x)) = (h = c.h,)
x_deriv(::HandleOut, (; x)) = (a = -x.a,)
herr = fail(() -> build(Group((; h = HandleOut())); activations = (Float64, ProbeDual)))
show_err("frozen handle at unpinned output, ProbeDual", herr)

println("== D-304 flat x_init, store fields")
struct Nested <: AbstractComponent end
x_init(::Nested) = (a = (b = 1.0,),)
y_types(::Nested) = (y = Float64,)
y_state(::Nested, (; x)) = (y = 0.0,)
x_deriv(::Nested, (; x)) = x
show_err("nested x_init", fail(() -> build(Group((; n = Nested())))))
struct SymBox; s::Symbol; end
struct SymStore <: AbstractComponent end
s_init(::SymStore) = (k = SymBox(:a),)
y_types(::SymStore) = (n = Int,)
y_state(::SymStore, (; s)) = (n = 0,)
s_update(::SymStore, (; s)) = s
show_err("struct nesting Symbol in s_init", fail(() -> build(Group((; s = SymStore())))))
struct SymOk <: AbstractComponent end
s_init(::SymOk) = (k = :a,)
y_types(::SymOk) = (n = Int,)
y_state(::SymOk, (; s)) = (n = 0,)
s_update(::SymOk, (; s)) = s
println("bare Symbol field: ", fail(() -> build(Group((; s = SymOk())))) === nothing ? "ok" : "refused")
struct PinnedStore <: AbstractComponent end
x_init(::PinnedStore) = (a = Pinned{Float64},)
y_types(::PinnedStore) = (y = Float64,)
y_state(::PinnedStore, (; x)) = (y = 0.0,)
x_deriv(::PinnedStore, (; x)) = x
show_err("Pinned in x_init", fail(() -> build(Group((; p = PinnedStore())))))

println("== D-322 / D-323 / D-324 unconnected, two producers")
show_err("unconnected input", fail(() -> build(Group((; p = Plant())))))
show_err("two producers", fail(() -> build(Group((; a = Src(), b = Src(), p = Plant()); local_wires = ("a/out" => "p/u", "b/out" => "p/u")))))
println("u_types default-value API? ", isdefined(R, :u_defaults), " ", isdefined(R, :input_defaults))

println("== D-414 / D-440 paths")
println("PathResolution reason comment: see diagnostics.jl:513")
e1 = fail(() -> port(sim, "plnt"))
show_err("port unknown path", e1)
e1 isa DiagnosticError && (d = onediag(e1); println("  owner=", repr(d.owner), " segment=", d.segment, " candidates=", d.candidates))
e1b = fail(() -> port(sim, "plant/deep"))
e1b isa DiagnosticError && (d = onediag(e1b); println("  deep: reason=", d.reason, " owner=", repr(d.owner), " candidates=", d.candidates))
show_err("state unknown path", fail(() -> state(sim, "nope")))
show_err("modes unknown path", fail(() -> modes(sim, "nope")))
e2 = fail(() -> port(sim, "plant", :bogus))
println("port unknown name: ", typeof(e2), " ", e2 isa ArgumentError ? e2.msg : "")
println("modes at plant (no m): ", repr(modes(sim, "plant")))
tb = build(Group((; t = Tick(), src = Src()); local_wires = ("src/out" => "t/u",)))
tsim = Simulation(tb; Δt_frame = 1//100); init!(tsim)
println("state at discrete (no x): ", repr(state(tsim, "t")), "  state at src: ", repr(state(tsim, "src")))
snap = Redstone.latest(tsim)
e3 = fail(() -> port(snap, "nope"))
show_err("snapshot port unknown path", e3)
show_err("snapshot state unknown path", fail(() -> state(snap, "nope")))
println("== D-072 linearize")
lin = linearize(sim, taps(x = (q1 = get_state("plant", "q[1]"), q2 = get_state("plant", "q[2]")), y = (y = get_output("plant", :y),)))
println("A=", lin.A, " ẋ₀=", lin.ẋ₀, " y₀=", lin.y₀)
println("status after linearize: ", sim.model.status)
show_err("discrete state tap", fail(() -> linearize(tsim, taps(x = (n = get_state("t", "n"),)))))
println("done")

println("== second run: D-440 stateless state, D-211 sample_times bare key")
struct Neg <: AbstractComponent end
x_init(::Neg) = nothing
u_types(::Neg) = (u = Float64,)
y_types(::Neg) = (y = Float64,)
y_direct(::Neg, (; u)) = (y = -u.u,)
nsim = Simulation(build(Group((; src = Src(), n = Neg()); local_wires = ("src/out" => "n/u",))); Δt_frame = 1//100)
init!(nsim)
println("state at stateless primitive: ", repr(fail(() -> state(nsim, "n")) === nothing ? state(nsim, "n") : fail(() -> state(nsim, "n"))))
println("state/modes at assembly root \"\": ", repr(state(nsim, "")), " ", repr(modes(nsim, "")))
struct DHolder <: AbstractComponent
    kids::NamedTuple
end
transparent_container(::DHolder) = :kids
local_wires(::DHolder) = ()
sample_times(::DHolder) = (d = Relative(4),)
dh = build(DHolder((; d = Disc(), e = Disc())))
for r in Deployment(dh; Δt_frame = 1//10).schedule.rows; println("  ", r.path, " D=", r.D); end
dsim = Simulation(dh; Δt_frame = 1//10); init!(dsim)
println("state via bare key: ", state(dsim, "d"))
show_err("old segment kids/d", fail(() -> state(dsim, "kids/d")))
