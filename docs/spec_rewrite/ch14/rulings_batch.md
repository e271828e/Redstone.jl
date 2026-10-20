# Chapter 14 rulings batch (step 6)

Items B1 onward, in four groups: Blocking, Landing, Track 2, Carried. Sources
are the units' `rulings.md` (U-rul) and `verify.md` (U-ver), `chapter_pass_1.md`
(P1-n), `chapter_pass_2.md` (P2-n), `inbound_check_1.md` and `_2.md` (IC1, IC2,
by row or line), the surveys' part E (S1-E, S2-E), `brief.md` (R1 to R39) and
`step5_carry.md`. Chapter lines are `chapter_new.md` lines as the passes read
them, before the editorial fixers; re-find each by its quoted text. Spec and
log lines are the frozen `c3d29fb` lines unless a file is named.

Not in the batch. Every correction in the units' `rulings.md` already ruled
by R17 to R39 is settled. `escalations.md` E1 is the owner's. F80 (the code's
positional `at` lift against D-188's keyword spelling) goes to the owner as a
loose code fix. The unit verifiers' remaining editorial nits (wrap, links,
reader-cold clauses) are the pass's EDITORIAL findings and belong to the
fixers. Two verifier notes need no edit: unit F's correction 4 (the residual
return is also re-checked at the first seeded evaluation) is F52's list in
unit G, and unit H's C-081 (the "three-component" chain, accepted).

## Blocking

The chapter cannot land with these open. They run roughly by weight. The
first eleven are the passes' RULING findings with their dependants; B12 to
B20 are corrections the units left open.

### B1. The §14.4 heading says "One plan"

Sources: P1-14; R37; IC1 (titles unchanged).
Lines: chapter heading 14.4 (362); §14.3 313-316; §14.4 375, 379, 401. Old
heading, spec 11559. Contents entry at spec 98.
Evidence: R37 fixed that the entry list compiles to two plans. §14.3 states
both, and §14.4 itself says "the compiled plans" and "its own plan". D-066's
"one compiled plan" is the reading F16 corrected. The heading is the one
place that still says one plan. Inbound citations use the number only (IC1).
Proposal: retitle to "14.4 Two ways to apply a resolved condition". The
Contents entry follows at landing (B28).
Recommendation: adopt. The heading is a claim, and it now contradicts the
body. Check by grep that no file quotes the old title.
Status: ruled, adopt. Retitle §14.4 "Two ways to apply a resolved condition". Only spec.md 98 (Contents) and 11559 quote the old title; the Contents entry lands with B28, and linkify regenerates the anchors.

### B2. R5's live-store pointer cites §14.7, which does not state it

Sources: P1-23; P2-47; U-rul B correction 4.
Lines: chapter 475-477 and 511-513 (§14.4).
Evidence: the sentence reads "a reader that runs over live stores, which
today are the services' ([§14.7][s14-7], [§14.10][s14-10])". §14.7's reads
(chapter 807-834) never say trim's readers run over stores.
§14.8's "Scratch stores" (chapter 1048-1060) does. Lines 475-477 also say
`checkpoint` and post-run inspection "hold live stores", which a cold
reader sets against F22, since they take no selector (`src/readers.jl`
36-42).
Proposal: cite [§14.8][s14-8] in place of [§14.7][s14-7]. Add to the
sentence at 475-477, or to the F22 sentence, "`checkpoint` and post-run
inspection hold live stores but take no selector". R5 dictated the old
citation, so this amends R5.
Recommendation: adopt both. The pointer is wrong, and the second clause
removes the apparent conflict at no cost.
Status: ruled, adopt both. Cite [§14.8][s14-8] for [§14.7][s14-7]. At the live-stores sentence (old 475-477), add that of the holders only the services' readers take a store selector: the code's only executor-source readers are trim's and linearization's (`src/readers.jl` 36-42). This amends R5's dictation.

### B3. "Snapshot inspection reads a cell by path and port name" cites §11.2, which never says so

Sources: P1-22; R5 (F21).
Lines: chapter 510-511 (§14.4).
Evidence: §11.2 (spec 6912-7166) has no path-and-port-name read. F21's
evidence is the code, `port(snapshot, path, name)` (`src/dataplane.jl`
480-481). Appendix B lists only `port(model, path, name)` (spec 13039).
Proposal: keep the sentence. Cite [§11.2][s11-2] for the word "snapshot"
alone, by moving the pointer to "Snapshot inspection ([§11.2][s11-2])", and
carry an item that Appendix B owes the snapshot form of `port` (B76).
Recommendation: adopt. It keeps R5's sentence and stops the citation from
claiming more than §11.2 holds.
Status: ruled, adopt. The pointer moves to "Snapshot inspection ([§11.2][s11-2])". B76 carries Appendix B's snapshot form of `port`.

### B4. The D-069 bold names the wrong owner

Sources: P2-6; U-ver F ("Owners", "Re-check" C-065 nit); `step5_carry.md`
(unit F item); R23.
Lines: chapter 895-899 (§14.7, "The formulation").
Evidence: the bold says FlightPhysics' formulation has a core whose
7-variable search is `c172.jl`'s `TrimState` (`lib/FlightApps/src/c172/c172.jl`
796, `TrimState <: AbstractTrimState{7}`). Only `θ_constraint`
(`aircraftbase.jl` 110) and `AbstractTrimState` (92) are FlightPhysics'.
Proposal: "**Flight.jl's trim formulation is correct at its core and survives
verbatim as user math** ([D-069][d-069])", next sentence unchanged. The
owner clauses that follow name FlightPhysics and `c172.jl` as the source
shows.
Recommendation: adopt. "Flight.jl's" is true of both owners and keeps the
bold one clause.
Status: ruled, adopt the proposed bold. R23 and P2-6: the 7-variable `TrimState` is `c172.jl`'s, `θ_constraint` FlightPhysics'.

