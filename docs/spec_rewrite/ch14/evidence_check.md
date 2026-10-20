# Chapter 14 evidence check (step 6a)

Items B21 to B80 of `rulings_batch.md`: Landing, Track 2 and Carried. Spec and
log lines are the frozen copies `scratch_survey/h1/spec.md` and
`decisions.md` at `c3d29fb`. `src/`, the companions and `pending.md` are read
at the working tree. IC1 row numbers count data rows of
`inbound_check_1.tsv`, header excluded, as `inbound_check_1.md` says.

Chapter lines are those of `chapter_new.md` at `b187775`, before the editorial
fixers, as the batch numbers them. Commit `bfcf024` rewrapped and edited the
file while this check ran. A spot check of 24 cited passages found each one
still present in the working tree, at shifted lines.

For Track 2 items that propose an annotation or entry, "Position check" says
whether an existing Position already states the ruling or the ruling follows
from one (recipe lessons 42 and 68).

## Landing

### B21. The totality sites list four, not three

CONFIRMED, with one caveat. Spec 4690-4692 (§9.3, in bold): "**Every
complete-world application, namely `init!`, trim setup and trim commit,
carries the pre-write `UninitializedInputs` check** ([§14.6][s14-6],
[D-149][d-149])". Spec 7333-7334 (§11.3): "Totality is enforced pre-write at
every complete-world application, namely `init!`, trim setup and trim
commit". Glossary 14770-14772 (`#g-root-input-totality`): "an application
establishing a complete world over virgin stores (`init!`, trim setup, trim
commit)". `chapter_new.md` 682-683 (§14.6) adds "and linearization's
operating condition under `about`". Brief R3: "§9.3, §11.3 and the glossary
are landing edits"; R34: "§9.3's bold (old 4690–4692) goes plain with a
pointer to §14.6". IC1 rows 32, 48 and 130 flag the three lists.
Caveat: no list states a number. Each lists three sites after "namely" or in
parentheses, so "its count to four" has no count word to change; only the
list grows.

### B22. Glossary `#g-baseline` and "all four services"

CONFIRMED. Glossary 14719-14720: "It is also the `baseline` keyword
`init!`/`trim!` take ([§14.6][s14-6])". 14780: "`errored` is terminal for all
four services ([§14][s14])". `src/sim.jl` 591: `function init!(sim::Simulation,
condition = set(); t0::Real = 0.0, trace = true, log = true, log_every = 1,
log_max = 65536)`, no `baseline`. `src/model.jl` 170 forwards `kw...` to the
plan method at 177, which takes only `t0` and `hooks`. Only `trim!` takes
`baseline` (`src/sim.jl` 757, `src/trim.jl` 446). `chapter_new.md` 5-7 names
five: "initialization, trim, linearization, and `checkpoint` with its
partner `restore!`". IC1 rows 122 and 132 agree.

### B23. Glossary `#g-selector` keeps "before any client policy applies"

CONFIRMED. Glossary 14578-14579: "Each resolves against a source before any
client policy applies." IC1 row 118 (MISSING, deliberate): "R31 cut the
clause as false after R5", with new text "against a source. Table sources
are a". Brief R31: "The glossary's `#g-selector` carries the same clause: a
landing edit." The line is 14579, not 14580; 14580 carries the next clause.

### B24. §13.2 calls the `TrimCommit...` kinds report fields

CONFIRMED. Spec 10139-10141: "A stopped-sim service returns an artifact, so
its warnings live on it. `trim!` returns a `TrimReport`, and
`TrimCommitEvents`, `TrimCommitResiduals` and `TrimCommitChecks` are that
report's fields ([§14.8][s14-8])." `src/trim.jl` 620: `isempty(fired) ||
@warn logline(TrimCommitEvents(events = fired))`; 633 and 644 the same for
`TrimCommitResiduals` and `TrimCommitChecks`. The `TrimReport` struct
(`src/trim.jl` 145-157) holds `residuals`, `committed_residuals`,
`committed_checks` and `fired_events`, and no `TrimCommit...` field.
Appendix C 13669-13676 calls all three "Warning · service · logged". IC2's
new text is quoted exactly in the proposal.

### B25. §9.6 on the fallback and `get_x_ss`

CONFIRMED. Spec 5113-5114: "The derivative-free fallback runs the same loop
on the nominal `Float64` activation". Spec 5122-5123: "That replacement
discharges the layer's deletion ([§7.1][s7-1])". `pending.md` 158: "**The
NLopt fallback** (§14.8, H 4.5): `NLoptBackend(:LN_BOBYQA)` as a package
extension ... and the nominal-activation loop it would run on." Brief R10:
"It is not *recorded, not built*: do not mark it with that term. §9.6 is a
landing edit." Survey 2 F64 (row 1033): "§7.1 no longer promises a deletion".
The §9.6 sentence does not name `get_x_ss`; it says "the hand-written
per-aircraft state-space mapping layer".

### B26. Appendix B rows that cite the chapter wrongly

CONFIRMED. Spec 13199-13200: "The problem itself closes at seven fields
([§14.7][s14-7])". Spec 13201: "The commit is `init!` with `override(baseline,
solution)`". Spec 13212: "Non-convergence reports, never throws
([§14.7][s14-7], [§14.8][s14-8])." Old §14.7 (11880-11890) lists nine fields:
`guess`, `lower`, `upper`, `condition`, `reads`, `residuals`, `tolerances`,
`checks`, `check_tolerances`. It never names a count, and it holds no
"throw". Old §14.8 holds "Non-convergence never throws" (12309). The code
commits `override(baseline, problem.condition(solution))` (`src/trim.jl` 612).
The "seven fields" text sits at 13199, with its citation on 13200.

### B27. Appendix C citations that point at the wrong section

CONFIRMED. Spec 13735: "**`ReadSetMisuse`** ([§14.4][s14-4]). Error · service
· fail-fast." Spec 13722-13723 (`ArgumentInvalid`): "... [§13.5][s13-5],
[§14.7][s14-7])". `chapter_new.md` 1376 (§14.9): "and raises
`ReadSetMisuse`"; 954 (§14.8, "The backend seam"): "refused as
`ArgumentInvalid` with reason `:non_nominal`"; 956: "`ArgumentInvalid` with
reason `:claimed`"; 1533 (§14.10, "The operating point"): "a `t0` passed
without `about` is an `ArgumentInvalid`". Brief R14: "`ReadSetMisuse` is
§14.9's (unit G), not §14.4's." Note: `:claimed` is also stated in the
chapter opening, `chapter_new.md` 64-65 ("as `ArgumentInvalid` with reason
`:claimed` ([D-318][d-318])"), so [§14][s14] would also hold; the proposal's
two citations are sound without it.

### B28. Contents entry for §14.4

CONFIRMED. Spec 98: "[14.4 One plan, two ways to apply it](#144-one-plan-two-ways-to-apply-it)".
Note: `docs/design/tools/linkify.jl` regenerates the Contents wholesale
(header, job 3: "Regenerate the spec's `## Contents` ... the TOC is generated
wholesale, so its slugs never rot"), so recipe step 7.2's Contents fix and
step 7.6's linkify run both reach it.

