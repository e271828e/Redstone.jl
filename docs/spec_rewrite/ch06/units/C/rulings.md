# Unit C (§6.2): rulings, citations and open points

## Corrections proposed

None applied beyond R3, R7, R8 and R9. Points left as written, for the
orchestrator:

1. **F6, left as written.** "For example, the landing gear `Ldg` sums its
   three struts and exports `wrench`. The systems assembly sums `aero + ldg +
   pwp`. The vehicle wires the systems totals into the rigid-body equations
   of motion." (old 1449–1451) against the `local_wires(::Systems)` block
   (old 1403–1410), where `Systems` wires its own total into a `dynamics`
   child. Only the label, F5's `wrench` and R3's wording changed.
2. **Applied at the verifier's round (R11 to R14).** R11: "Every bookkeeping
   mistake at the junction is loud under the declaration layer" (C-023). R12:
   "`Wrench` is FlightPhysics' force-and-torque type, here parametrized by its
   scalar type as a walked type of §7.2" (sources: `dynamics.jl` 114–117,
   `migration_outline.md` 37–39). R13: "Contributors are ragged, each having
   only some of the three quantities" (C-058; D-037 annotation, log
   1203–1207). R14: the `Systems` sentence gains "and a child `dynamics`
   that consumes the total", describing the sketch only. F6 stays flagged.

## Citations added or replaced

- **D-037 at the rule** (old 1366): Position, ruling 1, "Aggregation by
  explicit summing junctions (generic positional or named site-specific —
  plain components)". Bold.
- **D-037 at the idiom** (old 1441): Position, ruling 2, "hierarchical idiom:
  junctions at ownership boundaries, totals exported across generic
  boundaries". Bold. "Generic boundaries" is stale since D-207 (survey
  part E); the spec does not import it.
- **D-037 at fold order** (old 1424): Position, ruling 3, "fold order
  author-visible". Bold. The citation moved from the bullet's last sentence
  (old 1428) to the bold sentence, in the same bullet.
- **D-037 at the sugar** (old 1466): Position, ruling 4, "helper/macro sugar
  guarded". Bold.
- **D-007 dropped** at old 1503 and 1505 (F9). D-007 is superseded by D-037.
  D-037 Rejected bullet 1 carries the content: "canonical-fold,
  multi-connection legality and identity-element machinery all retired".
- **D-311 at the Bool gates** (old 1396): Position bullet 2,
  "`SumJunction{V, N}`, `Or{N}` and `And{N}` are constant aliases at `+`,
  `|` and `&`". Repeated because M7's paragraph split separates the gates
  from the parameters sentence.
- **D-062 at the library's seed** (old 1469): Position bullet 3, "A standard
  component library (summing junctions, Bool gates) ships as ordinary
  components". Its "demand-driven" and separate gate types are stale (D-313,
  D-311); the spec imports neither.
- **D-313 at the inventory's growth** (old 1472, F8): Position, "A block
  joins the standard library's inventory by judgement against three
  guidelines, none of them a requirement."
- **D-084 on R7's added sentence** ("A contributor's output that nobody wires
  stays legal and silent, as any unconnected output does"): Position, "No
  unconnected-output warning".
- **D-143 at the spelling** (old 1486): Position, "[§6.2] gains the spelling
  for a zero-contributor aggregate" and "`Constant(Wrench()) →
  dynamics/wr_ext` is the whole remedy". Bold.
- **D-143 at the not-a-default clarification** (old 1493): Position,
  clarification (i), "this is not §6.1's banned default in component
  clothing but its opposite — the banned default is silent and
  consumer-declared, the `Constant` is loud and assembly-declared, the author
  writing both the child and the wire, both inspectable structure". Bold.
  D-143 is cited nowhere for the ban itself (lesson 16): "§6.1 bans
  unconnected inputs and silent defaults" keeps only its pointer and D-037.
- **§8.6 for §3.3** at old 1443 (F19).
- **§7.2 added** in R12's clause: `migration_outline.md` 37–39, "the walked
  class of [§7.2]", lists `Wrench` among the payload types the pass
  parametrizes.
