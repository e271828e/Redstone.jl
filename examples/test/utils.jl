# --- helpers shared across the examples' test files --------------------------------

# A port's or a level's exported face's value over the logged snapshots, beside their times.
logged_times(sim) = series(sim, reads()).t
logged_port(sim, path, name) = series(sim, reads(y = get_output(path, name))).columns.y
logged_face(sim, path, name) = series(sim, at(path, reads(y = get_face(name)))).columns.y

# The times at which `values` crosses `level`, at the snapshot after each crossing.
crossings(times, values, level) =
    [times[i] for i in 2:length(times) if (values[i - 1] - level) * (values[i] - level) < 0]

# The snapshots of `sim` in `[t_from, t_to)`, as a mask.
window(sim, t_from, t_to) = (times = logged_times(sim); (times .>= t_from) .& (times .< t_to))

# The largest frame-to-frame change of a logged signal over the snapshots in `[t_from, t_to)`.
largest_jump(signal, sim, t_from, t_to) = maximum(abs, diff(signal[window(sim, t_from, t_to)]))

# The largest gap between the logged signals `follower` and `leader` over the snapshots in
# `[t_from, t_to)`.
largest_gap(follower, leader, sim, t_from, t_to) =
    maximum(abs, (follower .- leader)[window(sim, t_from, t_to)])
