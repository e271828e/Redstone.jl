# Unit G (§4.4) verify

**Counts.** 41 inventory claims: 40 MATCH, 1 DRIFT (ordered by R11), 0 LOST. 41 phase-1 assertions, all sourced. ADDED: 14 declared items (glosses, "illustrative" markers, one subheading). None changes meaning. `check_unit.py` prints `checks failed: 0`. The code block is byte-identical to old.md, and old.md matches spec.md 602–671 at the base.

## DRIFT

- **C-038 (R11).** Old: "It dovetails with the terrain ray-query direction of the landing-gear redesign." New: "Flight.jl's landing-gear model finds contact through a bounded ray query to the terrain model." The fact checks out. `landing_gear.md` 48 reads "Contact determination is delegated to the terrain model through a bounded ray query", and `landinggear.jl` 247 implements it with `SurfaceIntersection(terrain, …, ks_e, l_0)`, so the present tense is right. The new sentence drops the old claim's link to §4.4's mechanism. The old "It" was the field-handle mechanism, and "dovetails" said that mechanism fits the ray query. The new sentence now stands alone between "replaces threading" and substitutability. R11 ordered this drop. Fix, if the owner wants the link kept: "…to the terrain model, the query a terrain field handle's `ray_intersect` serves." The old text already made that claim.

## Checks asked for

- **R8.** "Caches belong in the consumer's state, or the interpolant is restructured to be pure." This is verbatim.
- **"mutable box"** keeps the claim. A `Ref` is a heap-allocated mutable object, and bare *cell* is reserved.
- **"silent drift"** and **"that drift"** keep the claim. "that drift" refers back to "the silent drift" across one sentence, and the reference resolves.
- **"Parametric/Bulk-data environment models"** and **"environment sub-models"** keep scope. Every model in the section is an environment model. D-139 says "sub-models", and a field-emitting component's sub-models are environment models.
- **R11's "FlightPhysics' `AbstractTerrain`"** is confirmed: `terrain.jl` 26 reads `abstract type AbstractTerrain <: ModelDefinition end`.
- **Define-before-use.** "swept output stage" (new 37) comes one sentence before *sweep* is linked and glossed (new 39). §3.4 (spec 376) already links *sweep*, so a reader of chapters 1 to 4 has met it. This is acceptable. To tidy it, put the link and gloss on "swept". Under the added `####` "Pre-sampling and substitutability", *pre-sampling* is defined in the sentence after the heading, as in the old text. "The field-handle mechanism replaces threading…" and the R11 sentence fit neither word of that label. This is minor.

## Citations

Every old citation survives with its claim (§14.1, §5.3, D-008, §8.2). Added citations carry their claims:
- D-008, Position 477 ("Function-valued environment signals + handle pattern"), for the bold. Rejected 485 carries "not a separate mechanism".
- D-139, Position 4575–4579, for the bold. Rationale 4587–4589 carries the bulk-data claim (rationale-only, as listed).
- D-296, bullet 1 at 12551 ("Abstract entries state structural substitutability, as §4.4's field handles use them"). Not superseded.
- D-078, Position 2390–2392 (`producer_face <: entry`). It carries "wires to any concrete field type below the bound".

## Bold

Two bolds, one per ruling, each with its D-citation in the same sentence. **D-008**: "+" joins a single ruling, so one bold is right. "because of that shape" keeps the old "therefore" direction (shape is the cause, carriage the result), and the reason now follows the rule. Minor: the bold contains the port gloss "(each one declared name with its cell)", which adds weight that is not part of the headline clause. Fix: move the gloss out of the bold, or put it in a short plain sentence after this one. **D-139**: this is the headline clause. "one-line call" and "shipped component's obligation" stay plain, so the ruling is not stated twice in bold.

## Reader-cold names

- (1) "threading `atmosphere`/`terrain` as arguments through every update signature" describes Flight.jl's practice without naming it (`c172.jl` 307, `f_ode!(mdl, terrain, …)`). Fix: "replaces Flight.jl's threading of…".
- (2) `T_sl`, `p_sl` and `wind` (sea-level temperature and pressure) are not introduced. This is minor, since they are illustrative parameters.
- All other names are marked illustrative or FlightPhysics' (`SimpleAtmosphere` 260, `AirData` 198, both confirmed). Flight.jl and FlightPhysics are introduced at spec 186.

## Re-check

`check_unit.py` prints `checks failed: 0`. Apart from the four edits, the text is unchanged.

1. **R11** now reads "…to the terrain model, the query a terrain field handle's `ray_intersect` serves". This restores the old "dovetails" claim that the mechanism fits the ray query, with no new claim. `ray_intersect` is introduced at new 15 as illustrative. C-038 is now a MATCH.
2. **D-008's bold** is now only the headline clause, "Ordinary ports carry them as immutable query objects", and the port gloss follows outside it. "because of that shape" still closes the sentence, so the shape is the cause and carriage by ports is the result, as in the old "therefore". "called field handles" comes after the closed parenthesis, and it still refers to the query objects. OK.
3. **"replaces Flight.jl's threading of `atmosphere`/`terrain`"** is confirmed. `c172.jl` 307 and 706–707 pass `terrain` to `f_ode!`, and `atmosphere::Model{<:AbstractAtmosphere}` is threaded at `c172s.jl` 230, `c172x.jl` 291 and `c172.jl` 827 and 871. OK.
4. **The sweep link** is on "swept", and it is the only *sweep* gloss. "only a sweep can reach it" and "outside any sweep" therefore come after the gloss. No term is left unexplained.

DRIFT (new). The gloss is now "[swept] output stage (run in each pass through the execution order)". That overclaims. Per the glossary at spec 13117, the interior sweep walks continuous entries only. A discrete field-emitting component's output stage therefore runs only in boundary sweeps when it is due, not in each pass. The old text claimed nothing about how often the stage runs. Fix: "(the stage a pass through the execution order runs)", or keep the glossary's own words, "[swept] output stage (run by a sweep, one pass through the execution order)".

Verdict: three of the four edits pass. The fourth needs its gloss changed from "each pass" to "a pass" or "a sweep".

Second re-check: "[swept] output stage (run by a sweep, one pass through the execution order)" now uses the glossary's own definition of *sweep* (spec 13117) and claims nothing about how often the stage runs, so it passes. Apart from this gloss and its rewrap, new.md is unchanged, and `check_unit.py` prints `checks failed: 0`. Unit G passes.
