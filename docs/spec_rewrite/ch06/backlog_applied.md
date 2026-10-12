# Chapter 6 track 2: edits applied — 2026-10-12

Applies `rulings_batch.md` section "Track 2". `log` is
`docs/design/decisions.md`, `spec` is `docs/design/spec.md`, and `walk` is
`docs/design/companions/inbound_periphery_walkthrough.md`. Every line number
is the line **after** all edits and the `linkify.jl` run. New citations were
written bare, and `linkify.jl` linked them afterwards. Every annotation is
dated 2026-10-12 and sits after its entry's Rationale, before **Rejected.**

## Step 1. Annotations to stale Positions

D-065 is not annotated. It waits on the owner's ruling on E1
(`escalations.md`).

### D-037 (log 1197)

- Old: Position "totals exported across generic boundaries"; Rejected
  "*FlightCore tree walks:*". No annotation.
- New: "Annotation (2026-10-12): since D-207 every connection routes one
  level, so every assembly that owns contributors exports its total, at every
  boundary and not only at a generic one (§6.2). The tree walks of the second
  rejection are FlightPhysics' generated functions `get_wr_b`, `get_mp_b` and
  `get_hr_b` (§6.2), not FlightCore's. The junctions, the idiom, the
  author-visible fold order and the guarded sugar stand."
- Source: D-207 Position; §6.2 "A child is opaque to wiring at every boundary,
  so every assembly that owns contributors must export its aggregate" and
  "FlightPhysics' generated functions `get_wr_b`, `get_mp_b` and `get_hr_b`".
  Checked in Flight.jl: `lib/FlightPhysics/src/dynamics.jl` defines the
  `@generated` walks.

### D-061 (log 1843)

- Old: Position "enforcing §6.1's generic-boundary rule at the primitive
  (past-generic segment = diagnostic even where the instance resolves; …)".
  No annotation.
- New: "Annotation (2026-10-12): §6.1 has stated no generic-boundary rule since
  D-207, which made the generic-seam stop the universal rule. The wiring
  client's duty is the one-level rule, and an endpoint reaching past the
  immediate child is `PathResolution` (§6.1). The generic-holding rule, with
  its past-generic diagnostic, governs the deep paths the read side still
  writes, under D-130's client scoping (§13.3). The declared-type walk, the
  face lists and the terminal split stand."
- Source: D-207 Position bullet 1 ("the generic-seam stop becomes the
  universal rule"); §6.1 "An endpoint reaching past the immediate child is a
  `PathResolution` error"; §13.3 "The walk enforces two duties", its client
  table, and its accessor and `resolve_terminal` bullets.

### D-062 (log 1873)

- Old: Position bullet 3 "A standard component library (summing junctions,
  Bool gates) ships as ordinary components, demand-driven, arity by type
  parameter (`Or{N}` — computed contracts), stateless-continuous hence
  tier-transparent." No annotation.
- New: "Annotation (2026-10-12): the summing junction and the Bool gates are
  one leaf, `Junction{In, Out, N, F}`, since D-311, and `SumJunction{V, N}`,
  `Or{N}` and `And{N}` are its aliases. A block joins the library by
  judgement against three guidelines, not on demand (D-313). Ordinary
  components, arity by type parameter and tier transparency stand (§13.7)."
- Source: D-311 Position and bullet 2; D-313 Position; §13.7 "Arity and port
  types come from type parameters" and "Tier-transparency falls out of
  settled semantics".

### D-073 (log 2217)

- Old: Position "§6.2's `SumJunction` dispatches on its unparametrized type
  constructor." No annotation.
- New: "Annotation (2026-10-12): D-311 makes the junction's type parameter the
  nominal type, as in `SumJunction{Wrench{Float64}, 3}`, never an
  unparametrized constructor, and §6.2 writes it so."
- Source: D-311 bullet 3; §6.2 `wr_sum::SumJunction{Wrench{Float64}, 3}`.

### D-143 (log 4913)

- Old: Position "`output_types(::Constant{V}) = (out = V,)`" and "a stateless
  `h_xu`"; Rationale "FlightCore's silent identity methods". No annotation.
- New: "Annotation (2026-10-12): `Constant{V}` declares `(out = Pinned{V},)`
  (D-312), and `output_types` is `y_types` (D-267). The stateless `h_xu` of
  the tier argument is `y_direct` (D-220, D-267, §13.7). The identity methods
  the Rationale calls FlightCore's are FlightPhysics', defined at the
  `aircraftbase.jl` lines it cites. The block, its two clarifications and its
  tier stand."
- Source: D-312 bullet 1; D-220 bullet 2 (`h_xu` → `output_direct`); D-267
  bullet 1 (`output_types` → `y_types`, `output_direct` → `y_direct`); §13.7
  "A stateless continuous `y_direct` recomputes every sweep". Checked in
  Flight.jl: `lib/FlightPhysics/src/aircraftbase.jl` 31–33 define `get_hr_b`,
  `get_wr_b` and `get_mp_b` on `Model{NoVehicleSystems}`, inside the 27–35
  range D-143's Rationale cites.

