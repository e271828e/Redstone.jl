# G1a, §13: rows for the fixer

Each row: the doc site at the pinned tip 89a10a14, the claim, the verifier's evidence and proposed fix, and its note. The fix is a proposal: conform it to the rules and to the code. Every row here is clear by the brief's test.

## S13a-126 (drift, clear=True)

- at: `design/spec.md:11326`
- claim: The committed runtime warnings, in one place, are these (the list names every runtime warning kind).
- evidence: src/dataplane.jl:36-38 KINDS and src/diagnostics.jl:1652-1664,1732 include the runtime warning StepFloor (§10.2, D-460), which the §13.2 list omits.
- fix: Add a bullet after `FiringBudget`: "- `StepFloor`, a floor step ([§10.2][s10-2], [D-460][d-460]). An adaptive step is taken at the floor `h_min`, accepted though its error test failed or reached once the step spent its `attempt_budget`, and is reported at most once per frame into the model's own diagnostic cell."

## S13a-127 (drift, clear=True)

- at: `design/spec.md:11328`
- claim: ChatteringBudget reports chattering or localization-budget exhaustion
- evidence: src/frame.jl:231-243: the budget test is `localizations ≥ model.deployment.localization_budget`, the frame's count across all events and steps (D-446), and a ChatteringBudget is reported per triggered event at the step end; the doc calls it 'the event's bracketing budget'.
- fix: `ChatteringBudget`, for chattering or localization-budget exhaustion ([§10.4][s10-4]). A localized event's crossing instant is bracketed by root-finding. The frame's localization budget, counted across all its steps, runs out, and the event's further crossings that frame fire at boundary granularity.

## S13b-001 (drift, clear=True)

- at: `design/spec.md:11459`
- claim: A runtime failure is a throw inside a frame or inside boundary zero
- evidence: src/model.jl:473-477 (overlay! catch, host :overlay) and src/model.jl:1333-1336 (restore catch, host :restore) wrap throws of model code run in their settling, beside src/frame.jl:85-95 (:loop) and src/model.jl:333-337 (:boundary_zero)
- fix: A runtime failure of model code is a throw inside a [frame](#g-frame) (one iteration of the loop), inside [boundary zero](#g-boundary-zero), or inside the settling `overlay!` or `restore!` runs.
- note: The same section already names the :overlay and :restore hosts at spec 11530-11532. Only this opening scope sentence lags them.
- backing entry: D-429, D-441

## S13b-051 (drift, clear=True)

- at: `design/spec.md:11556`
- claim: A bare value thrown deliberately by model code is refused by the constructor, so it propagates from the catch unwrapped
- evidence: Probe: x_deriv throwing 42 makes frame! throw a MethodError (not 42), with status :inconsistent. test/test_failures.jl:706-712 asserts the MethodError. src/model.jl:1080 builds StepError(..., _species(model, err)) inside rethrow, so the constructor's MethodError escapes in place of the value
- fix: A bare value thrown deliberately by model code is neither, and the constructor refuses it with a `MethodError` inside the catch. That `MethodError` propagates in the value's place, unframed. The framework does not handle that throw ([D-225][d-225]).
- note: D-225 (log.md:9175-9176) already says the bare value 'fails the constructor with a MethodError inside the catch and leaves unframed'. The spec's 'it propagates from the catch unwrapped' reads as the value itself propagating.
- backing entry: D-225

## S13c-165 (drift, clear=True)

- at: `design/spec.md:12323`
- claim: local_wires(::StrutRig) = ("stub/out" => "strut/terrain",) wires the Constant stub's output as face `out`.
- evidence: src/library.jl:350: Constant has a bare y_types, so its one output face is y. Probe line 85: output_faces(Constant(1.0)) == ["y"]. Probe line 87: wiring "c/out" is refused as UnknownPort, and "c/y" builds (probe line 89). The test fixture writes local_wires(::TerrainRig) = ("stub/y" => "dut/terrain",) (test/fixtures.jl:1568).
- fix: local_wires(::StrutRig) = ("stub/y" => "strut/terrain",)
- note: D-437 renamed a bare contract's port to the default face y. The rig sketch kept the pre-D-437 name out.

## S13c-183 (deviation, clear=True)

- at: `design/spec.md:12390`
- claim: Its only misses are untaken branches
- evidence: src/tracer.jl:48: Float64(::Tracer{false}) = x.value, and the Int conversions at src/tracer.jl:113-127 sever the set in local mode. Probe line 165: a branch-free member F = TABLE[round(Int, v)] falls back to :sampled and is classified :artificial with dead hop (m, v, F), although F does depend on v. That is a sampled-mode miss with no untaken branch.
- fix: Its misses are untaken branches and the value-severing blind spot below ([D-012][d-012], [D-349][d-349]).
- note: The blind spot is documented three paragraphs later as a general tracer limit. The global mode refuses it, so it bites only in sampled mode, which makes the 'only' in this sentence false.
- backing entry: D-349

## S13d-001 (deviation, clear=True)

- at: `design/spec.md:12586`
- claim: Faces come from the declaration reader at `Float64`, which takes an instance and its tier
- evidence: src/descriptor.jl:290-293: _primitive_faces calls invoke_declaration(fn, instance), which takes the instance alone with no tier and no scalar type. _primitive_face (src/descriptor.jl:296-299) then unwraps Pinned itself on either tier. The reader the doc names, contract_at/declared_at(fn, comp, tier, Float64) at src/declare.jl:794-807, takes the tier but unwraps Pinned on the continuous tier, so it would lose the pinned flag. Probe '001': declared_at gives (e = Float64,), while raw invoke_declaration gives (e = Pinned{Float64},), which the descriptor flags pinned = true. The code has read the raw declaration since c749addf (_leaf_faces).
- fix: Faces come from each instance's own declarations, read as written with a `Pinned` entry unwrapped and flagged. The instances are in the `Structure`, so a failure after the structure step can still carry them.
- backing entry: D-432 ("Faces come from the declaration reader at `Float64` over the `Structure`'s instances"). It does not mention the tier.
