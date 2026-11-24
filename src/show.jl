# --- the artifacts' renderings (§9.2, §13.7, D-257) ----------------------------
# Each build-side and deployment artifact renders itself through `show`, with no
# accessor returning a table beside it. Two methods apiece: the compact form
# (one line, no newline — what a container or `repr` prints) and the REPL form
# under `MIME"text/plain"` (the tables). A REPL form is built as lines: no
# trailing newline, no line with trailing whitespace, tables aligned with `rpad`
# over `textwidth` and two spaces between columns, as `_grid_block` does, each
# block indented two spaces under its heading, and a nested artifact's lines two
# spaces further in. The grid block itself stays in `diagnostics.jl`, since the
# messages use it; the `Structure` sets its lines under `grid:` here. The
# `Deployment` prints the schedule in a block of its own, under the four frames'
# symbols and against the frame tops, since the `Schedule` holds neither an
# anchor nor a period (D-471). The published `FrameworkStatus` renders here too,
# under the same conventions, with §11.8's `maxlog` cap its presentation policy.

const _SUBSCRIPTS = collect("₀₁₂₃₄₅₆₇₈₉")

# `A₀`, `A₁`, …: the anchor by its index, 0 the base grid.
_anchor_name(anchor::Int) = "A" * join(_SUBSCRIPTS[c - '0' + 1] for c in string(anchor))

# A count with its noun: `no anchors`, `1 anchor`, `4 components`.
_count(number::Integer, noun::String) =
    number == 0 ? "no $(noun)s" : number == 1 ? "1 $noun" : "$number $(noun)s"

# The root's path in a table column; a primitive at the root is its own component.
_path_label(path::String) = isempty(path) ? "root" : path

# A rate entry as its fields spell it. Not the default `show`, whose
# qualification of the type name depends on the printing module.
_entry_label(entry::Relative) = "Relative($(entry.D), $(entry.Φ))"
_entry_label(entry::Absolute) = "Absolute($(entry.Δt), $(entry.τ))"

# A `RateLink` chain, `key = entry` joined by ` → `; empty is a dash.
_rates_label(rates::Vector{RateLink}) =
    isempty(rates) ? "—" :
    join(("$(link.key) = $(_entry_label(link.entry))" for link in rates), " → ")

# A comma-separated list of names; empty is a dash.
_names_label(name_list) = isempty(name_list) ? "—" : join(name_list, ", ")

# One aligned table, header first, every line under `indent` and stripped on
# the right.
function _table(indent::String, header::Vector{String}, rows::Vector{Vector{String}})
    widths = [maximum(textwidth(line[j]) for line in (header, rows...)) for j in eachindex(header)]
    [rstrip(indent * join((rpad(cell, width) for (cell, width) in zip(line, widths)), "  "))
     for line in (header, rows...)]
end

# The lines two spaces further in, for a nested artifact or a rendered block.
_indented(lines::Vector{<:AbstractString}) = ["  " * line for line in lines]

# The warnings block every artifact that carries a list ends with: `none`, or one
# `logline` per warning, its own lines indented under the heading.
_warning_lines(warning_list::Vector{Diagnostic}) =
    isempty(warning_list) ? ["warnings: none"] :
    vcat(["warnings:"],
         (_indented(split(logline(warning), '\n')) for warning in warning_list)...)

# --- Structure --------------------------------------------------------------------

_structure_counts(structure::Structure) =
    join((_count(length(structure.components), "component"),
          _count(length(structure.anchors), "anchor"),
          _count(length(structure.scopes), "rate scope")), ", ")

Base.show(io::IO, structure::Structure) = print(io, "Structure(", _structure_counts(structure), ")")

# A root face's route: its bare name, then each hop as `path/name`, joined with
# ` → ` and ending at the terminal (§13.7).
_route_label(face::Symbol, route::Vector{Tuple{String,Symbol}}) =
    join([String(face); [_named(path, name, "/") for (path, name) in route]], " → ")

# One side's block: one line per route of each root face in `faces`, derived from
# the wires (D-315), or no block when the side has no root face. A route whose
# terminal `marks` holds takes that mark in one column after the widest route.
function _route_lines(heading::String, structure::Structure, faces::Vector{Symbol},
                      marks::Dict{Tuple{String,Symbol},String} = Dict{Tuple{String,Symbol},String}())
    routes = [(face, route) for face in faces for route in face_routes(structure, ("", face))]
    isempty(routes) && return String[]
    labels = [_route_label(face, route) for (face, route) in routes]
    width = maximum(textwidth, labels)
    vcat(["  " * heading],
         [rstrip("    " * rpad(label, width) * "  " * get(marks, last(route), ""))
          for (label, (_, route)) in zip(labels, routes)])
