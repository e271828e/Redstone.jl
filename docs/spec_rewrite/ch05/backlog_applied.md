# Chapter 5 track 2: edits applied — 2026-10-12

Applies `rulings_batch.md` group B, items B8 to B21. `log` is
`docs/design/decisions.md`, `spec` is `docs/design/spec.md`, `cases` is
`docs/design/companions/flight_case_studies.md`, and `pid` is
`docs/design/companions/pid_anti_windup.md`. Every line number is the line
**after** all edits and the `linkify.jl` run. New citations were written
bare, and `linkify.jl` linked them afterwards. Every annotation is dated
2026-10-12 and sits after its entry's Rationale, before **Rejected.**

Not applied, by ruling: B12, B16 and B21 (no edit).

## B8. D-267's Spec field (log 10786)

- Old: "… [§5.3][s5-3], [§5.4][s5-4], [§6.2][s6-2], …"
- New: "… [§5.3][s5-3], [§5.4][s5-4], [§5.6][s5-6], [§6.2][s6-2], …"

## B13. D-016's annotation (log 635–636)

- Old: "`h_x` as the uniform state decoder and `project` as the sole
  raw-state function stand."
- New: "`h_x` as the uniform state decoder and `project` as the sole
  raw-state function (schedule-structural) stand." The last line was
  rewrapped.

## B14. D-195 annotation (log 7173–7175)

- Old: no annotation.
- New: "Annotation (2026-10-12): amended by D-220, which retires the
  output-stage split with its member of `DeclarationOnWrongTier`, and gives
  `y_state` and `y_direct` one legal name set per tier. The state-letter
  split stands."
- Source: D-220 Rationale, log 8226–8230.

## B15. D-111 annotation (log 3432)

- Old: no annotation.
- New: "Annotation (2026-10-12): the two positions are stated in §5.3
  (D-131)."
- Source: D-131 Rationale, "`project`'s two schedule positions cited to
  §5.3"; §5.3 "`x_projection` runs between a state write and its decode"
  (spec 1019–1021). D-111's Spec field is unchanged.

## B9 to B11. New entries

D-341 to D-343 sit after D-323 and before the link-definition block, at log
14026 to 14141. Each was checked bullet by bullet against its source entry at
the lines below (lesson 17). No bullet claims more than its source, so none
was trimmed. The text is the batch's proposal, verbatim.

### D-341 — The bundle law, the closed name sets and per-key return checks (log 14026)

Spec: §5.2. Rejected: none beyond the source entries' lists.

- Bullet 1, the bundle law ← D-074 Rationale, log 2256–2258: "a field exists
  iff the store or tier fact exists: undeclared stores absent, never
  `nothing`-filled; `t` everywhere, `Δt` discrete-only, `ws` iff `workspace`
  declared". `workspace` is `ws_init` since D-220 and D-267.
- Bullet 2, closed sets ← D-074 Rationale, log 2258–2259: "closed
  per-function-kind name sets, growth = a decision-log event"; D-220
  Rationale, log 8228–8230: "`output_state` and `output_direct` take one legal
  set per tier again".
- Bullet 3, the `FieldError` mechanism ← D-074 Rationale, log 2259–2263.
- Bullet 4, the funnel ← D-075 Rationale, log 2300–2301: "three-level
  narrowing taught (stage name ⊇ bundle ⊇ destructured reads)". "At its
  tier" rests on bullet 2's D-220 source.
- Bullet 5, closed spellings and padding ← D-074 Rejected, log 2266–2271 and
  2276–2277; D-090 Rejected, log 2762–2764: "reintroduces the padding D-074
  bans on arguments — `((;), m⁺)` / `(x⁺, (;))`".
- Bullet 6, per-key checks ← D-090 Rationale, log 2756–2759; D-287 Rationale,
  log 12144–12147: "`m` present ⇒ names-subset … the argument-side
  `FieldError` machinery run in both directions".
- Bullet 7, no dependency annotations ← D-006 Rejected, log 444–447: "*N
  output groups with declared input subsets*", "*Per-output declarations +
  tracer verification*".

### D-342 — Pure output stages, the dependence-class names and supervisory resets (log 14067)

Spec: §5.3, Appendix A. Rejected: none beyond the source entries' lists.

- Bullet 1, the dependence class ← D-075 Rationale, log 2295–2298: "suffix =
  the *dependence class* (state-only vs state-plus-input …; modes fold under
  the state letter, ambient `t`/`Δt`/`ws` unnamed)"; D-220 Rationale, log
  8221: "the new names state the dependence class in words".
- Bullet 2, purity ← D-015 Rejected, log 611–612: "*Mutable caches between
  `f` and outputs:* … hidden state, purity violation."
