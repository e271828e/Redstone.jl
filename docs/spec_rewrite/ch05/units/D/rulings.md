# Unit D rulings: step boundaries and supervisory inputs (old 924–1015)

Old 796 normalized words (`show-old`), new 910 (`show-new`). Log lines are
`decisions.md` at `b08afca`.

## Corrections proposed

- **Applied, R5 F3.** Old 1003–1004: "the bumpless-engage answer
  ([§11.7][s11-7]) presupposes exactly this spelling". §11.7 holds no such
  answer (survey F3). New: "the bumpless-engage answer of the C172X demo's
  *Mode engage* frame presupposes exactly this spelling. The C172X demo is the
  interactive Flight.jl demo that section 3 of
  `companions/flight_case_studies.md` examines." Evidence:
  `flight_case_studies.md` at `b08afca`, 349–350 ("*Mode engage.* …
  **Bumpless-engage semantics live in the FCS already.**"), under section 3,
  "The interactive C172X demo: the periphery under load" (193).
- **Applied, R16.** Old 934–935 and 937: "positions in the execution order"
  and "that position of the execution order" now say "boundary sequence". The
  glossary's *execution order* (12934) is the order the stage functions run;
  integration and a handler's `x`-reset are steps of the boundary sequence.
  No prose use of "execution order" remains in the unit, so it carries no
  `#g-execution-order` link.

## Citations added or replaced

- **D-016** at "`x_projection` runs between a state write and its decode"
  (bold). Position log 620–621: "`project` is the sole raw-state function
  (schedule-structural)". The annotation (log 627–629) keeps this clause:
  "`project` as the sole raw-state function stand". The cited clause is not
  the superseded one. The annotation drops "(schedule-structural)", which
  carries the spec's reading that `x_projection` is unique in its position,
  not in receiving raw state (survey part E, track 2).
- **D-020** at the iteration to quiescence. Position log 749–753: "Boundary
  event phase iterates to quiescence — rounds of full re-sweep → guards →
  handlers". Annotation log 759–761: "The iteration to quiescence and the
  ticks after it stand." Plain, per R4.
- **D-154** three times, plain, per R4.
  - At "The signal table is written only by sweeps". Position log 5408–5409:
    "the signal table is written only by sweeps".
  - At the epoch rule. Position log 5414–5416: "**a handler executes against
    exactly the world its guard fired on** — own `y`, foreign `u` and own
    `x`/`m` are all the firing round's sweep, so `y = h(x)` holds at every
    handler entry".
  - At the one-event-per-round rule. Position log 5409–5410: "a component
    fires at most one event per round, declaration order picking among its
    simultaneously-eligible events". The annotation (log 5433–5435) keeps it:
    "One event per component per round and the epoch rule stand."
- **D-089** four times.
  - At "Scheduled gains are inputs" (bold). Position log 2690–2694:
    "scheduled gains are input ports — scheduler components own lookup tables
    as inert parameters and publish per-compensator gain bundles".
  - At the one-shot gains, plain. Rationale log 2698–2699: "One-shot
    design-time gains = construction-time parameters or stopped-sim service
    outputs".
  - At the commanded discrete reset (bold, R9). Rationale log 2699–2700:
    "commanded resets are same-tick inputs consumed in the *output stage*".
  - At "Honoring the reset only in `s_update` is legal", plain. Rationale log
    2700–2701: "reset honored only in `g` = one-tick-late outputs, legal where
    that is meant"; Rejected log 2708–2710.
- **D-141** at "A continuous component's reset is an event" (bold). Position
  log 4690: "A continuous component's state reset is an event". The old text
  cited it two sentences later only; that citation stays too.
- **§10.5** at the zero-order-hold gloss. Spec 5633–5636: "A discrete
  component's `y_state`/`y_direct` run only at its own ticks … Its cells …
  hold in between. This is zero-order hold (ZOH)".
- **§11.7** removed by R5 F3 (above).
- **§10.6** added once, in "Two rules from [§10.6][s10-6] matter here",
  replacing "Two of its rules" so the antecedent survives the merge.
- Not added. D-111 (survey part E lists it for row 64): its Position names
  neither position and cites §7.1, so its text does not carry the claim.
  D-191: the unit does not state "blocked, not lost"; §10.6 bolds it. D-016
  at "Guards and handlers read the same fresh world": the clause that states
  it (log 619–620) carries the superseded per-event re-decode in the same
  clause, so the sentence stays uncited. D-020 is cited in the next paragraph.

## Rationale-only rulings

- D-089, Rationale, log 2699–2701: the commanded discrete reset is a same-tick
  input consumed in the output stage. Bold kept, per R9. The log owes a
  Position that states it.
- D-089, Rationale, log 2698–2699: one-shot design-time gains are
  construction-time parameters or stopped-sim service outputs. Plain, cited.
- D-089, Rationale log 2700–2701 and Rejected log 2708–2710: a reset honored
  only in `s_update` is legal and one tick late. Plain, cited.
- D-067, Rejected, log 1990–1992: republishing from `s⁺` is rejected. Cited
  as before, plain.

## Bold on the same entry elsewhere

- The unit bolds D-016, D-089 (twice, two rulings: the Position's gains and
  the Rationale's reset) and D-141. No bold cites any of them in chapters 7 to
  10 of the base spec. No other unit's `new.md` bolds them (checked against
  A, B, C, E and F as they stand).
- Appendix A carries two old-style bold lead-ins on the same rulings, with no
  D-citation: "**Same-tick reset consumption**" (11648) and "**A continuous
  component's state reset is an event**" (11656). They belong to the appendix
  rewrite.
- D-020 and D-154 stay plain here per R4. §10.6 bolds them (5934, 5938, 6060,
  6165).

## Inbound citations affected

All of survey part D's M3 rows hold.

- Spec 312 (§3.1): "Guards and handlers read the same fresh world" survives
  as the first paragraph's topic sentence.
- Spec 5062, 5070, 5089, 5101, 5220: the boundary sequence survives, in prose
  and in the blockquote.
- Spec 5929 (§10.6): the hand-off paragraph survives whole.
- Spec 2720 (§8.2): the declaration-order sentence survives verbatim, now
  cited to D-154.
- Spec 11681 (Appendix A): the epoch rule, one event per round, and "only by
  sweeps" each survive as plain sentences.
- `event_visibility_walkthrough.md` 12: "a handler executes against exactly
  the world its guard fired on" survives word for word, after "Under the epoch
  rule ([§10.6][s10-6]),".
- `flight_case_studies.md` 180 still carries the dangling §11.7 pointer
  (survey F12, track 2).

## Open questions

1. **The blockquote's bold.** The old blockquote bolds
   "[ sweep → guards → handlers ]". A bold with no D-citation in its paragraph
   fails `check_bold.jl` once chapter 5 joins `REWRITTEN`, and `spec_style.md`
   lets bold mark rulings only. I dropped the `**` and kept the brackets,
   which carry the grouping. §10.6's final-form blockquote (6189) has no bold
   either. The brief says to carry the blockquote as written; this is the one
   change.
2. **Glossary links shared with unit C.** Settled by R13. Unit C takes
   `#g-store`, `#g-sweep` and `#g-guard`; this unit dropped those links and
   their glosses, keeping only the unlinked gloss on "boundary sweep". The
   unit links *quiescence*, *tick*, *firing budget*, *trace*, *replay* and
   *face*, each glossed.
3. **F10 touched.** "A flag-gated reset face on a library PI block" gained the
   *face* gloss only, in the glossary's words. `PIVector` stays unnamed, as the brief says.
4. **No *continuous component* link.** Part C notes its first use (old 1006)
   has an anchor and no link. The first use is the bold headline. A gloss
   there would add bold weight, so I left the term unlinked.
5. **"owned by the reset component"** is kept verbatim. It means the
   component whose state is reset (D-141 Rationale, log 4716–4717: "the
   state's owner is the reset's only possible home"). A wording fix to "the
   component it resets" is available if wanted.
