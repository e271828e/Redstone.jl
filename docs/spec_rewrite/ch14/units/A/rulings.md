# Unit A rulings: chapter 14 heading, §14.1, §14.2, §14.3

## Corrections proposed

All three are ruled as R27 and applied in new.md.

1. **§9.6 previews two services, not all of them.** Old 11269, kept as
   "[§9.6][s9-6] previewed the services as clients of an activation".
   §9.6 (frozen spec 5100–5131) opens "Trim and linearization are
   stopped-sim services, and each is a client of an activation", and its
   bullets take trim, the generic service loop and linearization. Now that
   the next sentence names five services, "the services" reads as all five.
   Proposed: "[§9.6][s9-6] previewed trim and linearization as clients of an
   [activation](#g-activation) (the build's typed products at a given scalar
   type)."
2. **The lifecycle table keeps an em dash.** Old 11300, last cell: "inherits
   `init!`'s legality — legal wherever `init!` is". `spec_style.md` bars em
   dashes, and the brief removes the converter table's but says nothing of
   this one, so the table is carried verbatim. Proposed: "inherits `init!`'s
   legality, legal wherever `init!` is".
3. **Row 105's plan (F16).** Old 11514–11516, kept as written: "A valid list
   compiles to a plan. Per leaf, the plan holds a lens (…), a destination
   offset, and a converter." It describes the specialized plan only; the
   dynamic walk's `ConditionPlan` holds converted values, and the `s`/`m`
   stores take one whole value each (`src/conditions.jl` 270–275, 656–664).
   The brief's amended F16 wording is this sentence's rewrite but is
   assigned to unit B, whose draft §14.4 already states it ("A valid list of
   condition entries compiles two ways … Its plan holds, per leaf, a lens …
   a destination and a converter … from a plan that holds the converted
   values themselves"). Proposed for §14.3, so the two sections do not
   double: "A valid list of condition entries compiles two ways
   ([§14.4][s14-4]). The specialized `apply!`'s plan holds, per leaf, a
   [lens](#g-lens) (the compiled navigation step of a condition entry), a
   destination and a converter." See Open questions, Q1.

## Citations added or replaced

- [D-108][d-108] at "Every service requires a non-running simulation":
  Position, "every stopped-sim service requires a non-running simulation,
  pause included".
- [D-108][d-108] at "Within the stopped-sim states, legality follows each
  service's inputs": Position, "within the stopped states legality follows
  each service's inputs".
- [D-108][d-108] at "A violation is `ServiceLifecycle`": Rationale, "one kind
  `ServiceLifecycle` (operation, current status, legal statuses) shared with
  `attach!`/`detach!`-while-running".
- [§12.6][s12-6] replaces [D-059][d-059] at the `errored` sentence (R2):
  §12.6 bolds "`errored` is terminal" on D-059 (9429). D-108 stays.
- [D-232][d-232] at the post-mortem read: Position, "The stopped-sim reads
  stay admitted there: post-mortem inspection is reading."
- [D-108][d-108], [D-274][d-274] at "It may not become a checkpoint": D-108
  Rationale, "post-mortem stores/log/trace stay readable as diagnostics,
  never as condition values"; D-274 bullet 2, "`checkpoint(sim)` is a
  stopped-sim service …: legal in `initialized` and `stopped`".
- [§12.6][s12-6], [Appendix C][sC] at the added `CheckpointMidFrame`
  sentence: §12.6 9540–9545, "It is refused wherever the executor is not at
  the rest a published frame top leaves (`CheckpointMidFrame`, …). That is
  after a `t*` stop … and after a frame abandoned unpublished".
- [D-063][d-063] at "It never specifies outputs": Position, "never outputs or
  workspace".
- [D-306][d-306] at the workspace sentence: bullet 1, "A workspace is never a
  condition target."
- [D-063][d-063] at "The overlay base is always the declared defaults":
  Position, "sparse overlays … on the declared `init_*` defaults".
- [Appendix C][sC] at the added `ConditionResolution` sentences (§14.1,
  §14.2, §14.3), the `ConditionNodeMisuse` reasons (§14.2), and
  `DuplicateConditionLeaf` (§14.2): the kinds' rows, 13637, 13644, 13647.
- [D-409][d-409] at "Addressing conditions by path does not reopen …" (R4):
  Position, "Observation by path is rejected."
- [D-064][d-064] at the pre-sweep sentence: Position, "pre-sweep doctrine: a
  condition value needing swept outputs is caller-computable (…) or an
  equilibrium constraint for the trim service".
- [D-139][d-139] at "'Caller-computable' reaches past closed-form knowledge
  to environment queries" and at "the second escape already covers the
  case": Rationale, "§14.1's caller-computable escape is extended to cover
  environment queries" and "the environment-free fallback through the
  existing second escape".
- [D-064][d-064] at "What preserves the locality is an idiom, not schema":
  Position, "Per-component init knowledge = fragment-returning user functions
  dispatched on component types, composed by pull".
- [D-405][d-405] at the condition method: bullet 2, "A method of the
  `condition` generic is a condition method."
- [D-316][d-316] at the foreign `condition`: Rationale, "`condition` stays
  outside the family because a foreign `condition` fails loudly, as a
  `MethodError` at the owner's pull."
- [D-065][d-065] at "Resolution walks the export chain to the root input":
  Position, "slots resolve through export chains (unexported = unwritable,
  init included)".
- [D-207][d-207] at the one-level routing sentence: bullet 2, "The face graph
  is therefore total — every signal crossing an assembly boundary bears a
  declared face there — and the `Build` retains it".
- [D-065][d-065] at "Composition builds an inert, lazy fragment tree":
  Position, "Fragments form a lazy inert tree (… `at`/`merge` store, never
  apply — stack-only rebuild per iteration)".
