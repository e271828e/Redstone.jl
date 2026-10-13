# Unit H (§11.7): rulings

Rulings applied: R6 (old 8166–8169 kept), R10 (F65 at old 8146, F66), R11
(`Cessna172Xv1`, `T16000M`, `World`), R13, R16, R18 (the panel kit's
signatures). Survey 2's order: one context sentence, then five `####` labels.
Every glossary link at its first use carries a gloss, declared in `added`.

## Corrections proposed

- **`World` is introduced in §8.8, not §8.7.** R11 says "point at §8.7,
  which introduces it" (from survey 2's F67). In the frozen spec, §8.7 is
  "Rate scopes" (line 3779) and §8.8 "Computed connections and generic
  holding" starts at 3825. `World` first appears at 3837, inside §8.8's "The
  passthrough helpers". I pointed at `[§8.8][s8-8]`, because a §8.7 pointer
  would be false. The new sentence reads "`World` names the example assembly
  of pure composition that §8.8 introduces", in §8.8's own words ("a `World`
  assembly, a component of pure composition").
- **Bare "cell" for the staging cell, beyond F65's one listed instance.**
  Old 8213 ("published into the cell"), 8216 ("skips the cell") and 8221
  ("the drain that takes the cell") all mean the staging cell. I wrote
  "staging cell" under the brief's reserved-word rule. "The producer's cell"
  (8195, 8215–8216) is a signal-table cell and stays bare.
- **The claim's gloss says "root inputs" where the glossary says "faces".**
  Writing "faces" would use *face* before its link at "one face … at a
  time". A claim is a set of root-input faces (glossary *claim*, *root
  input*), so the gloss claims nothing new.
- **Proposed, not applied:** survey 2's part B suggests the API paragraphs
  say "the rule above" in place of restating fan-out consistency (8217–8218)
  and the orphan fact. Both stay, since cutting them is a move no ruling
  orders.

## Citations added or replaced

- D-026 at "Widgets, however, name the component's own ports, never root
  inputs" (Position: "per-component panels name own ports").
