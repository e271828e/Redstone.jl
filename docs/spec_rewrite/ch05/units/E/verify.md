# Unit E verify

**Counts.** 65 phase-1 assertions. 63 inventory claims: 59 MATCH, 4 DRIFT, 0 LOST. 6 `added` entries, none changing a ruling. Checker: 0 failures. Fence byte-identical. Both quoted diagnostics verbatim. No moves.

## DRIFT

- **C-010 (gloss).** Old: "The tracer ([§5.6]) labels it artificial." New: "(the diagnostic that classifies a rejected cycle, [§5.6])". The glossary (spec 13672) calls the tracer an instrument. Here the noun "diagnostic" means the build report ("dodging the diagnostic"). Fix: "(the instrument that classifies a rejected cycle as real or artificial, [§5.6])".
- **C-054 (scope).** Old: "insert dynamics (the α-filter idiom)". New: "The dynamics route is the α-filter idiom, a filter state inserted in the loop." "Is" makes the α-filter the only way to insert dynamics. Fix: "insert dynamics (the α-filter idiom, a filter state inserted in the loop)".
- **C-058 (gloss, R5 F6).** New: "sampled on a `Δt_base`-scale period (the base tick period, …)". The gloss attaches to "period" and says the period is the base tick, which undoes F6. Fix: "sampled on a period on the scale of `Δt_base`, the base tick period (an integer multiple `N_base·h`)".
- **C-040 (citation scope).** D-245 shares one parenthetical with §8.6 and §13.2 on "separate payload field rather than dotting it onto the path". Bullet 2 (log 9230) carries only "Every dead hop is listed". Fix: "carries the dead hop ([D-245][d-245]) as a separate payload field rather than dotting it onto the path ([§8.6][s8-6], [§13.2][s13-2])".

## ADDED

- `ψ_sw` sentence: nearly D-140's own words (log 4643–4645). It states only the before-wiring the diagram shows. Within its source; acceptable. It has no D-140 cite of its own; the nearest is four sentences on.
- Genuine-cycle sentence: a pointer plus the glossary's definition (12926). "Simulink calls this" still points at sentence 1.
- R7 and R12: applied as worded. R12 claims only what spec 10042 says.

## Citations

All 10 old citations survive with their claims. D-140 is cited 4 times, and each field named carries its claim: Position 4629 (bold), Rationale (ii) (substitution test), 4660 (both exits), 4662 ("rare" earned). D-194 bullet 6 ("no `Private` level is added") carries C-035. D-005's Position carries the bold. D-245: partial, see C-040.

## Bold

Two bolds, each a ruling headline followed by its D-entry. None is doubled, and none falls on a mechanism or lead-in. The D-140 bold claims exactly the Position. Survey part A (line 415) puts that bold "at the sentence that names the rungs". It exceeds R10's "add only" by one sentence but states only the count; acceptable, worth noting.

## Rulings

R5 F6 applied, but see C-058. R7, R10 (bullets unnumbered, conservatism last), R11 and R12 applied as worded. No unordered correction. All antecedents resolve: "it is the rung", "That case", "Its cost" and "That is a real cost".

## Reader-cold names

- (1) Used without introduction, as in old: `StrutGeometry` (only "in the strut example"), `ψ_cmd`, `engaged`, `unlisted`/`Private(T)` and `migration_outline.md`. `ψ_sw` is introduced but its meaning is never glossed. D-140 gives no gloss to draw on.
- (2) The strut/steering pair, as Flight.jl's landing gear. True: `FlightPhysics/src/landinggear.jl`.
- (3) None.

## Re-check

All four fixes landed as targeted. The checker reports 0 failures, and the inventory spans match new.md.
- **C-010** now reads "the instrument that classifies a rejected cycle as real or artificial", as the glossary has it.
- **C-054**: the α-filter gloss is a parenthetical inside the routes sentence. All three routes stand, and the α-filter is no longer the only one.
- **C-058**: the gloss follows the `Δt_base` link directly ("a period on the scale of `Δt_base` (the base tick period, …)"). F6 holds.
- **C-040**: D-245 now sits on "carries the dead hop", and §8.6 and §13.2 sit on the payload-field form.

Extra fix:
- **C-036**: "the `unlisted` presentational flag" is D-034's Rejected wording (log 1119), and "the `Private(T)` wrapper" is D-055's (log 1656). The sentence adds nothing the old parenthetical did not already say. "The two visibility spellings they reject" is slightly loose, because D-034 also rejects "`Private(T)` contract entries", but it does not mislead. R11 still holds, with the citations kept.
- **C-026**: the companion document `docs/design/companions/migration_outline.md` exists at b08afca. Correct.

I found no other change. The bolds, the fence, the quotes and every other sentence are as before.
