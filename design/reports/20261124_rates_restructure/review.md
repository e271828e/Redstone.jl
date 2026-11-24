# Independent review against the claim list

**Verdict: ready after the listed fixes.** All of them are small wording, citation or wrap fixes. No claim is missing and no new norm was found.

I edited, staged and committed nothing. `linkify.jl` was a no-op on both runs (md5 unchanged), and `git status` matches the snapshot.

## Findings, most severe first

1. **B-138 to B-140, spec.md:2050–2052 (§6.3, end of "Reference lattices and composition").** "...so the discretized laws are unaffected by staggering."
   - "the discretized laws" has no antecedent in §6.3. In HEAD it followed the "`Δt` in the bundle" discussion of PID and Tustin laws, which went to §8.7.
   - "staggering" comes before the "Coincidence and stagger" part that introduces it.
   - Fix: "An offset shifts firing instants and never the period, so a law discretized over `Δt` is unaffected by the phase."

2. **C-116, spec.md:1182–1184 (§5.2), mis-cited.** "`Δt` is the same in both output stages and in the update, and the component's phase never changes it ([§6.3], [D-019], [D-291])."
   - The first half's content (B-126, "the field arrives in `y_state`, `y_direct` and `s_update` alike") now lives in §8.7, not §6.3.
   - Fix: cite "([§6.3][s6-3], [§8.7][s8-7], [D-019][d-019], [D-291][d-291])".

3. **C-153, spec.md:4336–4338 (§8.7), broken antecedent.** The inserted B-011 sentence ("A discrete component or sub-assembly is scheduled by the entry its enclosing assembly gives it.") now sits between the code example and "These are the two forms that §6.3 defines". So "These" reads as pointing at "the entry".
   - Fix: "`Relative` and `Absolute` are the two forms that [§6.3][s6-3] defines ([D-185][d-185])."

4. **spec.md:4340 (§8.7), the anchor gloss disagrees with the glossary and §9.1.** The new gloss reads "(the lattice an `Absolute` entry establishes)". The glossary and §9.1 define the anchor as the exact `(Δt(a), τ(a))` pair.
   - Fix: "(the exact period and offset an `Absolute` entry establishes)".

5. **§6.3, spec.md:1964, term used without gloss or link.** "the boundary sequence already orders them" is the section's only use of the `g-boundary-sequence` term.
   - Fix: "the [boundary sequence](#g-boundary-sequence) (what the framework runs at each boundary) already orders them ([§5.3][s5-3])".

6. **§10.5, spec.md:7185 onward: `D₀` and `Φ₀` have no gloss or link in the section.** In HEAD the same section defined them earlier. Now `(n − Φ₀) % D₀` and "the gate" appear with neither `g-divisor` nor `g-phase` linked.
   - Fix: add to the first paragraph of "The two sweep variants": "A component's [divisor](#g-divisor) `D₀` and [phase](#g-phase) `Φ₀` are its period and offset in base ticks ([§6.3][s6-3])."
   - Lesser point in the same paragraph: the `g-sweep` link comes one sentence after "sweep variants" is first used in the bold sentence.

7. **§6.3, spec.md:2144: the `g-pacing` link and gloss left with B-118.** "A stagger also shapes the load of a paced run ([§10.7])" reads, but "paced" is unexplained. This is optional.
   - Fix: "A stagger also shapes the load of a run under real-time [pacing](#g-pacing) (waits inserted between completed frames, [§10.7][s10-7])."

8. **C-198, spec.md:2034–2037: "links the last two pairs" is now ambiguous.** The notation table it refers to is two paragraphs back.
   - Fix: "links the base-grid pair to the seconds pair, `Δt(i) = …`".

9. **Two new lines render past 80 columns.** Both should be rewrapped.
   - spec.md:142, Part I roadmap, renders at 84.
   - spec.md:16477, harmonic-grid glossary, renders at 83.
   - Lines 4319, 7263 and 7269 also run past 80, but they are pre-existing, as the coordinator said.

10. **Bold placement, a judgment to confirm rather than a defect.**
    - The A-006 move to §3.2 is correct under "first in reading order keeps the bold". So is the A-012/A-013 move to §2.1, whose bold now covers only the "no boundary" headline. That is fine: D-445's bullet is one ruling.
    - The coordinator's "verbatim vs summary" test for the others is defensible for A-019 against C-114, where "therefore" demotes C-114, and for B-006 against C-107, since "flattened away for ordering" is a narrower claim.
    - A-030 against C-093 (§3.2, "Those outputs are held zero-order between ticks ([D-019])", unbolded and earlier in reading order) is borderline. Both state the ZOH ruling. Under the mechanical rule, §3.2 would keep the bold. I would keep the current placement, since §6.3's sentence is the precise one. The user should know the rule was applied by judgment there.

