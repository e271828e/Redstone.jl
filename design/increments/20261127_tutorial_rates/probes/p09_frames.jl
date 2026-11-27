# p09: candidate A under three deployments: A (frame 1//200, base 1//200), V1 (frame 1//400,
# base 1//200) and V2 (frame 1//200, base 1//200, h_max = 1//400). The log, the trajectories at
# common instants, every pin of the report's section 5, the tests' indices, the approach's wall
# time and log stride, V1 without Δt_base, and the phase bodies' allocations.
include("common.jl")
using BenchmarkTools
import Redstone: warnings
solution = trim_solution()
deployments = (A = (Δt_frame = 1//200, Δt_base = 1//200), V1 = (Δt_frame = 1//400, Δt_base = 1//200),
               V2 = (Δt_frame = 1//200, Δt_base = 1//200, h_max = 1//400))
fps(dep) = Int(1 / dep.Δt_frame)

function climb(dep; h_step = 50.0, noise_psd = RE.sensor_noise_psd, t_end = 120.0)
    sim = Simulation(autopilot(solution; noise_psd); dep...)
    init!(sim, override(cruise(solution), set(u = (h_ref = 1000.0 + h_step,))))
    run!(sim; t_end)
    sim
end
function by_hand!(sim, dep; until = 60.0, engage = true)
    f(t) = round(Int, t * fps(dep))
    step!(sim; frames = f(5.0)); stage!(sim, "δe_pilot" => solution.δe - 0.02)
    step!(sim; frames = f(7.0) - f(5.0)); stage!(sim, "δe_pilot" => solution.δe)
    step!(sim; frames = f(30.0) - f(7.0)); engage && stage!(sim, "engage" => true)
    step!(sim; frames = f(until) - f(30.0))
end
function hand(dep)
    sim = Simulation(piloted(solution); dep...)
    init!(sim, hand_flown(solution)); by_hand!(sim, dep); run!(sim; t_end = 90.0); sim
end

sims = Dict{Symbol, Any}()
for (name, dep) in pairs(deployments)
    println("==== $name")
    s60 = climb(dep; t_end = 60.0)
    t = logged_times(s60)
    q = logged_port(s60, "cascade/q_ctl", :u)
    ch = change_times(s60, q)
    plant_ch = change_times(s60, logged_port(s60, "plant", :q))
    println("1. snapshots over 60 s: ", length(t), "; q_ctl changes ", length(ch), ", all on 200 Hz ", all(x -> on_grid(x, 200), ch),
            "; snapshots off the 200 Hz grid ", count(x -> !on_grid(x, 200), t), "; plant q changes ", length(plant_ch))
    rest = climb(dep; h_step = 0.0, noise_psd = QUIET, t_end = 60.0)
    @printf("3. rest drift h %.2e\n", maximum(abs, logged_port(rest, "plant", :h) .- 1000))
    c = climb(dep); sims[name] = c
    f5 = figures5(c)
    @printf("3. ch5 late %.4f %.4f peak %.4f Vexc %.4f\n", f5.late_h, f5.late_V, f5.peak, f5.V_exc)
    tc = logged_times(c)
    for (face, port, rate, σ) in ((:q_meas, :q, 200, 0.002), (:θ_meas, :θ, 50, 5e-4), (:h_meas, :h, 10, sqrt(0.018)), (:V_meas, :V, 10, 0.02))
        m = logged_face(c, "sensing", face)
        n = (m .- logged_port(c, "plant", port))[on_grid.(tc, rate)]
        @printf("3. %s on grid %s std/σ %.4f\n", face, all(x -> on_grid(x, rate), change_times(c, m)), std(n) / σ)
    end
    for (loop, rate, coarser) in (("q_ctl", 200, 50), ("θ_ctl", 50, 10), ("h_ctl", 10, nothing))
        chl = change_times(c, logged_port(c, "cascade/$loop", :u))
        println("3. $loop own grid ", all(x -> on_grid(x, rate), chl), coarser === nothing ? "" : " not only coarser " * string(!all(x -> on_grid(x, coarser), chl)))
    end
    h = hand(dep)
    f6 = figures6(h)
    @printf("3. ch6 gaps %.4f %.4f %.4f %.4f latch %.4f jumps %.5f %.5f act %.2e jitter %.4f recap %.4f\n", f6.gap_δe, f6.gap_δt,
            f6.gap_hθm, f6.gap_θqm, f6.t_latch, f6.jump_δe, f6.jump_δt, f6.jump_act, f6.jitter, f6.recapture)
    staged = series(h, reads(δe = get_input("δe_pilot"), engage = get_input("engage")))
    println("4. staged indices ", findfirst(!=(solution.δe), staged.δe), " ", findfirst(==(solution.δe), staged.δe[1002:end]) + 1001,
            " (search from 1002) engage ", findfirst(identity, staged.engage))
    un = Simulation(piloted(solution); dep...); init!(un, hand_flown(solution)); by_hand!(un, dep; until = 30.4, engage = false)
    tu = logged_times(un)
    for loop in ("q_ctl", "θ_ctl", "h_ctl")
        a = logged_port(h, "cascade/$loop", :u)[1:length(tu)]; b = logged_port(un, "cascade/$loop", :u)
        println("4. $loop departs at ", tu[findfirst(i -> a[i] != b[i], eachindex(b))])
    end
    println("4. snapshots in (30.2, 30.205): ", filter(x -> 30.2 < x < 30.205, tu))
    dt = @elapsed begin
        flight = Simulation(approach(solution); dep...)
        init!(flight, at("vehicle", hand_flown(solution))); by_hand!(flight, dep)
        top = checkpoint(flight); n = descend!(flight)
    end
    f7 = figures7(flight)
    tf = logged_times(flight)
    println("3. ch7 writes $n t_stop ", f7.t_stop, " tracking ", round(f7.tracking, digits = 4), " V ", round(f7.V_lo, digits = 3), "..", round(f7.V_hi, digits = 3))
    @printf("5. approach wall %.2f s; snapshots %d; median stride after 60 s %.4f s\n", dt, length(tf), sort(diff(tf[tf .> 60]))[end ÷ 2])
    sec = Simulation(approach(solution); dep...); restore!(sec, top); descend!(sec; sink_rate = 2.0)
    println("3. ch8 second ", termination(sec).t)
    bodies = phase_bodies(Simulation(approach(solution); dep...))
    allocs = map((:sweep_1, :sweep_2, :rhs, :ticks)) do k
        b = bodies[k]; b(); b(0); (@ballocated($b()), @ballocated($b(1)))
    end
    println("7. phase bodies allocations ", allocs, "; warnings ", warnings(Simulation(approach(solution); dep...)))
end
# 2. V1 against V2 at their common instants.
for (a, b) in ((:V1, :V2), (:A, :V2))
    ta, tb = logged_times(sims[a]), logged_times(sims[b])
    common = intersect(ta, tb)
    ia, ib = findall(in(common), ta), findall(in(common), tb)
    worst = maximum(name -> maximum(abs, logged_port(sims[a], "plant", name)[ia] .- logged_port(sims[b], "plant", name)[ib]), (:h, :V, :θ, :q))
    same = all(name -> logged_port(sims[a], "plant", name)[ia] == logged_port(sims[b], "plant", name)[ib], (:h, :V, :θ, :q, :γ))
    println("2. $a vs $b: common ", length(common), " bit-identical ", same, " largest gap ", worst)
end
# 6. V1 without Δt_base.
bare = Simulation(piloted(solution); Δt_frame = 1//400)
rows = Dict(r.path => r.Δt for r in bare.model.deployment.schedule.rows)
println("6. V1 without Δt_base: q_ctl ", 1 / rows["cascade/q_ctl"], " Hz, θ_ctl ", 1 / rows["cascade/θ_ctl"], " Hz, h_ctl ",
        1 / rows["cascade/h_ctl"], " Hz; warnings ", warnings(bare))
