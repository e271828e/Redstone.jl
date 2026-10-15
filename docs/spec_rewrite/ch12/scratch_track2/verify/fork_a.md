# Fork A: d19fe88, hunks and Spec fields

Counts: 37 hunks in `decisions.md`; 37 log entries (L1–L37). Every hunk maps
to one log entry by D-id and new text (L12's one hunk carries D-030's Spec
and annotation; D-128 and D-274 have two hunks each, L20/L21 and L35/L36).
No log entry lacks a hunk. All 14 removed lines are **Spec.** lines; every
added line is a Spec field, its wrapped tail, or an annotation. No Position,
Rationale, Rejected or title line changed. Annotation placement holds for all
23 annotated entries (D-255 after Rejected; D-261 after its pre-Rejected
2026-10-08 annotation). 15 Spec edits checked (L1–L11, L12, L20, L35, L37):
each added section states or cites the entry's ruling at HEAD, and each field
is sorted and deduplicated. D-200 left out correctly: landed §12.6 9440–9452
speaks of the harness staging cell, not D-200's diagnostic cell. Findings: 1.

## Findings

1. d19fe88 (log only), `docs/spec_rewrite/ch12/track2_log_1.md` 643 and 657.
   Text: "### D-256 — ```". Problem: L31's Old and New blocks close their
   fence on the same line as a truncated D-256 heading. A closing fence must
   stand alone, so the block does not close where meant, the rest of the log
   renders with fences inverted, and the recorded text truncates the
   heading. Fix: write the full heading line, then the closing fence on its
   own line.

## Checked, no finding

- D-274 L36: B74 and the evidence check call §13.7 a renumbering leftover,
  which would let rule 2 fix the Position in place. At D-274's own commit
  (c39a37d) §13.7 was already "Tooling consequences", so the pointer was
  wrong at birth, and annotating the Position (rule 1) while correcting the
  Spec field holds.
- D-374 §12.2 rests on 8780 ("never a detach") and 8747 (the frozen roster);
  D-045 §12.5 rests on 9256 ("latched commands or counters"); D-022 §12.3
  on 8801 ("framework-only code"). Weak but adequate readings.
