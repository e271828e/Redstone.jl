module H2Blocks
include(joinpath(@__DIR__, "..", "..", "..", "..", "..", "..", "test", "repl.jl"))
using Test
res(name, f) = try
    r = f(); println("PASS  ", name, "  => ", repr(r)[1:min(end,200)])
catch e
    println("FAIL  ", name, "  => ", sprint(showerror, e)[1:min(end,400)])
end

# Block 7756-7761: the four contract functions exist with AbstractDevice fallbacks
res("7756 contract names", () -> (Redstone.init!, Redstone.loop, Redstone.shutdown!, Redstone.unblock!))
struct D0 <: AbstractDevice end
res("7760 unblock! default no-op", () -> Redstone.unblock!(D0()))
res("7757 init! default", () -> Redstone.init!(D0()))
res("7759 shutdown! default", () -> Redstone.shutdown!(D0()))

# Block 7879-7892: the definable lines (struct + three traits), plus a claims method
struct T16000MBinding <: AbstractBinding
    table::NamedTuple
end
Redstone.is_input(::T16000MBinding) = true
Redstone.is_output(::T16000MBinding) = false
Redstone.is_greedy(::T16000MBinding) = false
res("7879 T16000MBinding without claims: check_binding", () -> Redstone.check_binding(T16000MBinding((;))))
res("7879 T16000MBinding claims fallback fires", () -> claims(T16000MBinding((;))))
Redstone.claims(b::T16000MBinding) = ("a",)
res("7879 with claims: check_binding", () -> Redstone.check_binding(T16000MBinding((;))))
# converse direction: reads defined under false is_output
Redstone.reads(::T16000MBinding) = (; x = get_input("a"))
res("7936 reads under false trait", () -> Redstone.check_binding(T16000MBinding((;))))

# Block 8046-8050: TableBinding as written
res("8046 TableBinding as written", () -> TableBinding(stick_y  = (face = "elevator", deadzone = 0.05, expo = 0.6),
             throttle = (face = "throttle",),
             trigger  = (face = "brake_count",)))
tb = TableBinding(stick_y  = (face = "elevator", deadzone = 0.05, expo = 0.6),
             throttle = (face = "throttle",),
             trigger  = (face = "brake_count",))
res("8046 claims", () -> claims(tb))
res("8046 map_input sparse", () -> map_input((; stick_y = 0.5, trigger = 3), tb))

# Block 7823-7850: the stage! call shape the loop sketches use
two_root_inputs() = Group((; s = Sum(sa = 1.0, sb = 1.0));
                    input_wires = ("a" => "s/a", "b" => "s/b"))
sim = Simulation(two_root_inputs(); h = 1//10)
pad = Pad("p")
h = attach!(sim, pad, TableBinding(x = (face = "a",), y = (face = "b",)))
res("7827 stage!(handle, map_input(...)) unsplatted", () -> stage!(h, map_input((; x = 0.3), binding(h))))
res("7827 stage!(handle, map_input(...)...) splatted", () -> stage!(h, map_input((; x = 0.3), binding(h))...))
res("7831 report! MalformedDatum", () -> report!(h, MalformedDatum(ErrorException("bad"))))
# detached handle refuses write primitives (7722)
detach!(sim, pad)
res("7722 stage! after detach", () -> stage!(h, "a" => 0.1))
res("7722 report! after detach", () -> report!(h, MalformedDatum(ErrorException("x"))))
res("7722 latest after detach", () -> latest(h) === nothing)
end
