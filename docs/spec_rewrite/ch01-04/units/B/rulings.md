# Unit B rulings: §2, §2.1 and §2.2

Line numbers are `spec.md` lines at `d3af35a` unless marked `log`
(`decisions.md` at `d3af35a`). Claim ids are `inventory.json`'s, which
`make_inventory.py` builds. Words: 631 old, 859 new (normalized), after the verifier's fixes.

## Corrections proposed

None new. Applied as ruled:

- R5 F1 (B-062): old 291–292 becomes the brief's sentence verbatim, citing
  [§5.3], [D-001] and [D-141]. Source: FlightPhysics `landinggear.jl` 467,
  `!strut.y.wow && f_init!(contact.frc) #if !wow, reset friction regulator`;
  D-141 Position log 4737–4738 ("The gear wires `strut.wow → frc.reset` (the
  touchdown edge)"). `!wow` occurs nowhere else in the unit.
- R5 F2 (B-008): "applied after each accepted step and after any handler
  reset of `x` ([§5.3])". §5.3 1019–1021. "accepted step" occurs once.
- R5 F4 (B-018): "one guard evaluation per event per iteration round
  ([§10.6])". §10.6 6093–6099. "per event per step" occurs nowhere else.
- R4 (i), M3: §2.1 runs one declaration (B-013, B-014); predicate and forms
  (B-035 to B-037); edges, prior, opposite direction, D-180 (B-038 to B-042);
  return type, plain (B-043 to B-046); "The two policies follow", moved after
  the §10.4 pointer (verifier fix 4); the two policies (B-015 to B-022);
  pace-independence (B-023); "the crossing defines the transition" (B-032 to
  B-034); time and state events last (B-024 to B-031).
- R4 (ii): §2's continuous bullet gains "This design's `f` also receives the
  published table, and the composite map from `x` to $\dot{x}$ is identical
  to the textbook form's ([§5.3])", in `added` (verifier fix 3: "mathematically
  identical" compared with nothing). §5.3 954–956 gives the textbook form. §5.3 956–958: "This design's
  `f` receives the orthodox arguments *plus* the published table … The
  composite map $x \mapsto \dot{x}$ is mathematically identical". No new
  formula; old 217–218 stay as written.
- R3: "[§2.1] gives the two event-detection policies, and [§2.2] the
  exclusions taken deliberately", in `added`, after the five-part list. Part I
  roadmap 124–126: "It fixes the class of systems in scope, the two
  event-detection policies, and the exclusions taken deliberately."
- R5 D-180: "A per-event `direction` keyword is recorded as a guarded addition
  (…), unbuilt ([D-180])", in `added`, after the opposite-direction sentence.
- R9 (i): the third exclusion gains "because its semantics depend on the step
  size ([D-001])" (B-056). "so no `f_step!` equivalent" becomes its own
  sentence, "So there is no equivalent of `f_step!`, FlightCore's per-step
  hook" (B-055), which introduces `f_step!` (FlightCore `modeling.jl` 214).
- §2.1's return-type paragraph (B-043 to B-046) loses its bold and keeps its
  D-179 citation in the next sentence, as before; §10.4 5415 bolds D-179.
- Reserved word: "For one class the mapping tightens semantics" becomes "For
  one group of uses" (B-060).
- Reader-cold names: DCM spelled out (B-009); DAE and SDE spelled out in the
  item names (B-048, B-050); `!wow` glossed by F1's own words; `f_step!` as
  above.
- R16 (B-051): no introducing sentence for Dryden/von Kármán. The sentence now
  reads "Noise processes, such as sensor noise and turbulence from Dryden/von
  Kármán turbulence models, are modeled as shaping filters ([D-001]), that is,
  as ordinary discrete processes driven by a random number generator (RNG)".
  The "that is" equivalence is the old one, with its two sides swapped so RNG
  is spelled out at its first use.
