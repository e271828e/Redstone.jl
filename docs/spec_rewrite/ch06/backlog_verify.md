# Chapter 6 track 2: cold verification — 2026-10-12

Scope: `git diff HEAD` of `decisions.md`, `spec.md` and
`companions/inbound_periphery_walkthrough.md`, against `backlog_applied.md`,
recipe step 8 and lesson 17, `decisions_style.md` and `rulings_batch.md`
"Track 2". Nothing under `ch05/` was read or touched.

Verdict: the edits are sound. No hunk claims a ruling without a recorded
source. Two wording problems (P1, P2) and one weak citation (P3) need a
fix or an owner's nod. Notes N1–N6 need no action.

## 1. New entries

### D-321

- Bullet 1, parallel routes. Source: D-207 Rationale, "parallel routes
  proliferating through several boundaries are the signal to gather them
  into a custom type". Same strength. "A component of their own" replaces
  "a custom type". D-207's Rejected list endorses bundling for "signal
  highways", so "custom type" could mean a bundled struct. But commit
  d7144b8 wrote both D-207's phrase and the spec's "a component of their
  own" together, so the spec phrase is the author's own reading. Sound.
- Bullet 2, pin chain. Source: D-264 Rationale, "a consumer that re-emits a
  frozen handle under an unpinned output hits the store's identity rule, so
  a handle's pin is a property of its chain, and every component that
  forwards it pins that output too". Same strength and scope. Sound.
- Bullet 3, sentence 1 (timing). Sources: D-263 Rationale, "an input pin is
  a wire check at the first nominal build only when written", and D-236
  Rationale, "the input-side forgotten `T` fails at the first nominal build,
  at the wire". Both are live. They state it as unconditionally as the
  bullet does, so F13's unstated walking-producer condition comes over
  unchanged. Sound.
