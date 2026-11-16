# Orders: (a) global error at fixed steps (frame = h, tolerance huge); (b) one step from
# pericenter: true local error and each estimate, against h.
include(joinpath(@__DIR__, "kepler.jl"))
using Printf
hs = (1 // 16, 1 // 32, 1 // 64, 1 // 128, 1 // 256)
for lab in ("A", "B_mid", "C")
    errs = map(hs) do h
        alg = lab == "A" ? CountedBS3(BS3(reltol = 1e6, abstol = 1e3)) :
              lab == "B_mid" ? Probe(:emb, 2 / 9, 1e6, 1e3) : Probe(:alsh, 0.0, 1e6, 1e3)
        r = kepler_run(alg; Δt_frame = h, t_end = 4.0)
        @assert r.rej == 0 && r.acc == Int(4 / h)
        r.err_end
    end
    println(rpad(lab, 6), " fixed-step err(t=4): ", join((@sprintf("%.3e", e) for e in errs), " "),
            "  ratios: ", join((@sprintf("%.2f", errs[i] / errs[i+1]) for i in 1:length(errs)-1), " "))
end
# (b) single step from pericenter
x0 = kepler_exact(ECC, 0.0)
for lab in ("A'", "B_mid", "C")
    ests, trues = Float64[], Float64[]
    for h in hs
        alg = lab == "A'" ? Probe(:bs3, 0.0, 1e6, 1e3) : lab == "B_mid" ? Probe(:emb, 2 / 9, 1e6, 1e3) :
              Probe(:alsh, 0.0, 1e6, 1e3)
        sim = Simulation(kepler_model(); Δt_frame = h, h_min = 1 // 2^40, algorithm = alg)
        init!(sim)
        st = sim.model.exec.stepper; st.tracing = true
        step!(sim; frames = 1)
        (t, hv, xa, xb, est, _) = st.trace[1]
        push!(ests, maximum(abs, est)); push!(trues, maximum(abs, xb .- rk4_ref(xa, hv)))
    end
    sl(v) = join((@sprintf("%.2f", log2(v[i] / v[i+1])) for i in 1:length(v)-1), " ")
    println(rpad(lab, 6), " local err: ", join((@sprintf("%.2e", e) for e in trues), " "), " slopes ", sl(trues))
    println(rpad(lab, 6), " estimate:  ", join((@sprintf("%.2e", e) for e in ests), " "), " slopes ", sl(ests))
end