- R17 (B-013, `added`): §2.1 opens with "**Events have two detection
  policies** ([D-001])", D-001's two-tier events. "Both policies share one
  declaration" is plain, citing D-179. D-082's edge bold stays (B-038).
- Verifier fix 7: D-179 moves from "Detection resolution is an
  execution-policy detail" (B-034) to "The crossing defines the transition"
  (B-033), which "semantics-preserving by construction" carries.
- "Every current use" becomes "Every current use of `f_step!`" (B-057), naming
  the referent the survey found unsaid (part A row 46). The uses are
  Flight.jl's.
- "how they are specified" becomes "how the noise processes are specified"
  (B-052), so the antecedent survives the restructured sentence before it.
- Glosses, all in `added` or inside their claim's span and drawn from the
  glossary: *tick* (§2 lead), *guard* (§2 lead, "each defining an event's
  predicate"), *prior* (an appositive), *boundary* (inside the prior's
  sentence, its first use in §2.1; verifier fix 6 dropped the later link in
  the boundary-detected bullet), *guarded addition*, *pacing* (as a sentence:
  "The pacer inserts waits between completed frames and never alters the
  boundary sequence", glossary 13224), *replay*, and *projection* in §2.2 as
  an appositive. The §2.1 tick sentence is gone (verifier fix 5): the §2
  bullet keeps the tick gloss.
- Glossary links: the second `#g-edge-semantics` link (old 236, on
  "holding") is dropped; "edge semantics" keeps the link. `#g-guarded-addition`
  is new, with D-180's sentence. `#g-boundary-detected` and `#g-localized` now
  sit in the return-type paragraph, their first use after M3; the bullet item
  names are plain. *tier* and *component* are linked without a gloss: the
  only first uses sit inside a bold headline clause or a dense sentence.

## Citations added or replaced

| claim | entry | words that rule it |
|---|---|---|
| B-002 (bold) | D-001 Position, log 359 | "Hybrid causal formalism" |
| B-002 | D-002 Position, log 376 | "Causal port-based paradigm" |
| B-005 | D-019 Position, log 715–716 | "discrete stages gated to own tick instants (ZOH by construction)" |
| B-007 (bold) | D-001 Position, log 359 | "projection" |
| B-008 | §5.3 1019–1021 | "That is after integration, and after any handler `x`-reset. Those are the only positions" |
| B-011 | D-022 Position, log 809–810 | "staged inputs drained at frame top" |
| added (§2.1 lead, bold, R17) | D-001 Position, log 359 | "two-tier events" |
| B-013 | D-179 Position, log 6539–6540 | "`Event(guard, handler)` loses the `localize` keyword" |
| B-018 | §10.6 6093–6099 | "One round re-runs the boundary sweep …, evaluates all guards … Rounds continue to quiescence" |
| B-020 | D-018 Position, log 687–688 | "bracketed derivative-free root-finding" |
| B-023 | D-080 Position, log 2459–2461 | "detection is pace-independent: localization runs identically in every execution mode" |
| B-024 (bold) | D-220 Rationale, log 8248–8253 | "The discrete tier's ticks, declared by `sample_times`, are *time events*" (Rationale only, below) |
| B-029 | D-220 Position bullet 4, log 8188 | "`events` → `state_events`, and the pair type `Event` → `StateEvent`" |
| B-033 | D-179 Position, log 6540–6541 | "de-localization = casting the guard to its predicate (… semantics-preserving by construction)" |
| B-035 (bold) | D-082 Position, log 2509–2510 | "a guard defines a condition (`Bool` predicate, or continuous with positive = holding, `σ ≥ 0`)" |
| B-035 | D-001 Position, log 360–361 | "guard conditions are normative — positive = holding, edge semantics ([D-082])" |
| B-038 (bold) | D-082 Position, log 2510–2511 | "events fire on not-holding → holding edges against a per-event baseline" |
| B-038 | D-001 Position, log 361 | as for B-035 |
| B-041 | D-082 Rationale, log 2519–2520 | "opposite direction = second event with negated guard" (Rationale only, below) |
| added (D-180) | D-180 Position, log 6568–6569 | "Per-event `direction` (`:upward`/`:downward`/`:both`) is recorded as a guarded addition, unbuilt." |
| B-051 | D-001 Rejected, log 369 | "*SDEs:* shaping filters suffice." |
| B-054 | D-231 Position, log 8692–8693 | "A PRNG object is workspace; the values that determine its next draw are the state." Plain; §7.3 1975 bolds it |
| B-056 | D-001 Rejected, log 370 | "*`f_step!`:* step-size-dependent semantics." (R9) |
| B-062 | D-141 Position, log 4730–4738 | "Even a commanded continuous reset … is spelled as an event whose guard reads that input … The gear wires `strut.wow → frc.reset` (the touchdown edge)." (F1) |
| added (§2.2 lead, bold) | D-001 Position, log 359–360 | "no DAE/SDE/per-step hook" |

## Rationale-only rulings

| claim | entry | field | log |
|---|---|---|---|
| B-024 to B-031 (bold on B-024): ticks are time events, a declared `StateEvent` is a state event, the criterion is detection against scheduling | D-220 | Rationale | 8248–8253 |
| B-041: the opposite direction is a second event with the negated guard | D-082 | Rationale | 2519–2520 |
| B-056: the per-step hook's step-size-dependent semantics | D-001 | Rejected | 370 |
| B-051: noise as shaping filters | D-001 | Rejected | 369 |

The log owes a Position for the first two (survey part E, items 1 and 2).

## Bold on the same entry elsewhere

None in two places. Checked against the other units' `new.md` files and
`scratch_survey/bold_spans_all.tsv` (base spec):

- D-001: no other bold anywhere.
- D-082: §10.4 5492 (localized trigger), 5622 and 5649 (Rationale items), and
  §10.6 6192 (boundary zero, D-082 with D-292) bold other rulings. 5492 applies
  the edge rule to localization against tₙ's quiescence; it reads as a
  consequence of B-038's ruling rather than the ruling itself. R17: 5492 goes
  plain at landing.
- D-220: §5.3 876 and 893 bold its Position sentence and the dependence-class
  naming, not the time/state Rationale.
- D-179: cited plain at B-013 and B-033; no bold here. §10.4
  5415 keeps D-179's bold.
- Units C and E bold D-231 rulings (`m` continuous-only; immutability plus frozen
  references); B-054 cites D-231 plain for the PRNG values.

## Inbound citations affected

- Spec 6121 (§10.6) and log 772 (D-020 Rejected) cite §2.2 for `f_step!`'s
  step-size dependence; B-056 now states it.
- D-180 Spec (log 6571, §2.1 only) becomes true.
- D-141 Spec (log 4740) lacks §2.2, which now cites D-141; track 2.
- D-001 Spec (log 363) lists §2.2 only; §2 lead and §2.1 now cite it; track 2.
- D-082 Spec (log 2516) and D-080 Spec (log 2463) lack §2.1, which now cites
  both; track 2.
- Glossary 12914 (*hybrid causal system*) names the five parts by the old item
  names; all five survive verbatim.
- Spec 6110, 5435, 13178, 13237, 13270, 13298 and the companions citing §2.1
  for the predicate, edges, the negated-guard pair and time/state events keep
  their target (M3 is internal).
- Spec 1979, 6379, `extensions.md` 55: "deterministic replay" survives.
- `extensions.md` 114 ("DAEs / implicit constraints. Excluded in [§2.2]")
  still holds.

## Open questions

- Settled by R16: the turbulence gloss is gone and D-002 stays beside D-001's
  first bold.
- The bold §2.2 lead sentence ("The formalism deliberately excludes three
  constructs") is a new context sentence carrying D-001's fourth ruling, per
  R6's "§2.2's three exclusions"; the alternative was a bold headline clause
  on the first bullet, which would mark only the DAE exclusion.
