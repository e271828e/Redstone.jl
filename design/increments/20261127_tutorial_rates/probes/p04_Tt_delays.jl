# p04: seams 2 and 3 under candidate A with the source's four densities. `Tt` swept, and the two
# command delays at the base tick (no entry) against following their readers' sensors
# (`command_δe = Relative(imu)`, `command_δt = Relative(air_data)`). Chapter 5's limited time
# with the attitude loop cut to ±0.05 rad/s, chapter 6's gaps, latch and jumps.
include("common.jl")
include("knobs.jl")
solution = trim_solution()
for delays in (:base, :sensor), Tt in (0.0, 0.005, 0.01, 0.02, 0.05, 0.1)
    knobs!(; Tt, delays, θ_lim = 0.05)
    held = limited_time(fly_autopilot(solution; Δt_base = 1//200), 0.05)
    knobs!(; Tt, delays)
    f5 = figures5(fly_autopilot(solution; Δt_base = 1//200))
    f6 = figures6(fly_piloted(solution; Δt_base = 1//200))
    @printf("delays %-6s Tt=%-5g limited %.2f s late_h %.4f | gaps δe %.4f δt %.4f hθm %.4f θqm %.4f latch %.2f jumps %.5f %.5f act %.2e jitter %.4f recap %.4f\n",
            delays, Tt, held, f5.late_h, f6.gap_δe, f6.gap_δt, f6.gap_hθm, f6.gap_θqm, f6.t_latch,
            f6.jump_δe, f6.jump_δt, f6.jump_act, f6.jitter, f6.recapture)
end
