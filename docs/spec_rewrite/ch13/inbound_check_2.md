# Inbound check, half 2 (§13.5 to §13.8)

The rows are the 291 rows of `inbound.tsv` whose target is §13.5, §13.6, §13.7
or §13.8, judged against `chapter_new.md` and `inbound_scope.md`. Every one of
the four sections has an entry in `inbound_scope.md`, so each row was judged
against its listed claims. The four headings are unchanged. Line numbers are
`1fee0fc`'s. `spec.md` and `decisions.md` were read as the frozen copies, and
the other files from the working tree, which matches `1fee0fc` under
`docs/design/`. Row numbers (#n) count the half-2 rows in `inbound.tsv` order.
Quoted old and new text joins wrapped lines with one space.

## Counts

| verdict | rows |
|---|---|
| OK | 264 |
| RETARGET | 6 |
| COMPANION | 3 |
| MISSING | 18 |
| VAGUE | 0 |

| file | OK | RETARGET | COMPANION | MISSING |
|---|---|---|---|---|
| `spec.md` | 73 | 6 | 0 | 4 |
| `decisions.md` | 129 | 0 | 3 | 12 |
| `implementation.md` | 32 | 0 | 0 | 0 |
| companions | 27 | 0 | 0 | 1 |
| `extensions.md` | 2 | 0 | 0 | 1 |
| `pending.md` | 1 | 0 | 0 | 0 |

By target, §13.5 has 125 OK, 6 RETARGET and 7 MISSING. §13.6 has 20 OK.
§13.7 has 87 OK, 3 COMPANION and 11 MISSING. §13.8 has 32 OK.

All 18 MISSING rows were already wrong before the rewrite. **The rewrite lost
nothing an inbound row relies on.** Eight of the 18 are live text (4 in
`spec.md`, 2 in D-071, 1 each in `extensions.md` and `migration_outline.md`).
The other ten are log text from its own time. Four of those are annotated
already, and six want a track 2 annotation.

Every row in survey 2's part D list "Citations already wrong before the
rewrite" that has a §13.N token is confirmed MISSING here. Two of that list's
items have no §13.N token and so no row: D-062 Position (log 1974–1976) and
D-120 Position (log 3912). They still stand as the survey describes them.

## RETARGET

All six follow from R4. §12.6 holds the per-advance declaration, the keywords
and the lifetime. §13.5 keeps one pointer sentence to them (new 712–720).

- **#32, spec 7757–7758 (§11.5).** It relies on the keywords.
  - old: ``` `t_end` and `ignore_stop_requests` are keywords of each advance ([§13.5][s13-5], [D-316][d-316]). ```
  - new: ``` `t_end` and `ignore_stop_requests` are keywords of each advance ([§12.6][s12-6], [D-316][d-316]). ```
- **#37, spec 8655 (§12.1).** It relies on the declaration (C-074, R4).
  - old: `policy is what the caller declares for one advance ([§13.5][s13-5]). The stop`
  - new: `policy is what the caller declares for one advance ([§12.6][s12-6]). The stop`
- **#52, spec 9849 (§12.7's table).** It relies on the declaration per call.
  - old: ``each `replay!` call declares its own ([§13.5][s13-5])``
  - new: ``each `replay!` call declares its own ([§12.6][s12-6])``
- **#63, spec 12875–12876 (Appendix B).** It relies on the keywords.
  - old: ``fix) binds no stop policy. `t_end` and `ignore_stop_requests` are keywords of each advance ([§13.5][s13-5]).``
  - new: ``fix) binds no stop policy. `t_end` and `ignore_stop_requests` are keywords of each advance ([§12.6][s12-6]).``
- **#68, spec 13140 (Appendix B).** "nothing else keeps one" is the lifetime,
  which R4 relocated to §12.6 (C-042). §13.5 still says the record carries the
  policy (new 718–720, 801–802).
  - old: `ended the run, and nothing else keeps one ([§13.5][s13-5], [D-260][d-260]).`
  - new: `ended the run, and nothing else keeps one ([§12.6][s12-6], [§13.5][s13-5], [D-260][d-260]).`