end

# The input routes' marks (§13.7, D-468): each pinning consumer's terminal, by
# its tier, where the route that ends there is printed.
_pin_marks(structure::Structure) =
    Dict{Tuple{String,Symbol},String}(
        (consumer.path, consumer.port) =>
            (consumer.tier === DISCRETE ? "pinned by tier" : "pinned by declaration")
        for consumers in pinning_consumers(structure) for consumer in consumers)

# The component table with its timing against the anchors, the rate-scope rows
# when any keyed scope exists, the anchor table with the `A₀` row always
# present: `Δt_base` symbolic in its `T` column and dashes where no scope
# declares it (§9.2), the grid report derived from the anchors, its block's
# lines under `grid:` and no block where no anchor exists (D-466), and the root
# faces' routes, derived through `face_routes`, an input route marked where its
# consumer pins the root input (D-468). The level rows and their wires are
# fields, printed by no method here.
function _lines(structure::Structure)
    lines = ["Structure: " * _structure_counts(structure) * "; root inputs: " *
             (isempty(structure.root_inputs) ? "none" : join(structure.root_inputs, ", ")),
             "  components:"]
    append!(lines, _table("    ", ["path", "tier", "anchor", "Dₐ", "Φₐ", "rates"],
                          [[_path_label(entry.path), tier_word(entry.tier),
                            _anchor_name(entry.timing.anchor), string(entry.timing.D),
                            string(entry.timing.Φ), _rates_label(entry.rates)]
                           for entry in structure.components]))
    if !isempty(structure.scopes)
        push!(lines, "  rate scopes:")
        append!(lines, _table("    ", ["path", "key", "anchor", "Dₐ", "Φₐ"],
                              [[_path_label(scope.path), string(scope.key),
                                _anchor_name(scope.timing.anchor), string(scope.timing.D),
                                string(scope.timing.Φ)]
                               for scope in structure.scopes]))
    end
    push!(lines, "  anchors:")
    append!(lines, _table("    ", ["anchor", "Δt", "τ", "scope", "key"],
                          vcat([[_anchor_name(0), "Δt_base", string(zero(Rational{Int})), "—", "—"]],
                               [[_anchor_name(k), string(anchor.Δt), string(anchor.τ),
                                 _path_label(anchor.scope), string(anchor.key)]
                                for (k, anchor) in enumerate(structure.anchors)])))
    block = _grid_block(_grid_report(structure.anchors))
    isempty(block) || append!(lines, ["  grid:"; _indented(split(block, '\n')[2:end])])
    root_level = first(structure.levels)
    append!(lines, _route_lines("input routes:", structure, _boundary_inputs(root_level),
                                _pin_marks(structure)))
    append!(lines, _route_lines("output routes:", structure, _boundary_outputs(root_level)))
    lines
end

# --- Outputs ----------------------------------------------------------------------

Base.show(io::IO, outputs::Outputs) =
    print(io, "Outputs(", _count(length(outputs.order), "component"), ")")

# One row per position in the execution order: the component at it, by its
# path, with its stage-1 and stage-2 names.
function _lines(outputs::Outputs)
    rows = [[_path_label(outputs.components[ci].path),
             _names_label(outputs.components[ci].stage1),
             _names_label(outputs.components[ci].stage2)]
            for ci in outputs.order]
    vcat(["Outputs: execution order over " * _count(length(outputs.order), "component")],
         _table("  ", ["component", "stage 1", "stage 2"], rows))
end

# --- Events -----------------------------------------------------------------------

_events_counts(events::Events) =
    _count(sum(row -> length(row.policies), events.components; init = 0), "event") *
    " over " * _count(length(events.components), "component")

Base.show(io::IO, events::Events) = print(io, "Events(", _events_counts(events), ")")

# One row per component that declares an event: its path, `name => policy` in
# declaration order, and the event bundle's field names. No events is the
# heading alone.
function _lines(events::Events)
    rows = [[_path_label(row.path),
             join(("$name => $policy" for (name, policy) in pairs(row.policies)), ", "),
             isempty(row.bundle) ? "—" : "(" * join(row.bundle, ", ") * ")"]
            for row in events.components if !isempty(row.policies)]
    lines = ["Events: " * _events_counts(events)]
    isempty(rows) || append!(lines, _table("  ", ["component", "events", "bundle"], rows))
    lines
end

