# Unit G (§4.4): rulings

Rulings applied:

- R6. Two bolds. D-008 at row 143 (old 604–607): "**Ordinary ports carry
  them as immutable query objects**", with "therefore" turned into a trailing
  "because of that shape", so the rule is not stated as a consequence. The
  port gloss "(a port is one declared name with its cell)" sits after the
  bold span, so the bold holds the headline clause only (verifier fix 2). D-139
  at row 148 (old 626–628): "**Every field-emitting component must expose the
  map (component, input values) → handle as a plain, pure, public
  function**". Row 149's "one-line call" is the same ruling and stays plain.
  The other old bold spans (parametric/bulk-data lead-ins, the cache lead-in,
  "idiom built on top", "one-line call") go plain. The lead-in "The
  value-level constructor." becomes a `####` topic label; the term keeps its
  glossary link in the bold sentence ("its value-level constructor"). The
  **Example.** label goes.
- R8. "Caches belong in the consumer's state" (old 622) stays as written. M6
  is not applied, and the optional §4.3 pointer is not added (see Open
  questions, item 2).
- R11. Old 663–664 becomes "Flight.jl's landing-gear model finds contact
  through a bounded ray query to the terrain model, the query a terrain field
  handle's `ray_intersect` serves", from
  `Flight.jl/docs/notes/physics/landing_gear.md` 48 ("Contact determination
  is delegated to the terrain model through a bounded ray query"). The second
  clause restates the old "dovetails" claim, the link between that query and
  the field-handle mechanism, through §4.4's own `ray_intersect(field, p, u)`
  (old 612); it is not an addition (verifier fix 1). Old
  667–668's "today's" becomes "FlightPhysics'" (`terrain.jl` 26, `abstract
  type AbstractTerrain <: ModelDefinition end`). The lowercase "model" in the
  first sentence follows R11's words and the note's own; it names Flight.jl's
  models, not a Redstone `Model`.

Subheadings: `#### The value-level constructor` (the old lead-in) and
`#### Pre-sampling and substitutability` (a declared addition, so the closing
two paragraphs do not sit under the constructor's label). Neither slug occurs
elsewhere in `spec.md` at `d3af35a`. No reorder.

Wording changes that carry no claim:

- Old 619 "whose mutable cell allocates" becomes "whose mutable box
  allocates". Bare *cell* means a signal-table entry only (D-121 Position, log
  3728; glossary *cell*, "Bare 'cell' means only this"); a `Ref`'s cell is not
  one.
- Old 636 "the silent-drift class" becomes "the silent drift", and old 639
  "re-created the drift class" becomes "re-created that drift". *class* is
  reserved (part F; glossary *class*).
- Old 614–615 "Parametric models", "Bulk-data models" become "Parametric
  environment models", "Bulk-data environment models"; old 638 "sub-models"
  becomes "environment sub-models" (part F, lowercase *model*).
- Old 662 "replaces threading `atmosphere`/`terrain` as arguments" becomes
  "replaces Flight.jl's threading of `atmosphere`/`terrain` as arguments"
  (verifier fix 3). Source: FlightApps' `c172.jl` 307 and 706–707 pass
  `terrain::Model{<:AbstractTerrain}` through `f_ode!`; `flight_case_studies.md`
  33 states the same contrast.
- Old 637 "This is a shipped component's obligation" becomes "The
  value-level constructor is …": the antecedent of "This" sat across the
  drift sentence.
- Old 620 "No mutable caches inside field objects, such as memoizing
  interpolators or lazy loaders" becomes "A field object must hold no mutable
  cache, such as a memoizing interpolator or a lazy loader" (a bold lead-in
  restated as a sentence; same prohibition).
- Old 617's parenthesized examples of bulk data become their own sentence, so
  the geoid gloss is not a nested parenthetical.