- **#77, spec 14485 (glossary, `StopPolicy`).** The entry's one citation set
  covers its whole text. §13.5 keeps the mask, the validation and the `t*` hit.
  "ControlRequestedStop is outside it" is §12.1's (spec 8654), and the old §13.5
  never said it. "afterwards only the termination record keeps one" is
  §12.6's (R4).
  - old: `declares and the stop word is what anyone can issue ([§13.5][s13-5],`
  - new: `declares and the stop word is what anyone can issue ([§12.1][s12-1], [§12.6][s12-6], [§13.5][s13-5],`

## COMPANION

- **#224, #225, #226: the Spec fields of D-383, D-384 and D-385 (log 15430,
  15514, 15556).** Each rules inventory content: the LQR tracker, the
  `saturated` code and the controller axes. That content lives in
  `companions/library_inventory.md` and `lqr_tracker.md`. §13.7 only points
  there (new 1004–1005, 1013–1014), as the old text did. No edit is needed. If
  the orchestrator wants Spec fields to name only sections that state the
  ruling, these become track 2 items.

## MISSING, live text

All eight were wrong before the rewrite. The chapter never stated these
claims, old or new.

- **#25, spec 5385 (§9.7).** §13.5 says nothing of the measurement seam
  (survey 2 part D).
  - old: `The seam is diagnostic only ([§13.5][s13-5]), and it makes one promise.`
  - new: `The seam is diagnostic only, and it makes one promise.`
- **#33, spec 7766 (§11.5).** Neither the old nor the new §13.5 mentions run
  metadata. The glossary defines it (spec 14551).
  - old: ``the artifact's [run metadata](#g-run-metadata) names, its `Deployment` and `t₀` ([§13.5][s13-5], [Appendix B][sB]).``
  - new: ``the artifact's [run metadata](#g-run-metadata) names, its `Deployment` and `t₀` ([Appendix B][sB]).``
- **#54, spec 11338 (§14.2).** §13.7's library is `Redstone.Blocks`, which
  holds components only. `set`, `at` and `combine` are §14's. This is a RULING,
  since it changes a claim. The proposal keeps the no-privileges point, which
  §13.7 does state for its blocks (new 1033–1034).
  - old: ``machine-checked ([D-065][d-065]). `set`/`at`/`combine` are [§13.7][s13-7] standard-library material, ordinary artifacts with no privileges.``
  - new: ``machine-checked ([D-065][d-065]). `set`/`at`/`combine` are ordinary artifacts with no privileges, as [§13.7][s13-7]'s library blocks are ordinary components.``
- **#57, spec 12351 (§14.9).** §13.7's library holds components, not helpers.
  The text agrees with D-071's Position but not with §13.7. This is a RULING,
  and it pairs with #93 and #94.
  - old: ``a `product(p₁ => "lead", p₂ => "wing")` helper belongs in the [§13.7][s13-7] library.``
  - new: ``a `product(p₁ => "lead", p₂ => "wing")` helper belongs in the framework ([D-071][d-071]).``
- **#93, log 2274 (D-071 Position).** "A `product()` helper is recorded for
  the §13.7 library, unbuilt". §13.7 records no such helper, and §14.9 does.
  Track 2 annotation: "The helper is recorded in [§14.9][s14-9]. §13.7's
  library holds components only."
- **#94, log 2276 (D-071 Spec).** §13.7 is the entry's only Spec section, yet
  nothing of D-071 lives there. Track 2: `[§13.7][s13-7]` becomes
  `[§14.9][s14-9]`, plus whatever trim sections the entry rules.
- **#229, `extensions.md` 334.** §13.7 has no migration. The parametric
  spelling it once carried fell with D-263 (D-311 bullet 3).
  - old: `which library structs get the parametric spelling in the [§13.7][s13-7] migration — whether`
  - new: `which library structs get the parametric spelling in the migration — whether`
