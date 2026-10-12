# Unit C verification

**Counts.** There are 85 inventory claims and 74 phase-1 assertions. 83 claims MATCH, C-059 among them: the census is held word for word in D-037's annotation. 1 is DRIFT in context (C-023). 0 are LOST. Of 15 ADDED items, 2 need a fix. `check_unit.py` reports 0 failures.

## DRIFT
- **C-023.** Old: "**Every mistake is loud** under the declaration layer." New: the same words. R7's new D-084 sentence now sits in the same bullet: "A contributor's output that nobody wires stays legal and silent". A forgotten contributor with no slot is a mistake, and it stays silent. The bullet now contradicts itself. Fix: "Every bookkeeping mistake at the junction is loud under the declaration layer." This matches R7's cost wording and rulings.md open question 1.

## ADDED, needing a fix
- **"`Wrench` is FlightPhysics' force-and-torque type."** The clause sits beside `Wrench{Float64}`. FlightPhysics' `Wrench` (`dynamics.jl` 114–117) is not parametric. Its fields are `F` and `τ`, both `SVector{3,Float64}`. `Wrench{Float64}` is the migration's form (`migration_outline.md` 39). A reader will take `Wrench{Float64}` for Flight.jl's type. Fix: "`Wrench` is FlightPhysics' force-and-torque type, which the migration parametrizes by its scalar."
- **"Contributors are ragged, each publishing only the quantities it has."** D-037 says contributors *have* different quantities. It does not say what they *publish*. The added clause states a publishing rule. Fix: "Contributors are ragged, each having only some of the three quantities."

The other added items are fine:
- The roadmap.
- The glosses for contract, leaf walk, root input, assembly, guarded addition and constant source. Each matches its Appendix D entry.
- The "inside the assembly…" clause, which the brief orders.
- The D-084 sentence.
- The `Systems` sentence. It is checked against FlightApps' `Systems` (`c172.jl` 678: `aero`, `ldg`, `pwp`, among others) and §8.8 3624. "Include" keeps it non-exhaustive, and it describes the sketch.

## Minor
- **C-076.** "The zero total *thus* becomes declared structure." The old "Why." made this the reason for the rule. D-143's Rationale calls it "the argument". "Thus" recasts it as a consequence. This is acceptable, or write "The spelling makes the zero total declared structure."
- **"instead of none" for "instead of zero".** The meaning is the same: zero levels edited, D-037's "zero-edit convenience".

## Citations
Every old citation survives.
- D-007 is gone (F9). Its content is covered by D-037 Rejected bullet 1.
- §3.3 became §8.6, where `output_wires` is.
- D-037 moved inside the fold-order bullet to the bold sentence.

Added citations, checked against the log:
- D-311 bullet 2 carries the Bool gates. Bullet 1 carries "infers `F`".
- D-062 Position bullet 3 carries the seed ("ships as ordinary components").
- D-313 Position carries the growth by judgement.
- D-084 Position carries the D-084 sentence.
- D-143 Position carries the spelling, and its clarification (i) carries the opposite-of-default sentence.
- The §6.1 pointer is good. §6.1 states "exactly one" at spec 1339.

## Bold
There are 7 bolds. Each is a ruling headline, cited in its own sentence, and none is doubled.
- D-037 has four bolds: the rule, fold order, the idiom and the sugar.
- D-311 has one.
- D-143 has two.

No bold falls on mechanism, consequence, definition or lead-in.

## Moves
- The roadmap is done.
- M7 is done.
- "replace the tree walk" now comes after the example. "The ports a junction sums" gives it an antecedent.

No other moves were made. Define-before-use holds.

## R3 and the F-corrections
Each R3 clause matches its source:
- `get_*_b` (`dynamics.jl` 328–393, generated sums over submodels).
- "FlightPhysics' tree walk".
- The Cessna 172 (FlightApps `c172`).
- `Vehicle{NoVehicleSystems}` (`aircraftbase.jl` 27–53).
- `VehicleDynamics` (`dynamics.jl` 406, totals in `DynamicsU`).
- The equations of motion.
- The loads monitor.

F1, F5, F7, F8, F9, F15, F18, F19, F20 and the `F` clause are all applied. D-007 appears nowhere.

## Reader-cold names
- **Class 1 (Flight.jl machinery):** none left unintroduced. FlightPhysics is introduced in §1, at spec 186.
- **Sketch child `dynamics`** (`dynamics/wr_ext`) is never introduced. This is the old wording, tied to F6. Leave it, or add "and a `dynamics` child" to the `Systems` sentence once F6 is ruled.
- **Class 2:** none outstanding.
- **Class 3:** none.

## Re-check (R11 to R14)

R11 to R14 are all clean, and `check_unit.py ch06 check C` reports 0 failures.

- **R11 (line 73).** All three mistakes that follow concern the junction's slots: `in4`, the double-wired slot and the stale arity. The D-084 sentence now falls outside the scoped lead, so the contradiction is gone. Cosmetic: line 73 runs past the wrap width. Reflow it.
- **R12 (lines 32–33).** §7.2 defines the walked class as payload and value types constructed during evaluation, with FlightPhysics' `FrameTransform` as its example. `migration_outline.md` 37–39 lists `Wrench` in that class. "Its scalar type" matches the `Float64` in `Wrench{Float64}`. The §7.2 citation covers only the class, and the migration outline backs `Wrench`'s membership. That scope is fine.
- **R13 (line 123).** "The three quantities" refers back to the sentence before it. The clause now claims only what D-037's census says.
- **R14 (lines 55–58).** The `dynamics` child matches `"wr_sum/out" => "dynamics/wr_ext"`. "The total" reads as the junction's sum, which is correct. A small snag: "no dynamics of its own" sits right before a child named `dynamics`. It does not contradict, but it reads oddly. It could be reworded to "no equations of its own", but only if the glossary's wording allows that.
- **Inventory.** C-023 is tagged R11 and C-058 is tagged R13. Their spans and the four `added` entries match `new.md` word for word.