# --- Schedule ---------------------------------------------------------------------

# The hyperperiod: the pattern repeats every `H = lcm D₀(i)` base ticks, so one
# is the complete truth (§9.2). A `BigInt`, since coprime periods can take it
# past `Int` and it is printed, never indexed past the chart's guard.
_hyperperiod(schedule::Schedule) = lcm(big.([row.D for row in schedule.rows]))

function Base.show(io::IO, schedule::Schedule)
    isempty(schedule.rows) && return print(io, "Schedule(no rows)")
    print(io, "Schedule(", _count(length(schedule.rows), "row"), ", hyperperiod ",
          _count(_hyperperiod(schedule), "base tick"), ")")
end

# The counts a schedule's heading states, the `Schedule`'s own and the
# deployment's block's alike.
_schedule_counts(schedule::Schedule) =
    (isempty(schedule.rows) ? "no rows" : _count(length(schedule.rows), "row")) *
    (isempty(schedule.scopes) ? "" : ", " * _count(length(schedule.scopes), "rate scope")) *
    (isempty(schedule.rows) ? "" : ", hyperperiod " * _count(_hyperperiod(schedule), "base tick"))

# A chart's ruler: the column index at every column divisible by 10.
function _chart_ruler(columns::Int)
    ruler = ""
    for k in 0:10:columns-1
        ruler = rpad(ruler, k) * string(k)
    end
    ruler
end

# The rows, the rate-scope rows when any exist, and the hyperperiod chart: one
# row per schedule row, one character per base tick `n = 0 … H − 1`, `●`
# where `(n − Φ₀) % D₀ == 0`, under a ruler carrying the tick index at every
# column divisible by 10. The guard is binary (D-257): at `hyperperiod > 100`
# the chart's place holds one line naming the length instead.
function _lines(schedule::Schedule)
    rows = schedule.rows
    lines = ["Schedule: " * _schedule_counts(schedule)]
    isempty(rows) ||
        append!(lines, _table("  ", ["path", "anchor", "D₀", "Φ₀", "Δt", "rates"],
                              [[_path_label(row.path), _anchor_name(row.anchor), string(row.D),
                                string(row.Φ), repr(row.Δt), _rates_label(row.rates)]
                               for row in rows]))
    if !isempty(schedule.scopes)
        push!(lines, "  rate scopes:")
        append!(lines, _table("    ", ["path", "key", "anchor", "D₀", "Φ₀"],
                              [[_path_label(scope.path), string(scope.key), _anchor_name(scope.anchor),
                                string(scope.D), string(scope.Φ)]
                               for scope in schedule.scopes]))
    end
    isempty(rows) && return lines
    hyperperiod = _hyperperiod(schedule)
    hyperperiod > 100 &&
        return push!(lines, "  hyperperiod: $hyperperiod base ticks, chart omitted")
    hyperperiod = Int(hyperperiod)
    push!(lines, "  hyperperiod chart, " * _count(hyperperiod, "base tick") * ":")
    width = maximum(textwidth(_path_label(row.path)) for row in rows)
    push!(lines, " "^(4 + width + 2) * _chart_ruler(hyperperiod))
    for row in rows
        push!(lines, "    " * rpad(_path_label(row.path), width) * "  " *
                     join(((n - row.Φ) % row.D == 0 ? '●' : '·') for n in 0:hyperperiod-1))
    end
    lines
end

# --- Build ------------------------------------------------------------------------

# The activation keys, read under the build's lock (§9.4): the nominal `Float64`
# first, the rest by name, since the dictionary has no order of its own.
_activations_label(build::Build) =
    lock(build.lock) do
        others = sort([string(T) for T in keys(build.activations) if T !== Float64])
        join(["Float64"; others], ", ")
    end

Base.show(io::IO, build::Build) =
    print(io, "Build(", _count(length(build.structure.components), "component"),
          ", activations: ", _activations_label(build), ")")

# The feedthrough edges the execution order was computed over (§5.3, D-261),
# derived rather than carried: a face of a component with a stage 2, fed by
# another component's stage-2 port. A root input and a stage-1 port add none.
# Each end is `path/name`.
function _feedthrough(structure::Structure, outputs::Outputs, decls::Vector{Decls})
    edges = String[]
    for ci in outputs.order
        isempty(outputs.components[ci].stage2) && continue
        consumer = structure.components[ci]
        for face in keys(keyed_ins(decls[ci]))
            (producer, port_name) = terminal_producer(structure, (consumer.path, face))
            isempty(producer) && continue
            port_name in outputs.components[index_of(structure, producer)].stage2 || continue
            push!(edges, _named(producer, port_name, "/") * " → " *
                         _named(_path_label(consumer.path), face, "/"))
        end
    end
    edges