### B29. Glossary entries that state the chapter wrongly

CONFIRMED. Glossary 14791 (`TrimProblem`): "committed as an `init!` of
`override(baseline, solution)`". 14903-14904 (`recorded, not built`): "the
sampled-data `Dual` activation and declarative non-participation,
[§14.10][s14-10]". Old §14.10, 12672: "**Both halves of this door have a
spelling.**"; 12721: "What stays recorded is only the remaining **tooling**
over that visibility." `chapter_new.md` 1678 and 1724 keep both. Glossary
14782-14786 (`taps`): "Every tap names one scalar, by a leaf address
resolving to one scalar leaf", with no seeded-tap limit. `_check_seedable`
(`src/linearize.jl` 336-347) raises `:unseedable` for a `.name` step or a
second step and for a non-`Float64` leaf, and `:vector_tap` for a non-`Real`
leaf; its comment: "a seeded tap reaches its scalar through one index step
at most and never a `.name` step".

### B30. Companion pointers into the chapter that were wrong before the rewrite

CONFIRMED. `linearization_walkthrough.md` 370-374: "`get_state(path,
field[, i])` names a state leaf ... both with the same index since
[D-271][d-271]". `trim_environment_walkthrough.md` 65: "the "init as a third
scheduled sweep" that [§14.2][s14-2] rejects by name"; 537: "which is
[§14.2][s14-2]'s rejected "init as a third scheduled sweep"". Those are the
file's only `[s14-2]` uses; the definition is at 905 and `[d-008]` at 900.
D-064 Rejected (log 2084-2085): "*Init as a third scheduled sweep:* what
"component-local `α_filt = α`" actually requires." `lqr_tracker.md` 184 and
`pid_anti_windup.md` 493: "routes the port through `Freeze`
([§14.10][s14-10])". Old §14.10 12719 only points: "beside the `Freeze` block
([§13.7][s13-7])". §13.7 states the block (spec 11065-11074). Both files
define `[s13-7]` (`lqr_tracker.md` 347, `pid_anti_windup.md` 618).

### B31. The C172 audit row and its added paragraph

CONFIRMED. `migration_outline.md` 28: "*Residual*: the C172 AD audit for
trim | Interpolations tables (prefer cubic knots), saturation rank-deficiency
(LM-tolerated, reported), the gear identically zero airborne | [§14.8][s14-8]
| [D-070][d-070]". Brief R15: "The gear and `norm`-guard bullets move to
`docs/design/companions/migration_outline.md`, beside its audit row".
`units/G/companion_addition.md` exists and opens "**The C172 AD audit for
trim.** [§14.8][s14-8] keeps the audit's guidance on Interpolations tables
and in-model saturations."

### B32. Reference definitions the chapter needs

CONFIRMED. The frozen spec has no `[d-066]:`, `[d-095]:`, `[d-098]:`,
`[d-110]:`, `[d-124]:`, `[d-125]:`, `[d-126]:` or `[d-155]:` definition, and
`chapter_new.md` uses each. Of the other new entries, `[d-118]:` and
`[d-071]:` are also undefined (D-118 used five times, D-071 seven); `[d-150]:`
and `[d-262]:` exist. `linkify.jl` job 2 regenerates "each file's
definitions block (only the labels the file uses, sorted)". Recipe step 7.6:
"Run `linkify.jl`, then the battery".

## Track 2

**Note N1, on the form of an owed Position.** The batch's preamble defines
an "owed Position" as an annotation that states a Rationale or Rejected
ruling "in Position form", and B33, B34, B41, B46, B50, B53, B63 and B66
propose that form. The recipe's chapter 12 lesson (`recipe.md` 643-645)
reads: "**A Rationale-only ruling gets a new entry, never new Position text
in an old one.** `decisions_style.md` rules 1 and 10 say so; the evidence
check found the batch proposing the old form for 23 items (its note N1)."
Lesson 68 (`recipe.md` 1125-1126) repeats it: "Track 2 writes new entries,
never new Position text in an old entry, and no entry for a consequence of
a Position." Rule 10 of `decisions_style.md`: "The older entry gets an
annotation, and a new entry states the position if none does." So an
annotation may point or correct, and a ruling no Position holds goes to a
new entry. The item blocks below flag each proposal this touches.

**Note N2, on Spec fields.** Recipe step 7.3 reads "update the Spec fields
the moves changed, in place, keeping each field's own order". B36, B37 and
B69 propose in-place additions; B52 proposes an annotation for the same
kind of fix.

### B33. D-108

CONFIRMED. Position 3555-3560: "`capture` requires `initialized`/`stopped`
(reads committed stores) ... `linearize` inherits `capture`'s precondition".
Rationale 3564-3571: "`errored` is terminal for all four ([D-059][d-059])
... one kind `ServiceLifecycle` (operation, current status, legal statuses)
shared with `attach!`/`detach!`-while-running". Rejected 3574-3576:
"*Folding `MissingInit` into `ServiceLifecycle`:* distinct cases". D-274
bullet 2 (11945-11948): "`checkpoint(sim)` is a stopped-sim service
([§13.7][s13-7]): legal in `initialized` and `stopped`, refused while
running". The entry carries no annotation.
Position check: partly stated elsewhere. D-232's Position (9200-9203)
states the sharing with `attach!`/`detach!`: "`attach!` and `detach!`
refuse an `errored` simulation with `ServiceLifecycle`, as they refuse a
running one". D-404 bullet 1 (16104-16106) uses the two kinds apart:
"with `MissingInit` at `built` and `ServiceLifecycle` in any other state".
D-059's Position (1903) says only "Status goes terminal
`stopped`/`errored`"; no Position says no service accepts `errored`. The
payload's field list is in no Position (D-319 bullet 2 uses `op` and
`legal` without listing them). The `checkpoint` legality is D-274 bullet
2's. Under N1, the errored rule and the payload would take a new entry,
and the `capture` precondition an annotation pointing to D-274.

### B34. D-139

CONFIRMED. Position 4936-4944 rules the value-level constructor only.
Rationale 4950-4951: "[§14.1][s14-1]'s **caller-computable escape is
extended to cover environment queries**"; 4962: "**Trim problems never
author the environment** ([§14.7][s14-7], [§14.9][s14-9])"; 4968-4969:
"[§14.9][s14-9]'s "the aircraft is never literally the root" is
**softened from doctrine to default**". D-364 Position (14995-14997): "A
thin rig holds its environment as a root input only when the handle is
isbits." Rejected 5008-5009: "reaffirms [§14.2][s14-2]'s by-name rejection
of init as a third scheduled sweep". The third-sweep rejection is D-064's
Rejected (2084-2085). IC1 row 208 gives the annotation text quoted.
Position check: no Position states "never author the environment". D-064's
Position (2070-2073) states the caller-computable escape for swept outputs
("a condition value needing swept outputs is caller-computable"), not for
environment queries. D-071 bullet 4 (2315-2316) states the root idiom:
"`design_world(ac)` promotes today's ad-hoc linearize models to a shipped
rig ("root" = shallowest world, one idiom)". Under N1 the two Rationale
rulings take a new entry; the §14.2 correction is a plain annotation.

### B35. D-278

CONFIRMED. Rationale 12247-12248: "Authoring at the current level already
has a spelling, the unwrapped node, and [§14.2][s14-2] wants one way to say
everything." Position 12235-12238: "`at` refuses an empty prefix when it is
called, at the root as below it."

### B36. D-065

CONFIRMED. Position 2096-2097: "deep `at` only within owned concrete
subtrees". Annotation 2026-10-13 (2105-2114), at 2108-2109: "Its concrete half is
machine-checked, since a service path may not traverse past a
generically-held field ([D-061][d-061], [D-130][d-130], [§13.3][s13-3])."
D-414 bullet 1 (16456-16457): "`:past_generic` retires from
`PathResolution`. A deep path resolves wherever the structure has it".
Spec field (2101): "[§6.1][s6-1], [§13.5][s13-5], [§14.2][s14-2]".
`chapter_new.md` §14.3 cites D-065 at 280, 321 and 357. Rejected: "*Last-writer-wins
merge:* silent near-certain bug". D-204 Rationale (7909): "`Base.merge`'s
documented contract is last-writer-wins".
Position check: already stated. D-207's Position (8026-8027) amends the
clause by name: "(amending [D-065][d-065]'s "deep `at` only within owned
...". D-414 bullet 4 (16466-16468): "The locality law for shipped fragments
and problems ([§14.2][s14-2]) is authoring guidance, not a framework
check." The annotation can point to D-414 and needs no ruling of its own.

### B37. D-064

CONFIRMED. Spec field (2075): "**Spec.** [§14.2][s14-2]". `chapter_new.md`
105 (§14.1): "known to the caller or an equilibrium constraint**
([D-064][d-064])". Old §14.1 (spec 11320-11375) cites D-064 nowhere, so
the gap opens with the rewrite. Rejected (2084-2085): "*Init as a third
scheduled sweep:*". IC1 row 138: "D-064 Spec lacks §14.1 (pre-sweep
doctrine). Track 2."

### B38. D-316

CONFIRMED. Rationale 13997-13999: "`condition` stays outside the family
because a foreign `condition` fails loudly, as a `MethodError` at the
owner's pull." `chapter_new.md` 150-152: "No shadowing check covers it,
because a method written to a foreign `condition` fails loudly at the
owner's pull, as a `MethodError` naming the child ([D-316][d-316])."

### B39. D-148

CONFIRMED. Rationale 5595-5611: "Leaf types are **shape facts**";
"[§9.5][s9-5]'s nominal exact-match doctrine for table cells is untouched";
"converters still run only on the write paths, never on state views". The
Position (5580-5592) rules per-leaf selection.

### B40. D-124

CONFIRMED. Rationale 4113-4117: "[§14.4][s14-4]'s source axis is restated
as *table sources* (a boundary snapshot, or the scratch tables a service
evaluation instantiates, [§14.8][s14-8]) vs. store sources". Position
4105-4109: "[§14.7][s14-7]'s `reads` grammar widens to the full service
set".

### B41. D-095

UNCONFIRMED in part. Confirmed: Position 3075-3079 lists
"`get_state`/`get_deriv`/`get_output`/`get_local`/`get_slot`/`get_face`",
and `chapter_new.md` 501-502 names five. Rationale 3086-3087: "inspection
readers the whole family (within [D-098][d-098]'s later source axis)".
Not confirmed: D-095 never names `ignore_stop_requests`. Its Rationale
(3087-3088) says "`stop_on` outside the family entirely (root-exported
`Bool` faces only, [D-060][d-060])", and its Rejected list "*`stop_on` as a
family client:*". D-316 retired `stop_on` (13963: "The `stop_on` keyword
and `StopFaceInvalid` retire"), and the chapter cites D-316, not D-095,
for the rule (`chapter_new.md` 516-520: "`ignore_stop_requests` is not a
family client ... ([§13.5][s13-5], [D-316][d-316])").
Position check: D-316 bullet 7 (13941-13948) states the ignore list's
spelling: "an iterable of strings names requesters by component path,
validated path by path against the roster". The family's change is
`get_slot` → `get_input`, D-206's Position (7990), a rename that rule 2
keeps out of the log, plus `get_local`'s retirement, which D-165 states in
its Rationale (6224: "`get_local` retired from the [§14.4][s14-4] selector
family"), not its Position.

### B42. D-098

CONFIRMED, with a caveat. Position 3172-3176: "store selectors
(`get_state`/`get_deriv`) only against live stores, which only stopped-sim
service evaluations, `capture` and post-run inspection ever hold".
`chapter_new.md` 475-477: "Only stopped-sim service evaluations,
[`checkpoint`](#g-checkpoint), and post-run inspection of the live stores
... ever hold live stores". Caveat: the same Position sentence opens "a
selector resolves against a *source* before any client policy", which
R31 cut as false after R5 (brief R31). And B2 adds that `checkpoint` and
post-run inspection "hold live stores but take no selector". A bare
`capture` → `checkpoint` annotation would leave both readings standing.
D-273 and D-274 state `checkpoint`'s form; the annotation is a pointer.

### B43. D-063

CONFIRMED. Position 2047-2051: "warm restart = `capture` reads current
stores back as a condition value (capture → tweak → apply)". No
annotation follows. D-273 bullet 4 (11863-11867): "The cycle capture →
tweak → apply retires with `capture`'s condition form."
Position check: D-273's Position states the retirement, so the annotation
only points to it.

### B44. D-066

CONFIRMED. Position 2126-2132 ends "compiled readers as the gather twin
(cost reads, linearization gather, `capture`)". No log entry contains
`ConditionShapeDrift` (grep of the frozen log finds none). `chapter_new.md`
389-390: "It is `ConditionShapeDrift` ([Appendix C][sC]), reason
`:tree_type` or `:prefix`". `src/conditions.jl` 781 and 785 raise both
reasons.

### B45. D-067 and D-026

CONFIRMED. D-067 Rejected 2178-2182: "*Condition-authoritative boundary
zero:* no events/updates: delays the identical firings one step while
hiding non-quiescence — [§11.7][s11-7]'s insurance-masking-invariants
pattern". D-067 annotation 2026-10-02 (2173-2175): "amended by
[D-185][d-185], [D-205][d-205] and [D-291][d-291]... every discrete output
stage publishes, due or not". D-026 Rejected (996-1000): "as insurance it
masks invariant violations at render rate".

### B46. D-276

CONFIRMED. Annotation 2026-09-30 (12073-12083): "On `get_input`, `get_face`
and a binding read the head is therefore matched against the level's face
list, the longest face name that is a prefix of the address". Annotation
2026-10-01 (12084-12094): "the decline is final". The Position (12063-12068)
states the leaf address only. `chapter_new.md` 430 states the match.
Position check: no Position states the head match. Under N1, folding it
into "one later annotation in Position form" is the form chapter 12
retired; a new entry, or no change since two annotations already hold it.

### B47. D-409

CONFIRMED. Position 16348-16350: "Observation by path is rejected. Service
observation must speak the contract, while inspection observation sees
everything". §13.5 (spec 10757): "Rejecting observation-by-path separates
inspection from the reads a run acts on". `chapter_new.md` 97-99 (R4):
"That rejection bars a run from acting on reads its model did not
declare." D-409's Rationale (16357-16358) says "The entry decides nothing new."
Position check: D-414 bullet 4 (16466-16469) states the service half as
guidance: "authoring guidance, not a framework check ... `get_face`
remains the read for a consumer meant to outlive the build". The
annotation can point to D-414 and §13.5.

### B48. D-130

UNCONFIRMED. The Position (4310-4312) does put "*inspection* (device read
bindings, GUI panels, snapshot/log inspection) the instance walk". But the
frozen log already holds the annotation the brief asks for, twice.
Annotation 2026-10-19 (4323-4326): "since [D-406][d-406] and
[D-407][d-407], device read bindings and log extraction by series resolve
on the service side ... GUI panels are parked ([D-310][d-310])". Annotation
2026-10-19 (4328-4330): "[D-414][d-414] drops the service walk's refusal
of traversal past a generically held child". IC1 row 185 and the brief
missed both. Nothing is owed.

### B49. D-242

UNCONFIRMED. The Position (9606-9609) does read "*Inspection* replaces
*diagnostic*: device read bindings, GUI panels, snapshot and log
inspection, resolved by the instance walk". But an annotation already
follows the Rationale (9639-9641): "Annotation (2026-10-19): since
[D-406][d-406] and [D-407][d-407], device read bindings and log extraction
by series resolve on the service side; GUI panels are parked
([D-310][d-310])." It does not name D-414, whose effect on bindings D-406
already carries. Nothing is owed beyond, at most, a D-414 pointer.

### B50. D-149

CONFIRMED. Position 5643-5646: "**Slot totality is checked at every
application that establishes a complete world over virgin stores —
`init!`, trim setup, trim commit**". Rationale 5657-5660: "commit's
totality check is structurally unfailable *through the trim path* ... no
`TrimReport` committed flag exists or is needed". `src/linearize.jl` 178
calls `assert_total(plan, build.structure, :linearize)`.
Position check: the fourth site follows from the Position's own principle.
It reads "every application that establishes a complete world over virgin
stores" and "the governing principle replaces the enumeration";
linearization's `about` applies to fresh scratch. Only the dash list lags,
so an annotation pointing to §14.10 suffices for it (lesson 68). The
Rationale clauses are in no Position (N1).

### B51. D-122

CONFIRMED. Rationale 4043-4045: "Event baseline → prior: the `baseline`
keyword of `trim!`/`init!` owns it". `src/sim.jl` 591 and `src/model.jl`
177 give `init!` no `baseline` keyword. Note: the clause is a reason for a
rename, not a ruling, and the batch's preamble says "Only [an overtaken
ruling] does" earn a repair; the log does not show whether `init!` took
`baseline` when D-122 was written.

### B52. D-253

CONFIRMED. Spec field 10212 lists "[§14.1][s14-1], [§14.4][s14-4]" among
others. Old §14.1 (11320-11375) cites D-253 nowhere; old §14.3 cites it at
11512 and `chapter_new.md` at 311. IC1 row 261 (RETARGET) gives the
annotation text. See N2: step 7.3 edits Spec fields in place.

### B53. D-118

CONFIRMED. Position 3903-3904: "The `TrimProblem` field set closes at seven
— `guess`/`lower`/`upper`, `condition`, `reads`, `residuals`, `tolerances`".
Rationale 3917-3918: "Shape/key-set checks at the setup guess evaluation
join `TrimProblemInvalid`". D-262's Rationale (10874-10877): "Setup
evaluates the checks once at the guess ... so a key-set or field-type
mismatch is `TrimProblemInvalid` before any solve".
Position check: the nine fields follow from two Positions. D-262's
Position (10834-10835): "A `TrimProblem` carries a second, optional
equation set, `checks` with `check_tolerances`". So the D-118 annotation
only points to D-262. The setup check is partly D-113 bullet 3's Position
(3727-3730): "`TrimProblemInvalid`: offending problem field, shapes/names
in hand; service batch ... the residual/tolerance length case joins when
... `tolerances` field is adjudicated ... (discharged, [D-118][d-118])".
Under N1, the remaining clause, placement at the guess evaluation, takes
a new entry if any.

### B54. D-262

UNCONFIRMED. The batch says "checks stay out of the solve" is a Rejected
clause. D-262's Position (10838) states it: "The service never solves
them. It evaluates them once, at the committed state". Setup's check at
the guess is Rationale (10874-10877), as the item says. The decline holds
more strongly: the bolded rulings and the no-solve rule are both in the
Position.

### B55. D-151

CONFIRMED. Position 5730-5731: "**At every author↔framework `NamedTuple`
seam the names are the pairing and field order carries no semantics**".
Rationale 5749-5750: "A permutation is a non-event." Rejected
(5753-5758): "a permuted `lower` passes the check and applies α's bound to
`throttle` ... the residual/tolerance pair carries the same hazard".

### B56. D-132

CONFIRMED. Rationale 4432-4434: "the services need no story of their own —
an interrupt during a long `trim!` unwinds an ordinary call over
per-invocation scratch stores, no commit having happened
([§14.8][s14-8])."

### B57. D-273

CONFIRMED. Rationale 11904-11906: "What retires with the condition form is
accepted: a captured state can no longer be tweaked, `trim!` no longer
takes a mid-run capture as its baseline". `chapter_new.md` 1145-1148:
"Fly-then-retrim is spelled as a `checkpoint` of the flight, then a trim
baseline authored from what the checkpoint ... shows ([D-273][d-273])".
Note on the reason: D-274's Position says nothing of trim's baseline. The
clause follows from D-273's own Position (11847-11851): "`capture` no
longer produces a condition, and the state of a simulation past its
initial instant is carried by a checkpoint ([D-274][d-274]), a distinct
value with no algebra." A baseline is a condition, so the decline rests on
D-273's Position.

### B58. D-307

CONFIRMED. Rationale 13464-13465: "The spec's caveats on `Linear()` kinks
and the `Interpolations.gradient` escape hatch are guidance, not rulings."

### B59. D-070

CONFIRMED. Bullet 3 (2275-2276): "a malformed problem a `BuildError` at
setup". Bullet 5 (2280-2281): "saturation rank-deficiency (LM-tolerated,
reported)". `_saturated` (`src/trim.jl` 587-596) pushes a decision only
when `d[i] == lower[i]` or `d[i] == upper[i]`. Bullet 1 (2269-2270) already
scopes the flag correctly: "saturated-at-solution flagged in the report".
`chapter_new.md` 1235 says "`DiagnosticError` carrying
`TrimProblemInvalid`".
Position check: the `BuildError` half follows from D-222's Position
(8772: "The one carrier is `DiagnosticError{P}`"; title "Replace
`BuildError` with the policy-parametric `DiagnosticError` carrier"). That
makes it a carrier rename, which rule 2 keeps out of the log unless D-222
is read as an overtaken ruling. The `saturated` scope is in no Position.

### B60. D-069

CONFIRMED. Bullet 2 (2234-2235): "reads are declared via `deriv`/`output`
selectors compiled to a stack NamedTuple reader."
Position check: already stated. D-124's Position (4105-4109) widens the
grammar and names the old form: "the two-selector alternation was a
pre-[D-095][d-095] straggler, not policy". The `get_` prefix is D-095's
Position, a rename (rule 2). An annotation would only point to D-124.

### B61. D-071

CONFIRMED. Bullet 2 (2310-2312): "an unexported face is untrimmable from
outside — correctly, it being a model-driven input, named by the build."
The refusal is at resolution: `src/conditions.jl` 455 pushes
`:internally_wired` with the producer; `src/readers.jl` 538 does the same
for a read. Survey 2 F54: "`build` of a tree whose mounted input is
internally wired raised nothing". Note: "named by the build" can also read
as "identified by the build as model-driven", which stays true; only the
reading "the build raises it" is stale.
Position check: no Position states the `:internally_wired` refusal.

### B62. D-072

CONFIRMED. Bullet 3 (2349-2351): "its default operating point is
`capture(sim)`, `capture` settled as the full-store gather returning
`(condition, t)`". No annotation follows (2336-2371). D-274 bullet 5
(11967-11968): "`linearize`'s default operating point is the checkpoint of
the simulation as it stands ([D-272][d-272])".
Position check: D-274 bullet 5 states the current form; the annotation is
a pointer.

### B63. D-272

CONFIRMED. Bullet 4 (11779-11780): "The operating point is `capture(sim)`
by default." Annotation 2026-09-28 (11825-11836): "Two taps resolving to
one site are refused at resolution with both labels in hand"; "the refusal
names the tier rather than an entry to promote". Neither later annotation
(the second is 2026-09-30, 11838-11841) records D-274.
Position check: the default point is D-274 bullet 5's (pointer only). The
two annotation rulings are in no Position. D-296 bullet 4 (13067-13070) is
the sibling for an entry pin ("naming the pinning consumer and its
entry"), not the tier pin. The same annotation's third ruling, "`t0` is
admitted only beside `about`", is also in no Position, and the chapter
states it (`chapter_new.md` 1533). Under N1, the rulings take a new entry,
not Position text in an annotation.

### B64. D-126

CONFIRMED. Rationale 4181-4182: "which `capture`-defaulted `linearize`
([§14.10][s14-10]) then reads".

### B65. D-155

CONFIRMED. Position 5895-5896: "the point `capture`-defaulted `linearize`
reads".

### B66. D-263

CONFIRMED, with two corrections. D-167 is "superseded → D-263", and its
Rejected item (6436-6440) reads: "if [§14.10][s14-10]'s sampled-data door
opens, the opt-in participation trait brings the `T`-signature with it —
the hinge is recorded here so the forms stay compatible." The words
"turns the walk on for its contracts" are the spec's (old §14.10, 12646),
not D-167's. D-263's brush is at 11003-11004 ("[§14.10][s14-10]'s
sampled-data door would bring the scalar there anyway"); lines 10958-10960
speak of the freeze and FFI doors.
Position check: no Position states the trait. The trait belongs to the
sampled-data extension, which D-073's Position records unbuilt (2379-2380).
B74 declines entries for recorded design, so B66 and B74 treat one class
two ways. Under N1, an annotation "stating the trait's ruling" is the
retired form.

### B67. D-197 and D-073

CONFIRMED. D-197 Rationale 7634-7636: "the error's next-move guidance
points at the step map $\Phi$, the object whose differentiation the author
actually wants". D-073 Rejected (2406-2408): "*Extending differentiation
through the discrete tier now:* frozen-`z` is exact for every built
consumer; $\Phi$ differentiability breaks at events".

### B68. D-150

CONFIRMED. Rationale 5694-5699: "**The tolerance translation into each
backend's stopping language is the service's too**, per backend family";
5700-5704: "**Soundness (inscribed sphere)**". `chapter_new.md` 1012-1013
states it as a rule: "The tolerance translation is the service's too, per
backend family ([D-150][d-150])."
Position check: partly stated. D-069 bullet 5 (2241-2242): "The
derivative-free scalar fallback is the service squaring the residuals";
D-070's Position: "the `NLoptBackend` extension takes squared residuals".
The normalization at `stopval = 1` is Rationale only. The Rationale bolds
the translation as a ruling, so N1 bears on the decline.

### B69. D-213

CONFIRMED. Spec field (8264): "**Spec.** [§14.8][s14-8]". D-213's Position
(8257-8262) rules "A service's seeded scratch set", which §14.10's
evaluation reuses (survey 2 row 690: "D-072 bullet 2; D-213 Position; D-319
bullet 5"). Notes: §14.10 cites D-213 nowhere, old or new; D-274 bullet 5
(11969-11970) narrows it for the default point ("the frozen tier's cells
are the checkpoint's held cells, which is what [D-213][d-213]'s
establishment round approximated"). Survey 2 lists six more stale Spec
fields (D-070, D-286, D-237, D-406, D-414, D-317, survey 2 1050-1058) that
no batch item carries.

### B70. D-068

CONFIRMED. Bullet 3 (2203-2206): "trim commits `override(baseline,
solution)`." `src/trim.jl` 612: `commit!(override(baseline,
problem.condition(solution)))`. Note: D-071's Position (2300-2301) says the
problem is "committed by initializing with the solved condition", so
"`solution`" in D-068 can read as the solved condition. The exact spelling
is in D-149's Rationale (5658: "`override(baseline, condition(d*))`"), not
a Position.

### B71. New entry: the two `TrimProblemInvalid` reasons

CONFIRMED. `src/trim.jl` 321 (`:inverted_box`) and 346
(`:nonpositive_tolerance`). The frozen log contains neither name, nor any
ruling on an inverted box or a non-positive tolerance. `chapter_new.md`
1240-1241 states both: "A box with `lower` above `upper`. A tolerance or
check tolerance that is not finite and positive." Note: `git log -S`
finds both names first in `415ed0b` (the reason list in
`src/diagnostics.jl` and its tests), and `3408028` moves them into
`src/trim.jl`.
Position check: no Position states either.

### B72. New entry: the seeded tap's limits

CONFIRMED. `test/test_linearize.jl` 308: "a seed follows index steps
alone: a `.name` step is unseedable (§14.10, D-036, D-276)". D-036's
Position (1275-1278) is table mechanics; D-276's (12063-12068) is the
general leaf address. `_check_seedable` (`src/linearize.jl` 336-347)
raises `:unseedable` for a `.name` step or a second step and for a
non-`Float64` leaf, and `:vector_tap` for a non-`Real` leaf.
Position check: none states the limits. D-272 bullet 6 (11785-11787),
"Seeds are written at the resolved tap's own site, the state's buffer
offset or the root input's cell", is the nearest and does not imply them.

### B73. Rulings with no entry, survey 1

CONFIRMED. No log entry names `ConditionShapeDrift`. Survey 1 rows 11, 17,
122, 128 and 129 say what the batch says. D-130's Position (4313-4314):
"which of the three a client falls under is internal, never user-facing
API ([§14.4][s14-4]'s `apply!` precedent)".
Position check: the restore row follows from a Position. Survey 1 row 11:
"legality from `built` follows from "beside `init!`"" (D-274 bullet 3,
11950: "`restore!(sim, cp)` is a door beside `init!` and `replay!`"). On a
`Model`, D-319 bullet 2 (14312) says `restore!` "has no status gate". By
lesson 68 that row takes no entry. `init!`'s any-status legality is in no
Position. The kind's check is D-066's Position ("shape check via tree type
+ literal `===` sweep"), and the kind name and its two reasons are code
facts (`src/conditions.jl` 781, 785).

### B74. Rig and non-participation rulings with no entry; glossary `design_world`

UNCONFIRMED in part. Confirmed: glossary 14745-14746 reads "the shipped
thin world (aircraft + `SimpleAtmosphere(wind = NoWind())` +
`HorizontalTerrain`)". Flight.jl defines `NoWind`
(`lib/FlightPhysics/src/atmosphere.jl` 153) and `SimpleAtmosphere` (260),
and no file in `~/.julia/dev/Flight.jl` names `HorizontalTerrain`. Old
§14.10 12721-12725 records the tooling (pinned-face validation, the
feedthrough-graph lint), and no Position names either.
Not confirmed: the reason for no entry. `decisions_style.md` rule 9 is
"**Implementation policy earns no entry.**", which is about implementation
or process policy, not recorded design. D-073's Position records only the
"sampled-data Dual activation recorded unbuilt ([§14.10][s14-10])"; it
covers the walked-leaf parametrization but not the non-participation
tooling.

## Carried

### B75. Appendix C rows the chapter found stale

CONFIRMED. Spec 13637-13643 (`ConditionResolution`): "Its sub-kinds are
assembly path, undeclared field, unconvertible value and unexported
root-input face." The code's reason field (`src/diagnostics.jl` 1757-1758)
lists seven: `:assembly_path`, `:unexported_face`, `:no_input_face`,
`:internally_wired`, `:no_store`, `:undeclared_field`, `:unconvertible`,
and `chapter_new.md` 176-183 and 296-299 name all seven. Spec 13644-13646
(`DuplicateConditionLeaf`): "The leaf `(path, store, field)`";
`chapter_new.md` 291: "where a `u` payload's leaf is the root input its
face resolves to". Spec 13647-13649 (`ConditionNodeMisuse`): "The offending
argument's type, the node kinds in hand. Or an empty prefix handed to
`at`", with no `:set_payload`. Spec 13678-13681 (`ConditionShapeDrift`):
"The compiled tree type and the observed one; for a prefix mismatch, the
node position and both strings", with no `reason`; `chapter_new.md`
389-390 names `:tree_type` and `:prefix`. Spec 13661-13665
(`TapResolution`) lists "a discrete store, a vector leaf, a duplicate site,
and a declaredly unseedable root input", with no `.name`-step or
non-`Float64` limit. Spec 13666-13668 (`TrimProblemInvalid`): "(a key-set
or field-type mismatch; never a field-order difference)". The
`ConditionResolution` row cites §14.2 and §14.3, and `ReadResolution`
(13650) cites §14.4 only; `chapter_new.md` 1387 (§14.9) names both kinds.
`chapter_new.md` 85 (§14.1) names `ConditionResolution` with
`:undeclared_field`, which supports adding §14.1.

### B76. Appendix B owes the snapshot form of `port`

CONFIRMED. Spec 13039: "`port(model, path, name)`, `state(model, path)` and
`modes(model, path)`." `src/dataplane.jl` 480-481:
`port(snapshot::Snapshot, path::String, name::Symbol) =
gather_cell(snapshot.store, snapshot.layout.addr[(path, name)])`. The
frozen spec has no `port(snapshot` spelling. Note: `src/sim.jl` 2304 also
defines `port(sim::Simulation, path::String, name::Symbol)`, which
Appendix B does not list either.

### B77. The Part IV roadmap

CONFIRMED. Spec 9907-9921 names "[§14.1][s14-1]–[§14.6][s14-6] build the
condition ... and apply it through boundary zero ...
[§14.7][s14-7]–[§14.10][s14-10] build trim and linearization", with no
`checkpoint`. Brief R1: "The Part IV roadmap (9907–9921) is not edited: it
belongs to the front-matter rewrite."

### B78. Appendix D `#g-entry` and bare *entry*

UNCONFIRMED. Glossary 13985-13988 does not list only *condition entry*:
"**entry** — never used bare. The spec's compounds are table entry (a
cell), input entry ([§8.2][s8-2]), executor entry ([§9.7][s9-7]), roster
entry ([§11.3][s11-3]), batch entry ([§11.3][s11-3]) and condition entry
([§14.3][s14-3]), each a different thing." *Input entry* is already there,
and *tap* is not an *entry* compound. Chapter 13's carried item says
something else (`docs/spec_rewrite/README.md` 84-85): "`#g-entry` lacks the
wiring entry that §6.1 and §13.3 use (chapter 13's B81)." R13's three words
need no glossary change; the open item is the wiring entry.

### B79. `linearization_walkthrough.md` 572

CONFIRMED. Lines 571-573: "`sim.exec` was never touched, and the sim's
lifecycle is what it was. This is [§14.10][s14-10]'s "pure query": no
commit, no boundary zero, no restore step." D-317's Position (14041-14047)
gives `Simulation` four fields (model, run, data plane, control plane), so
there is no `sim.exec`. `chapter_new.md` 1526: "each restored into the
scratch world". D-072 bullet 3 (2349) supports the Flight.jl reading: "no
commit, no boundary zero, no restore dance".

### B80. `gloss_table.md` row 202

CONFIRMED. `docs/design/tools/gloss_table.md` 202: "| `TrimProblem` |
g-trimproblem | 1 | B | the closed seven-field value specifying a trim |".
Glossary 14787: "the closed nine-field value". `chapter_new.md` 1312: "the
closed nine-field".

## Summary

CONFIRMED: 54. UNCONFIRMED: 6.

UNCONFIRMED: B41 (D-095 names `stop_on`, not `ignore_stop_requests`; D-316
rules the ignore list), B48 (D-130 already has both annotations), B49
(D-242 already has the annotation), B54 (D-262's Position says "The service
never solves them"), B74 (rule 9 is implementation policy, and D-073
covers only the sampled-data half), B78 (`#g-entry` lists six compounds,
input entry included; the carried item is the wiring entry).

Items an existing Position already states, or that follow from one: B36
(D-207, D-414 bullet 4), B43 (D-273 bullet 4), B50 (D-149's own
principle), B53 (D-262, D-113 bullet 3), B60 (D-124), B62 (D-274 bullet 5),
B63's default-point half (D-274 bullet 5), B73's `restore!` row (D-274
bullet 3; D-319 bullet 2), and in part B33 (D-232, D-404, D-274 bullet 2),
B41 (D-316 bullet 7, D-206), B47 (D-414 bullet 4), B54 (D-262), B57
(D-273), B59's carrier half (D-222) and B68's squaring half (D-069 bullet
5, D-070).

Proposals in the retired "annotation in Position form" shape (N1): B33,
B34, B41, B46, B50, B53, B63, B66.
