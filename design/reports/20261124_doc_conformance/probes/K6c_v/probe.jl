# K6c_v probes, run from W with --project=test.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
include(joinpath(pwd(), "test", "imports.jl"))
include(joinpath(pwd(), "test", "fixtures.jl"))
fed(c) = Group((; c = c); input_wires = ("in" => "c/u",))
const L = Redstone.Library
fed_by(src, c) = Group((; k = src, c = c); local_wires = ("k/y" => "c/u",))
linear_root_model(system) = Group((; c = system); input_wires = ("in" => "c/u",), output_wires = ("c/y" => "out",))
feedback_loop(plant) = Group((; r = Constant(1.0), e = Junction{Float64, Float64, 2}(-), p = plant);
                             local_wires = ("r/y" => "e/in1", "p/y" => "e/in2", "e/y" => "p/u"))
say(tag, x) = println(tag, " => ", x)
tryit(f) = try f() catch e; e isa DiagnosticError ? (typeof(e), first(sprint(showerror, e), 300)) : e end

# K6c-003: realizability by length vs degree
say("P003 num=(0,0,1) den=(1,1)", tryit(() -> TransferFunction(num = (0, 0, 1), den = (1, 1))))
say("P003 num=(1,1,1) den=(1,1)", tryit(() -> TransferFunction(num = (1, 1, 1), den = (1, 1))))
say("P003 num=(1,2) den=(1,5)", typeof(TransferFunction(num = (1, 2), den = (1, 5))))

# K6c-017: has_stage by methods on type
say("P017 has_stage y_direct strictly proper TF", Redstone.has_stage(y_direct, TransferFunction(num = (1,), den = (0.5, 1))))
say("P017 has_stage y_state proper TF", Redstone.has_stage(y_state, TransferFunction(num = (1, 2), den = (1, 5))))
say("P017 loop lag TF", typeof(tryit(() -> build(feedback_loop(TransferFunction(num = (1,), den = (0.5, 1)))))))
say("P017 loop lead-lag TF", tryit(() -> build(feedback_loop(TransferFunction(num = (1, 2), den = (1, 5))))))

# K6c-022: port types by width, independently
mixed = StateSpace(A = [-1.0 0; 0 -2], B = [1.0; 1.0;;], C = [1.0 0; 0 1])
say("P022 NU=1 NY=2 u_types,y_types", (u_types(mixed), y_types(mixed)))
mixed2 = StateSpace(A = [-1.0 0; 0 -2], B = [1.0 0; 0 1], C = [1.0 2])
say("P022 NU=2 NY=1 u_types,y_types", (u_types(mixed2), y_types(mixed2)))

