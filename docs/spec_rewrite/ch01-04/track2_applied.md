# Track 2 applied: chapters 1 to 4 (step 8)

The log of track 2's edits: rulings batch items B4, B5, B6, B8 and B12, plus
two Spec fields. Each entry gives the file, the old text, the new text and
the source line it rests on. Log source lines are `decisions.md` at
`675c5f8`, the commit before this track. Spec lines are `spec.md` at that
commit; no spec edit adds or removes a line. Citations were written bare and
`linkify.jl` linked them. The new text below is the linked text, as committed.

Commits: `a23ad77` holds T1 to T4. The commit that adds this file holds T5
to T25.

## Departures from the batch

Three bullets were changed from the batch's proposals, because each claimed
more than its source records.

- D-362, fourth bullet. The batch had "until the owner's next tick decode".
  D-020's Rejected item (log 780–781) says "invisible until the next tick
  decode", with no owner. Dropped "owner's".
- D-362, sixth bullet. The batch had "A periodic reset is not an event. A
  time-guard event would hand-roll …". D-056's Rejected item (log 1714–1715)
  rejects "*Periodic reset via time-guard events*" only. In today's
  vocabulary ticks are time events (D-220, D-361), and a periodic reset on a
  tick is exactly D-056's idiom, so "not an event" said more than the source
  and clashed with D-361. Now "A periodic reset is not a time-guard event.
  Such an event would hand-roll …".
- D-363, seventh bullet. The batch had "Pre-sampling is an idiom built on the
  handle pattern, not a mechanism". D-008 (log 484–489) records the handle
  pattern in its Position and rejects "*Pre-sampling as mechanism:*
  dependency inversion at struts". Nothing in it says pre-sampling builds on
  the handle pattern. Dropped "built on the handle pattern".

## Found after commit a23ad77, not applied

D-292's Position, bullet 5 (log 12452–12453), already states "Event/tick
fixed-point iteration is structurally unnecessary, because a tick's `s⁺` is
invisible until the next tick decode". The batch's premise for B5 ("never in
a Position") fails for that row. D-362's fourth bullet duplicates it. A
search of the log for the other rows' rulings found every other statement in
a Rationale, a Rejected list or an annotation. Left for the orchestrator.

## The log

### T1. B4: D-361

File: `docs/design/decisions.md`, inserted after D-343, before the
link-definition block (now 14155–14175).
Source: D-220 Rationale, log 8252–8257; D-082 Rationale, log 2523–2524.

Old: none.

New:

~~~~
### D-361 — Time and state events, and the opposite crossing direction

**Status.** ratified

**Position.** Two event rulings that §2.1 states are fixed here.

- The discrete tier's ticks, declared by `sample_times`, are time events,
  scheduled because their instants are known in advance. Everything
  declared through `StateEvent(guard, handler)` is a state event, whose
  instant is unknown and must be detected. The criterion is detection
  against scheduling, not which bundle fields a guard reads.
- The opposite crossing direction is a second event with the negated
  guard.

**Spec.** §2.1

**Rationale.** Each bullet restates what an existing entry recorded
outside its Position. The time and state events were recorded in D-220's
Rationale, and the opposite direction in D-082's.

**Rejected.** None beyond the source entries' lists.
~~~~

### T2. B5: D-362

File: `docs/design/decisions.md`, after D-361 (now 14177–14213).
Sources, bullet by bullet: D-003 Rejected, log 399–400; D-231 annotation,
log 8728–8729, and D-249 bullet 1, log 9497–9500; D-056 Rejected, log
1705–1710; D-020 Rejected, log 780–781; D-056 Rejected, log 1711–1713;
D-056 Rejected, log 1714–1715.

Old: none.

New:

~~~~
### D-362 — Reset maps, the continuous-only mode store and the rejected all-in-one component

**Status.** ratified

**Position.** Six taxonomy rulings that §3.1, §3.2 and §3.4 state are
fixed here.

- Internal modes enable reset maps. Without modes, latch logic becomes
  wiring ceremony.
- `m` is continuous-only: a discrete component has no mode store, and
  `m_init` on a discrete leaf is `DeclarationOnWrongTier`.
- An all-in-one component, one leaf carrying both tiers' facets, is
  rejected. Its halves would still communicate through cells, with one
  home per datum, a sole-reader `s` and no cross-tier state views, so it
  gains no expressiveness. It costs stage doubling with tier-tagged names,
  per-port tier vocabulary and facet-conditional obligations, and it hides
  the sampling interface.
- Event/tick fixed-point iteration is structurally unnecessary, because
  `s⁺` stays invisible until the next tick decode.
- No `s` view in the flow and no discrete-tier write into `x`: either
  would un-sample the sampled-data semantics, break the held-`s`
  linearization's exactness and hide the coupling from the table, the
  trace and the feedthrough graph.
- A periodic reset is not a time-guard event. Such an event would
  hand-roll the tick scheduler and forfeit the harmonic grid and the
  discrete-bundle `Δt`.

**Spec.** §3.1, §3.2, §3.4

