# Unit A rulings: the chapter heading, the opening, §5.1 and §5.2 to the views

Line numbers are `spec.md` lines at `b08afca` unless marked `log`
(`decisions.md` at `b08afca`). Claim ids are `inventory.json`'s.
`make_inventory.py` builds the inventory.

## Corrections proposed

None new. Applied as ruled:

- R1, the chapter opening: a context paragraph and one roadmap sentence, all
  in `added`. Its first sentence is spec 130–132 nearly word for word ("It
  fixes two output stages per component, what each stage may see, and how
  those signatures alone yield a static execution order"). Its second is the
  capability bullet at 157–158 ("derives the execution order from declared
  feedthrough and rejects algebraic loops by naming the cycle"). The roadmap
  names §5.1 to §5.6 by their titles. "The central chapter" was left out, so
  the opening claims nothing about Part I. §5.1's declared clause is "A cyclic
  graph is the subject of [§5.5]", in `added`.
- R2, M1: "What the views are" follows the hand-off (A-027 to A-039). The
  roadmap sentence gains "where each view comes from" (A-017).
- R3, as corrected by R14: "The views themselves are unchanged in meaning"
  becomes "The views come from the sources below" (A-028). It claims no count
  and no "each", since the hand-down `y_x`/`y_s` fits none of the bullets.
- R11: the closed spellings sentence stays with its D-074 citation (A-024).
- Reserved words: §5.1's "`(component, stage)` entries" becomes "pairs"
  (A-007), and "the wiring's name binding" becomes "through the wiring, by
  name" (A-032).
- Reader-cold names: `kwarg_decl` and slurping keywords take one introducing
  sentence each, from D-074 Rejected log 2234–2237 ("Keyword arguments via
  `Base.kwarg_decl` reflection: a relied-on seam on an internal binding";
  "Keyword + `_...` slurp"). Both are in `added`.
- Labels: **Rule.** (old 714) and **Why.** (old 719) go. The reasons follow
  the rule as reasons: "The rule exists so that the executor … issues one
  fixed call shape" (A-021), then "Two more reasons support it" before the
  other two (A-022, A-023).
- R13: `#g-cell` is linked at the first "cells" in the views block, glossed
  "(concretely typed entries, one per output port)" from the glossary entry
  (12826). The old "(the declared ports, §8.2)" parenthetical becomes the
  sentence "Those cells are the declared ports (§8.2)", so one sentence holds
  one gloss (A-031).
- PID is spelled out at its first use: "Here `PID` names a
  proportional-integral-derivative controller" (A-020, in `added`).

## Citations added or replaced

| claim | entry | words that rule it |
|---|---|---|
| A-006, the graph and its topological sort, at build time | D-048 Position bullet B, log 1488–1489 | "B, schedule: … feedthrough graph → topo/cycle." Plain; §9.1 3787 bolds D-048 |
| A-007, a flat list with no runtime graph logic | D-086 Position, log 2597–2600 | "schedule data compiled per activation into a concretely-typed entry tuple over statically typed storage, walked by compile-time unrolling". Plain; §9.7 4792 bolds D-086 |
| A-009, exactly two output stages (bold) | D-006 Position, log 430–431 | "Strict two-stage structural feedthrough". D-006 was cited nowhere in the chapter |
| A-011, no dependency annotations | D-006 Rejected, log 440–441 | "*Per-output declarations + tracer verification:* under-declaration = silent wrongness." Listed below |
| A-019, the hand-off (bold) | D-074 Position, log 2216–2218 | "Named-bundle hand-off: every component function is `fn(comp, args)` — one NamedTuple bundle of zero-copy views, destructured by name in the signature" |
| A-025, `x_projection` alone positional (bold) | D-074 Position, log 2218 | "`project(comp, x)` alone stays positional" (`project` is the log's old name; the spec keeps `x_projection`) |
| A-035, produced signals only (bold) | D-035 Position, log 1132–1133 | "the table holds produced signals only, never transported ones (one home per datum)" |

Section pointers added: §5.1 to §5.6 in the opening's roadmap, and §5.5 in
§5.1's declared clause.

Not cited: D-258, which survey part E lists for §5.1. Its Position rules the
words "schedule" and "execution order", not the claims of §5.1. The five view
bullets (A-028 to A-034) carry no citation of their own. D-035's Position
("zero-copy views of the stores it genuinely reads") covers only the state
views. D-035 is cited in the paragraph right after the bullets.

## Rationale-only rulings

| claim | entry | field | log line |
|---|---|---|---|
| A-011, no dependency annotations anywhere | D-006 | Rejected | 440–441 |
| A-024, positional, `kwarg_decl` and slurp spellings closed (old citation, kept) | D-074 | Rejected | 2232–2237 |
| A-039, no minimization of the set without a copy (old citation, kept) | D-035 | Rejected | 1151–1155 |

The reason `x_projection` stays positional ("nothing to select", A-026) is
recorded in no entry.

## Bold on the same entry elsewhere

None for the same ruling. Chapters 7 to 10 of the base spec bold none of
D-006, D-074 or D-035. They bold D-048 (§9.1) and D-086 (§9.7), which §5.1
cites plain. Among the other units' `new.md` files, unit B bolds D-074's
Rationale ruling, the bundle law, and unit C bolds D-035's last ruling,
`y_state` as the no-feedthrough stage. Each is a different ruling of the
entry from the ones bold here. D-074 is therefore bold three times in §5.2,
once per ruling: the hand-off (A-019), `x_projection` (A-025) and the bundle
law (unit B).

## Inbound citations affected

- Spec 130 and 158 (Part I roadmap, capability bullet): the opening quotes
  them; they hold.
- Spec 2075, 4798 and glossary 12939, "zero runtime graph logic ([§5.1])":
  hold. A-007 keeps "no runtime graph logic". Glossary 12939 keeps "`(component,
  stage)` entries" where §5.1 now says "pairs"; the claim is the same.
- D-258 Position, "[§5.1] is "The ordering problem"": holds.
- Spec 309, 1978, 12797 (two output stages, structural feedthrough, no
  dependency annotations): hold (A-009 to A-011).
- Spec 379, 1576, 11626 and glossary 12867–12869 (one home per datum, no
  mirroring, produced signals only): hold (A-035 to A-038).
- Spec 1752 and `event_visibility_walkthrough.md` 38 (the bundle of views,
  `fn(comp, args)`): hold (A-019, A-021).
- Spec 1555 and 1869, "the argument rule of [§5.2]": §5.2 still calls it the
  hand-off. Survey part D already lists this for track 2.

## Open questions

1. **Glossary links that M1 makes first in §5.2.** M1 puts the first prose
   uses of *tier* and *port* in §5.2 into "What the views are", so A links
   both there (with a gloss for *tier*; *port* in the sentence "Those cells
   are the declared ports"). The old text linked them in the bundle law's
   table (old 734, 740). Unit B's current `new.md` links neither, so nothing
   duplicates now. At assembly, check that B adds no second link to
   `#g-tier`, `#g-port`, `#g-cell`, `#g-bundle` or `#g-view` in §5.2.
2. **`store` before its link.** The hand-off's `x_projection` sentence (old
   725) uses "store" before "What the views are" links it, as the old order
   did. Moving the link up would leave M1's bullet unlinked. Left as is.
3. **Unglossed links.** *buffer* and *stores* in the first view bullet take no
   parenthetical gloss; the home sentence three sentences on says what each
   holds. *views* in the hand-off is glossed only by "zero-copy" and by the
   subsection that follows. Adding glosses there would put two parentheticals
   in one sentence.
4. **Old vocabulary.** D-074's Position says `project`; the spec keeps
   `x_projection`. D-006's title says `h_x`/`h_xu`; nothing of it is imported.
