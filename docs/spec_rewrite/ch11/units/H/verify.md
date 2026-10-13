# Unit H (§11.7): cold verification

**Counts.** 98 inventory claims: 98 MATCH, 0 DRIFT, 0 LOST. 71 phase-1 assertions. 31 additions: glosses, labels, R11 and R16 clauses, the block and its lead-in. None changes meaning. `check_unit.py` prints 0 failures.

**Added sentences with content.** Only "The roster (…) is frozen for a run, since `attach!` and `detach!` are stopped-sim operations (§11.3)". The glossary entry *roster* carries the same causal link, so it holds. R16's clause restates only D-026's Rejected item (log 935–936). It adds nothing from the "motivating contest" half, which old 8167 already carries.

**Citations.** Every old citation survives with its claim. I checked each added citation in the frozen log:
- D-026, Position: "own ports", "first-class read-only rendering" and "own-pending-else-snapshot peek" are each a ruling separated by semicolons. The R16 clause rests on the Rejected item.
- D-045: bullet 1 carries the liveness lines, with the caveat that it says "slot unclaimed" (rulings.md, question 2). Bullet 5 is the unpokeable ruling, word for word.
- D-047: the first ruling in its Position.
- D-174: Rationale, log 6382–6383.
- D-270: Position sentence 1 is the two halves. Bullets 1, 2 and 3 are `port_views`, `pending` and `incumbent_status`. Bullet 4 is the drain-to-publication window.

All hold.

**Bold.** Nine bolds, each cited to the entry that rules it.
- D-270 has four bolds on four separate rulings (sentence 1, bullets 1–3). Bullet 4 and "nothing else" stay plain. The one-bold test passes.
- D-026 has two bolds on two separate rulings. D-045 has two, on bullets 1 and 5.
- The liveness ruling is bolded once ("live exactly when"). "Liveness is a derived property" is now plain.
- No bold sits on a mechanism or lead-in.

Cross-check: I grepped all units' new.md and the frozen spec for bolds on these entries.
- D-026 and D-270: bold nowhere else.
- D-045: bold elsewhere only on other rulings. Unit D bolds bullets 2 and 3, and §4.3 (frozen 931) bolds a Rejected item.
- D-047: bold elsewhere only on other rulings (units B and C).
- D-174: bold in units C and G2. Unit H cites it plain.
- Forward note: frozen §12.2 at 8543 has a **Rule.** label citing D-270 (`orphaned` is exactly `:done`). If chapter 12's rewrite makes that a bold headline, check it against unit H's `incumbent_status` bold (bullet 3).

**Moves.** I found only survey 2's order (one context sentence, five `####` labels) and the ruled insertions. Nothing else moved.

**R18.** `src/devices.jl` 150, 296, 337 and 352 match the four calls, in the order of the text. The docstrings agree on `Some`/`nothing` and on `WriterStatus | nothing`.

**F65.** I checked all four sites against the drain glossary and the `pending` docstring. Each one means the staging cell:
- old 8146, own cell peek
- 8213, batch published into it
- 8216, read-only view skips it
- 8221, drain takes it

"Producer's cell" (8195, 8215–8216) is a signal-table cell and correctly stays bare.

**Table.** Identical to the old one, checked by diff.

**Glossary.** Every gloss checked against frozen Appendix D claims nothing extra. The claim gloss says "root inputs" where the glossary says "faces", which is justified in rulings.md. "peeks" at old 8097–8099 carries the link and the gloss "the GUI display rule, specified below". Each term is linked once.

**Define-before-use (minor).**
- `World` is used at new 71. Its introducing sentence comes two lines later (73–74). Fix: make it a clause at first use: "a scripted `World` (the example assembly of pure composition that [§8.8] introduces) wires …".
- `T16000M`: the separate sentence at 121–122 sits between the label and "beside that fact", so "that fact" could now attach to the type sentence. Fix: put the clause inside the label sentence, or right after the quoted label.

**R11 clauses.**
- `Cessna172Xv1`: `FlightApps/src/c172/c172x/c172x1.jl` 16 defines it as a `Cessna172X` alias. The claim of "first variant" comes from R11.
- `T16000M`: `FlightCore/src/joysticks.jl` 281.
- `World`: frozen spec 3837, in §8.8.

None of the three claims more than its source.

**Reader-cold names** (all unchanged from old):
- `GUI.draw!`: class 3, FlightCore's style named.
- `input_slider!`: neither FlightCore nor Redstone source has it. It is illustrative, so it should be called "an illustrative widget function".
- `Layout` as a type appears only here in the spec. It is a Redstone src name, unintroduced.
- `Structure` is defined in §9.2, not nearby.
- `pending.md` is used as if known.

None of these is class 1 or 2.

## Re-check (after the four fixes)

`check_unit.py ch11 check H` prints 0 failures. The inventory carries each new span, either in C-031, C-059 and C-092 or in `added`.

- **`T16000M`.** The clause now sits inside the label's parenthetical. "That fact" again points at the task's death. One parenthetical, plus the citation.
- **`World`.** The clause is at first use, one parenthetical. Read alone, "A scenario component is the home of a sim-time script" holds against the glossary. It sits between the build-time and run-start sentences, but "the switch" is named explicitly, so the antecedent holds.
- **`input_slider!`.** Fine.
- **`pending.md`.** The gloss "the implementation's list of open items" is a little off. Frozen spec 223 says `pending.md` "records what the implementation still owes this document and the questions the design leaves open". Fix: "(`pending.md`, the list of what the implementation still owes and the questions the design leaves open)", or "the project's list of open items".

No other breakage.

## Re-check 2

The `pending.md` gloss matches frozen spec 223 ("records what the implementation still owes this document and the questions the design leaves open"). It drops only "this document", which changes no meaning. C-092 and `added` carry it. `check_unit.py` prints 0 failures. A nit: two "which" clauses now sit back to back. The second still refers to the half, because the parenthetical closes first.
