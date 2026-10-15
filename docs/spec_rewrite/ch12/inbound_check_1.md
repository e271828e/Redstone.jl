# Chapter 12, half 1: inbound check

Rows: the 239 rows of `inbound.tsv` whose target is §12, §12.1, §12.2, §12.3
or §12.4. Every one of the five sections has entries in `inbound_scope.md`, so
every row was judged against the citing sentence. The four section numbers and
titles are unchanged in `chapter_new.md`. The full table is
`inbound_check_1.tsv`. Line numbers marked "new" are `chapter_new.md`'s.

## Counts

| verdict | rows |
|---|---|
| OK | 230 |
| RETARGET | 4 |
| COMPANION | 0 |
| MISSING | 5 |
| VAGUE | 0 |

| file | OK | RETARGET | MISSING |
|---|---|---|---|
| `spec.md` | 93 | 0 | 1 |
| `decisions.md` | 106 | 3 | 3 |
| `implementation.md` | 25 | 1 | 1 |
| `flight_case_studies.md` | 4 | 0 | 0 |
| `frame_walkthrough.md` | 1 | 0 | 0 |
| `inbound_periphery_walkthrough.md` | 1 | 0 | 0 |

Only one non-OK row comes from the rewrite: row 74 (R8's correction). The
other eight were already wrong at `17ad42d`, and survey 1's part D listed
each of them.

## Rows that are not OK

### Row 74, `spec.md` 12855 (Appendix B), §12.4: MISSING

The old §12.4 said a failed device is "dead from boundary zero". R8 corrected
that to "dead from the run's first frame top" (new 500–501), since a run need
not start at boundary zero. The citing sentence still has the old wording.
This is not a loss. The old text was wrong, and R8 fixed it.

- old: `name, and the device is dead from boundary zero ([§12.4][s12-4]). The`
- new: `name, and the device is dead from the run's first frame top ([§12.4][s12-4]). The`

### Row 121, `decisions.md` 3482 (D-109 Rationale), §12.4: MISSING

"The affine device is outside §12.4's join and abandonment" was not true at
`17ad42d` either. D-310 removed the calling-task device. D-109 is superseded →
D-310, so this Rationale is historical. No edit: the status line is enough.

### Row 122, `decisions.md` 3492 (D-109 Annotation), §12.4: RETARGET → §11.1

R5 removed §12.4's bold "Topology is derived after initialization" (old
9057–9060) and made §11.1 the home. The entry is superseded, so this edit is
optional.

- old: `outcomes**, not from the frozen roster alone. [§11.1][s11-1] and [§12.4][s12-4] carry the`
  `canonical statement, and the looser …`
- new: `outcomes**, not from the frozen roster alone. [§11.1][s11-1] carries the`
  `canonical statement, and the looser …`

### Row 131, `decisions.md` 4256 (D-132 Rationale), §12.4: MISSING

"Cannot repair §12.4(5)'s honest asymmetry (nothing can abandon the task
`run!` stands on)". Step (5) has had no asymmetry since D-310 (F3). The
spec's copy of this claim (old 9159–9161) was deleted under R10 F3, so the
old chapter stated it, but it was already wrong. `decisions_style.md` rule 10
repairs an older entry by annotation. Proposed annotation, at the end of
D-132's Rationale:

- old: (none)
- new: `Annotation (2026-10-15): since [D-310][d-310] no device runs on the
  calling task, so [§12.4][s12-4](5) has no asymmetry left, and the clause
  on "(5)'s honest asymmetry" above is historical.`

### Row 135, `decisions.md` 4316 (D-133 Position), §12.4: RETARGET → §12.4

The landing rule is in the paragraph after the chart (new 380–388), not in
step (1). That was also true of the old text.

- old: `ring, not a constant]. Finally `t_end`'s landing rule, stated once in [§12.4][s12-4](1):`
- new: `ring, not a constant]. Finally `t_end`'s landing rule, stated once in [§12.4][s12-4]:`

### Row 138, `decisions.md` 4321 (D-133 Spec), §12.4(1): RETARGET → §12.4

This is the same mistake as row 135. The field already lists plain §12.4, so
the `(1)` item should go.

