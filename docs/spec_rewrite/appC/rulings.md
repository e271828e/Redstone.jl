# Appendix C: the audit's rulings

The audit of `../appendices.md` ("Appendix C: audit against the code, no
rewrite"), run at `84eff6a` on 2026-10-20 and 2026-10-21.

## Method

1. **The kind set, both ways.** C has 84 bold entries and `src/` has 83
   structs under `Diagnostic`. The one extra is `StepError`, the runtime
   carrier, an `Exception` and not a `Diagnostic`. C keeps it, since its
   payload is what a test matches, and its entry now says what it is.
2. **Per kind.** Five read-only Sonnet agents over bounded ranges, one TSV
   row per kind and aspect (payload, severity, raised, policy), from
   `audit_brief.md`. The rows are in `survey/A1.tsv` to `survey/A5.tsv`:
   345 rows, 291 ok, 53 stale, 1 extra. Severity agreed for every kind. I
   checked every stale row against `src/` before it became a fix.
3. **Owners.** `survey/owners.py` lists, per kind, the sections that name
   it against the sections C cites. Most of its output is noise, because C
   cites where a rule is stated, not every mention. An owner was added only
   where a section states a raise rule the entry describes.
4. **Verification.** One fresh Opus agent checked every added claim against
   `src/`. It found four payload claims stated for every occurrence where
   the code sets the field on one reason only (`ArgumentInvalid`,
   `ReadResolution`, `PathResolution`, `DeclarationOnWrongTier`). All four
   now name the reason that carries the field.

## Rulings

- **R1. Every payload field is named.** C is the acceptance-test contract
  and tests match on payload fields, so a field the struct holds and C
  omits is drift. Every such field is now named, and every `reason` tag is
  spelled with its full value set. A remedy or fix that lives only in the
  message is described as the message's, not listed as payload
  (`IllegalStoreField`, `DuplicateConditionLeaf`, `ConditionShapeDrift`).
  `IllegalPortType`'s "leaf vocabulary" was no field and went.
- **R2. A device that is not yet admitted is named by type.** `ClaimConflict`,
  `AlreadyAttached` and `NotAttached` carry the offered device's type name,
  since its roster id exists only after admission. `detach!` takes a device,
  not a handle.
- **R3. The trim warnings are logged beside the report.** §13.2 already says
  `trim!`'s facts live on the `TrimReport` and the warnings are logged
  beside it. C's lead definition of *logged* said the warning lives on the
  artifact. The lead now names `trim!` as the exception, and the three
  entries cite §13.2.
- **R4. Fail-fast exceptions inside a collected kind are stated.**
  `PathResolution` fails fast where a declaration body calls `resolve` or
  `resolve_terminal`, since that is user code (§13.1). `CheckpointMismatch`'s
  scalar case throws alone on `restore!`, by dispatch. `Model`'s `:scalar`
  refusal throws alone before the keywords are read. Each is the code's
  shape and follows from a rule already stated, so none needs the owner.
- **R5. Raise sites C omitted are added.** `MissingInit` on `trace`;
  `ServiceLifecycle` on `overlay!`, the four advances, `logged` and
  `series`; `CheckpointMidFrame` on `overlay!`; `ReadResolution` at
  `series`; `ArgumentInvalid` on `overlay!` and `trace`, and collected over
  the recording keywords of the four doors (D-261).
- **R6. Owners added.** `PathResolution` §14.3. `ConditionResolution` §14.1,
  §14.9, §14.10. `ReadResolution` §11.2, §14.8, §14.9, §14.10.
  `ArgumentInvalid` §9.2.
- **R7. The carried items.** All of the README's Appendix C items landed:
  `ConditionResolution`'s seven reasons, `DuplicateConditionLeaf`'s `u` leaf,
  `ConditionNodeMisuse`'s `:set_payload` and "node types",
  `ConditionShapeDrift`'s `reason`, `TapResolution`'s seeded-tap limits
  (D-424), `TrimProblemInvalid`'s two D-422 reasons, `ReadResolution`'s
  §14.9, `TwoProducers`' "local wire", and `ArgumentInvalid`'s `:not_built`.
  `DeploymentInvalid` no longer cites Appendix B for the constructors'
  keywords, which B never said.
- **R8. Left out on purpose.** `UserCodeFraming` is constructible at
  `linearize`, which reads `u_types` again, but the build read the same
  declaration already, so only a non-deterministic declaration could throw
  there. `CheckpointMismatch`'s "per-component vector" case has no site and
  went.

## Ruled by the owner

**Q1. A check that reports every violation in its own subject, then stops
the step.** Ruled on 2026-10-21: the spec describes the code. D-431 records
it and annotates D-229. §13.1 states it, C's lead definition of *collected*
names it, and the six entries below now read collected over their unit. C's *fail-fast* says the first occurrence throws on its own and
nothing else is gathered. §13.1 says a malformed container "throws alone"
(D-229). The code instead gathers one unit's violations into one
collection, throws `DiagnosticError{Vector{Diagnostic}}`, and runs nothing
past it:

- one component's child-naming pass: `ContainerMixed`, `ContainerNested`,
  `ChildNameCollision`, `TransparentContainerUnknown`
  (`src/assembly.jl`, `_children`);
- one probe stage's port check: `UndeclaredReturnField` with
  `ConformanceFailure` `:field_type` (`src/build.jl`, `_check_ports`);
- one handler: `HandlerReturnKey` with `ConformanceFailure`;
- the probe's update and projection passes: `ConformanceFailure`. A
  non-NamedTuple return still throws alone.

The code predates D-229 (`3b5b204`, 2026-08-29) and was never conformed.
D-215, ratified earlier, had listed `ChildNameCollision` and
`TransparentContainerUnknown` as collected. D-239's "alone" means without
`DeclaredNotProduced`, which the code honors.

The reason, as D-431 records it: D-229 argued "at once", since nothing
reads past the failure, and never argued "alone". A component with three
mixed containers is fixed in one build cycle rather than three.
