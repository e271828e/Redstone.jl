# Unit G rulings: §14.8 from "The commit, in full", and §14.9

Old spec lines are lines of the frozen `scratch_survey/h1/spec.md` at
`c3d29fb`; log lines are its `decisions.md`. Code lines are `src/` at
`c3d29fb`.

## Corrections proposed

1. **"the report names the saturated variable"** (12364–12365, the
   saturation bullet R15 keeps). The report's `saturated` field lists
   *decisions* sitting at their own box bounds: `_saturated`
   (`src/trim.jl` 588–596) compares each decision with `lower` and `upper`
   and nothing else. An in-model saturation (an actuator limit, an idle
   clamp inside the model) is invisible to it unless the clamped quantity
   is itself a decision at its bound. D-070 bullet 5 says "LM-tolerated,
   reported", so the entry carries the same looseness. Kept as written.
   Proposed: "LM damping tolerates the rank deficiency ([D-070][d-070]).
   The report's `saturated` list names a decision only at its own bound,
   so an in-model saturation shows in the Jacobian's zero columns rather
   than in the report." Track 2 then annotates D-070 bullet 5.
2. **`HorizontalTerrain` has no owner** (12458, and the glossary's
   `#g-design_world`, 14745). Flight.jl has no `HorizontalTerrain`; its
   flat terrain is `UniformTerrain` (`lib/FlightPhysics/src/terrain.jl`
   60), which its `linearize` builds (`aircraftbase.jl` 299). `design_world`
   does not exist in Flight.jl either; it is this design's rig. I named the
   owner only of `SimpleAtmosphere` and `NoWind` (FlightPhysics'
   `atmosphere.jl` 153, 260). Proposed: write `UniformTerrain`, Flight.jl's
   flat terrain, in §14.9 and the glossary, or say that `HorizontalTerrain`
   is the rig's own terrain component, still to be written.
3. **"useful in its own right and free"** (12335–12336). The empty problem
   costs one residual evaluation (the nominal half's establishment round,
   `src/trim.jl` 481–485), so "free" means "no solve". D-156 says only
   "useful in its own right". Kept. Proposed: "which is useful in its own
   right and costs no solve".

## Citations added or replaced

- D-110 at the `t0` sentence (12233). Position: "`trim!` gains the
  init-service `t0` argument ... default `0.0` matching `init!` (one rule
  for both entry points)".
- D-110 at the recorders' restart (12234). Rationale only; see below.
- D-070 at "`trim!` returns a structured `TrimReport`" (12249). Bullet 3:
  "`TrimReport` is a no-throw structured value".
- D-070 at "Non-convergence never throws" (12309), bold. Bullet 3:
  "non-convergence is an expected envelope-sweep outcome"; Rejected:
  "*Throw-on-non-convergence:* an expected outcome, not broken machinery."
- D-070 at the AD obligation's scope (12340), bold. Bullet 4: "The AD
  obligation is scoped to continuous stages, `f` and user assignment/residual
  math, the discrete tier frozen-exact".
- D-070 at the audit's introduction (12352). Bullet 5: "The C172 audit is
  Interpolations tables (prefer cubic knots), saturation rank-deficiency
  (LM-tolerated, reported), gear zero airborne."
- D-155 with §14.5 at the `residuals`/`tolerances` bullet (12265), a plain
  pointer under R7. Position: "the `TrimReport` carries both residual sets:
  the solved-point residuals ... and the committed-state residuals,
  re-gathered from the boundary-zero world".
- D-155 at "nearly free" (12279). Position: "(nearly free — boundary zero's
  sweep has already run — and they describe the state the simulation is
  actually in ...)".
- D-155 at `TrimCommitResiduals` (12293), bold under R7. Position: "a
  converged solve whose committed-state residuals violate the box test
  raises the new service warning `TrimCommitResiduals` ([Appendix C][sC]:
  offending residual names, committed values, tolerances)".
