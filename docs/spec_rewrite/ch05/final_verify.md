# Chapter 5: the final verifier (step 6b)

Diff: `git diff b2d2c1f 925a28b -- units/*/new.md`. Line numbers are
`chapter_new.md` lines at 925a28b. Base spec and log read at `b08afca`.

## Counts

- Hunks checked: 19 (A 4, B 1, C 4, D 4, E 4, F 2). They hold 65 logged
  changes: 34 edits (two of them finding 7's trailing-blank trims) and 31
  rewraps.
- Logged: 65 of 65. Replaying every Old→New entry of `chapter_fixes.md` in
  order on b2d2c1f reproduces all six `new.md` files at 925a28b byte for
  byte. No change is unlogged.
- Rewraps: all 31 change whitespace only (Old and New are equal once
  whitespace is normalized). A word-level diff shows content changes only
  where an edit entry logs them.
- Findings: 2.

## Findings

1. **L386, unit D, finding 14 (antecedent).** "The feedthrough graph carries
   the dependency." It now comes straight after "replay re-drives the
   ordinary loop from that trace". That sentence describes a dependency of
   its own (replay on the trace). The real referent, "Compensators consume
   gains as `u`" (L382), is now four sentences back. In the old text it was
   two. Fix: "The feedthrough graph carries the compensators' dependence on
   the gains."
2. **L496–498, unit E, finding 17 (antecedent, low).** "as a separate field
   of its [payload] (the structured data a diagnostic carries) rather than
   dotting it onto the path". The inserted gloss puts "a diagnostic" and
   "payload" between "the dead hop" and "it". Fix: "rather than dotting the
   hop onto the path".

## Checked, no finding

- **The three flagged spots.**
  - Finding 9 (L317): the log's line 7046 paraphrases §5.3 without quotation
    marks, and the phrase is not on survey part F's verbatim list.
    `frame_walkthrough.md` 93 already says "evaluating the right-hand side
    means running the sweep". The citation holds, and unit C's `rulings.md`
    records this.
  - Finding 23 (L635): D-140's Rejected list (log 4682) says "the branch
    taken at the probe point", and part F lists "probe point" as a term of
    art. The rename now matches the log.
  - Finding 14: finding 1 above.
- **Sources.**
  - R18, R19 and R20 match their rulings. R20's sentence matches D-015's
    Rejected item (log 607–608) and uses none of the log's old vocabulary.
  - The new glosses claim no more than their glossary entries: store,
    tier, cell, payload, feedthrough tracer, and boundary sweep against
    *sweep* and *due*.
  - Finding 19's revision, "one way to insert dynamics", follows unit E's
    verifier (C-054): the α-filter idiom is not the only route.
  - Finding 22 drops D-245 from "either mode", as the finding ordered. The
    claim keeps its citation at the bold two paragraphs on (L644).
  - Finding 24's D-140 moves onto the ladder sentence. The old text cited
    only the §5.4 pointer there.
  - Findings 4 (view) and 11 (continuous component) link with no gloss, as
    their findings ordered.
- **Whole chapter.**
  - `chapter_new.md` equals the assembled units.
  - No glossary anchor is linked twice in any section, and each new link
    sits at its term's first prose use in its section.
  - The chapter has 25 bolds. Each one has its D-citation in its sentence,
    and no ruling is bold twice. The fixes touched no bold span except
    finding 11's link.
  - The three fences are byte-identical to `chapter_old.md`.
  - No prose line runs past 80 rendered columns. Unit B's `u` table row is
    carried as written.
  - `check_unit.py ch05 check` prints `checks failed: 0` for A to F.

## Re-check

I checked the fixes against `git diff 925a28b -- units/*/new.md`. Only units
D and E changed, with one hunk each. Both edits are logged under "Final verify
fixes" in `chapter_fixes.md`.

- **Finding 1 holds.** L386 now reads "The feedthrough graph carries the
  compensators' dependence on the gains." It names the referent from L382
  and adds no claim.
- **Finding 2 holds.** The sentence now reads "rather than dotting the hop
  onto the path". It keeps the old claim, that the dead hop is a separate
  payload field and not a dotted path. The citation split is unchanged:
  D-245 on the dead hop, §8.6 and §13.2 on the path. The payload gloss
  matches glossary 13683 ("the structured data a diagnostic carries").
- **Rewraps.** A word-level diff shows only the two edits. Both rewraps
  change whitespace only.
- **Nothing else changed.** Outside the two `new.md` files, only
  `chapter_new.md` and the D and E inventories changed. `chapter_new.md`
  equals the assembled units.
- **Whole chapter.** The fences are still byte-identical to
  `chapter_old.md`. No prose line runs past 80 rendered columns.
  `check_unit.py ch05 check` prints `checks failed: 0` for A to F.

Re-check findings: 0.
