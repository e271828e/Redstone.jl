# Track 2 applied: chapters 1 to 4 (step 8)

The log of track 2's edits: rulings batch items B4, B5, B6, B8 and B12, plus
two Spec fields. Each entry gives the file, the old text, the new text and
the source line it rests on. Log source lines are `decisions.md` at
`675c5f8`, the commit before this track, for T1 to T25, and at `4dd81f2`
for T26 to T36, and at `49e2665` for T37 on. Spec lines are `spec.md` at
the same commits; only the rewraps, T31 to T42, add or remove a line. Citations were written bare and
`linkify.jl` linked them. The new text below is the linked text, as committed.

Commits: `a23ad77` holds T1 to T4, `4dd81f2` holds T5 to T25 and this file,
`49e2665` holds T26 to T36, and the commit after it holds T37 to T44.

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

## Found after commit a23ad77, applied as T26 to T30

D-292's Position, bullet 5 (log 12452–12453), already states "Event/tick
fixed-point iteration is structurally unnecessary, because a tick's `s⁺` is
invisible until the next tick decode". The batch's premise for B5 ("never in
a Position") fails for that row. D-362's fourth bullet duplicates it. A
search of the log for the other rows' rulings found every other statement in
a Rationale, a Rejected list or an annotation. The orchestrator ruled the
fix, applied as T26 to T30.

## Citations weak by design

Three citations carry only part of their sentence. The batch named the first
two; the track 2 verifier found the third (its P4).

- D-231 at §2.2's RNG sentence carries "RNG state lives in `s`", not the
  replay guarantee (C9).
- D-090 at §3.1 carries the handler's returns, not "own".
- D-308 at §3.1's mode-variables bullet (T7) carries the mode values only,
  its Position bullet 1: a continuous component's `Int`s, enums and `Bool`s
  belong in its modes. The same sentence's "change *only* through event
  handlers" has no entry behind it. It is already the owner's item C5. No
  edit, by ruling.

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

T5 to T23 leave these lines over 80 raw columns: 402, 576, 599, 699, 764 and
782. T31 to T36 rewrap their paragraphs at the orchestrator's ruling. Measured
in rendered columns (`spec_style.md`), the lines over 80 were 269, 299, 447,
453, 479, 480 and 670, which T37 to T42 rewrap.

### T26. D-362's headline counts five rulings

File: `docs/design/decisions.md`, line 14181. Source: T27 drops one bullet.

Old: `**Position.** Six taxonomy rulings that [§3.1][s3-1], [§3.2][s3-2] and [§3.4][s3-4] state are`

New: `**Position.** Five taxonomy rulings that [§3.1][s3-1], [§3.2][s3-2] and [§3.4][s3-4] state are`

### T27. D-362's fourth bullet dropped

File: `docs/design/decisions.md`, lines 14194–14195. Source: D-292
Position bullet 5, line 12460–12461, states the ruling already.

Old:

~~~~
- Event/tick fixed-point iteration is structurally unnecessary, because
  `s⁺` stays invisible until the next tick decode.
~~~~

New: none.

### T28. D-362's Rationale drops the event/tick clause

File: `docs/design/decisions.md`, lines 14210–14211. Source: T27.

Old:

~~~~
`x` and the periodic reset were recorded in [D-056][d-056]'s Rejected list, and the
needless event/tick iteration in [D-020][d-020]'s.
~~~~

New:

~~~~
`x` and the periodic reset were recorded in [D-056][d-056]'s Rejected list.
~~~~

### T29. D-292's Spec field gains §3.4

File: `docs/design/decisions.md`, line 12463. Source: T30.

Old: `**Spec.** [§10.6][s10-6]`

New: `**Spec.** [§3.4][s3-4], [§10.6][s10-6]`

### T30. §3.4's deferred-decode sentence cites D-292, not D-362

File: `docs/design/spec.md`, line 447. Source: D-292 Position bullet 5.
Replaces T11's citation.

Old: `impossible ([D-020][d-020], [D-362][d-362]). It is also`

New: `impossible ([D-020][d-020], [D-292][d-292]). It is also`

### T31. Rewrap §3.2's `m` paragraph

File: `docs/design/spec.md`, lines 402–408, whitespace only.

Old:

~~~~
**`m` is continuous-only** ([D-231][d-231], [D-249][d-249], [D-362][d-362]). A discrete
component has no mode store. Its finite-state machine (FSM) enums, flags and
counters are ordinary `s` fields. `m` exists on the continuous side because
modes must change *between* flow evaluations, which is what handlers do. On the
discrete side `g` already runs at the only instants at which anything may
change. A second store would duplicate the discrete tier's own state semantics
under another name.
~~~~