11. **Log `**Spec.**` field, minor.** The coordinator rewrote D-283's field to "§6.3, §9.1, §9.2, Appendix B". D-283 is also cited in §8.7 (C-155), which was already the case in HEAD.
    - Fix: add §8.7 while the field is being touched.
    - D-452 is cited in §10.5 but its field lacks §10.5. That is pre-existing and untouched, so mention only.

12. **Optional consistency items.**
    - A-066's "after `t₀`" is correct and implied by A-009 and A-025. I accept it. §14.5 (spec 13350) and Appendix A's startup-hole item (14594) still say "at `Φ₀·Δt_base`". Add "after `t₀`" there too, or leave them as the coordinator did.
    - §10.4:7080 "The due sets of [§6.3] give the full reason": the modulo-test reason (A-059) is now in §10.5. Consider citing "§6.3 and §10.5".

13. **Stale §10.5 references outside the battery and outside `citations_docs.md`.** These are open items, not fixes to this diff.
    - `design/tools/coinage_inventory.md` rows 74, 77–79 (mandatory instant, floor, divisor, `Δt_unit`): the section lists omit §6.3 for divisor.
    - `design/tools/gloss_table.md` rows 291, 305, 306, 308, 309, 334 (bundle, pacing, phase, quiescence, schedule, boundary zero): the glosses now sit in §6.3 or §8.7.
    - `RedstoneInspector.jl/design/deployment_overlay.md:790` cites "§9.2, §10.5" for the timing notation, now in §6.3 and §8.7.
    - The code pointers are the coordinator's finding 2.

14. **A Part I completeness gap, pre-existing and not caused by the move.** A-121/A-122 say "The split follows the schedule, not the state" and that a `Dual` model takes the `Float64` model's steps (D-444). That is a law about which runs are equivalent, and Part I never states it. It lives only in §10.5. Worth a `pending.md` bullet, not a fix here.

15. **The coordinator's call 4.** Moving B-117–B-120 (load shaping) to §10.7 is consistent with Part I's depth rule, since it is wall-time cost and not values. Confirm with the user that the ruling "coincidence and stagger wholly in Part I" allowed it. The destination map quotes a "load shaping may move to §10.7" allowance I could not see.

## Per-check summary

**1. Claims.** I checked all 498 ids: A 156, B 140, C 202.
- Missing 0, weakened 0, strengthened 0, wrongly split 0, mis-cited 1 (C-116).
- Method: a sentence-survival script over HEAD's §10.5, §9.2 notation passage, §8.7, §9.1, §2.1–2.2, §3.2–3.3, §5.3 and §10.7 against the new spec. Every non-surviving sentence is accounted for by a mapped merge, an intended rewording or a citation change, and I read each one.
- I confirmed every merge target says the same:
  - A-006 → C-073;
  - A-008 → C-008 plus C-061 (covers `h_max`);
  - A-012/013 → C-029/030;
  - A-014/015 → C-019/031;
  - A-016 → C-041/042;
  - A-064/065 → C-139/140;
  - A-067 → §2.2:405;
  - A-155 → C-129;
  - B-040 → C-160;
  - B-042 → §9.1's list, which keeps "keys naming discrete or scope children";
  - B-047/048 → §9.1 fold row and §9.2 table;
  - B-052 → the D-465 paragraph;
  - B-058/059 → §9.1 and §8.7.
- D-citation counts in old against new homes differ only by the merges: D-019 −1, D-283 −2, D-449 −2, D-465 −1, D-445 −1 net, D-185 +1 (the arity-selection cite duplicated in §6.3 and §10.5), D-186 +1 (§8.7 convention), D-478 +1 (§9.2 pointer).
- Glossary links: only `g-pacing` left, with B-118. `dt_base`, `dt_frame` and `localized` were added.
- Wording issues outside these counts: B-138 (finding 1), C-153 (finding 3), C-198 (finding 8).

**2. New norms.** 0 unbacked rules.
- The admitted "after `t₀`" (A-066) is accepted.
- Unadmitted but backed additions, all accepted:
  - §6.3 "`Dₛ = 1` admits no stagger, since `0 ≤ Φₛ < Dₛ`": a reason drawn from the table.
  - §8.7 "since an anchored child may tick faster than its scope": constructive rationale from B-075.
  - §8.7 "the offset defaulting to zero": B-014/B-016.
  - §10.5's extension of arity selection to `t*`: backed by §10.4:6098 and D-147/D-288.
  - §6.3 "the boundary sequence already orders them (§5.3)": names B-001's "settled machinery", backed by C-125.

