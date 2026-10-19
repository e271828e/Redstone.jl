# Unit F verification

Frozen spec and log only (`scratch_survey/h1`). Splits appended to `verify_phase1.md`.

## Counts

MATCH 214, DRIFT 1, LOST 0, ADDED 8 (V22, V32, V106, V107, V108, V140, V188b, V204). Every ADDED item comes from a ruling (R10, R14/F71, F56, F62) or checks out against the source. Claims C-042, C-073 and C-181 hold where they moved, in B/new.md 91–93, A/new.md 328 and B/new.md 326.

## DRIFT

- **C-017 / V17 (antecedent).** Old: "the θ-constraint elimination survives inside `trim_condition`" (the real problem's). New adds "the worked problem's illustrative condition function". The real problem's elimination now lives inside the worked problem's function. Fix: "survives inside its condition function, which the worked problem calls `trim_condition`".

## Citations

- **V107.** The `:claimed` reason is D-318's (log 14213–14228). D-319 gives only the gate and its timing, and `src/trim.jl` 443 cites both. Fix: cite D-318 and D-319.
- **V188.** The added clause "followed by one derivative evaluation for the reads" is F56's and the code's (`src/trim.jl` 485–486). D-213 does not state it. That is acceptable, but D-213 now covers more than it rules.
- Every other added or replaced citation carries its claim, including D-223 bullet 4 with §13.4 (spec 10449–10451) and §9.5 (spec 4973). Every old citation survives or moved with its claim.

## Bold

There are 18 bolds, each a ruling headline with its entry in the sentence and no doubles across units A, B, G and H. R21 is applied: the fallback is bold in the conditional, and `NLoptBackend` is plain. Open: **D-124**'s widened `reads` grammar is homed at §14.7 (V36) and bold nowhere. **D-118**'s "Returned names are the report's equation names" (V62) is plain. q24 listed neither.

## Moves

M51–M56 and M58 are done, in survey C's order, and nothing else moved. All eleven bullets survive, every count still matches its list, and every cross-reference points the right way after M51. R5 is applied.

## Owners (spot-checked in Flight.jl)

- Correct: `f_periodic!` and `f_ode!` in FlightCore `modeling.jl` 219 and 209; `AbstractTrimState` and `θ_constraint` in FlightPhysics `aircraftbase.jl` 92 and 110; BOBYQA and `stopval = 1e-16` in c172.jl 924–927; warn-but-assign at 933–938; `TrimParameters` at c172.jl 806.
- Note: V83 credits FlightPhysics with "the minimal 7-variable search", but that search is c172.jl's `TrimState`. R23 dictates the owner. Consider "and the Cessna 172 model's minimal 7-variable search".

## F55 and F56

Both are confirmed. `_establish_frozen!` (`src/model.jl` 97–114) makes a value copy, and the embedding happens at the consumer's read. `_verdict!` runs `rhs()` before the gather (`src/trim.jl` 622–627), and setup does the same (486).

## Links (§14.8 across F and G)

No term is linked twice between F and G. `TrimProblem` and `baseline` are linked in F. Optional: `claimed` (V107) could link `#g-claim`. `deployment` and `store` are never linked in §14.8, as in the old text.

## Reader-cold names

- (1) Every Flight.jl name carries an owner clause.
- (2) "CG-limit diagnostic" (V156) needs a clause: "the centre-of-gravity-limit diagnostic". EAS is glossed.
- (3) FlightCore as the predecessor (V86, V100) is fine.

## Re-check (after R39)

`build_inventory.py ch14 F` reports 215 claims, 18 added and 0 failed checks. The only citations old.md holds and new.md lacks are §8.3 and §14.3, both moved with M55 and F55 as before.

- **C-017: OK.** "Its condition function" means the real problem's, and the next sentence still reads well.
- **V107: OK.** D-318 is cited beside D-319 in the existing sentence. No sentence was added.
- **C-199/C-200: OK.** D-213's Rationale has "zero-decision probe falls out as the nominal half alone" (log 8278). The `rhs` clause is the code's (`src/trim.jl` 486), and it is now uncited.
- **C-166: OK.** "CG is the center of gravity" uses US spelling, which the spec uses. The line runs past the wrap, a reflow nit.
- **C-034 bold: OK on all three conditions.**
  - D-124's Position rules the widened grammar as a ruling of its own.
  - §14.7 states the grammar.
  - No other section of the frozen spec bolds it. §11.6's bold `reads(b)` (8095) is D-199's device binding. §14.4's "Service reads speak the contract" (11666) is D-414's, and R5 has made it plain.
  - Unit B has no D-124 bold.
- **C-099 bold: OK.** "Returned names are the report's equation names" is its own sentence in D-118's Position. §14.7 (old 12043) is its only statement, and nothing else bolds it.
- **C-065: OK.** c172.jl 796 has `TrimState <: AbstractTrimState{7}`. One nit: the bold head still says "The FlightPhysics formulation's core", and the core now includes a `c172.jl` part. That is acceptable under R23.

Nothing new is broken.