end

# The summary and the parts: the structure, the outputs, the feedthrough line
# the `Build` alone can derive, the events, then the warnings.
function _lines(build::Build)
    components = build.structure.components
    continuous = count(entry.tier === CONTINUOUS for entry in components)
    edges = _feedthrough(build.structure, build.outputs, activation(build, Float64).decls)
    vcat(["Build: " * _count(length(components), "component") *
          " ($continuous continuous, $(length(components) - continuous) discrete); activations: " *
          _activations_label(build) * "; " * _count(length(build.warnings), "warning")],
         _indented(_lines(build.structure)),
         _indented(_lines(build.outputs)),
         ["  feedthrough: " * (isempty(edges) ? "none" : join(edges, ", "))],
         _indented(_lines(build.events)),
         _indented(_warning_lines(build.warnings)))
end

# --- Deployment -------------------------------------------------------------------

# The time quantities print exact, as the deployment compares them (D-454),
# the bound resolved (D-449), the floor where one is set (D-460), and the
# algorithm by its token's `show` (D-442).
_deployment_parameters(deployment::Deployment) =
    "Δt_frame = $(repr(deployment.Δt_frame)), Δt_base = $(repr(deployment.Δt_base)), " *
    "h_max = $(repr(deployment.h_max)), " *
    (deployment.h_min === nothing ? "" : "h_min = $(repr(deployment.h_min)), ") *
    sprint(show, deployment.algorithm)

Base.show(io::IO, deployment::Deployment) =
    print(io, "Deployment(", _deployment_parameters(deployment), ")")

# The steps of a fixed-step method per frame (§9.2, §10.5, D-449). A frame no
# due instant falls inside is one span, taken in `⌈Δt_frame / h_max⌉` steps, one
# `cld` over the bound's ratio to the unit. Under a proposing method the count
# is the controller's, and the line states its range instead: at least the
# fixed count, which a proposal at or above the bound takes, and at most
# `⌊Δt_frame / h_min⌋`, since no step of an unsplit frame is shorter than the
# floor; a localized event's `t*` adds a step beyond it (D-460). A row's ticks lie at
# `(Φ₀ + j·D₀)·base` units, all of them frame tops exactly when the frame divides
# both `Φ₀·base` and `D₀·base`; every other row splits frames, and the line names
# it, the count then labelled as the unsplit frame's. No frame is walked, so
# the line costs one check per row. The products fit
# `Int`, since `_lattice` fits `D₀·base` past a frame top and `Φ₀ < D₀`.
function _steps_line(deployment::Deployment)
    lattice = deployment.lattice
    steps = cld(lattice.frame * denominator(lattice.bound), numerator(lattice.bound))
    ratio = proposes(deployment.algorithm) ?
            Rational{Int128}(deployment.Δt_frame) / deployment.h_min : nothing
    steps_text = ratio === nothing ? string(steps) :
                 "$steps to $(max(steps, fld(numerator(ratio), denominator(ratio)))), as proposed"
    splitting = [_path_label(row.path) for row in deployment.schedule.rows
                 if (row.Φ * lattice.base) % lattice.frame != 0 ||
                    (row.D * lattice.base) % lattice.frame != 0]
    # Where a row splits frames, the count is labelled as the unsplit frame's,
    # which holds even when every frame is split.
    isempty(splitting) ? "steps per frame: $steps_text" :
        "steps per unsplit frame: $steps_text; due instants of " * join(splitting, ", ") *
        " split frames"
end

# A count of base ticks in seconds, exact (D-471). The product of two `Int`s
# fits `Int128`, and a `Rational` prints alike at every width.
_seconds_label(ticks::Int, Δt_base::Rational{Int}) = repr(ticks * Rational{Int128}(Δt_base))

