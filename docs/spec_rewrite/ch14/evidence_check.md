# Chapter 14 evidence check (step 6a)

Items B21 to B80 of `rulings_batch.md`: Landing, Track 2 and Carried. Spec and
log lines are the frozen copies `scratch_survey/h1/spec.md` and
`decisions.md` at `c3d29fb`. `src/`, the companions and `pending.md` are read
at the working tree. Chapter lines are `chapter_new.md` lines. IC1 row
numbers count data rows of `inbound_check_1.tsv`, header excluded, as
`inbound_check_1.md` says.

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
extended to cover environment queries**"; 4961: "**Trim problems never
author the environment** ([§14.7][s14-7], [§14.9][s14-9])"; 4967-4968:
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

CONFIRMED. Rationale 12243-12244: "Authoring at the current level already
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
declare." D-409's Rationale (16354) says "The entry decides nothing new."
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

