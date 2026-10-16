# The Windows SIGINT crash on Julia 1.13, reduced (see ../report.md, section 5).
# Usage: julia -t N sigint_probe.jl masked_throw | masked_safepoint_throw | unmasked_throw

struct Boom <: Exception end

pending() = unsafe_load(cglobal(:jl_signal_pending, Cint))
say(s) = ccall(:jl_safe_printf, Cvoid, (Cstring, Cstring...), "[probe %s] %s\n", ARGS[1], s)
send() = Sys.iswindows() ? ccall(:raise, Cint, (Cint,), 2) :
                           ccall(:kill, Cint, (Cint, Cint), getpid(), 2)

function spin_until_pending()
    t = time() + 10
    while pending() == 0 && time() < t
    end
end

# The signal arrives, then a throw with no safepoint between them.
@noinline function send_then_throw(safepoint)
    send()
    spin_until_pending()
    p = pending()
    safepoint && GC.safepoint()
    throw(Boom())
    p
end

function masked_throw(; safepoint)
    Base.sigatomic_begin()
    try
        send_then_throw(safepoint)
    catch err
        say("caught $(typeof(err)) inside the mask")
    end
    say("pending before the unmask: $(pending())")
    Base.sigatomic_end()
    say("sigatomic_end returned without throwing")
end

Base.exit_on_sigint(false)
case = ARGS[1]
say("start, nthreads = $(Threads.nthreads())")
try
    if case == "masked_throw"
        masked_throw(safepoint = false)
    elseif case == "masked_safepoint_throw"
        masked_throw(safepoint = true)
    elseif case == "unmasked_throw"
        try
            send_then_throw(false)
        catch err
            say("caught $(typeof(err))")
        end
    end
catch err
    say("caught $(typeof(err)) outside")
end
say("end")
