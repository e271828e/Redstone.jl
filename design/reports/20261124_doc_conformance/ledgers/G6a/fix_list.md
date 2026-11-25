# G6a: rows for the fixer

Each row: the site at the pinned tip cb398676, the claim, the verifier's evidence and proposed fix, and its note. The fix is a proposal: conform it to the rules and to the code.

## S6b-231 (drift, clear=True)

- at: `design/spec.md:828`
- claim: Relative entries compose down the tree with periods multiplying and phases adding
- evidence: src/structure.jl:397-399: `Timing((scope.anchor, D·scope.D, scope.Φ + rate.Φ·scope.D))`, so a child's phase is scaled by its scope's period before it is added. Probe P2: Relative(2,1) nested under Relative(2,1) gives D=4, Φ=3, not Φ=1+1=2. §6.3 (spec:2033-2037) and D-478 state the affine law.
- fix: Relative entries compose down the tree, periods multiplying and phases composing affinely: a child's phase, scaled by its scope's period, adds to the scope's phase.
- note: The phrase 'phases adding' dates from the move in e7468964. The log has said 'phases affine' since D-185 (log.md:7381), and D-478 (log.md:21129-21131) gives the law the code implements.

## S6c-002 (deviation, clear=True)

- at: `design/spec.md:1139`
- claim: Every primitive provides exactly two output stages, y_state and y_direct (also line 889 'the two output stages every primitive provides' and line 1118 'two output stages per primitive').
- evidence: src/declare.jl:617 "A component defines the stages it needs"; src/build.jl:72 `has_stage(y_state, comp) || return NamedTuple()` and src/build.jl:1183 do the same for `y_direct`; probe.jl:71-72 (P11) `BareTicker` defines only `y_state` and builds, and `Terrain` defines only `y_direct`.
- fix: "**A primitive has at most two output stages**, `y_state` and `y_direct`, and defines the ones it needs" at line 1139, with "the two output stages a primitive may define" at line 889 and "at most two output stages per primitive" at line 1118.
- note: The spec's own lines 1226 and 1259 ("A stage that exists...") admit an absent stage. D-006 backs "two, no more", not "both always".

## S6e-005 (drift, clear=True)

- at: `design/spec.md:1773`
- claim: A junction has one output, `out`.
- evidence: src/library.jl:24 and :118, y_types(::Junction{In, Out}) = Out, which is bare, so the face is `y`. probe.jl P1 shows `s/out` refused as UnknownPort, 'its faces are in1, in2, in3, y'.
- fix: A junction is an ordinary stateless component with N inputs of one type, `in1` to `inN`, and one output, `y`.
- note: Moved by commit 4d79875c, which declared the library's single-port blocks bare. D-437 names the bare output face `y`. §13.7 (spec.md:12195) already says the face is y.

## S6e-011 (drift, clear=True)

- at: `design/spec.md:1793`
- claim: The wire `"wr_sum/out" => "dynamics/wr_ext"` takes the junction's output.
- evidence: src/library.jl:118 bare output face `y`; probe.jl P1 `"s/out" => ...` gives UnknownPort, and `s/y` builds.
- fix:     "wr_sum/y"    => "dynamics/wr_ext",
- note: Same move as S6e-005 (commit 4d79875c, D-437).

## S6e-014 (deviation, clear=True)

- at: `design/spec.md:1802`
- claim: A stale arity surfaces as an unconnected input or a double-wired slot.
- evidence: probe.jl P4: a SumJunction{Float64,2} with a third contributor kept on `in3` is refused as UnknownPort ('`s/in3` names no `in3` on `s`'), not as an unconnected input or a double-wired slot. A too-high arity gives UnconnectedInput (P2), and a doubled slot gives TwoProducers (P3).
- fix: A stale arity surfaces as one or the other, or as an unknown port when a contributor is wired past the last slot.
- note: The loudness the doc promises holds. Only the list of diagnostics is short by UnknownPort. No log entry records the narrower list.

## S6e-016 (drift, clear=True)

- at: `design/spec.md:1805`
- claim: `"wr_sum/out"` is an ordinary port.
- evidence: src/library.jl:118 bare output `y`; probe.jl P1 and P6b: `s/out` names no port.
- fix: - The aggregate is a first-class signal. `"wr_sum/y"` is an ordinary port.
- note: Same move as S6e-005 (commit 4d79875c, D-437).

## S6e-022 (drift, clear=True)

- at: `design/spec.md:1822`
- claim: The assembly exports its junction's `out` port.
- evidence: probe.jl P6: output_wires ("s/y" => "wrench") builds, while P6b ("s/out" => "wrench") is UnknownPort. src/library.jl:118.
- fix: The junction is a component inside the assembly, and the assembly exports its `y` port ([§8.6][s8-6]).
- note: Same move as S6e-005 (commit 4d79875c, D-437).
