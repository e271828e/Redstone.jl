# Chapter 13, track 2: cold verification (recipe step 8)

Each of `ebaa273`, `e1a7004` and `32a4e98` was diffed against its parent
hunk by hunk and checked against `track2_log_1.md`, `track2_log_2.md` and
the Status lines of `rulings_batch.md`, B40 to B85. Scratch files are in
`scratch_track2/verify/`.

## Counts

- `ebaa273`: 4 hunks, edits 1 to 4, all logged and as ordered (F54, R12
  entry and link, B85).
- `e1a7004`: 43 hunks carrying 45 logged edits (D-058's and D-071's Spec
  and annotation edits share a hunk). That is 18 annotations, not 17: B40's
  D-184 annotation counts. And 27 Spec-field edits, not 25: the 22 from B78
  plus B45, B46, B50, B62 and B68. Every hunk is logged. No hunk touches a
  Position.
- `32a4e98`: 7 entries, 7 Index rows, 11 spec citations, one Spec field
  (D-369), and the generated link definitions, all logged. The committed
  entries match the log's text. A word diff of `spec.md` shows citations
  added and nothing else. Every changed line is at most 80 rendered columns.
- Battery, run from `docs/design/tools/`, each check as its own command:
  `check_refs.jl` OK, `check_rows.jl` OK, `check_glossary.jl --strict` OK,
  `check_bold.jl` OK (chapter 13: 57 spans, 521 words).
- Findings: 4. One entry to drop (D-410), and one bullet to drop (D-409
  bullet 2).

## Checked and right

- Annotations: each states only what its item's evidence records, writes
  no ruling, and sits after the Rationale with the Position untouched. The
  quoted wordings check against §13.1, §13.3, §13.5, §13.7, §13.8 and D-222,
  D-233, D-250, D-251, D-257, D-285, D-311 and D-313.
- Spec fields: in each of the 28, the entry's Position rules what the citing
  sentence states. Leaving out D-310 §13.5 is right. D-071's field as §14.9
  alone is right: §14.9 states all of the entry's rulings.
- B85: `init!` in `src/model.jl` 177–198 hosts the catch, and `replay!` runs
  no `boundary_zero!`.
- D-414 matches `src/sim.jl`. `_advance!` calls `_stop_hit` before its loop
  (1590–1591). `_bind_policy` calls `_t_bound` before `_ignored_requests`
  (300–304). `run!`, `replay!` and `step!` all bind through it. No Position
  states either bullet. D-316's "first publication where it holds" does not
  cover a later run whose request already holds.
- D-411, D-412 and D-413 restate their sources word for word, and no
  Position states them.
- Drops: B45 (D-058's "paths and names as strings"), B49 (a reason), B51
  (D-108's legal-state list has no `errored`), B55 (D-132, D-317 bullet 8,
  D-398 bullet 2), B56 (D-369 bullet 3), B62's three (D-260, D-255, D-203
  bullets 1 and 2), B64 (D-225's `StepError{Kind}`), B67 (D-250's Position
  and bullet 3), and B71 (rule 9). All are right. The D-108 citation at
  §13.6 and the D-369 citation at §13.2, with §13.2 added to D-369's field,
  are right.

## Findings

### 1. D-408's Rationale names the wrong design text

- `docs/design/decisions.md` 16322–16325: "The design text that ruled
  [D-030][d-030] stated the discard and the promotion, since the boundary is
  all-or-nothing outside the loop, and the log's entry did not carry them."
