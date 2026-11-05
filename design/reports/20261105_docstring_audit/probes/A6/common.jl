function summ(e)
    if e isa DiagnosticError
        ds = e.carried isa Vector ? e.carried : [e.carried]
        return "DiagnosticError[" * join([string(nameof(typeof(d)), " ", join(["$f=$(repr(getfield(d,f)))" for f in fieldnames(typeof(d)) if f in (:reason,:argument,:call,:parameter,:op,:status,:what,:name,:frame,:t,:t_frame,:spelling,:candidates,:owner,:segment,:path,:label,:paths,:utilization,:fastest) && getfield(d,f) !== nothing])) for d in ds], "; ") * "]"
    elseif e isa StepError
        return "StepError{cause=$(typeof(e.cause))} host=$(e.host) boundary=$(e.boundary) t=$(e.t) cursor=$(e.cursor)"
    else
        s = try sprint(showerror, e) catch; "?" end
        return string(typeof(e), ": ", first(s, 260))
    end
end
function tryit(label, f)
    try
        r = f()
        println(label, " => ", repr(r))
    catch e
        println(label, " THROW ", summ(e))
    end
end
