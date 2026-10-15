# Fork B: d19fe88's annotations, L12 to L24

Scope: the 2026-10-15 annotations on D-030, D-031, D-088, D-097, D-101,
D-110, D-114, D-127, D-128, D-132, D-133 and D-138. Each was read against
its entry in full at `d19fe88^`, its `rulings_batch.md` item (B43–B60), its
`evidence_check.md` entry and N1, the brief's R8, and every entry it names
at the tip.

Counts: 12 annotations checked, 1 finding (a judgment call).

Clean on every annotation: the form is `Annotation (2026-10-15): …` after
the Rationale, as the log's 162 earlier annotations are written; no Position
line changed (the commit's only removed lines are 14 **Spec.** lines); no E1
clause (D-132's "resumable by the next `run!`") or E2 clause is touched; no
owner item is touched (D-127's "`t₀` applied rather than compared" is left);
every named entry says what the annotation gives it (D-373 bullet 1, D-102's
wrapper, D-206's renames, D-255 bullets 2, 3 and 5, D-091 superseded,
D-316's `ignore_stop_requests`, D-228, D-273 bullet 4, D-274 bullet 4,
D-174's harness-writer rename, D-176, D-230, D-234, D-181's
`localization_budget`, D-198, D-310). `ReplayHeaderMismatch` →
`CheckpointMismatch` is credited to Appendix C, not D-319, as the evidence
check's B62 asks. D-132's first sentence is IC1's dictated text verbatim.

## Finding

**F1 (judgment).** Commit d19fe88, `docs/design/decisions.md` 4777–4787
(D-138's annotation).

Text: "so the Rationale's boundary-zero clauses read at the run's start
(§12.4). … so the run advances no frame and ends `stopped` where it
started, its terminal snapshot the one it started from."

Problem: R8, which B60 says the annotation follows, drops two Rationale
clauses as the mechanism: "boundary zero is published" and "the run reuses
§13.5's existing terminal-at-`t₀` path". The blanket reading rule instead
maps them onto the run's start, so the annotated Rationale still reads as
publishing at the run's start and ending through §13.5's path. The closing
clause "its terminal snapshot the one it started from" comes from landed
§12.4, not from R8 or any entry.

Fix: replace the closing clause with "The Rationale's 'boundary zero is
published' and its §13.5 terminal-at-`t₀` path are historical: the loop's
frame-top read ends the run."
