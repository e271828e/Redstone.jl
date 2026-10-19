# Chapter 13: rulings batch (step 6)

Merged from the four units' `rulings.md` and `verify.md`, `chapter_pass_1.md`
and `chapter_pass_2.md`, `inbound_check_1.md` and `inbound_check_2.md`, and
part E of `survey_1.md` and `survey_2.md`. Settled by `brief.md` (R1 to R30)
or applied and verified: left out. Chapter lines are `chapter_new.md` at
`5f21eba`; the editorial fixers shift them, so find each by its quoted
words. Spec and log lines are those of the frozen copies at `1fee0fc`.
"Pass" is a chapter-pass finding id (P1-n, P2-n); "row" and "#n" are
inbound-check rows. The chapter has no escalations.

**Not in this batch.** The chapter pass's EDITORIAL findings go to the
fixers. The units' open questions are all ruled (R16 to R30). Edits that
`brief.md` "Edits at landing" already lists are not repeated: the §11.2 7108
and §8.6 3410 sentences, §9.5 5094, the §9.2 D-261 cite, the README and
Part IV omissions, and track 2 for D-130, D-242, D-061 (R26), D-250 and
D-058 (R11), the requester-roster glossary entry, the feedthrough-tracer
entry, and Appendix C's `ArgumentInvalid` row. Items below add only what the
checks found beyond those.

**Groups.** Blocking holds every item that changes chapter text and needs a
ruling, worst first. Items B1 to B5 state or imply a wrong claim or a broken
pointer; B6 to B22 are doubles, glosses and dictated wordings that the
orchestrator should settle before landing. Counts: Blocking 22 (B1 to B22),
Landing 19 (B23 to B41), Track 2 38 (B42 to B79), Carried 6 (B80 to B85).

## Blocking

### B1. "The service walk" is undefined and its pointer points nowhere

- Sources: chapter_pass_1 P1-15 (RULING); inbound_check_1 row 55 (its
  proposed Appendix B text uses the term too); unit B `rulings.md` (F2, F3).
- Lines: 312–314, 369–371 ("the read side" at 313).
- Evidence: F2 and F3 coin "the service walk". Pass P1-15: no glossary entry,
  not introduced in the chapter, absent elsewhere in the frozen spec. Line
  371 cites §14.3 and §14.4 for "split their own paths through the service
  walk", but neither section names a walk or describes the split. The code
  is `resolve_authored` (`src/assembly.jl` 1494–1534); D-406's Position
  names "the read-selector family's one collecting resolver".
- Proposal: at 314, "It is enforced by the service walk, the read-selector
  family's one collecting resolver ([D-406][d-406]), which follows declared
  field types alongside instances." At 371, cite where the claim is stated
  ([§11.2][s11-2], [D-406][d-406], [D-407][d-407]) or narrow the §14.3/§14.4
  pointer to what those sections do say. Reword "the read side".
- Recommendation: adopt, and drop the §14.3/§14.4 cite unless step 6a finds
  the split stated there. Settle this before B28, which reuses the term.
- Status: ruled, amended. At old 313–315 (unit B): "The second is the generic-holding rule, which governs the deep paths a service or a reader is given. It is enforced by the service walk, the walk every service and the read resolver run over an authored path, which follows *declared field types* alongside instances." Conditions walk with `resolve_authored` (`src/conditions.jl`), and the read resolver walks every path selector with it (`src/readers.jl` `_rebase`). At old 370–371: "Condition addressing ([§14.3][s14-3]) and the readers ([§14.4][s14-4], [D-406][d-406]) split their own paths through the service walk." The pointers then name the clients, and the walk is defined where it is used. No glossary entry: one section uses the term. Amended after application, since "which" read as the path: "It is enforced by the service walk, which follows *declared field types* alongside instances. Every service and the read resolver run it over an authored path."

### B2. F64's dead hop is a face, but the section defines a hop as a path

- Sources: chapter_pass_2 P2-22 (RULING); unit G `verify.md` (F64 matched
  its dictated wording).
- Lines: 1381–1382 against 1345–1349.
- Evidence: the dictated sentence reads "The dead hop is the member's input
  face that its stage-2 function does not route to the output port". Lines
  1345–1349 define a hop as running from a face to a port, and a dead hop
  as one the member's map does not route. D-245 bullet 1 agrees with 1345.
  The sentence also follows four earlier uses of "dead hop".
- Proposal: "The dead hop runs from the member's input face that its
  stage-2 function does not route to the output port". Or, for the
  example, "Here the dead hop is `systems/aero`'s, from `a` to `F`."
- Recommendation: adopt the first wording; it amends R6's F64 and keeps the
  claim D-245 states.
- Status: ruled, adopt the first wording. It amends R6's F64, which was the orchestrator's own error.

### B3. The stop-request gloss says a request ends the run

- Sources: chapter_pass_2 P2-16 (RULING).
- Lines: 1017–1018 against 646 and 722.
- Evidence: the gloss "(a port that ends the run when it reads
  `STOP_REQUESTED`)" overclaims. An ignored request does not end the run
  (line 722; D-316's Position, "unless the advance ignores it"). The old
  text had the same gloss. The glossary and line 646 say "an output port of
  the framework enum `StopFlag`".
- Proposal: use "(an output port of the framework enum `StopFlag`)" at 1017.
- Recommendation: adopt.
- Status: ruled, adopt: the glossary's gloss.

### B4. §13.3 does not point back to the stop scan

- Sources: chapter_pass_2 P2-26 (RULING); `brief.md` R4 (q28) and R29.
- Lines: §13.5 at 872 (R29's pointer); §13.3 inspection warrant, lines
  299–360.
- Evidence: R4 has §13.3 and §13.5 point at each other, for the three-client
  rule and the stop scan as "the one read a run acts on". §13.5 points to
  §13.3. §13.3 has no pointer to §13.5. R29 decided only that the two lines
  differ.
- Proposal: add at §13.3's inspection warrant, "The stop scan, the one read
  a run acts on, is §13.5's ([§13.5][s13-5])."
- Recommendation: adopt; R4 asked for both pointers and R29 withdrew
  neither.
- Status: ruled, adopt. R4 asked for both pointers. Amended after application, since the dictated "is §13.5's (§13.5)" rendered twice: "The stop scan, the one read a run acts on, belongs to [§13.5][s13-5]."

### B5. The D-120 bold carries a whole gloss

- Sources: chapter_pass_2 P2-23 (RULING); `brief.md` R21.
- Lines: 1216–1218.
- Evidence: the bold is "A concrete stub child (a provider of
  `SampleTerrainField`, an illustrative concrete terrain) is wired to the
  face". The gloss doubles the bold's weight past the headline clause
  (`brief_common.md`, Bold). R21 dictated the headline "A concrete stub child
  … is wired to the face".
- Proposal: "**A concrete stub child is wired to the face**, and the concrete
  remainder is exposed via `input_passthrough(rig, "strut"; except =
  ("terrain",))` ([D-120][d-120]). The stub provides `SampleTerrainField`, an
  illustrative concrete terrain."
- Recommendation: adopt.
- Status: ruled, adopt: the bold is the headline clause alone, with D-120 in its sentence.

### B6. The device crash path is stated twice

- Sources: chapter_pass_1 P1-11 (RULING); `brief.md` R4 and R6's F10; unit A
  `rulings.md`.
- Lines: 280–283 against 604–607.
- Evidence: two sentences each repeat the path almost word for word. R4
  asks for one clause each. At 280 "A genuine bug" has no antecedent inside
  the index.
- Proposal: §13.2 reads "`DeviceCrash`, a device crash ([§12.4][s12-4],
  [§13.4][s13-4]). The framework wrapper catches a device task's failure,
  and the run goes on without the device unless its attachment set
  `should_abort` ([§11.6][s11-6])." "A genuine bug takes the per-device
  crash path" stays in §13.4 only. `should_abort` then needs its §13.2 link
  (P1-29, a fixer item).
