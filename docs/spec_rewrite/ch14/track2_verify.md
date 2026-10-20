# Chapter 14, track 2 verification (step 8, cold)

Commits `f0fc916`, `bc48aa9` and `41c1126`, against `track2_plan.md` with
its orchestrator amendments and the two logs. `c11b6db`, made since, touches
nothing under `docs/design/`.

## Counts

- Hunks: 54 at `git show`'s default context, all matched to a log edit.
  `f0fc916` has 1 (log 1, edit 1). `bc48aa9` has 36 for log 1's 37 edits,
  since D-069's Spec field and annotation (edits 22 and 13) share a hunk.
  `git show -U1` gives 37. `41c1126` has 17: the Index rows, the twelve
  entries and their link definitions in `decisions.md` (log 2, edit 1), and
  14 in `spec.md`, 13 for edits 2 to 15 (edits 10 and 11 share the §14.9
  hunk) plus the link definitions.
- Entries: 12, D-415 to D-426. Each Position checked against its source,
  and each bullet grepped against all 400 Positions, annotations left out.
- Annotations: 16 (log 1, edits 2 to 17). All dated 2026-10-20. No Position
  line changed, and every added line in `bc48aa9` is an annotation or a Spec
  field.
- Spec fields: 21 entries (edits 18 to 38), 24 sections added, D-253's §14.1
  replaced by §14.3. Each section checked against the entry's Position at the
  sentences that cite it. The B69 decline (D-213, §14.10) is sound.
- Citations: 16 added in 14 edits. A word diff shows only the citations
  added; no wording or bold changed. Every changed line is at most 80
  rendered columns.
- Battery, each check run on its own: `check_refs.jl` OK, `check_rows.jl` OK
  (D-415 to D-426 newly cited), `check_glossary.jl --strict` OK,
  `check_bold.jl` OK, and `linkify.jl` a no-op (`git status` clean after it).

## Findings

