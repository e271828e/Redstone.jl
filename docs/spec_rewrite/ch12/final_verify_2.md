# Chapter 12, step 6b: final verifier, half 2 (units F and G)

Verified commit `69a3191`, current commit `702ae15`. Scripts and scratch files
are in `scratch_final/h2/`.

## Counts

- Hunks (`git diff -U0 69a3191 702ae15`): 110. `units/F/new.md` 16,
  `units/G/new.md` 16, `units/F/claims.md` 41, `units/G/claims.md` 36,
  `units/G/deleted.md` 1 (new file). No commit after `509ea77` touches F or G
  except `702ae15`.
- Edits checked: 61 logged edits, 42 from `chapter_fixes_2.md` (36 edit and
  rewrap, 6 rewrap only) and 19 from `ruled_edits.md` (8 `new.md`, 10
  `claims.md`, 1 `deleted.md`). Also the fixer's 42 changed `claims.md`
  blocks, which have no entries of their own.
- Findings: 1, bookkeeping only. No finding touches the spec text.

## Replay

- `chapter_fixes_2.md` replayed on `69a3191`'s `new.md` files: all 42 old
  texts found exactly once, in order. The result equals `509ea77`'s
  `units/F/new.md` and `units/G/new.md` byte for byte.
- The F and G entries of `ruled_edits.md`, replayed on that result and on
  `509ea77`'s `claims.md` files: all 19 applied. The result equals `702ae15`'s
  `units/F/new.md`, `units/F/claims.md`, `units/G/new.md`,
  `units/G/claims.md` and `units/G/deleted.md` byte for byte.
- Every one of the 32 `new.md` hunks maps to a logged entry. No hunk is
  unlogged in `new.md`.
- `chapter_new.md` equals the four units concatenated, as `assemble.sh`
  builds it.

## Checks run

- `python3 checks/build_inventory.py ch12 <U>`: A, B, F and G each print
  `checks failed: 0`. B prints its standing line 561 note, unchanged. The
  regenerated `inventory.json` files are identical to the committed ones.
- Width: no line of `units/F/new.md` or `units/G/new.md` passes 80 rendered
  columns, backticks counted and link markup collapsed. Every rewrapped
  paragraph in both logs is filled. The three short lines are each followed
  by a link that would pass 80 columns.
- Glossary links: no anchor is linked twice in §12.5, §12.6 or §12.7. Every
  link an edit moved or added sits at the term's first use in its section:
  *checkpoint*, *executor*, *staging cell*, *harness writer*, *holding*,
  *sweep* (§12.5), *root-input totality*, *face*, *stop request* (§12.7).
- Bold: every bold in F and G has a D-citation in its sentence.

## The special checks

1. **B3** (F 355–356). "spawns a task for each whose `init!` succeeds
   ([§11.1][s11-1], [D-093][d-093])". §11.1 (frozen spec 6878–6880): "Which
   devices get a task is decided after initialization … A device whose
   `init!` failed gets no task". D-093's Position: "`run!` spawns one task per
   roster entry after per-run device `init!`". Its 2026-10-13 annotation says
   every rostered device runs on a spawned task since D-310, so the sentence
   is true and complete. D-093 carries the per-run respawn and §11.1 the
   exclusion, so each citation covers its part. Correct.
2. **B4** (F 313–319). `src/model.jl` 644–651: `restore!(model, model_state)`
   runs `_check_checkpoint!`, which pushes `CheckpointMismatch` for every
   fingerprint field. Its deployment walk, `_deployment_diff!` in
   `src/trace.jl` 181–184, pushes `CheckpointMismatch` with
   `what = :deployment`. `_check_grid!` pushes `CheckpointMidFrame`, and
   both are thrown as one. D-319 bullet 2: "checks the fingerprint and the
   grid. It collects every mismatch, `CheckpointMismatch` and
   `CheckpointMidFrame` alike, into one throw before any write". "Either
   kind" now has both antecedents. The paragraph-end D-319 citation covers
   the sentence by adjacency. Correct.
3. **B9** (G 84–92). `units/G/deleted.md` quotes the old sentence verbatim
   (old.md 84–85), and the claims block maps there with `ruling: B9`. The
   sentence said §13.4's pointer also halts at a frame top. The kept text
   still says it: `to_boundary` is "the consumer of the replay pointer" (G
   78), it takes the frame-entry boundary index (G 84), and "Replay therefore
   always halts at a frame top" (G 87–88). Only the self-comparison is lost.
   Correct.
