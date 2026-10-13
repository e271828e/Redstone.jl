# Unit C (§11.3): rulings, citations and open questions

Rulings applied: R4 (the harness writer stages from any task), R5 (claim
mechanism kept whole here; `EmptyGreedyClaim`'s diagnostic-cell clause to
§11.6; the orphan label to §11.7), R6 (old 7266–7269 to "nothing republishes
it", D-087), R10 (F9, F15, F18, F20, F22, F23, plus the second "(below)" at
old 7272, which also means §11.4), R12 (`AttachUnknownFace`, `NotAttached`),
R13 (the drain's gloss), R15 (F19 held), R18 (the `stage!` block), R23 (the
standard GUI binding's claim, §11.6). Survey 1 moves M7 (the layout paragraph
after the harness writer) and M8 (the edge case shrunk to one sentence with
its §11.4 pointer). R11's `T16000M` no longer applies: under R5 the label
that named it lives in §11.7.

R18 check: `src/sim.jl` 1809 defines `function stage!(sim::Simulation,
writes::Pair...)`, and its docstring (1792) shows `stage!(sim, "face" =>
value, ...)`. The block matches, so it was added.

Glossary links: every link at a term's first use in the section carries a
5–10 word gloss from its glossary entry, declared in `added`. Component and
face, and the trace, are glossed in a following sentence, since their first
use sits in a sentence that already carries a parenthetical. New links:
frame, binding (at its true first use, "chooses per binding") and derived
liveness. The freeze's link moved to its first use (old 7176). *Device*
is now linked in the context paragraph, before the roster gloss uses it.

Side effect outside the unit: `scratch_survey/entry.sh`, as the brief
directs, writes `scratch_survey/entries/D-nnn.md` for each entry printed.

Fixes after the verifier: "constants within a frame" is its own clause; the
exclusivity bold now says "at most one writer"; `device` is linked and glossed
at its first use in the context paragraph; the one-mechanism sentence lists
shape, shim, merge and scatter compilation (§11.4) and cites §11.5 at the
trace again, as D-174's Position and §11.6's text list them (from G2's
verifier, R5's claim-mechanism home).

## Corrections proposed

- Old 7216–7219, "drain order a diagnostic fact (below)": applied after the
  verifier, as an extension of R10's F9. It now reads "([§11.4][s11-4])".
- Old 7123–7124 names `input_wires` and `u_types`; D-208's Position (log
  7699–7701) says `input_connections` and `input_types`. `src/` uses
  `input_wires` and `u_types`, so the spec is right and D-208's text is
  stale (track 2).
- Old 7270, "The trace still tags entries": bare *entry*. Reworded to "tags
  each record" (a trace record, the retained form of a drained batch, carries
  the device id). Old 7284, "as long as the entry", became "as long as its
  roster entry". Both are reserved-word fixes, not content changes.
- §12.2 heartbeat phrasing "the [§12.2][s12-2] heartbeat" kept from the old
  text, though it reads close to a possessive citation.

## Citations added or replaced

- D-208, root-input definition: "the model's root inputs are the root's input
  faces uniformly". Plain here: §8 bolds the same ruling.
- D-031, root inputs as the periphery's only write, and "nothing else
  changes": "root-input staging + control commands, nothing else".
- D-129, the write side speaks face names: "the write side speaks contract
  exclusively ([§11.3], unchanged), the read side speaks structure in
  inspection reads and contract wherever meaning must outlive the build".
