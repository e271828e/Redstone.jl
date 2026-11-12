# Increment 94: retire the term *block*, notes

The user retired the word on 2026-11-11 and left the names to the session
that writes the ruling (`pending.md`'s first bullet as it stood at
`90c13a1`). The user delegated the increment overnight on 2026-11-12, so
every ruling the coordinator made is recorded here with its reason, and
nothing is pushed (`rules/increment_rules.md`).

## Rulings

1. **The module is `Redstone.Library`, in `src/library.jl`.** The bullet's
   candidate. "Library" is the noun the spec already uses for the thing
   ("the standard library", §13.7), so the module's name and the prose
   agree. `Redstone.Components` would claim for the library a term every
   model's parts share. `Stdlib` and `StandardLibrary` name Julia's
   standard libraries to a Julia reader.
2. **The parents are `AbstractLinearSystem`, `AbstractDiscreteLinearSystem`,
   `AbstractPID`, `AbstractLQRTracker` and
   `AbstractAntiWindupController`.** The first four are the bullet's
   proposals. The fifth replaces the bullet's `AbstractController`, which
   the bullet itself flagged as broad. The type's two parameters are the
   anti-windup axes, and its methods are the gate and the correction's
   reference that the axes set for the integral term. A user's controller
   without the axes could not subtype it, so `AbstractController` would
   name a set the type does not hold. The longer name is typed rarely: it
   is an extension point, not a constructor.
3. **The glossary entry becomes *library component*, anchor
   `g-library-component`.** The phrase replaces the word in dozens of places,
   so it keeps an entry under the coinage rule (`spec_rules.md`), and the
   library's docstrings keep a link target. The entry says what the old
   one said: a component the standard library ships, with no privilege a
   user's component lacks.
4. **The companion `linear_blocks.md` becomes `linear_systems.md`.**
   "Linear system" is the docstrings' phrase, and the parents' new names
   use it.
5. **The test file is `test_library.jl`, routed as `library`.** It is kept
   for its source file, as `test_blocks.jl` was (`code_rules.md`), so it
   follows the file's name.
6. **No aliases and no deprecation shims**, on D-220's terms, as D-314 did.
   Nothing is released.
7. **The log is not swept** (`log_rules.md` rule 2). A new entry records the
   retirement and the names. The entries whose Position names the word, the
   module or a parent are annotated: D-062, D-313, D-316, D-383, D-433.
8. **The increments' records and the reports are not swept**, the paths
   `src/blocks.jl` and `companions/linear_blocks.md` included. They record
   their day, as the split of `implementation.md` left the older briefs
   citing it (`AGENTS.md`).
9. **The descriptor's format does not change.** A node's `type` and
   `alias` strings read `Redstone.Library.…` because the module's name is
   their content. The schema changes only in its description text, which
   quotes an example alias.

## For the inspector

What its next pin needs, sent to the inspector's session at the code
stage's tip:

- `parentmodule` prints `Redstone.Library`, so a node's `type` reads
  `Redstone.Library.PID`.
- The hosted API anchors follow the module, `api/#Redstone.Library.PID`.
- The anchor `g-block` is gone; the library's docstrings link
  `g-library-component`.
- No descriptor field other than `type`, `alias` and `signature` changes.
