# Unit B (§5.2: the bundle law, the stage return law, the handler return law): rulings, citations and open items

## Corrections proposed

None new. Applied as ruled:

- R5 F1, both instances. Old 750–751 "fails at the probe, inside the [§13.2]
  framing diagnostic" now reads "fails at the probe with a `BundleFieldError`
  diagnostic ([D-248])", followed by "[§13.2] describes the catch that
  recognizes it", which keeps the pointer for the catch machinery. Old 758–759
  "synthesizes the framing diagnostic from the legal set" now reads "The probe
  synthesizes the `BundleFieldError` from the legal set". This also applies R7
  for `BundleFieldError`.
- R5 F2. The `x`, `s` and `m` cells read "declares a non-empty `x_init`" (and
  `s_init`, `m_init`), each ending with `([D-297])` inside the cell. No other
  cell changed, and no sentence was added.
- R6. The hand-down cites D-285 in place of D-252 and keeps its bold.
- R7. "An unknown key gets did-you-mean against `{x, m}` in a
  `HandlerReturnKey` diagnostic" (old 809–810).
- R9. The bundle law (row 12) keeps a bold with its D-074 Rationale citation.
  The closed name sets (row 21) are plain, cited to D-074.
- R11. The padding-forms sentence (old 804–805) stays word for word with its
  citations.
- Part C's order. The absence rule (old 749) now precedes the hand-down
  (old 744–747).

Other edits:

- "The wrong-tier class" (old 765) became "The wrong-tier classification",
  since bare *class* is reserved. "lands in that bucket" became "is classified
  as a wrong-tier fact".
- "A pure FSM" takes its expansion: "(finite-state machine, with modes and
  events and no `x`)".
- "On the continuous tier the sets are" names its sets: "the `y_state` and
  `y_direct` sets".
- The **Rule.** labels (729, 785, 797) are gone. The bold words "**iff …**",
  "**closed**", the handler law's "**iff**" and "**and**", and the table's
  `u`-row "**and**" lost their bold, because bold marks only headline clauses.
  Every word and both conditions of each "iff … and" stay.

## Citations added or replaced

- D-074 at the bundle law's bold headline (old 729). Rationale, log 2222:
  "The bundle law (a field exists iff the store or tier fact exists".
- D-297 in the `x`, `s` and `m` cells of the table. Position bullet 6, log 12545:
  "A store puts its letter in the bundle only when it is non-empty."
- D-285 replaces D-252 at the hand-down (old 744–745). Position bullet 3, log
  11985–11986: "The stage-1 hand-down, `y_x` on the continuous tier and `y_s`
  on the discrete, is sourced from the stage-1 probes' returns." D-252's
  Position says nothing of the hand-down.
- D-248 at the `BundleFieldError` sentence (old 750–751). Position bullet 4,
  log 9401–9402: "A `FieldError` matched against the bundle is
  `BundleFieldError` at the probe".
- D-074 right after "closed" at the closed name sets (old 769). Rationale, log 2224–2225: "closed
  per-function-kind name sets, growth = a decision-log event". The per-tier
  half is D-220's (Rationale, log 8181–8183: "`output_state` and
  `output_direct` take one legal set per tier again"), which the next sentence
  already cites.
- D-194 at the stage return law's bold headline (old 785). Position, log
  7015–7016: "Every output stage returns its port NamedTuple alone"; bullet 1,
  log 7020: "stage returns are `y`, period."
- D-285 beside §9.3 at the `DeadStage` sentence (old 791). Position bullet 2,
  log 11983–11984: "A stage returning bare `(;)` produces no ports and is
  `DeadStage`, fail-fast."
- D-090 at the handler return law's bold headline (old 797). Position, log
  2716–2718: "Handler returns are NamedTuples under the bundle law …, a key
  present iff the store exists AND the handler updates it".
