# The failure descriptor: the first minor bump of the inspector's stage 1

The record of one short session, on 2026-10-28, that fixed the failure
descriptor: the body a carrier exception renders to, the encoding of a
diagnostic as data, the carrier's `structure` field and where the build's
door fills it, the fixtures, and the spec and log homes. It builds on
`initial_design.md`'s answer 6, on `descriptor_design.md`'s answers 1, 2,
13 and 15, and on `visual_grammar.md`'s answer 8 and its pending bullet on
what the overlay needs, and never restates them. Like its parents it is not
normative; its rulings are §13.2, §13.9 and D-434. The bump joins version
one's shape with no version bump, the package being unreleased.

One question the pending list asked dissolved on reading the code: a raw
user exception never escapes a probe. D-248 frames every user-authored
method the build invokes, so a throw arrives as a `UserCodeFraming`
diagnostic inside the carrier with the original exception as its `cause`,
and only a nested carrier, an `InternalInvariant` and an
`InterruptException` pass unframed, none of them a build failure to draw.

## Pending questions

- **The runtime carrier.** `StepError` is not a `DiagnosticError` and has no
  descriptor; stage 3, which has a run to show, owns it.
- **The kind names.** A diagnostic's `kind` is its type's name, which the
  export audit may still rename, as every name in Appendix C's set.

## Answered questions

1. **The failure body: policy, structure when held, diagnostics,
   warnings.** The envelope's `kind` gains `"failure"`, and the body under
   `failure` holds `policy`, `"fail-fast"` or `"collected"`, read off the
   carrier's type parameter; `structure`, the `StructureSection` the build
   body already uses, present only when the carrier holds a `Structure`;
   `diagnostics`, one element for a fail-fast throw and the collection for a
   barrier's; and `warnings`, the carrier's warnings so far. The build body
   gains `warnings` too, the `Build`'s own, encoded the same way and an
   empty array when none. No version bump.
   *Why:* `policy` tells the reader whether the list is complete, as
   `showerror` does by rendering one line against a group. The encoder
   exists once, and the grammar reserved amber for warnings "once a
   descriptor carries them". `alias` and `name` joined version one unbumped
   for the same reason. *Rejected:* warnings in a bump of their own; a
   version bump with no reader to protect.

2. **A diagnostic as data: four fields, three optional additions, never the
   payload.** Every diagnostic carries `kind`, its type's name; `severity`;
   `path`, the attribution `path(d)` answers, `""` for the root as for a
   wire endpoint; and `message`, the text `showerror` renders, a
   `UserCodeFraming`'s cause included as its second line. Three optional
   fields are written by the kinds whose payload holds the fact: `function`,
   the user method at fault, for `UserCodeFraming`, `ConformanceFailure`,
   `DeadStage` and `UndeclaredReturnField`, `GuardForm`'s payload naming no
   method; `marks`, an object of two arrays, `ports` as endpoints `{"path",
   "port"}` and `wires` as `{"from", "to"}`, the kind names beyond its path,
   `UnconnectedInput`'s input, `TwoProducers`' destination, whose producers
   the payload spells as text and not as endpoints, `WireTypeMismatch`'s and
   `WalkingFaceAtFrozenEntry`'s consumer and producer-to-consumer wire; and
   `cycle`, for
   `AlgebraicCycle` alone, with `members`, `wires` as terminal pairs,
   `classification` when present, `dead` as `{"path", "input", "output"}`
   and `traced` as `{"path", "mode"}`. `UnknownPort` names a port that does
   not exist and marks its node alone.
   *Why:* the overlay of `visual_grammar.md`'s answer 8 draws a node, a
   port, a wire or a loop's chain, none of which message text gives back,
   and nothing beyond them; Appendix C's payloads stay the test contract,
   unbound by the format as the artifacts' fields are. *Rejected:* message
   and attribution only; the full payload of every kind, fifty strict
   schema definitions with `Any`-typed fields for a few needed facts, and a
   format change on every payload change.

