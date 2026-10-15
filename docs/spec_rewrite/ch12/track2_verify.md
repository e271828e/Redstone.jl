# Chapter 12, track 2: cold verification

Commits 54779c2, d19fe88 and c31dea1, against `track2_log_1.md`,
`track2_log_2.md`, `rulings_batch.md`, `evidence_check.md` (N1), the brief's
R8 and R15, `escalations.md` and `owner_items.md`. Each source entry was read
in full in `decisions.md` at the commit's parent. Lines are tip (45f5047)
lines unless stated. Working notes: `scratch_track2/verify/fork_a.md` to
`fork_f.md`.

## Counts

- 54779c2: 3 hunks, 3 log entries (E1–E3, B81 no edit). Findings 0.
- d19fe88: 37 hunks, 37 log entries (L1–L37). 14 removed lines, all
  **Spec.** lines; no Position, Rationale, Rejected or title line edited.
  15 Spec-field edits checked, all sorted, each naming a section that states
  or cites the ruling; D-200's §12.6 rightly left out. 23 annotations
  checked, placement as logged. Findings 3, none firm.
- c31dea1: `decisions.md` 3 hunks (17 Index rows, the entries block equal to
  log 2 part 1 once delinkified, 17 link definitions); `spec.md` 30 hunks
  (C1–C37, the nine-line rewrap, link definitions). Word diff: citations
  only, no bold or wording change; no chapter 12 line over 80 rendered
  columns. 17 entries, 34 Position rulings. 37 citations; none inside a
  gloss's parentheses, none at an E1, E2 or owner-item clause. Findings 9
  (1 firm, 8 judgment).
- Log (f22cb9d): 1 finding.
- E1, E2 and owner items: no new entry, annotation or citation states one.
- Glossary *stop word*: R15's wording verbatim ("the control plane's stop
  command, one atomic word holding its issuer"), with the §12.1 pointer and
  the *stop request* note B79 asked for. No finding.
- Battery on the tip, each tool run once: `check_refs.jl` OK;
  `check_rows.jl` OK; `check_glossary.jl --strict` OK (174 entries);
  `check_bold.jl` OK (chapter 12: 65 spans, 596 words).
- Findings: 13 in all, 1 firm.

## Findings

### 1. D-397 restates D-218's Position (firm; lessons 42 and 43)

- c31dea1, `docs/design/decisions.md` 15798.
- Text: "The input mode outlives the `replay!` call, so after a partial
  replay the recording still has a consumer, and the next `step!`
  re-executes the following frame on its recorded inputs."
- Problem: D-218's Position already rules it. Bullet 1 says "`step!` and
  `run!` consume it frame by frame from there", and bullet 3 says the mode
  "stays `:replay` otherwise". The re-execution clause comes from D-218's
  Rationale, which takes it from "[§13.4] promises …". That source cites the
  spec back, so log 2's lesson 43 line is wrong for this entry.
- Fix: drop D-397 with its Index row and link definition, and cite D-218
  alone at spec 9638.

### 2. D-399 bullet 2 restates two Positions (judgment)

- c31dea1, `decisions.md` 15839–15841.
- Text: "The placeholder run gives every accessor a run to read, and the
  lifecycle state says whether it started."
- Problem: D-255's Position ("constructed with a placeholder run …
  `Control.lifecycle` says whether it started") and D-261's ("The
  placeholder an accessor needs is the one exception") state it. Only
  "never `nothing`" is Rationale-only.
- Fix: cut the bullet to "The simulation's run field is never `nothing`."

### 3. D-399 bullet 1 is a reason whose ruling a Position states (judgment)

- c31dea1, `decisions.md` 15838.
- Text: "The control plane is what anyone may poke, and a run's outcome is
  not."
- Problem: this is the reason D-255's Rejected list gives. D-255's Position
  already rules "`termination` leaves `Control`". Log 2 drops such reasons
  elsewhere (B66, B68, B75).
- Fix: drop the bullet and keep D-255 as the citation at spec 8683.

### 4. D-398 follows from D-219's Position (judgment)

