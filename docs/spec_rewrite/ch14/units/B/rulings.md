# Unit B (§14.4, §14.5, §14.6): rulings

Line numbers are old spec lines at `c3d29fb`; log lines are lines of the
frozen `scratch_survey/h1/decisions.md`.

## Corrections proposed

1. **"`!stall`" as a hand-written trim assert** (11808). The asserts that
   close Flight.jl's C172 trim setup are no weight-on-wheels and
   `ω > ω_idle`, plus engine-state and filter-derivative checks
   (`~/.julia/dev/Flight.jl/lib/FlightApps/src/c172/c172s/c172s.jl`
   256–260, `c172x/c172x.jl` 317–322). `stall = false` is set in the
   initializer (c172s.jl 244), not asserted. Kept as written. Proposed:
   "(no weight-on-wheels, `ω > ω_idle`)", or "the trim setup's
   `stall = false` and its asserts (…)".
2. **"before any client policy applies"** (11642, now the D-098 bold). After
   R5 no client policy is enforced. The clause is D-098's Position wording,
   and `#g-selector` (14577–14578) repeats it. Kept as written. Proposed:
   "before any authoring guidance applies", or drop the clause in both
   places.
3. **"That is one class, one mechanism and one kind"** (11837–11838).
   *class* is reserved for primitive versus assembly. The words are D-149's,
   and part F lists the count as a claim. Kept as written. Proposed: "one
   family of sites, one mechanism and one kind".
4. **"Only stopped-sim service evaluations, `checkpoint`, and post-run
   inspection … ever hold live stores"** (11652–11654) sits beside R5's F22
   sentence, "which today are the services'". The first says who holds
   stores, the second who resolves selectors against them, so both stand.
   But a reader may take them as disagreeing. Kept as written. Proposed:
   none unless the verifier flags it.

## Citations added or replaced

§14.4:

- **D-066** at the context sentence (F28's wording), and bold on its three
  semicolon rulings: the specialized `apply!` ("specialized `apply!` … for
  iterating services"), the dynamic walk ("dynamic entry-list walk … for
  one-shot init") and the gather twin ("compiled readers as the gather
  twin"). Also plain at the codegen cost: Position "~10–50 ms codegen once
  per shape", annotation 2026-10-02 "the codegen cost grows with the
  shape's writes".
- **§14.8** at the dynamic walk's uses (F19, trim's setup write).
- **D-095**, bold at "The read-selector family is closed" and plain at the
  `get_` prefix. Position: "Read-selector family spelled with a `get_`
  prefix and completed … a selector is a *deferred read*, so the prefix
  names the eventual action".
- **D-276**, bold at "`leaf` is a leaf address". Position: "The second
  argument of every read selector is a *leaf address*".
- **D-277** at `get_face`'s mount level. Bullet 3: "`get_face(name)` names
  an output face of the mount level … at the root it is the integration
  read it was".
- **D-098**, bold at "A selector resolves against a source", and plain at
  the store selectors. Position: "a selector resolves against a *source*
  before any client policy … store selectors (`get_state`/`get_deriv`) only
  against live stores".
- **D-124** at "A table source is …" (Rationale only, below).
- **D-406** repeated at its bold, "The resolver takes the source it
  resolves for". Bullet 1: "The resolver takes the source it resolves for …
  The source rule is the resolver's, not a client's."
- **D-414, D-125, D-083, §13.3**: R5's dictated guidance paragraph. D-083
  leaves the cut "Client policy rides on top" sentence for the inspection
  read sentence. D-125 Position: "`get_face` is admitted to the service set
  … so an equilibrium equation crossing a generic seam binds the curated
  face contract", with D-414's 2026-10-19 annotation.
- **§11.2** at snapshot inspection (R5, F21), and **§14.7, §14.10** at the
  live-store reader (R5, F22).
- **D-060 moved** from the requester-roster sentence to the run-policy
  sentence. Its policy clause is superseded by D-316 (annotation
  2026-10-08), so the roster sentence cites §13.5 and D-316 alone (bullet
  6). D-060's Rejected item "Root-type-declared policy: stopping is run
  policy" stands (Rationale only, below).

§14.5:

- **D-067**, bold at the opening, "The init service then completes the
  §10.6 macro-sequence with an empty integrate". Position: "Boundary zero is
  the §10.6 macro-sequence run with an empty integrate".
- **D-292** at the prior rule. Bullet 1: "Boundary zero sets every prior to
  not-holding, so an authored condition whose guard holds fires at `t₀`."
  Plain, since §10.6 6487 bolds it.
- **D-274** at replay. Bullet 3: "runs no boundary zero"; bullet 4: "Replay
  restores it and feeds the batches from frame 1".
- **D-413** at the stop request. Bullet 1: "After `init!` that snapshot is
  boundary zero's, so an authored condition already terminal ends the run at
  `t₀`".
- **D-067** moved into the sentence of its bullet 1 bold, "A boundary's
  `s_update` is the outgoing transition". Bullet 1: "a boundary's update is
  the *outgoing* transition".
- **D-067** at the bullet 2 bold, "`t₀` is an init-service argument".
  Bullet 2: "`t₀` is an init-service argument anchoring the harmonic grid";
  Rejected: "`t₀` as a condition entry: time is not a store".
- **D-110**, bold at "Both init-service entry points carry the argument,
  with the same default". Position: "`trim!` gains the init-service `t0`
  argument … default `0.0` matching `init!` (one rule for both entry
  points)".
- **§14.8** at the `trim!` pointer (R6).
- **D-067** at the bullet 3 bold, "Trim is untouched by all of this".
  Bullet 3: "Trim iterations bypass boundaries entirely … and only the
  commit runs boundary zero".
- **D-126**, bold at "The channel that says it is the trim report".
  Position: "Events firing at trim's boundary zero get a channel — the
  `TrimReport` carries the fired set".
- **D-155**, bold at "A commit-fired handler is not the only mover".
  Position: "Projection is named the second legitimate mover of the
  committed point".

§14.6:

- **D-376** beside D-068 at the bare-types sentence. Position: "The
  services own root-input initial values. Neither export entries nor face
  declarations carry root-input defaults."
- **D-068**, now in the sentence of each of its four bolds. Position:
  "Slot totality is enforced at the service"; bullet 1: "`probe_value` is
  structurally unreachable from the services path"; bullet 2: "Baselines
  are aircraft-shipped full-coverage condition functions"; bullet 3:
  "`override(base, patch)` is admitted as the fourth node kind".
- **D-149**, bold at "Totality is a property of every application that
  establishes a complete world over virgin stores". Position: "Slot
  totality is checked at every application that establishes a complete
  world over virgin stores".
- **§14.10** at the fourth totality site (R3).
- **Appendix C** replaces §13.2 at `UninitializedInputs` (F24).

Part E listed **D-276** for row 132, the family's members. Its Position
names the leaf address, not the members, so nothing was added there.
**D-098** at row 145 was not added either: its Position says `capture`
where the spec says `checkpoint`.

## Rationale-only rulings

- **D-124**, Rationale: "table sources (a boundary snapshot, or the scratch
  tables a service evaluation instantiates, §14.8)" (log 4113–4115).
