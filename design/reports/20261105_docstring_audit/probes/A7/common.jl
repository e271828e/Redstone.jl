using Test, BenchmarkTools
include(joinpath(pwd(), "test/repl.jl"))
include(joinpath(pwd(), "test/utils.jl"))
include(joinpath(pwd(), "test/test_readers.jl"))
include(joinpath(pwd(), "test/test_trim.jl"))
include(joinpath(pwd(), "test/test_linearize.jl"))
function dshow(ds)
    for d in ds
        extras = String[]
        for f in (:reason, :tap, :list, :label, :status, :op, :call, :argument, :field, :frame, :faces, :duplicate_of)
            hasproperty(d, f) && getproperty(d, f) !== nothing && push!(extras, "$f=$(getproperty(d,f))")
        end
        println("     ", nameof(typeof(d)), " ", join(extras, " "))
    end
end
function tryit(label, f)
    try
        r = f()
        println(label, " => OK ", first(string(typeof(r)), 60))
        r
    catch e
        if e isa DiagnosticError
            println(label, " => throw ", first(string(typeof(e)), 80))
            dshow(e isa DiagnosticError{Vector{Diagnostic}} ? diagnostics(e) : [diagnostic(e)])
        else
            println(label, " => RAW ", typeof(e), ": ", first(sprint(showerror, e), 200))
        end
        nothing
    end
end
