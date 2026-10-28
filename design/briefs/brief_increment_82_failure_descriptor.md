# Brief: increment 82, the failure descriptor

One code commit, which I apply from the prototype, one cold review and a
fixer if the review needs one. Written on 2026-10-28 at 848d527, the docs
commit that landed D-434, §13.2's carrier field as built, §13.9's failure
paragraphs and the bump's record, `design/inspector/failure_descriptor.md`,
not normative. Find passages in `design/implementation.md` by heading.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

`prototype_increment_82.patch`, beside this brief, is the reference
implementation, taken at 848d527 on a scratch worktree where the routed
subset (`descriptor build declare assembly diagnostics leaves show`) ran
green at 2397 assertions and the full gate ran green; the figures are
below. Six files, 332 insertions, 23 deletions.

## What is settled

D-434's bundle and §13.9, as 848d527 leaves them:

- The envelope's third kind is `failure`. The failure body holds `policy`,
  `fail-fast` or `collected` off the carrier's type parameter; `structure`,
  the build body's own section, present only when the carrier holds one;
  `diagnostics`; and `warnings`. `descriptor(err::DiagnosticError)` takes
  any carrier; `StepError` stays out.
- Every diagnostic carries `kind`, the type's name; `severity`; `path`,
  `""` the root; and `message` as `showerror` renders it. `function`,
  `marks` and `cycle` are optional, written by the kinds whose payload
  holds the fact. The payload is never exported.
- The build body gains `warnings`, the `Build`'s warnings encoded the same
  way, an empty array when none.
- The carrier's `structure` field, typed `Any`, `nothing` by default in
  both constructors, filled at the door's one rewrap site whenever a throw
  leaves the door past the structure step, a requested activation's
  included.
- No version bump.

## The shape, as the patch has it

- `src/diagnostics.jl`: `DiagnosticError` gains `structure::Any` after
  `warnings`; both outer constructors take it as a third positional
  argument defaulting to `nothing`; the docstring states the invariant.
- `src/build.jl`: `build` declares `structure = nothing` before the `try`,
  assigns it inside the `with` block where `Structure(draft, root_types)`
  is built, and its `catch` rethrows every `DiagnosticError` as
  `DiagnosticError(err.carried, raised_warnings, structure)`, the
  non-empty-warnings guard gone.
- `src/descriptor.jl`: `descriptor(err::DiagnosticError)` over
  `_failure_body`; `_build_body` gains `warnings`; `_diagnostic` writes the
  four fields and the optional three; `_function` on `UserCodeFraming`
  (`fn`), `ConformanceFailure` (`what`), `DeadStage` and
  `UndeclaredReturnField` (`stage`); `_marks` on `UnconnectedInput`,
  `TwoProducers`, `WireTypeMismatch` and `WalkingFaceAtFrozenEntry`;
  `_cycle` with `_terminal_endpoint` splitting a `path/port` terminal at
  its last slash, a primitive root's `/port` giving path `""`.
- `src/descriptor.json`: `kind`'s enum and the `oneOf` gain the third
  branch, each branch's `not` now an `anyOf` over the two other body keys;
  `BuildBody` requires `warnings`; new definitions `FailureBody`,
  `Diagnostic`, `Marks`, `Cycle`, `DeadHop` and `TracedMember`.
- `test/test_descriptor.jl`: six new testsets and `_structure_of`; the
  sweep asserts `warnings == []`. `test/test_build.jl`:
  `build_carrier_structure`, run after `build_barrier`. No new fixtures:
  the cases reuse `SelectedNothing`, `merged_failures`, `feedback_model`,
  `Piecewise`, `TypedGain`, `Thrower`, `FieldReader` with `RealEntry`, and
  `AnchoredBank`.

## Three readings the prototype took where the docs stop short or overstate

Each is a one-line docs correction, to land docs-commit-first before the
code commit, or a ruling the other way:

1. **`marks` is an object `{ports, wires}`**, two typed arrays, rather than
   one array mixing endpoints and wires. §13.9 says "the endpoints and
   wires a kind names", which the object carries; the record's answer 2
   gains the container shape. A strict schema and the client both prefer
   two homogeneous arrays over a `oneOf` per element.
2. **`TwoProducers` marks its destination alone.** §13.9 and D-434 say
   "its destination and its two producers' wires", but the payload spells
   each producer as rendered text, "`a`.out" or "root input `x`", a
   terminal *or the handing face*, which is no endpoint pair. Recovering
   one would mean parsing message text. The spec sentence and the record
   lose the producers' wires; D-434's bullet says "naming a face or a wire
   beyond their path", which stays true.
3. **`GuardForm` writes no `function`.** The record lists it among the
   probe-chain kinds, but its payload holds the event name and the observed
   return type and names no method; §13.9's "probe-chain kinds" is
   unlisted and stays true. The record's answer 2 drops it.

## What the tests pin, by property

- The sweep: a clean build's `warnings` is `[]`, never omitted.
- Warnings: `SelectedNothing`'s `EmptyFaceSelection` as one row with kind,
  severity `warning`, path `g` and `message(d)`; the build body's keys;
  the deployment's embedded body carrying the same row.