- Recommendation: adopt.
- Status: ruled, adopt. §13.4 keeps the path; §13.2's index line names the kind and points.

### B7. F63's "local" names two things

- Sources: chapter_pass_2 P2-21 (RULING); inbound_check_2 #80, #259 (the
  glossary and `implementation.md` still say "local"); unit G `rulings.md`.
- Lines: 1292, 1335–1339.
- Evidence: the sampled mode is glossed "(the local, primal-carrying mode)"
  and the per-member variant "*per-member* (local)". Lines 1338–1339 then
  say the two must not be conflated, and a cold reader cannot see that
  *local* is an old name. Lines 1335–1336 also say "the *per-member* …
  variant of tracing, the order-free per-member trace" twice over.
- Proposal: "(the local mode of D-349)" and "(the local variant of D-012)",
  and "uses the *per-member* variant of tracing, an order-free trace at the
  probe point ([D-012][d-012])".
- Recommendation: adopt; it keeps F63's tie to the old names.
- Status: ruled, amended: the glosses are "(the log's *local* mode)" and "(the log's *local* variant)", no citation inside either; and "uses the *per-member* variant of tracing, an order-free trace at the probe point ([D-012][d-012])". "Of D-349" would claim more than the entry is known to say.

### B8. The requester-roster ruling is stated three times in six lines

- Sources: chapter_pass_2 P2-2 (RULING); `brief.md` R12.
- Lines: 699–705.
- Evidence: the R12 gloss says "one `Requester(path, port, reason)` per
  `StopFlag` output port, in build order". The next sentence bolds the same
  fact, and 704–705 add "requester roster order is build order". The first
  statement is plain, the bold comes second.
- Proposal: open the paragraph with the bold sentence, then "This list is
  the requester roster (gloss), and it names every request." Drop "and
  requester roster order is build order".
- Recommendation: adopt.
- Status: ruled, adopt.

### B9. R17's wording uses the reserved word "kind"

- Sources: chapter_pass_1 P1-16 (RULING); `brief.md` R17.
- Lines: 324 (old 10203).
- Evidence: "Three kinds of client share one resolution". *Kind* is reserved
  for diagnostics. Line 350 says "the three clients".
- Proposal: "Three clients share one resolution, and each gets the rule its
  promises require."
- Recommendation: adopt.
- Status: ruled, adopt: *kind* is reserved.

### B10. The inspection row cites D-310 for nothing it says

- Sources: chapter_pass_1 P1-18 (RULING); `brief.md` R2 and R16.
- Lines: 331.
- Evidence: the row reads "snapshot and log inspection ([D-310][d-310])".
  D-310 parks the GUI. The row no longer names the GUI panels, so the cite
  rules nothing the row says. R16 kept D-310 once "for the removal".
  Unit F cites D-310 at the front end's stop button (F53), which is where
  R2 wanted it cited once.
- Proposal: drop the cite from the row.
- Recommendation: adopt, amending R16.
- Status: ruled, adopt, amending R16: the row no longer names the GUI, so D-310 leaves §13.3. F53's citation in §13.5 stays.

### B11. A sketch comment uses "frame" outside R7's senses

- Sources: chapter_pass_1 P1-25 (RULING, a code edit); `brief.md` R7.
- Lines: 473.
- Evidence: "# the cursor's frame at the catch". R7 glosses *the cursor
  frame* as the copy of the cursor a `StepError` carries.
- Proposal: "# the cursor frame: the cursor's copy at the catch".
- Recommendation: adopt.
- Status: ruled, adopt: R7's term.

### B12. The companion pointer sits twice in nine lines

- Sources: chapter_pass_2 P2-17 (RULING); `brief.md` R13.
- Lines: 1004–1005 and 1013–1014.
- Evidence: the guidelines paragraph says the inventory "is
  `companions/library_inventory.md`"; R13's sentence after the list says
  "The shipped list lives in `companions/library_inventory.md`". R13 was
  written before the survey's move put the guidelines first.
- Proposal: cut the companion clause at 1004 and keep R13's sentence.
- Recommendation: adopt; R13 is the standing ruling.
- Status: ruled, adopt: R13's sentence is the standing one. Amended after application: the cut clause also carried "the Simulink mapping that prunes it", which the ruling failed to list (lesson 65). R13's sentence keeps it: "The shipped list, and the Simulink mapping that prunes it, live in `companions/library_inventory.md`."

### B13. "The author's, the integrator's" is stated twice in §13.5

- Sources: chapter_pass_2 P2-3 (RULING); `brief.md` R9.
- Lines: 756–758 and 878–879.
- Evidence: 756 "The request is the author's and the ignore list the
  integrator's"; 878 "The trigger is the author's knowledge and the ignore
  list the integrator's" (R9 folded it into the doctrine). 756–758 sits under
  "The scan and the source order" but is about the policy.
- Proposal: cut 756's first clause, keep "The ignore list sits beside
  `t_end` at the same declaration site", and move it to the end of "The
  policy per advance" (after 720).
- Recommendation: adopt.
- Status: ruled, adopt.

### B14. The operator path is the control plane, twice

- Sources: chapter_pass_2 P2-27 (RULING).
- Lines: 624–625 (moved up by M51) and 695–696.
- Evidence: the same claim sits in the section's opening and in the
  placement part. Neither is wrong.
- Proposal: cut the sentence at 695–696.
- Recommendation: adopt; 624–625 is the home.
- Status: ruled, adopt: the opening (M51) is the home.

### B15. The record carries the ending policy, twice

- Sources: chapter_pass_2 P2-27 (RULING).
- Lines: 718–720 (kept from "Why one binding site") and 801–802.
- Evidence: both say the termination record carries the policy that ended
  the run. The pass proposes no cut. Appendix B 13140 cites §13.5 for the
  lifetime (B35).
