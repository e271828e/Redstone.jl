# Chapter 14, track 2 log, agent 1

Edits in order, each matched by its old text. Commit 1 is the glossary
edit in `docs/design/spec.md`; the rest are in `docs/design/decisions.md`,
applied by `scratch_track2/1/apply.py` and then linkified, so a bare
citation below reads linked in the file.

## 1. B74c glossary `#g-design_world` (`docs/design/spec.md`, commit 1)

Old:

```markdown
<a id="g-design_world"></a>**`design_world`** — the shipped thin world (aircraft +
`SimpleAtmosphere(wind = NoWind())` + `HorizontalTerrain`) that mounts an
aircraft for trim and linearization. "Aircraft as root" is the shallowest
world, not a special case ([§14.9][s14-9]).
```

New:

```markdown
<a id="g-design_world"></a>**`design_world`** — the rig this design records for design-time
work, aircraft + `SimpleAtmosphere(wind = NoWind())` + `HorizontalTerrain`,
which mounts an aircraft for trim and linearization. `SimpleAtmosphere` and
`NoWind` are FlightPhysics' atmosphere types. "Aircraft as root" is the
shallowest world, not a special case ([§14.9][s14-9]).
```

## 2. B33a D-108 annotation

Old:

```markdown
**Rejected.**
- *Folding `MissingInit` into `ServiceLifecycle`:* distinct cases: a
```

New:

```markdown
Annotation (2026-10-20): the precondition the Position gives `capture` is
`checkpoint`'s since D-273 and D-274. `checkpoint(sim)` is legal in
`initialized` and `stopped`, and `linearize`'s default operating point is the
checkpoint of the simulation as it stands (D-274).

**Rejected.**
- *Folding `MissingInit` into `ServiceLifecycle`:* distinct cases: a
```

## 3. B34d D-139 annotation

Old:

```markdown
**Rejected.**
- *Widening the condition signature to `condition(d, baseline)` so the math
```

New:

```markdown
Annotation (2026-10-20): the by-name rejection of init as a third scheduled
sweep is D-064's; §14.2 never stated it.

**Rejected.**
- *Widening the condition signature to `condition(d, baseline)` so the math
```

## 4. B36a D-065 annotation

Old:

```markdown
**Rejected.**
- *Eager path concatenation in `at`:* strings and allocation on the hot path.
```

New:

```markdown
Annotation (2026-10-20): the earlier annotation's machine-checked concrete half
predates D-414. `:past_generic` retired from `PathResolution`, so a deep path
resolves wherever the structure has it, and the locality law for shipped
fragments and problems is authoring guidance, not a framework check (D-414).

**Rejected.**
- *Eager path concatenation in `at`:* strings and allocation on the hot path.
```

## 5. B41a D-095 annotation

Old:

```markdown
**Rejected.**
- *Bare-noun family:* `local(path, field)` is unparseable — reserved word,
```

New:

```markdown
Annotation (2026-10-20): the family §14.4 states has five members, `get_state`,
`get_deriv`, `get_output`, `get_input` and `get_face`. `get_local` retired from
it with `local_types` (D-165), and `get_slot` is spelled `get_input` since
D-206.

**Rejected.**
- *Bare-noun family:* `local(path, field)` is unparseable — reserved word,
```

## 6. B42 D-098 annotation

Old:

```markdown
**Rejected.**
- *Client-only validation:* [D-095][d-095]'s original "diagnostic readers admit the
```

New:

```markdown
Annotation (2026-10-20): `capture` reads `checkpoint` here. A checkpoint is a
distinct value with no condition algebra (D-273, D-274). Of the holders of live
stores, only the services' readers take a store selector (§14.4). No client
policy applies on top of the source rule, which is the resolver's, not a
client's (D-406).

**Rejected.**
- *Client-only validation:* [D-095][d-095]'s original "diagnostic readers admit the
```

## 7. B43 D-063 annotation

Old:

```markdown
**Rejected.**
- *Mirror-tree spelling:* a second structure artifact, ragged under partiality,
```

New:

```markdown
Annotation (2026-10-20): the warm-restart clause is retired. The cycle capture →
tweak → apply retires with `capture`'s condition form, and a resume is a
checkpoint and a restore (D-273). The overlay clauses stand.

**Rejected.**
- *Mirror-tree spelling:* a second structure artifact, ragged under partiality,
```

## 8. B47 D-409 annotation

Old:

