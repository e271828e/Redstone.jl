# Chapter 6: the rulings batch (recipe step 6)

The orchestrator consolidated this batch itself, without a consolidator
agent. The chapter's open items were few: six ruling items from
`chapter_pass.md`, one optional edit from `inbound_check.md`, F6 from the
survey, and the units' out-of-chapter notes. Each item carries its status and
reason. Ruled edits carry their id into the unit inventories.

## Blocking: edits inside the chapter

- **RP-1. "Frame responsibility" becomes "Reference-frame responsibility"**
  (chapter pass R-1; unit C). *Ruled: accept.* The glossary's `#g-frame`
  reserves bare *frame* for the loop iteration and names reference frames as
  always compounded (spec 12947–12951 at the base). One word changes, and no
  claim does.
- **RP-2. Gloss *wrench* at its first use in §6.2** (chapter pass R-2; unit
  C). *Ruled: accept.* "Total wrench (force and torque), total mass
  properties …". The source is R12's (`dynamics.jl` 114–117, fields `F` and
  `τ`). R12's clause at the type stays.
- **RP-4. F6 and "the vehicle"** (chapter pass R-4; survey F6; unit C).
  *Ruled: keep the vehicle, introduce it, and name the difference from the
  block.* The idiom's example matches §8.8, whose `Systems` exports
  `"wrench"` to the level above (spec 3628–3631 at the base), and Flight.jl,
  where `Vehicle` holds `systems` and `dynamics` as siblings
  (`FlightPhysics/src/aircraftbase.jl` 49–54). The outlier is §6.2's code
  block, which feeds a `dynamics` child inside `Systems`. Both shapes are
  legal, and the survey's probe built the block's. The code block stays
  verbatim. The sentence becomes: "The vehicle, the assembly one level above
  the systems assembly, wires the systems totals into the rigid-body
  equations of motion. The block above places the `dynamics` child inside
  `Systems` instead, and both shapes are legal." The chapter pass preferred
  aligning the prose with the block. That was declined, because the block,
  not the prose, departs from §8.8 and from the idiom's "exports the total".
- **RI-1. "The unconnected-input error, `UnconnectedInput`, fires …"**
  (inbound check; unit B). *Ruled: accept.* Spec 2412 and 2882 quote
  "unconnected-input error" from §6.1, and the phrase now appears there.
- **The 19 EDITORIAL items of `chapter_pass.md`.** *Ruled: apply as the
  pass gives them.* They include the `#g-component` link moved to its first
  use in §6.1 and dropped from unit B, the rewrap of R11's bullet, and §6.2's
  assembly gloss trimmed to "a component of pure composition". The fixer
  checks each against its unit's inventory.

## Not blocking: no chapter change

- **RP-3. The glossary's *entry* lacks the wiring sense** (chapter pass R-3).
  *Ruled: carry to Appendix D.* Add "wiring entry (an entry of
  `local_wires`, `input_wires` or `output_wires`, §6.1)" to `#g-entry`'s list.
  §13.3 already says "a wiring entry". The chapter's use is old and
  consistent.
- **RP-5. "One-level rule" beside "locality law"** (chapter pass R-5).
  *Ruled: no change.* The spec keeps the two apart, as §13.3 and §14.2 show,
  and R2's clause relates them by "This restriction". Escalation E1 below
  bears on what the locality law's name now implies.
- **RP-6. "Mounting transforms"** (chapter pass R-6). *Ruled: no change.* The
  glossary's *mounting* does not reserve the bare word, and the use is
  compounded and old.
- **F13, F14, F16, F17.** *Ruled: stay as written* (brief). None misstates
  the design. Each narrows or assumes by example, and the brief kept the
  rewriters from sharpening them.

## Carried out of the chapter at landing

To `docs/spec_rewrite/README.md`, "Carried to later chapters". The chapter 6
bullet there is settled (R1: §8.2 keeps D-295's bold) and is removed.

- **Chapter 13.** §13.7 bolds D-311 (spec 10004), which §6.2 bolds. §13.7's
  "Two demonstrated needs admit `Constant` under the inventory's
  demonstrated-need charter" (spec 10094–10095) predates D-313's judgement.
- **Chapter 14.** §14.2's "The law is convention" (spec 10342–10345), see
  E1. §14.10 cites superseded D-167 at spec 11382, 11425 and 11544.
- **Appendix C.** `TwoProducers` says "sibling wire" (spec 12294–12296).
  D-314 makes it "local wire" (unit B).
- **Appendix D.** *generic holding* (spec 12750) cites §6.1, which no longer
  states it; it belongs to §8.8. *local wire* (spec 12760) cites §6.1 for "one
  end on the boundary", which D-314's Rationale states. RP-3's wiring entry.

## Track 2 (recipe step 8)

New entries, if any, take numbers from D-321 to D-340.

- Annotations to stale Positions: D-037 ("totals exported across generic
  boundaries"; its Rejected "FlightCore tree walks" are FlightPhysics'),
  D-061 ("§6.1's generic-boundary rule"), D-062 bullet 3 (the gates folded
  into `Junction` by D-311, demand replaced by D-313's judgement), D-073
  ("unparametrized type constructor", against D-311 bullet 3), D-143
  (`output_types`, `h_xu`, the pinned port of D-312, and "FlightCore's
  silent identity methods", which are FlightPhysics'), and D-065, after E1.
- Positions owed for Rationale-only rulings, each restating only what its
  entry records: the parallel-routes signal (D-207 Rationale), the pin chain
  (D-264 Rationale), the failure asymmetry's input side (D-263 and D-236
  Rationales), the root-only checks (D-048 Rejected), no auto-bubbling
  (D-043 Rejected), no framework aggregation mechanism and the explicit
  form's gains (D-037 Rejected), and do-not-bundle (D-037 Rejected and its
  annotation).
- No entry at all, for the owner: the walk violation's payload and remedies
  (Appendix C states them, but the only entry is superseded D-167),
  unconnected inputs as a build error with no silent defaults (no Position;
  two Rejected lists point back at §6.1), local fan-out is free, and the
  common body frame (Flight.jl's convention).
- Outside the spec: `companions/inbound_periphery_walkthrough.md` 159 "see
  §6" becomes "see section 6". `src/build.jl` 511, `test/test_build.jl`
  764, `test/test_linearize.jl` 334 and `test/test_blocks.jl` 449 cite §6.1
  or §6.2 for what those sections do not state. These go to `pending.md`, on
  the implementation side.

## Escalations

See `escalations.md`: E1.