- Proposal: none.
- Recommendation: leave both. 718–720 keeps what the R4 pointer owes and
  801–802 is the record's own part.
- Status: ruled, no change: each states what its part owes.

### B16. "`StopRequest` holds no privilege" appears three times

- Sources: chapter_pass_2 P2-27 (RULING).
- Lines: 648, 684–685, 1019–1020.
- Evidence: §13.5 says it twice; §13.7 repeats it after a pointer at 1018.
- Proposal: reduce 1019–1020 to the pointer already at 1018.
- Recommendation: adopt.
- Status: ruled, adopt.

### B17. "The library's spelling of a request" appears three times

- Sources: chapter_pass_2 P2-27 (RULING).
- Lines: 657, 660 (bold), 1017.
- Evidence: 660 is D-316's bold; 657 and 1017 restate it.
- Proposal: cut "the library's spelling of a request" at 657.
- Recommendation: adopt.
- Status: ruled, adopt: the bold at 660 is the home.

### B18. The face routes of `show` sit in three places, and `Structure` in two sentences

- Sources: chapter_pass_2 P2-27 (RULING); unit G `verify.md` (the
  `Structure` link and sentence); `brief.md` R4 (q27, M60).
- Lines: 962, 981–983 (bold), 986–987; G's line 7 and line 25.
- Evidence: the verifier found the `#g-structure` link at line 25, but
  `show(::Structure)` first appears at line 7. R4 allowed one plain sentence
  on `show`; line 25's sentence says only that `Structure` has a `show`, in
  old text that agrees with the glossary.
- Proposal: move the link and gloss to line 7. Cut nothing else unless step
  6a finds 962 and 986–987 only repeat 981–983.
- Recommendation: adopt the link move. Rule the rest after the evidence
  check.
- Status: ruled, no change. A link cannot sit inside the code span at line 7, so the link stays at its first prose use. Lines 962, 981–983 and 986–987 each add detail: the commitment, the ruling, the mechanism.

### B19. "Integration intermediates" appear in a workspace sentence and in the quarantine

- Sources: unit F `rulings.md` (corrections proposed); `verify.md` (no
  drift).
- Lines: old 10675–10676 against 10716–10717; new 907–911 and the
  quarantine sentence.
- Evidence: one sentence says intermediates live in framework-owned
  integrator buffers, never in a workspace; the quarantine lists them among
  what the stores may hold mid-boundary. The `x` store is a range of the
  buffer (`#g-store`), so the two agree.
- Proposal: no change, unless the owner wants "integration intermediates in
  the `x` range" in the quarantine sentence.
- Recommendation: no change.
- Status: ruled, no change: the two sentences agree.

### B20. §13.5 lost its `#g-port` link

- Sources: chapter_pass_2 P2-24 (last bullet); old 747.
- Lines: first use of *port* in §13.5, near 646.
- Evidence: the old §13.5 linked `#g-port`; the new has none. The pass asks
  whether that is intended. No ruling drops it (R12 bars `#g-kind` only).
- Proposal: link *port* at its first use, with no gloss.
- Recommendation: adopt, subject to `check_glossary.jl`'s whitelist.
- Status: ruled, adopt: one `#g-port` link at its first use in §13.5. A link takes a gloss under `spec_style.md`; use the glossary's.

### B21. D-057's bold joins two clauses a semicolon separates

- Sources: unit A `rulings.md` and `verify.md`; `brief.md` R5.
- Lines: §13.1, the "Declarative checks over collected structure collect,
  and user-code evaluation fails fast" bold.
- Evidence: D-057's Position separates the two policies with a semicolon,
  so the strict test makes them two rulings. R5 counts them as one. The
  verifier passed the bold.
- Proposal: none.
- Recommendation: keep the bold as R5 dictates. It is one headline, the
  split by population; the entry's Position opens with "Reporting policy
  split:".
- Status: ruled, keep: D-057's Position opens "Reporting policy split:", one ruling R5 counted once, and the verifier passed it.

### B22. §13.5 states D-260's rule under D-255's cite

- Sources: inbound_check_2 #183 (OK with a note); unit F `rulings.md`
  (inbound citations).
- Lines: 801–802 (old 591).
- Evidence: the sentence "the termination record is the policy's one
  lasting home" is D-260's Spec ruling. Old 591 cited D-260 in the clause R4
  relocated. Appendix B 13140 also cites D-260 for "nothing else keeps one".
- Proposal: cite [D-260][d-260] beside D-255 at 802.
- Recommendation: adopt. It is a ruled cite, not a new claim.
- Status: ruled, adopt: D-260 is the old text's citation for the clause R4 relocated.

### B86. "Substitution is answered by the ignore list" reads cold

- Sources: chapter_pass_2 P2-5 (EDITORIAL, left as RULING by fixer 2).
- Lines: 877–878 at `5f21eba` (unit F).
- Evidence: the objection is D-060's Rejected list (log 1930–1932,
  "swapping an aircraft silently changes when runs end").
- Proposal: "A substitution that changes when runs end is answered by the
  ignore list."
- Status: ruled, adopt, with [D-060][d-060] in the sentence if the
  paragraph's citation does not already cover it; list it under
  Rationale-only rulings. Fixer 2's other leftovers: the rig gloss stays
  out, since the paragraph defines the rig; the `#g-port` link is B20.

### B87. The `Outputs` gloss uses *class*

- Sources: chapter_pass_1 P1-22 (EDITORIAL, left as RULING by fixer 1,
  since R19 kept the gloss).
- Lines: 403 at `5f21eba` (unit B).
- Evidence: "the port classes" uses the reserved *class*; the glossary's
  `#g-outputs` entry reads "per component the output port names each stage
  produces, and the execution order".
- Status: ruled, adopt, amending R19's keep (ruled before the reserved
  word was raised): "(the nominal evaluation's product, the output port
  names each stage produces and the execution order)". Fixer 1's other
  leftovers stand: P1-19's second half stays out (it would make "one site"
  false), and the chattering link stays unglossed.

## Landing

Edits outside the chapter that land with it, in file order. Old and new
texts are inbound_check's, quoted with wrapped lines joined.

### B23. §11.2 also says "Every cell is reachable"

- Sources: inbound_check_2 #29 (OK, with a note); `brief.md` "Edits at
  landing" (§11.2 7108).
- Lines: spec 7125 (§11.2), after the 7108–7109 edit.
- Evidence: the paragraph ends "Every cell is reachable, because the table is
  public throughout". Under R2 a binding is refused past a generic seam.
- Proposal: extend the landing edit to 7125, scoping it to a path through no
  generic seam ([§13.3][s13-3]).
- Recommendation: adopt.
- Status: ruled, adopt, with the 7108 edit.

### B24. Appendix A "The two observation sides" reads as a binding's reach

