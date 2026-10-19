# --- the log (§11.2, increment 11) ----------------------------------------------
# Publication now follows *every* boundary — t* boundaries included, retiring
# the increment-9 stand-in — and the log is retention policy over exactly those
# publications: the switch, the stride, the bound with its progressive
# re-decimation, and the two unconditional endpoints outside it.

function test_log()
    @testset "every boundary publishes: t* included, boundary-consistent (§11.2, §10.6)" begin
        model = Group((; src = Sawtooth(1.0), s = Stamper(0.315));
                      local_wires = ("src/q" => "s/sig",))
        sim = Simulation(model; h = 1//10)
        init!(sim)
        run!(sim; t_end = 0.5)
        snapshots = logged(sim)
        t★ = modes(sim, "s").t_fired
        i = findfirst(snapshot -> snapshot.t == t★,
                       snapshots)   # bitwise: a snapshot published at t* itself
        @test i !== nothing
        @test length(snapshots) == 7               # boundary zero + 5 frame tops + one t*
        @test [snapshot.frame for snapshot in snapshots] == [0, 1, 2, 3, 4, 4, 5]   # t* shares its frame's ordinal
        # The t* snapshot is the settled boundary's: the re-sweep after the firing
        # is what it captures, so `armed` has already dropped — while the boundary
        # before it still shows the armed value. Boundary-consistency at t*.
        @test port(snapshots[i], "s", :armed) === false
        @test port(snapshots[i-1], "s", :armed) === true
        ts = [snapshot.t for snapshot in snapshots]
        @test issorted(ts) && allunique(ts)    # t never decreases, t* strictly inside
    end

    @testset "the log is the publications themselves: full density, zero copies (§11.2)" begin
        sim = Simulation(fed(Plant(), "u"); h = 1//10)
        init!(sim, set(u = (in = 1.0,)))
        step!(sim; t_plus = 1.0)
        snapshots = logged(sim)
        @test [snapshot.frame for snapshot in snapshots] == collect(0:10)      # boundary zero + every frame top
        @test snapshots[end] === latest(sim)                     # the same object publication handed out
        ys = [port(snapshot, "c", :y) for snapshot in snapshots]
        @test issorted(ys) && allunique(ys)                  # the step response, one value per boundary
        @test ys[end] === port(sim, "c", :y)        # the terminal endpoint is the live boundary
        step!(sim; t_plus = 1.0)
        @test length(logged(sim)) == 21                      # the session accumulates: one trajectory, one log
    end

    @testset "the log allocates nothing beyond publication (§9.8, §11.2)" begin
        # Equal, not zero: §11.2 builds a snapshot and a table copy per frame
        # by design, log or no log. The log stores the box publication made.
        # 1000 frames carry the ordinal past 511, where a dynamic `Int` read boxes.
        sim = Simulation(feedback_model(); h = 1//100)
        authored = set(u = (ref = 0.0,))
        for log in (true, false)                             # compilation out of the number
            init!(sim, authored; log)
            run!(sim; t_end = 10.0)
        end
        logged_bytes = @ballocated(run!($sim; t_end = 10.0),
                                   setup = (init!($sim, $authored; log = true)), evals = 1)
        unlogged_bytes = @ballocated(run!($sim; t_end = 10.0),
                                     setup = (init!($sim, $authored; log = false)), evals = 1)
        @test logged_bytes == unlogged_bytes
    end

    @testset "logged is typed by the run's snapshot type, empty or not (§11.2)" begin
        sim = Simulation(fed(Plant(), "u"); h = 1//10)
        unpublished = eltype(logged(sim))                    # before the first `init!`
        init!(sim, set(u = (in = 0.0,)))
        run!(sim; t_end = 0.5)
        @test eltype(logged(sim)) === typeof(latest(sim))
        @test unpublished === typeof(latest(sim))
        init!(sim, set(u = (in = 0.0,)); log = false)
        run!(sim; t_end = 0.5)
        @test isempty(logged(sim)) && eltype(logged(sim)) === typeof(latest(sim))
    end

    @testset "log_every thins retention, never publication (§11.2)" begin
        sim = Simulation(fed(Plant(), "u"); h = 1//10)
        init!(sim, set(u = (in = 0.0,)); log_every = 3)
        step!(sim; frames = 1)
        @test latest(sim).frame == 1                         # published to live readers…
        @test [snapshot.frame for snapshot in logged(sim)] == [0, 1]       # …not retained: `last` alone holds it
        step!(sim; t_plus = 0.9)
        @test [snapshot.frame for snapshot in logged(sim)] == [0, 3, 6, 9, 10]
    end

    @testset "the endpoints are unconditional and outside the bound (§11.2)" begin
        sim = Simulation(fed(Plant(), "u"); h = 1//10)
        init!(sim, set(u = (in = 0.0,)); log_every = 4, log_max = 2)
        run!(sim; t_end = 4.0)
        snapshots = logged(sim)
        @test [snapshot.frame for snapshot in snapshots] ==
              [0, 16, 32, 40]    # two generations in
        @test sim.run.log.live == 2                              # the bound counts the middle alone
    end

    @testset "re-decimation: stride doubles, coverage stays global, the bound holds continuously (§11.2, D-137)" begin
        sim = Simulation(fed(Plant(), "u"); h = 1//10)
        init!(sim, set(u = (in = 0.0,)); log_max = 8)
        ok_bound = ok_ends = ok_sorted = true
        for k in 1:128                                       # one frame at a time: every
            step!(sim; frames = 1)                           # intermediate state is checked
            ok_bound &= sim.run.log.live ≤ 8
            snapshots = logged(sim)
            ok_ends &= snapshots[1].frame == 0 && snapshots[end].frame == k
            ts = [snapshot.t for snapshot in snapshots]
            ok_sorted &= issorted(ts) && allunique(ts)
        end
        @test ok_bound && ok_ends && ok_sorted
        # 128 = 16·8 boundaries, four generations in: the middle sits at exactly
        # stride·(1..log_max) — coverage global at the effective stride, gap-free —
        # and the retained final boundary dedups against the terminal endpoint.
        @test sim.run.log.stride == 16
        @test [snapshot.frame for snapshot in sim.run.log.snaps] == collect(16:16:128)
        @test length(logged(sim)) == 9

        # The effective stride composes with the authored one: log_every · 2^k.
        sim2 = Simulation(fed(Plant(), "u"); h = 1//10)
        init!(sim2, set(u = (in = 0.0,)); log_every = 2, log_max = 4)
        run!(sim2; t_end = 4.0)
        @test [snapshot.frame for snapshot in logged(sim2)] == [0, 8, 16, 24, 32, 40]
        @test sim2.run.log.stride == 16                          # 2 · 2³
    end

    @testset "log = false retains nothing; publication is upstream of the switch (§11.2)" begin
        sim = Simulation(fed(Plant(), "u"); h = 1//10)
        init!(sim, set(u = (in = 0.0,)); log = false)
        run!(sim; t_end = 0.5)
        @test isempty(logged(sim))
        @test latest(sim).frame == 5
    end

    @testset "view policies, never trajectory-determining (§11.2)" begin
        # A localized-event trajectory, so the t* machinery is in the loop too:
        # retention differing in every keyword, the trajectory bitwise the same.
        function session(; kw...)
            sim = Simulation(single(Bouncer(1.0, 0.315)); h = 1//10)
            init!(sim; kw...)
            sim
        end
        full, unlogged, thinned =
            session(), session(log = false), session(log_every = 7, log_max = 3)
        foreach(sim -> run!(sim; t_end = 2.0), (full, unlogged, thinned))
        q_reference = state(full, "c").q
        @test q_reference === state(unlogged, "c").q
        @test q_reference === state(thinned, "c").q
        count_reference = modes(full, "c").count
        @test count_reference === modes(unlogged, "c").count
        @test count_reference === modes(thinned, "c").count
    end

    @testset "a warm restart is a new trajectory: the log starts over (§11.2)" begin
        sim = Simulation(fed(Plant(), "u"); h = 1//10)
        init!(sim, set(u = (in = 0.0,)))
        run!(sim; t_end = 1.0)
        @test length(logged(sim)) == 11
        init!(sim, set(u = (in = 0.0,)))
        @test [snapshot.frame for snapshot in logged(sim)] ==
              [0]          # the new boundary zero, alone
    end

    @testset "a restored run counts its stride from its first endpoint (§11.2, D-274)" begin
        sim = Simulation(fed(Plant(), "u"); h = 1//10)
        init!(sim, set(u = (in = 0.0,)))
        step!(sim; frames = 4)
        restored = Simulation(fed(Plant(), "u"); h = 1//10)
        restore!(restored, checkpoint(sim); log_every = 3)
        step!(restored; frames = 9)
        # the first endpoint re-publishes boundary 4, and every third past it is kept
        @test [snapshot.boundary for snapshot in logged(restored)] == [4, 7, 10, 13]
    end

    @testset "logged is a stopped-sim read behind the §11.3 gate" begin
        sim = Simulation(fed(Plant(), "u"); h = 1//100000)
        init!(sim, set(u = (in = 0.0,)); log_max = 16)
        logged(sim)                                          # warms the compile path, so the
                                                             # mid-run check below races no JIT
        attach!(sim, TailProbe(), NoClaim())   # a rostered device makes the loop yield every
                                               # frame (§12.2), so the spin gets its turn on one thread
        task = Threads.@spawn run!(sim; t_end = 1.0)
        while lifecycle(sim) !== :running && !istaskdone(task)   # a missed start fails below, never hangs
            yield()
        end
        err = try logged(sim) catch err; err end
        wait(task)
        @test err isa DiagnosticError && diagnostic(err) isa ServiceLifecycle
        # the readers' gate refuses `:running` alone, post-mortem reads included (§13.6)
        @test diagnostic(err).legal == [:built, :initialized, :stopped, :errored]
        @test length(logged(sim)) ≥ 2                        # the gate lifts with the run
    end

    @testset "the retention keywords are validated with their siblings (§11.2)" begin
        sim = Simulation(fed(Plant(), "u"); h = 1//10)
        authored = set(u = (in = 0.0,))
        # View policies are the door's keywords, so they are `ArgumentInvalid`s
        # at `call = :init!` (D-261), refused before any write.
        d = only(diagnostics(failure(() -> init!(sim, authored; log = 1))))
        @test d isa ArgumentInvalid && d.call === :init! && d.argument === :log
        d = only(diagnostics(failure(() -> init!(sim, authored; log_every = 0))))
        @test d isa ArgumentInvalid && d.argument === :log_every && d.reason === :range
        d = only(diagnostics(failure(() -> init!(sim, authored; log_max = 0))))
        @test d isa ArgumentInvalid && d.argument === :log_max
        d = only(diagnostics(failure(() -> init!(sim, authored; log_max = 1.5))))
        @test d isa ArgumentInvalid && d.argument === :log_max
        @test lifecycle(sim) === :built
        init!(sim, authored; log_max = Inf)                         # the explicit opt-out
        @test length(sim.run.log.snaps.ref.mem) < 1024              # no bound, no hint
        run!(sim; t_end = 1.0)
        @test length(logged(sim)) == 11
        # A finite bound hints the middle's capacity at `init!` (§9.8, §11.2).
        init!(sim, authored; log_max = 4096)
        @test isempty(sim.run.log.snaps)
        @test length(sim.run.log.snaps.ref.mem) ≥ 4096
    end

    # --- the series over the log (§11.2, D-407) --------------------------------------

    @testset "columns are the comprehension's values, typed by the leaf (§11.2, D-407)" begin
        sim = Simulation(fed(VectorPlant(), "u"); h = 1//10)
        init!(sim, set(u = (in = 1.0,)))
        run!(sim; t_end = 1.0)
        snapshots = logged(sim)
        columns = series(sim, reads(q = get_output("c", :q), power = get_output("c", :power))).columns
        @test columns.q == [port(snapshot, "c", :q) for snapshot in snapshots]
        @test columns.power == [port(snapshot, "c", :power) for snapshot in snapshots]
        @test allunique(columns.power)                       # the stage-2 port moves with the state
        @test typeof(columns.q) === Vector{SVector{2,Float64}}
        @test typeof(columns.power) === Vector{Float64}
        # The stamps are the snapshots' own, read on a run whose t* boundary
        # shares its frame's ordinal, so the frame and boundary columns differ.
        stamped = Simulation(Group((; src = Sawtooth(1.0), s = Stamper(0.315));
                                   local_wires = ("src/q" => "s/sig",)); h = 1//10)
        init!(stamped)
        run!(stamped; t_end = 0.5)
        snapshots = logged(stamped)
        stamped_series = series(stamped, reads(armed = get_output("s", :armed)))
        @test stamped_series.t == [snapshot.t for snapshot in snapshots]
        @test stamped_series.frame == [0, 1, 2, 3, 4, 4, 5]
        @test stamped_series.boundary == [snapshot.boundary for snapshot in snapshots] == 0:6
        @test stamped_series.columns.armed == [port(snapshot, "s", :armed) for snapshot in snapshots]
        @test typeof(stamped_series.columns.armed) === Vector{Bool}
    end

    @testset "a leaf step reads one component (§14.4, D-276, D-407)" begin
        sim = Simulation(fed(VectorPlant(), "u"); h = 1//10)
        init!(sim, set(u = (in = 1.0,)))
        run!(sim; t_end = 1.0)
        qs = [port(snapshot, "c", :q) for snapshot in logged(sim)]
        columns = series(sim, reads(q2 = get_output("c", "q[2]"))).columns
        @test columns.q2 == getindex.(qs, 2)
        @test typeof(columns.q2) === Vector{Float64}
        # A `.name` step and a two-index step on a struct port.
        posed = Simulation(pose_model(); h = 1//10)
        init!(posed)
        run!(posed; t_end = 0.5)
        poses = [port(snapshot, "c", :pose) for snapshot in logged(posed)]
        columns = series(posed, reads(v = get_output("c", "pose.v"), m12 = get_output("c", "pose.m[1,2]"))).columns
        @test columns.v == getfield.(poses, :v)
        @test typeof(columns.v) === Vector{SVector{3,Float64}}
        @test columns.m12 == [pose.m[1, 2] for pose in poses]
        @test allunique(columns.m12)                         # the entry the state drives
    end

    @testset "labels and order are the set's (D-407)" begin
        sim = Simulation(fed(VectorPlant(), "u"); h = 1//10)
        init!(sim, set(u = (in = 1.0,)))
        run!(sim; t_end = 0.5)
        columns = series(sim, reads(power = get_output("c", :power), q = get_output("c", :q),
                                    input = get_input(:in))).columns
        @test keys(columns) === (:power, :q, :input)
        @test columns.input == fill(1.0, 6)
    end

    @testset "empty before the first init!, typed all the same (§11.2, D-407)" begin
        sim = Simulation(fed(VectorPlant(), "u"); h = 1//10)
        empty_series = series(sim, reads(q = get_output("c", :q), q2 = get_output("c", "q[2]")))
        @test length(empty_series.t) == length(empty_series.frame) == length(empty_series.boundary) == 0
        @test typeof(empty_series.columns) ===
              @NamedTuple{q::Vector{SVector{2,Float64}}, q2::Vector{Float64}}
        @test isempty(empty_series.columns.q) && isempty(empty_series.columns.q2)
    end

    @testset "a mount reads what its root-authored twin reads (§14.9, D-277)" begin
        sim = Simulation(fed(Plant(), "u"); h = 1//10)
        init!(sim, set(u = (in = 1.0,)))
        run!(sim; t_end = 1.0)
        mounted = series(sim, at("c", reads(h = get_face(:y), p = get_face(:power)))).columns
        rooted = series(sim, reads(h = get_output("c", :y), p = get_output("c", :power))).columns
        @test mounted == rooted
        @test mounted.h == [port(snapshot, "c", :y) for snapshot in logged(sim)]
    end

    @testset "refusals are the resolver's, collected (§14.4, §13.1, D-406, D-407)" begin
        sim = Simulation(fed(VectorPlant(), "u"); h = 1//10)
        init!(sim, set(u = (in = 1.0,)))
        run!(sim; t_end = 0.5)
        d = only(diagnostics(failure(() -> series(sim, reads(x = get_state("c", :q))))))
        @test d isa ReadResolution && d.reason === :store_selector && d.label === :x
        d = only(diagnostics(failure(() -> series(sim, reads(h = get_output("c", :nope))))))
        @test d isa ReadResolution && d.reason === :undeclared && d.declares === :output_port
        @test d.candidates == [:q, :power]                   # declaration order
        d = only(diagnostics(failure(() -> series(sim, reads(h = get_output("nope", :q))))))
        @test d isa PathResolution && d.reason === :unknown_child && d.segment == "nope"
        diags = diagnostics(failure(() -> series(sim, reads(a = get_output("c", :nope),
                                                            b = get_state("c", :q),
                                                            c = get_face(:nope)))))
        @test all(d -> d isa ReadResolution, diags)
        @test [d.label for d in diags] == [:a, :b, :c]
        @test [d.reason for d in diags] == [:undeclared, :store_selector, :unknown_output_face]
        # A bare NamedTuple of selectors is the §14.2 misuse, not a MethodError.
        d = carried(@test_throws DiagnosticError{ReadSetMisuse} series(sim, (; h = get_output("c", :q))))
        @test d.reason === :not_a_read_set && d.observed <: NamedTuple
    end

    @testset "the stride thins the columns with the log (§11.2)" begin
        sim = Simulation(fed(VectorPlant(), "u"); h = 1//10)
        init!(sim, set(u = (in = 1.0,)); log_every = 3)
        run!(sim; t_end = 1.0)
        thinned = series(sim, reads(q = get_output("c", :q)))
        @test length(thinned.t) == length(thinned.columns.q) == length(logged(sim))
        @test thinned.frame == [0, 3, 6, 9, 10]
    end

    @testset "series is a stopped-sim read behind the §11.3 gate" begin
        sim = Simulation(fed(Plant(), "u"); h = 1//100000)
        init!(sim, set(u = (in = 0.0,)); log_max = 16)
        read_set = reads(y = get_output("c", :y))
        series(sim, read_set)                                # warms the compile path, so the
                                                             # mid-run check below races no JIT
        attach!(sim, TailProbe(), NoClaim())   # a rostered device makes the loop yield every
                                               # frame (§12.2), so the spin gets its turn on one thread
        task = Threads.@spawn run!(sim; t_end = 1.0)
        while lifecycle(sim) !== :running && !istaskdone(task)   # a missed start fails below, never hangs
            yield()
        end
        err = try series(sim, read_set) catch err; err end
        wait(task)
        @test err isa DiagnosticError && diagnostic(err) isa ServiceLifecycle
        @test diagnostic(err).op === :series
        @test diagnostic(err).legal == [:built, :initialized, :stopped, :errored]
        @test length(series(sim, read_set).t) ≥ 2           # the gate lifts with the run
    end

    @testset "labels reach no compiled body (D-407)" begin
        # `series` compiles once per simulation type, whatever its read set, and
        # `_column` once per entry type. The counts are read around calls on one
        # simulation, so the snapshot type is fixed; `q[1]` is read nowhere else.
        sim = Simulation(fed(VectorPlant(), "u"); h = 1//10)
        init!(sim, set(u = (in = 1.0,)))
        run!(sim; t_end = 0.5)
        series(sim, reads(q = get_output("c", :q), power = get_output("c", :power)))
        counts = specialization_counts((series, Redstone._column))
        series(sim, reads(b = get_output("c", :power), a = get_output("c", :q)))   # new labels, new order
        series(sim, reads(input = get_input(:in)))           # a new entry of a seen type
        @test specialization_counts((series, Redstone._column)) == counts
        series(sim, reads(q1 = get_output("c", "q[1]")))    # a new chain
        @test specialization_counts((series, Redstone._column)) ==
              [:series => last(counts[1]), :_column => last(counts[2]) + 1]
    end
end
