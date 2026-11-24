module S12cV
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))

macro p(label, ex)
    line = __source__.line
    quote
        local v = try $(esc(ex)) catch e
            e isa DiagnosticError ? (:THREW, [(nameof(typeof(d)), hasproperty(d, :status) ? d.status : nothing) for d in (e.carried isa Vector ? e.carried : [e.carried])]) :
                (:THREW, typeof(e), hasproperty(e, :host) ? (e.host, e.boundary) : nothing)
        end
        println("P", $line, " ", $label, " => ", v)
    end
end

ramp_request(level, reason) =
    Group((; src = Ramp(0.0), trig = Trigger(level), stop = StopRequest(reason = reason));
          local_wires = ("src/out" => "trig/sig", "trig/on" => "stop/u"))
point = set(u = (ref = 0.0,))
mk() = Simulation(feedback_model(); Δt_frame = 1//10)

# placeholder, built refusals
s = mk()
@p "Run fields" fieldnames(Redstone.Run)
@p "Model fields" fieldnames(Redstone.Model)
@p "placeholder" (s.run.trace, s.run.feed, s.run.termination, (s.run.log.first, s.run.log.last, length(s.run.log.snaps)), lifecycle(s))
@p "overlay! from built" overlay!(s, set())
@p "checkpoint from built" checkpoint(s)

# recording per door
init!(s, point; trace = false)
@p "init trace=false" s.run.trace === nothing
cp0 = checkpoint(s)
restore!(s, cp0; trace = true)
@p "restore trace=true" s.run.trace !== nothing
@p "lifecycle after restore" lifecycle(s)

# step! counts, t_end inside last requested frame
s = mk(); init!(s, point)
@p "step frames=3 t_end=0.3" (step!(s; frames = 3, t_end = 0.3), lifecycle(s))
s = mk(); init!(s, point)
@p "step frames=3 t_end=0.2" (step!(s; frames = 3, t_end = 0.2), lifecycle(s))
s = mk(); init!(s, point)
@p "step frames=3 ordinary" (step!(s; frames = 3), lifecycle(s))
@p "stopped → step!" (step!(s; frames = 1, t_end = 0.3), lifecycle(s))
@p "stopped → step! again" step!(s)
@p "stopped → run!" run!(s)

# overlay! from stopped opens a run that advances
pre = (s.run.frame, s.run.boundary, latest(s).boundary)
overlay!(s, set())
@p "overlay counters (pre frame, next ord, last pub ord) / post" (pre, (s.run.frame, s.run.boundary, latest(s).boundary))
@p "lifecycle after overlay" lifecycle(s)
@p "step after overlay from stopped" (step!(s; frames = 2), lifecycle(s))

# restore re-publication ordinal
s = mk(); init!(s, point); step!(s; frames = 2)
cp = checkpoint(s); lastord = latest(s).boundary
step!(s; frames = 3)
restore!(s, cp)
@p "restore republish ordinal == checkpoint's last published" (lastord, latest(s).boundary, cp.boundary, s.run.boundary)
@p "checkpoint(model) type / t₀" (typeof(checkpoint(Model(feedback_model(); Δt_frame = 1//10)) ) )
m = Model(feedback_model(); Δt_frame = 1//10); init!(m, point; t0 = 1//2)
ms = checkpoint(m)
@p "ModelState fields" fieldnames(typeof(ms))
@p "ModelState t₀" ms.t₀

# step! with pace held never waits
s = mk(); init!(s, point); pace!(s, 1e-3)
@p "step! under pace 1e-3 elapsed (s)" (@elapsed step!(s; frames = 5))

# attach between steps; mode line in show
s = mk(); init!(s, point); step!(s)
@p "lifecycle between steps" lifecycle(s)
@p "show lines" split(sprint(show, MIME"text/plain"(), s), '\n')

# overlay mid-frame: stop request at a t* boundary
s = Simulation(ramp_request(0.35, "r"); Δt_frame = 1//10); init!(s)
@p "run! monitored" (run!(s), lifecycle(s), s.model.exec.clock.t)
@p "checkpoint mid-frame" checkpoint(s)
@p "overlay! mid-frame" overlay!(s, set())
end