- **D-060**, Rejected: "Root-type-declared policy: stopping is run policy"
  (log 1953–1954).
- **D-276**, annotations 2026-09-30 and 2026-10-01 (log 12073–12094): the
  face head matched on `get_input` and `get_face`. Cited by adjacency in
  the leaf-address paragraph.
- **D-149**, Rationale: coverage as a plan-level fact, checked "before the
  first evaluation, not merely before a write" (log 5651–5655). Adjacent to
  D-149's bold.
- **D-067**, Rejected: the suppressed firings and the accumulator one
  period late, "the authored `z(0)` needs no protection" (log 2178–2182).
  Cited.
- **D-026**, Rejected: insurance that masks invariant violations. Cited.
- **D-068**, Rejected: "a fabricated zero is a fine probe input and a
  terrible flight condition"; totality "belongs to boundary-zero
  application" (log 2215–2218). Adjacent.
- **D-095**, Rationale and Rejected: inspection readers admit the whole
  family; `stop_on` outside the family (log 3087–3089, 3099–3100). Now
  plain and uncited ("Inspection reads admit …", "`ignore_stop_requests`
  is not a family client").
- **D-125**, Rationale: demand-driven publication, the export remedy (log
  4143–4146). Uncited at the merged remedy (M5).

## Bold on the same entry elsewhere

- **D-149**: §9.3 4690–4692 bolds "Every complete-world application,
  namely `init!`, trim setup and trim commit, carries the pre-write
  `UninitializedInputs` check". R7 makes §14.6 its bold home, so it is
  bold in two places until §9.3 goes plain at landing. §9.3 also lists
  three sites (R3's landing edit).
- Checked and not doubled. D-292 (§10.6 6487), D-274 (§11.5 7747, §12.6,
  §12.7), D-083 (§11.2 7122) and D-376 (§11.3 7326) are bold elsewhere and
  plain here. D-406 is bold in §11.2 7128 and 7135 and §11.6 8101 on its
  Position sentence and bullets 2 and 4. Here it is bold on bullet 1, which
  nothing else bolds. D-276 is bold at 903 on its wiring bullet, and here on
  its Position. No sibling `new.md` exists yet. R7 has unit G point to
  §14.5 for D-126 and D-155's first ruling, and bold only
  `TrimCommitResiduals`.

## Inbound citations affected

- §9.3 4690–4692, §11.3 7334 and the glossary 14770–14772 list three
  totality sites; §14.6 now lists four (R3, landing edits).
- §14.8's signature (unit F, "The backend seam") is the home for the
  `trim!` signatures that §14.5 dropped (R6).
- Appendix C 13678, `ConditionShapeDrift` (§14.4): its payload list names no
  `reason` field, while §14.4 now names `:tree_type` and `:prefix`
  (`src/diagnostics.jl`). This is for Appendix C's carried list.
- Appendix C 13659, `UninitializedInputs`: §14.6 now cites Appendix C (F24).
- Appendix C 13735, `ReadSetMisuse` (§14.4): still stated nowhere in
  §14.4 (R14 leaves it to §14.9).
- §13.3 10283 and D-130 (log 4315, 4338) rely on "internal, never
  user-facing". The sentence is kept, plain.
- §8.6 3470–3473, §11.3 7203–7205 and the glossary 13995–13997 rely on
  §14.4 for service reads that want the contract speaking faces. This holds
  as R5's guidance.
- `#g-selector` (14577–14578) repeats "before any client policy applies".
  It is consistent with the kept clause (correction 2).
- D-414 Rejected (log 16522), "a resolver §14.4 keeps client-free", is now
  true of the text.

## Open questions

All four are ruled. R17: the recording-clear sentence is dropped, and §14.8
keeps it. R18: D-067's four bolds stand. R19: D-276 bullets 1–4 each take one
bold in §14.4, since a grep of the frozen spec finds them bold nowhere else.
The binding read (bullet 5) and wiring (bullet 7) stay plain. R20: the M5
merge stands. None remain open.