3. **The carrier field and the door.** `DiagnosticError` gains `structure`
   after `warnings`, typed `Any` because `diagnostics.jl` is included before
   `assembly.jl` declares `Structure` and `declare.jl` throws the carrier
   before any artifact exists; both constructors default it to `nothing`.
   The door hoists its `structure` local above the `try`, assigns it where
   the `Structure` is built inside the `with` block, and its one `catch`
   rebuilds every carrier with the warnings and the structure, dropping the
   non-empty-warnings guard. A throw from an activation requested at build
   runs inside the same block after the `Build` exists and carries the
   structure too, so the trigger is "a throw leaving the door past the
   structure step". `descriptor(err::DiagnosticError)` takes any carrier, a
   build's with its structure or a service's with its list alone.
   *Why:* the `do` block is a closure, so the hoisted binding is updated by
   reference and the catch outside the `with` sees it; the rewrap already
   sat at the door and not at the barriers, which know nothing of warnings
   or structure. *Rejected:* `Union{Nothing, Structure}`, undeclarable at
   the carrier's definition; moving the carrier below `assembly.jl`, which
   `declare.jl` forbids.

4. **Fixtures and tests.** One fixture per case, each validated after the
   round trip: a structure-step failure with an unknown port and an unfed
   input, collected, no structure, the input's mark; a real loop past the
   structure step, every member and wire endpoint naming a node and face of
   the carried structure; an artificial loop with a dead hop and a sampled
   member; a probe throw, fail-fast, with `function` and the cause's line; a
   wire type mismatch for the wire mark; a successful build with an
   `EmptyFaceSelection` warning, the deployment fixture's embedded body
   carrying it too; and a `Deployment` refusing a `RatesViolation`, a
   service carrier with the list alone. Content assertions: `kind` and
   `message` equal the type's name and `message(d)`; `policy` matches the
   type parameter; `structure` is present exactly when the carrier holds
   one; the warnings count matches; every mark and cycle path resolves
   against the structure when there is one. In `test_build.jl`: a failure
   past the structure step carries the model's structure, one at the
   structure step carries `nothing`, a requested activation's throw carries
   it, the rewrap keeps warnings and structure together. The schema gains
   `Diagnostic` and `FailureBody`, the third `oneOf` branch, and `warnings`
   in `BuildBody`'s required set.
   *Why:* the suite already builds every failing model the cases need, in
   `test_build.jl`'s cycle tests and `test_assembly.jl`'s wiring tests.

5. **Spec, log, record, order.** §13.2's carrier sketch and sentence as
   built; §13.9's envelope with the third kind, `warnings` in the build
   body, one paragraph for the failure body and one for the encoding rule,
   the carrier paragraph as built. One entry, D-434, in D-406's bundled
   shape, and a one-line annotation on D-432 for the widened trigger. This
   record, with the settled notes on `descriptor_design.md`'s and
   `visual_grammar.md`'s pending bullets. Docs commit first, the increment
   at once under the delegation pipeline; the spec carries no "recorded and
   unbuilt" marker, and a slip would be a `Deviations` bullet.

## Design axes

What this bump hands on, in working order:

1. **The increment**: `src/diagnostics.jl` and `src/build.jl` for the
   carrier and the door; `src/descriptor.jl` for the failure method, the
   diagnostic encoder and the build body's `warnings`; `src/descriptor.json`;
   `test_descriptor.jl`'s cases and `test_build.jl`'s carrier tests.
   Briefed under `brief_lessons.md`'s rules, prototyped first.
2. **The page**, as `workspace.md`'s answers 6 and 10 and
   `visual_grammar.md`'s answer 8 already settle: the drawer on the
   diagnostics with the overlay lit, the list alone without a structure,
   amber for warnings.
3. **The deployment overlay's bump**, next of the inherited bumps, as
   `visual_grammar.md` hands it on.

## Glossary

- **Cycle section.** The `cycle` object an `AlgebraicCycle` diagnostic
  carries: members, wires as terminal pairs, the classification, the dead
  hops and the tracing modes.
- **Diagnostic's kind.** Its Julia type's name, the third sense of `kind` in
  the format beside the envelope's and the kind marker's, told apart by
  where it sits.
- **Failure body.** The object under `failure`: `policy`, `structure` when
  held, `diagnostics` and `warnings`.
- **Mark.** A port or a wire a diagnostic names beyond its path, where the
  overlay draws; `marks` holds them as two arrays.
- **Policy.** `fail-fast` or `collected`, the carrier's type parameter read
  out: whether the list is the first failure alone or everything a step
  found.
