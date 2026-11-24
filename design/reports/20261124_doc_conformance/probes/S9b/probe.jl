# S9b probe: spec §9.2 (Deployment ... Warnings) and §9.3 (probing).
# Run: cd W && JULIA_LOAD_PATH="@" julia --startup-file=no --project=test P
using Test, StaticArrays, LinearAlgebra, ForwardDiff, Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test/imports.jl"))
include(joinpath(W, "test/fixtures.jl"))
include(joinpath(W, "test/utils.jl"))

section(s) = println("\n=== ", s)
dlist(err) = try Redstone.diagnostics(err) catch; [Redstone.diagnostic(err)] end
function reasons(f)
    try
        f(); println("  no throw")
    catch err
        if err isa DiagnosticError
            for d in dlist(err)
                println("  ", nameof(typeof(d)), " ",
                        hasproperty(d, :parameter) ? (d.parameter, d.reason, d.value, d.related) : "")
            end
        else
            println("  other throw: ", typeof(err), " ", sprint(showerror, err)[1:min(end,200)])
        end
    end
end
msg(f) = try f(); "no throw" catch err
    err isa DiagnosticError ? join((Redstone.message(d) for d in dlist(err)), "\n---\n") : sprint(showerror, err)
end
struct NoDefault{T}; a::T; b::T; end
struct Unsynthesized <: AbstractComponent end
x_init(::Unsynthesized) = nothing
u_types(::Unsynthesized) = (q = NoDefault{Float64},)
y_types(::Unsynthesized) = (s = Float64,)
y_direct(::Unsynthesized, (; u)) = (s = u.q.a + u.q.b,)

mr = build(MultiRate())
rampb = build(single(Ramp(1.0)))

