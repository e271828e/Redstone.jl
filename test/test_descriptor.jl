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
          local_wires = ("s/phase" => "p/phase", "stub/y" => "dut/terrain", "v/y" => "free/v"),
          input_wires = ("dut.k" => "dut/k",))

# The junction aliases beside a junction over a user function, all fed by one
# constant: the first three carry their `const` as `alias`, the last none.
aliases_model() =
    Group((; k = Constant(1.0), sum = SumJunction{Float64, 2}(), pack = Pack{Float64, 2}(),
             diff = Junction{Float64, Float64, 2}(-));
          local_wires = ("k/y" => "sum/in1", "k/y" => "sum/in2", "k/y" => "pack/in1",
                         "k/y" => "pack/in2", "k/y" => "diff/in1", "k/y" => "diff/in2"))

# Two continuous entries a `Dual` tells apart from a stand-in scalar (D-468):
# `AbstractFloat` admits no `Dual` and pins its root input by declaration, and
# `Union{Float64, Dual}` admits one and pins nothing, where a scalar that is no
# `Dual` would pin it. Each is a lag on its one input.
struct FloatEntry <: AbstractComponent end
x_init(::FloatEntry) = 0.0
u_types(::FloatEntry) = (u = AbstractFloat,)
y_types(::FloatEntry) = (y = Float64,)
y_state(::FloatEntry, (; x)) = (y = x,)
x_deriv(::FloatEntry, (; x, u)) = u.u - x

struct DualUnionEntry <: AbstractComponent end
x_init(::DualUnionEntry) = 0.0
u_types(::DualUnionEntry) = (u = Union{Float64, ForwardDiff.Dual},)
y_types(::DualUnionEntry) = (y = Float64,)
y_state(::DualUnionEntry, (; x)) = (y = x,)
x_deriv(::DualUnionEntry, (; x, u)) = u.u - x

# A `Pinned` vector entry: the root input it pins keeps a type that is no `Float64`.
struct PinnedVectorEntry <: AbstractComponent end
x_init(::PinnedVectorEntry) = 0.0
u_types(::PinnedVectorEntry) = (u = Pinned{SVector{2,Float64}},)
y_types(::PinnedVectorEntry) = (y = Float64,)
y_state(::PinnedVectorEntry, (; x)) = (y = x,)
x_deriv(::PinnedVectorEntry, (; x, u)) = u.u[1] - x

# The fan-out over both, beside a concrete gain that fixes the type: `in` is
# pinned by `f`, and `loose` by nothing.
abstract_entries() =
    Group((; g = Gain(2.0), f = FloatEntry(), n = DualUnionEntry(), h = Gain(3.0));
          input_wires = ("in" => ("g/e", "f/u"), "loose" => ("h/e", "n/u")))

# The `@ref` pass (D-467): `RefOwner` exports `owned`, a macro and an operator,
# which `RefUser` brings in with the module's own name, and holds `Deep`, whose
# export `RefUser` does not see;
# `RefUser` exports its component and `exported_helper` and keeps `internal_helper`
# unexported. The docstring holds one link of each kind the pass reads, and
# the macro's and the operator's, which it leaves as written though exported.
module RefOwner
export owned, @owned_macro, ⊕
"A binding another module's docstring links to."
owned() = nothing
macro owned_macro(x) x end
⊕(a, b) = a + b
module Deep
export deep
deep() = nothing
end
end

module RefUser
using Redstone
import Redstone: u_types, y_types, x_init, y_state, x_deriv
using ..RefOwner
export Linked, exported_helper
exported_helper() = nothing
internal_helper() = nothing
"""
A component whose docstring links [`owned`](@ref), [`Linked`](@ref),
[`exported_helper`](@ref), [`RefOwner.owned`](@ref), [`internal_helper`](@ref),
[`missing_name`](@ref), [`exported_helper(x)`](@ref), [`owned`](@ref RefOwner.owned)
and [the owner](@ref), and the glossary's [state](@ref g-state), and
[`@owned_macro`](@ref), [`⊕`](@ref), [`RefOwner.Deep.deep`](@ref) and [`RefOwner`](@ref).
"""
struct Linked <: Redstone.AbstractComponent end
x_init(::Linked) = 0.0
y_types(::Linked) = (y = Float64,)
y_state(::Linked, (; x)) = (y = x,)
x_deriv(::Linked, (; x)) = -x
end

