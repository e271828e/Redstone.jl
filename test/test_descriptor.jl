# The descriptor (§13.9, D-432): the value `descriptor` returns, encoded to
# JSON text, parsed back into generic dictionaries and validated against the
# schema of record, so that the bytes a client reads are what conforms; and the
# content beside it, read off the artifacts the sections mirror. JSON and
# JSONSchema are the suite's alone: the core encodes nothing.

using JSON, JSONSchema

const DESCRIPTOR_SCHEMA = Schema(JSON.parsefile(joinpath(pkgdir(Redstone), "src", "descriptor.json")))

# The round trip: the text a client would read, validated, with no `null` in it
# (the omission rule), returned parsed.
function round_trip(value)
    text = JSON.json(value)
    parsed = JSON.parse(text)
    @test JSONSchema.validate(DESCRIPTOR_SCHEMA, parsed) === nothing
    @test !occursin("null", text)
    parsed
end

# The structure section a carrier's `Structure` renders to, for comparison.
_structure_of(err) = Redstone._structure_section(err.structure)

# The node at `path`, and a face of it by name.
node_at(body, path) = only(node for node in body.structure.nodes if node.path == path)
face_of(node, side, name) = only(face for face in getfield(node, side) if face.name == name)

# One face of every kind in §13.9's table, with a `Pinned` one and a dotted root
# face: the constants pin their outputs, the gear is an enum, the phase a
# `Symbol`, `armed` a `Bool`, the terrain handle `stub` emits and the closure
# `fn` emits are opaque, and so is `dut`'s abstract `terrain` entry (D-433).
kinds_model() =
    Group((; i = Constant(Int8(0)), r = Constant(1//2), v = Constant(SVector(1.0, 2.0)),
             mat = Constant(SMatrix{2,2}(1.0, 2.0, 3.0, 4.0)), nt = Constant((a = 1.0, b = 2.0)),
             g = GearMode(), s = PhaseSelector(), p = PhaseReader(),
             stub = Constant(height_field(Terrain(h0 = 1.5))), dut = TerrainGain(),
             fn = Constant(let k = 2.0; x -> k * x end), tup = TupleOut(), free = FreeSizeIn(), pose = PoseOut());
          local_wires = ("s/phase" => "p/phase", "stub/out" => "dut/terrain", "v/out" => "free/v"),
          input_wires = ("dut.k" => "dut/k",))

# The junction aliases beside a junction over a user function, all fed by one
# constant: the first three carry their `const` as `alias`, the last none.
aliases_model() =
    Group((; k = Constant(1.0), sum = SumJunction{Float64, 2}(), pack = Pack{Float64, 2}(),
             diff = Junction{Float64, Float64, 2}(-));
          local_wires = ("k/out" => "sum/in1", "k/out" => "sum/in2", "k/out" => "pack/in1",
                         "k/out" => "pack/in2", "k/out" => "diff/in1", "k/out" => "diff/in2"))

function test_descriptor()
    @testset "every fixture's descriptor validates after the round trip and mirrors the artifacts (§13.9)" begin
        for model in (Plant(), fed(PinnedGain(), "e"), Vehicle(), FannedLoops(2), MultiRate(),
                      routed_pair(), TerrainRig(), KeyedGains(), GreekGains(), single(LateDoc()),
                      kinds_model(), aliases_model())
            built = build(model)
            value = descriptor(built)
            round_trip(value)
            @test keys(value) == (:format_version, :redstone_version, :kind, :build)
            @test value.format_version == (major = 1, minor = 0)
            @test value.redstone_version == string(pkgversion(Redstone))
            @test value.kind == "build"
            @test value == descriptor(built)
            nodes = value.build.structure.nodes
            # node order is the walk order, on both classes; a primitive root's
            # level row is no assembly
            @test [node.path for node in nodes if node.class == "leaf"] == paths(built.structure)
            @test [node.path for node in nodes if node.class == "assembly"] ==
                  [level.path for level in built.structure.levels if level.path ∉ paths(built.structure)]
            # every wire endpoint names a node, the level's own path included
            node_paths = Set(node.path for node in nodes)
            for node in nodes
                node.class == "assembly" || continue
                level = only(level for level in built.structure.levels if level.path == node.path)
                @test length(node.wires) == length(level.wires)
                @test allunique(wire.to for wire in node.wires)    # `to` keys the wire
                for wire in node.wires, endpoint in (wire.from, wire.to)
                    @test endpoint.path in node_paths
                end
            end
            # every node type has a `types` row, and each row is one type
            type_names = [row.name for row in value.build.structure.types]
            @test allunique(type_names)
            @test Set(node.type for node in nodes) == Set(type_names)
            # the outputs section mirrors the `Outputs`
            @test value.build.outputs.order == [built.outputs.components[ci].path for ci in built.outputs.order]
            @test [row.path for row in value.build.outputs.components] == paths(built.structure)
            @test [(row.stage1, row.stage2) for row in value.build.outputs.components] ==
                  [(String.(row.stage1), String.(row.stage2)) for row in built.outputs.components]
            # the root inputs mirror the structure's, typed
            @test [face.name for face in value.build.structure.root_inputs] ==
                  String.(built.structure.root_inputs)
            @test [face.type for face in value.build.structure.root_inputs] ==
                  string.(built.structure.root_types)
            # a clean build's warnings are an empty array, never omitted
            @test value.build.warnings == []
        end
    end

    @testset "a build's warnings ride the build body, encoded as diagnostics (§13.9, D-434)" begin
        built = @test_logs (:warn, r"^EmptyFaceSelection") build(SelectedNothing(Gain(2.0), Gain(3.0)))
        value = descriptor(built)
        round_trip(value)
        @test keys(value.build) == (:structure, :outputs, :warnings)
        @test [(d.kind, d.severity, d.path) for d in value.build.warnings] == [("EmptyFaceSelection", "warning", "g")]
        @test only(value.build.warnings).message == message(only(warnings(built)))
        # the deployment's embedded body carries them too
        deployed = descriptor(Deployment(built; h = 1//100))
        round_trip(deployed)
        @test deployed.deployment.build.warnings == value.build.warnings
    end

    @testset "a structure-step failure is a failure descriptor with the list alone (§13.9, D-434)" begin
        err = failure(() -> build(merged_failures()))
        value = descriptor(err)
        round_trip(value)
        @test keys(value) == (:format_version, :redstone_version, :kind, :failure)
        @test value.kind == "failure"
        body = value.failure
        @test keys(body) == (:policy, :diagnostics, :warnings)     # no structure before the step completes
        @test body.policy == "collected"
        @test length(body.diagnostics) == length(diagnostics(err))
        @test [d.kind for d in body.diagnostics] == [string(nameof(typeof(d))) for d in diagnostics(err)]
        @test [d.message for d in body.diagnostics] == message.(diagnostics(err))
        @test [d.path for d in body.diagnostics] == path.(diagnostics(err))
        @test all(d.severity == "error" for d in body.diagnostics)
        @test body.warnings == []
        # the unfed input marks its port; the unknown port marks nothing beyond its node
        unfed = only(d for d in body.diagnostics if d.kind == "UnconnectedInput")
        source = only(d for d in diagnostics(err) if d isa UnconnectedInput)
        @test unfed.marks == (ports = [(path = source.path, port = String(source.face))], wires = [])
        unknown = only(d for d in body.diagnostics if d.kind == "UnknownPort")
        @test !haskey(unknown, :marks) && !haskey(unknown, :function) && !haskey(unknown, :cycle)
    end

    @testset "a failure past the structure step carries the whole structure and the cycle as data (§13.8, §13.9, D-434)" begin
        # A real loop: the structure section is the one a clean build of the same
        # tree would give, and every cycle path names one of its nodes.
        model = feedback_model(feedback_port = "power")
        err = failure(() -> build(model))
        value = descriptor(err)
        round_trip(value)
        body = value.failure
        @test keys(body) == (:policy, :structure, :diagnostics, :warnings)
        @test body.policy == "collected"
        @test body.structure == _structure_of(err)
        node_paths = Set(node.path for node in body.structure.nodes)
        cycle = only(body.diagnostics).cycle
        d = only(diagnostics(err))
        @test cycle.members == d.members && all(m in node_paths for m in cycle.members)
        @test cycle.classification == "real" && cycle.dead == []
        @test cycle.traced == [(path = m, mode = string(t)) for (m, t) in d.traced]
        for wire in cycle.wires, endpoint in (wire.from, wire.to)
            @test endpoint.path in node_paths
            node = only(node for node in body.structure.nodes if node.path == endpoint.path)
            @test any(face.name == endpoint.port for face in vcat(node.inputs, node.outputs))
        end
        @test [(w.from.path * "/" * w.from.port, w.to.path * "/" * w.to.port) for w in cycle.wires] ==
              [(p, c) for (p, c) in d.wires]
        # An artificial loop with a dead hop and a sampled member.
        err = failure(() -> build(
            Group((m = Piecewise(), g1 = Gain(1.0), g2 = Gain(1.0));
                  local_wires = ("m/F" => "g2/e", "g2/out" => "m/g", "g1/out" => "m/v"),
                  input_wires = ("r" => "g1/e", "f" => "m/f"))))
        cycle = only(descriptor(err).failure.diagnostics).cycle
        @test cycle.classification == "artificial"
        @test cycle.dead == [(path = "m", input = "g", output = "F")]
        @test cycle.traced == [(path = "m", mode = "global"), (path = "g2", mode = "global")]
        round_trip(descriptor(err))
        # A member that throws ships the cluster unclassified: no `classification` key.
        err = failure(() -> build(Group((a = TypedGain(), b = TypedGain());
                                        local_wires = ("a/out" => "b/e", "b/out" => "a/e"))))
        cycle = only(descriptor(err).failure.diagnostics).cycle
        @test !haskey(cycle, :classification) && cycle.dead == [] && cycle.traced == []
        round_trip(descriptor(err))
    end

    @testset "a probe throw is fail-fast with the function and the cause's line (§13.2, §13.9, D-434)" begin
        err = failure(() -> build(single(Thrower())))
        value = descriptor(err)
        round_trip(value)
        body = value.failure
        @test body.policy == "fail-fast"
        @test haskey(body, :structure)
        d = only(body.diagnostics)
        @test d.kind == "UserCodeFraming" && d.path == "c" && d.var"function" == "y_state"
        @test occursin("\n  cause: boom", d.message)
        @test !haskey(d, :marks)
    end

    @testset "a wire type mismatch marks its consumer port and its wire (§13.9, D-434)" begin
        err = failure(() -> build(Group((a = FieldReader(), b = RealEntry());
                                        input_wires = ("in" => ("a/f", "b/u"),))))
        value = descriptor(err)
        round_trip(value)
        d = only(value.failure.diagnostics)
        @test d.kind == "WireTypeMismatch"
        @test d.marks == (ports = [(path = "a", port = "f")],
                          wires = [(from = (path = "", port = "in"), to = (path = "a", port = "f"))])
        @test !haskey(value.failure, :structure)
    end

    @testset "a service's carrier is a failure descriptor with the list alone (§13.9, D-434)" begin
        anchored_build = build(AnchoredBank((TickCounter(), TickCounter()), TickCounter()))
        err = failure(() -> Deployment(anchored_build; h = 1//500))
        value = descriptor(err)
        round_trip(value)
        @test value.failure.policy == "collected"
        @test !haskey(value.failure, :structure)
        @test [d.kind for d in value.failure.diagnostics] == ["DeploymentInvalid"]
    end

    @testset "the deployment envelope embeds the build body whole (§13.9)" begin
        built = build(MultiRate())
        value = descriptor(Deployment(built; h = 1//1000, N_base = 2))
        round_trip(value)
        @test keys(value) == (:format_version, :redstone_version, :kind, :deployment)
        @test value.kind == "deployment"
        @test keys(value.deployment) == (:build,)
        @test value.deployment.build == descriptor(built).build
        # a primitive root deploys too: one leaf node at the root, no wires
        primitive = descriptor(Deployment(build(Plant()); h = 1//100))
        round_trip(primitive)
        root = only(primitive.deployment.build.structure.nodes)
        @test root.path == "" && root.class == "leaf" && !haskey(root, :wires)
        @test !haskey(root, :field) && !haskey(root, :key)
    end

    @testset "the node carries its membership as field and key (§8.5, §13.9)" begin
        body = descriptor(build(KeyedGains())).build
        root = node_at(body, "")
        @test root.class == "assembly" && !haskey(root, :field) && !haskey(root, :key)
        keyed = node_at(body, "gains/a")
        @test keyed.field == "gains" && keyed.key == "a"
        tuple_element = node_at(body, "pair/1")
        @test tuple_element.field == "pair" && tuple_element.key == "1"
        transparent = node_at(descriptor(build(routed_pair())).build, "pair")
        @test transparent.field == "children" && transparent.key == "pair"
        component_field = node_at(descriptor(build(Vehicle())).build, "loop")
        @test component_field.field == "loop" && !haskey(component_field, :key)
        greek = node_at(descriptor(build(GreekGains())).build, "ωs/a")
        @test greek.field == "ωs" && greek.key == "a"
        # an assembly's faces are names alone, in the level's order, and its
        # wires are the level's, producer to consumer with full paths
        @test root.inputs == [(name = "u",)] && root.outputs == [(name = "y",)]
        @test root.wires[1] == (from = (path = "gains/a", port = "out"), to = (path = "gains/b", port = "e"))
        @test root.wires[3] == (from = (path = "", port = "u"), to = (path = "gains/a", port = "e"))
        @test root.wires[4] == (from = (path = "pair/1", port = "out"), to = (path = "", port = "y"))
        @test !haskey(keyed, :wires) && keyed.class == "leaf"
    end

    @testset "a leaf face carries its type, kind marker and pinned flag (§13.9)" begin
        body = descriptor(build(kinds_model())).build
        marker(path, name) = face_of(node_at(body, path), :outputs, name).kind
        @test marker("i", "out") == (kind = "integer",)
        @test marker("r", "out") == (kind = "number",)
        @test marker("v", "out") == (kind = "vector", shape = [2], element = (kind = "float",))
        @test marker("mat", "out") == (kind = "vector", shape = [2, 2], element = (kind = "float",))
        @test marker("nt", "out") == (kind = "struct", fields = ["a", "b"])
        @test marker("g", "gear") == (kind = "enum", values = ["up", "down"])
        @test marker("g", "y") == (kind = "float",)
        @test marker("s", "phase") == (kind = "symbol",)
        @test marker("p", "armed") == (kind = "boolean",)
        @test marker("stub", "out") == (kind = "opaque",)       # a handle, not isbits
        @test marker("fn", "out") == (kind = "opaque",)         # a closure with a capture
        @test marker("tup", "out") == (kind = "struct", fields = ["1", "2"])
        @test face_of(node_at(body, "free"), :inputs, "v").kind == (kind = "opaque",)   # size left free
        @test marker("pose", "pose") == (kind = "vector", shape = [3], element = (kind = "float",))   # a FieldVector
        @test face_of(node_at(body, "dut"), :inputs, "terrain").kind == (kind = "opaque",)
        # the pinned flag reads the declaration, and the type string is the leaf's
        @test face_of(node_at(body, "i"), :outputs, "out").pinned
        @test face_of(node_at(body, "i"), :outputs, "out").type == "Int8"
        @test !face_of(node_at(body, "p"), :inputs, "phase").pinned
        pinned_gain = node_at(descriptor(build(fed(PinnedGain(), "e"))).build, "c")
        @test face_of(pinned_gain, :inputs, "e") == (name = "e", type = "Float64", kind = (kind = "float",), pinned = true)
        # a root face may carry a dot (D-418): the endpoint carries it whole
        @test body.structure.root_inputs == [(name = "dut.k", type = "Float64", kind = (kind = "float",), pinned = false)]
        @test node_at(body, "").wires[end] == (from = (path = "", port = "dut.k"), to = (path = "dut", port = "k"))
    end

    @testset "a leaf node carries its tier and timing, and the structure its anchors and scopes (§9.1, §13.9)" begin
        body = descriptor(build(MultiRate())).build
        @test node_at(body, "gnss").tier == "discrete"
        @test node_at(body, "gnss").timing == (anchor = 1, m = 1, c = 0)
        @test node_at(body, "fcs/outer").timing == (anchor = 0, m = 5, c = 2)
        @test node_at(body, "src").tier == "continuous"
        @test !haskey(node_at(body, "fcs"), :tier) && !haskey(node_at(body, "fcs"), :timing)
        @test body.structure.anchors == [(T = (num = 1, den = 50), tau = (num = 0, den = 1), scope = "", key = "gnss")]
        @test body.structure.scopes == [(path = "fcs", key = "fcs", timing = (anchor = 0, m = 1, c = 0))]
    end

    @testset "a node carries its alias when a const binds its type, and the envelope admits a name (§13.9)" begin
        value = descriptor(build(aliases_model()))
        body = value.build
        @test node_at(body, "sum").alias == "Redstone.Blocks.SumJunction"
        @test node_at(body, "pack").alias == "Redstone.Blocks.Pack"
        @test !haskey(node_at(body, "diff"), :alias)    # a `Junction` over a user function
        @test !haskey(node_at(body, "k"), :alias)
        @test !haskey(node_at(body, ""), :alias)
        @test keys(node_at(body, "sum"))[end-5:end-3] == (:type, :alias, :signature)
        # `descriptor` never writes `name`; a writer outside the core may
        @test !haskey(value, :name)
        parsed = round_trip(value)
        parsed["name"] = "aliases"
        @test JSONSchema.validate(DESCRIPTOR_SCHEMA, parsed) === nothing
    end
    @testset "a type is described once, with its docstring and locations, and an instance by its summary (§13.9)" begin
        body = descriptor(build(Vehicle())).build
        rows = body.structure.types
        @test [row.name for row in rows] ==
              ["Main.RedstoneTests.Vehicle", "Main.RedstoneTests.SampledLoop", "Main.RedstoneTests.Plant",
               "Main.RedstoneTests.DiscreteAccumulator", "Main.RedstoneTests.Sum", "Main.RedstoneTests.Gain"]
        plant = only(row for row in rows if row.name == "Main.RedstoneTests.Plant")
        @test startswith(plant.docstring, "Damped second-order plant.")
        @test [getfield(location, :function) for location in plant.locations] == ["u_types", "y_types", "x_init"]
        @test all(endswith(location.file, "fixtures.jl") && location.line > 0 for location in plant.locations)
        @test plant.locations[3].line + 1 == plant.locations[1].line    # `x_init` is declared the line above `u_types`
        vehicle = only(row for row in rows if row.name == "Main.RedstoneTests.Vehicle")
        @test [getfield(location, :function) for location in vehicle.locations] == ["local_wires", "input_wires", "output_wires"]
        # a type with no docstring omits the field
        undocumented = only(row for row in descriptor(build(single(GearStateSource()))).build.structure.types
                            if row.name == "Main.RedstoneTests.GearStateSource")
        @test !haskey(undocumented, :docstring)
        # a type documented on a constructor first still reports its own docstring
        late = only(row for row in descriptor(build(single(LateDoc()))).build.structure.types
                    if row.name == "Main.RedstoneTests.LateDoc")
        @test late.docstring == "The type's own docstring, registered second."
        # an interpolated docstring joins its parts
        @test only(row for row in descriptor(build(single(Interpolated()))).build.structure.types
                   if row.name == "Main.RedstoneTests.Interpolated").docstring == "Cut at 80 characters."
        # the node's summary lists the inert fields alone, children left out
        @test node_at(body, "loop/plant").parameters ==
              [(name = "ω", value = "2.0"), (name = "ζ", value = "0.1"), (name = "q₀", value = "[0.0, 0.0]")]
        @test node_at(body, "loop").parameters == [(name = "ctl_rate", value = "Relative(1, 0)")]
        @test node_at(body, "").parameters == []
        @test node_at(body, "").signature == "Main.RedstoneTests.Vehicle"
        @test node_at(body, "loop").type == "Main.RedstoneTests.SampledLoop"
        # a long value is cut at 80 characters with an ellipsis
        long = Constant((; (Symbol(:p, i) => float(i) for i in 1:20)...))
        summary = only(node_at(descriptor(build(single(long))).build, "c").parameters)
        @test summary.name == "value" && length(summary.value) == 81 && endswith(summary.value, "…")
        @test summary.value == first(repr(long.value; context = (:compact => true, :limit => true)), 80) * "…"
    end
end
