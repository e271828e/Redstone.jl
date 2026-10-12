# Unit A (§1): rulings

Rulings applied: R2 (the five lead-ins become `####` subheadings, the five
criterion names lose their bold and stay as plain opening words, no bold in
the chapter, "debugging, tooling and comprehension" kept verbatim) and R5's F5
as corrected by R14 (old 170–171 becomes "The continuous hot path allocates
nothing, and CI asserts it", both citations kept). Grep of the unit for
other instances of F5's phrasing ("inner loop", "test suite", "allocat"):
none besides the corrected sentence.

Wording changes that carry no claim:

- Old 148 "A model is written as a tree of components" becomes "An author
  writes a tree of components". Lowercase *model* is reserved (part F,
  `spec_style.md` "Terms"); the sentence is about authoring.
- Old 200 "`pending.md` registers" becomes "records". *register* is reserved
  (D-242); the verb meant "records".
- Old 189–191 is split in two at ", and the case studies". The second
  sentence's "against it" becomes "against that code", so the antecedent
  stays FlightCore's code after the split.
- Glosses added, each from a named source: *component* "(the units of
  modeling)", from the glossary's *component* ("the unit of modeling", spec
  12850); "the decision log (`decisions.md`)", from the scope paragraph's own
  "Decision rationale lives in `decisions.md`" (old 206), since Origins uses
  the log before that paragraph names it; "DSL (domain-specific language)",
  per the brief's reader-cold list. *guarded addition* takes the spec's
  standard gloss, "a capability the design admits but does not build"
  (glossary 13892), by recasting old 167–168 around it: "It weighs each
  guarded addition (a capability it admits but does not build) against them."
- The scope paragraph is split after the appendices sentence, so the
  companion files (`pending.md`, `companions/`) take their own paragraph.

## Corrections proposed

None beyond R5's F5.

## Citations added or replaced

None. Every row of §1 is an O row (survey part A): it points at the chapter
that rules it and takes no D-citation at the spot.

## Rationale-only rulings

None.

## Bold on the same entry elsewhere

None. Unit A places no bold and cites no entry.

## Inbound citations affected

- Spec 2178 (§8.1), "The debugging, tooling and comprehension criterion
  ([§1])": the words survive verbatim in the "Rigor and error locality"
  bullet.
- Spec 13892–13895 (glossary *guarded addition*) and 122 (Part I roadmap):
  "the design criteria of [§1]" now also lands on the `#### Design criteria`
  subheading. Unchanged otherwise.
- Pre-existing, not caused by the rewrite: glossary 13893–13894 cites §1 for
  "recorded with its shape so adoption stays additive". §1 never said that,
  before or after; it says only that a guarded addition is weighed against
  the criteria. Track 2 should retarget that second `[§1]` or drop it.
- Pre-existing, already F12: glossary 13885 cites §1 for the supersession
  rule, which is `decisions_style.md`'s.

## Open questions

- Closed by R14: the "Zero-allocation stepping and type stability" bullet
  keeps "type stability" and gains no clause. §7.5's allocation policy is the
  type-instability canary (D-305 bullet 2), so the bullet's [§7.5] pointer
  covers it.
