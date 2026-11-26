# What M1 (round after boundary_zero!) and M13 (tick 0 for ESTABLISH) leave in
# a model the suite does not build: a continuous consumer of a frozen cell read
# right after init!, and an offset discrete component.
include(joinpath(@__DIR__, "probe_common.jl"))
const SRC = read(joinpath(TREE, "src", "model.jl"), String)
cut(from, to) = (i = findfirst(from, SRC); j = findnext(to, SRC, last(i)); SRC[first(i):last(j)])
const ESTABLISH_SRC = cut("function _establish_frozen!(model::Model{T}, origin::Rational{Int}) where {T}", "\nend\n")
const INIT_SRC = cut("function init!(model::Model{T}, plan::ConditionPlan; t0 = 0,", "\nend\n")
ev(s) = Base.include_string(Redstone, s, "mutant")

zoh_neg() = Group((; zoh = ZOH(), neg = Negator());
                  local_wires = ("zoh/out" => "neg/u",), input_wires = ("r" => "zoh/in",))
# An offset hold: Φ₀ = 1 at a base period of 1//10 under a 1//20 frame.
offset_world() = Group((; zoh = ZOH(), base = ZOH()); sample_times = (; zoh = Relative(2, 1)),
                       input_wires = ("r" => ("zoh/in", "base/in"),))

function show_state(label)
    m = Model(zoh_neg(), D8; Δt_frame = 1//10)
    init!(m, set(u = (r = 2.0,)))
    println(label, ": zoh/out = ", port(m, "zoh", :out), "  neg/y = ", ForwardDiff.value(port(m, "neg", :y)),
            "  status ", m.status)
    for T in (Float64, D8)
        mo = try Model(offset_world(), T; Δt_frame = 1//10) catch err; println("   offset model: ", sprint(showerror, err)[1:min(end, 300)]); return end
        init!(mo, set(u = (r = 2.0,)))
        println("   offset ", T === Float64 ? "Float64" : "D8", ": zoh/out = ", port(mo, "zoh", :out))
    end
end

show_state("real")
ev(replace(INIT_SRC, "        _establish_frozen!(model, origin)   # a non-nominal scalar's frozen cells (D-481)\n        boundary_zero!(model)\n" =>
                     "        boundary_zero!(model)\n        _establish_frozen!(model, origin)\n"))
show_state("M1")
ev(INIT_SRC)
ev(replace(ESTABLISH_SRC, "_round!(nominal_exec, ESTABLISH)" => "_round!(nominal_exec, 0)"))
show_state("M13")
