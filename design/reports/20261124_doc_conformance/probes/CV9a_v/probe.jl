# CV9a verifier probes. Run from the pinned worktree with --project=test.
module CV9aV
using Test, StaticArrays, LinearAlgebra, ForwardDiff
using Redstone
const W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance/test/"
include(W * "imports.jl")
include(W * "fixtures.jl")
include(W * "utils.jl")
const R = Redstone

say(id, x) = println(id, " => ", x)
function caught(f)
    try
        return (:no_throw, f())
    catch e
        return e
    end
end
kk(e::DiagnosticError) = e.carried isa Vector ? [(typeof(d).name.name, hasfield(typeof(d), :reason) ? d.reason : nothing, R.path(d)) for d in e.carried] : [(typeof(e.carried).name.name, hasfield(typeof(e.carried), :reason) ? e.carried.reason : nothing, R.path(e.carried))]
kk(e) = e

# --- 003: Δt placeholder and frozen probe-nothing in probe_stage1
const SEEN_DT = Any[]
struct DtTick <: AbstractComponent end
s_init(::DtTick) = 0.0
y_types(::DtTick) = Float64
y_state(::DtTick, (; s, Δt)) = (push!(SEEN_DT, Δt); s)
s_update(::DtTick, (; s)) = s
struct DtFlow <: AbstractComponent end
x_init(::DtFlow) = 1.0
y_types(::DtFlow) = Float64
y_state(::DtFlow, (; x)) = x
x_deriv(::DtFlow, (; x)) = -x
let b = build(Group((; d = DtTick(), f = DtFlow())))
    n1 = length(SEEN_DT)
    act = activation(b, ProbeDual)
    say("003 Δt seen nominal", SEEN_DT[1:n1])
    say("003 calls at ProbeDual (should be 0 new)", length(SEEN_DT) - n1)
    nom = activation(b, Float64)
    ci = findfirst(e -> e.path == "d", b.structure.components)
    say("003 frozen product carried", (act.products[ci], nom.products[ci], typeof(act.products[ci][1])))
end

# --- 011: port with the name left out at an assembly exporting a lone face y
inner() = Group((; r = BareRamp()); output_wires = ("r/y" => "y",))
let m = Model(Group((; a = inner())); Δt_frame = 1)
    say("011 port(m, \"a\", :y)", caught(() -> port(m, "a", :y)))
    e = caught(() -> port(m, "a"))
    say("011 port(m, \"a\") type", typeof(e)); e isa Exception && say("011 msg", sprint(showerror, e))
    say("011 port(m, \"a/r\")", caught(() -> port(m, "a/r")))
end
let m = Model(inner(); Δt_frame = 1)
    e = caught(() -> port(m, ""))
    say("011 root assembly face y, name left out", typeof(e))
end

# --- 013: IllegalPortType reasons from cell_layout
struct NoLeaf end
struct Opaque; s::Symbol; end
struct ReasonPorts <: AbstractComponent end
x_init(::ReasonPorts) = nothing
u_types(::ReasonPorts) = (h = Symbol, f = StopFlag)
y_types(::ReasonPorts) = (a = Vector{Float64}, b = NoLeaf, c = Tuple{StopFlag,Float64})
y_direct(::ReasonPorts, (; u)) = (a = [1.0], b = NoLeaf(), c = (StopFlag(), 1.0))
let e = caught(() -> build(Group((; c = ReasonPorts()); input_wires = ("h" => "c/h", "f" => "c/f"))))
    say("013 all", kk(e))
    say("013 reasons", e isa DiagnosticError ? [(d.site, d.name, d.reason, d.position) for d in e.carried if d isa IllegalPortType] : e)
    say("013 default reason", IllegalPortType(path = "", site = :port, name = :a, declared = Int).reason)
end

# --- 017: Activation fields
say("017 Activation fields", fieldnames(R.Activation))

# --- 024, 037: x_projection probed at a Dual activation; carrier takes the structure
struct DualProj <: AbstractComponent end
x_init(::DualProj) = 1.0
y_types(::DualProj) = Float64
y_state(::DualProj, (; x)) = x
x_deriv(::DualProj, (; x)) = -x
const PROJ_SEEN = Any[]
x_projection(::DualProj, x) = (push!(PROJ_SEEN, typeof(x)); x isa Float64 ? x : error("dual projection"))
let e = caught(() -> build(single(DualProj()); activations = (Float64, ProbeDual)))
    say("037 projection arg types", PROJ_SEEN)
    say("037 build at ProbeDual", kk(e))
    e isa DiagnosticError && say("024 carrier structure", typeof(e.structure))
