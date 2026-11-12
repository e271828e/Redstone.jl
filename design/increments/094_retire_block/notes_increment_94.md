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
7. **The log is not swept** (`log_rules.md` rule 2). D-453 records the
   retirement and the names. An entry is annotated where it names the module
   or a parent as a position, or argues from the term: D-062, D-226, D-311,
   D-313, D-316, D-383, D-433. Entries that use the word in passing, such as
   D-143, D-312, D-385, D-410, D-411, D-436 and D-437, are left to D-453.
8. **The increments' records and the reports are not swept**, the paths
   `src/blocks.jl` and `companions/linear_blocks.md` included. They record
   their day, as the split of `implementation.md` left the older briefs
   citing it (`AGENTS.md`).
9. **The descriptor's format does not change.** A node's `type`, `alias`
   and `signature` strings read `Redstone.Library.…` because the module's
   name is their content. A `types` row's source `file` and `line` and its
   `docstring` text change as content too. The schema changes only in its
   description text, which quotes an example alias.

## For the inspector

What its next pin needs, sent to the inspector's session at the code
stage's tip:

- `parentmodule` prints `Redstone.Library`, so a node's `type` reads
  `Redstone.Library.PID`.
- The hosted API anchors follow the module, `api/#Redstone.Library.PID`.
- The anchor `g-block` is gone; the library's docstrings link
  `g-library-component`.
- No descriptor field other than `type`, `alias` and `signature` changes
  its module string. A `types` row's `file`, `line` and `docstring` change
  as content, so regenerated fixtures differ there too.

## The cold review

The review found nothing blocking. The gate ran 9822 of 9822 on 1.13.3, and
the battery and the examples' runner were green. Adjudicated:

- Five new test locals named `children` hid the imported `children`. They
  are `kids` now, the word `src/assembly.jl` uses. The one at
  `test_library.jl:125` was already there before this increment and is left.
- Ruling 7 above was restated, and D-226 and D-311 were annotated, the
  review's option (a).
- §13.5's "one visible block" was the retired sense. It reads "one visible
  junction", as §6.2 does.
- §13.7's "earns no library component" reads "earns no place in the
  library", and the privilege clause cites D-062 beside D-453's term.
- D-453's Position takes the other senses as a bullet, within the
  template's one or two sentences.
- A test comment regained its "only".
- Left as taste or as defensible: "the library component is stateless" in
  the docstrings (docstring rule 25), the 91-column aligned sketch lines in
  `linear_systems.md` (the longest has no padding to give), "unfiltered
  derivative" in the inventory, §8.5 and §14.9 out of D-453's Spec field
  (they gained a link, not a word), and the Simulink contrast in D-453's
  Rationale.
- Already there before this increment, noted only: `code_map.md`'s library
  entry names `AbstractDiscreteLinearSystem` but not `AbstractLinearSystem`,
  and it says `src/Redstone.jl` includes the library last, while
  `precompile.jl` follows it.

The reviewer's delta check confirmed every fix. It found one slip: D-226's
new annotation stood before the Rejected list, ahead of the 2026-10-27
annotation it corrects. It now ends the entry, in date order.