# The chart against the frame tops (§9.2, D-471): one column per `Δt_unit`
# over the joint period, the least common multiple of the hyperperiod and the
# frame in units, where the frame tops and the ticks repeat together. The first
# row marks the frame tops, in every deployment. A row's column is `●` at a
# base tick where it is due, `·` at one where it is not, and blank where no
# base tick falls. The guard is binary, at 100 columns: past it the chart's
# place holds one line naming the span. The span is a `BigInt`, as the
# hyperperiod is.
function _chart_lines(deployment::Deployment)
    rows, lattice = deployment.schedule.rows, deployment.lattice
    span = lcm(_hyperperiod(deployment.schedule) * lattice.base, big(lattice.frame))
    extent = _count(span, "column") * " of $(repr(lattice.unit)) s over " *
             _count(span ÷ lattice.base, "base tick") * " and " *
             _count(span ÷ lattice.frame, "frame")
    span > 100 && return ["chart omitted: " * extent]
    columns = 0:Int(span)-1
    labels = [_path_label(row.path) for row in rows]
    width = maximum(textwidth, ["frame tops"; labels])
    chart_row(label, marks) = rstrip("  " * rpad(label, width) * "  " * join(marks))
    lines = ["chart, " * extent * ":", " "^(2 + width + 2) * _chart_ruler(length(columns)),
             chart_row("frame tops", (k % lattice.frame == 0 ? '│' : ' ' for k in columns))]
    for (row, label) in zip(rows, labels)
        push!(lines, chart_row(label, (k % lattice.base != 0 ? ' ' :
                                       (k ÷ lattice.base - row.Φ) % row.D == 0 ? '●' : '·'
                                       for k in columns)))
    end
    lines
end

# The deployment's base tick against the coarsest admissible one (§9.2,
# D-471, D-479): `gcd(pool)` over the whole number `Q` the base tick divides it
# by, the clause dropped at `Q = 1`. A structure with no anchors admits every
# base tick and gets no line. A bound deployment's base tick divides every pool
# entry, so `Q` is whole, and the division runs in `Int128` as the anchors'
# counts do.
function _admissible_line(structure::Structure, Δt_base::Rational{Int})
    admissible = _grid_report(structure.anchors).admissible
    admissible === nothing && return nothing
    Q = something(_as_int(Rational{Int128}(admissible) / Δt_base))
    "Δt_base: $(repr(Δt_base)), the coarsest admissible" *
        (Q == 1 ? "" : " $(repr(admissible)) divided by $Q")
end

# The schedule under the four frames' symbols (§9.2, D-464, D-471, D-478), the
# deployment's own block: the base tick against the coarsest admissible one,
# where the structure has anchors; the anchor table with each anchor's seconds
# pair and its counts, `A₀` at `Δt_base` by its value; one row per discrete component
# with `(Dₐ, Φₐ)`, `(D₀, Φ₀)` and `(Δt, τ)`, the seconds exact; the rate-scope rows
# under the same columns; and the chart. `(Dₐ, Φₐ)` are the structure's, whose
# discrete components and scopes stand in the schedule's order, and the
# anchors' counts are derived by the constructor's own division, since the
# `Schedule` holds neither (D-261). No rows and no scopes is the heading alone.
function _schedule_lines(deployment::Deployment)
    schedule, structure, Δt_base = deployment.schedule, deployment.build.structure, deployment.Δt_base
    lines = ["schedule: " * _schedule_counts(schedule)]
    isempty(schedule.rows) && isempty(schedule.scopes) && return lines
    admissible_line = _admissible_line(structure, Δt_base)
    admissible_line === nothing || push!(lines, "  " * admissible_line)
    anchor_rows =[[_anchor_name(0), repr(Δt_base), string(zero(Rational{Int})), "1", "0"]]
    for (k, anchor) in enumerate(structure.anchors)
        D_anchor, Φ_anchor = _anchor_counts(anchor, Δt_base)   # whole on a bound deployment
        push!(anchor_rows, [_anchor_name(k), string(anchor.Δt), string(anchor.τ),
                            string(something(D_anchor)), string(something(Φ_anchor))])
    end
    push!(lines, "  anchors:")
    append!(lines, _table("    ", ["anchor", "Δt", "τ", "D₀", "Φ₀"], anchor_rows))
    timing_cells(timing::Timing, D_0::Int, Φ_0::Int) =
        [_anchor_name(timing.anchor), string(timing.D), string(timing.Φ), string(D_0), string(Φ_0),
         _seconds_label(D_0, Δt_base), _seconds_label(Φ_0, Δt_base)]
    if !isempty(schedule.rows)
        discrete = [entry for entry in structure.components if entry.tier === DISCRETE]
        push!(lines, "  components:")
        append!(lines, _table("    ", ["path", "anchor", "Dₐ", "Φₐ", "D₀", "Φ₀", "Δt", "τ"],
                              Vector{String}[[_path_label(row.path); timing_cells(entry.timing, row.D, row.Φ)]
                                             for (row, entry) in zip(schedule.rows, discrete)]))
    end
    if !isempty(schedule.scopes)
        push!(lines, "  rate scopes:")
        append!(lines, _table("    ", ["path", "key", "anchor", "Dₐ", "Φₐ", "D₀", "Φ₀", "Δt", "τ"],
                              Vector{String}[[_path_label(row.path); string(row.key);
                                              timing_cells(scope.timing, row.D, row.Φ)]
                                             for (row, scope) in zip(schedule.scopes, structure.scopes)]))
    end
    isempty(schedule.rows) || append!(lines, _indented(_chart_lines(deployment)))
    lines
