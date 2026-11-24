# G3b: rows for the fixer

Each row: the site at the pinned tip d7d3ddff, the claim, the verifier's evidence and proposed fix, and its note. The fix is a proposal: conform it to the rules and to the code.

## CV9a-011 (deviation, clear=True)

- at: `src/build.jl:375`
- claim: Appendix B and the `port` docstring say a left-out name reads a bare output's face `y` and that a bare port is addressed by the path alone; the throw is stated only for a component whose output contract is named. They are silent on an assembly that exports a lone face `y`.
- evidence: src/build.jl:375-379: with the name left out, port_addr throws ArgumentError unless the path is in layout.bare_outputs, which holds only primitives whose y_types is bare (Layout field comment, :363). Probe: port(m, "a", :y) => 0.0, but port(m, "a") on an assembly that exports a lone face y throws 'ArgumentError: `a` declares no bare output ... name the port'. The same happens at an assembly root (path ""). Appendix B (spec.md:15125-15127) and the port docstrings (src/model.jl:986-998, src/dataplane.jl:550-566) state the throw only for a component whose output contract is named. D-437 names the assembly case for the headless reader leaf (ReadResolution) but not for `port`.
- fix: Appendix B: 'The name may be left out, which names a bare output's face `y`; left out at a component whose output contract is named, or at an assembly, the call throws `ArgumentError`.' The port docstring in model.jl: 'A name left out at a component whose output contract is named, or at an assembly, is an `ArgumentError` too, which tells the caller to name the port.'

## CV9a-017 (deviation, clear=True)

- at: `src/build.jl:565`
- claim: Spec §9.4 says the activation cache's entries each hold 'layouts, compiled plans and a validated flag'. An `Activation{T}` holds `decls`, `products` and `layout` only.
- evidence: src/build.jl:565-569: struct Activation{T} has the fields decls, products and layout. Probe '017 Activation fields => (:decls, :products, :layout)'. No compiled plan and no validated flag exist. Compiled bodies live on the per-Model Executor (src/build.jl:1414-1430), which is never cached. spec.md:5766-5767 says each entry holds 'layouts, compiled plans and a validated flag'. No later entry records the change. D-135 (log.md:4833) and D-052 (log.md:1793) carry the old list, and D-261 (log.md:11068) only says Activation keeps its columns.
- fix: §9.4: 'Each entry holds the declarations retyped at its scalar, the complete probe products and the cell layout.'

## CV9a-034 (deviation, clear=True)

- at: `src/build.jl:1068`
- claim: The `probe_stage2` docstring orders the work as the stage-2 chain, 'the update laws last', 'then the declaration-completeness check'. The code runs the completeness pass before the update laws, then the `x_projection` pass, which the docstring omits.
- evidence: src/build.jl:1069-1076: the docstring says stage 2, 'the update laws last', 'then the declaration-completeness check'. The code runs the completeness pass at :1107-1119, the update laws at :1121-1143 and the x_projection pass at :1145-1168. Probe '034 completeness vs bad x_deriv' gives [DeclaredNotProduced] alone for a component whose x_deriv returns a String: completeness throws before the update laws run. '034 update pass before projection pass' gives only the x_deriv ConformanceFailure. The docstring has been wrong since it was written: 983b7390, and its parent, already ran completeness first. No record of a move exists.
- fix: 'Probe stage 2 in topological order — real upstream values available by construction — then the declaration-completeness check, for every component, then the update laws and last `x_projection`, checking every return against the declaration (§9.3).' The rest of the docstring is unchanged.

## CV9b-046 (drift, clear=True)