### B5. The §14.2 bold "It is `ConditionNodeMisuse`" has a pronoun subject

Sources: P1-12.
Lines: chapter 264 (§14.2).
Evidence: under the one-bold test the bold is the ruling's headline clause,
and "It" does not say what is decided. D-113 bullet 4 rules the error and
its kind.
Proposal: "**The blend rejection is `ConditionNodeMisuse`**
([Appendix C][sC], [D-113][d-113])". The bold span stays one clause.
Recommendation: adopt.
Status: ruled, adopt. The context (new 260-266) is the blend of a node with a bare NamedTuple, so "The blend rejection" names it.

### B6. The D-155 bold in §14.5 sits on a framing clause

Sources: P1-31; R7, R18.
Lines: chapter 655-658 (§14.5).
Evidence: D-155's headline is "Projection is named the second legitimate
mover of the committed point". The bold sits on "A commit-fired handler is
not the only mover", which frames it.
Proposal: "A commit-fired handler is not the only mover. **Projection is the
second, and it is unconditional** ([D-155][d-155]). Boundary zero's *first*
act is ...", rest unchanged.
Recommendation: adopt. This is the first of D-155's two bolds and is homed
in §14.5 (R7), so the bold must carry the ruling.
Status: ruled, adopt. D-155's headline is projection as the second mover.

### B7. The `at` lift sketch's comment contradicts the prose

Sources: P2-28; D-277 Position.
Lines: chapter 1348 (sketch comment), 1360 (prose), §14.9.
Evidence: the comment says "the prefix joins the read set's mount chain".
The prose and D-277 say `at` "prepends the prefix to that chain and joins
nothing". Comments in code blocks change only by ruling.
Proposal: change the comment to "#inert selector data: the prefix is
prepended to the read set's mount chain".
Recommendation: adopt. It is the one comment edit the sketch needs, and it
removes a false word.
Status: ruled, adopt. The one comment edit of the sketch, to D-277's "prepends … and joins nothing".

### B8. "Raises `TrimCommitEvents`" reads as a throw

Sources: P2-24; IC2 (spec 10141); brief ("Edits at landing", F79).
Lines: chapter 1207, 1214, 1222 (§14.8, "The report"). Paired with B24.
Evidence: nothing in the chapter says the three `TrimCommit...` kinds are
logged warnings. D-262 says "a logged warning that rides the report".
Appendix C says "Warning · service · logged". `src/trim.jl` 620-644 logs
them with `@warn`. "Raises" sits near "Non-convergence never throws".
Proposal: once, at 1207: "also raises `TrimCommitEvents`, a logged warning
([Appendix C][sC], [D-126][d-126])". Later mentions keep "raises".
Recommendation: adopt. It adds one claim the sources state and that F79's
landing edit (B24) needs the chapter to carry.
Status: ruled, adopt, once at the first "raises `TrimCommitEvents`"; B24 fixes §13.2 at landing.

### B9. Two pointers at each other: the `residuals`/`tolerances` field

Sources: P2-21; R7.
Lines: chapter 1179 (§14.8, "The report"); §14.5 661-662; chapter 1215-1216.
Evidence: the field cites "[§14.5][s14-5], [D-155][d-155]". §14.5 does not
state the two residual sets. It says the remedy is "specified with the
report in [§14.8]". The move §14.5 is meant for is named at 1215-1216, which
cites §14.5 already.
Proposal: drop "[§14.5][s14-5]" at 1179 and keep D-155.
Recommendation: adopt.
Status: ruled, adopt.

### B10. "The no-silent-zeros rule again" has no antecedent

Sources: P2-35.
Lines: chapter 1504-1505 (§14.10, "The operating point").
Evidence: the zero-column rejection comes later (1575), so "again" points
at nothing. The rule's prose is §9.5's "Deliberate stripping". D-197 is cited
in two consecutive sentences.
Proposal: "That is the no-silent-zeros rule ([§9.5][s9-5])." Keep one D-197
citation, on the sentence that states its ruling.
Recommendation: adopt.
Status: ruled, adopt.

### B11. "Shipped rig" in §14.9

Sources: P2-32; R26, R29; U-rul H question 3.
Lines: chapter 1416 and 1435 (§14.9, the D-071 bullet 4 bold and its
restatement).
Evidence: no source holds a `design_world`. R26 dropped "shipped" from
§14.10's gloss: "the rig this design records for design-time work". D-071
bullet 4 says "shipped rig". §14.9 still says it twice.
Proposal: at 1416 write "the rig this design records" inside the bold,
keeping D-071 in the sentence. At 1435, keep the sentence only for any claim
the bold lacks, and cut it otherwise; list the cut clause's claims in the
inventory (recipe step 6, chapter 13 lesson).
Recommendation: adopt, so §14.9 and §14.10 agree. The glossary word is a
Track 2 item (B74).
Status: ruled, adopt; list the claims of any clause cut at the restatement (lesson 75).

### B12. The saturation bullet says the report "names the saturated variable"

Sources: U-rul G correction 1.
Lines: §14.8, the saturation bullet R15 keeps (old spec 12364-12365; find by text).
Evidence: `_saturated` (`src/trim.jl` 588-596) lists decisions at their own
box bounds and nothing else. An in-model saturation shows only in the
Jacobian's zero columns. D-070 bullet 5 ("LM-tolerated, reported") carries
the same looseness.
Proposal: "LM damping tolerates the rank deficiency ([D-070][d-070]). The
report's `saturated` list names a decision only at its own bound, so an
in-model saturation shows in the Jacobian's zero columns rather than in the
report." Track 2 annotates D-070 bullet 5 (B59).
Recommendation: adopt. The old sentence overstates what the report holds.
Status: ruled, adopt. `_saturated` compares each decision with its own bounds only.

### B13. "Reach any port the structure has" is false of `get_state` and `get_deriv`