end

# The parameters, the steps per frame, the build in its compact form (a reader
# wanting it evaluates `deployment.build`), the schedule's block and the
# warnings. The grid report is the structure's to print (D-466).
function _lines(deployment::Deployment)
    vcat(["Deployment: " * _deployment_parameters(deployment) *
          "; firing_budget = $(deployment.firing_budget), " *
          "localization_tol = $(repr(deployment.localization_tol)), " *
          "localization_budget = $(deployment.localization_budget), " *
          "attempt_budget = $(deployment.attempt_budget)",
          "  " * _steps_line(deployment),
          "  build: " * sprint(show, deployment.build)],
         _indented(_schedule_lines(deployment)),
         _indented(_warning_lines(deployment.warnings)))
end

# --- FrameworkStatus (§11.8) ------------------------------------------------------

"""
§11.8's presentation policy, the `maxlog` successor: a writer × kind prints
its occurrences in full up to this many cumulative ones, then as a count
alone. Presentation, never channel policy: the channel's own bound is
`DIAG_RING`, and the counts accumulate regardless.
"""
const STATUS_MAXLOG = 25

_pace_label(p::Float64) = isinf(p) ? "unpaced" : "pace = $p"

# The writer count, the cumulative occurrences over every writer's totals, the pace.
_status_counts(status::FrameworkStatus) =
    join((_count(length(status.writers), "writer"),
          _count(sum(record -> _total(record.totals), status.writers; init = 0), "occurrence"),
          _pace_label(status.pacer.pace)), ", ")

Base.show(io::IO, status::FrameworkStatus) =
    print(io, "FrameworkStatus(", _status_counts(status), ")")

# One kind's group under its writer: the count-only line, then the retained
# occurrences within the cap, then this boundary's suppressed count. The cap
# needs no state across snapshots: the occurrences before this boundary are the
# total less this boundary's retained and suppressed ones, so a reader sampling
# every snapshot sees each of the first `STATUS_MAXLOG` exactly once.
function _kind_lines(record::WriterStatus, kind_type::Type)
    field = _kind(kind_type)
    total = getfield(record.totals, field)
    total == 0 && return String[]
    retained = [occurrence for occurrence in record.recent if occurrence isa kind_type]
    suppressed_count = getfield(record.suppressed, field)
    earlier = total - length(retained) - suppressed_count
    lines = ["$(nameof(kind_type)): $(_count(total, "occurrence"))"]
    for (i, occurrence) in enumerate(retained)
        earlier + i ≤ STATUS_MAXLOG && append!(lines, _indented(split(logline(occurrence), '\n')))
    end
    suppressed_count > 0 && push!(lines, "  $suppressed_count suppressed this boundary")
    lines
end

# One writer's block: its name, the task state and the raw heartbeat where the
# record carries them, then a group per kind with a nonzero total in `KINDS`'s
# order. No staleness verdict: read after the run, every heartbeat is stale
# against the wall clock, and `stale(record)` stays the GUI's question.
function _writer_lines(record::WriterStatus)
    facts = String[]
    record.task_state === nothing || push!(facts, string(record.task_state))
    record.heartbeat === nothing || push!(facts, "heartbeat $(record.heartbeat)")
    _total(record.totals) == 0 && push!(facts, "no occurrences")
    heading = isempty(facts) ? record.who * ":" : record.who * ": " * join(facts, ", ")
    vcat([heading],
         _indented(mapreduce(kind_type -> _kind_lines(record, kind_type), vcat, KINDS;
                             init = String[])))
end

_pacer_line(pacer::PacerStatus) =
    "pacer: " * join((_pace_label(pacer.pace), "debt $(pacer.debt) s",
                      "peak $(pacer.peak_debt) s", _count(pacer.overruns, "overrun"),
                      _count(pacer.reanchors, "reanchor"), "$(pacer.forgiven) s forgiven",
                      _count(pacer.waits, "wait"), "$(pacer.waited) s waited"), ", ")

