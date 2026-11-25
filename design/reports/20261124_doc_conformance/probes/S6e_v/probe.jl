# S6e verifier probes, run from the pinned worktree with --project=test.
using Redstone
import Redstone: AbstractComponent, Group, build, Deployment, DiagnosticError, Relative, Absolute,
    x_init, s_init, u_types, y_types, y_state, y_direct, s_update
import Redstone.Library: SumJunction, Constant

diags(f) = try f(); "built" catch e
    e isa DiagnosticError ? [ (nameof(typeof(d)), d) for d in (e.carried isa Vector ? e.carried : [e.carried]) ] : e
end
show_d(label, r) = (println("== ", label); r isa Vector ? foreach(x -> println("  ", x[1], ": ", sprint(showerror, DiagnosticError(x[2], Redstone.Diagnostic[], nothing))[1:min(end, 300)]), r) : println("  ", r))

src3 = (; a = Constant(1.0), b = Constant(2.0), c = Constant(3.0))
# P1: the junction's output face
show_d("P1 out face", diags(() -> build(Group((; src3..., s = SumJunction{Float64,3}(), k = Constant(0.0));
    local_wires = ("a/y" => "s/in1", "b/y" => "s/in2", "c/y" => "s/in3", "s/out" => "s/in1")))))
show_d("P1 y face, ok", diags(() -> build(Group((; src3..., s = SumJunction{Float64,3}());
    local_wires = ("a/y" => "s/in1", "b/y" => "s/in2", "c/y" => "s/in3")))))
println("P1 y_types: ", y_types(SumJunction{Float64,3}()))
# P2: counted but unwired contributor
show_d("P2 arity 4, three wires", diags(() -> build(Group((; src3..., s = SumJunction{Float64,4}());
    local_wires = ("a/y" => "s/in1", "b/y" => "s/in2", "c/y" => "s/in3")))))
# P3: double-wired slot
show_d("P3 double wire", diags(() -> build(Group((; src3..., s = SumJunction{Float64,3}());
    local_wires = ("a/y" => "s/in1", "b/y" => "s/in2", "c/y" => "s/in2")))))
# P4: stale arity too small, third contributor kept on in3
show_d("P4 arity 2, three wires", diags(() -> build(Group((; src3..., s = SumJunction{Float64,2}());
    local_wires = ("a/y" => "s/in1", "b/y" => "s/in2", "c/y" => "s/in3")))))
# P5: zero arity
show_d("P5 zero arity", diags(() -> build(Group((; s = SumJunction{Float64,0}())))))
show_d("P5b zero arity exported", diags(() -> build(Group((; s = SumJunction{Float64,0}()); output_wires = ("s/y" => "tot",)))))
# P6: an assembly exports its junction's output
show_d("P6 export s/y", diags(() -> build(Group((; src3..., s = SumJunction{Float64,3}());
    local_wires = ("a/y" => "s/in1", "b/y" => "s/in2", "c/y" => "s/in3"), output_wires = ("s/y" => "wrench",)))))
show_d("P6b export s/out", diags(() -> build(Group((; src3..., s = SumJunction{Float64,3}());
    local_wires = ("a/y" => "s/in1", "b/y" => "s/in2", "c/y" => "s/in3"), output_wires = ("s/out" => "wrench",)))))

# P7: probe call count at build
const CALLS = Ref(0)
struct Counted <: AbstractComponent end
s_init(::Counted) = (n = 0,)
y_types(::Counted) = (n = Int,)
y_state(::Counted, (; s)) = (CALLS[] += 1; (n = s.n,))
s_update(::Counted, (; s)) = (n = s.n + 1,)
CALLS[] = 0; b = build(Group((; c = Counted()))); println("P7 y_state calls in build(): ", CALLS[])
CALLS[] = 0; b2 = build(Group((; c = Counted())); activations = (Float64, Redstone.ProbeDual)); println("P7 y_state calls with ProbeDual activation: ", CALLS[])

# P8: Relative range
for r in (Relative(0), Relative(2, 2), Relative(2, -1), Relative(3, 2))
    show_d("P8 $(r.D),$(r.Φ)", diags(() -> build(Group((; c = Counted()); sample_times = (c = r,)))))
end

# P9: base grid and a relative phase
d = Deployment(build(Group((; c = Counted(), e = Counted()); sample_times = (c = Relative(5, 2), e = Relative(2, 1)))); Δt_frame = 1//10)
println("P9 Δt_base = ", d.Δt_base, " Δt_frame = ", d.Δt_frame)
for row in d.schedule.rows; println("  row ", row.path, " anchor=", row.anchor, " D=", row.D, " Φ=", row.Φ, " Δt=", row.Δt); end
d0 = Deployment(build(Group((; c = Counted(), e = Counted()); sample_times = (c = Relative(5), e = Relative(2)))); Δt_frame = 1//10)
println("P9 phase-free Δt_base = ", d0.Δt_base)
g = Redstone._grid_report(build(Group((; c = Counted()); sample_times = (c = Relative(5, 2),))).structure.anchors)
println("P9 grid report with only a relative phase: ", g)