## Step 2. New entries

D-321 to D-323 sit after D-320 and before the link-definition block, at log
13928 to about 14010. Vocabulary is today's: root input, structure step,
`Pinned`, local wire not used. The sources say "root slot", "Stratum A" or
"structure", "custom type" and "forgotten `T`".

### D-321 — The parallel-routes signal, the handle's pin chain and the input pin's failure at the wire (log 13928)

Spec: §6.1. Rejected: none beyond the source entries' lists.

- Bullet 1, parallel routes ← D-207 Rationale: "parallel routes proliferating
  through several boundaries are the signal to gather them into a custom
  type". The chapter's "a component of their own" replaces "a custom type".
- Bullet 2, the pin chain ← D-264 Rationale: "a consumer that re-emits a
  frozen handle under an unpinned output hits the store's identity rule, so a
  handle's pin is a property of its chain, and every component that forwards
  it pins that output too."
- Bullet 3, the input side of the failure asymmetry ← D-236 Rationale: "the
  timing is the promise D-167 makes: the input-side forgotten `T` fails at the
  first nominal build, at the wire"; D-263 Rationale: "fails where the
  forgotten `T` did and never silently: an input pin is a wire check at the
  first nominal build only when written". The counterparty reason ("inputs
  have a build-time counterparty, outputs don't") is recorded only in
  superseded D-167's Rationale, which D-236's Rationale invokes as D-167's
  promise. D-167's annotation keeps its walk clause and makes `Pinned{P}` the
  spelling of "demands frozen", which maps the forgotten `T` to today's pin at
  a promoting entry. Flagged for the verifier: this clause leans on a
  superseded Rationale through a ratified one. The bullet keeps F13's
  condition implicit, as the chapter does, and does not sharpen it.

### D-322 — No auto-bubbling of unconnected inputs, and the whole-tree checks decided at the root (log 13958)

Spec: §6.1. Rejected: none beyond the source entries' lists.

- Bullet 1, no auto-bubbling ← D-043 Rejected: "*Auto-bubbling:* forgotten wire
  silently promoted to a live root slot". "Root slot" is "root input" since
  D-206.
- Bullet 2, the root-only checks ← D-048 Rejected: "*Single-pass tree walk with
  per-level validation:* obligation/two-producers undecidable below the root";
  D-048 Position bullet A, "global wiring + obligations" in the structure
  stratum, the structure step since D-259.

### D-323 — No framework aggregation mechanism, what explicit junctions buy, and no bundled contributions (log 13982)

Spec: §6.2. Rejected: none beyond the source entries' lists.

- Bullet 1, no mechanism ← D-037 Rejected bullet 1: "canonical-fold,
  multi-connection legality and identity-element machinery all retired";
  D-143 Rejected bullet 1: "reintroducing identity machinery for the
  degenerate case … reopens the canonical-fold and identity-element rules
  retired wholesale".
- Bullet 2, the explicit form's gains ← D-037 Rejected bullet 1: "the
  aggregate wasn't even observable"; D-311 Rationale: "a custom fold, a
  weighted blend or a mass-properties composition, is §6.2's arbitrary
  stage-2 aggregation written at the site"; D-037 Rejected bullet 2: "silent
  omission — the zero-edit convenience *is* the hazard"; D-143 Rationale: "the
  zero total becomes a declared wire and an observable port". The bullet does
  not claim every mistake is loud (F2): it says every contribution a total
  includes is a declared wire.
- Bullet 3, do not bundle ← D-037 Rejected bullet 3: "ragged contributors →
  identity-element noise"; its annotation bullet: "a bundle forces
  zero-filled identity noise through every port, the 'silently sum nothing'
  hazard in a new coat."

## Step 3. Citations in chapter 6

Each adds the new entry beside the source the chapter cites. No other word
changed. One paragraph was rewrapped.

| spec line | old | new |
|---|---|---|
| 1295 | `([D-207][d-207])` | `([D-207][d-207], [D-321][d-321])` |
| 1342 | `([D-264][d-264])` | `([D-264][d-264], [D-321][d-321])` |
| 1353 | `endpoints named ([D-263][d-263])` | `endpoints named ([D-263][d-263], [D-321][d-321])` |
| 1369 | `inputs ([D-043][d-043])` | `inputs ([D-043][d-043], [D-322][d-322])` |
| 1371 | `per-declaration one ([D-048][d-048])` | `… ([D-048][d-048], [D-322][d-322])` |
| 1373 | `decidable below it ([D-048][d-048])` | `… ([D-048][d-048], [D-322][d-322])` |
| 1398 | `identity-element opt-outs. Every` | `identity-element opt-outs ([D-323][d-323]). Every` |
| 1511 | `in a new coat ([D-037][d-037])` | `… ([D-037][d-037], [D-323][d-323])` |
| 1529 | `deliberately absent ([D-037][d-037])` | `… ([D-037][d-037], [D-323][d-323])` |
| 1552 | `warning or error ([D-037][d-037])` | `… ([D-037][d-037], [D-323][d-323])` |
| 1555 | `are closed ([D-037][d-037])` | `… ([D-037][d-037], [D-323][d-323])` |

