# p03: the noise densities under candidate A (Δt_base = 1//200, multipliers 1, 4, 20). One
# measurement's noise varied at a time, given as the deviation per sample at its sensor's rate,
# the altimeter at today's density and the other two off. Figures of chapters 5 and 6.
include("common.jl")
solution = trim_solution()
rates = (q = 200, θ = 50, h = 10, V = 10)
base = (q = 0.0, θ = 0.0, h = 1.8e-3, V = 0.0)
psd(name, σ) = σ^2 / rates[name]
for (name, σs) in ((:q, (0.0, 0.001, 0.002, 0.005)), (:θ, (0.0, 2e-4, 5e-4, 1e-3)), (:V, (0.0, 0.01, 0.02, 0.03, 0.05)))
    for σ in σs
        noise_psd = merge(base, NamedTuple{(name,)}((psd(name, σ),)))
        f5 = figures5(fly_autopilot(solution; Δt_base = 1//200, noise_psd))
        f6 = figures6(fly_piloted(solution; Δt_base = 1//200, noise_psd))
        @printf("%s σ=%-7g psd=%-9.3g late_h %.4f late_V %.4f peak %.3f | gaps δe %.4f δt %.4f hθm %.4f θqm %.4f jumps %.5f %.5f act %.2e jitter %.4f recap %.4f\n",
                name, σ, psd(name, σ), f5.late_h, f5.late_V, f5.peak, f6.gap_δe, f6.gap_δt, f6.gap_hθm, f6.gap_θqm,
                f6.jump_δe, f6.jump_δt, f6.jump_act, f6.jitter, f6.recapture)
    end
end
