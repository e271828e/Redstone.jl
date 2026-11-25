# CV6b_v probes, run from the pinned worktree with --project=test.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
const T = joinpath(pwd(), "test")
include(joinpath(T, "imports.jl"))
include(joinpath(T, "fixtures.jl"))
include(joinpath(T, "utils.jl"))
import Redstone.Library as L
p(tag, x) = println(tag, " => ", x)
tryp(tag, f) = try p(tag, f()) catch e; p(tag, "THROWS " * sprint(showerror, e)[1:min(end, 300)]) end

# P1 CV6b-012: a one-input Junction and a one-output Unpack declare named contracts
p("P1a Junction{F,F,1} u_types", u_types(L.Junction{Float64, Float64, 1}(identity)))
p("P1b Pack{F,1} u_types", u_types(L.Pack{Float64, 1}()))
p("P1c Unpack{F,1} y_types", y_types(L.Unpack{Float64, 1}()))
tryp("P1d Junction N=1 builds", () -> build(Group((; j = L.Junction{Float64, Float64, 1}(identity));
        input_wires = ("a" => "j/in1",), output_wires = ("j/y" => "b",))) isa Build)
p("P1e Junction y_types bare", y_types(L.SumJunction{Float64, 2}()))

let
# P2 CV6b-023, CV6b-010, CV6b-001
up = L.Unpack{Float64, 3}()
p("P2a Unpack u/y types", (u_types(up), y_types(up), x_init(up)))
p("P2b Unpack y_direct", y_direct(up, (; u = SVector(1.0, 2.0, 3.0))))
p("P2c And{3} fold", (L.And{3}().f, y_direct(L.And{3}(), (; u = (in1 = true, in2 = false, in3 = true))), u_types(L.And{3}())))

# P3 CV6b-033: as_static
p("P3a Vector", typeof(L.as_static([1.0, 2.0])))
p("P3b Diagonal", typeof(L.as_static(Diagonal([1.0, 2.0]))))
p("P3c MVector", typeof(L.as_static(MVector(1, 2))))
p("P3d scalar", typeof(L.as_static(3)))
logs = Test.collect_test_logs() do
    L.as_static(zeros(L.STATIC_WARN_LENGTH))
    L.as_static(zeros(L.STATIC_WARN_LENGTH + 1))
    L.as_static(zeros(L.STATIC_WARN_LENGTH + 2))
end
p("P3e warnings at 512, 513, 514", length(logs[1]))
p("P3f message", logs[1][1].message)

# P4 CV6b-022: Delay outputs
p("P4a Delay y_types", y_types(L.Delay(K = 2)))
p("P4b Delay taps y_types", y_types(L.Delay(K = 2, taps = true)))

# P5 CV6b-036, CV6b-037: root spelling refusals
tryp("P5a conjugate pair", () -> L.TransferFunction(poles = (-1 + 2im, -1 - 2im)).den)
tryp("P5b unpaired", () -> L.TransferFunction(poles = (-1 + 2im, -1.0)))
tryp("P5c ten pairs on circle (discrete)", () -> L.DiscreteTransferFunction(
        poles = [0.9 * cis(s * k * pi / 11) for k in 1:10 for s in (1, -1)]).den[end])
tryp("P5d mixed", () -> L.TransferFunction(num = (1,), poles = (-1.0,)))
tryp("P5e more zeros", () -> L.TransferFunction(zeros = (-1.0, -2.0), poles = (-3.0,)))
tryp("P5f complex gain", () -> L.TransferFunction(poles = (-1.0,), gain = 1im))
tryp("P5g zeros without poles", () -> L.TransferFunction(zeros = (-1.0,)))
tryp("P5h discrete mixed", () -> L.DiscreteTransferFunction(den = (1, 0.5), zeros = (0.1,), poles = (0.5,)))
tryp("P5i discrete unpaired", () -> L.DiscreteTransferFunction(poles = (0.5im, 0.1)))

# P6 CV6b-053: DiscreteStateSpace keywords
A = [0.5;;]; B = [1.0;;]; C = [1.0;;]
tryp("P6a s0", () -> L.DiscreteStateSpace(; A, B, C, s0 = [2.0]).s0)
tryp("P6b x0", () -> L.DiscreteStateSpace(; A, B, C, x0 = [2.0]))
tryp("P6c s0 wrong length", () -> L.DiscreteStateSpace(; A, B, C, s0 = [2.0, 1.0]))
tryp("P6d A size zero", () -> L.DiscreteStateSpace(; A = zeros(0, 0), B = zeros(0, 1), C = zeros(1, 0)))

# P7 CV6b-062: LimitedDoubleIntegrator vector event names
ldi = L.LimitedDoubleIntegrator(lower = SVector(-1.0, -1.0), upper = SVector(1.0, 1.0))
p("P7a LDI event names", keys(state_events(ldi)))
li = L.LimitedIntegrator(lower = SVector(-1.0, -1.0), upper = SVector(1.0, 1.0))
p("P7b LI event names", keys(state_events(li)))

# P8 CV6b-044, CV6b-029: Source
p("P8a Source(f) type", typeof(L.Source(sin)))
p("P8b y_types", y_types(L.Source(sin)))
seen = Set{Any}()
src = L.Source(t -> (push!(seen, typeof(t)); 2.0 * t))
m = Group((; s = src, e = L.Integrator()); local_wires = ("s/y" => "e/u",), output_wires = ("e/y" => "z",))
mb = build(m; activations = (Float64, LinearizeDual))
sim = Simulation(mb; Δt_frame = 1//10)
init!(sim, set())
lin = linearize(sim, taps(x = (x = get_state("e"),), y = (z = get_output("e"),)))
p("P8c f's time types under Float64 and LinearizeDual", seen)
err = failure(() -> build(single(L.Source(t -> 1))))
p("P8d Int at build", err === nothing ? nothing : typeof(only(diagnostics(err))))
late = L.Source(t -> t < 0.25 ? 0.0 : 1)
sim2 = Simulation(single(late); Δt_frame = 1//10)
init!(sim2, set())
err2 = failure(() -> run!(sim2; t_end = 1.0))
p("P8e Int later", err2 === nothing ? nothing : (typeof(err2), err2 isa Redstone.StepError ? typeof(err2.cause) : nothing))
end
