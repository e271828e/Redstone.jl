# Unit B2 of Appendix B: rulings and findings

Frozen line numbers are frozen-spec numbers; `src/` paths are in the frozen tree.

## Corrections proposed

None outside the rulings. The R7 rows (R3-18, R3-36, R3-37, R3-38, R3-39, R4-05,
R4-06, R4-19, R4-22, R4-41, R4-62, R4-69) are applied as the brief orders:
R3-38, R3-39, R4-19, R4-41 and R4-62 corrected in place, the rest dropped to
their homes.

Coordinator rulings of 2026-10-20, adopted (ruling "coordinator 2026-10-20" in
claims.md):

1. Glossary links. B1's new text no longer uses trace header, selector,
   calling task or root-input totality, so B2 links each at its first use in
   B2: root-input totality and trace header in `init!`'s entry, selector on
   the read-selector family, calling task in `run!`'s entry. Snapshot stays
   B1's.
2. Diagnostic names stay on B (D-226: a name is public by standing on B).
   `CheckpointMismatch` and `CheckpointMidFrame` are back on both `restore!`
   entries (R3-59 and R3-65 kept as they stood; R3-64's check now names
   `CheckpointMismatch`). `UnboundedRun` is back on `run!`, corrected under R7
   to fire in `:live` only (R4-19), with §13.5 beside §11.8; diagnostic cell
   takes its link there (B1's old text never uses it). `converged` is back on
   `trim!`'s entry as the report's field the commit gates on (R3-47).
3. The four doors. `restore!`'s gloss says "A door beside `init!`, `overlay!`
   and `replay!`" (R3-58), and the Recording sentence says `overlay!`,
   `restore!` and `replay!` take the same four (R3-32), under R7 and R2-55's
   correction; §12.6 (frozen 9475) names `overlay!` the fourth door.
4. R3-78 stays as it was, open for the owner.
5. Stop policy. B1 keeps the term out, so B2 links `StopPolicy` at its first
   use, the `StopPolicy` sentence in `run!`'s entry (`#g-stop-policy`).

Coordinator rulings of 2026-10-20 on the verifier's report (`verify.md`),
adopted:

6. C-041. "By default" now scopes the method only: "It solves against the
   problem's own `tolerances`, by default as nonlinear least squares on the
   packed residuals with exact Dual Jacobians". The per-residual box test
   against `tolerances` holds for every backend (§14.8, 12325; D-150).
7. `logged`. "oldest first" goes; the spec does not state it (only the
   src/sim.jl docstring does). The entry keeps its other words.
8. `trim!` spells `t0::Real = 0.0`, as src/sim.jl:812 does. §14.8 (frozen
   12275) spells `t0 = 0.0` on the model form.
9. `linearize` keeps `width = 8`. `src/` spells `width::Int = LINEARIZE_WIDTH`
   (src/sim.jl:835), and `const LINEARIZE_WIDTH = 8` (src/linearize.jl:61).
   §14.10 (frozen 12848) and D-272 state the default 8.
10. D-261 leaves the replay sentence, which it does not support, and closes
    the restored clause "taking `init!`'s four recording keywords as well"
    (R4-64). The signature still spells the keywords.
11. The two off-by-one frozen line references are fixed: the measurement seam
    is 5384, `t_plus` is 9490.
12. Q1, stop request: no change. B1 links it at "stop requests" in its
    Any-component bullet.
13. Q2. drain (`#g-drain`), batch (`#g-batch`) and staging cell
    (`#g-staging-cell`) are linked at their first use in B2, `mode`'s entry.
    All three anchors exist; batch is used in its reserved sense.
14. Q3. `trim!`'s entry gains one clause on `LevenbergMarquardt()`, as far as
    §14.8 says it: "`LevenbergMarquardt()`, the default backend, is an
    in-house dense Levenberg–Marquardt" (§14.8, D-070; frozen 12283, "The
    default backend is an in-house dense Levenberg–Marquardt (D-070)"). It is
    an `added:` block in claims.md.

Signature findings under R8, left as stated:

- `series(sim, read_set) → ts` and `trace(sim) → trc`. `src/` returns a `Series`
  (src/sim.jl:2293, docstring "series(sim, read_set) → Series") and a `Trace`
  (src/sim.jl:2347). No spec section names either type (D-407's Position calls
  `series` and `Series` provisional until the export audit), so B keeps the
  variable names. For the audit.
- `init!(sim, condition = set(); …)` and `overlay!(sim, condition = set(); …)`.
  Spelled as src/sim.jl:591 and :690 spell them, as R8 orders. No spec
  sentence states that the condition defaults to `set()`.
- `set(; x = (;), s = (;), m = (;), u = (;))` and `taps(; x = (;), u = (;), y = (;))`.
  Spelled as src/conditions.jl:74 and src/linearize.jl:36 spell them, under R1.
  The spec spells both without defaults (§14.2 and glossary `set(; x, s, m, u)`;
  §14.10 and D-272 `taps(x = …, u = …, y = …)`).
- `replay!` now shows `to_boundary = nothing, to_time = nothing` and the four
  recording keywords, as src/sim.jl:974 spells it (R1).
- `step!` keeps `frames = 1` (R8); `src/` spells `frames = nothing`, meaning 1.
  `t_plus = nothing` joins the signature from src/sim.jl:1751.
- Not listed in B, by design or for the audit: `phase_bodies(model)`
  (src/model.jl:273); `restore!(sim, ::ModelState{T})` at a non-`Float64` scalar,
  which throws `CheckpointMismatch` (src/sim.jl:798); the misuse methods
  `trim!(sim, other)`, `linearize(sim, other)` and `series(sim, other)`
  (src/sim.jl:823, :849, :2316), which refuse a non-problem, non-tap-set or
  non-read-set argument.

Survey rows found wrong:

- signatures.tsv row 170 says `termination` is absent from `src/`. It is
  defined at src/sim.jl:367 with a docstring (the record, `nothing` until the
  loop's tail writes it).
- R3-56's home: the sentence at frozen 11435 cites D-274, and its claim is
  D-273's too; the old B2 citation of D-319 carried nothing of it. Moot, since
  the claim drops to its home.
- R3-53's home line is 9566 ("`checkpoint(sim)` wraps that state with the run's
  frame index and boundary ordinal"), not 9559.

## Citations added or replaced

- §14.2 on `set`, `at`, `combine` and `condition` (R3-03, R3-06, R3-10, R3-11,
  R3-17). The old bullets cited only the group's §14.1–§14.6 range. §14.2 states
  each: "`set`'s payloads speak only about the component at the authoring
  point" (11513); the `Scoped` comment "at(prefix, node): stores, never
  applies" (11535); "`combine` (the symmetric, collision-intolerant
  combinator)" (11529) and "it reports both origins" (11586); "a method of the
  framework's `condition` generic … dispatched on the component" (11481).
- §14.9 replaces §14.7 on "the closed nine-field value a trim solves" (R3-42).
  §14.7 (12062) states "The field set is normative and closed" and no count;
  §14.9 (12628) states "a `TrimProblem` (the closed nine-field value a trim
  solves)".
- §14.7 on the trim default (R3-39): "The default is nonlinear least squares
  on r(d) with exact AD Jacobians" (12231).
- §14.8 on the trim commit (R3-44): "The committed solution is applied as an
  `init!` in every respect. It is `override(baseline, condition(d))` through
  boundary zero" (12448). The old §12.6 carried only the recorders' restart.
- §14.8 on the `solve` entry (R3-48): "The backend seam is a pinned signature,
  value-passed, with one required method per backend (D-158)" (12292).
- §14.5 joins `init!`'s boundary-zero sentence (R3-24), which its home states.
- §12.6 and D-274 on the `checkpoint(sim)` gloss (R3-53). D-274's Position:
  "A `Checkpoint{T}` is the executor's state at a frame top, taken by
  `checkpoint(sim)` and by `init!`"; it holds "the clock in full (`t`, the
  frame index, the boundary ordinal, `t₀`), and the fingerprint, the
  deployment".
- §14.10 on `linearize` (R3-77). The old bullet's D-272, D-276 and §14.4 stay
  on `taps`, where their claims are. D-319 leaves with the `Model` form (R3-80).
- §11.1 on "`run!` blocks until the run ends" (R4-03): "`run!` blocks its
  caller until the run ends" (6918). §12.6 on the deviceless clause (R4-04):
  "Deviceless, `run!` is fully synchronous" (9482).
- §13.5 and D-260 on the `StopPolicy` sentence (R4-16). D-260's Position:
  "The stop policy is the advance's argument. `run!`, `replay!` and `step!`
  build it, pass it to the loop and to the record's assembly, and drop it."
- §12.6 on `t_plus` (R4-23): "`step!(sim; t_plus = 10.0)` is the duration
  spelling (D-390). It is mutually exclusive with `frames`" (9490).
- §11.3 moves from the harness-writer clause to the bullet's end (R4-30,
  R4-31); §11.3 homes both (7319, 7324).
