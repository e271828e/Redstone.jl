using Redstone, StaticArrays, LinearAlgebra, ForwardDiff, Test
W = "/Users/miguel/.julia/dev/Redstone.jl-worktrees/doc_conformance"
include(joinpath(W, "test/imports.jl"))
include(joinpath(W, "test/fixtures.jl"))
include(joinpath(W, "test/utils.jl"))
const R = Redstone
readable() = Group((; plant = Plant(), ctl = DiscreteAccumulator(3.0), src = ModedSource());
                   input_wires = ("u" => "plant/u", "e" => "ctl/e"),
                   output_wires = ("plant/y" => "y",))
readable_condition(q = SVector(0.3, -0.2), acc = 4.0) =
    combine(at("plant", set(x = (q = q,))),
            at("ctl", set(s = (acc = acc,))),
            at("src", set(m = (phase = :running,))),
            set(u = (u = 1.5, e = 0.0)))
p(tag, x) = println("PROBE[", tag, "] ", x)
diag(f) = (e = failure(f); e === nothing ? :no_error : e isa DiagnosticError ?
           [(nameof(typeof(d)), hasproperty(d, :reason) ? d.reason : nothing) for d in (e.carried isa Vector ? e.carried : [e.carried])] : e)

# signatures
for f in (get_state, get_deriv, get_output, get_input, get_face)
    p("methods $(nameof(f))", [m.sig for m in methods(f)])
end
p("defaults", (get_state("a"), get_deriv("a"), get_output("a"), get_input(), get_face()))

rb = build(readable())   # plant (x q, named ports y, power), ctl discrete, src mode store
# 004: store selectors under a table source
p("004 table get_state", diag(() -> R._compile_reads(reads(a = get_state("plant", :q)), rb, Float64; source = :table)))
p("004 table get_deriv", diag(() -> R._compile_reads(reads(a = get_deriv("plant", :q)), rb, Float64; source = :table)))
p("004 exec get_state ok", diag(() -> R._compile_reads(reads(a = get_state("plant", :q)), rb, Float64)))
sim = Simulation(readable(); Δt_frame = 1//10)
init!(sim, readable_condition())
step!(sim)
p("004 series get_state", diag(() -> series(sim, reads(a = get_state("plant", :q)))))
p("004 series get_output ok", diag(() -> series(sim, reads(a = get_output("plant", :y)))))

# 013: get_output
bb = build(bare_ports_world())
p("013 bare ports world paths", paths(bb.structure))
bw = build(bare_world())
p("013 headless on bare-y port (acc, named y)", diag(() -> R._compile_reads(reads(a = get_output("acc")), bw, Float64; source = :table)))
p("013 headless bare-y spin whole", diag(() -> R._compile_reads(reads(a = get_output("plant/spin")), bb, Float64; source = :table)))
p("013 headless bare-y spin [2]", diag(() -> R._compile_reads(reads(a = get_output("plant/spin", "[2]")), bb, Float64; source = :table)))
p("013 bare-y spin :y", diag(() -> R._compile_reads(reads(a = get_output("plant/spin", :y)), bb, Float64; source = :table)))
p("013 named y on bare (acc, :y)", diag(() -> R._compile_reads(reads(a = get_output("acc", :y)), bw, Float64; source = :table)))
p("013 assembly path", diag(() -> R._compile_reads(reads(a = get_output("", :y)), rb, Float64; source = :table)))
p("013 undeclared port", diag(() -> R._compile_reads(reads(a = get_output("plant", :nope)), rb, Float64; source = :table)))
p("013 bad step", diag(() -> R._compile_reads(reads(a = get_output("plant", "y[2]")), rb, Float64; source = :table)))
p("013 headless on named ports", diag(() -> R._compile_reads(reads(a = get_output("plant")), rb, Float64; source = :table)))
p("013 snapshot ok + exec ok", (diag(() -> R._compile_reads(reads(a = get_output("plant", :y)), rb, Float64; source = :table)),
                                 diag(() -> R._compile_reads(reads(a = get_output("plant", :y)), rb, Float64))))

# 022: reads
p("022 type", typeof(reads(a = get_state("plant", :q))))
p("022 non-selector", diag(() -> reads(a = 1.0)))
p("022 unknown path", diag(() -> R._compile_reads(reads(a = get_state("nope", :q)), rb, Float64)))
p("022 other", diag(() -> R._compile_reads(reads(a = get_state("plant", :zz)), rb, Float64)))
p("022 series unknown path", diag(() -> series(sim, reads(a = get_output("nope", :y)))))

# 028: m stores and the letter
p("028 latch get_state headless", diag(() -> R._compile_reads(reads(a = get_state("latch")), bw, Float64)))
p("028 latch get_state m", diag(() -> R._compile_reads(reads(a = get_state("latch", :m)), bw, Float64)))
p("028 latch get_state x", diag(() -> R._compile_reads(reads(a = get_state("latch", :x)), bw, Float64)))
p("028 src (mode only) get_state headless", diag(() -> R._compile_reads(reads(a = get_state("src")), rb, Float64)))
p("028 src get_state :phase", diag(() -> R._compile_reads(reads(a = get_state("src", :phase)), rb, Float64)))
p("028 tick get_state headless", diag(() -> R._compile_reads(reads(a = get_state("tick")), bw, Float64)))
p("028 acc get_deriv headless", diag(() -> R._compile_reads(reads(a = get_deriv("acc")), bw, Float64)))
