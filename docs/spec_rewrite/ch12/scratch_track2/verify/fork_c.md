# Fork C: d19fe88 annotations L25–L36

Scope: the annotations of D-198, D-217, D-218, D-223, D-230, D-249, D-255,
D-260, D-261, D-268 and D-274 (track2_log_1.md L25–L36). Each entry read in
full at `d19fe88^`, against rulings_batch.md B61–B74 and evidence_check.md
B61–B74 and N1. Each entry diffed across d19fe88: every change is one added
annotation, plus D-274's Spec field (L35). No Position, Rationale or Rejected
line changed.

Counts: 11 annotations checked; 2 findings (1 minor misquote, 1 log
formatting defect); 3 notes, not findings.

All 11 annotations follow the log's form ("Annotation (2026-10-15): ...", a
paragraph after the last annotation or after the Rationale). They decide
nothing new. Every entry they cite says what they attribute to it:

- D-256 bullet 3 (`join_timeout` into `Control`).
- D-317 bullet 2 (`Simulation(model::Model{Float64}; join_timeout = 5.0)`,
  `Model(...; chunk_size = 16)`), its "running flag" bullet, and its
  Supersedes line naming D-255's lifecycle clause, D-260's four-field `Run`
  and D-261's `chunk_size` clause.
- D-274 bullets 3 and 4 and its Position ("replay is a restore followed by
  the feed").
- D-316 ("The `stop_on` keyword and `StopFaceInvalid` retire").
- D-260 bullets 2 and 4, and D-261 bullet 7 (the placeholder).

D-217's annotation follows the evidence check's correction: it does not
credit D-319. None touches E1, E2 or an owner item. D-218 leaves `restore!`
out of its doors, D-261 leaves the `restore!` keywords out, and D-127 is out
of scope.

## Findings

### F1. Misquoted spec wording (minor)

- Commit: d19fe88
- File: `docs/design/decisions.md`, line 7536–7537 (D-198 annotation)
- Text: `[§12.4][s12-4] says "usage contexts".`
- Problem: §12.4 (spec.md 8978) reads "Usage contexts legitimately differ in
  patience". The quoted phrase changes the case of the spec's words.
  Judgment call: the meaning is unchanged.
- Fix: write `says "Usage contexts"`, or drop the quotation marks.

### F2. Fence fused onto a heading line in the log

- Commit: f22cb9d (the log, outside the three verified commits)
- File: `docs/spec_rewrite/ch12/track2_log_1.md`, lines 643 and 657
- Text: `### D-256 — ```` (as the last line of L31's Old and New blocks)
- Problem: L31's old and new text end with D-256's heading prefix
  (`### D-256 — `, with no title), and the closing fence sits on that line.
  A closing fence must stand on its own line. Rendered, the Old block never
  closes, so "New:" and L31's annotation render inside and outside code in
  turn. Whoever replays the edits by raw text still gets the right strings.
  This is a log defect only, not a decisions.md defect.
- Fix: put each closing fence on its own line, and mark the trailing
  `### D-256 — ` (it has a trailing space) as part of the matched text.

## Notes (not findings)

- D-268 (tip 11313): the annotation says the stop faces "of the second bullet
  and the Rationale" are stop requests. The B72 evidence records only bullet
  2. The Rationale's wording ("where the stop faces are read") is true at the
  source. The Rejected item at 11329 ("over a holding face") predates D-316
  too and is not named.
- D-274 (tip 11858): B74 proposed correcting §13.7 → §14 "in both places".
  The Position's §13.7 is annotated, not edited, and the Spec field is
  corrected in place. Rule 2 would allow the in-place citation sweep. The
  annotation is the conservative choice and is consistent with "no Position
  edited".
- D-223, outside B65's evidence: bullet 1 ("`replay!` of the captured header
  reproduces either failure, and the rendered recipe at zero is the bare
  replay") is also stale under D-274's last bullet ("A throw inside boundary
  zero leaves no trace and no checkpoint ... Its reproduction is `init!`
  under the same condition"). No item records it, so it is a candidate for
  the owner or a later annotation, not a defect of L28.