- Problem: D-030 was ruled at `a73ad0d` (§12.9, item 7: "Loop-side failure
  runs (1)–(5) from the catch path"), and that text states neither the
  discard nor the promotion. Both are in `6fe7de2`'s §15.6, which "fills the
  seat §12.9's 'loop failure runs the same protocol from the catch path'
  reserved". That text says "outside the sim task", not "outside the loop".
  The Rationale never names `6fe7de2`.
- Fix: "The design text at `6fe7de2` (§15.6), which filled the seat
  [D-030][d-030]'s catch-path clause left, stated the discard and the
  promotion, since the boundary is all-or-nothing outside the sim task, and
  no entry carried them."

### 2. D-409's second bullet restates D-316's Position

- `docs/design/decisions.md` 16338–16341: "The ignore list narrows the
  rejection. It reads no arbitrary cell. It addresses the `Build`'s
  requester roster, a build product like the root-input list, and it binds
  at an advance, …". Also 16347–16348: "[D-316][d-316]'s Position states
  neither."
- Problem: D-316's Position states the narrowing in its Supersedes paragraph
  (13953: "and narrows its observation-by-path rejection"). Its bullets
  state the rest. The ignore list names requester paths validated against
  the roster, so it reads no cell, and the policy is the advance's value.
  The clauses left over, "a build product like the root-input list" and "a
  stopped-sim point where conditions already address state by path", are
  reasons (lessons 42 and 68).
- Fix: drop bullet 2, so the Position is bullet 1's text alone. Drop the
  Rationale's two sentences on D-316 and its "neither". The §13.5 citation
  at 10739 stays for bullet 1.
- Note: D-129's Position (4271–4273) already has service reads speak the
  contract and inspection reads speak structure. Name it beside D-083 in the
  Rationale's sentence on what other Positions cover.

### 3. Drop D-410: a consequence and a reason

- `docs/design/decisions.md` 16354–16367 (D-410), Index row 411; spec
  10724: "([D-060][d-060], [D-410][d-410])".
- Problem: the source clause, "models never state their terminal dynamics",
  is the ground of D-060's rejection of termination by exception. That makes
  it a reason. The ruling follows from D-060's Position (termination is
  model state) and from D-316's (a request the advance ignores leaves the
  run integrating). §13.5 itself writes it as a consequence: "The discipline
  forces models to have well-defined terminal states" (10723). Lesson 68
  says no entry.
- Fix: delete D-410 and its Index row. Revert spec 10724 to "([D-060][d-060])".
  Renumber D-411 to D-414 down by one before the push, as chapter 12 did.
  `master` is 14 commits ahead of `origin`, so nothing is pushed yet.

### 4. D-413's citation sits on the sentence it excludes (minor)

- `docs/design/spec.md` 10711–10712: "An ignored request is still a cell in
  every snapshot, so the log records when validity broke even on a run that
  continued ([D-316][d-316], [D-413][d-413])."
- Problem: D-413's Rationale says it does not restate this clause. Its
  ruling is the next two sentences, which cite nothing. The citation does
  sit beside its source, as the prompt asked, so this is a placement choice.
- Fix (optional): move it to "… and the framework never will
  ([D-413][d-413])." Or leave it, since the paragraph cites D-316 once.

## Entries to drop

- D-410, by finding 3.

## Re-check (`f6beddf`)

`f6beddf` was diffed against `32a4e98` hunk by hunk: 9 hunks in
`decisions.md` and 8 in `spec.md`. Each one is logged under "Review fixes"
in `track2_log_2.md`, and each one does what its finding asked.

- F1: D-408's Rationale now names "Section 15.6 of the design text at
  `6fe7de2`" and says "outside the sim task". It matches the source.
  Leaving out `§` is right, since `§` is for spec citations.
- F2: D-409 keeps bullet 1 alone, its Rejected is "None beyond D-060's
  list", and its Spec is unchanged. The added D-129 clause holds against
  D-129's Position (decisions 4271–4273): "the read side speaks structure
  in inspection reads and contract wherever meaning must outlive the
  build: … service reads".
- F3: D-410 is gone, along with its Index row, its link definitions and
  its §13.5 citation (spec 10724 now reads "([D-060][d-060])"). The
  renumbering maps rig stub to D-410, pin to D-411, reason string to D-412
  and advance entry to D-413. Headings, Index rows, both link-definition
  blocks and the six spec citations all agree with it. No `D-414` or
  `d-414` remains under `docs/design/`, `src/` or `test/`, and no entry
  cites a sibling's old number.
- F4: D-412 now sits at "… and the framework never will ([D-412][d-412])"
  (spec 10714), and D-316 stays alone on the sentence before it.
- Every changed spec line is at most 80 rendered columns.
- Battery, each check as its own command: `check_refs.jl` OK,
  `check_rows.jl` OK (408 to 413 newly cited), `check_glossary.jl --strict`
  OK, `check_bold.jl` OK (chapter 13: 57 spans, 521 words).

New findings: none.