- at: `src/model.jl:95`
- claim: The `Model` docstring says 'A model holds six values, each a field' and lists six; the struct has seven fields. `floor_reported` (the frame's StepFloor latch, D-460) is not listed.
- evidence: src/model.jl:60 says 'A model holds six values, each a field.' and lists six; src/model.jl:96-103 declares seven fields, the seventh `floor_reported::Bool` (D-460). Probe P1: fieldnames(Model) = (:deployment, :exec, :status, :claimed, :frame_diag, :fresh, :floor_reported), count=7. The field is set in src/model.jl:893-894 and cleared once per frame in src/frame.jl:121.
- fix: 'A model holds seven values, each a field.' Add a bullet after `fresh`: '- `floor_reported`: whether the frame has filed its one `StepFloor` report. The frame loop clears it at the start of each frame.' (Also worth adding StepFloor to the `frame_diag` bullet, since src/model.jl:895 files it into that cell.)
- note: Commit 4367fa55 (D-460, D-461, D-462) added the field and left the docstring's count and list unchanged.

## CV9b-047 (drift, clear=True)

- at: `src/model.jl:117`
- claim: A `chunk_size` that is not an integer of at least 1 is refused as `ArgumentInvalid` reason `:range` on argument `:chunk_size`, collected with the call; Appendix B's chunk_size row, Appendix C's ArgumentInvalid entry and §9.7 state no refusal or reason for it.
- evidence: src/model.jl:117-120 pushes ArgumentInvalid(call=:Model, reason=:range, argument=:chunk_size) into a collected list. Probe P2: chunk_size=0 and chunk_size=1.5 each give [(ArgumentInvalid, :range, :chunk_size)], and chunk_size=1 is accepted. In the spec, Appendix B's chunk_size row (design/spec.md:15087) states no refusal. Appendix C's ArgumentInvalid entry (design/spec.md:15932-15971) says the Model keywords are collected but gives no reason for chunk_size, and §9.7 never mentions a refusal.
- fix: Appendix B row meaning: 'the executor's unroll width, an integer of at least 1, a performance knob that never moves the trajectory; any other value is refused as `ArgumentInvalid` `:range`'. Appendix C, after the `BS3` sentence: 'A `chunk_size` handed to `Model` that is not an integer of at least 1 is `:range`, collected with the call.'
- note: Commit 945abebf ('Refuse a chunk_size that is not an integer ≥ 1 at the Model door, collected as Appendix C says') records the refusal. The docstring at src/model.jl:56-58 states it but names no reason.

## CV9b-064 (drift, clear=True)

- at: `src/model.jl:1262`
- claim: `restore!` can raise `ArgumentInvalid` reason `:range` on argument `:t0`, collected beside the mismatches, for a hand-built state whose origin fails the clock-integers check. The `restore!` docstring and Appendix C (which gives `:range` on `t0` to init!, trim! and linearize only) omit it.
- evidence: src/model.jl:1259-1265: _check_grid! pushes ArgumentInvalid(call=:restore!, reason=:range, argument=:t0, value=t₀) into the list the mismatches collect into, when _clock_integers fails on the state's origin. restore! calls it at src/model.jl:1312, and so do sim's doors at src/sim.jl:1073 and 1090. test/test_lifecycle.jl:114-126 asserts this for a forged origin 1//typemax(Int). The restore! docstring (src/model.jl:1287-1292) names only CheckpointMismatch, CheckpointMidFrame and the claim. Appendix C (design/spec.md:15966-15968) gives t0 :range to init!, trim! and linearize only.
- fix: Appendix C: 'A `t0` handed to `init!`, `trim!` or `linearize` that is not exact, or whose run the clock's integers cannot carry, is `:range`, and `restore!` refuses a state whose origin's run the clock's integers cannot carry the same way, collected beside the mismatches ([D-457]).' restore! docstring, after the CheckpointMidFrame sentence: 'One whose origin's run the clock's integers cannot carry, as only a state built by hand can, is refused as `ArgumentInvalid`.'
- note: D-457 (ratified, design/log.md) says: 'A restore checks a state's origin the same way, since a state built by hand carries an origin no door accepted.' code_map.md:996-998 also states it. Only the docstring and Appendix C lag.

## CV9b-013 (deviation, clear=True)

- at: `src/structure.jl:248`
- claim: `Structure.root_types` (the root inputs' types, as the wire pass fixed them) is a public field that spec §9.1's list of what `Structure` carries, the g-structure glossary entry, Appendix B and the log omit; only the docstring and code_map.md 1376 state it.
- evidence: src/structure.jl:248 `root_types::Vector{Type}` is a field of Structure. Probe P7 gives root_types = Type[Float64, Float64] beside root_inputs = [:u, :p]. Spec §9.1's list of what Structure carries (design/spec.md:4960-4970) gives 'the root inputs' with no types. The g-structure glossary entry (design/spec.md:16813-16820, docs/src/glossary.md:241) and Appendix B (design/spec.md:15027-15031) omit it as well. rg finds 'root_types' in no spec or log line, only in code_map.md:1376 and the docstring at src/structure.jl:225.
- fix: §9.1 list: replace '- the root inputs;' with '- the root inputs, each with the type the wire check fixed for it;'. Glossary g-structure: '... the [root inputs] with their types, the rate chains and the scope triples.'
- note: D-236 fixes the root-input type itself and D-261 sets the artifact-holds-declared-facts rule, but no log entry places the types on Structure. The field arrived with commit 1ea65d21 (increment 32) and nothing recorded the placement in the spec.
- coordinator: If the glossary entry g-structure needs the same change, apply it there too.

## CV9b-017 (drift, clear=True)

- at: `src/structure.jl:435`
- claim: The `flatten_tree!` docstring says sample times are folded to `(anchor, m, c)` timings; the fold's value is `Timing = (anchor, D, Φ)`.
- evidence: src/structure.jl:435-437 (flatten_tree! docstring) says 'sample times folded to `(anchor, m, c)` timings'. The fold's value is `Timing = @NamedTuple{anchor::Int, D::Int, Φ::Int}` (src/structure.jl:135), and the walk seeds it as Timing((0, 1, 0)) at src/structure.jl:450. Probe P7 shows the scopes field type timing::@NamedTuple{anchor::Int64, D::Int64, Φ::Int64}.
- fix: '... sample times folded to `(anchor, Dₐ, Φₐ)` timings, ...'
- note: Commit 7c24c484 ('Write the code's timing counts as D and Φ under their lattice's subscript ... (D-478, D-479)') renamed the fields and missed this docstring. The section comment at src/structure.jl:305-313 already uses (a, Dₐ, Φₐ).

## CV9b-025 (deviation, clear=True)

- at: `src/structure.jl:756`
- claim: code_map.md 1409-1411 says `_check_face_names` 'refuses an empty assembly face as FaceNameIllegal :empty'; the function also refuses a `/` in a face name (:contains_slash) and a repeated name across the two boundary declarations (FaceNameCollision, site :assembly).
- evidence: src/structure.jl:756-769: _check_face_names pushes FaceNameIllegal :contains_slash for a name containing '/', FaceNameIllegal :empty for an empty name, and FaceNameCollision site :assembly when the names across input and output entries are not all unique. Probe P8 shows a slash face giving (FaceNameIllegal, :contains_slash), an empty face giving (FaceNameIllegal, :empty), and 'q' as both input and output face giving (FaceNameCollision, :assembly). design/code_map.md:1418-1421 (the claim's 1409-1411) names only the :empty refusal.
- fix: '`_check_face_names` refuses an assembly face containing `/` or empty as `FaceNameIllegal` `:contains_slash` or `:empty`, and a name repeated across its input and output faces as `FaceNameCollision` `:assembly`; the root check `_check_root_faces` ...'
- note: The slash and collision refusals predate the map's line (commit 3b5b204b). The :empty clause came with D-437 (commit 4d79875c), and the map line was never complete.

## K9b-004 (deviation, clear=True)

- at: `design/companions/frozen_discrete_walkthrough.md:28`
- claim: At B's tick times `y_state`/`y_direct` read whatever their inputs are at that instant
- evidence: src/declare.jl:904-905 LEGAL_BUNDLE: discrete `y_state` gets (:s, :t, :Δt, :ws) with no `u`. Only `y_direct` gets (:s, :u, :y_s, ...). Spec §5.3 says y_state 'carries no u'.
- fix: at B's tick times $t_k$, its stages run: `y_direct` reads whatever B's inputs *are at that instant*, `y_state` reads B's `s`, the two compute B's outputs and write them to B's cells, and `s_update` updates B's `s`.
- note: The text is true only if 'inputs' means each stage's bundle. In Redstone's vocabulary inputs are the `u` ports, and y_state never sees them.

## K9b-067 (deviation, clear=True)

- at: `design/companions/handle_walk_walkthrough.md:257`
- claim: A stage that hands a `Dual` for `b` dies in `convert(Float64, ::Dual)`, which has no method
- evidence: probe 'K9b-067': MixedRight{Dual}(d, d) throws `MethodError: no method matching Float64(::Dual{LinearizeTag,Float64,8})`. which(convert, (Type{Float64}, LinearizeDual)) resolves to Base number.jl:7, `convert(::Type{T}, x::Number)`. The convert method exists. The missing method is the Float64 constructor it calls.
- fix: a stage that hands a `Dual` for `b` dies in `convert(Float64, ::Dual)`, whose fallback calls `Float64(::Dual)`, which has no method.
- note: This is a Julia and ForwardDiff fact, not Redstone code. The behaviour the doc describes, a loud failure at construction, holds.
