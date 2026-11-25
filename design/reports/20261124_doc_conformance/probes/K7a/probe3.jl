# K7a probe: longitudinal_aircraft.md against the code. Run from the worktree W with --project=examples/test.
using Test, LinearAlgebra
using Statistics: std
using Redstone, RedstoneExamples
import Redstone: Build, Simulation, build, init!, run!, step!, stage!, trim!, linearize, state, modes,
    series, reads, get_output, get_face, get_input, get_state, taps, termination, lifecycle, set, at, combine,
    override, checkpoint, restore!, replay!, trace, local_wires, diagnostics, DiagnosticError, TapResolution,
    AlgebraicCycle, Group, Absolute
using Redstone.Library: Constant, GaussianWhiteNoise, SumJunction, Junction, StopRequest, DiscretePID
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "examples/test/utils.jl"))
import RedstoneExamples: Longitudinal, aircraft, level_flight, longitudinal_taps, lqr_gains, closed_loop,
    trimmed, pitch_hold, autopilot, cruise, piloted, hand_flown, approach, GroundContact, actuators, feedback_wires

pr(label, xs...) = println("PROBE ", label, ": ", join(xs, " | "))
r(x, n = 4) = round(x; sigdigits = n)
function sect(f, name)
    println("== ", name)
    try f() catch err; println("SECTION FAILED ", name, ": ", sprint(showerror, err)[1:min(end, 600)]); end
end

function trim_of(plant)
    m = Group((; plant); input_wires = ("δe" => "plant/δe", "δt" => "plant/δt"))
    sim = Simulation(m; Δt_frame = 1//100)
    rep = trim!(sim, level_flight(); baseline = set(u = (δe = 0.0, δt = 0.5)))
    (sim, rep)
end

sim0, report = trim_of(Longitudinal())
solution = report.solution
lin = linearize(sim0, longitudinal_taps())
A, B = lin.A, lin.B


sect("phugoid without drag speed dependence") do
    A2 = copy(A); A2[1, 1] = 0.0
    for (nm, M) in (("A", A), ("A with A[1,1]=0", A2))
        λ = eigvals(M); up = filter(x -> imag(x) > 0, λ); p = up[argmin(imag.(up))]
        pr("phugoid $nm ωn ζ", abs(p), -real(p) / abs(p))
    end
    # Cmq = 0 plant, A11 = 0
    s0, r0 = trim_of(Longitudinal(Cmq = 0.0)); l0 = linearize(s0, longitudinal_taps()); B0 = copy(l0.A); B0[1, 1] = 0.0
    λ = eigvals(B0); up = filter(x -> imag(x) > 0, λ); p = up[argmin(imag.(up))]
    pr("Cmq=0, A11=0 phugoid ωn ζ", abs(p), -real(p) / abs(p))
end
