# The exact-arithmetic audit's probes (report.md). Each line names a site and
# what an input that overflows it does: a value, a diagnostic, or a raw error.
# From the repository root, at 1074792:
#
#     julia --startup-file=no --project=test design/reports/20261113_exact_arithmetic/probes.jl
#
# Probe C5 does not terminate. It runs only with PROBE_HANG=1, and is best run
# under a timer: `perl -e 'alarm 200; exec @ARGV' julia …`.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff
import Random
include(joinpath(pwd(), "test", "imports.jl"))
include(joinpath(pwd(), "test", "fixtures.jl"))

function probe(label, f)
    t = @elapsed r = try
        "value " * first(repr(f(); context = :limit => true), 120)
    catch err
        if err isa DiagnosticError
            ds = err.carried isa Vector ? err.carried : [err.carried]
            "refused " * join(["$(nameof(typeof(d)))($(hasproperty(d, :parameter) ? d.parameter :
                                hasproperty(d, :argument) ? d.argument : :-), $(hasproperty(d, :reason) ? d.reason : :-))" for d in ds], ", ")
        else
            "RAW $(nameof(typeof(err)))"
        end
    end
    println(rpad(label, 52), r, t > 0.5 ? "  [$(round(t; digits = 1)) s]" : "")
end

anchored(rates) = build(Group(NamedTuple{keys(rates)}(Tuple(TickCounter() for _ in rates));
                              sample_times = rates))
nested(K1, K2) = build(Group((; g = Group((; a = TickCounter()); sample_times = (; a = Relative(K2))));
                             sample_times = (; g = Relative(K1))))