- old: `[§12.2][s12-2], [§12.4][s12-4], [§12.4][s12-4](1), [§12.4][s12-4](5), [§12.6][s12-6],`
- new: `[§12.2][s12-2], [§12.4][s12-4], [§12.4][s12-4](5), [§12.6][s12-6],`

(Rows 136–139 are the field's four links in order: §12.2, §12.4, §12.4(1),
§12.4(5).)

### Row 158, `decisions.md` 6530 (D-175 Position), §12.4: MISSING

"The detach sitting in §12.4's shutdown tail" was not true at `17ad42d`
either. D-175 is superseded → D-310, and `gui = true` no longer exists. No
edit: the status line is enough.

### Row 224, `implementation.md` 762, §12.1: RETARGET → §12.6

The four-field `Simulation` is §12.6's (new 798, "`Simulation` is a mutable
struct of four fields"). §12.1 lists `Control`'s fields.

- old: `and the run, its model a `Model{Float64}` by type (§12.1, D-256, D-317).`
- new: `and the run, its model a `Model{Float64}` by type (§12.6, D-256, D-317).`

### Row 233, `implementation.md` 1260, §12.2: MISSING

§12.2 has never said "a deviceless loop never yields", in the old text or
the new. It guarantees a per-frame yield only with devices attached (new
133). A paced deviceless loop does yield, in its coarse `sleep`
(`src/control.jl` 186). The `yield()` in `src/sim.jl` 1424 runs only with a
non-empty roster. So the claim was wrong before the rewrite.

- old: `no frame ran, so an assertion on that writer names its field. A deviceless loop`
  `never yields (§12.2), so a test that spawns an advance and waits on it from its`
- new: `no frame ran, so an assertion on that writer names its field. §12.2 guarantees`
  `a per-frame yield only with devices attached, and an unpaced deviceless loop never`
  `yields, so a test that spawns an advance and waits on it from its`

## OK rows with a problem next to the citation (track 2)

In these rows the cited section still states what the citation needs. The
problem is elsewhere in the citing text. Part D lists most of them.

- Rows 22, 64 (`spec.md` 7312, 11010): part D listed "Pause is a
  control-plane state *inside* a run (§12.1)" as wrong before. F21's new
  sentence (new 67–69) now states it. Resolved; no edit.
- Rows 54, 91 (`spec.md` 10239, 14243): "a frame-top or wait unmask point"
  leaves out the pause block, which §12.4 names (new 589–590). Minor. Part D
  confirmed.
- Row 89 (`spec.md` 14177, glossary *control plane*): the glossary's field
  list lacks the sticky stopped status, which §12.1 now lists (F7, new 96–97).
- Rows 114, 141 (D-093 Rejected, D-134 Rationale): these cite §12.2's
  stall argument and §12.3's GUI read path. Both are kept verbatim under R2
  and escalated as E2. Part D confirmed.
- Row 126 (D-132 Position): `stop_on` is retired (D-316), and "GUI" means the
  parked GUI (D-310). "Resumable by the next `run!`" is E1. Part D confirmed.
- Row 152 (D-138 Rationale 4670–4672): "(§11.8, D-136)" backs a staleness
  claim that §11.8 does not make. §12.4 now states the claim, citing D-138
  (new 503–506). "Dead from boundary zero" also differs from R8's wording.
  Part D confirmed.
- Rows 153, 154 (D-138 Rationale 4674, 4683): "holding their initial
  values" and "boundary zero is published, the run ends `stopped` at `t₀`"
  are D-138's own claims. R8 corrected both in the spec: the values become
  "the values the run started with", and the run "ends `stopped` where it
  started", with no boundary zero published (new 512, 524–535). D-138 needs
  an annotation pointing at R8's reading.
- Row 193 (D-268 Annotation 11172): the annotation says "until the next
  `init!`". §12.4 now says "`init!`, `restore!` or `replay!`" (F22).
- Row 61 (`spec.md` 10518, §13.5): "GUI stop button" is §13.5's own
  wording. This is R2's analogue for chapter 13.
- Row 237 (`flight_case_studies.md` 408): the window is the parked GUI's
  (D-310). The tail steps it lists still hold. Part D confirmed.
- Row 6 (`spec.md` 5478, Part III roadmap): it omits §12.5, as it did
  before. R1 leaves it to the front-matter rewrite.