- D-044 at the exclusivity bold ("one writer per root slot at a time"), the
  write-surface bold ("an entry reaches a slot iff the face is inside the
  writer's surface"), opportunistic writing ("autonomous opportunistic writing
  does not exist") and at "Exclusivity replaces any cross-device conflict
  policy". Only D-044's clauses that stand are cited;
  its derived-interactive-surface half is superseded by D-174.
- D-174 at `ClaimedFaceEntry` (Rationale: "`ClaimedFaceEntry` narrowed to
  it"), replacing D-044, whose clause sits in its superseded half.
- D-174 at the claim sources: "a binding's claim set has two *sources* and one
  meaning — returned … or computed"; at the one mechanism: "everything
  downstream of claim acquisition is identical for both".
- D-192 at "Attaching the greedy claimant last is the idiom": "Greedy-last
  attach is the idiom … attachment order is decisive by design" (Rationale).
- D-096 at the harness writer: "`stage!(sim, "face" => value, ...)` =
  task-free staging". Its Position also says "from the calling task" and
  "into the interactive writer", which D-200 and D-174 overtook.
- D-200 (R4): "written into its cell on whichever task stages"; Rationale "a
  harness `stage!` runs on whatever task calls it".
- D-047 at the initial-values bold: Rejected "services own initialization".
- D-149 at totality: "Slot totality is checked at every application that
  establishes a complete world over virgin stores — `init!`, trim setup, trim
  commit". Plain here: §14 bolds it.
- D-106 at the freeze bold ("`attach!`/`detach!` are stopped-sim operations …
  so the roster and the partition … are static, inspectable facts of each
  run"), at the partition sentence, at "Device death does not detach"
  (Rationale "device death mid-run is not detach"), and at the mid-run reader
  (Rationale "Guarded addition on record: mid-run attach for pure readers").
- D-108 at `ServiceLifecycle`: "one kind `ServiceLifecycle` … shared with
  `attach!`/`detach!`-while-running" (Rationale).
- D-087 (R6): Position "the roster (entries, claims, order) is a plain
  immutable value the loop reads once at `run!` — no republication, no
  per-frame acquire-load, no sequence numbers"; its Rejected list carries the
  atomic republished roster and next-frame attachment. At the trace tags:
  Rationale "trace device tags are stable ids, never roster indices — ids read
  across runs".
- D-216 (R12): "`AttachUnknownFace` … a refusal that precedes admission".
- D-215 (R12): "`NotAttached` (`detach!`'s mirror of `AlreadyAttached`)".
- Replaced: "(below)" → "([§11.4][s11-4])" twice (old 7237, 7272); "[§11.7]"
  → "[§11.6][s11-6]" at the greedy claim's binding (R23).
- Removed with the moved clause (R5): §11.8 and D-250 at `EmptyGreedyClaim`;
  the diagnostic-cell link goes with them.

## Rationale-only rulings

- D-200, Rationale, log 7364: the harness `stage!` runs on any task (R4).
- D-174, Rationale, log 6374–6378: the harness writer's derived surface,
  recomputed at roster changes. Log 6383–6385: the harness cell drains last
  as plain convention (bold here).
- D-174, Rationale, log 6378–6380: `ClaimedFaceEntry` narrowed to the
  harness writer.
- D-192, Rationale, log 7058–7060: greedy-last idiom.
- D-047, Rejected, log 1513–1514: services own root-input initial values
  (bold here).
- D-106, Rationale, log 3276–3277 (death is not detach, bold here) and
  3283–3287 (mid-run readers).
- D-108, Rationale, log 3357–3360: `ServiceLifecycle` for the roster
  operations.
- D-087, Rationale, log 2709–2711: stable ids as trace tags.

## Bold on the same entry elsewhere

None duplicates a ruling bold here. Bolds citing the same entries for other
rulings: B ("The captured table also includes the root inputs", D-047's
snapshot clause), H ("Widgets stage on interaction events only", D-047's
Position), D ("The harness cell gets the same treatment", D-174), G2 ("A
second greedy attach stakes the empty remainder" and "Several interactive
front ends may be rostered at once", D-174's Rationale). Frozen chapters
5–10 and 12–14 bold D-208, D-129 and D-149's rulings, so those stay plain
here; their D-261 bolds are other bullets.

## Inbound citations affected

- §12.6 9175 ("with the calling task as writer", cites §11.3), Appendix B
  12795–12796 and glossary 14019, 14023 ("the calling task"): now contradict
  §11.3 after R4 (track 2).
- Appendix C `EmptyGreedyClaim` (13127, cites §11.3 and §11.6): holds; §11.3
  still names the kind at its condition, §11.6 holds the cell.
- Appendix C `AttachUnknownFace` (13120) and `NotAttached` (13245): now
  stated in §11.3. D-216 and D-215's Spec fields would gain §11.3.
- Glossary *orphaned claims* (14046, "renders the fact in the widget's source
  label", cites §11.3): the label now lives in §11.7; holds through the
  pointer.
- Glossary *greedy claim* (14012, "the shipped GUI binding is the shipped
  instance"): changes at landing under R23.
- D-134 Rejected (log 4333) quotes the old "resident of the second class"
  wording, already stale.

## Open questions

- Rows 145–149 (device identity by instance, the stable id monotonic and
  never reused and living as long as its roster entry, the two-part admission
  order, the rebinding spelling, `ClaimConflict` naming two distinct devices)
  rest only on superseded D-109. Stated plain, cited nothing. They owe a
  Position.
- F19 (R15): "printable before the run starts" held as written. No printer of
  the roster or the surface partition exists in `src/`; the owner should say
  whether it promises a shipped printer or a printable value.
- "Exclusivity holds because a second live writer …" and "A claim is what a
  device *may* write, not what it will" have no entry stating them in a
  Position (survey rows 104, 105); left plain.