# One period whose denominator is 3 times the Mersenne prime 2^61 − 1: the trial
# division stops below it, so the cofactor is left whole and flagged (D-459).
unfactored_model() =
    Group((; c = TickCounter()); sample_times = (; c = Absolute(1//(3 * (2^61 - 1)))))

# A keyed scope over a container's bare field key and an explicit `Relative(1)`:
# chains the timings alone do not determine (§9.2, §13.9).
chained_model() =
    Group((; g = Group((; a = TickCounter(), b = TickCounter()); sample_times = (; children = Relative(2))),
             one = TickCounter());
          sample_times = (; g = Relative(3, 1), one = Relative(1)))

# --- a client of the file, for the parity check (D-467) ---------------------------
# What a client with no Julia derives from the parsed file, line by line as
# `show` prints it, compared as whitespace-split tokens: the layout is `show`'s
# own, and the facts are the file's. The printed side is read off `show`'s text
# by its headings, a grid pool row's label reduced to its scope and key.

tokens(line) = String.(split(line))
_rational_text(r) = string(r["num"] // r["den"])
_rational_of(r) = r["num"] // r["den"]
_digits(k, glyphs) = join(collect(glyphs)[d - '0' + 1] for d in string(k))
_anchor_text(k) = "A" * _digits(k, "₀₁₂₃₄₅₆₇₈₉")
_power_text(p) = p == 1 ? "" : _digits(p, "⁰¹²³⁴⁵⁶⁷⁸⁹")
_path_text(path) = isempty(path) ? "root" : path
_link_text(link) = haskey(link, "K") ? "$(link["key"]) = Relative($(link["K"]), $(link["phi"]))" :
                   "$(link["key"]) = Absolute($(_rational_text(link["dt"])), $(_rational_text(link["tau"])))"
_chain_text(links) = isempty(links) ? "—" : join(_link_text.(links), " → ")

# The lines under a two-space heading of a `show` text, up to the next heading.
function _block(lines, heading)
    i = findfirst(==("  " * heading), lines)
    i === nothing && return String[]
    j = something(findnext(line -> !startswith(line, "    "), lines, i + 1), length(lines) + 1)
    lines[i+1:j-1]
end

function printed_structure(structure)
    lines = split(sprint(show, MIME("text/plain"), structure), '\n')
    grid = map(_block(lines, "grid:")) do line
        m = match(r"^\s+`sample_times` at (?:the root component|`([^`]*)`), key `([^`]*)`(.*)$", line)
        m === nothing ? tokens(line) : [something(m.captures[1], ""); m.captures[2]; tokens(m.captures[3])]
    end
    (components = tokens.(_block(lines, "components:")[2:end]),
     scopes = tokens.(_block(lines, "rate scopes:")[2:end]),
     anchors = tokens.(_block(lines, "anchors:")[2:end]),
     grid = grid,
     inputs = tokens.(_block(lines, "input routes:")),
     outputs = tokens.(_block(lines, "output routes:")))
end

function client_structure(structure)
    nodes = Dict(node["path"] => node for node in structure["nodes"])
    levels = Dict(node["path"] => node for node in structure["nodes"] if node["class"] == "assembly")
    anchors = structure["anchors"]
    components = [tokens(join([_path_text(node["path"]), node["tier"], _anchor_text(node["timing"]["anchor"]),
                               string(node["timing"]["m"]), string(node["timing"]["c"]),
                               _chain_text(node["rates"])], " "))
                  for node in structure["nodes"] if node["class"] == "primitive"]
    scopes = [[_path_text(scope["path"]), scope["key"], _anchor_text(scope["timing"]["anchor"]),
               string(scope["timing"]["m"]), string(scope["timing"]["c"])] for scope in structure["scopes"]]
    anchor_rows = vcat([["A₀", "Δt_base", "0//1", "—", "—"]],
                       [[_anchor_text(k), _rational_text(anchor["dt"]), _rational_text(anchor["tau"]), _path_text(anchor["scope"]), anchor["key"]]
                        for (k, anchor) in enumerate(anchors)])
    # the grid report, its values and labels read through the anchor positions
    report, grid = Vector{String}[], structure["grid"]
    if haskey(grid, "admissible")
        admissible = _rational_of(grid["admissible"])
        push!(report, tokens("admissible: gcd(pool)/k, coarsest $admissible"), ["pool:"])
        labels = String[]
        for entry in grid["pool"]
            anchor = anchors[entry["anchor"]]
            row = [anchor["scope"], anchor["key"], entry["kind"],
                   _rational_text(entry["kind"] == "period" ? anchor["dt"] : anchor["tau"]), "×$(entry["factor"])"]
            haskey(entry, "alternatives") &&
                append!(row, tokens("declaring " * join(_rational_text.(entry["alternatives"]), " or ") *
                                    " keeps $(entry["factor"] * admissible)"))
            push!(report, row)
            push!(labels, "$(anchor["key"]) $(entry["kind"])")
        end
        powers = [get(row, "unfactored", false) ? "$(row["prime"]) unfactored" :
                  "$(row["prime"])$(_power_text(row["power"]))" for row in grid["primes"]]
        isempty(powers) || push!(report, tokens("primes: $(denominator(admissible)) = " * join(powers, "·")))
        for (row, power) in zip(grid["primes"], powers)
            push!(report, tokens(power * " " * join([labels[i] for i in row["suppliers"]], ", ")))
        end
    end
    # the routes, resolved over the wires as a client resolves them on load
    hop_text(endpoint) = "$(endpoint["path"])/$(endpoint["port"])"
    nested(path, level_path) = haskey(levels, path) && path != level_path
    function inward(level_path, port)
        routes = Vector{Any}[]
        for wire in levels[level_path]["wires"]
            (wire["from"]["path"], wire["from"]["port"]) == (level_path, port) || continue
            hop = wire["to"]
            nested(hop["path"], level_path) ?
                append!(routes, [pushfirst!(route, hop) for route in inward(hop["path"], hop["port"])]) :
                push!(routes, Any[hop])
        end
        routes
    end
    function outward(level_path, port)
        hop = only(wire["from"] for wire in levels[level_path]["wires"]
                   if (wire["to"]["path"], wire["to"]["port"]) == (level_path, port))
        nested(hop["path"], level_path) ? pushfirst!(outward(hop["path"], hop["port"]), hop) : Any[hop]
    end
    marks = Dict((consumer["path"], consumer["port"]) =>
                     (nodes[consumer["path"]]["tier"] == "discrete" ? "pinned by tier" : "pinned by declaration")
                 for row in structure["root_inputs"] for consumer in row["pinned_by"])
    inputs, outputs = Vector{String}[], Vector{String}[]
    if haskey(levels, "")
        root_wires = levels[""]["wires"]
        for face in unique([wire["from"]["port"] for wire in root_wires if wire["from"]["path"] == ""]),
            route in inward("", face)
            mark = get(marks, (last(route)["path"], last(route)["port"]), "")
            push!(inputs, tokens(join([face; hop_text.(route)], " → ") * " " * mark))
        end
        for face in [wire["to"]["port"] for wire in root_wires if wire["to"]["path"] == ""]
            push!(outputs, tokens(join([face; hop_text.(outward("", face))], " → ")))
        end
    end
    (components = components, scopes = scopes, anchors = anchor_rows, grid = report,
     inputs = inputs, outputs = outputs)
end

# The declaring rows of the events table.
client_events(events) =
    [tokens(join([_path_text(row["path"]),
                  join(("$(event["name"]) => $(event["policy"])" for event in row["events"]), ", "),
                  isempty(row["bundle"]) ? "—" : "(" * join(row["bundle"], ", ") * ")"], " "))
     for row in events["components"] if !isempty(row["events"])]

# The deployment's first two lines: the parameters, then the steps per frame,
# a count or, under a proposing method, a range, and the rows whose due instants
# split frames.
function client_deployment(body)
    exact(key) = _rational_of(body[key])
    parameters = "Δt_frame = $(repr(exact("dt_frame"))), Δt_base = $(repr(exact("dt_base"))), " *
                 "h_max = $(repr(exact("h_max"))), " *
                 (haskey(body, "h_min") ? "h_min = $(repr(exact("h_min"))), " : "") * body["algorithm"]["text"]
    first_line = "Deployment: " * parameters * "; firing_budget = $(body["firing_budget"]), " *
                 "localization_tol = $(repr(body["localization_tol"])), " *
                 "localization_budget = $(body["localization_budget"]), attempt_budget = $(body["attempt_budget"])"
    ratio = exact("dt_frame") / exact("h_max")
    steps = cld(numerator(ratio), denominator(ratio))
    floor_ratio = body["algorithm"]["proposes"] ? exact("dt_frame") / exact("h_min") : nothing
    steps_text = floor_ratio === nothing ? string(steps) :
                 "$steps to $(max(steps, fld(numerator(floor_ratio), denominator(floor_ratio)))), as proposed"
    splitting = [_path_text(row["path"]) for row in body["schedule"]["rows"]
                 if !isinteger(row["phi"] * exact("dt_base") / exact("dt_frame")) ||
                    !isinteger(row["D"] * exact("dt_base") / exact("dt_frame"))]
    [first_line,
     "  " * (isempty(splitting) ? "steps per frame: $steps_text" :
             "steps per unsplit frame: $steps_text; due instants of " * join(splitting, ", ") * " split frames")]
end

# The schedule's block as the deployment prints it (D-471). The tables come
# back as token lines: the heading with the hyperperiod over the rows' `D`, the
# anchors' rows, and the component and rate-scope rows under the four frames'
# symbols, each `Δt` and `τ` its count times `dt_base`, exact. The chart comes
# back as its heading and each row's label and marks: one column per gcd of the
# two periods over the joint period, the frame tops first, and no row past the
# guard. No rows is no chart.
function client_schedule(body)
    dt_base, dt_frame = _rational_of(body["dt_base"]), _rational_of(body["dt_frame"])
    structure, schedule = body["build"]["structure"], body["schedule"]
    nodes = Dict(node["path"] => node for node in structure["nodes"])
    rows, scopes = schedule["rows"], schedule["scopes"]
    count_text(n, noun) = n == 1 ? "1 $noun" : "$n $(noun)s"
    hyperperiod = lcm(BigInt[row["D"] for row in rows])
    lines = [tokens("schedule: " * (isempty(rows) ? "no rows" : count_text(length(rows), "row")) *
                    (isempty(scopes) ? "" : ", " * count_text(length(scopes), "rate scope")) *
                    (isempty(rows) ? "" : ", hyperperiod $hyperperiod base ticks"))]
    isempty(rows) && isempty(scopes) && return lines, nothing
    push!(lines, ["anchors:"], ["anchor", "Δtₖ", "τₖ", "Dₖ", "Φₖ"],
          ["A₀", repr(dt_base), "0//1", "1", "0"])
    for (k, (anchor, counts)) in enumerate(zip(structure["anchors"], schedule["anchors"]))
        push!(lines, [_anchor_text(k), _rational_text(anchor["dt"]), _rational_text(anchor["tau"]),
                      string(counts["D"]), string(counts["phi"])])
    end
    timing_cells(timing, row) =
        [_anchor_text(timing["anchor"]), string(timing["m"]), string(timing["c"]),
         string(row["D"]), string(row["phi"]), repr(row["D"] * dt_base), repr(row["phi"] * dt_base)]
    if !isempty(rows)
        push!(lines, ["components:"], ["path", "anchor", "m", "c", "D", "Φ", "Δt", "τ"])
        for row in rows
            push!(lines, [_path_text(row["path"]); timing_cells(nodes[row["path"]]["timing"], row)])
        end
    end
    if !isempty(scopes)
        # a scope's `(m, c)` by its path and key, the file stating no order
        scope_timing = Dict((scope["path"], scope["key"]) => scope["timing"] for scope in structure["scopes"])
        push!(lines, ["rate", "scopes:"], ["path", "key", "anchor", "m", "c", "D", "Φ", "Δt", "τ"])
        for row in scopes
            push!(lines, [_path_text(row["path"]); row["key"];
                          timing_cells(scope_timing[(row["path"], row["key"])], row)])
        end
    end
    isempty(rows) && return lines, nothing
    unit = gcd(dt_frame, dt_base)
    frame, base = Int(dt_frame / unit), Int(dt_base / unit)
    span = lcm(hyperperiod * base, big(frame))
    extent = "$(count_text(span, "column")) of $(repr(unit)) s over " *
             "$(count_text(span ÷ base, "base tick")) and $(count_text(span ÷ frame, "frame"))"
    span > 100 && return lines, (heading = "chart omitted: " * extent, rows = Tuple{String,String}[])
    columns = 0:Int(span)-1
    chart_rows = [("frame tops", String(rstrip(join(k % frame == 0 ? '│' : ' ' for k in columns))))]
    for row in rows
        push!(chart_rows,
              (_path_text(row["path"]),
               String(rstrip(join(k % base != 0 ? ' ' : (k ÷ base - row["phi"]) % row["D"] == 0 ? '●' : '·'
                                  for k in columns)))))
    end
    lines, (heading = "chart, " * extent * ":", rows = chart_rows)
end

function test_descriptor()
    @testset "every fixture's descriptor validates after the round trip and mirrors the artifacts (§13.9)" begin
        for model in (Plant(), fed(PinnedGain(), "e"), Vehicle(), FannedLoops(2), MultiRate(),
                      routed_pair(), TerrainRig(), KeyedGains(), GreekGains(), single(LateDoc()),
                      kinds_model(), aliases_model(), pinned_fanout(), abstract_entries(),
                      unfactored_model(), chained_model(), Motor(1.0), single(RefUser.Linked()))
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
            @test [node.path for node in nodes if node.class == "primitive"] == paths(built.structure)
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
            # the events section mirrors the `Events`, one row per primitive (D-467)
            @test [row.path for row in value.build.events.components] == paths(built.structure)
            @test [[event.name for event in row.events] for row in value.build.events.components] ==
                  [String.(collect(keys(row.policies))) for row in built.events.components]
            # each primitive node carries its chain as the component row holds it
            @test [length(node.rates) for node in nodes if node.class == "primitive"] ==
                  [length(entry.rates) for entry in built.structure.components]
            # the grid's positions count from 1 and name rows that exist (D-467)
            grid = value.build.structure.grid
            @test all(1 ≤ entry.anchor ≤ length(built.structure.anchors) for entry in grid.pool)
            @test all(1 ≤ i ≤ length(grid.pool) for row in grid.primes for i in row.suppliers)
            @test haskey(grid, :admissible) == !isempty(built.structure.anchors)
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
        @test keys(value.build) == (:structure, :outputs, :events, :warnings)
        @test [(row.kind, row.severity, row.path) for row in value.build.warnings] == [("EmptyFaceSelection", "warning", "g")]
        @test only(value.build.warnings).message == message(only(warnings(built)))
        # the deployment's embedded body carries them too
        deployed = descriptor(Deployment(built; Δt_frame = 1//100))
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
        @test [row.kind for row in body.diagnostics] == [string(nameof(typeof(d))) for d in diagnostics(err)]
        @test [row.message for row in body.diagnostics] == message.(diagnostics(err))
        @test [row.path for row in body.diagnostics] == path.(diagnostics(err))
        @test all(row.severity == "error" for row in body.diagnostics)
        @test body.warnings == []
        # the unfed input marks its port; the unknown port marks nothing beyond its node
        unfed = only(row for row in body.diagnostics if row.kind == "UnconnectedInput")
        source = only(d for d in diagnostics(err) if d isa UnconnectedInput)
        @test unfed.marks == (ports = [(path = source.path, port = String(source.face))], wires = [])
        unknown = only(row for row in body.diagnostics if row.kind == "UnknownPort")
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
        source = only(diagnostics(err))
        @test cycle.members == source.members && all(m in node_paths for m in cycle.members)
        @test cycle.classification == "real" && cycle.dead == []
        @test cycle.traced == [(path = m, mode = string(mode)) for (m, mode) in source.traced]
        for wire in cycle.wires, endpoint in (wire.from, wire.to)
            @test endpoint.path in node_paths
            node = only(node for node in body.structure.nodes if node.path == endpoint.path)
            @test any(face.name == endpoint.port for face in vcat(node.inputs, node.outputs))
        end
        @test [(w.from.path * "/" * w.from.port, w.to.path * "/" * w.to.port) for w in cycle.wires] ==
              [(p, c) for (p, c) in source.wires]
        # A loop one level down: a wire's end splits at the last slash, so the
        # path keeps its own slashes.
        err = failure(() -> build(Group((; loop = Group((a = Gain(1.0), b = Gain(1.0));
                                                        local_wires = ("a/out" => "b/e", "b/out" => "a/e"))))))
        nested = descriptor(err)
        round_trip(nested)
        cycle = only(nested.failure.diagnostics).cycle
        @test cycle.members == ["loop/a", "loop/b"]
        @test cycle.wires == [(from = (path = "loop/a", port = "out"), to = (path = "loop/b", port = "e")),
                              (from = (path = "loop/b", port = "out"), to = (path = "loop/a", port = "e"))]
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
        row = only(body.diagnostics)
        @test row.kind == "UserCodeFraming" && row.path == "c" && row.var"function" == "y_state"
        @test occursin("\n  cause: boom", row.message)
        @test !haskey(row, :marks)
        # The carrier's warnings ride the failure body: a selection that kept
        # nothing beside the throwing probe.
        err = failure(() -> build(Group((s = SelectedNothing(Gain(2.0), Gain(3.0)), t = Thrower());
                                        input_wires = ("in" => "s/in",))))
        value = descriptor(err)
        round_trip(value)
        @test value.failure.policy == "fail-fast" && haskey(value.failure, :structure)
        # the helper raised it inside `s`'s declaration body, and its path is the
        # child's full path
        @test [(w.kind, w.severity, w.path) for w in value.failure.warnings] ==
              [("EmptyFaceSelection", "warning", "s/g")]
        @test only(value.failure.warnings).message == message(only(err.warnings))
    end

    @testset "the optional fields on the remaining kinds that write them (§13.9, D-434)" begin
        function_of(model) = only(descriptor(failure(() -> build(model))).failure.diagnostics).var"function"
        @test function_of(single(DeadStateStage())) == "y_state"
        @test function_of(single(BadDerivative())) == "x_deriv"
        err = failure(() -> build(single(Undeclared())))
        @test function_of(single(Undeclared())) == only(diagnostics(err)).stage
        marks_of(model) = only(descriptor(failure(() -> build(model))).failure.diagnostics).marks
        @test marks_of(DoubleFed(SampledLoop(), ModedSource(), ModedSource())) ==
              (ports = [(path = "loop/sum", port = "a")], wires = [])
        @test marks_of(Group((; src = NomSource(), c = FrozenEntry()); local_wires = ("src/val" => "c/u",))) ==
              (ports = [(path = "c", port = "u")],
               wires = [(from = (path = "src", port = "val"), to = (path = "c", port = "u"))])
    end

    @testset "a wire type mismatch marks its consumer port and its wire (§13.9, D-434)" begin
        err = failure(() -> build(Group((a = FieldReader(), b = RealEntry());
                                        input_wires = ("in" => ("a/f", "b/u"),))))
        value = descriptor(err)
        round_trip(value)
        row = only(value.failure.diagnostics)
        @test row.kind == "WireTypeMismatch"
        @test row.marks == (ports = [(path = "a", port = "f")],
                          wires = [(from = (path = "", port = "in"), to = (path = "a", port = "f"))])
        @test !haskey(value.failure, :structure)
    end

    @testset "a service's carrier is a failure descriptor with the list alone (§13.9, D-434)" begin
        anchored_build = build(AnchoredBank((TickCounter(), TickCounter()), TickCounter()))
        err = failure(() -> Deployment(anchored_build; Δt_frame = 1//500))
        value = descriptor(err)
        round_trip(value)
        @test value.failure.policy == "collected"
        @test !haskey(value.failure, :structure)
        @test [row.kind for row in value.failure.diagnostics] == ["DeploymentInvalid"]
    end

    @testset "the deployment envelope embeds the build body whole, its parameters flat after it (§13.9, D-467)" begin
        built = build(MultiRate())
        value = descriptor(Deployment(built; Δt_frame = 1//1000, Δt_base = 1//500))
        round_trip(value)
        @test keys(value) == (:format_version, :redstone_version, :kind, :deployment)
        @test value.kind == "deployment"
        @test keys(value.deployment) == (:build, :dt_frame, :dt_base, :h_max, :algorithm, :firing_budget,
                                         :localization_tol, :localization_budget, :attempt_budget,
                                         :schedule, :warnings)
        @test value.deployment.build == descriptor(built).build
        # a primitive root deploys too: one primitive node at the root, no wires
        primitive = descriptor(Deployment(build(Plant()); Δt_frame = 1//100))
        round_trip(primitive)
        root = only(primitive.deployment.build.structure.nodes)
        @test root.path == "" && root.class == "primitive" && !haskey(root, :wires)
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
        @test !haskey(keyed, :wires) && keyed.class == "primitive"
    end

    @testset "a primitive face carries its type, kind marker and pinned flag (§13.9)" begin
        body = descriptor(build(kinds_model())).build
        marker(path, name) = face_of(node_at(body, path), :outputs, name).kind
        @test marker("i", "y") == (kind = "integer",)
        @test marker("r", "y") == (kind = "number",)
        @test marker("v", "y") == (kind = "vector", shape = [2], element = (kind = "float",))
        @test marker("mat", "y") == (kind = "vector", shape = [2, 2], element = (kind = "float",))
        @test marker("nt", "y") == (kind = "struct", fields = ["a", "b"])
        @test marker("g", "gear") == (kind = "enum", values = ["up", "down"])
        @test marker("g", "y") == (kind = "float",)
        @test marker("s", "phase") == (kind = "symbol",)
        @test marker("p", "armed") == (kind = "boolean",)
        @test marker("stub", "y") == (kind = "opaque",)       # a handle, not isbits
        @test marker("fn", "y") == (kind = "opaque",)         # a closure with a capture
        @test marker("tup", "out") == (kind = "struct", fields = ["1", "2"])
        @test face_of(node_at(body, "free"), :inputs, "v").kind == (kind = "opaque",)   # size left free
        @test marker("pose", "pose") == (kind = "vector", shape = [3], element = (kind = "float",))   # a FieldVector
        @test face_of(node_at(body, "dut"), :inputs, "terrain").kind == (kind = "opaque",)
        # the pinned flag reads the declaration, and the type string is the unwrapped type's
        @test face_of(node_at(body, "i"), :outputs, "y").pinned
        @test face_of(node_at(body, "i"), :outputs, "y").type == "Int8"
        @test !face_of(node_at(body, "p"), :inputs, "phase").pinned
        pinned_gain = node_at(descriptor(build(fed(PinnedGain(), "e"))).build, "c")
        @test face_of(pinned_gain, :inputs, "e") == (name = "e", type = "Float64", kind = (kind = "float",), pinned = true)
        # a root face may carry a dot (D-418): the endpoint carries it whole
        @test body.structure.root_inputs ==
              [(name = "dut.k", type = "Float64", kind = (kind = "float",), pinned = false, pinned_by = [])]
        @test node_at(body, "").wires[end] == (from = (path = "", port = "dut.k"), to = (path = "dut", port = "k"))
    end

    @testset "a primitive node carries its tier and timing, and the structure its anchors and scopes (§9.1, §13.9)" begin
        body = descriptor(build(MultiRate())).build
        @test node_at(body, "gnss").tier == "discrete"
        @test node_at(body, "gnss").timing == (anchor = 1, m = 1, c = 0)
        @test node_at(body, "fcs/outer").timing == (anchor = 0, m = 5, c = 2)
        @test node_at(body, "src").tier == "continuous"
        @test !haskey(node_at(body, "fcs"), :tier) && !haskey(node_at(body, "fcs"), :timing)
        @test body.structure.anchors == [(dt = (num = 1, den = 50), tau = (num = 0, den = 1), scope = "", key = "gnss")]
        @test body.structure.scopes == [(path = "fcs", key = "fcs", timing = (anchor = 0, m = 1, c = 0))]
    end

    @testset "a node carries its alias when a const binds its type, and the envelope admits a name (§13.9)" begin
        value = descriptor(build(aliases_model()))
        body = value.build
        @test node_at(body, "sum").alias == "Redstone.Library.SumJunction"
        @test node_at(body, "pack").alias == "Redstone.Library.Pack"
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
        long = Constant(SVector{30}(1.0:30.0))
        summary = only(node_at(descriptor(build(single(long))).build, "c").parameters)
        @test summary.name == "value" && length(summary.value) == 81 && endswith(summary.value, "…")
        # a `NamedTuple` field opens into one entry per field, named by the dotted path (D-439)
        pid_root = Group((; c = Redstone.Library.DiscretePID(; Kp = 0.01, Ki = 0.001)); input_wires = ("r" => "c/r", "y" => "c/y"))
        pid = node_at(descriptor(build(pid_root)).build, "c")
        @test pid.parameters ==
              [(name = "fixed.Kp", value = "0.01"), (name = "fixed.Ki", value = "0.001"), (name = "fixed.Kd", value = "0.0"),
               (name = "fixed.τd", value = "0.1"), (name = "fixed.Tt", value = "Inf"), (name = "fixed.u_min", value = "-Inf"),
               (name = "fixed.u_max", value = "Inf"), (name = "fixed.b", value = "1.0"), (name = "fixed.c", value = "0.0")]
        # a nested `NamedTuple` opens in turn; a tuple and a struct stay one entry
        nested = node_at(descriptor(build(single(Constant((; a = 1.0, b = (; c = 2.0, d = (3.0, 4.0))))))).build, "c")
        @test nested.parameters ==
              [(name = "value.a", value = "1.0"), (name = "value.b.c", value = "2.0"), (name = "value.b.d", value = "(3.0, 4.0)")]
        # an empty `NamedTuple` keeps its one entry, so the field stays listed: `single`'s `Group` declares no sample times
        @test (name = "sample_times", value = "NamedTuple()") in node_at(descriptor(build(single(long))).build, "").parameters
        @test summary.value == first(repr(long.value; context = (:compact => true, :limit => true)), 80) * "…"
    end
    @testset "a bare face's name and a bare endpoint's port are `u` or `y`, at version one (§13.9, D-437)" begin
        value = descriptor(build(bare_ports_world()))
        round_trip(value)
        @test value.format_version == (major = 1, minor = 0)
        body = value.build
        flow = node_at(body, "plant/loop/flow")
        @test [face.name for face in flow.inputs] == ["u"] && [face.name for face in flow.outputs] == ["y"]
        @test [face.name for face in node_at(body, "ramp").inputs] == String[]
        @test node_at(body, "plant").wires[1] == (from = (path = "plant/loop", port = "x"),
                                                  to = (path = "plant/spin", port = "u"))
        @test only(c for c in body.outputs.components if c.path == "plant/loop/scale").stage2 == ["y"]
        @test [face.name for face in node_at(body, "").outputs] == ["total", "ramp"]
        @test node_at(body, "").wires[end] == (from = (path = "ramp", port = "y"), to = (path = "", port = "ramp"))
        # A loop through bare ports: each end is its member's path and face.
        err = failure(() -> build(Group((; a = BareScale(), b = BareScale());
                                        local_wires = ("a/y" => "b/u", "b/y" => "a/u"))))
        round_trip(descriptor(err))
        cycle = only(descriptor(err).failure.diagnostics).cycle
        @test cycle.wires == [(from = (path = "a", port = "y"), to = (path = "b", port = "u")),
                              (from = (path = "b", port = "y"), to = (path = "a", port = "u"))]
    end

    @testset "a root input's pinned is the fan-out meet's, with the consumers that pin it (§8.2, §13.9, D-168, D-468)" begin
        built = build(pinned_fanout())
        value = descriptor(built)
        round_trip(value)
        rows = value.build.structure.root_inputs
        @test [(row.name, row.pinned, row.pinned_by) for row in rows] ==
              [("in", true, [(path = "acc", port = "e"), (path = "p", port = "e")]), ("free", false, [])]
        # The cause has no key: the consumer's node carries its tier, and a declared
        # pin its face's own flag.
        @test [node_at(value.build, consumer.path).tier for consumer in rows[1].pinned_by] ==
              ["discrete", "continuous"]
        @test face_of(node_at(value.build, "p"), :inputs, "e").pinned
        @test !face_of(node_at(value.build, "acc"), :inputs, "e").pinned
        # An abstract entry pins when it admits no `Dual`, and an entry that admits
        # one pins nothing, though it admits no other non-`Float64` scalar.
        abstract_rows = descriptor(build(abstract_entries())).build.structure.root_inputs
        @test [(row.name, row.pinned, row.pinned_by) for row in abstract_rows] ==
              [("in", true, [(path = "f", port = "u")]), ("loose", false, [])]
        # A primitive root pins its own face, by declaration or by tier alone.
        @test [(row.name, row.pinned, row.pinned_by) for row in descriptor(build(PinnedGain())).build.structure.root_inputs] ==
              [("e", true, [(path = "", port = "e")])]
        @test [(row.name, row.pinned, row.pinned_by) for row in descriptor(build(UnitDelay(0.0))).build.structure.root_inputs] ==
              [("u", true, [(path = "", port = "u")])]
        # The oracle is the activation's own cell, the meet as the layout takes it:
        # a pinned root input keeps its type at a `Dual`, an unpinned one follows it.
        for model in (pinned_fanout(), abstract_entries(), fed(PinnedGain(), "e"), fed(PinnedVectorEntry()), Vehicle())
            model_built = build(model)
            act = activation(model_built, ProbeDual)
            for (k, row) in enumerate(descriptor(model_built).build.structure.root_inputs)
                cell_type = Redstone._port_type(act.layout.addr[("", Symbol(row.name))])
                @test row.pinned == (cell_type === model_built.structure.root_types[k])
            end
        end
        # A failure past the structure step carries the pin, the structure being complete.
        err = failure(() -> build(Group((t = Thrower(), p = PinnedGain()); input_wires = ("in" => "p/e",))))
        carried_rows = descriptor(err).failure.structure.root_inputs
        @test [(row.pinned, row.pinned_by) for row in carried_rows] == [(true, [(path = "p", port = "e")])]
    end

    @testset "the structure carries the grid report as data, its positions from 1 (§9.2, §13.9, D-466, D-467)" begin
        @test descriptor(build(MultiRate())).build.structure.grid ==
              (admissible = (num = 1, den = 50), pool = [(anchor = 1, kind = "period", factor = 1)],
               primes = [(prime = 2, power = 1, suppliers = [1]), (prime = 5, power = 2, suppliers = [1])])
        # Two anchors, the second with an offset that drives: its pool entry names
        # the second anchor, and its repair rides it. `primes` names pool positions.
        anchored = Group((; a = TickCounter(), b = TickCounter());
                         sample_times = (; a = Absolute(1//500), b = Absolute(1//10, 1//150)))
        value = descriptor(build(anchored))
        round_trip(value)
        @test value.build.structure.grid ==
              (admissible = (num = 1, den = 1500),
               pool = [(anchor = 1, kind = "period", factor = 10), (anchor = 2, kind = "period", factor = 1),
                       (anchor = 2, kind = "offset", factor = 3,
                        alternatives = [(num = 3, den = 500), (num = 1, den = 125)])],
               primes = [(prime = 2, power = 2, suppliers = [1]), (prime = 3, power = 1, suppliers = [3]),
                         (prime = 5, power = 3, suppliers = [1])])
        # A cofactor left whole is flagged, and only it: 2^61 − 1 is past `2^53`,
        # and the round trip keeps it exact.
        parsed = round_trip(descriptor(build(unfactored_model())))
        primes = parsed["build"]["structure"]["grid"]["primes"]
        @test [(row["prime"], get(row, "unfactored", false)) for row in primes] == [(3, false), (2^61 - 1, true)]
        # No anchors: an empty pool and primes, and no `admissible`.
        @test descriptor(build(Plant())).build.structure.grid == (pool = [], primes = [])
    end

    @testset "the build body carries the events, one row per primitive in walk order (§9.2, §13.9, D-467)" begin
        @test descriptor(build(Motor(1.0))).build.events ==
              (components = [(path = "", events = [(name = "start", policy = "non_localized")],
                              bundle = ["x", "m", "u", "y", "t"])],)
        value = descriptor(build(Group((; g = Gain(1.0), saw = Sawtooth(1.0)); input_wires = ("in" => "g/e",))))
        round_trip(value)
        @test value.build.events.components ==
              [(path = "g", events = [], bundle = []),
               (path = "saw", events = [(name = "wrap", policy = "localized")], bundle = ["x", "y", "t"])]
        # A row's events stand in declaration order.
        relay = only(descriptor(build(fed(Relay(lower = 0.0, upper = 1.0)))).build.events.components)
        @test [event.name for event in relay.events] == ["switch_on", "switch_off"]
        # `state_events` joins the located declarations, after `sample_times`'s
        # place, at the line its method is written on.
        motor = only(row for row in descriptor(build(Motor(1.0))).build.structure.types
                     if row.name == "Main.RedstoneTests.Motor")
        located = last(motor.locations)
        fixture_lines = readlines(joinpath(@__DIR__, "fixtures.jl"))
        @test getfield(located, :function) == "state_events" && endswith(located.file, "fixtures.jl")
        @test located.line == findfirst(line -> startswith(line, "state_events(::Motor)"), fixture_lines)
    end

    @testset "the deployment body is flat: the parameters, the schedule with the anchors' counts, the warnings (§9.2, §13.9, D-467)" begin
        value = descriptor(Deployment(build(MultiRate()); Δt_frame = 1//500))
        round_trip(value)
        body = value.deployment
        @test (body.dt_frame, body.dt_base, body.h_max) == ((num = 1, den = 500), (num = 1, den = 500), (num = 1, den = 500))
        @test !haskey(body, :h_min)
        @test body.algorithm == (text = "RK4()", proposes = false)
        @test (body.firing_budget, body.localization_tol, body.localization_budget, body.attempt_budget) == (4, 1e-6, 8, 7)
        @test body.schedule == (anchors = [(D = 10, phi = 0)],
                                rows = [(path = "fcs/inner", D = 1, phi = 0), (path = "fcs/outer", D = 5, phi = 2),
                                        (path = "gnss", D = 10, phi = 0)],
                                scopes = [(path = "fcs", key = "fcs", D = 1, phi = 0)])
        @test body.warnings == []
        # The counts are in base ticks, never frames, nor the finer of the two.
        coarse = Deployment(build(MultiRate()); Δt_frame = 1//500, Δt_base = 1//100)
        @test descriptor(coarse).deployment.schedule.anchors == [(D = 2, phi = 0)]
        # A proposing method sets its floor, which follows `h_max`; the bound is
        # the resolved one, and every parameter is its own.
        adaptive = Deployment(build(MultiRate()); Δt_frame = 1//500, h_max = 1//1000, h_min = 1//100000,
                              algorithm = BS3(reltol = 1e-6, abstol = 1e-9), firing_budget = 3,
                              localization_tol = 1e-5, localization_budget = 5, attempt_budget = 9)
        value = descriptor(adaptive)
        round_trip(value)
        body = value.deployment
        @test keys(body)[3:6] == (:dt_base, :h_max, :h_min, :algorithm)
        @test (body.h_max, body.h_min) == ((num = 1, den = 1000), (num = 1, den = 100000))
        @test body.algorithm == (text = "BS3(reltol = 1.0e-6, abstol = 1.0e-9)", proposes = true)
        @test (body.firing_budget, body.localization_tol, body.localization_budget, body.attempt_budget) == (3, 1e-5, 5, 9)
        # The anchors' counts at a derived base tick, against the exact quotients,
        # and the deployment's own warnings.
        derived = @test_logs (:info, r"derived") (:warn, r"^GridUtilization") Deployment(
            build(Group((; a = TickCounter(), b = TickCounter());
                        sample_times = (; a = Absolute(1//500), b = Absolute(1//10, 1//150))));
            Δt_frame = 1//1500, Δt_base = :derive)
        value = descriptor(derived)
        round_trip(value)
        body = value.deployment
        @test body.schedule.anchors ==
              [(D = Int(anchor.Δt / derived.Δt_base), phi = Int(anchor.τ / derived.Δt_base))
               for anchor in derived.build.structure.anchors] == [(D = 3, phi = 0), (D = 150, phi = 10)]
        @test [(row.kind, row.severity) for row in body.warnings] == [("GridUtilization", "warning")]
        @test only(body.warnings).message == message(only(warnings(derived)))
        # An anchor with no discrete primitive beneath it has counts and no row: a
        # client could not solve them back (D-467).
        held = Deployment(build(Group((; s = Group((; g = Gain(1.0)); input_wires = ("in" => "g/e",)));
                                      input_wires = ("in" => "s/in",),
                                      sample_times = (; s = Absolute(1//10, 1//20))));
                          Δt_frame = 1//100)
        value = descriptor(held)
        round_trip(value)
        @test value.deployment.schedule == (anchors = [(D = 10, phi = 5)], rows = [],
                                            scopes = [(path = "s", key = "s", D = 10, phi = 5)])
    end

    @testset "a primitive node carries its rate chain, which the timings do not determine (§9.2, §13.9)" begin
        body = descriptor(build(chained_model())).build
        # a container's bare field key is the key the chain prints
        @test node_at(body, "g/a").rates ==
              [(scope = "", key = "g", K = 3, phi = 1), (scope = "g", key = "children", K = 2, phi = 0)]
        # an explicit `Relative(1)` is a link, at the timing an unkeyed child has
        @test node_at(body, "one").rates == [(scope = "", key = "one", K = 1, phi = 0)]
        @test node_at(body, "one").timing == (anchor = 0, m = 1, c = 0)
        multirate = descriptor(build(MultiRate())).build
        @test node_at(multirate, "gnss").rates ==
              [(scope = "", key = "gnss", dt = (num = 1, den = 50), tau = (num = 0, den = 1))]
        @test node_at(multirate, "src").rates == []
    end

    @testset "a bare `@ref` link resolving to an exported binding gains its owner as target (§13.9, D-467)" begin
        row = only(row for row in descriptor(build(single(RefUser.Linked()))).build.structure.types
                   if row.name == "Main.RedstoneTests.RefUser.Linked")
        @test row.docstring == """
            A component whose docstring links [`owned`](@ref Main.RedstoneTests.RefOwner.owned), [`Linked`](@ref Main.RedstoneTests.RefUser.Linked),
            [`exported_helper`](@ref Main.RedstoneTests.RefUser.exported_helper), [`RefOwner.owned`](@ref Main.RedstoneTests.RefOwner.owned), [`internal_helper`](@ref),
            [`missing_name`](@ref), [`exported_helper(x)`](@ref), [`owned`](@ref RefOwner.owned)
            and [the owner](@ref), and the glossary's [state](@ref g-state), and
            [`@owned_macro`](@ref), [`⊕`](@ref), [`RefOwner.Deep.deep`](@ref Main.RedstoneTests.RefOwner.Deep.deep) and [`RefOwner`](@ref Main.RedstoneTests.RefOwner).
            """
        # The package exports nothing until its export audit, so a library
        # docstring keeps every link as written.
        pid = only(row for row in descriptor(build(Group((; c = Redstone.Library.DiscretePID(; Kp = 0.01));
                                                          input_wires = ("r" => "c/r", "y" => "c/y")))).build.structure.types
                   if row.name == "Redstone.Library.DiscretePID")
        @test occursin("[`AbstractAntiWindupController`](@ref)", pid.docstring)
        @test !occursin(r"\(@ref [A-Z]", pid.docstring)
    end

    @testset "the file carries what `show` prints: a client's derivation matches the printed lines (§9.2, §13.9, D-467)" begin
        multirate = build(MultiRate())
        anchored = Group((; a = TickCounter(), b = TickCounter());
                         sample_times = (; a = Absolute(1//500), b = Absolute(1//10, 1//150)))
        two_scopes = Group((; g = Group((; a = TickCounter()); sample_times = (; a = Relative(2))),
                              h = Group((; b = TickCounter()); sample_times = (; b = Relative(1))));
                           sample_times = (; g = Relative(3, 1), h = Absolute(1//25, 1//50)))
        for built in (multirate, build(pinned_fanout()), build(abstract_entries()), build(chained_model()),
                      build(unfactored_model()), build(anchored), build(routed_pair()), build(FannedLoops(2)),
                      build(Motor(1.0)), build(bare_ports_world()))
            file = round_trip(descriptor(built))["build"]
            @test client_structure(file["structure"]) == printed_structure(built.structure)
            @test client_events(file["events"]) == tokens.(split(sprint(show, MIME("text/plain"), built.events), '\n')[3:end])
        end
        for deployment in (Deployment(multirate; Δt_frame = 1//500),
                           Deployment(multirate; Δt_frame = 1//1000, Δt_base = 1//500, h_max = 1//3000,
                                      h_min = 1//100000, algorithm = BS3()),
                           Deployment(build(anchored); Δt_frame = 1//100, Δt_base = 1//1500),
                           Deployment(build(chained_model()); Δt_frame = 3//10, Δt_base = 1//10),
                           # frame tops between base ticks, then no discrete
                           # component, then two rate scopes on two anchors
                           Deployment(multirate; Δt_frame = 3//1000, Δt_base = 1//500),
                           Deployment(build(Plant()); Δt_frame = 1//100),
                           Deployment(build(two_scopes); Δt_frame = 1//100))
            file = round_trip(descriptor(deployment))["deployment"]
            printed = split(sprint(show, MIME("text/plain"), deployment), '\n')
            @test client_deployment(file) == printed[1:2]
            # the schedule's block (D-471): its tables' lines as tokens, then the
            # chart's heading and each row's label and marks, read at the column
            # the ruler's zero stands in
            block_start = findfirst(startswith("  schedule:"), printed)
            block = printed[block_start:findfirst(startswith("  warnings"), printed)-1]
            table_lines, chart = client_schedule(file)
            chart_at = something(findfirst(startswith("    chart"), block), length(block) + 1)
            @test table_lines == tokens.(block[1:chart_at-1])
            @test (chart === nothing) == (chart_at > length(block))
            chart === nothing && continue
            @test strip(block[chart_at]) == chart.heading
            if isempty(chart.rows)
                @test chart_at == length(block)
            else
                zero_column = findfirst(==('0'), collect(block[chart_at+1]))
                @test [(strip(String(collect(line)[1:zero_column-1])), String(collect(line)[zero_column:end]))
                       for line in block[chart_at+2:end]] == chart.rows
            end
        end
    end
end