**3. Bold.** A multiset diff of all bold spans, HEAD against new, shows only the two intended moves (A-006 → §3.2, A-012 → §2.1), each with its D-citation in the same sentence. No superseded entry is cited; all 25 entries touched are ratified. One judgment call is noted (finding 10). The coordinator's finding 1 is confirmed: no Position states the fastest-member convention, and only D-186 (log:7455) states the "relative members only" part.

**4. Part I depth.**
- No violations beyond the accepted exceptions: the `sample_times` code, and the probe, `Schedule`, fold and constraint pool named by pointer.
- Spelling stays out of §6.3: defaults, `Rational{Int}`, refusals and printed-output subscripts are in §8.7 and §9.2.
- §6.3 reads without its forward citations.
- Terms used before introduction or without gloss: 3 (findings 1, 5, 7).

**5. Reading order.** §9.1 and §9.2 point back to §6.3 correctly. §3.2, §3.3, §5.2 and §5.3 point forward only as pointers. Defects: 2, the §8.7 antecedent (finding 3) and §10.5's unglossed `D₀`/`Φ₀` (finding 6). There is a mild order point in §6.3: `A₀` and `τ(a)` appear in the table and the proof before "Anchors" spells them out. The table row defines `A₀`, so it reads.

**6. Citations.** I checked all 111 spec rows of `citations_docs.md`, 51 log rows, 12 companion rows, 17 code_map rows and the 1 pending row.
- Mis-pointed: 1 (§5.2:1183, finding 2). Optional: 1 (§10.4:7080).
- Log findings 4 and 5: every prose re-point changes only the citation, which rule 2 requires to follow current numbering. I confirm the D-205:8229, D-186:7498 and D-464:20087 readings (§6.3 is where that topic now lives), and the D-133 → §9.2 re-point (the check runs there).
  - The left-alone ones are right: D-147:5724, D-194:7780, D-316:14417, D-471:20692 and D-258:10875. So is D-479:21219, since §10.5 still uses `n` as the tick index.
  - D-291's Position changed "§10.5 states" to "§6.3 and §8.7 state". The verb agreement change is forced by the split citation and is acceptable.
- `**Spec.**` fields: a script compared each field's §6.3, §8.7 and §10.5 against where the entry is actually cited.
  - The coordinator's edits all match the actual citation sites.
  - D-258 gaining §6.3 and §8.7 is vocabulary-based, the same way its field was built before, so I accept it.
  - Remaining mismatches are pre-existing: D-283/§8.7 (finding 11), D-452/§10.5, and the vocabulary lists D-121, D-234, D-242, D-453 and D-173, D-195, D-211.
  - D-133/§10.5 stays justified, since §10.5 mentions `localization_tol`.
- Out-of-battery stale references: finding 13.

**7. Style.**
- New lines over 80 rendered columns: 2 (finding 9). Pre-existing: 3.
- No em dashes in §6.3, §8.7 or §10.5. The one mid-sentence colon (7193) is pre-existing and is the spec_rules model sentence.
- One-burden lapses are minor, for example §6.3:1946 "It governs the updates alone, since every output stage publishes…". I would not change them.
- Gloss and link at first use: findings 5, 6, 7.

**8. Battery.** Run from `design/`: all OK.

## Battery output

```
linkify.jl (run 1): … contents: 115 entries — md5 of spec, log, companions unchanged (FIRST-RUN-NOOP)
linkify.jl (run 2): md5 unchanged (SECOND-RUN-NOOP)
check_refs.jl: total: 6769 citations, 2440 anchors, 11547 reference links
  self-vs-spec advisory: companions/event_visibility_walkthrough.md:19: §7 (pre-existing)
  OK — every citation and every anchor resolves.
check_rows.jl: newly cited by the spec (fine): [444 … 479]
  OK — every decision citation names an existing entry.
check_glossary.jl --strict: glossary: 208 entries; 3 advisory terms never matched (the letters, schema vs. layout, service lifecycle); OK
check_bold.jl: … chapter 10: 83 spans, 890 words … OK — every bold span in a rewritten chapter carries its D-citation.
git diff --stat: 10 files changed, 589 insertions(+), 531 deletions(-)  (unchanged from the start)
```
