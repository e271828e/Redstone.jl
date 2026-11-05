module P2
using Test
include(joinpath(pwd(), "test/repl.jl"))
include(joinpath(pwd(), "test/utils.jl"))
include(joinpath(pwd(), "design/reports/20261105_docstring_audit/probes/A6/common.jl"))
mutable struct LogHooks <: FrameHooks
    log::Vector{Any}
    model::Any
    ret::Any
end
frame_top!(h::LogHooks) = (push!(h.log, (:top, h.model.exec.clock.t)); nothing)
settled!(h::LogHooks) = (t = h.model.exec.clock.t; push!(h.log, (:settled, t)); h.ret(t))

struct TwoS <: AbstractComponent end
s_init(::TwoS) = (a = 0, b = 0)
y_types(::TwoS) = (a = Int, b = Int)
y_state(::TwoS, (; s)) = (a = s.a, b = s.b)
s_update(::TwoS, (; s)) = (a = s.a + 1, b = s.b + 1)

struct TwoM <: AbstractComponent end
x_init(::TwoM) = (q = 0.0, r = 5.0)
m_init(::TwoM) = (a = 0, b = 0)
y_types(::TwoM) = (q = Float64,)
y_state(::TwoM, (; x)) = (q = x.q,)
x_deriv(::TwoM, (; x)) = (q = 1.0, r = 0.0)

struct SinkOnly <: AbstractComponent end
s_init(::SinkOnly) = (n = 0,)
u_types(::SinkOnly) = (a = Float64,)
s_update(::SinkOnly, (; s)) = (n = s.n + 1,)

# bare u, field
struct UF; a::Float64; b::Float64; end
struct BareIn <: AbstractComponent end
x_init(::BareIn) = 0.0
u_types(::BareIn) = UF
y_types(::BareIn) = Float64
y_state(::BareIn, (; x)) = x
x_deriv(::BareIn, (; u)) = u.a

