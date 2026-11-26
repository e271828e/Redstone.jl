# Does the nominal round read x before or after projection, and can it throw
# where the Float64 init! and the pre-fix Dual init! do not?
include(joinpath(@__DIR__, "probe_common.jl"))

rotor_hold() = Group((; rot = Rotor(), zoh = ZOH()); local_wires = ("rot/c" => "zoh/in",))

# A continuous reader of the rotor's cosine that throws off the unit circle.
struct Arccos <: AbstractComponent end
x_init(::Arccos) = nothing
u_types(::Arccos) = (c = Float64,)
y_types(::Arccos) = (θ = Float64,)
y_direct(::Arccos, (; u)) = (θ = acos(u.c),)

rotor_acos() = Group((; rot = Rotor(), ac = Arccos(), zoh = ZOH());
                     local_wires = ("rot/c" => "ac/c", "ac/θ" => "zoh/in"))

for T in (Float64, D8)
    m = Model(rotor_hold(), T; Δt_frame = 1//10)
    init!(m, at("rot", set(x = (r = SVector(2.0, 0.0),))))
    println(T === Float64 ? "Float64" : "D8", ": rot.r = ", ForwardDiff.value.(state(m, "rot").r),
            "  rot/c = ", ForwardDiff.value(port(m, "rot", :c)), "  zoh/out = ", port(m, "zoh", :out))
end

for T in (Float64, D8)
    m = Model(rotor_acos(), T; Δt_frame = 1//10)
    err = failure(() -> init!(m, at("rot", set(x = (r = SVector(2.0, 0.0),)))))
    println(T === Float64 ? "Float64" : "D8", ": acos init! -> ", err === nothing ? "ok, zoh/out = $(port(m, "zoh", :out)), status $(m.status)" : (typeof(err), err isa StepError ? err.cursor : nothing))
end

# The pre-fix behaviour: the same two models with the new call removed.
const SRC = read(joinpath(TREE, "src", "model.jl"), String)
i = findfirst("function init!(model::Model{T}, plan::ConditionPlan; t0 = 0,", SRC); j = findnext("\nend\n", SRC, last(i))
Base.include_string(Redstone, replace(SRC[first(i):last(j)],
    "        _establish_frozen!(model, origin)   # a non-nominal scalar's frozen cells (D-481)\n" => ""), "revert")
m = Model(rotor_hold(), D8; Δt_frame = 1//10)
init!(m, at("rot", set(x = (r = SVector(2.0, 0.0),))))
println("pre-fix D8 rotor_hold: zoh/out = ", port(m, "zoh", :out))
m = Model(rotor_acos(), D8; Δt_frame = 1//10)
err = failure(() -> init!(m, at("rot", set(x = (r = SVector(2.0, 0.0),)))))
println("pre-fix D8 acos init! -> ", err === nothing ? "ok, status $(m.status)" : typeof(err))
