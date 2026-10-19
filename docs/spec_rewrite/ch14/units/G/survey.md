<!-- Sliced from survey_2.md for unit G (§14.8, §14.9) by checks/slice_survey.py. -->
# Survey of spec chapter 14, half 2, before its readability rewrite — 2026-10-20

Scope: `docs/design/spec.md` lines 11874–12730 at commit `c3d29fb`, 7,064
words by `wc -w`: §14.7 (11874–12054, 1,469 words), §14.8 (12055–12371,
2,462), §14.9 (12372–12483, 960) and §14.10 (12484–12730, 2,173). Half 1
(the heading and roadmap, §14.1–§14.6, 11267–11873) is the sibling survey's.
The convention is `docs/design/tools/spec_style.md`; the method is
`docs/spec_rewrite/recipe.md` step 1; the model is chapter 13's half-1 survey
(`git show ae63ca9:docs/spec_rewrite/ch13/survey_1.md`).

Line numbers are lines of the frozen copies in `scratch_survey/h2/`
(`spec.md` and `decisions.md` at `c3d29fb`). Lines marked `log` are
`decisions.md` lines. Every claim about an entry rests on the entry as read in
full; `scratch_survey/h2/ent.sh` prints an entry with its line numbers. `src/`
was read at the working tree where a name or a claim was in doubt. The script
that ran the half's code and claims is `scratch_survey/h2/run/blocks.jl`, its
output `run/output.txt` (part C, "Running the half's code"). The half's
inbound rows are in `scratch_survey/h2/mine.tsv`.

Classification codes used in part A, as in chapters 10 to 13:

- **C** cited, and ruled by the cited entry's Position (at the spot or in the
  same paragraph, marked "adjacent").
- **U** ruled by an entry's Position that the section does not cite at that
  spot.
- **S** cited to a superseded entry or clause.
- **R** ruled only in an entry's Rationale, Rejected list or annotation
  (whether or not the entry is cited).
- **N** no entry found. Where the sentence reads as a description of an
  inherited status quo rather than a ruling, the row says so.
- **B** borderline; both readings are given.

"Marking" is how the spec marks the rule now: **Rule.** label, *Why.* label,
bold label (a bold phrase opening a paragraph and acting as a heading),
bold lead-in (a bold sentence or clause opening a paragraph or bullet), bold
sentence, bold term, or plain.

Bold now: 56 spans and 329 words in the half. §14.7 14 spans (104 words),
§14.8 9 (41), §14.9 11 (64), §14.10 22 (120). Labels: **Rule.** ×5 (§14.7 2,
§14.9 1, §14.10 2), **Why.** ×1 (§14.9 12441) and one italic *Why.* (§14.7
11973). Of the 56: nine are bold labels acting as headings (§14.9 12374, 12475;
§14.10 12486, 12526, 12548, 12584, 12601, 12614, 12671), six are the **Rule.**
and **Why.** labels, 22 are bold lead-ins (the §14.7 bullet list 11, §14.9
12385, 12434, 12447 and 12454, §14.10's sampled-data bullets 5, and 12621,
12691), twelve bold a term, a word or a short clause (12077 "pinned
signature", 12085, 12101 "open", 12265–12269 the three residual sets, 12374
"implicitly specified condition", 12463 "value", 12559, 12563, 12646, 12721
"tooling"), and seven are bold sentences or clauses (11924, 12110, 12168,
12182, 12467, 12628, 12672). No bold headline clause
carries its D-citation in its own sentence except 12467 (D-364).

