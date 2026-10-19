# One cold process over the examples' aircraft: user types on top of the image.
Base.cumulative_compile_timing(true)
ct() = Base.cumulative_compile_time_ns()[1] / 1e9
t_using = @elapsed using Redstone, RedstoneExamples
import Redstone: Simulation, build, init!, run!, trim!, set, series, reads, get_output, linearize
import RedstoneExamples: aircraft, level_flight, longitudinal_taps, lqr_gains, closed_loop, trimmed
using Printf
c0 = ct()
t_sim = @elapsed sim = Simulation(aircraft(); h = 1//100)
t_trim = @elapsed report = trim!(sim, level_flight(); baseline = set(u = (δe = 0.0, δt = 0.5)))
solution = report.solution
t_lin = @elapsed linearization = linearize(sim, longitudinal_taps())
gains = lqr_gains(linearization)
t_cl = @elapsed cl = Simulation(closed_loop(solution, gains); h = 1//200)
t_init = @elapsed init!(cl, trimmed(solution))
t_run = @elapsed run!(cl; t_end = 1.0)
t_series = @elapsed series(cl, reads(h = get_output("plant", :h)))
@printf("EXAMPLES using=%.2f aircraft_sim=%.2f trim=%.2f linearize=%.2f closed_loop_sim=%.2f init=%.2f run=%.2f series=%.2f | total=%.2f compile=%.2f\n",
    t_using, t_sim, t_trim, t_lin, t_cl, t_init, t_run, t_series,
    t_sim + t_trim + t_lin + t_cl + t_init + t_run + t_series, ct() - c0)
