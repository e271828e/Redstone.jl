# Unit F (§14.7, §14.8 to the end of "Scratch stores"): rulings

Old line numbers are lines of `units/F/old.md` (spec line = old line + 11873).
Log lines are lines of the frozen `scratch_survey/h1/decisions.md`.

## Corrections proposed

1. **"FlightCore's mutating `f_disc!`"** (old 149). FlightCore has no
   `f_disc!` any more. Flight.jl commit `30a5942c` is "Rename f_disc! and
   related macros to f_periodic! for clarity", and
   `~/.julia/dev/Flight.jl/lib/FlightCore/src/modeling.jl` 219 defines
   `f_periodic!`. Kept as written. Proposed: "FlightCore's mutating
   `f_periodic!`".
2. **"The FlightCore formulation"** and **"FlightCore's derivative-free
   scalar minimization"** (old 111, 115). FlightCore holds no trim code
   (`rg -il trim lib/FlightCore/src` finds nothing). The formulation is
   FlightPhysics' (`θ_constraint`, `AbstractTrimState`,
   `lib/FlightPhysics/src/aircraftbase.jl` 92, 110) and the BOBYQA
   minimization is Flight.jl's C172 model's (`lib/FlightApps/src/c172/c172.jl`
   924). Kept as written, since spec_style lets FlightCore stand for the
   predecessor. Proposed, if the owner wants the owners exact: "Flight.jl's
   formulation" and "Flight.jl's derivative-free scalar minimization". See
   open question 3.
3. **"reach any port the structure has"** (old 76–78). `get_state` and
   `get_deriv` reach a state field, not a port (survey row 528). Kept as
   written. Proposed: "reach any port or state field the structure has".
4. **"Names and types are checked at setup"** (old 175). True, and the code
   also re-checks the residual return at the first seeded evaluation
   (`src/trim.jl` 518–537; survey F52, unit G's). Kept as written; unit G's
   F52 list is the place to say it.

## Citations added or replaced

- **D-118** at the field set (bold), at `at`'s pass-through, at
  `TrimParameters` (with D-069), at the signature rule (bold) and at the
  returned names. Position: "The `TrimProblem` field set closes at seven …
  carried in the problem because a relocated problem must carry its own
  convergence test (`at`'s lift gains it as a path-free pass-through). The
  residual signature is … under one rule: what the solver varies is passed
  …, what is fixed per problem is closed over (`TrimParameters` stays
  framework-invisible …). Returned names are the report's equation names".
- **D-262** at the field set, beside D-118, for the two fields it adds, and
  at the checks' bold (was adjacent). Position: "A `TrimProblem` carries a
  second, optional equation set, `checks` with `check_tolerances` … The
  service never solves them. It evaluates them once, at the committed state".
- **D-069** at the field list's decisions (bold), the dropped supertype,
  `TrimParameters` (bold), the read side (bold), the residual system (bold),
  the formulation's core (bold), the default, non-squareness (bold), the
  fallback's survival, the recorded extensions (bold) and the LM evaluation.
  Position: "a nonlinear least squares on $r(d)$ with exact AD Jacobians, the
  Dual activation seeded through the `T`-generic assignment math"; bullets 1–6
  as quoted in `claims.md`; Rejected, "*Framework decision-variable
  supertype* (`AbstractTrimState`/`FieldVector`): vocabulary whose only job
  was vectorization".
- **D-151** at "the names are the pairing" (replacing the bold, H72), the
  residual reorder and the backend's unpacking order. Position: "At every
  author↔framework `NamedTuple` seam the names are the pairing and field order
  carries no semantics … `guess`'s field order … is the solver-vector packing
  order …, `tolerances`' for residuals (the residual return canonicalized to
  it before packing)".
- **D-124** at the `reads` spelling. Position: "[§14.7]'s `reads` grammar
  widens to the full service set … with per-selector validation targets".
- **D-277** at the mount-level validation (F69). Bullets 2 and 3:
  "`get_input(face)` names an input face of the mount level", "`get_face(name)`
  names an output face of the mount level".
- **D-414** at the face guidance and at `get_deriv` by convention (F70).
  Bullet 4: "The locality law … is authoring guidance, not a framework check
  … and `get_face` remains the read for a consumer meant to outlive the
  build."
- **D-125** at the face guidance. Position: "an equilibrium equation crossing
  a generic seam binds the curated face contract".
- **D-148** at the `Dual`-typed clause (M54). Position: "every
  decision-dependent leaf is `Dual`-typed in the shape ([§14.7]), which is
  what makes the seeded decisions reach the sweep at all".
- **D-319** at the two `ArgumentInvalid` refusals (F71, R14). Bullets: "`trim!`
  takes the claim's gate before any check, since it commits"; "`trim!` and
  `linearize` on a `Model{T}` at any `T` other than `Float64` throw
  `ArgumentInvalid` with reason `:non_nominal`".
- **D-070** at the LM default (bold), the fallback's status (R10), step
  projection (bold) and the one writer (bold). Position: "The trim service
  defaults to an in-house dense LM solver behind a value-passed backend
  contract: the `NLoptBackend` extension takes squared residuals"; bullet 1,
  "Box bounds are applied by step projection"; bullet 2, "authoritative
  stores have exactly one writer, the commit through boundary zero".
- **D-158** moved into the seam sentence (was adjacent at the status
  sentence, which keeps it). Position: "The backend seam is a pinned
  signature, not prose".
- **D-150** at the verdict (bold), the tolerance translation, the
  inscribed-sphere display's lead sentence and non-convergence. Position:
  "The convergence verdict is the service's, uniformly and
  backend-independently … That verdict, and nothing else, gates the commit".
- **D-149** at "checked here, as [§14.6] requires" (M58) and at the commit's
  unfailable totality check. Position: "Slot totality is checked at every
  application that establishes a complete world over virgin stores —
  `init!`, trim setup, trim commit".
- **D-213** moved into the bold sentence (it was at the paragraph's end,
  which keeps it).
- **§9.5** replaces **§14.3** at the frozen-cell copy (F55). §9.5: "The
  executor embeds a `Float64` as a zero-partial constant".
- **§13.4, D-223** at the interrupt inside the commit (F62). D-223 bullet 4:
  "An interrupt inside boundary zero moves the lifecycle to `built` and
  propagates raw; a service has no stop path."
- **§8.3 removed** with the undeclared-intermediate rule (M55); §14.4's home
  carries §8.3.

## Rationale-only rulings

- D-150, Rationale, log 5694: "The tolerance translation into each backend's
  stopping language is the service's too", cited at the tolerance
  translation's first sentence.
- D-150, Rationale, log 5700: "Soundness (inscribed sphere)", cited at the
  display's lead sentence as the exempt comparative passage's entry.
- D-149, Rationale, log 5659: "commit's totality check is structurally
  unfailable *through the trim path* — it remains as the shared
  `init!`-boundary defense, no `TrimReport` committed flag exists or is
  needed".
- D-069, Rejected, log 2251: the dropped decision-variable supertype.

## Bold on the same entry elsewhere

No ruling is bold in two places. Checked against the frozen spec's other
chapters (none bold D-069, D-070, D-118, D-150, D-158, D-213 or D-262; D-151
is bold at §9.5 and plain here; D-149 at §9.3, and in unit B's §14.6, plain
here; D-414 at §13.3, plain here) and the siblings' `new.md`:

- D-262: here sentences 2–3 of its Position (never solved, evaluated once at
  the committed state); unit G bolds sentence 4 (`TrimCommitChecks`).
  Different rulings.
- D-070: here the Position (the LM default), bullet 1 (step projection) and
  bullet 2 (one writer); unit G bolds bullet 3 (no throw) and bullet 4 (the AD
  obligation). Different rulings.

Judgment calls under the one-bold test (R7), each a row q24 listed:

- D-069 bullet 1 is two rulings, a semicolon apart. The decisions' shape is
  bold at the field list, its first statement in reading order (H52); the
  "Decisions and parameters" topic sentence restates it plain.
- D-069 bullet 2 ("Assignment is the pure `trim_condition` fragment function,
  and reads are declared …") is one ruling. The bold sits on the reads clause,
  not on the assignment sentence that precedes it, since that sentence names
  the worked problem's illustrative function.
- D-069 bullet 3 is a comma list. Its first items (per-residual tolerances,
  failure reports) are restated plain in the default's paragraph; the bold
  sits on "Non-squareness degrades gracefully", the one sentence stating the
  bullet as a headline.
- D-069 bullet 5 (the fallback) is bold in the conditional (R21, R10).
- D-070 bullet 2 is one ruling. The bold sits on the one-writer clause, its
  headline, not on "Every `trim!` invocation instantiates a fresh working
  store set" (old 281).
- D-158's later semicolon rulings (the packed vectors, `tol`, the counts, the
  `solve` name) stay plain as elaborations of the displayed signature; the
  open status set takes the second bold, as q24 proposed.
- D-150's second ruling (status demoted, authoritative over nothing) stays
  plain beside the verdict's bold.
- D-262's first and last sentences (the pair's shape, both default to empty)
  stay plain in the field list.