- §12.1 and D-268 on the pause verbs (R4-49, R4-50). D-268's Position: "The
  pause is spelled `pause!(sim)`, `resume!(sim)` and `paused(sim)`". §12.1
  (8701): "The pause is two verbs on the simulation (D-268)".
- D-268 on `stop!(handle)` (R4-52), beside the old §11.6. Rationale only, below.
- §9.7 and §9.8 on the measurement seam (R4-41): §9.7 (5384) "The phase bodies
  are the §9.8 measurement seam (D-116)".
- §11.5 on `trace(sim)` (R4-62): "Trace recording is on by default (D-029)"
  (7844).
- §13.5 joins §11.8 on `UnboundedRun` (R4-19): "The advisory fires in `:live`
  only" (10748).
- §14.8 on `converged` gating the commit (R3-47): "That verdict, and nothing
  else, gates the commit and fills `TrimReport.converged`" (12325).
- §12.7 alone on `live!` (R4-82): "`live!` sets the mode to `:live` and detaches
  the recording's remainder, touching nothing else (D-219)" (9789).
- The additions' citations: §14.4 on the selector family ("They form one
  address space for every reader that takes a selector", 11762); §13.5 and
  D-203 on `termination(sim)` (D-203's Position: "a typed source", the four
  sources `EndTimeReached`, `ModelRequestedStop`, `ControlRequestedStop`,
  `LoopError`); §11.2 on `logged(sim)` (its docstring cites §11.2; the spec
  spells no accessor, see Open questions); §11.2 and D-407 on `reads` (§11.2
  at 7131, "a read set, the value trim's `reads` builds and `at` mounts";
  D-407's first bullet, "The read set is the `Reads` value trim's `reads`
  builds, so `at` mounts it").
- Dropped with their claims: §14.1 and D-319 (R3-56, R3-80), §14 and the
  §14.1–§14.6 range (the group labels), D-029 (R3-33), §10.7 (R4-06, R4-15),
  D-269 on `step!` (R4-22), §12.4 (R4-56).

## Rationale-only rulings

- D-268 for `stop!(sim)` and `stop!(handle)`, cited under R6. Field: Rationale,
  log line 11498, "The verbs follow the stop's grammar, `stop!(sim)` beside
  `stop!(handle)`". The Position spells only the pause verbs. No spec sentence
  outside B spells either (the survey's R4-52 note places `stop!(handle)` in
  §12.4's code; the frozen spec has no such line). The §11.6
  citation on `stop!(handle)` carries the capability ("request shutdown"), not
  the spelling.

## Bold on the same entry elsewhere

None. B2 has no bold. The old bold on "this advance" (two table rows) goes
under R4; D-255 and D-316 hold that ruling bold in §12.6 (9653, "The stop policy
is declared per advance").

## Inbound citations affected

Frozen sentences citing Appendix B for B2's content, all still carried:

- 7037 (`log_every`): the `init!` table row.
- 7048 (`init!`'s and `run!`'s defaults, `log = true, log_every = 1`,
  `t_end = Inf`): the two tables and the signatures.
- 7056 (the four recording keywords on `init!` with their defaults): the
  `init!` signature and table.
- 7810 (the header's `Deployment` and `t₀`): kept through `init!`'s "the
  checkpoint that is the run's trace header" and the checkpoint entry's "with
  `t₀`, the fingerprint and the deployment". Both were otherwise class 2; they
  stay for this citation.
- 7845 (`init!`'s `trace` keyword): the table row.
- 8733 (`pace` and `margin` defaults): the `run!` table.
- 9369 (the doors' recording keywords): the `init!`, `restore!`, `overlay!` and
  `replay!` signatures, and the Recording sentence.

## Open questions

- R3-78, `linearize`'s `t0` "(default `0.0`)", for the owner (R6). The
  signature shows `t0 = nothing` as src/sim.jl:834 spells it, and the prose
  keeps "`about` with `t0` (default `0.0`)". `src/` already defaults it
  (`something(t0, 0.0)`, src/linearize.jl:175); no spec section or entry
  states the default (D-272 and D-420 place `t0` beside `about` with none).
  Ruled by the owner on 2026-10-20: the default stands, as D-430, stated
  in §14.10 and cited on B's `linearize(sim, …)` entry.
- Glossary links left to B1 under R12, because `units/B1/old.md` uses the term:
  boundary zero, condition, fragment, stop request,
  control plane, scratch, replay,
  nominal, activation, `latest`, and snapshot (B1's draft links it at
  `port(snapshot, path, name)`). Root-input totality, trace header, calling
  task and selector are now B2's, under coordinator ruling 1. Stop policy is B2's
  too, under coordinator ruling 5.
- `reads` is two names in one: `reads(; selectors...)`, the read-set
  constructor B2 lists, and the binding trait `reads(b)` B1 lists. For the
  exported-name audit.
- `logged(sim)` is in `src/` (src/sim.jl:2267) with a docstring citing §11.2,
  but no spec sentence spells the accessor; §11.2 says only that the log is the
  retained snapshots. Whether §11.2 should name it is the audit's question.
- `termination(sim)`: the spec spells it once, in §13.4's dispositions (frozen
  10484, "`termination(sim)` retaining the cause"), never in §13.5, which
  owns the record. Whether §13.5 should name the accessor is open.
- Length: 1,190 words against old B2's 1,898 (63%), after six added entries
  and the coordinator's restorations.
  Most of the remainder is signatures and the two keyword tables.