- Rewrap: the paragraph "There is no auto-bubbling …" (spec 1369–1379) passed
  80 rendered columns at three lines. It was rewrapped greedily to 80
  rendered columns, link markup collapsed, and grew from 10 to 11 lines.
- Spec 1398: the paragraph "There is no framework aggregation mechanism …"
  cited no entry before. D-323 is its first citation, as chapter 7 cited
  D-304 where no source stood (spec "no arithmetic is ever done on them").
- The bullets of "What the explicit form buys" take no D-323 citation. The
  cost paragraph (1552) cites the gains beside D-037.

## Step 4. Outside the spec

- walk 159: `# no checks — see §6` → `# no checks — see section 6`.
- Not done here: `src/build.jl` 511, `test/test_build.jl` 764,
  `test/test_linearize.jl` 334 and `test/test_blocks.jl` 449, which the batch
  sends to `pending.md`.

## Step 5. The battery

All pass: `linkify.jl`; `check_refs.jl` ("every citation and every anchor
resolves"); `check_rows.jl` ("newly cited by the spec (fine): [321, 322,
323]"); `check_glossary.jl --strict` (OK, three standing advisories);
`check_bold.jl` (chapter 6: 13 bold spans, 142 bold words, OK); `linkify.jl`
again, a no-op by checksum over the spec, the log and the companions.

## For the owner: rulings with no entry

Each states a chapter 6 ruling that no ratified entry records in a Position,
a Rationale, a Rejected list or an annotation. A new entry would be a design
decision, so none was written (lesson 17).

- **The walk violation's payload and remedies** (§6.1, "A violation of the
  walk clause is `WalkingFaceAtFrozenEntry`, naming both endpoints …"). Only
  superseded D-167's Rationale records them. Appendix C states them
  normatively, so the spec is not short; the log is.
- **Unconnected inputs are a build error, with no silent defaults** (§6.1).
  No Position states it. D-048's Position names "obligations" only, and
  D-051's and D-143's Rejected lists point back at "§6.1's ban" (lesson 16:
  §6.1 must not cite them for it).
- **Local fan-out is free** (§6.1, "Fan-out is free. One producer may feed
  many consumers."). D-170 states only the input half. F17 applies: the
  sentence is about producers and must not be generalized.
- **The common body frame** (§6.2, "Contributors publish in the common body
  frame, applying their own mounting transforms at source"). It describes
  Flight.jl's convention, not a framework rule.

## Notes, not applied

- D-065 waits on E1.
- D-061's Spec field lists §6.1 only, while `resolve` lives in §13.3 (survey
  part E). The Track 2 list did not name the field, so it is unchanged.
- D-143's Rationale cites "§13.7's strictly from demonstrated need charter",
  which D-313 replaced. The Track 2 list names only D-143's Position items, so
  the annotation leaves it out. Chapter 13's carried item covers the spec
  side.
- Survey part E item 11, the cost of adding a contributor from another
  subtree (D-037 Rejected bullet 2, D-207 Rationale), is not in the Track 2
  list and got no entry.

## Fixes after verification

Applies `backlog_verify.md` P1 to P4 as the coordinator ruled them.

- **P1, log D-321 Rationale.** Deleted: "The forgotten `T` of D-236's
  Rationale is today's pin at a promoting entry, since D-167's annotation
  makes `Pinned{P}` the spelling of "demands frozen"." It contradicted D-263's
  "The forgotten-`T` classes vanish rather than move", and D-263 already
  carries the timing.
- **P2, log D-321 Rationale.** Old: "D-263 supersedes D-167, and D-167's
  annotation keeps its walk clause." New: "D-263's rejection of D-167 reaches
  only the mandated forms, and D-263's Rationale restates both halves of the
  asymmetry, an input pin failing at the first nominal build and an output
  built from frozen data refused at the first `Dual` activation." Checked
  against D-263's Rejected item "*Superseded position — the mandated
  two-argument forms on the continuous tier (D-166, D-167)*" and its
  Rationale: "an input pin is a wire check at the first nominal build only
  when written, and an output built from frozen data is refused at the first
  `Dual` activation".
- **P3, spec 1552.** Old: "error ([D-037][d-037], [D-323][d-323])." New:
  "error ([D-037][d-037])." D-323's Position leaves out the claim that every
  silence is inverted into a warning or error. Nothing else in the sentence
  changed. The table row for spec 1552 in step 3 no longer holds.
- **P4, log D-062 annotation (log 1873).** Old: "not on demand (D-313)". New:
  "not by demonstrated need (D-313)". The annotation was rewrapped to 80
  rendered columns.

Battery after the fixes: `linkify.jl`; `check_refs.jl` OK; `check_rows.jl`
OK (newly cited: 321, 322, 323); `check_glossary.jl --strict` OK;
`check_bold.jl` OK; `linkify.jl` again, a no-op by checksum.
