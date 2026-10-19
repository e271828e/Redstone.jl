# Unit F (§13.5, §13.6): rulings, citations and open questions

Old lines are spec lines at `1fee0fc` (`old.md` line + 10442). Log lines are
`scratch_survey/h2/decisions.md`; spec lines elsewhere are
`scratch_survey/h2/spec.md`. Claims deleted by ruling are copied in
`deleted.md`.

## Rulings applied

- **R2, R29.** The inspection doctrine keeps "Output devices are the other
  half of the same doctrine". Under R29 the next sentence reads "Their reads
  are inspection on snapshot paths ([§11.2][s11-2]), though attach resolves
  them strictly, as [§13.3][s13-3]'s service clients ([D-406][d-406])", and
  the q28 pointer reads "[§13.3][s13-3] scopes path resolution by client, on
  a line of its own." The pointer is an `added` block, so it carries no tag.
  Nothing says a binding takes the instance walk.
- **Verifier's fixes (`verify.md`).** The `t*`-hit citation moved to the
  sentence end, so it covers the cursor clause. §14.5 now sits right after
  the boundary-zero gloss. The trace-header gloss dropped "taken at boundary
  zero", which used the term before its gloss. §10.4 is cited at the first
  `t*`. "A landing-gear strut's touchdown overload", following spec 4717.
  The opening sentence now names the policy and the record. "Authors are
  taught this rule." replaces the hard-to-parse version.
- **R3.** §13.5 has eight `####` labels in part C's order: detection and
  publication (with `StopRequest` by M52), placement and requesters, the
  policy per advance, the scan and the source order (M53, M54), unbounded
  runs, the termination record, ignored requests and post-terminal dynamics,
  and inspection with the rejected mechanisms (M56, M57). The context ends
  with a parts sentence naming all eight. §13.6 has no label; its new context
  ends with a parts sentence. The five bold list lead-ins, **Rule.**, **Why
  one binding site.**, the two bold terms of the doctrine and the bold
  `StopPolicy` link all went. The label "Placement and requesters" avoids
  "requester roster" before its gloss.
- **R4.** M55: one pointer sentence to §12.6 for the declaration, the three
  calls' keywords and the lifetime. §13.5 keeps the defaults `Inf` and `()`,
  which §12.6 does not state (9579–9588), the ignore list's semantics,
  `StopRequestInvalid`, the binder's mask (now cited to D-316) and the `t*`
  hit, so §12.6's citation of §13.5 for "the `StopPolicy` … it passes to the
  loop" (9583–9584) still has its referent. "Why one binding site" reduces to
  the pointer, keeping "The defaults belong to the calls that take the
  policy" and the trace-header clause; the "one notch later" argument is cut
  (`deleted.md`); "not the root-declared stop policy" sits beside the
  rejected mechanisms as "root-type-declared stop policy, which the
  per-advance policy is not"; the `stopped → init! → run!` sentence maps to
  §12.6's "A second run, or a `step!` sequence between two runs, can
  therefore stop on a different clock …". The lifetime sentence maps to
  §12.6 9584–9586 (M). M59: the errored clauses are one pointer sentence to
  §12.6 with D-059 and D-387. q28: §13.5 keeps the record and §13.6 the entry,
  each pointing at the other; the stop scan stays "the one such read", with
  the §13.3 pointer added; "promotes" and "retained" are verbatim in §13.6.
