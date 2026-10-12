# Unit F verify

**Counts.** 44 phase-1 assertions. 52 inventory claims: 51 MATCH, 1 DRIFT (minor), 0 LOST. 7 ADDED, none changes meaning. `check_unit.py`: 0 failures. `old.md` matches base lines 530–601. The code block is byte-identical.

## DRIFT

- **C-019/C-020, the cause of the `Symbol` mode's publishing.** Old: "interned, immutable and never freed, the same grounds §7.3 admits it in a store on, so a `Symbol` mode publishes like any other". New: "…never freed. §7.3 admits it in a store on the same grounds, so a `Symbol` mode publishes like any other." After the split, the "so" follows only §7.3's admission. In the old text it followed the `Symbol`'s properties. Fix: "Julia classifies it mutable, but it is interned, immutable and never freed, the grounds on which §7.3 admits it in a store. So a `Symbol` mode publishes like any other."

## ADDED

The `KinPose`, `Kinematics` and `Vehicle` notes say "illustrative" and nothing more. The `RQuat` sentences hold: FlightPhysics' `attitude.jl` 66 has `struct RQuat <: Abstract3DRotation`, which takes no type parameter. The field-handle gloss matches glossary 13016. "the bundle (the struct-valued port)" fits D-276's Rationale (log 11617, "A bundle port such as `pose = KinPose{T}` is one cell"), and *bundle* stays unlinked. The *leaf walk* gloss copies glossary 13354's opening words and §6.1 1432's gloss. Its sense, a walk over a declared type, fits D-237's "leaf walk over a port type". The brief's link list for F does not name this link. Unit E never uses the term, so this is §4.3's first use, and the link is defensible. The orchestrator decides (open question 2 in `rulings.md`).

## Citations

All old citations survive with their claims. D-243 moved three sentences earlier, onto its Position's headline. The claims after it rely on adjacency, which is acceptable. I checked each added citation against the log:
- D-036: lines 1169, 1170–1171 and 1171–1172 carry the first, third and fourth rulings. The Rejected list at 1183–1184 carries the guarded addition. Minor: the citation sits on "Its shape is obvious, and it is not built". D-036 carries the previous sentence, "is a guarded addition". Better there.
- D-237: lines 8950–8951 and 8951–8953 carry both clauses.
- D-316: bullet 1, line 13404, carries the enum clause.
- D-276: line 11611 carries "Wiring stays port-granular".
- D-045: the Rejected list (1436–1438) carries the different-writers half, through "kills per-field claiming". The different-cadences half is only implied, by liveness and trace tag. Rulings.md rightly lists it as Rationale-only and owed a Position.

## Bold

There are 8 bolds. Each states a ruling, is the headline clause and is followed by its entry:
- D-036: the 1st, 3rd and 4th rulings, which are separated by semicolons.
- D-237: sentences 1 and 3.
- D-243: its Position.
- D-276: its last bullet.
- D-045: its Rejected item, as R6 rules.

No bold falls on a mechanism, a consequence or a lead-in. The checks for doubles came up clean:
- §9.5 4790 bolds D-237's sentence 2 (identity), a different ruling.
- §8.3 2992 bolds D-252, and unit F leaves "exactly one producing function" plain.
- Unit E bolds D-036's second ruling and D-243's Rationale, both different rulings.

"Wiring is port-granular" (D-276) restates D-036's "atomic in wiring", but the D-036 bold here covers only "first-class port value", so no ruling is bold twice. Both halves of all four two-condition rulings survive. "Fan-out is free" stays plain and uncited (R13).

## Moves

None were due, and none were made. Paragraph splits and the reorder of "bundle what is written together" happen inside their own passages. `ProducedByTwoStages` is correctly left to unit E (R15).

## Reader-cold names

- (1) Flight.jl machinery: none. `RQuat` is glossed as FlightPhysics'.
- (2) Aerospace: "pilot commands" and "kinematics … pose … velocity-derived quantities" read plainly. No gloss is needed.
- (3) FlightCore: not used.
- Redstone names used before their definition, as in the old text: `output_wires` (defined §6.1, base 1354) and "stage 1"/"stage 2" (defined §5.2, base 699). Optional pointer: "(`output_wires`, [§6.1])".

## Other

- I agree with correction 1: the stop-request gloss omits "unless the advance ignores it" (D-316 Position, glossary 13852).
- I agree with corrections 2 and 3: "recorded" has no log record, and the composed principle has no entry.

## Re-check

Verdict: all three changes are correct, nothing else changed, and the checker prints `checks failed: 0`. The 8 bolds and the code block are unchanged.

1. **`Symbol` split.** "…never freed, the grounds on which [§7.3] admits it in a store. So a `Symbol` mode publishes like any other." The "So" now follows the whole chain of reasons, as in the old text. The DRIFT is resolved.
2. **D-036 moved.** D-036 Rejected (log 1183–1184) carries "kept as guarded addition", so the citation now sits on the claim it supports. Minor: it sits inside the glossary gloss's parentheses, so it can read as citing the gloss. "…does not build) ([D-036])" would be clearer. This is optional.
3. **Pointers.**
   - "which are stage 2 ([§5.2])" points at §5.2 base 699, "`y_state` is stage 1 and `y_direct` is stage 2". The pointer is sound, but it sits at "stage 2", not at the first use, "stage 1". Optional: move it after "which is stage 1".
   - The `output_wires` sentence repeats §6.1 base 1353–1354 word for word and claims nothing more. It fits the sketch's comment ("each face aliases an interior port"). It sits between the `KinPose` and `RQuat` introductions and disturbs no antecedent: "of it" in the next sentence still has `RQuat` as its antecedent.
4. **Bookkeeping.** `rulings.md` lists all three citations with their sources. `inventory.json`'s `added` list carries both pointers. One small error: C-020's `newcites` still lists D-243, which no longer sits on that span.