- The structure-step failure, `merged_failures()`: the envelope's keys and
  kind; the body's keys without `structure`; `collected`; one row per
  carried diagnostic with kind, message and path equal to the carrier's,
  every severity `error`, `warnings` empty; `UnconnectedInput`'s port mark
  from the payload; `UnknownPort` with no optional key.
- Past the structure step, `feedback_model(feedback_port = "power")`: the
  body's four keys; `structure` equal to `_structure_section` of the
  carrier's; the cycle's members and every wire endpoint naming a node and
  one of its faces; `real`, `dead` empty, `traced` from the payload; the
  wires as `path/port` pairs equal to the payload's strings. The artificial
  `Piecewise` loop: `artificial`, `dead` `[("m", "g", "F")]`, `traced`
  `global`, `global`. `TypedGain`'s unclassified pair: no `classification`
  key, `dead` and `traced` empty. Each validates.
- The probe throw, `single(Thrower())`: `fail-fast`, `structure` present,
  `UserCodeFraming` at `c` with `function` `y_state` and `cause: boom` on
  the message's second line, no `marks`.
- The mismatch, `FieldReader` with `RealEntry` fed from `in`: the port mark
  `("a", "f")` and the wire from the root input `("", "in")`; no structure.
- The service carrier, `AnchoredBank` deployed at `h = 1//500`:
  `collected`, no structure, `DeploymentInvalid` alone.
- The carrier, in `test_build.jl`: the loop's and the probe throw's
  carriers hold a `Structure` whose paths are a clean sibling build's; the
  structure-step failure's holds `nothing`; `fed(TypedGain(), "e")` builds
  clean and throws at `activations = (ProbeDual,)` with the structure held;
  a group of `SelectedNothing` and `Thrower` keeps the warning and the
  structure together; both two-argument constructors default the field.

## Bookkeeping, in the same commit

- `design/implementation.md`: the `src/descriptor.jl` entry gains the
  failure body, `_diagnostic` with `_function`, `_marks` and `_cycle`, and
  the build body's `warnings`, with D-434 in its Spec line; the
  `src/diagnostics.jl` entry's carrier bullet gains `structure` (D-434);
  the `src/build.jl` entry's rewrap bullet says every carrier is rewrapped
  with the warning list and the structure.
- `design/pending.md`: the stage-1 bullet records the increment as landed
  and names axis 7 as next.
- `design/inspector/failure_descriptor.md`: answer 2 takes readings 1 to
  3; `design/spec.md` §13.9 and D-434 take reading 2, docs-commit-first.
- Files to commit: `src/diagnostics.jl`, `src/build.jl`,
  `src/descriptor.jl`, `src/descriptor.json`, `test/test_build.jl`,
  `test/test_descriptor.jl`, `design/implementation.md`,
  `design/pending.md`. Never a `Manifest.toml`, and never another
  session's untracked files.

## Out of scope

- The deployment overlay, state events, stage 2's extensions: the record's
  remaining bumps.
- The page's drawer and overlay: the frontend's, settled by
  `workspace.md` answers 6 and 10 and `visual_grammar.md` answer 8.
- `StepError` as a descriptor: stage 3's.
- The kind names: the audit's (D-226).

## The cold review

One fresh Opus reviewer over the code commit, §13.2, §13.9 and D-434 read
for what they owe: open-mind stance, probe scripts in the scratchpad,
"empty is acceptable". Dimensions:

- **The docs against the tree.** Every sentence of §13.9's two failure
  paragraphs and its carrier paragraph, §13.2's carrier sentence, and every
  bullet of D-434's Position hold of the code, each probed.
- **The schema against the writer.** Every key the writer emits is in the
  schema and every `required` key is always emitted, probed over every
  failing model `test_build.jl`, `test_assembly.jl` and `test_discrete.jl`
  build, not only the six cases: catch each carrier, render it, round-trip
  it. In particular a diagnostic whose `path` is `""`, a cycle on a
  primitive root (`Plant` self-wired through `power`), and a carrier with
  warnings and a collection.
- **Every throw site of the door.** Each `throw(DiagnosticError(...))` in
  `build.jl`, `assembly.jl` and `declare.jl` reached through `build` arrives
  with `structure` set exactly when the structure step completed; probe one
  site per step and one in a requested activation.
- **Allocation and compile cost.** `descriptor(err)` runs once per call at
  the REPL; confirm `_diagnostic` and the `_marks` and `_function` methods
  add no per-component specialization, and that the door's hoisted
  `structure` binding costs `build` nothing measurable (`@allocated` on a
  clean build before and after).
- **Naming** over every touched line; no local shares a name with a
  function its module sees.
- **Mutants on a scratch copy**, each named test going red: `policy`
  swapped; `structure` emitted when `nothing` as an empty section or
  omitted when held; the door's `structure` assigned after `_nominal`
  returns; the catch's rewrap guarded by non-empty warnings again;
  `message` replaced by `string(d)`; `severity` hard-coded `error`; the
  `marks` port taken from the producer; the cycle wire split at the first
  slash; `classification` written as `"nothing"`; `dead`'s input and
  output swapped; the build body's `warnings` omitted when empty;
  `_function` returning the kind name. A surviving mutant is a missing
  test, or an acceptable survivor named with its reason.
- The gate green on the Julia floor `Project.toml` declares.