```markdown
**Rejected.** None beyond [D-060][d-060]'s list.

```

New:

```markdown
Annotation (2026-10-20): the service half bears on the reads a run acts on, as
§13.5 frames the rejection. Since D-414 the locality law is authoring guidance,
not a framework check, and `get_face` remains the read for a consumer meant to
outlive the build.

**Rejected.** None beyond [D-060][d-060]'s list.

```

## 9. B50a D-149 annotation

Old:

```markdown
**Rejected.**
- *`probe_value`-filling the scratch slots:* the [§14.6][s14-6] ban stands — it would
```

New:

```markdown
Annotation (2026-10-20): the list lags the governing principle. Linearization's
operating condition under `about`, applied to its own fresh scratch, is a fourth
such application, and §14.6 and §14.10 name it.

**Rejected.**
- *`probe_value`-filling the scratch slots:* the [§14.6][s14-6] ban stands — it would
```

## 10. B51 D-122 annotation

Old:

```markdown
**Rejected.**
- *Renaming the entrenched owners instead:* condition algebra, write surface,
```

New:

```markdown
Annotation (2026-10-20): only `trim!` takes the `baseline` keyword now. The
clause held when written, the spec at `8e2505c` reading "the `baseline` keyword
`init!`/`trim!` take", and `init!` lost the keyword later.

**Rejected.**
- *Renaming the entrenched owners instead:* condition algebra, write surface,
```

## 11. B53a D-118 annotation

Old:

```markdown
**Rejected.**
- *Vector-returning residuals:* [§14.8][s14-8]'s failure reports name unbalanced
```

New:

```markdown
Annotation (2026-10-20): the field set closes at nine since D-262, which adds
`checks` and `check_tolerances`.

**Rejected.**
- *Vector-returning residuals:* [§14.8][s14-8]'s failure reports name unbalanced
```

## 12. B59b D-070 annotation

Old:

```markdown
**Rejected.**
- *External NLS packages:* heavy dep for ~100 lines; [§10.2][s10-2] stepper precedent;
```

New:

```markdown
Annotation (2026-10-20): the audit bullet's "reported" overstates the report.
Its `saturated` list names a decision only at its own bound, the first bullet's
saturated-at-solution flag. An in-model saturation is LM-tolerated and shows in
zero Jacobian columns, not in the report (§14.8).

**Rejected.**
- *External NLS packages:* heavy dep for ~100 lines; [§10.2][s10-2] stepper precedent;
```

## 13. B60 D-069 annotation

Old:

```markdown
**Rejected.**
- *Framework decision-variable supertype* (`AbstractTrimState`/`FieldVector`):
```

New:

```markdown
Annotation (2026-10-20): the reads are declared with the full read-selector
family since D-124, which calls the two-selector alternation a pre-D-095
straggler. The selectors carry D-095's `get_` prefix.

**Rejected.**
- *Framework decision-variable supertype* (`AbstractTrimState`/`FieldVector`):
```

## 14. B61a, R26 D-071 annotation

Old:

```markdown
**Rejected.**
- *World-level trim wrapper methods:* call-tree reuse: one method per
```

New:

```markdown
Annotation (2026-10-20): two bullets read stale. The build raises nothing for an
internally wired face; resolution refuses it with the producer named, as D-277
states for a face fed by a component. And no source ships a `design_world`; it
is the rig this design records for design-time work (§14.9).

**Rejected.**
- *World-level trim wrapper methods:* call-tree reuse: one method per
```

## 15. B62 D-072 annotation

Old:

```markdown
**Rejected.**
- *Four `FiniteDiff` jacobians:* step-size heuristics, ~4n evaluations,
```

New:

```markdown
Annotation (2026-10-20): the default operating point is the checkpoint of the
simulation as it stands (D-274), and `capture` no longer produces a condition
(D-273).

**Rejected.**
- *Four `FiniteDiff` jacobians:* step-size heuristics, ~4n evaluations,
```

## 16. B63a D-272 annotation

Old:

```markdown
what resolution refuses.
```

New:

```markdown
what resolution refuses.

Annotation (2026-10-20): the default operating point is the checkpoint of the
simulation as it stands (D-274), which carries its own time. `capture` no longer
produces a condition (D-273).
```

## 17. B70 D-068 annotation

Old:

```markdown
**Rejected.**
- *Face-declaration defaults:* condition data inside the wiring contract;
```

New:

