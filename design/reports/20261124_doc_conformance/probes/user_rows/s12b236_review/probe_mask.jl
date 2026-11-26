# The mask count across the shape `try body finally begin; work; sigatomic_end end`.
cnt() = (n = 0; try; while true; Base.sigatomic_end(); n += 1; end; catch; end; for _ in 1:n; Base.sigatomic_begin(); end; n)
function shape(throw_body, throw_present)
    try
        throw_body && error("body")
    finally
        Base.sigatomic_begin()
        throw_present && throw(InterruptException())
        Base.sigatomic_end()
    end
end
for tb in (false, true), tp in (false, true)
    r = try; shape(tb, tp); :ok; catch err; typeof(err); end
    println("body throws=$tb present throws=$tp => $r, count after catch = ", cnt())
end
# Count inside the caller before any catch: a finally of the caller sees it.
function outer()
    try
        shape(false, true)
    finally
        println("caller's finally sees count ", cnt())
    end
end
try; outer(); catch; end
println("after outer catch ", cnt())
