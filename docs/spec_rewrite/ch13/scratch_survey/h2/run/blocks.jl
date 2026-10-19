# Runs half 2's code blocks and claims (§13.5–§13.8) against the package.
# From the repository root: julia --project=test -t 2 docs/spec_rewrite/ch13/scratch_survey/h2/run/blocks.jl
module H2Check
include(joinpath(@__DIR__, "..", "..", "..", "..", "..", "..", "test", "repl.jl"))
import Redstone.Blocks as B

ok(label, cond) = println(cond ? "PASS " : "FAIL ", label)
function caught(f)
    try f(); nothing catch e; e end
end
diags(e) = e isa DiagnosticError ? first(sprint(showerror, e), 300) : e

function section(f, name)
    println("\n== ", name)
    try f() catch e
        println("ERROR ", first(sprint(showerror, e), 400))
    end
end
struct StopRequestSketch <: AbstractComponent
    reason::String
end
StopRequestSketch(; reason = "") = StopRequestSketch(reason)
Redstone.x_init(::StopRequestSketch) = (;)
Redstone.u_types(::StopRequestSketch) = (request = Bool,)
Redstone.y_types(::StopRequestSketch) = (flag = StopFlag,)
Redstone.y_direct(::StopRequestSketch, (; u)) = (flag = u.request ? STOP_REQUESTED : NO_STOP,)
Redstone.stop_reason(c::StopRequestSketch) = c.reason
section("§13.5 StopRequest sketch (10523–10534) against Redstone.Blocks") do
r = B.StopRequest(reason = "x")
ok("Blocks.StopRequest declarations equal the sketch's",
   Redstone.u_types(r) == (request = Bool,) && Redstone.y_types(r) == (flag = StopFlag,) &&
   Redstone.x_init(r) == (;) && Redstone.stop_reason(r) == "x")
w = Group((; src = Sawtooth(1.0), mon = Overload(0.315), stop = StopRequestSketch(reason = "sketch"));
          local_wires = ("src/q" => "mon/sig", "mon/tripped" => "stop/request"))
