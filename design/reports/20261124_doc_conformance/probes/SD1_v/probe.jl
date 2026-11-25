# SD1 verifier probes, run from the pinned worktree with --project=test.
module SD1Probe
using Test, StaticArrays, LinearAlgebra, ForwardDiff, BenchmarkTools
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test"
include(joinpath(W, "imports.jl"))
include(joinpath(W, "fixtures.jl"))
include(joinpath(W, "utils.jl"))
import Redstone: x_init, u_types, y_types, y_direct, activation, output_faces, input_faces, local_wires, input_wires

report(id, x) = println(id, " => ", x)
tryb(f) = try f() catch e; e isa DiagnosticError ? map(d -> (typeof(d), d), diagnostics(e)) : e end

# P1 SD1-005: abstract entry alone at a root input vs. beside a concrete co-consumer
struct VecReader <: AbstractComponent end
x_init(::VecReader) = nothing
u_types(::VecReader) = (v = AbstractVector{Float64},)
y_types(::VecReader) = (n = Float64,)
y_direct(::VecReader, (; u)) = (n = sum(u.v),)
struct SVecEntry <: AbstractComponent end
x_init(::SVecEntry) = nothing
u_types(::SVecEntry) = (v = SVector{3,Float64},)
y_types(::SVecEntry) = (y = Float64,)
y_direct(::SVecEntry, (; u)) = (y = sum(u.v),)
_fv(a, b) = Group((a = a, b = b); input_wires = ("in" => ("a/v", "b/v"),))
report("P1 alone", tryb(() -> build(TerrainGain())))
report("P1 co-consumer builds", tryb(() -> build(_fv(VecReader(), SVecEntry())) isa Build))
report("P1 co-consumer root_inputs", build(_fv(VecReader(), SVecEntry())).structure.root_inputs)

# P2 SD1-114, SD1-138: a bare contract's port face
report("P2 BareScale input_faces", input_faces(BareScale()))
report("P2 BareScale output_faces", output_faces(BareScale()))
report("P2 bare wire by face", tryb(() -> build(bare_loop()) isa Build))

# P3 SD1-129, SD1-164: cells vs output ports and root inputs
let b = build(bare_world()), act = activation(b, Float64)
    report("P3 root_inputs", b.structure.root_inputs)
    report("P3 addr keys", sort(collect(keys(act.layout.addr))))
    report("P3 distinct cells", length(unique(values(act.layout.addr))))
    report("P3 output ports", sum(length(Redstone._ports(c)) for c in b.outputs.components))
    report("P3 root input addrs", [(k, v) for (k, v) in act.layout.addr if first(k) == ""])
end
report("P3 primitive root inputs", build(Plant()).structure.root_inputs)

# P4 SD1-048, SD1-058: generic holding
struct GenHolder <: AbstractComponent
    plant::AbstractComponent
    neg::Negator
end
local_wires(::GenHolder) = ("plant/y" => "neg/u",)
input_wires(::GenHolder) = ("u" => "plant/u",)
report("P4 holds Plant", tryb(() -> build(GenHolder(Plant(), Negator())) isa Build))
report("P4 holds BareRamp", tryb(() -> build(GenHolder(BareRamp(), Negator()))))

# P5 SD1-088: a primitive with only one output stage builds
report("P5 Negator alone (y_direct only)", tryb(() -> build(single(Negator())) isa Build))
report("P5 BareRamp alone (y_state only)", tryb(() -> build(BareRamp()) isa Build))

# P6 SD1-001: glossary order check
let lines = readlines(joinpath(W, "..", "design", "spec.md"))
    group = ""; prev = ""
    for (i, l) in enumerate(lines)
        i < 16091 && continue
        startswith(l, "### D.") && (group = l; prev = ""; continue)
        startswith(l, "## Appendix E") && break
        m = match(r"^<a id=\"g-[^\"]+\"></a>\*\*(.+?)\*\*", l)
        m === nothing && continue
        key = lowercase(replace(m.captures[1], r"[`*()]" => "", "the " => ""))
        key < prev && report("P6 out of order", (i, group, prev, key))
        prev = key
    end
end
end
