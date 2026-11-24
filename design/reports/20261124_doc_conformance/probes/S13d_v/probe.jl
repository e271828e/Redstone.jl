# S13d verifier probe. Run from the pinned worktree with --project=test.
include(joinpath(pwd(), "test", "RedstoneTests.jl"))
using .RedstoneTests
const RT = RedstoneTests
using Redstone, JSON, StaticArrays
const R = Redstone
using Redstone: build, descriptor, Deployment, BS3, u_types

say(id, x) = println(id, " | ", x)

# S13d-002: the methods
say("002", methods(R.descriptor))

# S13d-012: build body keys, and show prints activations
b = build(RT.kinds_model())
d = descriptor(b)
say("012 build body keys", keys(d.build))
say("012 show mentions activation", occursin("activation", sprint(show, MIME"text/plain"(), b)))
say("012 json has activation", occursin("activation", JSON.json(d)))

# S13d-022: bare endpoints' ports are Strings
bw = descriptor(build(RT.bare_ports_world())).build
loop = RT.node_at(bw, "plant/loop")
say("022 loop wires", loop.wires)
say("022 port types", unique(typeof(w.from.port) for w in loop.wires))

# S13d-032: pinned_by shape, empty one encoded
pf = descriptor(build(RT.pinned_fanout())).build.structure.root_inputs
say("032 rows", [(r.name, r.pinned_by, typeof(r.pinned_by)) for r in pf])
say("032 json", JSON.json([r.pinned_by for r in pf]))

# S13d-042 / S13d-001: primitive node keys; faces vs the tier reader at Float64
pg = build(RT.fed(RT.PinnedGain(), "e"))
pgd = descriptor(pg).build
for n in pgd.structure.nodes
    say("042 node keys $(repr(n.path))", keys(n))
end
for entry in pg.structure.components
    say("001 contract_at $(entry.path) tier=$(entry.tier)", R.declared_at(u_types, entry.instance, entry.tier))
    say("001 raw $(entry.path)", R.invoke_declaration(u_types, entry.instance))
end
say("001 descriptor faces", [(n.path, n.inputs) for n in pgd.structure.nodes if n.class == "primitive"])

# S13d-052: unfactored flag
ug = descriptor(build(RT.unfactored_model())).build.structure.grid
say("052 primes", ug.primes)

# S13d-062: deployment body order vs Deployment fields
dep = Deployment(build(RT.MultiRate()); Δt_frame = 1//500, h_max = 1//1000, h_min = 1//100000, algorithm = BS3())
dd = descriptor(dep).deployment
say("062 body keys", keys(dd))
say("062 fields", fieldnames(Deployment))

# S13d-072: schedule rows vs discrete primitives in walk order
for (label, model) in (("multirate", RT.MultiRate()), ("chained", RT.chained_model()), ("vehicle", RT.Vehicle()))
    bb = build(model)
    depl = try
        Deployment(bb; Δt_frame = 1//500)
    catch err
        try Deployment(bb; Δt_frame = 1//1) catch err2; say("072 $label deploy failed", sprint(showerror, err2)); continue end
    end
    body = descriptor(depl).deployment
    walk = [n.path for n in body.build.structure.nodes if n.class == "primitive" && n.tier == "discrete"]
    say("072 $label rows", [(r.path, r.D, r.phi) for r in body.schedule.rows])
    say("072 $label walk discrete", walk)
    say("072 $label match", [r.path for r in body.schedule.rows] == walk)
end

# S13d-082 / S13d-092: kind markers
for T in (Float64, Float32, BigFloat, AbstractFloat, Float16, Tuple{Float64, Int}, Tuple{Float64, Float64})
    say("082/092 marker $T", R._kind_marker(T))
end

# S13d-102: located declarations
say("102 count", length(R.LOCATED_DECLARATIONS))
say("102 names", nameof.(R.LOCATED_DECLARATIONS))

# S13d-112: an empty NamedTuple parameter
struct EmptyNT <: R.AbstractComponent
    fixed::NamedTuple{(),Tuple{}}
    g::NamedTuple
end
say("112 params", R._parameters(EmptyNT((;), (a = 1.0, b = (;), c = (d = 2,)))))

# S13d-133: `function` per probe-chain kind
for (label, c) in (("ReadsM", RT.ReadsM()), ("ReadsU", RT.ReadsU()), ("Thrower", RT.Thrower()),
                   ("DeadStateStage", RT.DeadStateStage()), ("BadDerivative", RT.BadDerivative()),
                   ("Undeclared", RT.Undeclared()))
    err = RT.failure(() -> build(RT.single(c)))
    row = only(descriptor(err).failure.diagnostics)
    say("133 $label", (row.kind, haskey(row, :function) ? row.var"function" : "<none>",
                        first(split(row.message, '\n'))))
end