- Bullet 3, drift ← D-015 Rejected, log 613–614.
- Bullet 4, the orthodox split ← D-015 Rejected, log 616–617.
- Bullet 5, one-shot gains ← D-089 Rationale, log 2732–2733.
- Bullet 6, the commanded reset ← D-089 Rationale, log 2733–2735: "commanded
  resets are same-tick inputs consumed in the *output stage* with `g`
  storing the matching `z⁺` (…; reset honored only in `g` = one-tick-late
  outputs, legal where that is meant)"; D-089 Rejected, log 2742–2744:
  "*Reset-in-`g`-only as the idiom*".
- Bullet 7, no republishing ← D-067 Rejected, log 2020–2022:
  "republish-from-`z⁺`: … Mealy update-feedthrough: same-boundary
  circularity"; D-089 Rejected, log 2743–2744: "§10.6's `z⁻¹` discipline
  makes the output stage the only same-tick path, D-067".

### D-343 — The remedy ladder's content, the closed loop remedies and the trace's reach (log 14103)

Spec: §5.4, §5.5, §5.6. Rejected: none beyond the source entries' lists.

- Bullet 1, coarse units ← D-006 Rejected, log 449: "*Component-atomic
  conservative:* false loops everywhere"; D-019 Rejected, log 734–735:
  "*Atomic assemblies, incl. opt-in:* coarsened schedulable unit → §5.4
  artificial loops at assembly scale".
- Bullet 2, the fallback branch ← D-140 Rationale, log 4672–4677.
- Bullet 3, substitution ← D-140 Rationale, log 4685–4688: "the factoring
  **survives substitution** … which is the test that it records structure
  rather than dodging the diagnostic".
- Bullet 4, the split's cost ← D-140 Rationale, log 4690–4695.
- Bullet 5, both exits ← D-140 Rationale, log 4696–4698.
- Bullet 6, "rare" earned ← D-140 Rationale, log 4699–4700.
- Bullet 7, closed remedies ← D-005 Rejected, log 427–430.
- Bullet 8, the trace's reach ← D-140 Rejected, log 4717–4720.
- Bullet 9, unwalked faces ← D-245 Rationale, log 9294–9296: "The structural
  answer extends from discrete members to any continuous face or port
  declared without a walking leaf".

## B17. Citations in chapter 5

Each adds the new entry beside the source the chapter cites. No other word
changed. The bundle-law, dependence-class and reset bolds sat on
Rationale-only citations; the new entry joins each in the same sentence.

| spec line | old | new |
|---|---|---|
| 698–699 | `anywhere in the design ([D-006][d-006]).` | `… ([D-006][d-006], [D-341][d-341]).` |
| 738 | `closed ([D-074][d-074]).` | `closed ([D-074][d-074], [D-341][d-341]).` |
| 771 | `for that component** ([D-074][d-074]).` | `… ([D-074][d-074], [D-341][d-341]).` |
| 806 | `bare NamedTuple ([D-074][d-074]).` | `… ([D-074][d-074], [D-341][d-341]).` |
| 815 | `are closed ([D-074][d-074]), one set` | `are closed ([D-074][d-074], [D-341][d-341]), one set` |
| 828 | `is worth teaching once, because` | `is worth teaching once ([D-341][d-341]), because` |
| 854 | `([D-090][d-090], on the argument-side ground of [D-074][d-074])` | `([D-090][d-090], [D-341][d-341], on the argument-side ground of [D-074][d-074])` |
| 859 | `predicate applies ([D-090][d-090]).` | `… ([D-090][d-090], [D-341][d-341]).` |
| 894 | `the argument list ([D-220][d-220]).` | `… ([D-220][d-220], [D-342][d-342]).` |
| 901 | `inventory ([D-075][d-075]).` | `inventory ([D-075][d-075], [D-342][d-342]).` |
| 948 | `a stale copy in the other ([D-015][d-015]).` | `… ([D-015][d-015], [D-342][d-342]).` |
| 950 | `with no side effects ([D-015][d-015]).` | `… ([D-015][d-015], [D-342][d-342]).` |
| 970 | `expensive here ([D-015][d-015]).` | `… ([D-015][d-015], [D-342][d-342]).` |
| 981 | `caching, by design ([D-015][d-015]).` | `… ([D-015][d-015], [D-342][d-342]).` |
| 1061 | `service outputs ([D-089][d-089]).` | `… ([D-089][d-089], [D-342][d-342]).` |
| 1065 | `output stage** ([D-089][d-089]).` | `output stage** ([D-089][d-089], [D-342][d-342]).` |
| 1077 | `something else ([D-089][d-089]).` | `… ([D-089][d-089], [D-342][d-342]).` |
| 1084 | `from `s⁺` is rejected ([D-067][d-067]).` | `… ([D-067][d-067], [D-342][d-342]).` |
| 1105 | `admit no evaluation order. Simulink` | `admit no evaluation order ([D-343][d-343]). Simulink` |
| 1147 | `dodging the diagnostic ([D-140][d-140]).` | `… ([D-140][d-140], [D-343][d-343]).` |
| 1166 | `both exits explicitly ([D-140][d-140]).` | `… ([D-140][d-140], [D-343][d-343]).` |
| 1175 | `asserting it ([D-140][d-140]).` | `… ([D-140][d-140], [D-343][d-343]).` |
| 1206 | `are both closed ([D-005][d-005]).` | `… ([D-005][d-005], [D-343][d-343]).` |
| 1310 | `doctrine, [D-012][d-012]).` | `doctrine, [D-012][d-012], [D-343][d-343]).` |
| 1313 | `continuous members ([D-140][d-140]).` | `… ([D-140][d-140], [D-343][d-343]).` |
| 1316 | `structurally too ([D-245][d-245]).` | `… ([D-245][d-245], [D-343][d-343]).` |
| 1323 | `([§5.4][s5-4], [D-140][d-140]).` | `([§5.4][s5-4], [D-140][d-140], [D-343][d-343]).` |

