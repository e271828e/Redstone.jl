# --- the artifacts' renderings (§9.2, §13.7, D-257; increment 48) --------------
# Each build-side and deployment artifact prints itself: the compact form on
# `show(io, x)` and the tables on `MIME"text/plain"`. The exact blocks below are
# `MultiRate`'s at `h = 1//500`, whose rows and hyperperiod §9.2's worked example
# fixes; the anchored `1//500`/`1//10, 1//150` group is the guard's long case.

# The REPL form.
plain(x) = sprint(show, MIME("text/plain"), x)

# The one-line form: what a container or `repr` prints.
compact(x) = sprint(show, x)

# The anchored group of `test_discrete.jl`'s attribution test, derived at
# `h = 1//1500`: `lcm(Dᵢ) = 150`, past the chart guard.
function anchored_group()
    comp = Group((; a = TickCounter(), b = TickCounter());
                 sample_times = (; a = Absolute(1//500), b = Absolute(1//10, 1//150)))
    @test_logs (:info, r"derived") (:warn, r"^GridUtilization") Deployment(
        build(comp); Δt_frame = 1//1500, Δt_base = :derive)
end

# The framework status built by hand (§11.8), no run needed: a counter record
# holding `number` `MalformedDatum`s and nothing else.
malformed_counts(number::Int) =
    KindCounts((f === :malformed ? number : 0 for f in fieldnames(KindCounts))...)

# A device's record with `total` occurrences in all, the last ones this
# boundary's: `retained` in the ring, then `suppressed` refused past it. The
# retained ones are numbered by their place in the run's account.
function malformed_record(total::Int, retained::Int, suppressed::Int)
    first_retained = total - suppressed - retained + 1
    WriterStatus("device 1 (Parser)",
                 [MalformedDatum("datum $k") for k in first_retained:first_retained + retained - 1],
                 malformed_counts(suppressed), malformed_counts(total), 1.0e9, :running)
end

# A writer with no task and no occurrences: the harness's and the loop's shape.
quiet_record(who::String) = WriterStatus(who, MalformedDatum[], KindCounts(), KindCounts(),
                                         nothing, nothing)

hand_status(device_record::WriterStatus; pacer = PacerStatus(nothing)) =
    FrameworkStatus([device_record, quiet_record("harness"), quiet_record("loop")], pacer)

const QUIET_STATUS = """
FrameworkStatus: 3 writers, no occurrences, unpaced
  device 1 (Parser): running, heartbeat 1.0e9, no occurrences
  harness: no occurrences
  loop: no occurrences
  pacer: unpaced, debt 0.0 s, peak 0.0 s, no overruns, no reanchors, 0.0 s forgiven, no waits, 0.0 s waited"""

const MULTIRATE_STRUCTURE = """
Structure: 4 components, 1 anchor, 1 rate scope; root inputs: none
  components:
    path       tier        anchor  m  c  rates
    src        continuous  A₀      1  0  —
    fcs/inner  discrete    A₀      1  0  fcs = Relative(1, 0) → inner = Relative(1, 0)
    fcs/outer  discrete    A₀      5  2  fcs = Relative(1, 0) → outer = Relative(5, 2)
    gnss       discrete    A₁      1  0  gnss = Absolute(1//50, 0//1)
  rate scopes:
    path  key  anchor  m  c
    fcs   fcs  A₀      1  0
  anchors:
    anchor  Δtₖ      τₖ    scope  key
    A₀      Δt_base  0//1  —      —
    A₁      1//50    0//1  root   gnss
  grid:
    admissible: gcd(pool)/k, coarsest 1//50
    pool:
      `sample_times` at the root component, key `gnss`  period 1//50  ×1
    primes: 50 = 2·5²
      2   gnss period
      5²  gnss period
  output routes:
    inner → fcs/y_inner → fcs/inner/out
    outer → fcs/y_outer → fcs/outer/out
    gnss → gnss/out"""

const MULTIRATE_OUTPUTS = """
Outputs: execution order over 4 components
  component  stage 1  stage 2
  src        out      —
  fcs/inner  —        out
  gnss       —        out
  fcs/outer  —        out"""

const MULTIRATE_SCHEDULE = """
Schedule: 3 rows, 1 rate scope, hyperperiod 10 base ticks
  path       anchor  D   Φ  Δt     rates
  fcs/inner  A₀      1   0  0.002  fcs = Relative(1, 0) → inner = Relative(1, 0)
  fcs/outer  A₀      5   2  0.01   fcs = Relative(1, 0) → outer = Relative(5, 2)
  gnss       A₁      10  0  0.02   gnss = Absolute(1//50, 0//1)
  rate scopes:
    path  key  anchor  D  Φ
    fcs   fcs  A₀      1  0
  hyperperiod chart, 10 base ticks:
               0
    fcs/inner  ●●●●●●●●●●
    fcs/outer  ··●····●··
    gnss       ●·········"""

# The schedule's block of the same deployment's own form (D-471): the four
# frames' symbols, the seconds exact, and the chart under its frame tops.
const MULTIRATE_DEPLOYED_SCHEDULE = """
schedule: 3 rows, 1 rate scope, hyperperiod 10 base ticks
  Δt_base: 1//500, the coarsest admissible 1//50 divided by 10
  anchors:
    anchor  Δtₖ     τₖ    Dₖ  Φₖ
    A₀      1//500  0//1  1   0
    A₁      1//50   0//1  10  0
  components:
    path       anchor  m  c  D   Φ  Δt      τ
    fcs/inner  A₀      1  0  1   0  1//500  0//1
    fcs/outer  A₀      5  2  5   2  1//100  1//250
    gnss       A₁      1  0  10  0  1//50   0//1
  rate scopes:
    path  key  anchor  m  c  D  Φ  Δt      τ
    fcs   fcs  A₀      1  0  1  0  1//500  0//1
  chart, 10 columns of 1//500 s over 10 base ticks and 10 frames:
                0
    frame tops  ││││││││││
    fcs/inner   ●●●●●●●●●●
    fcs/outer   ··●····●··
    gnss        ●·········"""

# The schedule's block of a deployment's REPL form, from its heading to the
# line before the warnings, without the two spaces it is nested by.
function schedule_block(deployment)
    lines = split(plain(deployment), '\n')
    first_line = findfirst(startswith("  schedule:"), lines)
    last_line = findfirst(startswith("  warnings"), lines) - 1
    [chopprefix(line, "  ") for line in lines[first_line:last_line]]
end

function test_show()
    multirate = build(MultiRate())
    deployed = Deployment(multirate; Δt_frame = 1//500)
    pendulum = build(Pendulum())
    pendulum_deployed = Deployment(pendulum; Δt_frame = 1//100)
    group = anchored_group()

    @testset "the compact forms are one line with the counts (§9.2, D-257)" begin
        @test compact(multirate.structure) == "Structure(4 components, 1 anchor, 1 rate scope)"
        @test compact(pendulum.structure) == "Structure(1 component, no anchors, no rate scopes)"
        @test compact(multirate.outputs) == "Outputs(4 components)"
        @test compact(multirate.events) == "Events(no events over 4 components)"
        @test compact(build(Motor(1.0)).events) == "Events(1 event over 1 component)"
        @test compact(deployed.schedule) == "Schedule(3 rows, hyperperiod 10 base ticks)"
        @test compact(pendulum_deployed.schedule) == "Schedule(no rows)"
        @test compact(multirate) == "Build(4 components, activations: Float64)"
        # A second activation lists after the nominal one, whatever the dictionary's
        # order; on its own build, since the others print the shared one.
        activated = build(MultiRate())
        activation(activated, D8)
        @test compact(activated) == "Build(4 components, activations: Float64, $(D8))"
        @test compact(deployed) ==
              "Deployment(Δt_frame = 1//500, Δt_base = 1//500, h_max = 1//500, RK4())"
        for x in (multirate.structure, multirate.outputs, multirate.events, deployed.schedule,
                  multirate, deployed)
            @test !occursin('\n', compact(x))
            @test repr(x) == compact(x)
        end
    end

    @testset "Structure: the component, rate-scope and anchor tables (§9.2, D-257)" begin
        @test plain(multirate.structure) == MULTIRATE_STRUCTURE
        # The `m` and `c` columns are the fold's timing, row by row.
        for (entry, line) in zip(multirate.structure.components, split(MULTIRATE_STRUCTURE, '\n')[4:7])
            columns = split(line)
            @test columns[1] == entry.path && parse.(Int, columns[4:5]) == [entry.timing.m, entry.timing.c]
        end
        # The `A₀` row is always present, `Δt_base` symbolic and no declaring scope.
        @test occursin("\n    A₀      Δt_base  0//1  —      —", plain(multirate.structure))
        # A primitive at the root is the one component, at path `root`, with no
        # rate-scope block and its root input on the heading.
        text = plain(pendulum.structure)
        @test startswith(text, "Structure: 1 component, no anchors, no rate scopes; root inputs: u\n")
        @test occursin("\n    root  continuous  A₀      1  0  —\n", text)
        @test !occursin("rate scopes:", text)
        @test occursin("\n  anchors:\n    anchor  Δtₖ      τₖ    scope  key\n    A₀      Δt_base  0//1  —      —", text)
        @test count('\n', text) == 6
    end

    @testset "Structure: the grid report under the anchor table, and no block with no anchors (§9.2, D-466)" begin
        # Derived from the anchors, the grid block's lines re-indented under
        # `grid:`, between the anchor table and the routes.
        @test occursin("    A₁      1//50    0//1  root   gnss\n  grid:\n" *
                       "    admissible: gcd(pool)/k, coarsest 1//50\n", plain(multirate.structure))
        @test occursin("      5²  gnss period\n  output routes:\n", plain(multirate.structure))
        # A driving offset's repair rides its pool row, as in the refusals.
        text = plain(group.build.structure)
        @test occursin("\n  grid:\n    admissible: gcd(pool)/k, coarsest 1//1500\n    pool:\n" *
                       "      `sample_times` at the root component, key `a`  period 1//500  ×10\n" *
                       "      `sample_times` at the root component, key `b`  period 1//10   ×1\n" *
                       "      `sample_times` at the root component, key `b`  offset 1//150  ×3   " *
                       "declaring 3//500 or 1//125 keeps 1//500\n" *
                       "    primes: 1500 = 2²·3·5³\n", text)
        # No anchor, no block.
        @test !occursin("grid", plain(pendulum.structure))
        @test !occursin("grid", plain(build(routed_pair()).structure))
    end

    @testset "Structure: the root faces' routes, one line per route (§9.2, §13.7, D-257)" begin
        # After the anchors, each side's block: the face's bare name, then every
        # hop as `path/name`, ending at the terminal. The root input fans out
        # through `pair`'s face, so it prints one line per consumer; `pair`'s own
        # routes print nowhere.
        text = plain(build(routed_pair()).structure)
        @test endswith(text, "\n  anchors:\n" *
                             "    anchor  Δtₖ      τₖ    scope  key\n" *
                             "    A₀      Δt_base  0//1  —      —\n" *
                             "  input routes:\n" *
                             "    u → pair/u → pair/a/e\n" *
                             "    u → pair/u → pair/b/e\n" *
                             "  output routes:\n" *
                             "    y → pair/y → pair/a/out")
        # A root face fanned out at the root level itself prints each route once.
        @test endswith(plain(build(FannedLoops(2)).structure),
                       "\n  input routes:\n" *
                       "    ref → loops/l1/ref → loops/l1/sum/a\n" *
                       "    ref → loops/l2/ref → loops/l2/sum/a")
        # A side with no root face prints no block.
        @test !occursin("input routes:", plain(multirate.structure))
        @test !occursin("routes:", plain(pendulum.structure))
    end

    @testset "Structure: an input route ending at a pinning consumer is marked with its cause (§9.2, §13.7, D-468)" begin
        # One root input fanned out to a tolerant gain, a discrete consumer and a
        # `Pinned` entry, a second read by the tolerant gain alone: each mark
        # names its consumer's cause, in one column after the widest route, and
        # an unpinned route carries none.
        text = plain(build(pinned_fanout()).structure)
        @test endswith(text, "\n  input routes:\n" *
                             "    in → g/e\n" *
                             "    in → acc/e  pinned by tier\n" *
                             "    in → p/e    pinned by declaration\n" *
                             "    free → h/e")
        # A primitive root prints no routes, so its pin shows in no mark.
        @test !occursin("pinned", plain(build(PinnedGain()).structure))
        @test !occursin("pinned", plain(build(routed_pair()).structure))
    end

    @testset "Outputs: the execution order with each stage's ports (§9.2, D-257, D-261)" begin
        @test plain(multirate.outputs) == MULTIRATE_OUTPUTS
        # Inside the `Build` the same table, indented, and under it the one
        # feedthrough edge, `fcs/outer`'s, fed by `gnss`'s stage-2 port;
        # `fcs/inner` and `gnss` read `src.out`, a stage-1 port, so they add none.
        text = plain(multirate)
        @test occursin("\n" * join("  " .* split(MULTIRATE_OUTPUTS, '\n'), "\n") * "\n", text)
        @test occursin("\n  feedthrough: gnss/out → fcs/outer/in\n", text)
    end

    @testset "Events: one row per declaring component (§9.2, D-257)" begin
        @test plain(multirate.events) == "Events: no events over 4 components"
        @test plain(build(Motor(1.0)).events) ==
              "Events: 1 event over 1 component\n" *
              "  component  events                  bundle\n" *
              "  root       start => non_localized  (x, m, u, y, t)"
        @test occursin("\n  Events: 1 event over 1 component\n" *
                       "    component  events             bundle\n" *
                       "    root       wrap => localized  (x, y, t)\n", plain(build(Sawtooth(1.0))))
    end

    @testset "Schedule: the rows and the hyperperiod chart (§9.2, D-257)" begin
        @test plain(deployed.schedule) == MULTIRATE_SCHEDULE
        lines = split(plain(deployed.schedule), '\n')
        @test lines[end-2:end] == ["    fcs/inner  ●●●●●●●●●●",
                                   "    fcs/outer  ··●····●··",
                                   "    gnss       ●·········"]
        # The gate, computed here: `●` exactly where `(k − Φ) % D == 0`.
        rows = deployed.schedule.rows
        hyperperiod = lcm([row.D for row in rows])
        @test hyperperiod == 10
        for (row, line) in zip(rows, lines[end-2:end])
            chart = collect(last(split(line)))
            @test length(chart) == hyperperiod
            @test [k for k in 0:hyperperiod-1 if chart[k+1] == '●'] ==
                  [k for k in 0:hyperperiod-1 if (k - row.Φ) % row.D == 0]
        end
        # The guard is binary: past 100 base ticks the chart's place holds one line.
        text = plain(group.schedule)
        @test startswith(text, "Schedule: 2 rows, hyperperiod 150 base ticks\n")
        @test endswith(text, "\n  hyperperiod: 150 base ticks, chart omitted")
        @test !occursin("●", text) && !occursin("hyperperiod chart", text)
        # Two coprime periods past 2^40 base ticks: a hyperperiod past `Int`,
        # printed whole, and the deployment's plain form whole too.
        coprime = Deployment(build(Group((; a = TickCounter(), b = TickCounter());
                                         sample_times = (; a = Relative(2^40 + 15),
                                                           b = Relative(2^40 + 61))));
                             Δt_frame = 1)
        hyperperiod = lcm(big(2^40 + 15), big(2^40 + 61))
        @test hyperperiod > typemax(Int)
        @test compact(coprime.schedule) == "Schedule(2 rows, hyperperiod $hyperperiod base ticks)"
        @test endswith(plain(coprime.schedule),
                       "\n  hyperperiod: $hyperperiod base ticks, chart omitted")
        @test occursin("\n  schedule: 2 rows, hyperperiod $hyperperiod base ticks\n", plain(coprime))
        @test last(schedule_block(coprime)) ==
              "  chart omitted: $hyperperiod columns of 1//1 s over $hyperperiod base ticks " *
              "and $hyperperiod frames"
        # No rows: the heading alone, no chart line at all.
        @test plain(pendulum_deployed.schedule) == "Schedule: no rows"
        # A hyperperiod of one base tick takes the singular, in both forms and
        # on the chart's heading.
        single_tick = Deployment(build(TickCounter()); Δt_frame = 1//10)
        @test compact(single_tick.schedule) == "Schedule(1 row, hyperperiod 1 base tick)"
        @test split(plain(single_tick.schedule), '\n')[[1, 4]] ==
              ["Schedule: 1 row, hyperperiod 1 base tick", "  hyperperiod chart, 1 base tick:"]
        @test schedule_block(single_tick)[1] == "schedule: 1 row, hyperperiod 1 base tick"
    end

    @testset "Build: the summary and its parts (§9.2, D-257)" begin
        text = plain(multirate)
        @test startswith(text, "Build: 4 components (1 continuous, 3 discrete); activations: Float64; no warnings\n")
        @test occursin("\n" * join("  " .* split(MULTIRATE_STRUCTURE, '\n'), "\n") * "\n", text)
        @test endswith(text, "\n  Events: no events over 4 components\n  warnings: none")
        # The feedthrough line lists every edge, consumers in execution order,
        # or `none`.
        @test occursin("\n  feedthrough: sum/e → ctl/e, ctl/out → plant/u\n", plain(build(feedback_model())))
        text = plain(pendulum)
        @test startswith(text, "Build: 1 component (1 continuous, 0 discrete); activations: Float64; no warnings\n")
        @test occursin("\n  feedthrough: none\n", text)
        # A build with a warning names it on the heading and lists its logline.
        warned = @test_logs (:warn, r"^EmptyFaceSelection") build(SelectedNothing(Gain(2.0), Gain(3.0)))
        text = plain(warned)
        @test startswith(text, "Build: 2 components (2 continuous, 0 discrete); activations: Float64; 1 warning\n")
        @test endswith(text, "\n  warnings:\n    " * logline(only(warnings(warned))))
    end

    @testset "Deployment: the parameters, the schedule's block and the warnings, with no grid block (§9.2, D-257, D-466, D-471)" begin
        text = plain(deployed)
        @test startswith(text, "Deployment: Δt_frame = 1//500, Δt_base = 1//500, h_max = 1//500, " *
                               "RK4(); firing_budget = 4, localization_tol = 1.0e-6, " *
                               "localization_budget = 8, attempt_budget = 7\n" *
                               "  steps per frame: 1\n" *
                               "  build: Build(4 components, activations: Float64)\n")
        # The warnings follow the schedule directly: the grid report is the
        # structure's to print, with or without an anchor.
        @test endswith(text, "\n" * join("  " .* split(MULTIRATE_DEPLOYED_SCHEDULE, '\n'), "\n") *
                             "\n  warnings: none")
        @test !occursin("grid:", text)
        # The block is the deployment's own: the `Schedule`'s lines, with their
        # float `Δt` and their rate chains, are not nested in it.
        @test !occursin("Schedule:", text) && !occursin("0.002", text) && !occursin("Relative", text)
        # An advisory still carries the block, as its own message's lines.
        text = plain(group)
        @test occursin("    chart omitted: 150 columns of 1//1500 s over 150 base ticks and 150 frames\n" *
                       "  warnings:\n    GridUtilization: Δt_base derived as 1//1500 s: the grid is 3× finer", text)
        @test !occursin("\n  grid:", text)
        text = plain(pendulum_deployed)
        @test endswith(text, "\n  build: Build(1 component, activations: Float64)\n  schedule: no rows\n" *
                             "  warnings: none")
    end

    @testset "Deployment: each row under the four frames' symbols, the seconds exact (§9.2, D-464, D-471)" begin
        # An anchor off the origin, with a member off its own: every pair of the
        # two tables differs from its neighbours, so no column stands for another.
        nested = build(Group((; g = Group((; a = TickCounter(), b = TickCounter());
                                          sample_times = (; a = Relative(3, 1), b = Relative(2))));
                             sample_times = (; g = Absolute(1//50, 1//100))))
        block = schedule_block(Deployment(nested; Δt_frame = 1//100, Δt_base = 1//200))
        @test block[1:12] == ["schedule: 2 rows, 1 rate scope, hyperperiod 24 base ticks",
                              "  Δt_base: 1//200, the coarsest admissible 1//100 divided by 2",
                              "  anchors:",
                              "    anchor  Δtₖ     τₖ      Dₖ  Φₖ",
                              "    A₀      1//200  0//1    1   0",
                              "    A₁      1//50   1//100  4   2",
                              "  components:",
                              "    path  anchor  m  c  D   Φ  Δt     τ",
                              "    g/a   A₁      3  1  12  6  3//50  3//100",
                              "    g/b   A₁      2  0  8   2  1//25  1//100",
                              "  rate scopes:",
                              "    path  key  anchor  m  c  D  Φ  Δt     τ"]
        @test block[13] == "    g     g    A₁      1  0  4  2  1//50  1//100"
        # The composition law, read off the printed cells (D-464): `D = m·Dₖ`,
        # `Φ = Φₖ + c·Dₖ`, `Δt = D·Δt_base` and `τ = Φ·Δt_base`.
        (Dk, Φk) = parse.(Int, split(block[6])[4:5])
        for line in block[9:10]
            (m, c, D, Φ) = parse.(Int, split(line)[3:6])
            @test (D, Φ) == (m * Dk, Φk + c * Dk)
            @test split(line)[7:8] == [repr(D * 1//200), repr(Φ * 1//200)]
        end
        # Three base ticks of 1//10: the deployment prints the period exact,
        # where the schedule's row holds a float that is not the nearest to it.
        thirds = Deployment(build(Group((; a = TickCounter()); sample_times = (; a = Relative(3))));
                            Δt_frame = 1//10)
        @test schedule_block(thirds)[7] == "    a     A₀      3  0  3  0  3//10  0//1"
        @test occursin("0.30000000000000004", plain(thirds.schedule))
        @test !occursin("0.30000000000000004", plain(thirds))
        # A base tick coarser than the frame: the anchors' counts are in base
        # ticks, never in the lattices' unit.
        coarse = schedule_block(Deployment(multirate; Δt_frame = 1//500, Δt_base = 1//100))
        @test coarse[2] == "  Δt_base: 1//100, the coarsest admissible 1//50 divided by 2"
        @test coarse[5:6] == ["    A₀      1//100  0//1  1   0", "    A₁      1//50   0//1  2   0"]
        @test coarse[9:11] == ["    fcs/inner  A₀      1  0  1  0  1//100  0//1",
                               "    fcs/outer  A₀      5  2  5  2  1//20   1//50",
                               "    gnss       A₁      1  0  2  0  1//50   0//1"]
        # A rate scope with no discrete member: the anchors and the scope's
        # row, no component table and no chart.
        inner = Group((; c = Plant()); input_wires = ("in" => "c/u",))
        scoped = build(Group((; g = inner); input_wires = ("in" => "g/in",),
                             sample_times = (; g = Relative(2))))
        @test schedule_block(Deployment(scoped; Δt_frame = 1//100)) ==
              ["schedule: no rows, 1 rate scope",
               "  anchors:",
               "    anchor  Δtₖ     τₖ    Dₖ  Φₖ",
               "    A₀      1//100  0//1  1   0",
               "  rate scopes:",
               "    path  key  anchor  m  c  D  Φ  Δt     τ",
               "    g     g    A₀      2  0  2  0  1//50  0//1"]
        # Two rate scopes on two anchors, each off `(1, 0)`: a scope's row
        # takes its own `(m, c)`, never its neighbour's.
        two = build(Group((; g = Group((; a = TickCounter()); sample_times = (; a = Relative(2))),
                             h = Group((; b = TickCounter()); sample_times = (; b = Relative(1))));
                          sample_times = (; g = Relative(3, 1), h = Absolute(1//25, 1//50))))
        @test schedule_block(Deployment(two; Δt_frame = 1//100))[12:14] ==
              ["    path  key  anchor  m  c  D  Φ  Δt      τ",
               "    g     g    A₀      3  1  3  1  3//100  1//100",
               "    h     h    A₁      1  0  4  2  1//25   1//50"]
        # A period whose seconds leave `Int`: the product is taken wide.
        wide = Deployment(build(Group((; a = TickCounter()); sample_times = (; a = Relative(2^40 + 15))));
                          Δt_frame = (2^31 - 1)//2^31)
        @test split(schedule_block(wide)[7])[7] == repr(big(2^40 + 15) * ((2^31 - 1)//2^31))
        @test_throws OverflowError (2^40 + 15) * ((2^31 - 1)//2^31)
        # A discrete primitive at the root reads `root`, in the table and on
        # the chart, whose one column is a base tick and a frame top.
        @test schedule_block(Deployment(build(TickCounter()); Δt_frame = 1//10))[5:end] ==
              ["  components:",
               "    path  anchor  m  c  D  Φ  Δt     τ",
               "    root  A₀      1  0  1  0  1//10  0//1",
               "  chart, 1 column of 1//10 s over 1 base tick and 1 frame:",
               "                0",
               "    frame tops  │",
               "    root        ●"]
    end

    @testset "Deployment: the base tick against the coarsest admissible one, where the structure has anchors (§9.2, D-466, D-471)" begin
        admissible(deployment) = schedule_block(deployment)[2]
        # A tenth of the coarsest, which the structure's grid block names.
        @test admissible(deployed) == "  Δt_base: 1//500, the coarsest admissible 1//50 divided by 10"
        @test occursin("admissible: gcd(pool)/k, coarsest 1//50", plain(multirate.structure))
        # The coarsest itself drops the clause, given or derived.
        @test admissible(Deployment(multirate; Δt_frame = 1//50, Δt_base = 1//50)) ==
              "  Δt_base: 1//50, the coarsest admissible"
        @test admissible(group) == "  Δt_base: 1//1500, the coarsest admissible"
        # An offset sets the coarsest below every period: `gcd(1//50, 1//100)`.
        nested = build(Group((; g = Group((; a = TickCounter()); sample_times = (; a = Relative(2))));
                             sample_times = (; g = Absolute(1//50, 1//100))))
        @test admissible(Deployment(nested; Δt_frame = 1//100, Δt_base = 1//300)) ==
              "  Δt_base: 1//300, the coarsest admissible 1//100 divided by 3"
        # No anchors: every base tick is admissible, and the block has no line.
        thirds = Deployment(build(Group((; a = TickCounter()); sample_times = (; a = Relative(3))));
                            Δt_frame = 1//10)
        @test admissible(thirds) == "  anchors:"
        @test !occursin("coarsest admissible", plain(thirds))
    end

    @testset "Deployment: the chart against the frame tops, one column per exact unit over the joint period (§9.2, §10.5, D-471)" begin
        chart(deployment) = (block = schedule_block(deployment);
                             block[findfirst(startswith("  chart"), block):end])
        # A frame of five base ticks: a column is a base tick, and the frame
        # tops' row marks every fifth.
        @test chart(Deployment(multirate; Δt_frame = 1//100, Δt_base = 1//500)) ==
              ["  chart, 10 columns of 1//500 s over 10 base ticks and 2 frames:",
               "                0",
               "    frame tops  │    │",
               "    fcs/inner   ●●●●●●●●●●",
               "    fcs/outer   ··●····●··",
               "    gnss        ●·········"]
        # Frame tops between base ticks: the unit is 1 ms, a base tick is two
        # columns and a frame three, and the pattern closes at 60 columns, six
        # hyperperiods and twenty frames.
        between = Deployment(multirate; Δt_frame = 3//1000, Δt_base = 1//500)
        lines = chart(between)
        @test lines[1] == "  chart, 60 columns of 1//1000 s over 30 base ticks and 20 frames:"
        @test lines[2] == "                0         10        20        30        40        50"
        # A row's 60 marks after its label, the blanks `show` strips restored.
        marks(line, label) = collect(rpad(chopprefix(line, "    " * rpad(label, 10) * "  "), 60))
        @test [k for k in 0:59 if marks(lines[3], "frame tops")[k+1] == '│'] == collect(0:3:57)
        @test all(mark in ('│', ' ') for mark in marks(lines[3], "frame tops"))
        # The gate, computed here: `●` at a base tick where `(n − Φ) % D == 0`,
        # `·` at every other base tick, blank off the base grid.
        for (row, line) in zip(between.schedule.rows, lines[4:6])
            cells = marks(line, row.path)
            @test [k for k in 0:59 if cells[k+1] == '●'] ==
                  [k for k in 0:2:59 if (k ÷ 2 - row.Φ) % row.D == 0]
            @test [k for k in 0:59 if cells[k+1] == ' '] == collect(1:2:59)
        end
        # A base tick coarser than the frame: every column is a frame top, and
        # a base tick falls on every fifth.
        @test chart(Deployment(multirate; Δt_frame = 1//500, Δt_base = 1//100)) ==
              ["  chart, 50 columns of 1//500 s over 10 base ticks and 50 frames:",
               "                0         10        20        30        40",
               "    frame tops  " * "│"^50,
               "    fcs/inner   ●    ●    ●    ●    ●    ●    ●    ●    ●    ●",
               "    fcs/outer   ·    ·    ●    ·    ·    ·    ·    ●    ·    ·",
               "    gnss        ●    ·    ●    ·    ●    ·    ●    ·    ●    ·"]
        # The guard is binary, at 100 columns: the chart prints whole at 100
        # and its place holds one line at 101.
        ticking(K) = build(Group((; a = TickCounter()); sample_times = (; a = Relative(K))))
        @test chart(Deployment(ticking(100); Δt_frame = 1)) ==
              ["  chart, 100 columns of 1//1 s over 100 base ticks and 100 frames:",
               "                " * join(rpad(string(k), 10) for k in 0:10:80) * "90",
               "    frame tops  " * "│"^100,
               "    a           ●" * "·"^99]
        @test chart(Deployment(ticking(101); Δt_frame = 1)) ==
              ["  chart omitted: 101 columns of 1//1 s over 101 base ticks and 101 frames"]
        # The guard counts the joint period's columns, not the hyperperiod's
        # base ticks: one base tick, and a frame of 150.
        @test chart(Deployment(ticking(1); Δt_frame = 3//2, Δt_base = 1//100)) ==
              ["  chart omitted: 150 columns of 1//100 s over 150 base ticks and 1 frame"]
        # Nor the joint period's base ticks: 51 of them, on 102 columns.
        @test chart(Deployment(ticking(51); Δt_frame = 1//2, Δt_base = 1)) ==
              ["  chart omitted: 102 columns of 1//2 s over 51 base ticks and 102 frames"]
        # A label wider than the frame tops' sets the chart's first column.
        long = build(Group((; a_very_long_name = TickCounter());
                           sample_times = (; a_very_long_name = Relative(2))))
        @test chart(Deployment(long; Δt_frame = 1//50, Δt_base = 1//100)) ==
              ["  chart, 2 columns of 1//100 s over 2 base ticks and 1 frame:",
               "                      0",
               "    frame tops        │",
               "    a_very_long_name  ●·"]
        # The `Schedule`'s own chart stays the tick chart over one hyperperiod,
        # whatever the frame.
        @test split(plain(between.schedule), '\n')[end-4:end] ==
              split(MULTIRATE_SCHEDULE, '\n')[end-4:end]
    end

    @testset "Deployment: the steps of an unsplit frame, and the components that split frames (§9.2, §10.5, D-449)" begin
        steps_line(deployment) = split(plain(deployment), '\n')[2]
        # A counter at 0.07 s in 0.1 s frames under a 25 ms bound: an unsplit
        # frame takes 4 steps, and the counter's ticks fall inside frames.
        rig = build(Group((; c = Plant(), a = TickCounter()); input_wires = ("in" => "c/u",),
                          sample_times = (; a = Absolute(7//100))))
        @test steps_line(Deployment(rig; Δt_frame = 1//10, Δt_base = 1//100, h_max = 1//40)) ==
              "  steps per unsplit frame: 4; due instants of a split frames"
        # No bound: one step per unsplit frame.
        @test steps_line(Deployment(rig; Δt_frame = 1//10, Δt_base = 1//100)) ==
              "  steps per unsplit frame: 1; due instants of a split frames"
        # No discrete component: a bound that divides the frame, then one that
        # divides nothing, ⌈0.01/0.003⌉ = 4.
        @test steps_line(Deployment(pendulum; Δt_frame = 1//100, h_max = 1//400)) ==
              "  steps per frame: 4"
        @test steps_line(Deployment(pendulum; Δt_frame = 1//100, h_max = 3//1000)) ==
              "  steps per frame: 4"
        @test steps_line(pendulum_deployed) == "  steps per frame: 1"
        # Two components at the frame period, one offset by half a frame: only
        # the offset one splits, by its phase alone.
        offset = build(Group((; a = TickCounter(), b = TickCounter());
                             sample_times = (; a = Absolute(1//10, 1//20),
                                               b = Absolute(1//10))))
        @test steps_line(Deployment(offset; Δt_frame = 1//10, Δt_base = 1//20)) ==
              "  steps per unsplit frame: 1; due instants of a split frames"
        # Periods of 0.1 s and 0.10001 s in 20 ms frames: only the second splits,
        # by its period alone. With both offset, both are named in row order.
        long = build(Group((; a = TickCounter(), b = TickCounter());
                           sample_times = (; a = Absolute(1//10),
                                             b = Absolute(10001//100000))))
        @test steps_line(Deployment(long; Δt_frame = 1//50, Δt_base = 1//100000)) ==
              "  steps per unsplit frame: 1; due instants of b split frames"
        both = build(Group((; a = TickCounter(), b = TickCounter());
                           sample_times = (; a = Absolute(1//10, 1//100),
                                             b = Absolute(1//10, 1//100))))
        @test steps_line(Deployment(both; Δt_frame = 1//50, Δt_base = 1//100)) ==
              "  steps per unsplit frame: 1; due instants of a, b split frames"
    end

    @testset "the status's compact form is one line with the counts (§11.8, D-257)" begin
        @test compact(hand_status(malformed_record(0, 0, 0))) ==
              "FrameworkStatus(3 writers, no occurrences, unpaced)"
        @test compact(hand_status(malformed_record(21, 16, 5))) ==
              "FrameworkStatus(3 writers, 21 occurrences, unpaced)"
        paced = hand_status(malformed_record(0, 0, 0);
                            pacer = PacerStatus(2.0, 0.0, 0.0, 0, 0, 0.0, 3, 0.25))
        @test compact(paced) == "FrameworkStatus(3 writers, no occurrences, pace = 2.0)"
        for x in (hand_status(malformed_record(21, 16, 5)), paced)
            @test !occursin('\n', compact(x))
            @test repr(x) == compact(x)
        end
    end

    @testset "the status renders each writer, the pacer's line last (§11.8, §10.7)" begin
        # A quiet status: every writer's heading says so, and the device's alone
        # carries a task state and a heartbeat, the raw value and no verdict.
        @test plain(hand_status(malformed_record(0, 0, 0))) == QUIET_STATUS
        paced = hand_status(malformed_record(0, 0, 0);
                            pacer = PacerStatus(2.0, 0.5, 0.75, 1, 1, 0.5, 3, 0.25))
        @test last(split(plain(paced), '\n')) ==
              "  pacer: pace = 2.0, debt 0.5 s, peak 0.75 s, 1 overrun, 1 reanchor, " *
              "0.5 s forgiven, 3 waits, 0.25 s waited"

        # Under the cap, the kind's count line and every retained occurrence.
        lines = split(plain(hand_status(malformed_record(3, 3, 0))), '\n')
        @test lines[2] == "  device 1 (Parser): running, heartbeat 1.0e9"
        @test lines[3] == "    MalformedDatum: 3 occurrences"
        @test lines[4:6] == ["      " * logline(MalformedDatum("datum $k")) for k in 1:3]
        @test lines[7] == "  harness: no occurrences"
    end

    @testset "a writer × kind prints in full up to 25 occurrences, then count-only (§11.8, D-136)" begin
        @test STATUS_MAXLOG == 25
        # Total 30 with ten retained and none suppressed: occurrences 21–30 are
        # this boundary's, and the first five of them fill the cap.
        lines = split(plain(hand_status(malformed_record(30, 10, 0))), '\n')
        @test lines[3] == "    MalformedDatum: 30 occurrences"
        @test lines[4:8] == ["      " * logline(MalformedDatum("datum $k")) for k in 21:25]
        @test lines[9] == "  harness: no occurrences"

        # Far past the cap: the count line and this boundary's suppressed count
        # alone, no occurrence printed.
        lines = split(plain(hand_status(malformed_record(1482, 16, 100))), '\n')
        @test lines[3:5] == ["    MalformedDatum: 1482 occurrences",
                             "      100 suppressed this boundary",
                             "  harness: no occurrences"]

        # A live status renders the same way: the occurrence in full on the
        # snapshot whose delta carries it, its count line on every later one.
        sim = Simulation(two_root_inputs(); Δt_frame = 1//10)
        handle = attach!(sim, Pad("p"), Enumerated("a"))
        init!(sim, set(u = (a = 0.0, b = 0.0)))
        report!(handle, MalformedDatum("one"))       # folded at frame 1's top
        run!(sim; t_end = 0.5)
        first_frame, final = plain(logged(sim)[2].status), plain(latest(sim).status)
        rendered = logline(MalformedDatum("one"))
        @test occursin("\n    MalformedDatum: 1 occurrence\n      $rendered\n", first_frame)
        @test occursin("\n    MalformedDatum: 1 occurrence\n", final) && !occursin(rendered, final)
    end

    @testset "every REPL form ends without a newline and carries no trailing whitespace (D-257)" begin
        for x in (multirate.structure, multirate.outputs, multirate.events, deployed.schedule,
                  multirate, deployed, pendulum.structure, pendulum_deployed.schedule, pendulum,
                  pendulum_deployed, group.schedule, group, build(Motor(1.0)).events,
                  # blank columns at a row's end: frame tops between base ticks,
                  # and a base tick coarser than the frame
                  Deployment(multirate; Δt_frame = 3//1000, Δt_base = 1//500),
                  Deployment(multirate; Δt_frame = 1//500, Δt_base = 1//100),
                  hand_status(malformed_record(0, 0, 0)), hand_status(malformed_record(30, 10, 0)),
                  hand_status(malformed_record(1482, 16, 100)))
            text = plain(x)
            @test !endswith(text, '\n')
            @test all(line == rstrip(line) for line in split(text, '\n'))
        end
    end
    @testset "a bare port reads as its default face in every table (§9.2, D-437)" begin
        text = plain(build(bare_ports_world()))
        @test occursin("\n  feedthrough: plant/loop/scale/y → plant/loop/echo/u\n", text)
        @test occursin("    plant/loop/flow   y        —\n", text)
        @test occursin("      u → plant/u → plant/summer/u  pinned by tier\n", text)
        @test occursin("      total → plant/total → plant/summer/y\n", text)
        @test occursin("      ramp → ramp/y\n", text)
        @test !occursin(r"[a-z]/(\s|$)", text) && !occursin(r"[a-z]\.(\s|$)", text)
    end
end