- D-126 at the `fired_events` bullet (12277) and at `TrimCommitEvents`
  (12287), plain under R7. Position: "the `TrimReport` carries the fired set
  (component paths and event names) beside the saturated-bounds list, and a
  non-empty set raises `TrimCommitEvents`".
- D-262 at `TrimCommitChecks` (12301), beside D-139 (F81), bold. Position:
  "A check outside its tolerance raises `TrimCommitChecks`, a logged warning
  that rides the report." D-139 stays for the elimination clause.
- §13 replaced by §13.5 (12310, F58): §13.5's "exceptions from model code
  are always abnormal" (10526–10527, D-060).
- D-224 joined to the propagation sentence (12324), bold. Position: "The
  throw propagates, the simulation is left `built` under [D-223][d-223], and
  no `TrimReport` is returned for that solve." Same entry, same paragraph.
- D-156 at the empty problem (12329), bold. Position: "Zero decision
  variables: `TrimProblem(guess = (;))` bypasses the solver"; Rejected:
  "*`TrimProblemInvalid` on an empty guess*".
- D-307 at the probe's errors (12348, F77). Rationale: "fails at the
  offending line with a `MethodError` or an `InexactError`".
- D-280 at "puts the probe in CI" (12349, H85). Position: "The repository's
  test suite builds a `Dual` activation of every component, with
  `build(world; activations = (Float64, ProbeDual))`."
- D-071 seven times in §14.9, each bold (q24 rows 641, 645, 657, 665, 668,
  673, 675):
  - Position: "A `TrimProblem` is an implicitly specified condition ...
    which unifies the services as condition-algebra clients."
  - Bullet 1, its standing clauses: "the condition is post-composed ...
    while guess, bounds and residuals pass through path-free" (the read-set
    clause is amended by D-277, annotation 2026-09-30).
  - Bullet 2, its standing clause: "Slots resolve through export chains from
    the mount point" ("named by the build" is stale, F54).
  - Bullet 3: "The world-level `f_init!` wrapper dissolves into the
    `baseline` condition: method nesting becomes value layering."
  - Bullet 4: "`design_world(ac)` promotes today's ad-hoc linearize models to
    a shipped rig".
  - Bullet 5: "A swarm takes one problem per solve".
  - Bullet 6 with its annotation of 2026-10-19: "A `product()` helper is
    recorded ..., unbuilt"; "the helper is recorded in [§14.9][s14-9]".
- D-277 beside D-071 at the lift (12385). Bullet 4: "`at` on a
  `TrimProblem` lifts field by field".
- D-277 at "A read set carries its mount chain as data" (12409), at
  "Resolution walks the chain" (12411) and at "A refusal spells the selector
  as authored" (12420). Position: "`at(prefix, read_set)` prepends the prefix
  to the read set's own chain of prefixes and joins nothing; `Reads` is not
  a condition node and `Scoped` never wraps one. Resolution walks the chain
  from the root ..."; bullet 5: "A refusal spells the selector as authored
  and names the mount."
- §14.2 at "An unexported face fails resolution by name" (12427), R6's
  pointer to the home of the `u` payload's export chain.
- D-139 at "A problem never authors the environment" (12434). Rationale
  only; see below.
- §13.7 removed (12480, F57). D-071's annotation of 2026-10-19: "[§13.7]'s
  library holds components only."
- §4.4 and D-237 kept on M66's pointer sentence (12468–12470).

## Rationale-only rulings

