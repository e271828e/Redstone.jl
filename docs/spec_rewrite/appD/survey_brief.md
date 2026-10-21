# Appendix D: the per-entry survey brief

Appendix D is checked for citations and length, not rewritten for style
(`../appendices.md`, "Appendix D: citations, gaps and length"). This brief
is what each read-only survey agent reads. One agent takes one range of
entries and returns one TSV and one file of proposed entries.

## Base and files

Base commit `4004522`. Read the frozen copies under `<F>`, the directory
the launch prompt names, never the working tree:

- `<F>/appD.md` is Appendix D, frozen spec lines 14322 to 15450. Its line
  `n` is spec line `n + 14321`.
- `<F>/spec.md` is the whole frozen spec, with its outline in
  `<F>/spec_outline.txt`. Find a cited section's span from the outline and
  read that span, never the whole file.
- `<F>/decisions.md` is the log, when an entry cites a D-number or a claim
  needs its ruling.
- `<F>/words.tsv` gives each entry's anchor, spec line and rendered word
  count (anchor, citations and link markup dropped).
- `<F>/anchors.tsv` lists every glossary anchor with its term.

Search with `rg`; list directories with `/bin/ls` or `fd`, never `ls`.
Edit nothing, commit nothing.

## What an entry is

An entry is `<a id="g-…"></a>**term** — definition (citations)`. It
compresses the meaning its owning section fixes, and the owning section
wins where they diverge. Chapters 1 to 14 were rewritten after most
entries were written, and much text moved between sections. Read the
appendix's lead (`<F>/appD.md` lines 1 to 11) first.

## The checks, per entry

One TSV row per check that applies. Every entry gets a `cite` row per
citation and one `accuracy` row; an entry over the cap also gets a
`length` row.

- **cite**: for each section or D-number the entry cites, does that
  section still state what the entry attributes to it? Read the section.
  - `ok`: it does.
  - `moved`: the claim is stated, but in another section; name it.
  - `gone`: no section states it any more; say whether a log entry does.
  - `wrong`: the section states something different; quote it.
  A claim that carries no citation of its own falls under the entry's
  nearest citation. A `§D.n` citation points inside the glossary: check
  that the named group holds the entry it points at.
- **accuracy**: every claim of the entry against the spec as it stands,
  citation aside. Stale names are the usual drift: renamed functions,
  types, keywords or fields, a retired term, a count that changed. Check
  every backticked name the entry uses against the spec by `rg`. A claim
  stated nowhere in chapters 1 to 14 or Appendices A to C is a finding,
  even if the log states it, since the glossary is no home.
- **length**: the cap is **60 rendered words**, as `words.tsv` counts
  them. For an entry over it, decide which clauses go. A clause may go
  only where its owning section states it: give that section and the
  frozen spec line. A clause no section states stays, and the row says so
  (`orphan`). Cut in this order:
  1. restatement of the owning section's mechanism, enforcement or edge
     cases, where the gloss of what the term *means* survives without it;
  2. lists the owning section already enumerates, replaced by the list's
     name and a citation;
  3. "not to be confused with" clauses that re-define the neighbor
     rather than name it. A clause stays only where the neighbor is
     genuinely close, as one short sentence naming the neighbor and its
     anchor or section, without restating it.
  The definition a reader looks up, the term's sense in one or two
  sentences, never goes.

## Verdicts

Every row's `verdict` is one of `ok`, `moved`, `gone`, `wrong`, `stale`
(an accuracy finding), `over` (a length row), `orphan` (a length row whose
entry keeps a clause no section states), or `unclear` (say why).

## The TSV

Columns, tab-separated, a header row first:

```
anchor	check	verdict	cites	entry_says	spec_says	home	note
```

- `cites`: for a `cite` row, the citation checked (`§8.2`, `D-314`).
- `entry_says`: the entry's words for the claim, trimmed.
- `spec_says`: what the section says, short, or empty for `ok`.
- `home`: `§N.M:line` in the frozen spec where the claim is stated, for
  every non-`ok` row and every clause a `length` row drops. For a `length`
  row, list each dropped clause's home, `;`-separated.
- `note`: for a non-`ok` row, the fix in one sentence.

No tabs or newlines inside a cell.

## The proposed entries

For every entry with any non-`ok` row, write the full replacement entry
to the proposals file, in spec markdown, separated by blank lines:

- keep the anchor and the bold term exactly; after the term comes ` — `,
  the one em-dash the format allows; no other em-dashes;
- section citations in the reference form the spec uses, `[§8.2][s8-2]`,
  and glossary links inline, `[drain](#g-drain)`;
- wrap at 80 columns of source;
- at most 60 rendered words, unless a clause stays as `orphan`;
- short sentences in the active voice, plain vocabulary, at most one
  parenthetical per sentence, no colons joining clauses;
- no bold inside the definition except a sub-term the entry defines, as
  *sweep* bolds interior sweep and boundary sweep;
- nothing the frozen spec does not state.

## Output

Write the TSV and the proposals file with a shell heredoc to the paths the
launch prompt names; if a write is refused, return them in your reply
instead, the TSV first. Reply in under 150 words: the count of rows by
verdict, the anchors with a `gone`, `wrong` or `orphan` row, and anything
that looks like a design question rather than drift.