```markdown
Annotation (2026-10-20): the commit is spelled
`override(baseline, condition(d*))`, the problem's condition at the solution, as
D-149's Rationale and the code spell it.

**Rejected.**
- *Face-declaration defaults:* condition data inside the wiring contract;
```

## 18. B36b D-065 Spec field

Old:

```markdown
**Spec.** [§6.1][s6-1], [§13.5][s13-5], [§14.2][s14-2]
```

New:

```markdown
**Spec.** [§6.1][s6-1], [§13.5][s13-5], [§14.2][s14-2], §14.3
```

## 19. B37 D-064 Spec field

Old:

```markdown
equilibrium constraint for the trim service.

**Spec.** [§14.2][s14-2]
```

New:

```markdown
equilibrium constraint for the trim service.

**Spec.** §14.1, [§14.2][s14-2]
```

## 20. B52 D-253 Spec field

Old:

```markdown
**Spec.** [§9.1][s9-1], [§9.2][s9-2], [§9.3][s9-3], [§9.4][s9-4], [§9.7][s9-7], [§13.3][s13-3], [§13.4][s13-4], [§13.7][s13-7], [§14.1][s14-1], [§14.4][s14-4]
```

New:

```markdown
**Spec.** [§9.1][s9-1], [§9.2][s9-2], [§9.3][s9-3], [§9.4][s9-4], [§9.7][s9-7], [§13.3][s13-3], [§13.4][s13-4], [§13.7][s13-7], §14.3, [§14.4][s14-4]
```

## 21. audit D-066 Spec field

Old:

```markdown
primitive family in the `Build`'s client kit.

**Spec.** [§9.5][s9-5], [§9.8][s9-8]
```

New:

```markdown
primitive family in the `Build`'s client kit.

**Spec.** [§9.5][s9-5], [§9.8][s9-8], §14.4
```

## 22. audit D-069 Spec field

Old:

```markdown
  ground static equilibrium as another problem value.

**Spec.** [§14.7][s14-7]
```

New:

```markdown
  ground static equilibrium as another problem value.

**Spec.** [§14.7][s14-7], §14.8
```

## 23. audit D-223 Spec field

Old:

```markdown
**Spec.** [§12.6][s12-6], [§13.4][s13-4]
```

New:

```markdown
**Spec.** [§12.6][s12-6], [§13.4][s13-4], §14.8
```

## 24. audit D-232 Spec field

Old:

```markdown
**Spec.** [§11.3][s11-3], [§13.6][s13-6], [Appendix B][sB]
```

New:

```markdown
**Spec.** [§11.3][s11-3], [§13.6][s13-6], §14, [Appendix B][sB]
```

## 25. audit D-273 Spec field

Old:

```markdown
**Spec.** [§12.6][s12-6], [§14.1][s14-1], [§14.5][s14-5], [§14.9][s14-9], [§14.10][s14-10], [Appendix B][sB]
```

New:

```markdown
**Spec.** [§12.6][s12-6], §14, [§14.1][s14-1], [§14.5][s14-5], §14.8, [§14.9][s14-9], [§14.10][s14-10], [Appendix B][sB]
```

## 26. audit D-277 Spec field

Old:

```markdown
**Spec.** [§13.3][s13-3], [§14.4][s14-4], [§14.9][s14-9], [§14.10][s14-10]
```

New:

```markdown
**Spec.** [§13.3][s13-3], [§14.4][s14-4], §14.7, [§14.9][s14-9], [§14.10][s14-10]
```

## 27. audit D-286 Spec field

Old:

```markdown
**Spec.** [§8.2][s8-2], [§9.5][s9-5]
```

New:

```markdown
**Spec.** [§8.2][s8-2], [§9.5][s9-5], §14.10
```

## 28. audit D-292 Spec field

Old:

```markdown
  tick's `s⁺` is invisible until the next tick decode.

**Spec.** [§5.3][s5-3], [§10.6][s10-6]
```

New:

```markdown
  tick's `s⁺` is invisible until the next tick decode.

**Spec.** [§5.3][s5-3], [§10.6][s10-6], §14.5
```

## 29. audit D-297 Spec field

Old:

```markdown
**Spec.** [§5.2][s5-2], [§8.1][s8-1], [§8.2][s8-2], [§8.3][s8-3], [§8.6][s8-6]
```

New:

```markdown
**Spec.** [§5.2][s5-2], [§8.1][s8-1], [§8.2][s8-2], [§8.3][s8-3], [§8.6][s8-6], §14.10
```