4. **B7 and B8** (G 61–62, 102–103). "**the mode decides which source that
   one drain branch reads**" has its subject and verb, and D-218 follows in
   the same sentence. D-218's Position: "the one drain branch … is driven by
   that mode". "**`to_time` halts at the last frame top at or before the time
   given**" names its subject, and D-219 follows in the same sentence. D-219
   bullet 1: "`replay!(sim, trc; to_time)` halts at the last frame top at or
   before `to_time` … It is mutually exclusive with `to_boundary`". The old
   topic sentence's claim survives as the appositive "the same halt addressed
   by time" (claims.md, `ruling: B8`). No other bold in the chapter or the
   frozen spec cites D-218 or D-219 for these clauses. Correct.
5. **The fixer's logged departures.**
   - P2-8: "`feed` is described above." (F 112). R13's context sentence (F 98)
     holds the definition, and the claims block moves it there with tag M.
     The dropped context sentence on the two sources was an `added:` block,
     so no old claim goes. The body keeps the sources (F 200–203), now with
     the staging-cell link and gloss at first use. Sound.
   - P2-10: "to those of the [checkpoint](#g-checkpoint) (…)" (F 119–120)
     and the same gloss at G 38–40. The gloss matches the glossary entry: "the
     `Model`'s state at a frame top … beside the run's two counters, the
     frame index and the boundary ordinal". No earlier use in §12.6. Sound.
   - P2-11: "The clock of the [executor](#g-executor) (the compiled form of
     the stage execution order)" (F 124–125). This is the glossary's wording.
     The deleted sentence "The executor is the compiled form …" lives on as
     this gloss. Sound.
   - P2-25: the text is the proposal's own ("the gloss sits before the
     citation"), so there is no real departure. The gloss matches half 1's
     sense (B 212–213). Sound.
   - P2-26: the face link sits at its first use (G 56), inside the
     write-surface gloss. The face gloss follows as its own sentence (G 59),
     which is the glossary's wording. The old `added:` gloss sentence is the
     only text that goes, so no old claim goes. Sound. See note 1 for the
     write-surface gloss's wording.
   - P2-38: "the simulation's own clock runs, and its origin must equal the
     recording's" (G 245–246). The header claim stays at G 173–174 and G
     282–283, as the finding asked. Sound.

## Findings

1. **Unit F and G `claims.md`, the fixer's claims edits** (bookkeeping, not
   spec text).
   - The text: `chapter_fixes_2.md`, Notes: "each changed block's note names
     its finding as '(step 5, P2-N)'".
   - The problem: 11 changed non-`added:` blocks have no such note. In F they
     are the checkpoint-clock sentence (P2-10), the staging-cell gloss
     (P2-8), "§11.3 specifies the writer" (P2-16) and the *holding* gloss
     (P2-18). In G they are the checkpoint gloss (P2-10), the claims gloss
     (P2-26), the F68 range sentence (P2-28), the *localized* reorder
     (P2-30), the stop-request gloss (P2-31), "`to_time` is validated"
     (P2-33) and error reproduction (P2-35). The fixer's `claims.md` hunks
     also have no old and new text in the log, so a replay cannot rebuild
     them. Each block pairs with a logged `new.md` edit, and its spans pass
     `build_inventory.py`.
   - The fix: correct the Notes sentence to "most changed blocks", or add the
     missing "(step 5, P2-N)" notes.

## Notes, not findings

1. P2-26's write-surface gloss is "the bound on the faces a writer's batch
   entries may reach". The glossary says "the set of faces …". The gloss
   follows "write-surface rule", so as a gloss of the rule it is accurate and
   claims nothing new. It is the proposal's wording.
2. Two sentences now carry two gloss parentheticals: F 268–270 (stop request,
   holding; P2-18) and G 56–59 (write surface, claims; P2-26). `spec_style.md`
   allows one parenthetical per sentence. The verified text has the same
   pattern (F 57–60), and both follow their findings' proposals.
3. B3's sentence and the R5 pointer that follows it (F 355–361) both cite
   §11.1 on which devices get a task. The owner ruled B3's first form over
   the shorter alternative, so the overlap is the ruling's.
