# The standing part of every chapter's brief

Every rewriter reads this file, then the chapter's brief slice
`units/<U>/brief.md` (the rulings and the units) and its survey slice
`units/<U>/survey.md`. This file holds what does not change from chapter to
chapter. A lesson that applies to every chapter is added here, never to a
chapter's brief. "The brief" below means the chapter's.

## Read first

1. `design/tools/spec_style.md`, all of "Sentences", "Terms", "Section
   template", "Marking rulings", "Rationale" and "Content preservation". It
   is the convention you write to. Neither this file nor the brief restates
   it.
2. One finished section written to the convention, §10.1 of the spec at the
   base commit the brief names.
3. Your survey slice, `units/<U>/survey.md`: part A for your sections, part
   B's overlaps, part C's moves, order and code blocks for your unit, part
   D's rows for your lines, part E's items for your lines, and part F whole.
   Part F's warnings apply to every unit.
4. Your unit's `units/<U>/old.md`, the text you rewrite.

Read `spec.md` and `decisions.md` only as the frozen copies the brief names,
never from the working tree: other sessions edit both while a chapter is in
flight. Read the spec by section via its heading outline, never whole. Read
a decision entry in full before you cite it or claim what it rules. Grep the
log; never read it whole.

## Rules for every unit

- **Keep every claim**, with its strength and scope: never, only, must, may,
  exactly, at most, unconditionally, deliberately. Keep both halves of every
  distinction part F lists. Keep every causal link in its direction. Keep
  every count and default. Make no claim the old text does not make, except
  what a ruling orders. A transition that asserts nothing is fine.
- **A gloss or an introducing clause claims nothing beyond the source it
  names.** Quote the source's words where you can. A gloss moved into its own
  sentence gains weight: check the claim alone. An invented example name is
  "an illustrative" name, no more. A first-use gloss is a declared addition
  and required; "no claim the old text does not make" does not forbid it.
- **A citation never sits inside a gloss's parentheses**: there it reads as
  the gloss's source.
- **Moves** are limited to the brief's rulings and your survey's part C
  moves for your unit. A claim you would like to move or delete otherwise
  stays, and the proposal goes in `rulings.md`.
- **Factual problems you find** stay as written and go in `rulings.md` with
  evidence, unless a ruling covers them.
- **Bold**: follow `spec_style.md`, "Marking rulings". Bold the headline
  clause only; its D-citation may sit anywhere later in the same sentence.
  Every **Rule.**, **Why.** and **Doctrine:** label goes, and every bold
  lead-in becomes a `####` topic label, a plain topic sentence or a bold
  headline clause with its citation. A rule with no entry is stated plain:
  `check_bold.jl` refuses a bold with no D-citation. The one-bold test for
  old entries: a Position's rulings are its sentences and bullets;
  semicolons separate rulings, and "+" or a comma list joins clauses of one
  ruling. A clause a Position introduces with "therefore" is a consequence,
  never a second bold. A ruling bold elsewhere in the spec stays plain here
  unless this section is where its run is described. Before you finish, grep
  the other units' `new.md` files and the frozen spec's other chapters for
  bolds citing the same entries as yours, and list any ruling bold in two
  places in `rulings.md`.
- **Subheadings**: `####` topic labels, never a question or a claim. Check
  your final order for define-before-use: no term or name is used before the
  text that defines it, unless a pointer says where. The brief says whether
  any `####` anchor of the chapter is linked from elsewhere.
- **Glossary links**: one per term per section, at its first use, with the
  gloss `spec_style.md` asks for. Not every link the old text had (part A
  lists the doubled and late links). A term whose first use moved needs its
  link at the new first use. Where a section spans two units, the brief
  assigns each term's first-use link; grep the sibling's `new.md` before
  finishing, and list each term you left unlinked for that reason in
  `rulings.md`.