- Sources: inbound_check_2 #61.
- Lines: spec 12747.
- Evidence: "It sees everything", beside "Bind faces in anything meant to
  outlive the current build", reads as a binding's reach. R2 narrows it.
  §13.5 865–866 still says inspection sees every public cell, so the row holds.
- Proposal: cite [§13.3][s13-3] at that sentence.
- Recommendation: adopt, with B23.
- Status: ruled, adopt: inspection still sees everything, and the citation says where bindings differ.

### B25. §9.3 cites §13.1 for `UserCodeFraming`

- Sources: inbound_check_1 row 13 (RETARGET); survey_1 part D.
- Lines: spec 4706.
- Evidence: `UserCodeFraming` is §13.2's; §13.1 holds the fail-fast policy.
  Wrong before the rewrite.
- Proposal: "`UserCodeFraming`-wrapped build failure ([§13.1][s13-1],
  [§13.2][s13-2])."
- Recommendation: adopt.
- Status: ruled, adopt.

### B26. §9.5 says "that site's frame holds the boundary time"

- Sources: inbound_check_1 row 16 (MISSING); unit B `rulings.md`; `brief.md`
  R6's F12 and R7.
- Lines: spec 5085–5086.
- Evidence: after F12 the time is the clock at the failure; a table-write
  conformance failure inside integration carries a stage time.
- Proposal: "The carrier holds the clock at the failure and the replay
  pointer."
- Recommendation: adopt.
- Status: ruled, adopt (F12).

### B27. §10.6 calls the cursor a loop-state field

- Sources: inbound_check_1 row 20 (MISSING); survey_1 part D;
  `brief.md` "Edits at landing".
- Lines: spec 6531–6532.
- Evidence: the cursor is the executor's field (D-317 bullet 6). The brief
  lists 6531 under F20's "loop" to "model's" edit, but the survey and the
  check place the cursor sentence there. The brief's F20 edit may aim at the
  wrong sentence. Wrong before the rewrite.
- Proposal: "(the executor's field recording where execution stands,
  [§13.4][s13-4])". Check 6531 for a nonfinite "loop-state" phrase as well.
- Recommendation: adopt, and have the landing agent open 6531 first.
- Status: ruled, adopt. 6531 holds the cursor gloss and no nonfinite phrase (evidence check), so the brief's §10.6 F20 line is withdrawn and replaced by this edit.

### B28. Appendix B's `resolve` entry states the old two-rule primitive

- Sources: inbound_check_1 row 55 (MISSING); `brief.md` R6's F3; unit B
  `rulings.md`.
- Lines: spec 12831–12833.
- Evidence: the old chapter said `resolve` enforces the generic-holding rule
  for deep reads; after F3 it resolves one level, and the service walk
  enforces that rule.
- Proposal: "Resolves an immediate child, a container element's key segment
  included. Wiring resolution applies the one-level rule ([§6.1][s6-1]), and
  the service walk enforces the generic-holding rule ([§13.3][s13-3])."
- Recommendation: adopt after B1 settles the term.
- Status: ruled, adopt, with B1's term as amended.

### B29. Appendix C's stage line cites the bare §13

- Sources: inbound_check_1 row 62 (VAGUE).
- Lines: spec 13249; the build bullet below it.
- Evidence: §13.2 names the three stages. The build bullet "(an
  interface-connection body, a probe)" lags F5.
- Proposal: "The stages are the ones [§13.2][s13-2] names:". The bullet
  becomes "(a declaration body, a probe, an activation's continuous-tier
  function)".
- Recommendation: adopt both.
- Status: ruled, adopt both (F5).

### B30. Appendix C cites §13.2 for a collection that §9.2 now holds

- Sources: inbound_check_1 row 68 (RETARGET).
- Lines: spec 13296–13297.
- Evidence: R4 moved "a step that throws renders its warnings with the
  collection" to §9.2 (C-135).
- Proposal: "collection ([§9.2][s9-2], [D-250][d-250])."
- Recommendation: adopt.
- Status: ruled, adopt (R4, M9).

### B31. Appendix C's `StepError` row

- Sources: inbound_check_1 row 73 (MISSING); `brief.md` track 2 list; unit B
  `rulings.md`.
- Lines: spec 13617–13620.
- Evidence: the row states "boundary time" and four phases (F12, F14). Its
  place in the brief is as a track 2 item; the check supplies the text.
- Proposal: "Cursor frame (the component by its component-list index, the
  function, and the boundary phase: the frame-top drain, an integration
  stage, the arrival sweep, the θ = 0 validation, a localization trial,
  projection, an event round or the ticks), the clock at the failure,".
- Recommendation: adopt.
- Status: ruled, adopt (F12, F13, F14, R7).

### B32. Appendix C's `NonfiniteState` row says "state block" and "boundary time"

- Sources: inbound_check_1 row 74 (MISSING); `brief.md` R6's F20.
- Lines: spec 13623–13624.
- Evidence: fields come from `src/diagnostics.jl` 284–290: path, leaf, value,
  `t` (the frame-top time) and boundary. The row is not in the brief's list.
- Proposal: "Component path, the offending state leaf and its value, the
  frame-top time and the frame-entry boundary index."
- Recommendation: adopt.
- Status: ruled, adopt (F20, F32).

### B33. The glossary's execution-cursor entry

- Sources: inbound_check_1 row 84 (MISSING); `brief.md` R6's F13 and R7.
- Lines: spec 14689–14693.
- Evidence: the entry says the component path is "an index into the
  `Outputs`'s execution order", a claim F13 corrected, and "exception frames
  in the hot path" (R7).
- Proposal: "— the executor's plain mutable field recording where execution
  stands in the compiled order. It holds three facts, the component by its
  index in the structure's component list, the function running, and the
  boundary phase. It costs one cheap store per dispatch, so a runtime
  failure gets its cursor frame without exception handlers in the hot path
  ([§13.4][s13-4])."
- Recommendation: adopt.
- Status: ruled, adopt (F13, R7).

### B34. The glossary's `StopPolicy` entry cites §13.5 for text now in §12.1 and §12.6

- Sources: inbound_check_2 #77 (RETARGET).
- Lines: spec 14485.
- Evidence: the entry's citation set covers its whole text. "ControlRequestedStop
  is outside it" is §12.1's (8654); "afterwards only the termination record
  keeps one" is §12.6's (R4). §13.5 keeps the mask, the validation and the
  `t*` hit.
- Proposal: "([§12.1][s12-1], [§12.6][s12-6], [§13.5][s13-5],".
- Recommendation: adopt.
- Status: ruled, adopt (R4).

### B35. Six citations of §13.5 now belong to §12.6

- Sources: inbound_check_2 #32, #37, #52, #63, #68, #66 (the last optional);
  unit F `rulings.md` (inbound citations); `brief.md` R4.