- Glosses and introductions added, each from a named source: *port* "(a port
  is one declared name with its cell)" (glossary *port*, spec 13030; the gloss
  §8.2 already uses); *component* "(the unit of modeling, leaf or assembly)"
  (glossary 12850); *sweep* linked on "swept" at its first use (old 629),
  glossed "(run by a sweep, one pass through the execution order)" from the
  glossary's "one pass through the execution order" (13117), and old 631's
  "sweep" unlinked as a second link (verifier fix 4). An earlier gloss, "(run
  in each pass through the execution order)", overclaimed: the interior sweep
  walks continuous entries only (glossary 13117), so a discrete stage does not
  run in every pass; *root input* "(the inputs no component produces)"
  (glossary 13035, "produced by no component"); *face* "(the name a port
  wears on its component's boundary)" (glossary 13002); ISA spelled out as
  the International Standard Atmosphere (part F; FlightPhysics'
  `atmosphere.jl` names its ISA model); "the geoid undulation grid (the
  geoid's height above the reference ellipsoid)" (part F's reader-cold list;
  source, R20: FlightPhysics `geodesy.jl` 163, where the EGM96 grid holds
  "geoid height measured from the WGS84 ellipsoid" (163–164), and 226–228,
  which relate ellipsoidal and orthometric altitude "by the geoid's height",
  `HEllip(h._val + get_geoid_height(loc))`). `ISAField`, `TerrainField`,
  `airdata`, `ray_intersect`, `Airflow` and `AbstractTerrainField` are called
  "illustrative" (part F: in neither `src/` nor Flight.jl). `SimpleAtmosphere`
  and `AirData` are called FlightPhysics' (`atmosphere.jl` 260, 198).
  `atmospheric_field` is not called illustrative: D-139's Position names it as
  the function the `SimpleAtmosphere` successor exposes.
