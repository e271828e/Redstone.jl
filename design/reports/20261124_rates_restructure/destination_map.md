# Coordinator's report: destination map, outline, judgment calls

## Rates restructure of design/spec.md: report

The restructure is done and the full battery passes. Nothing is staged or committed, so the tree is dirty for review. Every §10.5 claim now lives at a destination below or is recorded as merged. src/, test/, examples/, reports/, increments/ and the RedstoneInspector.jl repo are untouched.

### 1. Destination map

**A (old §10.5, 6778–7028)**
- A-001–A-005 → §6.3, as the context paragraph. A-004 and A-005 are reworded as "three things", and §6.3 says it then works an example and covers coincidence and stagger.
- A-006 → merged → §3.2 C-073 ("Every discrete period is an integer multiple of a base tick period", D-019). It is the first statement in reading order, so the bold moved there.
- A-007 → §6.3. The harmonic grid is defined as "the rule of §3.2 that…", matching the glossary's "rule".
- A-008 → merged → §2.1 C-008 and §3.2 C-075.
- A-009–A-011 → §6.3.
- A-012–A-013 → merged → §2.1 C-029/C-030. The bold moved to C-029 ("A base tick at which no component is due is no boundary", D-445). §6.3 keeps a cited premise clause.
- A-014–A-015 → merged → §2.1 C-019 and C-031.
- A-016 → merged → §2.1 C-041/C-042.
- A-017–A-019 → §6.3. A-019 keeps its bold (D-185, D-291).
- A-020–A-021 → merged → §8.7 C-155/C-156 and §9.1's triple ruling. §6.3 keeps a pointer sentence (§8.7, §9.1, §9.2).
- A-022–A-027 → §6.3. The gate bold (D-185, D-291, D-479) went with them.
- A-028 → §10.5 ("The two sweep variants").
- A-029 → dropped as a pointer, replaced by the A-020 pointer.
- A-030–A-033 → §6.3 ("Due sets and the hold"). The ZOH bold (D-019) went with them.
- A-034–A-047 → §10.5 ("The two sweep variants"), with all three D-147 bolds.
- A-048–A-051 → §10.5 ("The due set at run time"), with the D-147 bold.
- A-052–A-055, A-057, A-058 → §6.3, as the due-set list for each kind of boundary.
- A-056, A-059 → §10.5. These are arity selection and why a modulo test on the last tick is wrong.
- A-060–A-062 → §6.3.
- A-063 → split. The law side goes to §6.3 ("No rule beyond the ordinary gate gives this due set"). The mechanism side goes to §10.5 ("Nothing implements the due set of boundary zero").
- A-064–A-065 → merged → §5.3 C-139/C-140. §6.3 keeps a pointer clause (§5.3, D-205).
- A-066 → §6.3, with "after `t₀`" added (see the findings).
- A-067 → merged → §2.2 ("Before its first tick… boundary zero"). §6.3 keeps a cited premise clause.
- A-068–A-073 → §6.3.
- A-074–A-122 → §10.5 ("Spans, steps and the clock"), unchanged.
- A-123–A-144 → §10.5, under a new subheading "Clock resolution and the last frame", unchanged.
- A-145–A-151 → §10.5, under a new subheading "A worked example", unchanged.
- A-152–A-156 (the same claims as B-001–B-005) → §6.3, last paragraph of "Due sets and the hold".
  - A-153 and A-154 are kept as short clauses that point to §5.3.
  - A-155 → merged → §5.3 C-129.
  - B-001's "settled machinery" now cites §5.3.