bw = build(w)
println("  requesters: ", activation(bw, Float64).layout.requesters)
sim = Simulation(w; h = 1//10)
init!(sim)
run!(sim; t_end = 5.0)
rec = termination(sim)
println("  record: t = ", rec.t, ", source = ", rec.source)
ok("sketch ends the run as ModelRequestedStop(stop, flag, sketch) at the crossing t* (0.315)",
   rec.source == ModelRequestedStop("stop", :flag, "sketch") && isapprox(rec.t, 0.315; atol = 1e-5))

end
mk() = (s = Simulation(overloaded(); h = 1//50); init!(s); s)
section("§13.5 policy example (10555–10563), on overloaded()") do
e = caught(() -> Simulation(overloaded(); h = 0.02))
println("  the block's own Simulation(world; h = 0.02): ", e === nothing ? "accepted" : diags(e))
s1 = mk(); run!(s1; t_end = 60)
ok("every request honoured: stops at t* ≈ 0.315", termination(s1).source isa ModelRequestedStop)
s2 = mk(); run!(s2; t_end = 0.5, ignore_stop_requests = ("stop",))
ok("one requester ignored by path: EndTimeReached; policy.ignored == [\"stop\"]",
   termination(s2).source isa EndTimeReached && termination(s2).policy.ignored == ["stop"])
s3 = mk(); n = step!(s3; frames = 100)
println("  step!(frames = 100) advanced ", n, " frames; lifecycle ", lifecycle(s3),
        "; policy ", termination(s3) === nothing ? nothing : termination(s3).policy)
ok("step! states Inf and () itself", termination(s3).policy.t_end == Inf && isempty(termination(s3).policy.ignored))
s4 = mk()
t = Threads.@spawn run!(s4; pace = 1.0, ignore_stop_requests = :all)
sleep(1.0); stop!(s4); wait(t)
ws = [d for d in termination(s4).residue]
println("  unbounded: source ", termination(s4).source, "; first status ", logged(s4)[1].status)
ok("unbounded run: ControlRequestedStop(:code)", termination(s4).source == ControlRequestedStop(:code))

end
section("§13.5 ignore list validation (10489–10493)") do
s5 = mk()
e = caught(() -> run!(s5; t_end = 1, ignore_stop_requests = ("nope", "nada")))
ok("two bad paths: StopRequestInvalid ×2, collected", e isa DiagnosticError &&
   length(diagnostics(e)) == 2 && all(d -> d isa StopRequestInvalid, diagnostics(e)))
s6 = mk(); run!(s6; t_end = 0.1, ignore_stop_requests = ("stop", "stop"))
ok("duplicates collapse", termination(s6).policy.ignored == ["stop"])
s7 = mk(); e = caught(() -> run!(s7; t_end = -1, ignore_stop_requests = ("nope",)))
println("  bad t_end and bad path: ", diags(e))

end
section("§13.5 the entry check (10512–10517): boundary zero, and a run after step!") do
st = Simulation(tick_alarmed(); h = 1//10)
init!(st)
step!(st; frames = 12, ignore_stop_requests = :all)
t_before = latest(st).t
run!(st; t_end = 5.0)
rec = termination(st)
println("  after step!(12, ignore :all) at t = ", t_before, ": run! ended at t = ", rec.t,
        ", source ", rec.source)
ok("a run starting mid-trajectory ends at its entry, not at t₀", rec.t == t_before && rec.t > 0)
so = Simulation(overloaded(); h = 1//10)
init!(so, at("mon", set(m = (tripped = true,))))
run!(so; t_end = 5.0)
ok("an authored condition already terminal ends the run at t₀, integrating nothing",
   termination(so).t == 0.0 && termination(so).source isa ModelRequestedStop)
sx = Simulation(tick_alarmed(); h = 1//10); init!(sx)
step!(sx; frames = 12, ignore_stop_requests = :all)
n = step!(sx; frames = 3)
println("  step! entry check after a holding request: advanced ", n, ", lifecycle ", lifecycle(sx))

end
struct Nested <: AbstractComponent end
struct FlagIn <: AbstractComponent end
Redstone.x_init(::Nested) = (;)
Redstone.y_types(::Nested) = (out = SVector{2, StopFlag},)
Redstone.y_state(::Nested, _) = (out = SVector(NO_STOP, NO_STOP),)
Redstone.x_init(::FlagIn) = (;)
Redstone.u_types(::FlagIn) = (f = StopFlag,)
Redstone.y_types(::FlagIn) = (y = Bool,)
Redstone.y_direct(::FlagIn, (; u)) = (y = u.f === STOP_REQUESTED,)
section("§13.5 placement (10469–10476)") do
e = caught(() -> build(Nested()))
println("  nested: ", diags(e))
e = caught(() -> build(FlagIn()))
println("  StopFlag root input: ", diags(e))
e = caught(() -> build(Group((; r = B.StopRequest(), c = FlagIn()); local_wires = ("r/flag" => "c/f",),
                             input_wires = "req" => "r/request")))
ok("a StopFlag input port fed by a request is left alone", !(e isa Exception))

end
section("§13.5 termination record (10576–10603): LoopError, errored, promotion (§13.6)") do
se = Simulation(Exploder(); h = 1//10)
init!(se, set(u = (arm = false,)))
step!(se; frames = 2)
stage!(se, "arm" => true)
e = caught(() -> step!(se; frames = 3))
rec = termination(se)
println("  throw: ", typeof(e), "; lifecycle ", lifecycle(se), "; record t = ", rec.t,
        ", source ", typeof(rec.source), " cause ", typeof(rec.source.exception))
ok("errored, record LoopError, final snapshot the last completed boundary (t = 0.2)",
   lifecycle(se) === :errored && rec.source isa LoopError && isapprox(rec.t, 0.2) &&
   isapprox(latest(se).t, 0.2))
println("  policy on the errored record: ", rec.policy)
for (label, f) in (("init!", () -> init!(se, set(u = (arm = false,)))),
                   ("attach!", () -> attach!(se, nothing)),
                   ("checkpoint", () -> checkpoint(se)),
                   ("run!", () -> run!(se)))
    e = caught(f); println("  ", label, " on errored: ", e === nothing ? "accepted" : diags(e))
end
println("  state read on errored: ", caught(() -> state(se, "")) === nothing ? "allowed" : "refused")

end
struct JunctionSketch{In, Out, N, F} <: AbstractComponent
    f::F
end
JunctionSketch{In, Out, N}(f::F) where {In, Out, N, F} = JunctionSketch{In, Out, N, F}(f)
Redstone.x_init(::JunctionSketch) = (;)
Redstone.u_types(::JunctionSketch{In, Out, N}) where {In, Out, N} =
    NamedTuple{ntuple(i -> Symbol(:in, i), N)}(ntuple(_ -> In, N))
Redstone.y_types(::JunctionSketch{In, Out}) where {In, Out} = (out = Out,)
Redstone.y_direct(j::JunctionSketch, (; u)) = (out = j.f(u...),)
section("§13.7 Junction sketch (10821–10832) against Redstone.Blocks") do
js = JunctionSketch{Bool, Bool, 3}(|)
ok("sketch u_types == Blocks.Or{3}'s", Redstone.u_types(js) == Redstone.u_types(B.Or{3}()))
ok("SumJunction{V,N} is Junction{V,V,N,typeof(+)}", B.SumJunction{Float64, 3} === B.Junction{Float64, Float64, 3, typeof(+)})
g = Group((; j = js); input_wires = ("a" => "j/in1", "b" => "j/in2", "c" => "j/in3"), output_wires = "j/out" => "o")
sg = Simulation(g; h = 1//10); init!(sg, set(u = (a = false, b = true, c = false)))
ok("the sketch builds and folds with |", port(sg, "j", :out) == true)
ok("custom fold infers F: Junction{Float64,Float64,2}(max)", B.Junction{Float64, Float64, 2}(max) isa B.Junction{Float64, Float64, 2, typeof(max)})

end
section("§13.7 UnitDelay, Constant, Freeze sketches (10874–10934)") do
d = B.UnitDelay(1.5)
ok("UnitDelay: s_init (v = v0), in/out", Redstone.s_init(d) == (v = 1.5,) &&
   Redstone.u_types(d) == (in = Float64,) && Redstone.y_types(d) == (out = Float64,))
c = B.Constant(2.0)
ok("Constant{Float64} declares Pinned{Float64}", Redstone.y_types(c) == (out = Pinned{Float64},))
ok("Freeze{struct} refused at the type", caught(() -> B.Freeze{Plant}) isa TypeError)
fz = B.Freeze{Float64}()
ok("Freeze: tolerant in, pinned out", Redstone.u_types(fz) == (in = Float64,) && Redstone.y_types(fz) == (out = Pinned{Float64},))
xd = ForwardDiff.Dual(1.0, 2.0)
ok("Freeze strips a Dual leafwise", Redstone.y_direct(fz, (; u = (in = SVector(xd, xd),))).out == SVector(1.0, 1.0))

end
section("§13.7 the rig sketch (10977–10986), as test/fixtures.jl's TerrainRig") do
e = caught(() -> build(TerrainGain()))
println("  TerrainGain alone: ", e === nothing ? "built" : diags(e))
br = build(TerrainRig())
println("  rig root inputs: ", [ri for ri in br.structure.root_inputs])
ok("rig builds", br isa Build)

end
section("§13.7 show(::Structure) routes, show(::Build) feedthrough line") do
io = IOBuffer(); show(io, MIME"text/plain"(), build(overloaded()).structure); txt = String(take!(io))
println(txt)
nest = Group((; inner = Group((; mon = Overload(0.3)); input_wires = "sig" => "mon/sig",
                                output_wires = "mon/tripped" => "crashed"));
             input_wires = "sig" => "inner/sig", output_wires = "inner/crashed" => "crashed")
io = IOBuffer(); show(io, MIME"text/plain"(), build(nest).structure); txt = String(take!(io))
println(txt)
io = IOBuffer(); show(io, MIME"text/plain"(), build(nest)); txt = String(take!(io))
println(txt)

end
struct Two <: AbstractComponent end
Redstone.x_init(::Two) = (;)
Redstone.u_types(::Two) = (a = Float64, b = Float64)
Redstone.y_types(::Two) = (y = Float64,)
Redstone.y_direct(::Two, (; u)) = (y = u.a + u.b,)
struct SelRig <: AbstractComponent
    t::Two
end
Redstone.x_init(::Two) = (;)
Redstone.u_types(::Two) = (a = Float64, b = Float64)
Redstone.y_types(::Two) = (y = Float64,)
Redstone.y_direct(::Two, (; u)) = (y = u.a + u.b,)
Redstone.local_wires(::SelRig) = ()
Redstone.input_wires(r::SelRig) = (input_passthrough(r, "t"; select = n -> n == "a")..., "b" => "t/b")
section("§13.7 select on input_passthrough") do
ok("select keeps the accepted face", build(SelRig(Two())) isa Build)

end
section("§13.8 AlgebraicCycle messages") do
for (label, grp) in (("artificial", Group((d = DerivativeFed(), g = Gain(1.0));
                         local_wires = ("d/y" => "g/e", "g/out" => "d/b"), input_wires = "a" => "d/a")),
                     ("real", Group((d = DerivativeFed(), g = Gain(1.0));
                         local_wires = ("d/y" => "g/e", "g/out" => "d/a"), input_wires = "b" => "d/b")),
                     ("sampled", Group((p = Piecewise(), g = Gain(1.0));
                         local_wires = ("p/F" => "g/e", "g/out" => "p/g"), input_wires = ("v" => "p/v", "f" => "p/f"))))
    e = caught(() -> build(grp))
    dd = only(diags(e))
    println("  ", label, ": ", dd.classification, " dead ", dd.dead, " traced ", dd.traced)
    println("    ", Redstone.message(dd))
end
end
end