- One glossary link added: "abstract input entry" to `#g-abstract-entry`
  (glossary 12829, "It states **structural substitutability**: any concrete
  producer face below the bound wires to it (the field handles, [§4.4], are
  the demonstrated client)"). It is that term's first use in the section; the
  old text left it unlinked. After step 5 (chapter pass finding 32) it takes
  the gloss sentence "An abstract input entry is an input whose declared type
  is abstract", from glossary 12829 ("an `u_types` entry whose declared type
  is abstract"). Before that it took no gloss beyond the sentence's own
  "structural substitutability".

## Corrections proposed

1. **"the silent drift that [§5.3] exists to kill"** (old 636–637). §5.3
   945–948 states the drift ("Computing a law twice invites drift, an edited
   law in one place and a stale copy in the other", D-015, D-342) but was not
   written to kill it (survey part D, last row of "Citations that already rely
   on content chapters 1 to 4 do not hold"). D-139's Position (log 4582–4583)
   carries the same words, so the log owes the fix too. Kept as written, with
   only "class" dropped. Proposed text: "The drift avoided here is the one
   [§5.3][s5-3] warns of, an edited law in one place and a stale copy in the
   other."

## Citations added or replaced

- **D-008** at row 143 (old 604–607, now bold). Position, log 477:
  "Function-valued environment signals + handle pattern."
- **D-139** at row 148 (old 626–628, now bold). Position, log 4575–4579: "the
  map (component, input values) → handle exposed as a plain, pure, exported
  function (`atmospheric_field(atm; T_sl, p_sl, wind)` for the
  `SimpleAtmosphere` successor), with the component's swept output stage a
  **one-line call to it and never the reverse** — stated in [§4.4] as a
  **shipped component's obligation**". The spec says "public", the entry
  "exported"; the spec's word is kept.
- **D-139** at row 153 (old 641–642). Rationale, log 4587–4589 (see below).
- **D-008** at row 155 (old 657–658). Rejected, log 485 (see below).
- **D-296** beside §8.2 at row 159 (old 664–666). Position bullet 1, log
  12551–12553: "Abstract entries state structural substitutability, as
  [§4.4]'s field handles use them." Not bold here: §8.2 2560 bolds it.
- **D-078** at row 160 (old 666–667). Position, log 2390–2392: "Input entries
  are face constraints: wiring check `producer_face <: entry` at nominal
  faces". Not bold here: §8.2 2529, 3984 bold it.

## Rationale-only rulings

- D-139, Rationale, log 4587–4589: "Bulk-data components owe only that the
  query math be *reachable* as a plain function; building a handle outside a
  build may then cost a resource load, acceptable because condition authoring
  is design-time code." Row 153, cited, plain. The log owes a Position.
- D-008, Rejected, log 485: "*Pre-sampling as mechanism:* dependency
  inversion at struts." Row 155 ("an idiom built on top … not a separate
  mechanism"), cited, plain.
- D-008, Rejected, log 484: "*Resource injection:* second composition
  mechanism, invisible." Row 156, already cited in the old text, plain.

## Bold on the same entry elsewhere

None. Grep of units A, C, D, E and F `new.md` for bold spans whose sentence
cites D-008, D-139, D-078 or D-296: none. Chapters 5 to 10 of the base spec
(`scratch_survey/bold_spans_all.tsv`): no bold cites D-008 or D-139; D-078
and D-296 are bold in §8.2 (2529, 2560, 2604, 3984), and this unit cites
them plain.

## Inbound citations affected

None changes target. Rows that quote or name §4.4's words, all kept:
§7.5 2097, 2103 ("The summarize-or-skip rule ([§4.4])": "skip or summarize"
kept); Appendix A 11789 ("**The value-level constructor** ([§4.4])", now
also the subheading); glossary 13019 ("never as mutable caches ([§4.4])");
glossary 13076 and spec 10410, 11074 (the value-level constructor); §8.2 2563
and spec 10275 (`terrain = AbstractTerrainField`); D-237 Rationale log
8960–8962 ("a bulk-data model is an immutable struct combining isbits
parameters with references to data loaded at build time and frozen, never a
`Ref`"); `flight_case_studies.md` 33 (threading `atmosphere`/`terrain`).
Appendix A 11794 still says "re-creating the drift class", the wording this
unit dropped for *class*; it is outside the run.

## Open questions

1. **R8, F11: "Caches belong in the consumer's state"** (old 622), kept as
   written for the owner. A memoizing interpolator or lazy loader cannot live
   in a store (D-231 Position log 8689–8691: every store field is isbits or a
   `Symbol`), nor in a workspace (D-183, §7.3 1914–1915: no information
   between calls), nor across stages (D-342 bullet 2, log 14076–14077).
   Survey part G q8's recommendation stands: strike the clause, leaving "the
   interpolant is restructured to be pure", unless an isbits cache in a
   discrete consumer's `s` is meant.
2. **The cache rule's home is §4.1, not §4.3.** The brief allows the bullet
   to point at §4.3's refusal of mutable port types. I did not add it, because
   that refusal does not reach a cache inside a field handle. The leaf walk
   stops at a non-isbits immutable type and never enters its fields (D-237
   Position log 8950–8953; annotation 2026-09-24, log 8984–8986: "the type
   walk over a contract substitutes parameters and never fields, so a handle's
   references stay frozen with no stop of their own"; D-263 Rationale log
   10522). A bulk-data handle holds a `Vector`, which is mutable, and builds
   (`scratch_survey/run_handle.jl`). So `IllegalPortType` never fires on a
   handle that holds a mutable cache by reference. The rule that forbids it is
   §4.1's "immutability plus frozen references" ("provided that data is
   read-only for the duration of the run", old 461–464), which no build check
   enforces inside a handle. Survey row 146's attribution of the refusal to
   D-237 should be read with that limit. Proposal: if a pointer is wanted, it
   is "([§4.1][s4-1])", and the owner may want to say the rule is the
   author's, unchecked inside a handle.
3. **The loggers' skip-or-summarize rule** (old 624) has no entry (survey row
   147), yet §7.5 2103 calls it a rule. Stated plain and uncited.
4. **"closed for the first cut"** (old 660), held by R13. For the record,
   D-237's Rationale (log 8981–8982) uses the same hedge for a caller-supplied
   root handle, "closed for the first cut ([D-008])", while D-008's Rejected
   list sets no time limit and D-139 (log 4657) calls resource injection
   "rejected".