**Rationale.** Each bullet restates what an existing entry recorded
outside its Position. The reset maps were recorded in D-003's Rejected
list. The mode store was recorded in D-231's annotation and follows from
D-249's first bullet. The all-in-one component, the forbidden write into
`x` and the periodic reset were recorded in D-056's Rejected list, and the
needless event/tick iteration in D-020's.

**Rejected.** None beyond the source entries' lists.
~~~~

### T3. B6: D-363

File: `docs/design/decisions.md`, after D-362 (now 14215–14251).
Sources, bullet by bullet: D-004 Rejected, log 416–418; D-034 Rejected, log
1130–1131; D-036 Rejected, log 1183–1186; D-036 Rejected, log 1187–1188;
D-045 Rejected, log 1440–1444; D-139 Rationale, log 4591–4593; D-008
Rejected, log 488–489.

Old: none.

New:

~~~~
### D-363 — Cell freshness, closed port alternatives, write-side atomicity and bulk-data handles

**Status.** ratified

**Position.** Seven port rulings that §4.1 to §4.4 state are fixed here.

- Each cell's freshness is tied to its producer's position in the
  execution order. A monolithic per-component `y` struct is rejected,
  since it could be half-fresh mid-sweep with no way for a reader to tell.
- A presentational `unlisted` flag, hidden but connectable, is rejected:
  it pretends privacy without enforcing it.
- Bare-struct returns with field-splatting are rejected as ambiguous,
  type-lossy and reflection-hungry.
- A field-projection connector is a guarded addition, unbuilt.
- A bundled command face, such as the pilot inputs as one struct port, is
  rejected: it kills per-field claiming, liveness and the trace tag. The
  port is the periphery's atomic unit on the write side too.
- A bulk-data component owes only that the query math be reachable as a
  plain function. Building its handle outside a build may then cost a
  resource load, acceptable because condition authoring is design-time
  code.
- Pre-sampling is an idiom, not a mechanism, since as a mechanism it
  inverts the dependency at the struts. Resource injection is rejected as
  a second, invisible composition mechanism.

**Spec.** §4.1, §4.2, §4.3, §4.4

**Rationale.** Each bullet restates what an existing entry recorded
outside its Position. The freshness was recorded in D-004's Rejected list,
the `unlisted` flag in D-034's, the bare-struct returns and the
field-projection connector in D-036's, the bundled command face in
D-045's, and pre-sampling and resource injection in D-008's. The
bulk-data obligation was recorded in D-139's Rationale.

**Rejected.** None beyond the source entries' lists.
~~~~

### T4. B8: D-141's annotation