## 30. audit D-306 Spec field

Old:

```markdown
  races.

**Spec.** [§7.3][s7-3]
```

New:

```markdown
  races.

**Spec.** [§7.3][s7-3], §14.1
```

## 31. audit D-317 Spec field

Old:

```markdown
**Spec.** [§9.1][s9-1], [§9.2][s9-2], [§9.4][s9-4], [§11.5][s11-5], [§11.8][s11-8], [§12.1][s12-1], [§12.6][s12-6], [§13.4][s13-4], [§13.5][s13-5], [§14.5][s14-5], [Appendix C][sC]
```

New:

```markdown
**Spec.** [§9.1][s9-1], [§9.2][s9-2], [§9.4][s9-4], [§11.5][s11-5], [§11.8][s11-8], [§12.1][s12-1], [§12.6][s12-6], [§13.4][s13-4], [§13.5][s13-5], [§14.5][s14-5], §14.8,
[Appendix C][sC]
```

## 32. audit D-318 Spec field

Old:

```markdown
**Spec.** [§9.2][s9-2], [§12.6][s12-6], [Appendix C][sC]
```

New:

```markdown
**Spec.** [§9.2][s9-2], [§12.6][s12-6], §14, §14.8, [Appendix C][sC]
```

## 33. audit D-364 Spec field

Old:

```markdown
**Spec.** [§4.4][s4-4], [§8.2][s8-2], [§13.7][s13-7], [§14.9][s14-9]
```

New:

```markdown
**Spec.** [§4.4][s4-4], [§8.2][s8-2], [§13.7][s13-7], §14.1, [§14.9][s14-9]
```

## 34. audit D-376 Spec field

Old:

```markdown
entries nor face declarations carry root-input defaults.

**Spec.** [§11.3][s11-3]
```

New:

```markdown
entries nor face declarations carry root-input defaults.

**Spec.** [§11.3][s11-3], §14.6
```

## 35. audit D-406 Spec field

Old:

```markdown
**Spec.** [§11.2][s11-2], [§11.6][s11-6], [§13.3][s13-3], [§13.5][s13-5], [§14.4][s14-4], [§14.7][s14-7], [Appendix C][sC]
```

New:

```markdown
**Spec.** [§11.2][s11-2], [§11.6][s11-6], [§13.3][s13-3], [§13.5][s13-5], [§14.4][s14-4], [§14.7][s14-7], §14.8, §14.10, [Appendix C][sC]
```

## 36. audit D-407 Spec field

Old:

```markdown
**Spec.** [§11.2][s11-2], [§13.3][s13-3], [Appendix B][sB]
```

New:

```markdown
**Spec.** [§11.2][s11-2], [§13.3][s13-3], §14.4, [Appendix B][sB]
```

## 37. audit D-409 Spec field

Old:

```markdown
rule applied to reads.

**Spec.** [§13.5][s13-5]
```

New:

```markdown
rule applied to reads.

**Spec.** [§13.5][s13-5], §14.1
```

## 38. audit D-413 Spec field

Old:

```markdown
  reason `:range`, before the ignore list is read.

**Spec.** [§13.5][s13-5]
```

New:

```markdown
  reason `:range`, before the ignore list is read.

**Spec.** [§13.5][s13-5], §14.5
```

## Results

- Commits: `f0fc916` (edit 1, the glossary), `bc48aa9` (edits 2 to 38, the
  log). The battery passed before each: `linkify.jl`, `check_refs.jl`,
  `check_rows.jl`, `check_glossary.jl --strict`, `check_bold.jl`, then
  `linkify.jl` as a no-op. No rebaseline was needed.
- Spec field script: `scratch_track2/1/specfields.py`. Before: 29 pairs
  (`specfields_out.txt`). After: the 5 left by the plan (`specfields_after.txt`):
  D-026 §14.5, D-139 §14.8, D-237 §14.9, D-280 §14.8, D-316 §14.2.
- Declined: B69. D-213's Position rules the establishment round on a nominal
  scratch set; §14.10 states neither half. It points to §14.8's mechanism and
  gives the default point's frozen cells as the checkpoint's held cells,
  D-274's narrowing.
- Note: D-274's default-operating-point bullet is its sixth, not the fifth
  that `evidence_check.md` (B62, B63) and brief R25 call it. The annotations
  cite D-274 without a bullet number.
