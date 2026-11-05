using Test
include(joinpath(pwd(), "test/repl.jl"))
include(joinpath(pwd(), "test/utils.jl"))
# prints what a call returns or the refusal it raises
_kinds(err) = err.carried isa Vector ? collect(err.carried) : [err.carried]
function tryit(label, f)
    try
        r = f()
        txt = repr(r; context = :limit => true)
        println(label, " => OK: ", first(txt, 200))
        r
    catch err
        if err isa DiagnosticError
            ds = _kinds(err)
            println(label, " => REFUSED ", [nameof(typeof(d)) for d in ds], " ",
                    [hasproperty(d, :reason) ? d.reason : nothing for d in ds])
        else
            println(label, " => THROW ", typeof(err), " ", first(sprint(showerror, err), 200))
        end
        err
    end
end
ramp_request(level, reason) =
    Group((; src = Ramp(0.0), trig = Trigger(level), stop = StopRequest(reason = reason));
          local_wires = ("src/out" => "trig/sig", "trig/on" => "stop/u"))
monitored() = ramp_request(0.35, "ramp at level")
two_ramps(level_a, level_b) =
    Group((; a = ramp_request(level_a, "a at level"), b = ramp_request(level_b, "b at level")))
two_ramps_swapped(level_a, level_b) =
    Group((; b = ramp_request(level_b, "b at level"), a = ramp_request(level_a, "a at level")))