- D-213's second sentence (raw iterations) stays plain; §14.5 is its home
  (R6).

## Inbound citations affected

All hold:

- spec 11533–11535 (§14.3) and log 5587 (D-148), "`Dual`-typed in the shape
  ([§14.7])": the clause stays (M54).
- spec 11683 (§14.4), "The component exports it ([§14.7])", and log 4140
  (D-125 Rationale), the `y_direct` idiom beside the `reads` bullet: both
  remedies stay, under "Reads".
- log 5716 (D-150 Rejected) and spec 12129, the hand-scaled `stopval` §14.7
  criticizes: the numerics paragraph stays.
- log 5655 (D-149 Rationale), raw instantiation sound because of the check:
  kept.
- spec 14927 (glossary, `worked`) and log 3919 (D-118 Rationale): the cruise
  block stays.

For landing: Appendix C's `ArgumentInvalid` row (13722–13723) lists §14.7,
which raises none, and omits §14.8, which now names `:non_nominal` and
`:claimed` (F71). `docs/design/tools/gloss_table.md` row 202 glosses
`TrimProblem` as "the closed seven-field value"; the glossary and this unit
say nine.

## Open questions

None open. Questions 1 to 3 were ruled R21 to R23 and applied. R21: D-069
bullet 5's headline clause is bold in the conditional; D-070's `NLoptBackend`
clause stays plain, an elaboration after the colon of D-070's one-sentence
Position, whose LM-default ruling is already bold. R22: `f_periodic!`
(corrections 1). R23 (correction 2): "FlightCore's" became FlightPhysics' at
the formulation's core and Flight.jl's Cessna 172 model at the minimization
and at §14.8's threshold. `f_ode!` stays FlightCore's, its real owner.