- [D-278][d-278] at "`at` refuses an empty prefix when it is called":
  Position, "`at` refuses an empty prefix when it is called, at the root as
  below it." It was cited at the paragraph's last sentence.
- [D-065][d-065] at the locality law's headline: Position, "locality law =
  §6.1's, third instance (own fields, declared children, own faces …)".
- [D-414][d-414] at the family-dispatch sentence: bullet 4, "An author
  scopes a fragment's or a problem's applicability by dispatch on the
  holding's type parameter".
- [D-065][d-065] at "Collisions are errors at resolution": Position,
  "duplicate leaf = error with both origins".
- [D-113][d-113] at "It is `ConditionNodeMisuse`": bullet 4,
  "`ConditionNodeMisuse` for §14.2's mixed-`merge` error method: offending
  argument type, node kinds in hand; raised at composition time …".
- [D-065][d-065] at "Flattening is the only place path strings are ever
  concatenated": Position, "all flattening/validation/addressing at
  resolution against the `Build`".
- [D-065][d-065], [D-148][d-148] at the converter rule: D-148 Position, "The
  condition plan's baked converter is selected per leaf, keyed by that
  leaf's type in the resolved condition shape"; D-065 Position, "converters
  and `m`/`z` overlay bases baked at compile".
- [D-148][d-148] at "They never run on state views": Rationale, "converters
  still run only on the write paths, never on state views".
- [D-065][d-065] at overlay partiality: Position, "converters and `m`/`z`
  overlay bases baked at compile".
- [§14.1][s14-1] to [§14.10][s14-10] in the roadmap sentence (R1).

## Rationale-only rulings

- D-108, Rationale (log 3564–3571): `ServiceLifecycle`'s payload and its
  sharing with `attach!`/`detach!`, cited at "A violation is
  `ServiceLifecycle`". `MissingInit`'s distinctness is D-108's Rejected list
  (3574–3576), adjacent to the same citation.
- D-139, Rationale (log 4950–4960): the caller-computable escape extended to
  environment queries, bold at its headline, and the environment-free
  fallback. D-139's Position rules the value-level constructor only.
- D-316, Rationale (log 13997–13999): a foreign `condition` fails loudly, so
  `condition` stays outside the declaration family.
- D-148, Rationale (log 5596–5611): converters never on state views. Its
  "shape facts" reason (old 11522–11524) and the untouched exact-match
  doctrine (old 11550–11551) sit next to the D-148 citations.

## Bold on the same entry elsewhere

No ruling is bold in two places. Checked with `units/A/boldscan.py` against
the frozen spec and the sibling drafts.

