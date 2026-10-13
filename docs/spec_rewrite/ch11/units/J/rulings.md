# Unit J (§11.8): rulings, citations and open questions

Old lines are spec lines at `f61b1af` (old.md line + 8244). Log lines are
`scratch_survey/decisions.md`.

## Rulings applied

- **R5.** The status bold stays here, on "The published framework status is a
  concrete frozen value", now cited to D-136. The terminal-snapshot paragraph
  stays whole (home). B's `new.md` keeps the status plain (line 42) and points
  here.
- **R30.** §11.8 is the home of `totals` monotonicity. The paragraph states it
  with its reason and cites §11.2 only on "the log retains snapshot
  references". The pointer at §11.2 for the claim itself is gone. The
  decimation sentence follows, uncited, as in the old text.
- **R6.** The rejected list (old 8383–8385) becomes "[D-136] lists the rejected
  alternatives." D-136's Rejected list (log 4434–4456) carries all four items:
  shared queue under a lock (4435), status referencing the live accumulator
  (4439), ring reuse by double-buffering (4442), unbounded accumulation (4446).
- **R10 F52** (old 8372–8374), applied as dictated; the `#g-sweep` link dropped.
  `grep "model sweep"` finds no other instance in the unit.
- **R10 F72** (old 8320–8322), applied as dictated. "this boundary" occurs
  nowhere else in the unit.
- **R10 F65.** Bare "cell" became "diagnostic cell" at the heading and old
  8245, 8260, 8274, 8277, 8280, 8298, 8295, 8309, 8314, 8349, 8375 (every
  instance, not only the listed ones; the link text at 8274 went with its
  doubled link). "The batch" (8303) became "The taken ring". Bare "entry"
  became "value" at 8286, 8320 and 8371 (the last unlisted, same sense).
  "cross the same task boundaries" (8249) became "cross between the same
  tasks": *boundary* is reserved.
- **R13.** The drain's gloss reads as ruled, at its first use (old 8272), where
  the old text left it unlinked; the late link at 8297 is gone.
- **R18.** The per-writer status record is added as a display block. Checked
  by grep against `src/dataplane.jl` 429–436 (`struct WriterStatus`, six
  fields, types as shown; built at `src/sim.jl` 1982). `DiagValue` is
  `Union{KINDS...}` (`src/dataplane.jl` 176) and `KindCounts` the per-kind
  isbits record (250–271); one declared sentence introduces both.
- **Bold lead-ins.** "Allocation." became a `####` label. The others became
  bold headline clauses with a citation in the same sentence. The bold words
  "bounded accumulation", "16", "empty sentinel" and "25" went plain: they
  are clauses of a ruling already bold or terms, not rulings. The `maxlog`
  bold (verifier) moved from the lead-in "Presentation is where `maxlog`
  lives", now plain, to the headline clause "That threshold is presentation
  policy, not channel policy".
- **Verifier fixes.** The D-200 and D-136 citations now sit after the
  harness-writer and diagnostic-cell glosses, not inside them. The binding
  rule's reason sits with its consequence: "Because the taken ring is
  exclusively the loop's …, the binding rule holds by construction".
  `DiagValue` is "any value of the kinds the channel carries"
  (`src/dataplane.jl` 170–176; Appendix C's closed set also holds error
  kinds). "Four things" is kept as in the old text.
- **Glossary.** Added first-use links with glosses: harness writer, frame,
  roster, kind, boundary, log. Glosses added to framework status, diagnostic
  cell, snapshot, staging cell, chattering, termination record, device. The
  second `#g-diagnostic-cell` link went (doubled).

## Corrections proposed