- **R5.** New bolds: D-060's headline; D-316's scan bullet (R5's "bullet
  7"; it is the eighth by count, after the mask's); D-203
  bullet 2, the interrupt a tag; D-233, the time always present. Bolds kept
  on their headline clauses: D-060's "exceptions from model code are always
  abnormal", D-316 bullets 1, 2, 4 and 5 and its Position, D-255's unbounded
  run, D-203 bullet 1 and bullet 5 (the old **Rule.**), and D-030's abnormal
  path, with "therefore" removed so the bold heads its sentence (row 581).
  Row 565 went plain. Row 524's bold term went plain. Row 577 went plain as a
  reason after its rule (M58), cited to D-030. 15 bold spans in the unit; the
  old had 22.
- **R22.** Row 501 keeps one bold, on "has no counterpart here", with D-060
  in its sentence; the history around it is plain. This corrects R5's
  reading, which had made it plain.
- **R23.** R9's sentence is split so each sentence carries one gloss. The
  `#g-blessed` link stays, in its own sentence, which puts the D-060
  attribution back. In §13.6, *component* is linked at its first use. The
  workspace clause is now three sentences with one gloss each.
- **R6.** F51 (the entry check, keeping "with that snapshot final"), F52
  (`h = 1//50`), F53 (both "GUI" uses, D-310 cited once at the stop button),
  F54 (the `t_end` range), F55 ("outside the loop"), F56 (prose and chart),
  F57 (the in-frame scope and "terminal, not resumable"), F67 (rows 520 and
  543). I grepped the unit for "GUI", "terminally", "sim task", "close hook"
  and "boundary-zero snapshot"; each now occurs nowhere.
- **R9.** One sentence names all seven rejected mechanisms with D-060 and
  D-316; closures and observation-by-path keep their names, and the
  `stop_when` example keeps its code. The constructive clauses fold into the
  doctrine. Row 569 keeps its verdict and gains D-060.
- **R10.** `Ldg`: "The landing gear `Ldg` from the example of [§6.1][s6-1]"
  (frozen spec 1553). `robot2d`: R10's clause in its own sentence, "Today"
  gone.
- **R12.** "Requester roster" in full at every use, glossed at its first use
  with R12's words. "The ignore list" for "the override" (four places). "The
  stop's `Bool`" for the first sense of "condition" (four places). No
  `#g-kind` link. Bare "kind" is reserved, so the source's "kind" became
  "type" ("its type is its identity", "four source types", "not a source type
  of its own"); the sources are types (`src/sim.jl` `TerminationSource` and
  its four subtypes). "Tail residue" takes an inline gloss at its first
  appearance, and §11.8 stays cited outside it.
- **R14.** The two `IllegalPortType` reasons are named. D-316 bullet 2's own
  first sentence, "Two placements are `IllegalPortType`", is the bold
  headline, which also shrinks the old 24-word bold.
- **Moves.** M51 to M59 as part C lists them. M58: §13.6 now runs context,
  ruling, reason, chart, record, hygiene, quarantine.
- **Reserved words.** "Entry `i`" and "no entry of its own" became "the
  requester at index `i`" and "no listing of its own". "The taught contract
  is this" became "The rule authors are taught is this", since *contract*
  means a component's declared interface.
- **Glossary.** Links with glosses at first use in §13.5: control plane
  (moved up by M51), guard, predicate, localized, boundary (newly linked),
  snapshot, stop request, cell (moved to first use), component (moved to
  first use), trace header, termination record (moved to first use),
  `StopPolicy`, execution cursor, boundary zero, condition, operator
  interrupt, diagnostic cell, replay. Doubled links dropped: control plane
  ×2, component ×1, operator interrupt ×1; blessed kept (R23). In §13.6:
  boundary, snapshot, device, sweep, component, workspace, termination record, store, trace with replay
  (one gloss for the compound), all glossed.

## Corrections proposed

- **F54, no entry.** Added: "A `t_end` that is not a non-negative real is
  `ArgumentInvalid`, refused before the ignore list is read." Source:
  `_t_bound` in `src/sim.jl` (line 241 in the working tree), `(t_end isa Real
  && t_end ≥ 0)`, called fail-fast ahead of the collecting path pass (line
  298's comment). No entry states the range; D-255 says "validated per call"
  only. Track 2: Appendix C's `ArgumentInvalid` gains §13.5.
- **§13.6, the integration intermediates (old 10675–10676 against
  10716–10717).** One sentence says integration intermediates live in
  framework-owned integrator buffers, never in a workspace; the quarantine
  sentence lists "integration intermediates" among what the stores may hold
  mid-boundary. Both stay as written. Evidence that the two can agree: the
  `x` store is a range of the buffer (glossary `#g-store`), so a throw
  between RK stages may leave stage values there. Proposed: no text change
  unless the owner wants "integration intermediates in the `x` range" in the
  quarantine sentence.

## Citations added or replaced

- D-060 at the headline, "Graceful termination is model state, never an
  exception" (Position, first ruling), and at "exceptions from model code are
  always abnormal" ("exceptions from model code always abnormal"); at
  detection ("detection by ordinary guard/handler machinery"); at row 569's
  verdict (Rejected, "Termination-by-exception: … models never state their
  terminal dynamics").
- D-310 at "a front end's stop button" (F53): "The built-in Julia GUI is
  parked in favour of a browser cockpit"; "A front end is attached by hand".
- D-316 at the `StopRequest` bold (bullet 5, "`StopRequest(; reason = "")`
  in `Redstone.Blocks` is the library spelling"); at "it refreshes at every
  boundary, `t*` included" (bullet 5, "Continuous, it refreshes at every
  boundary, `t*` included"); at "Two placements are `IllegalPortType`"
  (bullet 2, verbatim); at the scan (the bullet "After every publication the
  loop scans the `StopFlag` cell block of the just-published snapshot");
  replacing D-261 at the ignore mask (the bullet "The
  binder returns the policy and an ignore mask, one `Bool` per requester";
  D-261's bullet is superseded, log 13867–13868); at the ignored request as a
  cell (Rationale, below).
- D-203 at "The termination record names the source, as a typed value"
  (Position, "a typed source"; bullet 1, the four sources); at "its type is
  its identity" (bullet 1, "kind is identity, payload plain data"); at the
  interrupt tag (bullet 2, "The operator interrupt stays a tag on an ordinary
  stop … never a fifth kind"); at "The sources are consulted in a fixed
  order" (bullet 5, "Source consultation order is normative").
- D-255 at "An unbounded run is allowed" (bullet 5, "A run with `Inf` and no
  faces is allowed", amended by D-316 bullet 9 to "no requester is
  honoured").
- D-030 at the abnormal path's bold and at "A loop-side failure runs the same
  protocol from the catch path" (Position, "loop failure runs the same
  protocol from the catch path"); at "The boundary is all-or-nothing outside
  the loop" (Rejected, below).
- D-059 and D-387 at the M59 pointer: D-059 Position "Status goes terminal
  `stopped`/`errored`"; D-387 Position "An error is reproduced by trace
  replay, not by resurrecting the errored simulation".
- D-406 at the output-device sentence (R29): Position, "Attach resolves a
  binding's `reads` through the read-selector family's one collecting
  resolver".
- D-260 at "The run's termination record carries its *outcome*, and the
  `StopPolicy` of the advance that ended it" (B22), beside D-255: bullet 3,
  "The termination record is the policy's one lasting home" (log 10509).
- D-060 at "A substitution that changes when runs end is answered by the
  ignore list" (B86): Rejected, "swapping an aircraft silently changes when
  runs end" (log 1930–1932; Rationale-only, below).
- §10.4 at the first `t*` (verifier's fix).
- §12.6 at the policy pointer and the M59 pointer; §6.1 at `Ldg`; §13.3 at
  the q28 pointer; §11.8 moved outside the tail residue's gloss.
- Not added: D-083 at "Their reads are inspection bindings on snapshot
  paths" (part E's row 575). D-083's Position makes reads "inspection
  observation", which R2 records D-406 as overriding for bindings; citing it
  would cite a clause the brief treats as overtaken. D-201 or D-136 at row
  530: neither was read in full, and the sentence keeps its §11.8 pointer.

## Rationale-only rulings

- D-316 Rationale (log 13907–13911), "An ignored request is still a cell in
  every snapshot, so the log records when validity broke even on a run that
  continued", cited at that sentence. The doctrine's folded clauses rest on
  the same Rationale (log 13899–13907), cited at the paragraph's head.
- D-030 Rejected (log 1089), "*Mid-frame abort:* torn final snapshot;
  consumers observe un-swept state", cited at "The boundary is all-or-nothing
  outside the loop". Plain, not bold: in the new order it is the reason after
  the abnormal path's ruling.
- D-060 Rejected (log 1919–1920), cited at row 569's verdict.
- D-060 Rejected (log 1930–1932), "The scanned-terminal-type rejection also
  rests on substitution — swapping an aircraft silently changes when runs
  end", cited at "A substitution that changes when runs end is answered by
  the ignore list" (B86). The paragraph cites only D-316, which states the
  answer but not the objection.
- Discard-and-promote, inside the abnormal path's bold, has no entry beyond
  D-030's Position (rejoining the protocol) and its Rejected "Mid-frame
  abort". The log owes a Position stating it.

## Bold on the same entry elsewhere

None found. Checked the frozen spec's other chapters by script (every bold
with a D-citation in its sentence): §8.2 2905 bolds D-316 bullet 3, which
§13.5 states plain; §12.6 9581 bolds D-255's and D-316's per-advance
declaration, which §13.5 now points to; §12.1 8645 and §12.4 8929, 8981 bold
other D-203 bullets (the stop word, `DeviceJoinTimeout`, the residue's
presentation); §12.4 8892 bolds D-030's step order, not its catch-path
clause; §14.4 11561 bolds a D-060/D-316 point about the family. Units A, B and
G's `new.md`: B bolds D-317 bullet 8 and a D-059 point about the frame's
`try`, neither of which this unit bolds.

## Inbound citations affected

- spec 8655 (§12.1), "the policy is what the caller declares for one advance
  ([§13.5][s13-5])": §13.5 no longer says it in those words. It points to
  §12.6 and says "Each advance builds a `StopPolicy`". The fact holds across
  the pointer; the citation could become §12.6 at landing.
- spec 13140 (Appendix B), "… ended the run, and nothing else keeps one
  ([§13.5][s13-5], [D-260][d-260])": the lifetime is §12.6's now. §13.5 keeps
  "carries the policy that actually ended the run". Holds through the
  pointer; §12.6 is the better target.
- spec 9584 (§12.6): holds; §13.5 keeps the binder and the mask.
- spec 9474, log 3051, 3089, 15691: hold; the closure rejection is named.
- spec 11218, 11562; log 2053, 2679, 13899: hold; observation-by-path is
  named and its doctrine stays.
- log 7797 (D-203 Rejected), "the interrupt sentence in §13.5": holds.
- log 11326, 11389 (D-268), "§13.5's consultation order": holds.
- log 4794 (D-138), spec 12695 (Appendix A), the terminal-at-`t₀` path:
  holds after `init!`, as F51 now says.
- spec 8950 (§12.4), §13.6 "discards the failed boundary and promotes the
  previous snapshot": holds verbatim.
- spec 7326, 9154, 9179, 13001, 13836 (§13.6's quarantine and intermediates):
  hold; "half-written", "retained" and the integrator buffers stay.
- spec 5385 (§9.7), "The seam is diagnostic only ([§13.5][s13-5])": wrong
  before the rewrite (part D) and unchanged by it.

## Open questions

None. The three raised at step 3 are ruled: R22 (row 501's bold) and R23
(the `#g-blessed` and §13.6 *component* links). The verifier's question is
ruled R29.
