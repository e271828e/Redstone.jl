# Unit B (§6.1, "Type-checking a wire" and "Connections per port"): rulings and findings

Applied: R1 (the context sentence; the bound check plain with
`WireTypeMismatch` and D-078; the walk clause plain, "for a continuous
consumer only" in words; M1 as one sentence after the walk clause, citing
D-295 and D-263 and pointing to §8.2 for the reason; M2 before the
abstract-entry paragraph, "Both sides" become "The producer's declaration and
the entry"; the opaque leaf, the violation with its payload and remedies and
the failure asymmetry stay). R4 (five bolds: D-236 bullet 1, D-264 sentences
1 and 2, D-170's last chained ruling, D-084). R5 (M4, one label "Connections
per port", part C's order: fan-out, the rule, across levels, unconnected
inputs, unconnected outputs last; the declared D-048 sentence). R6
(`TwoProducers`, `UnconnectedInput`). R9 (F4 twice, F10, F15: the remedies
quoted from Appendix C 12304, "awaiting a wire from above", "input entry" at
first use).

Antecedents fixed by naming: "on the same terms" becomes "The walk clause
admits an opaque leaf on the same terms as a pinned or walking leaf"; old 1316's "the clause", old 1310's
"A violation" and old 1328's "The same clause" each say "the walk clause",
since M1 and M2 put the bound check or the run between them and the clause.

Glossary links: `#g-tier` and `#g-tick` go with the M1 paragraph, whose terms
the unit no longer uses; §8.2 2433–2439 links `tick`. `#g-cell` moves to the
new first use, "the producer's cell", with a gloss. `#g-activation` moves up
to the nominal gloss, now the first use. `#g-walked` moves from "pinned" to
"walking", the first of the entry's names in the section (spec_style,
"Terms"). Added: `#g-abstract-entry` (with a defining sentence, kept out of
the bold) and `#g-root-input` (glossed by the appositive before it).

Trimmed to §8.2 under M1, each mapped in the inventory to a span that says the
same: "The tier scope is a correctness rule, not tidiness" (§8.2 "That scope
is a correctness rule rather than tidiness"); "its stages read exclusively at
real ticks in the nominal world" (§8.2 "A discrete stage reads exclusively at
real ticks … in the nominal world"); "A `Dual`-carrying cell exists only
inside activations the discrete tier never runs in (§9.4)" (§8.2, the same
sentence with "discrete stages"). The nominal gloss stays in the unit.

## Corrections proposed

- **F13, F14, F16, F17 left as written.** The failure asymmetry's input side
  still assumes a walking producer (F13). "one declared `Pinned`" still
  narrows *pinned* by example (F14). "a store" at the identity rule is §9.5's
  sense and takes no `#g-store` link (F16). "Fan-out is free" stays scoped to
  producers (F17).
- **Appendix C's `TwoProducers` row says "sibling wire"** (spec 12294–12296 at the
  base: "both producers with their declarations (sibling wire / interface
  connection entry)"). D-314 Position makes the child-to-child kind a "local
  wire" in prose, and F4 removes "sibling wire" from §6.1. Proposed: "(local
  wire / interface connection entry)". Outside the unit; for Appendix C's
  rewrite or track 2.

## Citations added or replaced