- **#285, `companions/migration_outline.md` 80.** D-311 does not admit `Not`
  ("a one-input gate consolidates nothing"). §13.7 lists `Or{N}` and `And{N}`
  only. This is a RULING on the replacement wording. The companion needs a
  `[d-311]` link definition.
  - old: `Falling-edge consumers wire a NOT gate (the Bool gates, [§13.7][s13-7]).`
  - new: ``Falling-edge consumers negate the `Bool` in their own stage, since the library admits no `Not` ([D-311][d-311]).``

## MISSING, log text from its time

These are wrong today, but they record their own time. The log is
append-only, so none takes an edit in the chapter.

- Annotated already, so no edit:
  - **#95**, log 2332 (D-073 Position), `SumJunction`'s unparametrized
    constructor: annotated at 2338.
  - **#156**, log 7793 (D-203 Rejected), "the effective policy already lives
    in the run metadata": annotated at 7771.
  - **#193**, log 11844 (D-274 Position), checkpoint as a §13.7 service:
    annotated at 11919.
  - **#198**, log 12467 (D-285 Rationale), `stop_on`: annotated at 12474.
- Superseded, so no edit:
  - **#100** and **#101**, log 2898 and 2901, D-091's Position and Spec. The
    entry is superseded by D-255.
- Track 2 annotations wanted:
  - **#130**, log 5050 (D-141 Rationale): "§13.7's grow-by-migration-demand
    rule". D-313 retired that rule (survey 2 part D).
  - **#131**, log 5082 (D-141 Rejected): "§13.7's Bool gates covering
    falling-edge consumers". D-311 rejects `Not`, so `Or` and `And` cannot
    cover them. This is the same fact as #285.
  - **#135**, log 5132 (D-142 Rationale): "a published `Bool` output face plus
    `stop_on`, §13.5's existing machinery". Stop requests replaced `stop_on`
    (D-316). D-285 has the same sentence and annotates it at 12474. D-142 does
    not.
  - **#139**, log 5212 (D-143 Rationale): "§13.7's strictly from demonstrated
    need charter". D-313 retired the charter, and the rewrite applied F60, which
    cut its last trace from §13.7.

## OK rows with a note for landing

- **#29, spec 7122 (§11.2).** The row holds, because §13.5 new 880–882 keeps
  "Their reads are inspection" under R29. The same paragraph ends "Every cell
  is reachable, because the table is public throughout" (spec 7125). That
  sentence contradicts R2 for a binding, which attach refuses past a generic
  seam. The §11.2 landing edit (old 7108–7109) should extend to it.
- **#61, spec 12747 (Appendix A, "The two observation sides").** The row
  holds, because §13.5 865–866 still says inspection sees every public cell.
  But "It sees everything", beside "Bind faces in anything meant to outlive the
  current build", reads as a binding's reach, which R2 narrows. A cite of
  [§13.3][s13-3] could land with §11.2's edit.
- **#183, log 10526 (D-260 Spec).** §13.5 802 still states D-260's rule, "the
  termination record is the policy's one lasting home", but it cites D-255
  there. Old 591 cited D-260 in the clause that R4 relocated. The fix is a
  track 2 item, or a ruled cite of D-260 at new 802.
- **#18, #148, #230 (spec 3326; log 7017; `extensions.md` 346).** All three
  put `Group` in "§13.7's starting inventory". §13.7 1011–1013 lists the
  starting inventory without `Group`, while 1022 and 1027 put it in the library
  as the one member admitted by persona. The mismatch predates the rewrite
  (old 866, 887, 892).
- **#103, #227 (log 3089, D-096 Rejected; log 15691, D-390 Position).** Both
  speak of "the cost §13.5 rejects". §13.5 lists the rejection of predicate
  closures, but the cost is in D-060's Rejected list. This predates the
  rewrite.
- **#80, #259 (glossary 14698; `implementation.md` 933).** Both say "local"
  for the mode F63 renames "sampled". §13.8 1292 keeps the gloss that ties the
  two names. R28's glossary entry is track 2.
- **#66 (spec 13129, Appendix B's `t_end` row).** The row holds, because
  §13.5 727–728 keeps the validation. It could also cite §12.6 for "declared
  for this advance".
