# The precompile workload (§9.7, D-289). A closed loop of library blocks runs
# through the generic machinery a cold process pays, so the package image
# carries it. The workload sees the library's blocks alone, so a user's
# component types still pay their own stage methods, the chunks they fill and
# their `Dual` activation. `test/test_precompile.jl` runs `workload` in a fresh
# process and pins what it compiles.

"""
    workload_loop()

The workload's model: a `Step` reference into a `DiscretePID` at 50 Hz, a
`FirstOrderLag` actuator, a `SumJunction` adding the root input `disturbance`,
a second-order `TransferFunction` plant whose output is the root output `y`,
and a `LimitedIntegrator` on that output, for the event machinery.
"""
workload_loop() = Blocks.Group((
        reference = Blocks.Step(t_step = 0.5, after = 1.0),
        controller = Blocks.DiscretePID(Kp = 2.0, Ki = 1.0, Tt = 1.0, u_min = -1.0, u_max = 1.0),
        actuator = Blocks.FirstOrderLag(τ = 0.05),
        force = Blocks.SumJunction{Float64, 2}(),
        plant = Blocks.TransferFunction(num = (1.0,), den = (1.0, 0.6, 1.0)),
        integral = Blocks.LimitedIntegrator(lower = -0.5, upper = 0.5));
    local_wires = ("reference/out" => "controller/r", "plant/out" => "controller/y",
                   "controller/u" => "actuator/in", "actuator/out" => "force/in1",
                   "force/out" => "plant/in", "plant/out" => "integral/in"),
    input_wires = ("disturbance" => "force/in2",),
    output_wires = ("plant/out" => "y",),
    sample_times = (controller = Absolute(Hz(50)),))

"""
    workload()

The workload's body: `workload_loop` through `build`, the build's `show`,
`Simulation`, `init!`, `step!`, `run!`, `port`, `state`, `series` and a
`checkpoint` restored, then `trim!` and `linearize` on a second simulation of
the same build. `@compile_workload` runs it once while the package precompiles.
"""
function workload()
    loop_build = build(workload_loop())
    sprint(show, MIME"text/plain"(), loop_build)
    sim = Simulation(loop_build; h = 1//1000)
    init!(sim, set(u = (disturbance = 0.0,)))
    step!(sim)
    run!(sim; t_end = 0.1)
    port(sim, "plant", :out)
    state(sim, "plant")
    series(sim, reads(y = get_output("plant", :out)))
    restore!(sim, checkpoint(sim))
    trim_sim = Simulation(loop_build; h = 1//1000)
    trim!(trim_sim, TrimProblem(
        guess = (d = 0.3,), lower = (d = -1.0,), upper = (d = 1.0,),
        condition = d -> set(u = (disturbance = d.d,)),
        reads = reads(q̇₂ = get_deriv("plant", "[2]")),
        residuals = (derivatives, d) -> (q̇₂ = derivatives.q̇₂,),
        tolerances = (q̇₂ = 1e-9,)); baseline = set(u = (disturbance = 0.0,)))
    linearize(trim_sim, taps(
        x = (q₁ = get_state("plant", "[1]"), q₂ = get_state("plant", "[2]")),
        u = (d = get_input(:disturbance),), y = (y = get_output("plant", :out),)))
    nothing
end

@setup_workload begin
    @compile_workload begin
        workload()
    end
end
