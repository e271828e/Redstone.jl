# Chapter 12, step 6b: the final verifier, half 1 (units A and B)

Verified commit `69a3191`, current commit `702ae15`. Scratch files are in
`scratch_final/h1/`.

## Counts

- Hunks, `git diff -U0 69a3191 702ae15`: 110 in all. `A/new.md` 12,
  `B/new.md` 14, `A/claims.md` 41, `B/claims.md` 43.
- Edits checked: 117. `chapter_fixes_1.md` has 98 entries for A and B (39 in
  `new.md`, 59 in `claims.md`), P1-35 among them. `ruled_edits.md` has 19
  (9 in `new.md`, 10 in `claims.md`).
- Findings: 1.

## Replay

`scratch_final/h1/replay.py` applies each log's old and new text in order.
`chapter_fixes_1.md` on `69a3191` gives `509ea77`'s `A/new.md`, `A/claims.md`
and `B/claims.md` byte for byte. `B/new.md` differs only by P1-35, which is
logged as a description, not as text: drop the file's last empty line.
`ruled_edits.md` on `509ea77` then gives `702ae15`'s four files byte for
byte. The replay accounts for every hunk, and no hunk is unlogged.
`chapter_new.md` equals the assembled units. `inventory.json` was rebuilt
with no change.

`build_inventory.py ch12 <U>`: A, B, F and G each print `checks failed: 0`.
B also prints its standing note at line 561 (the C-122 span, `§13.5`).

## Special checks

1. **P1-23 and P1-24.** No claim is lost.
   - P1-23 drops the second D-198 citation. The citation still sits on the
     bold one sentence before, so it covers the extension sentence by
     adjacency. D-198's Rationale carries that sentence ("D-133's
     disposition for the semantic constants … reaches the join cap").
   - P1-24 drops "The run takes whole frames until the boundary time first
     covers the duration." Its claim stays in the bold ("the first grid
     boundary whose time reaches or exceeds `t_end`") and in "The run takes
     whole frames only". §12.6 keeps the same sentence for `t_plus`, and the
     pointer before the dropped sentence names it.
2. **B15.** "The tail's own owner" is lost. See finding 1.
3. **B20.** Confirmed. The text reads "a few fields on a separate atomic
   surface". "a" stays and only "scalar" goes.
4. **The stop word's gloss.** It agrees. §12.1 (A 39–40) and §12.4 (B 238–239)
   both read "the control plane's stop command, one atomic word holding its
   issuer", which is R15's wording. P1-17's "held in one atomic word" is
   reverted by the logged R15 edit.
5. **B19 and P2-42.** Both landed through P1-22 and P1-24.
   - B19: "Usage contexts legitimately differ in patience" (B 119). The
     wording is the one ruled, and nothing else in the sentence changes.
   - P2-42: the restatement is gone (B 92–94), as in item 1.

## Findings

**1. B, line 49–50, chapter 320–321 (step (5)): "the tail's own owner" is lost.** The
sentence now reads "It is a keyword of the `Simulation` constructor, held on
`Control` ([§12.1][s12-1]), a positive real …". B15 dropped "The cap lives on
`Control`, the tail's own owner". The chapter states nowhere else that
`Control` owns the tail:
- §12.1's bold (A 92) says only that `Control` keeps the tail's
  `join_timeout`.
- B 125's "therefore" gives the reason the cap is not on the `Deployment`,
  not the reason it is on `Control`.

D-256's Rationale carries the claim: "`join_timeout` is the shutdown tail's
parameter and the tail runs on `Control`". The fold also leaves "held on
`Control`" open to attaching to "the constructor". The ruled-edit log asks
the owner to confirm the drop. Fix: "held on `Control`, the tail's own owner
([§12.1][s12-1])", then rewrap the item. Or record that the owner accepts
the loss.

## Checked and sound

- Width: no line in a changed hunk runs past 80 rendered columns or is
  ragged. A 261's 82 columns are fixed. The code lines over 80 (A 224;
  B 158, 164, 171) are verbatim and older than these edits. B14's comment
  line is 78 columns.
- Glossary links: no anchor is linked twice in any section of A or B. Each
  new or moved link sits at its section's first use, with a gloss that
  matches the glossary:
  - `trace` in §12.1;
  - `log` in §12.3;
  - `frame` and `should_abort` in §12.4;
  - `snapshot` in §12.2, which by B16 is not the first use.

  The tail residue's gloss matches §12.4's "that last take is folded …
  as the tail residue" (frozen 8548–8549).
- Bold: B6's bold is on the clause that states the order, with D-114 later
  in the same sentence. No other bold changed.
- Reserved words: P1-26 removed the bare "entry". The edits add no reserved
  word in another sense.
- Citation scope: P1-20 moved the counter's `§10.1, §10.4` citations (A 210)
  to the sentence end. §10.4 separates boundaries from frames, so the wider
  scope holds.
- Not a finding: the parenthetical "(below)" and the snapshot gloss share one
  sentence at A 231–233. That was already so at `69a3191`.

## Re-check

This section checks orchestrator touch O-1 (`orchestrator_touches.md`),
which edited unit B, step (5), lines 49–60.

- **Claim:** sound. "Held on `Control`, the tail's own owner" restores the
  dropped appositive. D-256 carries it: its Position moves `join_timeout`
  into `Control`, and its Rationale says "the tail runs on `Control`".
  "It" still refers to the cap, and the appositive now ties "held on" to
  `Control`. In `claims.md`, both B15 claims and their `newcites` match the
  text.
- **Citation scope:** sound. The citation `([§12.1][s12-1], [D-256][d-256])`
  covers the clause only. D-256 also stays at B 125.
- **Checker:** `build_inventory.py ch12 B` prints `checks failed: 0`. The
  standing note on line 560 is unchanged (it was on line 561 before).

**R1. B 50–55: the rewrap does not fill to 80 rendered columns.**
- Line 50 ends at "([§12.1][s12-1]," at 63 rendered columns. "[D-256][d-256]),"
  (7 rendered) fits there, so the touch wrapped by source width, not
  rendered width.
- The touch's rewrap stops at "hang `run!`.". The item's next line, 55, was
  left as it stood and is now 81 columns with the bold markers counted.

Fix: rewrap the whole item, lines 49–60, at 80 rendered columns with link
markup collapsed. The result is 12 lines:

```
5. Join under the `join_timeout` cap. It is a keyword of the `Simulation`
   constructor, held on `Control`, the tail's own owner ([§12.1][s12-1], [D-256][d-256]), a
   positive real in seconds of wall clock, defaulting to 5 ([Appendix B][sB]). The
   constructor refuses any other value as `ArgumentInvalid`. A device task
   exceeding the cap is reported *by name* in a `DeviceJoinTimeout` diagnostic
   ([Appendix C][sC]). It is then abandoned rather than left to hang `run!`. **The
   diagnostic is written to the loop's own [diagnostic cell](#g-diagnostic-cell)**, a writer's own
   holding place for runtime diagnostics and liveness ([D-203][d-203]). The run's-end
   sweep, the loop's last pass over every diagnostic cell, collects the
   diagnostic into the [termination record](#g-termination-record) (the stopped-sim value naming how the
   run ended). The logging backend presents the diagnostic, with the terminal
   snapshot preceding the join ([D-201][d-201], [D-203][d-203]).
```

Then log the rewrap under O-1 and run `checks/assemble.sh`.