rows(d) = [(r.D, r.Φ) for r in d.schedule.rows]
loop_build = build(feedback_model())
point = set(u = (ref = 0.0,))
origin(t0) = (m = Model(feedback_model(); Δt_frame = 1//10); init!(m, point; t0); m.exec.clock.t₀)

println("== A. The declarations (section 2.1)")
probe("A1 Period(big(2)^70)", () -> Period(big(2)^70))
probe("A2 Period(big(1)//big(2)^70)", () -> Period(big(1) // big(2)^70))
probe("A3 Absolute(Period(1), big(1)//big(2)^70)", () -> Absolute(Period(1), big(1) // big(2)^70))
probe("A4 Hz(typemin(Int))", () -> Hz(typemin(Int)))
probe("A5 Hz(0)", () -> Hz(0))
probe("A6 build, Absolute(Hz(0))", () -> anchored((; a = Absolute(Hz(0)))))
probe("A7 Deployment, Absolute(Hz(0))", () -> Deployment(anchored((; a = Absolute(Hz(0)))); Δt_frame = 1))

println("== B. The fold and the schedule's multiply-add (section 2.2)")
probe("B1 Relative(2^32+1) in Relative(2^32+1), rows", () -> rows(Deployment(nested(2^32 + 1, 2^32 + 1); Δt_frame = 1)))
println(rpad("   the true divisor", 52), big(2^32 + 1)^2)
probe("B2 … and a run's first frame", () -> (s = Simulation(nested(2^32 + 1, 2^32 + 1); Δt_frame = 1); init!(s); step!(s); :ran))
probe("B3 Relative(2^32) in Relative(2^32), rows", () -> rows(Deployment(nested(2^32, 2^32); Δt_frame = 1)))
probe("B4 … and a run's first frame", () -> (s = Simulation(nested(2^32, 2^32); Δt_frame = 1); init!(s); step!(s); :ran))
probe("B5 Relative(3) in Relative(2^62)", () -> rows(Deployment(nested(3, 2^62); Δt_frame = 1)))
probe("B6 Relative(2^30) under Absolute(Period(2^40))",
      () -> rows(Deployment(build(Group((; g = Group((; a = TickCounter()); sample_times = (; a = Relative(2^30))));
                                        sample_times = (; g = Absolute(Period(2^40)))));
                            Δt_frame = 1//2^20, Δt_base = 1//2^20)))

println("== C. The grid report (section 2.3)")
probe("C1 gcd, periods 1//(2^40+1) and 1//(2^40+3)",
      () -> Deployment(anchored((; a = Absolute(Period(1//(2^40 + 1))), b = Absolute(Period(1//(2^40 + 3))))); Δt_frame = 1))
probe("C2 the same, Δt_base = :derive",
      () -> Deployment(anchored((; a = Absolute(Period(1//(2^40 + 1))), b = Absolute(Period(1//(2^40 + 3))))); Δt_frame = 1, Δt_base = :derive))
probe("C3 factor past Int, Absolute(Period(2^40), 1//(2^23+1))",
      () -> Deployment(anchored((; a = Absolute(Period(2^40), 1//(2^23 + 1)))); Δt_frame = 1))
probe("C4 trial division, one anchor at 1//(2^61-1)",
      () -> Deployment(anchored((; a = Absolute(Period(1//(2^61 - 1))))); Δt_frame = 1, Δt_base = :derive))
if get(ENV, "PROBE_HANG", "0") == "1"
    probe("C5 trial division, one anchor at 1//(2^63-25)",
          () -> Deployment(anchored((; a = Absolute(Period(1//(typemax(Int) - 24))))); Δt_frame = 1))
end

println("== D. The period door, Deployment's keywords (section 2.4)")
probe("D1 Δt_frame = big(2)^70", () -> Deployment(loop_build; Δt_frame = big(2)^70))
probe("D2 Δt_frame = big(1)//100", () -> Deployment(loop_build; Δt_frame = big(1)//100))
probe("D3 Δt_frame = Int32(1)//Int32(100)", () -> Deployment(loop_build; Δt_frame = Int32(1)//Int32(100)))
probe("D4 Δt_frame = Float16(0.5)", () -> Deployment(loop_build; Δt_frame = Float16(0.5)))
probe("D5 Δt_frame = true", () -> Deployment(loop_build; Δt_frame = true).Δt_frame)
probe("D6 Δt_frame = 1//0", () -> Deployment(loop_build; Δt_frame = 1//0))

println("== E. The origin door, init!'s t0 (section 2.6)")
probe("E1 t0 = Float16(0.1)", () -> origin(Float16(0.1)))
probe("E2 t0 = big(1)//3", () -> origin(big(1)//3))
probe("E3 t0 = Int32(1)//Int32(3)", () -> origin(Int32(1)//Int32(3)))
probe("E4 t0 = big(2)^70", () -> origin(big(2)^70))
probe("E5 t0 = true", () -> origin(true))
probe("E6 t0 = 1e-4", () -> origin(1e-4))

println("== F. Boundary zero's clock (section 2.6)")
let model = Model(feedback_model(); Δt_frame = 1//10), t₀ = 684943219091290305//514823562239077262
    integers = Redstone._clock_integers(t₀, model.deployment)
    println(rpad("F1 Float64(t₀), _instant at frame 0, nearest", 52),
            (Float64(t₀), Redstone._instant(integers..., 0), Float64(big(numerator(t₀)) // big(denominator(t₀)))))
    init!(model, point; t0 = t₀)
    probe("F2 checkpoint at boundary zero",
          () -> (checkpoint(model); :taken))
end

println("== G. The clock's division past 2^53 (sections 2.5, 4)")
Random.seed!(3)
let worst = 0.0, worst_rel = 0.0, over = 0, n = 1_000_000
    for _ in 1:n
        D = Int128(rand(2^60:2^62)) * rand(2^20:2^40)
        N = 2D - Int128(rand(1:2^50))                  # an instant just below 2, where an ulp is smallest relative to it
        exact = big(N) / big(D)
        err = abs(big(Float64(N) / Float64(D)) - exact)
        ulps = Float64(err / eps(Float64(exact)))
        over += ulps > 2; worst = max(worst, ulps); worst_rel = max(worst_rel, Float64(err / (exact * big(2.0)^-52)))
    end
    println(rpad("G1 Float64(N)/Float64(D), N/D just below 2", 52),
            "worst $(round(worst; digits = 2)) ulps and $(round(worst_rel; digits = 2))·2^-52·|t|, $over of $n past two ulps")
end
for (t0, Δt) in ((1.7631e9 + 0.123456, 1//10), (1.7631e9 + 0.123456, 1//1000), (12345.678, 1//10))
    model = Model(feedback_model(); Δt_frame = Δt)
    init!(model, point; t0)
    c = model.exec.clock
    off = count(0:9999) do k
        exact = big(numerator(c.t₀)) // big(denominator(c.t₀)) + k * big(numerator(Δt)) // big(denominator(Δt))
        Redstone._instant(c.origin, c.unit, c.scale, k * model.deployment.lattice.frame) != Float64(exact)
    end
    println(rpad("G2 t0 = $t0, Δt_frame = $Δt", 52),
            "origin integer of $(round(log2(Float64(c.origin)); digits = 1)) bits, $off of 10000 frame tops off the nearest float")
end
# A time typed from a float origin as `t0 + 5.0` is the float nearest its instant,
# since float addition rounds once. Does the frame top at that instant read it?
let t0 = 1.7631e9 + 0.123456, model = Model(feedback_model(); Δt_frame = 1//10)
    init!(model, point; t0)
    c = model.exec.clock
    off = count(s -> Redstone._instant(c.origin, c.unit, c.scale, 10s * model.deployment.lattice.frame) != t0 + s, 1:1000)
    println(rpad("G3 frame tops at t0 + s, s = 1:1000", 52), "$off of 1000 differ from `t0 + s`")
end
# Boundary zero's clock is `Float64(t₀)`, the float origin itself; `checkpoint`
# compares it with `_instant` at frame 0. How often do they part over wall-clock
# origins, floats drawn near today's `time()`?
Random.seed!(4)
for Δt in (1//10, 1//100, 1//1000, 1//1024)
    unit = Model(feedback_model(); Δt_frame = Δt).deployment.lattice.unit
    off = count(1:100_000) do _
        t0 = 1.7e9 + 1e8 * rand()
        Redstone._instant(Redstone._grid_integers(Rational{Int}(t0), unit)..., 0) != t0
    end
    println(rpad("G4 wall-clock t0, Δt_frame = $Δt", 52), "$off of 100000 origins whose frame-0 clock is not t0")
end
