module P
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
include(joinpath(pwd(), "test/imports.jl"))
include(joinpath(pwd(), "test/fixtures.jl"))
lin_pend() = Group((; s = Sum(), c = Pendulum()); local_wires = ("s/e" => "c/u",),
                   input_wires = ("τ" => "s/a", "d" => "s/b"),
                   output_wires = ("c/θ" => "θ", "s/e" => "u_eff"))
lin_point(θ = 0.3) = combine(at("c", condition(Pendulum(); θ = θ)),
                             set(u = (τ = 9.81 * sin(θ), d = 0.0)))
lin_taps() = taps(x = (θ = get_state("c", :θ), ω = get_state("c", :ω)),
                  u = (τ = get_input(:τ), d = get_input(:d)),
                  y = (θ = get_face(:θ), u_eff = get_face(:u_eff)))
other_taps() = taps(x = (ω = get_state("c", :ω),), y = (q = get_output("c", :ω),))
third_taps() = taps(x = (a = get_state("c", :θ),), u = (τ = get_input(:τ),), y = (e = get_output("s", :e), f = get_face(:θ)))

function timed(label, f)
    r = @timed f()
    println(rpad(label, 40), " time=", round(r.time, digits = 4), "s compile=", round(r.compile_time, digits = 4), "s")
    r.value
end

materialized = build(lin_pend(); activations = (Float64, LinearizeDual))
println("activation keys: ", collect(keys(materialized.activations)))
m = Model(materialized; h = 1//10)
init!(m, lin_point())
before = Set(keys(materialized.activations))
timed("1st call, materialized", () -> linearize(m, lin_taps()))
timed("2nd call, same taps", () -> linearize(m, lin_taps()))
timed("3rd call, other taps", () -> linearize(m, other_taps()))
timed("4th call, third taps", () -> linearize(m, third_taps()))
timed("5th call, third taps again", () -> linearize(m, third_taps()))
timed("about form, materialized, first", () -> linearize(m, lin_taps(); about = lin_point()))
timed("about form, again", () -> linearize(m, lin_taps(); about = lin_point()))
println("new activation entries: ", setdiff(Set(keys(materialized.activations)), before))

# the same structure, not listed: a fresh model of a new type
plain = build(Group((; s = Sum(), c = Pendulum(1.0, 0.1)); local_wires = ("s/e" => "c/u",),
                   input_wires = ("τ" => "s/a", "d" => "s/b"),
                   output_wires = ("c/θ" => "θ", "s/e" => "u_eff")))
m2 = Model(plain; h = 1//10); init!(m2, lin_point())
timed("not listed, first call (body cached)", () -> linearize(m2, lin_taps()))
println("plain keys: ", length(keys(plain.activations)))
end
