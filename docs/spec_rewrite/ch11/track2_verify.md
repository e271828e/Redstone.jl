# Chapter 11, track 2: cold verification

Commits `b216dee`, `0fd77f9`, `407a222`, against `track2_log_1.md`,
`track2_log_2.md` and `rulings_batch.md` B-29 to B-50. Scratch files are in
`scratch_track2/verify/`.

## 1. Replay

Checked: `b216dee`, 9 logged edits in 8 hunks plus 2 link definitions.
`0fd77f9`, 34 logged edits: 32 annotations and 2 Spec fields. `407a222`, 10
entries, 10 Index rows and 37 citations in 34 logged hunks. Every hunk traces
to a logged edit. The 31 distinct annotation texts in log 1 match the file.
Log 2's entry block matches the file once links are stripped. A word diff of
`spec.md` shows citation changes only. Rewraps change no words. B-41 left
D-134's status alone, as ruled.

Two logged edits go beyond what the Status lines name:

- **D-376 is outside B-48's ruled count.** B-48's Status reads "eight new
  entries, D-367 to D-374 (sources 3 merged)". The agent made nine for B-48
  and gave source 9 (D-047 and D-068 Rejected) the number D-376
  (`decisions.md` 15038–15059, cited at `spec.md` 7291). Log 2 section 1
  gives the reason: nine numbered sources, and source 3 already holds D-136
  and D-241. Fix: amend B-48's Status to cover D-376, or revert the entry and
  its citation.
- **The D-044 citation is not in any Status.** `spec.md` 7564, old "the drain
  is pure application ([D-106][d-106])." New "… ([D-106][d-106],
  [D-044][d-044])." It is logged as 3.18 and follows lesson 42's precedent,
  where D-292 was cited in place of a bullet. Fix: record it in B-48's
  Status, or revert it.

## 2. Annotations

Checked 32 against their items' evidence and the entries they cite: D-104,
D-200, D-136, D-165/D-194, D-174, D-176, D-177, D-252, D-255, D-261, D-274,
D-310 and Appendix C's `DeploymentInvalid` and `ArgumentInvalid` rows. All
use the form `Annotation (2026-10-13): …`. All sit before **Rejected.**, or at
the entry's end for D-255. None decides anything. One citation is loose:

- `decisions.md` 4607–4610 (D-137): "`log_max` is a keyword of `init!`,
  `restore!` and `replay!` … ([D-261][d-261])". D-261's Position names
  `init!` and `replay!` only. `restore!` takes the keyword according to
  Appendix B (`spec.md` 12926–12927). B-46's evidence makes the same
  attribution, so the annotation records its evidence. Fix: "([D-261][d-261],
  [Appendix B][sB])".

## 3. New entries

Checked 10 entries and 34 bullets or Position sentences against the source
lines in full: D-093, D-137, D-136 with its Rejected list, D-241, D-174,
D-177, D-138, D-102, D-106, D-109, D-310, D-047 and D-068. Every bullet
restates its source and adds no claim, scope or strength. D-374's "guarded
addition" keeps its glossary sense, a capability admitted but not built.
Every Rejected item is a rejection its source made. D-375's two items are
identity items from D-109. D-109's GUI and topology rejections are left out.
D-375's Position and Rejected carry no affinity or topology content. Its
Rationale says only that `CallerTaskConflict` fell.

Lesson 42: I extracted 3,729 Position lines from D-001 to D-366 and grepped
about 70 key terms. The near misses are D-028, D-044, D-096, D-097, D-192,
D-201, D-216, D-250, D-261, D-268 and D-310. None states a bullet's ruling.
The two clauses that older Positions do state were dropped (D-044's drain
clause, D-096's drain-last). Lesson 43: no bullet rests only on a source that
cites the spec back. All ten Spec fields match the sections where each entry
is cited. No problems.

## 4. Citations in chapter 11

Checked 37. Each sits beside its source entry's citation, on the bold or
sentence that states the ruling. D-375 is the exception allowed by B-49: it
sits in §11.3's identity and admission sentences, because D-109 is
superseded. No bold or wording was added (`check_bold.jl`: 78 spans, unchanged
per log 2). No bold cites two entries for two different rulings. No problems.

## 5. Battery

`check_refs.jl` OK (one standing self-vs-spec advisory). `check_rows.jl` OK
(D-367 to D-376 newly cited). `check_glossary.jl --strict` OK (three standing
advisories). `check_bold.jl` OK. `linkify.jl` then left `git status`
unchanged. No problems.
