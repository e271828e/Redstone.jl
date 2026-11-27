# r10: B1's claim that with the altitude noise alone the model reproduces increment 1's pins to three
# digits (increment 1: late 0.0775 m, 0.0187 m/s, peak 1050.061, excursion 3.90 m/s).
include(joinpath(@__DIR__, "r00_common.jl"))
solution = trim_solution()
s = climb(RE.autopilot(solution; noise_psd = (q = 0.0, θ = 0.0, h = 1.8e-3, V = 0.0)), solution)
t = logged_times(s); h = logged_port(s, "plant", :h); V = logged_port(s, "plant", :V); late = t .>= 75
@printf("altitude noise only: late h %.4f  late V %.4f  peak %.3f  excursion %.4f\n",
        maximum(abs, h[late] .- 1050), maximum(abs, V[late] .- 50), maximum(h), maximum(abs, V .- 50))