# The writers in the status's order, the pacer's line last (§11.8, §10.7).
_lines(status::FrameworkStatus) =
    vcat(["FrameworkStatus: " * _status_counts(status)],
         _indented(mapreduce(_writer_lines, vcat, status.writers; init = String[])),
         ["  " * _pacer_line(status.pacer)])

# --- Simulation, Series, TrimReport, Linearization (§11.2, §14.10, D-476) ---------

# A number in a table cell, as a REPL prints it inside a container: six
# significant digits.
_value_label(value) = sprint(show, value; context = :compact => true)

# A column of numbers under its header, aligned on the decimal point as a REPL
# aligns a matrix. The header ends at the point where it fits, and starts at
# the column's edge otherwise.
function _number_column(header::String, value_labels::Vector{String})
    splits = [match(r"^([^.]*)(.*)$", label).captures for label in value_labels]
    whole_width = maximum(textwidth(whole) for (whole, _) in splits; init = 0)
    fraction_width = maximum(textwidth(fraction) for (_, fraction) in splits; init = 0)
    [lpad(header, whole_width);
     [lpad(whole, whole_width) * rpad(fraction, fraction_width) for (whole, fraction) in splits]]
end

# One aligned table from its columns, each a header over its cells.
_column_table(indent::String, columns::Vector{Vector{String}}) =
    _table(indent, first.(columns),
           [[column[i] for column in columns] for i in 2:length(first(columns))])

# The lifecycle, then the clock once the simulation holds a state.
function _simulation_state(sim::Simulation, state_label::Symbol)
    state_label === :built && return String(state_label)
    "$state_label, frame $(sim.run.frame) at t = $(sim.model.exec.clock.t)"
end

Base.show(io::IO, sim::Simulation) = print(io, "Simulation(", _simulation_state(sim, lifecycle(sim)), ")")

# What a termination source holds beyond its kind.
_source_detail(::TerminationSource) = ""
_source_detail(source::ModelRequestedStop) =
    ", by $(_named(source.path, source.port, "/")), reason \"$(source.reason)\""
_source_detail(source::ControlRequestedStop) = ", by $(source.issuer)"
_source_detail(source::LoopError) = ", $(nameof(typeof(source.exception)))"

function _termination_line(record::TerminationRecord)
    line = "termination: $(nameof(typeof(record.source))) at t = $(record.t)" * _source_detail(record.source)
    isempty(record.residue) ? line : line * ", " * _count(length(record.residue), "residue record")
end

# The retained snapshots, counted off `logged`, which a running loop refuses.
function _log_line(sim::Simulation)
    sim.run.log.enabled || return "log: off"
    "log: " * _count(length(logged(sim)), "snapshot")
end

function _devices_line(sim::Simulation)
    isempty(sim.plane.roster) && return "devices: none"
    "devices: " * join(("device $(entry.id) ($(_typename(entry.dev)))" for entry in sim.plane.roster), ", ")
end

# The state line, the input mode, the deployment in its compact form, the run's
# outcome and log, the devices and the warnings. A running simulation's log is
# the loop's, and goes unread; the lifecycle is read once, so the two agree.
function _lines(sim::Simulation)
    state_label = lifecycle(sim)
    record = termination(sim)
    vcat(["Simulation: " * _simulation_state(sim, state_label),
          "  input mode: $(mode(sim))",
          "  deployment: " * sprint(show, sim.model.deployment)],
         record === nothing ? String[] : ["  " * _termination_line(record)],
         state_label === :running ? String[] : ["  " * _log_line(sim)],
         ["  " * _devices_line(sim)],
         _indented(_warning_lines(warnings(sim))))
end

# The count of snapshots and the span of `t` they cover.
function _series_counts(log_series::Series)
    count_label = _count(length(log_series.t), "snapshot")
    isempty(log_series.t) ? count_label :
    count_label * ", t = $(first(log_series.t)) to $(last(log_series.t))"
end

Base.show(io::IO, log_series::Series) =
    print(io, "Series(", _series_counts(log_series), "; ", _names_label(keys(log_series.columns)), ")")

# One row per column: its label and its element type, no values.
_lines(log_series::Series) =
    vcat(["Series: " * _series_counts(log_series)],
         isempty(log_series.columns) ? String[] :
         _table("  ", ["column", "eltype"],
                [[String(label), string(eltype(column))] for (label, column) in pairs(log_series.columns)]))

_verdict_label(report::TrimReport) =
    (report.converged ? "converged" : "not converged") * ", " *
    (report.committed_residuals === nothing ? "nothing committed" : "committed")

Base.show(io::IO, report::TrimReport) =
    print(io, "TrimReport(", _verdict_label(report), ", ", _count(report.n_iterations, "iteration"), ")")

