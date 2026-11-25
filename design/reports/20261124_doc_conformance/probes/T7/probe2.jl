using Redstone
import Redstone: Simulation, set, at, combine, init!, run!, state, lifecycle, taps, get_state, get_input, linearize, labeled, trim!, series, reads, get_output, port, Group
import RedstoneExamples: Longitudinal, aircraft, level_flight, longitudinal_taps
using ComponentArrays
println("== partial u")
s = Simulation(aircraft(); Δt_frame = 1//100)
try; init!(s, at("plant", set(x = (V = 55.0,)))); catch e; showerror(stdout, e); println(); end
println(lifecycle(s))
try; init!(s, set(u = (δe = 0.0,))); catch e; showerror(stdout, e); println(); end
init!(s, combine(at("plant", set(x = (V = 55.0, θ = 0.02))), set(u = (δe = 0.0, δt = 0.4))))
println("state after partial x: ", state(s, "plant"))
println("== plain linearize")
rep = trim!(s, level_flight(); baseline = set())
tp = longitudinal_taps()
lin = linearize(s, tp)
println(typeof(lin.A), " ", typeof(lin))
println(typeof(lin.A) <: Matrix)
ll = labeled(lin)
println(typeof(ll.A))
# labeled arithmetic
A1 = ComponentMatrix([1.0 2.0; 3.0 4.0], Axis(a=1,b=2), Axis(a=1,b=2))
A2 = ComponentMatrix([10.0 20.0; 30.0 40.0], Axis(b=1,a=2), Axis(b=1,a=2))
r = A1 + A2
println(r, " ", typeof(r))
println(A1 * A2)
println("== log: snapshots at steps")
s2 = Simulation(aircraft(); Δt_frame = 1, h_max = 1//10)
init!(s2, combine(at("plant", set(x = (V = 50.0,))), set(u = (δe = 0.025, δt = 0.37))))
run!(s2; t_end = 5.0)
sr = series(s2, reads(V = get_output("plant", :V)))
println(length(sr.t), " ", sr.t[1:4], " frame=", sr.frame[1:12], " boundary=", sr.boundary[1:4])
println("== deployment kwargs via Simulation")
try; Simulation(aircraft(); Δt_frame = 1//100, algorithm = Redstone.Heun(), h_max = 1//200); println("ok"); catch e; showerror(stdout,e); end
try; Simulation(aircraft()); catch e; showerror(stdout,e); println(); end
println("== trim fail log")
s3 = Simulation(aircraft(); Δt_frame = 1//100)
slow = trim!(s3, level_flight(V = 20.0); baseline = set())
println(slow.status, slow.saturated, " ", lifecycle(s3))
try; state(s3, "plant"); catch e; showerror(stdout,e); println(); end
println(isdefined(Redstone, :RK4), " ", isdefined(Redstone, :BS3), " ", isdefined(Redstone,:Deployment))
println("fields of Linearization: ", fieldnames(typeof(lin)))
