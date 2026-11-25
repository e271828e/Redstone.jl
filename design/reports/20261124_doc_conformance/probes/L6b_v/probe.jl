# L6b verifier probes. Run from W with --project=test.
using Redstone, StaticArrays
include(joinpath(pwd(), "test", "imports.jl"))
const R = Redstone
tag(t, v) = println("[", t, "] ", v)
fail(f) = try f(); nothing catch e; e end
kindsof(e) = e isa R.DiagnosticError{Vector{R.Diagnostic}} ? [(typeof(d), d) for d in e.carried] :
             e isa R.DiagnosticError ? [(typeof(e.carried), e.carried)] : e

# names that retired or were renamed
for n in (:local_types, :localize, :init_x, :init_s, :init_m, :init_workspace, :input_types,
          :output_types, :state_derivative, :state_update, :state_projection, :output_state,
          :output_direct, :h_x, :h_s, :h_xu, :h_su, :TierSignatureMismatch, :StopFaceInvalid,
          :inner_wires, :u_connections, :y_connections, :input_connections, :output_connections,
          :child_connections, :inner_connections, :s_init, :x_init, :sample_times,
          :input_passthrough, :output_passthrough, :local_wires, :input_wires, :output_wires,
          :EmptyStore, :DeclarationOnWrongTier)
    tag("defined $n", isdefined(R, n))
end
tag("default names", (R.default_name(x_init), R.default_name(s_init), R.default_name(m_init)))
tag("DOWT arms", fieldnames(R.DeclarationOnWrongTier))

# L6b-049: a domain wrapper as a state leaf
struct Meters; v::Float64; end
struct WrapLeaf <: AbstractComponent end
x_init(::WrapLeaf) = (h = Meters(1.0),)
y_types(::WrapLeaf) = (y = Float64,)
x_deriv(::WrapLeaf, (; x)) = (h = Meters(0.0),)
y_state(::WrapLeaf, (; x)) = (y = 0.0,)
tag("wrapper leaf", [(k, d.reason) for (k, d) in kindsof(fail(() -> build(Group((; c = WrapLeaf())))))])

# L6b-208 / L6b-118: (;) as a store
struct EmptyNT <: AbstractComponent end
x_init(::EmptyNT) = (;)
y_types(::EmptyNT) = (y = Float64,)
y_direct(::EmptyNT, _) = (y = 1.0,)
tag("(;) store", [(k, d.store) for (k, d) in kindsof(fail(() -> build(Group((; c = EmptyNT())))))])
struct NothingStore <: AbstractComponent end
x_init(::NothingStore) = nothing
y_types(::NothingStore) = (y = Float64,)
y_direct(::NothingStore, _) = (y = 1.0,)
tag("nothing store builds", fail(() -> build(Group((; c = NothingStore())))) === nothing)

# L6b-106: Pinned entry on a discrete leaf
struct PinDisc <: AbstractComponent end
s_init(::PinDisc) = (n = 0.0,)
u_types(::PinDisc) = (u = Pinned{Float64},)
y_types(::PinDisc) = (y = Float64,)
y_state(::PinDisc, (; s)) = (y = s.n,)
s_update(::PinDisc, (; s, u)) = (n = u.u,)
tag("Pinned on discrete", [(k, d.reason, d.declaration, d.entry) for (k, d) in
     kindsof(fail(() -> build(Group((; c = PinDisc()); input_wires = ("in" => "c/u",)))))])

# L6b-086: a discrete leaf declaring a continuous-tier name
struct DiscWithDeriv <: AbstractComponent end
s_init(::DiscWithDeriv) = (n = 0.0,)
x_init(::DiscWithDeriv) = (q = 0.0,)
y_types(::DiscWithDeriv) = (y = Float64,)
y_state(::DiscWithDeriv, (; s)) = (y = s.n,)
s_update(::DiscWithDeriv, (; s)) = (n = s.n + 1,)
tag("discrete + x_init", [(k, getfield(d, :declaration), d.reason) for (k, d) in
     kindsof(fail(() -> build(Group((; c = DiscWithDeriv())))))])