Sources: U-rul F correction 3 (survey row 528).
Lines: §14.7, "Reads" (old spec 11949-11951, unit F's old 76-78; find by text).
Evidence: `get_state` and `get_deriv` reach a state field, not a port.
Proposal: "reach any port or state field the structure has".
Recommendation: adopt. It fixes a plain misstatement and adds no claim.
Status: ruled, adopt.

### B14. "The default width's scalar type is public"

Sources: U-rul H ("One stated fact the code does not bear out"); U-ver H
("Other"); P2-37.
Lines: chapter 1541-1545 (§14.10, "The tap set").
Evidence: `LinearizeDual` (`src/linearize.jl` 64) is neither exported nor
declared `public` (`src/Redstone.jl`). P2-37 splits the sentence and keeps
"public".
Proposal: write "is named" in place of "is public", in P2-37's split
sentence. Add the `public` declaration to the loose code fixes reported to
the owner with F80.
Recommendation: adopt the text change. The following claim (a build
pre-materializes its activation through `activations`) needs only that the
type can be named.
Status: ruled, adopt "is named". Appendix B does not list `LinearizeDual`, and the export question belongs to the exported-name audit (D-226), not to F80's loose code fix.

### B15. §14.10 does not say what a bad seeded tap does

Sources: U-ver H ("Code checks", R14 gap).
Lines: §14.10, the seeded tap's leaf rule (unit H inventory V13, V14, V17; find by text).
Evidence: V13 and V14 state the seeded tap's limits and never say a
violation is rejected. The code does: `_check_seedable` (`src/linearize.jl`
336-347) raises `:unseedable` and `:vector_tap` as `TapResolution`. The
re-check of unit H does not say the fix was applied.
Proposal: add "; any other is rejected as a `TapResolution`" at V13/V14, and
"as a `TapResolution`" at V17. If the text already says so, close the item.
Recommendation: adopt after one grep. R14 requires the kind where the
section states the condition.
Status: ruled, adopt. Checked: units/H/new.md 27-33 states the seeded tap's limits and never says a violation is rejected. Add after the `Float64` sentence: "Any other seeded address is rejected at resolution as a `TapResolution`."

### B16. "Useful in its own right and free"

Sources: U-rul G correction 3.
Lines: §14.8, the empty problem (old spec 12335-12336; find by text).
Evidence: the empty problem costs one residual evaluation (`src/trim.jl`
481-485). D-156 says only "useful in its own right".
Proposal: "which is useful in its own right and costs no solve".
Recommendation: adopt.
Status: ruled, adopt.

### B17. A bare "entry" in a verbatim table

Sources: P2-40; R13; brief ("the table stays verbatim").
Lines: chapter 1595 (§14.10, the table).
Evidence: the table says "a root input whose entry is declared `Pinned`".
The prose says "input entry". R13 bans bare *entry*.
Proposal: "a root input whose input entry is declared `Pinned`". It changes
one word of one cell and no structure.
Recommendation: adopt. "Verbatim" governs the table's layout, and the reserved
word governs this cell.
Status: ruled, adopt. The reserved word governs the cell; the table's layout stays.

### B18. §14.10's default point has no pointer back to §14.6

Sources: P2-48; R3.
Lines: chapter 1531, 1537-1539 (§14.10).
Evidence: D-272 places the `about` point under `init!`'s legality. R3 makes
it a totality site, and §14.6 points here. §14.10 does not point back. The
application to its own scratch holds.
Proposal: "... without touching the sim, its coverage checked as
[§14.6][s14-6] requires".
Recommendation: adopt. It states R3's fourth site where the site lives.
Status: ruled, adopt.

### B19. D-188's keyword spelling at the `at` lift sketch

Sources: U-rul G question 4.
Lines: §14.9, the `at` lift sketch (old spec 12385 region).
Evidence: q24 proposed one sentence, "The lift builds its problem by keyword,
as every `TrimProblem` is built ([D-188][d-188])". No old sentence states it.
Proposal: add none. The sketch stays verbatim and keyword-form.
Recommendation: decline. The rewrite adds no claim no old sentence makes,
and D-188 stays a log citation through F80's code fix.
Status: ruled, decline, as recommended. No sentence is added.

### B20. Seven D-071 bolds in §14.9

Sources: U-rul G question 6; P2 checks ("D-071 (7) ... match their
Position's ruling count").
Lines: §14.9, chapter 1310-1450.
Evidence: bullets 3 to 6 (the world wrapper, `design_world`, the swarm, the
`product` helper) are rulings of the entry. The pass counted seven bolds
against seven rulings under the one-bold test.
Proposal: keep all seven, option (a).
Recommendation: adopt. The pass checked the count, and plain bullets would
leave rulings at home unbolded (R7).
Status: ruled, keep all seven, as recommended.

## Landing

Edits outside the chapter that land with it, in step 7's order: inbound
citations first, then the glossary and appendices, then the companions.
`brief.md`'s "Edits at landing" lists B21 to B25 in part. Each item merges
with the brief's entry and adds the evidence the checks found since. The
README strike-out of chapter 14's carried items, the `REWRITTEN` entry in
`check_bold.jl` and F80's report to the owner stay as the brief has them.

### B21. The totality sites list four, not three

Sources: brief (R3, R34, "Edits at landing"); IC1 rows 32, 48, 130; U-rul B.
Lines: spec 4690-4692 (§9.3), 7333-7334 (§11.3), 14770-14772 (glossary,
totality entry).
Evidence: all three lists read "`init!`, trim setup and trim commit" and
count three. §14.6 now lists four, with linearization's `about` (R3).
R34 makes §14.6 the bold home of D-149, so §9.3's bold on the same ruling
goes plain.
Proposal: add "and linearization's operating condition under `about`" to
each list, and its count to four. At §9.3, remove the bold and point to
[§14.6][s14-6].
Recommendation: adopt, as the brief and R34 rule.
Status: open

### B22. Glossary `#g-baseline` and "all four services"

Sources: brief (F26, R1); IC1 rows 122, 132; U-ver B.
Lines: glossary 14719 (`#g-baseline`), 14780 (`#g-service-lifecycle`).
Evidence: `#g-baseline` says `init!`/`trim!` take the `baseline` keyword, and
`init!` takes none (F26). The opening of §14 now names five services (R1).
Proposal: drop `init!` from `#g-baseline`. Change "all four services" to
"all five", or to the list R1's sentence gives.
Recommendation: adopt.
Status: open

### B23. Glossary `#g-selector` keeps "before any client policy applies"

Sources: R31; IC1 row 118; U-rul B correction 2.
Lines: glossary 14580 (and 14577-14578).
Evidence: R5 leaves no client policy that applies, and §14.4 dropped the
clause. IC1 row 118 is the deliberate loss.
Proposal: "against a source. Table sources are a ..." (IC1's new text).
Recommendation: adopt.
Status: open

### B24. §13.2 calls the `TrimCommit...` kinds report fields

Sources: brief (F79); IC2 (spec 10141); B8.
Lines: spec 10139-10141 (§13.2).
Evidence: `src/trim.jl` 620-644 logs the three with `@warn`. The report holds
`fired_events`, `committed_residuals` and `committed_checks`. IC2 notes that
the paragraph's opening, "so its warnings live on it", needs the same check.
Proposal: IC2's text: "`trim!` returns a `TrimReport`, which holds the fired
events and both residual sets, and logs `TrimCommitEvents`,
`TrimCommitResiduals` and `TrimCommitChecks` beside it ([§14.8][s14-8])."
Reread "so its warnings live on it" and reword it to match.
Recommendation: adopt, with B8 in the chapter.
Status: open

### B25. §9.6 on the fallback and `get_x_ss`

Sources: brief (R10, F64); IC2 ("Survey 2's part D, confirmed").
Lines: spec 5113-5114, 5122-5123 (§9.6).
Evidence: 5113-5114 says the derivative-free fallback "runs". §14.8 writes it
as design (R10), and `pending.md` line 158 lists "The NLopt fallback". The
`get_x_ss` deletion pointer at 5122-5123 follows F64.
Proposal: write the fallback as designed and not yet built, with the
[D-070][d-070] and `pending.md` pointer; fix the `get_x_ss` pointer after F64.
Do not use the term "recorded, not built" (R10).
Recommendation: adopt, as the brief rules.
Status: open

### B26. Appendix B rows that cite the chapter wrongly

Sources: IC2 (spec 13200, 13201, 13212); S2 part D.
Lines: spec 13200, 13201, 13212 (Appendix B, `trim!(sim, ...)`).
Evidence: 13200 says the problem "closes at seven fields", and §14.7 states
nine (D-262). 13201 spells the commit `override(baseline, solution)`, where
F61 corrected §14.8 to `override(baseline, condition(d*))`. 13212 cites
§14.7 for "Non-convergence reports, never throws", which only §14.8 states.
Proposal: "closes at nine fields"; `override(baseline, condition(solution))`;
"Non-convergence reports, never throws ([§14.8][s14-8])."
Recommendation: adopt. Each wrong spelling is exact in IC2.
Status: open

### B27. Appendix C citations that point at the wrong section

Sources: IC1 row 109; IC2 (spec 13723); S1-D F5; S2-D F71.
Lines: spec 13735 (`ReadSetMisuse`), 13722-13723 (`ArgumentInvalid`).
Evidence: §14.4 never stated `ReadSetMisuse`, and §14.9 does (R14). The
`ArgumentInvalid` row lists §14.7, which raises none. `:non_nominal` and
`:claimed` sit in §14.8 ("The backend seam") and `t0` without `about` in
§14.10 ("The operating point").
Proposal: 13735 cites [§14.9][s14-9]. 13723 ends "..., [§13.5][s13-5],
[§14.8][s14-8], [§14.10][s14-10])."
Recommendation: adopt. The content updates of the same rows are B75.
Status: open

### B28. Contents entry for §14.4

Sources: P1-14 (B1).
Lines: spec 98 (the Contents).
Evidence: B1 retitles §14.4.
Proposal: change the Contents entry to B1's new title, if B1 is adopted.
Recommendation: adopt with B1.
Status: open

### B29. Glossary entries that state the chapter wrongly

Sources: IC2 (spec 14791-14792, 14904, `taps` 14782-14786); IC1; R24; U-rul H.
Lines: glossary 14791-14792 (`TrimProblem`), 14904 (`recorded, not built`),
14782-14786 (`taps`).
Evidence: `TrimProblem` keeps `override(baseline, solution)` (as B26).
`recorded, not built` lists "declarative non-participation", and §14.10 says
both halves have a spelling, so only the tooling is recorded (D-263, D-286).
`taps` lacks the seeded tap's limits (one index step, no `.name` step, a
`Float64` leaf; F53, R24).
Proposal: `override(baseline, condition(solution))`; "the sampled-data `Dual`
activation and the tooling over declared non-participation, [§14.10]"; add
the limits to `taps`.
Recommendation: adopt.
Status: open

### B30. Companion pointers into the chapter that were wrong before the rewrite

Sources: IC1 rows 341, 350, 354; IC2 (`lqr_tracker.md` 184,
`pid_anti_windup.md` 493).
Lines: `companions/linearization_walkthrough.md` 370;
`companions/trim_environment_walkthrough.md` 65, 537, link block ~900-905;
`companions/lqr_tracker.md` 184; `companions/pid_anti_windup.md` 493.
Evidence: the selector spellings at 370 lost their trailing index at D-276.
The two `trim_environment` lines cite §14.2 for a rejection that is D-064's.
The two `Freeze` lines cite §14.10, which only points to §13.7.
Proposal: the replacement text in IC1 rows 341, 350, 354 (leaf-address
spellings and D-276; D-064 for the third-sweep rejection, with its link
definition added after `[d-008]` and the unused `[s14-2]` definition at 905
removed) and IC2 (`Freeze` lines cite [§13.7][s13-7]).
Recommendation: adopt. IC1 and IC2 give exact old and new text.
Status: open

### B31. The C172 audit row and its added paragraph

Sources: IC2 (`migration_outline.md` 28); R15; U-rul G.
Lines: `companions/migration_outline.md` 28; `units/G/companion_addition.md`.
Evidence: R15 moves the gear and `norm`-guard findings out of §14.8 into the
companion. The row's §14.8 citation then covers the tables and saturations.
Proposal: land `units/G/companion_addition.md` under the table. Append
"(Flight.jl's model alone, below)" to the row's gear cell.
Recommendation: adopt.
Status: open

### B32. Reference definitions the chapter needs

Sources: U-rul B ("eight undefined reference links"); U-ver B; U-rul G
question 7.
Lines: the spec's link-definition block.
Evidence: the frozen spec has no `[d-NNN]:` for D-066, D-095, D-098,
D-110, D-124, D-125, D-126 or D-155. Other new D-entries (D-118, D-150,
D-262 and others) may lack one too.
Proposal: run `linkify.jl` after the splice. It writes the definitions. Check
by `check_refs.jl` that none stays undefined.
Recommendation: adopt, as step 7.6 already does.
Status: open

## Track 2

Log repairs, annotations and entries owing a Position, one item per entry.
All lines are `decisions.md` lines at `c3d29fb`. The rewrite only cites; it
repairs nothing. `tools/decisions_style.md` governs every proposal. Rule 1
makes the repair a dated annotation, never a rewrite. Rule 2 keeps old
vocabulary (`capture`, `slot`, `merge`), so a stale word alone earns no
repair. Only an overtaken ruling does (rule 10). An "owed Position" is an
annotation that states the ruling in Position form, in the words of the
Rationale or Rejected clause named. The brief names D-149, D-409, D-095,
D-098, D-130 and D-242 for annotation, and F52's and F53's entries.

### B33. D-108

Sources: S1-E (rulings 1-3; stale text); U-rul A (Rationale-only).
Lines: Rationale 3564-3571; Rejected 3574-3576; Position 3555-3560.
Evidence: §14 cites D-108 at "`errored` is terminal for every service",
`ServiceLifecycle`'s payload and its sharing with `attach!`/`detach!`, and
`MissingInit`'s distinctness. Only the Rationale and Rejected list say so.
The Position's `capture` precondition predates D-273/D-274.
Proposal: one annotation stating the three rulings. It marks the `capture`
precondition as overtaken by D-274 (`checkpoint` is legal in `initialized`
and `stopped`).
Recommendation: adopt. The chapter now cites D-108 at three rules.
Status: open

### B34. D-139

Sources: S1-E (ruling 5); S2-E (ruling 4); IC1 row 208; U-rul A, G.
Lines: Position and Rationale 4950-4962; Rejected 5008-5009.
Evidence: the Position rules the value-level constructor only. The
Rationale holds two bold rulings the chapter cites: the caller-computable
escape reaches environment queries (§14.1), and "Trim problems never author
the environment" with "aircraft as root" as a default (§14.9). D-364's
Position covers only the bulk-data handle. The Rejected item at 5008-5009
cites "§14.2's by-name rejection of init as a third scheduled sweep", which
§14.2 never stated; the rejection is D-064's.
Proposal: one annotation stating the two Rationale rulings, and IC1's:
"Annotation (<date>): the by-name rejection of init as a third scheduled
sweep is [D-064][d-064]'s; [§14.2][s14-2] never stated it."
Recommendation: adopt. Both bolds in the chapter rest on Rationale text.
Status: open

### B35. D-278

Sources: S1-E (ruling 6).
Lines: Rationale (survey 1 row 68, "one way to say everything").
Evidence: the sentence is a Rationale clause, not a Position.
Proposal: no annotation.
Recommendation: decline. It is a reason, and rule 8 forbids sourcing
rationale the entry does not hold. The chapter cites D-278 for the
empty-prefix refusal, which the Position rules.
Status: open

### B36. D-065

Sources: S1-E (superseded; stale text; ruling 7); IC1 row 139.
Lines: Position 2091-2099; annotation 2108-2109; Rejected; D-204 Rationale.
Evidence: the clause "deep `at` only within owned concrete subtrees" is
amended by D-207 and D-414. The 2026-10-13 annotation says the concrete half
"is machine-checked", which D-414 retired. The Spec field lacks §14.3 (IC1
row 139). Last-writer-wins and `Base.merge`'s contract are reasons only.
Proposal: one annotation scoping the clause to D-207/D-414 and correcting
"machine-checked"; add §14.3 to the Spec field. No annotation for the
reasons.
Recommendation: adopt.
Status: open

### B37. D-064

Sources: IC1 row 138; S1-D.
Lines: Spec field; Rejected (third scheduled sweep).
Evidence: the Spec field lacks §14.1, which cites D-064. D-064's Rejected
list holds the by-name rejection of init as a third scheduled sweep that
the two companions and D-139 attribute to §14.2.
Proposal: add §14.1 to the Spec field. No other change.
Recommendation: adopt.
Status: open

### B38. D-316

Sources: S1-E (ruling 8); U-rul A.
Lines: Rationale 13997-13999; Position (superseding D-060 in part).
Evidence: "a foreign `condition` fails loudly" is a Rationale clause, and
the chapter cites it with a "because".
Proposal: no annotation.
Recommendation: decline. It is a reason the chapter cites as one.
Status: open

### B39. D-148

Sources: S1-E (ruling 9); U-rul A.
Lines: Rationale 5596-5611; Position (converter selection).
Evidence: the shape-fact reason, the untouched exact-match doctrine and "no
converters on state views" live in the Rationale. The chapter states them
next to D-148's Position.
Proposal: no annotation.
Recommendation: decline. They are reasons beside a ruling the Position holds.
Status: open

### B40. D-124

Sources: S1-E (ruling 10); U-rul B.
Lines: Rationale 4113-4115.
Evidence: the table/store axis wording and "table sources" are Rationale
text. The widened `reads` grammar is a Position ruling (U-ver F).
Proposal: no annotation.
Recommendation: decline.
Status: open

### B41. D-095

Sources: brief; S1-E (stale text; rulings 11, 12); IC1 row 159.
Lines: Position 3075-3079; Rationale and Rejected 3087-3089, 3099-3100.
Evidence: the Position lists a six-member family with `get_local` and
`get_slot`, and §14.4 has five. "Inspection readers admit the whole family"
and "`ignore_stop_requests` is outside the family" are Rationale and
Rejected text.
Proposal: one annotation giving the family as D-276 and §14.4 state it,
and the two Rationale clauses in Position form.
Recommendation: adopt. The brief lists D-095.
Status: open

### B42. D-098

Sources: brief; S1-E (stale text); IC1 row 161; U-rul B.
Lines: Position 3172-3176.
Evidence: the Position says `capture`, where §14.4 says `checkpoint`.
Proposal: the brief's annotation: `capture` reads `checkpoint` (D-273,
D-274).
Recommendation: adopt.
Status: open