**B (old §10.5, 7020–7288)**
- B-006–B-010 → §6.3 ("Rate scopes and the two forms"), with the D-019 bold "An assembly is virtual for execution".
- B-011 → §8.7, merged with C-151.
- B-012–B-017 → §6.3: the meaning table, without default-value spelling. The D-185 bold goes with B-012. The clause "the wrapper type names the unit system" is also stated in §8.7.
- B-018–B-020 → §6.3 ("Coincidence and stagger").
- B-021–B-035 → §8.7 ("The two wrappers"). The bolds for D-469, D-459 (×2) and D-478 went with them.
- B-036–B-039 → §8.7. B-038 is merged with C-159.
- B-040 → merged → §8.7 C-160 ("Only multiplied, phased or anchored children need appear").
- B-041, B-043 → §8.7.
- B-042 → merged → the per-entry validity list in §9.1. §8.7 keeps a one-line summary.
- B-044–B-045 → §6.3.
- B-046 → merged into C-194 (D-478's general law) and stated in §6.3 as its instance with `j` the scope.
- B-047 → merged → §9.1's fold `Relative` row.
- B-048 → merged → §9.2's admissibility table.
- B-049–B-051, B-053 → §9.1, a new paragraph after the fold, with the D-459 bold.
- B-052 → merged → §9.1's D-465 trial paragraph.
- B-054–B-057 → §6.3 (residue induction).
- B-058–B-059 → merged → §9.1's triple bold (D-478) and §8.7 C-155/C-156.
- B-060 → merged → the gate in §6.3 and the boundary sweep in §10.5.
- B-061 → §10.5, beside A-028.
- B-062–B-065 → §8.7 ("What the declaration never holds"): the reason Relative is the default, and the fastest-member convention.
- B-066–B-069 → §6.3 ("Coincidence and stagger"), with the D-185/D-291 bold "A relative phase never refines the base grid".
- B-070–B-075, B-077–B-087 → §6.3 ("Anchors"), with the D-186 bold and the D-186/D-283 bold.
- B-076 → §8.7. The fastest-member convention is authoring, so §6.3 now says "Two corollaries".
- B-088–B-098 → §8.7 ("When an anchor belongs in a library type"), with both D-186/D-291 bolds.
- B-099–B-100 → §8.7. B-100's gloss is merged with the §8.7 bundle gloss.
- B-101–B-110 → §6.3 ("A worked example"), code kept.
- B-111–B-116 → §6.3.
- B-117–B-120 → §10.7, a new paragraph after the adaptive-cost paragraph. §6.3 keeps a one-line pointer.
- B-121–B-123 → §6.3.
- B-124–B-137 → §8.7 ("`Δt` in the bundle"), with the §5.2/D-019 bold.
- B-138–B-140 → §6.3, end of "Reference lattices and composition", with the D-185/D-291 bold.

**C (receiving passages)**
- C-001–C-063 stay.
  - C-010's pointer now cites §6.3.
  - C-029 is now bold.
  - C-039 still cites §10.5, where the clock refusal stays.
- C-064–C-101 stay. C-073 is now bold, and C-077's pointer now cites §6.3.
- C-102–C-114 stay. C-109 and C-114 now cite §6.3.
- C-115–C-120 stay. C-116/C-117 now cite §6.3.
- C-121–C-142 stay.
  - C-122 keeps its §10.5 citation, since the sweep variants live there.
  - C-128/C-129 now cite §10.6 ("Ticks after quiescence"), not §10.5.
- C-143–C-148 stay, and a §6.3 sentence is added.
- C-149–C-177 stay in §8.7.
  - C-150 is rewritten as the new list of parts.
  - C-153 now cites §6.3.
  - C-157 is dropped as merged: §8.7 now holds the wrappers itself.
  - C-159 and C-176 lose their §10.5 citations, which are now self-references.
  - C-171 now says "as the last part of this section states".
- C-178–C-189, C-192–C-195, C-198–C-200 → §6.3, with the D-478 bolds for notation, constraint and law.
- C-190–C-191 stay in §9.2. The bold "The spec and the framework's printed output always write the subscript" is now in §9.2's pointer paragraph.
- C-196–C-197 and C-201–C-202 stay in §9.2, inside the new pointer paragraph.

### 2. New outline (spec.md lines)

**§6.3 Rates down the hierarchy** (1877–2153)
- 1892: The base grid and the gate
- 1922: Due sets and the hold
- 1972: Rate scopes and the two forms
- 2000: Reference lattices and composition
- 2054: Anchors
- 2087: A worked example
- 2121: Coincidence and stagger

**§8.7 Rate scopes** (4317–4489)
- 4327: The declaration and its keys
- 4367: The two wrappers
- 4405: What the declaration never holds
- 4425: When an anchor belongs in a library type
- 4455: `Δt` in the bundle

**§10.5, retitled "Multi-rate execution: sweeps, spans and the clock"** (7159–7338)
- 7169: The two sweep variants
- 7200: The due set at run time
- 7217: Spans, steps and the clock
- 7287: Clock resolution and the last frame
- 7326: A worked example

**Other insertions**
- §9.1: composition-overflow paragraph at 4889.
- §9.2: the notation pointer paragraph at 5212.
- §10.7: the load-shaping paragraph at 7677.

**Roadmaps updated**
- Part I intro, §6 intro, Part III intro and §10 intro.
- The Contents block is generated by linkify and now includes 6.3 and the new 10.5 title.

### 3. Judgment calls

1. **Where a moved bold goes when Part I already states the law.**
   - Where the §2/§3 sentence is essentially verbatim, I deleted the §10.5 sentence and bolded the Part I one, by the "first in reading order keeps the bold" rule. That applies to A-006 (→ §3.2) and A-012/013 (→ §2.1).
   - Where the Part I sentence is a summary or consequence, §6.3 keeps the precise bolded statement and the summary stays unbolded:
     - the ZOH law A-030, against §2 and §3.2's "held zero-order";
     - A-019, against §3.3's "therefore ends with one period and one phase", which "therefore" demotes;
     - B-006, against §3.3's "flattened away for ordering".
   - The alternative was to bold the summaries throughout. That would put rulings on consequence clauses.
2. **"Keep one" where §6.3 needs a premise.** For local readability §6.3 keeps short cited premise clauses for A-012/013 (§2.1), A-067 (§2.2), A-064/065 (§5.3) and the simultaneous-ticks ordering (§5.3). They are unbolded. Each is recorded above as merged.
3. **Phase versus `Δt`.** B-139 ("an offset shifts firing instants, never the period") overlaps §5.2's "the component's phase never changes it". I kept both. §5.2 states it as a fact about the bundle, and §6.3 derives it from the seconds law and draws the stagger consequence. Dropping it from §6.3 was the alternative.
4. **Coincidence and stagger "wholly in Part I" against "load shaping may move to §10.7".** B-117–B-120 concern wall-time cost, not values, so they moved to §10.7, and §6.3 keeps a pointer. Everything that changes what a model computes stays in §6.3.
5. **D-478's printed-output rule (C-190/C-191) stays in §9.2.** It is a rule about spelling: printed output and struct field names. Part I's "meaning, not spelling" rule excludes that. The rest of the notation, the constraint and the law moved to §6.3.
6. **The fastest-member convention (B-064, B-076) is authoring, so it went to §8.7.** §6.3's D-186 corollary list therefore drops from three items to two, and §8.7 cites D-186 for the "relative members only" clause.
7. **Spelling versus meaning.**
   - §6.3's form table uses `Relative(D, Φ)` and `Absolute(Δt, τ)` as labels.
   - The defaults `= 0`, exact-number normalization, refusals and the wrapper-names-unit clause are in §8.7.
   - B-012's bold now reads "and its form names the unit system". The bold span itself is unchanged.
8. **Validation (B-041/B-042).** §9.1 already carries the bolded D-185 ruling and the list, so §8.7 keeps one summary sentence.
9. **Composition overflow (B-049–B-053) goes to §9.1, as asked.** B-052 is merged into the existing D-465 trial paragraph. B-053 is kept as one sentence that points to §9.2.
10. **Titles.** I chose "6.3 Rates down the hierarchy", which fits §6's hierarchy theme. §10.5 is retitled "Multi-rate execution: sweeps, spans and the clock".
11. **Sweep variants stay in §10.5.** §9.7 carries the arities but not how the variants run: RK stages and trial evaluations on the interior variant, and the macro-sequence on the boundary variant.
12. **Log `**Spec.**` fields.** For each entry that listed §10.5, the new field is computed from where that entry is now cited in the moved or kept text. Each field I touched is sorted numerically. I left alone:
    - the vocabulary-sweep lists (D-121, D-220, D-234, D-242, D-267, D-453), because §10.5 still uses their terms and I could not tie their entries to particular sentences;
    - D-133 and D-443, whose topics §10.5 still touches;
    - D-147, D-444, D-449, D-450, D-455–D-458 and D-460, which are still cited in the new §10.5.

### 4. Findings

1. **No entry states the fastest-member convention itself** (B-064: "a scope's base rate is its fastest relative member, which gets `Dₛ = 1`"). D-186 states only that the convention counts relative members only. Under spec_rules ("An unmarked sentence settles nothing") the log owes a Position for it.
2. **Code went stale, and I did not edit it.**
   - test/test_discrete.jl:2 quotes §10.5's old title, "Multi-rate tick scheduling".
   - Per citations_code.md, the diagnostics message strings cite "(§10.5)" for the `sample_times` constraints. These are src/diagnostics.jl 770 and 791–798, plus the matching expected texts in test/test_diagnostics.jl 840–852. Those constraints now live in §6.3/§8.7, and composition `:range` (diagnostics.jl:790) in §9.1.
   - The ten `# Design: … §10.5` pointers in src/library.jl and declare.jl:620/716 refer to the hold and due sets, which are now §6.3.
3. **"First tick at `Φ₀·Δt_base`"** (A-066). Read literally it is an absolute time, while it means an offset from `t₀`. I wrote "after `t₀`" in §6.3. §14.5 (spec ~13349) and Appendix A's "startup hole" item still say "at `Φ₀·Δt_base`".
4. **Log citations left at §10.5 on purpose.**
   - D-147:5724, D-194:7780 and D-316:14417: gating and the boundary sweep stay in §10.5.
   - D-471:20692: `Δt_unit` stays there too.
   - D-258:10875: the word "schedule" is used in both §6.3 and §10.5.
   - D-479:21219: "In §10.5 `n` was the base tick index and, a paragraph later, the step count" now spans two sections. The tick index is in §6.3 and the step count in §10.5. I left it because the claim is historical.
5. **Log citations re-pointed whose content moved or was removed.**
   - D-205:8229 ("§10.5's content defense"), D-186:7498 ("the superseded §10.5 clause") and D-464:20087 ("scope phase was already φ in §10.5") describe text that no longer exists. I pointed them to §6.3, where that topic now lives. Please confirm that reading.
   - D-133:4668 "§10.5's harmonic-grid check" now points to §9.2, where the check runs. Spec §10.4 (line ~7146) got the same change.
6. **No contradictions found** between the Part I summaries (§2.1, §2.2, §3.2, §3.3, §5.2, §5.3) and the old §10.5. That includes the §2.2 adaptive-step prose against §10.5's `⌈r / min(p, h_max)⌉` with its `⌊r / h_min⌋` cap: §2.2's "the floor wins" covers the cap.
7. **Part I depth exceptions the user ruled in.**
   - §6.3 carries `sample_times` code in the worked example.
   - It names the probe, the Schedule and the fold by name with pointers.
   - It cites `reports/20260812_sample_time_proposal/report.md`.
8. **Pre-existing long lines I did not touch.** These run past 80 rendered columns:
   - §8.7 line 4319, the intro's first line, which I left as it was;
   - §10.5 lines 7263 and 7269, carried over from the old text.

### 5. Citation re-pointing

**spec.md:** 96 §10.5 citations outside §10.5 before, 45 after. One of the 45 is the new pointer from §6.3 to §10.5.
- 52 were re-pointed or removed: to §6.3, §8.7, §2.1, §3.2, §9.1, §9.2 or §10.6. Five of them were in §8.7 and became self-references.
- The 44 old citations left in place point at content still in §10.5:
  - clock, spans, `h_max` and `Δt_unit` (§2.1:345, §9.2 several, §10.2, §10.4, §13.4, §13.x, §14.5, Appendices B and C);
  - sweep variants (§5.3:1405, §8.6:4270, §9.7 ×3, §10.3, §10.4, §13.x:11737, glossary "sweep");
  - due set fixed per iteration (§10.6:7583);
  - arity selection (§13.4:11438).
- Also re-pointed from §9.2 to §6.3 for the moved notation:
  - §9.1, twice: "states the subscripts" and "the composition law of";
  - the glossary "divisor" and "phase" entries.
- The glossary "due" entry now cites §6.3 and §10.5 for the due set.

**log.md:** 51 lines citing §10.5 before, 27 after.
- 14 `**Spec.**` fields drop §10.5, and 4 more gain §6.3 but keep it (D-185, D-258, D-445, D-479). D-291 and D-019 now list §6.3 and §8.7.
- 10 prose citations re-pointed:
  - D-133 → §9.2;
  - D-147:5767 ("un-sampling"), D-185:7411 (residue induction), D-186:7498, D-205:8229, D-316:14416, D-444:18702, D-445:18767 and D-464 → §6.3;
  - D-291's Position → "§6.3 and §8.7".

**Companions:** 8 re-pointed, all to §6.3: library_inventory ×2, pid_anti_windup, lqr_tracker, longitudinal_aircraft, frozen_discrete_walkthrough ×2, frame_walkthrough:321 and :378. frame_walkthrough:3, :77 and :168 stay at §10.5 because they describe execution.

**code_map.md:** 17 → 13 lines.
- 340 → §8.7.
- 555 → §8.7, §9.1, §9.2.
- 1386 → §9.1.
- The structure.jl Spec list swaps §10.5 for §6.3.
- The rest are clock or sweep material and stay.

**pending.md:** line 190 is now (§6.3, §9.2, §10.5).

### 6. Battery and diff

- `julia tools/linkify.jl`: run twice. The second run changed nothing, verified by md5 of spec, log and companions. Contents now has 115 entries.
- `check_refs.jl`: "OK — every citation and every anchor resolves." Its one advisory, on event_visibility_walkthrough §7, was there before.
- `check_rows.jl`: "OK — every decision citation names an existing entry."
- `check_glossary.jl --strict`: OK. It lists 3 advisory terms, all there before.
- `check_bold.jl`: "OK — every bold span in a rewritten chapter carries its D-citation." Chapter 6 now has 22 spans and 250 bold words.

Content audit:
- Every bold span from the old §10.5 and the old §9.2 notation passage occurs exactly once in the new spec. The two exceptions are A-006 and A-012, whose bolds now sit on their surviving §3.2 and §2.1 statements.
- D-citation counts in the old and new homes differ only by the merges listed above. Examples: one D-019 and one D-445 now live in §2.1/§3.2; one D-465 in §9.1's trial; D-283 in §8.7 C-155 and §9.1's fold.
- One glossary link, g-pacing, left the moved text. It went with B-118, and §10.7 already defines pacing.

```
 design/code_map.md                               |   10 +-
 design/companions/frame_walkthrough.md           |    7 +-
 design/companions/frozen_discrete_walkthrough.md |    6 +-
 design/companions/library_inventory.md           |    6 +-
 design/companions/longitudinal_aircraft.md       |    4 +-
 design/companions/lqr_tracker.md                 |    4 +-
 design/companions/pid_anti_windup.md             |    4 +-
 design/log.md                                    |   59 +-
 design/pending.md                                |    2 +-
 design/spec.md                                   | 1018 ++++++++++++----------
 10 files changed, 589 insertions(+), 531 deletions(-)
```

The untracked folder `design/reports/20261124_rates_restructure/` (the inputs) is unchanged.
