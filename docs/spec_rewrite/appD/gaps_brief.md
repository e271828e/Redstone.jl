# Appendix D: the gap sweep brief

The second check of `../appendices.md`, "Appendix D: citations, gaps and
length": terms the rewritten chapters define with no glossary entry. This
brief is what each read-only sweep agent reads. One agent takes one range
of chapters and returns one TSV of candidates. The orchestrator decides
which become entries.

## Base and files

Base commit `4004522`. Read the frozen copies under `<F>`, the directory
the launch prompt names, never the working tree:

- `<F>/spec.md`, with its outline in `<F>/spec_outline.txt`. Read only the
  line range the launch prompt names, in chunks.
- `<F>/anchors.tsv`: every glossary anchor and its term.
- `<F>/coinage_inventory.md`: the triage rule and the coinages already
  sorted. Bucket B lists aliases of existing entries, bucket D the
  one-or-two-use coinages that get an inline gloss only.

Search with `rg`; list directories with `/bin/ls` or `fd`, never `ls`.
Edit nothing, commit nothing.

## What a candidate is

A term the range introduces as a name of its own and that `anchors.tsv`
does not hold under any alias. The signs:

- a parenthesized gloss at first use, as in "the drain (the frame-top swap
  that publishes staged writes)", on a term with no `(#g-…)` link;
- an explicit definition: "call it X", "X is the …", "we name … X", a term
  set in italics where it is defined;
- a coined compound the text reuses as a name, often "the X rule", "the X
  law", "the X step", "an X entry".

Not candidates: ordinary English and standard domain vocabulary used in
its standard sense; API identifiers in backticks that are functions or
keywords (Appendix B indexes those); a term with an anchor, or an alias
`coinage_inventory.md` bucket B already maps; bucket D's terms, unless
their use has grown to three or more places.

Known gaps, to confirm and give rows: the wiring entry (§6.1, §13.3), and
the condition entry, the input entry and the tap (chapter 14). They are
senses of *entry* that `g-entry`'s disambiguation entry lacks, or terms of
their own.

## For each candidate

- Count its uses over the body, frozen spec lines 1 to 14321, with a
  case-insensitive `rg -c` on a short fragment of the term, and list the
  sections that use it. A short fragment catches a use that wraps across
  a line; check the hits are the term and not an accident.
- Say whether its definition sits far from some of its uses: in another
  chapter, or in a section the use does not cite.
- Propose a class, from the triage rule: `C` for an entry (three or more
  uses, or used far from its definition), `B` for an alias of an existing
  entry (name the anchor), `D` for an inline gloss only, `sense` for a
  new sense of an existing disambiguation entry such as `g-entry`.

## The TSV

Columns, tab-separated, a header row first:

```
term	class	uses	sections	defined_at	definition	anchor	note
```

- `defined_at`: `§N.M:line` in the frozen spec.
- `definition`: the defining words, trimmed, verbatim.
- `anchor`: for class `B` or `sense`, the existing anchor.
- `note`: why the class, in one sentence; for `C`, a draft gloss of at
  most 25 words drawn from the defining words.

No tabs or newlines inside a cell. Write the TSV with a shell heredoc to
the path the launch prompt names; if the write is refused, return it in
your reply instead. Reply in under 100 words: the count by class and the
`C` terms.
