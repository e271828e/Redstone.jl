# G6 fixer re-checks, run from the pinned worktree with --project=test.
using Redstone
import Redstone: AbstractComponent, Group, build, Deployment, DiagnosticError, Relative,
    s_init, y_types, y_state, s_update
import Redstone.Library: SumJunction, Constant, Unpack, Junction

kinds(f) = try f(); "built" catch e
    e isa DiagnosticError ? [nameof(typeof(d)) for d in (e.carried isa Vector ? e.carried : [e.carried])] : e
end
src3 = (; a = Constant(1.0), b = Constant(2.0), c = Constant(3.0))
println("S6e-014 arity 2, three wires: ", kinds(() -> build(Group((; src3..., s = SumJunction{Float64,2}());
    local_wires = ("a/y" => "s/in1", "b/y" => "s/in2", "c/y" => "s/in3")))))
println("S6e-016 s/out export: ", kinds(() -> build(Group((; src3..., s = SumJunction{Float64,3}());
    local_wires = ("a/y" => "s/in1", "b/y" => "s/in2", "c/y" => "s/in3"), output_wires = ("s/out" => "w",)))))
println("S6e-016 s/y export: ", kinds(() -> build(Group((; src3..., s = SumJunction{Float64,3}());
    local_wires = ("a/y" => "s/in1", "b/y" => "s/in2", "c/y" => "s/in3"), output_wires = ("s/y" => "w",)))))

struct Tick <: AbstractComponent end
s_init(::Tick) = (n = 0,)
y_types(::Tick) = (n = Int,)
y_state(::Tick, (; s)) = (n = s.n,)
s_update(::Tick, (; s)) = (n = s.n + 1,)
inner = Group((; t = Tick()); sample_times = (t = Relative(2, 1),))
outer = Group((; g = inner, k = Tick()); sample_times = (g = Relative(2, 1),))
d = Deployment(build(outer); Δt_frame = 1//10)
for row in d.schedule.rows; println("S6b-231 row ", row.path, " D=", row.D, " Φ=", row.Φ); end
println("CV6b-012 Unpack{Float64,1} y_types: ", y_types(Unpack{Float64,1}()))
println("CV6b-012 SumJunction{Float64,1} u_types: ", Redstone.u_types(SumJunction{Float64,1}()))
