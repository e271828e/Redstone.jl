# S8d verifier probes, run from the pinned worktree with --project=test.
using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
include(joinpath(pwd(), "test", "imports.jl"))
include(joinpath(pwd(), "test", "fixtures.jl"))
include(joinpath(pwd(), "test", "utils.jl"))

function tryshow(tag, f)
    try
        r = f()
        println(tag, " => OK ", r isa Build ? "Build" : repr(r))
    catch err
        if err isa DiagnosticError
            ds = err.carried isa Vector ? err.carried : [err.carried]; println(tag, " => DiagnosticError ", [(typeof(d), d) for d in ds]); println("   msg: ", sprint(showerror, err)[1:min(end, 400)])
        else
            println(tag, " => ", typeof(err), ": ", sprint(showerror, err)[1:min(end, 300)])
        end
    end
end

# P1 (S8d-001): leading slash in a wire and in a snapshot read.
tryshow("P1a leading-slash wire", () -> build(Group((; a = Gain(1.0), b = Gain(2.0));
    local_wires = ("/a/out" => "b/e",), input_wires = ("in" => "a/e",))))
tryshow("P1b plain wire", () -> build(Group((; a = Gain(1.0), b = Gain(2.0));
    local_wires = ("a/out" => "b/e",), input_wires = ("in" => "a/e",))))
