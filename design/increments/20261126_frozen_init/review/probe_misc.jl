# A Symbol-valued frozen port read by a continuous consumer, a continuous
# y_direct downstream of a frozen cell read right after init!, a second init!
# after a failed one, and the Float64 door's cost.
include(joinpath(@__DIR__, "probe_common.jl"))

phase_world() = Group((; sel = PhaseSelector(), rd = PhaseReader());
                      local_wires = ("sel/phase" => "rd/phase",))
for T in (Float64, D8)
    m = Model(phase_world(), T; Δt_frame = 1//10)
    init!(m, at("sel", set(s = (n = 1,))))
    println(T, ": sel/phase = ", port(m, "sel", :phase), "  rd/armed = ", port(m, "rd", :armed))
end

# zoh -> neg: the continuous consumer's cell right after init!
zoh_neg() = Group((; zoh = ZOH(), neg = Negator());
                  local_wires = ("zoh/out" => "neg/u",), input_wires = ("r" => "zoh/in",))
for T in (Float64, D8)
    m = Model(zoh_neg(), T; Δt_frame = 1//10)
    init!(m, set(u = (r = 2.0,)))
    println(T, ": neg/y after init! = ", port(m, "neg", :y))
end

# Fuse throws on an input past 1: a failed init!, then a good one, at D8.
struct Fuse2 <: AbstractComponent end
x_init(::Fuse2) = nothing
u_types(::Fuse2) = (u = Float64,)
y_types(::Fuse2) = (y = Float64,)
y_direct(::Fuse2, (; u)) = u.u > 1 ? throw(Exploded()) : (y = u.u,)
fused() = Group((; zoh = ZOH(), fuse = Fuse2());
                local_wires = ("zoh/out" => "fuse/u",), input_wires = ("r" => "zoh/in",))
m = Model(fused(), D8; Δt_frame = 1//10)
e1 = failure(() -> init!(m, set(u = (r = 2.0,))))
println("first: ", typeof(e1), " status ", m.status, " zoh/out ", port(m, "zoh", :out))
init!(m, set(u = (r = 0.5,)))
println("second: status ", m.status, " zoh/out ", port(m, "zoh", :out), " fuse/y ", port(m, "fuse", :y))

# Float64 cost of init! on a model with discrete components.
mf = Model(sampled_loop(), Float64; Δt_frame = 1//50)
c = set(u = (ref = 1.0,))
plan = Redstone.resolve_condition(c, mf.deployment.build, Float64)
init!(mf, plan); init!(mf, plan)
println("Float64 init!(plan) allocated: ", @allocated(init!(mf, plan)))
md = Model(sampled_loop(), D8; Δt_frame = 1//50)
pland = Redstone.resolve_condition(c, md.deployment.build, D8)
init!(md, pland); init!(md, pland)
println("D8 init!(plan) allocated: ", @allocated(init!(md, pland)), "  time ", @elapsed(init!(md, pland)))
