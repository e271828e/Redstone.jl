# G6d: rows for the fixer

Each row: the site at the pinned tip cb398676, the claim, the verifier's evidence and proposed fix, and its note. The fix is a proposal: conform it to the rules and to the code.

## CV6a-051 (deviation, clear=True)

- at: `src/bindings.jl:199`
- claim: code_map.md's src/bindings.jl entry (94-104) lists the binding's runtime half
- evidence: design/code_map.md:96-104 names TableBinding, map_input/_map_channel, _condition, the reads' contract checks and _compile_binding_reads. It never names map_output, which src/bindings.jl:182-199 declares as the output side's convention function (`function map_output end`). The bindings.jl header at lines 1-6 counts it in the runtime half. rg finds no map_output anywhere in code_map.md. The entry has never listed it: implementation.md at 68fd586d and code_map.md since 54d4230a and a630deaa omit it too.
- fix: Add to the src/bindings.jl entry: "- The output side's convention name `map_output`, declared for the loop idiom with no method."

## CV6a-017 (drift, clear=True)

- at: `src/leaves.jl:11`
- claim: Comment 'Shared by both candidates ... C2 then reuses it for cells; C1 uses it only for state' points at the two cell-store candidates of the pre-D-162 bench
- evidence: src/leaves.jl:9-11 still speaks of 'both candidates' C1/C2. D-162 (design/log.md:6283-6290, ratified) adopted C2, the per-eltype homogeneous cell stores, and src/store.jl:1-9 and :46-71 reuse the leaf walk (_mreconstruct_expr/_mflatten_expr) for cells. No C1 path exists. The comment dates from a9f52a4c, the bench-era skeleton, and f672fc5e settled the choice.
- fix: # The continuous state buffer is flat by decision (§7.1), and the per-eltype cell stores (D-162) reuse the same flatten/reconstruct machinery for cells.

## CV6a-019 (drift, clear=True)

- at: `src/leaves.jl:28`
- claim: nleaves docstring: 'Number of activation-scalar leaves a value of type P occupies in a flat buffer'
- evidence: src/leaves.jl:31-34 counts one leaf per Real, enum or opaque leaf, whatever its eltype. Probe probe.jl:36 gives nleaves(Tuple{Int,Bool,Float64}) = 3, (Int, enum) gives 2, and an opaque HasSym or a Symbol gives 1. None of those are activation-scalar leaves. The enum arm came in 88ee89ce and the opaque arm in 85ba3bd6 (D-237), after the docstring was written in a9f52a4c.
- fix: Number of leaves a value of type `P` occupies in a flat buffer, one per real, enum or opaque leaf, whatever its eltype. Layout-time only — never on an evaluation path.

## CV6a-011 (deviation, clear=True)

- at: `src/store.jl:149`
- claim: code_map.md:1353 and the comment at store.jl:147 say capture_stores makes one boundary's fresh copy 'one allocation per boundary'
- evidence: src/store.jl:149 copies every eltype buffer. Probe probe.jl:64-66 measures capture_stores at 2 allocations with one eltype, 4 with two and 6 with three (a Vector copy is 2 allocations on Julia 1.13.3). test/test_diagnostics.jl:111 compares publish! against @allocations(capture_stores(...)) rather than a fixed 1. The wording came in bccd9a56 (2026-08-25), after the per-eltype split 3f167a06 (2026-08-18), and nothing records the gap.
- fix: code_map.md:1353 '`capture_stores`, one boundary's fresh copy of a bundle, a fresh buffer per eltype store (§9.8).' and store.jl:147 '# One boundary's capture: a fresh buffer per eltype store — the framework side of §9.8's scope, which carved publication and logging out.'

## CV6a-015 (deviation, clear=True)

- at: `src/store.jl:237`
- claim: code_map.md's src/store.jl entry (1348-1386) omits activation_scalar
- evidence: src/store.jl:236-237 defines activation_scalar(::Clock{T}) = T, which executor.jl:170, 176, 264, 403 and 462 use for every conformance check's activation. rg finds no activation_scalar in design/code_map.md, whose src/store.jl entry (1348-1386) lists the Clock and its helpers but not this one. Probe probe.jl:70 returns Float32 for a Clock{Float32}.
- fix: Add to the Clock bullet's sub-list in the src/store.jl entry: '- `activation_scalar`, the scalar an executor runs at, read off its clock (§9.4);'

## CV6b-050 (drift, clear=True)

- at: `src/Redstone.jl:35`
- claim: code_map.md:845-846 says nothing in the package depends on library.jl, so src/Redstone.jl includes it last
- evidence: src/Redstone.jl:35-36 includes library.jl and then precompile.jl, and src/precompile.jl:19-24 builds its workload from Library.Step, Library.DiscretePID, Library.FirstOrderLag, Library.SumJunction, Library.TransferFunction and Library.LimitedIntegrator. So precompile.jl depends on the library, and the library is not the last include. code_map.md:33, in the Redstone.jl entry, already lists 'library, precompile'.
- fix: Nothing in the package depends on it but the precompile workload, so `src/Redstone.jl` includes it last but for `precompile.jl`.
- note: Commit a88b8795 added the precompile workload over the library's components and the include after library.jl.