File: `docs/design/decisions.md`, after D-141's Rationale paragraph (ending
log 4775), before **Rejected.** (now 4780–4783).
Source: D-141 Position, log 4733 ("are unchanged"); Rationale 4751 and
Rejected item 4797 (§3.1's immutable views); spec §3.1 lines 377–378, §2.2
lines 330–333, §7.1 lines 1902 and 1907.

Old: none.

New:

~~~~
Annotation (2026-10-13): [§3.1][s3-1] now states the commanded-reset rule above and
[§2.2][s2-2] the gear's touchdown edge, so "unchanged" describes their state when this
entry was ratified. The immutable stage views cited to [§3.1][s3-1] here and in the
Rejected list are [§7.1][s7-1]'s.
~~~~

### T5. B12: §2.1, the opposite direction, to D-361

File: `docs/design/spec.md`, line 269. Source: D-361 bullet 2.

Old: `([D-082][d-082]). Stall entry and exit are one such pair.`

New: `([D-082][d-082], [D-361][d-361]). Stall entry and exit are one such pair.`

### T6. B12: §2.1, the time-events bold, to D-361

File: `docs/design/spec.md`, line 299. Source: D-361 bullet 1. The bold is
unchanged.

Old: `[time events](#g-time-event)** ([D-220][d-220]). A tier`

New: `[time events](#g-time-event)** ([D-220][d-220], [D-361][d-361]). A tier`

### T7. B12: §3.1, the mode-variables bullet, to D-308

File: `docs/design/spec.md`, line 353. Source: D-308 Position bullet 1, log
12970.

Old: `  handlers.`

New: `  handlers ([D-308][d-308]).`

### T8. B12: §3.1, the internal-modes bullet, to D-362

File: `docs/design/spec.md`, line 369. Source: D-362 bullet 1.

Old: `  ([D-003][d-003]).`

New: `  ([D-003][d-003], [D-362][d-362]).`

### T9. B12: §3.2, the `m` bold, to D-362

File: `docs/design/spec.md`, line 402. Source: D-362 bullet 2. The bold is
unchanged.

Old: ``**`m` is continuous-only** ([D-231][d-231], [D-249][d-249]). A discrete``

New: ``**`m` is continuous-only** ([D-231][d-231], [D-249][d-249], [D-362][d-362]). A discrete``

### T10. B12: §3.4, the sibling sentence, to D-362

File: `docs/design/spec.md`, line 443. Source: D-362 bullet 3.

Old: `exactly as two siblings do ([D-056][d-056]).`

New: `exactly as two siblings do ([D-056][d-056], [D-362][d-362]).`

### T11. B12: §3.4, the deferred-decode sentence, to D-362

File: `docs/design/spec.md`, line 447. Source: D-362 bullet 4 (see "Found
after commit a23ad77": D-292 bullet 5 states the same).

Old: `impossible ([D-020][d-020]).`

New: `impossible ([D-020][d-020], [D-362][d-362]).`

### T12. B12: §3.4, the trench-coat sentence, to D-362

File: `docs/design/spec.md`, line 453. Source: D-362 bullet 3.

Old: `primitives in a trench coat ([D-056][d-056]).`

New: `primitives in a trench coat ([D-056][d-056], [D-362][d-362]).`

### T13. B12: §3.4, the periodic-reset sentence, to D-362

File: `docs/design/spec.md`, line 479. Source: D-362 bullet 6.

Old: `mechanism ([D-056][d-056]). And the reset`

New: `mechanism ([D-056][d-056], [D-362][d-362]). And the reset`

### T14. B12: §3.4, the forbidden-write sentence, to D-362

File: `docs/design/spec.md`, line 480. Source: D-362 bullet 5.

Old: `exactly the operation this design forbids ([D-056][d-056]).`

New: `exactly the operation this design forbids ([D-056][d-056], [D-362][d-362]).`

### T15. B12: §4.1, the freshness bullet, to D-363

File: `docs/design/spec.md`, line 556. Source: D-363 bullet 1.

Old: `  functions run ([D-004][d-004]).`

New: `  functions run ([D-004][d-004], [D-363][d-363]).`

### T16. B12: §4.2, the `unlisted` sentence, to D-363

File: `docs/design/spec.md`, line 576. Source: D-363 bullet 2.

Old: `is closed ([D-016][d-016], [D-034][d-034]).`

New: `is closed ([D-016][d-016], [D-034][d-034], [D-363][d-363]).`

### T17. B12: §4.3, the periphery-atom paragraph, to D-363

File: `docs/design/spec.md`, line 599. Source: D-363 bullet 5. Uncited
before; stays plain (R6).

Old: `The port is the atomic unit of the entire periphery. It is each of the`

New: `The port is the atomic unit of the entire periphery ([D-363][d-363]). It is each of the`

### T18. B12: §4.3, "Bare-struct returns are rejected", to D-363

File: `docs/design/spec.md`, line 639. Source: D-363 bullet 3.

Old: `are rejected ([D-036][d-036]).`

New: `are rejected ([D-036][d-036], [D-363][d-363]).`

### T19. B12: §4.3, the field-projection sentence, to D-363

File: `docs/design/spec.md`, line 669. Source: D-363 bullet 4.

Old: `[guarded addition](#g-guarded-addition) ([D-036][d-036]), a capability the`

New: `[guarded addition](#g-guarded-addition) ([D-036][d-036], [D-363][d-363]), a capability the`

### T20. B12: §4.3, the write-side bold, to D-363

File: `docs/design/spec.md`, line 699. Source: D-363 bullet 5. The bold is
unchanged.

Old: `at different cadences, must not share a port** ([D-045][d-045]). In short,`

New: `at different cadences, must not share a port** ([D-045][d-045], [D-363][d-363]). In short,`

### T21. B12: §4.4, the bulk-data sentence, to D-363

File: `docs/design/spec.md`, line 764. Source: D-363 bullet 6.

Old: `reachable as a plain function ([D-139][d-139]). They own their resource`

New: `reachable as a plain function ([D-139][d-139], [D-363][d-363]). They own their resource`

### T22. B12: §4.4, the pre-sampling sentence, to D-363

File: `docs/design/spec.md`, line 782. Source: D-363 bullet 7.

Old: `mechanism ([D-008][d-008]). In it, a component consumes the field and a pose`

New: `mechanism ([D-008][d-008], [D-363][d-363]). In it, a component consumes the field and a pose`

### T23. B12: §4.4, the resource-injection sentence, to D-363

File: `docs/design/spec.md`, line 786. Source: D-363 bullet 7.

Old: `([D-008][d-008]).`

New: `([D-008][d-008], [D-363][d-363]).`

### T24. D-308's Spec field gains §3.1

File: `docs/design/decisions.md`, log 12973 (now 12981). Source: T7.

Old: `**Spec.** [§7.1][s7-1], [§7.3][s7-3]`

New: `**Spec.** [§3.1][s3-1], [§7.1][s7-1], [§7.3][s7-3]`

### T25. D-101's Spec field gains §2.2

File: `docs/design/decisions.md`, log 3073 (now 3076). Source: spec §2.2,
lines 318–320, which cite D-101 at the replay sentence (R23).

Old: `**Spec.** [§12.7][s12-7], [§14.5][s14-5]`

New: `**Spec.** [§2.2][s2-2], [§12.7][s12-7], [§14.5][s14-5]`

`linkify.jl` also added the definitions `[d-361]`, `[d-362]` and `[d-363]`
to the spec's link-definition block, and the three Index rows and link
definitions to the log.

T5 to T23 leave six lines over 80 columns that were under it (402, 576, 599,
699, 764, 782). The landed chapters already hold many such lines, so none
was rewrapped.
