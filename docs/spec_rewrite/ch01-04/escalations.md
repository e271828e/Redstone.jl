# Escalations: chapters 1 to 4

Serious findings, left as written in the text and sent to the owner when the
run closes.

## E1. Mutable caches "in the consumer's state" (§4.4, base 620–623)

The bullet "No mutable caches inside field objects" ends: "Caches belong in
the consumer's state, or the interpolant is restructured to be pure." The
home it names is closed three ways:

- D-231: every field of an `s` or `m` store value is isbits or a `Symbol`.
- D-183: no information passes between workspace calls.
- D-342 bullet 2: output stages are pure; no mutable cache carries values
  between stages.

Unit G's rewriter also found that no build check backs the bullet itself:
§4.3's `IllegalPortType` refusal never looks inside a field handle, since the
leaf walk stops at the handle (D-237, its 2026-09-24 annotation; D-263's
Rationale), and a bulk-data handle holding a mutable `Vector` builds. The
rule against a mutable cache inside a field object rests on §4.1's
"immutability plus frozen references" alone.

Recommendation: strike "Caches belong in the consumer's state", leaving "the
interpolant is restructured to be pure", unless an isbits cache in a discrete
consumer's `s` is meant, in which case say so. Evidence: survey F11 and q8;
units/G/rulings.md, open question 2.
