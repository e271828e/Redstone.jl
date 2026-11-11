# --- the stepper seam (§10.2, increment 8) --------------------------------------
# Interchangeability is the claim under test: the loop, the localization
# machinery and the deployment surface are method-blind, and the two backends
# differ exactly where their orders say they must.

# The bouncer beside a stop request that never holds: one honoured requester,
# scanned at every publication.
requested_bouncer() = Group((; b = Bouncer(1.0, 0.07), r = requested(false, "never")))

function test_stepper()
    @testset "the method is a deployment binding by instance, RK4() the default (§10.2, D-442, D-449)" begin
        sim = Simulation(feedback_model(); Δt_frame = 1//100)
        @test sim.model.exec.stepper isa RK4Stepper{Float64}
        heun_sim = Simulation(feedback_model(); Δt_frame = 1//100, algorithm = Heun())
        @test heun_sim.model.exec.stepper isa HeunStepper{Float64}
        @test sim.model.deployment.algorithm == RK4() && heun_sim.model.deployment.algorithm == Heun()
        @test sim.model.deployment != heun_sim.model.deployment
        # A token carries no step: the bound is the deployment's `h_max` (D-449).
        @test_throws MethodError RK4(1//100)
        @test_throws MethodError Heun(1//100)
        # validated with its siblings: anything but a token is refused at binding,
        # the type form included, not deep in a MethodError
        for bad in (4, Int, RK4, Heun)
            d = only(diagnostics(failure(() ->
                Simulation(feedback_model(); Δt_frame = 1//100, algorithm = bad))))
            @test d isa DeploymentInvalid && d.parameter === :algorithm &&
                  d.reason === :range && d.value === bad
        end
        # The token prints as it is spelled, so a header reads alike from any module.
        @test repr(RK4()) == "RK4()" && repr(Heun()) == "Heun()"
    end

    @testset "h_max bounds the step, divides nothing, and is recorded resolved against the frame (§9.2, §10.5, D-449)" begin
        feedback_build = build(feedback_model())
        multirate_build = build(MultiRate())   # discrete work: three rows
        refused(; kw...) = diagnostics(failure(() -> Deployment(multirate_build; kw...)))
        # No bound, a bound at the frame and one above it are one trajectory, so
        # they deploy as one value, the bound resolved to the frame.
        unbounded = Deployment(feedback_build; Δt_frame = 1//100)
        for spelled in (Deployment(feedback_build; Δt_frame = Hz(100), h_max = 1//100),
                        Deployment(feedback_build; Δt_frame = 1//100, h_max = Period(1//50)),
                        Deployment(feedback_build; Δt_frame = 1//100, h_max = 7))
            @test spelled == unbounded && hash(spelled) == hash(unbounded)
            @test spelled.h_max === unbounded.h_max === 0.01
        end
        # A bound below the frame is a different deployment, in every spelling.
        bounded = Deployment(feedback_build; Δt_frame = 1//100, h_max = Hz(400))
        @test bounded.h_max === Float64(1//400) && bounded != unbounded &&
              bounded == Deployment(feedback_build; Δt_frame = 1//100, h_max = 1//400)
        # A bound need divide nothing: with discrete work, `Δt_frame = 1//500`,
        # `Δt_base = 1//300` and `h_max = 3//2000` deploy, the bound a ratio of
        # the unit `gcd(1//500, 1//300) = 1//1500`.
        deployment = Deployment(multirate_build; Δt_frame = 1//500, Δt_base = 1//300,
                                h_max = 3//2000)
        @test (deployment.lattice.frame, deployment.lattice.base, deployment.lattice.bound) ==
              (3, 5, 9//4)
        # `h_max` is a premise of its own, exact, positive and finite.
        d = only(refused(Δt_frame = 1//500, h_max = 0.001))
        @test d isa DeploymentInvalid && d.parameter === :h_max && d.reason === :inexact &&
              d.value === 0.001
        for bad in (0, -1//500, 1//0)
            d = only(refused(Δt_frame = 1//500, h_max = bad))
            @test d.parameter === :h_max && d.reason === :range && d.value == bad
        end
        d = only(refused(Δt_frame = 1//500, h_max = "1//1000"))
        @test d.parameter === :h_max && d.reason === :not_a_quantity
        # `Δt_base` is a premise of its own, positive and finite (D-445).
        for bad in (0, -1//300, 1//0)
            d = only(refused(Δt_frame = 1//500, Δt_base = bad))
            @test d.parameter === :Δt_base && d.reason === :range && d.value == bad
        end
        # Every check whose premise holds runs (D-229): a bound's fault skips
        # nothing, since the anchor loop reads `Δt_base` alone.
        @test Set((d.parameter, d.reason)
                  for d in refused(Δt_frame = 1//500, Δt_base = 3//250, h_max = 0)) ==
              Set([(:h_max, :range), (:Δt_base, :anchor_period)])
    end

    @testset "convergence order: each backend is itself — 4 and 2 (§10.2)" begin
        # The sharp form of the interchangeability claim: same model, same loop,
        # same reference, and the fitted order is the method's own. A mislabeled
        # backend cannot sit in both bands, where a shared loose tolerance would
        # let it hide.
        ω, ζ, k, r = 2.0, 0.1, 4.0, 0.7
        A = SMatrix{2,2}(0.0, -ω^2, 1.0, -2ζ * ω)
        B = SVector(0.0, 1.0)
        Acl = A - B * k * SVector(1.0, 0.0)'
        exact(t) = exp(Acl * t) * (Acl \ (B * k * r)) - Acl \ (B * k * r)
        function final_error(algorithm, h)
            sim = Simulation(feedback_model(; k, ω, ζ); Δt_frame = h, algorithm)
            init!(sim, set(u = (ref = r,)))
            run!(sim; t_end = 2.0)
            norm(state(sim, "plant").q - exact(2.0))
        end
        hs = (1//10, 1//20, 1//40, 1//80)   # errors 5e-8..2e-4: well above float noise
        for (algorithm, p) in ((RK4(), 4.0), (Heun(), 2.0))
            errs = [final_error(algorithm, h) for h in hs]
            orders = [log2(errs[i] / errs[i+1]) for i in 1:3]
            @test all(o -> abs(o - p) < 0.3, orders)
        end
    end

    @testset "localization is seam-generic: t* under Heun (§10.2, §10.4)" begin
        # Linear trajectory: Heun and the Hermite are both exact, so the stamp is
        # method-independent down to the bracket width — the machinery, not the
        # method, sets the error.
        model = Group((; src = Sawtooth(1.0), s = Stamper(0.315));
                      local_wires = ("src/q" => "s/sig",))
        sim = Simulation(model; Δt_frame = 1//10, algorithm = Heun())
        init!(sim)
        run!(sim; t_end = 0.5)
        @test modes(sim, "s").count == 1
        @test modes(sim, "s").t_fired ≈ 0.315 atol = 1e-6

        # Nonlinear trajectory: the stamp error is now the discrete solution's
        # O(h²), not RK4's O(h⁴) — quartering under h-halving is the method
        # showing through the same machinery. (Boundary-resolution firing would
        # sit at ~h and shrink linearly instead.)
        stamp_error(h) = begin
            rotor_model = Group((; src = Rotor(; ω = 1.0, r₀ = SVector(-1.0, 0.0)), s = Stamper(-0.5));
                                local_wires = ("src/c" => "s/sig",))
            rotor_sim = Simulation(rotor_model; Δt_frame = h, algorithm = Heun())
            init!(rotor_sim)
            run!(rotor_sim; t_end = 1.5)
            @test modes(rotor_sim, "s").count == 1
            abs(modes(rotor_sim, "s").t_fired - π / 3)
        end
        coarse_error, fine_error = stamp_error(1//10), stamp_error(1//40)
        @test coarse_error < 5e-3
        @test 10 < coarse_error / fine_error < 24               # h²: ×16 over two halvings

        # The frame-top claims never depended on the method: an epoch-caused edge
        # falls through to fire at the indexed grid time bitwise under Heun too.
        fed_sim = Simulation(fed(Stamper(0.5), "sig"); Δt_frame = 1//10, algorithm = Heun())
        init!(fed_sim, set(u = (in = 0.0,)))
        step!(fed_sim; t_plus = 0.3)
        stage!(fed_sim, "in" => 1.0)                   # frame 4's drain, at its frame top
        step!(fed_sim; t_plus = 0.3)
        @test modes(fed_sim, "c").t_fired == 4 * fed_sim.model.deployment.Δt_frame
    end

    @testset "gate 4: the second backend holds the §9.8 invariant" begin
        sim = Simulation(feedback_model(); Δt_frame = 1//1000, algorithm = Heun())
        init!(sim, set(u = (ref = 0.0,)))
        integrate!(sim, 1e-3)
        @test @ballocated(integrate!($sim, 1e-3)) == 0
        # The localizing frame allocates exactly its two boundaries' publications,
        # the t* one's and the frame top's — the framework-side carve-out (§9.8,
        # §11.2) — as under RK4 (gate 3).
        bouncer_sim = Simulation(single(Bouncer(1.0, 0.07)); Δt_frame = 1//10, algorithm = Heun())
        init!(bouncer_sim; log = false)
        publish_bytes = @ballocated publish!($bouncer_sim, $(bouncer_sim.plane.roster))
        no_mask = Bool[]                    # the advance's argument (D-260, D-261)
        hooks = LoopHooks(bouncer_sim, bouncer_sim.plane.roster, nothing, no_mask, 0)
        @test @ballocated(frame!($(bouncer_sim.model), 1, $hooks), setup = (init!($bouncer_sim; log = false)), evals = 1) == 2 * publish_bytes
        # One honoured requester adds the scan of its buffer and no allocation
        # (§13.5, D-316).
        requested_sim = Simulation(requested_bouncer(); Δt_frame = 1//10, algorithm = Heun())
        init!(requested_sim; log = false)
        requested_bytes = @ballocated publish!($requested_sim, $(requested_sim.plane.roster))
        honoured_mask = Bool[false]
        requested_hooks = LoopHooks(requested_sim, requested_sim.plane.roster, nothing, honoured_mask, 0)
        @test @ballocated(frame!($(requested_sim.model), 1, $requested_hooks), setup = (init!($requested_sim; log = false)), evals = 1) == 2 * requested_bytes
    end

    @testset "the second backend is generic over the scalar (§7.2)" begin
        dual_model = Model(feedback_model(), D8; Δt_frame = 1//1000, algorithm = Heun())
        init!(dual_model, set(u = (ref = D8(0.7),)))
        frames!(dual_model, 50)                # `run!` to 0.05
        @test state(dual_model, "plant").q isa SVector{2,D8}
    end
end
