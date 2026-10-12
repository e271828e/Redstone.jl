# Unit C rulings: §5.3's opening, the stage roles, M2 and the execution order

Old lines are `spec.md` lines at `b08afca`; log lines are `decisions.md` at
`b08afca`.

Rulings applied: R2 (M2 moved up after "Stage roles: what each stage may see"
and retitled "Derivatives that read outputs"; M5 cut the `DeadStage` sentence
to a pointer at §5.2), R5 F4 (the textbook form reads $y = h(x, u)$), R7
(`DeclarationOnWrongTier` named after old 868–870), R9 (D-220 bullet 2 bold at
old 856 and plain at 865–867; D-015 bold at old 898 and plain at 903; D-252
sentence 1 plain with a pointer to §8.3, sentence 2 bold), R13 (`#g-store` at
the tier-agreement sentence, `#g-sweep` inside the D-015 headline with its
gloss after the bold span, `#g-guard` at the interior-sweep sentence, each
glossed from its glossary entry).

## Corrections proposed

None beyond R5's F4, which is applied. F11 (bare `h`, old 843) is a wording
fix: the sentence now reads "The output map is `h` in `y = h(x, u)`, the
control/estimation convention", and claims what the old one did.

## Citations added or replaced

- D-220 at "Mathematical symbols and API names are two vocabularies" (old
  840), bold. Position head, log 8133–8135: "The component-authoring family
  drops its single letters and bare nouns for distinctive words; the spec's
  formulas keep `f`, `g` and `h` as mathematical symbols."
- D-220 at "A stage's name states the dependence class" (old 856), bold, per
  R9. Position bullet 2, log 8138–8139: "One pair of names serves both tiers,
  'direct' naming direct feedthrough." The words "dependence class" are the
  Rationale's, log 8173–8175 ("the new names state the dependence class in
  words, `output_state` for `y = h(x)` and `output_direct` for `y = h(x,
  u)`"); see "Rationale-only rulings".
- D-112 at "A stateful leaf's declarations must agree on one tier throughout"
  (old 867–868), plain, beside the existing §8.2. Position, log 3408–3409:
  "the tier-consistency rule enumerates four declaration families". §8.2 2774
  bolds it.
- D-035 at "`y_state` is the no-feedthrough stage" (old 874), bold. Position,
  log 1134: "`h_x`/`h_z` = the no-feedthrough stage"; annotation, log
  1141–1142: "the no-feedthrough stage stand[s]".
- D-252 sentence 1 (old 885–886) keeps its citation and gains a pointer to
  §8.3, which bolds it (2834). D-252 sentence 2 at "A component exposes a state
  or mode field by returning it from `y_state`" (old 886), bold. Position, log
  9618–9620: "A component exposes a state or mode field by returning it from
  `output_state`."
- §5.2 at the `DeadStage` sentence (old 882), M5's pointer. §5.2 791 (unit B)
  states the rule.
- D-006 at "`y_direct` receives all wired inputs plus the stage-1 hand-down"
  (old 891), plain. Position, log 430–431: "state decoder `h_x` + all-inputs
  `h_xu`". Unit A bolds D-006. D-006 carries only the all-inputs half.
- D-194 at the same sentence, for the hand-down half, plain. Position bullet
  2, log 7021–7023: "An intermediate a later function needs is declared in
  `output_types` and read where the bundle law already delivers it: stage-1
  products through `y_x`". Bullet 3 of D-285 (the hand-down "is sourced from
  the stage-1 probes' returns") was read and not added, since it rules the
  probe's sourcing rather than what `y_direct` receives.
- D-194 at "Stage 1 declares it as a port, and stage 2 finds it in `y_x`"
  (old 893–894), plain. Position bullet 2, log 7021–7023: "An intermediate a
  later function needs is declared in `output_types` and read where the bundle
  law already delivers it: stage-1 products through `y_x`".
- D-015 at "`x_deriv` and `s_update` run after the sweep" (old 898), bold.
  Position, log 595–596: "Fused evaluation: `f`/`h` read the fresh table (own
  `y` included)".