- Spec 1105: §5.4's atomic-unit sentence cited no entry before. D-343 is its
  first citation, as chapter 6 cited D-323 where no source stood.
- Spec 828: the funnel cited no entry before. The citation sits on "worth
  teaching once", since D-075 records the narrowing as "taught".
- Not cited, as the batch rules: D-015 for "The computer/integrator split
  remains fully expressible" (spec 978–979) and D-016 for the `x_projection`
  bold (spec 1019). Spec 1110 cites D-140's Position, not its Rationale, and
  takes no D-343.
- Not in B17's list, so not cited: §5.4's first remedy (the fallback branch,
  spec 1120–1125) and second remedy (the split's cost, spec 1151–1161) carry
  no citation, though D-343 bullets 2 and 4 state them. §5.2's "Undeclared
  stores are *absent*" (spec 785) and "Adding a name to any of them is a
  decision-log entry" (spec 821–822) stay uncited; their paragraphs' bold or
  first sentence carries D-341.
- Rewrap: fifteen lines in thirteen paragraphs passed 80 rendered columns
  (link markup collapsed) after the edits. Each was fixed by carrying the
  overflow words to the next line within its paragraph, links kept whole:
  spec 698–699, 828–829, 901–902, 970–972, 1061–1062, 1065–1068, 1077–1088,
  1105–1106, 1147–1150, 1166–1172, 1175–1177, 1310–1316, 1323–1324. No word
  changed.

## B18. cases 178–180

- Old: "and the bumpless-engage answer ([§11.7][s11-7]) presupposes exactly
  this spelling."
- New: "and the bumpless-engage answer of section 3's *Mode engage* frame
  presupposes exactly this spelling." Lines 179–180 rewrapped.
- Source: cases 348–349, the *Mode engage* frame under "Frame anatomies".

## B19. The retired `init_*` spelling

- spec 3955 (§9.1): "`init_*` values" → "`*_init` values".
- spec 4434–4435 (§9.3): "`x`/`s`/`m` come from `init_*` declarations, which
  declare by value." → "`x`/`s`/`m` come from the `x_init`, `s_init` and
  `m_init` declarations, which declare by value." Wrapped to two lines.
- spec 10382–10383 (§14.1): "fresh run from the `init_*` defaults" → "fresh
  run from the `x_init`, `s_init` and `m_init` defaults". Lines 10382–10383
  rewrapped by carrying "condition is an" forward.

## B20. pid 100–103

- Old: "because its integrator splits the stages by construction, which is
  [§5.4][s5-4]'s second remedy for free."
- New: "because its integrator is a component of its own by construction,
  which is [§5.4][s5-4]'s second remedy, the component split, for free."
  Rewrapped to four lines.
- Checked against the companion first: section 8 (pid 299–301) says "an
  assembly of stateless folds and one integrator never meets the
  constraint, and that the integrator in it is precisely the component split
  §5.4 describes". The new words claim no more than that.

## The battery

All pass: `linkify.jl`; `check_refs.jl` ("OK — every citation and every
anchor resolves"); `check_rows.jl` ("newly cited by the spec (fine): [89,
140, 321, 322, 323, 341, 342, 343]", "OK — every decision citation names an
existing entry"); `check_glossary.jl --strict` (OK, three standing
advisories); `check_bold.jl` (chapter 5: 25 bold spans, 211 bold words, "OK
— every bold span in a rewritten chapter carries its D-citation");
`linkify.jl` again, a no-op by checksum over the 120 Markdown files under
`docs/design` to depth 2.

## Orchestrator touches after the track 2 verification

- B17, extended on the verifier's recommendation (backlog_verify.md): spec.md
  1125, "natural owner and the wire disappears." → "natural owner and the wire
  disappears ([D-343][d-343])."; spec.md 1153, "Its cost is stated where it
  bites." → "Its cost is stated where it bites ([D-343][d-343])." D-343
  bullets 2 and 4 state the two remedies. Both lines stay within 80 rendered
  columns. Battery green, linkify a no-op.