1. **§14.2, spec 11449, the D-277 citation (agent 2's flag).** D-277 bullet 2
   states the condition-entry refusal only by citing §14.2 back ("as a
   condition's `inputs` entry is ([§14.2])"), so it is no source (lesson 43).
   No other Position rules it. D-065's "unexported = unwritable" covers the
   unexported face, not a face a component feeds. D-071 bullet 2 and D-139's
   Rationale assert the refusal but cite §14.9. The ruling has a design
   source and the code implements it. §16.2 of the design text at `2ee101a`
   (D-065's v0.11 commit) reads "resolution walks the export chain to the
   root slot and errors if the face never surfaces — an internally-wired
   input has no slot and writing it is meaningless (the first sweep
   overwrites)". `_root_input` (`src/conditions.jl` 444–455) raises
   `ConditionResolution` with reason `:internally_wired` and the producer in
   hand. Ratifying the ruling would not choose between behaviors.
   Fix: write D-427, "Refuse a condition entry naming an internally wired
   input at resolution, with its producer". It restates `2ee101a` §16.2 by
   commit and section (as D-408 does) and the code with the landed §14.2 (as
   D-400 and D-422 do). Then §14.2 cites D-427 in place of D-277, and §14.9
   (spec 12609) cites D-277 and D-427.
2. **D-071 annotation (log 1, edit 14).** "Resolution refuses it with the
   producer named, as D-277 states" sends a reader to D-277, and for a
   condition entry D-277 points back to §14.2 (lessons 16 and 43). Fix:
   point the clause to D-427 (finding 1), keeping D-277 for the `get_input`
   half.
3. **D-122 annotation (log 1, edit 10).** "The clause held when written …
   and `init!` lost the keyword later" is false. At D-122's own commit
   `4728a93` the spec gives `init!(sim, condition; t0 = 0.0)`. The same text
   rejects a service-level base keyword (`init!(sim, patch; base = ...)`).
   `8e2505c`'s glossary repeats D-122's wording but no `init!` signature has
   ever taken `baseline`. The orchestrator's amendment F6 rests on that
   glossary line. Fix: "only `trim!` takes the `baseline` keyword; `init!`
   took none when this entry was written (`4728a93`: `init!(sim, condition;
   t0 = 0.0)`)".
4. **D-098 annotation (log 1, edit 6).** "No client policy applies on top of
   the source rule" goes beyond D-406's words ("The source rule is the
   resolver's, not a client's"). It also contradicts D-098's own Rationale
   ("[D-083]'s client split rides on top unchanged") and does not address
   it. Fix: quote D-406's Position and its Rationale ("it splits by source
   and not by client") in place of the sentence.
5. **D-409 annotation (log 1, edit 8).** "The service half bears on the reads
   a run acts on, as §13.5 frames the rejection" narrows the Position's scope
   on the spec's framing alone (lesson 43). That is a ruling, not a record of
   stale text. Fix: keep the D-414 sentence (the stale part) and drop the
   scoping clause, or send the scope to the owner.
6. **D-424 Rationale.** "Neither Position states them" is too broad. D-276's
   Position bullet ("A store selector takes a field name with at most an
   index step") already limits the `x` list, and D-272 bullet 2 makes the
   `:vector_tap` refusal, as the Rationale itself grants. What is new is the
   `u` list's step limit, the exact-`Float64` leaf and the reason names.
   Fix: name D-276's store-selector bullet for the `x` half in the
   Rationale.
7. **D-422 Rationale.** "Both entered the code in `415ed0b` and moved into
   `src/trim.jl` in `3408028`" is inaccurate. `415ed0b` added the reasons to
   the kind (`src/diagnostics.jl`). The checks were already in `src/trim.jl`
   as strings, and `3408028` made them raise the reasons. Fix: "named in
   the kind in `415ed0b`, raised by `src/trim.jl`'s checks since `3408028`".
8. **D-426 Rationale.** The Position's words, "pinned-face validation by the
   tap declaration", the two pieces that remain and "additive when a
   consumer shows up", are the text `9ad74d5` wrote ("What stays recorded is
   only the remaining tooling …"). `f990b63` §16.10 says "validated by the
   linearization surface" and lists three pieces. The log names `9ad74d5`,
   but the Rationale does not. Fix: cite `9ad74d5`'s spec text beside
   `f990b63` §16.10 as the source of the two-piece form.

## Checked, no finding

- D-425 against `src/model.jl`. `init!` takes only the claim gate, and so
  does `trim!(model, …)` (`src/trim.jl` 446). `linearize(model, …; about)`
  takes neither gate, while the default form gates at `:consistent`. A
  `Model`'s statuses are `:built`, `:consistent` and `:inconsistent`.
  D-059's terminal `errored` belongs to a simulation (through
  `lifecycle(sim)`), whose methods keep their gates (D-108, D-319). So "at
  any status of the model" holds and does not conflict with D-059.
- D-417's source, D-139's Rationale, cites §14.7 and §14.9. That is not a
  citation back: the rule entered in D-139's own commit `f2658bc`.
- D-415, D-416, D-418 to D-421 and D-423 restate their named sources, and
  the grep finds no Position that states or implies any of their bullets.
- D-422's "collected with the rest" restates D-113's "service batch", as
  context, not as a bullet.
- The other annotations record stale text only, and D-070's matches
  `TrimReport`, which carries no Jacobian.
- Every Spec field addition names a section whose citing sentence states the
  entry's Position.

## Re-check (`c14d920`, `track2_log_3.md`)

### Counts

- Hunks: 14 at `git show`'s default context (11 in `decisions.md`, 3 in
  `spec.md`), each matched to a log 3 entry with its old and new text.
- Fixes re-checked: 8 of 8. New entry: 1, D-427. Citations: 2, at §14.2
  (D-427 in place of D-277) and §14.9 (D-427 beside D-277). No Position
  line changed. Every changed line is at most 80 rendered columns.
- Battery, each check run on its own: `check_refs.jl` OK, `check_rows.jl` OK
  (D-427 newly cited), `check_glossary.jl --strict` OK, `check_bold.jl` OK,
  and `linkify.jl` a no-op (`git status` shows nothing under `docs/design/`).

### The fixes

1. D-427 is sourced as finding 1 asked. Its quote matches §16.2 of
   `framework_design.md` at `2ee101a`, and its Position matches
   `_root_input`. Lesson 42: no Position carries `internally_wired`.
   Lesson 68: D-071 bullet 2 rules only that an unexported, model-driven face
   is untrimmable from outside. It names no resolution-time refusal, no kind
   and no producer, so D-427 does not follow from it. Lesson 43: the design
   text cites no spec section for the ruling. Lesson 17: the ruling is on
   record. The §14.2 and §14.9 citations sit at the refusal sentences.
2. The D-071 annotation now points to D-427 for a condition entry and to
   D-277 for a `get_input`. Fixed.
3. The D-122 annotation is fixed. `init!(sim, condition; t0)` is in the
   design text at `4728a93`.
4. The D-098 annotation now quotes D-406's Position and Rationale verbatim.
   Fixed.
5. The D-409 annotation drops the scoping clause and keeps the D-414
   sentence. Fixed.
6. The D-424 Rationale now names D-276's store-selector bullet, quoted
   verbatim, and narrows what is new. Fixed.
7. The D-422 Rationale's commit history now matches `415ed0b` and
   `3408028`. Fixed.
8. The D-426 Rationale now cites `9ad74d5`. The quotes match
   `framework_spec.md` §14.10 at that commit (bold markup dropped). Fixed.

### Finding

R1. **D-427 Rationale.** "[D-071]'s second bullet and [D-139]'s Rationale
assert it by citing [§14.9]" is wrong for D-071. Its second bullet cites
nothing ("correctly, it being a model-driven input, named by the build").
Only D-139's Rationale cites §14.9. Fix: "D-071's second bullet asserts it
with no citation, and D-139's Rationale by citing §14.9".
