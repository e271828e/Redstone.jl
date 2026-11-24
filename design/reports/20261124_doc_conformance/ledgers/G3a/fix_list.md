# G3a: rows for the fixer

Each row: the site at the pinned tip d7d3ddff, the claim, the verifier's evidence and proposed fix, and its note. The fix is a proposal: conform it to the rules and to the code.

## S9b-280 (deviation, clear=True)

- at: `design/spec.md:5561`
- claim: framework methods cover three kinds of type: Real, Bool, enums
- evidence: src/declare.jl:932-936 has framework methods for Real (zero), Bool (false), Enum (first instance), StaticArray (zero(P)) and the P() fallback. The StaticArray arm is a fourth kind that the doc does not list. Probe: probe_value(SVector{3,Float64}) dispatches to declare.jl:935 and returns zeros, while SVector{3,Float64}() throws DimensionMismatch, so the arm changes behaviour. A root input of type SVector{3,Float64} builds. The arm has been in the code since a9f52a4c (walking skeleton), and no record mentions it.
- fix: Framework methods cover four kinds of type:

- `Real`, with `zero(T)`;
- `Bool`, with `false`;
- enums, with their first instance;
- `StaticArray`, with `zero(T)`.
- note: The same three-kind list appears in the glossary's probe value entry (spec.md:16790) and in D-051's Position, so a fix there may need to match.

## S9b-298 (drift, clear=True)

- at: `design/spec.md:5583`
- claim: abstract entries only occur on component-fed inputs
- evidence: src/build.jl:916-933: a root input takes its type from the one concrete consumer entry, and abstract co-consumers are admitted under the bound clause. Probe: Group(n = Negator(), a = AbsIn() with u_types (u = Real,)), input_wires ('in' => ('n/u', 'a/u')) builds with root type Float64. The abstract entry `Real` on a/u is fed by the root input, not by a component. Synthesis still meets only the concrete type.
- fix: Abstract entries occur only on component-fed inputs, which the probe sources from upstream products, and on a root input's abstract co-consumers, which receive the value synthesized at its one concrete declaration ([§8.2][s8-2], [D-236][d-236]).
- note: D-236 (abstract co-consumers checked by the bound clause) and spec §8.2 at spec.md:3123-3124 record the fan-out rule.

## S9c-032 (drift, clear=True)

- at: `design/spec.md:5706`
- claim: only y_state, y_direct and x_deriv see a Dual, so only they are probed at it
- evidence: src/build.jl:1145-1166 probes x_projection at every activation, T included; src/build.jl:1607-1614 puts projection entries in every executable set; probe: x_projection saw ForwardDiff.Dual{ProbeTag,Float64,1} during activation(b, ProbeDual)
- fix: Only the continuous output stages (`y_state`/`y_direct`), `x_deriv` and `x_projection` ever see a `Dual`. So only they are probed at it.
- note: D-111 (later than D-052) folds the projection into the check at the activation's T, and spec.md:5963 already says so; the 5706 bullet kept D-052's list.
- coordinator: G3b's CV9a-037 names the same fix; one edit covers both.

## S9c-132 (deviation, clear=True)

- at: `design/spec.md:5885`
- claim: didactic message reads 'field `M_shaft`: expected `Float64`, got `Int64` — return `zero(x.ω)`, not `0`'
- evidence: src/diagnostics.jl:1142-1148 and 1167-1169; probe on a Shaft returning M_shaft = 0: "y_state returns `M_shaft`::Int64, declared Float64 — an integer literal where a real was declared: return `zero(…)` of a value at the activation, not `0`"
- fix: The error can afford to be didactic, as in "`y_state` returns `M_shaft`::Int64, declared Float64 — an integer literal where a real was declared: return `zero(…)` of a value at the activation, not `0`".

## S9d-001 (drift, clear=True)

- at: `design/spec.md:6058`
- claim: Outputs holds paths, stage names and execution order as plain data
- evidence: src/build.jl:576-580 and 616-619: Outputs holds `components::Vector{ComponentOutputs}` (each `path`, `stage1`, `stage2`, which are port-name vectors) and `order::Vector{Int}`. It holds no stage names. Probe P3: `ComponentOutputs("c", [:out], Symbol[])`.
- fix: On [`Outputs`](#g-outputs) (the nominal evaluation's product, the port classes and the execution order) it is plain printable data ([§9.2][s9-2]), namely paths, the port names each stage produces, and order.
- note: The phrase "paths, stage names, order" comes from f9e2cacb's old §14.7, which described the Build's schedule. D-253 and the glossary entry g-outputs (spec.md:16775) now describe per-component stage-1/stage-2 port name sets. Paths and order match. "Stage names" is wrong only if read literally, since D-253 itself says "stage-1 and stage-2 name sets".

## S9d-010 (deviation, clear=True)

- at: `design/spec.md:6090`
- claim: A cell address is a build-time offset carried in an entry field with the port type as its parameter
- evidence: src/store.jl:11-13 `struct CellAddr{P,K}; offsets::NTuple{K,Int}` has one offset per distinct leaf eltype. src/build.jl:433-434 builds it with `length(eltypes)` offsets. Probe P2: MixedCell's port address is `CellAddr{TaggedValue{Float64},2}` with offsets (0, 0), across the Float64 and Int blocks. test/test_store.jl:56-61 does the same. Field carriage and the port-type parameter match: executor.jl:56-60, store.jl:11.
- fix: A cell address is a build-time offset into each block its leaves occupy, one per element type, so a mixed-leaf cell spans several blocks. The offsets are carried in an entry *field*, with the port type as the address's own parameter.
- note: The spec never says that a cell can span several element-type blocks. The store.jl:1-9 comment cites a 2026-08-20 'C2M' bench that appears in no spec or log text. D-162's Position says 'build-time offsets' in the plural, which fits either reading.