- D-078 at the bound check (Position: "wiring check `producer_face <: entry`
  at nominal faces — one uniform rule, exact equality the concrete
  degenerate").
- D-295 and D-263 replace D-167 at the continuous → discrete sentence (D-295
  Position bullet 1: "Discrete consumers take the bound check only … so
  continuous → discrete wires are unconditionally legal"; D-263 Position
  bullet 2: "Both wire clauses of §6.1 stand"; D-167 is superseded by D-263,
  log 5934).
- D-236 at the abstract-entry bold (Position bullet 1: "An abstract entry is
  checked on the whole declaration"). The following sentence keeps its own
  D-236.
- D-264 moves into the bold admission sentence (Position sentence 1: "admits a
  pinned or discrete producer of an opaque leaf at an unpinned entry of that
  leaf's type, as the producer's cell").
- D-264 at the identity-rule bold, beside §9.5 (Position sentence 2: "The
  identity rule for an opaque leaf … governs a store and the producer's own
  conformance check alone, never a wire"). §9.5 4632–4634 states the same
  split.
- D-264 at "a handle's pin is a property of its chain" (Rationale only,
  below).
- D-266 at the `Freeze` remedy (Position bullet 2: "A walking producer feeds a
  pinned entry through the `Freeze{V}` library block").
- D-263 at the input side of the failure asymmetry (Rationale only, below).
- D-286 beside §8.2 at "It lurks loudly, never silently" (Position bullet 2:
  "An observed `Dual` at a pinned leaf is the misplaced-pin error, with the
  didactic hint").
- D-170 at the single-connection bold and at "The rule spans levels"
  (Position: "one invariant spans all three: … every right side fed exactly
  once").
- D-048 at the whole-tree sentence (Position bullet A: "global wiring +
  obligations"; the whole-tree reading is its Rejected list, below) and at
  the declared sentence on deciding both checks at the root (Rejected, below).
- D-208 beside §11.3 at the root-input terminus (Position: "the model's root
  inputs are the root's input faces uniformly").
- D-167 dropped (superseded). No other citation removed. §9.4 goes with the
  M1 trim; §8.2 keeps it at the same sentence.

## Rationale-only rulings

- D-264, Rationale, log 10569–10573: "a consumer that re-emits a frozen
  handle under an unpinned output hits the store's identity rule, so a
  handle's pin is a property of its chain". Also log 10541–10546 for "the
  consumer gathers the producer's cell as stored" and the promotion inside
  the consumer's math, which sit beside the Position-cited admission.
- D-263, Rationale, log 10434–10436: "an input pin is a wire check at the
  first nominal build only when written". The "build-time counterparty"
  reason has no entry.
- D-048, Rejected, log 1500–1501: "Single-pass tree walk with per-level
  validation: obligation/two-producers undecidable below the root". It
  carries the whole-tree reading and the declared sentence.
- D-043, Rejected, log 1343–1344: auto-bubbling (cited already).
- No live entry states the walk violation's payload or its two remedies
  (D-167 Rationale, superseded). Appendix C 12301–12305 states them, and the
  sentence stays uncited. "with no silent defaults" stays uncited: D-051 and
  D-143 point back at §6.1 (lesson 16).

## Bold on the same entry elsewhere

None of the five rulings is bold anywhere else. Checked against units A and C
`new.md` (D-207 and D-037, D-311, D-143 only) and the whole working-tree
`spec.md`. Related bolds on the same entries, each a different ruling:
D-236 sentence 2 at §8.2 2417 ("Two clauses check a wire") and §9.1 3831 (the
marker retyping), whose sentence names "on the whole declaration at an
abstract one" after the bold, unbolded; D-236 bullet 3 at §8.2 2472
("Abstract-at-root is a build error"); D-170 rulings 1–3 at §8.6 3136, 3141
and 3153. §8.6 3154–3157 states the "fed exactly once" invariant plain, as
the reason for the direction ruling. Unit C's R7 sentence cites D-084 plain
("stays legal and silent, as any unconnected output does"), not bold.

## Inbound citations affected

- Spec 2430 (§8.2) points here for the bound check's kind and the remedies:
  both stay stated.
- Spec 2511 (§8.2), 10071 (§13.7), `handle_walk_walkthrough.md` 4 and 64:
  the walk clause and "a frozen arrival … is the producer's cell" stay.
- Log 8845 (D-236), 10386 (D-263), `src/build.jl` 853 and 856: "marker
  scalar" stays, beside the §9.1 pointer.
- Log 12483 (D-295 Spec), log 6048 (D-168 Rejected), `test/test_linearize.jl`
  334: the tier scope stays as one sentence citing D-295.
- `test/test_build.jl` 567 and 681: "failure asymmetry" and "first nominal
  build" stay word for word.
- Spec 3760–3762 (§9.1) said §6.1 decides cross-level two-producers detection
  only at the root, which §6.1 did not say. The declared D-048 sentence now
  says it, so that row holds.
- Spec 3161, 3258, 3581 ("two-producers"), 3203 and 3813 ("whole-tree",
  "obligation"), 2412 and 2882 ("unconnected-input error" by sense),
  `src/assembly.jl` 959 and 979 ("obligation chain"), `src/diagnostics.jl`
  346 and 361 ("exactly one connection", "across levels"): the words stay.
- Log 11789 (D-279 Rejected, "`sibling_connections`: §6.1's own adjective
  for these wires") is history; after F4, §6.1 says "local wire".
- Survey part C's label "One producer per input" is not used; R5's "Connections
  per port" is, and unit A's roadmap sentence follows it.

## Open questions

- The log owes Positions for the pin-chain consequence (D-264), the input
  side of the failure asymmetry (D-263), the whole-tree and root-only checks
  (D-048), no auto-bubbling (D-043) and the walk violation's payload and
  remedies (no live entry). Track 2.