### B43. D-063

Sources: S1-E (superseded; stale text).
Lines: Position 2047-2051.
Evidence: the Position's `capture -> tweak -> apply` clause is retired by
D-273 and carries no annotation. The overlay clauses stand.
Proposal: one annotation naming D-273 as the retirement.
Recommendation: adopt. It is an overtaken ruling, not a vocabulary change.
Status: open

### B44. D-066

Sources: S1-E (stale text; rulings with no entry).
Lines: Position 2131; entries for `ConditionShapeDrift`.
Evidence: the Position says `capture`. D-066 rules the shape check, and no
entry names `ConditionShapeDrift` as the kind. B's chapter text names the
kind and its `:tree_type` and `:prefix` reasons.
Proposal: no annotation for `capture` (rule 2). The kind is covered in B73.
Recommendation: adopt the split.
Status: open

### B45. D-067 and D-026

Sources: S1-E (ruling 13; superseded); U-rul B.
Lines: D-067 Rejected 2178-2182; D-026 Rejected.
Evidence: "the `t0` firing is not suppressed" and the insurance lesson are
Rejected text the chapter cites. D-067's "every tick due" clause is amended
by D-205, which is annotated already.
Proposal: no annotation.
Recommendation: decline. They are reasons, and the amendment is recorded.
Status: open

