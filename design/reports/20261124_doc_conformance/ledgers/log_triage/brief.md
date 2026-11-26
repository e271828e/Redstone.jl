# Brief: triage of the log findings, slice {N}

You triage the rows of one slice of the doc conformance audit's log findings.
Each row says that an entry of `design/log.md` no longer matches the code or
the spec. You decide, row by row, what the log owes. You change no file: you
read, you may run small probes, and you hand the result back in your final
message.

Paths are relative to the repository root, `/Users/miguel/.julia/dev/Redstone.jl`.

## Inputs

- Your slice: `design/reports/20261124_doc_conformance/ledgers/log_triage/slice{N}.tsv`.
  One row per finding, its entry in the first column. The columns `claim`,
  `fix_or_moved_by`, `evidence` and `note` come from the audit's verifier.
  Rows with an empty `kind` are pointer rows. Their detail is the
  `orig_finding` column, a spec or code finding whose verifier named the
  entry as backing the old text. The fix of a pointer row has already landed
  in the spec or the code, so the question is whether the entry now reads
  against the spec.
- The log rules: `design/rules/log_rules.md`. Read it whole first. Rules 1,
  2, 9 and 10 decide most rows.
- An entry: `rg -n '^### D-147' design/log.md`, then read from that line to
  the next `### `. Read every entry of your slice whole, including its
  annotations, and read the later entries a row's note names.
- The spec: `design/spec.md` is about 17,000 lines. Never read it whole. Find
  a section with `rg -n '^#{2,4} ' design/spec.md`, or a claim with `rg`, and
  read the passage.
- The code: `src/`, `test/`, `examples/src/`. Find with `rg`.

The rows were written days ago, and fixes have landed since. Check each row
against master as it stands now, not against its evidence column.

## The four outcomes

Give every row exactly one.

1. `none`: the log owes nothing. Use it when:
   - the drift is vocabulary of its day, a name a later entry renamed (rule 2);
   - an annotation on the entry, or a later entry, already records the change
     and says where the position now lives;
   - on re-check, the entry is right.
2. `annotate`: the position moved, and the spec or a later entry already
   states the new one, but nothing on the old entry says so. The old entry
   gets one dated line. Draft it in the log's form, as the existing
   annotations do (`rg -n '^Annotation \(' design/log.md | head`):
   `Annotation (2026-11-26): <what changed>, <where it lives now>.` Cite bare,
   `§9.4` and `D-263`, never links. Never draft an annotation for a rename
   alone: rule 2 says a rename applies forward, and a term's rename is
   annotated only where it touches the entry's argument.
3. `supersede`: the position changed, and neither the spec nor any entry
   states the current position as a ruling. Give the current position in one
   or two sentences and where it lives: the spec passage, the code, or both.
   Name a topic of two to five words. The coordinator groups the rows by
   topic later, so reuse a topic when two rows are about one thing.
4. `outside`: the fix is not a log entry. A citation to correct in place
   (rule 1 allows citations), a policy entry to rewrite in place (rule 9), or
   a defect in the code or spec rather than in the log. Say which.

Prefer `none` to `annotate` and `annotate` to `supersede`. When the spec and
the latest entry agree against an older entry, the older entry gets an
annotation, not a new entry (rule 10).

## Probes

Settle a claim by reading where you can. Run a probe only where reading
cannot settle it, with `julia --project=test -e '…'` from the repository
root, or a script under
`/private/tmp/claude-501/-Users-miguel--julia-dev-Redstone-jl/e73673fe-4c84-4058-bd8a-9010448d8b4f/scratchpad/triage{N}/`.
Keep a probe under a minute. Run no test suite.

## Rules of the house

- Use `/bin/ls` or `fd`, never `ls`.
- Edit, write or commit nothing in the repository.
- Never run `git` commands that change state.

## What you return

Your final message is a TSV block and nothing else, with this header and one
line per row of your slice, in the slice's order:

```
id	entry	outcome	evidence	draft
```

- `evidence`: at most 200 characters. What you checked and found, with
  `file:line` where it helps. For `none` on a rename, the entry that renamed it.
- `draft`: for `annotate`, the annotation line. For `supersede`, the topic,
  then ` :: `, then the current position and where it lives. For `outside`,
  the kind and the fix in place. Empty for `none`.

No tabs or newlines inside a field. Keep the whole message under 30,000
characters: terse evidence for `none` rows leaves room for the drafts.