# L6b-116: the discrete allocator's scalar
const SEEN = Any[]
struct DiscWS <: AbstractComponent end
s_init(::DiscWS) = (n = 0.0,)
y_types(::DiscWS) = (y = Float64,)
ws_init(::DiscWS, ::Type{T}) where {T} = (push!(SEEN, T); (buf = zeros(T, 1),))
y_state(::DiscWS, (; s)) = (y = s.n,)
s_update(::DiscWS, (; s)) = (n = s.n + 1,)
sim = Simulation(Group((; c = DiscWS())); Δt_frame = 1//10)
init!(sim); run!(sim; t_end = 0.3)
tag("discrete ws_init scalars", unique(SEEN))

# L6b-071: face-name uniqueness across both boundary declarations
asm = Group((; a = Integrator(), b = Integrator()); local_wires = ("a/y" => "b/u",),
            input_wires = ("q" => "a/u",), output_wires = ("b/y" => "q",))
tag("face collision", [(k, d.faces, d.site) for (k, d) in kindsof(fail(() -> build(asm)))])

# L6b-026: branch-shape-stable returns
struct Branchy <: AbstractComponent end
x_init(::Branchy) = nothing
y_types(::Branchy) = (a = Float64, b = Float64)
y_state(::Branchy, (; t)) = t < 0.05 ? (a = 1.0, b = 2.0) : (a = 1.0,)
sim = Simulation(Group((; c = Branchy())); Δt_frame = 1//100)
init!(sim)
e = fail(() -> run!(sim; t_end = 0.2))
tag("branch shape", (typeof(e), e isa R.StepError ? (e.cause.reason, e.cause.observed_fields, e.t, e.boundary) : e))

# L6b-028: a bare contract's stage returns the bare value
struct BareOut <: AbstractComponent end
x_init(::BareOut) = nothing
y_types(::BareOut) = Float64
y_state(::BareOut, _) = 3.0
sim = Simulation(Group((; c = BareOut()); output_wires = ("c/y" => "out",)); Δt_frame = 1//10)
init!(sim)
tag("bare return port", port(sim, "c", :y))

# L6b-198 / L6b-220: a bare store's leaf is the letter; headless get_state
sim = Simulation(Group((; c = Integrator()); input_wires = ("in" => "c/u",)); Δt_frame = 1//100)
init!(sim, set(u = (in = 0.0,)))
lin = linearize(sim, taps(x = (q = get_state("c"),), u = (in = get_input(:in),)))
tag("headless get_state on bare store", lin.A)
tag("x_init(Integrator()) typeof", typeof(x_init(Integrator())))
struct BareInt <: AbstractComponent end
x_init(::BareInt) = 1
y_types(::BareInt) = (y = Float64,)
x_deriv(::BareInt, _) = 0
y_state(::BareInt, _) = (y = 0.0,)
tag("bare Int x_init", [(k, d.name, d.reason) for (k, d) in kindsof(fail(() -> build(Group((; c = BareInt())))))])
e = fail(() -> linearize(sim, taps(x = (q = get_state("c", "foo"),), u = (in = get_input(:in),))))
tag("named head vs bare", e isa R.DiagnosticError ? [(typeof(d), d) for d in R.diagnostics(e)] : e)

# L6b-234: proposal shaping, the step count
sim = Simulation(Group((; c = Integrator()); input_wires = ("in" => "c/u",)); Δt_frame = 1//10,
                 algorithm = BS3(), h_max = 1//20, h_min = 1//100)
m = sim.model
for (p, r) in ((0.03, 0.1), (0.001, 0.1), (0.001, 0.035), (1.0, 0.1), (0.02, 0.07))
    steps = R._shaped_steps(m, p, 0.0, r)
    tag("shaped p=$p r=$r", (steps, ceil(r / min(p, 0.05)), floor(r / 0.01)))
end
