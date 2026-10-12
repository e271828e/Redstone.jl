# Unit A (§1): verification

## Counts

- Phase 1: 53 assertions (V1–V53), in `verify_phase1.md`.
- Inventory: 50 claims. MATCH 50, DRIFT 0, LOST 0. Checker: `checks failed: 0`.
- ADDED: 3 listed glosses ("(the units of modeling)", "(`decisions.md`)",
  "(domain-specific language)"). None changes meaning. The *guarded addition*
  gloss is not an addition. It recasts old 167–168 (C-019), which already
  said the same thing.

## Changed claims, all MATCH

- C-007 "A model is written as" → "An author writes". The claim is the same.
  This avoids the reserved lowercase *model*.
- C-019 "Wherever it admits a capability it does not build, that capability is
  weighed against them as a guarded addition" → "It weighs each guarded
  addition (a capability it admits but does not build) against them". The set
  and the quantifier are the same. The gloss matches glossary 13892 word for
  word ("the design" → "it"). "It" refers back to "The design".
- C-021 is F5, word for word as R5 orders, with both citations kept.
- C-036/037: the split is fine. "against it" → "against that code" keeps the
  antecedent (FlightCore's code).
- C-045 "registers" → "records". The claim is the same.

## Glosses against their sources

- *component* "(the units of modeling)": glossary 12850 says "the unit of
  modeling". Holds.
- *guarded addition*: glossary 13892. Holds.
- "(`decisions.md`)": old 206 names the log's file. Holds.
- "DSL (domain-specific language)": a plain expansion. Holds.

## Pointers and overreach

All six capability bullets keep their pointers unchanged (§2/§10, §3.2/§10.5,
§5/§9, §11/§12, §11.5, §14). The five criterion bullets keep theirs too. The
old and new citation multisets are identical (21). The rewrite changed only
one sentence of substance. That is F5, and it overreaches slightly:

- F5 says the phase bodies "allocate nothing, and CI asserts it" with no
  qualification. §7.5 (old 2084–2090) gives ticks and handlers a budget of
  "zero by idiom" with "a documented tolerance" for the rare exception (D-116).
  §9.7 (old 5191–5194) says that tolerance "loosens exactly one assertion".
  The old "inner loop" sentence overreached the same way, and R5 dictates the
  wording. Not a DRIFT. Owner's note: a possible fix is "allocate nothing
  outside documented tolerances".
- The rulings' open question stands: nothing in the bullet backs "type
  stability". The cited §7.5 covers it only as the canary.

## Citations

Every old citation survives with its claim. rulings.md adds or replaces none,
so no log entry needed checking.

## Bold

There is no bold in new.md, as R2 requires. The criterion names are plain
opening words. "debugging, tooling and comprehension" is kept word for word,
so the §8.1 quote at old 2178 still lands.

## Moves

R2's five `####` subheadings are in place, in the old order. Two paragraph
splits (the Origins sentence, and the scope paragraph after the appendices)
are layout, not moves. There are no other moves.

## Reader-cold names

- (3) `FlightCore` is named as the predecessor. Fine.
- (1) `FlightPhysics` and `FlightApps` are introduced with their owner and
  role ("its physics library", "its applications"). Fine.
- "phase bodies" (new, from F5) is a glossary term (g-measurement-seam) that
  appears here unlinked and unglossed. A reader of chapter 1 meets it cold.
  The pointers to §7.5 and §9.7 cover it as an overview pointer. Optional fix:
  link it as `[phase bodies](#g-measurement-seam)`. That is markup only, and
  the ruled words stay.
- "stopped-sim services", "staging", "snapshot", "ticks", "feedthrough" and
  "input trace" are all used before their chapters. Each sits in a bullet
  that points at the chapter that defines it, which the brief allows for
  chapter 1.
- `pending.md` and `companions/` are named without a location. This is
  unchanged from the old text.
- No aerospace example needs an introducing clause.

## Other

None.

## Re-check (after R14)

- C-021 now reads "The continuous hot path allocates nothing, and CI asserts
  it" and keeps both citations. That is R14's text word for word. It matches
  §7.5 old 2078–2083, where the continuous hot path (per-stage evaluation,
  guards and `x_projection`) has the budget "exactly zero, CI-enforced". It no
  longer covers ticks and handlers, which have D-116's tolerance. MATCH. The
  overreach noted above is closed.
- The "phase bodies" note under reader-cold names is moot now. "Continuous hot
  path" is a §7.5 term, and the bullet points at §7.5. R14 also settles the
  type-stability question, since D-305 bullet 2 makes the policy the
  type-instability canary.
- I compared new.md with the copy verified above. Lines 39–40 (the F5
  sentence) are the only change.
- The inventory tags C-021 as R14, and rulings.md records it.
- `check_unit.py ch01-04 check A` still prints `checks failed: 0`.

Verdict: pass. 50 of 50 claims match, with nothing drifted or lost.