# A table's first column, the names under their header.
_name_column(header::String, name_list) = [header; [String(name) for name in name_list]]

# A NamedTuple's values as a column of numbers under `header`.
_number_column(header::String, labeled_values::NamedTuple) =
    _number_column(header, String[_value_label(value) for value in labeled_values])

# The verdict; the backend's own status and counts; the decisions, a bound the
# solution sits at marked on its row; the residuals beside their tolerances, and
# the committed state's beside them when one was committed; the committed
# checks; the events the commit fired.
function _lines(report::TrimReport)
    bounds = Dict(report.saturated)
    bound_marks = [""; [haskey(bounds, name) ? "at the $(bounds[name]) bound" : ""
                        for name in keys(report.solution)]]
    committed = report.committed_residuals
    residual_columns = [_name_column("residual", keys(report.residuals)),
                        _number_column("value", report.residuals),
                        _number_column("tolerance", report.tolerances[keys(report.residuals)])]
    committed === nothing ||
        push!(residual_columns, _number_column("committed", committed[keys(report.residuals)]))
    checks = report.committed_checks
    vcat(["TrimReport: " * _verdict_label(report),
          "  backend: status $(report.status), " * _count(report.n_iterations, "iteration") * ", " *
          _count(report.n_evaluations, "evaluation")],
         isempty(report.solution) ? String[] :
         _column_table("  ", [_name_column("decision", keys(report.solution)),
                              _number_column("value", report.solution), bound_marks]),
         isempty(report.residuals) ? String[] : _column_table("  ", residual_columns),
         checks === nothing || isempty(checks) ? String[] :
         _column_table("  ", [_name_column("check", keys(checks)), _number_column("committed", checks)]),
         isempty(report.fired_events) ? String[] :
         ["  fired events: " * join((_named(path, name, "/") for (path, name) in report.fired_events), ", ")])
end

_linearization_counts(linearization::Linearization) =
    join((_count(length(linearization.x_labels), "state"),
          _count(length(linearization.u_labels), "input"),
          _count(length(linearization.y_labels), "output")), ", ")

Base.show(io::IO, linearization::Linearization) =
    print(io, "Linearization(", _linearization_counts(linearization), ")")

# One matrix under its row and column labels, read by integer index so a plain
# and a labeled value print alike (§14.10). An empty matrix prints no block.
function _matrix_lines(heading::String, matrix::AbstractMatrix{Float64},
                       row_labels::Tuple{Vararg{Symbol}}, column_labels::Tuple{Vararg{Symbol}})
    isempty(matrix) && return String[]
    vcat([heading * ":"],
         _column_table("  ", [[_name_column("", row_labels)];
                              [_number_column(String(column_labels[j]),
                                              [_value_label(matrix[i, j]) for i in eachindex(row_labels)])
                               for j in eachindex(column_labels)]]))
end

# One list's operating point under its labels, beside the derivative for the
# states. An empty list prints no block.
function _point_lines(heading::String, labels::Tuple{Vararg{Symbol}}, columns::Vector)
    isempty(labels) && return String[]
    vcat([heading * ":"],
         _column_table("  ", [[_name_column("", labels)];
                              [_number_column(header, [_value_label(point[i]) for i in eachindex(labels)])
                               for (header, point) in columns]]))
end

# The operating point per list, then the four matrices.
function _lines(linearization::Linearization)
    (; ẋ₀, x₀, u₀, y₀, A, B, C, D, x_labels, u_labels, y_labels) = linearization
    vcat(["Linearization: " * _linearization_counts(linearization)],
         _indented(_point_lines("states", x_labels, ["x₀" => x₀, "ẋ₀" => ẋ₀])),
         _indented(_point_lines("inputs", u_labels, ["u₀" => u₀])),
         _indented(_point_lines("outputs", y_labels, ["y₀" => y₀])),
         _indented(_matrix_lines("A", A, x_labels, x_labels)),
         _indented(_matrix_lines("B", B, x_labels, u_labels)),
         _indented(_matrix_lines("C", C, y_labels, x_labels)),
         _indented(_matrix_lines("D", D, y_labels, u_labels)))
end

# --- the REPL forms ---------------------------------------------------------------

for Artifact in (Structure, Outputs, Events, Schedule, Build, Deployment, FrameworkStatus,
                 Simulation, Series, TrimReport, Linearization)
    @eval Base.show(io::IO, ::MIME"text/plain", artifact::$Artifact) =
        join(io, _lines(artifact), "\n")
end
