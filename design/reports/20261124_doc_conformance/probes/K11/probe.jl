using Redstone, StaticArrays
import Redstone: AbstractComponent, Group, Deployment, build, init!, step!, stage!, port, state,
    x_init, s_init, u_types, y_types, y_direct, y_state, x_deriv, s_update, diagnostics, DiagnosticError,
    input_wires, RK4, Simulation, replay!, run!, trace, series, set

macro tryit(label, ex)
    quote
        try
            r = $(esc(ex))
            println("probe:", $(esc(label)), " OK -> ", repr(r))
        catch e
            println("probe:", $(esc(label)), " ERR ", typeof(e), " ", e isa DiagnosticError ? [typeof(d) for d in diagnostics(e)] : sprint(showerror, e)[1:min(end,300)])
        end
    end
end

# P1: Simulation kwargs, Δt_base default, t0 = 0.0
struct PIc <: AbstractComponent; k_p::Float64; k_i::Float64; end
s_init(::PIc) = (s_i = 0.0,)
u_types(::PIc) = (engage = Bool, u_latch = Float64, e = Float64)
y_types(::PIc) = (u_cmd = Float64,)
y_direct(c::PIc, (; s, u)) = (; u_cmd = u.engage ? u.u_latch : c.k_p*u.e + s.s_i)
s_update(c::PIc, (; s, u, Δt)) = (; s_i = u.engage ? u.u_latch - c.k_p*u.e : s.s_i + c.k_i*Δt*u.e)

# update-only variant: output ignores engage
struct PIlate <: AbstractComponent; k_p::Float64; k_i::Float64; end
s_init(::PIlate) = (s_i = 0.0,)
u_types(::PIlate) = (engage = Bool, u_latch = Float64, e = Float64)
y_types(::PIlate) = (u_cmd = Float64,)
y_direct(c::PIlate, (; s, u)) = (; u_cmd = c.k_p*u.e + s.s_i)
s_update(c::PIlate, (; s, u, Δt)) = (; s_i = u.engage ? u.u_latch - c.k_p*u.e : s.s_i + c.k_i*Δt*u.e)

mk(c) = Group((; c); input_wires = ("engage" => "c/engage", "u_latch" => "c/u_latch", "e" => "c/e"))

@tryit "P1 sim kw" begin
    sim = Simulation(mk(PIc(1.0, 1.0)); Δt_frame = 1//50, algorithm = RK4())
    d = sim.model.deployment
    (d.Δt_frame, d.Δt_base, d.algorithm)
end
for (nm, C) in (("same-tick", PIc), ("update-only", PIlate))
    @tryit "P2 $nm" begin
        sim = Simulation(mk(C(1.0, 1.0)); Δt_frame = 1//50)
        init!(sim, set(u = (engage = false, u_latch = 5.0, e = 1.0)); t0 = 0.0)
        stage!(sim, "engage" => true)
        step!(sim; frames = 1)
        (port(sim, "c", :u_cmd), state(sim, "c").s_i)
    end
end

# P3: forgotten ẋ entry
struct TwoX <: AbstractComponent end
x_init(::TwoX) = (a = 0.0, b = 0.0)
y_types(::TwoX) = (a = Float64,)
y_state(::TwoX, (; x)) = (a = x.a,)
x_deriv(::TwoX, (; x)) = (a = 1.0,)
@tryit "P3 forgotten xdot" begin
    sim = Simulation(Group((; t = TwoX())); Δt_frame = 1//50)
    init!(sim); step!(sim; frames = 1); state(sim, "t")
end

# P4: algebraic loop and P5 unconnected
struct Gn <: AbstractComponent end
u_types(::Gn) = (e = Float64,)
y_types(::Gn) = (out = Float64,)
y_direct(::Gn, (; u)) = (out = 2u.e,)
@tryit "P4 loop" build(Group((; a = Gn(), b = Gn()); local_wires = ("a/out" => "b/e", "b/out" => "a/e")))
@tryit "P5 unconnected" build(Group((; a = Gn())))

# P7: stage-1 port from s closes a tick-domain loop
struct Acc <: AbstractComponent end
s_init(::Acc) = (v = 0.0,)
u_types(::Acc) = (e = Float64,)
y_types(::Acc) = (out = Float64, prev = Float64)
y_state(::Acc, (; s)) = (prev = s.v,)
y_direct(::Acc, (; s, u)) = (out = s.v + u.e,)
s_update(::Acc, (; s, y, u)) = (v = y.out,)
@tryit "P7 s-field stage-1 port in output contract" begin
    b = build(Group((; a = Acc(), b = Acc()); local_wires = ("a/out" => "b/e", "b/prev" => "a/e")))
    "built"
end
@tryit "P7b naive loop" build(Group((; a = Acc(), b = Acc()); local_wires = ("a/out" => "b/e", "b/out" => "a/e")))