- **§6.1 pointer added** at "Every input port takes exactly one connection,
  everywhere" (old 1371), since §6.1 states and bolds the rule (survey
  part B, overlap 1).

## Rationale-only rulings

- **Do not bundle the three quantities** (old 1461–1464, cited D-037): D-037
  Rejected bullet 3 and its annotation, log 1201–1207.
- **The identity element is deliberately absent** (old 1483–1484, cited
  D-037): D-037 Rejected bullet 1, log 1195–1198; also D-143 Rejected
  bullet 1, log 4884–4887.
- **The cost, and every bookkeeping silence inverted** (old 1500–1503, cited
  D-037): D-037 Rejected bullet 2, log 1199–1200.
- **Consumer-declared folds with multi-connection legality are closed** (old
  1505–1506, cited D-037): D-037 Rejected bullet 1, log 1195–1198.
- Uncited as before, ruled only in Rejected lists: "There is no framework
  aggregation mechanism" and its list (old 1369–1370; D-037 Rejected
  bullet 1, D-062 Rejected bullet 1), and the first three bullets of "What
  the explicit form buys" (D-037 Rejected bullets 1–2; D-311 Rationale, log
  13033–13035, for "arbitrary stage-2"). Survey part E, items 8 and 9.

## Bold on the same entry elsewhere

- **D-311 bullet 3** is bold here and at §13.7 (spec 10004 at the base,
  "Arity and port types come from type parameters"). §13.7 is not
  rewritten; R4 sends its bold to chapter 13's carry list.
- D-313 is bold at §13.7 (spec 9974); §6.2 cites it plain.
- D-084 is bold in unit B's `new.md` ("Unconnected output ports are legal,
  silently, with no build-time warning"); §6.2 cites it plain.
- D-037 and D-143: bold nowhere else (chapters 7 to 10, §13.7, units A and B
  as found).

## Inbound citations affected

None breaks. Checked against `inbound.tsv`'s §6.2 rows:

- spec 2063 (`SumJunction{Wrench{Float64}, 3}`) holds; F1 makes old 1400
  agree with it.
- spec 2064 ("at the price §6.2 states openly") holds: "at the price of
  hard-coding it into a type" and "A stale arity surfaces as one or the
  other" stay.
- spec 4873 and log 5688 ("made every sum an ordered junction entry") hold:
  fold order stays author-visible and positional.
- spec 9659 ("the ownership idiom, §6.2"), 9962, 10095, 12836, 12911 hold.
  12911 quotes "There is no framework aggregation mechanism" word for word.
- log 1203 (D-037's migrated census) stays true as history; R8 finishes the
  migration.
- `flight_case_studies.md` 30 and `migration_outline.md` 18 hold; the C172
  count stays in §6.2 (R3).
- Spec fields at landing: D-062, D-084 and D-313 gain §6.2. D-007 loses its
  last two spec citations (`check_rows.jl` rebaseline).

## Open questions

1. Resolved by R11.
2. **Introducing clauses beyond R3's list.** Section-local re-readability
   needed `Systems`, `ldg` and `Ldg` introduced in §6.2 too. The clauses
   follow R3's unit-A wording and §8.8 3624: "In the block below, `Systems`
   is the systems assembly. Its children include the aerodynamics `aero`,
   the powerplant `pwp` and the landing gear `ldg`, and a child `dynamics`
   that consumes the total" (the last clause R14's), and "the landing gear
   `Ldg`". They describe the sketch, not Flight.jl's tree.
3. **Glosses.** `#g-component` and `#g-port` keep their links without a
   gloss, as rewritten chapters 7 and 8 often do; a gloss on "multi-connection
   ports" would narrow it to inputs. `#g-summing-junction` keeps its link
   unglossed, since the paragraphs before it define the junction.
   `#g-activation` is gone: F18 turned "activation walk" into "leaf walk",
   and §6.2 no longer uses *activation* as a term.
