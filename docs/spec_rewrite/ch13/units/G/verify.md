# Unit G verification

Against frozen `h1/spec.md` and `h1/decisions.md`.

## Counts

213 claims. MATCH 212, DRIFT 1, LOST 0. ADDED: 6 sentences, 14 clauses. All are glosses, pointers or ruled text (F61, R10, R13). None changes meaning. The five sketches are byte-identical.

## DRIFT

- **C-004** (F58). Dictated: "the face routes `show(::Structure)` prints". New: "the routes `show(::Structure)` prints for each face". `show` prints only the root's routes (D-257 b3, V11). Fix: "for each root [face](#g-face) (gloss)".

## Citations

- All 20 added citations carry their claims in the field rulings.md names. D-143 at the stub child is Rationale-only, as declared.
- **D-261 is lost with M60** (C-018). §9.2 (4525–4527) states the edge derivation with D-257 alone. Fix at landing: cite D-261 there, or accept.
- V91: "Two uses" rests on D-143's Rationale, which is uncited. Optional: add D-143.
- V97 (F61, dictated): D-364 rules a *rig's* environment, and the general claim is D-237's. Optional: cite D-237, or write "never enters a rig as a root input".
- Every other old citation survives with its claim.

## Bold

Compliant. Each bold is a ruling headline with its entry in its sentence. Where one entry has several bolds, each is a distinct ruling:
- D-245, D-349, D-312: bullets 1–3.
- D-343: bullets 5, 8, 9.
- D-012: the SCC clause and the discrete-members clause.
- D-037's sugar against D-323 b3's bundle.

R5, R20 and R21 are applied. "The rig therefore satisfies that entry *inside* the rig" stays plain and keeps D-120. No ruling is bold twice. No mechanism or lead-in is bold.

## Hazards

- F58–F62 and F64 match their dictated wording, except C-004 above.
- F63: in §13.8, "local" appears only in the two glosses. "The local rule (§14.10)" in §13.7 is D-266's sense.
- M60: §9.2 holds every artifact the list named, the no-accessors rule, the events and the feedthrough line.
- M61 and M62: tier-transparency (line 139) precedes `Constant` (line 189), so "above" holds. "The rig stub below" still holds. "A member's map" precedes the verdict.
- The Simulink sentence and "The starting inventory" are verbatim. The shipped-list sentence follows the list.
- R12: no forbidden links.
- Moves: M60–M62 and part C's guidelines-first order were done. There are no others.

## Reader-cold names

- (1) None. FlightPhysics is introduced at spec line 205.
- (2) `VehicleWrenchSum`'s `aero`/`ldg`/`pwp` are introduced only in §6.2 (1656). Fix: point to §6.2's example. "Stall blending" and `systems/aero` are mild and pre-existing.
- (3) None.
- Other: M60 removed `Structure`'s link. Its first use, V2, is bare. Fix: link `#g-structure` there.

## Open, from rulings.md

These proposals are unruled:
- Corrections 1–2: "substitutability contract" and "root contract" use *contract* in other senses; "verification" names nothing.
- Correction 3: the glossary's tracer entry, for Track 2.

## Re-check

I re-read new.md, claims.md and rulings.md after the fixes. §13.8 is unchanged, and "error messages and verification" is kept (R28). There are seven edits, all in §13.7.

- **C-004** (line 7) now reads "each root face". Landed. The claims.md note still quotes "for each face", which is stale.
- **The kept `Structure` sentence** (line 25) states only that `Structure` has a `show`. It names nothing §9.2's item prints, so it does not double the list. Its gloss is old text and agrees with the glossary. Two small points:
  - The link is not at the first use. `show(::Structure)` already appears at line 7.
  - R4 allowed one plain sentence, and there are now two.

  Optional fix: move the link and gloss to line 7.
- **`VehicleWrenchSum`** (lines 124–126). The citation carries the clause: §6.2 (1655–1657) names `Systems` and its children `aero`, `pwp` and `ldg`. No neighbour broke.
- **D-143 at "Two uses"** (line 205) carries through its Rationale ("demonstrated the need twice, at the zero-contributor totals and at the rig"). rulings.md lists it.
- **R27** (lines 212–214) is verbatim. D-364 carries its second clause. **The first clause conflicts with §14.9.** D-237 refuses a handle-typed root input, and in D-237's sense a handle is a non-isbits opaque type. §14.9 (12333–12334) instead uses "handle" to include isbits handles, and makes an isbits handle "an ordinary root input holding the handle **value**". D-364's Rationale agrees: "Isbits handles … stay root inputs". A reader of "A handle-typed value never surfaces as a root input" therefore meets a contradiction. Proposed: "A handle that references bulk data never surfaces as a root input ([D-237][d-237]); …". The phrase is §14.9's bold (12338).
- **R28** (lines 282 and 290–291) is verbatim in both places. "Structural substitutability" is the glossary's term (13689). The antecedents ("It", meaning the rig) still hold.

Counts: 7 edits. 6 are clean, 1 has an open question (R27), and there are 2 minor notes (the stale C-004 note and the placement of the `Structure` link). No new DRIFT or LOST. The bolds and the sketches are unchanged.

### Re-check 2 (R30)

- **F61 sentence** (new.md 212–214, claims.md 421). It matches R30 word for word.
  - D-237's Position carries the first clause. D-237 refuses "a handle-typed face surfacing as a root input", where a handle is a non-isbits opaque type, and a handle that references bulk data is one.
  - §14.9's bold (12338) says the same thing in the same words, and §14.9's isbits case (12333) no longer conflicts.
  - D-364 still carries the rig clause.
  - The neighbouring sentences are intact.
  - Optional, cosmetic: "holds such a handle" would avoid saying "bulk data" twice.
- **C-004's note** now says "each root face" and explains where the `Structure` link sits. It is accurate.

Both edits are clean, and no questions remain open.