sim1 = Simulation(Group((; g = Group((; a = TickCounter()); output_wires = ("a/n" => "n",)))); Δt_frame = 1//10)
init!(sim1); run!(sim1; t_end = 0.3)
snap = latest(sim1)
tryshow("P1c snapshot read g/a", () -> port(snap, "g/a", :n))
tryshow("P1d snapshot read /g/a", () -> port(snap, "/g/a", :n))
println("P1e component_paths ", snap.layout.component_paths)

# P2 (S8d-012): full-depth read on snapshot and on a logged snapshot.
deep = Group((; systems = Group((; ldg = Group((; left = TickCounter()))))))
sim2 = Simulation(deep; Δt_frame = 1//10)
init!(sim2); run!(sim2; t_end = 0.3)
tryshow("P2a deep snapshot read", () -> port(latest(sim2), "systems/ldg/left", :n))
tryshow("P2b deep logged read", () -> port(logged(sim2)[2], "systems/ldg/left", :n))

# P3 (S8d-023): empty fan-out tuple.
tryshow("P3 empty tuple", () -> build(Group((; a = Gain(1.0)); input_wires = ("in" => (), "x" => "a/e"))))

# P4 (S8d-033, S8d-037): fed twice; two entries producing one output face; unfed input.
tryshow("P4a input fed twice", () -> build(Group((; a = Gain(1.0), b = Gain(2.0), c = Gain(3.0));
    local_wires = ("a/out" => "c/e", "b/out" => "c/e"), input_wires = ("in" => ("a/e", "b/e")))))
tryshow("P4b two producers one output face", () -> build(Group((; a = Gain(1.0), b = Gain(2.0));
    input_wires = ("in" => ("a/e", "b/e"),), output_wires = ("a/out" => "o", "b/out" => "o"))))
tryshow("P4c unfed input", () -> build(Group((; a = Gain(1.0), b = Gain(2.0));
    input_wires = ("in" => "a/e",))))

# P5 (S8d-042): `/` in an assembly face and in a primitive's contract key.
tryshow("P5a slash in assembly face", () -> build(Group((; a = Gain(1.0)); input_wires = ("i/n" => "a/e",))))
struct SlashKey <: AbstractComponent end
x_init(::SlashKey) = nothing
u_types(::SlashKey) = NamedTuple{(Symbol("p/q"),)}((Float64,))
y_types(::SlashKey) = NamedTuple{(Symbol("r/s"),)}((Float64,))
y_direct(::SlashKey, (; u)) = NamedTuple{(Symbol("r/s"),)}((1.0,))
tryshow("P5b slash in contract keys, at root", () -> build(SlashKey()))
tryshow("P5c slash in contract keys, below root", () -> build(Group((; k = SlashKey(), g = Gain(1.0));
    input_wires = ("in" => "g/e",))))

# P6 (S8d-045): empty contract key.
struct EmptyKey <: AbstractComponent end
x_init(::EmptyKey) = nothing
u_types(::EmptyKey) = NamedTuple{(Symbol(""),)}((Float64,))
y_types(::EmptyKey) = (out = Float64,)
y_direct(::EmptyKey, (; u)) = (out = 1.0,)
tryshow("P6a empty u_types key at root", () -> build(EmptyKey()))
tryshow("P6b empty face", () -> build(Group((; a = Gain(1.0)); input_wires = ("" => "a/e",))))

# P7 (S8d-055): primitive root with both contracts bare; and named `u` beside bare u_types.
struct BothBare <: AbstractComponent end
x_init(::BothBare) = nothing
u_types(::BothBare) = Float64
y_types(::BothBare) = Float64
y_direct(::BothBare, (; u)) = 2u
tryshow("P7a both bare at root", () -> build(BothBare()))
struct BareUNamedU <: AbstractComponent end
x_init(::BareUNamedU) = nothing
u_types(::BareUNamedU) = Float64
y_types(::BareUNamedU) = (u = Float64,)
y_direct(::BareUNamedU, (; u)) = (u = 2u,)
tryshow("P7b named u beside bare u_types", () -> build(BareUNamedU()))

# P8 (S8d-066): face types derive from the internal endpoint, mixed tiers.
mixed = Group((; tick = TickCounter(), plant = Plant());
              input_wires = ("force" => "plant/u",),
              output_wires = ("tick/n" => "count", "plant/y" => "pos"))
sim8 = Simulation(mixed; Δt_frame = 1//10)
init!(sim8, set(u = (force = 0.0,))); run!(sim8; t_end = 0.2)
L = latest(sim8).layout
println("P8a face addr === producer addr: count ", L.addr[("", :count)] == L.addr[("tick", :n)],
        ", pos ", L.addr[("", :pos)] == L.addr[("plant", :y)])
println("P8b face values ", typeof(port(latest(sim8), "", :count)), " ", typeof(port(latest(sim8), "", :pos)))
println("P8c root inputs ", L.root_inputs)
tryshow("P8d sample_times key on continuous child", () -> build(Group((; plant = Plant(), tick = TickCounter());
    input_wires = ("force" => "plant/u",), sample_times = (; plant = Relative(1)))))

# P9 (S8d-076): x_deriv sees each RK stage's state.
const XSEEN = Float64[]
struct Recorder <: AbstractComponent end
x_init(::Recorder) = (q = 1.0,)
y_types(::Recorder) = (y = Float64,)
y_state(::Recorder, (; x)) = (y = x.q,)
x_deriv(::Recorder, (; x)) = (push!(XSEEN, x.q); (q = x.q,))
sim9 = Simulation(Recorder(); Δt_frame = 1//10)
init!(sim9); empty!(XSEEN); step!(sim9; frames = 1)
println("P9 stepper ", typeof(sim9.model.deployment).parameters[1:min(end,0)], " x_deriv x values in one frame: ", XSEEN)

# P10 (S8d-089): child at Relative(1) in its own scope; parent sets the rate.
imu = Group((; sampler = TickCounter(), errors = TickCounter()); sample_times = (; sampler = Relative(1), errors = Relative(1)))
s10 = build(Group((; imu = imu); sample_times = (; imu = Relative(4)))).structure
entry10(p) = s10.components[index_of(s10, p)]
println("P10 imu/sampler timing ", Tuple(entry10("imu/sampler").timing), " rates ", entry10("imu/sampler").rates)
s10b = build(Group((; imu = imu); sample_times = (; imu = Absolute(1//50)))).structure
println("P10b anchored imu/sampler timing ", Tuple(s10b.components[index_of(s10b, "imu/sampler")].timing), " anchors ", s10b.anchors)

# P11 (S8d-099): a discrete component's stage runs only when due.
const STAGECALLS = Int[]
struct CountingSampler <: AbstractComponent end
s_init(::CountingSampler) = (n = 0,)
y_types(::CountingSampler) = (n = Int,)
y_state(::CountingSampler, (; s)) = (push!(STAGECALLS, s.n); (n = s.n,))
s_update(::CountingSampler, (; s)) = (n = s.n + 1,)
sim11 = Simulation(Group((; p = Plant(), c = CountingSampler()); input_wires = ("f" => "p/u",),
                         sample_times = (; c = Relative(3))); Δt_frame = 1//10)
init!(sim11, set(u = (f = 0.0,))); empty!(STAGECALLS)
step!(sim11; frames = 6)
println("P11 stage calls over 6 frames at Relative(3): ", STAGECALLS, " schedule ", [(r.D, r.Φ) for r in sim11.model.deployment.schedule.rows])