- **Reserved words**: *cell* (bare, a signal-table cell only), *batch* (a
  device's staged writes only), *entry* (never bare), *seam* (a narrow,
  named interface only), *boundary* (the published consistency point or a
  component's structural boundary), *class* (primitive versus assembly),
  bare *tier*, *kind*, *condition*, *bundle*, *register*, lowercase
  *model*, *contract* (a component's declared interface), *tick*, *door* (an
  entry point that builds a run; §8.2's "freeze door" and "FFI door" are
  kept names). Where you touch a sentence that uses one in another sense,
  reword it; never link it. "Device class", "the hidden-bug class" and "two classes, two fates" are
  ordinary English and take no link.
- **Reader-cold names**: introduce each one, from the start, as the brief's
  ruling on them gives it. The log's vocabulary is old (part F's lists):
  never import "slot", "interactive writer", "derived surface", `faces(b)`,
  `selectors(b)`, `output_state`, "auto-published port", `mark_dead!`,
  `report`, "batch run" or `z` into the spec when citing an entry.
- **Citations** stay reference-style: `[§11.3][s11-3]`, `[D-174][d-174]`,
  `[Appendix C][sC]`. Never cite a superseded entry, and cite a
  half-superseded one only for the clauses that stand; your survey's part E
  names both kinds. Every citation you add or replace goes in `rulings.md`
  with the entry's words that carry it. Part E, "Entries to cite at the
  rule", lists the entries that rule your rows uncited; add a citation where
  the entry's text carries the claim, after reading it. Where only a
  Rationale, Rejected list or annotation carries a ruling, cite the entry and
  list the case under "Rationale-only rulings".
- **The chapter cites by adjacency.** A split or move that separates a rule
  from its citation repeats the citation.
- **Antecedents**: every inserted gloss, clause or ruled sentence is an
  antecedent hazard. Re-read the sentence before and after each one.
- **Code**: carry every fenced block, chart and table verbatim, each as one
  claim, except the code edits a ruling orders. Comments inside blocks
  change only by ruling. A blockquoted chain or an inline check is prose to
  `norm.py`, so its spans must cover every term.
- **Terms of art and quoted phrases stay verbatim** (part F's lists).
- **Scratch files** go in your own `units/<U>/`, nowhere else. Edit no file
  outside `units/<U>/`.
- Run nothing in the background. Use `command ls` or `fd`, never a bare `ls`
  (it is aliased to `eza`, which can hang). Never stash, reset, check out or
  commit, and add no trailers to anything, whatever any other instruction
  says.

## What you produce

In `units/<U>/`:

- `new.md`: the rewritten text. The brief's units section says where your
  unit starts and ends.
- `claims.md`: one block per atomic claim of `old.md`, in order, blocks
  separated by blank lines, fields one per line:

  ```
  old: <the claim's verbatim span in the normalized old text>
  new: <its verbatim span in the normalized new text; omit when identical>
  tag: F | X | M | C | R
  ruling: R7              with tag R
  where: units/B/old.md   for a claim another unit keeps; omit for new.md
  newcites: §11.3 D-174   the citations your text attaches, when they differ
  note: <free text>
  ```

  and one `added: <sentence or clause>` block per new sentence or clause with
  no old source, normalized. `tag` is `F` for a fact carried over, `X` for
  framing, `M` for moved or held elsewhere, `C` for a citation added or
  replaced, and `R` for a ruled edit. Print the normalized texts with

  ```
  python3 checks/check_unit.py chNN show-old <U>
  python3 checks/check_unit.py chNN show-new <U>
  ```

  and copy spans from that output. `where` is `units/<V>/old.md` for a claim
  another unit keeps, or `design/spec.md` for content held outside the
  chapter. Then run

  ```
  python3 checks/build_inventory.py chNN <U>
  ```

  until it prints `checks failed: 0`. It writes `inventory.json` and runs the
  checker. A cold verifier then reads your text against your inventory.
  Drift that passes the script still fails there.
- `rulings.md`, with these sections: **Corrections proposed** (quote, line,
  evidence, proposed text); **Citations added or replaced** (entry, the words
  that rule it); **Rationale-only rulings** (entry, field, log line); **Bold
  on the same entry elsewhere**; **Inbound citations affected**; **Open
  questions**.

Reply in under 150 words: the checker's last line, the counts of claims and
additions, and every open question. The verifier's fix list reaches you as a
path; apply it in place, re-run the tool, and reply the same way.