- Bullet 3, sentence 2 (the reason, "an input has a build-time counterparty
  and an output has none"). See the ruling below.

**The counterparty hazard.** No live entry states the reason in words. It
appears only in superseded D-167's Rationale ("inputs have a build-time
counterparty, outputs don't"). Live entries record the mechanism behind
it. D-236 makes the input side a wire relation checked in the structure
step against the producer's declaration. D-263 states both halves: an
input pin is a wire check at the first nominal build, and an output built
from frozen data is refused at the first `Dual` activation. D-236 also
invokes D-167's timing as a live promise. D-263's only Rejected item
against D-167 is the mandated two-argument forms. So the reason was
recorded, never retracted, and follows from what the live entries state.
It is an explanation, not a new design ruling, so lesson 17 does not send
it to the owner. Restating it is sound.

Two defects in how D-321 grounds it:

- **P1. D-321 Rationale, the mapping sentence.** Current: "The forgotten
  `T` of D-236's Rationale is today's pin at a promoting entry, since
  D-167's annotation makes `Pinned{P}` the spelling of "demands frozen"."
  D-263's Rationale says "The forgotten-`T` classes vanish rather than
  move", and it names a *forgotten* pin as the class that replaces them. The
  sentence's "is" contradicts that. It is also unnecessary, because D-263's
  "an input pin is a wire check at the first nominal build only when
  written" carries the timing directly. Fix: delete the sentence.
- **P2. D-321 Rationale, the last sentence.** Current: "D-263 supersedes
  D-167, and D-167's annotation keeps its walk clause." The annotation lists
  what stands: the permissive reading, the walk clause, its tier scope and
  the root-slot rules. The failure asymmetry is not on that list. Fix:
  "D-263's rejection of D-167 reaches only the mandated forms, and D-263's
  Rationale restates both halves of the asymmetry."

Optional, not a defect. The reason sentence is reasoning, not a ruling.
`decisions_style.md` puts reasoning in Rationale. D-322's and D-323's
bullets carry reasons the same way, matching their spec sentences, so I
leave it.

### D-322

- Bullet 1. Source: D-043 Rejected, "*Auto-bubbling:* forgotten wire
  silently promoted to a live root slot". D-206 renamed "root slot" to "root
  input". Same strength. Sound.
- Bullet 2. Source: D-048 Rejected, "*Single-pass tree walk with per-level
  validation:* obligation/two-producers undecidable below the root".
  "Obligation" is the unconnected-input check (§6.1's "obligation chain").
  "Whole-tree properties" is the spec's phrase for "undecidable below the
  root". Sound.
- N1. The Rationale says "structure step" for D-048's Stratum A without
  citing D-259. Optional: add "(D-259)".

### D-323

- Bullet 1. Sources: D-037 Rejected bullet 1, "canonical-fold,
  multi-connection legality and identity-element machinery all retired",
  and D-143 Rejected bullet 1 for the zero-arity case. Sound.
- Bullet 2. Sources: D-037 ("the aggregate wasn't even observable"), D-311
  Rationale (the custom fold written at the site), and D-037 bullet 2
  ("silent omission — the zero-edit convenience *is* the hazard"). All
  match. N2: "Every contribution a total includes is a declared wire" is
  sourced only through D-143's zero total, which is narrower. It follows
  from the mechanism (junction inputs are ports, and D-170 gives each one
  connection), so the risk is low. D-007's surviving Rejected item on
  contribution buses ("contributes by being in scope rather than by being
  wired") would be a closer source.
- Bullet 3. Source: D-037 Rejected bullet 3 and its annotation bullet,
  nearly verbatim. Sound.
- Vocabulary in all three entries is current ("root input", "structure
  step", "first nominal build", "root build", "stage-2", `Pinned`). No
  retired term appears in a Position.

## 2. Annotations

All five sit after Rationale and before **Rejected.**, are dated 2026-10-12
and cite their sources.

- D-037: matches D-207 and §6.2 ("every assembly that owns contributors
  must export its aggregate"). The FlightPhysics claim checks out:
  `lib/FlightPhysics/src/dynamics.jl` 328–393 defines the `@generated`
  `get_mp_b`, `get_hr_b` and `get_wr_b` in `module Dynamics`, and
  `lib/FlightCore` defines none of them.
- D-061: matches D-207 bullet 1, §6.1 (`PathResolution`) and §13.3 (two
  duties, client table). Sound.
- D-062: **P4 (minor).** Current: "A block joins the library by judgement
  against three guidelines, not on demand (D-313)." D-313 says a listed
  block "is built whenever wanted", which "on demand" can be read to deny.
  What D-313 replaced is D-062's "demand-driven", meaning demonstrated need
  (D-313 Rejected, "Strictly demonstrated need"). Fix: "not by demonstrated
  need (D-313)". The rest matches D-311 and §13.7 (10046, 10053, 10060).
- D-073: matches D-311 bullet 3 and §6.2's
  `SumJunction{Wrench{Float64}, 3}`. Sound.
- D-143: matches D-312 bullet 1, D-267 bullet 1, and D-220 bullet 2 with
  D-267 (`h_xu` → `output_direct` → `y_direct`). It also matches §13.7
  10060–10061 ("A stateless continuous `y_direct` recomputes every
  sweep"). The annotation rightly scopes `y_direct` to the tier argument,
  since `Constant` itself defines `y_state` (§13.7 10104). The FlightPhysics
  claim checks out: `aircraftbase.jl` 31–33 define the three identity
  methods on `Model{NoVehicleSystems}`, inside D-143's cited 27–35. N3: that
  sentence cites nothing; "(§6.2)" would cover it, since §6.2 names the
  vehicle as FlightPhysics'.

## 3. Spec citations

I compared `git diff HEAD --word-diff` and the token streams with the new
citations stripped. Only the eleven citations and three link definitions
changed. All 18 link-collapsed bold spans are unchanged. The rewrapped
paragraph (1369–1379) is greedy, and no line is over 80 rendered columns
(75, 70, 78, 79, 76, 71, 68, 76, 78, 77, 7). The other edited lines are at
80 or under.

| line | source beside | Position states it? |
|---|---|---|
| 1295 | D-207 | yes, D-321 bullet 1 |
| 1342 | D-264 | yes, D-321 bullet 2 |
| 1353 | D-263 | yes, D-321 bullet 3 (spec's "both endpoints named" not in the Position; minor) |
| 1369 | D-043 | yes, D-322 bullet 1 |
| 1371 | D-048 | yes, D-322 bullet 2 |
| 1373 | D-048 | yes, D-322 bullet 2 |
| 1398 | none | yes, D-323 bullet 1; see N4 |
| 1511 | D-037 | yes, D-323 bullet 3 |
| 1529 | D-037 | yes, D-323 bullet 1 |
| 1552 | D-037 | partly; see P3 |
| 1555 | D-037 | yes, D-323 bullet 1 |

- **P3. Spec 1552.** The cited sentence is "explicit wiring buys
  per-contributor values and intermediate totals as observable ports, with
  every silence in the aggregation's bookkeeping inverted into a warning or
  error ([D-037], [D-323])". D-323's Position states the observable
  aggregate. It deliberately does not state "every silence … inverted into
  a warning or error" (F2). Citing it there implies it does. Fix: drop
  ", [D-323][d-323]" at 1552, or have the owner accept the partial match.
  D-323 bullet 2's exact sites are the "What the explicit form buys"
  bullets 2–3, which cite no entry.
- N4. Spec 1398 cites D-323 alone, with no source entry beside it. Step 8
  asks for a citation beside the source. Chapter 7's spec 1769 and 1779
  (D-304 alone) are a real precedent, so I accept it. The owner may want to
  know.
- N5. Spec 1398 says "no identity-element opt-outs", and D-323 says "no
  identity elements". The Position is broader and consistent with D-143
  ("the identity element D-037 retired on purpose"). No fix needed.

## 4. Walkthrough

Line 159 now reads "`# no checks — see section 6`". The walkthrough's own
section 6 is "The write-surface rule", the survey's intended target.
Correct. N6: the code line is now 84 columns. Companions are not held to 80
and other lines there run longer, so no fix is needed.

## 5. Battery

Each check ran as its own command from the repository root.

- `linkify.jl`: no-op. `git diff --stat` matched before and after, and so
  did shasums of every file under `docs/design`.
- `check_refs.jl`: OK. 5140 citations, 1343 anchors, one standing
  self-vs-spec advisory (`event_visibility_walkthrough.md:20`).
- `check_rows.jl`: OK, "newly cited by the spec (fine): [321, 322, 323]".
- `check_glossary.jl --strict`: OK. 173 entries, three standing advisories.
- `check_bold.jl`: OK. Chapter 6 has 13 bold spans and 142 bold words.

## Re-check

I re-checked the four fixes against `git diff HEAD`. All four hold.

- P1: the mapping sentence is gone from D-321's Rationale. Nothing else in
  the Rationale moved.
- P2: the new sentence reads "D-263's rejection of D-167 reaches only the
  mandated forms, and D-263's Rationale restates both halves of the
  asymmetry, an input pin failing at the first nominal build and an output
  built from frozen data refused at the first `Dual` activation". D-263's
  only Rejected item against D-167 is "the mandated two-argument forms".
  "Refused" is D-263's own verb: "an output built from frozen data is
  refused at the first `Dual` activation by the identity comparison … or by
  the `MethodError`". §6.1's "lurks until the first `Dual` activation …
  loudly, never silently" says the same thing: no build-time check, then a
  loud failure at that activation. D-286 calls the output case "the
  misplaced-pin error" at activation. "Refused" does not overstate.
  "Failing" on the input side drops D-263's "only when written", but "an
  input pin" already means a written one. No fix.
- P3: spec 1552 now matches HEAD exactly. The word diff now shows three
  "([D-037], [D-323])" insertions, down from four, and nothing else changed.
- P4: D-062's annotation reads "not by demonstrated need (D-313)". Its word
  stream matches the old text with that one substitution. The rewrapped
  lines are 78, 76, 78, 80 and 47 rendered columns.

Battery, each check run as its own command:

- `linkify.jl`: no-op. `git diff --stat` and the shasums of every file
  under `docs/design` matched before and after.
- `check_refs.jl`: OK.
- `check_rows.jl`: OK, with 321, 322 and 323 newly cited.
- `check_glossary.jl --strict`: OK.
- `check_bold.jl`: OK. Chapter 6 still has 13 bold spans and 142 bold words.