- D-015 repeated on the second half of the split old 898 sentence ("They run
  when the full signal table … is complete and fresh, the component's own
  stage-2 ports included"), plain. The split for R13's sweep gloss separated
  that clause from the bold headline and its citation. Same Position words,
  log 595–596: "`f`/`h` read the fresh table (own `y` included)".
- D-015 at "All output stages must be pure" (old 906), plain. Rejected, log
  605–606; see "Rationale-only rulings".
- D-015 at "The computer/integrator split remains fully expressible" (old
  1039), plain. Rejected, log 610–611; see "Rationale-only rulings". §7.4
  1888–1889 states it citing D-015.
- D-015 at "Purity rules forbid the classic resolution by mutable caching"
  (old 1041), plain. Rejected, log 605–606; see "Rationale-only rulings".
- D-288 and §9.7 at the execution order (old 911–913), plain, replacing the
  **Rule.** label. Position bullet 1, log 12124–12126: "the order-free
  stage-1, `x_deriv` and `s_update` blocks, the topologically ordered stage-2
  block". §9.7 4826 bolds it.
- D-147 at "RHS evaluations and guard trial evaluations alike run the
  *interior* sweep" (old 919–920), plain. Position, log 5084–5088: "The
  interior sweep walks continuous entries only and is what RK stage
  evaluations and localization guard probes run … discrete entries … are
  absent from the walk at compile time". §10.4 5321 and §10.5 5642 bold it.
- §3.4 at `f_c_c` (old 1038), a pointer to the strapdown IMU example
  (396–398), per the brief. It glosses no physics.

Considered and not added: D-020 at old 898 (its Position puts due `g` updates
after quiescence at a boundary, not `x_deriv` after the sweep); D-195 bullet 3
at old 868–870 (it speaks of the retired `h_x`/`h_s` names); D-285 at old
880–883 and 891 (M5 points at §5.2, which cites the probe; the hand-down's
sourcing is unit B's).

## Rationale-only rulings

- D-075, Rationale, log 2263 ("modes fold under the state letter, ambient
  `t`/`Δt`/`ws` unnamed"), and Rejected, log 2273–2275. Old 861–863, cited
  in place already.
- D-220, Rationale, log 8173–8175: the stage names state the dependence class.
  Old 856, bold per R9 with D-220; the Position's bullet 2 carries only
  "'direct' naming direct feedthrough".
- D-015, Rejected, log 605–606 (mutable caches: "hidden state, purity
  violation"): output stages are pure (old 906) and mutable caching is
  forbidden (old 1041). Both cited plain.
- D-015, Rejected, log 607–611: the orthodox split is expensive here (old
  1032, cited in place already) and the computer/integrator split stays
  expressible without framework support (old 1039, cited plain).

## Bold on the same entry elsewhere

No ruling is bold in two places. Checked against units A, B, D, E and F's
`new.md` and chapters 7 to 10 of the base spec.

- D-035: unit A bolds its second ruling (one home per datum); unit C bolds its
  last (the no-feedthrough stage). Different rulings.
- D-220: unit C bolds the Position head and bullet 2; no other unit or
  chapter 7–10 bolds D-220. §8.2 2771–2772 states bullet 2 plain.
- D-252: §8.3 2834 bolds sentence 1, which unit C states plain with a pointer;
  unit C bolds sentence 2 only.
- D-015: bold here only.
- D-006 (unit A), D-194 (unit B; §9.3 4294), D-288 (§9.7), D-147 (§10.4,
  §10.5) and D-112 (§8.2 2774) are bold elsewhere and cited plain here.

## Inbound citations affected

None broken. Rows of `inbound.tsv` that rely on unit C's sentences, each still
true: spec 1852 (§7.4, overlap is the norm), 1579, 2840, 10541, 12419 (return
the field from `y_state`), 5906 (each law computed once and published), 12855
(stage-2 conservatism), 12945 (no incremental `x_deriv`-only re-evaluation);
log 7046 (D-194, "evaluating the RHS means running the sweep", kept verbatim),
log 10772–10773 (D-267, no `direct` in the name is the no-feedthrough
property); `linear_blocks.md` 100, `flight_case_studies.md` 99 and 132,
`frame_walkthrough.md` 93. The pre-existing mismatches of part D (spec 636,
6526, `trim_environment_walkthrough.md` 62, log 7157) are unchanged.

## Open questions

1. **First uses of *sweep* and *guard* in §5.3.** Settled by R13: unit C
   links `#g-store`, `#g-sweep` and `#g-guard`, and unit D drops its three.
2. **D-015's semicolon.** Its Position chains two clauses: derivatives read the
   fresh table, and one computation site is the rewarded idiom. The one-bold
   test would give the second its own bold at old 903 ("The interfaces
   *reward* single-source-of-truth"). R9 rules it plain; applied.
3. **`DeclarationOnWrongTier` for a store against the other update law.**
   Named per R7, following §8.2 2783–2787 and Appendix C 12348–12354. D-220's
   Rationale (log 8185–8187) calls `state_derivative` beside `init_s`
   "`StoreWithoutUpdate` or a tier disagreement". The spec's two homes agree
   with the name used; the log's hedge is for track 2.
4. **Rules with no entry**, stated plain as before: stage 1 exists when
   state-derived ports exist (old 880), every stage-2 output presumed
   dependent on every wired input (old 896), evaluating the RHS means running
   the sweep (old 915–916). Survey part E lists them for the log.