# K6c-028: whole one-element state tap
scalar_sim = Simulation(fed(StateSpace(A = [-2.0;;], B = [3.0;;], C = [1.0;;])); Δt_frame = 1//100)
init!(scalar_sim, set(u = (in = 0.0,)))
for leaf in ("x", :x, "", :q, "[1]")
    r = tryit(() -> linearize(scalar_sim, taps(x = (q = get_state("c", leaf),), u = (in = get_input(:in),))))
    say("P028 tap get_state(c, $(repr(leaf)))", r isa Linearization ? ("ok", r.A) : r)
end

# K6c-038: pole at origin refusal; static backslash on singular
say("P038 den=(1,0) u0=1", tryit(() -> TransferFunction(num = (1,), den = (1, 0), u0 = 1.0)))
say("P038 den=(1,0) u0=0", typeof(TransferFunction(num = (1,), den = (1, 0))))
say("P038 static \\ singular 1x1", SMatrix{1,1}(0.0) \ SVector(1.0))
say("P038 static \\ singular 2x2", SMatrix{2,2}(0.0, 0.0, 1.0, 0.0) \ SVector(0.0, 1.0))

# K6c-048: both stages produce the bare port
struct TwoStage <: AbstractComponent end
Redstone.x_init(::TwoStage) = SVector(0.0)
Redstone.u_types(::TwoStage) = Float64
Redstone.y_types(::TwoStage) = Float64
Redstone.x_deriv(::TwoStage, (; x, u)) = -x + SVector(u)
Redstone.y_state(::TwoStage, (; x)) = x[1]
Redstone.y_direct(::TwoStage, (; x, u)) = x[1] + 0.0 * u
say("P048 both stages", tryit(() -> build(fed_by(Constant(1.0), TwoStage()))))

# K6c-064 / K6c-069
lag_pair = Group((; k = Constant(1.0), tf = TransferFunction(num = (1,), den = (0.5, 1)), l = FirstOrderLag(τ = 0.5));
                 local_wires = ("k/y" => "tf/u", "k/y" => "l/u"))
sim = Simulation(lag_pair; Δt_frame = 1//100)
init!(sim, set()); step!(sim; t_plus = 1.0)
say("P064 tf, l, equal, state tf, state l", (repr(port(sim, "tf")), repr(port(sim, "l")), port(sim, "tf") === port(sim, "l"), state(sim, "tf"), state(sim, "l")))
s69 = Simulation(linear_root_model(TransferFunction(num = (1,), den = (0.5, 1), u0 = 3.0)); Δt_frame = 1//100)
init!(s69, set(u = (in = 3.0,)))
a69 = port(s69, "c"); step!(s69; t_plus = 1.0)
say("P069 start, after 1 s", (repr(a69), repr(port(s69, "c"))))

# K6c-072..074, K6c-106: allocations of step! over 0.1 s after warm-up
struct AbsSS{FT} <: L.AbstractLinearSystem{FT}
    A::SMatrix{2, 2, Float64}
    B::SMatrix{2, 2, Float64}
    C::SMatrix{2, 2, Float64}
    D::SMatrix{2, 2, Float64}
    x0::SVector{2, Float64}
end
struct AbsSS1{FT} <: L.AbstractLinearSystem{FT}
    A::SMatrix{1, 1, Float64}
    B::SMatrix{1, 1, Float64}
    C::SMatrix{1, 1, Float64}
    D::SMatrix{1, 1, Float64}
    x0::SVector{1, Float64}
end
L.realization(c::AbsSS) = c
L.realization(c::AbsSS1) = c
function step_alloc(model)
    s = Simulation(model; Δt_frame = 1//100)
    init!(s, set()); step!(s; t_plus = 0.1); step!(s; t_plus = 0.1)
    @allocated step!(s; t_plus = 0.1)
end
two = SMatrix{2,2}(-1.0, 0, 0.5, -2)
models = [
    "abstract scalar" => fed_by(Constant(1.0), AbsSS1{false}(SMatrix{1,1}(-1.0), SMatrix{1,1}(1.0), SMatrix{1,1}(1.0), SMatrix{1,1}(0.0), SVector(0.0))),
    "abstract 2x2" => fed_by(Constant(SVector(1.0, -1.0)), AbsSS{false}(two, SMatrix{2,2}(1.0, 0, 0.5, 1), SMatrix{2,2}(1.0, 0, 2, 1), zeros(SMatrix{2,2}), SVector(0.0, 0.0))),
    "SS scalar" => fed_by(Constant(1.0), StateSpace(A = [-1.0;;], B = [1.0;;], C = [1.0;;])),
    "SS 2x2" => fed_by(Constant(SVector(1.0, -1.0)), StateSpace(A = [-1 0.5; 0 -2], B = [1 0.5; 0 1], C = [1 2; 0 1])),
    "scalar lag" => fed_by(Constant(1.0), FirstOrderLag(τ = 0.5)),
    "vector lag" => fed_by(Constant(SVector(1.0, -2.0)), FirstOrderLag(τ = SVector(0.5, 0.25))),
    "TF lag form" => fed_by(Constant(1.0), TransferFunction(num = (1,), den = (0.5, 1))),
    "TF lead-lag" => fed_by(Constant(1.0), TransferFunction(num = (1, 2), den = (1, 5))),
    "Discretized scalar" => fed_by(Constant(1.0), DiscretizedStateSpace(A = [-1.0;;], B = [1.0;;], C = [1.0;;])),
]
for (name, m) in models
    say("P07x step! 0.1 s alloc $name", step_alloc(m))
end
# a tick's own cost: boundary! of a discrete component, and one frame of step!
let s = Simulation(fed_by(Constant(1.0), DiscretizedStateSpace(A = [-1.0;;], B = [1.0;;], C = [1.0;;])); Δt_frame = 1//100)
    init!(s, set()); Redstone.boundary!(s, 1); Redstone.boundary!(s, 1)
    say("P106 boundary! alloc discrete hold", @ballocated(Redstone.boundary!($s, 1)))
    step!(s; t_plus = 0.01); step!(s; t_plus = 0.01)
    say("P106 step! one frame alloc", @allocated step!(s; t_plus = 0.01))
end

# K6c-105: static exp
for n in (4, 5)
    M = @SMatrix randn(n, n)
    say("P105 exp $n x $n ns, bytes", (1e9 * @belapsed(exp($M)), @ballocated(exp($M))))
end
say("P105 VERSION", VERSION)

# K6c-082 / K6c-092
say("P082 DSS FT", (typeof(DiscreteStateSpace(A = [0.5;;], B = [1.0;;], C = [1.0;;])), typeof(DiscreteStateSpace(A = [0.5;;], B = [1.0;;], C = [1.0;;], D = [1.0;;]))))
d = DiscretizedStateSpace(A = [-1.0;;], B = [1.0;;], C = [1.0;;])
say("P092 held, realization(0.1)", (typeof(L.held(d)), L.realization(d, 0.1).A, exp(-0.1), L.realization(d, 0.1).B, 1 - exp(-0.1)))

# K6c-105, rerun on the augmented hold matrices [A B; 0 0] Δt at Δt = 1/100
for (nx, nu) in ((3, 1), (4, 1), (2, 2), (3, 2))
    A = @SMatrix randn(nx, nx); B = @SMatrix randn(nx, nu)
    M = vcat(hcat(A, B), hcat(zeros(SMatrix{nu, nx, Float64}), zeros(SMatrix{nu, nu, Float64}))) * 0.01
    say("P105b exp $(nx + nu) x $(nx + nu) augmented ns, bytes", (1e9 * @belapsed(exp($M)), @ballocated(exp($M))))
end
