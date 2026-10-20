# Appendix B: the classification brief

The first step of Appendix B's treatment (`../appendices.md`, "Appendix B:
thin it, don't polish it"). Read that section first. B disclaims being a
second home and then is one. This pass finds out, sentence by sentence,
which of its words are a name, which repeat their owning section, and
which are stated nowhere else.

## Base and files

- Base commit `e6a4fcb`. Frozen copies, read these and never the working
  tree, which another session edits: `<S>/frozen/spec.md`,
  `<S>/frozen/decisions.md`, the heading outline
  `<S>/frozen/spec_outline.txt`, and the whole repository at that commit in
  `<S>/frozen_tree/`. `<S>` is the scratchpad directory the launch prompt
  names.
- Appendix B is frozen spec lines 13371 to 13846. Your range is in the
  launch prompt. Read your range whole, and the lines just before it for
  context.
- Read the spec by section via the outline, never whole. Grep the log by
  entry number; read an entry in full before you claim what it rules.

## What you classify

Every sentence of your range, and every table row. Split a sentence into
clauses where its clauses fall into different classes. A table row is one
item; a bullet's lead signature is one item.

- **1, name**: a name, a signature, a keyword with its default, or a
  return type. Nothing more than what a reader types.
- **2, duplicate**: its owning section states the same claim with the same
  strength and scope. Give the section and the frozen line where it does.
  A claim stated in a different section from the one B cites is still a 2;
  give the section that states it.
- **2d, drifted duplicate**: the owning section states the claim, but B's
  version differs in strength, scope, a count, a default, a name, or is
  stale against a later entry. Quote both and say what differs.
- **3, stated nowhere else**: no sentence of the spec outside Appendix B
  states it. Grep at least two phrasings and the names it uses before you
  call it a 3. Then say where it belongs: a named owning section with the
  sentence it would sit beside, or the docstring of a named function when
  it is an API detail too small for the spec. And say whether it is a
  **decision**: yes when it settles behavior that no log entry and no spec
  sentence settles, so that the owner must rule before it lands; no when it
  follows from a stated rule by reading it, or a log entry states it and
  only the spec sentence is missing (name the entry and quote its words).
- **X, framing**: a transition, a heading, or a sentence that asserts
  nothing.

## Also flag, in the note column

- A reserved word used in another sense (`checks/brief_common.md`, "Reserved
  words"). In particular *door*, which chapter 12's rewrite reserves for an
  entry point that builds a run: the `Model`'s rows call every one of its
  entry points a door.
- A bold with no D-citation in its sentence, and the entry that rules it.
- A citation that does not carry the claim it is attached to.
- A glossary term used unlinked where Appendix D has an anchor
  (`grep -n 'id="g-' <S>/frozen/spec.md`), e.g. the requester roster,
  `#g-requester-roster`.

## What you produce

A TSV file at the path the launch prompt names, header row first, one row
per item, tab-separated, no tabs inside fields:

```
id	spec_line	class	excerpt	home	home_line	decision	note
```

- `id`: your range letter and a running number, `R1-01`.
- `excerpt`: the item's words, verbatim, up to 200 characters.
- `home`: the owning section (`§12.6`) or the docstring (`doc:restore!`)
  for a 3, the section stating it for a 2 or 2d, empty for 1 and X.
- `home_line`: the frozen line of the home's sentence, or the source file
  and line for a docstring home.
- `decision`: `yes`, `no`, or empty; only for a 3.
- `note`: for a 2d, both versions and the difference; for a 3, the
  sentence's proposed home and, when `decision` is `no`, the entry's words
  that carry it; any flag from the list above.

Write only that TSV file. Edit nothing else. Run nothing in the background.
Use `command ls` or `fd`, never a bare `ls`. Never stash, reset, check out
or commit. Reply in under 200 words: the row count per class, and every 3
and 2d in one line each.