### B46. D-276

Sources: S1-E (ruling 4); U-rul B.
Lines: annotations 2026-09-30 and 2026-10-01 at 12073-12094.
Evidence: the face head matched on `get_input` and `get_face` lives in two
annotations. The Position states the leaf address only. §14.4 states the
matching.
Proposal: fold the two annotations' ruling into one later annotation in
Position form.
Recommendation: adopt. It is low weight; do it with the D-095 pass.
Status: open

### B47. D-409

Sources: brief; S1-E (stale text); U-ver A.
Lines: Position 16348-16350.
Evidence: "Service observation must speak the contract" reads against D-414's
guidance. §13.5 frames the rejection as bearing on reads a run acts on, and
§14.1 (R4) says so.
Proposal: the brief's annotation: scope the Position to the reads a run acts
on, as §13.5 frames it.
Recommendation: adopt.
Status: open

### B48. D-130

Sources: brief; S1-E (stale text); IC1 row 185; IC2 (log 4310).
Lines: Position 4310-4312.
Evidence: the Position puts device read bindings under inspection by the
instance walk. D-414 and D-310 replace that reading.
Proposal: the brief's annotation naming D-414 and D-310.
Recommendation: adopt.
Status: open

### B49. D-242

Sources: brief; S1-E (stale text); IC1 row 256.
Lines: Position 9606-9609.
Evidence: bindings and GUI panels under inspection, against D-414.
Proposal: the brief's annotation, as B48.
Recommendation: adopt.
Status: open

