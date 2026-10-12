# Runs §5.3's commanded-reset block (spec 988–992 at b08afca) against the package.
# From the repo root: julia --project=test -e 'include("test/repl.jl"); include("docs/spec_rewrite/ch05/scratch_survey/run_pi.jl")'

import Redstone: s_init, u_types, y_types, y_direct, s_update

# The block's component, with the fields and declarations the block implies.
struct PI <: AbstractComponent
    k_p::Float64
    k_i::Float64
end
s_init(::PI) = (s_i = 0.0,)
u_types(::PI) = (engage = Bool, u_latch = Float64, e = Float64)
y_types(::PI) = (u_cmd = Float64,)

# --- the block, verbatim ---
y_direct(c::PI, (; s, u)) = (; u_cmd = u.engage ? u.u_latch : c.k_p*u.e + s.s_i)
s_update(c::PI, (; s, u, Δt)) = (; s_i = u.engage ? u.u_latch - c.k_p*u.e
                                                      : s.s_i + c.k_i*Δt*u.e)
# ---

# The reset-in-update-only spelling the text says is legal but one tick late.
struct PILate <: AbstractComponent
    k_p::Float64
    k_i::Float64
end
s_init(::PILate) = (s_i = 0.0,)
u_types(::PILate) = (engage = Bool, u_latch = Float64, e = Float64)
y_types(::PILate) = (u_cmd = Float64,)
y_direct(c::PILate, (; s, u)) = (; u_cmd = c.k_p*u.e + s.s_i)
s_update(c::PILate, (; s, u, Δt)) = (; s_i = u.engage ? u.u_latch - c.k_p*u.e
                                                          : s.s_i + c.k_i*Δt*u.e)

# A supervisor publishing `engage` and the latch value from its own feedthrough
# stage. It engages at exactly one tick, t = 0.1.
struct Sup <: AbstractComponent end
s_init(::Sup) = (;)
u_types(::Sup) = (e = Float64,)
y_types(::Sup) = (engage = Bool, u_latch = Float64, e = Float64)
y_direct(::Sup, (; u, t)) = (; engage = abs(t - 0.1) < 1e-9, u_latch = 5.0, e = u.e)

loop(P) = Group((sup = Sup(), pi = P(2.0, 1.0));
                local_wires = ("sup/engage" => "pi/engage", "sup/u_latch" => "pi/u_latch",
                               "sup/e" => "pi/e"),
                input_wires = "e" => "sup/e",
                output_wires = "pi/u_cmd" => "u_cmd")

for P in (PI, PILate)
    sim = Simulation(loop(P); h = 1//50)
    init!(sim, fragment(u = (e = 1.0,)))
    println("== ", P)
    step!(sim; frames = 3)
    for k in 3:7
        println(rpad("t = $(sim.model.exec.clock.t)", 24), " published u_cmd = ", port(sim, "pi", :u_cmd),
                "   stored s_i = ", state(sim, "pi").s_i)
        step!(sim; frames = 1)
    end
end
