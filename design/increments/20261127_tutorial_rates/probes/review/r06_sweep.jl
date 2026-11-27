# r06: chapter 6's windows over 40 alignments of the pilot's writes, 0 to 97.5 ms in frames of
# 2.5 ms, a whole period of the 10 Hz loops and the latch. For each pin: the spread, and at offset
# 0 the instant where the window's maximum sits.
include(joinpath(@__DIR__, "r00_common.jl"))
solution = trim_solution()
argwin(sig, sim, a, b) = (w = findall(window(sim, a, b)); logged_times(sim)[w[argmax(sig[w])]])
rows = []
for off in 0:39
    s = hand_sim(RE.piloted(solution), solution; offset = off)
    t = logged_times(s)
    se, st = logged_face(s, "selection", :δe), logged_face(s, "selection", :δt)
    ce, ct = logged_face(s, "cascade", :δe), logged_face(s, "cascade", :δt)
    hu, θu = logged_port(s, "cascade/h_ctl", :u), logged_port(s, "cascade/θ_ctl", :u)
    θm, qm = logged_face(s, "sensing", :θ_meas), logged_face(s, "sensing", :q_meas)
    sw = findfirst(identity, logged_face(s, "selection", :engaged))
    h = logged_port(s, "plant", :h)
    r = (off = off, ge = largest_gap(ce, se, s, 8, 30), gt = largest_gap(ct, st, s, 5, 30),
         gh = largest_gap(hu, θm, s, 8, 30), gθ = largest_gap(θu, qm, s, 8, 30),
         je = abs(se[sw] - se[sw - 1]), jt = abs(st[sw] - st[sw - 1]), tsw = t[sw],
         rc = maximum(abs, h[window(s, 80, 90)] .- 1000))
    push!(rows, r)
    if off == 0
        @printf("offset 0, where the maxima sit: δe gap %.4f, δt gap %.4f, h_ctl gap %.4f, θ_ctl gap %.4f, recapture %.4f\n",
                argwin(abs.(ce .- se), s, 8, 30), argwin(abs.(ct .- st), s, 5, 30), argwin(abs.(hu .- θm), s, 8, 30),
                argwin(abs.(θu .- qm), s, 8, 30), argwin(abs.(h .- 1000), s, 80, 90))
    end
end
for (k, tol) in ((:ge, 0.008), (:gt, 0.035), (:gh, 0.015), (:gθ, 0.03), (:je, 0.005), (:jt, 0.015), (:rc, 0.12))
    v = [r[k] for r in rows]
    @printf("%-3s offset0 %.5f  min %.5f  max %.5f  spread %.2e  tolerance %.3f  max/tol %.2f\n", k, v[1], minimum(v), maximum(v),
            maximum(v) - minimum(v), tol, maximum(v) / tol)
end
println("switch instants: ", unique([r.tsw for r in rows]))
for r in rows
    @printf("%2d %.5f %.5f %.5f %.5f %.6f %.6f %.4f\n", r.off, r.ge, r.gt, r.gh, r.gθ, r.je, r.jt, r.rc)
end