println("=== abandon at t*")
m = Model(single(Sawtooth(3.0)); h = 1//10)
h = LogHooks(Any[], m, t -> false)
init!(m; hooks = h); empty!(h.log)
h.ret = t -> true
function find!()
    h.ret = t -> abs(t*10 - round(t*10)) > 1e-6
    for k in 1:6
        r = frame!(m, k, h)
        println("frame ", k, " returned ", r, " log ", h.log, " clock ", m.exec.clock.t, " state ", state(m, "c"), " status ", m.status)
        empty!(h.log)
        if r
            tryit("checkpoint after abandon", () -> checkpoint(m))
            tryit("overlay after abandon", () -> overlay!(m, set()))
            println("x kept ", state(m,"c"))
            return
        end
    end
end
find!()

println("=== overlay semantics, discrete")
m = Model(single(TwoS()); h = 1//10); init!(m); frames!(m, 3)
println("before s=", state(m,"c"), " y=", port(m,"c",:a), port(m,"c",:b), " t=", m.exec.clock.t)
overlay!(m, at("c", set(s = (a = 100,))))
println("after partial overlay s=", state(m,"c"), " y=", port(m,"c",:a), port(m,"c",:b), " t=", m.exec.clock.t, " status ", m.status)
frame!(m, 4); println("next tick s=", state(m,"c"), " y=", port(m,"c",:a), port(m,"c",:b))

println("=== overlay mode partial, x partial")
m = Model(single(TwoM()); h = 1//10); init!(m); frames!(m, 2)
overlay!(m, at("c", set(m = (a = 7,)))); println("modes after overlay ", modes(m,"c"))
overlay!(m, at("c", set(m = (b = 9,)))); println("modes partial on current ", modes(m,"c"))
overlay!(m, at("c", set(x = (q = 7.0,)))); println("x partial on current ", state(m,"c"))
init!(m); println("init restores modes ", modes(m,"c"))

println("=== overlay root input, none required, projection, event")
m = Model(fed(Plant(), "u"); h = 1//10); init!(m, set(u = (in = 1.0,)))
tryit("no root input needed", () -> overlay!(m, set()))
overlay!(m, set(u = (in = 2.0,))); println("in cell ", port(m, "", :in), " power/y ", port(m,"c",:power), " input read ", gather_cell(m.exec.store, m.exec.act.layout.addr[("",:in)]))
m = Model(single(Rotor()); h = 1//10); init!(m); frames!(m,2)
overlay!(m, at("c", set(x = (r = SVector(3.0, 4.0),)))); println("projected ", state(m,"c"), " y=", port(m,"c",:c))
m = Model(single(Sawtooth(0.1)); h = 1//10); init!(m); frames!(m, 2)
pr = copy(m.exec.events.prior)
overlay!(m, at("c", set(x = (q = 1.5,)))); println("event fires at once ", state(m,"c"), " prior before ", pr, " after ", m.exec.events.prior)
overlay!(m, at("c", set(x = (q = 0.5,)))); println("no fire ", state(m,"c"))
m = Model(fed(Trigger(0.5), "sig"); h = 1//10); init!(m, set(u=(in=1.0,))); frames!(m,1)
println("Trigger after init ", modes(m,"c"), " prior ", m.exec.events.prior)
overlay!(m, set(u=(in=2.0,))); println("already holding does not refire ", modes(m,"c"))
m = Model(fed(Trigger(0.5), "sig"); h = 1//10); init!(m, set(u=(in=0.0,))); frames!(m,1)
overlay!(m, set(u=(in=2.0,))); println("moved into holding fires ", modes(m,"c"), " y=", port(m,"c",:on))
m = Model(single(Chatterer()); h = 1//10, firing_budget = 3); init!(m)
println("chatterer init flips ", modes(m,"c"))
take = m.frame_diag
overlay!(m, at("c", set(m = (v = false, flips = 0)))); println("overlay under budget ", modes(m,"c"), " status ", m.status)

println("=== overlay refusals")
b = Model(single(TwoS()); h = 1//10)
tryit("overlay built", () -> overlay!(b, set()))
m = Model(single(TwoS()); h = 1//10); init!(m)
tryit("overlay unresolved", () -> overlay!(m, at("c", set(s = (nope = 1,)))))
tryit("overlay unknown path", () -> overlay!(m, at("nope", set(s = (a = 1,)))))
tryit("overlay not a condition", () -> overlay!(m, (; s = 1)))
m = Model(fed(Mine(), "sig"); h = 1//10); init!(m, set(u=(in=false,))); frames!(m,2)
tryit("overlay throw", () -> overlay!(m, set(u = (in = true,))))
println("status ", m.status, " clock ", m.exec.clock.t)
println("cell written partly: in=", port(m, "", :in))

println("=== phase_bodies")
m = Model(Group((; a = Rotor(), b = Sawtooth(1.0), c = Plant(), d = TickCounter()); input_wires = ("in" => "c/u",)); h = 1//10)
init!(m, set(u=(in=0.0,)))
b = phase_bodies(m)
println(keys(b))
println("events ", typeof(b.events), " keys ", collect(keys(b.events)))
println("event value ", typeof(b.events[("b", :wrap)]))
println("projections ", typeof(b.projections), " keys ", collect(keys(b.projections)))
println("event value fields ", b.events[("b", :wrap)] isa NamedTuple ? keys(b.events[("b", :wrap)]) : "-")
tryit("guard call", () -> (v=b.events[("b", :wrap)]; v isa NamedTuple ? (v.guard(), v.handler()) : v()))
tryit("projection call", () -> b.projections["a"]())
tryit("ticks no-disc", () -> phase_bodies(Model(single(Sawtooth(1.0)); h=1//10)).ticks(1))
tryit("ticks no-disc zero", () -> phase_bodies(Model(single(Sawtooth(1.0)); h=1//10)).ticks())
mm = Model(single(Sawtooth(1.0)); h=1//10); init!(mm)
println("identity ", phase_bodies(mm) === mm.exec.bodies)
sim = Simulation(single(Sawtooth(1.0)); h = 1//10); println("sim's are its model's ", phase_bodies(sim) === sim.model.exec.bodies)

println("=== port")
g = Group((; a = Rotor(), inner = Group((; p = Plant(), neg = Negator()); input_wires = ("in"=>"p/u", "n"=>"neg/u")), t = BareTicker(), acc = BareAccumulator());
          input_wires = ("in" => "inner/in", "n" => "inner/n", "u" => "acc/u"), output_wires = ("a/c" => "out",))
m = Model(g; h = 1//10); init!(m, set(u = (in = 1.0, n = 2.0, u = 3.0)))
println("layout addr keys ", sort(collect(keys(m.exec.act.layout.addr))))
tryit("root exported via ''", () -> port(m, "", :out))
tryit("root input via ''", () -> port(m, "", :in))
tryit("name-less ''", () -> port(m, ""))
tryit("inner face", () -> port(m, "inner", :y))
tryit("inner face2", () -> port(m, "inner", :nope))
tryit("inner noname", () -> port(m, "inner"))
tryit("inner input face", () -> port(m, "inner", :in))
tryit("primitive named", () -> port(m, "inner/p", :power))
tryit("primitive bad name", () -> port(m, "inner/p", :nope))
tryit("primitive noname named contract", () -> port(m, "inner/p"))
tryit("named input", () -> port(m, "inner/p", :u))
tryit("unknown path", () -> port(m, "inner/zz", :y))
tryit("unknown path top", () -> port(m, "zz"))
m2 = Model(Group((; a = Rotor(), bare = BareTwo = Negator()); input_wires = ("x" => "bare/u",)); h = 1//10)
init!(m2, set(u = (x = 1.0,)))
tryit("bare by name", () -> port(m2, "bare", :y))
tryit("bare by path alone", () -> port(m2, "bare"))
println("--- no ports")
m3 = Model(Group((; s = SinkOnly(), c = Rotor()); input_wires = ("a" => "s/a",), output_wires = ()); h = 1//10)
init!(m3, set(u = (a = 1.0,)))
println("addr ", sort(collect(keys(m3.exec.act.layout.addr))))
tryit("no-port primitive with name", () -> port(m3, "s", :y))
tryit("no-port primitive", () -> port(m3, "s"))
println("--- primitive root")
m4 = Model(Negator(); h = 1//10); init!(m4, set(u = (u = 2.0,)))
println("addr ", sort(collect(keys(m4.exec.act.layout.addr))))
tryit("root primitive port ''", () -> port(m4, ""))
tryit("root primitive port '' y", () -> port(m4, "", :y))
tryit("root primitive port '' u", () -> port(m4, "", :u))

println("=== state and modes")
g2 = Group((; p = Plant(), acc = BareAccumulator(), t = BareTicker(), tc = TickCounter(), neg = Negator(), dm = DiscreteMap(), l = BareLatch(), ms = ModedSource(), inner = Group((; r = Rotor(),)));
    input_wires = ("in" => "p/u", "u" => "acc/u", "n" => "neg/u", "a" => "dm/a"))
m = Model(g2; h = 1//10); init!(m, set(u = (in = 1.0, u = 3.0, n = 2.0, a = 1)))
for path in ("p", "acc", "t", "tc", "neg", "dm", "l", "ms", "inner/r", "inner", "", "zz", "inner/zz")
    tryit("state $path", () -> state(m, path))
    tryit("modes $path", () -> modes(m, path))
end
println("=== warnings")
wb = build(single(Sawtooth(1.0))); println(warnings(wb))
end