end
let e = caught(() -> build(Group((; a = BareScale())); ))  # unfed input? structure-step failure
    say("024 structure-step failure", e isa DiagnosticError ? (kk(e), e.structure) : e)
end

# --- 034, 035, 036: completeness pass before the update laws
struct NotProduced <: AbstractComponent end
x_init(::NotProduced) = (q = 1.0,)
y_types(::NotProduced) = (a = Float64, b = Float64)
y_state(::NotProduced, (; x)) = (a = x.q,)
x_deriv(::NotProduced, (; x)) = "bad"
let e = caught(() -> build(single(NotProduced())))
    say("034 completeness vs bad x_deriv", kk(e))
    e isa DiagnosticError && (d = e.carried[1]; say("036 fields", (d.ports, d.products, d.state_fields)))
end
struct BadProjOnly <: AbstractComponent end
x_init(::BadProjOnly) = (q = 1.0,)
y_types(::BadProjOnly) = (a = Float64,)
y_state(::BadProjOnly, (; x)) = (a = x.q,)
x_deriv(::BadProjOnly, (; x)) = "bad"
x_projection(::BadProjOnly, x) = "badproj"
let e = caught(() -> build(single(BadProjOnly())))
    say("034 update pass before projection pass", kk(e))
end
struct DiscProj <: AbstractComponent end
s_init(::DiscProj) = 0.0
y_types(::DiscProj) = Float64
y_state(::DiscProj, (; s)) = s
s_update(::DiscProj, (; s)) = s
x_projection(::DiscProj, x) = x
let e = caught(() -> build(single(DiscProj())))
    say("035 projection on discrete", kk(e))
end

# --- 049: a root input read before init! holds its probe value
struct Probed; v::Float64; end
probe_value(::Type{Probed}) = Probed(42.0)
struct ProbedSink <: AbstractComponent end
x_init(::ProbedSink) = nothing
u_types(::ProbedSink) = (p = Probed,)
y_types(::ProbedSink) = (y = Float64,)
y_direct(::ProbedSink, (; u)) = (y = u.p.v,)
let m = Model(Group((; k = ProbedSink()); input_wires = ("p" => "k/p",)); Δt_frame = 1)
    say("049 status", m.status)
    say("049 root input before init!", caught(() -> port(m, "", :p)))
    say("049 downstream before init!", caught(() -> port(m, "k", :y)))
    say("049 layout root_inputs", m.exec.act.layout.root_inputs)
end

# --- 050: a non-NamedTuple update return is one entry among others
struct ShapeBad <: AbstractComponent end
x_init(::ShapeBad) = (q = 1.0,)
y_types(::ShapeBad) = (a = Float64,)
y_state(::ShapeBad, (; x)) = (a = x.q,)
x_deriv(::ShapeBad, (; x)) = 1.0                    # not a NamedTuple
struct FieldBad <: AbstractComponent end
x_init(::FieldBad) = (q = 1.0,)
y_types(::FieldBad) = (a = Float64,)
y_state(::FieldBad, (; x)) = (a = x.q,)
x_deriv(::FieldBad, (; x)) = (r = 1.0,)             # wrong field set
struct BareGotNT <: AbstractComponent end
x_init(::BareGotNT) = 1.0
y_types(::BareGotNT) = (a = Float64,)
y_state(::BareGotNT, (; x)) = (a = x,)
x_deriv(::BareGotNT, (; x)) = (x = 1.0,)            # NamedTuple against a bare state
let e = caught(() -> build(Group((; s = ShapeBad(), f = FieldBad(), b = BareGotNT()))))
    say("050 update pass", kk(e))
end
struct ProjShape1 <: AbstractComponent end
x_init(::ProjShape1) = (q = 1.0,)
y_types(::ProjShape1) = (a = Float64,)
y_state(::ProjShape1, (; x)) = (a = x.q,)
x_deriv(::ProjShape1, (; x)) = (q = -x.q,)
x_projection(::ProjShape1, x) = 1.0
struct ProjShape2 <: AbstractComponent end
x_init(::ProjShape2) = (q = 1.0,)
y_types(::ProjShape2) = (a = Float64,)
y_state(::ProjShape2, (; x)) = (a = x.q,)
x_deriv(::ProjShape2, (; x)) = (q = -x.q,)
x_projection(::ProjShape2, x) = (r = 1.0,)
let e = caught(() -> build(Group((; p = ProjShape1(), q = ProjShape2()))))
    say("050 projection pass", kk(e))
end
end
