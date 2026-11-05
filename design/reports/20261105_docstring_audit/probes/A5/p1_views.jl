module P1
using Test
const W = pwd()
include(W * "/test/repl.jl")
include(W * "/test/utils.jl")
using InteractiveUtils

inner() = Group((; p = Plant()); input_wires = ("u" => "p/u",), output_wires = ("p/y" => "y",))
outer() = Group((; inner = inner(), g = Gain(2.0)); input_wires = ("u" => "inner/u",),
                local_wires = ("inner/y" => "g/e",),
                output_wires = ("inner/y" => "y", "g/out" => "gy"))
sim = Simulation(outer(); h = 1//10)
h = attach!(sim, Pad("a"), Enumerated("u"))
init!(sim, set(u = (u = 1.0,)))
views = port_views(h)
for k in sort!(collect(keys(views)))
    v = views[k]
    println(k, " source=", v.source, " live=", v.live, " slot=", v.slot, " inc=", repr(v.incumbent))
end
s = latest(sim)
println("root out view incumbent_status: ", incumbent_status(views[("", :y)], s) === nothing ? nothing : incumbent_status(views[("", :y)], s).who)
println("inner out view incumbent_status: ", incumbent_status(views[("inner", :y)], s))
println("peek root out = ", peek(views[("", :y)], h, s), " port = ", port(s, "", :y))

# same with no device claim on u
sim2 = Simulation(outer(); h = 1//10)
h2 = attach!(sim2, Pad("o"), NoClaim())
init!(sim2, set(u = (u = 1.0,)))
v2 = port_views(h2)
println("nodev: root in ", v2[("", :u)].incumbent, " | root out ", repr(v2[("", :y)].incumbent), " src ", v2[("", :y)].source,
        " | inner out ", repr(v2[("inner", :y)].incumbent), " src ", v2[("inner", :y)].source)

# a wire from a root input straight to a root output; does it build?
feed() = Group((; g = Gain(2.0)); input_wires = ("u" => "g/e",), output_wires = ("u" => "echo", "g/out" => "out"))
try
    sim3 = Simulation(feed(); h = 1//10)
    h3 = attach!(sim3, Pad("f"), Enumerated("u"))
    init!(sim3, set(u = (u = 3.0,)))
    v3 = port_views(h3)
    for k in sort!(collect(keys(v3)))
        v = v3[k]
        println("feed ", k, " source=", v.source, " live=", v.live, " slot=", v.slot, " inc=", repr(v.incumbent))
    end
    stage!(h3, "u" => 4.0)
    println("pending echo via peek=", peek(v3[("", :echo)], h3, latest(sim3)), " pending u via peek=", peek(v3[("", :u)], h3, latest(sim3)))
catch err
    println("feedthrough: ", sprint(showerror, err)[1:min(end,300)])
end
# inner feedthrough
inner_feed() = Group((; g = Gain(2.0)); input_wires = ("a" => "g/e",), output_wires = ("a" => "echo",))
outer_feed() = Group((; i = inner_feed(), g2 = Gain(1.0)); input_wires = ("u" => "i/a",), local_wires = ("i/echo" => "g2/e",))
try
    sim4 = Simulation(outer_feed(); h = 1//10)
    h4 = attach!(sim4, Pad("f"), Enumerated("u"))
    init!(sim4, set(u = (u = 3.0,)))
    v4 = port_views(h4)
    for k in sort!(collect(keys(v4)))
        v = v4[k]
        println("ifeed ", k, " source=", v.source, " live=", v.live, " slot=", v.slot, " inc=", repr(v.incumbent))
    end
catch err
    println("inner feedthrough: ", sprint(showerror, err)[1:min(end,300)])
end

# port addressing (Snapshot docstring)
s = latest(sim)
println("port(s,'',:u)=", port(s, "", :u), " port(s,'',:y)=", port(s, "", :y), " port(s,'inner',:y)=", port(s, "inner", :y))
println("port(s,'inner/p',:y)=", port(s, "inner/p", :y))
for args in (("",), ("inner",), ("inner/p",), ("g",), ("g", :out))
    r = try port(s, args...) catch e; sprint(showerror, e)[1:min(end,160)] end
    println("port(s, ", args, ") => ", r)
end
println("port(sim, g)=", try port(sim,"g") catch e; typeof(e) end)
end