New:

~~~~
**`m` is continuous-only** ([D-231][d-231], [D-249][d-249], [D-362][d-362]). A
discrete component has no mode store. Its finite-state machine (FSM) enums,
flags and counters are ordinary `s` fields. `m` exists on the continuous side
because modes must change *between* flow evaluations, which is what handlers do.
On the discrete side `g` already runs at the only instants at which anything may
change. A second store would duplicate the discrete tier's own state semantics
under another name.
~~~~

### T32. Rewrap §4.2's contract paragraph

File: `docs/design/spec.md`, lines 570–576 (now 570–577), whitespace only.

Old:

~~~~
Which ports exist at all is a declaration-layer decision. The output
[contract](#g-contract) (the ports a component declares in `y_types`) *is* the
public interface ([D-034][d-034]). There are no private intermediates. A value
a later function needs is a declared port like any other ([§5.2][s5-2], [D-194][d-194]). A
stage result outside the contract is a build error (`UndeclaredReturnField`,
[§8.3][s8-3]). A presentational *unlisted* flag, skipped in logs
and GUI but still connectable, is closed ([D-016][d-016], [D-034][d-034], [D-363][d-363]).
~~~~

New:

~~~~
Which ports exist at all is a declaration-layer decision. The output
[contract](#g-contract) (the ports a component declares in `y_types`) *is* the
public interface ([D-034][d-034]). There are no private intermediates. A value a
later function needs is a declared port like any other
([§5.2][s5-2], [D-194][d-194]). A stage result outside the contract is a build
error (`UndeclaredReturnField`, [§8.3][s8-3]). A presentational *unlisted* flag,
skipped in logs and GUI but still connectable, is closed
([D-016][d-016], [D-034][d-034], [D-363][d-363]).
~~~~

### T33. Rewrap §4.3's periphery-atom lead

File: `docs/design/spec.md`, lines 599–600 (now 600–601), whitespace only.

Old:

~~~~
The port is the atomic unit of the entire periphery ([D-363][d-363]). It is each of the
following.
~~~~

New:

~~~~
The port is the atomic unit of the entire periphery ([D-363][d-363]). It is each
of the following.
~~~~

### T34. Rewrap §4.3's write-side paragraph

File: `docs/design/spec.md`, lines 698–700 (now 699–701), whitespace only.

Old:

~~~~
Under the write-side rule, **data written by different external writers, or
at different cadences, must not share a port** ([D-045][d-045], [D-363][d-363]). In short,
bundle what is written together.
~~~~

New:

~~~~
Under the write-side rule, **data written by different external writers, or at
different cadences, must not share a port** ([D-045][d-045], [D-363][d-363]). In
short, bundle what is written together.
~~~~

### T35. Rewrap §4.4's bulk-data paragraph

File: `docs/design/spec.md`, lines 763–766 (now 764–767), whitespace only.

Old:

~~~~
For bulk-data components the obligation is only that the query math be
reachable as a plain function ([D-139][d-139], [D-363][d-363]). They own their resource
loading, so building a handle outside a build may cost a load. That cost is
acceptable, because condition authoring is design-time code.
~~~~

New:

~~~~
For bulk-data components the obligation is only that the query math be reachable
as a plain function ([D-139][d-139], [D-363][d-363]). They own their resource
loading, so building a handle outside a build may cost a load. That cost is
acceptable, because condition authoring is design-time code.
~~~~

### T36. Rewrap §4.4's pre-sampling paragraph

File: `docs/design/spec.md`, lines 781–786 (now 782–787), whitespace only.

Old:

~~~~
Pre-sampling is an idiom built on top, used where natural, not a separate
mechanism ([D-008][d-008], [D-363][d-363]). In it, a component consumes the field and a pose
and emits plain data, as an illustrative `Airflow` component emits
FlightPhysics' `AirData` for the whole vehicle. Resource injection
(declare-and-resolve service registries) is closed for the first cut
([D-008][d-008], [D-363][d-363]).
~~~~

New:

~~~~
Pre-sampling is an idiom built on top, used where natural, not a separate
mechanism ([D-008][d-008], [D-363][d-363]). In it, a component consumes the
field and a pose and emits plain data, as an illustrative `Airflow` component
emits FlightPhysics' `AirData` for the whole vehicle. Resource injection
(declare-and-resolve service registries) is closed for the first cut
([D-008][d-008], [D-363][d-363]).
~~~~

The rewrap script kept links, citation groups and code spans whole, filled
to 80 columns, refused to start a line with a list marker, and asserted that
each paragraph's text was unchanged up to whitespace.

### T37. Refill §2.1's opposite-direction paragraph at 80 rendered columns

File: `docs/design/spec.md`, lines 269–271 (now 269–271), whitespace only, from
the long line to the paragraph's end. Source: the verifier's P1 text; the line
was pushed past 80 rendered columns by T5.

Old:

~~~~
([D-082][d-082], [D-361][d-361]). Stall entry and exit are one such pair. [D-180][d-180] records a per-event
`direction` keyword as a [guarded addition](#g-guarded-addition) (a capability the design admits but does
not build).
~~~~

New:

~~~~
([D-082][d-082], [D-361][d-361]). Stall entry and exit are one such pair. [D-180][d-180] records a
per-event `direction` keyword as a [guarded addition](#g-guarded-addition) (a capability the design
admits but does not build).
~~~~

### T38. Refill §2.1's time-events paragraph at 80 rendered columns

File: `docs/design/spec.md`, lines 299–305 (now 299–306), whitespace only, from
the long line to the paragraph's end. Source: the verifier's P1 text; the line
was pushed past 80 rendered columns by T6.

Old:

~~~~
discrete [tier](#g-tier)'s [ticks](#g-tick) are [time events](#g-time-event)** ([D-220][d-220], [D-361][d-361]). A tier is one side of the hybrid
formalism, continuous or discrete. Ticks are declared by `sample_times`. Their
instants are known in advance and scheduled ([§10.5][s10-5]). Everything declared through
`StateEvent(guard, handler)` is a [state event](#g-state-event). Its instant is unknown and must be
detected, by boundary check or by localization. That is why the declaration is
named `state_events` ([§8.2][s8-2], [D-220][d-220]). The criterion is detection versus scheduling,
not which fields a guard reads. A guard over an input is still a state event.
~~~~

New:

~~~~
discrete [tier](#g-tier)'s [ticks](#g-tick) are [time events](#g-time-event)** ([D-220][d-220], [D-361][d-361]). A tier is one side of the
hybrid formalism, continuous or discrete. Ticks are declared by `sample_times`.
Their instants are known in advance and scheduled ([§10.5][s10-5]). Everything declared
through `StateEvent(guard, handler)` is a [state event](#g-state-event). Its instant is unknown and
must be detected, by boundary check or by localization. That is why the
declaration is named `state_events` ([§8.2][s8-2], [D-220][d-220]). The criterion is detection
versus scheduling, not which fields a guard reads. A guard over an input is
still a state event.
~~~~

### T39. Refill §3.4's deferred-decode paragraph at 80 rendered columns

File: `docs/design/spec.md`, lines 447–450 (now 448–451), whitespace only, from
the long line to the paragraph's end. Source: the verifier's P1 text; the line
was pushed past 80 rendered columns by T11 and T30.

Old:

~~~~
impossible ([D-020][d-020], [D-292][d-292]). It is also what terminates the iteration at each [boundary](#g-boundary) (a
published consistency point, [§10.6][s10-6]). Inside an all-in-one component, influence
across [tiers](#g-tier) (the continuous and discrete sides of the formalism) still routes
through [cells](#g-cell) of the published signal table ([D-056][d-056]).
~~~~

New:

~~~~
impossible ([D-020][d-020], [D-292][d-292]). It is also what terminates the iteration at each
[boundary](#g-boundary) (a published consistency point, [§10.6][s10-6]). Inside an all-in-one component,
influence across [tiers](#g-tier) (the continuous and discrete sides of the formalism)
still routes through [cells](#g-cell) of the published signal table ([D-056][d-056]).
~~~~

### T40. Refill §3.4's trench-coat paragraph at 80 rendered columns

File: `docs/design/spec.md`, lines 453–457 (now 454–458), whitespace only, from
the long line to the paragraph's end. Source: the verifier's P1 text; the line
was pushed past 80 rendered columns by T12.

Old:

~~~~
primitives in a trench coat ([D-056][d-056], [D-362][d-362]). It buys no expressiveness. It incurs costs
of its own, which [D-056][d-056] enumerates. One of those costs is not bookkeeping. The
sampling interface is the zero-order hold (ZOH) plus the one-sample `z⁻¹` delay.
It is the most bug-prone boundary in a flight-control stack. A monolith swallows
it. The split keeps it a visible wire.
~~~~

New:

~~~~
primitives in a trench coat ([D-056][d-056], [D-362][d-362]). It buys no expressiveness. It incurs
costs of its own, which [D-056][d-056] enumerates. One of those costs is not bookkeeping.
The sampling interface is the zero-order hold (ZOH) plus the one-sample `z⁻¹`
delay. It is the most bug-prone boundary in a flight-control stack. A monolith
swallows it. The split keeps it a visible wire.
~~~~

### T41. Refill §3.4's reset paragraph at 80 rendered columns

File: `docs/design/spec.md`, lines 479–484 (now 480–485), whitespace only, from
the long line to the paragraph's end. Source: the verifier's P1 text; the line
was pushed past 80 rendered columns by T13 and T14.

Old:

~~~~
mechanism ([D-056][d-056], [D-362][d-362]). And the reset is a discrete-tier write into continuous state,
exactly the operation this design forbids ([D-056][d-056], [D-362][d-362]). `s_update` writes only its own
`s`. Guard-driven handlers are the sole resetters of continuous state ([D-141][d-141]).
Integrate-and-dump falls squarely into the crack between the two leaf classes.
It is tightly coupled continuous and periodic dynamics in one physical
instrument.
~~~~

New:

~~~~
mechanism ([D-056][d-056], [D-362][d-362]). And the reset is a discrete-tier write into continuous
state, exactly the operation this design forbids ([D-056][d-056], [D-362][d-362]). `s_update` writes
only its own `s`. Guard-driven handlers are the sole resetters of continuous state
([D-141][d-141]). Integrate-and-dump falls squarely into the crack between the two leaf
classes. It is tightly coupled continuous and periodic dynamics in one physical
instrument.
~~~~

### T42. Refill §4.3's field-projection paragraph at 80 rendered columns

File: `docs/design/spec.md`, lines 670–671 (now 671–672), whitespace only, from
the long line to the paragraph's end. Source: the verifier's P1 text; the line
was pushed past 80 rendered columns by T19.

Old:

~~~~
A field-projection connector is a [guarded addition](#g-guarded-addition) ([D-036][d-036], [D-363][d-363]), a capability the
design admits but does not build. Its shape is obvious.
~~~~

New:

~~~~
A field-projection connector is a [guarded addition](#g-guarded-addition) ([D-036][d-036], [D-363][d-363]), a capability
the design admits but does not build. Its shape is obvious.
~~~~

### T43. D-141's annotation no longer counts §2.2 as "unchanged"

File: `docs/design/decisions.md`, lines 4780–4782. Source: D-141 Position,
line 4736, names only §3.1, §2.1 and §13.7 as unchanged. The verifier's P2
text. The last sentence, on §7.1, stays.

Old:

~~~~
Annotation (2026-10-13): [§3.1][s3-1] now states the commanded-reset rule above and
[§2.2][s2-2] the gear's touchdown edge, so "unchanged" describes their state when this
entry was ratified.
~~~~

New:

~~~~
Annotation (2026-10-13): [§3.1][s3-1] now states the commanded-reset rule above, so
"unchanged" describes its state when this entry was ratified, and [§2.2][s2-2] now
states the gear's touchdown edge.
~~~~

### T44. D-362's third bullet carries the trench coat

File: `docs/design/decisions.md`, lines 14188–14193. Source: D-056 Rejected,
line 1708, "*All-in-one component kind:* an assembly in a trench coat". The
verifier's P3 text, so D-362 carries spec §3.4's trench-coat sentence; the
spec stays.

Old:

~~~~
- An all-in-one component, one leaf carrying both tiers' facets, is
  rejected. Its halves would still communicate through cells, with one
  home per datum, a sole-reader `s` and no cross-tier state views, so it
  gains no expressiveness. It costs stage doubling with tier-tagged names,
  per-port tier vocabulary and facet-conditional obligations, and it hides
  the sampling interface.
~~~~

New:

~~~~
- An all-in-one component, one leaf carrying both tiers' facets, is
  rejected as an assembly in a trench coat. Its halves would still
  communicate through cells, with one home per datum, a sole-reader `s` and
  no cross-tier state views, so it gains no expressiveness. It costs stage
  doubling with tier-tagged names, per-port tier vocabulary and
  facet-conditional obligations, and it hides the sampling interface.
~~~~