# probe:20 -- the worked example (§6.3 / §9.2 table)
section("worked example at Δt_base = 2 ms")
dep = Deployment(mr; Δt_frame = 1//500)
for r in dep.schedule.rows; println("  ", r.path, " anchor=", r.anchor, " (D0,Φ0)=", (r.D, r.Φ), " Δt=", r.Δt); end
println(sprint(show, MIME("text/plain"), dep))
println("fields: ", fieldnames(Deployment))
println("anchors: ", mr.structure.anchors)
dep2 = Deployment(mr; Δt_frame = 1//100, Δt_base = 1//500)
println(sprint(show, MIME("text/plain"), dep2))
println(sprint(show, MIME("text/plain"), mr))
println(sprint(show, MIME("text/plain"), dep.schedule))

# time quantities
section("h_max exact")
for hm in (1//3, Rational(1/3), nothing, 1, 2, 1//2)
    d = Deployment(rampb; Δt_frame = 1, h_max = hm)
    println("  h_max=", hm, " resolved=", d.h_max, " lattice.bound=", d.lattice.bound, " ",
            Redstone._steps_line(d))
end
println("  equal(none, =frame, above): ",
        Deployment(rampb; Δt_frame = 1) == Deployment(rampb; Δt_frame = 1, h_max = 1) ==
        Deployment(rampb; Δt_frame = 1, h_max = 5))
println("  1//3 vs Rational(1/3): ", Deployment(rampb; Δt_frame = 1, h_max = 1//3) ==
        Deployment(rampb; Δt_frame = 1, h_max = Rational(1/3)))
println("  Δt_frame 0.01 vs 1//100 float repr equal? ", Float64(1//100) == 0.01)

section("exactness refusals")
for (name, v) in ((:float, 0.01), (:i32, Rational{Int32}(1, 100)), (:big_ok, big(1)//100),
                  (:big2_70, big(2)^70), (:div0, 1//0), (:neg, -1), (:zero, 0), (:inf, Inf),
                  (:str, "a"))
    println(" Δt_frame=", name)
    reasons(() -> Deployment(rampb; Δt_frame = v))
end
println(" Δt_frame missing"); reasons(() -> Deployment(rampb))
println(" Δt_frame = 1//100 -> ", Deployment(rampb; Δt_frame = Rational{Int32}(1, 100)).Δt_frame, " type ", typeof(Deployment(rampb; Δt_frame = Rational{Int32}(1, 100)).Δt_frame))
println(" h_max float"); reasons(() -> Deployment(rampb; Δt_frame = 1, h_max = 0.1))
println(" Δt_base float"); reasons(() -> Deployment(mr; Δt_frame = 1//100, Δt_base = 0.002))

section("h_min / algorithm")
println(" BS3 no h_min"); reasons(() -> Deployment(rampb; Δt_frame = 1, algorithm = BS3()))
println(" BS3 h_min 1//2 h_max 1//2 (above half)"); reasons(() -> Deployment(rampb; Δt_frame = 1, h_max = 1//2, h_min = 1//2, algorithm = BS3()))
println(" BS3 h_min=1//4 h_max=1//2 (at half)"); reasons(() -> Deployment(rampb; Δt_frame = 1, h_max = 1//2, h_min = 1//4, algorithm = BS3()))
println(" BS3 h_min 0.1 (float)"); reasons(() -> Deployment(rampb; Δt_frame = 1, h_min = 0.1, algorithm = BS3()))
println(" RK4 h_min above half"); reasons(() -> Deployment(rampb; Δt_frame = 1, h_min = 1, algorithm = RK4()))
println(" RK4 h_min=1//10 stored: ", Deployment(rampb; Δt_frame = 1, h_min = 1//10).h_min,
        " equal to none: ", Deployment(rampb; Δt_frame = 1, h_min = 1//10) == Deployment(rampb; Δt_frame = 1))
println(" attempt_budget default: ", Deployment(rampb; Δt_frame = 1).attempt_budget,
        " equal differing attempt_budget: ", Deployment(rampb; Δt_frame = 1, attempt_budget = 3) == Deployment(rampb; Δt_frame = 1))
println(" algorithm :x"); reasons(() -> Deployment(rampb; Δt_frame = 1, algorithm = :x))
println(" all event params bad together")
reasons(() -> Deployment(rampb; Δt_frame = 1, firing_budget = 0, localization_tol = -1.0, localization_budget = 0,
                        attempt_budget = 0, algorithm = 3))
println(" localization_tol Inf / NaN / 0.5 int");
reasons(() -> Deployment(rampb; Δt_frame = 1, localization_tol = Inf))
reasons(() -> Deployment(rampb; Δt_frame = 1, localization_tol = NaN))
println(" Δt_frame bad AND event bad AND h_max bad together:")
reasons(() -> Deployment(rampb; Δt_frame = -1, h_max = 0.5, firing_budget = 0))
println(" frame ok, base not dividing anchor:")
reasons(() -> Deployment(mr; Δt_frame = 1//30, Δt_base = 1//30))
println(msg(() -> Deployment(mr; Δt_frame = 1//30, Δt_base = 1//30)))

section("derive")
println(" derive on MultiRate (unanchored)")
println(msg(() -> Deployment(mr; Δt_frame = 1//100, Δt_base = :derive)))
println(" derive on no-anchor tree")
reasons(() -> Deployment(rampb; Δt_frame = 1, Δt_base = :derive))
function anchored_group2()
    comp = Group((; a = TickCounter(), b = TickCounter());
                 sample_times = (; a = Absolute(1//500), b = Absolute(1//10, 1//150)))
    build(comp)
end
ag = anchored_group2()
println(" derive anchored:")
dd = Deployment(ag; Δt_frame = 1//1500, Δt_base = :derive)
println(" derived base: ", dd.Δt_base, " warnings: ", length(dd.warnings), " ", map(w -> nameof(typeof(w)), dd.warnings))
println(sprint(show, MIME("text/plain"), dd))
println(sprint(show, MIME("text/plain"), dd.schedule))
println(sprint(show, MIME("text/plain"), ag))
println(" explicit coarsest-multiple: ")
reasons(() -> Deployment(ag; Δt_frame = 1//1000, Δt_base = 1//1000))
println(msg(() -> Deployment(ag; Δt_frame = 1//1000, Δt_base = 1//1000)))
println(" gcd(pool)=", Redstone._grid_report(ag.structure.anchors).admissible)
# derive when A₀ populated by discrete component: mix
mix = build(Group((; a = TickCounter(), b = TickCounter());
                  sample_times = (; a = Absolute(1//500), b = Relative(2))))
println(" derive mix:"); reasons(() -> Deployment(mix; Δt_frame = 1//500, Δt_base = :derive))
# GridUtilization only when min D0 > 1
d_nowarn = Deployment(build(Group((; a = TickCounter()); sample_times = (; a = Absolute(1//500)))); Δt_frame = 1//500, Δt_base = :derive)
println(" derive single anchor: warnings=", length(d_nowarn.warnings))
println(" GridUtilization message: ", Redstone.message(dd.warnings[1])[1:140])

section("prime attribution cap")
big_den = 1048583 * 1048589
println(" _prime_powers(1048583*1048589) = ", Redstone._prime_powers(big_den))
println(" _prime_powers(2^20*3)=", Redstone._prime_powers(2^20*3), " _prime_powers(1048573*3) ", Redstone._prime_powers(1048573*3))
println(" cap = ", Redstone.PRIME_DIVISOR_CAP, " unfactored(2^40)=", Redstone._unfactored(2^40), " unfactored(2^40-1)=", Redstone._unfactored(2^40-1))
gcomp = build(Group((; a = TickCounter(), b = TickCounter());
                    sample_times = (; a = Absolute(1//1048583), b = Absolute(1//1048589))))
rep = Redstone._grid_report(gcomp.structure.anchors)
println(" report admissible=", rep.admissible, " primes=", rep.primes)
println(Redstone._grid_block(rep))

section("scalar refusal")
for T in (Float32, BigFloat, Int, ForwardDiff.Dual{Nothing,Float32,1})
    print(" ", T, ": "); reasons(() -> Model(dep, T))
end
m64 = Model(dep, Float64)
println(" Dual ok: ", typeof(Model(dep, ForwardDiff.Dual{Nothing,Float64,2})))
println(" nested Dual ok: ", typeof(Model(dep, ForwardDiff.Dual{Nothing,ForwardDiff.Dual{Nothing,Float64,1},1})))
println(" Simulation(Model{Float64}) ok; warnings(sim) == vcat: ")
sim = Simulation(Model(dd, Float64))
println("  ", warnings(sim) == vcat(warnings(dd.build), warnings(dd)), " ", length(warnings(sim)), " Build,Deployment ", length(warnings(dd.build)), length(warnings(dd)))

section("trial binding")
println(" overflow anchor: ")
reasons(() -> build(Group((; a = TickCounter()); sample_times = (; a = Absolute(1//typemax(Int))))))
reasons(() -> build(Group((; a = TickCounter(), b = TickCounter()); sample_times = (; a = Absolute(typemax(Int)//3), b = Absolute(1//7)))))

section("show of Deployment variants")
println(sprint(show, MIME("text/plain"), Deployment(rampb; Δt_frame = 1, h_max = 1//3)))
println(sprint(show, MIME("text/plain"), Deployment(build(Group((; a = TickCounter()); sample_times = (; a = Relative(2)))); Δt_frame = 1//10)))
println(sprint(show, MIME("text/plain"), Deployment(mr; Δt_frame = 1//250, Δt_base = 1//500)))
println(sprint(show, MIME("text/plain"), Deployment(mr; Δt_frame = 1//250, Δt_base = 1//500, algorithm = BS3(), h_min = 1//5000)))
println(sprint(show, MIME("text/plain"), mr))
println(sprint(show, MIME("text/plain"), mr.outputs))
println(sprint(show, MIME("text/plain"), mr.events))

section("probe: counts and clock")
const LOG = Any[]
struct Spy <: AbstractComponent end
x_init(::Spy) = (q = 1.0,)
y_types(::Spy) = (y = Float64,)
ws_init(::Spy, ::Type{T}) where {T} = (push!(LOG, (:ws_init, T)); (tmp = Vector{T}(undef, 1),))
y_state(::Spy, (; x, t, ws)) = (push!(LOG, (:y_state, t, typeof(ws))); (y = x.q,))
x_deriv(::Spy, (; x, t)) = (push!(LOG, (:x_deriv, t)); (q = -x.q,))
spy_guard(::Spy, (; x)) = (push!(LOG, (:guard,)); x.q - 0.5)
spy_handler(::Spy, (; x)) = (push!(LOG, (:handler,)); (x = (q = 1.0,),))
state_events(::Spy) = (e = StateEvent(spy_guard, spy_handler),)
x_projection(::Spy, x) = (push!(LOG, (:proj,)); x)
struct DSpy <: AbstractComponent end
s_init(::DSpy) = (n = 0,)
y_types(::DSpy) = (n = Int,)
y_state(::DSpy, (; s, t, Δt)) = (push!(LOG, (:d_y_state, t, Δt)); (n = s.n,))
s_update(::DSpy, (; s, t, Δt)) = (push!(LOG, (:d_s_update, t, Δt)); (n = s.n + 1,))
b = build(Group((; a = Spy(), d = DSpy())))
foreach(println, LOG)
empty!(LOG)

section("probe_value")
@enum Color red green
struct HasCtor; a::Float64; HasCtor() = new(7.0); end
println(" ", Redstone.probe_value(Float64), Redstone.probe_value(Int), Redstone.probe_value(Bool), Redstone.probe_value(Color),
        Redstone.probe_value(SVector{2,Float64}), Redstone.probe_value(HasCtor), Redstone.probe_value(Float32))
println(" which for Bool: ", which(Redstone.probe_value, Tuple{Type{Bool}}))
println(" String: ", try Redstone.probe_value(String) catch e; typeof(e) end, " Symbol: ", try Redstone.probe_value(Symbol) catch e; typeof(e) end)
println(msg(() -> build(Group((; c = Unsynthesized()); input_wires = ("in" => "c/q",)))))
println(" Complex/Rational/Integer: ", try Redstone.probe_value(Complex{Float64}) catch e; typeof(e) end)

section("unknown AbstractAlgorithm subtype")
struct FooAlg <: AbstractAlgorithm end
reasons(() -> Deployment(rampb; Δt_frame = 1, algorithm = FooAlg()))
section("Deployment equality ignores build?")
println(Deployment(rampb; Δt_frame = 1) == Deployment(build(single(Ramp(2.0))); Δt_frame = 1))