### B50. D-149

Sources: brief; S1-E (stale text); S2-E (ruling 9); IC1 row 32.
Lines: Position 5643-5646; Rationale 5651-5659; Rejected.
Evidence: the Position lists three sites, and `linearize`'s `about` is a
fourth (R3, F2). The Rationale holds "unfailable through the trim path" and
no `committed` flag.
Proposal: one annotation adding the fourth site, with the Rationale
clause in Position form.
Recommendation: adopt.
Status: open

### B51. D-122

Sources: S1-E (stale text); IC1 row 176; F26.
Lines: Rationale 4043-4044.
Evidence: "the `baseline` keyword of `trim!`/`init!`" is false of `init!`
(`src/sim.jl` 591, `src/model.jl` 170).
Proposal: one annotation: only `trim!` takes `baseline`.
Recommendation: adopt, with B22.
Status: open

### B52. D-253

Sources: IC1 row 261.
Lines: Spec field 10212.
Evidence: the Spec field lists §14.1, which never cites D-253. §14.3 does.
Proposal: IC1's text: "Annotation (<date>): the Spec field's [§14.1][s14-1]
reads [§14.3][s14-3]."
Recommendation: adopt.
Status: open

### B53. D-118

Sources: S2-E (stale; ruling 6); IC2.
Lines: Position 3903; Rationale.
Evidence: "closes at seven" went stale when D-262 added two fields. Setup's
checks of the residual and check returns at the guess are Rationale text.
Proposal: one annotation: the field set closes at nine (D-262); the
setup-check clause in Position form.
Recommendation: adopt. It pairs with B26.
Status: open

### B54. D-262

