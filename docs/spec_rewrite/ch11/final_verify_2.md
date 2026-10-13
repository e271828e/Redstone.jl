# Chapter 11, step 6b: final verification, half 2 (F, G1, G2, H, J)

Base `e16a63c`, head `95393c6`. Scratch files are in `scratch_final/h2/`
(`replay.py`, `cmp.py`, `wd.py`, `norm/`).

Counts: 51 edits checked. That is 42 from `chapter_fixes_2.md` and 9 ruled
edits (`ruled_edits.md` entries 3 to 8 and 10 to 12). The normalized word
diff has 80 hunks: F 23, G1 17, G2 7, H 16 and J 17. There are also 5 bold
changes and 1 code-block change.

## 1. Replay: no problems

- Fixes 1 to 40 and 42 each hit exactly once on `e16a63c`. Edit 40 is a
  verbatim match.
- The replayed text matches `c3d69f1` token for token in all five units. The
  normalized paragraphs (`show-new`) are identical, and so are the fenced
  blocks, headings and table rows. Edit 41 changes whitespace only.
- The ruled edits, applied verbatim to `c3d69f1`, give the current `new.md`
  of all five units byte for byte. Ruled entry 5's one-word old block
  ("dead.") hits once.
- No unlogged edit.

## 2. Meaning

Every hunk traces to its item: P2-1, P2-6 to P2-23 (except P2-16, whose only
change is a heading), P2-27 and P2-28, RP-8 to RP-13, and B-18 to B-20 and
B-22 to B-24. Strength, scope, quantifiers and causal links match what each
item orders.

- The two scope changes are ordered: J's "per writer per boundary" → "per
  diagnostic cell per frame" (B-18), and J L14's D-200 moving inside the
  gloss (P2-22).
- J's "so … So" → "Because … therefore" keeps both causal links (P2-21).
- Edit 42, "That" → "The recording", restores the old antecedent of
  "That", which was the recording.
- **Glosses.** Each new or moved gloss agrees with its frozen glossary entry
  (spec 13342 to 14065): drain, batch, staging cell, diagnostic cell, frame,
  component, claim, greedy claim, root input, roster and `Run`. The roster's
  "attached devices" is P2-23's ordered text.
- **Citations.** Each added citation is checked in the frozen log:
  - D-317 bullet 5 (13616)
  - D-240 (9129)
  - D-193 (7075)
  - D-241 (9153)
  - D-270 bullet 1 (11162)
  - D-177 (6472)
  - D-310 (bridge, 13052)
  - §12.6's doors (spec 9047, 9054)

  Every new link reference has a definition.
- **Bolds.**
  - The three bolds B-20 adds match their Positions: D-200's second
    sentence (7360), D-240 and D-241. Each has a D-citation in its sentence.
  - The RP-11 and RP-13 bolds read exactly as ruled.
  - Edit 36 drops only the link inside J's "Each writer has one diagnostic
    cell".
- **Code blocks.** All are byte-identical to `e16a63c`, except G1's RP-12
  split. Both `#` signs of the split sit at column 46.

Two optional readability notes. Neither changes meaning.

- **F, edit 6 (P2-7).** Old: "about one [binding](#g-binding) (the value
  passed at `attach!` that makes a device framework-legible), not about a
  category of writers". New: "…[binding](#g-binding), the value passed at
  `attach!` that makes a device framework-legible, not about a category of
  writers". The appositive now runs straight into the "not about" contrast.
  P2-7 did not order this change. The fixer chose it to keep one
  parenthetical per sentence. Fix, if wanted: end at "one binding, not about
  a category of writers", and add "A binding is the value passed at
  `attach!` that makes a device framework-legible."
- **H, edit 32 (P2-20).** New: "The bridge is the link to the simulation,
  and [D-310][d-310] leaves its design open." The fixer left the pass's text
  because "whose" could bind to "the simulation". "its" has a weaker form of
  the same problem. Fix: "leaves the bridge's design open". This needs no
  inventory change beyond the `added` span.

## 3. Inventories: no problems

`check_unit.py ch11 check` prints `checks failed: 0` for all nine units (A,
B, C, D, F, G1, G2, H and J). No word lacks a claim or an addition.

## 4. Wrap: no problems

With link markup collapsed across line breaks, the widest prose line is 80
columns in each of F, G1, G2, H and J. No line starts with a new list or
heading marker except G1's "#### The failure policy" (P2-16).

## Re-check: orchestrator touches 5 and 6

- **Log and text.** The normalized `show-new` diffs for F and H show exactly
  the text the log gives, and nothing else. Each inventory span changed to
  match. `check_unit.py ch11 check` prints `checks failed: 0` for F and H.
- **Antecedents and gloss.** Both are clean. F's new gloss, "A binding is the
  value passed at `attach!` that makes a device framework-legible", is the
  glossary's wording (spec 13943). F's "not about a category of writers"
  contrasts with "about one binding" again. H's "the bridge's design" leaves
  no doubt about what D-310 leaves open.
- **Wrap: one problem.** H L188 is 98 columns. It reads "a child component,
  and the widgets. Its constraints are fixed here. Panels name their own
  ports by". The rewrap stopped partway through the paragraph. Fix: refill
  H's paragraph from L186 to its end.
- **Wrap, underfilled.** F L25 to L27 are not filled greedily. L27,
  "framework-legible. A [greedy", is 27 columns. H L186 is 64 columns. Fix:
  refill F's paragraph from L24 and H's from L186.