- c31dea1, `decisions.md` 15818.
- Text: "After `live!` the trace keeps the header it inherited, so the
  frames flown after the call append to the re-recorded prefix".
- Problem: D-219 bullet 2 has `live!` "touching nothing else", as D-398's
  own Rationale says. Log 2 dropped a consequence of the same kind from
  D-397 ("follows from bullet 3").
- Fix: drop D-398 and cite D-219 at spec 9701, or record why it differs
  from the dropped case.

### 5. D-400 follows from D-261's Position (judgment)

- c31dea1, `decisions.md` 15859.
- Text: "Recording is per run: a long untraced run and then a short traced
  one may share one simulation."
- Problem: D-261 bullet 7 makes the recording keywords keywords of the
  doors that build a run. D-400's Rationale says per-run recording "comes
  with that move".
- Fix: drop D-400 and cite D-261 at spec 9305, or keep it on the grounds
  recorded for finding 4.

### 6. D-396 bullet 1's first clause restates D-138's Position (judgment, minor)

- c31dea1, `decisions.md` 15764.
- Text: "The failure is reported as the ordinary `DeviceCrash`, with no
  diagnostic kind of its own."
- Problem: D-138's Position "reports `DeviceCrash` by name". Only "no
  diagnostic kind of its own" is Rationale-only.
- Fix: "An init failure gets no diagnostic kind of its own."

### 7. D-386 accounts for the wrong dropped clause (judgment)

- c31dea1, `decisions.md` 15550; `track2_log_2.md` 17.
- Text: "The spin's rule is not restated, because [D-027]'s Position states
  it."
- Problem: B42 is UNCONFIRMED. Its correction says the new clause covers
  "only the monopolist and the spin's reason" (µs precision traded for
  scheduler noise, D-027 Rejected). D-386 leaves the reason out and gives the
  spin's rule as the dropped clause, which the correction had already set
  aside.
- Fix: in both places, give the dropped clause as "the spin's reason, a
  reason and not a ruling, which D-027's Rejected list keeps".

### 8. D-392's Position goes beyond its named source's words (judgment)

- c31dea1, `decisions.md` 15674.
- Text: "The thread budget is checked once per run, against the frozen
  roster, and never re-checked per attach."
- Problem: the Rationale names D-106's Rejected list as the source. That list
  records only the rejected per-attach re-checks. "Once per run, against
  the frozen roster" combines D-027's "startup warning" with D-106's freeze.
  Both are Positions already, so that half restates no Rationale-only words.
- Fix: cut the Position to "The thread budget is never re-checked per
  attach."

### 9. C22 cites D-390 at D-096's sentence (judgment)

- c31dea1, `docs/design/spec.md` 9451.
- Text: "Advance-assert-advance is `stage!` → `step!` → `latest`
  ([D-096][d-096], [D-390][d-390])."
- Problem: D-390 bullet 1 rules the read half. The sentences that state it,
  "The read half is `latest(sim)`. It hands back the same immutable snapshot
  value …", stay uncited.
- Fix: move D-390 to the end of "… navigated directly for assertions."

### 10. D-138's annotation departs from R8 (judgment)

- d19fe88, `decisions.md` 4777–4787.
- Text: "so the Rationale's boundary-zero clauses read at the run's start
  … ends `stopped` where it started, its terminal snapshot the one it
  started from."
- Problem: R8 drops "boundary zero is published" and §13.5's
  terminal-at-`t₀` path as the mechanism. The blanket rule maps them onto
  the run's start instead. R8 ends the clause "its termination record naming
  the device". The annotation's "its terminal snapshot the one it started
  from" is in neither R8 nor any entry.
- Fix: end the clause "its termination record naming the device", and add
  "The Rationale's 'boundary zero is published' and its §13.5
  terminal-at-`t₀` path are historical."

### 11. D-198's annotation changes the spec's case (minor)

- d19fe88, `decisions.md` 7536–7537.
- Text: "[§12.4] says "usage contexts"."
- Problem: spec 8978 reads "Usage contexts legitimately differ in patience".
- Fix: quote "Usage contexts", or drop the quotation marks.

### 12. D-268's annotation names a clause its evidence does not record (judgment, minor)