- D-139, Rationale, log 4962: "**Trim problems never author the
  environment** ([§14.7][s14-7], [§14.9][s14-9]): handles arrive through the
  user parameter record". Bold at §14.9 12434. The log owes a Position
  (survey 2's part E, "Rulings that need an entry", item 4).
- D-110, Rationale, log 3644–3647: "an `init!` in every respect — boundary
  zero, §14.6 pre-write totality, guards-at-commit, `t0` anchoring, and the
  §12.6 three-item clear (trace, log, staged batches)". Cited at the
  recorders' restart; not bold.
- D-307, Rationale, log 13455–13456: the `MethodError` beside the
  `InexactError` (F77). Not bold.

## Bold on the same entry elsewhere

Checked against the four siblings' `new.md` and the frozen spec's other
chapters. No ruling is bold in two places.

- D-155: unit B bolds its first ruling ("A commit-fired handler is not the
  only mover", §14.5); G bolds its second, `TrimCommitResiduals`.
- D-262: unit F bolds "Checks are equations the service reports once, at
  the committed state, and never solves" (§14.7, Position sentences 2–3);
  G bolds sentence 4, `TrimCommitChecks`.
- D-070: unit F bolds the Position's headline and bullets 1 and 2 (§14.8);
  G bolds bullets 3 and 4.
- D-139: unit A bolds the Rationale's caller-computable clause (§14.1); G
  bolds its never-authors clause. Both Rationale-only, different rulings.
- D-156: the frozen spec bolds its other two rulings at 5394 and 5587
  (§10.1, §10.2); G bolds the zero-decision ruling.
- D-126 and D-110: bold in unit B only. D-278: bold in unit A only (§14.2).
- D-071, D-277, D-364, D-224: bold in G only. D-364 is plain at §13.7
  11048–11050 and §4.4 976.

## Inbound citations affected

- `migration_outline.md` 28 cites §14.8 for the audit, gear included. After
  R15 the gear and the `norm` guards sit in the outline's own paragraph
  (`companion_addition.md`); the row's §14.8 citation holds for the tables
  and the saturations.
- §7.2 1932 ("§14.8 records what that asks of an interpolation package"):
  holds, the Interpolations bullet stays.
- §13.7 11050 (the rig's constant source, §14.9, D-364): holds, the bold
  stays.
- D-071's annotation of 2026-10-19 ("the helper is recorded in §14.9"):
  now true (F57).
- Appendix C's `ConditionResolution` and `ReadResolution` rows may not list
  §14.9, which now names both for the internally wired input (R14, F71).
  Track 2.
- Appendix C's `TrimProblemInvalid` row (13666) and its reasons follow F52's
  list. Track 2, as the brief's landing edits say.

## Open questions

1. Correction 1: reword the saturation bullet's "the report names the
   saturated variable", or keep D-070's wording.
2. Correction 2: `HorizontalTerrain` (Flight.jl has `UniformTerrain`), here
   and in the glossary.
3. D-277's Position has two semicolon halves, the chain and "`Reads` is not
   a condition node and `Scoped` never wraps one". I read the second as
   elaborating the first (where the chain is not kept) and bolded once. Its
   bullets 1–3 elaborate the resolution sentence and stay plain. Confirm,
   or bold the second half too.
4. D-188: q24 proposes "one [sentence] added at the sketch" stating that
   `TrimProblem` is built by keyword. No old sentence states it, so I added
   none and left the sketch verbatim. Rule whether to add "The lift builds
   its problem by keyword, as every `TrimProblem` is built
   ([D-188][d-188])."
5. R6 names §14.5 the home of the recording clear, but unit B's §14.5 does
   not state it. §14.8 keeps its two sentences in full, now with D-110.
   Confirm §14.8 as the clear's home, or have B state it.
6. Seven D-071 bolds in §14.9 (18 bold spans in the unit). Bullets 3–6
   (the world wrapper, `design_world`, the swarm, the `product` helper)
   could go plain as descriptions of Flight.jl's past and of user-side
   composition, q24's option (b). I applied option (a).
7. Links left for unit F, per the brief: guard and tier (F links both
   first), `TrimProblem` and baseline. Links G keeps in §14.8 although F
   uses the word first unlinked: component (F's "component-declared",
   F `new.md` line 334) and root-input totality (F's "Commit's totality
   check"). First-use links left without a parenthesized gloss, one
   parenthetical per sentence being the limit: batch (the staging cell's
   gloss beside it says what a batch is), component in §14.8 and in §14.9
   (inside face's gloss), scenario component (inside the old example's
   parentheses) and `design_world` (the next sentence spells its parts).