Sources: S2-E (rulings 6, 12); U-rul F, G.
Lines: Position; Rationale; Rejected.
Evidence: "checks stay out of the solve" is a Rejected clause, and setup's
check at the guess is Rationale text. The chapter bolds Position sentences
2 to 4.
Proposal: no annotation.
Recommendation: decline. The bolded rulings are in the Position already.
Status: open

### B55. D-151

Sources: S2-E (ruling 7).
Lines: Rejected (permuted bound; residual reorder).
Evidence: the hazard is in the Rejected list. The Position states the
canonicalization.
Proposal: no annotation.
Recommendation: decline.
Status: open

### B56. D-132

Sources: S2-E (ruling 8).
Lines: Rationale (services need no boundary masking).
Evidence: a Rationale clause the chapter cites at row 601.
Proposal: no annotation.
Recommendation: decline.
Status: open

### B57. D-273

Sources: S2-E (ruling 11).
Lines: Rationale ("`trim!` no longer takes a mid-run capture as its
baseline").
Evidence: fly-then-retrim rests on this clause.
Proposal: no annotation.
Recommendation: decline. D-274's `checkpoint` ruling states the current form.
Status: open

### B58. D-307

Sources: S2-E (ruling 10).
Lines: Rationale ("guidance, not rulings").
Evidence: the interpolation guidance is guidance.
Proposal: none.
Recommendation: decline.
Status: open

### B59. D-070

Sources: S2-E (stale text, ruling 13, superseded); U-rul G correction 1;
IC2.
Lines: bullet 3 at 2276; bullet 5; Rejected.
Evidence: bullet 3 says `BuildError`, and D-222 made it `DiagnosticError`.
Bullet 5 says the saturation is "LM-tolerated, reported", and the report's
`saturated` list names decisions at their own bound only (B12). The
external-NLS rejection is constructive rationale.
Proposal: one annotation covering `DiagnosticError` and the `saturated`
scope.
Recommendation: adopt.
Status: open

### B60. D-069

Sources: S2-E (stale text); IC2 (log 2235).
Lines: bullet 2 at 2235.
Evidence: "`deriv`/`output` selectors" predate D-095's prefix and D-124's
widening.
Proposal: one annotation naming D-095 and D-124.
Recommendation: adopt.
Status: open

### B61. D-071

Sources: S2-E (stale text); IC2 (log 2311-2312); F54.
Lines: bullet 2 at 2311-2312.
Evidence: "named by the build" is stale. A refusal now fails resolution by
name.
Proposal: one annotation.
Recommendation: adopt.
Status: open

### B62. D-072

Sources: S2-E (stale text); IC2 (log 2349-2351).
Lines: bullet 3 at 2349-2351.
Evidence: `capture(sim)` as the default point is overtaken by D-274 bullet 5.
No annotation records it.
Proposal: one annotation naming D-274 bullet 5.
Recommendation: adopt. It is an overtaken ruling.
Status: open

### B63. D-272

Sources: S2-E (stale; ruling 1); IC2 (log 11780).
Lines: bullet 4 at 11780; annotation 2026-09-28 at 11825-11836.
Evidence: bullet 4's `capture(sim)` is overtaken by D-274, which neither
annotation records. The annotation holds two rulings the chapter states: two
taps at one site are rejected with both labels in hand, and a tier-pinned
root input's refusal names the tier.
Proposal: one annotation naming D-274 and stating the two rulings in
Position form.
Recommendation: adopt.
Status: open

### B64. D-126

Sources: S2-E (stale text); IC2 (log 4182).
Lines: Rationale 4182.
Evidence: "`capture`-defaulted `linearize`".
Proposal: none.
Recommendation: decline. It is vocabulary of its day (rule 2), and D-274
states the current default.
Status: open

### B65. D-155

Sources: S2-E (stale text).
Lines: Position 5896.
Evidence: as B64.
Proposal: none.
Recommendation: decline, for B64's reason.
Status: open

### B66. D-263

Sources: S2-E (ruling 2; superseded); IC2 (log 6437).
Lines: Rationale 10958-10960; D-167 Rejected 6437.
Evidence: the participation trait that "turns the walk on for its contracts"
sits in D-167's Rejected list, and D-167 is superseded by D-263. D-263's
Rationale only brushes it.
Proposal: one annotation on D-263 stating the trait's ruling.
Recommendation: adopt. The chapter cited D-167 three times, and F59 moved
them away.
Status: open

### B67. D-197 and D-073

Sources: S2-E (ruling 3).
Lines: D-197 Rationale 7628-7636; D-073 Rejected.
Evidence: the frozen-discrete step map as "the different object" and
$\Phi$'s event-quiescent scope are Rationale and Rejected text.
Proposal: none.
Recommendation: decline. Reasons only.
Status: open

### B68. D-150

Sources: S2-E (ruling 5).
Lines: Rationale 5694, 5700.
Evidence: the tolerance translation per backend family and the inscribed
sphere are Rationale text. The chapter cites D-150 at the display's lead
sentence.
Proposal: none.
Recommendation: decline.
Status: open

### B69. D-213

Sources: S2-E (stale text).
Lines: Spec field.
Evidence: the Spec field lacks §14.10.
Proposal: add §14.10.
Recommendation: adopt.
Status: open

### B70. D-068

Sources: S1-E (stale); S1-F25.
Lines: Position 2192-2206.
Evidence: the Position spells the commit `override(baseline, solution)`.
The code spells it `override(baseline, condition(d*))`. The vocabulary
(`UninitializedSlots`, "slot", `merge`) is kept by rule 2.
Proposal: no annotation for vocabulary. One annotation for the spelling.
Recommendation: adopt the spelling annotation only.
Status: open

### B71. New entry: the two `TrimProblemInvalid` reasons

Sources: S2-F52; S2-E ("Rulings with no entry"); brief.
Lines: new entry, after the highest D-nnn.
Evidence: `:inverted_box` and `:nonpositive_tolerance` come from a code
commit (`3408028`). No entry rules them, and §14.8 states both.
Proposal: one entry, ratified, whose Position states both reasons.
Recommendation: adopt, as the brief says.
Status: open

### B72. New entry: the seeded tap's limits

Sources: S2-F53; R24; S2-E; brief.
Lines: new entry.
Evidence: at most one index step, no `.name` step, a `Float64` leaf. The suite
cites "§14.10, D-036, D-276" (`test/test_linearize.jl` 308), and neither
states it.
Proposal: one entry, ratified, whose Position states the three limits and
the `:unseedable` and `:vector_tap` kinds.
Recommendation: adopt.
Status: open

### B73. Rulings with no entry, survey 1

Sources: S1-E ("Rulings with no entry at all").
Lines: none.
Evidence: no entry rules `ConditionShapeDrift` as a kind, the activation
pairing as an invariant, "which of the two a service uses is internal"
(assumed by D-130), `init!` legal at any status, `restore!` legal from
`built` (implied by D-274), the framework-owned `condition` generic, the
`===` content comparison, the two lookup families or the tree position.
Proposal: one entry for the kind and the activation pairing, which the
chapter states as rules. One short entry for the two legality rows. None for
the rest, which describe code.
Recommendation: adopt the two entries, and decline the rest.
Status: open

### B74. Rig and non-participation rulings with no entry; glossary `design_world`

Sources: S2-E (no entry at all); R26, R29; U-rul G correction 2, H.
Lines: glossary `#g-design_world` (14745); no entry.
Evidence: no entry records non-participation tooling, pinned-face validation
or the feedthrough-graph lint (row 745), or the sampled-data walked-leaf
parametrization (D-073 says only "recorded unbuilt"). The glossary's
`design_world` copies "the shipped thin world", and `HorizontalTerrain` has
no owner.
Proposal: no new entry for the recorded designs (rule 9: they are recorded
design under D-073). Rewrite the glossary entry to "the rig this design
records for design-time work", naming `SimpleAtmosphere` and `NoWind` as
FlightPhysics' (R29) and no owner for `HorizontalTerrain`.
Recommendation: adopt.
Status: open

## Carried

Items for the front matter, the appendices, the companions and the tools.
They do not block the chapter and do not land with it. The brief puts the
appendices' stale rows on the appendices' carried list and the
`linearization_walkthrough.md` line on the companions'.

### B75. Appendix C rows the chapter found stale

Sources: brief ("Edits at landing"); IC1 rows 100-103; IC2; U-rul A, B, G, H;
S2 part E closing list.
Lines: spec 13637-13649 (`ConditionResolution`, `DuplicateConditionLeaf`,
`ConditionNodeMisuse`), 13678 (`ConditionShapeDrift`), 13661-13666
(`TapResolution`, `TrimProblemInvalid`), `ConditionResolution` and
`ReadResolution` (§14.9).
Evidence: the `ConditionResolution` row lists four sub-kinds, and §14.2 and
§14.3 name seven reasons. `DuplicateConditionLeaf`'s leaf is
`(path, store, field)`, and a `u` payload's leaf is its root input (F11).
`ConditionNodeMisuse` lacks `:set_payload` (F8) and says "node kinds" where
§14.2 says node types (R38). `ConditionShapeDrift`'s payload names no
`reason` field, and §14.4 names `:tree_type` and `:prefix`. `TapResolution`
lacks the seeded tap's limits (F53, R24). `TrimProblemInvalid` lacks F52's
two reasons. The `ConditionResolution` and `ReadResolution` rows may not
list §14.9 (R14, F71).
Proposal: carry each row to the appendices' list with the chapter's wording.
`ConditionResolution` may add §14.1.
Recommendation: adopt.
Status: open

### B76. Appendix B owes the snapshot form of `port`

Sources: P1-22 (B3).
Lines: spec 13039 (Appendix B, `port(model, path, name)`).
Evidence: the code has `port(snapshot, path, name)` (`src/dataplane.jl`
480-481), and Appendix B lists only the `model` form.
Proposal: carry a row for the snapshot form, and let §11.2 state the read.
Recommendation: adopt.
Status: open

### B77. The Part IV roadmap

Sources: R1; brief (R1: "9907-9921 is not edited").
Lines: spec 9907-9921.
Evidence: the roadmap names the chapter's contents as the old chapter did.
R1 leaves it to the front-matter rewrite.
Proposal: carry it with the chapter's new §14.1 to §14.10 roadmap sentence.
Recommendation: adopt.
Status: open

### B78. Appendix D `#g-entry` and bare *entry*

Sources: S1-E ("Findings carried"); R13; F29.
Lines: Appendix D `#g-entry`.
Evidence: chapter 13 carried an item that `#g-entry` says the word is never
used bare and lists only *condition entry* (§14.3). §14.1 to §14.5 used it
bare, and R13 now gives "condition entry", "input entry" and "tap".
Proposal: carry the glossary entry's update to list the three.
Recommendation: adopt.
Status: open

### B79. `linearization_walkthrough.md` 572

Sources: brief; IC2 ("Other notes").
Lines: `companions/linearization_walkthrough.md` 572.
Evidence: "`sim.exec` was never touched" is stale since D-317. "No restore step"
now sits next to §14.10's checkpoint "restored into the scratch world"; it
most likely means Flight.jl's restore dance.
Proposal: reword both clauses together when the companions are swept.
Recommendation: adopt.
Status: open

### B80. `gloss_table.md` row 202

Sources: U-rul F ("For landing").
Lines: `docs/design/tools/gloss_table.md` 202.
Evidence: it glosses `TrimProblem` as "the closed seven-field value". The
glossary and §14.7 say nine.
Proposal: change "seven-field" to "nine-field".
Recommendation: adopt.
Status: open
