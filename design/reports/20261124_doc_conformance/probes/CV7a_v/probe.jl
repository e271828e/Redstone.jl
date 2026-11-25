module P
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test/imports.jl"))
include(joinpath(W, "test/fixtures.jl"))
import Redstone: _record!, Batch, _compile_feed, DiagnosticError

plain(x) = sprint(show, MIME("text/plain"), x)
compact(x) = sprint(show, x)
hr(s) = println("\n==== ", s, " ====")

# CV7a-002: a primitive at the root prints `root` in the Outputs and Events tables
hr("002 Outputs/Events of a root primitive")
pb = build(Pendulum())
println(plain(pb.outputs)); println(plain(pb.events))

# CV7a-005: Structure blocks and the A₀ row
hr("005 Structure")
mr = build(MultiRate())
println(plain(mr.structure))

# CV7a-016/024/025: Deployment heading and steps line
hr("016/024/025 Deployment fixed-step and proposing")
d_fixed = Deployment(mr; Δt_frame = 1//500)
println(join(split(plain(d_fixed), '\n')[1:3], '\n'))
println("compact: ", compact(d_fixed))
d_bs3 = Deployment(build(feedback_model()); Δt_frame = 1//100, h_max = 1//400, h_min = 1//10^5, algorithm = BS3())
println(join(split(plain(d_bs3), '\n')[1:2], '\n'))
println("compact: ", compact(d_bs3))
# h_min bigger than frame/steps: M = max(N, floor)
d_bs3b = Deployment(build(feedback_model()); Δt_frame = 1//100, h_max = 1//400, h_min = 1//1000, algorithm = BS3())
println(split(plain(d_bs3b), '\n')[2])
d_rk4h = Deployment(build(feedback_model()); Δt_frame = 1//100, h_max = 1//400, h_min = 1//10^5)
println("fixed with h_min: ", join(split(plain(d_rk4h), '\n')[1:2], " | "))

# CV7a-018: Deployment's exact Δt, τ against the Schedule's float
hr("018 exact vs float")
nested = build(Group((; g = Group((; a = TickCounter(), b = TickCounter());
                                  sample_times = (; a = Relative(3, 1), b = Relative(2))));
                     sample_times = (; g = Absolute(1//50, 1//100))))
dn = Deployment(nested; Δt_frame = 1//100, Δt_base = 1//200)
println(plain(dn))
println(plain(dn.schedule))

# CV7a-033: TrimReport
hr("033 TrimReport")
rep = TrimReport(true, (θ = 0.3, δ = -0.25), (a = 0.0, b = -2.5e-10), (a = 1e-9, b = 1e-9),
                 (a = 1.0e-12, b = -2.5e-10), (level = 0.019930198715528237, big = 123456.789), :converged, 5, 4,
                 [(:δ, :lower)], [("c", :touchdown)])
println(plain(rep)); println(compact(rep))

# CV7a-037: the frame a recorded batch carries against run.frame
hr("037 frame stamp")
three() = Group((; s = Sum(sa = 1.0, sb = 1.0), g = Gain(2.0));
                input_wires = ("a" => "s/a", "b" => "s/b", "c" => "g/e"))
sim = Simulation(three(); Δt_frame = 1//10)
init!(sim, set(u = (a = 0.0, b = 0.0, c = 0.0)))
println("before: run.frame = ", sim.run.frame, ", trace.frames = ", sim.run.trace.frames)
stage!(sim, "b" => 1.0)
step!(sim)
println("after one step: run.frame = ", sim.run.frame, ", batch.frame = ", only(trace(sim).batches).frame,
        ", trace.frames = ", trace(sim).frames)

# CV7a-046: allocations of the drain-side conversion
hr("046 allocations of _record!")
trc = Trace(nothing, Pair{String,Vector{Symbol}}[], TraceBatch[], 0)
b1 = Batch((1.0, 2.0, 3.0), (false, true, false))
b2 = Batch((1.0, 2.0, 3.0), (true, true, true))
sizehint!(trc.batches, 10_000)
_record!(trc, 1, b1); _record!(trc, 1, b2)
f(trc, b) = @allocations _record!(trc, 1, b)
f(trc, b1); f(trc, b2)
println("1 touched: ", f(trc, b1), " allocations, ", (@allocated _record!(trc, 1, b1)), " bytes")
println("3 touched: ", f(trc, b2), " allocations, ", (@allocated _record!(trc, 1, b2)), " bytes")
println("isbitstype(TraceBatch) = ", isbitstype(TraceBatch), ", inline in array: ", Base.allocatedinline(TraceBatch))

# CV7a-048/052: replay entry pass
hr("048/052 replay")
sim2 = Simulation(three(); Δt_frame = 1//10)
init!(sim2, set(u = (a = 0.0, b = 0.0, c = 0.0)))
stage!(sim2, "b" => 1.0); step!(sim2); stage!(sim2, "a" => 2.0); step!(sim2)
rec = trace(sim2)
target() = (s = Simulation(three(); Δt_frame = 1//10); init!(s, set(u = (a = 0.0, b = 0.0, c = 0.0))); s)
bad = Trace(rec.header, copy(rec.schemas), [TraceBatch(1, 9, Pair{Int,Any}[1 => 1.0, 3 => 2.0])], 2)
err = try _compile_feed(target(), bad); nothing catch e; e end
for d in diagnostics(err); println(typeof(d), " face=", repr(d.face), " frame=", d.frame, " writer=", repr(d.writer)); println("  ", message(d)); end
# a schema naming an unknown face fails at the schema stage, not at _replay_writer
bent = Trace(rec.header, [first(rec.schemas[1]) => [:a, :zzz, :c]], copy(rec.batches), 2)
err = try _compile_feed(target(), bent); nothing catch e; e end
println([typeof(d) for d in diagnostics(err)])
end