- d19fe88, `decisions.md` 11313–11314.
- Text: "the stop faces of the second bullet and the Rationale are stop
  requests since [D-316]."
- Problem: B72's evidence records "stop face" in bullet 2 only. The
  Rationale's "where the stop faces are read" is true under D-316, but no
  evidence lists it, and the Rejected item "over a holding face" goes
  unnamed.
- Fix: drop "and the Rationale", or record the Rationale clause in B72's
  evidence.

### 13. A fence fused onto a heading line in log 1

- f22cb9d, `docs/spec_rewrite/ch12/track2_log_1.md` 643 and 657.
- Text: "### D-256 — ```"
- Problem: L31's Old and New blocks close their fence on the line of a
  truncated D-256 heading. The fence never closes, so the rest of the log
  renders with code and prose swapped. The raw strings are still right.
- Fix: put each closing fence on its own line, and note that the matched
  text ends with "### D-256 — ", trailing space included.

## Notes, no fix in these commits

- D-223 bullet 1 ("`replay!` of the captured header reproduces either
  failure") is stale under D-274's last bullet. No item records it, so it
  goes to the owner.
- D-274's Position §13.7 was wrong when the entry was written (c39a37d), not
  left over from a renumbering. Annotating it while correcting the Spec field
  in place is right.

## Re-check of 025f78a

`git diff 45f5047 025f78a`, against `track2_log_2.md` "Review fixes" (R1–R26)
and the working-tree edits to `track2_log_1.md` (R24, R25) and log 2's B42
row (R11).

- Hunks: `decisions.md` 11, `spec.md` 12. Every one is covered by R1–R23 or
  R26, or is an Index row or link definition `linkify.jl` regenerated. The
  log 1 fences (R24, R25) and the B42 row (R11) match the log and are not in
  the commit, as the log says.
- Fixes: findings 1 to 13 are each applied as asked. Findings 4 and 5 took
  their drop option. Finding 8 also retitled D-392 (R26).
- Old numbers: no citation of D-400 to D-402 is left anywhere outside the
  logs and scratch. Each D-397 to D-399 citation in `spec.md` names the
  renumbered entry whose Position it states: 9330 → D-397; 8655, 9155,
  9178 → D-398; 9616, 9856 → D-399. `recipe.md` 894's "D-386 to D-399" is
  current.
- New citations: D-390 at spec 9450 and D-219 at 9701 sit outside any
  gloss's parentheses, at sentences that state the ruling. No bold changed,
  and no edited line goes past 80 rendered columns.
- Titles: D-392 and D-397 match their cut Positions. The D-386, D-396 and
  D-398 to D-399 titles still fit.
- Battery on 025f78a, each tool run once: `check_refs.jl` OK;
  `check_rows.jl` OK; `check_glossary.jl --strict` OK; `check_bold.jl` OK
  (chapter 12: 65 spans, 596 words).
- Findings: 2.

### R1. D-396 bullet 1's "Its" lost its antecedent

- 025f78a, `docs/design/decisions.md` 15761–15762.
- Text: "An init failure gets no diagnostic kind of its own. Its payload and
  disposition already fit."
- Problem: "Its" meant `DeviceCrash`, which the cut removed. It now reads as
  the init failure's payload. The source, D-138's Rejected list, reads
  "`DeviceCrash`'s payload and …".
- Fix: "`DeviceCrash`'s payload and disposition already fit."

### R2. Log 2 names the commit from before the amend

- Working tree, `docs/spec_rewrite/ch12/track2_log_2.md` 1035 and 1053–1055.
- Text: "one commit, `9d66d54`", and "D-392's title still reads … finding 8
  did not touch it."
- Problem: the amend replaced 9d66d54 with 025f78a, and R26 retitled D-392.
  R26 records both, but the header still contradicts it.
- Fix: write `025f78a` in the header, and drop the D-392 title sentence.

Note: D-397's Rationale keeps "The source's `Control.lifecycle` is
`lifecycle(sim)` since D-317". The cut Position no longer uses that clause,
but the Rejected item's "the lifecycle" still does, so the clause stands.