- D-287 at "The return's semantics are per key" (old 807). Position, log
  12084: "The always-on check reads handler returns by key"; bullet 1 (unknown
  key, did-you-mean against `{x, m}`) and bullet 2 ("A present `x` is complete
  against the state field set").
- D-090 at the `m` names-subset sentence (old 808). Rationale only, below.

Not added: D-194 at row 27 ("every value a later function needs is one of
those cells"). D-194 bullet 2 carries it, and the bold sentence just before
already cites D-194.

## Rationale-only rulings

- The bundle law (row 12), bold, D-074 Rationale, log 2222–2224. The log owes
  a Position that states it. D-297 bullet 6 restates only the state-letter
  piece.
- The closed per-function name sets and growth by log entry (rows 21, 24),
  plain, D-074 Rationale, log 2224–2225. One set per tier for the shared
  output stages, D-220 Rationale, log 8179–8183. D-195 Position bullet 2 (log
  7100–7101) still says per-function sets with no annotation pointing at D-220.
- The absence rule, "absent, never `nothing`-filled" (rows 15, 16), plain,
  D-074 Rationale, log 2222–2223, and Rejected, log 2242–2243. Uncited, as in
  the old text.
- The `FieldError` mechanism, no scraping, the getproperty fallback (row 19),
  D-074 Rationale, log 2225–2229, cited as in the old text. The three
  classifications have no entry.
- The `m` names-subset predicate and "both directions" (row 34), D-090
  Rationale, log 2722–2725. D-090 is now cited at the `m` sentence.
- The padding forms (row 33), D-090 Rejected, log 2728–2730, cited as in the
  old text.
- The three-level funnel (row 25), D-075 Rationale, log 2267. Uncited, as in
  the old text.

## Bold on the same entry elsewhere

No ruling of this unit is bold in two places within chapters 7 to 10 or the
other units. Same entry, different ruling:

- D-074. Unit A bolds two Position rulings (the hand-off; `x_projection` alone
  positional). This unit bolds the bundle law from D-074's Rationale. §5.2 thus
  carries three D-074 bolds.
- D-285. §9.3 (spec 4296–4297) bolds bullet 2, `DeadStage`, with D-194. This
  unit bolds bullet 3, the hand-down, and cites bullet 2 plain. §9.3 4277–4279
  states bullet 3 plain.
- D-194. §9.3 (4296) bolds bullet 5 (`DeadStage`) and §9.7 (4860) bolds
  bullet 3 ("These bodies communicate only through the stores and the
  table"). This unit bolds the Position's second sentence.
- D-287. §9.5 (4701) bolds bullet 1, the key-set check. This unit cites D-287
  plain.
- D-090. Appendix B (spec 11807) bolds the handler return law old-style, with
  no D-citation. That is the same ruling bold twice. The survey (part B)
  proposes dropping the appendix bold when the appendices are rewritten.
- D-297. §8.1 (2055) bolds bullet 1. This unit cites bullet 6 plain.

## Inbound citations affected

- Spec 2322 and 2799 (§8.2), "the bundle law puts a state declaration's letter
  in the bundle only when it is non-empty ([§5.2])". These now hold through F2.
- Appendix C 12435 (`BundleFieldError`) and 12440 (`HandlerReturnKey`) cite
  §5.2. §5.2 now names both kinds where it states their conditions.
- Appendix C 12348 (`DeclarationOnWrongTier`) cites §5.2. This unit's
  wrong-tier classification is `BundleFieldError`'s, not that kind's condition.
  It is still track 2's retarget to §5.3 (F14).
- Appendix B 11802 cites D-252 with §5.2 for "`y_x`/`y_s` are present iff the
  stage-1 *return* is non-empty". §5.2 now cites D-285 for the hand-down. A
  track 2 candidate for the appendix's citation.
- Appendix B 11800–11801, in the footnotes "from the bundle law ([§5.2])",
  says "`x`/`s`/`m`/`ws` are present iff declared". After F2, §5.2 says a
  non-empty `x_init`, `s_init` or `m_init`. That makes the appendix line stale
  for the three state letters. It goes to track 2.
- These hold unchanged: spec 4279 and 4286 (§9.3), 4689 (§9.5), 9264 (§13.2),
  11618 (*The stage funnel*), 11804, 12742–12744 (glossary *function family*),
  12824 (glossary *bundle*), `implementation.md` 353.
- Spec 6500, 10517 and 10829 already rely on content §5.2 does not hold
  (survey part D). This unit does not change that.

## Open questions

Settled by the coordinator: the `u`-row "and" stays unbolded; the `Foo`
diagnostic stays verbatim; under R13 the table's `#g-cell` link is dropped and
unit A takes it; D-297 sits inside the F2 cells, not in a sentence.

1. **Glossary links shared with unit A.** Unit A's `new.md` links `#g-tier`
   and `#g-port` in "What the views are", before this unit's table, so the
   table carries neither. Restore them if unit A drops its own. `#g-bundle` on
   "bundle law" (old 729) is dropped, because unit A links *bundle* at the
   hand-off.
2. **Row 28** ("Stages are discovered by method existence, and stage
   membership is a partition of the declared ports") has no live Position.
   Only superseded D-165 states the first half. It stays plain and uncited,
   as written.
3. **The `Foo` example diagnostic** differs from `src`'s text (survey
   `run_bundle.jl`). It stays verbatim, in the same class as F9.
