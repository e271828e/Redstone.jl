# Chapter 11, step 6b: final verification, half 1 (units A to D)

Base: `e16a63c`. Logs: `chapter_fixes_1.md` (51 entries), `ruled_edits.md`
(entries 1, 2, 9, 13 and 14). Scratch: `scratch_final/h1/`.

## Counts

- Edits checked: 55. That is 47 text edits and 3 inventory-only entries
  (9, 19, 31) from the fixer, the rewrap (entry 51), and 4 ruled edits
  (B-15, B-21, B-24 for C, RP-14). B-16 is a logged no-op, already applied
  by P1-5.
- Hunks: 73 word-level hunks in the whitespace-collapsed source (A 13, B 15,
  C 26, D 19). That falls to 70 in `show-new` text, because three hunks
  change only link markup (C 24, D 18).

## 1. Replay

Entries 1 to 50 applied in order, then the embedded `wrap.py`, then the ruled
edits. Every old block matched exactly once. A, B, C and D match the current
`new.md` byte for byte. No unlogged edit.

## 2. Meaning

Every hunk traces to its entry, and every entry traces to an EDITORIAL item
of `chapter_pass_1.md`, to RP-3, RP-4, RP-6 or RP-14, or to an Accepted batch
item. The logged deviations from the pass wording hold up. P1-2's "the lock"
keeps the antecedent. P1-34 keeps D-024 off harness-last, which is right,
because D-024 never mentions the harness cell. The P1-25 glosses outside
parentheses, and *snapshot* linked inside the boundary gloss, add nothing.
Bold changes are RP-3 and RP-4 verbatim, plus D's bold losing only its face
link. No term is linked twice in any unit.

Glosses checked against the frozen glossary: cell, port, face, batch (A, B,
C), root input, greedy claim, activation, probe, boundary, coalescing,
roster, harness writer (RP-9's text verbatim). All are faithful.

Added citations: D-096 at C's drains-last bold. D-096's Position (log 2955)
says "drained *last* at the frame top". Supported. `[§11.3]` in D is a
section pointer. No other citation added.

Problems:

1. **C, `chapter_fixes_1.md` entry 38 (P1-25, *boundary*).** Minor. A
   citation now covers more than its claim. The appositive gloss sits
   between the claim and its §12.7 pointer, so the pointer can read as the
   gloss's source.
   - Old: "continues from the interrupted boundary ([§12.7][s12-7])."
   - New: "continues from the interrupted [boundary](#g-boundary), a
     published consistency point ([§12.7][s12-7])."
   - Fix: "continues from the interrupted [boundary](#g-boundary)
     ([§12.7][s12-7]), a published consistency point."

Everything else in A, B, C and D: no problems.

## 3. Inventories

`check_unit.py ch11 check` prints `checks failed: 0` for all nine units
(A, B, C, D, F, G1, G2, H, J).

## 4. Wrap

No line in A to D runs over 80 rendered columns. No problems.

Cosmetic only: the B-15 ruled edit was wrapped by hand, so A's paragraph at
lines 89–98 is ragged. Line 94 ends at "continuous state," and the next
token, "[§9.4][s9-4]).", would fit on it. Fix: run `wrap.py apply` on A, and
log the run as a line-break-only rewrap.

## Outside scope

In `rulings_batch.md`, many `Status:` lines have the next `### B-n` heading
joined onto them (lines 50, 61, 69, … 338, 350). Those headings will not
render. The text of the items is intact.

`chapter_new.md` already carries the ruled edits, so it is not stale.

## Re-check (orchestrator touches 3 and 4)

The working-tree diffs of `units/A` and `units/C` (`new.md` and
`inventory.json`) match touches 3 and 4 exactly. Nothing else changed.
`check_unit.py ch11 check` prints `checks failed: 0` for A and for C.

- **Touch 3 (C).** §12.7 now covers only the claim that `run!` continues
  from the interrupted boundary. The gloss "a published consistency point"
  binds to *boundary*. C-114's `new` matches. No problems.
- **Touch 4 (A).** §9.4 now covers the claim that each `Simulation` owns its
  `Model`'s buffers, as in the old text ("owns its own buffers (§9.4)").
  C-041 and the `added` span match. No meaning problem. Style note: this puts
  two parentheticals in a row, "(the framework-owned … state) ([§9.4])". The
  pass cut that pattern at P1-27 and P1-33. Optional fix: "the `Model`'s
  [buffers](#g-buffer) ([§9.4][s9-4]), the framework-owned vectors backing
  continuous state." That is touch 3's shape.
- **Wrap.** No line runs over 80 rendered columns. Both paragraphs were
  wrapped by hand, so they are ragged. In C (lines 225–235), touch 3
  introduced it: line 234 renders 46 columns, and "consistency" would fit on
  it. In A (lines 89–98), it remains from B-15: "([§9.4][s9-4])." would fit
  on line 94. Fix: run `wrap.py apply` on A and C, and log each run as a
  line-break-only touch.