- D-059: §12.6 bolds "`errored` is terminal" (9429). The old bold here
  (11310) goes plain under R2.
- D-319: §12.6 bolds "a `Checkpoint` is the `Model`'s state beside the run's
  cursor" (9532), the Position's first sentence. Here the bold is its
  second, "`checkpoint`, `restore!`, `trim!` and `linearize` are doors of the
  `Model`", as "Each row's service also has a form on a `Model`". Unit H's
  draft bolds D-319's `linearize` bullet, a third ruling.
- D-139: §8.2 bolds its Position (2939) and unit G's draft bolds "A problem
  never authors the environment" (Rationale). Here the bold is the
  Rationale's caller-computable extension, a third ruling.
- D-318, D-207, D-414, D-274, D-253 and D-364 are bold elsewhere (§9.2;
  §6.1 and §9.2; §13.3; §11.5, §12.7 and §13.4; §9.1 and §9.2; §14.9) and
  stay plain here.
- D-113: Appendix C's bolds near its citations are kind labels; bullet 4 is
  bold only here.

Rulings at home here that stay plain, so a reviewer can rule otherwise: D-207
bullet 2 (the total face graph, per-level `at` addressing), stated twice in
§14.2 and bold in neither; D-414 bullet 4 (the locality law as guidance),
spread over four sentences of §14.2 with no headline clause; D-405's Position
(`set` as the leaf constructor) and bullet 2 (the condition method), naming
rulings; D-273's second sentence (the state past `t₀` is a checkpoint), whose
§14.1 sentence cites D-274, the checkpoint's own entry. D-063's first
ruling is bold at the overlay base, not at the earlier sentences on what a
condition may specify: the base is what its Rejected list decides against
the current-stores base, and §14.3 calls it "the overlay-base rule". Its second ruling, "never outputs or workspace", a separate
semicolon clause of the Position, is bold once at "It never specifies
outputs"; the workspace half cites D-306 plain.

## Inbound citations affected

None breaks. Every move stays inside its section.

- spec 2312–2313 (§8.2), "§14.2's shipped condition uses" `ω_rated`: holds;
  the block keeps `eng.ω_rated`.
- spec 1573 (§6.1), the `u` export chain "has a name to resolve through
  (§14.2)": holds; M2 moves the sentence within §14.2.
- spec 1550 (§6.1), 10278–10279 (§13.3), the locality law as guidance:
  holds.
- spec 10251 (§13.3), absolute paths as a compiled derivative: holds.
- spec 10757–10762 (§13.5), "conditions already address state by path
  (§14.1)": holds, and §14.1's paragraph now cites D-409 as §13.5 does.
- spec 13597, 13707 (Appendix C, `ServiceLifecycle` and `CheckpointMidFrame`
  cited to bare §14): the lifecycle block now names both, under `####
  Lifecycle preconditions`.
- spec 13644 (Appendix C, `DuplicateConditionLeaf`, "the leaf is `(path,
  store, field)`"): §14.3 now says a `u` payload's leaf is its root input
  (F11); the row follows at landing, as the brief lists.
- spec 13647 (Appendix C, `ConditionNodeMisuse`): §14.2 now names the
  `:set_payload` reason (F8); the row follows at landing.
- spec 13637 (Appendix C, `ConditionResolution`, cited to §14.2 and §14.3):
  §14.1 now names the kind too, for outputs and workspace. The row may add
  §14.1.
- spec 14779–14780 (glossary `#g-service-lifecycle`, "all four services"):
  the opening names five; the brief lists it for landing (R1).

## Rulings after verification

- R35: §14.2's construction clause in the `assign!` sentence is scoped to
  literal prefixes.
- R36: F8's sentence adds "and `override` builds a fourth kind
  ([§14.6][s14-6])".
- R37: §14.3 states both plans' contents, the `lens` gloss included.
- Verifier fixes: the D-316 "because" restored; D-108 added beside D-274;
  the D-064 citation at "Delegation runs by dispatch" dropped; the quoted
  message introduced by "It reads".

## Open questions

- Q1. F16 and row 105: ruled as R27; §14.3 now carries the pointer form.