Eight entries that rule much of the half are cited nowhere in the whole
spec: D-071 (mounting, §14.9), D-110 (`trim!`'s `t0` and recording clear),
D-118 (the field set and the residual signature, §14.7), D-124 and D-125 (the
`reads` grammar and `get_face`, §14.7), D-126 (the commit's fired events),
D-155 (projection as the second mover, the two residual sets) and D-188 (the
keyword lift). D-069 and D-150 are cited once each in the half, D-158 once,
D-070 once (and not at its bold, 12168). §14.10 cites superseded D-167 three
times (12519, 12562, 12681); D-295, D-296 and D-263 carry those rulings now.

The half's main factual problems, all spec-lags-code or spec-lags-entry, none
serious: the NLopt fallback is described as present and is unbuilt (F51); the
malformed-problem list misses four refusals the code raises (F52); a seeded
tap refuses a `.name` step and a non-`Float64` leaf, which the spec does not
say (F53); "the build says so" for an internally wired input is resolution's
refusal, not the build's (F54); the frozen cells are copied as `Float64`
values, not embedded (F55); the committed-state residuals cost one `rhs`
evaluation, not a bare gather (F56); and the `product(...)` helper is placed
in §13.7's library, which D-071's annotation of 2026-10-19 refuses (F57,
carried).

## A. Per section

### §14.7 The trim problem: NamedTuple decisions, declared reads, named residuals (11874–12054, 1,469 words)
(§14.7 is another unit's; see the full survey.)

### §14.8 The trim service: solver seam, scratch stores, commit and report (12055–12371, 2,462 words)

Purpose: `trim!` itself: its signature, the backend seam and the verdict,
the tolerance translation, bounds, the two-half scratch world, the commit,
the report and the AD obligation.

Subheadings: eight `####` labels, in order "The backend seam" (12062), "The
convergence verdict is the service's, uniformly" (12107), "The tolerance
translation, per backend family" (12116), "Box bounds and saturated
decisions" (12145), "Scratch stores, stated without type luck" (12152), "The
commit, in full" (12226), "The report, not an exception" (12247), "The AD
obligation, scoped" (12338). Four of them are claims, not topic labels
(12107, 12152, 12247, 12338). No `####` anchor of the half is linked from
anywhere (`rg 'spec.md#'` over `docs/` finds section-level definitions only).
A four-sentence context opens (12057–12060) and names the parts.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 560 | 12057–12060 | "A `TrimProblem` is an inert value until a service runs it. `trim!` is that service. It drives a solver it holds behind one method, works on scratch stores of its own, commits a converged solution the way `init!` would, and returns a report." | plain | D-070 Position | framing (context); counted out |
| 561 | 12064–12067 | "The signature is `trim!(model, problem; baseline, t0 = 0.0, backend = LevenbergMarquardt())`, where `model` is a [`Model`] … at `Float64` ([D-319])." | plain | D-319 bullet 5; D-110 Position (`t0`) | C |
| 562 | 12067–12068 | "`trim!(sim, problem; …)` gates on the simulation's lifecycle and commits through the simulation's `init!`." | plain | D-319 bullet 5 | C, adjacent; confirmed (`src/sim.jl` 757–767) |
| 563 | 12068–12069 | "The default backend is an in-house dense Levenberg–Marquardt." | plain | D-070 Position | U |
| 564 | 12069–12075 | "For decision dimensions ~10 with exact Jacobians, the core is ~100 lines … That is the [§10.2] stepper precedent exactly … They are a convergence test no external package spells natively. That is precisely why the *service*, not the backend, applies it." | plain | D-070 Rejected (external NLS packages) | R |
| 565 | 12077–12078 | "The backend contract is a **pinned signature**, value-passed, with one required method per backend. That one method is the [seam]." | bold term | D-158 Position (headline); D-070 Position ("value-passed backend contract") | C, adjacent (12103); "contract" misuses the reserved word (F66) |
| 566 | 12080–12082 | the `solve` signature block | code | D-158 Position | code; counted out |
| 567 | 12084–12088 | "`eval!(r, J, d)` is in-place and always fills `r` … It fills `J` **iff `J !== nothing`**. The Jacobian is requested by argument …" | bold term | D-158 Position; Rejected (a second method or a flag) | C, adjacent |
| 568 | 12090–12094 | "`d0`, `lower` and `upper` are packed `Vector{Float64}` in `guess`'s field order, with `±Inf` meaning unbounded. … A backend that ignores bounds therefore ignores two vectors, not a missing argument." | plain | D-158 Position; Rejected (bounds as tuples) | C, adjacent |
| 569 | 12096–12098 | "`tol` is a `Vector{Float64}` in `tolerances`' field order. It is data the backend *may* stop on … and it is decisive of nothing." | plain | D-158 Position | C, adjacent |
| 570 | 12100–12103 | "The return holds `d`, the solution, `status::Symbol` from a deliberately **open** set, and the diagnostic counts … The status is recorded verbatim in the report because the verdict is the service's ([D-158])." | bold word | D-158 Position | C |
| 571 | 12103–12104 | "The name `solve` is subject to the exported-name audit (`pending.md`) like every other API spelling." | plain | D-158 Position (last clause) | C, adjacent |
| 572 | 12104–12105 | "The backend sees vectors and never names, so the solution it returns unpacks by the same order it was given." | plain | D-151 Position (packing order) | U |
| 573 | 12109–12111 | "`converged` means `all(abs.(rᵢ) .≤ tolᵢ)`. That is the per-residual box test ([§14.7]) in its own physical units, evaluated **by the service at the backend's returned point**." | bold clause | D-150 Position (bold there) | U; D-150 cited only at 12297 |
| 574 | 12111–12114 | "It is one residual evaluation, noise against the solve that produced it. That verdict, and nothing else, gates the commit and fills `TrimReport.converged`. The backend's returned `status` is recorded in the report as diagnostic data, and it is authoritative over nothing." | plain | D-150 Position | U |
| 575 | 12118–12121 | "The tolerance translation is the service's too, per backend family. In least-squares backends the tolerances *are* the stopping criterion …" | plain | D-150 Rationale (bold "The tolerance translation … is the service's too") | R |
| 576 | 12123–12126 | "The derivative-free scalar fallback is `NLoptBackend(:LN_BOBYQA)` in a package extension. It passes `nothing` for the Jacobian, keeps today's algorithm one keyword away, and leaves the framework core carrying zero optimizer dependencies." | plain | D-070 Position | U; **unbuilt**: no `ext/`, no `NLoptBackend` in the package; `pending.md` 158 lists it (F51) |
| 577 | 12126–12130 | "For that fallback the service squares *and normalizes*. The objective minimized is $\sum_i (r_i/tol_i)^2$ with `stopval = 1`. That objective is dimensionless … It is a well-scaled valley where a raw $\|r\|^2$ sums forces against moments." | plain | D-150 Rationale | R; describes an unbuilt piece (F51) |
| 578 | 12132–12143 | "The two criteria cannot disagree in the dangerous direction: [the display] so the `stopval` sphere is *inscribed* in the tolerance box … What is eliminated is per-backend meanings of `converged`." | plain, one display | D-150 Rationale (soundness, inscribed sphere; "Not claimed: point identity") | R; mid-sentence colon before the display |
| 579 | 12147 | "Box bounds are honored by step projection." | plain | D-070 bullet 1 | U; confirmed (`src/trim.jl` 253, `clamp`) |
| 580 | 12147–12150 | "A decision variable saturated *at the solution* is flagged in the report: "converged with `elevator` at its upper bound". That is the classic CG-limit diagnostic, today inferable only from mysterious residuals." | plain | D-070 bullet 1 | U; the report holds `saturated::Vector{Tuple{Symbol,Symbol}}`, no message string; "today" is Flight.jl's (F65) |
| 581 | 12154–12156 | "Every `trim!` invocation instantiates a fresh working store set. Each half of it (below) is a scratch `Model` of its own, materialized from the deployment the service was called on ([D-317], [D-319])." | plain | D-319 bullet 5; D-282 bullet 2; D-070 bullet 2 | C |
| 582 | 12156–12162 | "The set holds the `x` backing, the `s` and `m` stores, the [root input] and [signal tables], and the derivative [buffer]. The set is built from the [activation]'s *layout* … The buffers are per-invocation and die with the call (stopped-sim allocation, [§9.8])." | plain | D-070 bullet 2; D-135 Rationale | U |
| 583 | 12162–12164 | "Each set also calls every [workspace] allocator once, at the activation's scalar ([D-077])." | plain | D-077 Position | C |
| 584 | 12166–12168 | "The `Dual` backend's buffers being un-aliasable by type is defense in depth, not the mechanism. A `Float64` backend (NLopt) gets equally fresh buffers. The invariant is backend-independent." | plain | D-070 bullet 2 | U; "NLopt" is unbuilt (F51) |
| 585 | 12168–12170 | "**The simulation's authoritative stores have exactly one writer, the commit through [boundary zero]** (the initialization boundary …)." | bold sentence | D-070 bullet 2; Rejected (nominal singleton buffers) | U; no citation in or near it |
| 586 | 12172–12176 | "Setup applies `override(baseline, condition(guess))` to the scratch set once, and that application's full coverage is *checked here*. The check is the comparison of the resolved plan against the `Build`'s `input_faces` ([§14.6]), one plan-level comparison before the first evaluation." | plain | D-149 Position; Rationale (plan-level fact) | U; double of §14.6 11838–11845 (part B) |
| 587 | 12176–12180 | "[Sweeps] therefore see a complete world. Raw instantiation is sound exactly because of that check … An incomplete `baseline` is one declaration-ordered `UninitializedInputs` at setup rather than a whole solve against undefined [cells]." | plain | D-149 Rationale; Rejected (trusting the baseline) | R; kind named |
| 588 | 12182 | "**The frozen cells are established, not probe-seeded.**" | bold lead-in | D-213 Position | C, adjacent (12202) |
| 589 | 12182–12186 | "At the seeded activation the discrete [tier] is frozen ([§9.4]). Its stages never run there, so nothing at that activation can derive a discrete output cell from the authored `s`. Setup therefore instantiates the [scratch] set in two halves." | plain | D-213 Rationale; D-052 | R |
| 590 | 12186–12190 | "A [nominal] set takes the composite first, by the dynamic walk ([§14.4]), and runs one establishment round. That round is boundary zero's sweep with every discrete output stage admitted, due or not ([D-205]), with no [projection], no [guards] and no `s_update`." | plain | D-213 Position | C, adjacent |
| 591 | 12190–12193 | "The seeded set is then written by the specialized `apply!`, and its frozen cells are copied from the nominal set as zero-partial constants (the embedding of [§14.3])." | plain | D-213 Position ("copied as zero-partial constants") | C, adjacent; the copy is a `Float64` value copy, the embedding happens at the consumer's read (F55) |
| 592 | 12193–12198 | "Every cell the iterations read is thus derived from the authored world. A frozen cell holds what the authored discrete state publishes … No scratch cell holds the [probe]'s synthesized values. That is the [§14.6] barrier reaching the scratch world, as [D-205] made it reach the published one." | plain | D-213 Position ("the probe's synthesized products never reach a service evaluation"); Rationale | C, adjacent |
| 593 | 12198–12200 | "The iterations are untouched. They are raw write → sweep → read cycles at the seeded activation, over the continuous chain and `x_deriv` alone ([§14.5])." | plain | D-213 Position (last sentence) | C, adjacent; double of §14.5 11804–11806 |
| 594 | 12200–12202 | "The zero-decision problem (below) is the nominal half alone, and its one evaluation is that establishment round ([D-213])." | plain | D-213 Rationale ("the zero-decision probe falls out as the nominal half alone") | R (cited) |
| 595 | 12204–12207 | "The commit applies the same composite over the same `baseline` (`override(baseline, condition(d*))`, [§14.9]), so its coverage is setup's. Commit's totality check is therefore structurally unfailable through the trim path, and it stands as the shared `init!`-[boundary] defense." | plain | D-149 Rationale | R; "`init!`-boundary" misuses *boundary* and its link (F66) |
| 596 | 12207–12209 | "A converged solve is always committable. `TrimReport` therefore carries no committed flag, and the no-throw doctrine needs no exception." | plain | D-149 Rationale; Rejected (a `committed` flag) | R |
| 597 | 12211–12213 | "Iterations rewrite the composite's write-set via the compiled plan. The write-set is `override(baseline, condition(d))`, the same tree setup resolved, so a store both layers touch merges exactly as it did at setup." | plain | D-068 Position (`override`); D-066 | U (D-066 not read in full; the two-ways-to-apply rule is §14.4's) |
| 598 | 12213–12215 | "An LM evaluation is one Dual-seeded sweep yielding `r` (value parts) and `J` (partials) together." | plain | D-069 Position | U |
| 599 | 12215–12217 | "No convergence means no commit. Non-convergence is the service's box test failing at the returned point, whatever status the backend attached to it." | plain | D-150 Position | U |
| 600 | 12217–12218 | "No commit means the sim is bit-for-bit untouched, including "never initialized". Today's warn-but-assign is structurally impossible." | plain | D-070 Rejected (nominal singleton buffers: "warn-but-assign reborn"); D-135 | R; confirmed (`:built` model stays `:built`, sim stays `built`, part C) |
| 601 | 12220–12224 | "The same structure covers an interrupt. Ctrl-C during a long solve unwinds an ordinary Julia call … The services need no counterpart to the loop's boundary masking ([§12.4])." | plain | D-132 Rationale ("the services need no story of their own"); D-223 bullet 4 | R; silent on an interrupt inside the commit's boundary zero, which D-223 bullet 4 rules (F62) |
| 602 | 12228–12231 | "The committed solution is applied as an `init!` in every respect. It is `override(baseline, solution)` through boundary zero, with the pre-write [root-input totality] check ([§14.6]), the sequence ([§14.5]) and [guards] at commit." | plain | D-110 Rationale; D-068 Position | R; "`override(baseline, solution)`" is loose for `override(baseline, condition(solution))` (F61) |
| 603 | 12233–12234 | "The `t0` argument that anchors the grid, and its default, are the same for both init-service entry points ([§14.5])." | plain | D-110 Position | U; double of §14.5 11792–11803 |
| 604 | 12234–12238 | "The [recorders] restart exactly as [§12.6] states for `init!`. The [trace] and the log are new objects, and any [batches] still in [staging cells] … are cleared." | plain | D-110 Position ("recording clear"); Rationale ("the §12.6 three-item clear") | U |
| 605 | 12240–12241 | "A fresh recording starting at its own anchor is unattended mode's natural shape." | plain | — | N; a reason |
| 606 | 12241–12245 | "A trim at a point reached by flying is not offered. Trim takes an authored baseline. Fly-then-retrim is `checkpoint` the flight, then author the trim's baseline from what the [checkpoint] … shows ([D-273])." | plain | D-273 Rationale ("`trim!` no longer takes a mid-run capture as its baseline"); bullet 4 | R (cited); D-273's Position states the read-only view as an authoring aid, not trim |
| 607 | 12249 | "`trim!` returns a structured `TrimReport`:" | plain | D-070 bullet 3 | U; mid-sentence colon before the block |
| 608 | 12251–12258 | the `TrimReport` sketch, `converged` and "… the remaining fields, enumerated below; this section does not name them" | code | D-070 bullet 3; D-150 | code; counted out; the code names eleven fields (F63) |
| 609 | 12262–12263 | "The `converged` flag is the service's own box test at the returned point, never a backend's opinion." | plain | D-150 Position | U; restates rows 573–574 |
| 610 | 12264 | "The solution NamedTuple is guess-shaped, hence warm-startable." | plain | D-069 bullet 1 | U |
| 611 | 12265–12266 | "The **solved-point residuals** come with their tolerances. They are the very numbers the verdict is read off …" | bold term | D-155 Position | U |
| 612 | 12267–12268 | "The **committed-state residuals** are the same residuals re-gathered from the boundary-zero world after the commit." | bold term | D-155 Position | U |
| 613 | 12269–12271 | "The **committed-state checks** are the check function's return at the committed state … and empty when the problem declares none ([§14.7])." | bold term | D-262 Position | U; empty is `(;)`, and `nothing` with no commit (`src/trim.jl` 131–134) |
| 614 | 12272–12274 | "The backend's returned status comes with its iteration and evaluation counts. These are diagnostic throughout …" | plain | D-150 Position; D-158 Position | U |
| 615 | 12275 | "The saturated-bounds list." | plain | D-070 bullet 1; D-126 Position | U |
| 616 | 12276–12277 | "The commit's fired events, as component paths and event names. The list is empty when boundary zero ran quiet ([§14.5])." | plain | D-126 Position | U |
| 617 | 12279–12281 | "The committed-state residuals are nearly free. That boundary's sweep has already run, so the residuals' declared reads need only gather from it." | plain | D-155 Position ("nearly free — boundary zero's sweep has already run") | U; the code runs one `rhs` for the derivative reads first (F56) |
| 618 | 12281–12284 | "There is no offset caveat to carry. Every output stage publishes at boundary zero ([D-205], [§14.5]), so a residual reading an offset [component]'s [port] reads a commit-refreshed cell like any other." | plain | D-205 Position; Rationale ("dissolves §14.8's caveat") | C |
| 619 | 12284–12286 | "Those committed-state residuals are the numbers describing the state the simulation is actually *in*, which is the point a `linearize` at its default operating point reads." | plain | D-155 Position | U |
| 620 | 12286–12289 | "A non-empty fired-event set also raises `TrimCommitEvents` ([Appendix C]). The committed stores then sit at the post-handler point, not the reported solution, and a `linearize` at its default operating point ([§14.10]) reads that point." | plain | D-126 Position; Rationale | U; kind named; confirmed (`[("trig", :fire)]`, part C) |
| 621 | 12291–12295 | "The two residual sets are what make the moved point auditable. A converged solve whose *committed-state* residuals violate the box test raises `TrimCommitResiduals` ([Appendix C]) … The move, whether `x_projection` or a commit-fired handler ([§14.5]), is surfaced rather than left silent." | plain | D-155 Position | U; kind named |
| 622 | 12295–12297 | "The verdict itself is not re-litigated. It gated the commit, at the solved point, and the numbers ([D-150]) stand as reported." | plain | D-155 Rejected (refusing or reverting the commit); D-150 | R (cited D-150) |
| 623 | 12299–12304 | "The committed-state checks audit the point rather than the move. A converged solve whose committed-state checks leave their tolerances raises `TrimCommitChecks` ([Appendix C]) … ([§14.7], [D-139])." | plain | D-262 Position; Rationale | U; kind named; cites D-139 where D-262 rules |
| 624 | 12304–12307 | "The checks are gathered from the same boundary-zero sweep, so they cost no evaluation of their own. No commit means no checks, exactly as for the committed-state residuals." | plain | D-262 Position; Rationale | U |
| 625 | 12309–12311 | "Non-convergence never throws. It is an expected *outcome*, per the exceptions-are-broken-machinery line ([§13]). In an envelope sweep, hitting the infeasible edge is information." | plain | D-070 bullet 3; Rejected (throw-on-non-convergence); D-060 (the doctrine, §13.5) | U; bare §13 citation (F58, carried); "envelope sweep" is not a [sweep] (F66) |
| 626 | 12311–12313 | "A malformed problem is a different case. It is a `DiagnosticError`-class failure at setup, `TrimProblemInvalid` ([Appendix C])." | plain | D-070 bullet 3 ("a `BuildError` at setup"); D-113 | U; "class" misuses the reserved word (F66) |
| 627 | 12313–12317 | "The malformed cases are a guess/bounds key-set or field-type disagreement, an unknown `reads` [selector], a `tolerances`/residual key-set mismatch observed at the setup guess evaluation, and a `check_tolerances`/check key-set mismatch observed at the same evaluation." | plain | D-118 Rationale; D-151 Rationale; D-262 Rationale | R; the code raises four more reasons (F52) |
| 628 | 12318–12321 | "The error carries the offending field with the names or types in hand, collected, and the read set's own `ReadResolution` values beside it ([§14.4], [D-406]). A permuted spelling is none of these ([§14.7])." | plain | D-406 bullet 2 | C; an unknown path segment is a `PathResolution` (part C) (F52) |
| 629 | 12323–12326 | "A throw inside the commit's boundary zero is a third case … It propagates out of `trim!` as the commit's `StepError`. The simulation is left `built` ([§13.4], [D-223]), and no report is returned for that solve ([D-224])." | plain | D-224 Position; D-223 bullet 3 | C |
| 630 | 12328–12333 | "An *empty* problem is none of them either. [`TrimProblem`]`(guess = (;), …)` is legal … There is nothing to pack, no seeded activation and no backend call. The service simply evaluates the residuals once at the [baseline]." | plain | D-156 Position | U; "at the baseline" is the composite `override(baseline, condition((;)))` in the code (`src/trim.jl` 481); confirmed `:bypassed` (part C) |
| 631 | 12333–12336 | "The ordinary box test decides `converged`, and the commit runs as usual. The degenerate problem is the "is this operating point an equilibrium?" probe …" | plain | D-156 Position | U |
| 632 | 12340–12344 | "The default formulation requires `Dual` genericity of exactly the continuous output-stage chains and `x_deriv`, plus the user's assignment and residual math. The discrete [tier]'s stages and `s_update`, and the event system's guards and handlers, never see a `Dual`. They are frozen constants with zero partials, semantically exact ([§8.2])." | plain | D-070 bullet 4; D-297 bullet 3 | U |
| 633 | 12346–12347 | "This is *not a new obligation*. It is the same activation linearization is defined on." | plain | D-070 bullet 4 ("identical to linearization's activation") | U |
| 634 | 12347–12350 | "AD-readiness is also a build-checked property. The Dual probe detonates [pinned] intermediates with a culprit-naming `InexactError`, and `build(world; activations)` puts it in CI." | plain | D-070 bullet 4 ("build-checked by the Dual probe"); D-280 Position; D-307 Rationale (`MethodError` or `InexactError`) | U; D-307 names two errors, the spec one |
| 635 | 12352 | "C172 migration audit (one afternoon):" | plain | D-070 bullet 5 | U; mid-sentence colon; Flight.jl case material (q27) |
| 636 | 12354–12362 | "`Interpolations.jl` tables … must accept generic scalars. They do. … But prefer cubic knots over linear where partials matter … ([D-307]). A manual chain rule via `Interpolations.gradient` is the escape hatch … ([§14.10], [D-266])." | plain | D-070 bullet 5; D-307 Rationale ("guidance, not rulings") | R (cited); §7.2 1932 points here |
| 637 | 12363–12366 | "In-model saturations … zero Jacobian columns when active. LM damping tolerates the rank deficiency, and the report names the saturated variable ([D-070]). Cruise trim leaves those saturations inactive." | plain | D-070 bullet 5 | C |
| 638 | 12367 | "The landing gear is never evaluated off-zero airborne." | plain | D-070 bullet 5 | U; Flight.jl fact |
| 639 | 12368 | "`norm`-at-zero guards are already in place (e5efb3a)." | plain | — | N; a Flight.jl commit hash (`git cat-file` finds it in Flight.jl, not here) (F65) |
| 640 | 12370 | "The fallback is per problem, through one `backend =` keyword." | plain | D-070 Position ("one keyword away") | U; `backend` is a `trim!` keyword, so the choice is per call, not per problem |

D-158 is cited once (12103) and appears in seven rows (565–571, 614). D-150
appears in nine rows and is cited only at 12297, outside the verdict
subsection. D-070 is cited once (12365) and appears in 23 rows, the bold at
12168 among them. D-155 and D-126 rule the report's
residual and event rows and are cited nowhere in the spec. D-213 is cited
twice and governs rows 588–594.

Descriptions that read like rules: rows 582 (what the store set holds), 590
(what the establishment round runs), 598, 617.

Display-block candidates: the malformed-case list (12313–12317) is a
four-item inline list and reads better as a bullet list once F52 adds the
code's reasons. The `TrimReport` field list (12262–12277) would serve better
as the sketch's own fields (F63).

Glossary terms in §14.8 (lesson 35):

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| `TrimProblem` | 12057 | no; linked at 12329 | yes; late link |
| scratch | 12058 ("scratch stores") | no; linked at 12186 | yes; late link |
| `Model` | 12066 | yes, glossed | yes |
| baseline | 12065 | no; linked at 12333 | yes; late link |
| seam | 12078 | yes, no gloss | yes (the backend seam the entry lists) |
| contract | 12077 ("the backend contract") | no | **no**: reserved for a component's declared interface (F66) |
| root input | 12157 | yes, no gloss | yes |
| signal table | 12158 | yes, no gloss | yes |
| buffer | 12158 | yes, no gloss | yes |
| activation | 12159 | yes, glossed | yes |
| workspace | 12163 | yes, no gloss | yes |
| boundary zero | 12169 | yes, glossed | yes |
| override | 12172 | no; never linked in the section | yes |
| sweep | 12176 | yes, no gloss | yes; "envelope sweep" (12310) is not this sense |
| cell | 12180 | yes, no gloss | yes |
| tier | 12183 | yes; linked again at 12342 | yes; duplicate link (F67) |
| nominal | 12186 | yes, no gloss | yes |
| projection | 12190 | yes | yes; "step projection" (12147) is the bound clamp, not this sense |
| guard | 12190 | yes; linked again at 12231 | yes; duplicate link (F67) |
| probe | 12196 | yes, no gloss | yes |
| boundary | 12207 ("the shared `init!`-boundary defense") | yes | **no**: an `init!` call is not a boundary (F66) |
| root-input totality | 12230 | yes, no gloss | yes |
| recorders, trace, batch, staging cell | 12235–12237 | yes; staging cell glossed | yes |
| checkpoint | 12242 | linked at 12243, glossed | yes |
| component, port | 12283 | yes | yes |
| selector | 12314 | yes, no gloss | yes |
| walked / pinned | 12348 ("[pinned] intermediates") | yes | loose: the entry's *pinned* is a genericity class of parameters and definitions; "pinned intermediates" are `Float64`-annotated values inside authored math (D-307) |
| condition | 12172 | no | yes |

Appendix C kinds cited to §14.8: `TrimProblemInvalid` (13666), named at
12312 where its conditions are listed; `TrimCommitEvents` (13669),
`TrimCommitResiduals` (13672) and `TrimCommitChecks` (13675), each named at
the sentence stating its condition (12287, 12293, 12301). `UninitializedInputs`
(§14.6's) is named at 12179. `ArgumentInvalid` (13722) does not list §14.8,
yet `trim!` raises it as `:non_nominal` and `:claimed` (`src/trim.jl` 447, 459–461,
confirmed in part C); §14.8 states neither condition (F71).

### §14.9 Mounting: problems as relocatable values (12372–12483, 960 words)

Purpose: a `TrimProblem` as an implicitly specified condition, its lift by
`at`, the read set's mount chain, and the environment doctrine that keeps a
problem relocatable.

Subheadings: none. No context paragraph: the section opens on a bold label
(12374). Bold labels at 12374 and 12475; bold lead-ins at 12385, 12434,
12447, 12454; one **Rule.** (12409); one **Why.** (12441).

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 641 | 12374–12375 | "**What a `TrimProblem` is.** It is not a condition but an **implicitly specified condition**." | bold label + bold term | D-071 Position | U |
| 642 | 12375–12378 | "`condition` is a condition-*valued function* over the decision space. `reads`/`residuals` are the equations that pin the free variables down. `guess`/`bounds` say where to search. Solving makes the implicit condition explicit." | plain | D-071 Position | U; "`bounds`" names no field, the fields are `lower` and `upper` (F61) |
| 643 | 12378–12381 | "The commit is then literally an init, `override(baseline, condition(d*))` through [boundary zero] …" | plain | D-071 Position ("committed by initializing with the solved condition") | U |
| 644 | 12381–12383 | "The services unify as clients of one condition algebra. `init!` applies an explicit condition, and `trim!` searches a family for the member satisfying its equations." | plain | D-071 Position ("unifies the services as condition-algebra clients"); D-273 Rationale (`capture` no longer a third client) | U |
| 645 | 12385–12386 | "**`at` lifts a problem field by field, and each field falls in one of three cases.**" | bold lead-in | D-071 bullet 1; D-277 bullet 4 | U |
| 646 | 12386–12389 | "The `condition` field is condition-producing (path-relative), so the lift post-composes it. The `reads` field is a read set, and the lift prepends the prefix to the set's mount chain. Every other field is path-free and passes through." | plain | D-071 bullet 1, annotated by D-277; D-277 bullet 4 | U; "mount chain" used before 12409 defines it (F68) |
| 647 | 12389–12390 | "The rule that residual math sees only the gathered NamedTuple ([§14.7]) pays off here." | plain | D-118 Position | U |
| 648 | 12392–12403 | the `at` lift sketch | code | D-188 Position (keyword form); D-277 bullet 4 | code; counted out; the code's lift is positional and passes a `reads` that is no read set through (`src/trim.jl` 99–103) (F80) |
| 649 | 12405–12407 | "The condition side needs nothing new at resolution. The flattening accumulator of [§14.3] enters each `Scoped` wrapper and prefixes every entry below it." | plain | D-071 bullet 1 | U |
| 650 | 12409–12411 | "**Rule.** A read set carries its mount chain as data. `at(prefix, read_set)` prepends the prefix to that chain and joins nothing. A `Reads` value is no condition node, so `Scoped` never wraps one." | **Rule.** | D-277 Position | C, adjacent (12420) |
| 651 | 12411–12413 | "Resolution walks the chain from the root, each prefix from the level the previous one reached ([§13.3])." | plain | D-277 Position; D-414 bullet 2 | C, adjacent |
| 652 | 12413–12415 | "It then rebases every [selector] … to the root before the selector resolves. A path selector's path is joined to the mount (`"vehicle/dynamics"` → `"wing/vehicle/dynamics"`)." | plain | D-277 Position; bullet 1 | C, adjacent |
| 653 | 12416–12418 | "`get_input` names an input [face] … of the mount level. It follows the export chain to the [root input] it lands on." | plain | D-277 bullet 2 | C, adjacent; D-277's "a face fed by a component is refused with the producer named" is not stated (row 657) |
| 654 | 12418–12420 | "`get_face` names an output face of the mount level and reads its producer's port ([D-277])." | plain | D-277 bullet 3 | C |
| 655 | 12420–12421 | "A refusal spells the selector as authored and names the mount." | plain | D-277 bullet 5 | C, adjacent |
| 656 | 12421–12423 | "`at` refuses an empty prefix on a read set, as it does on a condition node ([§14.2]), and raises `ReadSetMisuse`. A problem's lift and a tap set's lift reach that refusal through `at` on their read sets ([D-278])." | plain | D-278 Position | C; kind named; confirmed (`:empty_prefix`, part C) |
| 657 | 12425–12427 | "Root input entries authored in the aircraft's face vocabulary resolve through the export chain *from the mount point* (`throttle` at `"wing"` → root input `"wing.throttle"`)." | plain | D-071 bullet 2 | U; double of §14.2 11426–11429 (part B) |
| 658 | 12427–12428 | "An unexported face fails resolution by name, and correctly so." | plain | D-071 bullet 2 | U |
| 659 | 12428–12430 | "An internally wired input (a [scenario component] driving the wingman's throttle) is untrimmable from outside, and the build says so." | plain | D-071 bullet 2 ("named by the build") | U; resolution says so, not the build (F54) |
| 660 | 12430–12432 | "The service compiles the scoped condition and reads, and runs the identical loop. It never knows where its paths are mounted." | plain | D-071 (mounting); glossary `#g-mounting` | U |
| 661 | 12434–12435 | "**A problem never authors the environment.** The environment is the world's and the `baseline`'s business." | bold lead-in | D-139 Rationale (bold "Trim problems never author the environment") | R |
| 662 | 12435–12438 | "In a full world it is a sibling [component]'s root inputs. In a thin rig it is a root input holding an isbits handle, or a [constant source] holding a bulk-data one ([D-364])." | plain | D-364 Position | C |
| 663 | 12438–12439 | "The problem *receives* its handles through the user parameter record ([§14.7]), and only queries them." | plain | D-139 Rationale | R; double of §14.7 12040–12041 |
| 664 | 12441–12445 | "**Why.** The reason is the resolution rule just stated. A condition entry naming an internally wired input fails by name, correctly. A problem writing an environment face would therefore be applicable only to those rigs where that face happens to be unconnected …" | **Why.** | D-139 Rationale | R (constructive rationale) |
| 665 | 12447–12449 | "**The world wrapper dissolves.** Flight.jl's `f_init!(::Model{<:SimpleWorld})` (initialize environment, then call the aircraft's trim) has no successor method." | bold lead-in | D-071 bullet 3; Rejected (world-level wrappers) | U; Flight.jl history (F65) |
| 666 | 12449–12452 | "The environment, the other aircraft and all root inputs are covered by the `baseline` condition ([§14.6]), applied once at setup. The commit is `override(baseline, at(mount, condition(d*)))`. Method nesting became value layering." | plain | D-071 bullet 3 | U |
| 667 | 12454–12456 | "**"Aircraft as root" is a thin world.** By default the aircraft is not literally the root. Its environment inputs ([§4.4] function-valued signals) are wired from provider components." | bold lead-in | D-139 Rationale ("softened from doctrine to default"); D-071 Rejected (literal aircraft-as-root idiom) | R |
| 668 | 12456–12461 | "Design tasks therefore use a shipped rig, `design_world(ac)` = aircraft + `SimpleAtmosphere(wind = NoWind())` + `HorizontalTerrain`. That rig is today's ad-hoc models inside `linearize` promoted to a named artifact. There is one mechanism. The "root" case is the shallowest world …" | plain | D-071 bullet 4 | U; reader-cold Flight.jl names, `design_world` unlinked (F65, F67) |
| 669 | 12461–12466 | "Leaving an environment face *unconnected* is legal by construction, though, for an isbits handle. The face becomes an ordinary root input holding the handle **value**, written by the `baseline` like any other root input. That is the test-rig idiom …" | plain, one bold word | D-139 Rationale; D-364 Position (isbits only) | R/C: D-364 Position covers the isbits restriction (cited 12468), D-139's Rationale the idiom |
| 670 | 12467–12468 | "**A handle that references bulk data is never a root input. The rig wires a constant source holding it** ([D-364])." | bold sentence | D-364 Position | C; two sentences in bold where one headline clause would do |
| 671 | 12468–12470 | "Root inputs are traced and checkpointed by value, and such a handle can be neither recorded faithfully nor kept frozen when a writer supplies it ([§4.4], [D-237])." | plain | D-364 Rationale; D-237 annotation (2026-10-13) | R; double of §4.4 976–979 (Part I) and §8.2 2673–2678 (part B) |
| 672 | 12470–12473 | "For design tasks the shipped rig stays `design_world(ac)`. That keeps the environment's tunables in the root-input vocabulary that conditions, linearization's input surface and the [trace header] already speak." | plain | D-139 Rationale | R; repeats row 668's rig |
| 673 | 12475–12477 | "**Swarm doctrine.** The service solves *one problem at a time*. Sequential independent trims … cover weak or one-way coupling." | bold label | D-071 bullet 5 | U |
| 674 | 12477–12479 | "A joint trim is user-side value composition. Concatenate decision NamedTuples under prefixed names, combine the scoped condition trees, and stack the residuals." | plain | D-071 bullet 5; Rejected (framework joint-trim machinery) | U |
| 675 | 12479–12482 | "If joint trims become routine, a `product(p₁ => "lead", p₂ => "wing")` helper belongs in the [§13.7] library. That helper is [recorded, not built] …" | plain | D-071 bullet 6, annotated 2026-10-19 ("the helper is recorded in §14.9. §13.7's library holds components only") | R; contradicts the annotation (F57, carried) |

D-277 is cited once (12420) and governs rows 650–656; D-278 once; D-364
twice. D-071 appears in 18 rows and is cited nowhere in the spec. D-139's
rulings here live in its Rationale only.

Descriptions that read like rules: rows 649 (the flattening accumulator),
660 (the service never knows its mount).

Display-block candidates: none beyond the existing sketch.

Glossary terms in §14.9 (lesson 35):

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| mounting | 12372 (title); 12388 in prose ("mount chain") | no; never linked in the section | yes |
| `TrimProblem` | 12374 | no | yes |
| condition | 12374 | no | yes |
| baseline | 12379 | no | yes |
| `at` | 12385 | no | yes |
| boundary zero | 12379 | yes, glossed | yes |
| selector | 12413 | yes, glossed | yes |
| face | 12416 | yes, glossed | yes |
| root input | 12418 | yes, no gloss | yes |
| scenario component | 12429 | yes, no gloss | yes |
| component | 12417 ("its component's boundary") | linked at 12436 | yes; late link |
| constant source | 12437 | yes; glossed at 12465, a later use | yes; the gloss sits at the second use |
| `design_world` | 12457 | no; `#g-design_world` exists (14744) | yes |
| trace header | 12473 | yes, no gloss | yes |
| recorded, not built | 12481 | yes, glossed | yes |
| override | 12379 | no | yes |
| entry | 12407 ("every entry below it"), 12425 ("Root input entries") | no | loose: condition entries both times; the glossary's compound is "condition entry", never bare |
| field handle | 12437 ("isbits handle") | no | yes |

Appendix C kinds cited to §14.9: `ReadSetMisuse` (13735) cites §14.4 and
§14.9; §14.9 names it at 12422 where the empty prefix's refusal is stated.
The refusals of row 653's internally wired face (`ReadResolution`
`:internally_wired`) and row 659's (`ConditionResolution`
`:internally_wired`) are stated without their kinds (lesson 20, F71).

### §14.10 Linearization: tap selectors, one seeded pass, a pure query (12484–12730, 2,173 words)
(§14.10 is another unit's; see the full survey.)

### Tally

| section | rules | C | U | S | R | N | B |
|---|---|---|---|---|---|---|---|
| §14.7 | 55 | 3 | 33 | 0 | 17 | 2 | 0 |
| §14.8 | 78 | 19 | 41 | 0 | 16 | 2 | 0 |
| §14.9 | 34 | 9 | 17 | 0 | 8 | 0 | 0 |
| §14.10 | 65 | 17 | 27 | 2 | 13 | 6 | 0 |
| total | 232 | 48 | 118 | 2 | 54 | 10 | 0 |

The count leaves out framing, pointers, code, the chart and the table:
rows 501, 511, 512, 550 (§14.7), 560, 566, 608 (§14.8), 648 (§14.9), 683,
694, 695, 706, 740, 744 (§14.10). Each row is classed by its first code
(counted by script over this part); "C, adjacent" counts as C, row 669 (R/C)
and row 725 (R/S) count as R, row 548 (U/R) as U. Row 686 is C for D-197 and
S for D-167, counted C; the two S rows are 702 and 735. In §14.8, 8 of the 19
C rows carry their citation in the sentence itself (561, 570, 581, 583, 618,
628, 629, 637).

The U rows cluster in entries the half cites seldom or never. Counted over
part A's entry column for U rows (a row naming two entries counts for
each): D-070 19, D-069 18, D-071 17, D-072 17, D-118 10, D-151 9, D-150 7,
D-155 6, D-262 5, D-297 5, D-126 4, D-124 3, D-295 3, D-073 3, D-277 3, and
one or two for each of 23 others. The R rows are mostly reasons living in
D-139's and D-262's Rationales (§14.7, §14.9), D-149's and D-150's
Rationales (§14.8), and D-072's, D-197's and D-266's Rejected lists and
Rationales (§14.10). D-167's three citations are rows 686, 702 and 735.

## B. Overlaps

Each item names the lines on both sides, the part A rows, and the home
proposed. Chapters 1 to 13 are rewritten; where an overlap reaches them, the
item says which home the rewritten text already chose. Chapter 14's half 1
is not rewritten, so overlaps with it are ruled jointly with the sibling.

### Inside half 2

- **H51. The derivative-free fallback's normalization, twice.** §14.7
  12011–12015 (row 548) and §14.8 12123–12130 (rows 576–577). Home §14.8,
  where the tolerance translation is the mechanism (D-150 Rationale). §14.7
  keeps "survives as the fallback" with a pointer (M53). Both describe an
  unbuilt piece (F51).
- **H52. The decisions' shape, twice in §14.7.** The field list 11883 (row
  503) and the bold lead-in 11919–11920 (row 513). One statement; the
  bullet's bold is the double.
- **H53. Residual packing, twice in §14.7.** 11961–11966 (rows 535–536) and
  12043–12053 (rows 555–559). Merged by M51.
- **H54. `TrimProblemInvalid`'s conditions, three times.** §14.7 11929–11930
  (row 520), 12048–12053 (rows 558–559), §14.8 12311–12321 (rows 626–628).
  Home §14.8's enumeration (D-118 Rationale), completed by F52; §14.7 names
  the kind once per field with a pointer.
- **H55. D-069's one ruling bold twice.** §14.7 11961 (row 534, "a residual
  system, not a scalar cost") and 11993 (row 544, "nonlinear least squares
  … is the default"). D-069's Position is one sentence; one bold (q24).
- **H56. The problem receives the environment, three times.** §14.7
  12040–12041 (row 554), §14.9 12434 and 12438–12439 (rows 661, 663). Home
  §14.9, which carries the reason (row 664, D-139 Rationale); §14.7 a pointer.
- **H57. `converged`, twice in §14.8.** 12109–12114 (rows 573–574) and
  12262–12263 (row 609). The report's field list may keep a clause; the
  verdict subsection is the home (D-150).
- **H58. The Pinned-entry tap rejection, twice in §14.10.** 12560–12562 (row
  702) and 12687–12689 (row 737); with 12558–12560 (row 701) and 12683–12687
  (row 736) stating the marker twice. Home rows 701–705; row 737 goes (M64).
- **H59. The frozen discrete tier is exact, three times in §14.10.** 12554–12555
  (row 699), 12623–12627 (row 719) and the bold 12627–12630 (row 720), which
  claims it is "stated once". Home of the pass's mechanism: row 699; of the
  law: §7.2 (H75).
- **H60. `design_world(ac)`, twice in one paragraph.** §14.9 12456–12459 (row
  668) and 12470–12473 (row 672).
- **H61. The commit is an init, in both sections.** §14.8 12228–12231 (row
  602) and §14.9 12378–12381 (row 643). Both may stay: §14.9 states what a
  problem is, §14.8 what the commit does. No ruling needed.

### With half 1 (chapter 14, not yet rewritten)

- **H62. The undeclared intermediate and its remedy.** §14.7 11952–11955
  (row 530) against §14.4 11634–11637 ("no selector for a value a component
  computes without declaring it") and 11681–11683 ("The component exports it
  ([§14.7])"). Home: §14.4 for the rule, §14.7 for the remedy, since §14.4
  points to §14.7 for it. §14.7 drops its restatement of the rule (M55).
- **H63. The gather twin.** §14.7 11958–11960 (row 533) against §14.4
  11705–11708. Home §14.4; §14.7 a pointer.
- **H64. Converter selection.** §14.7 11995–11999 (row 545) against §14.3
  11528–11548 (D-148). Home §14.3. §14.7 keeps "a decision-descended leaf is
  `Dual`-typed", because §14.3 11533–11535 cites §14.7 for it (M54).
- **H65. Totality at trim's setup and commit.** §14.8 12172–12180 and
  12204–12207 (rows 586–587, 595) against §14.6 11830–11845 (bold
  "Totality is a precondition of starting", D-149). Home §14.6 for the rule
  and the plan-level comparison; §14.8 keeps the consequence for trim (raw
  instantiation is sound; the commit's check cannot fail), which D-149's
  Rationale states as §14.8's (M58).
- **H66. The iterations are raw cycles.** §14.8 12198–12200 (row 593)
  against §14.5 11804–11806. Home §14.5 for "no boundaries, no events";
  §14.8 keeps the clause with its pointer, as now.
- **H67. `t0` and the two entry points.** §14.8 12064–12068 and 12233–12234
  (rows 561–562, 603) against §14.5 11792–11803, which spells both `trim!`
  signatures. Home: §14.8 for `trim!`'s signature, §14.5 for `t0` (D-110).
  §14.5's signature list could become a pointer to §14.8 (sibling's call).
- **H68. The two movers.** §14.8 12291–12297 (rows 621–622) against §14.5
  11807–11819, which names them and defers the remedy to §14.8. Homes as
  they stand; no ruling.
- **H69. The mount's face resolution.** §14.9 12425–12430 (rows 657–659)
  against §14.2 11435–11442 (a `u` payload names faces of the authoring
  level; an internally wired input has no root input). Home §14.2 for the
  rule; §14.9 keeps the from-the-mount-point consequence.
- **H70. The read side's mount and its empty prefix.** §14.9 12409–12423
  (rows 650–656) against §14.4 11638–11641 (`get_face` of the mount level,
  pointing to §14.9) and §14.2 11425–11431 (the read side's lifts refuse,
  pointing to §14.9). Home §14.9 (D-277, D-278); the others are pointers
  already.
- **H71. The condition-algebra unification.** §14.9 12381–12383 (row 644)
  against the chapter roadmap 11269–11273. No ruling.

### With other chapters

- **H72. The names are the pairing (D-151).** §14.7 11923–11925 (row 516,
  bold) against §9.5 4927–4929 (bold, D-151), which says "[§14.7] states it
  for the trim problem's decisions and residuals". Chapter 9's rewrite chose
  §9.5 as the home of the general rule. §14.7 goes plain with D-151 (q24).
- **H73. The model-code exception doctrine.** §14.8 12309–12310 (row 625)
  against §13.5 10522–10527 ("**exceptions from model code are always
  abnormal**", D-060). Chapter 13 chose §13.5. §14.8 cites §13.5 and drops
  the phrase "exceptions-are-broken-machinery line", which §13.5 does not use
  (F58, carried).
- **H74. A throw inside the commit's boundary zero.** §14.8 12323–12326 (row
  629) against §13.4 10466–10476 ("`trim!`'s commit is an `init!` ([§14.8])
  and inherits the rule ([D-223])"). Chapter 13 chose §13.4 for the
  disposition; §14.8 keeps D-224's no-report ruling, whose only home it is.
- **H75. The frozen discrete tier as the exact answer (Part I's depth).**
  §14.10 12623–12632 (rows 719–721) restates §7.2 1900–1904 ("not a
  limitation but the exact answer ([D-072])", with
  `frozen_discrete_walkthrough.md`) at Part I's depth, as a law about what
  the hybrid semantics means, and bolds it. §9.6 5124–5125 says it a third
  time. Chapter 7's rewrite made §7.2 the home of the law. §14.10 should keep
  the mechanism (the cell frozen in the pass; the step map as the different
  object) and point to §7.2 (M65, q26).
- **H76. Participation by seeding (Part I's depth).** §14.10 12556–12558 (row
  700) against §7.2 1919–1921 ("partials enter only through the directions
  seeded for that evaluation", D-297). Same depth; §14.10 a pointer.
- **H77. Seedability and the meet.** §14.10 12551–12565 (rows 698, 701, 703)
  and 12683–12687 (row 736) against §8.2 2685–2696 (bold "That retyping makes
  seedability schema-visible", D-263, D-295; bold "Fan-out combines tolerance
  by a meet", D-168) and 2713–2715 ("A tap selecting it is rejected naming the
  *pinning consumer* … ([§14.10])"). Chapter 8 chose §8.2 for seedability and
  the meet and pointed to §14.10 for the rejection. §14.10 drops its bold on
  "declaredly unseedable" and keeps the rejection as its home (M63, F60,
  carried).
- **H78. `Pinned` as the FFI door and the freeze door.** §14.10 12671–12689
  (rows 732–737) against §8.2 2545–2555 (the FFI door, bold D-266) and
  2760–2766 ("That delivers the recorded freeze door ([§14.10]). Declare
  `Pinned{Float64}` and strip with `ForwardDiff.value`", D-286), and §9.5
  5018–5023 (bold "The pinned leaf is the schema-visible freeze", D-286).
  Chapters 8 and 9 hold the rule. §14.10 keeps what stays recorded (the
  tooling) and the consequence at tap resolution (M64, q26). Two inbound
  rows need a §14.10 sentence to land on (part D).
- **H79. The local rule's statement.** §14.10 12691–12692 (row 738) restates
  §8.2 2551–2552's bold (D-266) plain. §8.2 points to §14.10 for the rule
  itself. No ruling: the plain restatement introduces the home section.
- **H80. The bulk-data handle in a rig.** §14.9 12467–12470 (rows 670–671)
  against §4.4 974–979 (Part I: never a root input, isbits may be, D-237,
  D-364), §8.2 2673–2678 and §13.7 11048–11050. §14.9 is the rig ruling's
  home (D-364's Position is about the rig) and keeps its bold; the reason
  sentence (row 671) restates §4.4 at Part I's depth and becomes a pointer.
- **H81. The recording restart at the commit.** §14.8 12234–12238 (row 604)
  against §12.6 (rewritten), which states the restart for `init!`. §14.8
  already points; no ruling.
- **H82. The services sketch.** §9.6 5104–5127 sketches trim and
  linearization ("The derivative-free fallback runs the same loop on the
  nominal `Float64` activation", "A failed trim leaves the model's stores
  untouched ([D-070])", "discharges the layer's deletion ([§7.1])"). Chapter
  9 kept §9.6 as a sketch pointing to §14; nothing moves. §9.6 shares F51's
  unbuilt fallback and F64's stale §7.1 pointer.
- **H83. Where the trim warnings live.** §13.2 10139–10141 (rewritten) says
  "`TrimCommitEvents`, `TrimCommitResiduals` and `TrimCommitChecks` are that
  report's fields". The code logs each kind as a warning and puts the lists
  in the report's `fired_events`, `committed_residuals` and
  `committed_checks` (`src/trim.jl` 620, 633, 644, and the `TrimReport` fields 145–157); D-262 says "a
  logged warning that rides the report" and Appendix C "logged. The same list
  rides the `TrimReport`". §14.8 (rows 620–623) says "raises". Not this
  half's text; reported for chapter 13's loose-fix list (F79).
- **H84. The interpolation guidance.** §14.8 12354–12362 (row 636) against
  §7.2 1930–1933 ("**table data is a pinned parameter and the query
  coordinate is walked traffic** … [§14.8] records what that asks of an
  interpolation package"). Chapter 7 chose §14.8 for the guidance; it stays
  there whatever q27 rules.
- **H85. The AD obligation and CI.** §14.8 12340–12350 (rows 632–634)
  against §7.2 1869–1876 (the four consumers, the CI invariant, D-280).
  Different scopes (trim's obligation against the general property); no
  ruling, a citation of D-280 at row 634.

## C. Proposed structure

No section is renumbered and none is retitled. 297 inbound rows point at the
half's sections (part D). No file links a `####` anchor of the half
(`rg 'spec.md#' docs/` finds only section-level link definitions), so §14.8's
labels can change and §14.10 and §14.7 can gain labels freely.

### Moves

| move | content | from | to | needs a ruling |
|---|---|---|---|---|
| M51 | the residual signature block, its **Rule.**, and the two paragraphs after it | §14.7 12025–12053 (rows 550–559) | up, directly after the residual bullet (ends 11966), merging 12043–12053 into 11961–11966 (H53), so the checks bullet's "the residual function's signature" (11968) follows the signature it names | no |
| M52 | §14.7's bullet list | 11919–12023 (rows 513–549) | into paragraphs under `####` labels, in this order: "The fields" (11876–11913), "Decisions and parameters" (rows 513–524), "Reads" (525–533), "Residuals and checks" (534–541 with M51), "The formulation" (542–548), "Recorded extensions" (549) | yes, q25 |
| M53 | the fallback bullet's normalization | §14.7 12011–12015 (row 548) | trimmed to the survival clause and a pointer to §14.8 12123–12130 (H51) | yes, q23 |
| M54 | the converter mechanism | §14.7 11995–11999 (row 545) | trimmed to "a decision-descended leaf is `Dual`-typed in the shape and keeps its partials ([§14.3])" (H64) | no |
| M55 | "A value a component computes without declaring it is not addressable at all" | §14.7 11952–11953 (row 530) | trimmed to a pointer to §14.4; the export remedy and the `y_direct` remedy stay (H62) | no |
| M56 | §14.8's claim-shaped and qualified `####` labels | 12107, 12116, 12152, 12247, 12338 | "The convergence verdict", "The tolerance translation", "Scratch stores", "The report", "The AD obligation" | yes, q25 |
| M57 | the `TrimReport` sketch | §14.8 12251–12258 (row 608) | filled with the code's eleven fields, the "Field by field" list keyed to their names (F63) | yes, q28 |
| M58 | the restated plan-level comparison | §14.8 12173–12175 (row 586) | trimmed to "checked here, as [§14.6] requires", keeping 12176–12180 (H65) | no |
| M59 | the C172 migration audit | §14.8 12352–12368 (rows 635–639) | kept, Flight.jl introduced and the commit hash dropped; or the Flight.jl-only bullets (gear, `norm` guards) to `migration_outline.md`'s existing audit row, keeping the Interpolations and saturation guidance (H84) | yes, q27 |
| M60 | §14.9's bold labels and **Why.** | 12374, 12441, 12475 | plain topic sentences; a context paragraph opens the section and names its parts; "mount chain" glossed at its first use (12388, F68) | no |
| M61 | §14.10's seven bold labels | 12486, 12526, 12548, 12584, 12601, 12614, 12671 | `####` labels: "The tap set", "The operating point", "The seeded pass", "Seeded and frozen leaves", "The returned value", "Coordinate guidance", "The sampled-data extension", "Declared non-participation" | yes, q25 |
| M62 | the operating-point paragraph | §14.10 12584–12599 (rows 707–712) | up, after the tap set (ends 12524) and before the seeded pass (12526), which "establishes the operating point in it (below)" | no |
| M63 | the seedability restatement | §14.10 12551–12560 (rows 698, 700, 701) | trimmed to a pointer to §8.2 2685–2689, bold removed; the rejection (rows 702–705) stays, its home (H77) | no; carried (F60) |
| M64 | the two non-participation halves | §14.10 12672–12689 (rows 732–737) | trimmed to one paragraph pointing to §8.2 and §9.5 for the spelling, keeping the conformance clause (row 734), the root-input "choice versus declaration" (row 736) and the tooling (rows 745–746); row 737 merged into row 702 (H58, H78) | yes, q26 |
| M65 | the frozen-exact restatement | §14.10 12623–12632 (rows 719–721) | trimmed to the mechanism and a pointer to §7.2 (H75); the bold goes | yes, q26 |
| M66 | the reason sentence of the bulk-data handle | §14.9 12468–12470 (row 671) | a pointer to §4.4 (H80) | no |

All moves stay inside one section, and each stays inside one unit (below).

### Order within each section

Define-before-use was checked for each order below against the terms each
block uses.

- **§14.7 (q25).** Context (11876–11878, gaining one sentence naming the
  parts); "The fields": the **Rule.**, the list, the `tolerances` sentence,
  the worked block; "Decisions and parameters"; "Reads"; "Residuals and
  checks": the residual system, the signature block and its **Rule.** (M51),
  the packing, then the checks, which now follow the signature they share;
  "The formulation": FlightCore's core, the numerics, the least-squares
  default, non-squareness, the fallback (M53); "Recorded extensions".
  Checked: "committed state" (checks) points forward to §14.8, as now; the
  worked block precedes the field discussion that cites its names
  (`throttle`, `α`).
- **§14.8.** Unchanged order under the relabelled `####`s (M56). The
  commit paragraph 12204–12209 stays after setup's coverage check, because
  its argument is that the commit's coverage is setup's. Checked: "nominal
  set" and "seeded activation" are introduced at 12182–12186 before
  12204's commit; "the zero-decision problem (below)" is a forward pointer
  kept.
- **§14.9 (M60).** A context paragraph (a problem is a relocatable value;
  `at` lifts it; the environment stays the world's), then the implicit
  condition, the lift and its sketch, the condition side, the read set's
  **Rule.**, the mount's root-input resolution, the environment doctrine and
  its reason, the world wrapper, the thin world, the swarm. Checked: "mount
  chain" is glossed at 12388, its first use.
- **§14.10 (M61, M62).** Context (what linearization computes and the
  parts in order); "The tap set" (rows 676–689); "The operating point"
  (rows 707–712, moved up by M62); "The seeded pass" (690–696); "Seeded and
  frozen leaves" (697–706, with M63); "The returned value" (713–715);
  "Coordinate guidance" (716–717); "The sampled-data extension" (718–731,
  with M65); "Declared non-participation" (732–746, with M64), the local
  rule among them. Checked: the pass's "establishes the operating point in it
  (below)" becomes "above"; "the recorded step-map extension below" (12520)
  and "the recorded step map below" (12571) still point forward to their
  `####`; `design_world` (12617) follows §14.9, which introduces it.

### Rewrite units

| unit | lines (original) | sections | moves in | words |
|---|---|---|---|---|
| F | 11874–12225 | §14.7; §14.8 to the end of "Scratch stores" | M51–M56, M58 | 2,840 |
| G | 12226–12483 | §14.8 from "The commit, in full"; §14.9 | M57, M59, M60, M66 | 2,051 |
| H | 12484–12730 | §14.10 | M61–M65 | 2,173 |

Total 7,064 words. Units I to K are unused.

§14.8 spans F and G at its `####` "The commit, in full", a clean cut: G's
part reads the scratch world only through pointers. The brief must assign
§14.8's first-use links: every §14.8 term whose first use is in F takes its
link in F, `TrimProblem` (12057) and `baseline` (12065) included, and G
links only the terms it uses first (`checkpoint` 12242, `trace` 12236,
`recorders`, `batch`, `staging cell`, `selector` 12314, `walked` 12348).
M56's relabelling crosses the cut and is one ruling for both units.

G and H fall under the 2,500-word floor. The alternatives: two units, F′ =
§14.7–§14.8 (11874–12371, 3,931 words) and G′ = §14.9–§14.10 (12372–12730,
3,133), each over the 3,000 ceiling, F′ by a third; or F″ = 11874–12151
(2,199), G″ = 12152–12483 (2,692), H (2,173), which splits §14.8 between its
seam and its scratch world. Recommendation: F, G, H (q29). F is in range,
each move sits in one unit, and the cut falls between the solve and its
commit.

### Code blocks, charts and tables

The half holds seven code blocks, one display formula, one chart and one
table:

- 11899–11913: the cruise `TrimProblem`, a `julia` fence. Carry verbatim.
- 12027–12029: the residual signature, a `julia` fence. Carry; moves with M51.
- 12080–12082: the `solve` seam signature. Carry verbatim.
- 12134–12135: the inscribed-sphere implication, a `$$` display. Carry.
- 12251–12258: the `TrimReport` sketch. Carry, or fill under q28 (F63).
- 12392–12403: the `at` lift on a `TrimProblem`. Carry verbatim.
- 12505–12511: the tap-set example. Carry verbatim.
- 12539–12543: the seeded-pass chart (a plain fence). Carry verbatim.
- 12574–12582: the seeded-and-frozen table, seven rows. Carry; its two
  `Pinned` and discrete rows stay with the rejection (M63).
- 12700–12710: the local rule, a `julia` fence. Carry verbatim.

Lists: §14.7's field list (11883–11891) and bullets (11919–12023), §14.8's
report fields (12262–12277) and the C172 audit (12354–12368), §14.10's
sampled-data bullets (12641–12657).

### Running the half's code

Loaded with `test/repl.jl` inside `module H2Check`, with `fed` copied from
`test/utils.jl` (script `scratch_survey/h2/run/blocks.jl`, run with
`julia --project=test -t 2`; output in `run/output.txt`). The fixtures are
the suite's `Pendulum`, `Sum`, `VectorPlant`, `StateFeedback`,
`DiscreteAccumulator`, `Trigger` and `PinnedGain`, plus three defined in the
script (`Opaque`, `DuoSink`, `Duo`). Every check printed its result; none
failed.

- **11899–11913, the cruise problem: cannot run as written** (Flight.jl's
  C172: `trim_condition`, `ac`, `params`, the `vehicle/…` paths). Its shape
  ran on the pendulum: a nine-field keyword `TrimProblem` with `checks` and
  `check_tolerances` converged to θ = 0.41998548 (asin(4/9.81) =
  0.41998548), `committed_checks = (θ_check = -3.9e-16,)`, status
  `:converged`, 5 evaluations, 4 iterations. `fieldnames(TrimProblem)` are
  the nine the section lists, in its order.
- **12027–12029, the residual signature: cannot run** (a signature). Every
  problem above calls `residuals(reads, d)` in that order.
- **12080–12082, the seam: ran and passed.** `solve(LevenbergMarquardt(),
  eval!, [1.0], [-Inf], [Inf], [1e-12])` on $d^2 - 2$ returned keys
  `(:d, :status, :n_evaluations, :n_iterations)`, `d = [1.41421356…]`,
  status `:converged`.
- **12134–12135, the implication: checked by sampling.** 100,000 random
  `(r, tol)` triples: whenever $\sum (r_i/tol_i)^2 \le 1$, every
  $|r_i| \le tol_i$.
- **12251–12258, the report sketch: cannot run** (pseudo-code, `…`). The
  code's fields are `converged, solution, residuals, tolerances,
  committed_residuals, committed_checks, status, n_evaluations,
  n_iterations, saturated, fired_events` (F63).
- **12392–12403, the `at` lift: ran and passed.** The spec's sketch, typed
  in as a function `at_spec`, and the package's `at` both mounted a
  pendulum problem at `"wing"` and converged to the same θ = 0.41998548. The
  package's lift is positional, not the sketch's keyword form (F80).
- **12505–12511, the tap set: cannot run as written** (Flight.jl paths). The
  same shape on `lin_pend` (two states, two root inputs, a `get_output` and
  a `get_face`) gave `A = [0 1; -9.3719 -0.5]` with `A[2,1] = -g cos θ`
  exactly, `B = [0 0; 1 -1]`, `C = [1 0; 0 0]`, `D = [0 0; 1 -1]`. A vector
  state tapped as `"q[1]"`, `"q[2]"` and a vector root input as `"qin[1]"`
  resolved; an unindexed vector tap was `TapResolution` `:vector_tap`.
- **12700–12710, the local rule: ran and passed.** Inside a continuous
  component `Opaque` whose `x_deriv` calls `lookup` on a cubic standing in
  for a C table, `linearize` gave `B = 13.50000012` against the exact
  $3a u^2 = 13.5$: finite-difference quality on the one component, as
  12714 says, and `A = [-1.0]` exact.
- Claims checked in passing:
  - Permuted bounds and a permuted residual order (row 519, 557): the same
    solution `(θ = 0.3, u = 2.89905…)`, both converged.
  - `TrimProblemInvalid` reasons: bounds key set `:key_set`, tolerances key
    set `:key_set`, an inverted box `:inverted_box`, a zero tolerance
    `:nonpositive_tolerance` (the last two unlisted in §14.8, F52). An
    unknown `reads` path raised `PathResolution` `:unknown_child`, not a
    `ReadResolution` (F52).
  - A non-converged solve (θ boxed to [0, 0.2]): `converged = false`, status
    `:stalled`, `saturated = [(:θ, :upper)]`, `committed_residuals =
    nothing`; the model stayed `:built` and a simulation stayed `built`
    (rows 600, 613).
  - The empty problem: converged, status `:bypassed`, one evaluation (row
    630).
  - A commit that fires a guard: `fired_events = [("trig", :fire)]` and the
    `TrimCommitEvents` warning in the log (row 620).
  - `trim!` on a `Model{LinearizeDual}`: `ArgumentInvalid` `:non_nominal`;
    on a model a simulation claimed: `ArgumentInvalid` `:claimed` (F71).
  - `at("", problem)` and `at("", read_set)`: `ReadSetMisuse` `:empty_prefix`
    (row 656).
  - **An internally wired input under a mount** (row 659): the mounted
    condition raised `ConditionResolution` `:internally_wired` at `trim!`'s
    setup, the mounted `get_input` `ReadResolution` `:internally_wired`, and
    `build` of the same tree raised nothing (F54).
  - `linearize`'s refusals: the default form on a `:built` model
    `ServiceLifecycle`; a `t0` without `about` `ArgumentInvalid`
    `:t0_without_about`; an `x` tap on a discrete store `:discrete_state`; a
    `u` tap read by a discrete consumer `:unseedable`; two taps at one site
    `:duplicate_site`; a `get_input` in the `x` list `:tap_kind`; a `Pinned`
    root input `:unseedable` with `pinning = [("g", :continuous,
    Pinned{Float64})]`; **a `u` tap with a `.name` step (`"in.a"` on a
    struct root input) `:unseedable`** (F53).
  - After `trim!(sim, …)`, the default `linearize(sim, …)` read `x₀.θ` at
    the trim point; the simulation was `initialized` (row 711).
  - `width = 1` and the default 8 gave identical `A`, `B`, `C`, `D` (row 692).
  - Outside any spec claim: a walked struct root input with no `convert`
    method between its scalar instances (`Duo{Float64}` to `Duo{Dual}`)
    makes the default operating point die in a raw `MethodError` from
    `convert` (`src/linearize.jl` 191–195, the root-input loop). §14.3's
    "the type's ordinary `convert`/constructor methods" covers condition
    writes; nothing names the obligation for this copy. Reported, not a
    finding of this half.

## D. Inbound citations

The rows analysed are the 297 rows of `inbound.tsv` whose target is §14.7,
§14.8, §14.9 or §14.10 (copied to `scratch_survey/h2/mine.tsv`). Bare §14
rows belong to half 1.

By file: `decisions.md` 162 (Spec 86, Rationale 34, Position 21, Rejected
16, Annotation 3, the index and a heading 2), `spec.md` 63, companions 47
(`trim_environment_walkthrough.md` 19, `longitudinal_aircraft.md` 6,
`linearization_walkthrough.md` 4, `flight_case_studies.md` 4,
`lqr_tracker.md` 3, `handle_walk_walkthrough.md` 2,
`frozen_discrete_walkthrough.md` 2, `sample_time_proposal.md`,
`pid_anti_windup.md`, `migration_outline.md`, `linear_blocks.md` and
`examples_inventory.md` 1 each), `implementation.md` 18, `extensions.md` 8,
`pending.md` 1. The 63 `spec.md` rows: Part I 5, Part II 14, Part III 3,
Part IV's roadmap and chapter 13 11, Appendix B 8, Appendix C 9, the
glossary 13.

By target: §14.7 64, §14.8 81, §14.9 59, §14.10 93 (in `spec.md` alone: 12,
20, 12, 19).

Ranges recorded at their ends only: spec 9918 and `extensions.md` 52
("§14.7–§14.10") also cover §14.8 and §14.9; `implementation.md` 973
("§14.5–§14.9") also covers §14.6 (half 1's) and §14.7–§14.8 (this half's).
`implementation.md` 278 ("§14.1–§14.6") is half 1's alone.

### Citations relying on moved or trimmed content

| move | file:line | fact relied on | after the move |
|---|---|---|---|
| M53 | log 5716 (D-150 Rejected) | the hand-scaled `stopval` "[§14.7] itself criticizes FlightCore for" | holds: row 543 (the numerics bullet) stays |
| M53 | spec 12129 (§14.8, inside the half) | "FlightCore's threshold was hand-scaled and absolute ([§14.7])" | holds as above |
| M54 | spec 11533–11535 (§14.3) | "every decision-dependent leaf is `Dual`-typed in the shape ([§14.7])" | holds only if §14.7 keeps that clause, as M54 does |
| M54 | log 5587 (D-148 Position) | the same clause | as above |
| M55 | spec 11683 (§14.4) | "The component exports it ([§14.7])" | holds: the export remedy stays |
| M55 | log 4140 (D-125 Rationale) | the `y_direct` idiom "beside [§14.7]'s `reads` bullet" | holds: the remedy stays, in the "Reads" paragraph after M52 |
| M58 | log 5655 (D-149 Rationale) | "[§14.8]'s raw scratch instantiation is thereby sound **because** of the check" | holds: 12176–12177 stay |
| M59 | spec 1932 (§7.2) | "[§14.8] records what that asks of an interpolation package" | holds under either option of q27: the Interpolations bullet stays |
| M59 | `migration_outline.md` 28 | the audit row cites §14.8 | holds if the audit stays; under the move option the row cites §14.8 for the Interpolations guidance only |
| M63 | spec 2689 (§8.2) | "a `Pinned` root input is *declaredly* unseedable ([§14.10])" | holds if §14.10 keeps "declaredly unseedable" plain beside the rejection |
| M63 | spec 2715 (§8.2) | the rejection naming the pinning consumer ([§14.10]) | holds: rows 702–705 stay |
| M64 | spec 2764 (§8.2) | "That delivers the recorded freeze door ([§14.10])" | holds only if §14.10 keeps one sentence naming the output half as the declared freeze door, pointing back to §8.2; otherwise the two sections point at each other with nothing at either end |
| M64 | log 10959 (D-263 Rationale), 12614 (D-286 Rationale), 2607 (D-079 Rationale), 6287 (D-166 Rationale, superseded) | "[§14.10]'s freeze door and the FFI door survive as declared doors" | as above |
| M65 | log 7628 (D-197 Rationale) | "The frozen-discrete doctrine ([§14.10]) already fixes the semantics" | holds loosely: row 699 keeps the frozen tier in the pass; the doctrine's law is §7.2's (track 2 may add §7.2) |
| M65 | `linearization_walkthrough.md` 608 | "[§14.10]'s frozen-exact doctrine" | as above |
| M66 | spec 11050 (§13.7) | the rig's constant source ([§14.9], [D-364]) | holds: the bold stays |
| M51, M52 | spec 14927 (glossary, `worked`) and log 3919 (D-118 Rationale) | the worked C172 cruise problem of §14.7 | holds: the block stays |

M56, M61 and M62 relabel or reorder within their sections, and no row names
a `####` anchor or a moved sentence by position.

### Citations already wrong before the rewrite

The inbound check will flag these whatever the rewrite does; they belong to
track 2 or to their own chapters.

| file:line | claim | what half 2 or the code says |
|---|---|---|
| spec 13199–13200 (Appendix B, `trim!(sim, …)`) | "The problem itself closes at seven fields ([§14.7])" | nine since D-262 (§14.7 11880–11891, `fieldnames(TrimProblem)`) |
| spec 13201 (Appendix B) | "The commit is `init!` with `override(baseline, solution)`" | `override(baseline, condition(solution))` (`src/trim.jl` 612); loose like row 602 (F61) |
| spec 13212 (Appendix B) | "Non-convergence reports, never throws ([§14.7], [§14.8])" | §14.7 states no throw policy; §14.8 alone |
| spec 13723 (Appendix C, `ArgumentInvalid`) | lists §14.7 among its sections | §14.7 raises none; the `:non_nominal`, `:claimed` and `:t0_without_about` reasons are §14.8's and §14.10's, which the row does not list (F71) |
| spec 13661–13665 (Appendix C, `TapResolution`) | its reasons: the list, a discrete store, a vector leaf, a duplicate site, an unseedable root input | the `.name` step and the non-`Float64` leaf ride `:unseedable` without being stated (F53) |
| spec 14782–14786 (glossary, `taps`) | "Every tap names one scalar, by a leaf address resolving to one scalar leaf" | a seeded tap also takes at most one index step (F53) |
| spec 10139–10141 (§13.2) | the three `TrimCommit…` kinds "are that report's fields" | logged warnings; the report holds their lists (H83, F79) |
| spec 5113–5114 (§9.6) | "The derivative-free fallback runs the same loop on the nominal `Float64` activation" | unbuilt (F51) |
| spec 5122–5123 (§9.6) | "That replacement discharges the layer's deletion ([§7.1])" | §7.1 no longer promises a deletion (F64) |
| spec 13059 (Appendix B, `linearize(model, …)`) | default point `checkpoint(model)` ([§14.10]) | holds; listed only because D-272's Position still says `capture(sim)` (part E) |
| log 2350 (D-072 bullet 3) | "its default operating point is `capture(sim)`, `capture` settled as the full-store gather returning `(condition, t)`" | `checkpoint` since D-273/D-274; no annotation on D-072 |
| log 11780 (D-272 bullet 4) | "The operating point is `capture(sim)` by default" | `checkpoint(sim)` (D-274 bullet 5); D-272's annotations do not record it |
| log 4182 (D-126 Rationale), 5896 (D-155 Position) | "`capture`-defaulted `linearize` ([§14.10])" | checkpoint-defaulted; stale vocabulary in a Position (D-155) |
| log 3555–3560 (D-108 Position) | `capture` requires `initialized`/`stopped`; `linearize` inherits `capture`'s precondition | `checkpoint`; D-108 carries no annotation for it |
| log 2276 (D-070 bullet 3) | "a malformed problem a `BuildError` at setup" | a `DiagnosticError` carrying `TrimProblemInvalid` (D-222's rename) |
| log 2235 (D-069 bullet 2) | "reads are declared via `deriv`/`output` selectors" | the five `get_` selectors (D-095, D-124) |
| log 3903 (D-118 Position) | "The `TrimProblem` field set closes at seven" | nine (D-262); D-118 carries no annotation |
| log 2311–2312 (D-071 bullet 2) | an unexported face is untrimmable, "named by the build" | named by resolution at `trim!`'s setup (F54) |
| log 4310 (D-130 Position) | "mount prefix is checked by the mount itself, [§14.9]'s contract validation" | amended by D-414 (log 16471); chapter 13 recorded D-130's other staleness |
| log 16198 (D-406 Position) | "`TapResolution` keeps [§14.10]'s five tap-set reasons" | holds (five reasons in `src/diagnostics.jl`), though §14.10 never names the kind (F71) |
| log 6437 (D-167 Rejected) | the participation trait hinge for "[§14.10]'s sampled-data door" | a superseded entry is the only statement of row 725's ruling |
| log 4968 (D-139 Rationale), `trim_environment_walkthrough.md` 161, 575 | quote §14.9's "the aircraft is never literally the root" | history: the spec now says "By default the aircraft is not literally the root" (12454–12455). Holds as history |

### Log entries whose Spec field would change

- Under M51–M66: none; every move is inside its section.
- Spec fields stale before any move, entries that rule half 2 without
  listing its section (track 2):
  - D-070: lists §14.8; rules §14.7's fallback and numerics (rows 546,
    548).
  - D-213: lists §14.8; rules §14.10's two-half world (row 690).
  - D-286: lists §8.2, §9.5; rules §14.10 rows 733–734.
  - D-237: lacks §14.9, though cited at 12470.
  - D-406: lacks §14.8, though cited at 12320.
  - D-414: lacks §14.9; its bullet 2 cites §14.9.
  - D-317: lacks §14.8, though cited at 12156.
  - D-223: lists §12.6, §13.4; cited at §14.8 12325.
  - D-273: lacks §14.8, though cited at 12245.
  - D-280: lists no §14 section; rules row 634.
  - D-148: lists §14.7 and §14.10; fine. D-072: fine. D-151: fine.
  - D-155, D-126, D-071, D-118, D-124, D-125, D-188, D-110: Spec fields
    list the half's sections correctly, but the spec cites none of them
    (part E).

## E. Log repairs and factual problems

Log repairs go to the second track, after landing. The rewrite only adds or
replaces citations; it states no repair. Factual problems stay as written and
go to the units' `rulings.md`, unless part G pre-rules them.

### Entries to cite at the rule

From part A's U rows, each entry read in full:

- **D-118** (rows 502, 506, 507, 509, 523, 551, 552, 555): the field set and
  the residual signature's rule. Cited nowhere in the spec.
- **D-151** (503, 515, 516, 518, 535, 536, 556, 572): the pairing by name and
  the canonical orders. Cite at row 516 in place of the bold (H72).
- **D-069** (513, 523–525, 534, 544–547, 598, 610): the formulation. Cited
  only at 11992.
- **D-071** (504, 641–646, 649, 657–660, 665, 666, 668, 673, 674): mounting.
  Cited nowhere in the spec.
- **D-124, D-125** (526, 527, 529): the `reads` grammar, its validation
  targets and `get_face`. Cited nowhere in the spec.
- **D-070** (563, 576, 579–582, 584, 585, 607, 615, 625, 626, 632–635, 638, 640): the
  service, the scratch sets, the one writer (bold 12168), the report, the AD
  obligation. Cited only at 12365.
- **D-150** (573, 574, 599, 609, 614): the verdict. Cite in the verdict
  subsection, at the bold clause (row 573).
- **D-155** (611, 612, 617, 619, 621): the two residual sets and
  `TrimCommitResiduals`. Cited nowhere in the spec.
- **D-126** (615, 616, 620, 711): the fired-event list and `TrimCommitEvents`.
  Cited nowhere in the spec.
- **D-156** (630, 631): the empty problem. Cited elsewhere in the spec, not
  here.
- **D-110** (603, 604): `trim!`'s `t0` and the recording clear. Cited nowhere.
- **D-149** (586): setup's totality check; and D-282 or D-135 (582) for the
  per-invocation buffers.
- **D-262** (613, 623, 624): the committed-state checks in the report;
  row 623 cites D-139 where D-262 rules (F81).
- **D-072** (679, 685, 688–690, 693, 697, 699, 707, 708, 714–717, 719): the
  linearization surface. Cited in §7.1 and §7.2, never in §14.10.
- **D-073** (718, 726): the sampled-data activation recorded unbuilt.
- **D-295** (698, 701, 736), **D-296** (702–704, 737): seedability and the
  pinning consumer, in place of D-167 (F59).
- **D-297** (632, 697, 699, 700, 719): seeding, not typing; the frozen
  discrete output exact.
- **D-286** (733, 734): the pinned leaf held to its word.
- **D-280** (634): the `Dual` activation in CI.
- **D-148** (545): the per-leaf converter, if the clause stays (M54).
- **D-277** (645, 646): the lift's read-set field.

### Superseded and half-superseded citations

- **D-167** (cited 12519, 12562, 12681; rows 686, 702, 735; carried): status
  superseded → D-263. At 12519 cite D-197 alone, whose Rationale names
  "[D-167]'s no-silent-zeros principle" and whose Position is the `x`-tap
  rejection. At 12562 cite D-295 bullet 3 (declaredly unseedable) and D-296
  bullet 4 (the rejection). At 12681 ("The input half is [D-167]") cite D-263
  bullet 2: "The permissive reading of `input_types` ([D-167]) stands with
  the marker as its spelling … a `Pinned` one demands a frozen arrival".
- **D-072** (not cited in the half, cited at §7.2 1902 for the frozen
  discrete tier): bullet 3's `capture(sim)` default is overtaken by D-274
  bullet 5. Cite D-072 only for its standing clauses (the three lists, the
  shuttle deletion, the pure query, the labeled return, `LinearizedSS`, the
  guidance) and D-274 for the operating point.
- **D-272** (cited five times): bullet 4's `capture(sim)` is overtaken by
  D-274 bullet 5; the half cites D-272 at 12605 and 12571 for clauses that
  stand. Row 709 already cites D-274 and D-319 for the default point.
- **D-070** (cited 12365): bullet 3's "`BuildError`" is D-222's
  `DiagnosticError`; its other clauses stand.

### Rulings that need an entry stating them in a Position

1. "Two taps resolving to one site are rejected together, both labels in
   hand" (row 682): D-272's annotation of 2026-09-28. The tier-pinned root
   input's refusal naming the tier (row 705): the same annotation.
2. The participation trait that "turns the walk on for its contracts" (row
   725): D-167's Rejected list, a superseded entry; D-263's Rationale only
   brushes it.
3. The frozen-discrete step map as the "different object", and $\Phi$'s
   event-quiescent scope (rows 722, 729): D-197 Rationale, D-073 Rejected.
4. The environment doctrine, "a problem never authors the environment" (rows
   554, 661, 663, 664) and "aircraft as root" as a default (row 667):
   D-139's Rationale, where both are bold. D-364's Position covers only the
   bulk-data handle.
5. The tolerance translation per backend family and the inscribed-sphere
   soundness (rows 575, 577, 578): D-150's Rationale.
6. Setup's checks of the residual and check returns at the guess (rows 539,
   558, 627): D-118's and D-262's Rationales.
7. The permuted bound as a non-event, and the reorder of the residual
   return (rows 519, 557): D-151's Rejected list (the Position states the
   canonicalization, the Rejected list the hazard).
8. The services need no counterpart to boundary masking (row 601): D-132's
   Rationale.
9. Commit's totality unfailable through the trim path; no `committed` flag
   (rows 595, 596): D-149's Rationale and Rejected list.
10. The interpolation guidance, prefer cubic knots (row 636): D-307's
    Rationale calls it "guidance, not rulings"; D-070 bullet 5 states the
    audit. May need none.
11. Fly-then-retrim (row 606): D-273's Rationale ("`trim!` no longer takes a
    mid-run capture as its baseline").
12. The checks stay out of the solve (row 541): D-262's Rejected list.
13. The external NLS packages rejected, the §10.2 precedent (row 564): D-070's
    Rejected list; constructive rationale, may need none.

### Rulings with no entry at all

- The two `TrimProblemInvalid` reasons the code adds, `:inverted_box` and
  `:nonpositive_tolerance` (F52): no entry; `git log -S'inverted_box'` finds
  them in a code commit (`3408028`).
- The seeded tap's step limit, at most one index step and no `.name` step,
  and the `Float64` leaf (F53): no entry; the suite cites "§14.10, D-036,
  D-276" for it (`test/test_linearize.jl` 308), neither of which states it.
- The non-participation tooling, pinned-face validation and the
  feedthrough-graph lint (row 745): no entry records either.
- The sampled-data extension's walked-leaf parametrization, forward
  sensitivities and the "loud diagnostic" for an event inside a
  differentiated step (rows 724, 727, 730): recorded design, no entry beyond
  D-073's "recorded unbuilt".
- Descriptions needing none: rows 521 (warm-start by `merge`), 522, 605,
  723, 746.

### Stale entry text and Spec fields

- D-069 bullet 2 (log 2235): "`deriv`/`output` selectors" (D-095's prefix,
  D-124's widening).
- D-070 bullet 3 (log 2276): "`BuildError`".
- D-071 bullet 2 (log 2311–2312): "named by the build" (F54).
- D-072 bullet 3 (log 2349–2351): `capture(sim)` and "`capture` settled as
  the full-store gather returning `(condition, t)`"; no annotation since
  D-273.
- D-108 Position (log 3555–3560): `capture`'s precondition; no annotation.
- D-118 Position (log 3903): "closes at seven"; D-262 added two, no
  annotation.
- D-126 Rationale (log 4182), D-155 Position (log 5896): "`capture`-defaulted
  `linearize`".
- D-272 bullet 4 (log 11780): `capture(sim)`; its two annotations do not
  record D-274.
- D-213 Spec: lacks §14.10. Other Spec fields: part D's list.

### Findings carried from earlier chapters

`docs/spec_rewrite/README.md` 43–80, "Carried to later chapters", lists
four items in this half's sections. Each is confirmed at the lines.

- **§14.10 cites superseded D-167 three times.** Confirmed: 12519, 12562,
  12681 (rows 686, 702, 735). The replacements are under "Superseded" above
  (F59).
- **§14.10 bolds seedability and states the tap rejection, both of which §8.2
  states (D-295, D-296).** Confirmed: the bold "**declaredly unseedable**"
  at 12559 (row 701) doubles §8.2 2686's bold "That retyping makes
  seedability schema-visible" (D-263, D-295), and 12560–12571 (rows
  702–705) state the rejection §8.2 2713–2715 states plain with a pointer to
  §14.10. Proposed: §14.10's bold goes; the rejection stays in §14.10, its
  home as `TapResolution`'s section, bold once on its headline clause with
  D-296 (M63, F60, q24).
- **§14.9 (old 12351) puts a `product(...)` helper in §13.7's library, which
  holds components only.** Confirmed at 12479–12482 (row 675); D-071's
  annotation of 2026-10-19 says "the helper is recorded in [§14.9].
  [§13.7]'s library holds components only" (F57).
- **§14.8 (old 12180) cites the bare §13 for §13.5's
  exceptions-are-broken-machinery line.** Confirmed at 12309–12310 (row
  625). The phrase appears nowhere in §13.5, whose line is "**exceptions from
  model code are always abnormal**" (10526–10527, D-060) (F58).

### Factual problems in half 2

None is serious. Each is the spec lagging the code or a later entry, or a
wording slip, and the code, an entry or a rewritten chapter settles it.

- **F51. The NLopt fallback is unbuilt.** The half describes it in the
  present tense at 12011–12015 (row 548), 12123–12130 (rows 576–577),
  12166–12167 ("A `Float64` backend (NLopt) gets equally fresh buffers", row
  584), 12370 (row 640), 12665–12666 (row 731) and 12716–12718 (row 743), and
  §9.6 5113–5114 does too. The package has no `ext/` directory, and
  `rg 'NLopt|BOBYQA'` over `src/`, `test/` and the Project files finds
  nothing. `pending.md` 158–160 lists "**The NLopt fallback** (§14.8, H 4.5):
  `NLoptBackend(:LN_BOBYQA)` as a package extension, the squared and
  normalized objective at `stopval = 1`, and the nominal-activation loop it
  would run on." D-070's Position rules the design. Not serious: the design is
  ruled and the addition listed. Proposed: say once, at §14.8's tolerance
  translation, that the fallback is designed and not yet built (`pending.md`),
  and write the other sentences as the design they are (q30).
- **F52. The malformed-problem list misses four refusals.** 12313–12317 (row
  627) lists four cases. `TrimProblemInvalid`'s reasons are
  `:not_a_namedtuple`, `:key_set`, `:field_types`, `:inverted_box`,
  `:nonpositive_tolerance` and `:not_a_read_set` (`src/diagnostics.jl`
  2007–2008), raised by `_check_decisions!`, `_check_tolerances!`,
  `_check_reads!` and `_check_equations` (`src/trim.jl` 295–391). So the code
  also refuses a field that is not a NamedTuple, a `reads` that is no read
  set, a box with `lower > upper`, a tolerance or check tolerance that is not
  finite and positive, and a residual or check return whose fields are not
  real scalars. It re-checks the residual return once more at the first
  seeded evaluation (`src/trim.jl` 518–537). An unknown `reads` path raises
  `PathResolution` (`:unknown_child`, part C), not the `ReadResolution`
  12319 names. No entry rules the inverted box or the positive tolerance.
  Proposed: "The malformed cases are a field that is not a NamedTuple, or a
  `reads` that is no read set; a guess/bounds key-set or field-type
  disagreement; a box with `lower` above `upper`; a tolerance that is not
  finite and positive; and, observed at the setup guess evaluation, a
  residual or check return whose key set differs from its tolerances' or whose
  fields are not real scalars. The read set's own refusals ride beside them,
  `ReadResolution` and the path walk's `PathResolution`." Track 2 owes an
  entry or an annotation for the two unruled reasons.
- **F53. A seeded tap's address is narrower than the spec says.** 12496–12500
  (row 680), the glossary's `taps` (14782–14786) and Appendix C's
  `TapResolution` (13661–13665) say a tap's leaf address resolves to one
  scalar leaf. `_check_seedable` (`src/linearize.jl` 336–347) refuses, in the
  `x` and `u` lists, any `.name` step, more than one step, and a leaf that is
  not exactly `Float64`, each as `:unseedable`; a `y` tap takes any steps to
  any `Real` leaf (`_seeded_tap(::Val{:y}, …)`). The reason in the code: "a
  seed is a `Float64` direction written into a whole cell or one `SArray`
  component, … there is no lens into a struct's slots". The run refused
  `get_input("in.a")` on a struct root input as `:unseedable`; the suite
  pins it (`test/test_linearize.jl` 308). No entry states it. Proposed, after
  row 680: "A seeded tap, in the `x` or `u` list, reaches its scalar through
  one index step at most and never a `.name` step, because a seed is written
  into a whole cell or one array element. A `y` tap is a read and takes any
  leaf address." The glossary and Appendix C follow in track 2.
- **F54. "And the build says so."** 12428–12430 (row 659). `build` of a tree
  whose mounted input is internally wired raised nothing (part C). The
  refusal comes at resolution: a condition entry as `ConditionResolution`
  `:internally_wired` with the producer (`src/conditions.jl` 444–455), a
  `get_input` as `ReadResolution` `:internally_wired` (`src/readers.jl`
  536–539), both at `trim!`'s setup. D-071 bullet 2's "named by the build"
  is the stale source. Proposed: "is untrimmable from outside, and resolution
  refuses it by name, with the producer that drives it in hand".
- **F55. The frozen cells are copied, not embedded.** 12190–12193 (row 591):
  "copied from the nominal set as zero-partial constants (the embedding of
  [§14.3])". `_establish_frozen!` (`src/model.jl` 97–114) copies the values:
  "A discrete producer's cells are pinned `Float64` at every activation, so
  this is a value copy; the zero-partial embedding happens where a continuous
  consumer reads them". §14.3's embedding is the converter on condition
  writes, which this copy does not run. D-213's "copied as zero-partial
  constants" is the looser source. Proposed: "its frozen cells are copied
  from the nominal set, `Float64` values that a continuous consumer reads as
  zero-partial constants ([§9.5])".
- **F56. The committed-state residuals cost one derivative evaluation.**
  12279–12281 (row 617): "the residuals' declared reads need only gather from
  it". `_verdict!` runs `model.exec.bodies.rhs()` before the gather, "with
  one `rhs` for the derivative reads, `ẋbuf` being integrator scratch and
  this a service evaluation" (`src/trim.jl` 622–627); setup does the same
  after the establishment round (485). §14.4 11654–11656 says why: `ẋ`
  buffers are integrator scratch outside a service evaluation. Proposed: "That
  boundary's sweep has already run, so the reads need one derivative
  evaluation and a gather." 12305 ("they cost no evaluation of their own")
  holds, since the checks share that gather. 12200–12202's "its one
  evaluation is that establishment round" carries the same omission.
- **F57. The `product` helper and §13.7 (carried).** 12479–12482 (row 675).
  D-071's annotation of 2026-10-19. Proposed: "If joint trims become routine,
  a `product(p₁ => "lead", p₂ => "wing")` helper is the extension recorded
  for it ([D-071])", keeping `recorded, not built`.
- **F58. The bare §13 citation (carried).** 12309–12310 (row 625). Proposed:
  "Non-convergence never throws. It is an expected *outcome*, not broken
  machinery ([D-070])", and, if the doctrine is wanted, "exceptions from
  model code are always abnormal ([§13.5])". D-070's Rejected list carries
  the phrase: "*Throw-on-non-convergence:* an expected outcome, not broken
  machinery."
- **F59. D-167 three times (carried).** Part E, "Superseded".
- **F60. Seedability bold in two places (carried).** Part E, "Findings
  carried"; M63.
- **F61. Loose spellings of the commit and the fields.** 12229 (row 602)
  "`override(baseline, solution)`", where the code commits
  `override(baseline, problem.condition(solution))` (`src/trim.jl` 612) and
  12205 and 12379 write `condition(d*)`; the same loose form is at §14.6
  11871, Appendix B 13201 and the glossary's `TrimProblem` (14791). 12377
  (row 642) "`guess`/`bounds`", where the fields are `lower` and `upper`.
  Proposed: "`override(baseline, condition(d*))`" and "`guess`, `lower` and
  `upper`", the other sites in track 2 or with the sibling.
- **F62. An interrupt inside the commit.** 12220–12224 (row 601) covers an
  interrupt "during a long solve". An interrupt inside the commit's boundary
  zero moves the simulation to `built` and propagates raw (D-223 bullet 4:
  "a service has no stop path"), so the simulation is not "bit-for-bit
  untouched" then. Proposed: one sentence, "An interrupt inside the commit's
  boundary zero moves the simulation to `built` and propagates raw
  ([§13.4], [D-223])."
- **F63. The `TrimReport` sketch hides the fields the code names.**
  12251–12258 (row 608) shows `converged` and "the remaining fields,
  enumerated below; this section does not name them". The code's struct has
  `converged::Bool, solution, residuals, tolerances, committed_residuals,
  committed_checks, status::Symbol, n_evaluations, n_iterations, saturated,
  fired_events` (`src/trim.jl` 145–157); D-262 names `committed_checks` and
  D-150 `TrimReport.converged`. Not serious: the code settles the names.
  Proposed: a ruled edit filling the sketch with the eleven fields, each with
  a one-line comment, and the "Field by field" list keyed to them (q28).
- **F64. The `get_x_ss` deletion's pointer.** 12522–12524 (row 689) and §9.6
  5122–5123 cite §7.1 for a "promised" deletion. Rewritten §7.1 1818–1827
  says the arrays come "through the framework's canonical layout, with no
  hand-written state-space mapping per model ([D-072])" and promises nothing.
  Proposed: "The shuttle layer's successor is that compiled writer/reader
  pair, and no hand-written state-space mapping remains ([§7.1], [D-072])."
- **F65. Reader-cold Flight.jl names.** The half uses Flight.jl's names and
  its present tense as if known: `c172.jl` and "today's" (11917, 12015,
  12149, 12218, 12486, 12616, 12624), `trim_condition`, `TrimParameters`,
  `θ_constraint` (11897, 11935–11936, 11985), `AbstractTrimState{N}` and
  `FieldVector` (11920), `f_ode!` and `f_disc!` (11991, 12022),
  `f_init!(::Model{<:SimpleWorld})` (12447), `design_world(ac)`,
  `SimpleAtmosphere(wind = NoWind())`, `HorizontalTerrain` (12457–12458,
  12617), `XStateSpace`/`UStateSpace`/`YStateSpace` and
  `get_*_ss`/`assign_*_ss!` (12487–12488), `FiniteDiff` (12545, 12589),
  `subsystem`/`delete_vars`, `c172x_ctl`, `LinearizedSS` (12605–12607), the
  `{NED}` variant (12617), the commit hash `e5efb3a` (12368, a Flight.jl
  commit). `g` in "$g(s) - s = 0$" (12020, 12665) is the old letter for
  `s_update`. FlightCore's own names (`stopval`, BOBYQA) are the predecessor
  and need nothing. Proposed: q31.
- **F66. Reserved words in other senses.** *door* (12665 "the closed-loop
  trim door", 12672 "Both halves of this door"), which chapter 12's R14 keeps
  for an entry point that builds a run; *contract* (12077 "The backend
  contract"), reserved for a component's declared interface; *boundary*
  (11996 "the condition write boundary", 12207 "the shared
  `init!`-[boundary] defense" with a wrong link, 12659 "The honest
  boundary"); *class* (12312 "a `DiagnosticError`-class failure"); bare
  *entry* (12517 "An `x` entry", 12561 "the offending entry", 12688);
  *sweep* (12310 "an envelope sweep"); and [component] linked at 12499 for
  an array element ("one tap per [component]"). Proposed: "the closed-loop
  trim extension", "Both halves of non-participation"; "The backend seam is a
  pinned signature"; "the condition write", "the shared `init!` defense",
  "The honest limit"; "a `DiagnosticError` at setup"; "An `x` tap", "the
  offending input entry"; "an envelope of trims"; "one tap per element", the
  link moved to a real use.
- **F67. Glossary links.** Duplicates: `#g-tier` (12183, 12342) and
  `#g-guard` (12190, 12231) in §14.8; `#g-walked` (12641, 12642) in §14.10.
  Late links: §14.7 `sweep` (11995, first use 11971); §14.8 `TrimProblem`
  (12329, first 12057), `baseline` (12333, first 12065), `scratch` (12186,
  first 12058); §14.9 `component` (12436, first 12417) and the constant
  source's gloss (12465, at its second use); §14.10 `taps` (12604, first
  12490), `tier` (12554, first 12516), `activation` (12552, first 12531).
  Unlinked anchors used: `#g-trimproblem`, `#g-condition`, `#g-at`,
  `#g-fragment`, `#g-boundary-zero`, `#g-baseline` in §14.7; `#g-override`,
  `#g-condition` in §14.8; `#g-mounting`, `#g-trimproblem`, `#g-condition`,
  `#g-baseline`, `#g-at`, `#g-override`, `#g-design_world` in §14.9;
  `#g-design_world`, `#g-scratch`, `#g-store` in §14.10. Proposed: one link
  per term per section at its first use, as `brief_common.md` asks.
- **F68. "Mount chain" before its definition.** 12388 (row 646) uses it; the
  **Rule.** at 12409 defines it. Proposed gloss at 12388: "the set's mount
  chain (the prefixes it is mounted under, root first)".
- **F69. "Validated against the root face lists."** 11949 (row 527). Under a
  mount, `get_input` and `get_face` resolve against the mount level's faces
  (D-277 bullets 2–3; `_input_faces_at(structure, decls, mount)`,
  `src/readers.jl` 523). Proposed: "(validated against the faces of the
  level the read set is mounted at, the root's when unmounted)".
- **F70. "That leaves `get_deriv` scoped to owned concrete subtrees."** 11958
  (row 532). Since D-414 no check scopes it; the scoping is authoring
  guidance (D-414 bullet 4; D-125's annotation of 2026-10-19). Proposed:
  "By convention, then, `get_deriv` stays inside subtrees the problem's
  author owns ([D-414])."
- **F71. Kinds stated without their names (lesson 20).** `TapResolution` is
  never named in §14.10 though rows 681, 682, 686, 702 and 705 state its
  conditions; `ReadResolution` for the did-you-mean refusals (row 684);
  `ConditionResolution` and `ReadResolution` `:internally_wired` in §14.9
  (rows 653, 659); `ArgumentInvalid` `:non_nominal` and `:claimed` for
  `trim!` (§14.8, rows 561–562) and `:t0_without_about` for `linearize`
  (§14.10, row 712), all confirmed in part C. Appendix C's `ArgumentInvalid`
  row (13722–13723) lists §14.7, which raises none, and omits §14.8 and
  §14.10. Proposed: name each kind where its condition is stated; Appendix
  C's row in track 2 (q32).
- **F72. "The first service with no commit."** 12584–12585 (row 707).
  `checkpoint` commits nothing either. Proposed: "Linearization commits
  nothing and runs no boundary zero."
- **F73. "The fallback is per problem."** 12370 (row 640). `backend` is a
  `trim!` keyword, so the choice is per call. Proposed: "The backend is
  chosen per call, by the one `backend =` keyword."
- **F74. "This is stated once."** 12627–12630 (row 720) says the frozen-exact
  doctrine is "stated once, because the question recurs", and bolds two
  sentences with no citation. §7.2 1900–1904 states it (D-072), §9.6
  5124–5125 too, and §14.10 itself at 12554–12555. Proposed under M65: the
  pointer to §7.2, no bold.
- **F75. "Both halves of this door have a spelling."** 12672 (row 732), a
  bold sentence with no entry behind it; D-263's and D-286's Rationales say
  the doors "survive as declared doors". Proposed: plain, with D-263 cited,
  and *door* reworded (F66).
- **F76. "Rejected together."** 12500–12503 (row 682). The code refuses the
  later tap naming the earlier label (`:duplicate_site`,
  `duplicate_of = seeded_by[site]`, `src/linearize.jl` 308–313), as
  `linearization_walkthrough.md` 5.3 says. Proposed: "A second tap resolving
  to a site already seeded is rejected naming the earlier label".
- **F77. "A culprit-naming `InexactError`."** 12348–12349 (row 634). D-307's
  Rationale: the `Dual` sweep "fails at the offending line with a
  `MethodError` or an `InexactError`". Proposed: "with a culprit-naming
  `MethodError` or `InexactError`".
- **F78. The saturated decision's message.** 12147–12149 (row 580) quotes
  "converged with `elevator` at its upper bound". The report holds
  `saturated` as `(name, :lower | :upper)` pairs (`src/trim.jl` 138–139,
  `_saturated`), and nothing prints that sentence. Proposed: "is listed in
  the report's saturated list, as `(:elevator, :upper)`".
- **F79. Where the trim warnings live (outside the half).** §13.2 10139–10141
  (H83). For chapter 13's loose-fix list, not this rewrite.
- **F80. The code's lift is positional (outside the spec).** D-188's
  Position: "`TrimProblem` is constructed by keyword everywhere: the `at`
  lift rewritten … to the keyword spelling". `at(prefix, problem)` in
  `src/trim.jl` 99–103 calls the positional constructor, and passes a `reads`
  that is no read set through untouched. The spec's sketch (12392–12403)
  matches D-188; the code lags the entry. For the implementation track, not
  the rewrite.
- **F81. A citation beside the wrong entry.** 12304 (row 623) cites D-139
  for `TrimCommitChecks`, which D-262 rules. Proposed: "([§14.7], [D-262])",
  D-139 kept if the elimination clause is to carry it.
- **F82. "At the baseline."** 12332–12333 (row 630). The empty problem
  evaluates the composite `override(baseline, condition(guess))` with
  `guess = (;)` (`src/trim.jl` 481), so the problem's own condition applies.
  D-156 says "at the baseline". Proposed: "evaluates the residuals once at
  `override(baseline, condition((;)))`, the baseline with whatever the
  problem's condition sets".
- **F83. `t0` "as in `trim!`".** 12597–12599 (row 712). `linearize` refuses
  a `t0` passed without `about` (`ArgumentInvalid` `:t0_without_about`,
  D-272's annotation of 2026-09-28, Appendix B 13240–13241); `trim!` has no
  such refusal. Proposed: "with `t0` beside it, admitted only there".

Outside the half, met while checking citations: Appendix B 13199–13201 (seven
fields; `override(baseline, solution)`), 13212, Appendix C 13661–13665 and
13722–13723, the glossary's `taps` and `TrimProblem`, §9.6 5113–5123, §13.2
10139–10141, `linearization_walkthrough.md` 572 ("`sim.exec` was never
touched", where the executor is the model's since D-317). All in part D or
above.

## F. Difficulty per section

| section | difficulty | reason |
|---|---|---|
| §14.7 (F) | medium to high | 1,469 words in an eleven-bullet list, every bullet a bold lead-in, two **Rule.** labels and an italic *Why.*; the residual signature sits after the bullets that use it (M51); three doubles inside the section (H52–H55) and four with half 1 and §9.5 (H62–H64, H72); D-118, D-151, D-124, D-125 uncited; much Flight.jl vocabulary (F65); the read-side bullet carries several inbound rows (part D, M55) |
| §14.8 to "Scratch stores" (F) | medium | 1,371 words under five `####`s, four of them claim-shaped (M56); D-070, D-150 uncited at their bolds; the unbuilt NLopt fallback in the present tense (F51, q30); F55 and the totality double (H65) in the scratch-world paragraphs; the inscribed-sphere display is exempt comparative evidence and stays whole |
| §14.8 from "The commit" (G) | medium | 1,091 words; the near-empty `TrimReport` sketch (F63, q28); the malformed list (F52); D-155, D-126, D-110 uncited; the C172 audit (q27) with a Flight.jl commit hash; F56, F58 (carried), F61, F62 |
| §14.9 (G) | low to medium | 960 words in good order; no context paragraph; three labels to convert (M60); D-071 uncited throughout; F54, F57 (carried), F68; Flight.jl's `design_world` and world wrapper; the reason for the bulk-data refusal doubles §4.4 (H80) |
| §14.10 (H) | high | 2,173 words with no context paragraph and seven bold labels acting as headings (M61), a reorder for define-before-use (M62), three trims onto §7.2 and §8.2 (M63–M65, q26), D-167 three times (F59, carried), the seedability double bold (F60, carried), a bold claiming the doctrine is "stated once" (F74), `TapResolution` never named (F71), the seeded tap's step limit unstated (F53), *door* and bare *entry* (F66), and Flight.jl's structs, `LinearizedSS` and `c172x_ctl` (F65) |

Warnings for the rewriter:

- **Terms of art stay verbatim**: implicitly specified condition; the field
  set is normative (closed); what the solver varies is passed, what is fixed
  per problem is closed over; the names are the pairing, order carries no
  semantics; the pinned signature; request-by-argument; the open status set;
  the convergence verdict is the service's; the per-residual box test; the
  inscribed sphere; the tolerance translation per backend family; step
  projection; the CG-limit diagnostic; defense in depth, not the mechanism;
  exactly one writer, the commit through boundary zero; established, not
  probe-seeded; the establishment round; the nominal half, the seeded half;
  the no-throw doctrine (§10.4 6020 cites it); warn-but-assign; solved-point
  residuals, committed-state residuals, committed-state checks; the moved
  point; the AD obligation, scoped; the mount chain; the rebase; the world
  wrapper dissolves; method nesting became value layering; the thin world;
  the test-rig idiom; swarm doctrine; one problem at a time; tap set; named
  scalars; no-silent-zeros; declaredly unseedable; the pinning consumer; the
  fan-out meet; pure query; the frozen-exact doctrine; consumer-scoped, not a
  capability wall; the sampled-data step map; event-quiescent; the local
  rule; the forbid-seeding marker; a choice, a declaration.
- **Scope words are exact.** "exactly the continuous output-stage chains and
  `x_deriv`"; "That verdict, and nothing else, gates the commit"; "decisive
  of nothing"; "authoritative over nothing"; "structurally unfailable
  through the trim path"; "No commit means the sim is bit-for-bit
  untouched, including 'never initialized'"; "one plan-level comparison
  before the first evaluation"; "every discrete output stage admitted, due
  or not"; "over the continuous chain and `x_deriv` alone"; "Order is never a
  mismatch"; "A tap names one scalar"; "one rule for `x` and root inputs
  alike"; "whenever any one of its consumers demands frozen". Keep each.
- **Counts are claims.** "three cases" of the lift (rows 645–646); "~100
  lines"; "~5–15 evaluations"; "~150 lines of bookkeeping"; "~4n perturbed
  evaluations"; "four `FiniteDiff` jacobians"; "default 8"; "the full
  7-variable search"; "three-equation core"; "two problems are recorded";
  "Two consumers wait"; "seven" rows of the seeded-and-frozen table; the
  field list's nine names. Each must match its list after the rewrite.
- **The half cites by adjacency.** Rows 537–538, 562, 565, 567–569, 571,
  588, 590–593, 650–653, 655, 678, 681, 691, 710, 738 carry their citation
  one or more sentences away. A move that separates a rule from its
  citation (M51, M52, M61, M62) repeats it.
- **Glossary links reset per section, once each** (F67): three duplicates,
  nine late links, and twenty unlinked anchors. §14.8 spans units F and G;
  the brief assigns its links (part C).
- **Reserved words** (F66): *door*, *contract*, *boundary*, *class*, bare
  *entry*, *sweep* in "envelope sweep", and *component* for an array
  element. *Tier* is used in its sense throughout; *batch* (12237) and
  *cell* are correct.
- **The log's vocabulary is old.** D-069 says `deriv`/`output`; D-070
  `BuildError`; D-071 "slots" and "named by the build"; D-072 `capture(sim)`
  and `state`/`slot`/`output` lists; D-108 `capture`; D-118 "closes at
  seven"; D-124 `get_slot`; D-125 `h_xu` and "slot faces"; D-126 and D-155
  "`capture`-defaulted `linearize`"; D-139 "root slot", `capture`; D-149
  `UninitializedSlots`; D-167 "slot", "Stratum A", the superseded
  `Type{T}` mandate; D-197 `init_x`; D-213 `g`; D-272 `capture(sim)`. Never
  import them.
- **Code blocks are carried verbatim** except as q28 rules for the
  `TrimReport` sketch. The `at` sketch matches D-188 and stays keyword-form
  even though the code's lift is positional (F80).
- **Flight.jl case material.** The worked cruise problem, the C172 audit,
  the world wrapper, `design_world`, the state-space structs and the `{NED}`
  variant are grounding, not API. Their status-quo present tense ("today's")
  is Flight.jl's, not Redstone's. Carry them until q27 and q31 are ruled.
- **Recorded, not built, in four places**: closed-loop and on-ground trim
  (§14.7), the `product` helper (§14.9), the sampled-data activation and the
  non-participation tooling (§14.10). The unbuilt NLopt fallback is a
  different status (pending, not recorded); q30 rules its marking. Do not
  mark one as the other.

## G. Decisions for checkpoint 1

Settled and not asked again: log repair rides track 2, and bold marks one
headline clause per ruling. Citing an uncited entry where its text carries
the claim is the brief's standing rule (`brief_common.md`), so part E's
"Entries to cite at the rule" needs no question.

**q21. Overlap homes with half 1 (H62–H71).** Options: (a) the homes part B
proposes: §14.4 for the undeclared-intermediate rule and the gather twin,
§14.7 for the export and `y_direct` remedies; §14.3 for converter selection,
§14.7 keeping the `Dual`-typed clause §14.3 cites; §14.6 for totality, §14.8
for its trim consequences; §14.5 for the raw iterations and `t0`, §14.8 for
`trim!`'s signature; §14.2 for the `u` payload's export chain, §14.9 for the
from-the-mount consequence; §14.9 for the read-side mount and the empty
prefix; each other text a pointer with its citation; (b) leave every
duplicate. Recommendation: (a), ruled jointly with the sibling's overlap
items, since half 1's sides of H62–H71 are its units.

**q22. *Door* in §14.10 (F66).** `brief_common.md`'s reserved list does not
name *door*; chapter 12's R14 reserves it for an entry point that builds a
run, and chapter 13's survey applied that reading. §14.10 uses "the
closed-loop trim door" (12665) and "Both halves of this door" (12672); §8.2
2764 (rewritten) says "the recorded freeze door" and "the FFI door", and
D-263, D-286 and D-266 say "door" throughout. Options: (a) apply R14 here:
"extension" for the closed-loop trim, "non-participation" for the halves,
and leave §8.2's "freeze door" and "FFI door" as the names chapter 8 kept;
(b) keep "door" in §14.10 as §8.2's sense, a declared opening; (c) add
*door* to `brief_common.md`'s reserved words with both senses ruled.
Recommendation: (a). The two §14.10 uses are not the names §8.2 coined, and
R14's sense is the reserved one.

**q23. The fallback's home (H51, M53).** Options: (a) §14.8's tolerance
translation is the home of the normalization and the inscribed sphere;
§14.7's bullet keeps "the derivative-free scalar path survives as the
fallback" with a pointer; (b) the reverse, §14.7 the home, §14.8 a pointer;
(c) leave both. Recommendation: (a). The normalization is a mechanism of the
service, D-150 rules it as the service's translation, and §14.8 carries the
soundness argument the normalization needs.

**q24. Bold homes.** The half is the home of these rulings, none bold now as
a headline clause with its citation in the sentence:

| entry | ruling | proposed bold | where |
|---|---|---|---|
| D-118 | the field set is closed | "The field set is closed" | §14.7 row 502 |
| D-118 | what the solver varies is passed | its **Rule.** sentence | §14.7 row 551 |
| D-069 | a residual system, solved as least squares | row 534's clause; row 544 plain (H55) | §14.7 |
| D-069 bullets | decisions as NamedTuples; reads declared and compiled; elimination survives; non-squareness; the fallback; recorded unbuilt | one bold each, rows 513, 525, 542, 547, 548, 549 | §14.7 |
| D-262 | checks reported, never solved | row 537 | §14.7 |
| D-070 | in-house LM behind a value-passed seam | row 563 | §14.8 |
| D-158 | the seam is one pinned signature; the status set is open | rows 565 and 570; row 567's "iff" plain (one ruling with 565) | §14.8 |
| D-150 | the verdict is the service's box test at the returned point | row 573 | §14.8 |
| D-070 bullets | step projection; one writer; no throw; the AD obligation's scope | rows 579, 585, 625, 632 | §14.8 |
| D-213 | frozen cells from the nominal half | row 588 | §14.8 |
| D-224 | a commit throw propagates, no report | row 629 | §14.8 |
| D-156 | the empty problem is legal | row 630 | §14.8 |
| D-071 | a problem is an implicitly specified condition; and its bullets (lift, mount-point resolution, world wrapper, `design_world`, swarm, `product`) | rows 641, 645, 657, 665, 668, 673, 675 | §14.9 |
| D-277 | a read set carries its mount chain | row 650 | §14.9 |
| D-364 | a bulk-data handle enters through a constant source | row 670, trimmed to its headline clause | §14.9 |
| D-139 (Rationale only) | a problem never authors the environment | row 661, cited, the log flagged (part E) | §14.9 |
| D-188 | `TrimProblem` is constructed by keyword | no sentence states it; one added at the sketch (row 648) | §14.9 |
| D-272 | the tap set; a tap names one scalar; the width | rows 677, 680, 692 | §14.10 |
| D-197 | no discrete store in `x` | row 686 | §14.10 |
| D-296 bullet 4 | the pinned root input's tap refused, naming the pinning consumer | row 702 | §14.10 |
| D-274 bullet 5 | the default point is the checkpoint | row 709 | §14.10 |
| D-072 | the pure query; the labeled return; `LinearizedSS`; the guidance | rows 707, 713, 715, 716 | §14.10 |
| D-073 | the sampled-data activation recorded unbuilt | row 718 | §14.10 |
| D-266 bullets 1 and 3 | the local rule; no perturbation fallback | rows 739, 742 | §14.10 |

Doubles to make plain with their citations: row 516 (D-151, bold at §9.5);
row 543 (framing); row 701 (D-295, bold at §8.2); row 703's term (D-296's
naming, one ruling with row 702); row 720 (D-072's law, §7.2's); row 732 (no
entry); row 738 (D-266's headline, bold at §8.2); the terms at 611–613
(D-155), 12463 ("value"), 12646, 12721 ("tooling"). Joint with the sibling:
D-155 (the second mover, bold at §14.5 11813; the report clause here),
D-126 (bold at §14.5 11807 "A guard firing at commit is a wanted failure
signal"), D-110 (§14.5's `t0` bullet), D-149 (§14.6), D-278 (§14.2's
**Rule.**). Options: (a) bold each listed home ruling once at its headline
clause, under the one-bold test, and make the doubles plain; (b) the same,
but leave D-071's bullets and D-072's plain as descriptions of the shipped
surface. Recommendation: (a).

**q25. Subheadings and labels.** §14.7 is a bullet list of bold lead-ins;
§14.8 has eight `####`s, four claim-shaped; §14.9 has two bold labels and a
**Why.**; §14.10 has seven bold labels. Options: (a) as part C: §14.7 gains
six `####` labels (M52); §14.8's four claim-shaped labels become topic
labels (M56); §14.9 takes no `####`, gains a context paragraph and loses its
labels (M60); §14.10's labels become eight `####`s (M61); (b) `####` in
§14.10 only, §14.7 kept as a list with its bold lead-ins reduced under q24;
(c) no new `####`, each label a plain topic sentence. Recommendation: (a).
§14.10 at 2,173 words and §14.7 at 1,469 are reference sections a reader
enters by topic (the tap set, the operating point, the residuals), and
inbound rows cite the topics, not positions.

**q26. §14.10's restatements of §7.2 and §8.2 (M64, M65; H75, H77, H78).**
Options: (a) trim: the frozen-exact law points to §7.2 and §14.10 keeps the
pass's mechanism and the step map; the non-participation halves point to
§8.2 and §9.5, keeping one sentence naming the output half as the declared
freeze door (part D needs it, D-263's and D-286's Rationales cite it), the
root input's "choice versus declaration", and the tooling; (b) leave both
passages, removing only the bolds; (c) move the non-participation passage
whole to §8.2. Recommendation: (a). Part I's depth rule makes §7.2 the
home of the law, chapter 8 already holds the marker's spelling, and the
rejection and the tooling are linearization's. Option (c) would empty the
section §8.2's pointers land on.

**q27. The C172 migration audit (M59, F65).** §14.8 12352–12368 is a
Flight.jl audit: interpolation tables, saturations, the gear, `norm` guards
with a Flight.jl commit hash. D-070 bullet 5 states the audit in its
Position, §7.2 1932 points to §14.8 for the interpolation guidance, and
`migration_outline.md` 28 already carries the audit as a row. Options: (a)
keep the four bullets in §14.8, introduce them as "Flight.jl's Cessna 172
model" and drop the hash; (b) keep the interpolation and saturation bullets
(guidance any author meets) and move the gear and `norm`-guard bullets to
`migration_outline.md`; (c) move the whole audit to the companion, leaving
the interpolation guidance and a pointer. Recommendation: (b). The two kept
bullets are what §7.2 and D-307 rely on; the other two are facts about one
aircraft.

**q28. The `TrimReport` sketch (F63).** Options: (a) a ruled edit: the
sketch names the code's eleven fields, each with a one-line comment, and the
"Field by field" list is keyed to the names; (b) keep the sketch and name the
fields in the list only; (c) leave both. Recommendation: (a). The code
settles the names, D-262 and D-150 already use two of them, and a sketch
whose comment says it does not name the fields is the gap a reader hits.

**q29. The units.** Three units as part C: F 2,840 (§14.7 and §14.8 to the
end of "Scratch stores"), G 2,051 (the rest of §14.8, §14.9), H 2,173
(§14.10). Alternatives: two units of 3,931 and 3,133, or three cut at
§14.8's "Scratch stores" (2,199, 2,692, 2,173). Recommendation: F, G, H.
§14.8's cut falls between the solve and the commit, every move stays in one
unit, and the brief assigns §14.8's first-use links.

**q30. The NLopt fallback's status (F51).** Options: (a) one sentence at
§14.8's tolerance translation, "The derivative-free fallback is designed and
not yet built; `pending.md` lists it", the other sentences kept as the
design, and §9.6 (5113) aligned in track 2; (b) mark it *recorded, not built*
(`#g-recorded-not-built`); (c) leave the present tense. Recommendation: (a).
*Recorded, not built* names extensions deliberately left unimplemented, while
`pending.md` lists this one as an addition to build; (b) would change its
status, and (c) states what the code does not do.

**q31. Reader-cold Flight.jl names (F65).** Options: (a) an introducing
clause at first use per section that claims nothing beyond its source:
"Flight.jl's Cessna 172 model (`c172.jl`)", "Flight.jl's `trim_condition`",
"Flight.jl's `XStateSpace` … structs", "`design_world(ac)`, Flight.jl's
shipped rig", and "today's" made "Flight.jl's current"; the hash dropped;
`g` replaced by `s_update`; (b) move the Flight.jl history sentences (rows
514, 676, 696, 708, 714, 715, 717) to `flight_case_studies.md`, leaving the
rules; (c) leave them. Recommendation: (a), with the owners checked in the
Flight.jl source before ruling each clause (recipe, chapter 7's lesson).
The worked problem and the rigs ground the section and are what the
glossary's `worked` and `design_world` entries point at.

**q32. The clear factual corrections.** F52 (the malformed list), F53 (the
seeded tap's steps), F54 (resolution, not the build), F55 (the frozen-cell
copy), F56 (the committed-state residuals' `rhs`), F57 (the `product` helper,
carried), F58 (§13.5 and D-070, carried), F59 (D-167's replacements,
carried), F61 (`condition(d*)`; `lower` and `upper`), F62 (the interrupt
inside the commit), F64 (§7.1's pointer), F66 (reserved words, with q22),
F67 (glossary links), F68 (the mount chain's gloss), F69 (the mount level's
faces), F70 (`get_deriv` by convention), F71 (kind names), F72–F78, F81–F83.
Options: (a) rule them all at checkpoint 1 with part E's evidence and
proposed wording, grepping the chapter for each phrase first
("`override(baseline, solution)`" recurs at §14.6 11871, "today's" and
"the build says" may recur in half 1); (b) leave them for rulings.
Recommendation: (a). F51 is q30, F60 is q24, F63 is q28, F65 is q31; F79 and
F80 are outside the rewrite.

## H. Descriptive passages

One row per passage that describes a rule's mechanism rather than stating
the rule. The source file is the one `implementation.md`'s map and a grep
put it in; where no file realizes the passage, the row says whether it
describes a planned piece, a recorded extension, Flight.jl's status quo or a
stale one. These rows are the normative kernel's migration list; part C
proposes no move on their account.

| id | section | lines | summary | realized in |
|---|---|---|---|---|
| P201 | §14.7 | 11919–11934 | the decisions' packing by `guess`'s order, the setup key-set and type checks, the type-level reorder of the bounds | `src/trim.jl` (`_check_decisions!` 295–325; the packing and the guess clamp in `_solve_problem`) |
| P202 | §14.7 | 11939–11960 | the `reads` spelling, each selector's validation target, the compiled stack-only reader | `src/readers.jl` (`reads` 299, `_compile_reads` 410, `_resolve_reads` 429, `gather_reads`), `src/trim.jl` (`_check_reads!`) |
| P203 | §14.7 | 11961–11966, 12043–12053 | the residual return reordered to `tolerances`' order and packed; names and types checked at the guess | `src/trim.jl` (`_named`, the `eval!` closure, `_check_equations` 378–391) |
| P204 | §14.7 | 11967–11973 | the checks gathered once after the commit; their shape observed at the guess; their reads in the one read set | `src/trim.jl` (`_verdict!` 603–648; `_check_equations(:checks, …)` in `_solve_problem`) |
| P205 | §14.7 | 11993–12005 | the decisions seeded through the `Dual` activation; the per-leaf converter carrying partials across the condition write | `src/trim.jl` (`TrimTag`, `_seeded`, `compile_plan` at the seeded scalar), `src/conditions.jl` (the baked converter, `resolve_condition` 295) |
| P206 | §14.7 | 12011–12015 | the fallback's squared and normalized objective | none: planned (`pending.md` 158, "The NLopt fallback") |
| P207 | §14.7 | 12016–12023 | closed-loop sampled-data trim and on-ground equilibrium | none: recorded, not built |
| P208 | §14.8 | 12064–12075 | the two `trim!` methods and the in-house dense LM core | `src/trim.jl` (`trim!` on a `Model` 446–452, `LevenbergMarquardt`, `solve` 229–275), `src/sim.jl` (`trim!` on a `Simulation` 757–767) |
| P209 | §14.8 | 12077–12105 | the `solve` seam: `eval!` in place, `J` by argument, packed vectors, `tol`, the open status | `src/trim.jl` (`solve`'s generic and docstring, the `eval!` closure in `_solve_problem`) |
| P210 | §14.8 | 12109–12114 | the service's verdict re-evaluated at the returned point | `src/trim.jl` (the final `eval!(r, nothing, out.d)` in `_solve_problem`, `_within`, `_verdict!`) |
| P211 | §14.8 | 12118–12121 | LM's stopping test in the tolerances' units | `src/trim.jl` (`_scaled_norm`, `_within`, `solve(::LevenbergMarquardt, …)`) |
| P212 | §14.8 | 12123–12143 | the derivative-free objective and the inscribed-sphere argument | none: planned (`pending.md` 158); the sphere is a proof with no code |
| P213 | §14.8 | 12147–12150 | step projection; the saturated decisions flagged | `src/trim.jl` (`clamp` in `solve` 253, the clamped guess, `_saturated`) |
| P214 | §14.8 | 12154–12170 | a fresh store set per invocation, each half a scratch `Model`, workspaces allocated per set | `src/model.jl` (`_scratch` 94), `src/trim.jl` (`_solve_problem`) |
| P215 | §14.8 | 12172–12180 | setup's totality check before the first evaluation | `src/trim.jl` (`assert_total(plan, …, :trim!)`), `src/conditions.jl` (`assert_total` 514) |
| P216 | §14.8 | 12182–12202 | the two halves: the nominal half's establishment round, the seeded half's `apply!`, the frozen copy, the zero-decision problem as the nominal half | `src/trim.jl` (`_round!(nominal_exec, ESTABLISH)` 484), `src/model.jl` (`_establish_frozen!` 97–114, `_round!` 337), `src/executor.jl` (`ESTABLISH` 470) |
| P217 | §14.8 | 12204–12218 | the commit's coverage equal to setup's; iterations rewriting the write set; no commit on non-convergence | `src/trim.jl` (`_verdict!`'s early return, the `eval!` closure) |
| P218 | §14.8 | 12220–12224 | an interrupt during the solve unwinds a call over scratch | none: no handler exists; the behavior follows from `_solve_problem`'s call-local executors |
| P219 | §14.8 | 12228–12245 | the commit as an `init!`; `t0`; the recorders restarted; the staged batches cleared | `src/trim.jl` (`_verdict!`'s `commit!` 612), `src/model.jl` (`init!`), `src/sim.jl` (`init!` on a simulation, its recording reset) |
| P220 | §14.8 | 12249–12277 | the report's fields | `src/trim.jl` (`TrimReport` 116–157) |
| P221 | §14.8 | 12279–12307 | the committed-state residuals and checks gathered after one `rhs`; the three warnings | `src/trim.jl` (`_verdict!` 603–648), `src/diagnostics.jl` (`TrimCommitEvents`, `TrimCommitResiduals`, `TrimCommitChecks`); the "need only gather" clause is stale (F56) |
| P222 | §14.8 | 12309–12321 | setup validation in one collected throw, the read set's refusals beside it | `src/trim.jl` (`_report_trim!`, `_check_decisions!`, `_check_tolerances!`, `_check_reads!`, `_check_equations`), `src/diagnostics.jl` (`TrimProblemInvalid`, reasons 2007–2008); the case list is stale (F52) |
| P223 | §14.8 | 12323–12326 | a throw inside the commit propagates as `StepError`, the simulation `built`, no report | `src/trim.jl` (`_verdict!` calls `commit!` with no `try`), `src/model.jl` (`init!`'s boundary-zero catch) |
| P224 | §14.8 | 12328–12336 | the zero-decision problem bypasses the solver | `src/trim.jl` (the `N == 0` branch of `_solve_problem`, status `:bypassed`) |
| P225 | §14.8 | 12340–12350 | the AD obligation's scope; the `Dual` probe and `activations` in CI | `src/build.jl` (`build`'s `activations` keyword, `_frozen`), the suite's `Dual` activation policy (D-280) |
| P226 | §14.8 | 12352–12368 | the C172 migration audit | none in Redstone: Flight.jl's model, carried as `migration_outline.md`'s row 28 |
| P227 | §14.9 | 12385–12403 | the field-by-field lift of a problem | `src/trim.jl` (`at(prefix, ::TrimProblem)` 99–103) |
| P228 | §14.9 | 12405–12407 | the flattening accumulator entering each `Scoped` | `src/conditions.jl` (`_flat(::Scoped, …)` 196) |
| P229 | §14.9 | 12409–12423 | the read set's mount chain, the walk from the root, the rebase, the refusals, the empty prefix | `src/conditions.jl` (`at(prefix, ::Reads)` 97–100), `src/readers.jl` (`_mount` 484–493, `_rebase` 501–560) |
| P230 | §14.9 | 12425–12432 | a `u` entry resolved through the export chain from the mount point; the internally wired input refused | `src/conditions.jl` (`_root_input` 443–456), `src/readers.jl` (`_rebase(::GetInput, …)` 520–545) |
| P231 | §14.9 | 12447–12452 | Flight.jl's world-level `f_init!` dissolving into the baseline | none: Flight.jl's status quo, history |
| P232 | §14.9 | 12454–12473 | `design_world(ac)` and the thin world; the isbits test-rig idiom | none in Redstone: Flight.jl's rig (`trim_environment_walkthrough.md` works it); the idiom is ordinary root inputs |
| P233 | §14.9 | 12475–12482 | swarm trims by user-side composition; the `product` helper | none: user-side; the helper recorded, not built |
| P234 | §14.10 | 12486–12494 | `taps` and its three closed lists | `src/linearize.jl` (`Taps`, `taps`, `_tap_list`, `_tap_kind`) |
| P235 | §14.10 | 12496–12503 | one scalar per tap; the wrong list; a second seed at one site | `src/linearize.jl` (`_resolve_taps`, `_check_seedable` 336–347, `_site_key`); the step limit is unstated (F53) |
| P236 | §14.10 | 12513–12524 | each list's validation target; the discrete store refused; offsets compiled once; the lift | `src/linearize.jl` (`_seeded_tap` methods, `at(prefix, ::Taps)` 44), `src/readers.jl` (`_resolve_selector`) |
| P237 | §14.10 | 12526–12546 | the seeded pass in groups of `width`; values and partials read back | `src/linearize.jl` (`_linearize`'s passes, `_seed`, `_seed_site!`, `_readback!`, `LINEARIZE_WIDTH`, `LinearizeDual`) |
| P238 | §14.10 | 12548–12582 | what is seeded and what is frozen; the unseedable root input and its pinning consumers | `src/linearize.jl` (`_seeded_tap(::Val{:u}, …)` and its meet witness), `src/model.jl` (`_establish_frozen!`), `src/build.jl` (`_accepts_wire`, the root-input retyping) |
| P239 | §14.10 | 12584–12599 | the pure query; the default point restored from the checkpoint; `about` with `t0` | `src/linearize.jl` (`linearize`, `_linearize`'s nominal half, `_check_linearize_call`), `src/checkpoint.jl` (`_restore_state!` 74), `src/sim.jl` (`linearize` on a simulation 780) |
| P240 | §14.10 | 12601–12612 | the `Linearization` value; `subsystem`/`delete_vars`; `LinearizedSS` | `src/linearize.jl` (`Linearization`); `subsystem`, `delete_vars` and `LinearizedSS`: none in Redstone, Flight.jl's migration |
| P241 | §14.10 | 12614–12619 | minimal-coordinate taps; the `{NED}` variant | none: guidance and Flight.jl's practice |
| P242 | §14.10 | 12621–12669 | the sampled-data activation, its five pieces, its scope and its two consumers | none: recorded, not built |
| P243 | §14.10 | 12671–12689 | the two halves of non-participation: `Pinned` outputs and entries, the forbid-seeding marker | `src/leaves.jl` (`Pinned` 238, the retype walk), `src/build.jl` (the always-on check at a pinned leaf), `src/linearize.jl` (the unseedable refusal) |
| P244 | §14.10 | 12691–12719 | the local derivative rule inside an opaque component | none in `src/`: an authoring pattern (`handle_walk_walkthrough.md`, D-266); the framework's part is that mid-expression stripping stays legal |
| P245 | §14.10 | 12721–12727 | pinned-face validation and the feedthrough-graph lint | none: recorded, not built |

45 rows. Rule statements the kernel would keep from these passages are in
part A; every row above describes how a ruling is carried out. P206, P212
describe a planned piece; P207, P233, P242 and P245 recorded extensions;
P226, P231, P232, P240 (in part) and P241 Flight.jl's status quo; P218 a
behavior with no code of its own. P221 and P222 contain stale clauses inside
otherwise realized descriptions, and P235 omits a realized restriction.