- **The loop's record has no heartbeat either.** Old 8279–8282 says the
  harness writer's diagnostic cell "carries no heartbeat, and its status record
  no `task_state`", then "The cell holds … one atomic liveness timestamp" for
  every cell. In `src` the loop's record also carries `nothing` for both
  (`src/dataplane.jl` 424–425: "The harness writer's and the loop's own records
  carry `nothing` for both"; `_status` in `src/sim.jl`). Proposed, after the
  harness sentence: "The loop's own record carries neither, for the same
  reason." Held as written.
- **`recent` can exceed sixteen values** (see Open questions 1).

## Citations added or replaced

- D-136 at "Each writer has one diagnostic cell": Position, log 4389, "one
  per-writer diagnostic cell, one per rostered device plus one for the loop
  itself". D-200 stays beside it for the harness writer (log 7360).
- D-200 repeated at the enumeration sentence, since the bold sentence split in
  two (cited by adjacency).
- D-136 at "no locking, no arbitration and no new primitive": Position, log
  4390–4392, "single-writer by the same ownership argument as §11.4's staging
  cells (no lock, no arbitration, no new primitive)".
- D-200 at the harness writer's CAS append: Position, log 7360, "written into
  its cell on whichever task stages"; Rationale, log 7364, "the same CAS append
  arbitrates".
- D-136 at the ring and counts: Position, log 4392–4393, "a bounded ring of 16
  diagnostic values plus per-kind suppressed counts and an atomic heartbeat
  timestamp".
- D-136 at "The heartbeat rides in the same diagnostic cell": Position, log
  4393, "an atomic heartbeat timestamp"; Rationale, log 4404–4405, "the
  heartbeat rides in the same cell".
- D-317 at the frame's two kinds: bullet 5, log 13616–13618, "The frame's
  chattering and firing-budget reports go to the model's diagnostic cell".
- D-193 at `task_state`: Position, log 7075–7077, "the published per-writer
  status gains `task_state`, read by the loop from its own device `Task`
  handles at publication".
- D-241 repeated at the quiet-frame bold, which old 8357 left uncited:
  Rationale, log 9172–9174, "nothing on a quiet frame scales with diagnostic
  activity".
- D-305 at the zero-allocation scope (F52): bullet 1, log 12943, "The
  zero-allocation invariant is scoped to the stepping loop."
- D-136 at the six Rationale-only bolds below.
- §11.2 at "the log retains snapshot references" (R30), where the old text
  had it; the trailing §11.2 pointer is gone.
- §13.5 moved one sentence earlier, inside the same paragraph, when the
  tail-residue sentence split.

## Rationale-only rulings

- D-136, Rationale, log 4398: "The bound **is** the rate limit" (bold).
- D-136, Rationale, log 4402–4403: the take "at the frame-top drain, §11.4's
  own point" (bold "taken at the same drain").
- D-136, Rationale, log 4407–4408: "framework status becomes a concrete frozen
  value" (bold, R5).
- D-136, Rationale, log 4414: "Presentation is separated from channel
  policy"; Rejected, log 4455–4456, "25 is a renderer's number" (bold "That
  threshold is presentation policy, not channel policy").
- D-136, Rationale, log 4417–4419: "the terminal snapshot carries the final
  cumulative counters" (bold).
- D-136, Rationale, log 4421–4423: "fixed-shape isbits record, never a `Dict`"
  (bold).
- D-241, Rationale, log 9172–9174: "nothing on a quiet frame scales with
  diagnostic activity" (bold).
- D-200, Rationale, log 7364: the CAS append on the harness cell (plain).

Survey 2 part E item 2 lists the D-136 rows as owing a Position.

## Bold on the same entry elsewhere

None. Grepped the frozen spec, chapters 5–10 and 12–14, and every other
unit's `new.md` (A–H, at the time of writing) for bold spans whose sentence
cites D-136, D-193, D-200, D-201, D-203, D-228, D-240, D-241, D-250, D-305 or
D-317. Hits cite other rulings of D-250 (§9.2), D-317 (§9.2, §12.1, §12.6) and
D-305 (§9.8's exactly-zero budget, bullet 3); none bolds a ruling bold here.
B states the status plain.

## Inbound citations affected

- **The heading retitle** ("per-writer cell" to "per-writer diagnostic cell",
  F65) changes the slug. `[s11-8]` definitions in `spec.md` (14727),
  `decisions.md` (14968) and the companions, and the TOC entry (spec 75), need
  `tools/linkify.jl` re-run at landing, which regenerates all three.
- **Glossary `framework status`** (spec 14009) says "this boundary's drained
  diagnostics (`recent`)", the wording F72 corrects here. Track 2.
- No inbound row loses its content. Rows checked: spec 4586, 8537, 8712, 8819,
  8828, 9088, 9762, 10161, 10200, 10232, 12783, 12919, 13288, 13291, 13296,
  13996, 14003, 14009; log rows of D-136, D-137, D-138, D-153, D-160, D-189,
  D-193, D-200, D-201, D-203, D-228, D-240, D-241, D-250, D-317. spec 8828
  ("reads stale … from the first frame (§11.8)") cites a fact §11.8 never
  stated, before or after (`src/dataplane.jl` 332–334 holds it).
- B's `new.md` cites §11.8 for "the `totals` monotonicity", which this
  section now states with its reason (R30).

## Open questions

1. **Thirty-two values in the loop's record (F72).** The loop's account folds
   two diagnostic cells, its own and the `Model`'s (`src/devices.jl` 588–589,
   `src/sim.jl` 1860–1861, D-317 bullet 5). Its `recent` can therefore carry
   up to thirty-two values. `_fold!` also appends rather than replaces when
   the pending delta was not yet published (`src/dataplane.jl` 406–407). Kept
   as written: "at most sixteen values", "at most sixteen retained values …
   per frame" and "One ring of sixteen values per writer per boundary is the
   worst case". Each holds per diagnostic cell, not per published record.
2. **F65 against F72 on "sixteen entries".** F72 says keep "at most sixteen
   entries" as written. F65 lists the same line (8320) for bare "entry". I
   read F72 as protecting the count, so I kept sixteen and wrote "values".
   Revert to "entries" if F72 meant the word.
3. **D-136 owes annotations.** D-200 (harness cell), D-317 (`Model` cell),
   D-240 (heartbeat read at publication, not at the drain), D-241 (status
   vector, not zero added allocation) and F52 (the "model-sweep" scope) each
   amend D-136's text, and D-136 carries no annotation. Track 2.
4. **Plain rulings in their home.** §11.8 is in the Spec field of D-240 and
   D-241 (the only section for D-241), and it states D-200's second ruling
   (harness diagnostics on whichever task stages). None is bold here or
   anywhere. I added no bold the old text lacked. Should these be bold?
5. **The display block's names.** `WriterStatus`, `DiagValue` and `KindCounts`
   appear nowhere else in the spec, and the package exports nothing. Keep
   the internal type names, or show the field names only?