## CV6b-009 (drift, clear=True)

- at: `src/library.jl:118`
- claim: spec.md §6.2 (lines 1773, 1793, 1805) says the junction has one output, `out`, wired as "wr_sum/out"
- evidence: src/library.jl:118 `y_types(::Junction{In, Out}) where {In, Out} = Out` is a bare output contract, so its face is `y` (D-437). Probe P1e shows that SumJunction's y_types is the bare Float64, and test fixtures wire 'force/y'. spec.md:1773 still says 'one output, `out`', and :1793 and :1805 say "wr_sum/out".
- fix: spec.md:1773 'and one output, `y`'; :1793 '"wr_sum/y"  => "dynamics/wr_ext",'; :1805 '`"wr_sum/y"` is an ordinary port.'
- note: Commit 4d79875c made the library's single-port outputs bare, and D-437 (ratified) gives a bare output the face `y`. D-437 says the addresses move in the inventory and the companions, but the §6.2 example was never swept.
- coordinator: Same §6.2 sites as G6a's S6e-005, S6e-011, S6e-016 and S6e-022; one edit per site covers both.

## CV6b-012 (deviation, clear=True)

- at: `src/library.jl:190`
- claim: code_map.md:837-842 says every component with one input or one output declares that contract bare, and only a side with two or more ports stays named (apart from Fields's outputs)
- evidence: src/library.jl:116-117 and :193 give the inputs and outputs names at every arity. Probe P1a-P1c: Junction{Float64,Float64,1} u_types is (in1 = Float64,), Pack{Float64,1} is (in1 = Float64,) and Unpack{Float64,1} y_types is (out1 = Float64,). P1d shows that a one-input Junction builds. So a component with one input or one output can keep that side named, which contradicts 'only a side with two or more ports stays named'. The Fn docstring (src/library.jl:139-140) says the same thing: Fn is 'the one-input Junction with its input bare'.
- fix: ... a side with two or more ports stays named, as do `Fields`'s outputs at any count, since the fields name them, and the inputs of a `Junction` and the outputs of `Unpack` at any count, `in1` and `out1` at one (§13.5, §13.7, D-437).

## CV6b-018 (deviation, clear=True)

- at: `src/library.jl:459`
- claim: Comment cites '§7.1's "few KB comfortable"' for the element count past which an array keyword's SArray compiles slowly
- evidence: src/library.jl:457-459 cites '§7.1's "few KB comfortable"'. The phrase sits at spec.md:2931, under §8.2 The declaration inventory, #### Workspace idioms. §7.1 (spec.md:2184-2267) says nothing about SArray compile cost or a size ceiling. The sentence was already under §8.2 when the comment landed in commit 4a818b2d.
- fix: # every stage that touches it and gains nothing over a plain array; §8.2's
# "few KB comfortable" at `Float64`.
- coordinator: A comment only. The matching @warn string (CV6b-019) is code and is not yours to change.

## CV6b-022 (drift, clear=True)

- at: `src/library.jl:536`
- claim: companions/library_inventory.md:330 lists `Delay(; K, v0)` with 'one output'
- evidence: src/library.jl:535-547: Delay(; K::Int, v0 = 0.0, taps::Bool = false), with y_types bare V for taps = false and (y = V, taps = SVector{K, V}) for taps = true. Probe P4b shows (y = Float64, taps = SVector{2, Float64}). The same companion records the taps output at library_inventory.md:430-439, but its table row at :330 still reads 'Delay(; K, v0)' with 'one output'.
- fix: | `Delay(; K, v0, taps)` | shipped | the tier's `z⁻ᴷ` in a ring store, `K` ticks of the component's own period ([§6.3][s6-3]), the one output `y`, or with `taps = true` the outputs `y` and `taps`, the last `K` inputs; `K = 1` the `UnitDelay` in keyword spelling |
- note: Commit f9b4ccf9 'Add the taps output on Delay ...' (increment 89).

## CV6b-036 (drift, clear=True)

- at: `src/library.jl:1172`
- claim: companions/library_inventory.md:440-443 says a root set is refused when 'a product whose imaginary part is not zero to rounding' results, which conjugate pairs pass
- evidence: src/library.jl:1166-1186: coefficients_from_roots pairs each complex root with a conjugate within 1e-12·|root| before the expansion and refuses a root with no partner. Its comment says the check on the expanded coefficients' imaginary parts was dropped because it refused exact sets of ten conjugate pairs. Probe P5b refuses an unpaired root with '... has no conjugate'. P5c accepts ten conjugate pairs on a circle.
- fix: Roots real or complex; a complex root with no conjugate partner, to a tolerance relative to the root, is refused, and the real coefficients then meet the existing refusals.
- note: Commit deb0bb38 'Fix increment 89's review findings: pair conjugate roots before the expansion ...'.
- coordinator: May be the same library_inventory.md site as G6b's K6b-100; if so, one edit covers both.