- Lines: spec 7757–7758 (§11.5), 8655 (§12.1), 9849 (§12.7 table), 12875–12876
  and 13140 (Appendix B), 13129 (Appendix B's `t_end` row).
- Evidence: R4 left the per-advance declaration, the keywords and the
  lifetime at §12.6; §13.5 keeps one pointer sentence. The facts hold across
  the pointer, but §12.6 is the better target.
- Proposal: change `[§13.5][s13-5]` to `[§12.6][s12-6]` at 7757, 8655, 9849
  and 12875. At 13140 add §12.6 before §13.5 and keep D-260. At 13129 add
  §12.6 for "declared for this advance".
- Recommendation: adopt all six.
- Status: ruled, adopt all six (R4).

### B36. §9.7 cites §13.5 for "the seam is diagnostic only"

- Sources: inbound_check_2 #25 (MISSING); survey_2 part D.
- Lines: spec 5385.
- Evidence: §13.5 says nothing of the measurement seam. Wrong before the
  rewrite.
- Proposal: drop the cite, "The seam is diagnostic only, and it makes one
  promise."
- Recommendation: adopt; §9.7 is rewritten and a loose reading of §13.5's
  "no effect on run semantics" does not carry the claim.
- Status: ruled, adopt.

### B37. §11.5 cites §13.5 for run metadata

- Sources: inbound_check_2 #33 (MISSING).
- Lines: spec 7766.
- Evidence: neither the old nor the new §13.5 mentions run metadata; the
  glossary defines it (14551).
- Proposal: drop the §13.5 cite, leaving [Appendix B][sB].
- Recommendation: adopt.
- Status: ruled, adopt.

### B38. `extensions.md` mentions a §13.7 migration

- Sources: inbound_check_2 #229 (MISSING).
- Lines: `extensions.md` 334.
- Evidence: §13.7 has no migration. The parametric spelling it once carried
  fell with D-263 (D-311 bullet 3).
- Proposal: "get the parametric spelling in the migration — whether".
- Recommendation: adopt.
- Status: ruled, adopt.

### B39. `migration_outline.md` wires a NOT gate

- Sources: inbound_check_2 #285 (MISSING, a RULING on the wording); #131.
- Lines: `companions/migration_outline.md` 80.
- Evidence: D-311 does not admit `Not` ("a one-input gate consolidates
  nothing"). §13.7 lists `Or{N}` and `And{N}` only. The companion needs a
  `[d-311]` link definition.
- Proposal: "Falling-edge consumers negate the `Bool` in their own stage,
  since the library admits no `Not` ([D-311][d-311])."
- Recommendation: adopt.
- Status: ruled, adopt, with the companion's `[d-311]` link definition.

### B40. Three files place `Group` in "§13.7's starting inventory"

- Sources: inbound_check_2 #18, #148, #230.
- Lines: spec 3326 (§8.5); log 7017; `extensions.md` 346.
- Evidence: §13.7 1011–1013 lists the starting inventory without `Group`,
  while 1022 and 1027 put it in the library as the one member admitted by
  persona. The mismatch predates the rewrite (old 866, 887, 892).
- Proposal: in the two live files, "§13.7's library" in place of "§13.7's
  starting inventory"; annotate the log line in track 2.
- Recommendation: adopt.
- Status: ruled, amended (UNCONFIRMED: the wordings differ). Spec 3326 "part of the starting inventory ([§13.7][s13-7])" becomes "part of the library ([§13.7][s13-7])"; `extensions.md` 346 "§13.7's starting inventory" becomes "§13.7's library"; log 7017 goes to track 2 as an annotation.

### B41. "Local" for the sampled mode, in the glossary and `implementation.md`

- Sources: inbound_check_2 #80, #259; `brief.md` R28 (glossary entry to track
  2); unit G `rulings.md` (correction 3).
- Lines: glossary 14695–14698; `implementation.md` 933.
- Evidence: both say "local primal-carrying at sampled states" for the mode
  F63 now calls the sampled mode. §13.8 1292 keeps the gloss tying the names.
  The brief lists the glossary entry; `implementation.md` 933 is not in it.
- Proposal: the glossary entry reads "global value-blind, or sampled
  primal-carrying". At `implementation.md` 933, "the sampled mode".
- Recommendation: adopt both.
- Status: ruled, amended (UNCONFIRMED for `implementation.md`). The glossary entry reads "global value-blind, or sampled primal-carrying". `implementation.md` 933's "global on `true` and local on `false`" becomes "global on `true` and sampled on `false`".

## Track 2

Log repairs, annotations and entries owing a Position, one item per entry
(rule 10 of `decisions_style.md` governs annotations). Log lines are the
frozen `decisions.md`. Sources "S1" and "S2" are part E of `survey_1.md` and
`survey_2.md`; "ic1" and "ic2" are the inbound checks. A repair is an
annotation unless it says otherwise. Entries the rewrite only cites need no
repair beyond what is listed.

### B42. D-012

- Sources: S2 stale text; unit G `rulings.md`; `brief.md` R20 and R28.
- Evidence: Position (log 600) says "Stratum-B topological stall", the
  nominal evaluation since D-259. Rejected is cited for the residue and the
  back edge.
- Proposal: annotate the vocabulary. The glossary tracer entry is the
  brief's (R28).
- Recommendation: adopt.
- Status: open

### B43. D-030

- Sources: S2 (cited nowhere in §13.6; owes a Position); unit F
  `rulings.md`.
- Evidence: the discard-and-promote rule has no Position beyond "rejoins the
  protocol" and the Rejected "Mid-frame abort" (log 1089). The all-or-nothing
  boundary rests on that Rejected entry.
- Proposal: a Position or annotation stating that a boundary is
  all-or-nothing, so no torn final snapshot is published, and that the
  abnormal path discards the failed boundary and promotes the previous
  snapshot. Add §13.6 to the Spec field if absent.
- Recommendation: adopt.
- Status: open

### B44. D-057

- Sources: unit A `rulings.md` (inbound citations); S1 (cluster reasons).
- Evidence: Rejected (log 1839), "adjacent path-sorted pairs are
  self-explanatory", now disagrees with §13.1 after F4, which cut the
  adjacency claim. D-057's Rejected also holds the no-partial-results
  argument (S1 item 2), a reason that may need no Position.
- Proposal: annotate log 1839 with F4's wording ("the did-you-mean names the
  input the other error says is unfed").
- Recommendation: adopt the annotation; skip the Position.
- Status: open

### B45. D-058

- Sources: S1 stale text; ic1 (spec fields); unit A `rulings.md`;
  `brief.md` R11.
- Evidence: Position says "a single `BuildError`" (log 1847) and "Warnings
  ride the same stream and never throw" (1852), overtaken by D-222 and
  D-250. Rejected (1866–1867) "blocks a warnings-as-errors switch" values the
  switch R11 rejects. The compact-frame rendering has no Position (S1 item
  13, Rejected). Spec field lists Appendix C alone but D-058 rules §13.2.
- Proposal: annotate the three overtaken passages (the brief lists the R11
  one); add the Position for the `compact_backtrace` lesson; add §13.2 to
  Spec.
- Recommendation: adopt.
- Status: open

### B46. D-059

- Sources: S2 (Spec gains §13.6); unit B `rulings.md` (Rejected, log
  1889–1890).
- Evidence: §13.6 cites D-059 and D-387 for terminal status. The Rejected
  line "Framing information does not need to be caught into existence" backs
  §13.4's topic sentence and is not a Position.
- Proposal: add §13.6 to Spec. Leave the Rejected line as the reason.
- Recommendation: adopt the Spec change only.
- Status: open

### B47. D-060

- Sources: S2 (stale text; owes Positions); unit F `rulings.md`; `brief.md`
  R9 and R22.
- Evidence: Position (log 1899–1904) keeps "Tier-2 event" and "`stop_on`
  root faces at `Simulation` construction"; the policy clauses are annotated
  as superseded (1910–1916), the vocabulary is not. The inspection doctrine
  (observation-by-path, Rejected), compound stop logic composing in the
  model (annotation 1922–1924) and post-terminal dynamics being the model's
  job (Rejected, cited at row 569) have no Position.
- Proposal: annotate the vocabulary; add one Position clause stating the
  inspection doctrine and one for post-terminal dynamics.
- Recommendation: adopt.
- Status: open

### B48. D-061, D-130 and D-242

- Sources: `brief.md` (track 2 list, R26); ic1 row 184 and row 94; S1 (D-130,
  D-242 stale text, D-061 annotation); unit B `rulings.md`.
- Evidence: D-130 Position (log 4244–4252) lists GUI panels,
  `ReadBindingUnresolved` (retired by D-406 bullet 2) and the instance walk
  for bindings. D-242 Position (9508–9509) puts bindings under the instance
  walk. D-061's annotation of 2026-10-12 (1955–1961) says `resolve` walks
  declared field types; after F3 it is one level. The brief already sends
  all three; ic1 supplies D-242's text.
- Proposal: D-242, "Since [D-406][d-406] and [D-407][d-407], device read
  bindings and log extraction by series resolve on the service side; GUI
  panels are parked ([D-310][d-310]). The inspection case is snapshot and log
  inspection (§13.3)." D-130 and D-061 take the same pointer.
- Recommendation: adopt.
- Status: open

### B49. D-062

- Sources: S2 stale text and owed Positions; unit G `rulings.md`.
- Evidence: Position (log 1974–1979) says "`faces` gains predicate
  selection" (the selector is on the passthrough helpers, D-251), "The
  `Build` printer renders face routes" (`show(::Structure)`, D-257) and
  "demand-driven" (D-313, annotated). The annotation (1985–1989) covers
  neither. Rejected holds "a gain earns no block", the toolbox and the torture
  test, stated in §13.7 with no Position.
- Proposal: annotate the two stale phrases; add one Position clause that
  ordinary status keeps schema authority total.
- Recommendation: adopt.
- Status: open

### B50. D-071

- Sources: ic2 #93, #94; S2.
- Evidence: Position (log 2274) says "A `product()` helper is recorded for
  the §13.7 library, unbuilt"; Spec (2276) names §13.7 alone. §13.7 records
  no such helper; §14.9 does.
- Proposal: annotate "The helper is recorded in [§14.9][s14-9]. §13.7's
  library holds components only." Spec becomes `[§14.9][s14-9]` plus the
  trim sections the entry rules.
- Recommendation: adopt.
- Status: open

### B51. D-108

- Sources: S2 (owes a Position, item 10).
- Evidence: the stopped-sim services refuse an errored simulation (§13.6,
  row 591). The ruling rests on D-108's Rationale; §14 bolds it with D-059.
- Proposal: add the refusal to the Position.
- Recommendation: adopt.
- Status: open

### B52. D-114

- Sources: ic1 rows 112, 113, 114; S1 part D.
- Evidence: Position (log 3711), Spec (3719) and Rejected (3734) presuppose a
  counter plus recorded `t` that D-230 retired. Chapter 12's survey recorded it.
- Proposal: annotate "§13.4 indexes a failure by the frame-entry boundary
  index ([D-128][d-128], [D-230][d-230]). The counter-plus-recorded-t
  indexing this entry presupposes is historical, and §13.4 no longer rests on
  it."
- Recommendation: adopt.
- Status: open

### B53. D-120

- Sources: S2 stale text; unit G `rulings.md`; `brief.md` R21.
- Evidence: Position (log 3910–3914) says `faces(rig, child; except)` for
  `input_passthrough(rig, child; except)`, and Rejected says "slot-typing"
  (root inputs since D-206). §13.7 is the entry's home and cited it
  nowhere before the rewrite.
- Proposal: annotate both; make sure Spec lists §13.7.
- Recommendation: adopt.
- Status: open

### B54. D-131

- Sources: ic1 rows 119, 120.
- Evidence: Rationale (log 4298) and Rejected (4319) say §13.4 counts the
  five lifecycle states. §13.4 names only the terminal statuses and the
  return to built; §12.6 counts. Minor, wrong before the rewrite.
- Proposal: annotate "§13.4 names only the terminal statuses and the return
  to built; the five-state count is §12.6's."
- Recommendation: adopt.
- Status: open

### B55. D-132

- Sources: unit B `rulings.md`; S1 items 10 and 12.
- Evidence: Rationale (log 4341–4343) holds the routing of an
  `InterruptException` to the stop path and the defensive branch. D-317
  bullet 8 says "never wrapped" alone. §13.4 cites D-132 there.
- Proposal: state both in the Position.
- Recommendation: adopt.
- Status: open

### B56. D-136

- Sources: S1 item 6; unit A `rulings.md`.
- Evidence: the stream surfacing through the framework status rests on the
  Rationale (log 4623–4630). §13.2 cites D-136 plain; §11.8 bolds it.
- Proposal: add the surfacing to the Position.
- Recommendation: adopt.
- Status: open

### B57. D-141

- Sources: ic2 #130, #131; S2.
- Evidence: Rationale (log 5050) cites "§13.7's grow-by-migration-demand
  rule", retired by D-313. Rejected (5082) cites "§13.7's Bool gates covering
  falling-edge consumers", but D-311 rejects `Not` (the same fact as B39).
- Proposal: annotate both lines.
- Recommendation: adopt.
- Status: open

### B58. D-142

- Sources: ic2 #135.
- Evidence: Rationale (log 5132) cites "a published `Bool` output face plus
  `stop_on`, §13.5's existing machinery". Stop requests replaced `stop_on`
  (D-316). D-285 has the same sentence and annotates it at 12474; D-142 does
  not.
- Proposal: annotate as D-285 does.
- Recommendation: adopt.
- Status: open

### B59. D-143

- Sources: ic2 #139; S2; unit G `rulings.md`.
- Evidence: Position (log 5189) says "a root slot (§11.3)"; Rationale
  (5212–5214) cites "§13.7's strictly from demonstrated need charter", retired
  by D-313 and cut from §13.7 by F60. The annotation of 2026-10-12 covers
  `Pinned` and `y_types` only. The stub child as first shipped instance and
  the two uses rest on the Rationale alone.
- Proposal: annotate both stale lines; add the stub child and the two uses
  to the Position.
- Recommendation: adopt.
- Status: open

### B60. D-159

- Sources: ic1 row 138; S1.
- Evidence: Position (log 5915–5920) says "a sixth severity" and "§13.2's
  two-stream partition stands". D-214 fixed two severities and D-250
  replaced the two streams. No annotation, no supersession line.
- Proposal: annotate "Superseded in part by [D-250][d-250]: §13.2's
  two-stream partition is gone; a service warning lives on the artifact the
  call returns."
- Recommendation: adopt.
- Status: open

### B61. D-167

- Sources: ic1 rows 142, 143 (VAGUE); README (chapter 14 cites D-167).
- Evidence: Spec (log 6293) and Rationale (6305) cite the bare §13 for "both
  remedies in the message", which is §13.2's didactic style. D-167 is
  superseded.
- Proposal: no annotation unless the entry is kept live.
- Recommendation: no action.
- Status: open

### B62. D-203

- Sources: S2 (stale text, owed Positions, spec field); S1 (Spec lacks
  §13.2); ic2 #156.
- Evidence: Position (log 7710–7712) keeps the absent-time arm D-233
  retired, with no annotation. Three rulings have no Position:
  `EndTimeReached`'s bound is read off the record's policy (Rejected,
  annotation 2026-10-13), a stopped simulation answers "why" and "how" from the
  record (Rationale; D-260 Rejected), and the interrupt adds nothing to
  Appendix C (Rejected). Spec lacks §13.2.
- Proposal: annotate the absent-time arm; add the three to the Position; add
  §13.2.
- Recommendation: adopt.
- Status: open

### B63. D-223

- Sources: unit B `rulings.md`; S1 item 11.
- Evidence: the remedy for a condition that fails at `t₀`, a corrected
  condition (Rationale, log 8733–8734), is cited at §13.4.
- Proposal: move the remedy into the Position.
- Recommendation: adopt.
- Status: open

### B64. D-225

- Sources: unit B `rulings.md`; S1 item 9; `brief.md` F30.
- Evidence: Rationale holds the test spelling `@test_throws
  StepError{ConformanceFailure}` (log 8795–8799) and "the frame and the
  pointer are lost, and the lifecycle word does not move as it does on the
  framed path" (8805–8807), which F30 added to §13.4.
- Proposal: state both in the Position.
- Recommendation: adopt.
- Status: open

### B65. D-229

- Sources: S1 item 1; unit A `rulings.md`.
- Evidence: "Tier and event checking read only the component list, so they
  run and merge" rests on the Rationale (log 8968–8971). §13.1 bolds the
  Position's first sentence.
- Proposal: add to the Position.
- Recommendation: adopt.
- Status: open

### B66. D-248

- Sources: S1 item 3.
- Evidence: "A declaration takes no bundle, so only the plain frame applies"
  rests on the Rationale (log 9815–9816).
- Proposal: add to the Position.
- Recommendation: adopt.
- Status: open

### B67. D-250

- Sources: S1 item 5; unit A `rulings.md`; `brief.md` R11.
- Evidence: Position names `Build`, `Deployment` and `attach!`, never
  `trim!`. That a stopped-sim service's warnings live on its artifact rests
  on the Rationale (log 9945–9948) and the Rejected "superseded position"
  (9970–9972). Rejected (9967–9969) "§13.2 already rejects it" is now true
  after R11 (ic1 row 197 OK); the brief's annotation is for D-058.
- Proposal: add the stopped-sim case to the Position.
- Recommendation: adopt.
- Status: open

### B68. D-255

- Sources: S1 stale text; S2 ("annotated"); ic1 (Spec lacks §13.2); unit F
  `rulings.md`.
- Evidence: bullet 5 (log 10232) says "`Inf` and no faces", which D-316
  bullet 9 and D-203's annotation (7766–7769) replace with "no requester is
  honoured". S1 lists it as stale; S2 says D-255 is annotated for D-316. The
  sources disagree on whether D-255 itself carries the note.
- Proposal: check D-255 for the annotation; add it if missing; add §13.2 to
  Spec.
- Recommendation: adopt.
- Status: open

### B69. D-266

- Sources: S2 item 14.
- Evidence: `Freeze`'s cost and the sampler as the other non-walking source
  rest on the Rationale.
- Proposal: add to the Position.
- Recommendation: adopt.
- Status: open

### B70. D-312

- Sources: S2 item 13; unit G `rulings.md`.
- Evidence: `Constant`'s honest pin, and the pin for every block whose output
  depends on neither state nor a walking input, rest on the Rationale and the
  annotation of 2026-10-06.
- Proposal: add to the Position.
- Recommendation: adopt.
- Status: open

### B71. D-313

- Sources: S2 item 11; unit G `rulings.md`.
- Evidence: "A gain earns no block; the library is a toolbox" rests on the
  Rationale and D-062's Rejected.
- Proposal: add to the Position.
- Recommendation: adopt.
- Status: open

### B72. D-316

- Sources: S2 items 1, 3, 5; unit F `rulings.md`.
- Evidence: the inspection doctrine (Rationale, log 13899–13902), "an ignored
  request stays a cell, and the reason string tells the two uses apart"
  (13907–13911) and "the operator's path is the control plane" rest on the
  Rationale. §13.5 cites it at each.
- Proposal: add the three to the Position.
- Recommendation: adopt.
- Status: open

### B73. D-245 and D-349

- Sources: S2 item 16; unit G `rulings.md`.
- Evidence: D-349's Rationale carries interpolation being immune to the blind
  spot. D-245's Rationale carries the simple-cycle reduction and weighing a
  sampled dead hop. Both are cited in §13.8.
- Proposal: add each to its entry's Position.
- Recommendation: adopt.
- Status: open

### B74. D-096 and D-390

- Sources: ic2 #103, #227.
- Evidence: D-096 Rejected (log 3089) and D-390 Position (15691) speak of
  "the cost §13.5 rejects". §13.5 names the rejection of predicate closures;
  the cost is in D-060's Rejected list, which §13.5 cites. Predates the
  rewrite.
- Proposal: none.
- Recommendation: no action.
- Status: open

### B75. D-383, D-384 and D-385

- Sources: ic2 #224, #225, #226 (COMPANION).
- Evidence: their Spec fields (log 15430, 15514, 15556) name §13.7 for
  inventory content that lives in `companions/library_inventory.md` and
  `lqr_tracker.md`. §13.7 points there, as the old text did.
- Proposal: none.
- Recommendation: no action.
- Status: open

### B76. Half 1 rulings with no entry

- Sources: S1 "Rulings with no entry at all".
- Evidence: the didactic frame rendering first (row 40); the author's own
  tuple with bundle names (47); a kind is a Julia type (29); the stream
  never collected (70); the service-path remedy of declaring the concrete
  type (103; `test_readers.jl` 279–283 cites D-125); NaNs defeat guards (161,
  163, 167, reasons). The index sentence (74), the collecting-check list (6)
  and the cursor's "environment closures" (114, cut by F15) are descriptions.
  The `resolve_terminal` claim (105) was false and is cut.
- Proposal: no new entry. Check D-125 for the remedy; add the rest to the
  entry the chapter cites beside each.
- Recommendation: adopt.
- Status: open

### B77. Half 2 rulings with no entry

- Sources: S2 "Rulings with no entry at all"; unit F `rulings.md` (F54).
- Evidence: the entry check reading the latest snapshot before the first
  frame (F51; D-138's annotation agrees); the two shapes of a request needing
  no latching (566); tail hygiene, each hook caught and logged (587); the
  cycle loop rendered as terminal pairs in slash form (680); classification
  touching no activation machinery (697); the wiring diagnostics sharing the
  route rendering (F59); the two channels meeting only at §12.4 (576); the
  `t_end` range (F54, `_t_bound` in `src/sim.jl`; D-255 says "validated per
  call" only).
- Proposal: state F51 and F54 in D-255; leave the rest as descriptions.
- Recommendation: adopt.
- Status: open

### B78. Spec fields that omit a section the chapter cites

- Sources: S1 and S2 part D; ic1; unit rulings.
- Evidence: entries that rule or are cited in a section their Spec field
  omits: D-019, D-084, D-147, D-218 (§13.5; D-218 also §13.4); D-022, D-261,
  D-274, D-294, D-389 (§13.4; D-261 also §13.7); D-401, D-251, D-254 (§13.2;
  D-251 also §13.7); D-224, D-394, D-398 (stated at rows 148, 151, 152);
  D-406 (§13.3); D-407 (cited §13.3, lists §11.2); D-231 (§13.7); D-364,
  D-322 (§13.7); D-387 (§13.6).
- Proposal: add each section to its entry's Spec field. A script should
  compare every `[D-nnn]` cited in the chapter with the entry's Spec field,
  since the rewrite added citations beyond this list.
- Recommendation: adopt, with the script run first.
- Status: open

### B79. Entries needing no action

- Sources: S1, S2, ic1, ic2.
- Evidence: D-097 (annotated 2026-10-15), D-073 (log 2338), D-203 Rejected
  (7771), D-274 (11919) and D-285 (12474) are annotated already. D-091 is
  superseded by D-255. D-253 and D-268 were replaced in the chapter by D-261
  and D-398. D-261's superseded bullet carries D-316's Supersedes line. D-261's
  `StepError` bullet (log 10637) is right; only the spec's "boundary time"
  was wrong. D-114's and D-131's cites are handled at B52 and B54.
- Proposal: none.
- Recommendation: no action.
- Status: open

## Carried

Items for chapter 14, the front matter and the appendices. Chapter 14 is not
yet rewritten, so its citations of this chapter go with its rewrite.

### B80. Part IV's roadmap still says §13 fixes only how a failure is reported

- Sources: unit A `rulings.md` (inbound citations); `brief.md` R1.
- Lines: spec 9904 (Part IV roadmap).
- Evidence: the opening now adds "and what the framework offers around it".
  R1 leaves the Part IV roadmap to the front-matter rewrite. The brief
  already carries its omissions of §13.3, §13.6 and §13.7.
- Proposal: carry this sentence with those omissions.
- Recommendation: adopt.
- Status: ruled, carried to the front matter in `README.md`, with the roadmap's omissions.

### B81. The glossary's `#g-entry` lacks the wiring entry

- Sources: S1 "Findings carried from earlier chapters" (Appendix D item);
  unit A `rulings.md` (bare *entry*).
- Lines: glossary 13856; §13.3's "wiring entry"; §13.2's "entry point".
- Evidence: §6.1 and §13.3 use "wiring entry"; the glossary says "never
  used bare" and lists table, input, executor, roster, batch and condition
  entries. The rewrite keeps "wiring entry" and "entry point" as written.
- Proposal: add the wiring entry to `#g-entry` in Appendix D's rewrite.
- Recommendation: adopt.
- Status: ruled, carried to Appendix D in `README.md`.

### B82. §14.8 cites the bare §13 for a §13.5 doctrine

- Sources: ic1 row 50 (RETARGET); S1 part D.
- Lines: spec 12180–12181.
- Evidence: "exceptions-are-broken-machinery line" is §13.5's ("exceptions from
  model code are always abnormal"). Wrong before the rewrite.
- Proposal: "([§13.5][s13-5])".
- Recommendation: carry to chapter 14's rewrite.
- Status: ruled, carried to chapter 14 in `README.md`.

### B83. §14.2 calls `set`, `at` and `combine` §13.7 library material

- Sources: ic2 #54 (MISSING, a RULING); S2 part D.
- Lines: spec 11338.
- Evidence: §13.7's library is `Redstone.Blocks`, components only; the
  condition algebra lives in `src/conditions.jl` and §14. §13.7 does state
  that its blocks are ordinary components with no privileges.
- Proposal: "`set`/`at`/`combine` are ordinary artifacts with no privileges,
  as [§13.7][s13-7]'s library blocks are ordinary components."
- Recommendation: carry to chapter 14's rewrite.
- Status: ruled, carried to chapter 14 in `README.md`.

### B84. §14.9 says a `product(...)` helper belongs in the §13.7 library

- Sources: ic2 #57 (MISSING, a RULING); S2 part D; pairs with B50.
- Lines: spec 12351.
- Evidence: D-071's Position records it so, but §13.7's library holds
  components, not helpers.
- Proposal: "helper belongs in the framework ([D-071][d-071])."
- Recommendation: carry to chapter 14's rewrite, with B50.
- Status: ruled, carried to chapter 14 in `README.md`, with B50.

### B85. `frame_walkthrough.md` 283 names a function `src/` does not define

- Sources: ic1 observation (row 264).
- Lines: `companions/frame_walkthrough.md` 283.
- Evidence: the citation to §13.4 holds, but the sentence names
  `_host_boundary_zero!`, which `src/` does not define, and says `replay!`
  runs boundary zero. Spec 9429–9431 says `restore!` and `replay!` run no
  boundary zero. The check did not open the code; step 6a should.
- Proposal: correct the companion against §12.4 and the code.
- Recommendation: carry to the companions' pass.
- Status: ruled, to track 2: a problem outside the chapter (recipe step 8).
