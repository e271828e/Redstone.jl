# Increment 88 prototype notes (Fn, Select, Fields)

## Milestone 1: setup and source (2026-11-05)
- Worktree wt_088 at 2bf58f9, root Manifest copied. Probes in scratchpad/inc88/.
- src/blocks.jl: Fn after Junction (before "structure blocks" header), Fields after Unpack, Select after Switch.
- test/imports.jl: Fn, Select, Fields added to the Blocks import line.
- Seam: a @generated helper cannot call `instances(K)` on a user enum (world age: the
  generator runs in its definition's world; probed, MethodError "method too new").
  So Select passes `Val(instances(K))` (instances is a literal tuple, folds) and the
  generator emits `select === K1 ? getfield(u, 1) : ...` positionally. code_typed: a
  pure `===` chain on literals, no Symbol, 0 allocs.
- Fields: `field_names(::Type{V})` generated over fieldnames (Base builtin, no world issue).
- `Select{V, Enum}()` throws MethodError from `instances(Enum)`; no explicit concrete check (seam).

## Probe (b): non-stripping f at a pinned struct Y
- Nominal build: accepted, runs (no Dual exists).
- build(...; activations = (Float64, LinearizeDual)) or ProbeDual: refused, DiagnosticError{Vector{Diagnostic}},
  one ConformanceFailure(path, what = "y_direct", reason = :field_type, shape = :ports,
  observed = Course{Dual}, declared = Course{Float64}, field = :y, activation = the Dual).
- Nominal-only build then linearize: the same ConformanceFailure, thrown by linearize when it materializes the Dual activation.
- (a) strip f at pinned Y: builds under LinearizeDual and ProbeDual; linearization through it reads D = 0.
- A struct root input needs `probe_value` (MissingProbeValue otherwise); a seeded tap cannot step into a struct (TapResolution).

## Measurements (probe4.jl)
- Float64 bodies sweep_1/sweep_2/rhs/ticks x (body(), body(1)) and both boundaries: all 0 B
  for fn_scalar, fn_struct (Fn build -> pinned Fn strip -> Fields), fields_chain, fields_nt, select_root, select_vec.
- LinearizeDual Model bodies: all 0 B for the same six.
- Specializations after the probe: selected_input 3, field_names 2; one method each.

## Milestone 2: tests written, routed run 1 launched (log scratchpad/inc88/run1.log)
- Fixtures in test_blocks.jl after flip_model: FlightLeg, Course{T} (+probe_value), module SelectClash,
  course_of, strip_partials, course_model(pass), NestedCourse + nested_course_model, select_root, vector_select_model.
- Seven Junction{_,_,1} -> Fn, wires in1 -> u; three AlgebraicCycle d.wires asserts updated (sat/u, gain/u).
- Six testsets inserted before "the source publishes"; allocation testset extended by 7 models.
- docs/src/api.md: Fn, Fields, Select added to Structure. Docstring roster: all checks empty.
- Fn's "StepError on a later frame" sentence verified by probe5 (StepError{ConformanceFailure}).

## Milestone 3: routed run green; mutants launched
- `blocks build` under sandbox flags: blocks 3367/3367 (4m26s), build 521/521, selected 3888/3888 (6m21s); Dual sweep 127 covered, 62 skipped; no warnings in log.
- Patch written: scratchpad/prototype_increment_88.patch (4 files, +346 -22), staged in wt_088.
- Mutant runner scratchpad/inc88/mutants.jl (11 mutants, each runs test_blocks() whole); summary in inc88/mutants_summary.txt.

## Milestone 4: mutants (inc88/mutants_summary.txt; each mutant runs test_blocks() whole via invokelatest)
- M1 Fn ignores f: red in Fn, pinned Fn, Fields, allocation (error), delay line, PID-from-blocks, hold w/o tracking.
- M2 Fn unwraps pinned Y: red in pinned Fn only.
- M3 Fn via invokelatest: red in the three allocation testsets (64-288 B per body).
- M4 Select off-by-one: red in Select and allocation (96/64 B, runtime index).
- M5 Select by Symbol(enum): red in Select and allocation (96/64 B per body).
- M6 no clash check: red in clash testset. M7 selector first: red in Select and allocation (build error).
- M8 Fields admits StaticArray: red in refusal testset. M9 reversed fields / M11 all-Float64 types: red in pinned Fn, Fields, allocation.
- M10 Fields names built in the body (Symbol.(string.(fieldnames(V)))): SURVIVES; Julia folds it, 0 B. The generated helper is kept per the settled shape; no pin can tell it apart at 1.13.
- First mutant run was void: Core.eval'd methods inside a top-level loop are invisible to calls in the same statement (world age); fixed with invokelatest.