- D-026 at "Read-only rendering is first-class …" (Position: "live vs
  first-class read-only rendering (with its wiring source shown)").
- D-026 at the peek rule's bold (Position: "own-pending-else-snapshot
  peek"). The old text cited D-026 two sentences later. That citation stays.
- D-026 at the R16 sentence (Rejected, log 935–936: "as insurance it masks
  invariant violations at render rate").
- D-045 at "A widget is live exactly when the underlying input is yours to
  command" and at "Liveness is a derived property, and resolution is
  transitive" (bullet 1: "GUI liveness is fully derived: transitive
  root-slot resolution ∧ slot unclaimed").
- D-045 repeated at "Unexported ports are unpokeable" (bullet 5, same
  words). The old text cited it in the previous sentence.
- D-174 at "that root input lies inside the GUI's own claim" (Rationale, log
  6382–6383: "live iff the port's feed chain terminates in a root slot
  **inside the GUI's own claim**").
- D-047 at "Widgets stage on interaction events only" (Position: "Widgets
  stage on interaction events only (value widgets on edit, edge widgets on
  activation with peek-computed counter levels)").
- D-270 at the bold two-halves sentence (Position: "splits into a framework
  half, fixed now …, and a GUI-package half that stays deferred"). It was
  cited at the end of the same paragraph, and that citation stays.
- D-270 at `port_views` (bullet 1), `pending` (bullet 2), the
  drain-to-publication window (bullet 4: "recorded as the rule's own
  consequence") and `incumbent_status` (bullet 3).
- §8.8 at the `World` sentence (above). §11.3 at the roster gloss (the
  freeze, as the old text cites it at 8172).

## Rationale-only rulings

- D-026, Rejected, log 933–936: the R16 clause (staging every render pass
  would mask invariant violations at render rate). Also the old
  rejection of staging every render pass (8166), which cites D-026.
- D-174, Rationale, log 6382–6383: "inside the GUI's own claim". D-045's
  Position still says "slot unclaimed" (log 1428–1429).
- Uncited and resting on Rationale (survey 2 part E, item 9): the bake once
  per run (D-047 Rationale log 1502; D-270 Rationale log 11197–11200),
  paused editing (D-270 Rationale log 11205–11207), held buttons (D-047
  Rejected log 1509–1510), no claim-transition policy and the orphan display
  (D-047 Rationale log 1501–1503). The text keeps them plain, as before.

## Bold on the same entry elsewhere

None in two places. Bolds in this unit: D-026 (own ports; the peek), D-045
(bullet 1, "live exactly when …"; bullet 5, unpokeable), D-047 (the
staging contract), D-270 (the two halves; `port_views`; `pending`;
`incumbent_status`). Checked against the frozen spec and units A, B, C, F
and G1:

- D-045 is bold at §4.3 (frozen 931), on the write-side granularity ruling
  with D-346 and D-363. That is a different ruling.
- D-047 is bold in unit B ("The captured table also includes the root
  inputs") and unit C ("The init/trim services own root-input initial
  values"). Those are D-047's third and fourth rulings. This unit bolds its
  first.
- D-174 (units C), D-106 (unit C) and D-310 (unit A) are bold elsewhere.
  This unit cites D-174 and D-310 plain.

Bold choices inside the unit:

- "A widget is live exactly when …" and "Liveness is a derived property,
  and resolution is transitive" both state D-045 bullet 1. The first in
  reading order keeps the bold. The second is now a plain topic sentence
  with the citation.
- The bold words "inside the GUI's own claim" go plain. They are the second
  conjunct of the same liveness ruling.
- "What stays deferred is the GUI package's half" goes plain and becomes
  the `####` label's topic. The deferral is D-270's first ruling, bold at
  the two-halves sentence. D-310's assignment to the browser client was
  never bold.
- The three **Rule.** labels go. Each D-270 bullet they marked becomes a
  bold headline clause citing D-270.

## Inbound citations affected

- R16's clause gives log 2049 (D-067), 2618 (D-084) and 5483 (D-153) the
  masking argument they cite §11.7 for. The text does not use the word
  "anti-diagnostic", so the phrase "§11.7's anti-diagnostic lesson" is
  still a paraphrase.
- No other row loses its target. Content moves only into `####` subsections,
  and "peek rule", "port view" and the orphan label stay verbatim (D-270
  log 11171, spec 8549, 12386, 13983, 14053, 14109, `implementation.md`
  416).

## R18 check

Checked by grep on `src/devices.jl`. The signatures are
`pending(handle::DeviceHandle, slot::Int)` (150),
`port_views(handle::DeviceHandle)` (296),
`peek(view::PortView, handle::DeviceHandle, snapshot::Snapshot)` (337) and
`incumbent_status(view::PortView, snapshot::Snapshot)` (352). The block
shows the four calls without types, in the order the text specifies them.

## Open questions

1. R11's `World` pointer names §8.7. The frozen spec introduces `World` in
   §8.8. I applied §8.8 (above). Please confirm.
2. D-045 bullet 1 still reads "slot unclaimed". The liveness bold cites
   it, and only D-174's Rationale states "inside the GUI's own claim". The
   log owes a Position, or an annotation on D-045.
3. D-026's Position says "build-time resolution". The text bakes liveness
   at run start (D-270, D-047 Rationale). D-026 owes an annotation.
4. "Assembly panels compose children by path" (old 8242–8243) has no
   entry. It is kept plain.
5. D-047's Spec field lists §11.3 only. It now rules a bold in §11.7
   (track 2).

## Rulings batch edits (checkpoint 3)

- **B-23**: "baked once … at render" cites D-270's Position bullet 1,
  "([D-270][d-270])". C-026, tag R.
